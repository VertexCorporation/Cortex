// lib/invite.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cortex/l10n/app_localizations.dart';

/// This service manages the creation and sharing of user-specific referral links,
/// ensuring the correct store link is provided based on the user's platform (iOS or Android).
class InviteService {

  /// Generates a platform-specific referral/store link and opens the share dialog.
  Future<void> createAndShareReferralLink(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    // Check if the user is logged in before allowing them to invite others.
    if (user == null) {
      debugPrint('[InviteService] Error: User not logged in.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to share invites.')),
      );
      return;
    }

    const String androidPackageName = 'com.vertex.cortex';
    // The Apple App Store link for Cortex
    const String iosAppStoreLink = 'https://apps.apple.com/app/id6755621587';

    final String referrerId = user.uid;
    // We encode the referrer ID to ensure the URL is valid.
    final String encodedReferrer = Uri.encodeComponent('ref=$referrerId');

    late final String finalLink;

    // Determine the platform to serve the correct store link.
    if (Theme
        .of(context)
        .platform == TargetPlatform.iOS) {
      // iOS: Direct App Store link (iOS App Store does not support referrer params in the same way as Play Store)
      finalLink = iosAppStoreLink;
    } else {
      // Android: Google Play Store link with the referrer parameter appended for tracking.
      finalLink =
      'https://play.google.com/store/apps/details?id=$androidPackageName&referrer=$encodedReferrer';
    }

    debugPrint('[InviteService] Generated store link: $finalLink');

    // Retrieve localized strings.
    // Ensure 'inviteShareMessage' in your .arb files accepts a String argument (the link).
    final localizations = AppLocalizations.of(context)!;
    final String shareText = localizations.inviteShareMessage(finalLink);
    final String shareSubject = localizations.inviteShareSubject;

    // Trigger the native share dialog.
    await SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: shareSubject,
      ),
    );
  }
}