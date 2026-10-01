import SwiftUI

/// The first screen: create a wallet or restore one.
struct WelcomeView: View {
    @EnvironmentObject private var store: WalletStore
    let opening: Bool

    var body: some View {
        ScreenFrame(
            heading: Heading(number: "01", title: "N\u{00D8}NOS"),
            failure: store.state.failure,
            onDismissFailure: store.dismissFailure,
            status: Status.of(store.state),
            backdrop: .welcome,
            content: {
            Logo(height: 44)
            Statement(text: "Shielded NOX. The keys never leave this phone.")
            Lead(
                text: "The balance is worked out here, from the pool itself, read over "
                    + "Tor. No server is told which notes are yours."
            )
            if opening {
                Lead(text: "Opening")
            }
            IntegrityNote(finding: store.state.integrity)
        },
            footer: {
                if !opening {
                    start
                }
            }
        )
    }

    @ViewBuilder private var start: some View {
        if !store.state.canConfirmOwner {
            Lead(
                text: "Set a passcode on this device first. The keychain will not seal "
                    + "a seed without one."
            )
        }
        Action(
            title: "Create a wallet",
            enabled: store.state.canConfirmOwner,
            run: store.create
        )
        Action(
            title: "Restore from a phrase",
            filled: false,
            enabled: store.state.canConfirmOwner
        ) {
            store.show(.restoring)
        }
    }
}
