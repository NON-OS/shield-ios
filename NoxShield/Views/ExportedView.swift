import SwiftUI

/// What an export shows. The words are never copied and never drawn as a code, only read and
/// written down, and a screenshot of them is answered with a warning as on the first screen. A key
/// can be copied, local to this device and cleared a minute later, and a view key is drawn as QR.
struct ExportedView: View {
    let shown: Exported
    let onCopy: () -> Void
    let onDone: () -> Void

    var body: some View {
        Group {
            Label(text: shown.title)
            if shown.words && shown.text.isEmpty {
                Lead(text: "This wallet keeps its seed and not its words, so they cannot be shown "
                    + "again. If the written copy is not certain, create a new wallet, write its "
                    + "words down, and move the value to it.")
            } else if shown.words {
                Tile {
                    ForEach(Array(rows.enumerated()), id: \.offset) { i, three in
                        TileRow(
                            name: "\(i * 3 + 1) to \(i * 3 + three.count)",
                            value: three.joined(separator: "  ")
                        )
                    }
                }
            } else {
                ValueBlock(value: shown.text)
                if shown.text.hasPrefix("nox") { QrCode(value: shown.text) }
                Action(title: "Copy, cleared in a minute", filled: false, run: onCopy)
            }
            Action(title: "Done", run: onDone)
        }
    }

    private var rows: [[String]] {
        let words = shown.text.split(separator: " ").map(String.init)
        return stride(from: 0, to: words.count, by: 3).map {
            Array(words[$0..<min($0 + 3, words.count)])
        }
    }
}
