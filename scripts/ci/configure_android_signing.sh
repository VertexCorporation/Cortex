#!/usr/bin/env bash
set -euo pipefail

# Fail clearly for partially configured secrets, without logging secret values.
if [[ -z "${CORTEX_JKS_BASE64:-}" && -z "${JKS_PASSWORD:-}" ]]; then
  echo 'release_ready=false' >> "$GITHUB_OUTPUT"
  echo 'NOTICE: CORTEX_JKS and JKS_PASSWORD are absent. Building debug APK only.'
  exit 0
fi
if [[ -z "${CORTEX_JKS_BASE64:-}" || -z "${JKS_PASSWORD:-}" ]]; then
  echo 'ERROR: Android release signing requires BOTH CORTEX_JKS (base64 JKS) and JKS_PASSWORD.' >&2
  exit 1
fi

# The configured alias "ai" is intentional and must exist in the supplied JKS.
if ! printf '%s' "$CORTEX_JKS_BASE64" | base64 --decode > android/app/Cortex.jks; then
  echo 'ERROR: CORTEX_JKS is not valid base64.' >&2
  exit 1
fi
if [[ ! -s android/app/Cortex.jks ]]; then
  echo 'ERROR: CORTEX_JKS decoded to an empty keystore.' >&2
  exit 1
fi
if ! keytool -list -keystore android/app/Cortex.jks -storepass "$JKS_PASSWORD" -alias ai >/dev/null 2>&1; then
  echo 'ERROR: Cannot open Android JKS with JKS_PASSWORD, or key alias "ai" is missing.' >&2
  exit 1
fi
printf 'storePassword=%s\nkeyPassword=%s\nkeyAlias=ai\nstoreFile=Cortex.jks\n' \
  "$JKS_PASSWORD" "$JKS_PASSWORD" > android/key.properties
chmod 600 android/app/Cortex.jks android/key.properties

echo 'release_ready=true' >> "$GITHUB_OUTPUT"
echo 'Android signing keystore validated (release APK + AAB enabled).'
