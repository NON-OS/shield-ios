import Foundation

/// Where the idle choice is kept: a file in the container, excluded from backup, with no
/// UserDefaults to declare. An unreadable file means no choice, which only locks sooner.
enum Locking {
    private static let file = "lock.txt"

    static func load() -> Idle {
        guard let url = try? CoreWallet.storage().appendingPathComponent(file),
              let text = try? String(contentsOf: url, encoding: .utf8)
        else {
            return .fiveMinutes
        }
        return Idle.of(Int(text.trimmingCharacters(in: .whitespacesAndNewlines)))
    }

    static func save(_ idle: Idle) {
        guard let url = try? CoreWallet.storage().appendingPathComponent(file) else { return }
        try? "\(idle.seconds)".write(to: url, atomically: true, encoding: .utf8)
    }
}
