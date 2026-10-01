import Foundation

/// Everything in the app and what it is licensed under, read from two files the build generated.
/// The list walks the resolved dependency graph for the device, so it names the crates linked.
enum Licences {
    static var all: [String] {
        read("licences").split(separator: "\n").map(String.init).filter { !$0.isEmpty }
    }

    /// The notice texts, one block per distinct text, each headed by its crates.
    static var texts: [String] {
        read("licence-texts").components(separatedBy: "\n\u{0C}\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private static func read(_ name: String) -> String {
        guard let url = Bundle.main.url(forResource: name, withExtension: "txt"),
              let text = try? String(contentsOf: url, encoding: .utf8)
        else {
            return ""
        }
        return text
    }
}
