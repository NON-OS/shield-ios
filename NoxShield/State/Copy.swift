import Foundation

/// Copying the receive address, local to this device and cleared a minute later. The policy and
/// the wait live in Core, where tests assert them.
extension WalletStore {
    func copyAddress() {
        let address = state.receiving
        Task { @MainActor [weak self] in
            await copyThenClear(
                clip: SystemClip(),
                address: address,
                onCopied: { held in self?.mutate { $0.copied = held } },
                wait: Wait { seconds in
                    try? await Task.sleep(for: .seconds(seconds))
                }
            )
        }
    }

    /// Copying an exported key under the same policy: local to this device, cleared a minute later.
    func copyExported() {
        guard let shown = state.exported, !shown.words else { return }
        Task { @MainActor [weak self] in
            await copyThenClear(
                clip: SystemClip(),
                address: shown.text,
                onCopied: { held in self?.mutate { $0.copied = held } },
                wait: Wait { seconds in
                    try? await Task.sleep(for: .seconds(seconds))
                }
            )
        }
    }
}
