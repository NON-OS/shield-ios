import SwiftUI

/// The words before the single action that loses money. The destructive choice is outlined and
/// the safe one filled, so pressing the obvious button keeps the wallet.
struct WipeConfirmation: View {
    @EnvironmentObject private var store: WalletStore
    let onCancel: () -> Void

    var body: some View {
        Group {
            Text(
                "This removes the seed, the notes and the key that seals them from this "
                    + "device. The 24 words are the only way back. Without them the balance "
                    + "is gone."
            )
            .font(.sans(14))
            .foregroundStyle(Palette.darkText)
            Action(title: "Keep this wallet", enabled: store.state.busy == .idle, run: onCancel)
            Action(
                title: "Destroy it",
                filled: false,
                enabled: store.state.busy == .idle,
                run: { store.wipe() }
            )
        }
    }
}
