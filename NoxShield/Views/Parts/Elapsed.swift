import SwiftUI

/// How long the thing on screen has been running, counted by the shell. The prover reports no
/// progress, so this is wall clock, never the proving time the core reports.
struct Elapsed: View {
    @State private var seconds = 0
    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Fact(name: "elapsed", value: "\(seconds) s")
            .onReceive(tick) { _ in seconds += 1 }
    }
}
