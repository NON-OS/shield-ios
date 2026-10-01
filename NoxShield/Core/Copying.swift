import Foundation

/// How long a copied address stays on the pasteboard: long enough to paste, gone before the
/// phone is handed over. Android waits the same minute.
let HOLD: TimeInterval = 60

/// Copying an address and then taking it back.
/// The pasteboard is readable by the next app opened, so the copy is cleared after the wait.
/// The wait is injected so a test can watch the clearing happen.
struct Wait {
    var hold: TimeInterval = HOLD
    let sleep: (TimeInterval) async -> Void
}

func copyThenClear(
    clip: Clip,
    address: String,
    onCopied: @escaping (Bool) -> Void,
    wait: Wait
) async {
    guard !address.isEmpty else { return }
    clip.hold(address)
    onCopied(true)
    await wait.sleep(wait.hold)
    clip.release()
    onCopied(false)
}
