import SwiftUI

/// A circle coloured from an address, so each account is known at a glance and two never look
/// alike by accident. It carries no information beyond the address it is drawn from.
struct Avatar: View {
    let address: String
    var size: CGFloat = 28

    var body: some View {
        Circle()
            .fill(LinearGradient(
                colors: [hue(0), hue(8)], startPoint: .topLeading, endPoint: .bottomTrailing
            ))
            .frame(width: size, height: size)
            .overlay(Circle().stroke(Palette.darkLine, lineWidth: 1))
            .accessibilityHidden(true)
    }

    /// A hue from six hex digits of the address, at a fixed saturation and brightness.
    private func hue(_ at: Int) -> Color {
        let digits = Array(address.lowercased().dropFirst(2))
        let slice = digits.dropFirst(at).prefix(6)
        let value = Int(String(slice), radix: 16) ?? 0
        return Color(hue: Double(value % 360) / 360, saturation: 0.55, brightness: 0.85)
    }
}
