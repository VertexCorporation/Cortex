// sections/language.dart

import 'package:cortex/main.dart';
import 'package:cortex/theme.dart'; // For your application's theme settings
import 'package:flutter/foundation.dart'; // For kDebugModes
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG icons
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import 'package:cortex/l10n/app_localizations.dart';

import '../../darkener.dart';
import '../../models/backend/data.dart'; // For localization

/// A widget that manages the app language selection section in the settings screen.
///
/// This widget provides a UI for the user to select the application language.
/// When the language selection is initiated, a dialog is displayed listing the available languages.
class AppLanguageSection extends StatefulWidget {
  /// Contains the necessary strings for localization.
  final AppLocalizations appLocalizations;

  /// The code of the currently selected language (e.g., 'en', 'tr').
  final String selectedLanguageCode;

  /// Callback function that is invoked when the language is changed.
  /// It receives the code of the newly selected language as a parameter.
  final Function(String) onLanguageChanged;

  /// Indicates whether a dialog is currently open.
  /// Used to prevent multiple dialogs from opening simultaneously.
  final bool isDialogOpen;

  /// Callback to notify the parent widget about the dialog's open/close state.
  final Function(bool) onDialogStateChanged;

  const AppLanguageSection({
    Key? key,
    required this.appLocalizations,
    required this.selectedLanguageCode,
    required this.onLanguageChanged,
    required this.isDialogOpen,
    required this.onDialogStateChanged,
  }) : super(key: key);

  @override
  AppLanguageSectionState createState() => AppLanguageSectionState();
}

class AppLanguageSectionState extends State<AppLanguageSection> {
  /// Returns the localized language name corresponding to the given language code.
  /// Returns the localized language name corresponding to the given language code.
  String _getLocalizedLanguageName(String code) {
    if (kDebugMode) {
      print('[AppLanguageSection] _getLocalizedLanguageName called for code: $code');
    }
    switch (code) {
      case 'en':
        return widget.appLocalizations.english;
      case 'tr':
        return widget.appLocalizations.turkish;
      case 'zh':
        return widget.appLocalizations.chinese;
      case 'fr':
        return widget.appLocalizations.french;
    // --- NEW CASES ADDED HERE ---
      case 'hi':
        return widget.appLocalizations.hindi;
      case 'pt':
        return widget.appLocalizations.portuguese;
      case 'id':
        return widget.appLocalizations.indonesian;
      case 'az':
        return widget.appLocalizations.azerbaijani;
      case 'de':
        return widget.appLocalizations.german;
      case 'es':
        return widget.appLocalizations.spanish;
      case 'it':
        return widget.appLocalizations.italian;
      case 'ja':
        return widget.appLocalizations.japanese;
      case 'ku':
        return widget.appLocalizations.kurdish;
      case 'nl':
        return widget.appLocalizations.dutch;
      case 'ru':
        return widget.appLocalizations.russian;
      case 'ko':
        return widget.appLocalizations.korean;
      default:
        if (kDebugMode) {
          print('[AppLanguageSection] Unknown language code: $code, returning code itself.');
        }
        return code; // Fallback for any unknown codes
    }
  }


  /// Displays the language selection dialog.
  Future<void> _showLanguageSelectionDialog() async {
    if (widget.isDialogOpen) {
      if (kDebugMode) {
        print('[AppLanguageSection] Language selection dialog requested, but another dialog is already open.');
      }
      return;
    }
    widget.onDialogStateChanged(true); // Notify that a dialog is opening
    if (kDebugMode) {
      print('[AppLanguageSection] Showing language selection dialog.');
    }

    final appLocalizations = widget.appLocalizations;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // List of supported languages. Each entry contains a code and its localized name.
    final languages = [
      {'code': 'en', 'name': appLocalizations.english},
      {'code': 'tr', 'name': appLocalizations.turkish},
      {'code': 'zh', 'name': appLocalizations.chinese},
      {'code': 'fr', 'name': appLocalizations.french},
      {'code': 'hi', 'name': appLocalizations.hindi},
      {'code': 'pt', 'name': appLocalizations.portuguese},
      {'code': 'id', 'name': appLocalizations.indonesian},
      {'code': 'az', 'name': appLocalizations.azerbaijani},
      {'code': 'de', 'name': appLocalizations.german},
      {'code': 'es', 'name': appLocalizations.spanish},
      {'code': 'it', 'name': appLocalizations.italian},
      {'code': 'ja', 'name': appLocalizations.japanese},
      {'code': 'ku', 'name': appLocalizations.kurdish},
      {'code': 'nl', 'name': appLocalizations.dutch},
      {'code': 'ru', 'name': appLocalizations.russian},
      {'code': 'ko', 'name': appLocalizations.korean},
    ];

    String tempSelectedLanguageCode = widget.selectedLanguageCode; // Temporarily selected language
    final double itemHeight = screenHeight * 0.07; // Approximate height of each language item
    // Maximum height of the language list, limited to 5 items if more are available.
    final double maxListHeight = languages.length > 5
        ? 5 * itemHeight
        : languages.length * itemHeight + (screenHeight * 0.01 * (languages.length - 1)); // Additional height for Radio padding

    final RestoreCallback restoreNavBar = Darkener.darken(factor: 0.5);

    await showGeneralDialog(
      context: context,
      barrierDismissible: true, // Allows dismissing the dialog by tapping outside
      barrierLabel: 'LanguageSelection', // Accessibility label
      transitionDuration: const Duration(milliseconds: 150), // Transition animation duration
      pageBuilder: (ctx, animation, secondaryAnimation) {
        // Builder for the dialog content
        return Center(
          child: Material(
            color: Colors.transparent, // Make the background transparent
            child: Container(
              width: screenWidth * 0.70, // Dialog width
              decoration: BoxDecoration(
                color: AppColors.secondaryColor, // Dialog background color
                borderRadius: BorderRadius.circular(16), // Rounded corners
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16), // Clip content to rounded corners
                child: StatefulBuilder( // For state changes within the dialog (e.g., Radio selection)
                  builder: (dialogContext, setStateDialog) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch content horizontally
                      mainAxisSize: MainAxisSize.min, // Size to fit content
                      children: [
                        SizedBox(height: screenHeight * 0.02), // Top padding
                        SvgPicture.asset(
                          'assets/icons/language.svg', // Language icon
                          width: screenWidth * 0.07,
                          height: screenWidth * 0.07,
                          colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn), // Icon color
                        ),
                        SizedBox(height: screenHeight * 0.008), // Spacing between icon and title
                        Text(
                          appLocalizations.language, // "Language" title
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor.inverted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Divider(thickness: 0.5, color: AppColors.quinaryColor.withOpacity(0.7)), // Separator line
                        // Language list
                        Container(
                          constraints: BoxConstraints(maxHeight: maxListHeight), // Max height for the list
                          child: ListView.builder(
                            shrinkWrap: true, // Size to fit content
                            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01), // Vertical padding within the list
                            itemCount: languages.length, // Number of languages
                            itemBuilder: (context, index) {
                              final lang = languages[index];
                              return Material(
                                color: Colors.transparent, // Transparent to remove ripple effect from Material
                                child: InkWell(
                                  onTap: () {
                                    if (kDebugMode) {
                                      print('[AppLanguageSection] Language item tapped: ${lang['name']}');
                                    }
                                    setStateDialog(() { // Update state within the dialog
                                      tempSelectedLanguageCode = lang['code']!;
                                    });
                                  },
                                  splashColor: Colors.transparent, // Remove splash effect
                                  highlightColor: Colors.transparent, // Remove highlight effect
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.01),
                                    child: Row(
                                      children: [
                                        Radio<String>(
                                          value: lang['code']!,
                                          groupValue: tempSelectedLanguageCode,
                                          onChanged: (value) {
                                            if (kDebugMode) {
                                              print('[AppLanguageSection] Radio changed to: $value');
                                            }
                                            setStateDialog(() {
                                              tempSelectedLanguageCode = value!;
                                            });
                                          },
                                          // Active (selected) Radio button color
                                          activeColor: AppColors.primaryColor.inverted, // Desired color (e.g., black or a dark theme-appropriate color)
                                          // Fill color for passive and active states
                                          fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                                            if (states.contains(MaterialState.selected)) {
                                              // For selected state, AppColors.primaryColor.inverted (like black)
                                              return AppColors.primaryColor.inverted;
                                            }
                                            // For unselected state, a lighter color
                                            return AppColors.primaryColor.inverted.withOpacity(0.6);
                                          }),
                                        ),
                                        Expanded( // Expanded to prevent text overflow
                                          child: Text(
                                            lang['name']!, // Language name
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.038,
                                              color: AppColors.primaryColor.inverted,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Divider(thickness: 0.5, color: AppColors.quinaryColor.withOpacity(0.7), height: 1), // Bottom separator
                        // "Done" button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: AppColors.senaryColor.withOpacity(0.1), // Light splash for the button
                            highlightColor: AppColors.senaryColor.withOpacity(0.1),
                            onTap: () {
                              if (kDebugMode) {
                                print('[AppLanguageSection] "Done" button tapped. Selected language: $tempSelectedLanguageCode');
                              }
                              // --- FIX: Apply changes in the correct order ---
                              // 1. Notify the parent (SettingsScreen) about the new language.
                              widget.onLanguageChanged(tempSelectedLanguageCode);

                              // 2. Clear the central model data cache to force a reload with the new language.
                              ModelData.clearCache();
                              debugPrint("[AppLanguageSection] ModelData cache cleared due to language change.");

                              // 3. Close the dialog.
                              Navigator.of(ctx).pop();
                            },
                            child: Container(
                              height: screenHeight * 0.065,
                              alignment: Alignment.center,
                              child: Text(
                                appLocalizations.done, // "Done"
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
      // Transition animation for the dialog
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    ).whenComplete(() {
      // Actions to perform when the dialog is closed (for any reason)
      if (kDebugMode) {
        print('[AppLanguageSection] Language selection dialog closed.');
      }
      restoreNavBar();
      widget.onDialogStateChanged(false); // Notify that the dialog is closed
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = widget.appLocalizations;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (kDebugMode) {
      print('[AppLanguageSection] Building widget. Selected language: ${widget.selectedLanguageCode}');
    }

    // Main view of the language selection section
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align titles to the left
      children: [
        // Section title: "Language"
        Text(
          appLocalizations.language,
          style: GoogleFonts.roboto(
            color: AppColors.primaryColor.inverted,
            fontSize: screenWidth * 0.05, // Title font size
            fontWeight: FontWeight.w600, // Title font weight
          ),
        ),
        SizedBox(height: screenHeight * 0.01), // Spacing between title and description
        // Section description
        Text(
          appLocalizations.languageDescription,
          style: GoogleFonts.roboto(color: AppColors.quinaryColor, fontSize: screenWidth * 0.035),
        ),
        SizedBox(height: screenHeight * 0.02), // Spacing between description and button
        // Language selection button
        Material(
          color: AppColors.secondaryColor, // Button background color
          borderRadius: BorderRadius.circular(10.0), // Button corner radius
          clipBehavior: Clip.antiAlias, // Clip content to bounds
          child: InkWell(
            onTap: _showLanguageSelectionDialog, // Open dialog on tap
            borderRadius: BorderRadius.circular(10.0), // Also for splash effect
            splashColor: AppColors.quaternaryColor.withOpacity(0.3), // Tap effect color
            child: Container(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.04), // Button inner padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space items out
                children: [
                  // Name of the selected language
                  Text(
                    _getLocalizedLanguageName(widget.selectedLanguageCode),
                    style: GoogleFonts.roboto(
                        color: AppColors.primaryColor.inverted,
                        fontSize: screenWidth * 0.041111, // Text font size
                        fontWeight: FontWeight.w500 // Text font weight
                    ),
                  ),
                  // Arrow icon on the right
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