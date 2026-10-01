import SwiftUI

/// The frame every screen sits in: a bar, a scrolling subject, and the actions pinned where a thumb
/// reaches them.
struct ScreenFrame<Content: View, Footer: View>: View {
    let heading: Heading
    let failure: String?
    let onDismissFailure: () -> Void
    var onBack: (() -> Void)?
    var status: [String] = []
    /// The section's photograph, above the content and never under it.
    var backdrop: Backdrop?
    @ViewBuilder var content: Content
    @ViewBuilder var footer: Footer
    @Environment(\.dynamicTypeSize) private var size

    var body: some View {
        VStack(spacing: 0) {
            bar
            ScrollView {
                VStack(spacing: 0) {
                    if let backdrop {
                        BackdropBand(backdrop: backdrop)
                    }
                    VStack(alignment: .leading, spacing: Room.gap) {
                        if let failure {
                            FailureBanner(text: failure, onDismiss: onDismissFailure)
                        }
                        content
                    }
                    .padding(.horizontal, Room.side)
                    .padding(.vertical, Room.room)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    // At the accessibility text sizes the actions and the machine's line scroll
                    // with the screen: pinned, they took most of it and left the subject a sliver.
                    if size.isAccessibilitySize { below }
                }
            }
            if !size.isAccessibilitySize { below }
        }
        .background(Palette.dark)
    }

    @ViewBuilder private var below: some View {
        if !(Footer.self == EmptyView.self) {
            Rule()
            VStack(spacing: Room.tight) {
                footer
            }
            .padding(.horizontal, Room.side)
            .padding(.vertical, Room.room)
        }
        if !status.isEmpty {
            Rule()
            StatusLine(parts: status)
        }
    }

    private var bar: some View {
        Bar(heading: heading, onBack: onBack)
    }
}
