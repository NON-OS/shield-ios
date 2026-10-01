import Foundation
import os

/// Memory for the measurement screen, from the kernel's own ledger: the footprint now, the highest
/// it has been since the app opened, and the footprint the system ends the app at. The core cannot
/// read these on iOS, so the shell does, and the card carries them.
struct Footprint: Equatable {
    let nowKib: UInt64
    /// The high water mark since launch, when the kernel keeps one for this process.
    let peakKib: UInt64?
    /// Now plus what the system still allows, which is where it ends the app. None on a simulator.
    let limitKib: UInt64?

    /// Read the ledger, or nothing when the kernel refuses to say.
    static func sample() -> Footprint? {
        var info = task_vm_info_data_t()
        let size = MemoryLayout<integer_t>.size
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / size)
        let result = withUnsafeMutablePointer(to: &info) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rebound in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), rebound, &count)
            }
        }
        guard result == KERN_SUCCESS else { return nil }
        let peakAt = MemoryLayout<task_vm_info_data_t>.offset(
            of: \task_vm_info_data_t.ledger_phys_footprint_peak
        )
        return of(
            now: info.phys_footprint,
            peak: info.ledger_phys_footprint_peak,
            peakFilled: peakAt.map { Int(count) * size >= $0 + MemoryLayout<Int64>.size } ?? false,
            available: os_proc_available_memory()
        )
    }

    /// The figures from the raw reads, apart from the kernel so a test can hand it any reading.
    /// An older kernel fills less of the structure, and a peak it did not write is not reported.
    static func of(now: UInt64, peak: Int64, peakFilled: Bool, available: Int) -> Footprint {
        let nowKib = now / 1024
        return Footprint(
            nowKib: nowKib,
            peakKib: peakFilled && peak > 0 ? UInt64(peak) / 1024 : nil,
            limitKib: available > 0 ? nowKib + UInt64(available) / 1024 : nil
        )
    }

    /// The memory line on the card the measurement leaves behind.
    var line: String {
        let limit = limitKib.map { "\($0) KiB" } ?? "not reported"
        return "footprint \(nowKib) KiB after the proof, limit \(limit)"
    }
}
