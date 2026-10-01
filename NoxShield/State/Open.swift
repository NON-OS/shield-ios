import Foundation

/// Opening the stored wallet, or offering to make one. Everything a cold start needs is read in
/// one go, so no screen renders a half opened wallet.
extension WalletStore {
    /// Open the stored wallet, or offer to make one.
    func open() {
        do {
            let opened = try CoreWallet.open()
            self.opened(opened)
            let stored = opened.stored()
            let holder = Custody.holder()
            let confirms = Custody.canConfirmOwner()
            let integrity = Integrity.now()
            mutate {
                $0.stage = stored ? .locked : .needsWallet
                $0.busy = .idle
                $0.holder = holder
                $0.canConfirmOwner = confirms
                $0.idle = Locking.load()
                $0.recordingAllowed = Recording.load()
                $0.integrity = integrity
                $0.threads = Threads.load()
            }
        } catch {
            failed(error)
        }
    }
}
