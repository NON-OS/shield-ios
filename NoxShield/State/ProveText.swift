import Foundation

/// Why a proof stopped, in one sentence each, the same as on Android. Nothing is sent after any of
/// them, and most clear on a second try.
func proving(_ error: ProveError) -> String {
    switch error {
    case .SeedEntropy: return "This phone gave no randomness for the proof. Try again."
    case .SeedReused: return "A proof needs fresh randomness. Try again."
    case .WitnessUnsatisfied:
        return "The notes could not be proved against the pool. Refresh, then try again."
    case .Unbalanced: return "The amounts do not add up. Nothing was sent."
    case .SelfVerify:
        return "The proof did not check out on this phone. Nothing was sent. Try again."
    case .Cancelled: return "Proving was stopped. Nothing was sent."
    case .Encoding: return "The proof could not be packed for the relayer. Nothing was sent."
    case .RootNotPublished: return "The pool moved while the proof was made. Try again."
    }
}
