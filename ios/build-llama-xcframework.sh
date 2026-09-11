#!/usr/bin/env bash
#
# ios/build-llama-xcframework.sh
#
# Rebuilds llama.xcframework from the vendored llama.cpp tree
# (vendor/llama.cpp).
#
# WHY THIS EXISTS
# ---------------
# The previously checked-in llama.xcframework was built from a llama.cpp
# revision that predated several model architectures (e.g. qwen3). Downloading
# such a model on iOS then failed at llama_model_load_from_file ("unknown
# model architecture"), which the Dart pipeline misdiagnosed as a corrupt
# download and "fixed" by deleting the perfectly valid GGUF.
#
# The upstream llama.cpp repository no longer ships an Xcode build script, so
# this script is the canonical way to regenerate the framework. Re-run it
# after EVERY vendor/llama.cpp update.
#
# USAGE
#   ./ios/build-llama-xcframework.sh
#   OUT_DIR=/some/dir ./ios/build-llama-xcframework.sh
#
# The final xcframework is written to $OUT_DIR/llama.xcframework (default:
# /tmp/llama-xcframework-build/llama.xcframework). Validate it, then replace
# ios/llama.xcframework with it (see the final output of this script).
#
# SLICES
#   ios-arm64                    (device, Metal + Accelerate)
#   ios-arm64_x86_64-simulator   (simulator, universal arm64 + x86_64)
#
# The old framework also carried macos/tvos/xros slices; this app is iOS-only
# and Xcode picks slices automatically, so they are intentionally dropped.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO_ROOT/vendor/llama.cpp"
BUILD_ROOT="${OUT_DIR:-/tmp/llama-xcframework-build}"
DEPLOYMENT_TARGET="15.0"   # must match the app's IPHONEOS_DEPLOYMENT_TARGET
JOBS="$(sysctl -n hw.ncpu)"

if [ ! -f "$SRC/CMakeLists.txt" ]; then
    echo "error: vendored llama.cpp not found at $SRC" >&2
    exit 1
fi

echo "==> Source:      $SRC"
echo "==> Build root:  $BUILD_ROOT"
echo "==> Deployment:  iOS $DEPLOYMENT_TARGET"
mkdir -p "$BUILD_ROOT"

# CMake configuration shared by all slices.
# * BUILD_SHARED_LIBS=OFF  -> everything is built as static archives; the
#   packaging step then hand-links ONE umbrella dylib with -force_load of all
#   archives, replicating the previous framework layout (a lone `llama`
#   binary with ggml + all backends folded in).
#   NOTE: GGML_STATIC must NOT be set — it injects a raw `-static` linker
#   flag (see ggml/src/CMakeLists.txt) which is fatal in combination with
#   `-dynamiclib`.
# * GGML_METAL_EMBED_LIBRARY -> Metal shaders embedded in the binary
#   (no default.metallib resource needed).
# * GGML_BLAS (Apple vendor)  -> Accelerate, as before.
# * LLAMA_CURL / GGML_LLAMAFILE -> mirror the Android build flags.
CMAKE_COMMON_ARGS=(
    -DCMAKE_BUILD_TYPE=Release
    -DLLAMA_CURL=OFF
    -DLLAMA_BUILD_COMMON=OFF
    -DLLAMA_BUILD_TESTS=OFF
    -DLLAMA_BUILD_TOOLS=OFF
    -DLLAMA_BUILD_EXAMPLES=OFF
    -DLLAMA_BUILD_SERVER=OFF
    -DBUILD_SHARED_LIBS=OFF
    -DGGML_METAL=ON
    -DGGML_METAL_EMBED_LIBRARY=ON
    -DGGML_BLAS=ON
    -DGGML_LLAMAFILE=OFF
    -DCMAKE_OSX_DEPLOYMENT_TARGET="$DEPLOYMENT_TARGET"
)

build_slice() {
    local name="$1" sysroot="$2" archs="$3"
    local bdir="$BUILD_ROOT/build-$name"
    echo "==> [$name] configuring (sysroot: $sysroot, arch: $archs)"
    cmake -S "$SRC" -B "$bdir" "${CMAKE_COMMON_ARGS[@]}" \
        -DCMAKE_SYSTEM_NAME=iOS \
        -DCMAKE_OSX_SYSROOT="$sysroot" \
        -DCMAKE_OSX_ARCHITECTURES="$archs"
    echo "==> [$name] building (this can take a while)"
    cmake --build "$bdir" --target llama --parallel "$JOBS"

    local libllama
    libllama="$(find "$bdir" -name 'libllama.a' -type f | head -1)"
    if [ -z "$libllama" ]; then
        echo "error: [$name] libllama.a not found after build" >&2
        exit 1
    fi
    echo "==> [$name] static archives produced:"
    find "$bdir" -name 'lib*.a' -type f | sed 's/^/    /'
}

package_framework() {
    local name="$1" sysroot="$2" archs="$3" supported_platform="$4"
    local fw="$BUILD_ROOT/$name/llama.framework"
    rm -rf "$BUILD_ROOT/$name"
    mkdir -p "$fw/Headers" "$fw/Modules" "$BUILD_ROOT/$name/dSYMs"

    # Single umbrella dylib: force-link every static archive produced by the
    # build into ONE dynamic library, replicating the previous framework
    # layout (a lone `llama` binary with ggml + all backends folded in).
    local sdk_path arch_args load_args a min_flag
    local old_ifs="$IFS"
    sdk_path="$(xcrun --sdk "$sysroot" --show-sdk-path)"
    # Platform matters: -miphoneos-version-min targets the iOS *device*
    # platform, simulator slices need -mios-simulator-version-min.
    if [ "$sysroot" = "iphonesimulator" ]; then
        min_flag="-mios-simulator-version-min=$DEPLOYMENT_TARGET"
    else
        min_flag="-miphoneos-version-min=$DEPLOYMENT_TARGET"
    fi
    arch_args=""
    IFS=';'
    for a in $archs; do
        arch_args="$arch_args -arch $a"
    done
    IFS="$old_ifs"
    load_args=""
    for a in $(find "$BUILD_ROOT/build-$name" -name 'lib*.a' -type f | sort); do
        load_args="$load_args -Wl,-force_load,$a"
    done
    # shellcheck disable=SC2086
    xcrun --sdk "$sysroot" clang++ -dynamiclib \
        $arch_args \
        -isysroot "$sdk_path" \
        $min_flag \
        -install_name "@rpath/llama.framework/llama" \
        $load_args \
        -framework Accelerate -framework Metal -framework Foundation \
        -framework CoreFoundation -lobjc \
        -o "$fw/llama"
    codesign --force --sign - "$fw/llama"

    # Headers (the set the modulemap exposes; ggml-opt.h is required since
    # recent llama.h versions include it)
    cp "$SRC/include/llama.h" "$fw/Headers/"
    local h
    for h in ggml.h ggml-alloc.h ggml-backend.h ggml-opt.h ggml-metal.h ggml-cpu.h ggml-blas.h gguf.h; do
        cp "$SRC/ggml/include/$h" "$fw/Headers/"
    done

    # Clang module (imported from Swift as `import llama`)
    cat > "$fw/Modules/module.modulemap" <<'MODULEMAP'
framework module llama {
    header "llama.h"
    header "ggml.h"
    header "ggml-alloc.h"
    header "ggml-backend.h"
    header "ggml-opt.h"
    header "ggml-metal.h"
    header "ggml-cpu.h"
    header "ggml-blas.h"
    header "gguf.h"

    link "c++"
    link framework "Accelerate"
    link framework "Metal"
    link framework "Foundation"

    export *
}
MODULEMAP

    # Framework Info.plist
    cat > "$fw/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>llama</string>
	<key>CFBundleIdentifier</key>
	<string>org.ggml.llama</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>llama</string>
	<key>CFBundlePackageType</key>
	<string>FMWK</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleSupportedPlatforms</key>
	<array>
		<string>$supported_platform</string>
	</array>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>MinimumOSVersion</key>
	<string>$DEPLOYMENT_TARGET</string>
	<key>UIDeviceFamily</key>
	<array>
		<integer>1</integer>
		<integer>2</integer>
	</array>
</dict>
</plist>
PLIST

    # Debug symbols
    dsymutil "$fw/llama" -o "$BUILD_ROOT/$name/dSYMs/llama.dSYM"
    echo "==> [$name] packaged: $fw"
}

# ---------------------------------------------------------------------------
# 1) Build both slices
# ---------------------------------------------------------------------------
build_slice "ios-arm64" "iphoneos" "arm64"
build_slice "ios-arm64_x86_64-simulator" "iphonesimulator" "arm64;x86_64"

# ---------------------------------------------------------------------------
# 2) Package each into a llama.framework replicating the previous layout
#    (name, sysroot, archs, supported platform)
# ---------------------------------------------------------------------------
package_framework "ios-arm64" "iphoneos" "arm64" "iPhoneOS"
package_framework "ios-arm64_x86_64-simulator" "iphonesimulator" "arm64;x86_64" "iPhoneSimulator"

# ---------------------------------------------------------------------------
# 3) Assemble the xcframework
# ---------------------------------------------------------------------------
OUT="$BUILD_ROOT/llama.xcframework"
rm -rf "$OUT"
echo "==> Creating $OUT"
xcodebuild -create-xcframework \
    -framework "$BUILD_ROOT/ios-arm64/llama.framework" \
    -debug-symbols "$BUILD_ROOT/ios-arm64/dSYMs/llama.dSYM" \
    -framework "$BUILD_ROOT/ios-arm64_x86_64-simulator/llama.framework" \
    -debug-symbols "$BUILD_ROOT/ios-arm64_x86_64-simulator/dSYMs/llama.dSYM" \
    -output "$OUT"

echo "==> Done: $OUT"
echo "    Quick sanity checks:"
echo "      strings $OUT/ios-arm64/llama.framework/llama | grep -c qwen3"
echo "      otool -L $OUT/ios-arm64/llama.framework/llama"
echo "    Then validate and replace ios/llama.xcframework with the built one."
