import SwiftUI

/// The way a proved spend travels to the pool, as five steps: which are done and which one it is
/// on, then the settlement's transaction once there is one.
struct LandingSteps: View {
    @EnvironmentObject private var store: WalletStore

    var body: some View {
        let now = Landing.of(store.state)
        Tile {
            ForEach(Landing.allCases, id: \.self) { step in
                LandingRow(step: step, now: now)
                if step != .settled { Rule(inset: 16) }
            }
        }
        if let hash = settlement {
            Label(text: "Settlement")
            ValueBlock(value: hash)
            Action(title: "Copy the hash", filled: false) { store.copyValue(hash) }
        }
    }

    /// The lander's settlement, or the one this account sent itself.
    private var settlement: String? {
        if let tx = store.state.relayState?.tx { return tx }
        return store.state.selfSettle == nil ? nil : store.state.sent?.hash
    }
}

/// One step: a mark for done, now or still to come, and its name.
private struct LandingRow: View {
    let step: Landing
    let now: Landing

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: mark)
                .foregroundStyle(reached ? Palette.cyan : Palette.darkMuted)
                .accessibilityHidden(true)
            Text(step.title)
                .font(.sans(14, step == now ? .medium : .regular))
                .foregroundStyle(reached ? Palette.darkText : Palette.darkMuted)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(step.title), \(spoken)")
    }

    private var reached: Bool { step.rawValue <= now.rawValue }

    /// Done is a step behind the one it is on, or every step once it has settled.
    private var done: Bool { step.rawValue < now.rawValue || now == .settled }

    private var mark: String {
        if done { return "checkmark.circle.fill" }
        return step == now ? "circle.inset.filled" : "circle"
    }

    private var spoken: String {
        if done { return "done" }
        return step == now ? "now" : "to come"
    }
}
