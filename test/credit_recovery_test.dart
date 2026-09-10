// test/credit_recovery_test.dart
//
// Tests for the credit-limit conversational recovery: when a send fails with
// a typed server credit refusal, the chat is answered with ONE natural
// assistant message instead of an error bubble. The message starts as the
// canonical credit copy (what happened, when it renews, what to do) and is
// refined in place by a lightweight-model reply composed from structured
// facts only. The selector is a pure function over the client credit state,
// so every band/tier/fallback permutation is exercised without Firebase or
// SendService; the provider tests cover exactly-one-insertion and the
// refinement guards.
import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/services/send.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/server/credits.dart';
import 'package:cortex/server/subscription.dart';
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
  final renewalText = formatRenewalRemainingLocalized(renewal, loc);

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
      expect(message, contains('23 hours 14 minutes'));
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
      expect(message, isNot(contains('23 hours 14 minutes')));
    });
  });

  group('formatRenewalRemaining — compact facts-payload form (never UI)', () {
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

  group('formatRenewalRemainingLocalized — user-facing countdown words', () {
    test('words hours and minutes with grammatical plurals', () {
      expect(
        formatRenewalRemainingLocalized(
            const Duration(hours: 23, minutes: 14), loc),
        '23 hours 14 minutes',
      );
      expect(
        formatRenewalRemainingLocalized(
            const Duration(hours: 2, minutes: 14), loc),
        '2 hours 14 minutes',
      );
    });

    test('words lone units', () {
      expect(
        formatRenewalRemainingLocalized(const Duration(hours: 1), loc),
        '1 hour',
      );
      expect(
        formatRenewalRemainingLocalized(const Duration(hours: 5), loc),
        '5 hours',
      );
      expect(
        formatRenewalRemainingLocalized(const Duration(minutes: 1), loc),
        '1 minute',
      );
      expect(
        formatRenewalRemainingLocalized(const Duration(minutes: 47), loc),
        '47 minutes',
      );
    });

    test('never counts below one minute', () {
      expect(
        formatRenewalRemainingLocalized(Duration.zero, loc),
        '1 minute',
      );
      expect(
        formatRenewalRemainingLocalized(const Duration(seconds: 30), loc),
        '1 minute',
      );
      expect(
        formatRenewalRemainingLocalized(const Duration(seconds: -90), loc),
        '1 minute',
      );
    });

    test('every supported locale words the countdown, never abbreviates',
        () async {
      // The user-facing contract holds in all 20 locales: fully worded,
      // grammatically pluralized, never "4m"-style abbreviations.
      final durations = [
        const Duration(minutes: 4),
        const Duration(hours: 1),
        const Duration(hours: 2, minutes: 14),
        const Duration(hours: 23, minutes: 59),
      ];
      for (final locale in AppLocalizations.supportedLocales) {
        final localeLoc = await AppLocalizations.delegate.load(locale);
        for (final remaining in durations) {
          final text = formatRenewalRemainingLocalized(remaining, localeLoc);
          expect(text, isNotEmpty,
              reason: 'locale ${locale.languageCode} must word the countdown');
          // No digit may trail into a bare h/m token in any locale (an
          // h/m followed by more letters is a real word like "minutes"):
          // that is exactly the abbreviation this feature replaces.
          expect(RegExp(r'\d\s*[hHmM](?![a-zA-Z])').hasMatch(text), isFalse,
              reason:
                  "locale ${locale.languageCode} must not abbreviate: '$text'");
        }
      }
    });
  });

  group('CreditsManager briefing dismissals — app-session-wide cooldown',
      () {
    final manager = CreditsManager.instance;

    setUp(manager.debugResetCreditBriefingDismissals);

    test('a dismissal suppresses the same kind for two hours', () {
      expect(manager.isCreditBriefingSuppressed('freeDeclining'), isFalse);
      manager.dismissCreditBriefing('freeDeclining');
      expect(manager.isCreditBriefingSuppressed('freeDeclining'), isTrue);
      // One hour in: still inside the window.
      manager.debugAgeCreditBriefingDismissals(const Duration(hours: 1));
      expect(manager.isCreditBriefingSuppressed('freeDeclining'), isTrue);
      // Past two hours: eligible again on the next ordinary evaluation.
      manager.debugAgeCreditBriefingDismissals(
          const Duration(hours: 1, minutes: 1));
      expect(manager.isCreditBriefingSuppressed('freeDeclining'), isFalse);
    });

    test("a different kind never inherits another kind's dismissal", () {
      manager.dismissCreditBriefing('freeDeclining');
      expect(manager.isCreditBriefingSuppressed('exhausted'), isFalse);
    });

    test('only a genuinely healthy observed balance clears the records', () {
      manager.dismissCreditBriefing('exhausted');
      // Snapshot gap (unknown balance): must never look like recovery.
      manager.observeCreditBriefingState(
          credits: null, debtFloor: _debtFloor);
      expect(manager.isCreditBriefingSuppressed('exhausted'), isTrue);
      // Declining band: a warning briefing would still resolve.
      manager.observeCreditBriefingState(credits: 0, debtFloor: _debtFloor);
      expect(manager.isCreditBriefingSuppressed('exhausted'), isTrue);
      // At the debt floor: the exhausted briefing itself would resolve.
      manager.observeCreditBriefingState(
          credits: _debtFloor, debtFloor: _debtFloor);
      expect(manager.isCreditBriefingSuppressed('exhausted'), isTrue);
      // Known healthy balance: every warning band is left behind.
      manager.observeCreditBriefingState(credits: 25, debtFloor: _debtFloor);
      expect(manager.isCreditBriefingSuppressed('exhausted'), isFalse);
    });

    test('dispose ends the session: the next one starts with no records',
        () {
      manager.dismissCreditBriefing('freeDeclining');
      expect(manager.isCreditBriefingSuppressed('freeDeclining'), isTrue);
      manager.dispose();
      expect(manager.isCreditBriefingSuppressed('freeDeclining'), isFalse);
    });
  });

  group('CreditLimits.operationCosts — server-published pricing', () {
    test('parses the operationCosts map from a creditLimits document', () {
      final limits = CreditLimits.fromData({
        'dailyGrant': 100,
        'debtFloor': -100,
        'operationCosts': {
          'image': 100,
          'video': 1000,
          'music': 500,
          'speech': 100,
          'easy': 10,
        },
      });
      expect(limits.dailyGrant, 100);
      expect(limits.debtFloor, -100);
      expect(limits.operationCosts['image'], 100);
      expect(limits.operationCosts['video'], 1000);
      expect(limits.operationCosts['speech'], 100);
      expect(limits.operationCosts['easy'], 10);
    });

    test('missing or malformed operationCosts resolve to an empty map', () {
      expect(
        CreditLimits.fromData({'dailyGrant': 100, 'debtFloor': -100})
            .operationCosts,
        isEmpty,
      );
      expect(CreditLimits.fromData(null).operationCosts, isEmpty);
      expect(CreditLimits.fallback.operationCosts, isEmpty);
      // Non-integer costs are dropped rather than crashing the parse.
      expect(
        CreditLimits.fromData({
          'dailyGrant': 100,
          'debtFloor': -100,
          'operationCosts': {'image': 'lots'},
        }).operationCosts,
        isEmpty,
      );
    });
  });

  group('CreditsManager.canGenerate — per-operation affordability gate', () {
    final manager = CreditsManager.instance;
    const costs = {'image': 100, 'video': 1000, 'speech': 100};

    setUp(() {
      manager.debugSetCreditLimits(const CreditLimits(
        dailyGrant: 100,
        debtFloor: -100,
        operationCosts: costs,
      ));
      manager.spendableNotifier.value = null;
      manager.accessNotifier.value = CreditAccess.full;
    });

    test('published cost is read per lane (audio → speech lane)', () {
      expect(manager.defaultCostFor('image'), 100);
      expect(manager.defaultCostFor('video'), 1000);
      expect(manager.defaultCostFor('speech'), 100);
      expect(manager.defaultCostFor('unknown'), isNull);
    });

    test('fail-open without a balance snapshot (server stays the gate)', () {
      manager.spendableNotifier.value = null;
      expect(manager.canGenerate('video'), isTrue);
    });

    test('affordability keeps the balance at or above the debt floor', () {
      manager.spendableNotifier.value = 150;
      // 150 - 100 = 50, well above the -100 floor.
      expect(manager.canGenerate('image'), isTrue);
      // 150 - 1000 = -850, below the floor: the server would refuse or
      // overdraw, so the sheet/greeting routes to Funds instead.
      expect(manager.canGenerate('video'), isFalse);
    });

    test('blocked band refuses regardless of the balance', () {
      manager.spendableNotifier.value = 5000;
      manager.accessNotifier.value = CreditAccess.blocked;
      expect(manager.canGenerate('image'), isFalse);
    });

    test('unknown lane fails open (server still enforces the real cost)', () {
      manager.spendableNotifier.value = 5;
      // 'music' is absent from the published snapshot in this group.
      expect(manager.canGenerate('music'), isTrue);
    });
  });

  group('ConversationProvider credit recovery — one natural assistant message',
      () {
    test('inserts exactly one plain assistant reply with the user turn', () {
      final provider = ConversationProvider();
      final index = provider.showCreditRecovery(
        Message(text: 'draw me a cat', isUserMessage: true),
        'You have run out of credits today.',
      );
      expect(index, isNotNull);
      expect(provider.messages.length, 2);
      expect(provider.messages.first.isUserMessage, isTrue);
      expect(provider.messages[index!].isUserMessage, isFalse);
      expect(provider.messages[index].isError, isFalse);
      expect(provider.messages[index].isThinking, isFalse);
      // A recovery reply is a real conversational turn: it stays in context
      // and is not styled as an error.
      expect(provider.messages[index].includeInContext, isTrue);
      expect(
          provider.messages[index].text, 'You have run out of credits today.');
    });

    test('converts an in-flight thinking bubble instead of duplicating', () {
      final provider = ConversationProvider();
      provider.appendBackgroundRestoredMessage(
          Message(text: '', isUserMessage: false, isThinking: true));
      final index = provider.showCreditRecovery(
        Message(text: 'hi', isUserMessage: true),
        'out of credits',
      );
      // The thinking bubble became the recovery reply; no duplicate pair.
      expect(provider.messages.length, 1);
      expect(provider.messages[index!].isThinking, isFalse);
      expect(provider.messages[index].isError, isFalse);
      expect(provider.messages[index].text, 'out of credits');
    });

    test('refinement replaces the text; stale refinements are dropped', () {
      final provider = ConversationProvider();
      final index = provider.showCreditRecovery(
        Message(text: 'hi', isUserMessage: true),
        'deterministic copy',
      )!;
      provider.updateCreditRecoveryText(index, 'natural reply');
      expect(provider.messages[index].text, 'natural reply');

      // Out-of-range, unchanged and cross-conversation refinements are all
      // dropped silently — a late reply after a conversation switch must
      // never corrupt the active chat.
      provider.updateCreditRecoveryText(index + 5, 'x');
      provider.updateCreditRecoveryText(index, 'natural reply');
      provider.updateCreditRecoveryText(
        index,
        'other conversation',
        expectedConversationId: 'conv-1',
      );
      expect(provider.messages[index].text, 'natural reply');
      expect(provider.messages.length, 2);
    });

    test('unrelated errors remain error bubbles', () {
      final provider = ConversationProvider();
      provider.showSendError(
        Message(text: 'hi', isUserMessage: true),
        'generic failure',
        false,
      );
      expect(provider.messages.length, 2);
      expect(provider.messages.last.isError, isTrue);
      expect(provider.messages.last.includeInContext, isFalse);
      expect(provider.messages.last.text, 'generic failure');
    });
  });
}
