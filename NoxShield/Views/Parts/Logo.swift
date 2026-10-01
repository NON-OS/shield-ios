import SwiftUI

/// The NØNOS logo: the Ø knocked out of a rounded square, and the wordmark.
struct Logo: View {
    var height: CGFloat = 24

    var body: some View {
        Image("NonosLogo")
            .renderingMode(.template)
            .resizable()
            .aspectRatio(1428.0 / 500.0, contentMode: .fit)
            .frame(height: height)
            .foregroundStyle(Palette.cyan)
            .accessibilityLabel("NØNOS")
    }
}
