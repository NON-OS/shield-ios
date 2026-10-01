import Foundation
import MachO

/// Signs that this phone is jailbroken, each named, none of them proof. A jailbreak lets other
/// code read this wallet's memory and screens, so the owner is told what was seen. A jailbreak
/// built to hide passes every check here, so finding nothing is not a promise, and the screens
/// say so. Nothing is reported anywhere: the answer stays on this phone.
enum Integrity {
    enum Finding: Equatable {
        /// The simulator shares the computer's file system, so the checks would only find a Mac.
        case notChecked
        case noneFound
        case signs([String])
    }

    /// Files only a jailbreak or its package manager puts on a phone.
    static let paths = [
        "/Applications/Cydia.app", "/Applications/Sileo.app", "/Applications/Zebra.app",
        "/var/jb", "/var/binpack", "/private/var/lib/apt", "/etc/apt", "/usr/sbin/sshd",
        "/bin/bash", "/Library/MobileSubstrate/MobileSubstrate.dylib"
    ]

    /// Libraries a tweak injector or an instrumentation kit loads into apps.
    static let injected = [
        "mobilesubstrate", "substrate", "libhooker", "ellekit", "tweakinject", "frida",
        "cycript", "sslkillswitch"
    ]

    static func now() -> Finding {
        #if targetEnvironment(simulator)
        return .notChecked
        #else
        return judge(
            exists: { FileManager.default.fileExists(atPath: $0) },
            images: loadedImages(),
            inserted: getenv("DYLD_INSERT_LIBRARIES") != nil
        )
        #endif
    }

    /// The finding for what was seen, apart from the device so a test can hand it any phone.
    static func judge(exists: (String) -> Bool, images: [String], inserted: Bool) -> Finding {
        var signs = paths.filter(exists)
        let lowered = images.map { $0.lowercased() }
        signs += injected.filter { name in lowered.contains { $0.contains(name) } }
            .map { "a library named \($0)" }
        if inserted { signs.append("libraries inserted at launch") }
        return signs.isEmpty ? .noneFound : .signs(signs)
    }

    /// The path of every image loaded into this process.
    private static func loadedImages() -> [String] {
        (0..<_dyld_image_count()).compactMap { index in
            _dyld_get_image_name(index).map { String(cString: $0) }
        }
    }
}
