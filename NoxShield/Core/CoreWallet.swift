import Foundation

/// Builds the core's wallet for this device, in its own container, guarded by the Secure Enclave.
enum CoreWallet {
    /// The wallet on this device, with no relayer until sending asks for one.
    static func open() throws -> Wallet {
        try Wallet(directory: storage().path, guard: EnclaveGuard())
    }

    /// The app's own container. Failing to exclude it from backup throws, to keep notes off iCloud.
    static func storage() throws -> URL {
        let support = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )
        guard let base = support.first else {
            throw CocoaError(.fileNoSuchFile)
        }
        var directory = base.appendingPathComponent("shield", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        var resources = URLResourceValues()
        resources.isExcludedFromBackup = true
        try directory.setResourceValues(resources)
        try protect(directory, .complete)
        // Older files keep their original class, so the vault and the note store are set by name.
        for name in ["vault.seal", "notes.log", "measurement.txt"] {
            let file = directory.appendingPathComponent(name)
            if FileManager.default.fileExists(atPath: file.path) {
                try protect(file, .complete)
            }
        }
        // Tor writes its cache just after the phone locks, which complete protection would fail.
        let tor = directory.appendingPathComponent("tor", isDirectory: true)
        try FileManager.default.createDirectory(at: tor, withIntermediateDirectories: true)
        try protect(tor, .completeUntilFirstUserAuthentication)
        return directory
    }

    /// Sets a protection class. Complete means unreadable, even to this app, while locked.
    private static func protect(_ url: URL, _ type: FileProtectionType) throws {
        try FileManager.default.setAttributes([.protectionKey: type], ofItemAtPath: url.path)
    }
}
