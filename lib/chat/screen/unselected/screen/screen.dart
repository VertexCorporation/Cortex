// lib/chat/screen/unselected/screen/screen.dart

import 'package:cortex/chat/screen/unselected/screen/search.dart';
import 'package:cortex/errorview.dart';
import 'package:cortex/models/backend/data.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../notifications.dart';
import '../cards.dart';

/// A widget that displays the model selection grid.
///
/// It handles multiple states:
/// 1. `isLoading`: Shows a shimmer placeholder grid.
/// 2. `isSearchEmpty`: Shows an "empty state" message when a search yields no results.
/// 3. `Normal`: Displays the grid of available models.
/// A smooth `AnimatedSwitcher` handles transitions between these states.
class SelectionScreen extends StatelessWidget {
  final TextEditingController searchController;
  final List<ModelInfo> allModels;
  final List<ModelInfo> filteredModels;
  final VoidCallback onReloadModels;
  final bool hasInternetConnection;
  final bool conversationLimitReached;
  final Function(ModelInfo) onSelectModel;
  final VoidCallback onScrollToBottom;
  final AppLocalizations localizations;
  final bool isServerSideModel;
  final bool isLoading;

  const SelectionScreen({
    Key? key,
    required this.searchController,
    required this.allModels,
    required this.filteredModels,
    required this.onReloadModels,
    required this.hasInternetConnection,
    required this.conversationLimitReached,
    required this.onSelectModel,
    required this.onScrollToBottom,
    required this.localizations,
    required this.isServerSideModel,
    required this.isLoading,
  }) : super(key: key);

  /// Builds the shimmer loading placeholder grid.
  ///
  /// This widget provides visual feedback to the user that content is being loaded.
  /// A unique [ValueKey] is used to help the `AnimatedSwitcher` differentiate it from the actual content.
  Widget _buildShimmerGrid(BuildContext context) {
    return GridView.builder(
      key: const ValueKey<String>('shimmer_grid'),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: 15, // Display a fixed number of shimmer cards for a consistent look.
      itemBuilder: (context, index) {
        return const ShimmerModelCard();
      },
    );
  }

  /// Builds the main grid displaying the selectable models.
  ///
  /// This widget is displayed once the `isLoading` flag is false.
  /// It uses a [ValueKey] that incorporates the search text to ensure the
  /// `AnimatedSwitcher` can track it correctly.
  Widget _buildModelGrid(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context, listen: false);

    return GridView.builder(
      key: ValueKey<String>('model_grid_${searchController.text}'),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredModels.length,
      itemBuilder: (context, index) {
        final model = filteredModels[index];
        final bool isServerModel = model.path == null;

        return ModelCard(
          model: model,
          hasInternet: hasInternetConnection,
          onTap: () {
            // Prevent interaction with server-side models if there is no internet.
            if (isServerModel && !hasInternetConnection) {
              notificationService.showNotification(
                message: localizations.internetRequired,
                isSuccess: false,
                bottomOffset: 0.1,
                duration: const Duration(seconds: 3),
              );
            } else {
              onSelectModel(model);
            }
          },
        );
      },
    );
  }

  /// Builds the view shown when a search returns no results.
  ///
  /// Provides clear feedback to the user that their search query did not match any models.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: ErrorView(
        key: const ValueKey<String>('empty_state'),
        title: localizations.noModelsFoundTitle,
        message: localizations.noModelsFoundMessage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearchEmpty = filteredModels.isEmpty && searchController.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          const SizedBox(height: 8.0),
          SearchBarWidget(
            controller: searchController,
            localizations: localizations,
          ),
          const SizedBox(height: 16),
          Expanded(
            // --- THE ARCHITECTURAL FIX ---
            // The `AnimatedSwitcher` is the key to solving the abrupt UI change.
            // It manages the transition between its children (shimmer, grid, or empty state)
            // using a smooth fade animation.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                // `FadeTransition` creates the desired smooth fade-in/fade-out effect.
                return FadeTransition(opacity: animation, child: child);
              },
              // The child of the switcher is determined by the current state of the screen.
              // Each potential child has a unique `key` so the switcher can identify
              // when a change has occurred.
              child: isLoading
                  ? _buildShimmerGrid(context)
                  : isSearchEmpty
                  ? _buildEmptyState(context)
                  : _buildModelGrid(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// A shimmer placeholder that perfectly mimics the layout and appearance of a [ModelCard].
///
/// This ensures a seamless and non-jarring visual transition when the actual data loads.
/// It uses the same layout calculations as [ModelCard] for consistency.
class ShimmerModelCard extends StatelessWidget {
  const ShimmerModelCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // These layout calculations are identical to `ModelCard` to ensure a perfect match.
    final totalHorizontalPadding = 12.0 * 2;
    final totalHorizontalSpacing = 8.0 * 2;
    final w = (MediaQuery.of(context).size.width -
        totalHorizontalPadding -
        totalHorizontalSpacing) /
        3;

    final imgSize = w * 0.7;
    final radiusOuter = imgSize * 0.15;
    final radiusInner = imgSize * 0.10;
    final borderW = w * 0.01;
    final gapBig = imgSize * 0.10;
    final gapSmall = imgSize * 0.05;

    // The `Shimmer` widget provides the animated "shine" effect over the placeholder shapes.
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(radiusOuter),
          border: Border.all(color: AppColors.border, width: borderW),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for the model image.
            Container(
              width: imgSize,
              height: imgSize,
              decoration: BoxDecoration(
                color: Colors.white, // The shimmer effect animates over this color.
                borderRadius: BorderRadius.circular(radiusInner),
              ),
            ),
            SizedBox(height: gapBig),
            // Placeholder for the model title.
            Container(
              height: 14,
              width: w * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: gapSmall),
            // Placeholder for the model producer.
            Container(
              height: 12,
              width: w * 0.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}