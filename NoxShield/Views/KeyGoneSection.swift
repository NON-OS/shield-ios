import SwiftUI

/// The way out of a wallet whose key this device no longer has: destroy it behind the same
/// confirmation as Settings, then restore it from the recovery words. The same words as on Android.
struct KeyGoneSection: View {
    @EnvironmentObject private var store: WalletStore
    @State private var confirming = false

    var body: some View {
        Lead(text: "The key that sealed this wallet is gone, so it cannot be opened on this device "
            + "again. Destroy it here, then restore it from the recovery words.")
        if confirming {
            WipeConfirmation { confirming = false }
        } else {
            Action(title: "Destroy this wallet", filled: false,
                   enabled: store.state.busy == .idle) { confirming = true }
        }
    }
}
