import SwiftUI

/// How far the newest money in the shield is from blending in: notes still to land in the pool and
/// hours still to pass. Nothing is shown before a first sync, or with nothing in the shield.
struct PrivacyMeter: View {
    @EnvironmentObject private var store: WalletStore

    var body: some View {
        let holds = store.state.balances.contains { $0.spendable > 0 }
        if let chain = store.state.chain, holds {
            Lead(text: line(notes: chain.waitLeaves, minutes: chain.waitMinutes))
        }
    }

    private func line(notes: UInt32, minutes: UInt32) -> String {
        if notes == 0 && minutes == 0 { return "Ready to spend privately." }
        var parts: [String] = []
        if notes > 0 { parts.append("\(notes) more notes in the pool") }
        if minutes > 0 { parts.append("about \((minutes + 59) / 60) hours") }
        return "Ready to spend privately after \(parts.joined(separator: " and ")). "
            + "Spending sooner can be linked by timing."
    }
}
