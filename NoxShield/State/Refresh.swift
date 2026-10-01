import Foundation

/// Reading back what the core holds after anything changed it, in one call, so a screen never
/// shows a new balance beside an old address.
extension WalletStore {
    /// Read the addresses and balances the core holds after a state change, then the public account
    /// on the network being shown.
    func refresh() {
        guard let wallet else { return }
        let handle = Handle(wallet)
        run(
            .syncing,
            work: {
                (
                    try handle.value.publicAddress(),
                    try handle.value.balances(),
                    try handle.value.receivingAddress(),
                    try handle.value.accounts(),
                    try handle.value.watchedAccounts(),
                    try handle.value.fromKey(),
                    try handle.value.freshWithdrawalAddress()
                )
            },
            then: { [weak self] read in
                self?.mutate {
                    $0.stage = .ready
                    $0.account = read.0
                    $0.balances = read.1
                    $0.receiving = read.2
                    $0.accountList = read.3
                    $0.watched = read.4
                    $0.fromKey = read.5
                    $0.freshAddress = read.6
                    $0.busy = .idle
                }
                self?.readAccount()
            }
        )
    }
}
