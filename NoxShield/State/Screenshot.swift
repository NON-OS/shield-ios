import Foundation

/// A screenshot taken while the recovery phrase or an exported key is on screen. iOS tells an app
/// a screenshot happened and gives it no way to stop one, so the screen warns while it can still be
/// deleted.
extension UiState {
    /// Whether the words or a key are on screen, which no recording may hold.
    var secretShown: Bool { stage == .showingPhrase || stage == .restoring || exported != nil }
}

extension WalletStore {
    func screenshotTaken() {
        guard state.secretShown else { return }
        mutate {
            $0.failure = "That screenshot is a copy of this wallet. Delete it from Photos "
                + "and from Recently Deleted."
        }
    }
}
