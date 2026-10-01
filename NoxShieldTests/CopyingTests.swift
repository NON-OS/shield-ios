import XCTest
@testable import NoxShield

/// That a copied address is taken back after the stated wait, and not before the holder can paste.
final class CopyingTests: XCTestCase {
    private final class Fake: Clip {
        var done: [String] = []
        func hold(_ address: String) { done.append("hold \(address)") }
        func release() { done.append("release") }
    }

    func testTheAddressIsHeldAndThenReleasedAfterTheWait() async {
        let clip = Fake()
        var waits: [TimeInterval] = []
        var flags: [Bool] = []
        await copyThenClear(
            clip: clip,
            address: "nox1abc",
            onCopied: { flags.append($0) },
            wait: Wait { waits.append($0) }
        )
        XCTAssertEqual(clip.done, ["hold nox1abc", "release"])
        XCTAssertEqual(waits, [HOLD])
        XCTAssertEqual(flags, [true, false])
    }

    func testTheWaitIsAMinute() {
        XCTAssertEqual(HOLD, 60)
    }

    func testAnEmptyAddressTouchesNothing() async {
        let clip = Fake()
        var flags: [Bool] = []
        await copyThenClear(
            clip: clip,
            address: "",
            onCopied: { flags.append($0) },
            wait: Wait { _ in }
        )
        XCTAssertEqual(clip.done, [])
        XCTAssertEqual(flags, [])
    }
}
