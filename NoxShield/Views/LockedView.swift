import SwiftUI

/// The locked wallet. Unlocking asks the device to unwrap the vault key, which confirms the user
/// without the phrase. The key facts are read back from the key, never assumed.
struct LockedView: View {
    @EnvironmentObject private var store: WalletStore

    var body: some View {
        ScreenFrame(
            heading: Heading(number: "02", title: "Locked"),
            failure: store.state.failure,
            onDismissFailure: store.dismissFailure,
            status: Status.of(store.state),
            backdrop: .history,
            content: {
            Statement(text: "This wallet is sealed.")
            Lead(
                text: "The seed is under a key this device holds. Unlocking asks the "
                    + "device to unwrap it."
            )
            Facts {
                Fact(name: "key held in", value: store.state.holder.place)
                Fact(name: "released", value: "after you are confirmed")
            }
            if store.state.stage == .keyGone {
                KeyGoneSection()
            }
        },
            footer: {
                Action(
                    title: store.state.busy == .unlocking ? "Unlocking" : "Unlock",
                    enabled: store.state.busy == .idle,
                    run: store.unlock
                )
            }
        )
    }
}
