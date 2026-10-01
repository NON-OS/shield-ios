import Foundation

/// Breaking a long value into runs of eight, so a person can check it and a quiet alteration shows.
enum Groups {
    static let run = 8

    /// How much of each end survives a cut, and what stands in for the rest.
    private static let ends = 6
    private static let mark = "…"

    static func grouped(_ value: String, run: Int = Groups.run) -> String {
        stride(from: 0, to: value.count, by: run)
            .map { start in
                let from = value.index(value.startIndex, offsetBy: start)
                let to = value.index(from, offsetBy: min(run, value.count - start))
                return String(value[from..<to])
            }
            .joined(separator: " ")
    }

    /// A long value cut to its ends, as in 0x6def9b…f3a4. Both ends stay, so a forged prefix must
    /// also match the suffix, and the ellipsis says something was left out.
    static func hash(_ value: String) -> String {
        guard value.hasPrefix("0x"), value.count > 12 else { return value }
        return String(value.prefix(8)) + mark + String(value.suffix(4))
    }

    static func shortened(_ value: String, ends: Int = Groups.ends) -> String {
        guard value.count > ends * 2 + mark.count else { return value }
        return String(value.prefix(ends)) + mark + String(value.suffix(ends))
    }
}
