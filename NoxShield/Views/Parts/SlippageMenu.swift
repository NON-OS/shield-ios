import SwiftUI

/// How far below the quote a swap may land, as one quiet line and a menu.
struct SlippageMenu: View {
    @Binding var bps: UInt16

    var body: some View {
        HStack {
            Text("Max slippage")
                .font(.sans(14))
                .foregroundStyle(Palette.darkMuted)
            Spacer()
            Menu {
                ForEach([UInt16(50), 100, 300], id: \.self) { choice in
                    Button(label(choice)) { bps = choice }
                }
            } label: {
                Text(label(bps))
                    .font(.value(13))
                    .foregroundStyle(Palette.darkText)
            }
        }
    }

    private func label(_ bps: UInt16) -> String {
        "\(bps / 100).\(bps % 100 / 10)%"
    }
}
