import Foundation

/// Taking back notes held as in flight whose spend was never settled. The core returns only what
/// the chain shows unspent, and the pool refuses a late hand-off as a second spend.
extension WalletStore {
    func takeBack() {
        guard let wallet else { return }
        let handle = Handle(wallet)
        run(.syncing, work: { (try handle.value.takeBackPending(), try handle.value.balances()) },
            then: { [weak self] result in
                self?.mutate { $0.balances = result.1; $0.busy = .idle }
            })
    }
}
