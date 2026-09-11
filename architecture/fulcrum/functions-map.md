# Fulcrum Functions Map

Catalog of the Fulcrum backend (`functions/`). `index.js` requires every family from `src/` and spreads the exports into one flat, unprefixed namespace so callable names stay stable for the Flutter client and older clients. Consult this map to locate a function; narratives live in `generation.md` and `billing.md`.

## Entry point

- **`functions/index.js`** (68) — Admin SDK init, `setGlobalOptions({ maxInstances: 10 })`, flat-namespace assembly of all function families.

## Generation path

- **`src/message.js`** (16) — backward-compatible re-export: `sendMessage`, `proxyOpenRouterRequest` (both delegate to gateway.js).
- **`src/gateway.js`** (1214) — `sendMessage`: the central chat gateway (validation, routing, context, credit rules, SSE).
- **`src/prompts.js`** (198) — `CORTEX_BASE_PROMPT`, `PLATFORM_INTEGRITY_PROMPT`, `assembleCortexSystemPrompt` and every reusable system-prompt string (character embodiment, voice/study/quiz modes, tool discipline, titles, media-failure explainers, vision describe/bridge): the single source of truth for Fulcrum-owned system instructions (see "System prompt ownership" in `generation.md`).
- **`src/router.js`** (612) — `getDynamicModels`, `pickBestModelList`, `analyzeIntent`, `analyzeMediaParams`, `resolveRoute`, `getProviderCatalog`, `workersAIModels`: provider/model policy engine.
- **`src/media-params.js`** (558) — `parseMediaDirective`, `closestAspectRatio`, `buildElevenLabsMediaPayload`, `applyFalSchemaMediaParams`, `ELEVENLABS_MEDIA_CAPABILITIES`: media parameter normalization. Maps analyzed user directives (aspect ratio / duration / resolution) onto each provider's supported values with Cortex defaults (image 1:1, video closest-to-1:1, music 30s, sound 5s); research-backed ElevenLabs per-model enums.
- **`src/stream.js`** (1709) — `executeApiStream`, `executeFalRequest`, `executeElevenLabsRequest`, `detectFalOutputType`, `deductDynamicCost`, `refundUserCredits`: provider execution, SSE parsing, retries, fallbacks, cost reconciliation.
- **`src/routing.js`** (72) — `findFalModel`, `candidatesFor`, `inputSchema`, `buildSchemaPayload`, `prepareFalRequest`, `endpointOutput`: Fal request helpers.
- **`src/sse.js`** (7) — `splitSseEvents`.
- **`src/title.js`** (92) — `generateFastTitle`: fast titles through Groq.
- **`src/tools.js`** (550) — `executeTool`, `TOOLS`: server-side tool definitions/execution incl. hosted code execution.
- **`src/voice.js`** (356) — `getSpeechToken`, `getAssemblyToken`, `synthesizeSpeech`, `settleSpeechUsage`: Deepgram/AssemblyAI/ElevenLabs endpoints with server-side secrets.
- **`src/chat.js`** (99) — `onNewChatMessage`: Firestore trigger, new-chat push notification.

## Identity and commercial

- **`src/user.js`** (1465) — `registerAnonymousDevice`, `onUserCreate`, `completeAnonymousRegistration`, `updateUsername`, `isUsernameAvailable`, `checkOrStartSpecialOffer`, `redeemCreatorCode`, `redeemPromoCode`, `addAdminRole`, `removeAdminRole`, `listAdmins`, `toggleVertexStatus`, `checkIfUserIsRegistered`, `requestAccountDeletion`, `verifyUserEmail`, `setPhoneNumber`.
- **`src/helpers.js`** (728) — `PRODUCT_CATALOG`, `grantEntitlement`, `revokeEntitlement`, `deductUserCredits`, `deductDynamicCredits`, `refundUserCredits`, `deductPredits`, `deductDredits`, `getProductDetails`, `resolveSubscriptionExpiryMillis`, `deleteUserAndData`, `awardCreditsWithDebtCheck`, `deleteCollection`, `deleteQueryBatch`, `applyReferralReward`, `scheduleSubscriptionExpiryCheck`.
- **`src/subscription.js`** (276, internal module — no exported Cloud Functions) — `TIER_LIMITS`, `TIER_ORDER`, `resolveSubscription`, `subscriptionPayload`, `subscriptionTerminalPayload`, `legacySubscriptionDeletes`, `parseTimestampMillis`: single source of truth for the nested `users/{uid}.subscription` entitlement map (see `billing.md`).
- **`src/iap.js`** (1060) — `verifyPurchase`: Apple/Google purchase verification.
- **`src/android/lifecycle.js`** (350) — `handlePlayNotifications`: Google Play billing notifications.
- **`src/ios/lifecycle.js`** (213) — `handleAppStoreNotifications`: App Store notifications.
- **`src/scheduled.js`** (929) — `initiateVerificationChecks`, `handleVerificationCheck`, `handleSubscriptionExpiry`, `backupSubscriptionSweeper`, `awardDailyBonusCredits`, `cleanupOrphanAndIncompleteUsers`, `detectAndActionRefundAbuse`, `processPendingDeletions`, `cleanupAbandonedAnonymousAccounts`.

## Content and operations

- **`src/models.js`** (744) — `getModelImageUploadUrl`, `createCustomModel`, `deleteCustomModel`, `blockOnlineModel`, `reconcileModelCounts`, `triggerAttributionsUpdate`: custom models across Firestore, Cloud Storage and Cloudflare KV.
- **`src/news.js`** (366) — `createNewsArticle`, `deleteNewsArticle`, `getCoverUploadUrl`, `getCoverDownloadUrl`, `generateNewsCache` (schedule), `getNewsCacheUrl`.
- **`src/notifications.js`** (383) — `sendTargetedNotification`, `scheduleNotification`, `cancelScheduledNotification`, `processScheduledNotification` (Cloud Tasks).
- **`src/config.js`** (153) — `getAppConfig`, `getServerStatus`, `setServerStatus`: server status and maintenance switches.
- **`src/partner.js`** (189) — `getPartnerDashboardData`.
- **`src/contributors.js`** (201) — `createVertexContributor`, `getVertexContributors`, `toggleContributorVerification`, `deleteVertexContributor`.
- **`src/leaderboard.js`** (16) — re-exports from `leaderboard/*`.
- **`src/leaderboard/callable.js`** (200) — `getLeaderboardUrl`, `submitScore`.
- **`src/leaderboard/triggers.js`** (98) — `updateHighscoresCounter`, `updateSeasonScoreboardCounter`.
- **`src/leaderboard/scheduled.js`** (254) — `advanceSeason`, `periodicCleanup`, `periodicCacheRefresh`.
- **`src/leaderboard/helpers.js`** (273) — leaderboard shared helpers.

## Tests

`functions/test/`: `chat-regression.test.js`, `completion.test.js`, `credit-authorization.test.js`, `credit-lifecycle.test.js`, `credit-reconciliation.test.js`, `daily-credits.test.js`, `fal-routing.test.js`, `media-params.test.js`, `media-routing.test.js`, `sse.test.js`, `system-prompt.test.js` (the Fulcrum-owned prompt contract).
