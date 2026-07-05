part of '../ai.dart';

class _InlineOptionsRow extends StatefulWidget {
  final Message message;
  final VoidCallback? onReport;
  final void Function({String? newModelId})? onRegenerate;
  final double scale;

  const _InlineOptionsRow({
    required this.message,
    this.onReport,
    this.onRegenerate,
    required this.scale,
  });

  @override
  State<_InlineOptionsRow> createState() => _InlineOptionsRowState();
}

class _InlineOptionsRowState extends State<_InlineOptionsRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtl;
  List<MessageOption> _visibleOptions = [];

  @override
  void initState() {
    super.initState();
    _animCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    // If the message is already done, start animation immediately
    if (!widget.message.isThinking && !widget.message.isError) {
      _animCtl.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _InlineOptionsRow old) {
    super.didUpdateWidget(old);
    if (old.message.isThinking &&
        !widget.message.isThinking &&
        !widget.message.isError) {
      _animCtl.forward(from: 0.0);
    } else if (!old.message.isThinking && widget.message.isThinking) {
      _animCtl.reverse();
    }
  }

  @override
  void dispose() {
    _animCtl.dispose();
    super.dispose();
  }

  void _onCopyTapped() async {
    final localizations = AppLocalizations.of(context)!;
    final message = widget.message;
    final bool isMediaOnly =
        message.hasAttachments && message.displayableText.trim().isEmpty;

    if (isMediaOnly) {
      try {
        final path = message.attachmentPaths.first;
        final success = await Pasteboard.writeFiles([path]);
        if (success) {
          if (!mounted) return;
          Provider.of<IntrovertNotificationService>(context, listen: false)
              .showNotification(
                  message: localizations.messageCopied,
                  type: NotificationType.success,
                  bottomOffset: 0.07,
                  isChatMode: true);
        } else {
          _saveFirstMediaToGallery(message, localizations);
        }
      } catch (e) {
        _saveFirstMediaToGallery(message, localizations);
      }
      return;
    }

    Clipboard.setData(ClipboardData(text: message.displayableText));
    Provider.of<IntrovertNotificationService>(context, listen: false)
        .showNotification(
            message: localizations.messageCopied,
            type: NotificationType.success,
            bottomOffset: 0.07,
            isChatMode: true);
  }

  Future<void> _saveFirstMediaToGallery(
      Message message, AppLocalizations localizations) async {
    final notificationService =
        Provider.of<IntrovertNotificationService>(context, listen: false);
    try {
      final firstPath = message.attachmentPaths.first;
      final ext = firstPath.toLowerCase().split('.').last;
      final isVideo = ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext);

      bool? success;
      if (isVideo) {
        success = await GallerySaver.saveVideo(firstPath);
      } else {
        success = await GallerySaver.saveImage(firstPath);
      }

      notificationService.showNotification(
        message: success == true
            ? localizations.downloadSuccess
            : localizations.downloadFailed,
        type:
            success == true ? NotificationType.success : NotificationType.error,
        bottomOffset: 0.07,
        isChatMode: true,
      );
    } catch (_) {
      notificationService.showNotification(
        message: localizations.downloadFailed,
        type: NotificationType.error,
        bottomOffset: 0.07,
        isChatMode: true,
      );
    }
  }

  void _onChangeModelTapped() {
    showModelSelectionDialog(
      context: context,
      currentModelId: widget.message.model ?? '',
      onRegenerate: widget.onRegenerate,
    );
  }

  Widget _buildIcon(MessageOption option, double s, int index, int total) {
    // Staggered animation
    final start = (index / total) * 0.5;
    final end = start + 0.5;
    final animation = CurvedAnimation(
      parent: _animCtl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    String iconAsset = '';
    VoidCallback onTap = () {};

    switch (option) {
      case MessageOption.copy:
        iconAsset = 'assets/icons/copy.svg';
        onTap = _onCopyTapped;
        break;
      case MessageOption.report:
        iconAsset = 'assets/icons/warning.svg';
        onTap = () => widget.onReport?.call();
        break;
      case MessageOption.regenerate:
        iconAsset = 'assets/icons/regenerate.svg';
        onTap = () => widget.onRegenerate?.call();
        break;
      case MessageOption.changeModel:
        iconAsset = 'assets/icons/variant.svg';
        onTap = _onChangeModelTapped;
        break;
      case MessageOption.speak:
        iconAsset = 'assets/icons/voice.svg';
        onTap = () {
          final ttsService = TtsService();
          final langCode = Localizations.localeOf(context).languageCode;
          ttsService.speak(widget.message.displayableText,
              languageCode: langCode);
        };
        break;
      default:
        break;
    }

    if (iconAsset.isEmpty) return const SizedBox.shrink();

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero)
            .animate(animation),
        child: Padding(
          padding: EdgeInsets.only(right: 6.0 * s),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10 * s),
              onTap: onTap,
              splashColor:
                  AppColors.primaryColor.inverted.withValues(alpha: 0.1),
              highlightColor:
                  AppColors.primaryColor.inverted.withValues(alpha: 0.05),
              child: Padding(
                padding: EdgeInsets.all(6.0 * s),
                child: SvgPicture.asset(
                  iconAsset,
                  width: 14 * s,
                  height: 14 * s,
                  colorFilter: ColorFilter.mode(
                    AppColors.primaryColor.inverted,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message.isThinking || widget.message.isError) {
      return const SizedBox.shrink();
    }

    final modelService = context.read<ModelService>();
    final creditsMgr = context.read<CreditsManager>();
    final totalCredits = creditsMgr.totalCreditsNotifier.value ?? 0;

    final viewModel = OptionsPanelViewModel(
      session: context.read<ChatSessionProvider>(),
      conversation: context.read<ConversationProvider>(),
      internet: context.read<InternetProvider>(),
      message: widget.message,
      modelService: modelService,
      totalCredits: totalCredits,
    );

    _visibleOptions = viewModel.getVisibleOptions(context);

    // Remove options that are not supported inline
    _visibleOptions.remove(MessageOption.stop);

    if (_visibleOptions.isEmpty) return const SizedBox.shrink();

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Padding(
        padding:
            EdgeInsets.only(top: 10.0 * widget.scale, left: 2.0 * widget.scale),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_visibleOptions.length, (index) {
            return _buildIcon(_visibleOptions[index], widget.scale, index,
                _visibleOptions.length);
          }),
        ),
      ),
    );
  }
}
