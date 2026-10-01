import SwiftUI

/// The send as it will be signed, or why it will not be. Every figure is the core's. The recipient
/// is shown whole, since a look-alike forges the ends. The core signs once the owner confirms.
struct AccountReviewView: View {
    @EnvironmentObject private var store: WalletStore
    let review: PublicReview

    var body: some View {
        if let refusal = review.refusal {
            Statement(text: refusal)
        } else {
            let unit = amountUnit(coin: review.coin)
            Label(text: "To")
            ValueBlock(value: review.to)
            Facts {
                Fact(name: "from", value: store.state.activeName)
                Fact(name: "you send", value: "\(review.amount) \(unit)")
                Fact(name: "arrives", value: "\(review.arrives) \(unit)")
                if review.coin == .nox {
                    Fact(name: "token fee", value: "\(review.tokenFee) NOX, "
                        + "\(review.tokenFeePercent)%")
                }
                Fact(name: "network fee, at most", value: "\(review.maxNetworkFee) ETH")
                Fact(name: "gas", value: "\(review.gasLimit) at \(review.maxFeePerGasGwei) gwei")
                Fact(name: "nonce, chain", value: "\(review.nonce), \(review.chainId)")
            }
            if review.toIsContract {
                Lead(text: "The recipient is a contract. Make sure it accepts "
                    + "\(unit), or what is sent may be stuck there.")
            }
            Action(title: store.state.busy == .sending ? "Sending" : "Confirm and send",
                   enabled: store.state.busy == .idle, run: store.confirmSend)
        }
        Action(title: "Change it", filled: false, enabled: store.state.busy == .idle,
               run: store.clearSend)
    }
}
