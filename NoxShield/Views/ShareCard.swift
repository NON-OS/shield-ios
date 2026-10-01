import SwiftUI

/// The share sheet for the last measurement card, handed a string, not a file URL, so the
/// receiving app gets no sandbox extension into the container with the sealed vault.
struct ShareCard: UIViewControllerRepresentable {
    let card: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [card], applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
