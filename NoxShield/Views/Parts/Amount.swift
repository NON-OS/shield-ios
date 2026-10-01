import SwiftUI

/// An amount, as the subject of a screen instead of a line of text.
struct Amount: View {
    /// The figure as the core formatted it, and the coin's name.
    let text: String
    let unit: String
    let caption: String
    /// The coin's mark before the figure, when the amount is one coin's.
    var coin: Coin?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 10) {
                if let coin {
                    CoinLogo(coin: coin, side: 28)
                }
                Text(text)
                    .font(.sans(34, .medium))
                    .monospacedDigit()
                    .foregroundStyle(Palette.darkText)
                Text(unit)
                    .font(.sans(15, .medium))
                    .foregroundStyle(Palette.darkMuted)
            }
            Text(caption)
                .font(.sans(13))
                .foregroundStyle(Palette.darkMuted)
        }
        .padding(.vertical, 8)
    }
}
