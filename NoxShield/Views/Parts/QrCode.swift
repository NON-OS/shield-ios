import CoreImage.CIFilterBuiltins
import SwiftUI

/// A value as a QR code, drawn on this device by Core Image, so nothing leaves the app to draw it.
struct QrCode: View {
    let value: String

    var body: some View {
        if let image = Self.render(value) {
            Image(decorative: image, scale: 1)
                .interpolation(.none)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: Edge.corner))
        }
    }

    private static func render(_ value: String) -> CGImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(value.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }
        return CIContext().createCGImage(output, from: output.extent)
    }
}
