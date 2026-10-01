import SwiftUI

/// A text field with its name above it, in the mono face the labels use. Nothing is validated
/// here, and [Typing] keeps the keyboard from learning what is typed.
struct Field: View {
    let label: String
    @Binding var text: String
    var oneLine: Bool = true
    var typing: Typing = .exact

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(text: label)
            TextField("", text: $text, axis: oneLine ? .vertical : .vertical)
                .textFieldStyle(.plain)
                .foregroundStyle(Palette.darkText)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .keyboardType(typing.keyboard)
                .textContentType(.none)
                // The name sits above the field, so VoiceOver is told it here, or the field
                // is read as an empty text field.
                .accessibilityLabel(label)
                .padding(12)
                .background(Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: Edge.corner))
                .overlay(
                    RoundedRectangle(cornerRadius: Edge.corner)
                        .stroke(Palette.darkLine, lineWidth: Edge.hair)
                )
        }
    }
}
