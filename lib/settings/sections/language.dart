// lib/settings/sections/language.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../darkener.dart';
import '../../l10n/app_localizations.dart';
import '../../language.dart';
import '../../library/providers/catalog.dart';
import '../../theme.dart';

/// A widget that manages the app language selection in the settings screen.
///
/// This component is a consumer of `LocaleProvider` to get the current language
/// and trigger language changes. It presents the user with a polished dialog to
/// select from a list of available application languages.
class AppLanguageSection extends StatelessWidget {
  const AppLanguageSection({super.key});

  /// Returns the localized language name corresponding to the given language code.
  String _getLocalizedLanguageName(
      AppLocalizations localizations, String code) {
    switch (code) {
      case 'en':
        return localizations.english;
      case 'tr':
        return localizations.turkish;
      case 'zh':
        return localizations.chinese;
      case 'fr':
        return localizations.french;
      case 'hi':
        return localizations.hindi;
      case 'pt':
        return localizations.portuguese;
      case 'id':
        return localizations.indonesian;
      case 'az':
        return localizations.azerbaijani;
      case 'de':
        return localizations.german;
      case 'es':
        return localizations.spanish;
      case 'it':
        return localizations.italian;
      case 'ja':
        return localizations.japanese;
      case 'nl':
        return localizations.dutch;
      case 'ru':
        return localizations.russian;
      case 'ko':
        return localizations.korean;
      case 'ar':
        return localizations.arabic;
      default:
        return code; // Fallback for unknown codes
    }
  }

  /// Displays the language selection dialog, featuring a custom design with icons
  /// and ripple effects for an enhanced user experience.
  Future<void> _showLanguageSelectionDialog(BuildContext context) async {
    final localeProvider = context.read<LocaleProvider>();
    final appLocalizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final modelCatalogProvider = context.read<ModelCatalogProvider>();

    // Define base languages with native names for sorting
    final allLanguages = [
      {'code': 'en', 'name': appLocalizations.english, 'native': 'English'},
      {'code': 'tr', 'name': appLocalizations.turkish, 'native': 'Türkçe'},
      {'code': 'zh', 'name': appLocalizations.chinese, 'native': '中文'},
      {'code': 'fr', 'name': appLocalizations.french, 'native': 'Français'},
      {'code': 'hi', 'name': appLocalizations.hindi, 'native': 'हिन्दी'},
      {
        'code': 'pt',
        'name': appLocalizations.portuguese,
        'native': 'Português'
      },
      {
        'code': 'id',
        'name': appLocalizations.indonesian,
        'native': 'Bahasa Indonesia'
      },
      {
        'code': 'az',
        'name': appLocalizations.azerbaijani,
        'native': 'Azərbaycan'
      },
      {'code': 'de', 'name': appLocalizations.german, 'native': 'Deutsch'},
      {'code': 'es', 'name': appLocalizations.spanish, 'native': 'Español'},
      {'code': 'it', 'name': appLocalizations.italian, 'native': 'Italiano'},
      {'code': 'ja', 'name': appLocalizations.japanese, 'native': '日本語'},
      {'code': 'nl', 'name': appLocalizations.dutch, 'native': 'Nederlands'},
      {'code': 'ru', 'name': appLocalizations.russian, 'native': 'Русский'},
      {'code': 'ko', 'name': appLocalizations.korean, 'native': '한국어'},
      {'code': 'ar', 'name': appLocalizations.arabic, 'native': 'العربية'},
    ];

    // Sort: TR first, EN second, rest alphabetically by native name
    final languages = [
      allLanguages.firstWhere((l) => l['code'] == 'tr'),
      allLanguages.firstWhere((l) => l['code'] == 'en'),
      ...allLanguages
          .where((l) => l['code'] != 'tr' && l['code'] != 'en')
          .toList()
        ..sort((a, b) {
          String getKey(String text) {
            return text
                .toLowerCase()
                .replaceAll('ç', 'c~')
                .replaceAll('ğ', 'g~')
                .replaceAll('ı', 'h~')
                .replaceAll('i', 'i')
                .replaceAll('ö', 'o~')
                .replaceAll('ş', 's~')
                .replaceAll('ü', 'u~');
          }

          return getKey(a['name']!).compareTo(getKey(b['name']!));
        }),
    ];

    // Temporarily holds the selected language within the dialog.
    String tempSelectedLanguageCode = localeProvider.locale.languageCode;
    final RestoreCallback restoreNavBar = Darkener.darken(factor: 0.5);

    final selectedLangCode = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'LanguageSelection',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (ctx, _, __) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: screenWidth * 0.7,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: StatefulBuilder(
                  builder: (dialogContext, setStateDialog) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Dialog Header with Icon ---
                        SizedBox(height: screenHeight * 0.02),
                        SvgPicture.asset(
                          'assets/icons/world.svg',
                          width: screenWidth * 0.07,
                          height: screenWidth * 0.07,
                          colorFilter: ColorFilter.mode(
                              AppColors.primaryColor.inverted, BlendMode.srcIn),
                        ),
                        SizedBox(height: screenHeight * 0.008),
                        Text(
                          appLocalizations.language,
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor.inverted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.008),
                        Divider(
                            height: 1,
                            thickness: 0.5,
                            color:
                                AppColors.quinaryColor.withValues(alpha: 0.7)),

                        // --- Language List ---
                        ConstrainedBox(
                          constraints:
                              BoxConstraints(maxHeight: screenHeight * 0.4),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.01,
                                horizontal: screenWidth * 0.02),
                            itemCount: languages.length,
                            itemBuilder: (context, index) {
                              final lang = languages[index];
                              final String langCode = lang['code']!;
                              final bool isSelected =
                                  (tempSelectedLanguageCode == langCode);

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryColor.inverted
                                          .withValues(alpha: 0.02)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  title: Text(
                                    lang['name']!,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.038,
                                      color: AppColors.primaryColor.inverted,
                                    ),
                                  ),
                                  leading: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    transitionBuilder: (child, animation) =>
                                        FadeTransition(
                                            opacity: animation, child: child),
                                    child: Icon(
                                      isSelected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      key: ValueKey<bool>(isSelected),
                                      // Important for AnimatedSwitcher
                                      color: AppColors.primaryColor.inverted,
                                    ),
                                  ),
                                  onTap: () {
                                    if (!isSelected) {
                                      HapticFeedback.lightImpact();
                                      setStateDialog(() =>
                                          tempSelectedLanguageCode = langCode);
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02),
                                ),
                              );
                            },
                          ),
                        ),

                        // --- Dialog Footer with "Done" Button ---
                        Divider(
                            height: 1,
                            thickness: 0.5,
                            color:
                                AppColors.quinaryColor.withValues(alpha: 0.7)),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor:
                                AppColors.senaryColor.withValues(alpha: 0.1),
                            highlightColor:
                                AppColors.senaryColor.withValues(alpha: 0.1),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(ctx).pop(tempSelectedLanguageCode);
                            },
                            child: Container(
                              height: screenHeight * 0.065,
                              alignment: Alignment.center,
                              child: Text(
                                appLocalizations.done,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: AppColors.senaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    restoreNavBar();

    if (selectedLangCode == null ||
        selectedLangCode == localeProvider.locale.languageCode) {
      return;
    }

    localeProvider.setLocale(Locale(selectedLangCode));

    // 1. Set the new locale. This will cause UI widgets that watch LocaleProvider to rebuild.
    await localeProvider.setLocale(Locale(selectedLangCode));

    // 2. Manually trigger a full refresh on the ModelCatalogProvider.
    modelCatalogProvider.refreshCatalog();

    debugPrint(
        "[AppLanguageSection] Language changed to '$selectedLangCode'. All caches cleared, models are refreshing.");
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    // Watch the LocaleProvider to rebuild this section when the language changes.
    final localeProvider = context.watch<LocaleProvider>();
    final appLocalizations = AppLocalizations.of(context)!;

    final currentLanguageCode = localeProvider.locale.languageCode;
    final currentLanguageName =
        _getLocalizedLanguageName(appLocalizations, currentLanguageCode);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          appLocalizations.language,
          style: TextStyle(
            color: AppColors.primaryColor.inverted,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        // Section Description
        Text(
          appLocalizations.languageDescription,
          style: TextStyle(
            color: AppColors.quinaryColor,
            fontSize: screenWidth * 0.035,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        // The main button to open the selection dialog.
        Material(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(10.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              _showLanguageSelectionDialog(context);
            },
            borderRadius: BorderRadius.circular(10.0),
            splashColor: AppColors.quaternaryColor.withValues(alpha: 0.3),
            child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentLanguageName,
                    style: TextStyle(
                      color: AppColors.primaryColor.inverted,
                      fontSize: screenWidth * 0.041,
                      fontWeight: FontWeight.w500,
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
          ),
        ),
      ],
    );
  }
}
