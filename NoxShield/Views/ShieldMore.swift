import SwiftUI

/// The quieter things the shield offers: reading the pool, taking back what a relayer never
/// settled, timing a proof, and the facts behind a balance.
struct ShieldMore: View {
    @EnvironmentObject private var store: WalletStore
    @State private var details = false

    var body: some View {
        QuietGroup {
            Quiet(title: reading, enabled: idle, run: store.sync)
            if store.state.balances.contains(where: { $0.pending > 0 }) {
                QuietRule()
                Quiet(title: "Take back what a relayer never settled", enabled: idle,
                      run: store.takeBack)
            }
            QuietRule()
            Quiet(title: "Time a proof on this phone", enabled: idle, run: store.measureProof)
            QuietRule()
            Quiet(title: details ? "Hide details" : "Details") { details.toggle() }
        }
        if details {
            Tile {
                TileRow(name: "Pool read at block", value: head)
                TileRow(name: "Notes held", value: held)
                TileRow(name: "Key held in", value: store.state.holder.place)
            }
        }
    }

    private var idle: Bool { store.state.busy == .idle }

    private var reading: String {
        store.state.busy == .syncing ? "Reading the pool over Tor" : "Read the pool"
    }

    private var head: String { store.state.chain.map { "\($0.head)" } ?? "none yet" }

    private var held: String { "\(store.state.balances.reduce(0) { $0 &+ $1.noteCount })" }
}
