// lib/library/screen/model/widgets/appbar.dart

import 'dart:async';

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../extensions.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme.dart';
import '../../../backend/data/entity.dart';
import '../../../providers/details.dart';

class _ExtensionOverlayPanel extends StatefulWidget {
  final List<Map<String, dynamic>> options;
  final String selectedExtension;
  final String modelTitle;
  final Function(Map<String, dynamic>) onSelect;
  final VoidCallback onClosed;

  const _ExtensionOverlayPanel({
    super.key,
    required this.options,
    required this.selectedExtension,
    required this.modelTitle,
    required this.onSelect,
    required this.onClosed,
  });

  @override
  _ExtensionOverlayPanelState createState() => _ExtensionOverlayPanelState();
}

class _ExtensionOverlayPanelState extends State<_ExtensionOverlayPanel>
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
    // Previously fixed 32.0 was too far for tablet.
    // Now using 2% dynamic width universally.
    // This moves the panel much closer to the left edge (approx 16px on an 800px screen).
    final marginPx = screenW * 0.02;

    // IMPORTANT: Account for the taller AppBar on tablet
    final double toolbarHeight = isTablet ? screenW * 0.14 : kToolbarHeight;
    final topPx = toolbarHeight + MediaQuery.of(context).padding.top;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: startClosing,
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
                  onTap: () {},
                  child: Extensions.buildExtensionPanelWidget(
                    context: context,
                    options: widget.options,
                    selectedExtension: widget.selectedExtension,
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

  const DetailAppBar({
    super.key,
    required this.provider,
    required this.onBackPressed,
  });

  @override
  State<DetailAppBar> createState() => DetailAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(120); // Generous size for tablet
}

class DetailAppBarState extends State<DetailAppBar> with TickerProviderStateMixin {
  OverlayEntry? _extensionOverlayEntry;
  BuildContext? _exitButtonContext;

  final GlobalKey<_ExtensionOverlayPanelState> _overlayKey = GlobalKey<_ExtensionOverlayPanelState>();

  String _currentDisplayExtensionName = '';

  bool get isPanelOpen => _extensionOverlayEntry != null;

  @override
  void initState() {
    super.initState();
    _currentDisplayExtensionName =
        widget.provider.selectedExtension?.displayTitle ??
            widget.provider.selectedExtensionName ??
            '';

    widget.provider.addListener(_onProviderChanged);
  }

  void _onProviderChanged() {
    final newExtensionName =
        widget.provider.selectedExtension?.displayTitle ??
            widget.provider.selectedExtensionName ??
            '';
    if (_currentDisplayExtensionName != newExtensionName) {
      if (mounted) {
        setState(() {
          _currentDisplayExtensionName = newExtensionName;
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
    _extensionOverlayEntry?.remove();
    _extensionOverlayEntry = null;
  }

  void _showExtensionOverlayPanel() {
    if (isPanelOpen) return;

    final provider = widget.provider;
    final langCode = Localizations.localeOf(context).languageCode;

    final List<ModelEntity> extensionEntities = provider.mainModel?.extensions?.values
        .whereType<Map<String, dynamic>>()
        .map((extMap) => ModelEntity.fromMap(extMap, langCode))
        .toList() ?? [];

    if (extensionEntities.isEmpty) return;

    final overlay = Overlay.of(context, rootOverlay: true);

    _extensionOverlayEntry = OverlayEntry(
      builder: (context) {
        return _ExtensionOverlayPanel(
          key: _overlayKey,
          options: List<Map<String, dynamic>>.from(extensionEntities.map((e) => e.toMap())),
          selectedExtension: provider.selectedExtensionName ?? '',
          modelTitle: provider.displayTitle,
          onClosed: _removeOverlayEntry,
          onSelect: (selectedMap) {
            provider.selectExtension(context, selectedMap['id'] as String);
          },
        );
      },
    );

    overlay.insert(_extensionOverlayEntry!);
  }

  Future<void> _handleBackPressed() async {
    if (isPanelOpen) {
      await dismissExtensionOverlay();
      if (!mounted) return;
    }
    widget.onBackPressed();
  }

  Future<void> dismissExtensionOverlay() async {
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
    final bool isTablet = screenWidth >= 600;

    // --- RESPONSIVE HEIGHT ---
    final double toolbarHeight = isTablet ? screenWidth * 0.14 : kToolbarHeight;

    // --- ELEMENT SCALING ---
    final double backIconSize = isTablet ? 36.0 : screenWidth * 0.07;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (PointerDownEvent event) {
        if (isPanelOpen &&
            _exitButtonContext != null &&
            !_isTapInsideWidget(_exitButtonContext!, event.position)) {
          dismissExtensionOverlay();
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

    // Tablet: Large Fonts (32/20). Phone: Dynamic.
    final double titleFontSize = isTablet ? 32.0 : screenWidth * 0.055;
    final double subFontSize = isTablet ? 20.0 : screenWidth * 0.04;
    final double iconSize = isTablet ? 24.0 : screenWidth * 0.04;
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
      onTap: _showExtensionOverlayPanel,
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
                    _currentDisplayExtensionName,
                    key: ValueKey<String>(_currentDisplayExtensionName),
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