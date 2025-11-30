// lib/settings/sections/theme.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../darkener.dart';
import '../../l10n/app_localizations.dart';
import '../../notifications/introvert.dart';
import '../../theme.dart';
import '../providers/general.dart';

/// A widget that manages the app theme selection section in the settings screen.
///
/// This component consumes `SettingsGeneralProvider` and `ThemeProvider`. It
/// displays the currently selected theme and provides a polished dialog for the user to
/// choose a new one. Theme availability is dynamically determined based on the
/// user's active subscription status from the provider.
class AppThemeSection extends StatelessWidget {
  const AppThemeSection({super.key});

  /// Returns the localized name for a given theme code.
  String _getLocalizedThemeName(AppLocalizations localizations, String themeCode) {
    final Map<String, String> mapping = {
      'light': localizations.light,
      'dark': localizations.dark,
      'love': localizations.love,
      'nature': localizations.nature,
      'behindTheSlaughter': localizations.behindTheSlaughter,
      'grayscale': localizations.grayscale,
      'ocean': localizations.ocean,
      'scarletSnow': localizations.scarletSnow,
    };
    return mapping[themeCode] ?? themeCode; // Fallback to the code itself
  }

  /// Determines the minimum subscription level required to unlock a theme.
  int _getRequiredSubscriptionLevelForTheme(String themeCode) {
    switch (themeCode) {
      case 'light':
      case 'dark':
      case 'grayscale':
        return 0; // Free
      case 'nature':
      case 'ocean':
      case 'behindTheSlaughter':
      case 'scarletSnow':
      case 'love':
        return 1; // Requires at least Plus
      default:
        return 99; // Unknown themes are locked by default
    }
  }

  /// Checks if a specific theme is enabled based on the user's active subscription status.
  bool _isThemeEnabled(SettingsGeneralProvider provider, String themeCode) {
    final int activeUserLevel = provider.activeSubscriptionLevel;
    final int requiredLevel = _getRequiredSubscriptionLevelForTheme(themeCode);

    return activeUserLevel >= requiredLevel;
  }

  /// Sorts themes according to a specific logic:
  /// 1. Base themes ('light', 'dark', 'grayscale') always come first.
  /// 2. All other enabled themes are sorted alphabetically.
  /// 3. All locked themes are listed last, sorted by required level, then alphabetically.
  List<Map<String, dynamic>> _sortThemes(List<Map<String, dynamic>> themes) {
    themes.sort((a, b) {
      final bool aEnabled = a['enabled'] as bool;
      final bool bEnabled = b['enabled'] as bool;
      final String aCode = a['code'] as String;
      final String bCode = b['code'] as String;
      final String aName = a['name'] as String;
      final String bName = b['name'] as String;

      const List<String> baseThemeOrder = ['light', 'dark', 'grayscale'];
      final int aBaseIndex = baseThemeOrder.indexOf(aCode);
      final int bBaseIndex = baseThemeOrder.indexOf(bCode);

      if (aBaseIndex != -1 && bBaseIndex != -1) return aBaseIndex.compareTo(bBaseIndex);
      if (aBaseIndex != -1) return -1;
      if (bBaseIndex != -1) return 1;

      if (aEnabled && !bEnabled) return -1;
      if (!aEnabled && bEnabled) return 1;

      if (aEnabled && bEnabled) return aName.toLowerCase().compareTo(bName.toLowerCase());

      if (!aEnabled && !bEnabled) {
        final int aRequiredLevel = _getRequiredSubscriptionLevelForTheme(aCode);
        final int bRequiredLevel = _getRequiredSubscriptionLevelForTheme(bCode);
        if (aRequiredLevel != bRequiredLevel) return aRequiredLevel.compareTo(bRequiredLevel);
        return aName.toLowerCase().compareTo(bName.toLowerCase());
      }
      return 0;
    });
    return themes;
  }

  /// Displays the theme selection dialog with a polished UI and animations.
  Future<void> _showThemeSelectionDialog(BuildContext context) async {
    final generalProvider = context.read<SettingsGeneralProvider>();
    final themeProvider = context.read<ThemeProvider>();
    final notificationService = context.read<IntrovertNotificationService>();
    final appLocalizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final List<String> availableThemeCodes = AppColors.overlayStyles.keys.toList();
    List<Map<String, dynamic>> themesList = availableThemeCodes.map((code) {
      return {
        'code': code,
        'name': _getLocalizedThemeName(appLocalizations, code),
        'enabled': _isThemeEnabled(generalProvider, code),
      };
    }).toList();
    themesList = _sortThemes(themesList);

    String tempSelectedTheme = themeProvider.currentTheme;
    final RestoreCallback restoreNavBar = Darkener.darken(factor: 0.5);

    final selectedThemeCode = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ThemeSelection',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (ctx, _, __) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: screenWidth * 0.7,
              decoration: BoxDecoration(color: AppColors.secondaryColor, borderRadius: BorderRadius.circular(16)),
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
                          'assets/icons/theme.svg',
                          width: screenWidth * 0.07,
                          height: screenWidth * 0.07,
                          colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
                        ),
                        SizedBox(height: screenHeight * 0.008),
                        Text(
                          appLocalizations.theme,
                          style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.008),
                        Divider(height: 1, thickness: 0.5, color: AppColors.quinaryColor.withValues(alpha:0.7)),

                        // --- Themes List with Animations ---
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: screenHeight * 0.4),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01, horizontal: screenWidth * 0.02),
                            itemCount: themesList.length,
                            itemBuilder: (context, index) {
                              final theme = themesList[index];
                              final bool isEnabled = theme['enabled'] as bool;
                              final String themeCode = theme['code'] as String;
                              final bool isSelected = (tempSelectedTheme == themeCode);

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryColor.inverted.withValues(alpha: 0.02) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  leading: isEnabled
                                      ? AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                                    child: Icon(
                                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                      key: ValueKey<bool>(isSelected),
                                      color: AppColors.primaryColor.inverted,
                                    ),
                                  )
                                      : SizedBox(
                                    width: 24, // Align with radio button size
                                    height: 24,
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/lock.svg',
                                        width: 20,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted.withValues(alpha:0.5), BlendMode.srcIn),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    theme['name'] as String,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isEnabled ? AppColors.primaryColor.inverted : AppColors.primaryColor.inverted.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  onTap: () {
                                    if (isEnabled) {
                                      if (!isSelected) {
                                        setStateDialog(() => tempSelectedTheme = themeCode);
                                      }
                                    } else {
                                      notificationService.showNotification(
                                        message: appLocalizations.themeLocked,
                                        type: NotificationType.error
                                      );
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                                ),
                              );
                            },
                          ),
                        ),

                        // --- Dialog Footer with "Done" Button ---
                        Divider(height: 1, thickness: 0.5, color: AppColors.quinaryColor.withValues(alpha:0.7)),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: AppColors.senaryColor.withValues(alpha:0.1),
                            highlightColor: AppColors.senaryColor.withValues(alpha:0.1),
                            onTap: () => Navigator.of(ctx).pop(tempSelectedTheme),
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              child: Text(
                                appLocalizations.done,
                                style: TextStyle(fontSize: 16, color: AppColors.senaryColor, fontWeight: FontWeight.w500),
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

    if (selectedThemeCode == null || selectedThemeCode == themeProvider.currentTheme) return;

    themeProvider.changeTheme(selectedThemeCode);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();
    final currentThemeName = _getLocalizedThemeName(appLocalizations, themeProvider.currentTheme);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.theme,
          style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.05, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          appLocalizations.themeDescription,
          style: TextStyle(color: AppColors.quinaryColor, fontSize: screenWidth * 0.035),
        ),
        SizedBox(height: screenHeight * 0.02),
        Material(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(10.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showThemeSelectionDialog(context),
            borderRadius: BorderRadius.circular(10.0),
            splashColor: AppColors.quaternaryColor.withValues(alpha:0.3),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentThemeName,
                    style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.041, fontWeight: FontWeight.w500),
                  ),
                  Icon(Icons.arrow_forward_ios, color: AppColors.primaryColor.inverted, size: screenWidth * 0.04),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}