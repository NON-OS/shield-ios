import SwiftUI

/// Which account a private send spends from, and when it goes to another account of this wallet,
/// that it is a private transfer with a relay fee. Value that arrived only just before can be
/// linked across the two accounts by timing, so that is said too.
struct FromNote: View {
    @EnvironmentObject private var store: WalletStore
    let withdraw: Bool

    var body: some View {
        Group {
            Lead(text: "From \(store.state.activeName).")
            if !withdraw, let own = store.state.ownTarget {
                Lead(text: "This moves value to \(accountName(own)) of this wallet, as a private "
                    + "transfer that pays the relay fee.")
                if store.state.arrivedRecently {
                    Lead(text: "Some of this value arrived only recently. Moving it on soon "
                        + "after can link the two accounts by timing. Waiting first makes that "
                        + "harder.")
                }
            }
        }
    }
}
