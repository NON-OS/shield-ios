import SwiftUI

/// The notes that would pay are too new. Waiting keeps the deposit and this spend apart. Going
/// early is allowed, but only by typing the word, so it is never a tap made in passing.
struct EarlyConfirm: View {
    @EnvironmentObject private var store: WalletStore
    let order: SpendOrder
    @State private var typed = ""

    private let word = "EARLY"

    var body: some View {
        Group {
            Statement(text: "These notes are still new.")
            Lead(text: "The pool must add 20 more notes and six hours must pass before they "
                + "blend in. Sent now, anyone watching can link your deposit to this spend by "
                + "its timing.")
            Field(label: "Type \(word) to send now anyway", text: $typed)
            Action(title: "Send now anyway", enabled: idle && typed == word) {
                var early = order
                early.early = true
                store.spend(early)
            }
            Action(title: "Wait instead", filled: false, enabled: idle) {
                store.mutate { $0.tooSoon = nil }
            }
        }
    }

    private var idle: Bool { store.state.busy == .idle }
}
