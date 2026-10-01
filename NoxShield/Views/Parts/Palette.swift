import SwiftUI

/// The palette, from the brand book at nonos.software/brand, where every colour has a job.
enum Palette {
    static let cyan = Color(red: 0x66 / 255, green: 0xFF / 255, blue: 0xFF / 255)
    static let ink = Color(red: 0x0A / 255, green: 0x0B / 255, blue: 0x0D / 255)
    static let deepTeal = Color(red: 0x2E / 255, green: 0x5C / 255, blue: 0x5C / 255)
    static let paper = Color(red: 0xF2 / 255, green: 0xF3 / 255, blue: 0xF7 / 255)

    /// The ground everything sits on, and the two names the views already use.
    // The shared design tokens, design-tokens.json version 1, the same file the explorer site is
    // built from.
    static let surface = Color(red: 0x10 / 255, green: 0x12 / 255, blue: 0x15 / 255)
    static let text2 = Color(red: 0xA3 / 255, green: 0xA4 / 255, blue: 0xA7 / 255)
    static let text3 = Color(red: 0x87 / 255, green: 0x88 / 255, blue: 0x8B / 255)
    static let line = Color(red: 0x1F / 255, green: 0x20 / 255, blue: 0x22 / 255)
    static let line2 = Color(red: 0x2F / 255, green: 0x30 / 255, blue: 0x32 / 255)
    static let bad = Color(red: 0xFF / 255, green: 0x8A / 255, blue: 0x8A / 255)

    static let dark = ink
    static let darkText = paper
    static let darkMuted = text3

    /// A card or a field, which is ink with a little light on it.
    static let dark2 = Color.white.opacity(0.05)
    static let dark3 = Color.white.opacity(0.08)

    /// A rule that divides without shouting.
    static let darkLine = Color.white.opacity(0.12)

    /// Buttons, highlights and labels: the book's own pair.
    static let accent = cyan

    /// One corner, everywhere.
    static let radius: CGFloat = 14

    /// One height for every action, so a row of them sits on one line.
    static let tall: CGFloat = 52
}
