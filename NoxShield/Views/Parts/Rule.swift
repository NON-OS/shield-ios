import SwiftUI

/// A thin rule that divides without shouting, and draws itself in.
struct Rule: View {
    var inset: CGFloat = 0

    @State private var drawn = false

    /// Long enough to be seen drawing, short enough not to be waited for.
    private static let draw = 0.26

    var body: some View {
        GeometryReader { space in
            Rectangle()
                .fill(Palette.darkLine)
                .frame(width: drawn ? space.size.width - inset : 0, height: 1)
                .offset(x: inset)
        }
        .frame(height: 1)
        .onAppear {
            withAnimation(.easeOut(duration: Self.draw)) { drawn = true }
        }
    }
}
