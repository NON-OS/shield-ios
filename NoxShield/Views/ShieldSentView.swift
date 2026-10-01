import SwiftUI

/// The approval or the deposit on its way. A mined approval leads to the deposit, and a mined
/// deposit says when the note can be spent.
struct ShieldSentView: View {
    @EnvironmentObject private var store: WalletStore
    let sent: PublicSent
    let approval: Bool
    let next: () -> Void
    let onDone: () -> Void

    var body: some View {
        Statement(text: headline)
        Label(text: "Transaction")
        ValueBlock(value: sent.hash)
        Action(title: "Copy link", filled: false) { store.copyValue(sent.link) }
        if approval && store.state.sentStatus == .confirmed {
            Action(title: "Review the deposit", enabled: store.state.busy == .idle, run: next)
        } else if store.state.sentStatus == .confirmed {
            Lead(text: "The note is in the pool. A private send waits for 20 more notes and about "
                + "six hours after it, which the meter on the shield counts down.")
            Action(title: "Done", run: onDone)
        }
    }

    private var headline: String {
        switch store.state.sentStatus {
        case .confirmed: return approval ? "The pool may take it now." : "Shielded."
        case .failed: return "Mined, but it failed. Nothing moved except the network fee."
        default: return (approval ? "Approval" : "Deposit") + " sent. Waiting for a block."
        }
    }
}
