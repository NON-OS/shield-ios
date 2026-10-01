import SwiftUI

/// The machine's own line, at the bottom of every screen.
struct StatusLine: View {
    let parts: [String]

    var body: some View {
        Text(parts.joined(separator: "  ·  "))
            .font(.value(10))
            .tracking(0.6)
            .foregroundStyle(Palette.darkMuted)
            // Wrapped rather than cut, which lost the build at the default size on a phone.
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, Room.side)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
