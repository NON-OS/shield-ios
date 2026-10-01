import Foundation

/// View-only accounts from a pasted view key, and whether a private transfer goes to an account of
/// this wallet. Both are local, so nothing here asks Tor.
extension WalletStore {
    func importViewKey(_ text: String) {
        guard let wallet else { return }
        let handle = Handle(wallet)
        run(.reading, work: { try handle.value.importViewKey(text: text) }, then: { [weak self] _ in
            self?.refresh()
        })
    }

    func forgetViewKey(_ index: UInt32) {
        guard let wallet else { return }
        let handle = Handle(wallet)
        let work = { try handle.value.forgetViewKey(index: index) }
        run(.reading, work: work, then: { [weak self] _ in
            self?.refresh()
        })
    }

    /// Whether `to` is one of this wallet's accounts. Quick, so the form asks as it is typed.
    func checkTarget(_ to: String) {
        guard let wallet else { return }
        let own = (try? wallet.ownAccountOf(address: to)) ?? nil
        let recent = own != nil && ((try? wallet.arrivedRecently()) ?? false)
        mutate { $0.ownTarget = own; $0.arrivedRecently = recent }
    }

    /// Whether a typed withdrawal address was used before, read over Tor off the main thread.
    func checkUsed(_ address: String) {
        guard let wallet, address != state.freshAddress, address.count == 42 else {
            mutate { $0.usedAddress = false }
            return
        }
        let handle = Handle(wallet)
        run(.idle, work: { (try? handle.value.addressUsed(address: address)) ?? false },
            then: { [weak self] used in self?.mutate { $0.usedAddress = used } })
    }
}
