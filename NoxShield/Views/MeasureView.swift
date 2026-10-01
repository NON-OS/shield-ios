import SwiftUI

/// The measurement screen. It ships because the release gate is a proof timed on a real phone.
struct MeasureView: View {
    @EnvironmentObject private var store: WalletStore
    @State private var sharing = false
    @State private var exporting: [URL] = []

    var body: some View {
        ScreenFrame(
            heading: Heading(number: "05", title: "Measure"),
            failure: store.state.failure,
            onDismissFailure: store.dismissFailure,
            onBack: { store.mutate { $0.stage = .ready } },
            status: Status.of(store.state),
            backdrop: .proving,
            content: {
            if store.state.busy == .measuring || store.state.busy == .cancelling {
                ProvingNotice()
            }
            if let bench = store.state.bench {
                BenchPlate(report: bench, footprint: store.state.footprint)
            }
        },
            footer: {
                Action(
                    title: "Time one proof",
                    enabled: store.state.busy == .idle,
                    run: store.measureProof
                )
                if let path = store.state.bench?.proofPath {
                    Action(title: "Export the proof", filled: false) {
                        exporting = ShareFiles.launchProof(at: path)
                    }
                }
                if store.state.cardPath != nil {
                    Action(title: "Share the card", filled: false) { sharing = true }
                }
                Quiet(title: threads, enabled: store.state.busy == .idle,
                      run: store.toggleThreads)
            }
        )
        .sheet(isPresented: $sharing) {
            if let card = store.card() {
                ShareCard(card: card)
            }
        }
        .sheet(isPresented: exportingShown) {
            ShareFiles(urls: exporting)
        }
    }

    /// The choice applies when the prover's pool starts, at the next launch, and says so.
    private var threads: String {
        let next = store.state.threads.map { "\($0) threads" } ?? "every core"
        return "Proving from the next launch: \(next)"
    }

    private var exportingShown: Binding<Bool> {
        Binding(get: { !exporting.isEmpty }, set: { if !$0 { exporting = [] } })
    }
}
