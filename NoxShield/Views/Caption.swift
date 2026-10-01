import Foundation

/// What the balance figure means, which is a different sentence in each of the four states a wallet
/// can be in.
enum Caption {
    static func of(_ state: UiState) -> String {
        for coin in [Coin.nox, .eth] {
            if let pending = state.shield(coin)?.pending, pending > 0 {
                let figure = formatAmount(coin: coin, units: pending)
                return "\(figure) \(amountUnit(coin: coin)) in flight"
            }
        }
        return held(state)
    }

    private static func held(_ state: UiState) -> String {
        if state.balances.contains(where: { $0.spendable > 0 }) {
            return "Shielded, on this device"
        }
        guard state.chain != nil else { return "Not read from the pool yet" }
        switch state.balances.reduce(0, { $0 &+ $1.noteCount }) {
        case 0: return "Nothing received at this address yet"
        default: return "Every note found here has been spent"
        }
    }
}
