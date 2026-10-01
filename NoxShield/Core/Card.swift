import Foundation

/// Handing the measurement card to another app, as text and never as a file.
/// A shared file would hand another app a URL into the container that holds the sealed vault
/// and the note log. `body` returns a string, so no other file can be attached without changing
/// the signature and the test that reads it.
enum Card {
    /// The card as it will leave the device: what the run wrote, minus trailing newlines.
    /// Nothing is added, since a line appended here would not come from the measurement.
    static func body(_ card: String) -> String {
        var end = card.endIndex
        while end > card.startIndex {
            let before = card.index(before: end)
            guard card[before].isNewline || card[before] == " " else { break }
            end = before
        }
        return String(card[card.startIndex..<end])
    }
}
