// lib/local_media_io.dart
//
// io implementation of the local media helpers: real `dart:io` backed
// SVG and raster image rendering.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Builds an [SvgPicture] backed by a real local file. Never returns null on
/// io platforms; callers may still guard with `?? fallback`.
Widget? localSvgFile(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
  ColorFilter? colorFilter,
  WidgetBuilder? placeholderBuilder,
}) =>
    SvgPicture.file(
      File(path),
      width: width,
      height: height,
      fit: fit,
      colorFilter: colorFilter,
      placeholderBuilder: placeholderBuilder,
    );

/// An [ImageProvider] backed by a real local file. Never returns null on io
/// platforms; callers may still guard with `?? const AssetImage(...)`.
ImageProvider? localFileImage(String path) => FileImage(File(path));
