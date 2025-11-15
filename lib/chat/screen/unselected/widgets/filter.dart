// lib/chat/screen/unselected/widgets/filter.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';

// This enum is defined in the controller, but we can redefine it here
// or move it to a shared file if it's used in multiple places.
// For now, let's keep it self-contained.
enum FilterType { all, online, offline, characters, custom }

/// Displays a modal bottom sheet for filtering models.
///
/// This function encapsulates the entire presentation and state management logic
/// for the filter selection UI, keeping the calling widget clean.
///
/// It takes the current active filter and returns the newly selected filter
/// via a callback function [onFilterChanged].
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
    builder: (BuildContext modalContext) {
      // Use a StatefulWidget inside the sheet to manage the tapped filter state.
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

/// The stateful content of the modal bottom sheet.
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

  Widget _buildFilterChip({
    required String title,
    required FilterType filter,
    required int index,
  }) {
    final bool isActive = _selectedFilter == filter;
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

          // Close the sheet after a short delay to show the selection feedback.
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
              vertical: widget.screenHeight * 0.012
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
    final filters = [
      {'title': widget.localizations.allModels, 'filter': FilterType.all},
      {'title': widget.localizations.onlineModels, 'filter': FilterType.online},
      {'title': widget.localizations.offlineModels, 'filter': FilterType.offline},
      {'title': widget.localizations.characterModels, 'filter': FilterType.characters},
      {'title': widget.localizations.customModels, 'filter': FilterType.custom},
    ];

    return Container(
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
          Container( // Drag handle
            width: widget.screenWidth * 0.1,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: widget.screenHeight * 0.025),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.05),
            child: Column(
              children: [
                Text(
                  widget.localizations.filters,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: widget.screenWidth * 0.05, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted),
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