# Signing and distribution

How the app reaches a phone today, what the signed path needs, and the order it goes in: TestFlight
for the team, TestFlight for outside testers, then App Review.

## Where it stands

| Path | State | Evidence |
|---|---|---|
| Unsigned `.ipa` on each `v*` tag, with its SHA-256 | working, installed with SideStore or AltStore ([04-install.md](04-install.md)) | `scripts/release-ipa.sh` on the build server, [Releases](https://github.com/NON-OS/shield-ios/releases) |
| Signed build uploaded to App Store Connect | written, not run: no Apple Developer account exists yet | `scripts/testflight.sh` on the build server stops at once and names what it lacks |
| TestFlight, internal and external | waits on the signed build | |
| App Store | waits on TestFlight and on the decisions below | |

## Why the account has to be an organization

App Review Guideline 3.1.5(i): apps may facilitate virtual currency storage provided they are
offered by developers enrolled as an organization. An individual account cannot ship this wallet.
Enrolling as an organization needs a legal entity, its D-U-N-S number, and a website on the
entity's own domain.

## Making the signing files

Everything runs on the build server, a Mac; nothing runs on GitHub Actions. `scripts/testflight.sh`
reads seven environment variables. Three name files kept outside the repository, readable by the
build user only; the others are short values.

| Variable | What it is | Where it comes from |
|---|---|---|
| `APPLE_TEAM_ID` | the ten-character team id | Membership details in the developer account |
| `DIST_CERT_P12` | the path of the Apple Distribution certificate and its private key, as a `.p12` | Certificates, Identifiers & Profiles: a certificate request made on the server, then exported from Keychain Access with a password |
| `DIST_CERT_PASSWORD` | the `.p12` password | chosen at export |
| `APPSTORE_PROFILE` | the path of an App Store provisioning profile for `systems.nonos.shield` with that certificate | Profiles, App Store Connect distribution. The App ID needs no capability |
| `ASC_KEY_ID`, `ASC_ISSUER_ID` | the App Store Connect API key's id and the issuer id | App Store Connect, Users and Access, Integrations, Team Keys, role App Manager |
| `ASC_KEY_P8` | the path of the key's `.p8` file | downloaded once when the key is made |

The certificate is the one key here that could sign an app as NØNOS. The script imports it into a
keychain made for the run and deletes that keychain when the run ends, whatever the outcome, with
the profile and the copy of the API key, so nothing of it stays in the server's keychains between
runs. If the server is ever doubted: revoke the certificate in the developer account and the API
key in App Store Connect, then make new ones. Apps already on the store keep working after a
certificate is revoked. The unsigned release never touches any of it.

## The order

1. **The app record.** In App Store Connect, a new iOS app with the bundle id
   `systems.nonos.shield`, the name NØNOS Wallet, and a SKU.
2. **A signed build.** On the build server, with the tag being shipped checked out and the core
   built (`NOX_SLICES=device scripts/build-core.sh`): `scripts/testflight.sh x.y.z`. The build
   number is the time of the run, which only grows, as App Store Connect requires.
3. **TestFlight, internal.** Once the build has processed, add the team as internal testers. No
   review is needed. A build expires after 90 days.
4. **TestFlight, external.** Add a group of outside testers. The first build of each version goes
   to Beta App Review, with test information: what to try, a contact, and the notes below.
5. **App Review.** Metadata, iPhone screenshots from the Screens UI test run on the server
   (`xcodebuild test -scheme Screens`), the privacy answers, then submit.

## What App Review will ask, and the answers ready

| Question | Answer, with where it is shown |
|---|---|
| Data collection | Data Not Collected. The privacy manifest declares nothing collected, nothing tracked, no domain and no required-reason API, and `scripts/check-privacy.sh` holds it to that |
| Export compliance | The app carries its own cryptography, so `ITSAppUsesNonExemptEncryption` is true (`NoxShield/Info.plist`). App Store Connect asks for the exemption claimed. The plist names the publicly available source ground. Until Apple issues a compliance code, the signed build leaves the empty `ITSEncryptionExportComplianceCode` out, so App Store Connect asks instead of refusing it |
| How to review a non-custodial wallet | No account to sign in to. Create a wallet on the device; the shield runs on Sepolia, where tokens have no value; a private send proves on the phone for about a minute and a half, one unpublished run on a test iPhone, with the published figure waiting on [06-measure.md](06-measure.md); every connection goes through the Tor client inside the app |

## Decisions before App Review

- **Swaps, decided.** Guideline 3.1.5(iii) lets an app facilitate cryptocurrency transactions on an
  approved exchange only where it has the licensing to do so. The App Store build leaves swaps out:
  `scripts/testflight.sh` sets `STORE_BUILD`, and `Release.swaps` hides the Swap action
  (`Core/Release.swift`). The sideloaded build keeps them.
- **The shield.** A pool that hides who paid whom draws questions a plain wallet does not. The
  review notes should say it runs on Sepolia only, with tokens of no value, until its audit.
- **The memory entitlement.** The increased memory limit is decided by the measurement in
  [06-measure.md](06-measure.md). If it is taken, it goes in an entitlements file of its own that
  only `scripts/testflight.sh` signs with, and on the App ID. `scripts/check-privacy.sh` refuses it in
  `NoxShield/NoxShield.entitlements`, so the sideloaded build never asks for a capability the
  Apple ID that installs it may not have.
