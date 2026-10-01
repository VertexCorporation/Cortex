part of '../ai.dart';

class _AiHeader extends StatelessWidget {
  final Message message;
  final String avatarPath;
  final double scale;
  final Animation<double> thinkPulseAnim;
  final Animation<double> thinkRotateAnim;
  final Animation<double> headerEntryAnim;
  final Animation<double> modelDetailsAnim;
  final String textToDisplay;
  final bool isCortexDynamic;

  static final _nameSplitter = RegExp(r'[-_]');

  const _AiHeader({
    required this.message,
    required this.avatarPath,
    required this.scale,
    required this.thinkPulseAnim,
    required this.thinkRotateAnim,
    required this.headerEntryAnim,
    required this.modelDetailsAnim,
    required this.textToDisplay,
    required this.isCortexDynamic,
  });

  static _HeaderData _resolveHeaderData(BuildContext context, Message message) {
    final modelService = context.read<ModelService>();
    final langCode = Localizations.localeOf(context).languageCode;
    final mId = message.model ?? '';

    bool isDynamicConversationId(String? id) {
      final normalized = (id ?? '').trim().toLowerCase();
      return normalized == 'cortex/auto' || normalized == 'dynamic';
    }

    String? associatedUserModelId;
    final convProvider = context.read<ConversationProvider>();
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

    final ModelEntity model;
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
      return name
          .split(_nameSplitter)
          .map((w) {
            if (w.isEmpty) return '';
            if (w.toLowerCase() == 'gpt') return 'GPT';
            return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
          })
          .join(' ');
    }

    final bool isCortexDynamic =
        isDynamicConversationId(mId) ||
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
      final parentSeries = ModelDataUtils.findParentSeriesData(
        mId,
        langCode: langCode,
        modelService: modelService,
      );
      final isRealVariantSeries =
          parentSeries != null &&
          parentSeries.variants != null &&
          parentSeries.variants!.isNotEmpty;
      if (isRealVariantSeries) {
        final seriesTitle = parentSeries.series ?? parentSeries.displayTitle;
        if (seriesTitle.isNotEmpty && seriesTitle != 'Unknown Model') {
          textToDisplay = seriesTitle;
        } else {
          textToDisplay =
              model.displayTitle.isNotEmpty &&
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

    final participant = FlowParticipantMetadata.fromKey(
      message.flowParticipant,
    );
    if (participant != null) {
      textToDisplay =
          '${participant.localizedName(AppLocalizations.of(context)!)} · '
          '$textToDisplay';
    }
    return _HeaderData(
      textToDisplay: textToDisplay,
      isCortexDynamic: isCortexDynamic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = message.isWebSearchActive && message.isThinking;
    final participant = FlowParticipantMetadata.fromKey(
      message.flowParticipant,
    );
    final identityColor = participant?.color ?? AppColors.primaryColor.inverted;

    // Reserve the header's vertical footprint before the first token arrives.
    // This keeps the whole message column from shifting when the model label
    // fades in or the search label changes.
    return SizedBox(
      height: 30 * scale,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _AiCortexIcon(
            isThinking: message.isThinking,
            inlineSize: 16 * scale,
            identityColor: identityColor,
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
                ? _SearchingLabel(
                    key: const ValueKey('searching'),
                    scale: scale,
                  )
                : const SizedBox.shrink(key: ValueKey('not_searching')),
          ),
          // Opacity keeps the header width stable while its metadata appears.
          FadeTransition(
            opacity: modelDetailsAnim,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 8 * scale),
                if (!isCortexDynamic) _buildAvatar(scale * 0.7, identityColor),
                if (textToDisplay.isNotEmpty) ...[
                  if (!isCortexDynamic) SizedBox(width: 6 * scale),
                  if (!isCortexDynamic)
                    Text(
                      "•",
                      style: TextStyle(
                        color: identityColor.withValues(alpha: 0.5),
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (!isCortexDynamic) SizedBox(width: 6 * scale),
                  Text(
                    ModelDataUtils.formatModelName(textToDisplay),
                    style: TextStyle(
                      color: identityColor.withValues(alpha: 0.7),
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(double s, Color identityColor) {
    final containerSize = 30 * s;
    final iconSize = 24 * s;
    final fallbackWidget = SvgPicture.asset(
      'assets/icons/self.svg',
      width: CortexDesign.icon,
      height: CortexDesign.icon,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(identityColor, BlendMode.srcIn),
    );
    Widget imageWidget;
    if (avatarPath.isEmpty || avatarPath.endsWith('self.svg')) {
      imageWidget = fallbackWidget;
    } else {
      final isSvg = avatarPath.toLowerCase().endsWith('.svg');
      final isAsset = avatarPath.startsWith('assets/');
      if (isSvg) {
        imageWidget = isAsset
            ? SvgPicture.asset(
                avatarPath,
                width: CortexDesign.icon,
                height: CortexDesign.icon,
                colorFilter: ColorFilter.mode(identityColor, BlendMode.srcIn),
                fit: BoxFit.contain,
                placeholderBuilder: (_) => fallbackWidget,
              )
            : SvgPicture.file(
                File(avatarPath),
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(identityColor, BlendMode.srcIn),
                fit: BoxFit.contain,
                placeholderBuilder: (_) => fallbackWidget,
              );
      } else {
        ImageProvider imageProvider = isAsset
            ? AssetImage(avatarPath) as ImageProvider
            : FileImage(File(avatarPath));
        final int cacheSize = (containerSize * 3).toInt().clamp(50, 200);
        imageProvider = ResizeImage(
          imageProvider,
          width: cacheSize,
          height: cacheSize,
        );
        imageWidget = Image(
          image: imageProvider,
          width: containerSize,
          height: containerSize,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallbackWidget,
        );
      }
    }
    return Container(
      padding: EdgeInsets.all(1.5 * s),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: identityColor.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Container(
        width: containerSize,
        height: containerSize,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: imageWidget,
      ),
    );
  }
}

/// The AI tile's Cortex mark. While the message is thinking it plays the
/// startup splash's looping morph inline; when loading ends it does not
/// snap — the splash stays mounted with [CortexStartupSplash.ready] raised
/// so the current morph finishes naturally, one final transition rotates
/// into the Cortex icon, and only once that completes does the normal
/// static icon take over. This reuses the startup splash's own graceful
/// exit machinery unchanged.
class _AiCortexIcon extends StatefulWidget {
  const _AiCortexIcon({
    required this.isThinking,
    required this.inlineSize,
    required this.identityColor,
  });

  final bool isThinking;

  /// Square inline footprint of the mark (the splash's [inlineSize]).
  final double inlineSize;
  final Color identityColor;

  @override
  State<_AiCortexIcon> createState() => _AiCortexIconState();
}

class _AiCortexIconState extends State<_AiCortexIcon> {
  /// True while the splash finishes its graceful exit after loading ended;
  /// the static icon only takes over once the exit reports completion.
  bool _splashExiting = false;

  /// Bumped when thinking restarts mid-exit (regeneration), so a fresh
  /// looping splash mounts instead of reusing a completed one.
  int _splashEpoch = 0;

  @override
  void didUpdateWidget(_AiCortexIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isThinking && !widget.isThinking) {
      // Loading ended: hold the splash in place and raise its ready flag.
      _splashExiting = true;
    } else if (!oldWidget.isThinking && widget.isThinking && _splashExiting) {
      // Regeneration restarted thinking while the exit was still running:
      // cancel it and remount a fresh looping splash.
      _splashExiting = false;
      _splashEpoch++;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isThinking && !_splashExiting) {
      return SvgPicture.asset(
        'assets/cortex.svg',
        width: widget.inlineSize,
        height: widget.inlineSize,
        colorFilter: ColorFilter.mode(widget.identityColor, BlendMode.srcIn),
      );
    }
    return CortexStartupSplash(
      key: ValueKey(_splashEpoch),
      inlineSize: widget.inlineSize,
      foreground: widget.identityColor,
      ready: !widget.isThinking,
      onComplete: () {
        if (_splashExiting) setState(() => _splashExiting = false);
      },
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
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _HeaderData {
  final String textToDisplay;
  final bool isCortexDynamic;
  const _HeaderData({
    required this.textToDisplay,
    required this.isCortexDynamic,
  });
}
