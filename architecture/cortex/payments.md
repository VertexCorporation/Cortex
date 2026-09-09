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

`SubscriptionEntitlement` (server/subscription.dart) is the single client-side resolver: enums for tier/mode/status/billingPeriod/source, `fromUserData` tolerant of Firestore Timestamps and cached ISO strings, and `isActive` / `isPaid` / `effectiveTier` / `dailyGrant` / `chatCharacterLimit` getters that mirror the server's `resolveSubscription`. UI code should use the `UserProvider.subscription` getter instead of reading the raw document.

`UserProvider` (server/user.dart) owns the only `users/{uid}` snapshot listener. `FundsBackend` and `CreditsManager` attach to it as `ChangeNotifier` listeners instead of opening their own snapshots, so all entitlement/credit state derives from a single stream. Season rewards use a dedicated `leaderboardRank` field on the user document, fully separate from subscription state.

## Verification (server side)

Purchases are verified by Fulcrum `iap.js` `verifyPurchase` (current and legacy Apple/Google APIs), which maps verified transactions to subscription entitlements. Store webhooks — `handlePlayNotifications` (android/lifecycle.js) and `handleAppStoreNotifications` (ios/lifecycle.js) — are idempotent and transaction-oriented because billing callbacks may retry or arrive out of order. See `../fulcrum/billing.md`.

## Credits engine (server/credits.dart)

`CreditsManager` is a client-side singleton that mirrors the server's credit engines so the UI can stop offering what the server would refuse:

- Access bands (`CreditAccess`): `full`, `low_only` (dynamic chat, cheapest mode, no model choice), `blocked`. The server decides on every request; the client only tracks it for UI gating.
- Daily grants per tier: free 100, plus 500, pro 1000, ultra 10000 — mirrored by `SubscriptionEntitlement.dailyGrant` from the server's `TIER_LIMITS`.
- Two engines are live at once: `billingV2` (single currency; spendable = allowance + owned credits) and `creditsV3` (daily allowance bucket + owned credits). The engine flags arrive from the server when it first renews the allowance.
- `spendableNotifier` mirrors what the server's `authorizeRequest` checks; `minTextBalance` mirrors the server's `MIN_TEXT_BALANCE` below which text requests are refused.
- Legacy `predits`/`dredits` notifiers are kept for older overlays and are fed the same spendable value.

## Related flows

- Entitlement grants/revokes and credit mutations: Fulcrum `helpers.js` (`grantEntitlement`, `revokeEntitlement`, `deductUserCredits`, `deductDynamicCredits`, `refundUserCredits`, `awardCreditsWithDebtCheck`).
- Daily bonus credits, subscription expiry, refund-abuse detection: Fulcrum `scheduled.js`.
- Special offers and promo/creator codes: Fulcrum `user.js` (`checkOrStartSpecialOffer`, `redeemPromoCode`, `redeemCreatorCode`).
- Guest limits before login: `SendService.checkGuestLimit` (see `chat.md`).
