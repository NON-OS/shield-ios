import Foundation

/// Run a core call off the main thread and fold its outcome into the state.
/// The wallet handle crosses queues safely: the core guards its session with a mutex and every
/// entry point takes a shared reference, so the Rust side is Send and Sync.
final class Handle<Value>: @unchecked Sendable {
    let value: Value

    init(_ value: Value) {
        self.value = value
    }
}

private let coreQueue = DispatchQueue(label: "systems.nonos.shield.core", qos: .userInitiated)

extension WalletStore {
    func run<Value>(
        _ busy: Busy,
        work: @escaping () throws -> Value,
        then finish: @escaping (Value) -> Void
    ) {
        mutate { $0.busy = busy; $0.failure = nil }
        coreQueue.async {
            let outcome = Result(catching: work)
            DispatchQueue.main.async {
                switch outcome {
                case .success(let value): finish(value)
                case .failure(let error): self.failed(error)
                }
            }
        }
    }

    /// Report a failure the user can read, and leave the wallet where it was. A key the device
    /// destroyed is told apart from one that refused once, since only the phrase recovers it, and
    /// a locked wallet without its key moves to the stage that offers the way out.
    func failed(_ error: Error) {
        let gone = KeyProbe.keyGone()
        let text = gone
            ? "This device no longer has the key that sealed this wallet. "
                + "Restore from the recovery words."
            : describe(error)
        mutate { state in
            state.busy = .idle
            state.failure = text
            if gone && state.stage == .locked { state.stage = .keyGone }
        }
    }

    /// Clear a failure the user has read.
    func dismissFailure() {
        mutate { $0.failure = nil }
    }
}
