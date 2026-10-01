import SwiftUI

/// The account and the network at the top of home, side by side, or one above the other when a
/// large text size leaves no room: side by side, the network squeezed the account's name to dots.
struct PillsRow: View {
    let onAccounts: () -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                AccountPill(onOpen: onAccounts)
                Spacer(minLength: 8)
                NetworkPill()
            }
            VStack(alignment: .leading, spacing: 12) {
                AccountPill(onOpen: onAccounts)
                NetworkPill()
            }
        }
    }
}
