import SwiftUI

/// The recovery phrase, and no copy button: other apps and a paired Mac read the clipboard. While
/// the screen is recorded the words are hidden and the screen still works.
struct PhraseView: View {
    @EnvironmentObject private var store: WalletStore

    var body: some View {
        ScreenFrame(
            heading: Heading(number: "01", title: "Recovery phrase"),
            failure: store.state.failure,
            onDismissFailure: store.dismissFailure,
            status: Status.of(store.state),
            backdrop: .backup,
            content: {
            Statement(text: "Write these 24 words down.")
            Lead(
                text: "On paper, not in a photo and not in a manager that syncs. These "
                    + "words are the wallet: nothing else can restore it."
            )
            if store.state.captured {
                Lead(text: "The words are hidden while the screen is recorded. Stop the recording "
                    + "to see them, or read them later in Settings, Recovery words and keys.")
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(store.state.phrase.enumerated()), id: \.offset) { index, word in
                        Text("\(index + 1). \(word)")
                            .font(.value(12))
                            .foregroundStyle(Palette.darkText)
                    }
                }
            }
        },
            footer: {
                Action(title: "I have written them down", run: store.phraseConfirmed)
            }
        )
    }
}
