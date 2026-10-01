import SwiftUI

/// The NØNOS icon from the brand kit, drawn from its vectors as a template, so a tint decides the
/// colour, one asset serves every surface at any size, and it stays sharp.
struct Mark: View {
    var side: CGFloat = 28

    var body: some View {
        Image("NonosIcon")
            .renderingMode(.template)
            .resizable()
            .aspectRatio(188.0 / 204.0, contentMode: .fit)
            .frame(height: side)
            .foregroundStyle(Palette.cyan)
            // Hidden from VoiceOver, since the label beside it already says NØNOS.
            .accessibilityHidden(true)
    }
}
