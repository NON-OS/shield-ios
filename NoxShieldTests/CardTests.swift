import XCTest
@testable import NoxShield

/// What leaves the device when a holder shares a measurement card: the run's own text and nothing
/// else. Android asserts the same three cases.
final class CardTests: XCTestCase {
    private let card = """
    proved: 587415 ms
    verified: 1238 ms, true
    proof: 1017516 bytes
    """

    func testTheCardLeavesExactlyAsTheRunWroteIt() {
        XCTAssertEqual(Card.body(card), card)
    }

    func testATrailingNewlineFromTheFileIsNotALineOfTheCard() {
        XCTAssertEqual(Card.body(card + "\n\n"), card)
    }

    func testNothingIsAddedToIt() {
        let shared = Card.body(card)
        XCTAssertEqual(shared.split(separator: "\n").count, card.split(separator: "\n").count)
        XCTAssertEqual(shared.split(separator: "\n").first, card.split(separator: "\n").first)
        XCTAssertEqual(shared.split(separator: "\n").last, card.split(separator: "\n").last)
    }
}
