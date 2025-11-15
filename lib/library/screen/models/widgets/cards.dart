// cards.dart

import 'dart:async';
import 'dart:io';
import 'package:cortex/app.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path/path.dart' as path;
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../internet.dart';
import '../../../../overflow.dart';
import '../../../../theme.dart';
import '../../../backend/data/entity.dart';
import '../../../backend/download/download.dart';
import '../../../backend/utils.dart';
import 'cancel.dart';

/// This widget is now a cleaner, more focused component.
/// It primarily accepts a single [ModelEntity] for its static data,
/// which significantly reduces the number of constructor parameters ("prop drilling").
/// Live state (like download status) and callbacks are still passed in separately.
class ModelTile extends StatefulWidget {
  const ModelTile({
    super.key,
    required this.model,
    required this.isLastInColumn,
    required this.isSeeAll,
    required this.isDownloaded,
    this.manager,
    required this.compatibilityStatus,
    required this.onTileTap,
    required this.onRemoveRequested,
    required this.onChatPressed,
    required this.onDownloadPressed,
    required this.onCancelDownload,
    required this.onResumeDownload,
  });

  // --- The main data source is now the entity ---
  final ModelEntity model;

  // Live state and layout properties remain separate for clarity.
  final bool isLastInColumn;
  final bool isSeeAll;
  final bool isDownloaded;
  final DownloadManager? manager;
  final CompatibilityStatus compatibilityStatus;

  // Callbacks remain unchanged.
  final VoidCallback onTileTap;
  final Future<void> Function() onRemoveRequested;
  final VoidCallback onChatPressed;
  final VoidCallback onDownloadPressed;
  final VoidCallback onCancelDownload;
  final VoidCallback onResumeDownload;

  @override
  State<ModelTile> createState() => _ModelTileState();
}

class _ModelTileState extends State<ModelTile> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.manager?.addListener(_onDownloadStateChanged);
    if (widget.manager?.isDownloading ?? false) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    widget.manager?.removeListener(_onDownloadStateChanged);
    _timer?.cancel();
    super.dispose();
  }

  void _onDownloadStateChanged() {
    if (mounted) {
      final manager = widget.manager;
      if (manager == null) return;

      if (manager.isDownloading && (_timer == null || !_timer!.isActive)) {
        _startTimer();
      } else if (!manager.isDownloading && _timer != null) {
        _stopTimer();
      }
      setState(() {});
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final double w = MediaQuery.of(context).size.width;

    // Logic now uses the entity's properties for clarity.
    final bool canLongPress = widget.model.isCustomModel || widget.isDownloaded;
    final Widget finalImageWidget = _buildImage(w);

    final gestureDetector = RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: {
        LongPressGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(duration: const Duration(milliseconds: 100)),
              (instance) => instance.onLongPress = canLongPress ? widget.onRemoveRequested : null,
        ),
      },
      child: _content(context, w, loc, finalImageWidget),
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: w * .008, horizontal: w * .005),
      child: Column(
        children: [
          gestureDetector,
          if (!widget.isLastInColumn) SizedBox(height: w * .01)
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, double w, AppLocalizations loc) {
    const double radiusFactor = .08;
    final double h = w * .09;
    final double btnW = w * .25;
    final BorderRadius br = BorderRadius.circular(w * radiusFactor);
    final manager = widget.manager;

    if (manager?.isDownloading ?? false) {
      return AnimatedCancelButton(
        key: ValueKey('cancel-${widget.model.id}'),
        onPressed: widget.onCancelDownload,
        width: btnW, height: h, borderRadius: w * radiusFactor,
        borderColor: AppColors.primaryColor.inverted, text: loc.cancel, fontSize: w * .035,
      );
    }

    if (manager?.isPaused ?? false) {
      return SizedBox(
        key: ValueKey('resume-${widget.model.id}'),
        width: btnW, height: h,
        child: ElevatedButton(
          onPressed: widget.onResumeDownload,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.senaryColor, shape: RoundedRectangleBorder(borderRadius: br), padding: EdgeInsets.zero),
          child: FittedBox(child: Text(loc.resume, style: _boldWhite(context, w))),
        ),
      );
    }

    // Logic uses the entity's properties for clarity.
    final bool showChatButton = (widget.isDownloaded || (manager?.isDownloaded ?? false)) || widget.model.isCustomModel || widget.model.isServerSide;
    if (showChatButton) {
      return SizedBox(
        key: ValueKey('chat-${widget.model.id}'),
        width: btnW, height: h,
        child: ElevatedButton(
          onPressed: widget.onChatPressed,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.senaryColor, shape: RoundedRectangleBorder(borderRadius: br), padding: EdgeInsets.zero),
          child: FittedBox(child: Text(loc.chat, style: _boldWhite(context, w))),
        ),
      );
    }

    return StreamBuilder<bool>(
      key: ValueKey('download-stream-${widget.model.id}'),
      stream: InternetService().onConnectivityChanged,
      initialData: InternetService().currentStatus,
      builder: (context, snapshot) {
        final bool hasInternet = snapshot.data ?? false;
        final bool isCompatible = widget.compatibilityStatus == CompatibilityStatus.compatible;
        bool isButtonEnabled;
        String buttonText;
        double fontSize = w * .035;

        // Use entity property 'isServerSide'.
        if (!widget.model.isServerSide && !hasInternet) {
          buttonText = loc.noInternetConnection;
          isButtonEnabled = false;
          fontSize = w * .028;
        } else if (isCompatible) {
          buttonText = loc.download;
          isButtonEnabled = true;
        } else {
          buttonText = (widget.compatibilityStatus == CompatibilityStatus.insufficientRAM ? loc.insufficientRAM : loc.insufficientStorage);
          isButtonEnabled = false;
          fontSize = w * .025;
        }

        return SizedBox(
          width: btnW, height: h,
          child: ElevatedButton(
            onPressed: isButtonEnabled ? widget.onDownloadPressed : null,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((s) => s.contains(WidgetState.disabled) ? AppColors.quaternaryColor : AppColors.primaryColor.inverted),
              foregroundColor: WidgetStateProperty.resolveWith<Color>((s) => s.contains(WidgetState.disabled) ? AppColors.tertiaryColor : AppColors.primaryColor),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: br)),
              padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
            ),
            child: FittedBox(child: Text(buttonText, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold))),
          ),
        );
      },
    );
  }

  /// It now passes the entire, type-safe [ModelEntity] to the helper function.
  /// It trusts that `widget.model.imagePath` is the definitive, correct path
  /// and no longer needs to perform any complex lookups.
  Widget _buildImage(double w) {
    // Use the pre-resolved path directly from the entity.
    // Provide a fallback just in case, for ultimate safety.
    final String resolvedImagePath = widget.model.imagePath ?? 'assets/icons/self.svg';

    final String extension = path.extension(resolvedImagePath).toLowerCase();
    final bool isFramedType = (extension == '.svg' || extension == '.png');
    double imgW = w * .14;
    double imgH = imgW;
    final Widget fallbackImage = _fallback(imgW, imgH);
    Widget imageContent;

    if (resolvedImagePath.endsWith('self.svg')) {
      imageContent = fallbackImage;
    } else {
      if (extension == '.svg') {
        imageContent = SvgPicture.asset(resolvedImagePath, fit: BoxFit.contain, placeholderBuilder: (_) => fallbackImage);
      } else {
        ImageProvider provider = resolvedImagePath.startsWith('assets/')
            ? AssetImage(resolvedImagePath)
            : FileImage(File(resolvedImagePath));
        imageContent = Image(image: provider, fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallbackImage);
      }
    }

    if (isFramedType) {
      return Container(width: imgW, height: imgH, padding: const EdgeInsets.all(6.0), decoration: BoxDecoration(color: AppColors.secondaryColor, borderRadius: BorderRadius.circular(w * .03)), child: imageContent);
    } else {
      return Container(width: imgW, height: imgH, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(w * .03)), child: imageContent);
    }
  }

  Widget _fallback(double w, double h) => Container(width: w, height: h, color: AppColors.secondaryColor, child: Padding(padding: const EdgeInsets.all(8.0), child: SvgPicture.asset('assets/icons/self.svg', colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn))));

  Widget _content(BuildContext context, double w, AppLocalizations loc, Widget img) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTileTap,
      child: AnimatedContainer(
        padding: EdgeInsets.all(widget.isSeeAll ? w * .01 : w * .005),
        duration: const Duration(seconds: 1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            img,
            SizedBox(width: w * .014),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OverflowText(
                    // Use pre-localized 'displayTitle' from the entity.
                    text: widget.model.displayTitle,
                    style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: w * .04, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: w * .005),
                  OverflowText(
                    // Use pre-localized 'displaySummary' from the entity.
                    text: widget.model.displaySummary,
                    maxLines: 2,
                    fadeLength: 6,
                    style: TextStyle(color: AppColors.primaryColor.inverted.withValues(alpha: .5), fontSize: w * .029),
                  ),
                ],
              ),
            ),
            SizedBox(width: w * .01),
            _rightColumn(context, w, loc),
          ],
        ),
      ),
    );
  }

  Widget _rightColumn(BuildContext context, double w, AppLocalizations loc) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(width: w * .2, height: w * .04, child: Center(child: _buildDownloadStatusText(loc, w))),
      SizedBox(height: w * .005),
      SizedBox(width: w * .2, height: w * .09, child: _fade(_buildButton(context, w, loc))),
    ]);
  }

  Widget _buildDownloadStatusText(AppLocalizations loc, double w) {
    final manager = widget.manager;
    if (manager == null) return const SizedBox.shrink();
    if (manager.isDownloading) {
      final String text = manager.progress >= 95 ? loc.finalPreparation : loc.downloaded(manager.progress.toStringAsFixed(0));
      return _fade(Text(text, textAlign: TextAlign.center, style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: w * .03)));
    } else if (manager.isPaused) {
      return _fade(Text(loc.downloadPaused, style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: w * .03)));
    }
    return const SizedBox.shrink();
  }

  Widget _fade(Widget child) => AnimatedSwitcher(duration: const Duration(milliseconds: 300), transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c), child: child);
  TextStyle _boldWhite(BuildContext ctx, double w) => TextStyle(color: Colors.white, fontSize: w * .035, fontWeight: FontWeight.bold);
}