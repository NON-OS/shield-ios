import Foundation

/// Landing a proved spend from this wallet's own public account, when no lander is on or none
/// has landed it. The core reviews the settlement, the owner confirms it, and it is followed like
/// a send.
extension WalletStore {
    func reviewSelfSettle() {
        guard let wallet else { return }
        let handle = Handle(wallet)
        mutate { $0.sent = nil; $0.sentStatus = nil }
        run(.reviewing, work: { try handle.value.reviewSelfSettle() },
            then: { [weak self] review in
                self?.mutate { $0.selfSettle = review; $0.busy = .idle }
            })
    }

    func confirmSelfSettle() {
        guard let wallet, let review = state.selfSettle, review.refusal == nil else { return }
        let handle = Handle(wallet)
        Presence.confirm("Settle this spend from your public account") { [weak self] yes in
            guard yes, let self else { return }
            self.run(.sending, work: { try handle.value.confirmPublicSend(id: review.id) },
                     then: { [weak self] sent in
                self?.mutate { $0.sent = sent; $0.sentStatus = .pending; $0.busy = .idle }
                self?.watch(sent, on: .sepolia)
            })
        }
    }

    /// Whether this build hands proofs to a lander. With none, the owner lands every spend.
    var hasLander: Bool { wallet?.hasLander() ?? false }
}
