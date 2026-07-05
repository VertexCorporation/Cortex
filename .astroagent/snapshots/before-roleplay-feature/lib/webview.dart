// lib/webview.dart

import 'dart:math' as math; // Used for the PI constant for rotation calculations.
import 'package:cortex/app.dart';
import 'package:cortex/theme.dart'; // Provides access to the app's color scheme.
import 'package:flutter/foundation.dart'; // Provides kDebugMode for conditional logging.
import 'package:flutter/gestures.dart'; // Required for custom gesture recognizers in WebView.
import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart'; // For localization strings.
import 'package:flutter_svg/flutter_svg.dart'; // For rendering SVG assets.
import 'package:webview_flutter/webview_flutter.dart'; // The core WebView widget.

// --- CACHING MECHANISM ---
// This static map acts as a cache for our WebView controllers.
// The key is the URL, and the value is the controller.
// By making it `static`, it persists for the app's entire lifecycle
// and is shared across all calls to `showAppWebViewModal`.
final Map<String, WebViewController> _controllerCache = {};

/// Displays a responsive, cached WebView within a modal bottom sheet.
Future<void> showAppWebViewModal(BuildContext context, String title,
    String url) async {
  if (kDebugMode) {
    print('[AppWebView] Showing modal for: "$title" at $url');
  }

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: double.infinity),
    builder: (BuildContext modalContext) {
      return _WebViewModalContent(url: url, title: title);
    },
  );
}

/// A stateful widget that manages the entire state of the WebView modal.
class _WebViewModalContent extends StatefulWidget {
  final String url;
  final String title;

  const _WebViewModalContent({required this.url, required this.title});

  @override
  _WebViewModalContentState createState() => _WebViewModalContentState();
}

class _WebViewModalContentState extends State<_WebViewModalContent>
    with TickerProviderStateMixin {
  // --- STATE VARIABLES ---
  bool _isLoading = true;
  bool _hasError = false;
  bool _canGoBack = false;
  late final WebViewController _controller;
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('[WebViewModalContent] Initializing state for ${widget.url}');
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )
      ..repeat(reverse: true);
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    // --- CACHE LOGIC ---
    // Check if a controller for this URL already exists in our cache.
    if (_controllerCache.containsKey(widget.url)) {
      if (kDebugMode) {
        print(
            '[WebViewModalContent] Found cached controller for ${widget.url}');
      }
      // If it exists, use the cached controller.
      _controller = _controllerCache[widget.url]!;
      // Since it's cached, it's already loaded.
      _isLoading = false;
      // We still need to update the navigation state (e.g., if the user navigated back/forward before).
      _updateNavigationState();
    } else {
      if (kDebugMode) {
        print(
            '[WebViewModalContent] No cached controller found. Creating new one for ${widget
                .url}');
      }
      // If not cached, create a new controller.
      final WebViewController controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(AppColors.background)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              if (kDebugMode) {
                print(
                    '[WebViewModalContent] Page finished loading. Caching controller for ${widget
                        .url}');
              }
              // Once the page successfully loads, add the controller to the cache.
              _controllerCache[widget.url] = _controller;
              if (mounted) {
                _updateNavigationState(isLoading: false);
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (kDebugMode) {
                print('[WebViewModalContent] WebResourceError: ${error
                    .description}');
              }
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                });
              }
            },
          ),
        );

      // Assign and load the request.
      _controller = controller;
      _controller.loadRequest(Uri.parse(widget.url));
    }
  }

  /// Helper function to check the WebView's navigation state and update the UI.
  Future<void> _updateNavigationState({bool? isLoading}) async {
    if (!mounted) return;
    final canGoBack = await _controller.canGoBack();
    setState(() {
      _canGoBack = canGoBack;
      if (isLoading != null) {
        _isLoading = isLoading;
      }
    });
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print(
          '[WebViewModalContent] Disposing state, but keeping controller in cache.');
    }
    _animationController.dispose();
    // We DO NOT dispose the WebViewController here, as we want to keep it in the cache.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      height: MediaQuery
          .of(context)
          .size
          .height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // --- Header ---
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedOpacity(
                  opacity: _canGoBack ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: IconButton(
                    icon: Transform.rotate(
                      angle: -math.pi / 2,
                      child: SvgPicture.asset(
                        'assets/icons/arrow.svg',
                        colorFilter: ColorFilter.mode(
                            AppColors.primaryColor.inverted, BlendMode.srcIn),
                        width: 22,
                      ),
                    ),
                    onPressed: _canGoBack ? () {
                      _controller.goBack();
                      _updateNavigationState();
                    } : null,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor.inverted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      color: AppColors.primaryColor.inverted.withValues(
                          alpha: 0.7),
                      size: 26),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(height: 1,
              thickness: 1,
              color: AppColors.quinaryColor.withValues(alpha: 0.2)),

          // --- Main Content ---
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!_hasError)
                    WebViewWidget(
                      controller: _controller,
                      gestureRecognizers: {
                        Factory<VerticalDragGestureRecognizer>(() =>
                            VerticalDragGestureRecognizer()),
                      },
                    ),
                  if (_isLoading && !_hasError)
                    _TriangleLoadingIndicator(animation: _animation),
                  if (_hasError)
                    _ErrorDisplay(
                        animation: _animation, localizations: localizations),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGETS ---
// ... The _TriangleLoadingIndicator, _ErrorDisplay, and _TrianglePainter classes remain exactly the same ...
class _TriangleLoadingIndicator extends StatelessWidget {
  final Animation<double> animation;

  const _TriangleLoadingIndicator({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) =>
            CustomPaint(
              size: const Size(60, 60),
              painter: _TrianglePainter(
                progress: animation.value,
                color: AppColors.primaryColor.inverted,
                strokeWidth: 3.5,
              ),
            ),
      ),
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  final Animation<double> animation;
  final AppLocalizations localizations;

  const _ErrorDisplay({required this.animation, required this.localizations});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background, // Obscures the WebView content underneath.
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // A gentle pulsing animation for the error icon.
          ScaleTransition(
            scale: animation,
            child: Icon(
                Icons.error_rounded, color: AppColors.septenaryColor,
                size: 70),
          ),
          const SizedBox(height: 24),
          Text(
            localizations.pageCouldNotBeLoaded,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryColor.inverted,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.checkYourInternet,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.quinaryColor, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _TrianglePainter(
      {required this.progress, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    const minOpacity = 0.3;
    const maxOpacity = 1.0;
    final currentOpacity = minOpacity + (progress * (maxOpacity - minOpacity));
    final paint = Paint()
      ..color = color.withValues(alpha: currentOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final path = Path();
    final h = size.height;
    final w = size.width;
    final p1 = Offset(w / 2, 0);
    final p2 = Offset(0, h * 0.866);
    final p3 = Offset(w, h * 0.866);
    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p3.dx, p3.dy);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}