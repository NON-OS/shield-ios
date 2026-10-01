import SwiftUI

/// Every term of a quoted swap, in the order a trader reads them.
struct SwapTerms: View {
    let swap: PublicSwap

    var body: some View {
        Tile {
            TileRow(name: "Rate", value: swap.rate)
            TileRow(name: "Minimum received",
                    value: "\(swap.minimumOut) \(amountUnit(coin: swap.to))")
            TileRow(name: "Price impact", value: "\(swap.priceImpactPercent)%")
            TileRow(name: "Max slippage", value: "\(swap.slippagePercent)%")
            Rule()
            TileRow(name: "Route", value: swap.route)
            TileRow(name: "Venue", value: swap.venue)
            ForEach(swap.pools, id: \.self) { pool in
                TileRow(name: swap.pools.count > 1 ? "Pool, 0.3% each" : "Pool, 0.3%", value: pool)
            }
            if swap.from == .nox || swap.to == .nox {
                TileRow(name: "NOX token fee", value: "\(swap.tokenFee) NOX")
            }
            Rule()
            TileRow(name: "Network fee, at most", value: "\(swap.maxNetworkFee) ETH")
            TileRow(name: "Nonce, chain", value: "\(swap.nonce), \(swap.chainId)")
        }
    }
}
