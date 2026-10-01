import Foundation

/// Removing the wrapping key, which is what makes destroying a wallet final.
/// The key goes even when the files are already gone, since flash may still hold their blocks.
enum Keychain {
    /// Remove the wrapping key. True when the keychain no longer holds it, or never did.
    static func destroyWrappingKey() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: EnclaveKey.tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
