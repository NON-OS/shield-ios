import SwiftUI

/// What a holder can change or find out about this wallet on this device. The key facts are read
/// from the key, so the screen never claims a chip the device is not using.
struct SettingsPanel: View {
    @EnvironmentObject private var store: WalletStore
    @State private var confirming = false
    let onKeys: () -> Void
    let onBack: () -> Void

    var body: some View {
        ScreenFrame(
            heading: Heading(number: "04", title: "Settings"),
            failure: store.state.failure,
            onDismissFailure: store.dismissFailure,
            onBack: onBack,
            status: Status.of(store.state),
            backdrop: .settings
        ) {
            Facts {
                Fact(name: "app", value: Release.version)
                Fact(name: "core", value: Provenance.current.line)
                Fact(name: "rustc", value: Provenance.current.rustc)
                Fact(name: "xcode", value: Provenance.current.xcode)
                Fact(name: "key held in", value: store.state.holder.place)
                Fact(name: "released", value: "after you are confirmed")
                Fact(name: "route", value: "tor, embedded")
                Fact(name: "lander", value: store.hasLander
                    ? "onion service, over Tor" : "none, you settle each spend")
                Fact(name: "jailbreak signs", value: IntegrityNote.fact(store.state.integrity))
            }
            IntegrityNote(finding: store.state.integrity)
            QuietGroup {
                Quiet(title: "Recovery words and keys", enabled: store.state.busy == .idle,
                      run: onKeys)
                QuietRule()
                Quiet(title: "Lock now", enabled: store.state.busy == .idle, run: store.lock)
                Quiet(title: store.state.recordingAllowed
                    ? "Screen recording: allowed, words and keys hidden"
                    : "Screen recording: hidden") { store.toggleRecording() }
                QuietRule()
                Quiet(title: "Licences") { store.show(.showingLicences) }
                QuietRule()
                Quiet(title: "Destroy this wallet", enabled: store.state.busy == .idle) {
                    confirming = true
                }
            }
            if confirming {
                WipeConfirmation { confirming = false }
            }
            Credits()
        }
    }
}
