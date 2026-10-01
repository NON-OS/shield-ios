import SwiftUI

/// A send from the public account, in three states: the form, the review the core worked out, and
/// what was sent. Nothing is signed until the owner confirms the review on the device.
struct AccountSendView: View {
    @EnvironmentObject private var store: WalletStore
    let onBack: () -> Void

    var body: some View {
        ScreenFrame(
            heading: Heading(number: "03", title: "Send"),
            failure: store.state.failure,
            onDismissFailure: store.dismissFailure,
            onBack: onBack,
            status: Status.of(store.state),
            backdrop: .send
        ) {
            RealMoney(network: store.state.network)
            if let sent = store.state.sent {
                AccountSentView(sent: sent, onDone: onBack)
            } else if let review = store.state.review {
                AccountReviewView(review: review)
            } else {
                AccountSendForm()
            }
        }
    }
}
