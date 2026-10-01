import Foundation

/// Where the wrapping key is held, strongest first.
/// Both rungs confirm the user and neither key is exportable. They differ in whether separate
/// hardware holds it. A device that cannot confirm its owner gets no rung: the wallet refuses a
/// seal it cannot defend against a phone seized unlocked.
enum Holder: String {
    /// Separate hardware, and the user confirmed for every use.
    case enclaveConfirmed

    /// The keychain, and the user confirmed for every use.
    case keychainConfirmed

    /// A phone seals only in the Enclave, which every iPhone that runs iOS 18 has: when the
    /// Enclave refuses, the wallet is refused too, rather than sealed quietly under a key the
    /// main processor holds. The keychain rung is for the simulator, which has no Enclave.
    #if targetEnvironment(simulator)
    static let strongestFirst: [Holder] = [.enclaveConfirmed, .keychainConfirmed]
    #else
    static let strongestFirst: [Holder] = [.enclaveConfirmed]
    #endif

    var inEnclave: Bool { self == .enclaveConfirmed }

    /// Where the key is, in the few words a fact row has.
    var place: String {
        switch self {
        case .enclaveConfirmed: "the Secure Enclave"
        case .keychainConfirmed: "the keychain"
        }
    }

    /// What the locked screen says about where the seed's key lives.
    var sentence: String {
        switch self {
        case .enclaveConfirmed:
            return "The seed is sealed under a key inside this device's Secure Enclave, "
                + "and that key will not be used until the device has confirmed it is you."
        case .keychainConfirmed:
            return "The seed is sealed under a key in this device's keychain, and that key "
                + "will not be used until the device has confirmed it is you."
        }
    }
}
