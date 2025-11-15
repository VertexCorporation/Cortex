// lib/chat/screen/unselected/widgets/search.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';

/// A sophisticated search bar widget that now includes an adjacent filter button.
/// The text field has a modern design with a background fill and a distinct border.
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations localizations;
  final VoidCallback? onFilterTap; // Callback for the new filter button

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.localizations,
    this.onFilterTap, // Optional: to be implemented later
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // --- DYNAMIC SIZING CONSTANTS ---
    final double borderRadiusValue = screenWidth * 0.04; // e.g., ~16 on a 400px wide screen
    final double horizontalSpacing = screenWidth * 0.03; // e.g., ~12
    final double buttonPadding = screenWidth * 0.03;
    final double textFieldVerticalPadding = screenWidth * 0.02; // e.g., ~8

    return Row(
      children: [
        // The TextField is wrapped in Expanded to fill the available horizontal space.
        Expanded(
          child: TextField(
            controller: controller,
            cursorColor: AppColors.primaryColor.inverted,
            style: TextStyle(
              color: AppColors.primaryColor.inverted,
              fontSize: screenWidth * 0.04,
            ),
            decoration: InputDecoration(
              hintText: localizations.searchHint,
              hintStyle: TextStyle(
                color: AppColors.primaryColor.inverted.withValues(alpha: 0.6),
                fontSize: screenWidth * 0.04,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.primaryColor.inverted.withValues(alpha: 0.8),
                size: screenWidth * 0.06,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: EdgeInsets.symmetric(vertical: textFieldVerticalPadding),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadiusValue),
                borderSide: BorderSide(
                  color: AppColors.border,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadiusValue),
                borderSide: BorderSide(
                  color: AppColors.border,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadiusValue),
                borderSide: BorderSide(
                  color: AppColors.primaryColor.inverted,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: horizontalSpacing), // Spacing between search bar and filter button

        // --- Filter Button ---
        // A stylish, circular button with an icon.
        InkWell(
          onTap: onFilterTap ?? () {},
          borderRadius: BorderRadius.circular(borderRadiusValue),
          splashColor: AppColors.primaryColor.withValues(alpha: 0.1),
          highlightColor: AppColors.primaryColor.withValues(alpha: 0.05),
          child: Container(
            padding: EdgeInsets.all(buttonPadding),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(borderRadiusValue),
              border: Border.all(
                color: AppColors.border,
                width: 1.0,
              ),
            ),
            child: Icon(
              Icons.filter_center_focus,
              size: screenWidth * 0.06,
              color: AppColors.primaryColor.inverted,
            ),
          ),
        ),
      ],
    );
  }
}