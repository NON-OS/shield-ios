import SwiftUI

/// The swap as it will be signed, or why it will not be: what is paid and what comes back up top,
/// then every term of the trade in one card, the way an exchange shows it.
struct SwapReviewView: View {
    @EnvironmentObject private var store: WalletStore
    let swap: PublicSwap

    var body: some View {
        if let refusal = swap.refusal {
            Statement(text: refusal)
        } else {
            if swap.approval {
                Statement(text: "First, let Uniswap take exactly \(swap.amountIn) "
                    + "\(amountUnit(coin: swap.from)). Then review the swap again.")
            }
            Tile {
                CoinRow(
                    coin: swap.from, amount: swap.amountIn, note: "\(store.state.activeName) pays"
                )
                Rule()
                CoinRow(coin: swap.to, amount: "≈ " + swap.expectedOut, note: "You receive")
            }
            SwapTerms(swap: swap)
            Action(title: store.state.busy == .sending ? "Sending" : confirm,
                   enabled: store.state.busy == .idle, run: store.confirmSwap)
        }
        Action(title: "Change it", filled: false, enabled: store.state.busy == .idle,
               run: store.clearSwap)
    }

    private var confirm: String { swap.approval ? "Confirm approval" : "Confirm swap" }
}
