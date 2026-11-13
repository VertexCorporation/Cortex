#!/usr/bin/env bash
set -euo pipefail

names=(BUILD_CERTIFICATE_BASE64 P12_PASSWORD BUILD_PROVISION_PROFILE_BASE64 KEYCHAIN_PASSWORD)
present=0
missing=()
for name in "${names[@]}"; do
  if [[ -n "${!name:-}" ]]; then
    present=$((present + 1))
  else
    missing+=("$name")
  fi
done

if [[ $present -eq 0 ]]; then
  echo 'release_ready=false' >> "$GITHUB_OUTPUT"
  echo 'NOTICE: Apple signing secrets absent. Building unsigned .app (NOT an IPA).'
  exit 0
fi
if [[ $present -ne ${#names[@]} ]]; then
  echo "ERROR: Incomplete Apple signing setup. Missing: ${missing[*]}" >&2
  echo 'These variables map to GitHub secrets APPLE_CERTIFICATE_P12_BASE64, APPLE_CERTIFICATE_PASS, APPLE_PROVISIONING_PROFILE_BASE64, KEYCHAIN_PASSWORD.' >&2
  exit 1
fi

echo 'release_ready=true' >> "$GITHUB_OUTPUT"
echo 'Apple signing secrets are present; validating actual files next.'
