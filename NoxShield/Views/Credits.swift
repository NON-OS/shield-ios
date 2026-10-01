import SwiftUI

/// About, and the single acknowledgement the photographs' licence asks for.
struct Credits: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(text: "About")
            Lead(text: "N\u{00D8}NOS Wallet: private payments on Ethereum. NOX is the token; "
                + "NOX Shield is the private layer.")
            Lead(text: "Designed after Etna, the volcano of Sicily, where N\u{00D8}NOS began.")
            Label(text: "Acknowledgements")
            Lead(text: "Etna photographs: gnuckx, CC BY 2.0, recoloured by N\u{00D8}NOS")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
