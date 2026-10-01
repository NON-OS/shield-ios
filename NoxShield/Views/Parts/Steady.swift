import SwiftUI

/// A button drawn the same whether or not it can be pressed right now, for a control held back only
/// while the wallet reads. Dimming it left its text under the contrast a screen needs, and the
/// status already says the wallet is busy.
struct Steady: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.6 : 1)
    }
}
