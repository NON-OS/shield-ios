import UIKit

/// What this app does to a pasteboard, as a protocol, so the policy around it can be asserted
/// without one. Two writes and no reads: reading would return whatever the owner copied next,
/// and recent iOS would show them a paste prompt.
protocol Clip {
    func hold(_ address: String)
    func release()
}

/// The device's pasteboard, with both mitigations iOS offers.
/// Local only keeps it off Universal Clipboard. The expiry lets the system drop it while the app
/// is closed, and a running app also clears it itself after the minute.
struct SystemClip: Clip {
    private let plainText = "public.utf8-plain-text"

    func hold(_ address: String) {
        UIPasteboard.general.setItems(
            [[plainText: address]],
            options: [
                .localOnly: true,
                .expirationDate: Date().addingTimeInterval(HOLD),
            ]
        )
    }

    func release() {
        UIPasteboard.general.items = []
    }
}
