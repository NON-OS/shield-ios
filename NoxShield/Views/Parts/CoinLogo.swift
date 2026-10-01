import SwiftUI

/// Each coin's mark, drawn in code at any size: the Ethereum diamond, the NØNOS Ø for NOX, and
/// USDC's blue disc.
struct CoinLogo: View {
    let coin: Coin
    var side: CGFloat = 28

    var body: some View {
        mark
            .frame(width: side, height: side)
            .accessibilityHidden(true)
    }

    @ViewBuilder private var mark: some View {
        switch coin {
        case .eth:
            EtherDiamond()
                .fill(Palette.paper)
                .padding(side * 0.1)
        case .nox:
            Mark(side: side * 0.8)
        case .usdc:
            Circle()
                .fill(Color(red: 0x27 / 255, green: 0x75 / 255, blue: 0xCA / 255))
                .overlay(
                    Text(verbatim: "$")
                        .font(.sans(side * 0.62, .medium))
                        .foregroundStyle(Color.white)
                )
        }
    }
}

/// The Ethereum diamond: an upper and a lower half meeting at the waist.
struct EtherDiamond: SwiftUI.Shape {
    func path(in rect: CGRect) -> Path {
        let (w, h) = (rect.width, rect.height)
        let top = CGPoint(x: rect.midX, y: rect.minY)
        let waist = rect.minY + h * 0.56
        let left = CGPoint(x: rect.midX - w * 0.32, y: waist)
        let right = CGPoint(x: rect.midX + w * 0.32, y: waist)
        let middle = CGPoint(x: rect.midX, y: rect.minY + h * 0.7)
        var path = Path()
        path.addLines([top, right, middle, left, top])
        let low = rect.minY + h * 0.62
        path.addLines([
            CGPoint(x: rect.midX - w * 0.32, y: low), CGPoint(x: rect.midX, y: rect.maxY),
            CGPoint(x: rect.midX + w * 0.32, y: low),
            CGPoint(x: rect.midX, y: rect.minY + h * 0.76),
        ])
        path.closeSubpath()
        return path
    }
}
