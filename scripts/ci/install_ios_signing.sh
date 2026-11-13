#!/usr/bin/env bash
set -euo pipefail

certificate="$RUNNER_TEMP/cortex-build-certificate.p12"
profile="$RUNNER_TEMP/cortex-build-profile.mobileprovision"
profile_plist="$RUNNER_TEMP/cortex-build-profile.plist"
keychain="$RUNNER_TEMP/cortex-build-signing.keychain-db"

# macOS uses BSD base64 (-D). Do not echo secrets into the logs.
printf '%s' "$BUILD_CERTIFICATE_BASE64" | base64 -D > "$certificate" || { echo 'ERROR: Invalid certificate base64.' >&2; exit 1; }
printf '%s' "$BUILD_PROVISION_PROFILE_BASE64" | base64 -D > "$profile" || { echo 'ERROR: Invalid mobileprovision base64.' >&2; exit 1; }
[[ -s "$certificate" && -s "$profile" ]] || { echo 'ERROR: Empty Apple signing file.' >&2; exit 1; }
chmod 600 "$certificate" "$profile"

security create-keychain -p "$KEYCHAIN_PASSWORD" "$keychain"
security set-keychain-settings -lut 21600 "$keychain"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$keychain"
security default-keychain -s "$keychain"
security list-keychains -d user -s "$keychain"
security import "$certificate" -k "$keychain" -P "$P12_PASSWORD" -T /usr/bin/codesign -T /usr/bin/security
security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" "$keychain"

# Parse the .mobileprovision as a proper plist (no unsafe shell substitution).
security cms -D -i "$profile" > "$profile_plist"
python3 scripts/ci/prepare_ios_signing.py "$profile_plist" "$profile"

# Show certificate metadata ONLY (no private keys/passwords).
security find-identity -v -p codesigning "$keychain"
