// lib/library/screen/model/widgets/appbar.dart

import 'dart:async';

import 'package:cortex/appbar.dart';
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
    final screenW = MediaQuery
        .of(context)
        .size
        .width;
    final bool isTablet = screenW >= 600;

    // --- DYNAMIC TOP POSITIONING ---
    // Must match the logic in DetailAppBar to align perfectly.
    // Tablet: Dynamic (approx 14%). Phone: Standard 56.0.
    final double toolbarHeight = isTablet ? screenW * 0.14 : kToolbarHeight;
    final topPx = toolbarHeight + MediaQuery
        .of(context)
        .padding
        .top;

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
            left: 0,
            right: 0,
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  alignment: Alignment.topCenter,
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
          ),
        ],
      ),
    );
  }
}

class DetailAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ModelDetailProvider provider;
  final VoidCallback onBackPressed;
  final ScrollController? scrollController;

  // Pre-calculated metrics for PreferredSize
  final double _toolbarHeight;
  final bool _isTablet;

  DetailAppBar({
    super.key,
    required BuildContext context, // Context required for sizing
    required this.provider,
    required this.onBackPressed,
    this.scrollController,
  })
      :
        _isTablet = MediaQuery
            .of(context)
            .size
            .width >= 600,
        _toolbarHeight = MediaQuery
            .of(context)
            .size
            .width >= 600
            ? MediaQuery
            .of(context)
            .size
            .width * 0.14
            : kToolbarHeight;

  @override
  State<DetailAppBar> createState() => DetailAppBarState();

  @override
  // Dynamically sized: ~120px+ for Tablets, 56px for Phones.
  Size get preferredSize => Size.fromHeight(_toolbarHeight);
}

class DetailAppBarState extends State<DetailAppBar>
    with TickerProviderStateMixin {
  OverlayEntry? _variantOverlayEntry;

  final GlobalKey<_VariantOverlayPanelState> _overlayKey = GlobalKey<
      _VariantOverlayPanelState>();

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
    final langCode = Localizations
        .localeOf(context)
        .languageCode;

    final List<ModelEntity> variantEntities = provider.mainModel?.variants
        ?.values
        .whereType<Map<String, dynamic>>()
        .map((extMap) => ModelEntity.fromMap(extMap, langCode))
        .toList() ?? [];

    if (variantEntities.isEmpty) return;

    final overlay = Overlay.of(context, rootOverlay: true);

    _variantOverlayEntry = OverlayEntry(
      builder: (context) {
        return _VariantOverlayPanel(
          key: _overlayKey,
          options: List<Map<String, dynamic>>.from(
              variantEntities.map((e) => e.toMap())),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final bool isTablet = widget._isTablet;

    return CortexAppBar(
      leadingMode: CortexLeadingMode.back,
      showGradient: false,
      scrollController: widget.scrollController,
      onLeadingPressed: _handleBackPressed,
      title: _buildTitleWidget(context, isTablet, screenWidth),
      actions: [
        _buildDownloadStatusIndicator(context, isTablet, screenWidth),
        SizedBox(width: isTablet ? 16.0 : 16.0),
      ],
    );
  }

  Widget _buildTitleWidget(BuildContext context, bool isTablet,
      double screenWidth) {
    final provider = widget.provider;

    // Tablet: Large Fonts (24/20).
    // Phone: Compact Fonts (20/14)
    final double titleFontSize = isTablet ? 24.0 : screenWidth * 0.05;
    final double iconSize = isTablet ? 20.0 : screenWidth * 0.04;
    final double iconPadding = 8.0;

    final titleText = Text(
      provider.displayTitle,
      style: TextStyle(
          fontFamily: 'Roboto',
          color: AppColors.primaryColor.inverted,
          fontSize: titleFontSize,
          fontWeight: FontWeight.bold),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (!provider.isPluralModel) {
      return titleText;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _showVariantOverlayPanel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: titleText),
          Padding(
            padding: EdgeInsets.only(left: iconPadding),
            child: Transform.rotate(
              angle: -1.57075, // Keeps original rotation logic
              child: SvgPicture.asset(
                'assets/icons/arrov.svg',
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(
                    AppColors.primaryColor.inverted, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadStatusIndicator(BuildContext context, bool isTablet,
      double screenWidth) {
    final provider = widget.provider;
    final localizations = AppLocalizations.of(context)!;

    // Status should be smaller than title
    final double fontSize = isTablet ? 14.0 : screenWidth * 0.03;

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
          ? Center(
        child: Text(
          downloadStatus,
          key: ValueKey<String>(downloadStatus),
          style: TextStyle(
              color: AppColors.quinaryColor,
              fontSize: fontSize),
        ),
      )
          : const SizedBox.shrink(key: ValueKey('empty')),
    );
  }
}