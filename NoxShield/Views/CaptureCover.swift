import SwiftUI
import UIKit

/// Whether any screen this app is on is being recorded, mirrored or shared.
enum Capture {
    @MainActor
    static func now() -> Bool {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.screen }
            .contains { $0.isCaptured }
    }
}

/// What a recording sees instead of the wallet, with the reason, so a share does not look broken.
struct CaptureCover: View {
    var body: some View {
        ZStack {
            Palette.dark.ignoresSafeArea()
            Text("Hidden while the screen is recorded or shared.")
                .font(.value(12))
                .foregroundStyle(Palette.darkMuted)
                .multilineTextAlignment(.center)
                .padding(Room.side)
        }
    }
}
