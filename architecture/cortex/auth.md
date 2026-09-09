# Authentication Architecture

## Service layer (login/backend.dart)

`LoginBackendService` is completely decoupled from the UI. Every flow returns an exhaustive sealed result set, so callers must handle each outcome explicitly:

- `LoginResult`: `LoginSuccess`, `LoginInvalidCredentials`, `LoginUserDisabled`, `LoginNetworkError`, `LoginUnknownError`.
- `RegistrationResult`: `RegistrationSuccess`, `RegistrationUsernameTaken`, `RegistrationEmailInUse`, `RegistrationWeakPassword`, `RegistrationNetworkError`, `RegistrationUnknownError`, `RegistrationInvalidUsername`.
- `GoogleSignInResult` / `AppleSignInResult` / `AnonymousSignInResult`: success/failure/cancelled/network-error variants.
- `UsernameStatus` (`available`, `taken`, `invalid`, `error`) wraps the `isUsernameAvailable` callable result.

## Registration details

Registration posts a username suggestion to the `usernameSuggestions` Firestore collection (username, `invitedBy` referrer, one-hour expiry). The write is best-effort: if it fails, the backend self-heals. The referrer ID comes from `ReferralHandler` (referral.dart); `InviteService` (invite.dart) supports the invite flow.

## Sessions

`_handleSessionPersistence` stores `email`/`password`/`remember_me` in `flutter_secure_storage` when "remember me" is on, and deletes only those keys when off (tokens and device state are untouched). After login, FCM token sync is fire-and-forget (`ExtrovertNotificationService.syncTokenAfterLogin`) — it deliberately waits briefly so backend triggers can create the user document in Firestore, preventing permission-denied races.

## Anonymous accounts

`AnonymousDeviceEntitlement` (login/anonymous.dart) tracks device entitlements. Fulcrum `user.js` provides `registerAnonymousDevice` and `completeAnonymousRegistration`; the upgrade flow is `UpgradeAccountScreen` (login/upgrade.dart) with the anonymous-upgrade panel in `settings/sections/anonymous.dart`. Anonymous users hit guest limits before features (see `SendService.checkGuestLimit`).

## App gates

`AppBootstrap`/`AppGatekeeper` (main.dart) and `AppInitializer` (initialization.dart) coordinate startup readiness, authentication state, onboarding (`OnboardingScreen`, meet.dart) and forced upgrades (`UpdateRequiredScreen`, update.dart, `AppUpgraderMessages`). `MaintenanceScreen` (maintenance.dart) covers server-side maintenance gates.

## UI

`AuthScreen` (login/screen.dart), `LoginForm`/`RegisterForm` (login/view/), `EmailVerificationScreen` (login/verify.dart) with animated code entry, driven by `LoginController`/`AuthMode` (login/controller.dart).

## Settings-side and user state

`AuthService` (settings/services/auth.dart) and `ProfileService` (settings/services/profile.dart) own account actions and profile edits, with their own exception types. `UserProvider` (server/user.dart) exposes the user record to the app and owns the single `users/{uid}` snapshot listener — `FundsBackend` and `CreditsManager` attach to it via `ChangeNotifier` instead of opening their own snapshots. The nested `subscription` entitlement is resolved through `SubscriptionEntitlement` (see `payments.md`).

## Server contract

The Fulcrum callables involved are listed in `../fulcrum/billing.md` (`registerAnonymousDevice`, `completeAnonymousRegistration`, `updateUsername`, `isUsernameAvailable`, `verifyUserEmail`, `requestAccountDeletion`, ...).
