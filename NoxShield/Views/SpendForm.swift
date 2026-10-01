import SwiftUI

/// What a spend needs: where it goes and how much. The relayer and its fee are the pool's, the same
/// for everyone, so nothing about them is typed. The core checks every field and the amount.
struct SpendForm: View {
    @EnvironmentObject private var store: WalletStore
    let withdraw: Bool

    @State private var coin: Coin = .nox
    @State private var to = ""
    @State private var amount = ""

    var body: some View {
        if let early = store.state.tooSoon {
            EarlyConfirm(order: early)
        } else {
            Group {
                Lead(text: "The proof hides who paid whom and how much. Deposits and withdrawals "
                    + "are public standard amounts.")
                CoinPicker(coin: $coin)
                Field(label: withdraw ? "To EVM address" : "To wallet address", text: $to,
                      oneLine: withdraw)
                    .onChange(of: to) { _, typed in
                        if withdraw { store.checkUsed(typed) } else { store.checkTarget(typed) }
                    }
                Field(label: "Amount in \(unit): \(sizes)", text: $amount, typing: .amount)
                WithdrawNote(withdraw: withdraw, to: to)
                FromNote(withdraw: withdraw)
                Lead(text: withdraw
                    ? "Fee: 0.50% of the amount and a network part, paid from the shield."
                    : "Fee from \(relayFee(coin: coin)) \(unit), the same for everyone, with a "
                        + "network part that follows gas, paid from the shield.")
                Action(title: "Prove and seal", enabled: ready) {
                    store.spend(SpendOrder(coin: coin, to: to, amount: amount, withdraw: withdraw))
                }
            }
            .onAppear(perform: prefill)
        }
    }

    private var unit: String { amountUnit(coin: coin) }

    /// A withdrawal starts on an unused address of this wallet.
    private func prefill() {
        if withdraw && to.isEmpty { to = store.state.freshAddress ?? "" }
    }

    private var sizes: String {
        coin == .eth ? "0.01, 0.02, 0.05, 0.1 and so on" : "1,000, 2,000, 5,000, 10,000 and so on"
    }

    private var ready: Bool { store.state.busy == .idle && !to.isEmpty && !amount.isEmpty }
}
