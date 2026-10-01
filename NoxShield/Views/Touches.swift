import SwiftUI

/// Noticing that somebody is here, which is what the idle lock measures. The gesture is
/// simultaneous and consumes nothing, so every button still gets its press.
extension View {
    func watchingTouches(_ store: WalletStore) -> some View {
        simultaneousGesture(
            DragGesture(minimumDistance: 0).onChanged { _ in store.touched() }
        )
    }
}
