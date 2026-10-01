import SwiftUI

/// A spend proved and sealed, and its way to the pool: handed to the lander over its onion service
/// and followed step by step until it settles, or landed from this account when no lander is on or
/// none lands it. The four files hold no secret, and the spent notes stay in flight until the pool
/// shows them.
struct SpendTicketView: View {
    @EnvironmentObject private var store: WalletStore
    let ticket: SpendTicket
    let onDone: () -> Void
    @State private var sharing = false

    var body: some View {
        Statement(text: Landing.headline(store.state))
        LandingSteps()
        Tile {
            TileRow(name: "Lander", value: store.hasLander ? "onion service, over Tor" : "you")
            TileRow(name: "Anonymity defaults", value: ticket.weakened.isEmpty
                ? "all kept" : "gave up " + ticket.weakened.joined(separator: ", "))
        }
        LandingActions()
        Action(title: "Share the files instead", filled: false) { sharing = true }
        Action(title: "Done", filled: false) {
            store.clearSpend()
            store.mutate { $0.selfSettle = nil }
            onDone()
        }
        .sheet(isPresented: $sharing) {
            ShareFiles(urls: ticket.handoffFiles.map { URL(fileURLWithPath: $0) })
        }
    }
}
