// lib/news/search.dart

import 'package:flutter/material.dart';
import 'package:cortex/theme.dart';
import '../app.dart';

class NewsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;
  final FocusNode? focusNode;

  const NewsSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.hintText,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.sizeOf(context).width;
    final bool isDesktop = w >= 800;
    final bool isTablet = w >= 600 && !isDesktop;

    // --- Styling Logic ---
    final EdgeInsets outerPadding = isDesktop
        ? const EdgeInsets.only(top: 24, bottom: 8, left: 2, right: 2)
        : isTablet
            ? const EdgeInsets.only(top: 40, bottom: 8, left: 2, right: 2)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    // Dimensions
    final double iconSize = isDesktop ? 22.0 : (isTablet ? 36.0 : w * .06);
    final double borderRadius = isDesktop ? 16.0 : (isTablet ? 24.0 : 16.0);
    final double maxBarWidth =
        isDesktop ? 500 : (isTablet ? 700 : double.infinity);
    final double? fontSize = isDesktop ? 16.0 : (isTablet ? 22.0 : null);

    final EdgeInsets contentPadding = isDesktop
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
        : isTablet
            ? const EdgeInsets.symmetric(horizontal: 30, vertical: 26)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 16);

    final Color contentColor = AppColors.primaryColor.inverted;
    final Color fillColor = AppColors.secondaryColor;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxBarWidth),
        padding: outerPadding,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          style: TextStyle(
            color: contentColor,
            fontSize: fontSize,
          ),
          cursorColor: contentColor,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: contentColor.withValues(alpha: 0.5),
              fontSize: fontSize,
            ),
            prefixIcon: Icon(
              Icons.search,
              size: iconSize,
              color: contentColor,
            ),
            filled: true,
            fillColor: fillColor,
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide.none,
            ),
            contentPadding: contentPadding,
          ),
        ),
      ),
    );
  }
}
