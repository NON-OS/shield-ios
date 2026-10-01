#!/usr/bin/env bash
# Lint the Swift sources, with or without a full Xcode installed.
#
# SwiftLint loads sourcekit as a framework and finds it through the dynamic
# linker rather than through xcrun. The framework sits in the default toolchain
# in a full Xcode and directly under usr/lib in the command line tools, so both
# are tried and a machine with neither is told so rather than left with a
# loader error nobody can read.
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v swiftlint >/dev/null; then
    echo "swiftlint not found" >&2
    exit 1
fi

developer="$(xcode-select -p)"
lib=""
for candidate in \
    "$developer/Toolchains/XcodeDefault.xctoolchain/usr/lib" \
    "$developer/usr/lib"
do
    if [ -d "$candidate/sourcekitdInProc.framework" ]; then
        lib="$candidate"
        break
    fi
done

if [ -z "$lib" ]; then
    echo "sourcekit is not under $developer" >&2
    echo "select a developer directory that has it with xcode-select" >&2
    exit 1
fi

DYLD_FRAMEWORK_PATH="$lib" swiftlint lint --strict
