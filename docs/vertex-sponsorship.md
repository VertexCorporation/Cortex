# Vertex-sponsored Plus display

Fulcrum resolves signed Vertex sponsorship separately from the user's paid subscription. The shared `UserProvider.subscription` display parser receives the active Auth UID and uses sponsor fallback only while `isVertex` is active and the stored sponsor has matching UID, source, tier and a correctly shaped signature. Existing active Plus/Pro/Ultra store entitlements win. Anonymous accounts and inactive/mismatched/unsigned sponsorships remain free. Paid-map contents are not changed.

This is display logic only. Fulcrum verifies the Ed25519 signature and authoritative document UID at every access/credit decision. No client write or privilege-grant endpoint is added. Requires the linked Fulcrum PR, reviewed security rules and separately approved server configuration; no app/production release is performed here.

Validation: 28 subscription/sponsorship Flutter tests passed; `flutter analyze --no-pub` reported no issues. On this machine `DEVELOPER_DIR=/Library/Developer/CommandLineTools` was used for the existing test-native-asset tools.
