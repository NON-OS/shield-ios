import SwiftUI

/// The photograph at the head of each section: Etna in eruption, recoloured to the brand's Ink,
/// Deep Teal and Cyan.
enum Backdrop: String {
    case welcome, home, send, receive, deposit, withdraw, proving, history, settings, backup

    var asset: String { "Etna-\(rawValue)" }
}

struct BackdropBand: View {
    let backdrop: Backdrop

    /// The header photographs are 1290 by 860.
    private static let aspect: CGFloat = 1290.0 / 860.0

    var body: some View {
        Image(backdrop.asset)
            .resizable()
            .aspectRatio(BackdropBand.aspect, contentMode: .fill)
            .frame(maxWidth: .infinity)
            .clipped()
            .overlay(
                LinearGradient(
                    stops: [
                        .init(color: Palette.ink.opacity(0.35), location: 0),
                        .init(color: Palette.ink.opacity(0), location: 0.3),
                        .init(color: Palette.ink.opacity(0), location: 0.55),
                        .init(color: Palette.ink, location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .accessibilityHidden(true)
    }
}
