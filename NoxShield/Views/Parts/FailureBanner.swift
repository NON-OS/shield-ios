import SwiftUI

/// What the core refused, in its own words, from a typed error, so no amount or key can leak here.
struct FailureBanner: View {
    let text: String
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(text).foregroundStyle(Palette.darkText)
            Button("Dismiss", action: onDismiss)
                .foregroundStyle(Palette.darkMuted)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.dark3)
        .clipShape(RoundedRectangle(cornerRadius: Palette.radius))
    }
}
