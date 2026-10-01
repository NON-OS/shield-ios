import Foundation

/// The wrapping key itself, generated on first use and never leaving the device.
/// The strongest holder the device offers is taken. Every rung is non-exportable and bound to
/// this device, and [Custody.holder] reports the rung actually taken.
enum EnclaveKey {
    /// ECIES with an ephemeral key and AES-GCM, which is what the Enclave offers.
    static let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM

    static let tag = "systems.nonos.shield.vault.v1".data(using: .utf8) ?? Data()

    /// The key, loading it or generating it.
    static func load() throws -> SecKey {
        if let existing = try find() { return existing }
        for holder in Holder.strongestFirst {
            if let key = try? generate(holder) { return key }
        }
        throw CustodyError.Guard
    }

    static func find() throws -> SecKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        // Checked by type id: a conditional cast to a CoreFoundation type always succeeds.
        guard status == errSecSuccess, let item, CFGetTypeID(item) == SecKeyGetTypeID() else {
            throw CustodyError.Guard
        }
        return unsafeDowncast(item, to: SecKey.self)
    }

    private static func generate(_ holder: Holder) throws -> SecKey {
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateRandomKey(
            try attributes(holder) as CFDictionary,
            &error
        ), error == nil else {
            throw CustodyError.Guard
        }
        return key
    }
}
