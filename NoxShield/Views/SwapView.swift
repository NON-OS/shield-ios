import SwiftUI

/// Swapping between ETH, NOX and USDC on mainnet, in three states: the form, the core's review, and
/// what was sent. A token going in first needs an approval for the amount, reviewed the same way.
struct SwapView: View {
    @EnvironmentObject private var store: WalletStore
    let onBack: () -> Void

    var body: some View {
        ScreenFrame(
            heading: Heading(number: "03", title: "Swap"),
            failure: store.state.failure,
            onDismissFailure: store.dismissFailure,
            onBack: onBack,
            status: Status.of(store.state),
            backdrop: .send
        ) {
            RealMoney(network: store.state.network)
            if !networkHasSwaps(network: store.state.network) {
                Statement(text: "Swaps run on Ethereum mainnet, where the pools are.")
                Action(title: "Switch to Ethereum") { store.choose(.mainnet) }
            } else if let sent = store.state.sent {
                AccountSentView(sent: sent, onDone: afterSent)
            } else if let swap = store.state.swap {
                SwapReviewView(swap: swap)
            } else {
                SwapForm()
            }
        }
    }

    /// After an approval, back to the form to review the swap itself.
    private func afterSent() {
        if store.state.swap?.approval == true {
            store.clearSwap()
        } else {
            onBack()
        }
    }
}
