// lib/chat/screen/unselected/widgets/filter.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';

// Enum defining the available filter categories for the model list.
enum FilterType { all, online, offline, characters, custom }

/// Displays a modal bottom sheet for filtering models.
///
/// This function encapsulates the presentation and state management logic
/// for the filter selection UI. It ensures the sheet utilizes the full
/// screen width, which is particularly important for tablet layouts.
///
/// [onFilterChanged] callback is triggered when a new filter is selected.
void showModelFilterSheet({
  required BuildContext context,
  required AppLocalizations localizations,
  required FilterType activeFilter,
  required ValueChanged<FilterType> onFilterChanged,
}) {
  final screen = MediaQuery.of(context);
  final screenWidth = screen.size.width;
  final screenHeight = screen.size.height;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    // CRITICAL: Forces the bottom sheet to take the full width of the screen.
    // Without this, the sheet may center itself or shrink on larger tablet screens.
    constraints: const BoxConstraints(maxWidth: double.infinity),
    builder: (BuildContext modalContext) {
      return _FilterSheetContent(
        localizations: localizations,
        initialFilter: activeFilter,
        onFilterChanged: onFilterChanged,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        bottomPadding: screen.padding.bottom,
      );
    },
  );
}

/// The internal stateful widget for the filter sheet content.
/// Handles the selection animation and logic before returning the value.
class _FilterSheetContent extends StatefulWidget {
  final AppLocalizations localizations;
  final FilterType initialFilter;
  final ValueChanged<FilterType> onFilterChanged;
  final double screenWidth;
  final double screenHeight;
  final double bottomPadding;

  const _FilterSheetContent({
    required this.localizations,
    required this.initialFilter,
    required this.onFilterChanged,
    required this.screenWidth,
    required this.screenHeight,
    required this.bottomPadding,
  });

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent> {
  late FilterType _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  /// Builds a single selectable filter chip with entry animations.
  Widget _buildFilterChip({
    required String title,
    required FilterType filter,
    required int index,
  }) {
    final bool isActive = _selectedFilter == filter;

    // Staggered animation based on index
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0.0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedFilter = filter);
          widget.onFilterChanged(_selectedFilter);

          // Provides a brief delay before closing to allow visual feedback (ripple/color change).
          Future.delayed(const Duration(milliseconds: 250), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: widget.screenWidth * 0.045,
            vertical: widget.screenHeight * 0.012,
          ),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryColor.inverted : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.primaryColor.inverted.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: widget.screenWidth * 0.035,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.secondaryColor : AppColors.primaryColor.inverted,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definition of filter options
    final filters = [
      {'title': widget.localizations.allModels, 'filter': FilterType.all},
      {'title': widget.localizations.onlineModels, 'filter': FilterType.online},
      {'title': widget.localizations.offlineModels, 'filter': FilterType.offline},
      {'title': widget.localizations.characterModels, 'filter': FilterType.characters},
      {'title': widget.localizations.customModels, 'filter': FilterType.custom},
    ];

    return Container(
      // Ensures the container fills the constraints provided by the modal sheet
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: widget.screenHeight * 0.015),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Visual Drag Handle
          Container(
            width: widget.screenWidth * 0.1,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: widget.screenHeight * 0.025),

          // Filter Options Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.05),
            child: Column(
              children: [
                Text(
                  widget.localizations.filters,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: widget.screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor.inverted,
                  ),
                ),
                SizedBox(height: widget.screenHeight * 0.01),
                Text(
                  widget.localizations.filterPanelDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: widget.screenWidth * 0.035,
                    color: AppColors.primaryColor.inverted.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: widget.screenHeight * 0.02),

                // Flexible wrap for filter chips
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: widget.screenWidth * 0.025,
                  runSpacing: widget.screenWidth * 0.025,
                  children: List.generate(filters.length, (index) {
                    return _buildFilterChip(
                      title: filters[index]['title'] as String,
                      filter: filters[index]['filter'] as FilterType,
                      index: index,
                    );
                  }),
                ),
              ],
            ),
          ),
          SizedBox(height: widget.bottomPadding + widget.screenHeight * 0.02),
        ],
      ),
    );
  }
}