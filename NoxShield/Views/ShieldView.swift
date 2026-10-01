import SwiftUI

/// The shield: private balances, on Sepolia only, and what can be done with them. On mainnet it
/// says where the shield runs and offers to switch.
struct ShieldView: View {
    @EnvironmentObject private var store: WalletStore
    let onPanel: (Panel) -> Void
    let onBack: () -> Void

    var body: some View {
        ScreenFrame(
            heading: Heading(number: "03", title: "Shield"),
            failure: store.state.failure,
            onDismissFailure: store.dismissFailure,
            onBack: onBack,
            status: Status.of(store.state),
            backdrop: .deposit
        ) {
            if networkHasShield(network: store.state.network) {
                Tile {
                    CoinRow(coin: .nox, amount: figure(.nox), note: Caption.of(store.state))
                    Rule()
                    CoinRow(coin: .eth, amount: figure(.eth))
                }
                PrivacyMeter()
                LandingPanel()
                HStack(spacing: 8) {
                    RoundAction(title: "Deposit", symbol: "arrow.down.to.line") {
                        onPanel(.deposit)
                    }
                    RoundAction(title: "Receive", symbol: "arrow.down") { onPanel(.receive) }
                    RoundAction(title: "Send", symbol: "arrow.up") { onPanel(.send) }
                    RoundAction(title: "Withdraw", symbol: "arrow.up.to.line") {
                        onPanel(.withdraw)
                    }
                }
                ShieldMore()
            } else {
                Statement(text: "The shield runs on Sepolia until its audit.")
                Action(title: "Switch to Sepolia") { store.choose(.sepolia) }
            }
        }
    }

    private func figure(_ coin: Coin) -> String {
        formatAmount(coin: coin, units: store.state.shield(coin)?.spendable ?? 0)
    }
}
