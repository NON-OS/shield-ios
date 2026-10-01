import Foundation

/// Following a sent transaction until the network settles it: every twelve seconds, about a block,
/// for up to half an hour. A private relay can hide it until mined, so pending is honest a while.
extension WalletStore {
    func watch(_ sent: PublicSent, on network: Network) {
        guard let wallet else { return }
        let handle = Handle(wallet)
        Task { @MainActor [weak self] in
            for _ in 0..<150 {
                try? await Task.sleep(for: .seconds(12))
                guard let self, self.state.sent?.hash == sent.hash else { return }
                let status = await Task.detached {
                    try? handle.value.publicSendStatus(network: network, hash: sent.hash)
                }.value
                guard let status, status != .pending else { continue }
                self.mutate { $0.sentStatus = status }
                self.readAccount()
                return
            }
        }
    }
}
