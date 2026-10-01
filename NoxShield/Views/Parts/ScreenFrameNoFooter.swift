import SwiftUI

/// The frame without a footer, for a screen whose subject is all there is: the phrase to write
/// down, a panel that only reads.
extension ScreenFrame where Footer == EmptyView {
    init(
        heading: Heading,
        failure: String?,
        onDismissFailure: @escaping () -> Void,
        onBack: (() -> Void)? = nil,
        status: [String] = [],
        backdrop: Backdrop? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            heading: heading,
            failure: failure,
            onDismissFailure: onDismissFailure,
            onBack: onBack,
            status: status,
            backdrop: backdrop,
            content: content,
            footer: { EmptyView() }
        )
    }
}
