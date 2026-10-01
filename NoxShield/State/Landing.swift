import Foundation

/// Where a proved spend stands on its way to the pool, one step of five, read from what the
/// lander and the chain have said. The screen draws the steps and decides nothing.
enum Landing: Int, CaseIterable {
    case proved
    case handed
    case scheduled
    case settling
    case settled

    static func of(_ state: UiState) -> Landing {
        if let landed = selfSettled(state) { return landed }
        switch state.relayState?.status {
        case "settled": return .settled
        case "settling": return .settling
        case "scheduled": return .scheduled
        default: return state.relay?.id == nil ? .proved : .handed
        }
    }

    /// A settlement sent from this wallet's own account: settling once sent, settled once mined.
    /// One that failed on chain leaves the step to the lander, which may have landed it first.
    private static func selfSettled(_ state: UiState) -> Landing? {
        guard state.selfSettle != nil, let status = state.sentStatus, status != .failed else {
            return nil
        }
        return status == .confirmed ? .settled : .settling
    }

    /// Whether the lander turned the spend away. That costs nothing, and Take back returns the
    /// notes.
    static func refused(_ state: UiState) -> Bool {
        state.relay?.refusal != nil || state.relayState?.status == "refused"
    }

    var title: String {
        switch self {
        case .proved: "Proved and sealed on this phone"
        case .handed: "Published to the lander, over Tor"
        case .scheduled: "Scheduled by the lander"
        case .settling: "Settling on the pool"
        case .settled: "Settled"
        }
    }
}
