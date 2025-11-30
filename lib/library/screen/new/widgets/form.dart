// lib/screens/models/screen/new/widgets/form.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import '../../../../../theme.dart';

/// A reusable form section widget for the model creation process.
///
/// It standardizes the layout for sections that include a title, a description,
/// and a multi-line text input field. This is used for inputs like the
/// "AI Prompt" and "Model Explanation".
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Section Title ---
        Text(
          title,
          style: TextStyle(
            color: AppColors.primaryColor.inverted,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenHeight * 0.005),

        // --- Section Description ---
        Text(
          description,
          style: TextStyle(
            color: AppColors.quinaryColor,
            fontSize: screenWidth * 0.035,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),

        // --- Text Input Field ---
        TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          style: TextStyle(color: AppColors.primaryColor.inverted),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.quinaryColor),
            filled: true,
            fillColor: AppColors.primaryColor,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(screenWidth * 0.025),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(screenWidth * 0.025),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryColor.inverted),
              borderRadius: BorderRadius.circular(screenWidth * 0.025),
            ),
          ),
        ),
      ],
    );
  }
}