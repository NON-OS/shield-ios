import SwiftUI

/// The network, as a small pill at the top of home: a dot, its name, and a menu to switch.
/// Mainnet says real money. The same address holds money on both.
struct NetworkPill: View {
    @EnvironmentObject private var store: WalletStore

    var body: some View {
        Menu {
            Button("Sepolia, test network") { store.choose(.sepolia) }
            Button("Ethereum, real money") { store.choose(.mainnet) }
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .fill(real ? Palette.cyan : Palette.darkMuted)
                    .frame(width: 8, height: 8)
                Text(real ? "Ethereum" : "Sepolia")
                    .font(.sans(13, .medium))
                    .foregroundStyle(Palette.darkText)
                    .lineLimit(1)
                    .fixedSize()
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Palette.darkMuted)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            // A floor, not a height: a larger text size grows the pill instead of spilling out.
            .frame(minHeight: 32)
            .background(Capsule().fill(Palette.dark3))
        }
        .disabled(store.state.busy != .idle)
        .accessibilityLabel(real ? "Network: Ethereum, real money" : "Network: Sepolia, test")
    }

    private var real: Bool { store.state.network.real }
}
