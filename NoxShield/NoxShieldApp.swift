import SwiftUI

/// The app. It starts nothing: no analytics, no crash reporter, no push registration. The wallet
/// is built when a screen asks for it and dropped when the session locks.
@main
struct NoxShieldApp: App {
    @StateObject private var store = WalletStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .background(Palette.dark.ignoresSafeArea())
        }
    }
}
