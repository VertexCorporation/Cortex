import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cortex/app.dart';
import 'package:cortex/funds/funds.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/navigation.dart';
import 'package:cortex/server/credits.dart';
import 'package:cortex/server/subscription.dart';
import 'package:cortex/server/user.dart';
import 'package:cortex/theme.dart';

class CreditWarningPanel extends StatelessWidget {
  const CreditWarningPanel({super.key});
  @override
  Widget build(BuildContext context) {
    final mgr = context.read<CreditsManager>();
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<int?>(
      valueListenable: mgr.totalCreditsNotifier,
      builder: (context, total, _) {
        final user = context.watch<UserProvider>();
        final tier = user.subscription.effectiveTier;
        final c = total ?? 0;
        if (c >= 0) return const SizedBox.shrink(key: ValueKey('cw_e'));
        final isFree = tier == SubscriptionTier.free;
        final isUltra = tier == SubscriptionTier.ultra;
        late final String t, m;
        late final bool premium;
        late final VoidCallback? tap;
        if (isUltra) {
          t = l10n.creditWarningUltraTitle;
          m = l10n.creditWarningUltraMessage;
          premium = false;
          tap = null;
        } else if (isFree) {
          if (c <= user.creditLimits.debtFloor) {
            t = l10n.creditWarningFreeExhaustedTitle;
            m = l10n.creditWarningFreeExhaustedMessage;
          } else {
            t = l10n.creditWarningFreeDecliningTitle;
            m = l10n.creditWarningFreeDecliningMessage;
          }
          premium = true;
          tap = () => navigateToScreen(const FundsScreen(), direction: const Offset(1.0, 0.0));
        } else {
          final n = _next(tier);
          t = l10n.creditWarningPaidUpgradeTitle;
          m = l10n.creditWarningPaidUpgradeMessage;
          premium = true;
          tap = () => navigateToScreen(FundsScreen(initialPlanType: n), direction: const Offset(1.0, 0.0));
        }
        return _P(
          key: ValueKey('cw_${tier.value}_$c'),
          title: t, msg: m, premium: premium, tap: tap,
        );
      },
    );
  }
  String _next(SubscriptionTier t) => switch (t) {
    SubscriptionTier.free => 'plus',
    SubscriptionTier.plus => 'pro',
    SubscriptionTier.pro => 'ultra',
    SubscriptionTier.ultra => 'ultra',
  };
}
class _P extends StatelessWidget {
  final String title;
  final String msg;
  final bool premium;
  final VoidCallback? tap;
  const _P({super.key, required this.title, required this.msg, required this.premium, this.tap});
  @override
  Widget build(BuildContext context) {
    final base = AppColors.premium.withValues(alpha: 0.15);
    final bg = premium ? Color.alphaBlend(base, AppColors.background) : AppColors.background;
    final fg = premium ? AppColors.premium : AppColors.primaryColor.inverted;
    final border = premium ? base.withValues(alpha: 0.8) : AppColors.border;
    Widget w = Container(
      margin: const EdgeInsets.fromLTRB(16,0,16,8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: tap,
            splashColor: fg.withValues(alpha: 0.08),
            highlightColor: fg.withValues(alpha: 0.04),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(children: [
                if (premium) ...[
                  SvgPicture.asset('assets/icons/sparkle.svg', width: 18, height: 18, colorFilter: ColorFilter.mode(fg, BlendMode.srcIn)),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg, height: 1.2)),
                    const SizedBox(height: 2),
                    Text(msg, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w400, color: fg.withValues(alpha: 0.85), height: 1.3)),
                  ]),
                ),
                if (tap != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: fg.withValues(alpha: 0.7)),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
    if (premium) {
      w = Shimmer.fromColors(
        baseColor: fg.withValues(alpha: 0.38),
        highlightColor: fg.withValues(alpha: 0.90),
        period: const Duration(milliseconds: 1250),
        child: w,
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (c, a) => SizeTransition(sizeFactor: a, child: FadeTransition(opacity: a, child: c)),
      child: w,
    );
  }
}

