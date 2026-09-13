# Fulcrum Billing, Identity and Commercial Systems

## Accounts (user.js)

`user.js` owns account lifecycle: anonymous-device registration (`registerAnonymousDevice`, the `onUserCreate` trigger, `completeAnonymousRegistration`), user records and usernames (`updateUsername`, `isUsernameAvailable`, `checkIfUserIsRegistered`), offers and codes (`checkOrStartSpecialOffer`, `redeemCreatorCode`, `redeemPromoCode`), admin roles (`addAdminRole`, `removeAdminRole`, `listAdmins`, `toggleVertexStatus`), verification (`verifyUserEmail`) and deletion requests (`requestAccountDeletion`, `setPhoneNumber`).

## Transactional helpers (helpers.js)

`helpers.js` provides transactional entitlement/credit mutations, expiry tasks and deletion workflows: `PRODUCT_CATALOG`, `getProductDetails`, `grantEntitlement`, `revokeEntitlement`, `deductUserCredits`, `deductDynamicCredits`, `refundUserCredits`, `awardCreditsWithDebtCheck`, `resolveSubscriptionExpiryMillis`, `scheduleSubscriptionExpiryCheck`, `deleteUserAndData`, `deleteCollection`, `deleteQueryBatch`, `applyReferralReward`.

## Subscription model (subscription.js)

`subscription.js` is an internal module (no exported Cloud Functions) and the single source of truth for the nested `users/{uid}.subscription` entitlement map:

- `TIER_LIMITS` — per-tier capabilities (`dailyCredits`: free 50 / plus 125 / pro 250 / ultra 1250, plus `negativeCreditLimit`, its negation), merging the previously duplicated `DAILY_SUBSCRIPTION_CREDITS` / `NEGATIVE_CREDIT_LIMIT` / `DAILY_DYNAMIC_ALLOWANCE` maps. It is the single source of truth for tier limits: `evaluateCreditPolicy` enforces from it at request time, and `creditLimitsForTier` publishes `{ dailyGrant, debtFloor }` onto `users/{uid}.creditLimits` at every tier/credit write-point (user creation, entitlement grants/revocations/referrals, store purchases, expiry terminals, and both daily renewals) so the Flutter client caches authoritative values from its normal user-data snapshot instead of hardcoding them.
- `TIER_ORDER` — relative tier weight (free 0 … ultra 3) for upgrade/downgrade comparisons.
- `resolveSubscription(userData)` — the authoritative active/tier/expiry read used by every consumer (chat gating in `gateway.js`, `voice.js`, `models.js`, scheduled jobs, notifications).
- `subscriptionPayload(...)` — builds the nested map for grants. Fields are conditional ("missing = not applicable"): free states collapse to `{tier, updatedAt}`, renewable/promotional grants carry `expiresAt`, lifetime grants never do, and store grants carry `productId`/`billingPeriod`/`source`.
- `subscriptionTerminalPayload(...)` — terminal states (`expired`, `revoked` — refunds and account transfers map to `revoked`, `grace_period` is preserved) keep the nominal tier for history but drop `expiresAt`.
- `legacySubscriptionDeletes()` — deletes the flat fields (`hasCortexSubscription`, `subscriptionExpiresAt`, `activeSubscriptionProductId`, `activeSubscriptionOption`, `subscriptionStatus`) on every entitlement write so legacy documents converge (clean break, no dual reads).
- `parseTimestampMillis` — accepts Firestore Timestamps, Dates, ISO strings and epoch millis.

`grantEntitlement(transaction, userId, productId, purchaseData, userData, source)` and `revokeEntitlement(transaction, userId, productId, reason, ...)` (helpers.js) are the only writers of the map. The `source` argument (`play_store`/`app_store`/`admin`/`referral`) is required for paid tiers, and `userData = null` skips the creator-supporter bonus. Season rewards (`leaderboard/scheduled.js` `advanceSeason`) write a dedicated `leaderboardRank` field — historically they hacked the rank into `hasCortexSubscription`, which collided with the subscription tier system.

## Purchases (iap.js + store lifecycles)

`iap.js` verifies Apple and Google purchases with current and legacy provider APIs (`verifyPurchase`), then maps verified transactions to subscription entitlements. `android/lifecycle.js` (`handlePlayNotifications`) consumes Google Play billing notifications; `ios/lifecycle.js` (`handleAppStoreNotifications`) receives App Store notifications. These paths are idempotent and transaction-oriented because billing callbacks may retry or arrive out of order.

## Scheduled work (scheduled.js)

`initiateVerificationChecks` + `handleVerificationCheck` (Pub/Sub), `handleSubscriptionExpiry`, `backupSubscriptionSweeper`, `awardDailyBonusCredits`, `cleanupExpiredUsageSessions`, `cleanupOrphanAndIncompleteUsers`, `detectAndActionRefundAbuse`, `processPendingDeletions`, `cleanupAbandonedAnonymousAccounts`.

## Realtime voice allowance (voice.js)

A product/safety daily cap, deliberately SEPARATE from the credit engine: one shared pool per user per Istanbul day for Voice Mode and Flow Mode, sized by `TIER_LIMITS.dailyVoiceSeconds` (free 120 / plus 300 / pro 720 / ultra 3600 seconds) and published to clients via `creditLimitsForTier` (`voiceDailySeconds`), stored on the user document as `voiceUsage: { day, seconds }`.

Enforcement is RESERVATION AT MINT + RECONCILIATION AT SETTLEMENT, each in one Firestore transaction: concurrent devices serialize on the user document and can never double-spend the pool; the pool resets LAZILY at the first mint of a new Istanbul day (`renewalDayKey` from credits.js — the same boundary as the credit renewal), so no scheduled voice job exists that could be missed. Each mint reserves `min(remaining, VOICE_WINDOW_SECONDS=300)` and creates the `usage_sessions` document in the same transaction, answers with the authoritative `voice` block (`allowanceSeconds`/`remainingSeconds`/`reservedSeconds`), and refuses with 403 `voice_daily_limit` once the pool is empty; a failed provider mint releases the reservation. Honest clients recycle the provider connection at the window boundary; the server re-checks the pool at every mint, and AssemblyAI sessions are additionally provider-capped at the user's remaining allowance via `max_session_duration_seconds`. Settlement replaces the reservation with the provider-reported actual session duration (clamped to one hour, same-day only). `reportOnly` failure telemetry is logged without minting, reserving or charging. `cleanupExpiredUsageSessions` (hourly) deletes usage-session documents 24h after their settlement window.

Credits continue to settle provider cost exactly as before — the LLM turn is charged by `sendMessage`, realtime STT by `settleSpeechUsage` (Deepgram exact-cost lookup when available, else duration×rate; AssemblyAI session-hour), TTS by the ElevenLabs character-cost path — so the allowance never double-charges anything.

## Credit engine

A single unified `credits` field on `users/{uid}` drives everything. `evaluateCreditPolicy` (subscription.js) bands it: `full` (>= 0), `low_only` (negative but above the per-tier debt floor `-dailyGrant`, with grants free 50 / plus 125 / pro 250 / ultra 1250), `blocked` (at or below the floor). While negative, manual model selection is refused, Dynamic Chat stays open but capped at low/medium lanes, and media operations are refused. The Flutter `CreditsManager` (see `../cortex/payments.md`) mirrors these bands client-side.

The banding lives in `subscription.js` (`evaluateCreditPolicy`, `TIER_LIMITS`); the transactional credit mutations (`deductUserCredits`, `deductDynamicCredits`, `refundUserCredits`) live in `helpers.js`. `creditLimitsForTier` (same file as the banding) publishes the effective tier's limits onto `users/{uid}.creditLimits` for the client cache (see `../cortex/payments.md`). There is no `functions/src/credits.js` or `functions/src/billing.js` — do not reintroduce references to them.

## Credit diagnostics and idempotency

All credit mutations that trace to a single chat generation carry `GenID: <generationId>` in the structured log:

- `deductDynamicCredits` / `deductUserCredits` — charged at gateway entry or after OpenRouter cost reconciliation.
- `refundUserCredits` — returned on upstream failure, provider fallback, or cost overcharge.

Idempotency is enforced by the `creditsDeducted` flag in the per-generation stream state. Refund calls check `creditsDeducted && totalCost > 0` before mutating Firestore, so multiple failure handlers (stream error + final fallback) cannot refund the same generation twice.
