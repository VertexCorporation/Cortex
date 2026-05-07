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

    final mId = message.model ?? '';
    final model = modelService.getPreciseModelData(mId, langCode: langCode);

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

    String? textToDisplay;
    if (mId == 'cortex/auto' || mId == 'dynamic') {
      textToDisplay = 'Cortex';
    } else if (model.category == 'self') {
      textToDisplay = model.displayTitle.isNotEmpty
          ? model.displayTitle
          : formatModelId(mId);
    } else {
      if (model.displayTitle == 'Unknown Model' || model.displayTitle.isEmpty) {
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
        SizeTransition(
          sizeFactor: headerEntryAnim,
          axis: Axis.horizontal,
          axisAlignment: -1.0,
          child: FadeTransition(
            opacity: headerEntryAnim,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 8 * scale),
                _buildAvatar(scale * 0.7),
                if (textToDisplay.isNotEmpty) ...[
                  SizedBox(width: 6 * scale),
                  Text("•",
                      style: TextStyle(
                          color: AppColors.primaryColor.inverted
                              .withValues(alpha: 0.5),
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.bold)),
                  SizedBox(width: 6 * scale),
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
        final imageProvider = isAsset
            ? AssetImage(avatarPath) as ImageProvider
            : FileImage(File(avatarPath));
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
