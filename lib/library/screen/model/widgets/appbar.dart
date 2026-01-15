// lib/library/screen/model/widgets/appbar.dart

import 'dart:async';

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../variants.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme.dart';
import '../../../backend/data/entity.dart';
import '../../../providers/details.dart';

class _VariantOverlayPanel extends StatefulWidget {
  final List<Map<String, dynamic>> options;
  final String selectedVariant;
  final String modelTitle;
  final Function(Map<String, dynamic>) onSelect;
  final VoidCallback onClosed;

  const _VariantOverlayPanel({
    super.key,
    required this.options,
    required this.selectedVariant,
    required this.modelTitle,
    required this.onSelect,
    required this.onClosed,
  });

  @override
  _VariantOverlayPanelState createState() => _VariantOverlayPanelState();
}

class _VariantOverlayPanelState extends State<_VariantOverlayPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startClosing() {
    if (mounted && !_controller.isAnimating) {
      _controller.reverse().then((_) {
        widget.onClosed();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final bool isTablet = screenW >= 600;

    // --- LEFT MARGIN CORRECTION ---
    final marginPx = screenW * 0.02;

    // --- DYNAMIC TOP POSITIONING ---
    // Must match the logic in DetailAppBar to align perfectly.
    // Tablet: Dynamic (approx 14%). Phone: Standard 56.0.
    final double toolbarHeight = isTablet ? screenW * 0.14 : kToolbarHeight;
    final topPx = toolbarHeight + MediaQuery.of(context).padding.top;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: startClosing,
              behavior: HitTestBehavior.opaque, // Ensure clicks are caught
            ),
          ),
          Positioned(
            top: topPx,
            left: marginPx,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {}, // Prevent clicks passing through the panel
                  child: Variants.buildVariantPanelWidget(
                    context: context,
                    options: widget.options,
                    selectedVariant: widget.selectedVariant,
                    modelTitle: widget.modelTitle,
                    onDismiss: startClosing,
                    onSelect: (selectedMap) {
                      widget.onSelect(selectedMap);
                      startClosing();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ModelDetailProvider provider;
  final VoidCallback onBackPressed;

  // Pre-calculated metrics for PreferredSize
  final double _toolbarHeight;
  final bool _isTablet;

  DetailAppBar({
    super.key,
    required BuildContext context, // Context required for sizing
    required this.provider,
    required this.onBackPressed,
  }) :
        _isTablet = MediaQuery.of(context).size.width >= 600,
        _toolbarHeight = MediaQuery.of(context).size.width >= 600
            ? MediaQuery.of(context).size.width * 0.14
            : kToolbarHeight;

  @override
  State<DetailAppBar> createState() => DetailAppBarState();

  @override
  // Dynamically sized: ~120px+ for Tablets, 56px for Phones.
  Size get preferredSize => Size.fromHeight(_toolbarHeight);
}

class DetailAppBarState extends State<DetailAppBar> with TickerProviderStateMixin {
  OverlayEntry? _variantOverlayEntry;
  BuildContext? _exitButtonContext;

  final GlobalKey<_VariantOverlayPanelState> _overlayKey = GlobalKey<_VariantOverlayPanelState>();

  String _currentDisplayVariantName = '';

  bool get isPanelOpen => _variantOverlayEntry != null;

  @override
  void initState() {
    super.initState();
    _currentDisplayVariantName =
        widget.provider.selectedVariant?.displayTitle ??
            widget.provider.selectedVariantName ??
            '';

    widget.provider.addListener(_onProviderChanged);
  }

  void _onProviderChanged() {
    final newVariantName =
        widget.provider.selectedVariant?.displayTitle ??
            widget.provider.selectedVariantName ??
            '';
    if (_currentDisplayVariantName != newVariantName) {
      if (mounted) {
        setState(() {
          _currentDisplayVariantName = newVariantName;
        });
      }
    }
  }

  @override
  void dispose() {
    widget.provider.removeListener(_onProviderChanged);
    _removeOverlayEntry();
    super.dispose();
  }

  void _removeOverlayEntry() {
    _variantOverlayEntry?.remove();
    _variantOverlayEntry = null;
  }

  void _showVariantOverlayPanel() {
    if (isPanelOpen) return;

    final provider = widget.provider;
    final langCode = Localizations.localeOf(context).languageCode;

    final List<ModelEntity> variantEntities = provider.mainModel?.variants?.values
        .whereType<Map<String, dynamic>>()
        .map((extMap) => ModelEntity.fromMap(extMap, langCode))
        .toList() ?? [];

    if (variantEntities.isEmpty) return;

    final overlay = Overlay.of(context, rootOverlay: true);

    _variantOverlayEntry = OverlayEntry(
      builder: (context) {
        return _VariantOverlayPanel(
          key: _overlayKey,
          options: List<Map<String, dynamic>>.from(variantEntities.map((e) => e.toMap())),
          selectedVariant: provider.selectedVariantName ?? '',
          modelTitle: provider.displayTitle,
          onClosed: _removeOverlayEntry,
          onSelect: (selectedMap) {
            provider.selectVariant(context, selectedMap['id'] as String);
          },
        );
      },
    );

    overlay.insert(_variantOverlayEntry!);
  }

  Future<void> _handleBackPressed() async {
    if (isPanelOpen) {
      await dismissVariantOverlay();
      if (!mounted) return;
    }
    widget.onBackPressed();
  }

  Future<void> dismissVariantOverlay() async {
    if (isPanelOpen && _overlayKey.currentState != null) {
      final completer = Completer<void>();
      _overlayKey.currentState!.startClosing();
      await Future.delayed(const Duration(milliseconds: 160));
      if (!completer.isCompleted) {
        completer.complete();
      }
      return completer.future;
    }
    return Future.value();
  }

  bool _isTapInsideWidget(BuildContext context, Offset globalPosition) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(globalPosition);
    return box.paintBounds.contains(localPosition);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Use pre-calculated metrics from widget
    final bool isTablet = widget._isTablet;
    final double toolbarHeight = widget._toolbarHeight;

    // --- ELEMENT SCALING ---
    final double backIconSize = isTablet ? 36.0 : screenWidth * 0.07;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (PointerDownEvent event) {
        if (isPanelOpen &&
            _exitButtonContext != null &&
            !_isTapInsideWidget(_exitButtonContext!, event.position)) {
          dismissVariantOverlay();
        }
      },
      child: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: toolbarHeight,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Builder(builder: (context) {
          _exitButtonContext = context;
          return IconButton(
            icon: Icon(Icons.arrow_back,
                color: AppColors.primaryColor.inverted,
                size: backIconSize),
            onPressed: _handleBackPressed,
          );
        }),
        title: Row(
          children: [
            Expanded(
              child: _buildTitleWidget(context, isTablet, screenWidth),
            ),
            SizedBox(width: isTablet ? 16.0 : screenWidth * 0.02),
            _buildDownloadStatusIndicator(context, isTablet, screenWidth),
          ],
        ),
        actions: [
          SizedBox(width: isTablet ? 32.0 : screenWidth * 0.04),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context, bool isTablet, double screenWidth) {
    final provider = widget.provider;

    // Tablet: Large Fonts (32/20).
    // Phone: Compact Fonts (20/14) to fit inside 56px height.
    final double titleFontSize = isTablet ? 32.0 : screenWidth * 0.055;
    final double subFontSize = isTablet ? 20.0 : screenWidth * 0.035;
    final double iconSize = isTablet ? 24.0 : screenWidth * 0.035;
    final double iconPadding = isTablet ? 10.0 : screenWidth * 0.015;

    if (!provider.isPluralModel) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          provider.displayTitle,
          style: TextStyle(
              fontFamily: 'Roboto',
              color: AppColors.primaryColor.inverted,
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold),
          maxLines: 1,
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _showVariantOverlayPanel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              provider.displayTitle,
              style: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.primaryColor.inverted,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axis: Axis.horizontal,
                        axisAlignment: -1.0,
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _currentDisplayVariantName,
                    key: ValueKey<String>(_currentDisplayVariantName),
                    style: TextStyle(
                        color: AppColors.quinaryColor,
                        fontSize: subFontSize),
                    maxLines: 1,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: iconPadding),
                  child: Transform.rotate(
                    angle: -1.57075,
                    child: SvgPicture.asset(
                      'assets/icons/arrov.svg',
                      width: iconSize,
                      height: iconSize,
                      colorFilter: ColorFilter.mode(
                          AppColors.quinaryColor, BlendMode.srcIn),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadStatusIndicator(BuildContext context, bool isTablet, double screenWidth) {
    final provider = widget.provider;
    final localizations = AppLocalizations.of(context)!;

    final double fontSize = isTablet ? 18.0 : screenWidth * 0.035;

    String downloadStatus = '';
    if (provider.isDownloading) {
      downloadStatus = provider.downloadProgress >= 95
          ? localizations.finalPreparation
          : localizations.downloaded(
          provider.downloadProgress.toStringAsFixed(0));
    } else if (provider.isPaused) {
      downloadStatus = localizations.downloadPaused;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: downloadStatus.isNotEmpty
          ? Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            downloadStatus,
            key: ValueKey<String>(downloadStatus),
            textAlign: TextAlign.end,
            style: TextStyle(
                color: AppColors.quinaryColor,
                fontSize: fontSize),
            softWrap: false,
          ),
        ),
      )
          : const SizedBox.shrink(key: ValueKey('empty')),
    );
  }
}