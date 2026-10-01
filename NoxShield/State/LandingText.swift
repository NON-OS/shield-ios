import Foundation

/// The one line the waiting screen is about, for every state a spend can be in, so a test can
/// read each one. A refusal and a long wait are said before the step, since they ask for a choice.
extension Landing {
    static func headline(_ state: UiState) -> String {
        if refused(state) {
            let why = state.relay?.refusal ?? state.relayState?.reason
            return "The lander refused it" + (why.map { ": \($0)." } ?? ".")
                + " Settle it yourself, or Take back returns the notes."
        }
        if state.selfSettle != nil && state.sentStatus == .failed {
            return "Your settlement failed on chain. The lander may have landed it first."
        }
        if state.notLanded && of(state) != .settled {
            return "Not landed yet. Ask the lander again, or settle it yourself."
        }
        return of(state).line
    }

    var line: String {
        switch self {
        case .proved: "Proved and sealed on this phone."
        case .handed: "Published over Tor. Waiting for the lander."
        case .scheduled: "Scheduled by the lander. Waiting for its turn."
        case .settling: "Settling on the pool."
        case .settled: "Settled on the pool."
        }
    }
}
