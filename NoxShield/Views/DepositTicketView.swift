import SwiftUI

/// What the pool said about a deposit. A refusal keeps nothing. Otherwise the note is already on
/// this phone and two transactions remain, in order: the approval, then the deposit.
struct DepositTicketView: View {
    @EnvironmentObject private var store: WalletStore
    let ticket: DepositTicket
    let coin: Coin
    let onDone: () -> Void

    var body: some View {
        if let refusal = ticket.refusal {
            Lead(text: refusal)
        } else {
            Facts {
                Fact(name: "you send", value: "\(ticket.amount) \(unit)")
                Fact(name: "pool fee", value: "\(ticket.fee) \(unit)")
                Fact(name: "note holds", value: "\(ticket.note) \(unit)")
            }
            if ticket.approveTo.isEmpty {
                step("Deposit", to: ticket.depositTo, data: ticket.depositData)
                Lead(text: "Send it from that address with a value of \(ticket.amount) ETH. "
                    + "Then read the pool; the note appears once it is in a block.")
            } else {
                step("1  Approve", to: ticket.approveTo, data: ticket.approveData)
                step("2  Deposit", to: ticket.depositTo, data: ticket.depositData)
                Lead(text: "Send both from that address, value zero. Then read the pool and "
                    + "the note appears once the deposit is in a block.")
            }
        }
        Action(title: "Done", filled: false, run: onDone)
    }

    private var unit: String { amountUnit(coin: coin) }

    private func step(_ name: String, to: String, data: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(text: name)
            ValueBlock(value: to)
            HStack(spacing: 12) {
                Action(title: "Copy to", filled: false) { store.copyValue(to) }
                Action(title: "Copy data", filled: false) { store.copyValue(data) }
            }
        }
    }
}
