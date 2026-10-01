import SwiftUI

/// One of the four things a holder does from home: a circle with its sign and a word under it.
struct RoundAction: View {
    let title: String
    let symbol: String
    var enabled: Bool = true
    let run: () -> Void

    var body: some View {
        Button(action: run) {
            VStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 56, height: 56)
                    .foregroundStyle(enabled ? Palette.ink : Palette.darkMuted)
                    .background(Circle().fill(enabled ? Palette.cyan : Color.clear))
                    .overlay(Circle().stroke(enabled ? Color.clear : Palette.darkLine))
                Text(title)
                    .font(.sans(13, .medium))
                    .foregroundStyle(enabled ? Palette.darkText : Palette.darkMuted)
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(!enabled)
        .accessibilityLabel(title)
    }
}
