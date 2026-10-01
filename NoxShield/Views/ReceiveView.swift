import SwiftUI

/// The address to receive at. A copy stays local and expires in a minute, and the screen says
/// while it is there. The address carries the spend key and an X-Wing key (X25519 with
/// ML-KEM-768) that senders seal note openings to, so only this wallet finds them. The public
/// 0x address stays one tap away, for a faucet or an ordinary send.
struct ReceiveView: View {
    @EnvironmentObject private var store: WalletStore
    let onPublic: () -> Void
    let onBack: () -> Void

    var body: some View {
        ScreenFrame(
            heading: Heading(number: "03", title: "Receive"),
            failure: store.state.failure,
            onDismissFailure: store.dismissFailure,
            onBack: onBack,
            status: Status.of(store.state),
            backdrop: .receive,
            content: {
                Lead(
                    text: "Give this to the sender. It says nothing about the balance or "
                        + "the notes held."
                )
                if !store.state.receiving.isEmpty {
                    QrCode(value: store.state.receiving)
                }
                ValueBlock(value: store.state.receiving)
                Facts {
                    Fact(name: "sealed with", value: "X-Wing, X25519 + ML-KEM-768")
                    Fact(
                        name: "pasteboard",
                        value: store.state.copied ? "expires in a minute" : "empty"
                    )
                }
            },
            footer: {
                Action(title: "Copy address", enabled: !store.state.receiving.isEmpty,
                       run: store.copyAddress)
                Action(title: "Receive at the 0x address", filled: false, run: onPublic)
            }
        )
    }
}
