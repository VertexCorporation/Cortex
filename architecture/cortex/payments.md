# Payments and Credits Architecture

## Store products and purchases (funds/)

`FundsBackend` (funds/backend/service.dart, a ChangeNotifier) owns the `in_app_purchase` integration:

- Listens to the purchase stream and auth-state changes (`_startListeningToPurchases`).
- Loads product details with `CacheService` caching (`premiumProducts`, `premiumScreenState`) and preloading checks (`isPreloaded`, `updateLocalizationAndRefresh`).
- Tracks pending purchases; subscription state is not read from the store — it comes from the shared `UserProvider` snapshot (`_attachUserProvider`) and is exposed as a `SubscriptionEntitlement` (`subscription` getter, plus `activeSubscriptionProductId` for the store upgrade flow).
- Special offers: active/eligible flags, expiry timestamp and the entry-point gate (`shouldShowSpecialOfferEntryPoint` — signed-in, non-anonymous, level 0).
- Part files under `funds/backend/`: `products.dart`, `purchase.dart`, `receipt.dart`, `verification.dart`, `offer.dart`, `user.dart` (`FundsProducts`, `FundsPurchase`, `FundsReceipt`, `FundsVerification`, `FundsSpecialOffer`, `FundsUserData`).

UI: `FundsScreen` (funds/funds.dart), `SubscriptionContentWidget` (widgets/subscriptions.dart), `FundsSkeletonLoader` (skeleton.dart). `ClaimOfferButton` lives in the chat appbar.

## Subscription entitlement model (`users/{uid}.subscription`)

Entitlements live in a nested `subscription` map on the user document, written exclusively by Fulcrum (`subscription.js` → `subscriptionPayload`; see `../fulcrum/billing.md`). Fields are conditional — a missing field means "not applicable":

- `tier` (`free`/`plus`/`pro`/`ultra`) — always present; a free/collapsed state is just `{tier: 'free', updatedAt}`.
- `mode` (`renewable`/`lifetime`/`promotional`) — present for paid tiers.
- `status` (`active`/`grace_period`/`past_due`/`expired`/`revoked`) — only `active` grants the tier; terminal states keep the nominal tier for history but resolve to free.
- `expiresAt` — required for `renewable`/`promotional`, never present for `lifetime`.
- `productId`, `billingPeriod` (`monthly`/`annual`), `source` (`app_store`/`play_store`/`referral`/`admin`) — store grants.
- `updatedAt` — server timestamp of the last entitlement write.

Legacy flat fields (`hasCortexSubscription`, `subscriptionExpiresAt`, `activeSubscriptionProductId`, `activeSubscriptionOption`, `subscriptionStatus`) are deleted by the server on every entitlement write — a clean break, no dual reads.

`SubscriptionEntitlement` (server/subscription.dart) is the single client-side resolver: enums for tier/mode/status/billingPeriod/source, `fromUserData` tolerant of Firestore Timestamps and cached ISO strings, and `isActive` / `isPaid` / `effectiveTier` / `chatCharacterLimit` getters that mirror the server's `resolveSubscription`. UI code should use the `UserProvider.subscription` getter instead of reading the raw document. Credit limits are **not** mirrored by hardcoded getters — the server publishes them on `users/{uid}.creditLimits` and the client caches them via `UserProvider.creditLimits` (typed `CreditLimits` in server/subscription.dart; see below).

`UserProvider` (server/user.dart) owns the only `users/{uid}` snapshot listener. `FundsBackend` and `CreditsManager` attach to it as `ChangeNotifier` listeners instead of opening their own snapshots, so all entitlement/credit state derives from a single stream. Season rewards use a dedicated `leaderboardRank` field on the user document, fully separate from subscription state.

## Verification (server side)

Purchases are verified by Fulcrum `iap.js` `verifyPurchase` (current and legacy Apple/Google APIs), which maps verified transactions to subscription entitlements. Store webhooks — `handlePlayNotifications` (android/lifecycle.js) and `handleAppStoreNotifications` (ios/lifecycle.js) — are idempotent and transaction-oriented because billing callbacks may retry or arrive out of order. See `../fulcrum/billing.md`.

## Credits engine (server/credits.dart)

`CreditsManager` is a client-side singleton that mirrors the server's unified credit engine so the UI can stop offering what the server would refuse:

- Access bands (`CreditAccess`): `full` (credits >= 0), `low_only` (negative but above the floor: Dynamic Chat only, lanes capped at low/medium server-side, no model choice), `blocked` (at or below the floor). The server decides via `evaluateCreditPolicy` (`subscription.js`) on every request; the client only tracks it for UI gating.
- Credit limits come from the server, never from the client: `creditLimitsForTier` (`subscription.js`) publishes `{ dailyGrant, debtFloor }` onto `users/{uid}.creditLimits` at every tier/credit write-point (creation, grants/revocations/referrals/store purchases, expiry, both daily renewals), so balances may go negative down to the per-tier debt floor — today free -50 / plus -125 / pro -250 / ultra -1250 — before anything is blocked. The client caches this map from the normal user-data snapshot with zero extra reads (`UserProvider.creditLimits`, `CreditsManager.dailyGrant` / `CreditsManager.debtFloor`), so backend limit changes propagate with the next snapshot and can never drift. `CreditLimits.fallback` (free-tier values) only covers documents written before the server began publishing limits; they converge on the next daily renewal. Backend enforcement stays authoritative — the published map is a client cache, never a security boundary.
- One unified `credits` field on `users/{uid}` is the only balance: `spendable == total == credits`. There are no engine flags or allowance buckets.
- While negative, manual model selection is lost (pickers close, sends are rewritten to Dynamic Chat) and media is refused server-side; at or below the floor nothing is sendable until the allowance renews. The negative-credit warning panel keeps its tier-specific states and switches to the "exhausted" variant at the floor.

## Related flows

- Entitlement grants/revokes and credit mutations: Fulcrum `helpers.js` (`grantEntitlement`, `revokeEntitlement`, `deductUserCredits`, `deductDynamicCredits`, `refundUserCredits`, `awardCreditsWithDebtCheck`).
- Daily bonus credits, subscription expiry, refund-abuse detection: Fulcrum `scheduled.js`.
- Special offers and promo/creator codes: Fulcrum `user.js` (`checkOrStartSpecialOffer`, `redeemPromoCode`, `redeemCreatorCode`).
- Guest limits before login: `SendService.checkGuestLimit` (see `chat.md`).
