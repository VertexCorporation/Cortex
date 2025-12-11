// lib/chat/services/review.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../darkener.dart';
import '../../notifications/introvert.dart';
import '../../theme.dart';

/// A service to manage showing the in-app review prompt to the user
/// at the optimal moment, without being intrusive.
class ReviewService {
  // SharedPreferences keys
  static const String _reviewCompletedKey = 'review_prompt_has_been_completed';
  static const String _lastPromptedKey = 'review_prompt_last_shown_timestamp';

  // App-specific constants
  final InAppReview _inAppReview = InAppReview.instance;

  // Cooldown duration
  static const Duration _promptCooldown = Duration(days: 3);

  /// A robust method to take the user to the store listing page.
  ///
  /// It first tries the `in_app_review` package's method. If that fails,
  /// it falls back to launching the Play Store URL directly.
  /// This ensures the user can always access the rating page.
  /// A robust method to take the user to the store listing page.
  ///
  /// It first tries the `in_app_review` package's method. If that fails,
  /// it falls back to launching the Play Store URL directly.
  /// This ensures the user can always access the rating page.
  Future<void> _launchStoreReview(BuildContext context) async {
    if (!context.mounted) return;

    final notificationService = Provider.of<IntrovertNotificationService>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;
    final platform = Theme.of(context).platform;

    debugPrint("[ReviewService] Starting platform-aware store review flow.");

    // Correct IDs for each platform.
    const String androidPackageName = "com.vertex.cortex";
    const String iosAppId = "6755621587";

    try {
      debugPrint("[ReviewService] Attempting to open store listing via in_app_review.");

      // Platform-aware native call
      if (platform == TargetPlatform.iOS) {
        await _inAppReview.openStoreListing(appStoreId: iosAppId);
      } else {
        await _inAppReview.openStoreListing(appStoreId: androidPackageName);
      }

      debugPrint("[ReviewService] openStoreListing succeeded.");
      return;

    } catch (e) {
      debugPrint("[ReviewService] openStoreListing failed: $e. Falling back to direct URL.");
    }

    // --- FALLBACK URL based on platform ---
    late final Uri url;

    if (platform== TargetPlatform.iOS) {
      url = Uri.parse("https://apps.apple.com/app/id$iosAppId");
    } else {
      url = Uri.parse("https://play.google.com/store/apps/details?id=$androidPackageName");
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      debugPrint("[ReviewService] Fallback URL succeeded.");
    } else {
      debugPrint("[ReviewService] Could not launch fallback URL: $url");
      notificationService.showNotification(
        message: localizations.anErrorOccurred,
        type: NotificationType.success,
      );
    }
  }

  /// The single entry point for the review logic.
  /// The single entry point for the review logic.
  Future<void> triggerReviewPromptIfNeeded(BuildContext context) async {
    // This initial check prevents us from even starting if the widget is already gone.
    if (!context.mounted) return;

    const bool isProduction = true; // Assuming this is your flag

    if (isProduction) {
      // --- PRODUCTION LOGIC ---
      try {
        // The async gap starts here.
        final prefs = await SharedPreferences.getInstance();

        // After the async gap, we can no longer trust the original 'context' directly.
        // However, the checks below do not use the context, so they are safe.
        if (prefs.getBool(_reviewCompletedKey) ?? false) {
          debugPrint("[ReviewService] Production: Flow completed. Skipping.");
          return;
        }
        final int? lastTs = prefs.getInt(_lastPromptedKey);
        if (lastTs != null && DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastTs)) < _promptCooldown) {
          debugPrint("[ReviewService] Production: In cooldown. Skipping.");
          return;
        }

        debugPrint("[ReviewService] Production: Conditions met. Showing prompt.");

        // This is the guard that the linter requires. It ensures that even after
        // waiting for SharedPreferences, the widget is still in the tree.
        if (!context.mounted) return;

        // Now, this call is guaranteed to be safe.
        await _showReviewPrePrompt(context: context, isProduction: true);

      } catch (e) {
        debugPrint("[ReviewService] Production: SharedPreferences check failed: $e");
      }
    }
  }

  /// Displays a friendly, custom dialog before showing the native review prompt.
  Future<void> _showReviewPrePrompt({
    required BuildContext context,
    required bool isProduction,
  }) async {
    // STEP 1: Capture all context-dependent variables BEFORE any awaits.
    if (!context.mounted) return;
    final localizations = AppLocalizations.of(context)!;

    if (isProduction) {
      try {
        // --- The First Async Gap ---
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_lastPromptedKey, DateTime.now().millisecondsSinceEpoch);
        debugPrint("[ReviewService] Production: Cooldown timestamp updated.");
      } catch (e) {
        debugPrint("[ReviewService] Production: Failed to update timestamp: $e");
      }
    }

    // STEP 2: Add a guard check AFTER the first async gap, right before using the context again.
    if (!context.mounted) return;

    // --- DYNAMIC STYLES ---
    final dialogBackgroundColor = AppColors.secondaryColor;
    final primaryTextColor = AppColors.primaryColor.inverted;
    final secondaryTextColor = AppColors.primaryColor.inverted.withValues(alpha:0.8);
    final borderColor = AppColors.border;
    final noThanksButtonColor = AppColors.septenaryColor;
    final laterButtonColor = AppColors.primaryColor.inverted.withValues(alpha:0.7);
    final rateButtonColor = AppColors.senaryColor;
    const double dialogMaxWidth = 340.0;

    final restoreNavBar = Darkener.darken();

    // --- The Second Async Gap ---
    await showGeneralDialog<void>(
      context: context, // This use is now safe.
      barrierLabel: 'ReviewPrompt',
      barrierDismissible: true,
      pageBuilder: (dialogCtx, _, __) {
        // `dialogCtx` is a new, valid context for the duration of this builder.
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: dialogMaxWidth),
              child: Container(
                decoration: BoxDecoration(
                  color: dialogBackgroundColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16),
                        child: Column(
                          children: [
                            Text(localizations.reviewEnjoyingAppTitle, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: primaryTextColor), textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            Text(localizations.reviewHelpUsGrow, style: TextStyle(fontSize: 14.0, color: secondaryTextColor, height: 1.4), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                      Divider(color: borderColor, thickness: 0.5, height: 0.5),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            // 1. "No, Thanks" Button
                            _buildDialogButton(
                              text: localizations.noThanks,
                              textColor: noThanksButtonColor,
                              onTap: () async {
                                debugPrint("[ReviewService] User selected 'No, Thanks'.");
                                if (isProduction) {
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setBool(_reviewCompletedKey, true);
                                }
                                // Guard usage of the dialog's context.
                                if (dialogCtx.mounted) {
                                  Navigator.of(dialogCtx).pop();
                                }
                              },
                            ),
                            VerticalDivider(color: borderColor, thickness: 0.5, width: 0.5),
                            // 2. "Maybe Later" Button
                            _buildDialogButton(
                              text: localizations.reviewMaybeLater,
                              textColor: laterButtonColor,
                              onTap: () {
                                debugPrint("[ReviewService] User selected 'Maybe Later'.");
                                Navigator.of(dialogCtx).pop();
                              },
                            ),
                            VerticalDivider(color: borderColor, thickness: 0.5, width: 0.5),
                            // 3. "Rate Now" Button
                            _buildDialogButton(
                              text: localizations.reviewRateNow,
                              textColor: rateButtonColor,
                              isBold: true,
                              onTap: () async {
                                debugPrint("[ReviewService] User selected 'Rate Now'.");

                                // First, close the custom dialog (safe to do without a check first).
                                Navigator.of(dialogCtx).pop();

                                if (isProduction) {
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setBool(_reviewCompletedKey, true);
                                }

                                // Guard usage of the original context.
                                if (context.mounted) {
                                  await _launchStoreReview(context);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    restoreNavBar();
  }

// Helper widget with updated parameters and splash color.
  Widget _buildDialogButton({
    required String text,
    required Color textColor,
    required VoidCallback onTap,
    bool isBold = false,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: textColor.withValues(alpha: 0.2),
          highlightColor: textColor.withValues(alpha: 0.1),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 16.0 * 3 * 1.2,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16.0,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}