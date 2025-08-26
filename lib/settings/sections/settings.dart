// section/settings.dart

import 'package:cloud_functions/cloud_functions.dart';
import 'package:cortex/main.dart';
import 'package:cortex/notifications.dart'; // For NotificationService
import 'package:cortex/theme.dart'; // For AppColors
import 'package:flutter/foundation.dart'; // For kDebugMode and Factory
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG icons
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import 'package:cortex/l10n/app_localizations.dart'; // For localization
import 'package:provider/provider.dart'; // To access NotificationService
import 'package:share_plus/share_plus.dart'; // For sharing functionality
import 'package:url_launcher/url_launcher.dart'; // For launching external URLs

import '../../darkener.dart';
import '../../login/login.dart';
import '../../webview.dart'; // For in-app WebView

/// A widget that displays the main settings section in the settings screen.
///
/// This section includes options like Help, Share App, Rate Us,
/// Terms of Use, Privacy Policy, and Copyrights.
/// It manages its own actions, such as launching URLs and showing modals.
class SettingsSection extends StatefulWidget {
  final AppLocalizations appLocalizations;
  final bool isDialogOpen;
  final ValueChanged<bool> onDialogStateChanged;
  final VoidCallback onDataNeedsRefresh;

  const SettingsSection({
    Key? key,
    required this.appLocalizations,
    required this.isDialogOpen,
    required this.onDialogStateChanged,
    required this.onDataNeedsRefresh,
  }) : super(key: key);

  @override
  SettingsSectionState createState() => SettingsSectionState();
}

class SettingsSectionState extends State<SettingsSection> with SingleTickerProviderStateMixin {
  // Method to get NotificationService, ensuring context is available.
  NotificationService _getNotificationService(BuildContext context) {
    return Provider.of<NotificationService>(context, listen: false);
  }

  late AnimationController _redeemCodeShakeController;

  @override
  void initState() {
    super.initState();
    const shakeDuration = Duration(milliseconds: 500);
    _redeemCodeShakeController = AnimationController(vsync: this, duration: shakeDuration);
  }

  @override
  void dispose() {
    _redeemCodeShakeController.dispose();
    super.dispose();
  }

  /// Launches the given URL in an external application (e.g., a browser).
  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri parsedUrl = Uri.parse(url);
    if (kDebugMode) {
      print('[SettingsSection] Attempting to launch URL: $url');
    }
    if (!await launchUrl(parsedUrl, mode: LaunchMode.externalApplication)) {
      if (kDebugMode) {
        print('[SettingsSection] Could not launch URL: $url');
      }
      if (mounted) {
        _getNotificationService(context).showNotification(
          message: widget.appLocalizations.anErrorOccurred,
          isSuccess: false,
          bottomOffset: 0.02,
        );
      }
    }
  }

  /// Launches the help center URL (Discord).
  void _launchHelp(BuildContext context) {
    if (kDebugMode) {
      print('[SettingsSection] Launching help.');
    }
    _launchURL(context, "https://discord.gg/sK53fypPBZ");
  }

  /// Triggers the native platform's sharing functionality.
  Future<void> _shareApp(BuildContext context) async {
    if (kDebugMode) {
      print('[SettingsSection] Sharing app.');
    }
    try {
      await Share.share(
        widget.appLocalizations.shareMessage,
        subject: widget.appLocalizations.shareSubject,
      );
    } catch (e) {
      if (kDebugMode) {
        print("[SettingsSection] Error sharing app: $e");
      }
      if (mounted) {
        _getNotificationService(context).showNotification(
          message: widget.appLocalizations.shareFailed,
          isSuccess: false,
          bottomOffset: 0.02,
        );
      }
    }
  }

  /// Launches the app store page for rating.
  void _launchRateUs(BuildContext context) {
    if (kDebugMode) {
      print('[SettingsSection] Launching rate us.');
    }
    _launchURL(context, "https://play.google.com/store/apps/details?id=com.vertex.cortex");
  }

  /// Displays the "Redeem Code" dialog and handles the server-side logic for creator code redemption.
  void _showRedeemCodeDialog(BuildContext context) {
    if (widget.isDialogOpen) return;
    widget.onDialogStateChanged(true);

    final redeemCodeController = TextEditingController();
    String? confirmError;
    bool isRedeeming = false; // Local state for the loading indicator
    final RestoreCallback restoreNavBar = Darkener.darken();
    // Get the functions instance once
    final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

    showGeneralDialog(
      context: context,
      barrierDismissible: !isRedeeming, // Prevent closing while loading
      barrierLabel: 'RedeemCodeDialogBarrier',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (dialogPageContext, animation, secondaryAnimation) {
        // Dynamic sizing variables...
        final screenWidth = MediaQuery.of(dialogPageContext).size.width;
        final screenHeight = MediaQuery.of(dialogPageContext).size.height;
        final double dialogWidth = screenWidth * 0.8;
        final double borderRadius = screenWidth * 0.03;
        final double contentPadding = screenWidth * 0.05;
        final double verticalSpacing = screenHeight * 0.015;
        final double inputSpacing = screenHeight * 0.025;
        final double buttonVerticalPadding = screenHeight * 0.02;
        final double titleFontSize = screenWidth * 0.045;
        final double bodyFontSize = screenWidth * 0.035;
        final double buttonFontSize = screenWidth * 0.04;

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: dialogWidth,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: SingleChildScrollView(
                  child: StatefulBuilder(
                    builder: (dialogContext, setDialogInnerState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(contentPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Title, Body, TextField... (remain the same)
                                Text(widget.appLocalizations.redeemCode, style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted), textAlign: TextAlign.center),
                                SizedBox(height: verticalSpacing),
                                Text(widget.appLocalizations.enterYourCode, style: TextStyle(color: AppColors.quinaryColor, fontSize: bodyFontSize), textAlign: TextAlign.center),
                                SizedBox(height: inputSpacing),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShakeWidget(
                                      controller: _redeemCodeShakeController,
                                      child: TextField(
                                        controller: redeemCodeController,
                                        autofocus: true,
                                        style: TextStyle(color: AppColors.primaryColor.inverted),
                                        decoration: InputDecoration(labelText: widget.appLocalizations.code, labelStyle: TextStyle(color: AppColors.primaryColor.inverted), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.quinaryColor), borderRadius: BorderRadius.circular(borderRadius)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor.inverted), borderRadius: BorderRadius.circular(borderRadius))),
                                      ),
                                    ),
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: confirmError != null ? Padding(padding: EdgeInsets.only(top: screenHeight * 0.01), child: Text(confirmError!, style: const TextStyle(color: Colors.red), key: ValueKey(confirmError))) : const SizedBox.shrink(key: ValueKey("emptyConfirmError")),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(color: AppColors.quinaryColor, thickness: 0.5, height: 1),
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: isRedeeming ? null : () => Navigator.of(dialogPageContext).pop(),
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding),
                                        child: Text(widget.appLocalizations.cancel, style: TextStyle(color: AppColors.quinaryColor, fontSize: buttonFontSize)),
                                      ),
                                    ),
                                  ),
                                ),
                                VerticalDivider(width: 1, thickness: 0.5, color: AppColors.quinaryColor),
                                Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      splashColor: AppColors.senaryColor.withOpacity(0.3),
                                      highlightColor: AppColors.senaryColor.withOpacity(0.1),
                                      onTap: isRedeeming ? null : () async {
                                        final code = redeemCodeController.text.trim();
                                        if (code.isEmpty) {
                                          setDialogInnerState(() => confirmError = widget.appLocalizations.codeCannotBeEmpty);
                                          _redeemCodeShakeController.forward(from: 0);
                                          return;
                                        }

                                        setDialogInnerState(() {
                                          isRedeeming = true;
                                          confirmError = null;
                                        });

                                        try {
                                          await functions.httpsCallable('redeemCreatorCode').call({'code': code});

                                          if (!dialogPageContext.mounted) return;
                                          Navigator.of(dialogPageContext).pop();

                                          _getNotificationService(context).showNotification(
                                              message: widget.appLocalizations.creatorSupportedSuccess,
                                              isSuccess: true,
                                              bottomOffset: 0.02
                                          );
                                          // --- REFRESH PARENT SCREEN DATA ---
                                          widget.onDataNeedsRefresh();

                                        } on FirebaseFunctionsException catch (e) {
                                          // Map server errors to user-friendly messages
                                          final String message = e.message ?? widget.appLocalizations.anErrorOccurred;
                                          setDialogInnerState(() => confirmError = message);
                                          _redeemCodeShakeController.forward(from: 0);
                                        } catch (e) {
                                          setDialogInnerState(() => confirmError = widget.appLocalizations.anErrorOccurred);
                                          _redeemCodeShakeController.forward(from: 0);
                                        } finally {
                                          // Ensure the loading state is always turned off
                                          setDialogInnerState(() => isRedeeming = false);
                                        }
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding),
                                        child: isRedeeming
                                            ? SizedBox(height: buttonFontSize, width: buttonFontSize, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.senaryColor))
                                            : Text(widget.appLocalizations.redeem, style: TextStyle(color: AppColors.senaryColor, fontSize: buttonFontSize, fontWeight: FontWeight.bold)),
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
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
    ).whenComplete(() {
      restoreNavBar();
      widget.onDialogStateChanged(false);
    });
  }

  /// Displays the "Terms of Use" page in a WebView modal.
  void _showTermsOfService(BuildContext context) {
    showAppWebViewModal(
      context,
      widget.appLocalizations.termsOfService,
      "https://vertexishere.com/cortex-terms-of-service",
    );
  }

  /// Displays the "Privacy Policy" page in a WebView modal.
  void _showPrivacyPolicy(BuildContext context) {
    showAppWebViewModal(
      context,
      widget.appLocalizations.privacyPolicy,
      "https://vertexishere.com/cortex-privacy-policy",
    );
  }

  /// Displays the "Copyrights and Attributions" page in a WebView modal.
  void _showCopyrights(BuildContext context) {
    showAppWebViewModal(
      context,
      widget.appLocalizations.copyrights,
      "https://vertexishere.com/cortex-attributions",
    );
  }

  /// Builds a styled button for a setting item.
  Widget _buildSettingsButton(
      BuildContext context,
      String text,
      Widget icon,
      VoidCallback onPressed,
      ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      color: AppColors.secondaryColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        splashColor: AppColors.primaryColor.inverted.withOpacity(0.1),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.02,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  icon,
                  SizedBox(width: screenWidth * 0.04),
                  Text(
                    text,
                    style: GoogleFonts.roboto(
                      color: AppColors.primaryColor.inverted,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primaryColor.inverted,
                size: screenWidth * 0.04,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a divider line used between settings buttons.
  Widget _buildDivider(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Divider(
      color: AppColors.quinaryColor.withOpacity(0.5),
      thickness: 0.5,
      height: 0.5,
      indent: screenWidth * 0.04,
      endIndent: screenWidth * 0.04,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (kDebugMode) {
      print('[SettingsSection] Building widget.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          widget.appLocalizations.settings,
          style: GoogleFonts.roboto(
            color: AppColors.primaryColor.inverted,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        // Section description
        Text(
          widget.appLocalizations.accessSettingsDescription,
          style: GoogleFonts.roboto(
            color: AppColors.quinaryColor,
            fontSize: screenWidth * 0.035,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        // Group of settings buttons with rounded corners for the whole group
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Column(
            children: [
              _buildSettingsButton(
                context,
                widget.appLocalizations.help,
                Icon(
                  Icons.help_outline,
                  color: AppColors.primaryColor.inverted,
                  size: screenWidth * 0.05,
                ),
                    () => _launchHelp(context),
              ),
              _buildDivider(context),
              _buildSettingsButton(
                context,
                widget.appLocalizations.shareApp,
                SvgPicture.asset(
                  'assets/icons/upload.svg',
                  width: screenWidth * 0.05,
                  height: screenWidth * 0.05,
                  colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
                ),
                    () => _shareApp(context),
              ),
              _buildDivider(context),
              _buildSettingsButton(
                context,
                widget.appLocalizations.rateUs,
                SvgPicture.asset(
                  'assets/icons/star.svg',
                  width: screenWidth * 0.05,
                  height: screenWidth * 0.05,
                  colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
                ),
                    () => _launchRateUs(context),
              ),
              _buildDivider(context),
              // --- NEW BUTTON ADDED HERE ---
              _buildSettingsButton(
                context,
                widget.appLocalizations.redeemCode, // Assuming 'redeemCode' is in your l10n file
                Icon(
                  Icons.card_giftcard, // A suitable icon for redeeming a code
                  color: AppColors.primaryColor.inverted,
                  size: screenWidth * 0.05,
                ),
                    () => _showRedeemCodeDialog(context),
              ),
              _buildDivider(context),
              _buildSettingsButton(
                context,
                widget.appLocalizations.termsOfService,
                Icon(
                  Icons.article_outlined,
                  color: AppColors.primaryColor.inverted,
                  size: screenWidth * 0.05,
                ),
                    () => _showTermsOfService(context),
              ),
              _buildDivider(context),
              _buildSettingsButton(
                context,
                widget.appLocalizations.privacyPolicy,
                Icon(
                  Icons.privacy_tip_outlined,
                  color: AppColors.primaryColor.inverted,
                  size: screenWidth * 0.05,
                ),
                    () => _showPrivacyPolicy(context),
              ),
              _buildDivider(context),
              _buildSettingsButton(
                context,
                widget.appLocalizations.copyrights,
                SvgPicture.asset(
                  'assets/icons/copyrights.svg',
                  width: screenWidth * 0.05,
                  height: screenWidth * 0.05,
                  colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
                ),
                    () => _showCopyrights(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}