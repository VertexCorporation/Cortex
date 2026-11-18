// lib/local_media_web.dart
//
// Web implementation of the local media helpers. The browser has no access
// to locally downloaded files, so every helper returns null and callers fall
// back to asset or placeholder widgets.

import 'package:flutter/material.dart';

/// Web stub: local files do not exist in the browser.
Widget? localSvgFile(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
  ColorFilter? colorFilter,
  WidgetBuilder? placeholderBuilder,
}) =>
    null;

/// Web stub: local files do not exist in the browser.
ImageProvider? localFileImage(String path) => null;
