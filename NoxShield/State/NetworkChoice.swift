import Foundation

/// Which network the public account is shown on, kept between launches. Sepolia is the default,
/// so a fresh install never lands on real money. Switching drops a pending review, which belongs
/// to the network it was worked out on.
extension WalletStore {
    private static let file = "network.txt"

    func restoreNetwork() {
        let url = try? CoreWallet.storage().appendingPathComponent(WalletStore.file)
        let saved = url.flatMap { try? String(contentsOf: $0, encoding: .utf8) }
        mutate { $0.network = saved == "mainnet" ? .mainnet : .sepolia }
    }

    func choose(_ network: Network) {
        if let url = try? CoreWallet.storage().appendingPathComponent(WalletStore.file) {
            try? (network == .mainnet ? "mainnet" : "sepolia")
                .write(to: url, atomically: true, encoding: .utf8)
        }
        mutate {
            $0.network = network
            $0.review = nil
            $0.sent = nil
            $0.sentStatus = nil
        }
        readAccount()
    }
}
