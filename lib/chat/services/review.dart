// lib/chat/services/review.dart

import 'package:cortex/main.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart'; // ADDED: For URL fallback

import '../../darkener.dart';
import '../../notifications.dart';
import '../../theme.dart';

/// A service to manage showing the in-app review prompt to the user
/// at the optimal moment, without being intrusive.
class ReviewService {
  // SharedPreferences keys
  static const String _reviewCompletedKey = 'review_prompt_has_been_completed';
  static const String _lastPromptedKey = 'review_prompt_last_shown_timestamp';

  // App-specific constants
  static const String _appStoreId = 'com.vertex.cortex';
  final InAppReview _inAppReview = InAppReview.instance;

  // Cooldown duration
  static const Duration _promptCooldown = Duration(days: 3);

  // --- NEW ROBUST METHOD WITH FALLBACK ---
  /// A robust method to take the user to the store listing page.
  ///
  /// It first tries the `in_app_review` package's method. If that fails,
  /// it falls back to launching the Play Store URL directly.
  /// This ensures the user can always access the rating page.
  Future<void> _launchStoreReview(BuildContext context) async {
    // We need context to show notifications in case of complete failure.
    if (!context.mounted) return;
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

    debugPrint("[ReviewService] Starting robust store review flow.");

    try {
      // --- METHOD 1: PREFERRED ---
      // Use the dedicated package function to open the store listing.
      debugPrint("[ReviewService] Attempting to open store listing via in_app_review package.");
      await _inAppReview.openStoreListing(appStoreId: _appStoreId);
      debugPrint("[ReviewService] Method 1 (openStoreListing) succeeded.");
    } catch (e) {
      // --- METHOD 2: FALLBACK ---
      // If the primary method fails, launch the URL directly.
      debugPrint("[ReviewService] Method 1 failed: $e. Falling back to URL launcher.");
      final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=$_appStoreId');

      if (await canLaunchUrl(url)) {
        // This will try to open the Play Store app or a browser as a last resort.
        await launchUrl(url, mode: LaunchMode.externalApplication);
        debugPrint("[ReviewService] Method 2 (URL Launcher) succeeded.");
      } else {
        // --- FINAL RESORT: ERROR MESSAGE ---
        // If nothing works, inform the user.
        debugPrint("[ReviewService] Could not launch URL: $url");
        notificationService.showNotification(
          message: localizations.anErrorOccurred,
          isSuccess: false,
        );
      }
    }
  }

  /// The single entry point for the review logic.
  Future<void> triggerReviewPromptIfNeeded(BuildContext context) async {
    if (!context.mounted) return;

    const bool isProduction = true;

    if (isProduction) {
      // --- PRODUCTION LOGIC ---
      try {
        final prefs = await SharedPreferences.getInstance();
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
        await _showReviewPrePrompt(context: context, isProduction: true);
      } catch (e) {
        debugPrint("[ReviewService] Production: SharedPreferences check failed: $e");
      }
    } else {
      // --- TESTING LOGIC ---
      debugPrint("[ReviewService] Testing: Forcing review prompt to show.");
      await _showReviewPrePrompt(context: context, isProduction: false);
    }
  }

  /// Displays a friendly, custom dialog before showing the native review prompt.
  Future<void> _showReviewPrePrompt({
    required BuildContext context,
    required bool isProduction,
  }) async {
    if (!context.mounted) return;

    final localizations = AppLocalizations.of(context)!;

    if (isProduction) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_lastPromptedKey, DateTime.now().millisecondsSinceEpoch);
        debugPrint("[ReviewService] Production: Cooldown timestamp updated.");
      } catch (e) {
        debugPrint("[ReviewService] Production: Failed to update timestamp: $e");
      }
    }

    // --- DYNAMIC STYLES ---
    final dialogBackgroundColor = AppColors.secondaryColor;
    final primaryTextColor = AppColors.primaryColor.inverted;
    final secondaryTextColor = AppColors.primaryColor.inverted.withOpacity(0.8);
    final borderColor = AppColors.border;

    // --- BUTTON COLORS ---
    final noThanksButtonColor = AppColors.septenaryColor;
    final laterButtonColor = AppColors.primaryColor.inverted.withOpacity(0.7);
    final rateButtonColor = AppColors.senaryColor;

    const double dialogMaxWidth = 340.0;

    final restoreNavBar = Darkener.darken();

    await showGeneralDialog<void>(
      context: context,
      barrierLabel: 'ReviewPrompt',
      barrierDismissible: true,
      pageBuilder: (dialogCtx, _, __) {
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
                                Navigator.of(dialogCtx).pop();
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
                                // First, close the custom dialog.
                                Navigator.of(dialogCtx).pop();

                                // Then, mark the flow as completed.
                                if (isProduction) {
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setBool(_reviewCompletedKey, true);
                                }

                                // --- MODIFIED ACTION ---
                                // Call the new robust function to handle store linking.
                                // We pass the original `context` for broader compatibility.
                                await _launchStoreReview(context);
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
          splashColor: textColor.withOpacity(0.2),
          highlightColor: textColor.withOpacity(0.1),
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