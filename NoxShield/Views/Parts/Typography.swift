import SwiftUI

/// The two faces the brand uses, and no third.
extension Font {
    /// Every size in the app is written at the scale it was designed at and set a quarter larger
    /// here, which is the size it reads well at on a phone held at arm's length.
    static let scale: CGFloat = 1.25

    /// Interface text.
    static func sans(_ size: CGFloat, _ weight: Weight = .regular) -> Font {
        let face = switch weight {
        case .medium: "Geist-Medium"
        case .semibold: "Geist-SemiBold"
        default: "Geist-Regular"
        }
        return .custom(face, size: size * scale, relativeTo: .body)
    }

    /// Anything that is a value instead of prose.
    static func value(_ size: CGFloat) -> Font {
        .custom("JetBrainsMono-Regular", size: size * scale, relativeTo: .body)
    }
}
