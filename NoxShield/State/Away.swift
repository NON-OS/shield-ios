import Foundation

/// What happens when the wallet stops being on screen: the session drops, since the phone may be
/// seized unlocked. A running call finishes first and the lock follows it, so no background scan
/// keeps the keys open. The vault keeps the words, so a phrase left unconfirmed is shown again
/// in Settings, Recovery words and keys.
extension WalletStore {
    func leftForeground() {
        switch state.stage {
        case .ready, .measuring:
            lock()
        case .showingPhrase:
            mutate { $0.phrase = [] }
            lock()
        case .restoring:
            show(.needsWallet)
        default:
            break
        }
    }
}
