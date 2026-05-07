// lib/settings/sections/anonymous.dart

import 'package:cortex/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app.dart';
import '../../login/upgrade.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';

class AnonymousUpgradePanel extends StatelessWidget {
  const AnonymousUpgradePanel({super.key});

  void _openUpgradeScreen(BuildContext context) {
    navigateToScreen(UpgradeAccountScreen(), direction: Offset(0, 1));
  }

  @override
  Widget build(BuildContext context) {
    // ThemeProvider is watched by parent SettingsScreen — no need to re-watch here.

    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(screenWidth * 0.05),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor.withValues(alpha: 0.15),
                AppColors.secondaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryColor.inverted.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Icon and Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified,
                      color: AppColors.primaryColor.inverted,
                      size: screenWidth * 0.07),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    l10n.upgradeAccountTitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor.inverted,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.03),

              // Description
              Text(
                l10n.upgradeAccountDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: AppColors.quinaryColor,
                  height: 1.4,
                ),
              ),
              SizedBox(height: screenWidth * 0.05),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _openUpgradeScreen(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor.inverted,
                    foregroundColor: AppColors.primaryColor,
                    padding:
                    EdgeInsets.symmetric(vertical: screenWidth * 0.035),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    l10n.createAccount,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenWidth * 0.04),
      ],
    );
  }
}
