import SwiftUI

/// Moving NOX or ETH into the shield on Sepolia, from this wallet's own account by default. The
/// core checks the live pool and works out every transaction, and the owner confirms each one.
struct DepositView: View {
    @EnvironmentObject private var store: WalletStore
    let onBack: () -> Void

    @State private var coin: Coin = .nox
    @State private var amount = ""
    @State private var external = false

    var body: some View {
        ScreenFrame(
            heading: Heading(number: "03", title: "Deposit"),
            failure: store.state.failure,
            onDismissFailure: store.dismissFailure,
            onBack: { store.clearShield(); onBack() },
            status: Status.of(store.state),
            backdrop: .deposit
        ) {
            RealMoney(network: .sepolia)
            if let ticket = store.state.deposit {
                DepositTicketView(ticket: ticket, coin: coin, onDone: onBack)
            } else if external {
                ExternalDepositForm(coin: $coin, amount: $amount)
            } else if let sent = store.state.sent, let review = store.state.shielding {
                ShieldSentView(sent: sent, approval: review.approval,
                               next: { store.reviewShield(coin: coin, amount: amount) },
                               onDone: { store.clearShield(); onBack() })
            } else if let review = store.state.shielding {
                ShieldReviewView(review: review, unit: amountUnit(coin: coin))
            } else {
                form
            }
        }
    }

    private var form: some View {
        Group {
            Lead(text: "From \(store.state.activeName), signed here. The pool is checked first, "
                + "and nothing is sent if it would refuse.")
            CoinPicker(coin: $coin)
            Field(label: "Amount in \(amountUnit(coin: coin)): \(sizes)", text: $amount,
                  typing: .amount)
            Action(
                title: store.state.busy == .reviewing ? "Reading the pool" : "Review",
                enabled: store.state.busy == .idle && !amount.isEmpty,
                run: { store.reviewShield(coin: coin, amount: amount) }
            )
            Quiet(title: "Deposit from another wallet instead") { external = true }
        }
    }

    private var sizes: String {
        coin == .eth ? "0.01, 0.02, 0.05 and so on" : "1,000, 2,000, 5,000 and so on"
    }
}
