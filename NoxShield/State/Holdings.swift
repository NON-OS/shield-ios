import Foundation

/// Reading the state by coin, so no view searches a list for its number.
extension UiState {
    /// The shielded balance of one coin, or nothing before the first read.
    func shield(_ coin: Coin) -> Balance? {
        balances.first { $0.coin == coin }
    }

    /// The public account on the network being shown.
    var publicHere: PublicBalances? {
        accounts[network]
    }
}

extension Network {
    /// The name a screen gives the network.
    var name: String {
        switch self {
        case .mainnet: return "Ethereum"
        case .sepolia: return "Sepolia"
        }
    }

    /// Whether money here is real.
    var real: Bool { self == .mainnet }
}
