import Foundation

/// What the machine's line says, assembled in the single place: how the traffic leaves, which chain
/// it reads, and which build is running. It shows no soundness figure, since the phone's
/// rehearsal point is not one the pool's verifier accepts.
enum Status {
    static func of(_ state: UiState) -> [String] {
        ["tor, embedded", state.network.real ? "mainnet, real money" : "sepolia, test",
         Release.version]
    }
}
