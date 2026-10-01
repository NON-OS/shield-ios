import SwiftUI

/// The accounts somebody shared a view key for. They show notes and never send. An incoming key
/// cannot tell a spent note from an unspent one, so its figure is what arrived, not what is held.
struct WatchedSection: View {
    @EnvironmentObject private var store: WalletStore
    @State private var key = ""

    var body: some View {
        Group {
            Label(text: "View only")
            if !store.state.watched.isEmpty {
                Tile {
                    ForEach(Array(store.state.watched.enumerated()), id: \.offset) { i, watched in
                        if i > 0 { Rule() }
                        Pick(title: "View only \(watched.index + 1)", detail: figure(watched),
                             enabled: false) {}
                    }
                }
                QuietGroup {
                    ForEach(store.state.watched, id: \.index) { watched in
                        Quiet(title: "Forget view only \(watched.index + 1)", enabled: idle) {
                            store.forgetViewKey(watched.index)
                        }
                    }
                }
            }
            Field(label: "A noxivk1 or noxfvk1 view key", text: $key, oneLine: false)
            Action(title: "Add the view key", enabled: idle && !key.isEmpty) {
                store.importViewKey(key)
                key = ""
            }
        }
    }

    private var idle: Bool { store.state.busy == .idle }

    private func figure(_ watched: WatchedSummary) -> String {
        let shown = watched.balances
            .map { balance in
                let figure = formatAmount(coin: balance.coin, units: balance.spendable)
                return "\(figure) \(amountUnit(coin: balance.coin))"
            }
            .joined(separator: " · ")
        return watched.kind == .full ? shown : "received \(shown)"
    }
}
