import SwiftUI

/// A line that resolves character by character, which is the brand's own rule for a title arriving.
@MainActor
final class Resolve: ObservableObject {
    @Published private(set) var shown = 0
    /// Set once the line has arrived. A line that changes after that, a status moving on, is shown
    /// whole: counting its characters against the first line's cut a longer one short.
    @Published private(set) var arrived = false

    /// The longest the whole line may take, and the longest one character may.
    private static let whole = 0.42
    private static let step = 0.022

    func run(_ text: String) {
        guard shown == 0 else { return }
        let count = max(text.count, 1)
        let step = min(Self.whole / Double(count), Self.step)
        Task { @MainActor [weak self] in
            while let self, self.shown < count {
                try? await Task.sleep(for: .seconds(step))
                self.shown += 1
            }
            self?.arrived = true
        }
    }

    func take(_ text: String) -> String {
        arrived ? text : String(text.prefix(shown))
    }
}
