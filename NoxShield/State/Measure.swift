import Foundation

/// The measurement screen's two actions. They ship in the app because the release gate is a
/// proof timed on a real phone.
extension WalletStore {
    func measureProof() {
        guard let wallet else { return }
        let token = CancelToken()
        hold(token)
        let handle = Handle((wallet, token))
        // The measurement screen opens at once, so the run shows its bar and its clock.
        mutate { $0.stage = .measuring; $0.bench = nil; $0.cardPath = nil }
        run(.measuring, work: {
            let (open, cancel) = handle.value
            let start = Machine.conditions()
            var report = try open.benchProof(cancel: cancel)
            // The core has no high water mark on iOS, so the kernel's is put on the report, and
            // the card says where it ran, with how much memory and how many threads.
            let memory = Footprint.sample()
            report.peakKib = report.peakKib ?? memory?.peakKib
            let note = [Machine.describe(), "at the start " + start,
                        "at the end " + Machine.conditions(), memory?.line,
                        "threads " + Threads.inUse]
            // The card goes to a file as well, so a run can be quoted and diffed.
            let card = try? open.saveMeasurement(
                report: report,
                note: note.compactMap { $0 }.joined(separator: "; ")
            )
            return (report, memory, card)
        }, then: { [weak self] outcome in
            self?.hold(nil)
            self?.mutate {
                $0.bench = outcome.0
                $0.footprint = outcome.1
                $0.cardPath = outcome.2
                $0.stage = .measuring
                $0.busy = .idle
            }
        })
    }
}

extension WalletStore {
    /// Prove on two threads from the next launch, or on every core again.
    func toggleThreads() {
        let next: UInt32? = state.threads == nil ? Threads.few : nil
        Threads.save(next)
        mutate { $0.threads = next }
    }
}
