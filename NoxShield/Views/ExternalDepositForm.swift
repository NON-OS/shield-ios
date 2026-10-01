import SwiftUI

/// A deposit signed in another EVM wallet: the core checks the live pool and builds the calldata,
/// and this screen only shows and copies it.
struct ExternalDepositForm: View {
    @EnvironmentObject private var store: WalletStore
    @Binding var coin: Coin
    @Binding var amount: String
    @State private var from = ""

    var body: some View {
        Group {
            Lead(text: "The EVM address you will send from, and how much. The pool is checked "
                + "first, and nothing is kept if it would refuse.")
            CoinPicker(coin: $coin)
            Field(label: "From EVM address", text: $from)
            Field(label: "Amount in \(amountUnit(coin: coin))", text: $amount, typing: .amount)
            Action(
                title: store.state.busy == .depositing ? "Reading the pool" : "Check the pool",
                enabled: store.state.busy == .idle && !amount.isEmpty && !from.isEmpty,
                run: { store.prepareDeposit(coin: coin, amount: amount, from: from) }
            )
        }
        .onAppear { if from.isEmpty { from = store.state.account } }
    }
}
