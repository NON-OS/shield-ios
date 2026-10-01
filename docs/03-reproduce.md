# Reproducing this build

What the core checks and what it does not is in
[its security status](https://github.com/NON-OS/shield-core/blob/main/docs/20-security-status.md).

A privacy wallet nobody can rebuild is a promise, not a property. This page says what is pinned,
what cannot be, and how to compare a build with a release.

## What is pinned

| Component | Version | Where |
|---|---|---|
| The core | the exact commit in `core.lock` | `scripts/build-core.sh` refuses a core checkout at any other commit |
| Rust | 1.91.1 | `rust-toolchain.toml` in the core, and `flake.nix` here |
| Swift language mode | 5.10, with targeted concurrency checking | `project.yml` |
| iOS deployment target | 18.0 | `project.yml` |
| XcodeGen and SwiftLint | from the pinned nixpkgs | `flake.nix` |
| Xcode on the build server | 16.4, recorded in every build | `NoxShield/Provenance/core.txt`, shown in Settings |
| The version | the release tag, for example `v0.6.0` gives 0.6.0 | `scripts/release-ipa.sh`. Any other build is 0.0.0 and shows "dev build" |

`scripts/build-core.sh` also remaps every path under the home directory and the core checkout in the
compiled library (`--remap-path-prefix`, `-ffile-prefix-map`), and fails if a home path survives, so
two builders in different directories produce the same bytes and no builder leaves a path behind.

## What cannot be pinned, and what that costs

Xcode is not redistributable, so the compiler and the SDK of the app come from the machine rather
than from the flake. Two builds by two people are only comparable when both record the Xcode version
they used:

```sh
xcodebuild -version | tee build/xcode-version.txt
```

The Rust core does not have this problem: its toolchain is pinned, and a core built from one commit
on two machines produces the same static library. That is the part that holds the prover, the
custody, the Ethereum account and the network client, so it is where byte-for-byte reproducibility
matters most.

## Steps

```sh
git clone <this repository> ios-app
git clone <the core repository> shield-core
git -C shield-core checkout "$(cat ios-app/core.lock)"
cd ios-app
nix develop
scripts/build-core.sh
shasum -a 256 build/NoxShieldCore.xcframework/ios-arm64/libnox_shield_core.a
xcodegen generate
xcodebuild -project NoxShield.xcodeproj -scheme NoxShield -configuration Release \
    -sdk iphoneos -destination 'generic/platform=iOS' \
    CODE_SIGNING_ALLOWED=NO MARKETING_VERSION=0.6.0 build
```

Compare the hash of the core first. If it matches and the app does not, the difference is in the
output of Xcode, not in the logic of the wallet.

## Comparing with a release

Each release publishes `NONOS-<tag>-unsigned.ipa` with its SHA-256. The IPA is the app bundle zipped, with
no signature, so the bundle inside it can be compared file by file with a local build of the same
tag and the same Xcode.
