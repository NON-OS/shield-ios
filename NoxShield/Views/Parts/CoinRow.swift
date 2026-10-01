import SwiftUI

/// One coin in a list: its mark, its symbol with a quiet line under it, and the amount on the right
/// in the figures face.
struct CoinRow: View {
    let coin: Coin
    let amount: String
    var note: String = ""

    var body: some View {
        HStack(spacing: 14) {
            CoinLogo(coin: coin, side: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text(amountUnit(coin: coin))
                    .font(.sans(17, .medium))
                    .foregroundStyle(Palette.darkText)
                if !note.isEmpty {
                    Text(note)
                        .font(.sans(12))
                        .foregroundStyle(Palette.darkMuted)
                }
            }
            Spacer(minLength: 0)
            Text(verbatim: amount)
                .font(.sans(19, .medium))
                .monospacedDigit()
                .foregroundStyle(Palette.darkText)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .accessibilityElement(children: .combine)
    }
}
