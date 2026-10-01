import Foundation

/// Scanning and sending. Amounts are parsed by the core off the main queue, so a bad one is a
/// state on screen.
extension WalletStore {
    /// Read the pool's history over the wallet's own Tor, then the public account.
    func sync() {
        guard let wallet else { return }
        let handle = Handle(wallet)
        run(.syncing, work: { try handle.value.syncChain() },
            then: { [weak self] summary in
                self?.mutate { $0.chain = summary; $0.balances = summary.balances; $0.busy = .idle }
                self?.readAccount()
            })
    }

    /// Prove a spend and seal its notes for a relayer: a private transfer or a withdrawal.
    func spend(_ order: SpendOrder) {
        guard let wallet else { return }
        let token = CancelToken()
        hold(token)
        let handle = Handle((wallet, token))
        mutate { $0.tooSoon = nil }
        run(.proving, work: { () throws -> (SpendTicket?, [Balance]) in
            let (open, cancel) = handle.value
            do {
                let ticket = order.withdraw
                    ? try open.withdraw(coin: order.coin, to: order.to, amount: order.amount,
                                        early: order.early, cancel: cancel)
                    : try open.sendPrivate(coin: order.coin, to: order.to, amount: order.amount,
                                           early: order.early, cancel: cancel)
                return (ticket, try open.balances())
            } catch WalletError.TooSoon {
                // Not a failure: the screen asks whether to go early, and says what it costs.
                return (nil, try open.balances())
            }
        }, then: { [weak self] pair in
            self?.hold(nil)
            self?.mutate {
                $0.spend = pair.0
                $0.tooSoon = pair.0 == nil ? order : nil
                $0.balances = pair.1
                $0.busy = .idle
            }
        })
    }

    /// Ask the running proof to stop at the next stage boundary, never mid allocation.
    func cancelProof() {
        cancel?.cancel()
        mutate { $0.busy = .cancelling }
    }
}
