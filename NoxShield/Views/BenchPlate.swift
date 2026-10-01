import SwiftUI

/// What a proof on this device actually cost, with the number as the subject. A failed
/// verification voids the timing, and the statement says so.
struct BenchPlate: View {
    let report: BenchReport
    let footprint: Footprint?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Statement(text: headline)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(verbatim: formatSeconds(ms: report.provedMs))
                    .font(.sans(44, .medium))
                    .monospacedDigit()
                    .foregroundStyle(Palette.darkText)
                Text("seconds to prove")
                    .font(.sans(15, .medium))
                    .foregroundStyle(Palette.darkMuted)
            }
            Facts {
                Fact(name: "circuit", value: circuit)
                Fact(name: "params id", value: Groups.shortened(report.paramsId, ends: 8))
                Fact(name: "verified here", value: report.verified ? "inside the time" : "FALSE")
                Fact(name: "witness built", value: formatSeconds(ms: report.builtMs) + " s")
                Fact(name: "proof", value: "\(report.proofBytes) bytes")
                Fact(name: "peak since launch", value: mib(report.peakKib))
                Fact(name: "memory limit", value: mib(footprint?.limitKib))
                Fact(name: "threads", value: Threads.inUse)
                Fact(name: "rows", value: "2 ^ \(report.shape.logTraceLen)")
                Fact(name: "columns", value: "\(report.shape.traceWidth)")
                Fact(
                    name: "queries",
                    value: "\(report.shape.queries) at grind \(report.shape.grindBits)"
                )
                Fact(name: "soundness", value: "\(report.shape.securityBits) bits")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// The kernel's high water mark is for the whole run of the app, so a proof timed first after
    /// a launch is the one whose peak is the proof's. The limit is where the system ends the app.
    private func mib(_ kib: UInt64?) -> String {
        guard let kib else { return "not reported here" }
        return "\(kib / 1024) MiB"
    }

    /// What the proof is, before how long it took: a fast number from any circuit but the launch
    /// one is not the number that matters.
    private var circuit: String {
        report.launchPoint ? "launch, the pool's" : "NOT the launch"
    }

    private var headline: String {
        guard report.verified else { return "The proof did not verify." }
        return report.launchPoint
            ? "A real transfer, proved on this device."
            : "Proved, but not on the launch circuit."
    }
}
