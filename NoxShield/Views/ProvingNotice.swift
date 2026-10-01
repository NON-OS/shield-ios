import SwiftUI

/// What a proof in progress looks like. The bar is indeterminate since the prover reports no
/// progress. Cancelling discards the proof when its arithmetic finishes, since the prover checks
/// only between stages and this runs as one stage.
struct ProvingNotice: View {
    @EnvironmentObject private var store: WalletStore

    var body: some View {
        Statement(text: cancelling ? "Finishing, then discarding." : "Proving.")
        Lead(
            text: cancelling
                ? "The proof will be thrown away rather than sent. It cannot be stopped "
                    + "mid proof."
                : "On this device, using \(Threads.inUse). Nothing has been sent."
        )
        ProgressView().progressViewStyle(.linear).tint(Palette.accent)
        Facts {
            Elapsed()
            Fact(name: "circuit", value: "launch, 19 queries, grind 28")
        }
        Action(
            title: "Cancel",
            filled: false,
            enabled: store.state.busy == .proving || store.state.busy == .measuring,
            run: store.cancelProof
        )
    }

    private var cancelling: Bool { store.state.busy == .cancelling }
}
