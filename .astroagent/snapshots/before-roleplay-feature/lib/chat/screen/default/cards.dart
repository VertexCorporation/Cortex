// lib/chat/screen/default/cards.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../app.dart';
import '../../../../theme.dart';

class DefaultCard extends StatelessWidget {
  final String text;
  final Widget iconWidget;
  final double height;
  final VoidCallback onTap;

  const DefaultCard({
    super.key,
    required this.text,
    required this.iconWidget,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final borderRadius = BorderRadius.circular(32);
    final contentColor = AppColors.primaryColor.inverted;

    return Material(
      color: AppColors.background,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        splashColor: AppColors.background.withValues(alpha: 0.1),
        highlightColor: contentColor.withValues(alpha: 0.05),
        child: Container(
          height: height,
          width: double.infinity,
          padding: EdgeInsets.only(
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: borderRadius,
            border: Border.all(color: AppColors.border, width: 1.0),
          ),
          child: Row(
            children: [
              // 1. Icon (Colored)
              iconWidget,

              SizedBox(width: screenWidth * 0.03),

              // 2. Text (Auto-scaling with FittedBox)
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: contentColor,
                      height: 1.0,
                    ),
                  ),
                ),
              ),

              SizedBox(width: screenWidth * 0.02),

              // 3. Arrow Icon (arrov.svg + Rotated 90 degrees)
              Transform.rotate(
                angle: -1.5708, // 90 degrees (Pi / 2)
                child: SvgPicture.asset(
                  'assets/icons/arrov.svg',
                  width: screenWidth * 0.05,
                  height: screenWidth * 0.04,
                  colorFilter: ColorFilter.mode(
                    contentColor.withValues(alpha: 0.6),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}