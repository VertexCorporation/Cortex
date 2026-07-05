// lib/arts/screen.dart

import 'dart:io';

import 'package:cortex/app.dart';
import 'package:cortex/arts/provider.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../appbar.dart';
import '../axon/inbox/logic/manager.dart';
import '../chat/messages/viewer.dart';
import '../main.dart';
import '../axon/inbox/logic/general.dart';
import '../chat/providers/input.dart';
import '../library/backend/data/entity.dart';
import '../library/backend/data/service.dart';

class ArtsScreen extends StatefulWidget {
  const ArtsScreen({super.key});

  @override
  State<ArtsScreen> createState() => _ArtsScreenState();
}

class _ArtsScreenState extends State<ArtsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ArtsProvider>().loadMedia();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context)!;
    final artsProvider = context.watch<ArtsProvider>();

    final Size screenSize = MediaQuery.sizeOf(context);
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final bool isDesktop = screenWidth >= 800;
    final double topSafeArea = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: CortexAppBar(
        leadingMode:
            isDesktop ? CortexLeadingMode.none : CortexLeadingMode.auto,
        titleText: l10n.arts,
      ),
      body: Stack(
        children: [
          // Background Gradient Blob (matching News screen — left side, behind content)
          Positioned(
            top: 0,
            left: -screenWidth * 0.2,
            child: Container(
              width: screenWidth * 0.82,
              height: screenHeight * 0.83,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.senaryColor.withValues(alpha: 0.3),
                    AppColors.background.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.7],
                  center: Alignment.center,
                  radius: 0.8,
                ),
              ),
            ),
          ),

          // Content
          artsProvider.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : artsProvider.isEmpty
                  ? _buildEmptyState(context, l10n, screenHeight)
                  : _buildGalleryGrid(context, artsProvider, topSafeArea),
        ],
      ),
    );
  }

  /// Empty state — centered icon + message (matching EmptyStateView style)
  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    double screenHeight,
  ) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double iconSize = screenWidth * 0.22;
    final double titleFontSize = screenWidth * 0.065;
    final double descFontSize = screenWidth * 0.042;
    final double titleSpacing = screenWidth * 0.04;
    final double descSpacing = screenWidth * 0.02;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              SvgPicture.asset(
                'assets/icons/inbox.svg',
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(
                  AppColors.tertiaryColor.withValues(alpha: 0.4),
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(height: titleSpacing),

              // Title
              Text(
                l10n.noArt,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.primaryColor.inverted,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: descSpacing),

              // Message
              Text(
                l10n.noArtDescription,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.tertiaryColor,
                  fontSize: descFontSize,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 3-column gallery grid
  Widget _buildGalleryGrid(
    BuildContext context,
    ArtsProvider artsProvider,
    double topSafeArea,
  ) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double padding = screenWidth * 0.04;
    final double spacing = 3.0;

    return CustomScrollView(
      slivers: [
        // Top spacer for appbar
        SliverToBoxAdapter(
          child: SizedBox(height: topSafeArea + kToolbarHeight + 16),
        ),

        // Grid
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = artsProvider.items[index];
                return _ArtTile(item: item);
              },
              childCount: artsProvider.items.length,
            ),
          ),
        ),

        // Bottom spacer
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
        ),
      ],
    );
  }
}

/// Individual art tile in the grid.
class _ArtTile extends StatelessWidget {
  final ArtItem item;

  const _ArtTile({required this.item});

  Future<void> _openSourceChatAndAttach({
    required File file,
    required bool isImage,
    required InboxViewModel inboxVM,
    required InputProvider inputProvider,
    required ModelService modelService,
    required String langCode,
  }) async {
    final mainState = mainScreenKey.currentState;
    if (mainState == null) {
      debugPrint('[Arts.Edit] MainScreenState is unavailable.');
      return;
    }

    ConversationManager? manager;
    final conversationId = item.conversationID.trim();
    if (conversationId.isNotEmpty) {
      manager = inboxVM.conversationManagers[conversationId] ??
          await ConversationManager.fromId(
            conversationId,
            langCode: langCode,
            modelService: modelService,
          );
    }

    if (manager != null) {
      debugPrint(
          '[Arts.Edit] Opening source conversation: ${manager.conversationID}');
      await mainState.openConversation(manager);
    } else {
      final fallbackModel = _resolveFallbackModel(modelService);
      if (fallbackModel != null) {
        debugPrint(
            '[Arts.Edit] Source conversation missing. Starting model: ${fallbackModel.id}');
        await mainState.startChatWithModel(fallbackModel);
      } else {
        debugPrint(
            '[Arts.Edit] Source conversation/model missing. Starting default chat.');
        mainState.startNewConversation();
        await Future<void>.delayed(const Duration(milliseconds: 450));
      }
      inputProvider.resetInputState();
    }

    inputProvider.addAttachment(file, isImage: isImage);
  }

  ModelEntity? _resolveFallbackModel(ModelService modelService) {
    final modelId = item.modelId?.trim();
    if (modelId == null || modelId.isEmpty) return null;

    final allModels = modelService.getCachedModelsSync();
    for (final model in allModels) {
      if (model.id == modelId) return model;
      if (model.variants?.containsKey(modelId) == true) return model;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        color: AppColors.senaryColor.withValues(alpha: 0.3),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (item.type) {
      case ArtType.image:
        return GestureDetector(
          onTap: () {
            final inboxVM = context.read<InboxViewModel>();
            final inputProvider = context.read<InputProvider>();
            final modelService = context.read<ModelService>();
            final langCode = Localizations.localeOf(context).languageCode;

            Navigator.of(context).push(PhotoViewer.route(
              File(item.path),
              onEditImage: (file) {
                _openSourceChatAndAttach(
                  file: File(file.path),
                  isImage: true,
                  inboxVM: inboxVM,
                  inputProvider: inputProvider,
                  modelService: modelService,
                  langCode: langCode,
                );
              },
            ));
          },
          child: Image.file(
            File(item.path),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            cacheHeight: 300,
            errorBuilder: (_, __, ___) =>
                _buildFallbackIcon(Icons.broken_image_rounded),
          ),
        );

      case ArtType.video:
        return GestureDetector(
          onTap: () {
            final inboxVM = context.read<InboxViewModel>();
            final inputProvider = context.read<InputProvider>();
            final modelService = context.read<ModelService>();
            final langCode = Localizations.localeOf(context).languageCode;

            Navigator.of(context).push(VideoViewer.route(
              item.path,
              onEditVideo: (path) {
                _openSourceChatAndAttach(
                  file: File(path),
                  isImage: false,
                  inboxVM: inboxVM,
                  inputProvider: inputProvider,
                  modelService: modelService,
                  langCode: langCode,
                );
              },
            ));
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: AppColors.senaryColor.withValues(alpha: 0.5),
              ),
              Center(
                child: Icon(
                  Icons.play_circle_filled_rounded,
                  color: AppColors.primaryColor.inverted.withValues(alpha: 0.7),
                  size: 36,
                ),
              ),
            ],
          ),
        );

      case ArtType.audio:
        return GestureDetector(
          onTap: () {
            final inboxVM = context.read<InboxViewModel>();
            final inputProvider = context.read<InputProvider>();
            final modelService = context.read<ModelService>();
            final langCode = Localizations.localeOf(context).languageCode;

            Navigator.of(context).push(AudioViewer.route(
              item.path,
              onEditAudio: (path) {
                _openSourceChatAndAttach(
                  file: File(path),
                  isImage: false,
                  inboxVM: inboxVM,
                  inputProvider: inputProvider,
                  modelService: modelService,
                  langCode: langCode,
                );
              },
            ));
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: AppColors.senaryColor.withValues(alpha: 0.5),
              ),
              Center(
                child: SvgPicture.asset(
                  'assets/icons/voice.svg',
                  width: 32,
                  height: 32,
                  colorFilter: ColorFilter.mode(
                    AppColors.primaryColor.inverted.withValues(alpha: 0.7),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildFallbackIcon(IconData icon) {
    return Center(
      child: Icon(
        icon,
        color: AppColors.tertiaryColor.withValues(alpha: 0.5),
        size: 28,
      ),
    );
  }
}
