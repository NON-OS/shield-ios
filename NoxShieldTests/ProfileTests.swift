import XCTest
@testable import NoxShield

/// The profile's table: every phase a row, a hot run kept and marked, and its two checks, the
/// match and the phases adding up to the total.
final class ProfileTests: XCTestCase {
    private func run(_ ms: [UInt64], total: UInt64, after: String = "nominal") -> ProfileRun {
        ProfileRun(phaseMs: ms, totalMs: total, matched: true, footprintKib: 900 << 10,
                   peakKib: 1_500 << 10, limitKib: 2_048 << 10, thermalBefore: "nominal",
                   thermalAfter: after)
    }

    func testPhasesThatAddUpToTheTotalPassAndOthersDoNot() {
        let ms: [UInt64] = [1, 2, 3, 4, 5, 6, 7, 8, 50, 9, 5]
        XCTAssertTrue(run(ms, total: 100).adds)
        XCTAssertTrue(run(ms, total: 101).adds)
        XCTAssertFalse(run(ms, total: 102).adds)
        XCTAssertFalse(run(Array(ms.dropLast()), total: 95).adds)
        XCTAssertEqual(run(ms, total: 100).friShare, 0.5, accuracy: 1e-9)
    }

    func testAHotRunIsKeptAndMarked() {
        let ms = [UInt64](repeating: 10, count: 11)
        let text = ProfileTable.text(
            runs: [run(ms, total: 110), run(ms, total: 110, after: "serious")],
            phone: "iPhone17,1, iOS 26.0", ramBytes: 8 << 30, threads: "all 6 cores"
        )
        let lines = text.split(separator: "\n")
        XCTAssertTrue(lines.contains { $0.hasPrefix("hot") && $0.contains("HOT") })
        XCTAssertTrue(lines.contains { $0.hasPrefix("run") && $0.contains("1 cold") })
        XCTAssertTrue(lines.contains { $0.hasPrefix("Fri ") && $0.contains("0.01") })
        XCTAssertTrue(lines.contains { $0.hasPrefix("total s") && $0.contains("0.11") })
        for phase in ProfileRun.phases {
            XCTAssertTrue(lines.contains { $0.hasPrefix(phase + " ") }, phase)
        }
        XCTAssertTrue(text.contains("RAM 8192 MiB"))
        XCTAssertTrue(lines.contains { $0.hasPrefix("peak MiB") && $0.contains("900") })
        XCTAssertTrue(lines.contains { $0.hasPrefix("hwm MiB") && $0.contains("1500") })
    }
}
