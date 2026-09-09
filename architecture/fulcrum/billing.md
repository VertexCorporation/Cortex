# Fulcrum Billing, Identity and Commercial Systems

## Accounts (user.js)

`user.js` owns account lifecycle: anonymous-device registration (`registerAnonymousDevice`, the `onUserCreate` trigger, `completeAnonymousRegistration`), user records and usernames (`updateUsername`, `isUsernameAvailable`, `checkIfUserIsRegistered`), offers and codes (`checkOrStartSpecialOffer`, `redeemCreatorCode`, `redeemPromoCode`), admin roles (`addAdminRole`, `removeAdminRole`, `listAdmins`, `toggleVertexStatus`), verification (`verifyUserEmail`) and deletion requests (`requestAccountDeletion`, `setPhoneNumber`).

## Transactional helpers (helpers.js)

`helpers.js` provides transactional entitlement/credit mutations, expiry tasks and deletion workflows: `PRODUCT_CATALOG`, `grantEntitlement`, `revokeEntitlement`, `deductUserCredits`, `deductDynamicCredits`, `refundUserCredits`, `deductPredits`, `deductDredits`, `getProductDetails`, `resolveSubscriptionExpiryMillis`, `deleteUserAndData`, `awardCreditsWithDebtCheck`, `deleteCollection`, `deleteQueryBatch`, `applyReferralReward`, `scheduleSubscriptionExpiryCheck`.

## Subscription model (subscription.js)

`subscription.js` is an internal module (no exported Cloud Functions) and the single source of truth for the nested `users/{uid}.subscription` entitlement map:

- `TIER_LIMITS` — per-tier capabilities (`dailyCredits`: free 100 / plus 500 / pro 1000 / ultra 10000, plus `negativeCreditLimit`), merging the previously duplicated `DAILY_SUBSCRIPTION_CREDITS` / `NEGATIVE_CREDIT_LIMIT` / `DAILY_DYNAMIC_ALLOWANCE` maps.
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

`initiateVerificationChecks` + `handleVerificationCheck` (Pub/Sub), `handleSubscriptionExpiry`, `backupSubscriptionSweeper`, `awardDailyBonusCredits`, `cleanupOrphanAndIncompleteUsers`, `detectAndActionRefundAbuse`, `processPendingDeletions`, `cleanupAbandonedAnonymousAccounts`.

## Credit engines

The Flutter `CreditsManager` (see `../cortex/payments.md`) mirrors the server's credit engines: access bands `full`/`low_only`/`blocked` and daily grants free 100 / plus 500 / pro 1000 / ultra 10000, with two engines live at once (single-currency `billingV2` and daily-allowance `creditsV3`; spendable = allowance + owned credits).

Caution: the client documents these mirrors as `functions/src/credits.js` (`ACCESS`, `DAILY_GRANTS`) and `functions/src/billing.js` (`MIN_TEXT_BALANCE`), but those files are not present in the current local Fulcrum checkout — the equivalent logic lives in `helpers.js` and `scheduled.js` here. Verify constants against the deployed revision before changing either side.
