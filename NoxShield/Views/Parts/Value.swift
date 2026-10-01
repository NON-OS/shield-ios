import SwiftUI

/// A value the app is showing to be read off the screen: an address, a hash, a path. Its length
/// is shown so a reader knows they have all of it.
struct ValueBlock: View {
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(Groups.grouped(value))
                .font(.value(12))
                .lineSpacing(6)
                .foregroundStyle(Palette.darkText)
                .textSelection(.disabled)
            Text("\(value.count) characters")
                .font(.value(12))
                .foregroundStyle(Palette.darkMuted)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: Edge.corner))
        .overlay(
            RoundedRectangle(cornerRadius: Edge.corner)
                .stroke(Palette.darkLine, lineWidth: Edge.hair)
        )
    }
}
