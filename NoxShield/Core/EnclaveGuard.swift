import Foundation
import LocalAuthentication

/// The platform half of custody. The core hands over its vault key and gets back a blob only
/// this device can open: the Secure Enclave holds a non-exportable P-256 key, and unwrapping
/// requires the owner to be present.
/// It holds no state so it can be Sendable, since a proof may run on any queue.
final class EnclaveGuard: HardwareGuard, Sendable {
    func wrap(key: Data) throws -> Data {
        guard let publicKey = SecKeyCopyPublicKey(try EnclaveKey.load()) else {
            throw CustodyError.Guard
        }
        var error: Unmanaged<CFError>?
        let sealed = SecKeyCreateEncryptedData(
            publicKey,
            EnclaveKey.algorithm,
            key as CFData,
            &error
        )
        guard let sealed, error == nil else { throw CustodyError.Guard }
        return sealed as Data
    }

    func unwrapKey(blob: Data) throws -> Data {
        var error: Unmanaged<CFError>?
        let opened = SecKeyCreateDecryptedData(
            try EnclaveKey.load(),
            EnclaveKey.algorithm,
            blob as CFData,
            &error
        )
        guard let opened, error == nil else { throw CustodyError.Guard }
        return opened as Data
    }
}
