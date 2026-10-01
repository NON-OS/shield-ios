import Foundation

/// A swap from the public account: the core's review, the owner's yes, and the same signing call a
/// send uses, so both pass the same checks. An approval lets the router take only the amount, and
/// the swap is reviewed again once it is mined.
extension WalletStore {
    func reviewSwap(from: Coin, to: Coin, amount: String, slippageBps: UInt16) {
        guard let wallet else { return }
        let handle = Handle(wallet)
        let network = state.network
        run(.reviewing, work: {
            try handle.value.reviewPublicSwap(network: network, from: from, to: to,
                                              amount: amount, slippageBps: slippageBps)
        }, then: { [weak self] swap in
            self?.mutate { $0.swap = swap; $0.busy = .idle }
        })
    }

    func confirmSwap() {
        guard let wallet, let swap = state.swap, swap.refusal == nil else { return }
        let handle = Handle(wallet)
        let what = swap.approval
            ? "Let Uniswap take \(swap.amountIn) \(amountUnit(coin: swap.from))"
            : "Swap \(swap.amountIn) \(amountUnit(coin: swap.from))"
        Presence.confirm(swap.realMoney ? what + ", real money" : what) { [weak self] yes in
            guard yes, let self else { return }
            self.run(.sending, work: { try handle.value.confirmPublicSend(id: swap.id) },
                     then: { [weak self] sent in
                self?.mutate { $0.sent = sent; $0.sentStatus = .pending; $0.busy = .idle }
                self?.watch(sent, on: swap.network)
            })
        }
    }

    func clearSwap() {
        mutate { $0.swap = nil; $0.sent = nil; $0.sentStatus = nil }
    }
}
