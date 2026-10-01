import SwiftUI

/// The public `0x` address, to receive ETH and NOX at. It is the same on every network and
/// anyone can see what it holds, so the shielded address sits beside it.
struct AccountReceiveView: View {
    @EnvironmentObject private var store: WalletStore
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
                RealMoney(network: store.state.network)
                Lead(text: "Public: anyone can see what this address holds and sends.")
                if !store.state.account.isEmpty {
                    QrCode(value: store.state.account)
                }
                ValueBlock(value: store.state.account)
                Facts {
                    Fact(name: "networks", value: "Ethereum and Sepolia, one address")
                    Fact(name: "derived at", value: "m/44'/60'/0'/0/0")
                }
            },
            footer: {
                Action(title: "Copy address", enabled: !store.state.account.isEmpty) {
                    store.copyValue(store.state.account)
                }
            }
        )
    }
}
