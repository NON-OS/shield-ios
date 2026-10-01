import SwiftUI

/// The active account on home: its colour, its name and its short address. Tapping it opens the
/// list of accounts.
struct AccountPill: View {
    @EnvironmentObject private var store: WalletStore
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            HStack(spacing: 10) {
                Avatar(address: store.state.account)
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.state.activeName)
                        .font(.sans(15, .semibold))
                        .foregroundStyle(Palette.darkText)
                    Text(Groups.shortened(store.state.account))
                        .font(.value(12))
                        .foregroundStyle(Palette.darkMuted)
                }
                .fixedSize(horizontal: false, vertical: true)
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Palette.darkMuted)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(Steady())
        .disabled(store.state.busy != .idle)
        .accessibilityLabel("\(store.state.activeName), change account")
    }
}
