import Foundation

/// Everything a screen can render, as one value. The shell derives nothing from it: a number not
/// here is one the core has not decided.
struct UiState {
    var stage: Stage = .opening
    /// The `nox1` address other wallets pay to on the pool, read from the core.
    var receiving: String = ""
    var chain: ChainSummary?
    /// A deposit checked against the live pool, waiting for the user's EVM wallet.
    var deposit: DepositTicket?
    var balances: [Balance] = []
    var network: Network = .sepolia
    var account: String = ""
    var accounts: [Network: PublicBalances] = [:]
    var review: PublicReview?
    var sent: PublicSent?
    var sentStatus: SendStatus?
    var swap: PublicSwap?
    var relay: RelayHandoff?
    var relayState: RelayState?
    var selfSettle: PublicShield?
    var notLanded: Bool = false
    var phrase: [String] = []
    var spend: SpendTicket?
    var bench: BenchReport?
    /// The kernel's memory figures, read right after a measured proof.
    var footprint: Footprint?
    /// The proving threads chosen for the next launch, nil for every core.
    var threads: UInt32?
    var busy: Busy = .idle
    var failure: String?
    var holder: Holder = .keychainConfirmed
    /// Without owner confirmation no seal is worth making, so the welcome screen says so.
    var canConfirmOwner: Bool = true
    var cardPath: String?
    var copied: Bool = false
    var idle: Idle = .fiveMinutes
    var accountList: [AccountSummary] = []
    var watched: [WatchedSummary] = []
    /// A key or the words on screen after the owner was confirmed, cleared on leaving.
    var exported: Exported?
    var ownTarget: UInt32?
    var arrivedRecently: Bool = false
    var searched: UInt32 = 0
    var recordingAllowed: Bool = false
    var shielding: PublicShield?
    var fromKey: Bool = false
    var captured: Bool = false
    var tooSoon: SpendOrder?
    var freshAddress: String?
    var usedAddress: Bool = false
    /// What this phone showed of a jailbreak when the app opened.
    var integrity: Integrity.Finding = .notChecked
}
