import Foundation

/// Scanning on a schedule instead of only when somebody taps, so the timing says only that the
/// app is open. It runs only while unlocked and idle, and a scan does not reset the idle lock.
extension WalletStore {
    func scanOnSchedule() {
        Task { @MainActor [weak self] in
            while !Task.isCancelled {
                let wait = Schedule.next { Double.random(in: 0...1) }
                try? await Task.sleep(for: .seconds(wait))
                guard let self else { return }
                guard self.state.stage == .ready, self.state.busy == .idle else { continue }
                if networkHasShield(network: self.state.network) {
                    self.sync()
                } else {
                    self.readAccount()
                }
            }
        }
    }
}
