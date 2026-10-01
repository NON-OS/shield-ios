import Foundation

/// What an export put on screen: a title, the text, and whether it is the words, which are never
/// copied or drawn as a code.
struct Exported: Equatable {
    let title: String
    let text: String
    let words: Bool
}

/// The words and the keys of the active account. Each call opens the vault again, so the Secure
/// Enclave asks for the owner before anything is shown.
extension WalletStore {
    func showWords() {
        guard let wallet else { return }
        let handle = Handle(wallet)
        run(.unlocking, work: { try handle.value.recoveryWords() }, then: { [weak self] words in
            let text = words?.joined(separator: " ") ?? ""
            self?.show(Exported(title: "Recovery words", text: text, words: true))
        })
    }

    /// The private key of the active account's public address, to use in another wallet.
    func exportPublicKey() {
        guard let wallet else { return }
        let handle = Handle(wallet)
        let index = activeIndex
        let work = { try handle.value.exportPublicKey(index: index) }
        run(.unlocking, work: work, then: { [weak self] key in
            self?.show(Exported(title: "\(accountName(index)) key", text: key, words: false))
        })
    }

    func exportViewKey(_ kind: ViewKind) {
        guard let wallet else { return }
        let handle = Handle(wallet)
        let index = activeIndex
        let title = (kind == .full ? "Full view key, " : "Incoming view key, ") + accountName(index)
        let work = { try handle.value.exportViewKey(index: index, kind: kind) }
        run(.unlocking, work: work, then: { [weak self] key in
            self?.show(Exported(title: title, text: key, words: false))
        })
    }

    /// Drop the exported text from the state when its screen closes.
    func clearExported() { mutate { $0.exported = nil } }

    private func show(_ shown: Exported) { mutate { $0.exported = shown; $0.busy = .idle } }

    private var activeIndex: UInt32 { state.accountList.first(where: \.active)?.index ?? 0 }
}
