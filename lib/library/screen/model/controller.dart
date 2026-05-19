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
/// and business logic. It then delegates the UI rendering to `_ModelDetailViewWithTicker`.
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
        context
            .read<ModelLocalStateProvider>()
            .downloadManagers[id];

        // Create the provider instance, passing all required dependencies
        // from the context via its constructor.
        return ModelDetailProvider(
          modelId: id,
          context: context,
          downloadManager: downloadManager,
        );
      },
      // The child of the provider is the view that will consume its state.
      child: const _ModelDetailViewWithTicker(),
    );
  }
}

/// A private helper widget that provides a `TickerProvider` to the view.
///
/// This is a clean pattern to supply a TickerProvider to a widget tree
/// that is otherwise stateless, without cluttering the main view logic.
class _ModelDetailViewWithTicker extends StatefulWidget {
  const _ModelDetailViewWithTicker();

  @override
  State<_ModelDetailViewWithTicker> createState() =>
      __ModelDetailViewWithTickerState();
}

class __ModelDetailViewWithTickerState extends State<_ModelDetailViewWithTicker>
    with TickerProviderStateMixin {
  final GlobalKey<DetailAppBarState> _appBarKey =
  GlobalKey<DetailAppBarState>();

  // A controller to manage the scroll position for the fog effect.
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pass the key and the controller to the ModelDetailView
    return ModelDetailView(
      appBarKey: _appBarKey,
      scrollController: _scrollController,
    );
  }
}

class ModelDetailView extends StatelessWidget {
  final GlobalKey<DetailAppBarState> appBarKey;
  final ScrollController scrollController;

  const ModelDetailView({
    super.key,
    required this.appBarKey,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ModelDetailProvider>();
    final screenHeight = MediaQuery
        .sizeOf(context)
        .height;

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
      child: Builder(
          builder: (context) {
            final bottomInset = MediaQuery
                .viewInsetsOf(context)
                .bottom;
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
                  scrollController: scrollController,
                ),
                bottomNavigationBar: const BottomActionButtons(),
                body: SizedBox.expand(
                  child: Stack(
                    children: [
                      ScrollFog(
                        scrollController: scrollController,
                        topFogHeight: screenHeight * 0.02,
                        showTop: true,
                        showBottom: false,
                        child: BodyContent(
                          key: const ValueKey('content'),
                          provider: provider,
                          scrollController: scrollController,
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
          }
      ),
    );
  }
}
