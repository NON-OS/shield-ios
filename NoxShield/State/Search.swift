import Foundation

extension WalletStore {
    /// Read how many accounts the search has looked at, each second while it runs.
    func watchSearch(_ handle: Handle<Wallet>) {
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(1))
            while let self, self.state.busy == .finding {
                let seen = handle.value.accountSearchProgress()
                self.mutate { $0.searched = seen }
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }
}
