import Foundation

/// The profile as text: one table per device, the model
/// and the iOS version above it, one column per run, the eleven phases and the total in seconds,
/// peak memory as `phys_footprint` read right after the call, the thermal state before and after,
/// and the match. The app sends it nowhere: the owner chooses where it goes.
enum ProfileTable {
    static func text(
        runs: [ProfileRun], phone: String, ramBytes: UInt64, threads: String
    ) -> String {
        let heads = runs.indices.map { $0 == 0 ? "1 cold" : "\($0 + 1)" }
        var lines = [
            "NØNOS Wallet for iOS: shape A proof, phase by phase",
            "phone \(phone), RAM \(ramBytes >> 20) MiB, threads \(threads)",
            "",
            row("run", heads)
        ]
        for (at, phase) in ProfileRun.phases.enumerated() {
            let cells = runs.map { at < $0.phaseMs.count ? seconds($0.phaseMs[at]) : "-" }
            lines.append(row(phase, cells))
        }
        lines.append(row("total s", runs.map { seconds($0.totalMs) }))
        lines.append(row("under 45 s", runs.map { $0.totalMs < 45_000 ? "yes" : "no" }))
        lines.append(row("matched", runs.map { $0.matched ? "yes" : "NO" }))
        lines.append(row("adds up", runs.map { $0.adds ? "yes" : "NO" }))
        lines.append(row("Fri share", runs.map { String(format: "%.1f%%", $0.friShare * 100) }))
        lines.append(row("peak MiB", runs.map { mib($0.footprintKib) }))
        lines.append(row("hwm MiB", runs.map { mib($0.peakKib) }))
        lines.append(row("limit MiB", runs.map { mib($0.limitKib) }))
        lines.append(row("thermal", runs.map { "\($0.thermalBefore)>\($0.thermalAfter)" }))
        lines.append(row("hot", runs.map { $0.hot ? "HOT" : "no" }))
        return lines.joined(separator: "\n") + "\n"
    }

    private static func row(_ name: String, _ cells: [String]) -> String {
        name.padding(toLength: 16, withPad: " ", startingAt: 0)
            + cells.map { $0.padding(toLength: 14, withPad: " ", startingAt: 0) }.joined()
    }

    private static func seconds(_ ms: UInt64) -> String {
        String(format: "%.2f", Double(ms) / 1000)
    }

    private static func mib(_ kib: UInt64?) -> String {
        kib.map { "\($0 >> 10)" } ?? "-"
    }
}
