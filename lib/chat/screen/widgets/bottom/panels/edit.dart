// lib/chat/screen/selected/widgets/input/panels/edit.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';

class EditPanelWidget extends StatelessWidget {
  final Animation<Offset> slideAnimation;
  final VoidCallback onCancel;

  const EditPanelWidget({
    super.key,
    required this.slideAnimation,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isTablet = screenWidth >= 600;
    final localizations = AppLocalizations.of(context)!;

    // --- DYNAMIC SCALING ---
    // Using screenWidth for height calculations on tablet to maintain proportions

    // Height: Tablet 6% of width. Phone 5% of height.
    final double height = isTablet ? screenWidth * 0.06 : screenHeight * 0.05;

    // Icon: Tablet 3% of width. Phone 5%.
    final double iconSize = isTablet ? screenWidth * 0.03 : screenWidth * 0.05;

    // Text: Tablet 2.2% of width. Phone 3.5%.
    final double fontSize =
        isTablet ? screenWidth * 0.022 : screenWidth * 0.035;

    // Radius: Tablet 2%. Phone 4%.
    final double radius = isTablet ? screenWidth * 0.02 : screenWidth * 0.04;

    return SlideTransition(
      position: slideAnimation,
      child: Container(
        width: screenWidth,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: AppColors.border.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(radius),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/edit.svg',
              width: iconSize,
              height: iconSize,
              colorFilter: ColorFilter.mode(
                  AppColors.primaryColor.inverted, BlendMode.srcIn),
            ),
            Expanded(
              child: Text(
                localizations.editingNotification,
                style: TextStyle(
                  color: AppColors.primaryColor.inverted,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.007),
              child: GestureDetector(
                onTap: onCancel,
                child: Icon(
                  Icons.cancel,
                  size: iconSize,
                  color: AppColors.primaryColor.inverted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
