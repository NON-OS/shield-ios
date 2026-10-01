import SwiftUI

/// The words and the keys of the active account, each shown only after the Secure Enclave
/// confirms the owner. The spend secret alone is never shown: the words are its only backup.
struct KeysPanel: View {
    @EnvironmentObject private var store: WalletStore
    let onBack: () -> Void

    var body: some View {
        ScreenFrame(
            heading: Heading(number: "06", title: "Keys"),
            failure: store.state.failure,
            onDismissFailure: store.dismissFailure,
            onBack: { store.clearExported(); onBack() },
            status: Status.of(store.state),
            backdrop: .backup
        ) {
            if store.state.exported != nil && store.state.captured {
                Lead(text: "Hidden while the screen is recorded. Stop the recording to see it.")
                Action(title: "Done", run: store.clearExported)
            } else if let shown = store.state.exported {
                ExportedView(shown: shown, onCopy: store.copyExported, onDone: store.clearExported)
            } else {
                Lead(text: store.state.fromKey
                    ? "Keys of \(store.state.activeName). It came from a private key, which is "
                        + "its backup."
                    : "Keys of \(store.state.activeName).")
                QuietGroup {
                    if !store.state.fromKey {
                        Quiet(title: "Show the recovery words", enabled: idle, run: store.showWords)
                        QuietRule()
                    }
                    Quiet(title: "Export the account private key", enabled: idle,
                          run: store.exportPublicKey)
                    if viewKeyExport() {
                        QuietRule()
                        Quiet(title: "Export the incoming view key", enabled: idle) {
                            store.exportViewKey(.incoming)
                        }
                        QuietRule()
                        Quiet(title: "Export the full view key", enabled: idle) {
                            store.exportViewKey(.full)
                        }
                    }
                }
                Lead(text: "A view key shows every note of this account, past and future, to "
                    + "whoever holds it. It cannot be revoked. The only way to stop it is to move "
                    + "the value to a new account.")
            }
        }
    }

    private var idle: Bool { store.state.busy == .idle }
}
