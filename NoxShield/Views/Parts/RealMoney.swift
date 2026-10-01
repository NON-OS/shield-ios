import SwiftUI

/// Which network a screen is acting on, said before anything else on it. Mainnet says real money,
/// since a send there cannot be taken back.
struct RealMoney: View {
    let network: Network

    var body: some View {
        Text(network.real ? "REAL MONEY  ·  ETHEREUM MAINNET" : "TEST NETWORK  ·  SEPOLIA")
            .font(.value(12))
            .tracking(1.6)
            .foregroundStyle(network.real ? Palette.ink : Palette.darkMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(network.real ? Palette.cyan : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: Edge.corner))
            .overlay(
                RoundedRectangle(cornerRadius: Edge.corner)
                    .stroke(network.real ? Color.clear : Palette.darkLine, lineWidth: Edge.hair)
            )
            .accessibilityLabel(network.real ? "Real money, Ethereum mainnet" : "Test network")
    }
}
