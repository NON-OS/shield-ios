import Foundation

/// The Max amount, from the core: all of a token, and ether less the most a swap fee can be, so a
/// swap of everything still pays for itself.
extension WalletStore {
    func fillMax(_ coin: Coin, into: @escaping (String) -> Void) {
        guard let wallet else { return }
        let handle = Handle(wallet)
        let network = state.network
        run(.reading, work: { try handle.value.publicMax(network: network, coin: coin) },
            then: { [weak self] amount in
                self?.mutate { $0.busy = .idle }
                into(amount)
            })
    }
}
