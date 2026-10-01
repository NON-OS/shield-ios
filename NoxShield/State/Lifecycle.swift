import Foundation

/// Creating, restoring, unlocking and locking, each a single core call.
extension WalletStore {
    func create() {
        guard let wallet else { return }
        let handle = Handle(wallet)
        run(.unlocking, work: { try handle.value.create() }, then: { [weak self] words in
            self?.mutate { $0.stage = .showingPhrase; $0.phrase = words; $0.busy = .idle }
        })
    }

    /// Move on from the phrase screen, dropping the words from the state.
    func phraseConfirmed() {
        mutate { $0.phrase = [] }
        refresh()
    }

    func restore(words: [String]) {
        guard let wallet else { return }
        let handle = Handle(wallet)
        run(.unlocking, work: { try handle.value.restore(words: words) }, then: { [weak self] _ in
            self?.findAccounts()
        })
    }

    /// Restore from a private key: one account, no words, no other accounts to look for.
    func restoreFromKey(_ key: String) {
        guard let wallet else { return }
        let handle = Handle(wallet)
        let work = { try handle.value.restoreFromKey(key: key) }
        run(.unlocking, work: work, then: { [weak self] _ in self?.refresh() })
    }

    func unlock() {
        guard let wallet else { return }
        let handle = Handle(wallet)
        run(.unlocking, work: { try handle.value.unlock() }, then: { [weak self] _ in
            self?.refresh()
            self?.resumeLanding()
        })
    }

    /// Drop the session, and with it every key derived from the seed.
    func lock() {
        guard let wallet else { return }
        let handle = Handle(wallet)
        run(.idle, work: { try handle.value.lock() }, then: { [weak self] _ in
            self?.mutate {
                $0.stage = .locked
                $0.balances = []
                $0.account = ""
                $0.accounts = [:]
                $0.review = nil
                $0.sent = nil
                $0.sentStatus = nil
                $0.swap = nil
                $0.receiving = ""
                $0.chain = nil
                $0.deposit = nil
                $0.accountList = []
                $0.watched = []
                $0.exported = nil
                $0.shielding = nil
                $0.busy = .idle
            }
        })
    }
}
