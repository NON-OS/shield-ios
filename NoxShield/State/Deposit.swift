import Foundation

/// A deposit from the user's own EVM wallet. The core checks it against the live pool and writes
/// the note to disk before returning a transaction.
extension WalletStore {
    func prepareDeposit(coin: Coin, amount: String, from: String) {
        guard let wallet else { return }
        let handle = Handle(wallet)
        run(.depositing, work: {
            try handle.value.prepareDeposit(coin: coin, amount: amount, depositor: from)
        }, then: { [weak self] ticket in
            self?.mutate { $0.deposit = ticket; $0.busy = .idle }
        })
    }

    func clearDeposit() {
        mutate { $0.deposit = nil }
    }

    /// Copy one field of a ticket, local to this device and cleared a minute later.
    func copyValue(_ text: String) {
        Task { @MainActor in
            await copyThenClear(
                clip: SystemClip(),
                address: text,
                onCopied: { _ in },
                wait: Wait { seconds in try? await Task.sleep(for: .seconds(seconds)) }
            )
        }
    }
}
