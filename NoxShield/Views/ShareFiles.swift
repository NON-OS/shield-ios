import SwiftUI
import UIKit

/// The system share sheet over files the core wrote, for AirDrop to a Mac.
struct ShareFiles: UIViewControllerRepresentable {
    let urls: [URL]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: urls, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}

    /// The proof and its public words, side by side where the core wrote them.
    static func launchProof(at path: String) -> [URL] {
        let proof = URL(fileURLWithPath: path)
        let dir = proof.deletingLastPathComponent()
        return [proof, dir.appendingPathComponent("launch-proof.publics.json")]
    }
}
