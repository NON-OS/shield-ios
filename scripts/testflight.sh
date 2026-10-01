#!/usr/bin/env bash
# The app signed by NØNOS and uploaded to App Store Connect, for TestFlight and then App Review.
# Run on the build server, a Mac with the Xcode in docs/03-reproduce.md, after
# scripts/build-core.sh has built the device slice (NOX_SLICES=device).
#
#   scripts/testflight.sh 0.9.0
#
# It needs an Apple Developer account enrolled as an organization, which a wallet needs, and what
# that account issues, given as environment variables that name files kept outside the
# repository, readable by the build user only:
#
#   APPLE_TEAM_ID       the ten-character team id
#   DIST_CERT_P12       the Apple Distribution certificate and its key, a .p12 file
#   DIST_CERT_PASSWORD  the .p12 password
#   APPSTORE_PROFILE    the App Store provisioning profile for systems.nonos.shield
#   ASC_KEY_ID          the App Store Connect API key id, role App Manager
#   ASC_ISSUER_ID       the issuer id of that key
#   ASC_KEY_P8          the key's .p8 file
#
# The certificate is imported into a keychain made for this run and deleted when it ends,
# whatever the outcome, so no signing key stays on the server between runs.
# docs/05-distribution.md says how to make each one, and how to revoke them.
set -euo pipefail

cd "$(dirname "$0")/.."

fail() {
    echo "$1" >&2
    exit 1
}

version="${1:-}"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "usage: scripts/testflight.sh x.y.z"

missing=""
for name in APPLE_TEAM_ID DIST_CERT_P12 DIST_CERT_PASSWORD APPSTORE_PROFILE \
    ASC_KEY_ID ASC_ISSUER_ID ASC_KEY_P8; do
    [ -n "${!name:-}" ] || missing="$missing $name"
done
[ -z "$missing" ] || fail "not signing: missing$missing (docs/05-distribution.md)"
for file in "$DIST_CERT_P12" "$APPSTORE_PROFILE" "$ASC_KEY_P8"; do
    [ -r "$file" ] || fail "cannot read $file"
done
[ -d build/NoxShieldCore.xcframework ] || fail "no core: run NOX_SLICES=device scripts/build-core.sh"

# App Store Connect takes a build number only once, so it is the time of the run, which only grows.
build_number="$(date -u +%Y%m%d%H%M)"
work="$(mktemp -d)"
keychain="$work/signing.keychain-db"
profiles="$HOME/Library/MobileDevice/Provisioning Profiles"
keys="$HOME/.appstoreconnect/private_keys"
plist=NoxShield/Info.plist
cp "$plist" "$work/Info.plist.orig"

cleanup() {
    security delete-keychain "$keychain" 2>/dev/null || true
    [ -n "${uuid:-}" ] && rm -f "$profiles/$uuid.mobileprovision"
    rm -f "$keys/AuthKey_$ASC_KEY_ID.p8"
    cp "$work/Info.plist.orig" "$plist"
    rm -rf "$work"
}
trap cleanup EXIT

# A keychain for this run only, holding the certificate and nothing else. The partition list lets
# codesign use the key without a prompt.
password="$(uuidgen)"
security create-keychain -p "$password" "$keychain"
security set-keychain-settings -lut 3600 "$keychain"
security unlock-keychain -p "$password" "$keychain"
security import "$DIST_CERT_P12" -k "$keychain" -P "$DIST_CERT_PASSWORD" \
    -T /usr/bin/codesign -T /usr/bin/security
security set-key-partition-list -S apple-tool:,apple: -s -k "$password" "$keychain" >/dev/null
# The search list is this keychain, then the ones already listed, one word each.
# shellcheck disable=SC2046
security list-keychains -d user -s "$keychain" $(security list-keychains -d user | tr -d '"')

security cms -D -i "$APPSTORE_PROFILE" >"$work/profile.plist"
uuid=$(/usr/libexec/PlistBuddy -c "Print :UUID" "$work/profile.plist")
profile_name=$(/usr/libexec/PlistBuddy -c "Print :Name" "$work/profile.plist")
mkdir -p "$profiles"
cp "$APPSTORE_PROFILE" "$profiles/$uuid.mobileprovision"

# The export compliance code is issued by Apple once the documentation is accepted. Until then the
# empty key is left out of the signed build, so App Store Connect asks instead of refusing it. The
# file is put back when the run ends.
code=$(/usr/libexec/PlistBuddy -c "Print :ITSEncryptionExportComplianceCode" "$plist" 2>/dev/null \
    || true)
if [ -z "$code" ]; then
    /usr/libexec/PlistBuddy -c "Delete :ITSEncryptionExportComplianceCode" "$plist" 2>/dev/null \
        || true
fi

xcodegen generate
xcodebuild -project NoxShield.xcodeproj -scheme NoxShield \
    -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' \
    -archivePath "$work/NoxShield.xcarchive" \
    CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM="$APPLE_TEAM_ID" \
    CODE_SIGN_IDENTITY="Apple Distribution" \
    PROVISIONING_PROFILE_SPECIFIER="$profile_name" \
    OTHER_CODE_SIGN_FLAGS="--keychain $keychain" \
    MARKETING_VERSION="$version" CURRENT_PROJECT_VERSION="$build_number" \
    SWIFT_ACTIVE_COMPILATION_CONDITIONS='$(inherited) STORE_BUILD' \
    archive

cat >"$work/export.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>app-store-connect</string>
  <key>teamID</key><string>$APPLE_TEAM_ID</string>
  <key>signingStyle</key><string>manual</string>
  <key>signingCertificate</key><string>Apple Distribution</string>
  <key>provisioningProfiles</key>
  <dict><key>systems.nonos.shield</key><string>$profile_name</string></dict>
</dict>
</plist>
EOF
xcodebuild -exportArchive -archivePath "$work/NoxShield.xcarchive" \
    -exportOptionsPlist "$work/export.plist" -exportPath "$work/export"
ipa="$work/export/NoxShield.ipa"
shasum -a 256 "$ipa"

# altool reads the API key from this directory by its id. The key can upload builds and nothing
# that moves money.
mkdir -p "$keys"
cp "$ASC_KEY_P8" "$keys/AuthKey_$ASC_KEY_ID.p8"
xcrun altool --upload-app -t ios -f "$ipa" --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"

echo "uploaded $version ($build_number) to App Store Connect"
