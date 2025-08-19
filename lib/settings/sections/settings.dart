// section/settings.dart

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

import '../../webview.dart'; // For in-app WebView

/// A widget that displays the main settings section in the settings screen.
///
/// This section includes options like Help, Share App, Rate Us,
/// Terms of Use, Privacy Policy, and Copyrights.
/// It manages its own actions, such as launching URLs and showing modals.
class SettingsSection extends StatefulWidget {
  /// Contains the necessary strings for localization.
  final AppLocalizations appLocalizations;

  const SettingsSection({
    Key? key,
    required this.appLocalizations,
  }) : super(key: key);

  @override
  SettingsSectionState createState() => SettingsSectionState();
}

class SettingsSectionState extends State<SettingsSection> {
  // Method to get NotificationService, ensuring context is available.
  NotificationService _getNotificationService(BuildContext context) {
    return Provider.of<NotificationService>(context, listen: false);
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