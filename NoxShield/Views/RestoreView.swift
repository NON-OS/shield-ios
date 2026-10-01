import SwiftUI

/// Restoring from recovery words, or from a private key. The core owns the word list, the checksum
/// and the check that a key is a real one.
struct RestoreView: View {
    @EnvironmentObject private var store: WalletStore
    @State private var text = ""
    @State private var byKey = false

    var body: some View {
        ScreenFrame(
            heading: Heading(number: "01", title: "Restore a wallet"),
            failure: store.state.failure,
            onDismissFailure: store.dismissFailure,
            onBack: { store.show(.needsWallet) },
            status: Status.of(store.state),
            backdrop: .backup,
            content: {
            if byKey {
                Statement(text: "Paste the private key.")
                Lead(text: "64 hex digits, 0x optional. The wallet gets one account, and the key "
                    + "stays its backup.")
                Field(label: "Private key", text: $text, oneLine: false)
            } else {
                Statement(text: "Type the recovery words: 12, 15, 18, 21 or 24.")
                Lead(text: "In order, separated by spaces. The core owns the word list and the "
                    + "checksum.")
                Field(label: "Recovery phrase", text: $text, oneLine: false)
            }
            Quiet(title: byKey ? "Use recovery words instead" : "Use a private key instead") {
                byKey.toggle()
                text = ""
            }
            if store.state.busy == .finding {
                Lead(text: "Looking over Tor for the other accounts these words were used with. "
                    + "Looked at \(store.state.searched) so far.")
            }
        },
            footer: {
                Action(title: "Restore", enabled: !text.isEmpty, run: restore)
            }
        )
    }

    private func restore() {
        if byKey {
            store.restoreFromKey(text.trimmingCharacters(in: .whitespacesAndNewlines))
        } else {
            store.restore(words: text.split(whereSeparator: \.isWhitespace).map(String.init))
        }
    }
}
