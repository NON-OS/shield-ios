import Foundation

/// Destroying this wallet on this device. The core removes the sealed seed and the note log, then
/// the keychain key goes, even when the files were already gone. It cannot be undone, and only
/// the recovery phrase brings the wallet back.
extension WalletStore {
    func wipe(reason: String? = nil) {
        guard let wallet else { return }
        let handle = Handle(wallet)
        run(.unlocking, work: {
            _ = try handle.value.wipe()
            HandoffRecord.save(nil)
            return Keychain.destroyWrappingKey()
        }, then: { [weak self] keyGone in
            self?.mutate { state in
                let confirms = state.canConfirmOwner
                state = UiState()
                state.stage = .needsWallet
                state.canConfirmOwner = confirms
                state.failure = reason
                if !keyGone {
                    state.failure = "The seed and the notes are gone. The key that sealed "
                        + "them could not be removed from the keychain, so report this "
                        + "rather than reusing the device for a new wallet."
                }
            }
        })
    }
}
