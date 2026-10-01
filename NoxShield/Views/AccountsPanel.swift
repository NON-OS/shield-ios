import SwiftUI

/// The accounts of this wallet, each with its own shield keys, `nox1` address and public account,
/// all from the same recovery words. The view-only accounts follow, and none of them can send.
struct AccountsPanel: View {
    @EnvironmentObject private var store: WalletStore
    let onBack: () -> Void

    var body: some View {
        ScreenFrame(
            heading: Heading(number: "05", title: "Accounts"),
            failure: store.state.failure,
            onDismissFailure: store.dismissFailure,
            onBack: onBack,
            status: Status.of(store.state),
            backdrop: .settings
        ) {
            Tile {
                ForEach(Array(store.state.accountList.enumerated()), id: \.offset) { i, account in
                    if i > 0 { Rule() }
                    Pick(
                        title: accountName(account.index),
                        detail: account.active ? "In use" : Groups.shortened(account.publicAddress),
                        enabled: idle && !account.active
                    ) { store.selectAccount(account.index) }
                }
            }
            QuietGroup {
                Quiet(title: "Add an account", enabled: idle, run: store.addAccount)
            }
            Lead(text: "Every account comes from the same recovery words. Moving value between two "
                + "of them is a private transfer and pays the relay fee.")
            WatchedSection()
        }
    }

    private var idle: Bool { store.state.busy == .idle }
}
