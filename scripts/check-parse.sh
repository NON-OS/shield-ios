#!/usr/bin/env bash
# Parse every Swift source, which is what a machine without Xcode can do.
#
# This is not a build and does not pretend to be one. It resolves no import,
# checks no type and links nothing: it says the sources are syntactically
# Swift. A machine with only the command line tools has no iOS SDK, so the
# build happens in the pipeline, and this is what catches a broken file before
# it gets there.
set -euo pipefail

cd "$(dirname "$0")/.."

sources=$(find NoxShield -name '*.swift')
if [ -z "$sources" ]; then
    echo "no swift sources found" >&2
    exit 1
fi

# shellcheck disable=SC2086
swiftc -parse $sources

echo "parsed $(wc -l <<<"$sources" | tr -d ' ') sources, which is not a build"
