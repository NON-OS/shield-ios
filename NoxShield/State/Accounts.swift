import Foundation

/// How an account is named on screen: counted from 1, from the key at index 0.
func accountName(_ index: UInt32) -> String { "Account \(index + 1)" }

extension UiState {
    /// The active account, named, for every screen that says whose money it shows.
    var activeName: String { accountName(accountList.first(where: \.active)?.index ?? 0) }
}

/// The accounts of this wallet: adding one, choosing one, and after a restore, finding them.
extension WalletStore {
    /// Add the next account. The core opens the vault again, so the device confirms the owner.
    func addAccount() {
        guard let wallet else { return }
        let handle = Handle(wallet)
        run(.unlocking, work: { try handle.value.addAccount() }, then: { [weak self] _ in
            self?.switched()
        })
    }

    func selectAccount(_ index: UInt32) {
        guard let wallet else { return }
        let handle = Handle(wallet)
        let work = { try handle.value.selectAccount(index: index) }
        run(.reading, work: work, then: { [weak self] _ in
            self?.switched()
        })
    }

    /// Forget what the last account showed, then read the new one. No review outlives a switch.
    private func switched() {
        HandoffRecord.save(nil)
        mutate {
            $0.accounts = [:]
            $0.review = nil
            $0.sent = nil
            $0.sentStatus = nil
            $0.swap = nil
            $0.deposit = nil
            $0.spend = nil
            $0.relay = nil
            $0.relayState = nil
            $0.shielding = nil
        }
        refresh()
    }

    /// After a restore, look over Tor for the other accounts the words were used with. A failure
    /// leaves the first account, and the owner can add the others by hand.
    func findAccounts() {
        guard let wallet else { return }
        let handle = Handle(wallet)
        let search = { Result { try handle.value.findAccounts() } }
        watchSearch(handle)
        run(.finding, work: search, then: { [weak self] found in
            self?.refresh()
            if case .failure = found {
                self?.mutate {
                    $0.failure = "The other accounts could not be looked for. Add them in Accounts."
                }
            }
        })
    }
}
