# Payments and Credits Architecture

## Store products and purchases (funds/)

`FundsBackend` (funds/backend/service.dart, a ChangeNotifier) owns the `in_app_purchase` integration:

- Listens to the purchase stream and auth-state changes (`_startListeningToPurchases`).
- Loads product details with `CacheService` caching (`premiumProducts`, `premiumScreenState`) and preloading checks (`isPreloaded`, `updateLocalizationAndRefresh`).
- Tracks the current subscription level, the active subscription option/product and pending purchases.
- Special offers: active/eligible flags, expiry timestamp and the entry-point gate (`shouldShowSpecialOfferEntryPoint` — signed-in, non-anonymous, level 0).
- Part files under `funds/backend/`: `products.dart`, `purchase.dart`, `receipt.dart`, `verification.dart`, `offer.dart`, `user.dart` (`FundsProducts`, `FundsPurchase`, `FundsReceipt`, `FundsVerification`, `FundsSpecialOffer`, `FundsUserData`).

UI: `FundsScreen` (funds/funds.dart), `SubscriptionContentWidget` (widgets/subscriptions.dart), `FundsSkeletonLoader` (skeleton.dart). `ClaimOfferButton` lives in the chat appbar.

## Verification (server side)

Purchases are verified by Fulcrum `iap.js` `verifyPurchase` (current and legacy Apple/Google APIs), which maps verified transactions to subscription entitlements. Store webhooks — `handlePlayNotifications` (android/lifecycle.js) and `handleAppStoreNotifications` (ios/lifecycle.js) — are idempotent and transaction-oriented because billing callbacks may retry or arrive out of order. See `../fulcrum/billing.md`.

## Credits engine (server/credits.dart)

`CreditsManager` is a client-side singleton that mirrors the server's credit engines so the UI can stop offering what the server would refuse:

- Access bands (`CreditAccess`): `full`, `low_only` (dynamic chat, cheapest mode, no model choice), `blocked`. The server decides on every request; the client only tracks it for UI gating.
- Daily grants per tier: free 100, plus 500, pro 1000, ultra 10000.
- Two engines are live at once: `billingV2` (single currency; spendable = allowance + owned credits) and `creditsV3` (daily allowance bucket + owned credits). The engine flags arrive from the server when it first renews the allowance.
- `spendableNotifier` mirrors what the server's `authorizeRequest` checks; `minTextBalance` mirrors the server's `MIN_TEXT_BALANCE` below which text requests are refused.
- Legacy `predits`/`dredits` notifiers are kept for older overlays and are fed the same spendable value.

## Related flows

- Entitlement grants/revokes and credit mutations: Fulcrum `helpers.js` (`grantEntitlement`, `revokeEntitlement`, `deductUserCredits`, `deductDynamicCredits`, `refundUserCredits`, `awardCreditsWithDebtCheck`).
- Daily bonus credits, subscription expiry, refund-abuse detection: Fulcrum `scheduled.js`.
- Special offers and promo/creator codes: Fulcrum `user.js` (`checkOrStartSpecialOffer`, `redeemPromoCode`, `redeemCreatorCode`).
- Guest limits before login: `SendService.checkGuestLimit` (see `chat.md`).
