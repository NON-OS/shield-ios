import SwiftUI

/// What a public send needs: which coin, where, and how much. The core reads every field and the
/// chain before anything is shown.
struct AccountSendForm: View {
    @EnvironmentObject private var store: WalletStore
    @State private var coin: Coin = .nox
    @State private var to = ""
    @State private var amount = ""

    var body: some View {
        Group {
            CoinPicker(coin: $coin, coins: [.nox, .eth, .usdc])
            Field(label: "To 0x address", text: $to)
            Field(label: "Amount in \(amountUnit(coin: coin))", text: $amount, typing: .amount)
            if let held {
                Lead(text: "This account holds \(held) \(amountUnit(coin: coin)) on "
                    + "\(store.state.network.name).")
            }
            Action(title: store.state.busy == .reviewing ? "Working it out" : "Review",
                   enabled: ready) {
                store.reviewSend(coin: coin, to: to, amount: amount)
            }
        }
    }

    private var held: String? {
        guard let here = store.state.publicHere else { return nil }
        switch coin {
        case .eth: return here.eth
        case .nox: return here.nox
        case .usdc: return here.usdc
        }
    }

    private var ready: Bool {
        store.state.busy == .idle && !to.isEmpty && !amount.isEmpty
    }
}
