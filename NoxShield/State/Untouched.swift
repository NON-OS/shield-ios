import Foundation

/// Locking a wallet nobody is touching, for a phone left unlocked on a table. Work in flight is
/// left to finish, since interrupting a proof loses it and tells the holder nothing.
extension WalletStore {
    /// How often the check runs, and the sharpest the shortest choice can be.
    private static let check = Duration.seconds(5)

    func watchIdle() {
        touched()
        Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: WalletStore.check)
                guard let self else { return }
                guard self.state.stage == .ready, self.state.busy == .idle else { continue }
                if self.state.idle.expired(now: WalletStore.now(), touched: self.lastTouch) {
                    self.lock()
                }
            }
        }
    }

    /// Record that somebody is here.
    func touched() {
        lastTouch = WalletStore.now()
    }

    /// Move to the next choice and write it down, so it survives a restart.
    func cycleIdle() {
        let next = state.idle.next()
        Locking.save(next)
        mutate { $0.idle = next }
        touched()
    }

    /// Seconds on a clock that counts through sleep and that no time change can move. Uptime stops
    /// during sleep, and a lock a holder can postpone by editing a clock is no lock.
    static func now() -> Int {
        Int(clock_gettime_nsec_np(CLOCK_MONOTONIC) / 1_000_000_000)
    }
}
