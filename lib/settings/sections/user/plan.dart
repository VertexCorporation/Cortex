part of '../user.dart';

/// A shiny, premium button for managing the subscription plan.
/// The design remains IDENTICAL for all users (Premium styling).
/// The only difference is the "Shine" effect, which is exclusive to non-subscribed users.
class _MyPlanButton extends StatefulWidget {
  const _MyPlanButton();

  @override
  State<_MyPlanButton> createState() => _MyPlanButtonState();
}

class _MyPlanButtonState extends State<_MyPlanButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shineController;
  late final Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    // 1 second active animation duration
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Sweep from left (-1.5) to right (1.5)
    _shineAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    // Loop logic: Play -> Wait 1s -> Play again
    _shineController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _shineController.forward(from: 0.0);
          }
        });
      }
    });

    // Initial start delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _shineController.forward();
    });
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final appLocalizations = AppLocalizations.of(context)!;

    return Consumer<FundsBackend>(
      builder: (context, backend, child) {
        // Level 0 implies "Free" or "No Active Plan".
        final isFreeUser = backend.currentUserSubscriptionLevel == 0;

        // Resource management:
        // 1. If user is Premium, STOP the animation immediately to save resources.
        if (!isFreeUser && _shineController.isAnimating) {
          _shineController.stop();
        }
        // 2. If user is Free and animation stopped unexpectedly (not just waiting), restart it.
        else if (isFreeUser &&
            !_shineController.isAnimating &&
            _shineController.status != AnimationStatus.completed) {
          _shineController.forward();
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              navigateToScreen(const FundsScreen(),
                  direction: const Offset(1.0, 0.0));
            },
            borderRadius: BorderRadius.circular(10.0),
            child: Stack(
              children: [
                // 1. BASE CONTAINER (Identical visual for ALL users)
                // This ensures the button always looks "Premium"
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenWidth * 0.045),
                  decoration: BoxDecoration(
                    // Unified background color
                    color: AppColors.premium.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.0),
                    // Unified border
                    border: Border.all(
                      color: AppColors.premium,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appLocalizations.myPlan,
                        style: TextStyle(
                          color: AppColors.primaryColor.inverted,
                          fontSize: screenWidth * 0.041,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.primaryColor.inverted,
                        size: screenWidth * 0.04,
                      ),
                    ],
                  ),
                ),

                // 2. SHINE OVERLAY (Visible ONLY to Free users)
                if (isFreeUser)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: AnimatedBuilder(
                        animation: _shineAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                                screenWidth * _shineAnimation.value, 0.0),
                            child: child,
                          );
                        },
                        child: Container(
                          width: screenWidth * 0.4, // Width of the light beam
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.4),
                                // Intense shine
                                Colors.white.withValues(alpha: 0.0),
                              ],
                              stops: const [0.1, 0.5, 0.9],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
