import SwiftUI

/// How a screen arrives: it settles.
extension AnyTransition {
    static var settle: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 8)),
            removal: .opacity
        )
    }
}

/// The single duration, so the two platforms move at the same speed.
enum Settle {
    static let arriving = 0.19
    static let leaving = 0.12
}
