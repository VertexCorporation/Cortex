// lib/screens/models/screen/new/widgets/form.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import '../../../../../theme.dart';

/// A reusable form section widget for the model creation process.
class CreationFormSection extends StatelessWidget {
  final String title;
  final String description;
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final int maxLines;

  const CreationFormSection({
    super.key,
    required this.title,
    required this.description,
    required this.controller,
    required this.hintText,
    this.maxLength = 1000,
    this.maxLines = 5,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final bool isTablet = screenWidth >= 600;

    // --- TABLET OPTIMIZATIONS ---
    final double titleSize = isTablet ? 26.0 : screenWidth * 0.05;
    final double descSize = isTablet ? 18.0 : screenWidth * 0.035;
    final double borderRadius = isTablet ? 16.0 : screenWidth * 0.025;
    final double inputTextSize = isTablet ? 18.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Section Title ---
        Text(
          title,
          style: TextStyle(
            color: AppColors.primaryColor.inverted,
            fontSize: titleSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenHeight * 0.005),

        // --- Section Description ---
        Text(
          description,
          style: TextStyle(
            color: AppColors.quinaryColor,
            fontSize: descSize,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),

        // --- Text Input Field ---
        TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          style: TextStyle(
              color: AppColors.primaryColor.inverted, fontSize: inputTextSize),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
                color: AppColors.quinaryColor, fontSize: inputTextSize),
            filled: true,
            fillColor: AppColors.background,
            counterText: '',
            // Taller input field on tablet
            contentPadding: EdgeInsets.symmetric(
                horizontal: 16, vertical: isTablet ? 20 : 12),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryColor.inverted),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ),
      ],
    );
  }
}