// lib/referral.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This service checks for and stores the Play Store install referrer.
/// Its logic has been enhanced to be more resilient against timing issues
/// where the referrer data might not be immediately available on the first app launch.
/// It now employs a retry mechanism to ensure the data is captured reliably.
class ReferralHandler {

  // Keys for storing data in SharedPreferences.
  static const _referrerCheckedKey = 'has_referrer_been_checked';
  static const _savedReferrerIdKey = 'saved_referrer_id';

  /// Checks for a Play Store referrer with a built-in retry mechanism.
  ///
  /// This function is designed to run only once per app installation.
  /// It attempts to fetch the referrer data multiple times over a short period
  /// to mitigate potential delays from the Google Play service, which might not
  /// provide the data at the exact moment of the first app open.
  static Future<void> checkAndStoreReferrer() async {
    final prefs = await SharedPreferences.getInstance();

    // Guard Clause: If this check has successfully completed in the past, do nothing.
    // This prevents re-running the logic on subsequent app starts.
    if (prefs.getBool(_referrerCheckedKey) ?? false) {
      debugPrint(
          '[ReferralHandler] Referrer check has already been completed. Skipping.');
      return;
    }

    debugPrint(
        '[ReferralHandler] Performing first-time referrer check with resilient retry logic...');

    // Configuration for the retry mechanism.
    const int maxRetries = 3;
    const Duration retryDelay = Duration(seconds: 3);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final ReferrerDetails referrerDetails = await PlayInstallReferrer
            .installReferrer;
        final String? referrerUrl = referrerDetails.installReferrer;

        // If data is found, process it and exit immediately.
        if (referrerUrl != null && referrerUrl.isNotEmpty) {
          debugPrint(
              '[ReferralHandler] Success: Referrer data found on attempt #$attempt: "$referrerUrl"');

          // The data is expected in a format like 'ref=USER_ID'. We parse it.
          final Uri uri = Uri.parse('http://dummy.com?$referrerUrl');
          final String? referrerId = uri.queryParameters['ref'];

          if (referrerId != null && referrerId.isNotEmpty) {
            debugPrint(
                '[ReferralHandler] Successfully parsed referrer ID: $referrerId. Saving to SharedPreferences.');
            await prefs.setString(_savedReferrerIdKey, referrerId);
          } else {
            debugPrint(
                '[ReferralHandler] Data found, but "ref" parameter was missing or empty.');
          }

          // CRITICAL: Mark the check as complete and exit the function.
          await prefs.setBool(_referrerCheckedKey, true);
          debugPrint('[ReferralHandler] Referrer flow successfully completed.');
          return;
        }

        // If we reach here, the referrerUrl was null or empty.
        debugPrint('[ReferralHandler] No referrer data on attempt #$attempt.');
      } catch (e) {
        // Log any errors from the plugin itself, but continue to the next attempt.
        debugPrint('[ReferralHandler] Error during attempt #$attempt: $e');
      }

      // If this is not the last attempt, wait before trying again.
      if (attempt < maxRetries) {
        debugPrint(
            '[ReferralHandler] Retrying in ${retryDelay.inSeconds} seconds...');
        await Future.delayed(retryDelay);
      }
    }

    // If the loop completes without finding data, we can assume there is no referrer.
    // Mark the check as complete to prevent it from running again on the next app launch.
    debugPrint(
        '[ReferralHandler] All attempts failed to find referrer data. Marking check as complete.');
    await prefs.setBool(_referrerCheckedKey, true);
  }

  /// Retrieves the saved referrer ID, to be used during user registration.
  static Future<String?> getSavedReferrerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_savedReferrerIdKey);
  }

  /// Clears the saved referrer ID after it has been successfully used.
  /// This prevents it from being accidentally reused for another account
  /// on the same device install.
  static Future<void> clearSavedReferrerId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedReferrerIdKey);
    debugPrint('[ReferralHandler] Saved referrer ID cleared after use.');
  }
}