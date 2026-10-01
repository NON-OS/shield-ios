import SwiftUI

/// The bar at the top of every screen: the way back when there is one, the screen's number and
/// name, then the rule.
struct Bar: View {
    let heading: Heading
    var onBack: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                if let onBack {
                    Back(run: onBack)
                }
                Label(text: heading.title, number: heading.number)
                    .padding(.leading, onBack == nil ? Room.side : 0)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, Room.half)
            .padding(.vertical, Room.tight)
            Rule()
        }
    }
}
