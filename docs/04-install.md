# Installing NØNOS Wallet on an iPhone

There is no App Store or TestFlight build yet ([05-distribution.md](05-distribution.md) says what
it waits for). Until there is, the app is published as an unsigned `.ipa` file, and a sideloading
store on your phone signs it with your own Apple ID. This page takes you from the file to the
wallet's first screen, and says what each step costs.

> [!WARNING]
> The shield runs on Sepolia, a test network, and its tokens have no value. The public account
> holds real ETH, NOX and USDC on Ethereum mainnet. Nothing is audited.

## What you need

| What | Why |
|---|---|
| An iPhone on iOS 18 or later, with a passcode set | `project.yml` sets iOS 18.0 as the floor. The wallet refuses to seal a seed on a phone with no passcode (`Custody.canConfirmOwner`, `Views/WelcomeView.swift`) |
| An Apple ID. A free one works | The sideloading store signs the app with it |
| SideStore or AltStore Classic on the phone | It installs the unsigned file and renews its signature |
| About 11 MB | the size of `NONOS-<tag>-unsigned.ipa` on [Releases](https://github.com/NON-OS/shield-ios/releases) |

SideStore renews the signature on the phone itself. AltStore Classic renews it from AltServer on a
computer on the same Wi-Fi. Install the store first by following its own guide, at sidestore.io
or altstore.io. AltStore PAL, the EU marketplace, installs only apps notarized by Apple and cannot
install this file.

## 1. Get the file and its hash

Each release carries two files, built from the tag on the build server by `scripts/release-ipa.sh`:

- `NONOS-<tag>-unsigned.ipa`, the app.
- `NONOS-<tag>-unsigned.ipa.sha256`, its SHA-256.

**From GitHub Releases.** The public repository
[NON-OS/shield-ios](https://github.com/NON-OS/shield-ios/releases) carries every release and its
SHA-256. Open the release of the tag and download both files.

**From the NØNOS site.** The download page at nonos.software/download links to those same
releases, so both ways lead to one file. The hash was computed by the build server from the file it
built, so a match means the file is the one built from the tagged source.

> [!NOTE]
> On 1 October 2026 neither way was open yet: the first public release on NON-OS/shield-ios is the
> next tag, and the site's download page listed the NØNOS OS images only.

## 2. Check the hash

On a computer, in the folder holding both files:

```sh
shasum -a 256 -c NONOS-<tag>-unsigned.ipa.sha256
```

It must print `NONOS-<tag>-unsigned.ipa: OK`. Anything else, stop and do not install it.

To check on the phone instead, the Shortcuts app's Generate Hash action, set to SHA-256, gives the
hash of the `.ipa`. Compare all 64 characters with the `.sha256` file, not the first few.

## 3. Turn on Developer Mode

iOS 16 and later run an app signed with a personal Apple ID only in Developer Mode: Settings,
Privacy & Security, Developer Mode, on. The phone restarts and asks you to confirm. The switch
appears once an app signed this way, such as the store itself, is on the phone.

## 4. Install it

1. Save the `.ipa` to Files on the phone, or AirDrop it to the phone.
2. Open SideStore or AltStore, go to My Apps, tap +, and choose the `.ipa`.
3. Sign in with your Apple ID when the store asks. It signs the app on the phone; neither NØNOS nor
   GitHub sees the Apple ID.
4. If iOS says the developer is untrusted: Settings, General, VPN & Device Management, your Apple
   ID, Trust.

The app appears as NØNOS. Open it: the first screen offers to create a wallet or restore one.

## 5. Keep it signed

| With | The signature lasts | What renews it |
|---|---|---|
| A free Apple ID | 7 days | the store's Refresh, on the phone for SideStore, from AltServer for AltStore |
| A paid Apple Developer account | 1 year | the same, less often |

When the signature lapses the app will not open, and the wallet inside it is untouched. Refresh in
the store and it opens again. A free Apple ID can keep at most three sideloaded apps active at
once, the store included.

## Updating

Install the newer `.ipa` the same way, with the same Apple ID. It installs over the older one and
keeps the wallet: same app, same container, same keychain group, so the key in the Secure Enclave
still opens the vault. Check the new file's hash first.

## What deletes a wallet

The words you wrote down are the only way back after any of these:

- **Installing under a different Apple ID.** The store gives the app an identifier of that Apple
  ID's team, so iOS sees a new app with a new, empty container and a keychain group the old key is
  not in.
- **Deleting the app.** The container goes with it. It is excluded from backup on purpose
  (`Core/CoreWallet.swift`), so no iCloud or computer backup holds the vault or the notes.
- **Removing the phone's passcode.** The key that seals the vault opens only for its owner, and
  removing the passcode can take the key with it. The app tells a key that is gone from one that
  refused once, and asks for the words (`Core/KeyProbe.swift`).

## When something goes wrong

| What you see | What it means |
|---|---|
| The hash check does not print OK | the file is not the one the release built. Delete it and download it again |
| "Unable to install" in the store | the free Apple ID's three-app or ten-identifier limit is reached, or the store's own signature lapsed. Refresh the store, or remove an app you no longer use |
| The app opens and closes at once | the signature lapsed. Refresh it in the store |
| "Set a passcode on this device first" | the phone has no passcode, and the wallet will not seal a seed without one |
| "This phone shows signs of a jailbreak" | the app found files or libraries a jailbreak leaves. It still works, and says what it saw. See [02-app.md](02-app.md) |

Once it is installed, [01-setup.md](01-setup.md) is the guide to every screen.
