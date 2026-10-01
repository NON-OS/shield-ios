import XCTest
@testable import NoxShield

/// How a long value is broken up for reading: stable runs, a short last run, no character dropped
/// or padded.
final class GroupsTests: XCTestCase {
    func testRunsAreEightCharactersSeparatedByOneSpace() {
        XCTAssertEqual(Groups.grouped("abcdefghijklmnop"), "abcdefgh ijklmnop")
    }

    func testTheLastRunIsAllowedToBeShort() {
        XCTAssertEqual(Groups.grouped("abcdefghijk"), "abcdefgh ijk")
    }

    func testNothingIsAddedOrLost() {
        let value = "nox1" + String(repeating: "q", count: 122)
        XCTAssertEqual(Groups.grouped(value).filter { $0 != " " }, value)
    }

    func testAValueShorterThanOneRunIsLeftAlone() {
        XCTAssertEqual(Groups.grouped("nox1"), "nox1")
    }

    func testAShortenedValueKeepsBothEndsAndMarksTheCut() {
        XCTAssertEqual(Groups.shortened("2gzyxa5ihm7nsggclen53wid", ends: 6), "2gzyxa…n53wid")
    }

    func testAValueThatAlreadyFitsIsNotCut() {
        XCTAssertEqual(Groups.shortened("127.0.0.1", ends: 6), "127.0.0.1")
    }
}
