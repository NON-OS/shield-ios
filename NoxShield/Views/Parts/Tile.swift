import SwiftUI

/// A quiet surface for a group of rows: ink with a little light on it, the brand corner and a
/// hairline, so a list of coins or a quote reads as one object instead of as lines floating on the
/// page.
struct Tile<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: Palette.radius))
        .overlay(
            RoundedRectangle(cornerRadius: Palette.radius)
                .stroke(Palette.line, lineWidth: Edge.hair)
        )
    }
}

/// One line of a card: a name on the left, its value on the right.
struct TileRow: View {
    let name: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Text(name)
                .font(.sans(14))
                .foregroundStyle(Palette.darkMuted)
            Spacer(minLength: 0)
            Text(value)
                .font(.value(13))
                .foregroundStyle(Palette.darkText)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
