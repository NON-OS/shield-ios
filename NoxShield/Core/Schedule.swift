import Foundation

/// When the next scan happens, if nobody asks for one.
/// A scan on a schedule tells the network only that the app is open, where a tap would say a
/// person picked up the phone. The jitter hides a fixed period. It is traffic shaping, not key
/// material, so the platform's ordinary random source is enough.
enum Schedule {
    /// How often a scan runs while the wallet is open and unlocked.
    static let period: TimeInterval = 300

    /// How far either side of it a scan may land.
    static let jitter: TimeInterval = 60

    /// The shortest wait this will ever hand back.
    private static let floor: TimeInterval = 1

    /// The wait before the next scan, from `draw` in zero to one. Never zero, so no loop spins.
    static func next(
        draw: () -> Double,
        period: TimeInterval = Schedule.period,
        jitter: TimeInterval = Schedule.jitter
    ) -> TimeInterval {
        let fraction = min(max(draw(), 0), 1)
        let wait = period + jitter * (fraction * 2 - 1)
        return max(wait, floor)
    }
}
