import SwiftUI

/// The way back, in the single place a thumb looks for it.
struct Back: View {
    let run: () -> Void

    var body: some View {
        Button(action: run) {
            Image(systemName: "chevron.left")
                .font(.system(size: 17 * Font.scale, weight: .medium))
                .foregroundStyle(Palette.darkMuted)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}
