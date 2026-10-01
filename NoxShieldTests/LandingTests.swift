import XCTest
@testable import NoxShield

/// The step a waiting spend is on and the line said about it, for every answer the lander gives,
/// and for a settlement this account sent itself.
final class LandingTests: XCTestCase {
    private func handed(_ status: String?, tx: String? = nil) -> UiState {
        var state = UiState()
        state.relay = RelayHandoff(id: "a1", refusal: nil)
        state.relayState = status.map { RelayState(status: $0, tx: tx, reason: nil) }
        return state
    }

    func testEachLanderStatusIsItsStep() {
        XCTAssertEqual(Landing.of(UiState()), .proved)
        XCTAssertEqual(Landing.of(handed(nil)), .handed)
        XCTAssertEqual(Landing.of(handed("queued")), .handed)
        XCTAssertEqual(Landing.of(handed("scheduled")), .scheduled)
        XCTAssertEqual(Landing.of(handed("settling")), .settling)
        XCTAssertEqual(Landing.of(handed("settled", tx: "0x1")), .settled)
    }

    func testAStatusTheLanderNeverSendsStaysOnTheLastKnownStep() {
        XCTAssertEqual(Landing.of(handed("lost")), .handed)
    }

    func testASettlementSentFromThisAccountIsFollowedByItsBlock() {
        var state = UiState()
        state.selfSettle = PublicShield(id: 1, refusal: nil, approval: false, amount: "0",
                                        poolFee: "0", shielded: "0", maxNetworkFee: "0.001",
                                        validForSeconds: 90)
        state.sentStatus = .pending
        XCTAssertEqual(Landing.of(state), .settling)
        state.sentStatus = .confirmed
        XCTAssertEqual(Landing.of(state), .settled)
        state.sentStatus = .failed
        XCTAssertEqual(Landing.of(state), .proved)
        XCTAssertEqual(
            Landing.headline(state),
            "Your settlement failed on chain. The lander may have landed it first."
        )
    }

    func testARefusalIsSaidWithItsReasonBeforeAnyStep() {
        var state = handed("refused")
        state.relayState = RelayState(status: "refused", tx: nil, reason: "fee too low")
        XCTAssertTrue(Landing.refused(state))
        XCTAssertEqual(
            Landing.headline(state),
            "The lander refused it: fee too low. Settle it yourself, or Take back returns "
                + "the notes."
        )
    }

    func testALongWaitOffersAChoiceUntilItSettles() {
        var state = handed("queued")
        state.notLanded = true
        XCTAssertEqual(
            Landing.headline(state),
            "Not landed yet. Ask the lander again, or settle it yourself."
        )
        state.relayState = RelayState(status: "settled", tx: "0x1", reason: nil)
        XCTAssertEqual(Landing.headline(state), "Settled on the pool.")
    }

    func testEveryStepHasItsOwnLine() {
        let lines = Set(Landing.allCases.map(\.line))
        XCTAssertEqual(lines.count, Landing.allCases.count)
    }
}
