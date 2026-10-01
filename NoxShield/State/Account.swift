import Foundation

/// The public `0x` account: reading it, and a send that is worked out in full, shown, confirmed by
/// the owner, and only then signed by the core. The core decides everything about the money.
extension WalletStore {
    /// Read the public account on the network being shown.
    func readAccount() {
        guard let wallet, state.stage == .ready, state.busy == .idle else { return }
        let handle = Handle(wallet)
        let network = state.network
        run(.reading, work: { try handle.value.publicBalances(network: network) },
            then: { [weak self] read in
                self?.mutate { $0.accounts[read.network] = read; $0.busy = .idle }
            })
    }

    func reviewSend(coin: Coin, to: String, amount: String) {
        guard let wallet else { return }
        let handle = Handle(wallet)
        let network = state.network
        run(.reviewing, work: {
            try handle.value.reviewPublicSend(network: network, coin: coin, to: to,
                                              amount: amount)
        }, then: { [weak self] review in
            self?.mutate { $0.review = review; $0.busy = .idle }
        })
    }

    /// Ask the owner, then have the core sign and send what the review showed.
    func confirmSend() {
        guard let wallet, let review = state.review, review.refusal == nil else { return }
        let handle = Handle(wallet)
        let reason = review.realMoney
            ? "Send \(review.amount) \(amountUnit(coin: review.coin)) of real money"
            : "Send \(review.amount) \(amountUnit(coin: review.coin)) on Sepolia"
        Presence.confirm(reason) { [weak self] yes in
            guard yes, let self else { return }
            self.run(.sending, work: { try handle.value.confirmPublicSend(id: review.id) },
                     then: { [weak self] sent in
                self?.mutate { $0.sent = sent; $0.sentStatus = .pending; $0.busy = .idle }
                self?.watch(sent, on: review.network)
            })
        }
    }

    /// Forget the review and what was sent, once the screen is done with them.
    func clearSend() {
        mutate { $0.review = nil; $0.sent = nil; $0.sentStatus = nil }
    }
}
