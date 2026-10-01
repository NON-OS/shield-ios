import Foundation
import LocalAuthentication

/// What this device actually gave us, asked of the device instead of assumed from what was
/// requested. The locked screen reports this, so it never claims a chip the device lacks.
enum Custody {
    /// Which rung the wrapping key ended up on, read back from the key itself.
    static func holder() -> Holder {
        guard let key = try? EnclaveKey.find() ?? nil else { return .keychainConfirmed }
        guard let attributes = SecKeyCopyAttributes(key) as? [String: Any] else {
            return .keychainConfirmed
        }
        let token = attributes[kSecAttrTokenID as String] as? String
        return token == (kSecAttrTokenIDSecureEnclave as String)
            ? .enclaveConfirmed
            : .keychainConfirmed
    }

    /// True when this device can confirm its owner at all: a passcode, or a biometric enrolled on
    /// top of one. Without it the keychain refuses a presence-bound key, so the welcome screen asks
    /// first and says what to fix before any seed exists.
    static func canConfirmOwner() -> Bool {
        LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
}
