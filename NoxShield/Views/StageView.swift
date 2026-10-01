import SwiftUI

/// The screen for the stage the core is in.
struct StageView: View {
    @EnvironmentObject private var store: WalletStore

    var body: some View {
        switch store.state.stage {
        case .opening, .needsWallet:
            WelcomeView(opening: store.state.stage == .opening)
        case .showingPhrase:
            PhraseView()
        case .restoring:
            RestoreView()
        case .locked, .keyGone:
            LockedView()
        case .ready:
            BalanceView()
        case .measuring:
            MeasureView()
        case .showingLicences:
            LicencesView()
        }
    }
}
