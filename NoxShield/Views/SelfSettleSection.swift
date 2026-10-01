import SwiftUI

/// Landing the spend from this account, said plainly: it works without anyone else, and it names
/// the account in public next to this spend. The fee in the proof comes back to the account.
struct SelfSettleSection: View {
    @EnvironmentObject private var store: WalletStore

    var body: some View {
        if let review = store.state.selfSettle {
            if let refusal = review.refusal {
                Statement(text: refusal)
            } else {
                Facts {
                    Fact(name: "from", value: store.state.activeName)
                    Fact(name: "network fee, at most", value: "\(review.maxNetworkFee) ETH")
                }
                Action(title: store.state.busy == .sending ? "Sending" : "Confirm and settle",
                       enabled: store.state.busy == .idle, run: store.confirmSelfSettle)
            }
        } else {
            Lead(text: "Settling it yourself sends it from your public account, which links that "
                + "account to this spend in public.")
            Action(title: "Settle it yourself", filled: !store.hasLander || store.state.notLanded,
                   enabled: store.state.busy == .idle, run: store.reviewSelfSettle)
        }
    }
}
