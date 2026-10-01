import Foundation

/// Moving between screens the user drives, instead of the core. A failure is cleared on the move,
/// since it belongs to the screen that produced it.
extension WalletStore {
    func show(_ stage: Stage) {
        mutate { $0.stage = stage; $0.failure = nil }
    }
}
