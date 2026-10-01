import Foundation

/// How many threads the prover may use, kept in a file like the idle choice. Every core is the
/// default. Two is the other choice, for a phone whose memory a first proof runs close to: each
/// thread carries its own working set. The prover's thread pool reads the count once, when it
/// starts, so a change applies the next time the app opens.
enum Threads {
    private static let file = "threads.txt"
    /// The variable the prover's thread pool reads when it starts.
    private static let variable = "RAYON_NUM_THREADS"
    static let few: UInt32 = 2

    /// The saved choice: a count, or nil for every core.
    static func load() -> UInt32? {
        guard let url = try? CoreWallet.storage().appendingPathComponent(file),
              let text = try? String(contentsOf: url, encoding: .utf8)
        else {
            return nil
        }
        return parse(text)
    }

    static func save(_ count: UInt32?) {
        guard let url = try? CoreWallet.storage().appendingPathComponent(file) else { return }
        try? (count.map { String($0) } ?? "all").write(to: url, atomically: true, encoding: .utf8)
    }

    /// A count between 1 and 16, or nil for anything else, which means every core.
    static func parse(_ text: String) -> UInt32? {
        guard let count = UInt32(text.trimmingCharacters(in: .whitespacesAndNewlines)),
              (1...16).contains(count)
        else {
            return nil
        }
        return count
    }

    /// Hand the saved choice to the prover, before anything has started its pool.
    static func apply() {
        if let count = load() {
            setenv(variable, String(count), 1)
        }
    }

    /// What this run of the app proves with, in the words a fact row has.
    static var inUse: String {
        if let set = getenv(variable).flatMap({ parse(String(cString: $0)) }) {
            return "\(set) threads"
        }
        return "all \(ProcessInfo.processInfo.activeProcessorCount) cores"
    }
}
