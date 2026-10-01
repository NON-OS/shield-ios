import Foundation

/// One timed proof of the pinned vector, for the phone profile: the prover's eleven
/// phases, the total, whether the proof matched the vector byte for byte, and what the phone said
/// about its memory and its heat. A run that ends hot is kept and marked, never dropped.
struct ProfileRun: Equatable {
    /// The prover's phases, in the order its progress callback reports them.
    static let phases = [
        "Request", "Blinding", "Region", "Products", "Periodic", "Composition",
        "CompositionTree", "Deep", "Fri", "Queries", "Verified"
    ]

    /// Milliseconds per phase, in the order of `phases`.
    let phaseMs: [UInt64]
    let totalMs: UInt64
    let matched: Bool
    /// The footprint after the run, `task_vm_info.phys_footprint`.
    let footprintKib: UInt64?
    /// The high water mark since the app opened. It covers the first run alone only for that run.
    let peakKib: UInt64?
    let limitKib: UInt64?
    let thermalBefore: String
    let thermalAfter: String

    /// Whether the phone was too hot for the time to stand for its speed.
    var hot: Bool { ["serious", "critical"].contains(thermalAfter) }

    /// Whether the phases add up to the total within a millisecond, as the core promises.
    var adds: Bool {
        let sum = phaseMs.reduce(0, +)
        let gap = sum > totalMs ? sum - totalMs : totalMs - sum
        return gap <= 1 && phaseMs.count == Self.phases.count
    }

    /// Fri's share of the total, which tells whether the query grind or the trace takes the time.
    var friShare: Double {
        guard totalMs > 0, let at = Self.phases.firstIndex(of: "Fri"), at < phaseMs.count else {
            return 0
        }
        return Double(phaseMs[at]) / Double(totalMs)
    }
}
