import Foundation

/// Which core this build carries, read from a file the build wrote: the commit, both toolchains,
/// and whether the tree was clean. A missing file shows unknown, never a typed number.
struct Provenance: Equatable {
    let commit: String
    let state: String
    let rustc: String
    let xcode: String

    private static let unknown = Provenance(
        commit: "unknown",
        state: "unknown",
        rustc: "unknown",
        xcode: "unknown"
    )

    /// One line for a fact row: the commit, and the state when it matters.
    var line: String { state == "clean" ? commit : "\(commit) (\(state))" }

    static var current: Provenance {
        guard let url = Bundle.main.url(forResource: "core", withExtension: "txt"),
              let text = try? String(contentsOf: url, encoding: .utf8)
        else {
            return unknown
        }
        return read(text)
    }

    /// Three words to a line, in the order the build writes them.
    static func read(_ text: String) -> Provenance {
        var fields: [String: String] = [:]
        for line in text.split(separator: "\n") {
            let parts = line.trimmingCharacters(in: .whitespaces).split(
                separator: " ", maxSplits: 1
            )
            guard parts.count == 2 else { continue }
            fields[String(parts[0])] = String(parts[1])
        }
        return Provenance(
            commit: fields["commit"] ?? unknown.commit,
            state: fields["state"] ?? unknown.state,
            rustc: fields["rustc"] ?? unknown.rustc,
            xcode: fields["xcode"] ?? unknown.xcode
        )
    }
}
