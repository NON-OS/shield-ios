import SwiftUI

/// A small label in the mono face, capitals spaced wide.
struct Label: View {
    let text: String
    var number: String = ""

    var body: some View {
        Text(number.isEmpty ? text.uppercased() : "\(number)  \(text.uppercased())")
            .font(.value(12))
            .tracking(2.4)
            .foregroundStyle(Palette.darkMuted)
            // Wrapped, never cut: a field's name carries its hint, such as the standard sizes,
            // and a larger text size must not lose its end.
            .fixedSize(horizontal: false, vertical: true)
    }
}
