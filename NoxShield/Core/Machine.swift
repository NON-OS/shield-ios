import Foundation

/// What this build is running on, as one line for a measurement card: the architecture and the
/// system version, so x86_64 marks a simulator. No device name, serial or vendor identifier.
enum Machine {
    static func describe() -> String {
        var info = utsname()
        guard uname(&info) == 0 else { return "unknown" }
        let machine = withUnsafePointer(to: &info.machine) { pointer in
            pointer.withMemoryRebound(to: CChar.self, capacity: Int(_SYS_NAMELEN)) { rebound in
                String(cString: rebound)
            }
        }
        return "\(machine), iOS \(ProcessInfo.processInfo.operatingSystemVersionString)"
    }

    /// What slows a proof without changing the code: the phone's heat, and Low Power Mode. A
    /// timing is quoted with both, since the same phone proves slower when either is up.
    static func conditions() -> String {
        let info = ProcessInfo.processInfo
        return "thermal \(heat(info.thermalState)), "
            + "low power \(info.isLowPowerModeEnabled ? "on" : "off")"
    }

    private static func heat(_ state: ProcessInfo.ThermalState) -> String {
        switch state {
        case .nominal: return "nominal"
        case .fair: return "fair"
        case .serious: return "serious"
        case .critical: return "critical"
        @unknown default: return "unknown"
        }
    }
}
