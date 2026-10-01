import SwiftUI

/// A deposit from this account, worked out by the core: the approval the pool needs first, or the
/// deposit itself, with what the note will hold and the most the network can charge.
struct ShieldReviewView: View {
    @EnvironmentObject private var store: WalletStore
    let review: PublicShield
    let unit: String

    var body: some View {
        if let refusal = review.refusal {
            Statement(text: refusal)
        } else {
            if review.approval {
                Statement(text: "First, let the pool take exactly \(review.amount) \(unit). "
                    + "Then the deposit.")
            }
            Facts {
                Fact(name: "from", value: store.state.activeName)
                Fact(name: "you shield", value: "\(review.amount) \(unit)")
                Fact(name: "pool fee", value: "\(review.poolFee) \(unit)")
                Fact(name: "the note holds", value: "\(review.shielded) \(unit)")
                Fact(name: "network fee, at most", value: "\(review.maxNetworkFee) ETH")
            }
            Action(title: title, enabled: store.state.busy == .idle, run: store.confirmShield)
        }
        Action(title: "Change it", filled: false, enabled: store.state.busy == .idle,
               run: store.clearShield)
    }

    private var title: String {
        if store.state.busy == .sending { return "Sending" }
        return review.approval ? "Confirm approval" : "Confirm and shield"
    }
}
