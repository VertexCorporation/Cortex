# Fulcrum Billing, Identity and Commercial Systems

## Accounts (user.js)

`user.js` owns account lifecycle: anonymous-device registration (`registerAnonymousDevice`, the `onUserCreate` trigger, `completeAnonymousRegistration`), user records and usernames (`updateUsername`, `isUsernameAvailable`, `checkIfUserIsRegistered`), offers and codes (`checkOrStartSpecialOffer`, `redeemCreatorCode`, `redeemPromoCode`), admin roles (`addAdminRole`, `removeAdminRole`, `listAdmins`, `toggleVertexStatus`), verification (`verifyUserEmail`) and deletion requests (`requestAccountDeletion`, `setPhoneNumber`).

## Transactional helpers (helpers.js)

`helpers.js` provides transactional entitlement/credit mutations, expiry tasks and deletion workflows: `PRODUCT_CATALOG`, `grantEntitlement`, `revokeEntitlement`, `deductUserCredits`, `deductDynamicCredits`, `refundUserCredits`, `deductPredits`, `deductDredits`, `getProductDetails`, `resolveSubscriptionExpiryMillis`, `deleteUserAndData`, `awardCreditsWithDebtCheck`, `deleteCollection`, `deleteQueryBatch`, `applyReferralReward`, `scheduleSubscriptionExpiryCheck`.

## Purchases (iap.js + store lifecycles)

`iap.js` verifies Apple and Google purchases with current and legacy provider APIs (`verifyPurchase`), then maps verified transactions to subscription entitlements. `android/lifecycle.js` (`handlePlayNotifications`) consumes Google Play billing notifications; `ios/lifecycle.js` (`handleAppStoreNotifications`) receives App Store notifications. These paths are idempotent and transaction-oriented because billing callbacks may retry or arrive out of order.

## Scheduled work (scheduled.js)

`initiateVerificationChecks` + `handleVerificationCheck` (Pub/Sub), `handleSubscriptionExpiry`, `backupSubscriptionSweeper`, `awardDailyBonusCredits`, `cleanupOrphanAndIncompleteUsers`, `detectAndActionRefundAbuse`, `processPendingDeletions`, `cleanupAbandonedAnonymousAccounts`.

## Credit engines

The Flutter `CreditsManager` (see `../cortex/payments.md`) mirrors the server's credit engines: access bands `full`/`low_only`/`blocked` and daily grants free 100 / plus 500 / pro 1000 / ultra 10000, with two engines live at once (single-currency `billingV2` and daily-allowance `creditsV3`; spendable = allowance + owned credits).

Caution: the client documents these mirrors as `functions/src/credits.js` (`ACCESS`, `DAILY_GRANTS`) and `functions/src/billing.js` (`MIN_TEXT_BALANCE`), but those files are not present in the current local Fulcrum checkout — the equivalent logic lives in `helpers.js` and `scheduled.js` here. Verify constants against the deployed revision before changing either side.
