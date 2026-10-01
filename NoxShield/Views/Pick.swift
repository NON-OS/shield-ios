import SwiftUI

/// A row chosen by tapping it: a name, and a detail in the quieter colour.
struct Pick: View {
    let title: String
    let detail: String
    var enabled: Bool = true
    let run: () -> Void

    var body: some View {
        Button(action: run) {
            HStack {
                Text(title).font(.value(14)).foregroundStyle(Palette.darkText)
                Spacer()
                Text(detail).font(.value(14)).foregroundStyle(Palette.darkMuted)
            }
            .padding(.vertical, 12)
        }
        .disabled(!enabled)
    }
}
