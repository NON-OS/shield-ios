import XCTest
@testable import NoxShield

/// Reading back which core a build carries, from a file absent, short or reordered, without ever
/// inventing a commit.
final class ProvenanceTests: XCTestCase {
    func testTheThreeFieldsAreReadInAnyOrder() {
        let read = Provenance.read("xcode 16.4\nrustc 1.91.1\nstate clean\ncommit 2433e7a\n")
        XCTAssertEqual(
            read,
            Provenance(commit: "2433e7a", state: "clean", rustc: "1.91.1", xcode: "16.4")
        )
    }

    func testACleanCheckoutShowsTheCommitAlone() {
        let clean = Provenance(
            commit: "2433e7a",
            state: "clean",
            rustc: "1.91.1",
            xcode: "16.4"
        )
        XCTAssertEqual(clean.line, "2433e7a")
    }

    func testAModifiedCheckoutSaysSoBesideIt() {
        let dirty = Provenance(
            commit: "2433e7a",
            state: "modified",
            rustc: "1.91.1",
            xcode: "16.4"
        )
        XCTAssertEqual(dirty.line, "2433e7a (modified)")
    }

    func testAMissingFieldIsUnknownRatherThanInvented() {
        XCTAssertEqual(Provenance.read("").commit, "unknown")
        XCTAssertEqual(Provenance.read("commit\nstate\n").commit, "unknown")
    }
}
