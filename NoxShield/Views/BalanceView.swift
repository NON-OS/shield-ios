import SwiftUI

/// Which panel of the unlocked wallet is showing.
enum Panel {
    case overview
    case send
    case receive
    case deposit
    case withdraw
    case settings
    /// The public account: a signed send, and its `0x` address to receive at.
    case accountSend
    case accountReceive
    /// Swapping between ETH, NOX and USDC, on mainnet.
    case swap
    /// The shield: private balances and what can be done with them.
    case shield
    /// The accounts of this wallet and the view-only ones, and the words and keys of one.
    case accounts
    case keys
}

/// The unlocked wallet, which is the panel switch and nothing else. No money is added up here.
struct BalanceView: View {
    @EnvironmentObject private var store: WalletStore
    @State private var panel: Panel = .overview

    var body: some View {
        switch panel {
        case .send:
            SpendView(withdraw: false, onBack: { panel = .shield })
        case .withdraw:
            SpendView(withdraw: true, onBack: { panel = .shield })
        case .receive:
            ReceiveView(onPublic: { panel = .accountReceive }, onBack: { panel = .shield })
        case .deposit:
            DepositView(onBack: { store.clearDeposit(); panel = .shield })
        case .settings:
            SettingsPanel(onKeys: { panel = .keys }, onBack: { panel = .overview })
        case .accounts:
            AccountsPanel(onBack: { panel = .overview })
        case .keys:
            KeysPanel(onBack: { panel = .settings })
        case .accountSend:
            AccountSendView(onBack: { store.clearSend(); panel = .overview })
        case .accountReceive:
            AccountReceiveView(onBack: { panel = .overview })
        case .swap:
            SwapView(onBack: { store.clearSwap(); panel = .overview })
        case .shield:
            ShieldView(onPanel: { panel = $0 }, onBack: { panel = .overview })
        case .overview:
            Overview(onPanel: { panel = $0 })
        }
    }
}
