part of '../ai.dart';

class _AiHeader extends StatelessWidget {
  final Message message;
  final String avatarPath;
  final double scale;
  final Animation<double> thinkPulseAnim;
  final Animation<double> thinkRotateAnim;
  final Animation<double> headerEntryAnim;

  const _AiHeader({
    required this.message,
    required this.avatarPath,
    required this.scale,
    required this.thinkPulseAnim,
    required this.thinkRotateAnim,
    required this.headerEntryAnim,
  });

  @override
  Widget build(BuildContext context) {
    final modelService = context.read<ModelService>();
    final langCode = Localizations.localeOf(context).languageCode;
    final isSearching = message.isWebSearchActive && message.isThinking;

    final mId = message.model ?? '';
    final convProvider = context.read<ConversationProvider>();
    ModelEntity model;

    bool isDynamicConversationId(String? id) {
      final normalized = (id ?? '').trim().toLowerCase();
      return normalized == 'cortex/auto' || normalized == 'dynamic';
    }

    String? associatedUserModelId;
    final messagesList = convProvider.messages;
    final msgIndex = messagesList.indexOf(message);
    if (msgIndex >= 0) {
      for (int i = msgIndex - 1; i >= 0; i--) {
        if (messagesList[i].isUserMessage) {
          associatedUserModelId = messagesList[i].model;
          break;
        }
      }
    }

    final bool conversationStartedAsDynamic =
        isDynamicConversationId(convProvider.persistedModelId) ||
            isDynamicConversationId(associatedUserModelId);

    if (modelService.hasModelInCache(mId)) {
      model = modelService.getPreciseModelData(mId, langCode: langCode);
    } else if (convProvider.persistedModelId == mId &&
        convProvider.persistedModelTitle != null) {
      model = ModelEntity.fromMap({
        'id': mId,
        'title': convProvider.persistedModelTitle,
        'imagePath': convProvider.persistedModelImagePath,
        'producer': 'Unknown',
        'type': 'online',
        'category': 'online',
      }, langCode);
    } else {
      model = modelService.getPreciseModelData(mId, langCode: langCode);
    }

    String formatModelId(String rawId) {
      if (rawId.isEmpty) return 'Cortex';
      if (rawId == 'cortex/auto' || rawId == 'dynamic') return 'Cortex';
      String name = rawId.contains('/') ? rawId.split('/').last : rawId;
      return name.split(RegExp(r'[-_]')).map((w) {
        if (w.isEmpty) return '';
        if (w.toLowerCase() == 'gpt') return 'GPT';
        return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
      }).join(' ');
    }

    final bool isCortexDynamic = isDynamicConversationId(mId) ||
        message.isServerFallback ||
        conversationStartedAsDynamic;

    String textToDisplay = '';
    if (isCortexDynamic) {
      textToDisplay = 'Cortex';
    } else if (model.category == 'self' || model.category == 'roleplay') {
      textToDisplay = model.displayTitle.isNotEmpty
          ? model.displayTitle
          : formatModelId(mId);
    } else {
      // SERIES NAME PRIORITY: Always show the series name instead of
      // the individual variant title. The user should see "Gemini"
      // not "Gemini 2.5 Pro" in the AI message header.
      final parentSeries = ModelDataUtils.findParentSeriesData(
        mId,
        langCode: langCode,
        modelService: modelService,
      );
      final isRealVariantSeries = parentSeries != null &&
          parentSeries.variants != null &&
          parentSeries.variants!.isNotEmpty;
      if (isRealVariantSeries) {
        final seriesTitle = parentSeries.series ?? parentSeries.displayTitle;
        if (seriesTitle.isNotEmpty && seriesTitle != 'Unknown Model') {
          textToDisplay = seriesTitle;
        } else {
          textToDisplay = model.displayTitle.isNotEmpty &&
                  model.displayTitle != 'Unknown Model'
              ? model.displayTitle
              : formatModelId(mId);
        }
      } else if (model.displayTitle == 'Unknown Model' ||
          model.displayTitle.isEmpty) {
        textToDisplay = formatModelId(mId);
      } else if (model.displayTitle == model.id) {
        textToDisplay = formatModelId(mId);
      } else {
        textToDisplay = model.displayTitle;
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: thinkPulseAnim,
          child: RotationTransition(
            turns: thinkRotateAnim,
            child: RepaintBoundary(
              child: SvgPicture.asset(
                'assets/cortex.svg',
                width: 16 * scale,
                height: 16 * scale,
                colorFilter: ColorFilter.mode(
                  AppColors.primaryColor.inverted,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final offset = Tween<Offset>(
              begin: const Offset(-0.35, 0),
              end: Offset.zero,
            ).animate(animation);
            return ClipRect(
              child: FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offset, child: child),
              ),
            );
          },
          child: isSearching
              ? _SearchingLabel(key: const ValueKey('searching'), scale: scale)
              : const SizedBox.shrink(key: ValueKey('not_searching')),
        ),
        SizeTransition(
          sizeFactor: headerEntryAnim,
          axis: Axis.horizontal,
          alignment: Alignment.centerLeft,
          child: FadeTransition(
            opacity: headerEntryAnim,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 8 * scale),
                // Hide the avatar when in dynamic/Cortex mode to avoid
                // showing two identical cortex.svg icons side by side.
                if (!isCortexDynamic) _buildAvatar(scale * 0.7),
                if (textToDisplay.isNotEmpty) ...[
                  if (!isCortexDynamic) SizedBox(width: 6 * scale),
                  if (!isCortexDynamic)
                    Text("•",
                        style: TextStyle(
                            color: AppColors.primaryColor.inverted
                                .withValues(alpha: 0.5),
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.bold)),
                  if (!isCortexDynamic) SizedBox(width: 6 * scale),
                  Text(
                    ModelDataUtils.formatModelName(textToDisplay),
                    style: TextStyle(
                        color: AppColors.primaryColor.inverted
                            .withValues(alpha: 0.7),
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(double s) {
    final containerSize = 30 * s;
    final iconSize = 24 * s;
    final fallbackWidget = SvgPicture.asset('assets/icons/self.svg',
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
        colorFilter:
            ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn));
    Widget imageWidget;
    if (avatarPath.isEmpty || avatarPath.endsWith('self.svg')) {
      imageWidget = fallbackWidget;
    } else {
      final isSvg = avatarPath.toLowerCase().endsWith('.svg');
      final isAsset = avatarPath.startsWith('assets/');
      if (isSvg) {
        imageWidget = isAsset
            ? SvgPicture.asset(avatarPath,
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(
                    AppColors.primaryColor.inverted, BlendMode.srcIn),
                fit: BoxFit.contain,
                placeholderBuilder: (_) => fallbackWidget)
            : SvgPicture.file(File(avatarPath),
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(
                    AppColors.primaryColor.inverted, BlendMode.srcIn),
                fit: BoxFit.contain,
                placeholderBuilder: (_) => fallbackWidget);
      } else {
        ImageProvider imageProvider = isAsset
            ? AssetImage(avatarPath) as ImageProvider
            : FileImage(File(avatarPath));
            
        // PERF: Prevent GC Jank on scrolling chat history.
        // Limit decode size of high-res custom model avatars in chat.
        final int cacheSize = (containerSize * 3).toInt().clamp(50, 200);
        imageProvider = ResizeImage(imageProvider, width: cacheSize, height: cacheSize);

        imageWidget = Image(
            image: imageProvider,
            width: containerSize,
            height: containerSize,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallbackWidget);
      }
    }
    return Container(
      padding: EdgeInsets.all(1.5 * s),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: AppColors.primaryColor.inverted.withValues(alpha: 0.2),
              width: 1.0)),
      child: Container(
          width: containerSize,
          height: containerSize,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
              color: AppColors.secondaryColor, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: imageWidget),
    );
  }
}

class _SearchingLabel extends StatelessWidget {
  final double scale;

  const _SearchingLabel({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!.searching;

    return Padding(
      padding: EdgeInsets.only(left: 8 * scale),
      child: Shimmer.fromColors(
        baseColor: AppColors.primaryColor.inverted.withValues(alpha: 0.38),
        highlightColor: AppColors.primaryColor.inverted.withValues(alpha: 0.90),
        period: const Duration(milliseconds: 1250),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.primaryColor.inverted.withValues(alpha: 0.55),
            fontSize: 14 * scale,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
