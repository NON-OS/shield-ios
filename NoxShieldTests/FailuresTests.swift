import XCTest
@testable import NoxShield

/// The table of core failure to sentence, asserted word for word as on Android. The key guard line
/// differs: keychain here, keystore there, naming what this phone has.
final class FailuresTests: XCTestCase {
    func testEveryWalletFailureHasItsSentence() {
        XCTAssertEqual(describe(WalletError.Insufficient), "That is more than the balance covers.")
        XCTAssertEqual(
            describe(WalletError.NoSpendPlan),
            "Two notes are needed to send. Receive again first."
        )
        XCTAssertEqual(describe(WalletError.Address), "That recipient address is not valid.")
        XCTAssertEqual(describe(WalletError.Amount), "That amount is out of range.")
        XCTAssertEqual(
            describe(WalletError.ReviewExpired),
            "That review has expired. Review the send again."
        )
        XCTAssertEqual(describe(WalletError.NoSuchAccount), "There is no such account.")
        XCTAssertEqual(describe(WalletError.Unavailable), "That is not in this build yet.")
        XCTAssertEqual(
            describe(WalletError.FeeTooHigh),
            "The pool would not take this fee. Try again in a minute, or update the app."
        )
    }

    func testANetworkFailureSaysNothingWasSent() {
        XCTAssertEqual(
            describe(WalletError.Net(source: .WrongChain)),
            "A server answered for the wrong network. Nothing was signed."
        )
        XCTAssertEqual(
            describe(WalletError.Net(source: .Transport)),
            "The connection over Tor dropped before an answer came. Try again."
        )
    }

    func testACustodyFailureNamesWhatRefused() {
        XCTAssertEqual(describe(WalletError.Custody(source: .Locked)), "The wallet is locked.")
        XCTAssertEqual(
            describe(WalletError.Custody(source: .Mnemonic)),
            "That recovery phrase did not check out."
        )
        XCTAssertEqual(
            describe(WalletError.Custody(source: .PhraseLength)),
            "A recovery phrase is 12, 15, 18, 21 or 24 words."
        )
        XCTAssertEqual(
            describe(WalletError.Custody(source: .VaultPresent)),
            "A wallet is already stored on this device."
        )
    }

    func testACustodyFailureThisShellDoesNotNameIsStillReported() {
        XCTAssertEqual(
            describe(WalletError.Custody(source: .VaultShape)),
            "The stored wallet could not be opened on this device."
        )
    }

    func testAFailureFromNowhereIsReportedRatherThanSwallowed() {
        struct Nowhere: Error {}
        XCTAssertEqual(describe(Nowhere()), "Something went wrong.")
    }
}
