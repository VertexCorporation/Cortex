part of 'service.dart';

/// Builds the final notification content from a data payload.
/// This is a shared helper used by both background and foreground handlers
/// to ensure consistent, localized content.
Future<Map<String, String>> _buildLocalizedContent(
    Map<String, dynamic> data) async {
  final String? titleKey = data['notification_title_key'];
  final String? bodyKey = data['notification_body_key'];

  if (titleKey == null || bodyKey == null) {
    debugPrint(
        "[Content Builder] Title or body key is missing in the payload.");
    return {}; // Return an empty map to signify failure.
  }

  final prefs = await SharedPreferences.getInstance();
  final savedLocaleCode = prefs.getString('language_code');

  final locale = savedLocaleCode != null
      ? Locale(savedLocaleCode)
      : Locale(Platform.localeName
      .split('_')
      .first);

  debugPrint(
      "[Content Builder] Using '${locale
          .languageCode}' for notification language.");

  final l10n = await AppLocalizations.delegate.load(locale);

  String getLocalizedString(String key) {
    // This maps your camelCase keys to the generated AppLocalizations properties.
    // It correctly handles both parameterized and non-parameterized strings.
    switch (key) {
    // --- PARAMETERIZED STRINGS ---
      case 'notificationNewModelAddedBody':
        return l10n
            .notificationNewModelAddedBody(data['modelName'] ?? '[Model]');
      case 'notificationNewFeatureBody':
        return l10n
            .notificationNewFeatureBody(data['featureName'] ?? '[Feature]');
      case 'notificationWelcomeOfferBody':
        return l10n.notificationWelcomeOfferBody;
      case 'notificationUpsellFeatureTitle':
        return l10n
            .notificationUpsellFeatureTitle(data['targetTier'] ?? '[Plan]');
      case 'notificationUpsellFeatureBody':
        return l10n.notificationUpsellFeatureBody(
            data['currentTier'] ?? '[Current Plan]',
            data['targetTier'] ?? '[New Plan]',
            data['featureName'] ?? '[Feature]');

    // --- NON-PARAMETERIZED STRINGS (unchanged from your original code) ---
      case 'notificationComebackTitle':
        return l10n.notificationComebackTitle;
      case 'notificationComebackBody':
        return l10n.notificationComebackBody;
      case 'notificationLongTimeNoSeeTitle':
        return l10n.notificationLongTimeNoSeeTitle;
      case 'notificationLongTimeNoSeeBody':
        return l10n.notificationLongTimeNoSeeBody;
      case 'notificationHowAreYouTitle':
        return l10n.notificationHowAreYouTitle;
      case 'notificationHowAreYouBody':
        return l10n.notificationHowAreYouBody;
      case 'notificationNewYearTitle':
        return l10n.notificationNewYearTitle;
      case 'notificationNewYearBody':
        return l10n.notificationNewYearBody;
      case 'notificationValentinesDayTitle':
        return l10n.notificationValentinesDayTitle;
      case 'notificationValentinesDayBody':
        return l10n.notificationValentinesDayBody;
      case 'notificationAtaturkRemembranceTitle':
        return l10n.notificationAtaturkRemembranceTitle;
      case 'notificationAtaturkRemembranceBody':
        return l10n.notificationAtaturkRemembranceBody;
      case 'notificationMothersDayTitle':
        return l10n.notificationMothersDayTitle;
      case 'notificationMothersDayBody':
        return l10n.notificationMothersDayBody;
      case 'notificationFathersDayTitle':
        return l10n.notificationFathersDayTitle;
      case 'notificationFathersDayBody':
        return l10n.notificationFathersDayBody;
      case 'notificationHomeworkHelperTitle':
        return l10n.notificationHomeworkHelperTitle;
      case 'notificationHomeworkHelperBody':
        return l10n.notificationHomeworkHelperBody;
      case 'notificationTrollAnimeTitle':
        return l10n.notificationTrollAnimeTitle;
      case 'notificationTrollAnimeBody':
        return l10n.notificationTrollAnimeBody;
      case 'notificationTrollAiRebellionTitle':
        return l10n.notificationTrollAiRebellionTitle;
      case 'notificationTrollAiRebellionBody':
        return l10n.notificationTrollAiRebellionBody;
      case 'notificationNewModelAddedTitle':
        return l10n.notificationNewModelAddedTitle;
      case 'notificationAppUpdateTitle':
        return l10n.notificationAppUpdateTitle;
      case 'notificationAppUpdateBody':
        return l10n.notificationAppUpdateBody;
      case 'notificationNewFeatureTitle':
        return l10n.notificationNewFeatureTitle;
      case 'notificationWelcomeOfferTitle':
        return l10n.notificationWelcomeOfferTitle;
      case 'notificationSocialMediaTitle':
        return l10n.notificationSocialMediaTitle;
      case 'notificationSocialMediaBody':
        return l10n.notificationSocialMediaBody;
      case 'notificationRandomFactTitle':
        return l10n.notificationRandomFactTitle;
      case 'notificationRandomFactBody':
        return l10n.notificationRandomFactBody;
      case 'notificationGoodMorningTitle':
        return l10n.notificationGoodMorningTitle;
      case 'notificationGoodMorningBody':
        return l10n.notificationGoodMorningBody;
      case 'notificationGoodNightTitle':
        return l10n.notificationGoodNightTitle;
      case 'notificationGoodNightBody':
        return l10n.notificationGoodNightBody;
      case 'notificationOfflineReadyTitle':
        return l10n.notificationOfflineReadyTitle;
      case 'notificationOfflineReadyBody':
        return l10n.notificationOfflineReadyBody;
      case 'notificationRateAppTitle':
        return l10n.notificationRateAppTitle;
      case 'notificationRateAppBody':
        return l10n.notificationRateAppBody;
      case 'notificationReferralTitle':
        return l10n.notificationReferralTitle;
      case 'notificationReferralBody':
        return l10n.notificationReferralBody;
      case 'notificationCookingTitle':
        return l10n.notificationCookingTitle;
      case 'notificationCookingBody':
        return l10n.notificationCookingBody;
      case 'notificationExistentialTitle':
        return l10n.notificationExistentialTitle;
      case 'notificationExistentialBody':
        return l10n.notificationExistentialBody;
      case 'notificationCustomModelTitle':
        return l10n.notificationCustomModelTitle;
      case 'notificationCustomModelBody':
        return l10n.notificationCustomModelBody;
      case 'notificationDynamicChatTitle':
        return l10n.notificationDynamicChatTitle;
      case 'notificationDynamicChatBody':
        return l10n.notificationDynamicChatBody;
      case 'notificationPirateTitle':
        return l10n.notificationPirateTitle;
      case 'notificationPirateBody':
        return l10n.notificationPirateBody;
      case 'notificationFortuneCookieTitle':
        return l10n.notificationFortuneCookieTitle;
      case 'notificationFortuneCookieBody':
        return l10n.notificationFortuneCookieBody;
      case 'notificationSingularityTitle':
        return l10n.notificationSingularityTitle;
      case 'notificationSingularityBody':
        return l10n.notificationSingularityBody;
      case 'notificationHackerJokeTitle':
        return l10n.notificationHackerJokeTitle;
      case 'notificationHackerJokeBody':
        return l10n.notificationHackerJokeBody;
      case 'notificationDetectiveCaseTitle':
        return l10n.notificationDetectiveCaseTitle;
      case 'notificationDetectiveCaseBody':
        return l10n.notificationDetectiveCaseBody;
      case 'notificationOriginStoryTitle':
        return l10n.notificationOriginStoryTitle;
      case 'notificationOriginStoryBody':
        return l10n.notificationOriginStoryBody;
      case 'notificationOpenSourceTitle':
        return l10n.notificationOpenSourceTitle;
      case 'notificationOpenSourceBody':
        return l10n.notificationOpenSourceBody;
      case 'notificationRejectionStoryTitle':
        return l10n.notificationRejectionStoryTitle;
      case 'notificationRejectionStoryBody':
        return l10n.notificationRejectionStoryBody;
      case 'notificationGGUFSupportTitle':
        return l10n.notificationGGUFSupportTitle;
      case 'notificationGGUFSupportBody':
        return l10n.notificationGGUFSupportBody;
      case 'notificationThemeCustomizationTitle':
        return l10n.notificationThemeCustomizationTitle;
      case 'notificationThemeCustomizationBody':
        return l10n.notificationThemeCustomizationBody;
      case 'notificationShowerThoughtTitle':
        return l10n.notificationShowerThoughtTitle;
      case 'notificationShowerThoughtBody':
        return l10n.notificationShowerThoughtBody;
      case 'notificationLowBatteryTitle':
        return l10n.notificationLowBatteryTitle;
      case 'notificationLowBatteryBody':
        return l10n.notificationLowBatteryBody;
      default:
        return '';
    }
  }

  String localizedTitle = getLocalizedString(titleKey);
  String localizedBody = getLocalizedString(bodyKey);

  return {'title': localizedTitle, 'body': localizedBody};
}
