// lib/chat/screen/unselected/widgets/search.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';

/// A sophisticated search bar widget that includes an adjacent filter button.
/// The layout adapts dynamically to the screen width, ensuring consistency
/// across mobile and tablet devices.
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations localizations;
  final VoidCallback? onFilterTap;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.localizations,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // --- DYNAMIC SIZING CONSTANTS ---
    // Scaled relative to screen width for responsiveness.

    final double borderRadiusValue = screenWidth * 0.04;

    // This prevents the search field and filter button from appearing
    // too close together on wider tablet screens.
    final double horizontalSpacing = screenWidth * 0.04;

    final double buttonPadding = screenWidth * 0.03;
    final double textFieldVerticalPadding = screenWidth * 0.02;

    return Row(
      children: [
        // The TextField is wrapped in Expanded to occupy all remaining horizontal space.
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
              prefixIcon: Padding(
                // Adds dynamic horizontal spacing around the icon.
                // This effectively increases the gap between the search icon and the hint text,
                // preventing them from looking crowded on larger tablet screens.
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                child: Icon(
                  Icons.search,
                  color: AppColors.primaryColor.inverted.withValues(alpha: 0.8),
                  size: screenWidth * 0.06,
                ),
              ),
              // We relax the default constraints to accommodate the extra padding
              // and the dynamic icon size, ensuring proper alignment.
              prefixIconConstraints: BoxConstraints(
                minWidth: screenWidth * 0.12,
                minHeight: 0,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: EdgeInsets.symmetric(vertical: textFieldVerticalPadding),
              // Unified border styling for all states
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

        // Dynamic spacing between search input and filter button
        SizedBox(width: horizontalSpacing),

        // --- Filter Button ---
        // A distinct, icon-only button designed to complement the search bar.
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