import SwiftUI

/// What the phone showed of a jailbreak, said as what was seen and not as a verdict: signs are
/// named, and finding none is not called safe, since a jailbreak built to hide shows none.
struct IntegrityNote: View {
    let finding: Integrity.Finding

    var body: some View {
        if let signs {
            Lead(text: "This phone shows signs of a jailbreak: " + signs.joined(separator: ", ")
                + ". On a jailbroken phone other code can read this wallet's memory and "
                + "screens. Keep no more here than you would lose.")
        }
    }

    private var signs: [String]? {
        guard case .signs(let signs) = finding else { return nil }
        return signs
    }

    /// The fact row's value.
    static func fact(_ finding: Integrity.Finding) -> String {
        switch finding {
        case .notChecked: "not checked on a simulator"
        case .noneFound: "none found, which a hidden one passes"
        case .signs(let signs): "\(signs.count) found"
        }
    }
}
