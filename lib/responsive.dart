import 'package:flutter/material.dart';

/// Responsive breakpoints matching mobile/tablet/desktop paradigms.
class AppBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double wide = 1440;
}

/// Responsive layout helpers.
extension ResponsiveContext on BuildContext {
  double get _width => MediaQuery.sizeOf(this).width;
  double get _height => MediaQuery.sizeOf(this).height;

  bool get isMobile => _width < AppBreakpoints.mobile;
  bool get isTablet =>
      _width >= AppBreakpoints.mobile && _width < AppBreakpoints.desktop;
  bool get isDesktop => _width >= AppBreakpoints.desktop;
  bool get isWide => _width >= AppBreakpoints.wide;

  /// Max content width for large screens (chat, inputs, etc.)
  double get contentMaxWidth =>
      isWide ? AppBreakpoints.wide * 0.65 : double.infinity;

  /// Sidebar width on desktop
  double get desktopSidebarWidth => (_width * 0.3).clamp(280.0, 420.0);

  /// Horizontal padding that scales with screen size
  double get responsiveHorizontalPadding =>
      isMobile ? 16.0 : isTablet ? 24.0 : 32.0;

  /// Whether the sidebar should be shown as a fixed panel on desktop
  bool get useFixedSidebar => isDesktop;

  /// Scale factor for UI elements based on screen width
  double get uiScale {
    final scale = _width / 430.0;
    return scale.clamp(0.85, isDesktop ? 1.0 : 1.3);
  }
}
