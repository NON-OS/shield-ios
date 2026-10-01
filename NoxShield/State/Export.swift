import Foundation

/// Reading back the card the last measured run wrote, from the file itself, so what leaves is
/// what is on disk. An unreadable card is nothing to share, never an empty share.
extension WalletStore {
    func card() -> String? {
        guard let path = state.cardPath,
              let text = try? String(contentsOfFile: path, encoding: .utf8)
        else {
            return nil
        }
        let body = Card.body(text)
        return body.isEmpty ? nil : body
    }
}
