#!/usr/bin/env bash
# The unsigned .ipa of a release and its SHA-256, built on the build server the way the release
# has always been built: for real iPhones, with signing off, so no certificate is needed. SideStore
# or AltStore signs it on the phone with the owner's Apple ID (docs/04-install.md).
#
#   NOX_SLICES=device scripts/build-core.sh
#   scripts/release-ipa.sh v0.9.0
#
# The tag must be checked out, so the build is the tagged source. The two files land in
# build/release, ready to attach to the tag's release on the public repository NON-OS/shield-ios,
# which the site's download page links to.
set -euo pipefail

cd "$(dirname "$0")/.."

tag="${1:-}"
if ! [[ "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "usage: scripts/release-ipa.sh vX.Y.Z" >&2
    exit 1
fi
if [ "$(git describe --tags --exact-match 2>/dev/null || true)" != "$tag" ]; then
    echo "HEAD is not $tag: check the tag out first, so the file is the tagged source" >&2
    exit 1
fi
if [ -n "$(git status --porcelain)" ]; then
    echo "the checkout has changes, and a release is the tagged source only" >&2
    exit 1
fi

xcodegen generate
xcodebuild -project NoxShield.xcodeproj -scheme NoxShield \
    -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' \
    -derivedDataPath build/dd \
    CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" \
    MARKETING_VERSION="${tag#v}" CURRENT_PROJECT_VERSION="$(date -u +%Y%m%d%H%M)" \
    build

out=build/release
rm -rf "$out" && mkdir -p "$out/Payload"
cp -R build/dd/Build/Products/Release-iphoneos/NoxShield.app "$out/Payload/"
name="NONOS-$tag-unsigned.ipa"
(cd "$out" && zip -qry "$name" Payload && rm -rf Payload && shasum -a 256 "$name" | tee "$name.sha256")
echo "core $(tr -d '[:space:]' <core.lock), xcode $(xcodebuild -version | sed -n '1s/^Xcode //p')"
