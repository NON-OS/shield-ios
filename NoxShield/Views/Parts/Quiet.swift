import SwiftUI

/// The actions a screen offers without asking for them.
struct Quiet: View {
    let title: String
    var enabled: Bool = true
    let run: () -> Void

    var body: some View {
        Button(action: run) {
            HStack {
                Text(title)
                    .font(.value(14))
                    .foregroundStyle(Palette.darkText)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.5)
    }
}

/// The quiet actions, grouped so they read as one block instead of a stack.
struct QuietGroup<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: Edge.corner))
        .overlay(
            RoundedRectangle(cornerRadius: Edge.corner)
                .stroke(Palette.darkLine, lineWidth: Edge.hair)
        )
    }
}

/// A rule between rows of a group, inset so it starts under the text.
struct QuietRule: View {
    var body: some View {
        Rule(inset: 16)
    }
}
