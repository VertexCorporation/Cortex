// lib/settings/sections/theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../darkener.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';

/// Theme selection section in settings.
class AppThemeSection extends StatelessWidget {
  const AppThemeSection({super.key});

  String _getLocalizedThemeName(
      AppLocalizations localizations, String themeCode) {
    return switch (themeCode) {
      AppTheme.dark => localizations.darkTheme,
      _ => localizations.lightTheme,
    };
  }

  Future<void> _showThemeSelectionDialog(BuildContext context) async {
    final themeProvider = context.read<ThemeProvider>();
    final appLocalizations = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double scale = screenWidth / 400.0;

    final themesList = AppTheme.all
        .map((code) => {
              'code': code,
              'name': _getLocalizedThemeName(appLocalizations, code),
            })
        .toList();

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
              width: (screenWidth * 0.8).clamp(0, 500 * scale),
              decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(16 * scale)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16 * scale),
                child: StatefulBuilder(
                  builder: (dialogContext, setStateDialog) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 20 * scale),
                        SvgPicture.asset(
                          'assets/icons/theme.svg',
                          width: 30 * scale,
                          height: 30 * scale,
                          colorFilter: ColorFilter.mode(
                              AppColors.primaryColor.inverted, BlendMode.srcIn),
                        ),
                        SizedBox(height: 10 * scale),
                        Text(
                          appLocalizations.theme,
                          style: TextStyle(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor.inverted),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10 * scale),
                        Divider(
                            height: 1,
                            thickness: 0.5,
                            color:
                                AppColors.quinaryColor.withValues(alpha: 0.7)),
                        ConstrainedBox(
                          constraints:
                              BoxConstraints(maxHeight: screenHeight * 0.4),
                          child: GridView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(
                                vertical: 10 * scale, horizontal: 10 * scale),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12 * scale,
                              mainAxisSpacing: 12 * scale,
                              childAspectRatio: 0.9,
                            ),
                            itemCount: themesList.length,
                            itemBuilder: (context, index) {
                              final theme = themesList[index];
                              final String themeCode = theme['code'] as String;
                              final bool isSelected =
                                  tempSelectedTheme == themeCode;
                              final themeColors =
                                  AppColors.getThemeColors(themeCode);

                              return GestureDetector(
                                onTap: () {
                                  if (!isSelected) {
                                    HapticFeedback.lightImpact();
                                    setStateDialog(
                                        () => tempSelectedTheme = themeCode);
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    color: themeColors.background,
                                    borderRadius:
                                        BorderRadius.circular(12 * scale),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryColor.inverted
                                          : AppColors.quinaryColor
                                              .withValues(alpha: 0.2),
                                      width: isSelected ? 3 * scale : 1 * scale,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                                color: AppColors
                                                    .primaryColor.inverted
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 8 * scale)
                                          ]
                                        : [],
                                  ),
                                  child: Stack(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Container(
                                            height: 24 * scale,
                                            decoration: BoxDecoration(
                                              color: themeColors.secondaryColor,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(
                                                          11 * scale)),
                                            ),
                                          ),
                                          SizedBox(height: 8 * scale),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8 * scale),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                width: 40 * scale,
                                                height: 12 * scale,
                                                decoration: BoxDecoration(
                                                  color: themeColors
                                                      .quaternaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4 * scale),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 6 * scale),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8 * scale),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                width: 50 * scale,
                                                height: 12 * scale,
                                                decoration: BoxDecoration(
                                                  color:
                                                      themeColors.senaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4 * scale),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 6 * scale),
                                            decoration: BoxDecoration(
                                              color: themeColors.secondaryColor
                                                  .withValues(alpha: 0.9),
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      bottom: Radius.circular(
                                                          11 * scale)),
                                            ),
                                            child: Text(
                                              theme['name'] as String,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 13 * scale,
                                                fontWeight: FontWeight.bold,
                                                color: themeColors
                                                    .primaryColor.inverted,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: 4 * scale,
                                          right: 4 * scale,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColors
                                                  .primaryColor.inverted,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.check_circle,
                                                color:
                                                    themeColors.secondaryColor,
                                                size: 20 * scale),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
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
                              Navigator.of(ctx).pop(tempSelectedTheme);
                            },
                            child: Container(
                              height: 50 * scale,
                              alignment: Alignment.center,
                              child: Text(
                                appLocalizations.done,
                                style: TextStyle(
                                    fontSize: 16 * scale,
                                    color: AppColors.senaryColor,
                                    fontWeight: FontWeight.w500),
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

    if (selectedThemeCode == null ||
        selectedThemeCode == themeProvider.currentTheme) {
      return;
    }

    themeProvider.changeTheme(selectedThemeCode);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();
    final currentThemeName =
        _getLocalizedThemeName(appLocalizations, themeProvider.currentTheme);

    final screenWidth = MediaQuery.of(context).size.width;
    final double scale = screenWidth / 400.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.theme,
          style: TextStyle(
              color: AppColors.primaryColor.inverted,
              fontSize: 18 * scale,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8 * scale),
        Text(
          appLocalizations.themeDescription,
          style: TextStyle(color: AppColors.quinaryColor, fontSize: 14 * scale),
        ),
        SizedBox(height: 16 * scale),
        Material(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(10.0 * scale),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              _showThemeSelectionDialog(context);
            },
            borderRadius: BorderRadius.circular(10.0 * scale),
            splashColor: AppColors.quaternaryColor.withValues(alpha: 0.3),
            child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: 16 * scale, horizontal: 16 * scale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentThemeName,
                    style: TextStyle(
                        color: AppColors.primaryColor.inverted,
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w500),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      color: AppColors.primaryColor.inverted, size: 16 * scale),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
