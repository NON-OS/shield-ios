import SwiftUI

/// Sending and withdrawing, in three states: the form, the proof in progress, and the sealed spend
/// waiting for a relayer. Both are proved on this phone and settled by a relayer for its fee.
struct SpendView: View {
    @EnvironmentObject private var store: WalletStore
    let withdraw: Bool
    let onBack: () -> Void

    var body: some View {
        ScreenFrame(
            heading: Heading(number: "03", title: withdraw ? "Withdraw" : "Send"),
            failure: store.state.failure,
            onDismissFailure: store.dismissFailure,
            onBack: onBack,
            status: Status.of(store.state),
            backdrop: withdraw ? .withdraw : .send
        ) {
            if store.state.busy == .proving || store.state.busy == .cancelling {
                ProvingNotice()
            } else if let ticket = store.state.spend {
                SpendTicketView(ticket: ticket, onDone: onBack)
            } else {
                SpendForm(withdraw: withdraw)
            }
        }
    }
}
