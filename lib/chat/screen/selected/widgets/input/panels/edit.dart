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
    final localizations = AppLocalizations.of(context)!;

    return SlideTransition(
      position: slideAnimation,
      child: Container(
        width: screenWidth,
        height: screenHeight * 0.05,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(screenWidth * 0.04),
            topRight: Radius.circular(screenWidth * 0.04),
          ),
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: screenWidth * 0.0025,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/edit.svg',
              width: screenWidth * 0.05,
              height: screenWidth * 0.05,
              colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
            ),
            Expanded(
              child: Text(
                localizations.editingNotification,
                style: TextStyle(
                  color: AppColors.primaryColor.inverted,
                  fontSize: screenWidth * 0.035,
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
                  size: screenWidth * 0.05,
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