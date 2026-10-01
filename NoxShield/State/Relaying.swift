import Foundation

/// Handing a proved spend to the lander over its onion service, then following it until it is
/// settled or refused. The core checks that the lander takes a fee paid to whoever submits. The id
/// is kept in a file, so a spend the app was closed on is followed again at the next unlock. After
/// half an hour with no landing, the owner can ask again or settle it from the public account.
extension WalletStore {
    func handToRelayer() {
        guard let wallet else { return }
        let handle = Handle(wallet)
        run(.handing, work: { try handle.value.handToRelayer() }, then: { [weak self] handed in
            self?.mutate { $0.relay = handed; $0.busy = .idle }
            HandoffRecord.save(handed.id)
            if let id = handed.id { self?.follow(id) }
        })
    }

    /// Follow a spend handed over before the app was last closed, once the wallet is open again.
    func resumeLanding() {
        guard state.relay == nil, let id = HandoffRecord.load() else { return }
        mutate { $0.relay = RelayHandoff(id: id, refusal: nil); $0.notLanded = false }
        follow(id)
    }

    /// Ask the lander again for another half hour, after a wait with no landing.
    func askAgain() {
        guard let id = state.relay?.id else { return }
        mutate { $0.notLanded = false }
        follow(id)
    }

    /// Ask every ten seconds, for up to half an hour, until the lander says settled or refused,
    /// then read the pool so the notes move.
    private func follow(_ id: String) {
        guard let wallet else { return }
        let handle = Handle(wallet)
        Task { @MainActor [weak self] in
            for _ in 0..<180 {
                try? await Task.sleep(for: .seconds(10))
                guard let self, self.state.relay?.id == id, !self.state.notLanded else { return }
                let state = await Task.detached { try? handle.value.relayerState(id: id) }.value
                guard let state else { continue }
                self.mutate { $0.relayState = state }
                if state.status == "settled" || state.status == "refused" {
                    HandoffRecord.save(nil)
                    // A locked wallet reads the pool when it is next opened instead.
                    if self.state.stage == .ready { self.sync() }
                    return
                }
            }
            self?.mutate { $0.notLanded = true }
        }
    }
}
