import SwiftUI

/// The single line a screen is about, set at the size a title used to be.
struct Statement: View {
    let text: String
    @StateObject private var resolve = Resolve()
    @Environment(\.accessibilityReduceMotion) private var still

    var body: some View {
        ZStack(alignment: .topLeading) {
            line(text).opacity(0)
            line(still ? text : resolve.take(text))
        }
        .onAppear { if !still { resolve.run(text) } }
        // Read whole and at once, as the line the screen is about, never half resolved.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
        .accessibilityAddTraits(.isHeader)
    }

    private func line(_ shown: String) -> some View {
        Text(shown)
            .font(.value(21))
            .lineSpacing(6)
            .foregroundStyle(Palette.darkText)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
