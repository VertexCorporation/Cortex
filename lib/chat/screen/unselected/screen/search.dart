// search.dart

import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/main.dart';

// --- MODIFIED: Converted to a simpler StatelessWidget.
class SearchBarWidget extends StatelessWidget {
  // --- MODIFIED: It only needs the controller and localizations.
  final TextEditingController controller;
  final AppLocalizations localizations;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.localizations,
  }) : super(key: key);

  // --- DELETED: All state management (_SearchBarWidgetState) is removed.

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return TextField(
      // --- MODIFIED: Uses the controller passed from the parent.
      controller: controller,
      cursorColor: AppColors.primaryColor.inverted,
      decoration: InputDecoration(
        hintText: localizations.searchHint,
        hintStyle: TextStyle(
          color: AppColors.primaryColor.inverted,
          fontSize: screenWidth * 0.04,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.primaryColor.inverted,
          size: screenWidth * 0.06,
        ),
        filled: true,
        fillColor: AppColors.quaternaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.border,
          ),
        ),
        contentPadding: EdgeInsets.zero,
      ),
      style: TextStyle(
        color: AppColors.primaryColor.inverted,
        fontSize: screenWidth * 0.04,
      ),
      // --- DELETED: onChanged is no longer needed here. The listener in
      // ChatScreenState handles all updates.
    );
  }
}