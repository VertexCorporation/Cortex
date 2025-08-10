// sections/theme.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/main.dart';
import 'package:cortex/notifications.dart'; // For showing notifications (e.g., theme locked)
import 'package:cortex/theme.dart'; // For AppColors and ThemeProvider
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemChrome
import 'package:flutter_svg/flutter_svg.dart'; // For SVG icons
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import 'package:provider/provider.dart'; // For accessing ThemeProvider
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../darkener.dart'; // For localization

/// A widget that manages the app theme selection section in the settings screen.
///
/// This widget allows the user to choose from a list of available themes.
/// It displays the current theme and opens a dialog for theme selection.
/// Theme availability can be dependent on user subscription status.
class AppThemeSection extends StatefulWidget {
  /// Contains the necessary strings for localization.
  final AppLocalizations appLocalizations;

  /// The current subscription level of the user, used to determine theme locks.
  /// 0: Free, 1: Plus, 2: Pro, 3: Ultra
  /// 4: Plus (Legacy), 5: Pro (Legacy), 6: Ultra (Legacy)
  final int userSubscriptionLevel;

  /// Indicates whether a dialog is currently open.
  final bool isDialogOpen;

  /// Callback to notify the parent widget about the dialog's open/close state.
  final Function(bool) onDialogStateChanged;

  /// Service for showing notifications.
  final NotificationService notificationService;

  final Timestamp? subscriptionExpiresAt;

  const AppThemeSection({
    Key? key,
    required this.appLocalizations,
    required this.userSubscriptionLevel,
    required this.subscriptionExpiresAt,
    required this.isDialogOpen,
    required this.onDialogStateChanged,
    required this.notificationService,
  }) : super(key: key);

  @override
  AppThemeSectionState createState() => AppThemeSectionState();
}

class AppThemeSectionState extends State<AppThemeSection> {

  /// A robust, reusable check to see if the subscription is currently active.
  /// It checks for a valid level AND a future expiration date.
  bool get _isSubscriptionActive {
    // A subscription is active if its level is greater than 0...
    if (widget.userSubscriptionLevel == 0) return false;

    final expires = widget.subscriptionExpiresAt;
    if (expires == null) return false; // If there's no expiration date, it's not active.

    return expires.toDate().isAfter(DateTime.now());
  }

  /// Returns the localized name for a given theme code.
  String _getLocalizedThemeName(String themeCode) {
    final localizations = widget.appLocalizations;
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
    final localized = mapping[themeCode];
    if (localized == null || localized.isEmpty) {
      // Fallback: Capitalize and space out the theme code
      if (kDebugMode) {
        print('[AppThemeSection] No direct localization for theme code: $themeCode. Generating name.');
      }
      return themeCode
          .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
          .trim()
          .split(' ')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');
    }
    return localized;
  }

  /// Determines the minimum subscription level required to unlock a theme.
  int _getRequiredSubscriptionLevelForTheme(String themeCode) {
    switch (themeCode) {
      case 'light':
      case 'dark':
      case 'grayscale':
        return 0; // Always available (Free)
      case 'nature':
      case 'ocean':
      case 'behindTheSlaughter':
      case 'scarletSnow':
      case 'love':
        return 1; // Plus
      default:
        return 0; // Unknown themes are treated as free
    }
  }


  /// Checks if a specific theme is enabled based on the user's subscription level.
  /// This function now correctly checks for an ACTIVE subscription.
  bool _isThemeEnabled(String themeCode) {
    // Legacy subscriptions (levels 4, 5, 6) always unlock all themes.
    if (widget.userSubscriptionLevel >= 4 && widget.userSubscriptionLevel <= 6) {
      return true;
    }

    final requiredLevel = _getRequiredSubscriptionLevelForTheme(themeCode);

    // Free themes are always enabled.
    if (requiredLevel == 0) {
      return true;
    }

    // For paid themes, the subscription must be ACTIVE and the user's
    // current level must be high enough to unlock it.
    return _isSubscriptionActive && widget.userSubscriptionLevel >= requiredLevel;
  }

  /// Sorts the themes according to the specified logic.
  List<Map<String, dynamic>> _sortThemes(List<Map<String, dynamic>> themes) {
    themes.sort((a, b) {
      bool aEnabled = a['enabled'] as bool;
      bool bEnabled = b['enabled'] as bool;
      String aCode = a['code'] as String;
      String bCode = b['code'] as String;
      String aName = a['name'] as String;
      String bName = b['name'] as String;

      // Define base themes that should always come first
      const List<String> baseThemeOrder = ['light', 'dark', 'grayscale'];
      int aBaseIndex = baseThemeOrder.indexOf(aCode);
      int bBaseIndex = baseThemeOrder.indexOf(bCode);

      // Sort base themes first by their defined order
      if (aBaseIndex != -1 && bBaseIndex != -1) {
        return aBaseIndex.compareTo(bBaseIndex);
      }
      if (aBaseIndex != -1) return -1; // a is base, b is not
      if (bBaseIndex != -1) return 1;  // b is base, a is not

      // Then, sort by enabled status (enabled themes first)
      if (aEnabled && !bEnabled) return -1;
      if (!aEnabled && bEnabled) return 1;

      // If both are enabled, sort alphabetically
      if (aEnabled && bEnabled) {
        return aName.toLowerCase().compareTo(bName.toLowerCase());
      }

      // If both are disabled (locked), sort by required subscription level, then alphabetically
      if (!aEnabled && !bEnabled) {
        int aRequiredLevel = _getRequiredSubscriptionLevelForTheme(aCode);
        int bRequiredLevel = _getRequiredSubscriptionLevelForTheme(bCode);

        if (aRequiredLevel != bRequiredLevel) {
          return aRequiredLevel.compareTo(bRequiredLevel); // Lower required level first
        }
        return aName.toLowerCase().compareTo(bName.toLowerCase()); // Alphabetical for same required level
      }
      return 0; // Should not happen
    });
    return themes;
  }


  /// Displays the theme selection dialog.
  Future<void> _showThemeSelectionDialog() async {
    if (widget.isDialogOpen) {
      if (kDebugMode) {
        print('[AppThemeSection] Theme selection dialog requested, but another dialog is already open.');
      }
      return;
    }
    widget.onDialogStateChanged(true);
    if (kDebugMode) {
      print('[AppThemeSection] Showing theme selection dialog.');
    }

    final appLocalizations = widget.appLocalizations;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    final List<String> availableThemeCodes = AppColors.overlayStyles.keys.toList();
    List<Map<String, dynamic>> themesList = availableThemeCodes.map((code) {
      return {
        'code': code,
        'name': _getLocalizedThemeName(code),
        'enabled': _isThemeEnabled(code),
      };
    }).toList();
    themesList = _sortThemes(themesList);

    String tempSelectedTheme = themeProvider.currentTheme;
    final RestoreCallback restoreNavBar = Darkener.darken(factor: 0.5);

    // =================================================================
    // == THE FIX: AWAIT THE DIALOG'S RESULT ==
    // =================================================================
    // The dialog will now return the selected theme code as a string result.
    // We will 'await' this result. The theme change logic will only execute
    // *after* the dialog is completely closed.
    final selectedThemeCode = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ThemeSelection',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: screenWidth * 0.70,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: StatefulBuilder(
                  builder: (dialogContext, setStateDialog) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor.inverted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Divider(thickness: 0.5, color: AppColors.quinaryColor.withOpacity(0.7)),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: screenHeight * 0.35),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                            itemCount: themesList.length,
                            itemBuilder: (context, index) {
                              final theme = themesList[index];
                              bool isEnabled = theme['enabled'] as bool;
                              // ... (The entire ListView.builder logic remains the same)
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (isEnabled) {
                                      setStateDialog(() {
                                        tempSelectedTheme = theme['code'] as String;
                                      });
                                    } else {
                                      widget.notificationService.showNotification(
                                        message: appLocalizations.themeLocked,
                                        isSuccess: false,
                                        oneLine: false,
                                        bottomOffset: 0.02,
                                      );
                                    }
                                  },
                                  child: Padding(
                                    // ... (The rest of the item's build logic is the same)
                                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01, vertical: screenHeight*0.01), // Simplified padding
                                    child: Row(
                                      children: [
                                        Container(
                                          width: screenWidth * 0.12,
                                          alignment: Alignment.center,
                                          child: isEnabled
                                              ? Radio<String>(
                                            value: theme['code'] as String,
                                            groupValue: tempSelectedTheme,
                                            onChanged: (value) => setStateDialog(() => tempSelectedTheme = value!),
                                            activeColor: AppColors.primaryColor.inverted,
                                            fillColor: MaterialStateProperty.resolveWith<Color>((states) => states.contains(MaterialState.selected) ? AppColors.primaryColor.inverted : AppColors.primaryColor.inverted.withOpacity(0.6)),
                                          )
                                              : SvgPicture.asset('assets/icons/lock.svg', width: screenWidth * 0.045, height: screenWidth * 0.045, colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted.withOpacity(0.5), BlendMode.srcIn)),
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        Expanded(child: Text(theme['name'] as String, style: TextStyle(fontSize: screenWidth * 0.038, color: isEnabled ? AppColors.primaryColor.inverted : AppColors.primaryColor.inverted.withOpacity(0.5)))),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Divider(thickness: 0.5, color: AppColors.quinaryColor.withOpacity(0.7), height: 1),
                        // "Done" button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: AppColors.senaryColor.withOpacity(0.1),
                            highlightColor: AppColors.senaryColor.withOpacity(0.1),
                            onTap: () {
                              // =============================================================
                              // == THE FIX: ONLY POP WITH THE RESULT, DO NOT CHANGE THEME HERE ==
                              // =============================================================
                              Navigator.of(ctx).pop(tempSelectedTheme);
                            },
                            child: Container(
                              height: screenHeight * 0.065,
                              alignment: Alignment.center,
                              child: Text(
                                appLocalizations.done,
                                style: TextStyle(fontSize: screenWidth * 0.04, color: AppColors.senaryColor, fontWeight: FontWeight.w500),
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
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );

    // This code block now runs *AFTER* the dialog has been popped and its result is received.
    restoreNavBar();
    widget.onDialogStateChanged(false);

    // If the dialog was dismissed (result is null) or the theme hasn't changed, do nothing.
    if (selectedThemeCode == null || selectedThemeCode == themeProvider.currentTheme) {
      if (kDebugMode) {
        print('[AppThemeSection] Dialog closed. No theme change necessary.');
      }
      return;
    }

    // Find the theme data to ensure it's actually enabled before changing.
    final selectedThemeData = themesList.firstWhere((t) => t['code'] == selectedThemeCode);
    if (selectedThemeData['enabled'] as bool) {
      if (kDebugMode) {
        print('[AppThemeSection] Dialog closed. Applying theme: $selectedThemeCode from main context.');
      }
      // Now, change the theme from the stable, main page context.
      // The ThemeProvider itself handles the SystemChrome update correctly.
      themeProvider.changeTheme(selectedThemeCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = widget.appLocalizations;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Get current theme name using Provider (listen: true to update when theme changes)
    final currentThemeCode = Provider.of<ThemeProvider>(context).currentTheme;
    final currentThemeName = _getLocalizedThemeName(currentThemeCode);

    if (kDebugMode) {
      print('[AppThemeSection] Building widget. Current theme: $currentThemeName ($currentThemeCode)');
    }

    // Main view of the theme selection section
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title: "Theme"
        Text(
          appLocalizations.theme,
          style: GoogleFonts.roboto(
            color: AppColors.primaryColor.inverted,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        // Section description
        Text(
          appLocalizations.themeDescription,
          style: GoogleFonts.roboto(color: AppColors.quinaryColor, fontSize: screenWidth * 0.035),
        ),
        SizedBox(height: screenHeight * 0.02),
        // Theme selection button
        Material(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(10.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _showThemeSelectionDialog, // Open dialog on tap
            borderRadius: BorderRadius.circular(10.0),
            splashColor: AppColors.quaternaryColor.withOpacity(0.3),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.04), // Consistent padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Current theme name
                  Text(
                    currentThemeName,
                    style: GoogleFonts.roboto(
                        color: AppColors.primaryColor.inverted,
                        fontSize: screenWidth * 0.041111, // Consistent font size
                        fontWeight: FontWeight.w500 // Consistent font weight
                    ),
                  ),
                  // Arrow icon
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