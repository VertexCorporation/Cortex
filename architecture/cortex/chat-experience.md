# Voice, Flow, offline setup and music

## Offline entry

Empty-chat offline taps open `OfflineSetupSheet`: explanation, automatic versus
specific choice, then device inspection/recommendation and explicit download.
Taps in an existing conversation retain `handleUseOfflineAction` and preserve
history. The specific-choice button reuses `PremiumButton`; free accounts enter
the existing Plus/account-upgrade funnel, paid accounts open the local library.
No purchase verification or backend entitlement logic is changed.

`recommendOfflineModel` operates on precise catalogue variants. Only free local
models with known RAM and file size are eligible. The RAM budget uses available
memory, reserves 512 MB, and is capped at 70% of total RAM. New downloads require
a secure URL and storage headroom. Suitable installed models are preferred.
The iOS memory channel reports app RSS rather than system-wide usage, so its
automatic recommendation uses a reduced 35% physical-RAM budget with the same
reserve. This is a conservative heuristic, not a measured iOS process limit.
Unknown device requirements produce a manual-library fallback. Recommendation
is not an inference benchmark and cannot guarantee a particular token rate.

Downloads use `ModelLocalStateProvider` and its existing native download manager.
The panel shows progress and allows entering offline mode after the registered
file exists. Closing the panel does not cancel the download. A retry/reopened
panel can reuse existing downloads. Paused downloads can be managed in the library.

## Voice/Flow lifecycle

Flow generations increase even when a voice-session identity is reused. Delayed
participant/round transitions verify both identities. Flow interruption clears
the transcript turn, invalidates synthesis, stops remote and native playback,
and checks the session again after asynchronous teardown. Four consecutive
uncaught participant callback failures stop the session rather than spin forever.
Server voice reservations and payment rules remain authoritative.

## Music

`musicGeneration` is a separate composer mode. The wire request retains the
established `generationTarget: audio` contract and chooses a Fal audio model
whose catalogue metadata explicitly advertises music. TTS and generic sound
models are excluded. Missing music capability is reported before the request;
the client never substitutes a demo song. Generation, audio events, persistence,
playback and sharing use the existing media pipeline. Duration/style/lyrics
remain user prompt content; provider capability enforcement stays on the backend.
Music failures retain their provider error instead of retrying generic audio
routing, which could generate speech or sound effects. The music path disables
text tools and web search, and excludes audio-only editing models.

The integration uses the existing `generating_audio` and `audio_chunk {url}`
contracts and the `speech` accounting lane. Live music-provider availability
and billing behavior require validation on an authenticated device.

## Verification

CI runs localization generation, application analysis, targeted Flutter
regressions and Android arm64/native debug compilation. Device acceptance:

- Complete/back/dismiss the wizard on narrow screens and with large text.
- Reject insufficient/unknown RAM and storage; reuse an installed model.
- Download, background, resume, retry, then start offline chat with no network.
- Enter/leave Flow rapidly; interrupt remote playback and change sessions.
- Generate real music; verify playable local audio survives restart and shares.

Physical-device audio timing, iOS compilation, actual music generation and
purchase routing are not proven by unit tests or an Android debug build.
