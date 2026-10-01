import SwiftUI

/// What the wallet knows, as values instead of as sentences.
struct Facts<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// One fact. The value is the app's own answer, never a placeholder. Read as one element, the
/// name then the value, and at the accessibility sizes the value goes under its name.
struct Fact: View {
    let name: String
    let value: String
    @Environment(\.dynamicTypeSize) private var size

    var body: some View {
        Group {
            if size.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 4) {
                    nameText
                    valueText
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    nameText
                    Spacer(minLength: 0)
                    valueText.multilineTextAlignment(.trailing)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(name), \(value)")
    }

    private var nameText: some View {
        Text(name.uppercased())
            .font(.value(12))
            .foregroundStyle(Palette.darkMuted)
    }

    /// Wrapped as far as it needs, never cut or shrunk.
    private var valueText: some View {
        Text(value)
            .font(.value(12))
            .foregroundStyle(Palette.darkText)
            .fixedSize(horizontal: false, vertical: true)
    }
}
