import XCTest
@testable import NoxShield

/// When an unlocked wallet left alone locks itself, a security property for a phone taken while
/// unlocked. Android asserts the same seven cases.
final class IdleTests: XCTestCase {
    func testAGapAtTheLimitLocks() {
        XCTAssertTrue(Idle.oneMinute.expired(now: 1_060, touched: 1_000))
    }

    func testAGapUnderTheLimitDoesNot() {
        XCTAssertFalse(Idle.oneMinute.expired(now: 1_059, touched: 1_000))
    }

    func testNeverNeverLocksHoweverLongItHasBeen() {
        XCTAssertFalse(Idle.never.expired(now: Int.max, touched: 0))
    }

    func testImmediatelyLocksOnTheFirstCheck() {
        XCTAssertTrue(Idle.immediately.expired(now: 1_000, touched: 1_000))
    }

    /// A clock that went backwards, from a time change or a restart, does not lock the wallet.
    func testAClockThatWentBackwardsDoesNotLock() {
        XCTAssertFalse(Idle.fiveMinutes.expired(now: 900, touched: 1_000))
    }

    func testTheChoicesCycleAndComeBackRound() {
        XCTAssertEqual(Idle.immediately.next(), .oneMinute)
        XCTAssertEqual(Idle.never.next(), .immediately)
    }

    func testAnUnreadableChoiceFallsBackRatherThanFailing() {
        XCTAssertEqual(Idle.of(nil), .fiveMinutes)
        XCTAssertEqual(Idle.of(99), .fiveMinutes)
        XCTAssertEqual(Idle.of(-1), .never)
    }
}
