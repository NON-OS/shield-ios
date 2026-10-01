import SwiftUI

/// The coin in a swap box: its mark and symbol, and a menu of the three.
struct CoinMenu: View {
    @Binding var coin: Coin

    var body: some View {
        Menu {
            ForEach([Coin.eth, .nox, .usdc], id: \.self) { choice in
                Button(amountUnit(coin: choice)) { coin = choice }
            }
        } label: {
            HStack(spacing: 8) {
                CoinLogo(coin: coin, side: 24)
                Text(amountUnit(coin: coin))
                    .font(.sans(16, .medium))
                    .foregroundStyle(Palette.darkText)
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Palette.darkMuted)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Capsule().fill(Palette.dark3))
        }
        .accessibilityLabel("Coin: \(amountUnit(coin: coin))")
    }
}
