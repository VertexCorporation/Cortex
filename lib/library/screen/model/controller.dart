// lib/library/screen/model/controller.dart

import 'package:cortex/analytics/service.dart';
import 'package:cortex/library/screen/model/widgets/appbar.dart';
import 'package:cortex/library/screen/model/widgets/banner.dart';
import 'package:cortex/library/screen/model/widgets/body.dart';
import 'package:cortex/library/screen/model/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme.dart';
import '../../../fog.dart';
import '../../providers/details.dart';
import '../../providers/local.dart';

/// The entry point for the Model Detail Screen.
///
/// Its primary responsibility is to receive a model ID and set up the
/// corresponding `ModelDetailProvider` which will manage the screen's state
/// and business logic. It then delegates the UI rendering to `ModelDetailContent`.
class ModelDetailPage extends StatelessWidget {
  final String id;

  const ModelDetailPage({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    // Log screen view
    AnalyticsService().logModelDetailScreen(id);

    // We create the provider here, directly in a standard ChangeNotifierProvider.
    return ChangeNotifierProvider<ModelDetailProvider>(
      create: (context) {
        // Read the download manager for this specific model ID.
        final downloadManager =
            context.read<ModelLocalStateProvider>().downloadManagers[id];

        // Create the provider instance, passing all required dependencies
        // from the context via its constructor.
        return ModelDetailProvider(
          modelId: id,
          context: context,
          downloadManager: downloadManager,
        );
      },
      // The child of the provider is the view that will consume its state.
      child: const ModelDetailContent(),
    );
  }
}

/// Provider-backed detail content, owning the scroll and variant animation state.
///
/// This is a clean pattern to supply a TickerProvider to a widget tree
/// that is otherwise stateless, without cluttering the main view logic.
class ModelDetailContent extends StatefulWidget {
  const ModelDetailContent({super.key});

  @override
  State<ModelDetailContent> createState() => _ModelDetailContentState();
}

class _ModelDetailContentState extends State<ModelDetailContent>
    with TickerProviderStateMixin {
  final GlobalKey<DetailAppBarState> _appBarKey =
      GlobalKey<DetailAppBarState>();

  // A controller to manage the scroll position for the fog effect.
  late final ScrollController _scrollController;
  late final AnimationController _variantFade;
  int _selectionRevision = 0;

  Future<void> _selectVariant(String id) async {
    final revision = ++_selectionRevision;
    try {
      // Fade out the current provider values before committing the next variant.
      // A newer request cancels this ticker and wins without adding any routes.
      await _variantFade.reverse().orCancel;
      if (!mounted || revision != _selectionRevision) return;
      context.read<ModelDetailProvider>().selectVariant(context, id);
      await _variantFade.forward().orCancel;
    } on TickerCanceled {
      // Rapid selection or disposal superseded this transition.
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _variantFade = AnimationController(
        vsync: this, value: 1, duration: const Duration(milliseconds: 150));
  }

  @override
  void dispose() {
    _variantFade.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pass the key and the controller to the ModelDetailView
    return ModelDetailView(
      appBarKey: _appBarKey,
      variantFade: _variantFade,
      onVariantSelected: _selectVariant,
      scrollController: _scrollController,
    );
  }
}

class ModelDetailView extends StatelessWidget {
  final GlobalKey<DetailAppBarState> appBarKey;
  final ScrollController scrollController;
  final Animation<double> variantFade;
  final ValueChanged<String> onVariantSelected;

  const ModelDetailView({
    super.key,
    required this.appBarKey,
    required this.scrollController,
    required this.variantFade,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ModelDetailProvider>();
    final screenHeight = MediaQuery.sizeOf(context).height;

    void handlePop() {
      Navigator.of(context)
          .pop(provider.didBaseModelChange ? 'model_updated' : null);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        if (provider.isButtonLocked) return;
        final appBarState = appBarKey.currentState;
        if (appBarState != null && appBarState.isPanelOpen) {
          await appBarState.dismissVariantOverlay();
          if (!context.mounted) return;
          handlePop();
        } else {
          handlePop();
        }
      },
      child: Builder(builder: (context) {
        final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
        return AnimatedPadding(
          padding: EdgeInsets.only(bottom: bottomInset),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: AppColors.background,
            extendBodyBehindAppBar: true,
            appBar: DetailAppBar(
              context: context,
              key: appBarKey,
              provider: provider,
              onBackPressed: handlePop,
              onVariantSelected: onVariantSelected,
              scrollController: scrollController,
            ),
            bottomNavigationBar: AnimatedBuilder(
              animation: variantFade,
              builder: (context, child) => IgnorePointer(
                ignoring: variantFade.status != AnimationStatus.completed,
                child: child,
              ),
              child: FadeTransition(
                  opacity: variantFade, child: const BottomActionButtons()),
            ),
            body: SizedBox.expand(
              child: Stack(
                children: [
                  ScrollFog(
                    scrollController: scrollController,
                    topFogHeight:
                        MediaQuery.paddingOf(context).top + kToolbarHeight,
                    showTop: true,
                    bottomFogHeight: screenHeight * 0.06,
                    showBottom: true,
                    child: FadeTransition(
                      opacity: variantFade,
                      child: BodyContent(
                        key: const ValueKey('content'),
                        provider: provider,
                        scrollController: scrollController,
                      ),
                    ),
                  ),
                  // Position the banners at the bottom of the screen.
                  // They are now managed and dismissed from within the WarningOverlays widget.
                  Positioned(
                    bottom: screenHeight * 0.01,
                    left: 0,
                    right: 0,
                    child: WarningOverlays(provider: provider),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
