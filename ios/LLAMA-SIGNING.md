# llama framework signing

The upload-only 409 originated in `build-llama-xcframework.sh`, not in the
application Bundle Identifier. The script signed the standalone dylib before
creating the framework Info.plist. The checked-in device binary carried exactly
`llama-555549442a9f64ca53b431dfb5c3a8c6015813be`; its signature did not bind
Info.plist. The simulator slice had the same class of defect.

Runner embeds the XCFramework using Xcode's CodeSignOnCopy. Re-signing with
identifier preservation carries an existing bad identifier forward. Flutter's
build/archive success therefore does not establish App Store acceptance.

Packaging now signs the complete framework after creating its resources, with
an explicit `--identifier org.ggml.llama`, and verifies every architecture.
The checked-in slices are repaired as well; rebuilding llama.cpp is unnecessary
for this signature-only correction. Keep their `_CodeSignature/CodeResources`
files alongside the changed binaries. Xcode still supplies the app's signing
identity when embedding the framework. No application signing settings change.

## Release verification

Produce a fresh archive and IPA from the repaired dependency (do not reuse an
old archive). With a configured Apple signing identity and provisioning:

```sh
flutter build ipa --release
./ios/verify-llama-signature.sh build/ios/archive/Runner.xcarchive
./ios/verify-llama-signature.sh build/ios/ipa/your-export.ipa
```

Use the actual exported IPA filename. Both checks must print
`Identifier=org.ggml.llama` and exit successfully. The checker is read-only and
also checks signature integrity. It accepts ad-hoc signatures for dependency
checks, so passing it alone does not prove distribution-signing eligibility.

Finally use Xcode Organizer's Validate App on the fresh archive with App Store
Connect distribution, or validate the exported IPA with Apple's upload tooling.
Only Apple's successful response establishes App Store validation. Do not
repair an already exported IPA in place: nested changes invalidate its enclosing
app signature.

## Local verification (2026-09-13)

- Full fresh native rebuild using `OUT_DIR=/tmp/cortex-signing-audit/rebuilt`
  completed, including device arm64 and simulator arm64/x86_64. All signatures
  pass, including verification after XCFramework assembly.
- Checked-in slices pass plist, identifier, signature-integrity, architecture
  manifest and matching dSYM UUID checks.
- Repository-wide search, including ignored files and binary content (excluding
  Git internals), found the original hash only in this explanation. No conflicting
  llama framework plist identifier or additional signing override was found.
  The dSYM's `com.apple.xcode.dsym.org.ggml.llama` identifies debug symbols and
  is not a framework Bundle Identifier.
- CocoaPods does not install llama; Runner's native Embed Frameworks phase does.
  Flutter's iOS backend embeds App, Flutter and native assets; it does not re-sign
  this directly referenced llama XCFramework.
- `flutter build ipa --release --no-codesign` succeeded twice, including after
  adding the final verification phase, and produced a fresh Runner.xcarchive.
  Its embedded device framework retained `Identifier=org.ggml.llama` and the
  application remained `com.vertex.cortex`.
- Unsigned embedding removes Headers/Modules without renewing the resource seal.
  Therefore use `--identifier-only` to inspect an intentionally unsigned archive.
  The default checker correctly rejects its stale seal. A copy of the processed
  framework, ad-hoc re-signed with metadata preservation, passes full verification.
- A ZIP/IPA container made locally from the actual unsigned archive also passes
  identifier-only inspection after extraction. It is not a distribution export.
- `python3 ios/test-llama-signature.py` tests valid slices, manifest architectures,
  default and metadata-preserving re-signing, archive/IPA fixtures, and rejection
  of wrong identifiers, wrong plists, absent signatures, tampering, missing
  binaries, and empty inputs. IPA fixtures are not distribution exports.
- Runner now has a final, always-run `Verify llama signature` phase after all
  embedding/resource scripts. Signed builds require full integrity; explicitly
  unsigned builds require matching identifiers. Both branches reject injected
  bad identifiers. The packaging script also verifies the assembled XCFramework.
- `flutter analyze`, shell syntax, Podfile Ruby syntax, Xcode project plist
  validation and `git diff --check` passed.

Apple Distribution export and App Store Connect validation are still pending.
This machine reports zero valid Apple signing identities. No local or ad-hoc
check proves App Store acceptance.
