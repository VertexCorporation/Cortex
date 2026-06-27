// errorview.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/theme.dart';

class ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.title,
    required this.message,
    this.buttonText,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    assert((buttonText == null && onRetry == null) ||
        (buttonText != null && onRetry != null),
    'Both buttonText and onRetry must be provided together, or both must be null.');

    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/warning.svg',
              colorFilter: ColorFilter.mode(AppColors.septenaryColor, BlendMode.srcIn),
              width: screenWidth * 0.2,
            ),
            SizedBox(height: screenWidth * 0.06),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor.inverted,
              ),
            ),
            SizedBox(height: screenWidth * 0.03),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: AppColors.quinaryColor,
                height: 1.5,
              ),
            ),
            // If buttonText and onRetry are provided, the button is shown. Otherwise, it's hidden.
            if (buttonText != null && onRetry != null) ...[
              SizedBox(height: screenWidth * 0.08),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.septenaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: Size(screenWidth * 0.5, screenHeight * 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}