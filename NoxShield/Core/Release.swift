import Foundation

/// Which build this is, read from the bundle instead of written down, so it cannot go stale.
enum Release {
    static var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String
        guard let short, short != "0.0.0" else { return "dev build" }
        return short
    }

    /// Whether this build offers swaps. The App Store build leaves them out, so App Review judges
    /// a wallet and not an exchange (guideline 3.1.5(iii)); scripts/testflight.sh sets STORE_BUILD.
    /// The sideloaded build keeps them.
    #if STORE_BUILD
    static let swaps = false
    #else
    static let swaps = true
    #endif
}
