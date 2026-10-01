import Foundation

/// What the wrapping key is generated under, in one place so that reading it is reading what
/// protects the seed. On every rung the key is this device's only, usable only while unlocked
/// and after the user is confirmed. `privateKeyUsage` applies only inside the Enclave.
/// With no access control there is no key: a key without one would open for anyone.
extension EnclaveKey {
    static func attributes(_ holder: Holder) throws -> [String: Any] {
        guard let access = control(holder) else { throw CustodyError.Guard }
        let privateAttributes: [String: Any] = [
            kSecAttrIsPermanent as String: true,
            kSecAttrApplicationTag as String: tag,
            kSecAttrAccessControl as String: access
        ]

        var attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecPrivateKeyAttrs as String: privateAttributes
        ]
        if holder.inEnclave {
            attributes[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
        }
        return attributes
    }

    // Every rung requires the user to be present. Without a passcode the keychain refuses the key.
    private static func control(_ holder: Holder) -> SecAccessControl? {
        var flags: SecAccessControlCreateFlags = [.userPresence]
        if holder.inEnclave {
            flags.insert(.privateKeyUsage)
        }
        return SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            flags,
            nil
        )
    }
}
