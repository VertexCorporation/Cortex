# Final Polish Tasks — Implementation Notes

Grounded reconnaissance for the 7 final-polish tasks of the credit-engine rollout.
Every claim below was verified against the working tree before editing (see file/line refs).

## Task 1 — Credit gating of generation features

**Surface (confirmed wider than the feature sheet alone):**
- `lib/chat/features/features/sheet.dart` (445 lines) — the feature sheet.
- `lib/chat/screen/widgets/bottom/panels/briefing.dart` — reactive credit-warning surface
  (`_resolveBriefing` L228–290, exhausted/declining copy L292–330).
- `lib/chat/screen/appbar/appbar.dart` — appbar credits area (L150–245).

**State available for gating (context-free):** `CreditsManager.instance`
(`lib/server/credits.dart` L29 singleton):
- `accessNotifier.value` → `CreditAccess.full / lowOnly / blocked` (L13–16, L53–54);
- `spendableNotifier.value` → `int?` unified balance (L57–58);
- `debtFloor` / `dailyGrant` from server-published `creditLimits` (L76–87);
- `modelSelectionAllowed` (L64) = `full` band only; `canSendAnything` (L68) = not `blocked`.

**Server law (payments.md L41–43):** while negative, media is refused server-side and
manual model selection is lost; at or below the floor (`-dailyGrant`) nothing is sendable.
The client gates features on the access band — never derives credit state client-side.

**Top-up CTA:** route to `FundsScreen` through `navigateToScreen` (supports `initialPlanType`).

## Task 2 — Credit-limit conversational recovery

**Funnel (single):** `_handleSendError` in `lib/chat/services/send.dart` L1761–1795
(call site L1036, in the catch of the send flow). `ApiException` arrives with the generic
`errorReachedLimit` message and the typed `code`.

**Code origin:** `lib/chat/services/api.dart` — `isProviderLimitFailure` (L247–290) maps
provider-limit failures to `ApiException(localizations.errorReachedLimit, code: code)`
(L386–392). Typed codes (L249–265, L394–448): `INSUFFICIENT_USER_CREDITS`,
`PREDIT_EXHAUSTED`, `DREDIT_EXHAUSTED`, `PREMIUM_TRIAL_EXHAUSTED`,
`DYNAMIC_CREDITS_EXHAUSTED`, `LIMIT_IMAGE/VIDEO/AUDIO/MEDIA_INSUFFICIENT`,
`INSUFFICIENT_CREDITS`, `INSUFFICIENT_BALANCE`, `CREDITS_EXHAUSTED`, `CREDIT_EXHAUSTED`,
`QUOTA_EXCEEDED`, `PAYMENT_REQUIRED`.

**Design (no new l10n keys — all locales carry every message, 22 ARBs × 600 getters):**
In `_handleSendError`, when the error code is a typed credit refusal, replace the generic
message with the canonical credit copy the briefing already uses, selected by the current
deterministic client state:
- `access == blocked` (or spendable ≤ debtFloor) → `creditWarningExhaustedMessage(renewal)`,
  ultra → `creditWarningUltraExhaustedMessage(renewal)`;
- `access == lowOnly` (or spendable < 0) → `creditWarningFreeDecliningMessage` /
  `creditWarningPaidUpgradeMessage` / `creditWarningUltraMessage`;
- `PREMIUM_TRIAL_EXHAUSTED` → `premiumTrialExhaustedMessage`;
- `full` band media refusals (`LIMIT_*_INSUFFICIENT` with non-negative balance) and thin
  state (`spendableNotifier.value == null`) → keep `errorReachedLimit` (deterministic fallback).

**Mechanics:**
- Extract the renewal formatter from `briefing.dart` (`_formatRenewalRemaining`, L328,
  "23h 14m" / "1m" floor) into a public `formatRenewalRemaining(Duration)` in
  `credits.dart`; the briefing delegates to it. One countdown format everywhere.
- Expose `String get subscriptionTier => _subscriptionTier;` on `CreditsManager`
  (presentation-only read of what `UserProvider` snapshots resolved).
- Pure top-level selector in `send.dart` (`creditRefusalRecoveryMessage`) so
  `test/credit_recovery_test.dart` can exercise it without constructing SendService.

**Invariants:** non-recursive (string composition only), non-retrying (no resend, no
Dynamic rewrite), deterministic (pure selection, explicit fallbacks).

## Task 3 — Rename restyle

Swap the ad-hoc rename dialog in `lib/chat/axon/inbox/tile/view.dart` for the shared
`showEditTitleDialog`. Verify the call site and the shared dialog signature before editing.

## Task 4 — Greeting shimmer removal

Pinned site: `lib/chat/screen/default/view.dart` ~L1176–1248 (shimmer block for the
dynamic-chat greeting). Remove the shimmer, keep the greeting rendered directly.

## Tasks 5–7

Per prior plan (unified preview UI, Edit-from-preview, attachment thumbnail cleanup) —
re-confirm exact scope against the working tree when reached; not grounded in this pass.

## Verification

- `flutter analyze` clean.
- New tests: `test/credit_recovery_test.dart`; formatter cases appended to
  `test/credits_test.dart` (plain `flutter_test`, pure functions, no Firebase).
- Run the touched suites: `credit_recovery_test.dart`, `credits_test.dart`,
  `credit_briefing_test.dart`, `features_test.dart`, `chat_test.dart`.
