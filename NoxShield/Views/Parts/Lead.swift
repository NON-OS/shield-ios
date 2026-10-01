import SwiftUI

/// The single sentence a screen is allowed.
struct Lead: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.sans(14))
            .foregroundStyle(Palette.darkMuted)
            .fixedSize(horizontal: false, vertical: true)
    }
}
