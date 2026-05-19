// lib/settings/sections/settings.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../app.dart';
import '../../darkener.dart';
import '../../l10n/app_localizations.dart';
import '../../notifications/introvert.dart';
import '../../shake.dart';
import '../../theme.dart';
import '../../webview.dart';
import '../providers/general.dart';
import '../providers/actions.dart';
import 'package:cortex/invite.dart';
import 'package:cortex/meet.dart';


/// A widget that displays the main settings and information section.
///
/// This component provides access to informational pages (Help, ToS, Privacy),
/// app-related actions (Share, Rate), and user actions like redeeming a code.
/// It delegates complex stateful actions to providers and manages its own
/// local UI state, like animation controllers for dialogs.
class SettingsSection extends StatefulWidget {
  const SettingsSection({super.key});

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection>
    with TickerProviderStateMixin {
  late final AnimationController _redeemCodeShakeController;

  @override
  void initState() {
    super.initState();
    _redeemCodeShakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _redeemCodeShakeController.dispose();
    super.dispose();
  }

  /// Launches the given URL in an external application.
  Future<void> _launchURL(BuildContext context, String url) async {
    final notificationService = context.read<IntrovertNotificationService>();
    final appLocalizations = AppLocalizations.of(context)!;
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      notificationService.showNotification(
          message: appLocalizations.anErrorOccurred,
          type: NotificationType.error);
    }
  }

  /// Displays the "Redeem Code" dialog, driven by `SettingsActionProvider`.
  Future<void> _showRedeemCodeDialog(BuildContext context) async {
    // Guard against async gaps: Get providers and localizations before the dialog.
    final actionProvider = context.read<SettingsActionProvider>();
    final generalProvider = context.read<SettingsGeneralProvider>();
    final appLocalizations = AppLocalizations.of(context)!;

    final codeController = TextEditingController();
    String? errorText;
    final RestoreCallback restoreNavBar = Darkener.darken();

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'RedeemCodeDialog',
      pageBuilder: (ctx, _, __) {
        final screenWidth = MediaQuery
            .of(ctx)
            .size
            .width;
        final keyboardPadding = MediaQuery
            .of(ctx)
            .viewInsets
            .bottom;

        return AnimatedPadding(
          padding: EdgeInsets.only(bottom: keyboardPadding),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: Center(
            child: SingleChildScrollView(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: screenWidth * 0.8,
                  decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Consumer<SettingsActionProvider>(
                      builder: (context, provider, child) {
                        final isRedeeming = provider.isRedeemingCode;
                        return StatefulBuilder(
                          builder: (dialogContext, setDialogInnerState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.05),
                                  child: Column(
                                    children: [
                                      Text(appLocalizations.creatorTag,
                                          style: TextStyle(
                                              fontSize: screenWidth * 0.045,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors
                                                  .primaryColor.inverted),
                                          textAlign: TextAlign.center),
                                      SizedBox(height: screenWidth * 0.03),
                                      Text(appLocalizations.enterYourTag,
                                          style: TextStyle(
                                              color: AppColors.quinaryColor,
                                              fontSize: screenWidth * 0.035),
                                          textAlign: TextAlign.center),
                                      SizedBox(height: screenWidth * 0.05),
                                      ShakeWidget(
                                        controller: _redeemCodeShakeController,
                                        child: TextField(
                                          controller: codeController,
                                          autofocus: true,
                                          style: TextStyle(
                                              color: AppColors
                                                  .primaryColor.inverted,
                                              fontSize: screenWidth * 0.04),
                                          decoration: InputDecoration(
                                            labelText: appLocalizations.support,
                                            labelStyle: TextStyle(
                                                color: AppColors
                                                    .primaryColor.inverted),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color:
                                                    AppColors.quinaryColor),
                                                borderRadius:
                                                BorderRadius.circular(
                                                    10.0)),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: AppColors
                                                        .primaryColor.inverted),
                                                borderRadius:
                                                BorderRadius.circular(
                                                    10.0)),
                                          ),
                                        ),
                                      ),
                                      AnimatedSwitcher(
                                        duration:
                                        const Duration(milliseconds: 300),
                                        child: errorText != null
                                            ? Padding(
                                            padding: EdgeInsets.only(
                                                top: screenWidth * 0.02),
                                            child: Text(errorText!,
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize:
                                                    screenWidth * 0.03),
                                                key: ValueKey(errorText)))
                                            : const SizedBox.shrink(
                                            key: ValueKey("emptyError")),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                    color: AppColors.quinaryColor,
                                    thickness: 0.5,
                                    height: 1),
                                IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                              onTap: isRedeeming
                                                  ? null
                                                  : () {
                                                HapticFeedback
                                                    .lightImpact();
                                                Navigator.of(ctx).pop();
                                              },
                                              splashColor: AppColors
                                                  .septenaryColor
                                                  .withValues(alpha: 0.1),
                                              highlightColor: AppColors
                                                  .septenaryColor
                                                  .withValues(alpha: 0.1),
                                              child: Container(
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical:
                                                      screenWidth * 0.04),
                                                  child: Text(
                                                      appLocalizations.cancel,
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .septenaryColor,
                                                          fontSize:
                                                          screenWidth *
                                                              0.04)))),
                                        ),
                                      ),
                                      VerticalDivider(
                                          width: 1,
                                          thickness: 0.5,
                                          color: AppColors.quinaryColor),
                                      Expanded(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            splashColor: AppColors.senaryColor
                                                .withValues(alpha: 0.1),
                                            highlightColor: AppColors
                                                .senaryColor
                                                .withValues(alpha: 0.1),
                                            onTap: isRedeeming
                                                ? null
                                                : () async {
                                              HapticFeedback
                                                  .lightImpact();
                                              final code = codeController
                                                  .text
                                                  .trim();

                                              if (code.isEmpty) {
                                                if (ctx.mounted) {
                                                  setDialogInnerState(
                                                          () =>
                                                      errorText =
                                                          appLocalizations
                                                              .tagCannotBeEmpty);
                                                  _redeemCodeShakeController
                                                      .forward(from: 0);
                                                }
                                                return;
                                              }

                                              try {
                                                await actionProvider
                                                    .redeemCode(
                                                    ctx, code);
                                                await generalProvider
                                                    .refreshData();

                                                if (ctx.mounted) {
                                                  Navigator.of(ctx).pop();
                                                }
                                              } catch (e) {
                                                if (ctx.mounted) {
                                                  setDialogInnerState(
                                                          () =>
                                                      errorText =
                                                          e.toString());
                                                  _redeemCodeShakeController
                                                      .forward(from: 0);
                                                }
                                              }
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: screenWidth * 0.04),
                                              child: isRedeeming
                                                  ? SizedBox(
                                                  width: screenWidth * 0.05,
                                                  height:
                                                  screenWidth * 0.05,
                                                  child:
                                                  CircularProgressIndicator(
                                                      strokeWidth: 2.0,
                                                      color: AppColors
                                                          .senaryColor))
                                                  : Text(
                                                  appLocalizations.support,
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .senaryColor,
                                                      fontSize:
                                                      screenWidth *
                                                          0.04,
                                                      fontWeight:
                                                      FontWeight.bold)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      restoreNavBar();
    });
  }

  /// Displays a page in a WebView modal.
  void _showWebView(BuildContext context, String title, String url) {
    showAppWebViewModal(context, title, url);
  }

  /// Builds a styled button for a setting item.
  Widget _buildSettingsButton(BuildContext context,
      {required String text,
        required Widget icon,
        required VoidCallback onPressed}) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Material(
      color: AppColors.secondaryColor,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        splashColor: AppColors.primaryColor.inverted.withValues(alpha: 0.1),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04, vertical: screenWidth * 0.045),
          child: Row(
            children: [
              icon,
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                  child: Text(text,
                      style: TextStyle(
                          color: AppColors.primaryColor.inverted,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w500))),
              Icon(Icons.arrow_forward_ios,
                  color: AppColors.primaryColor.inverted,
                  size: screenWidth * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a divider line used between settings buttons.
  Widget _buildDivider(double screenWidth) {
    return Divider(
        color: AppColors.quinaryColor.withValues(alpha: 0.5),
        thickness: 0.5,
        height: 0.5,
        indent: screenWidth * 0.04,
        endIndent: screenWidth * 0.04);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final appLocalizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    final List<Map<String, dynamic>> settingsButtons = [
      {
        'key': 'help',
        'icon': Icons.help,
        'action': () => _launchURL(context, "https://discord.gg/sK53fypPBZ")
      },
      {
        'key': 'shareApp',
        'icon': 'assets/icons/world.svg',
        'action': () =>
            InviteService().createAndShareReferralLink(context)
      },
      {
        'key': 'ourStory',
        'icon': 'assets/cortex.svg',
        'action': () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
              const OnboardingScreen(isStoryMode: true),
              transitionDuration: const Duration(milliseconds: 500),
              reverseTransitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      },
      {
        'key': 'rateUs',
        'icon': 'assets/icons/on/star.svg',
        'action': () =>
            _launchURL(context,
                "https://play.google.com/store/apps/details?id=com.vertex.cortex")
      },
      {
        'key': 'redeemCode',
        'icon': Icons.redeem,
        'action': () => _showRedeemCodeDialog(context)
      },
      {
        'key': 'termsOfService',
        'icon': Icons.article,
        'action': () =>
            _showWebView(context, appLocalizations.termsOfService,
                "https://vertexishere.com/cortex-terms-of-service")
      },
      {
        'key': 'privacyPolicy',
        'icon': Icons.privacy_tip,
        'action': () =>
            _showWebView(context, appLocalizations.privacyPolicy,
                "https://vertexishere.com/cortex-privacy-policy")
      },
      {
        'key': 'copyrights',
        'icon': 'assets/icons/copyrights.svg',
        'action': () =>
            _showWebView(context, appLocalizations.copyrights,
                "https://vertexishere.com/cortex-attributions")
      },
    ];

    String getLocalizedText(String key) {
      switch (key) {
        case 'help':
          return appLocalizations.help;
        case 'shareApp':
          return appLocalizations.shareApp;
        case 'ourStory':
          return appLocalizations.ourStory;
        case 'rateUs':
          return appLocalizations.rateUs;
        case 'redeemCode':
          return appLocalizations.supportCreator;
        case 'termsOfService':
          return appLocalizations.termsOfService;
        case 'privacyPolicy':
          return appLocalizations.privacyPolicy;
        case 'copyrights':
          return appLocalizations.copyrights;
        default:
          return '';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.settings,
          style: TextStyle(
              color: AppColors.primaryColor.inverted,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          appLocalizations.accessSettingsDescription,
          style: TextStyle(
              color: AppColors.quinaryColor, fontSize: screenWidth * 0.035),
        ),
        SizedBox(height: screenHeight * 0.02),
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Column(
            children: List.generate(settingsButtons.length, (index) {
              final item = settingsButtons[index];
              final key = item['key'] as String;

              if (key == 'shareApp') {
                return Column(children: [
                  _PremiumButton(
                    text: getLocalizedText(key),
                    iconPath: item['icon'],
                    hasBorder: false,
                    borderRadius: 0,
                    onPressed: item['action'],
                  ),
                  if (index < settingsButtons.length - 1)
                    _buildDivider(screenWidth),
                ]);
              }

              final iconData = item['icon'];
              Widget iconWidget;
              if (iconData is IconData) {
                iconWidget = Icon(iconData,
                    color: AppColors.primaryColor.inverted,
                    size: screenWidth * 0.05);
              } else if (iconData is String && iconData.endsWith('.svg')) {
                iconWidget = SvgPicture.asset(iconData,
                    width: screenWidth * 0.05,
                    colorFilter: ColorFilter.mode(
                        AppColors.primaryColor.inverted, BlendMode.srcIn));
              } else {
                iconWidget = const SizedBox.shrink();
              }

              return Column(
                children: [
                  _buildSettingsButton(
                    context,
                    text: getLocalizedText(item['key']),
                    icon: iconWidget,
                    onPressed: item['action'],
                  ),
                  if (index < settingsButtons.length - 1)
                    _buildDivider(screenWidth),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _PremiumButton extends StatefulWidget {
  final String text;
  final String iconPath;
  final bool hasBorder;
  final double borderRadius;
  final VoidCallback onPressed;

  const _PremiumButton({
    required this.text,
    required this.onPressed,
    this.iconPath = 'assets/icons/sparkle.svg',
    this.hasBorder = true,
    this.borderRadius = 10.0,
  });

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton>
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
    // If not animating for some reason (and not completed waiting), force start
    if (!_shineController.isAnimating &&
        _shineController.status != AnimationStatus.completed) {
      _shineController.forward();
    }

    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onPressed();
        },
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Stack(
          children: [
            // 1. BASE CONTAINER
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenWidth * 0.045),
              decoration: BoxDecoration(
                // Unified background color
                color: AppColors.premium.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                // Unified border
                border: widget.hasBorder
                    ? Border.all(
                  color: AppColors.premium,
                  width: 1,
                )
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        widget.iconPath,
                        width: screenWidth * 0.05,
                        colorFilter: ColorFilter.mode(
                            AppColors.premium, BlendMode.srcIn),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: AppColors.premium, // Premium Gold Text
                          fontSize: screenWidth * 0.041,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.premium,
                    size: screenWidth * 0.04,
                  ),
                ],
              ),
            ),

            // 2. SHINE OVERLAY
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: AnimatedBuilder(
                  animation: _shineAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(screenWidth * _shineAnimation.value, 0.0),
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
  }
}
