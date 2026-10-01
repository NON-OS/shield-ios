# The iOS app

What the iOS app owns, what it trusts, what it hands the core and the owner, and what an attacker
who controls a neighbour can do. What the core checks and what it does not is in
[its security status](https://github.com/NON-OS/shield-core/blob/main/docs/20-security-status.md).

## What this owns

The window, the Secure Enclave key, the screens, the confirmation of the owner before a send, and
the data protection of the wallet directory. It owns no decision about money.

## What it trusts

The core, for every decision. An amount is text until the core parses it, an address is text until
the core checks it, a balance is a figure the core computed and formatted, and a send or a swap is
a review the core worked out. This app contains no arithmetic on money, no address parsing, no
cryptography and no network code: every connection is made by the Tor client inside the core.

The Secure Enclave, for a P-256 key that cannot leave it (`Core/EnclaveKey.swift`). The file key of
the vault is sealed to that key with ECIES (X9.63, SHA-256, AES-GCM), and unwrapping requires the
owner, so a locked phone yields a vault nothing can open. On a phone the Enclave is the only place
the key may be generated: if it refuses, the wallet is refused, rather than sealed under a key the
main processor holds. The keychain rung exists for the simulator only (`Core/Holder.swift`).
Before every public send or swap the app asks again, with Face ID, Touch ID or the passcode
(`Core/Presence.swift`).

The app container, marked excluded from backup and given complete data protection
(`Core/CoreWallet.swift`), so the vault and the note store never reach iCloud or a computer backup
and are unreadable, to the app as well, while the phone is locked.

## What it hands its neighbours

To the core: a directory path and a `HardwareGuard` backed by the Enclave key. Then what the owner
asks for: create, restore, unlock, lock, read the account, send, receive, swap, and on the shield
deposit, send privately, withdraw, take back and time a proof.

To the owner: what the core returned, in the NØNOS screens. Home is a network pill, one tile of
coins with ETH, NOX and USDC, and four actions: send, receive, swap and shield. The figures the app
adds itself are the platform's, on the measurement screen: the kernel's high water mark of this
process since it opened, the limit iOS ends the app at, and the thermal state
(`Core/Footprint.swift`, `Core/Machine.swift`).

What the app keeps beside the core's files, each a small file in the same protected container:
the network, the idle time, whether recording is allowed, the proving threads, and the lander's id
for a spend on its way (`Core/HandoffRecord.swift`). None holds a key, an amount or an address.

## What an attacker who controls a neighbour can do

**A jailbreak.** It lifts the sandbox, so code the owner did not choose can read this app's memory
and screens. The app looks for the files a jailbreak or its package manager leaves, for injected
tweak and instrumentation libraries, and for libraries inserted at launch (`Core/Integrity.swift`),
and names what it finds on the welcome screen and in Settings. It does not refuse to run: the
owner decides. A jailbreak built to hide passes every one of these checks, so the app says "none
found, which a hidden one passes" rather than calling a phone clean.

**A log reader.** There is nothing to read: the app makes no print, `NSLog`, `os_log` or `Logger`
call, and `scripts/check-privacy.sh` fails the build check if one appears. The core prints nothing
either.

**A malicious app on the device.** It is sandboxed away from this container and this memory. A
copied address or hash is in the pasteboard for at most 60 s, local to this device so it is not
handed to a nearby Mac, and the receive screen says while it is there.

**Somebody who sees the screen, or a screenshot.** iOS gives an app no way to block a screenshot the
owner takes. The app covers its content when it leaves the foreground, so the task switcher
snapshot is blank. It keeps the content covered while the screen is recorded, mirrored or shared,
and answers a screenshot of the recovery words with a warning to delete it. The Android build blocks
screenshots outright. The iOS build cannot.

**Somebody holding the phone unlocked.** The wallet locks when the app leaves the foreground and
after the idle time the owner chose. A send or a swap asks for the owner again even inside an
unlocked session.

**An attacker with a device backup.** The container is excluded, so the vault and the note store are
not in it. If that flag were ever dropped, a backup would hold a vault whose key is still in the
Enclave of the original phone: unopenable, but more than should be there.

**An attacker with the IPA.** They get the code, which is published, and the addresses the core
names, which are listed with the evidence for each in the README of the core. What they cannot
reproduce byte for byte is the app binary itself, because Xcode is not redistributable.
[03-reproduce.md](03-reproduce.md) says what that costs and what to compare instead.

## Accessibility

| What | How | Where |
|---|---|---|
| VoiceOver | every field is named by its label, every icon button by what it does, the photographs and coin marks are hidden, a screen's statement is read once as a header, a fact is read as its name then its value, and each step of a spend on its way says done, now or to come | `Views/Parts/Field.swift`, `Views/Parts/Statement.swift`, `Views/Parts/Facts.swift`, `Views/LandingSteps.swift` |
| Dynamic Type | both faces are set relative to body, so they follow the text size the owner chose; labels, actions and the machine's line wrap rather than cut; at the accessibility sizes the home pills stack, a fact's value goes under its name, and the footer scrolls with the screen | `Views/Parts/Typography.swift`, `Views/PillsRow.swift`, `Views/Parts/ScreenFrame.swift` |
| Reduce Motion | the statement appears whole instead of arriving character by character | `Views/Parts/Statement.swift` |
| Checked by | Xcode's accessibility audit on every screen a new holder reaches, at the default text size and at the largest, each issue kept as text beside the screenshot | `NoxShieldUITests/`, run with `xcodebuild test -scheme Screens` on the build server |

What the last audit still named, on 1 October 2026, for the next run on the server to start from:

- At the default size, "Dynamic Type font sizes are partially unsupported" on the home pills and
  on the four round actions of the shield. At the largest size the same controls were not named,
  and their screenshots show the text grown and whole.
- Contrast on the one-glyph values "0" and "–" of the coin rows, which are the bright text colour
  on the dark tile, and at the largest size on two muted lead lines. Muted text is `#87888B` on
  `#0A0B0D`, about 5.5 to 1.
