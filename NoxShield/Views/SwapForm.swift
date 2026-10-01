import SwiftUI

/// What a swap needs, as the familiar pair of boxes: what is paid, with Max, a flip between them,
/// what comes back, and the slippage allowed.
struct SwapForm: View {
    @EnvironmentObject private var store: WalletStore
    @State private var from: Coin = .eth
    @State private var to: Coin = .nox
    @State private var amount = ""
    @State private var slippage: UInt16 = 50

    var body: some View {
        Group {
            SwapBox(title: "You pay", coin: $from) {
                TextField("0", text: $amount)
                    .font(.sans(28, .medium))
                    .keyboardType(.decimalPad)
                    .accessibilityLabel("Amount you pay")
                    .foregroundStyle(Palette.darkText)
                Button("Max") { store.fillMax(from) { amount = $0 } }
                    .font(.sans(13, .medium))
                    .foregroundStyle(Palette.cyan)
                    .disabled(store.state.busy != .idle)
            }
            HStack {
                Spacer()
                Button { (from, to) = (to, from) } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Palette.darkText)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Palette.dark3))
                }
                .accessibilityLabel("Flip")
                Spacer()
            }
            SwapBox(title: "You receive", coin: $to) {
                Text("Quoted on review")
                    .font(.sans(15))
                    .foregroundStyle(Palette.darkMuted)
            }
            SlippageMenu(bps: $slippage)
            Action(title: store.state.busy == .reviewing ? "Reading the pools" : "Review swap",
                   enabled: store.state.busy == .idle && !amount.isEmpty && from != to) {
                store.reviewSwap(from: from, to: to, amount: amount, slippageBps: slippage)
            }
        }
    }
}
