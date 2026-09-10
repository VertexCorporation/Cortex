// test/credit_recovery_test.dart
//
// Tests for the credit-limit conversational recovery: when a send fails with
// a typed server credit refusal, the error bubble carries the canonical
// credit copy (what happened, when it renews, what to do) instead of the
// generic limit line. The selector is a pure function over the client credit
// state, so every band/tier/fallback permutation is exercised without
// Firebase or SendService.
import 'package:cortex/chat/services/send.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/server/credits.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

// Free tier values — the documented defaults (payments.md): daily grant 100,
// debt floor -100. Any tier works for the band logic; these numbers keep the
// scenarios readable.
const _debtFloor = -100;

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final loc = await AppLocalizations.delegate.load(const Locale('en'));
  const renewal = Duration(hours: 23, minutes: 14);
  final renewalText = formatRenewalRemaining(renewal);

  group('creditRefusalRecoveryMessage — non-credit errors', () {
    test('passes through for untyped errors (null code)', () {
      expect(
        creditRefusalRecoveryMessage(
          code: null,
          spendable: 50,
          debtFloor: _debtFloor,
          access: CreditAccess.full,
          tier: 'free',
          renewalRemaining: renewal,
          localizations: loc,
        ),
        isNull,
      );
    });

    test('passes through for non-credit typed codes', () {
      expect(
        creditRefusalRecoveryMessage(
          code: 'CONTENT_FLAGGED',
          spendable: 50,
          debtFloor: _debtFloor,
          access: CreditAccess.full,
          tier: 'free',
          renewalRemaining: renewal,
          localizations: loc,
        ),
        isNull,
      );
    });

    test('passes through for unknown codes', () {
      expect(
        creditRefusalRecoveryMessage(
          code: 'SOME_FUTURE_CODE',
          spendable: 50,
          debtFloor: _debtFloor,
          access: CreditAccess.full,
          tier: 'free',
          renewalRemaining: renewal,
          localizations: loc,
        ),
        isNull,
      );
    });
  });

  group('creditRefusalRecoveryMessage — deterministic fallbacks', () {
    test('thin state (no balance snapshot) keeps the plain limit message', () {
      // The send flow can fail before the first user snapshot lands; without
      // a balance any band inference would be a guess.
      expect(
        creditRefusalRecoveryMessage(
          code: 'INSUFFICIENT_USER_CREDITS',
          spendable: null,
          debtFloor: _debtFloor,
          access: CreditAccess.full,
          tier: 'free',
          renewalRemaining: renewal,
          localizations: loc,
        ),
        isNull,
      );
    });

    test('full band keeps the plain limit message (lane refusal)', () {
      // Media codes with a positive balance are about a specific lane, not
      // the daily allowance.
      for (final code in const [
        'LIMIT_IMAGE_INSUFFICIENT',
        'LIMIT_VIDEO_INSUFFICIENT',
        'LIMIT_AUDIO_INSUFFICIENT',
        'LIMIT_MEDIA_INSUFFICIENT',
        'DYNAMIC_CREDITS_EXHAUSTED',
        'DREDIT_EXHAUSTED',
      ]) {
        expect(
          creditRefusalRecoveryMessage(
            code: code,
            spendable: 42,
            debtFloor: _debtFloor,
            access: CreditAccess.full,
            tier: 'pro',
            renewalRemaining: renewal,
            localizations: loc,
          ),
          isNull,
          reason: 'code $code should keep the generic limit wording',
        );
      }
    });
  });

  group('creditRefusalRecoveryMessage — blocked band (exhausted copy)', () {
    test('free tier gets the upgrade nudge and the renewal countdown', () {
      final message = creditRefusalRecoveryMessage(
        code: 'INSUFFICIENT_USER_CREDITS',
        spendable: -100, // exactly at the floor
        debtFloor: _debtFloor,
        access: CreditAccess.blocked,
        tier: 'free',
        renewalRemaining: renewal,
        localizations: loc,
      )!;
      expect(message, loc.creditWarningExhaustedMessage(renewalText));
      expect(message, contains('23h 14m'));
    });

    test('ultra tier gets no upgrade nudge', () {
      final message = creditRefusalRecoveryMessage(
        code: 'CREDITS_EXHAUSTED',
        spendable: -1250,
        debtFloor: -1250,
        access: CreditAccess.blocked,
        tier: 'ultra',
        renewalRemaining: renewal,
        localizations: loc,
      )!;
      expect(message, loc.creditWarningUltraExhaustedMessage(renewalText));
    });

    test('blocked access wins even if the balance reads above the floor', () {
      // The server band is authoritative: a stale spendable must not
      // downgrade the wording.
      final message = creditRefusalRecoveryMessage(
        code: 'QUOTA_EXCEEDED',
        spendable: 5,
        debtFloor: _debtFloor,
        access: CreditAccess.blocked,
        tier: 'plus',
        renewalRemaining: renewal,
        localizations: loc,
      )!;
      expect(message, loc.creditWarningExhaustedMessage(renewalText));
    });

    test('stale full band still recovers when the balance is blocked', () {
      final message = creditRefusalRecoveryMessage(
        code: 'PAYMENT_REQUIRED',
        spendable: -100,
        debtFloor: _debtFloor,
        access: CreditAccess.full, // stale band, balance says blocked
        tier: 'free',
        renewalRemaining: renewal,
        localizations: loc,
      )!;
      expect(message, loc.creditWarningExhaustedMessage(renewalText));
    });
  });

  group('creditRefusalRecoveryMessage — lowOnly band (declining copy)', () {
    test('free tier is told intelligence may be simpler', () {
      final message = creditRefusalRecoveryMessage(
        code: 'INSUFFICIENT_USER_CREDITS',
        spendable: -12,
        debtFloor: _debtFloor,
        access: CreditAccess.lowOnly,
        tier: 'free',
        renewalRemaining: renewal,
        localizations: loc,
      )!;
      expect(message, loc.creditWarningFreeDecliningMessage(renewalText));
    });

    test('plus tier gets the paid upgrade nudge', () {
      final message = creditRefusalRecoveryMessage(
        code: 'INSUFFICIENT_BALANCE',
        spendable: -3,
        debtFloor: _debtFloor,
        access: CreditAccess.lowOnly,
        tier: 'plus',
        renewalRemaining: renewal,
        localizations: loc,
      )!;
      expect(message, loc.creditWarningPaidUpgradeMessage(renewalText));
    });

    test('pro tier gets the paid upgrade nudge', () {
      final message = creditRefusalRecoveryMessage(
        code: 'CREDIT_EXHAUSTED',
        spendable: -9,
        debtFloor: _debtFloor,
        access: CreditAccess.full, // stale band; balance says low
        tier: 'pro',
        renewalRemaining: renewal,
        localizations: loc,
      )!;
      expect(message, loc.creditWarningPaidUpgradeMessage(renewalText));
    });

    test('ultra tier gets the plain low-usage warning', () {
      final message = creditRefusalRecoveryMessage(
        code: 'PREDIT_EXHAUSTED',
        spendable: -1,
        debtFloor: -1250,
        access: CreditAccess.lowOnly,
        tier: 'ultra',
        renewalRemaining: renewal,
        localizations: loc,
      )!;
      expect(message, loc.creditWarningUltraMessage(renewalText));
    });
  });

  group('creditRefusalRecoveryMessage — premium trial', () {
    test('premium trial exhaustion is worded independently of the bands', () {
      // The premium-model trial story holds at any balance, even blocked.
      final message = creditRefusalRecoveryMessage(
        code: 'PREMIUM_TRIAL_EXHAUSTED',
        spendable: -100,
        debtFloor: _debtFloor,
        access: CreditAccess.blocked,
        tier: 'free',
        renewalRemaining: renewal,
        localizations: loc,
      )!;
      expect(message, loc.premiumTrialExhaustedMessage);
      expect(message, isNot(contains('23h 14m')));
    });
  });

  group('formatRenewalRemaining', () {
    test('formats hours and minutes', () {
      expect(formatRenewalRemaining(const Duration(hours: 23, minutes: 14)),
          '23h 14m');
      expect(formatRenewalRemaining(const Duration(hours: 5, minutes: 2)),
          '5h 2m');
    });

    test('formats lone units', () {
      expect(formatRenewalRemaining(const Duration(hours: 5)), '5h');
      expect(formatRenewalRemaining(const Duration(minutes: 47)), '47m');
    });

    test('never counts below one minute', () {
      expect(formatRenewalRemaining(Duration.zero), '1m');
      expect(formatRenewalRemaining(const Duration(seconds: 30)), '1m');
      expect(formatRenewalRemaining(const Duration(seconds: -90)), '1m');
    });
  });
}
