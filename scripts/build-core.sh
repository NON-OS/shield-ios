#!/usr/bin/env bash
# Build the Rust core for iOS and generate its Swift bindings.
#
# The core is a separate checkout, since the Android shell builds the same
# crate. Point NOX_SHIELD_CORE at it, or keep it beside this repository.
set -euo pipefail

CORE="${NOX_SHIELD_CORE:-$(cd "$(dirname "$0")/../../shield-core" && pwd)}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build"
GENERATED="$ROOT/NoxShield/Generated"

if [ ! -d "$CORE/core" ]; then
    echo "core checkout not found at $CORE" >&2
    echo "set NOX_SHIELD_CORE to the directory holding core/" >&2
    exit 1
fi

# The core pins its own toolchain, and a system rust ahead of rustup's shims
# would win the path lookup and then fail for want of an ios standard library.
if [ -d "$HOME/.cargo/bin" ]; then
    PATH="$HOME/.cargo/bin:$PATH"
fi

# A full Xcode, and not the command line tools. The iOS SDK ships only inside
# Xcode, cargo asks xcrun for it, and with the tools active the linker is handed
# the macOS sysroot instead and fails on a dylib built for the wrong platform.
# Selecting Xcode for the whole machine needs root, so it is selected for the
# length of this script only.
if ! xcrun --sdk iphoneos --show-sdk-path >/dev/null 2>&1; then
    XCODE="$(ls -d /Applications/Xcode*.app 2>/dev/null | head -1)"
    if [ -z "$XCODE" ]; then
        echo "no full Xcode in /Applications, and the command line tools carry no iOS SDK" >&2
        exit 1
    fi
    export DEVELOPER_DIR="$XCODE/Contents/Developer"
    if ! xcrun --sdk iphoneos --show-sdk-path >/dev/null 2>&1; then
        echo "$XCODE has no iOS SDK" >&2
        exit 1
    fi
fi

# The core commit this shell is pinned to. A build from any other commit is a
# build nobody reviewed together with these screens, so it is refused; set
# NOX_CORE_UNPINNED=1 to build against a working core on purpose.
lock="$(dirname "$0")/../core.lock"
if [ -f "$lock" ] && [ -z "${NOX_CORE_UNPINNED:-}" ]; then
    want=$(tr -d '[:space:]' <"$lock")
    have=$(cd "$CORE" && git rev-parse HEAD)
    if [ "$want" != "$have" ]; then
        echo "the core is at $have, core.lock pins $want" >&2
        exit 1
    fi
fi

# No builder's path in the binary. Panic locations and C sources carry the path
# they were compiled from, which put this machine's home directory in every
# build, hundreds of times. Rust and C paths are remapped: the home directory
# first, then the cargo home and the core checkout, the last match winning.
CARGO_HOME_DIR="${CARGO_HOME:-$HOME/.cargo}"
export RUSTFLAGS="${RUSTFLAGS:-} --remap-path-prefix=$HOME=/home --remap-path-prefix=$CARGO_HOME_DIR=/cargo --remap-path-prefix=$CORE=/nox-shield-core"
export CFLAGS="${CFLAGS:-} -ffile-prefix-map=$HOME=/home -ffile-prefix-map=$CARGO_HOME_DIR=/cargo -ffile-prefix-map=$CORE=/nox-shield-core"

# Refuse a library that still names the builder's home, rather than ship it.
no_local_paths() {
    local found
    found=$(strings -a "$1" | grep -cF "$HOME" || true)
    if [ "$found" -ne 0 ]; then
        echo "$1 still carries $found local paths" >&2
        strings -a "$1" | grep -F "$HOME" | head -5 >&2
        exit 1
    fi
}

mkdir -p "$BUILD" "$GENERATED"

# One device architecture and both simulator architectures. The simulator an
# Intel host runs is x86_64 and the one an Apple silicon host runs is arm64, so
# a framework carrying only one of them links on one kind of machine and fails
# on the other.
DEVICE=aarch64-apple-ios
SIMULATORS=(aarch64-apple-ios-sim x86_64-apple-ios)

# A build for phones needs the device slice and nothing else. NOX_SLICES=device
# skips both simulator slices, which is two thirds of the compile on a runner.
if [ "${NOX_SLICES:-all}" = device ]; then
    SIMULATORS=()
fi
# NOX_SLICES=arm-sim adds the one simulator an Apple silicon runner tests on.
if [ "${NOX_SLICES:-all}" = arm-sim ]; then
    SIMULATORS=(aarch64-apple-ios-sim)
fi

# Asked inside the core, because the core pins its toolchain and that is the
# one that does the building. Asking here would ask whatever this directory
# defaults to, which is how this check first failed on targets that were
# installed all along.
for target in "$DEVICE" ${SIMULATORS[@]+"${SIMULATORS[@]}"}; do
    if ! ( cd "$CORE" && rustup target list --installed ) | grep -qx "$target"; then
        echo "rust target $target is not installed for the core's toolchain" >&2
        echo "add it with: ( cd $CORE && rustup target add $target )" >&2
        exit 1
    fi
done

for target in "$DEVICE" ${SIMULATORS[@]+"${SIMULATORS[@]}"}; do
    echo "building ${target}"
    ( cd "$CORE" && cargo build --release --target "$target" -p nox_shield_core )
done

# The two simulator slices become one library, because a framework holds one
# per platform variant and the simulator is one variant whichever host it runs
# on.
SIMULATOR_LIB="$BUILD/libnox_shield_core_simulator.a"
rm -f "$SIMULATOR_LIB"
if [ ${#SIMULATORS[@]} -gt 0 ]; then
    SIMULATOR_SLICES=()
    for target in "${SIMULATORS[@]}"; do
        SIMULATOR_SLICES+=("$CORE/target/$target/release/libnox_shield_core.a")
    done
    lipo -create -output "$SIMULATOR_LIB" "${SIMULATOR_SLICES[@]}"
fi

no_local_paths "$CORE/target/$DEVICE/release/libnox_shield_core.a"

# The archive, not a shared library: the Swift bindings link against the static
# library and need no library name, and an archive keeps the static symbol
# table the generator reads the interface out of. A release shared library has
# that table stripped, which makes the generator write nothing and say nothing.
echo "generating bindings"
( cd "$CORE" && cargo run --release --features bindgen --bin uniffi-bindgen -- \
    generate --library "target/aarch64-apple-ios/release/libnox_shield_core.a" \
    --language swift --out-dir "$GENERATED" )

# The generator exits zero when it finds no interface at all.
if [ -z "$(find "$GENERATED" -name '*.swift')" ]; then
    echo "the generator wrote no bindings" >&2
    exit 1
fi

# The generated modulemap has to be named module.modulemap inside the
# framework's Modules directory, and the header has to sit beside it.
HEADERS="$BUILD/headers"
rm -rf "$HEADERS" "$BUILD/NoxShieldCore.xcframework"
mkdir -p "$HEADERS"
cp "$GENERATED"/*.h "$HEADERS/"
cat "$GENERATED"/*.modulemap > "$HEADERS/module.modulemap"
rm -f "$GENERATED"/*.h "$GENERATED"/*.modulemap

XCF_ARGS=(-library "$CORE/target/$DEVICE/release/libnox_shield_core.a" -headers "$HEADERS")
if [ ${#SIMULATORS[@]} -gt 0 ]; then
    XCF_ARGS+=(-library "$SIMULATOR_LIB" -headers "$HEADERS")
fi
xcodebuild -create-xcframework "${XCF_ARGS[@]}" -output "$BUILD/NoxShieldCore.xcframework"

# Which core this is, written by the build rather than typed by somebody.
#
# A version in a constant is a version that goes stale, and the app shows this
# string beside its own so a person reporting a problem can read back exactly
# what they are running. The state is part of it: a library built from a dirty
# checkout is not the commit it claims, and saying so is the difference between
# provenance and decoration.
mkdir -p "$ROOT/NoxShield/Provenance"
core_commit=$( cd "$CORE" && git rev-parse --short HEAD 2>/dev/null || echo unknown )
core_state=$( cd "$CORE" && [ -z "$(git status --porcelain 2>/dev/null)" ] \
    && echo clean || echo modified )
# Asked inside the core, because the core pins its toolchain in
# rust-toolchain.toml and that is the compiler that built the library. Asked
# here it reported whatever this directory defaults to, which was a nightly
# the library was never compiled with: provenance naming the wrong compiler is
# worse than none.
core_rustc=$( cd "$CORE" && rustc --version 2>/dev/null | cut -d' ' -f2 )
[ -n "$core_rustc" ] || core_rustc=unknown
# The Xcode version is the other half of what a reproducer has to match: the
# same source and the same rustc through a different SDK is a different binary.
# Read with sed rather than head: head closes the pipe early, which under
# pipefail fails the whole pipeline and fired the fallback after the real
# value had already been printed. The file grew a stray line for one build.
core_xcode=$( xcodebuild -version 2>/dev/null | sed -n '1s/^Xcode //p' )
[ -n "$core_xcode" ] || core_xcode=unknown
printf 'commit %s\nstate %s\nrustc %s\nxcode %s\n' \
    "$core_commit" "$core_state" "$core_rustc" "$core_xcode" >"$ROOT/NoxShield/Provenance/core.txt"
echo "core: $core_commit $core_state, rustc $core_rustc, xcode $core_xcode"

# What is in the app and what each part is licensed under: every crate the core
# links on the device, walked from the resolved graph, with the notice files
# they carry, and the bundled faces. Generated, never typed, so a dependency
# added without a licence stops the build instead of shipping.
faces=()
for face in "$ROOT/NoxShield/Fonts"/*.ttf "$ROOT/NoxShield/Fonts"/*.otf; do
    [ -e "$face" ] && faces+=("$(basename "$face")")
done
if [ ${#faces[@]} -eq 0 ]; then
    echo "no bundled face was found to licence" >&2
    exit 1
fi
python3 "$ROOT/scripts/licences.py" "$CORE" "$ROOT/NoxShield/Provenance" "$ROOT/licenses" aarch64-apple-ios "${faces[@]}"

echo "done: $BUILD/NoxShieldCore.xcframework, Swift in NoxShield/Generated"
