import Foundation

/// How long an open wallet may sit untouched, for a phone left unlocked on a table.
enum Idle: CaseIterable {
    case immediately
    case oneMinute
    case fiveMinutes
    case never

    /// Not a duration, and stored as a number no duration can be.
    private static let forever: Int = -1

    var seconds: Int {
        switch self {
        case .immediately: 0
        case .oneMinute: 60
        case .fiveMinutes: 300
        case .never: Idle.forever
        }
    }

    var label: String {
        switch self {
        case .immediately: "immediately"
        case .oneMinute: "after a minute"
        case .fiveMinutes: "after five minutes"
        case .never: "never"
        }
    }

    /// The next choice, for a row tapped through them.
    func next() -> Idle {
        let all = Idle.allCases
        let at = all.firstIndex(of: self) ?? 0
        return all[(at + 1) % all.count]
    }

    /// Whether to lock at `now` after a touch at `touched`, in monotonic seconds. A negative gap
    /// from a clock jump never locks, and immediately means the next check.
    func expired(now: Int, touched: Int) -> Bool {
        guard self != .never else { return false }
        let gap = now - touched
        guard gap >= 0 else { return false }
        return gap >= seconds
    }

    /// Read a stored choice, falling back instead of failing.
    static func of(_ seconds: Int?) -> Idle {
        allCases.first { $0.seconds == seconds } ?? .fiveMinutes
    }
}
