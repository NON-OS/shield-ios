import Foundation

/// Shielding from this wallet's own account on Sepolia: the core reviews the approval or the
/// deposit, the owner confirms it with Face ID, and the send is followed like any other.
extension WalletStore {
    func reviewShield(coin: Coin, amount: String) {
        guard let wallet else { return }
        let handle = Handle(wallet)
        mutate { $0.sent = nil; $0.sentStatus = nil }
        run(.reviewing, work: { try handle.value.reviewShield(coin: coin, amount: amount) },
            then: { [weak self] review in self?.mutate { $0.shielding = review; $0.busy = .idle } })
    }

    func confirmShield() {
        guard let wallet, let review = state.shielding, review.refusal == nil else { return }
        let handle = Handle(wallet)
        let reason = review.approval
            ? "Let the pool take \(review.amount) on Sepolia"
            : "Shield \(review.amount) on Sepolia"
        Presence.confirm(reason) { [weak self] yes in
            guard yes, let self else { return }
            self.run(.sending, work: { try handle.value.confirmPublicSend(id: review.id) },
                     then: { [weak self] sent in
                self?.mutate { $0.sent = sent; $0.sentStatus = .pending; $0.busy = .idle }
                self?.watch(sent, on: .sepolia)
            })
        }
    }

    func clearShield() {
        mutate { $0.shielding = nil; $0.sent = nil; $0.sentStatus = nil }
    }
}
