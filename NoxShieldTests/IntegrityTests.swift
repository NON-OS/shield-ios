import XCTest
@testable import NoxShield

/// What the jailbreak check reports for a phone that shows nothing, for one with a package
/// manager, and for one with a tweak injector loaded. Finding nothing is never called safe.
final class IntegrityTests: XCTestCase {
    private let stock = ["/usr/lib/libSystem.B.dylib", "/System/Library/Frameworks/UIKit"]

    func testAPhoneThatShowsNothingIsReportedAsNoneFound() {
        let finding = Integrity.judge(exists: { _ in false }, images: stock, inserted: false)
        XCTAssertEqual(finding, .noneFound)
        XCTAssertEqual(IntegrityNote.fact(finding), "none found, which a hidden one passes")
    }

    func testEachSignIsNamed() {
        let finding = Integrity.judge(
            exists: { $0 == "/var/jb" },
            images: stock + ["/usr/lib/TweakInject/ElleKit.dylib"],
            inserted: true
        )
        XCTAssertEqual(finding, .signs([
            "/var/jb", "a library named ellekit", "a library named tweakinject",
            "libraries inserted at launch"
        ]))
        XCTAssertEqual(IntegrityNote.fact(finding), "4 found")
    }
}
