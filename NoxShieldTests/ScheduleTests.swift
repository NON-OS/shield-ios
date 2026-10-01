import XCTest
@testable import NoxShield

/// When the next scan lands: inside the window, never a fixed signature, and never a zero wait a
/// loop would spin on, whatever the draw.
final class ScheduleTests: XCTestCase {
    func testTheMiddleOfTheWindowIsThePeriod() {
        XCTAssertEqual(Schedule.next { 0.5 }, Schedule.period)
    }

    func testTheEndsOfTheWindowAreThePeriodEitherSideOfTheJitter() {
        XCTAssertEqual(Schedule.next { 0 }, Schedule.period - Schedule.jitter)
        XCTAssertEqual(Schedule.next { 1 }, Schedule.period + Schedule.jitter)
    }

    func testEveryDrawLandsInsideTheWindow() {
        let earliest = Schedule.period - Schedule.jitter
        let latest = Schedule.period + Schedule.jitter
        for step in 0...100 {
            let wait = Schedule.next { Double(step) / 100 }
            XCTAssertTrue((earliest...latest).contains(wait), "a draw of \(step) left the window")
        }
    }

    func testADrawOutsideZeroToOneIsPulledBackIn() {
        XCTAssertEqual(Schedule.next { -5 }, Schedule.period - Schedule.jitter)
        XCTAssertEqual(Schedule.next { 9 }, Schedule.period + Schedule.jitter)
    }

    func testAJitterWiderThanThePeriodStillNeverSpins() {
        let wait = Schedule.next(draw: { 0 }, period: 10, jitter: 600)
        XCTAssertGreaterThanOrEqual(wait, 1)
    }
}
