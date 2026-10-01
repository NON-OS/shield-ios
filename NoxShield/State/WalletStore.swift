import Foundation

/// The single place the shell holds state. Actions run on a background queue and [mutate] hops to
/// the main thread before publishing, so views read a single value.
final class WalletStore: ObservableObject {
    @Published private(set) var state = UiState()

    private(set) var wallet: Wallet?
    private(set) var cancel: CancelToken?

    /// When somebody last touched the screen. Kept out of the state so a tap rebuilds no view.
    var lastTouch: Int = 0

    init() {
        // Before the core can start the prover's thread pool, which reads its count once.
        Threads.apply()
        restoreNetwork()
        open()
        watchIdle()
        scanOnSchedule()
    }

    /// Publish a new state on the main thread.
    func mutate(_ change: @escaping (inout UiState) -> Void) {
        if Thread.isMainThread {
            var next = state
            change(&next)
            state = next
            return
        }
        DispatchQueue.main.async { self.mutate(change) }
    }

    func hold(_ token: CancelToken?) {
        cancel = token
    }

    /// Take the wallet the core handed back. Only opening can replace it.
    func opened(_ wallet: Wallet?) {
        self.wallet = wallet
    }
}
