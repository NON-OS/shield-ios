import Foundation

/// The id of the spend last handed to the lander, kept in a file so a spend the app was closed on
/// is followed again when the wallet next opens. It names a queue entry at the lander, which saw
/// it over Tor already: no key, amount or address is in it. It goes once the spend settles, is
/// refused, or the owner is done with it.
enum HandoffRecord {
    private static let file = "handoff.txt"

    static func load() -> String? {
        guard let url = try? CoreWallet.storage().appendingPathComponent(file),
              let text = try? String(contentsOf: url, encoding: .utf8)
        else {
            return nil
        }
        let id = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return id.isEmpty ? nil : id
    }

    static func save(_ id: String?) {
        guard let url = try? CoreWallet.storage().appendingPathComponent(file) else { return }
        guard let id else {
            try? FileManager.default.removeItem(at: url)
            return
        }
        try? id.write(to: url, atomically: true, encoding: .utf8)
    }
}
