#!/usr/bin/env bash
# Check the dependency, final .xcarchive, or exported .ipa before upload.
# This is a local signature check, not Apple's server-side validation.
set -eEuo pipefail
trap 'echo "error: llama signature verification failed at line $LINENO" >&2' ERR
identifier_only=false
if [ "${1:-}" = --identifier-only ]; then
    identifier_only=true
    shift
fi
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 [--identifier-only] <llama.framework|llama.xcframework|app.xcarchive|app.ipa>" >&2
    exit 2
fi
root="$1"
tmp=""
trap 'if [ -n "$tmp" ]; then rm -rf "$tmp"; fi' EXIT
if [[ "$root" = *.ipa ]]; then
    tmp="$(mktemp -d)"
    /usr/bin/ditto -x -k "$root" "$tmp"
    root="$tmp/Payload"
fi
if [ ! -d "$root" ]; then
    echo "error: directory not found: $root" >&2
    exit 1
fi
count=0
while IFS= read -r -d '' fw; do
    bundle_id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$fw/Info.plist")"
    if [ "$bundle_id" != org.ggml.llama ]; then
        echo "error: unexpected llama bundle identifier: $bundle_id ($fw)" >&2
        exit 1
    fi
    # Universal simulator binaries have a separate signature per architecture.
    architectures="$(/usr/bin/lipo -archs "$fw/llama")"
    [ -n "$architectures" ]
    for arch in $architectures; do
        details="$(/usr/bin/codesign --display --verbose=4 --arch "$arch" "$fw" 2>&1)"
        identifier="$(printf '%s\n' "$details" | sed -n 's/^Identifier=//p')"
        if [ "$identifier" != "$bundle_id" ]; then
            echo "error: $fw ($arch): Identifier=$identifier, expected $bundle_id" >&2
            exit 1
        fi
        echo "$fw ($arch): Identifier=$identifier"
    done
    if [ "$identifier_only" = false ]; then
        /usr/bin/codesign --verify --strict --all-architectures "$fw"
    fi
    count=$((count + 1))
done < <(find "$root" -type d -name llama.framework -print0)
if [ "$count" -eq 0 ]; then
    echo "error: no llama.framework found in $root" >&2
    exit 1
fi
