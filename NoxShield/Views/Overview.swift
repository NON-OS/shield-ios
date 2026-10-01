import SwiftUI

/// Home: the network, the coins the public account holds there, and the four things a holder does.
struct Overview: View {
    @EnvironmentObject private var store: WalletStore
    let onPanel: (Panel) -> Void

    var body: some View {
        ScreenFrame(
            heading: Heading(number: "03", title: "Wallet"),
            failure: store.state.failure,
            onDismissFailure: store.dismissFailure,
            status: Status.of(store.state),
            backdrop: .home
        ) {
            HStack {
                Logo(height: 18)
                Spacer()
                Button { onPanel(.settings) } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18))
                        .foregroundStyle(Palette.darkText)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Settings")
            }
            PillsRow { onPanel(.accounts) }
            Tile {
                CoinRow(coin: .eth, amount: here?.eth ?? "–", note: note)
                Rule()
                CoinRow(coin: .nox, amount: here?.nox ?? "–")
                Rule()
                CoinRow(coin: .usdc, amount: here?.usdc ?? "–")
            }
            HStack(spacing: 8) {
                RoundAction(title: "Send", symbol: "arrow.up", enabled: ready) {
                    onPanel(.accountSend)
                }
                // Where the shield runs, a payment is received privately unless the owner asks.
                RoundAction(title: "Receive", symbol: "arrow.down") {
                    let shielded = networkHasShield(network: store.state.network)
                    onPanel(shielded ? .receive : .accountReceive)
                }
                if Release.swaps {
                    RoundAction(title: "Swap", symbol: "arrow.left.arrow.right") { onPanel(.swap) }
                }
                RoundAction(title: "Shield", symbol: "lock.shield") { onPanel(.shield) }
            }
        }
        .refreshable { store.readAccount() }
    }

    private var here: PublicBalances? { store.state.publicHere }

    private var ready: Bool { store.state.busy == .idle && here != nil }

    private var note: String {
        if store.state.busy == .reading { return "Reading over Tor" }
        return here == nil ? "Pull to read" : ""
    }
}
