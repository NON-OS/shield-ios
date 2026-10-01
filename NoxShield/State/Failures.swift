import Foundation

/// Turn a core failure into one line for a screen, from the typed variant, which carries no
/// secret. An unknown error is reported as unknown, never swallowed.
func describe(_ error: Error) -> String {
    if let wallet = error as? WalletError { return text(wallet) }
    if let custody = error as? CustodyError { return text(custody) }
    return "Something went wrong."
}

private func text(_ error: WalletError) -> String {
    switch error {
    case .Insufficient: return "That is more than the balance covers."
    case .NoSpendPlan: return "Two notes are needed to send. Receive again first."
    case .Address: return "That recipient address is not valid."
    case .Amount: return "That amount is out of range."
    case .ReviewExpired: return "That review has expired. Review the send again."
    default: return accounts(error)
    }
}

/// The failures of accounts and of what a private send may carry.
private func accounts(_ error: WalletError) -> String {
    switch error {
    case .NoSuchAccount: return "There is no such account."
    case .Unavailable: return "That is not in this build yet."
    case .NotStandard:
        return "Amounts come in standard sizes, 1, 2 or 5 followed by zeros, "
            + "from 1,000 NOX or 0.01 ETH."
    case .FeeTooHigh:
        return "The pool would not take this fee. Try again in a minute, or update the app."
    case .TooSoon: return "These notes are still new. Wait, or go early from the send screen."
    default: return layer(error)
    }
}

/// A failure that came up from a layer below the wallet, told by that layer.
private func layer(_ error: WalletError) -> String {
    switch error {
    case .Custody(let source): return text(source)
    case .Net(let source): return network(source)
    case .Store: return "The note store could not be read."
    case .Prove(let source): return proving(source)
    default: return "Something went wrong."
    }
}

private func text(_ error: CustodyError) -> String {
    switch error {
    case .Locked: return "The wallet is locked."
    case .Guard: return "The device keystore refused."
    case .Mnemonic: return "That recovery phrase did not check out."
    case .PhraseLength: return "A recovery phrase is 12, 15, 18, 21 or 24 words."
    case .VaultPresent: return "A wallet is already stored on this device."
    case .KeyShape: return "That private key is not valid: 64 hex digits of a real key."
    default: return "The stored wallet could not be opened on this device."
    }
}
