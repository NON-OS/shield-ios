import SwiftUI

/// How the keyboard behaves in this app's fields. Correction and spell checking are off so no
/// address or phrase word lands in a keyboard's dictionary. A keyboard can still read what is
/// typed, and the app has no answer to that yet.
enum Typing {
    /// An address, a host, a phrase: text the keyboard must not learn.
    case exact
    /// An amount, which has a decimal point.
    case amount

    var keyboard: UIKeyboardType {
        switch self {
        case .exact: return .asciiCapable
        case .amount: return .decimalPad
        }
    }
}
