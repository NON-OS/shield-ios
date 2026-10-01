import Foundation

/// Whether the owner allows the screen to be recorded, kept in a file like the idle choice. Off
/// until chosen, and the words and exported keys stay hidden from a recording either way.
enum Recording {
    private static let file = "recording.txt"

    static func load() -> Bool {
        guard let url = try? CoreWallet.storage().appendingPathComponent(file),
              let text = try? String(contentsOf: url, encoding: .utf8)
        else {
            return false
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines) == "allowed"
    }

    static func save(_ allowed: Bool) {
        guard let url = try? CoreWallet.storage().appendingPathComponent(file) else { return }
        try? (allowed ? "allowed" : "hidden").write(to: url, atomically: true, encoding: .utf8)
    }
}

extension WalletStore {
    /// Allow or hide screen recording. The words and exported keys stay hidden either way.
    func toggleRecording() {
        let allowed = !state.recordingAllowed
        Recording.save(allowed)
        mutate { $0.recordingAllowed = allowed }
    }
}
