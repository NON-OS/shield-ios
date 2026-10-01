import SwiftUI

/// A send the network has taken, and where it stands. The explorer link is the owner's choice,
/// opened in the browser, never a request this app sends.
struct AccountSentView: View {
    @EnvironmentObject private var store: WalletStore
    let sent: PublicSent
    let onDone: () -> Void

    var body: some View {
        Statement(text: headline)
        Label(text: "Transaction")
        ValueBlock(value: sent.hash)
        HStack(spacing: 12) {
            Action(title: "Copy hash", filled: false) { store.copyValue(sent.hash) }
            Action(title: "Copy link", filled: false) { store.copyValue(sent.link) }
        }
        Action(title: "Done", run: onDone)
    }

    private var headline: String {
        switch store.state.sentStatus {
        case .confirmed: return "Sent and mined."
        case .failed: return "Mined, but it failed. Nothing moved except the network fee."
        default: return "Sent. Waiting for a block."
        }
    }
}
