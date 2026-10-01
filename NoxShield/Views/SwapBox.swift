import SwiftUI

/// One side of a swap: what it is ("You pay", "You receive"), the coin, and the amount, typed on
/// the paying side and quoted on the receiving side.
struct SwapBox<Trailing: View>: View {
    let title: String
    @Binding var coin: Coin
    @ViewBuilder var amount: Trailing

    var body: some View {
        Tile {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.sans(13))
                    .foregroundStyle(Palette.darkMuted)
                HStack(spacing: 12) {
                    amount
                    Spacer(minLength: 0)
                    CoinMenu(coin: $coin)
                }
            }
            .padding(16)
        }
    }
}
