// lib/chat/screen/unselected/controller.dart

import 'dart:ui';
import 'package:cortex/chat/screen/unselected/views/explore.dart';
import 'package:cortex/chat/screen/unselected/views/welcome.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/main.dart';
import 'package:cortex/library/backend/data/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../library/backend/data/entity.dart';
import 'package:cortex/theme.dart';


/// The main controller for the "unselected" chat screen state.
///
/// This widget acts as an orchestrator. It doesn't build detailed UI itself,
/// but instead decides which of its child "Views" (`WelcomeView` or `ExploreView`)
/// to display. It manages the top-level state for view switching, handles back
/// navigation logic, and provides the necessary data and callbacks down to its children.
class SelectionController extends StatefulWidget {
  final TextEditingController searchController;
  final List<ModelEntity> allModels;
  final List<ModelEntity> recentModels;
  final bool conversationLimitReached;
  final Function(ModelEntity, BuildContext) onSelectModel;
  final AppLocalizations localizations;
  final bool isLoading;
  final Map<String, dynamic>? userData;
  final Function(bool isShowingAllModels) onViewModeChanged;

  const SelectionController({
    super.key,
    required this.searchController,
    required this.allModels,
    required this.recentModels,
    required this.conversationLimitReached,
    required this.onSelectModel,
    required this.localizations,
    required this.isLoading,
    this.userData,
    required this.onViewModeChanged,
  });

  @override
  State<SelectionController> createState() => SelectionControllerState();
}

class SelectionControllerState extends State<SelectionController> {
  /// The single source of truth for which view is currently active.
  bool _isShowingExploreView = false;

  /// Switches the view to the initial welcome screen.
  void showWelcomeView() { // <-- RENAMED and PUBLIC
    if (mounted) {
      widget.searchController.clear();
      FocusScope.of(context).unfocus();
      setState(() => _isShowingExploreView = false);
      widget.onViewModeChanged(false);
    }
  }

  /// Switches the view to the model exploration/search screen.
  void showExploreView() { // <-- RENAMED and PUBLIC
    if (mounted) {
      setState(() => _isShowingExploreView = true);
      widget.onViewModeChanged(true);
    }
  }

  /// Handles the "Use Offline" feature request from the WelcomeView.
  /// This logic lives in the controller because it needs to decide whether to
  /// navigate to a different tab or switch to the ExploreView.
  Future<void> _onOfflineFeatureTap() async {
    final downloadedModelIds = (await UserModels.loadDownloadedModelPaths()).keys;
    if (downloadedModelIds.isEmpty) {
      // If no models are downloaded, navigate to the downloads tab.
      mainScreenKey.currentState?.onItemTapped(1, pulseOffline: true);
      return;
    }

    // This logic now correctly uses the passed-in `widget.allModels`.
    final bool hasDownloadedOfflineModels = widget.allModels.any((model) {
      return !model.isServerSide && downloadedModelIds.contains(model.id);
    });

    if (!mounted) return;

    if (hasDownloadedOfflineModels) {
      // If offline models exist, switch to the explore view.
      // We will need to pass the "offline" filter down to ExploreView.
      // For now, we just switch the view. The filter logic is in ExploreView.
      showExploreView();
      // A more advanced implementation could pass an initial filter:
      // setState(() => _initialFilterForExplore = FilterType.offline);
      // _showExploreView();
    } else {
      mainScreenKey.currentState?.onItemTapped(1, pulseOffline: true);
    }
  }

  /// Handles the "Start Dynamic Chat" request from the WelcomeView.
  void _onStartDynamicChat() {
    mainScreenKey.currentState?.startNewConversation(isDynamic: true);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    return PopScope(
      canPop: !_isShowingExploreView,

      onPopInvokedWithResult: (bool didPop, dynamic) {
        if (didPop) {
          return;
        }

        if (_isShowingExploreView) {
          showWelcomeView();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // The body is a Stack to layer the background effects behind the main content.
        body: Stack(
          children: [
            // Layer 1: The blurred background effects.
            ..._buildBackgroundEffects(context),

            // Layer 2: The main interactive content, wrapped in a SafeArea.
            SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  final slideAnimation = Tween<Offset>(
                    begin: const Offset(0.0, 0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic));
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: slideAnimation, child: child),
                  );
                },
                child: _isShowingExploreView
                    ? ExploreView(
                  key: const ValueKey('explore_view'),
                  searchController: widget.searchController,
                  allModels: widget.allModels,
                  localizations: widget.localizations,
                  isLoading: widget.isLoading,
                  conversationLimitReached: widget.conversationLimitReached,
                  onSelectModel: widget.onSelectModel,
                )
                    : WelcomeView(
                  key: const ValueKey('welcome_view'),
                  userData: widget.userData,
                  recentModels: widget.recentModels,
                  isLoading: widget.isLoading,
                  localizations: widget.localizations,
                  conversationLimitReached: widget.conversationLimitReached,
                  onSelectModel: widget.onSelectModel,
                  onShowExploreView: showExploreView,
                  onOfflineFeatureTap: _onOfflineFeatureTap,
                  onStartDynamicChat: _onStartDynamicChat,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the blurred background effects, which are part of the controller's layout.
  List<Widget> _buildBackgroundEffects(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return [
      AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: _isShowingExploreView ? 0.0 : 1.0,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
          child: Stack(
            children: [
              Positioned(
                top: screenHeight * 0.15,
                left: -screenWidth * 0.3,
                child: Container(
                  width: screenWidth * 0.6,
                  height: screenWidth * 0.6,
                  decoration: BoxDecoration(
                      color: AppColors.senaryColor.withValues(alpha: 0.4),
                      shape: BoxShape.circle),
                ),
              ),
              Positioned(
                top: screenHeight * 0.14,
                right: -screenWidth * 0.4,
                child: Container(
                  width: screenWidth * 0.8,
                  height: screenWidth * 0.8,
                  decoration: BoxDecoration(
                      color: AppColors.quaternaryColor.withValues(alpha: 0.3),
                      shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }
}