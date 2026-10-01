import SwiftUI
import UIKit

/// The whole navigation: the core's stage decides which screen is up. A cover replaces the content
/// in the background and while the screen is recorded or mirrored, so no snapshot or recording
/// holds a balance, an address or the phrase.
struct RootView: View {
    @EnvironmentObject private var store: WalletStore
    @Environment(\.scenePhase) private var phase

    @State private var captured = Capture.now()

    private let background = NotificationCenter.default
        .publisher(for: UIApplication.didEnterBackgroundNotification)
    private let capture = NotificationCenter.default
        .publisher(for: UIScreen.capturedDidChangeNotification)
    private let screenshot = NotificationCenter.default
        .publisher(for: UIApplication.userDidTakeScreenshotNotification)

    var body: some View {
        ZStack {
            // The id is the stage, so each screen is its own view and settles in.
            StageView()
            .id(store.state.stage)
            .transition(.settle)
            .animation(.easeOut(duration: Settle.arriving), value: store.state.stage)
            if phase != .active {
                Palette.dark.ignoresSafeArea()
            } else if captured, !store.state.recordingAllowed || store.state.stage == .restoring {
                CaptureCover()
            }
        }
        // Background, not inactive: an authentication prompt makes the app inactive, and locking
        // there would lock the wallet the user is opening.
        .onReceive(background) { _ in store.leftForeground() }
        .onReceive(capture) { _ in
            captured = Capture.now()
            store.mutate { $0.captured = captured }
        }
        .onAppear { store.mutate { $0.captured = captured } }
        .onReceive(screenshot) { _ in store.screenshotTaken() }
        .watchingTouches(store)
    }
}
