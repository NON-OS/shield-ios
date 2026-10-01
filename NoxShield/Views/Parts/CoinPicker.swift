import SwiftUI

/// Which coin a form is about, as one action per coin of which the chosen one is filled.
struct CoinPicker: View {
    @Binding var coin: Coin
    /// The coins offered: all three for the public account, ETH and NOX for the shield, which holds
    /// no USDC.
    var coins: [Coin] = [.nox, .eth]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(coins, id: \.self) { choice in
                Action(title: amountUnit(coin: choice), filled: coin == choice) { coin = choice }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Coin, \(amountUnit(coin: coin)) chosen")
    }
}
