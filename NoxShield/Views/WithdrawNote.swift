import SwiftUI

/// Where a withdrawal goes, said plainly. It is public, so the app fills in an unused address of
/// this wallet, and warns when the address typed instead has been used before.
struct WithdrawNote: View {
    @EnvironmentObject private var store: WalletStore
    let withdraw: Bool
    let to: String

    var body: some View {
        if withdraw {
            Lead(text: text)
        }
    }

    private var text: String {
        if !to.isEmpty && to == store.state.freshAddress {
            return "A fresh address of this wallet, never used. The words restore it as the next "
                + "account."
        }
        if store.state.usedAddress {
            return "This address has been used before. A withdrawal to it can be linked to its "
                + "past. A fresh one is safer."
        }
        return "A withdrawal is public: its amount and the address it pays can be seen by anyone."
    }
}
