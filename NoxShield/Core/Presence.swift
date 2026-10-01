import Foundation
import LocalAuthentication

/// The owner saying yes, at the moment money leaves. An unlocked phone handed over is not the
/// owner agreeing, so every public send asks again.
enum Presence {
    static func confirm(_ reason: String, done: @escaping (Bool) -> Void) {
        let context = LAContext()
        context.localizedFallbackTitle = "Use passcode"
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { ok, _ in
            DispatchQueue.main.async { done(ok) }
        }
    }
}
