import Foundation

/// What a send or withdraw screen collects. The relayer and its fee are the pool's, never typed.
/// `early` is set only after the owner typed the confirmation to spend notes that have not waited.
struct SpendOrder: Equatable {
    let coin: Coin
    /// A wallet address for a transfer, an EVM address for a withdrawal.
    let to: String
    let amount: String
    let withdraw: Bool
    var early = false
}

extension WalletStore {
    /// Forget a spend's ticket once it has been handed over.
    func clearSpend() {
        HandoffRecord.save(nil)
        mutate { $0.spend = nil; $0.relay = nil; $0.relayState = nil; $0.notLanded = false }
    }
}
