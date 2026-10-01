import XCTest
@testable import NoxShield

/// The memory figures a measurement reports, and the proving threads a launch hands the prover.
final class MemoryTests: XCTestCase {
    func testThePeakAndTheLimitComeFromTheKernelsLedger() {
        let memory = Footprint.of(now: 900 << 20, peak: 1_500 << 20, peakFilled: true,
                                  available: 500 << 20)
        XCTAssertEqual(memory.nowKib, 921_600)
        XCTAssertEqual(memory.peakKib, 1_536_000)
        XCTAssertEqual(memory.limitKib, 1_433_600)
    }

    /// An older kernel that did not write the peak, or a simulator with no limit, says nothing.
    func testAFigureTheKernelDidNotGiveIsNotReported() {
        let memory = Footprint.of(now: 1 << 20, peak: 7, peakFilled: false, available: 0)
        XCTAssertNil(memory.peakKib)
        XCTAssertNil(memory.limitKib)
        XCTAssertEqual(memory.line, "footprint 1024 KiB after the proof, limit not reported")
    }

    func testAThreadCountIsReadOnlyInsideItsRange() {
        XCTAssertEqual(Threads.parse("2\n"), 2)
        XCTAssertEqual(Threads.parse("16"), 16)
        for text in ["all", "0", "17", "-1", ""] {
            XCTAssertNil(Threads.parse(text), text)
        }
    }
}
