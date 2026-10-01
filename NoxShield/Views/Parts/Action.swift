import SwiftUI

/// The two weights of action, and no third.
struct Action: View {
    let title: String
    var filled: Bool = true
    var enabled: Bool = true
    let run: () -> Void

    var body: some View {
        Button(action: run) {
            Text(title.uppercased())
                .font(.value(12))
                .tracking(1.6)
                .multilineTextAlignment(.center)
                .padding(.vertical, 8)
                // A floor, not a height: at a large text size the title wraps instead of being
                // cut, which cut "Receive at the 0x address" to its first two words.
                .frame(maxWidth: .infinity, minHeight: Edge.tall)
                .background(ground)
                .foregroundStyle(ink)
                .clipShape(RoundedRectangle(cornerRadius: Edge.corner))
                .overlay(
                    RoundedRectangle(cornerRadius: Edge.corner)
                        .stroke(edge, lineWidth: Edge.hair)
                )
        }
        .disabled(!enabled)
        // Read as written, not letter by letter in capitals.
        .accessibilityLabel(title)
    }

    // An action that cannot be pressed is drawn as an outline, not as a faded fill.
    private var ground: Color { filled && enabled ? Palette.cyan : .clear }

    private var ink: Color {
        if filled && enabled { return Palette.ink }
        return enabled ? Palette.darkText : Palette.darkMuted
    }

    private var edge: Color { filled && enabled ? .clear : Palette.darkLine }
}
