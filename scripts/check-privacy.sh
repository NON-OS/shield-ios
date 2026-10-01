#!/usr/bin/env bash
# The declarations an upload is judged on, asserted here rather than read once.
#
# The privacy manifest, the entitlements and the encryption answer are three
# files that have to keep saying the same thing as the code. A dependency, a
# capability switched on in a hurry or a copied Info.plist would change one of
# them quietly, and the review that catches it happens after the upload.
set -euo pipefail

cd "$(dirname "$0")/.."

manifest=NoxShield/PrivacyInfo.xcprivacy
plist=NoxShield/Info.plist
entitlements=NoxShield/NoxShield.entitlements

fail() {
    echo "$1" >&2
    exit 1
}

# Nothing collected, nobody tracked, no domain contacted, no reasoned API.
for key in NSPrivacyCollectedDataTypes NSPrivacyTrackingDomains NSPrivacyAccessedAPITypes; do
    if ! /usr/libexec/PlistBuddy -c "Print :$key" "$manifest" >/dev/null 2>&1; then
        fail "$manifest does not declare $key"
    fi
    entries=$(/usr/libexec/PlistBuddy -c "Print :$key" "$manifest" | grep -cE '^[[:space:]]+[^[:space:]]' || true)
    [ "$entries" -eq 0 ] || fail "$manifest declares $entries entries under $key"
done

tracking=$(/usr/libexec/PlistBuddy -c "Print :NSPrivacyTracking" "$manifest")
[ "$tracking" = "false" ] || fail "$manifest says the app tracks"

# The encryption answer, and the exemption that goes with published source.
uses=$(/usr/libexec/PlistBuddy -c "Print :ITSAppUsesNonExemptEncryption" "$plist")
[ "$uses" = "true" ] || fail "$plist does not answer the encryption question with true"

# No service the vault could sync to, and no container shared with another app.
for forbidden in icloud-container-identifiers \
    com.apple.security.application-groups ubiquity-kvstore-identifier
do
    if grep -q "$forbidden" "$entitlements"; then
        fail "$entitlements grants $forbidden"
    fi
done

# A keychain group is allowed, and only the app's own. That group is what a
# profile would grant anyway, and without it a build with no team cannot use
# the keychain at all. A group naming anything else is a keychain shared with
# another app, which is the thing this check exists to refuse.
if grep -q keychain-access-groups "$entitlements"; then
    groups=$(/usr/libexec/PlistBuddy -c "Print :keychain-access-groups" "$entitlements" \
        | grep -oE '\$\(AppIdentifierPrefix\)\$\(CFBundleIdentifier\)|[A-Za-z0-9.$()]+' \
        | grep -v '^Array' | grep -v '^{$' | grep -v '^}$' || true)
    for group in $groups; do
        if [ "$group" != '$(AppIdentifierPrefix)$(CFBundleIdentifier)' ]; then
            fail "$entitlements grants a keychain group that is not this app's: $group"
        fi
    done
fi

# A framework that phones home cannot be linked if it is never named.
# The generated bindings are written by the generator in scripts/build-core.sh
# and carry its own comments, including links to its issue tracker. What is
# checked here is what somebody in this repository wrote.
written=$(find NoxShield -name '*.swift' -not -path 'NoxShield/Generated/*')

for forbidden in AppTrackingTransparency AdServices AdSupport StoreKit \
    CoreTelephony Contacts CoreLocation UserNotifications WebKit
do
    if grep -lq "import $forbidden" $written; then
        fail "the sources import $forbidden"
    fi
done

if grep -lqE 'https?://' $written; then
    fail "a source file carries a url"
fi

# App Transport Security at its default deny, with no exception: the app opens no connection
# itself, every one goes through the core's Tor client, so no key is needed and none may appear.
if /usr/libexec/PlistBuddy -c "Print :NSAppTransportSecurity" "$plist" >/dev/null 2>&1; then
    fail "$plist carries an App Transport Security exception"
fi
if grep -lqE '\bURLSession\b|\bNSURLConnection\b' $written; then
    fail "a source file opens a connection outside the core"
fi

# Nothing is logged: a log line on a wallet is an address, an amount or a key on its way to a
# sysdiagnose. Every call that writes to the console or the unified log is refused.
if grep -nE '(^|[^.A-Za-z_])(print|debugPrint|dump|NSLog|os_log)\(|\bLogger\(|\bOSLog\b|\bFileHandle\.standard(Error|Output)\b' $written; then
    fail "a source file logs"
fi

# The increased memory limit is a decision for the signed build, taken from a measurement on a
# phone (docs/06-measure.md). The sideloaded build is signed by whatever Apple ID installs it,
# which may not be granted the capability, so it never asks for it.
if grep -q increased-memory-limit "$entitlements"; then
    fail "$entitlements asks for the increased memory limit, which belongs to the signed build"
fi

echo "privacy manifest empty, entitlements share nothing, no vendor framework, no exception, no log"
