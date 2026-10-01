import SwiftUI

/// What the owner can do while a spend waits: hand it to the lander, ask the lander again after a
/// half hour with no landing, or land it from the public account, until it has settled.
struct LandingActions: View {
    @EnvironmentObject private var store: WalletStore

    var body: some View {
        if store.hasLander && store.state.relay?.id == nil {
            Action(title: store.state.busy == .handing ? "Handing over Tor" : "Send over Tor",
                   enabled: store.state.busy == .idle, run: store.handToRelayer)
        }
        if store.state.notLanded && Landing.of(store.state) != .settled {
            Action(title: "Ask the lander again", filled: false,
                   enabled: store.state.busy == .idle, run: store.askAgain)
        }
        if Landing.of(store.state) != .settled {
            SelfSettleSection()
        }
    }
}

/// A spend handed over before the app was last closed, followed again on the shield, where the
/// owner lands after unlocking. It goes once the owner is done with it.
struct LandingPanel: View {
    @EnvironmentObject private var store: WalletStore

    var body: some View {
        if store.state.spend == nil, store.state.relay?.id != nil {
            Lead(text: Landing.headline(store.state))
            LandingSteps()
            LandingActions()
            if Landing.of(store.state) == .settled || Landing.refused(store.state) {
                Quiet(title: "Done with this spend") {
                    store.clearSpend()
                    store.mutate { $0.selfSettle = nil }
                }
            }
        }
    }
}
