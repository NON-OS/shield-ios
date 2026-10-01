import Foundation

/// Why the wrapping key would not open the vault.
/// Removing the passcode or restoring from a backup leaves the vault with no key, and only the
/// recovery phrase helps then. It runs only after a failure and asks whether the key exists,
/// learning nothing about the seed.
enum KeyProbe {
    /// True when a wallet is stored and the key that seals it is not there.
    static func keyGone() -> Bool {
        guard stored() else { return false }
        // A throw and a nil mean the same thing here: the keychain did not hand back the key that
        // seals the vault sitting beside it.
        return (try? EnclaveKey.find()) == nil
    }

    /// Whether a sealed vault exists at all, asked of the core, which owns the file name.
    private static func stored() -> Bool {
        guard let wallet = try? CoreWallet.open() else { return false }
        return wallet.stored()
    }
}
