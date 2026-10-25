// lib/apps/logo.dart
//
// App logos from the Composio catalog. Logo URLs serve either SVG or raster
// images, so the bytes are sniffed instead of trusting the extension. Logos
// are cached in memory and on disk; a missing logo falls back to a colored
// monogram so every app always has an icon.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';

class _LogoData {
  final Uint8List bytes;
  final bool isSvg;

  const _LogoData(this.bytes, this.isSvg);
}

class _LogoCache {
  _LogoCache._();

  static final _LogoCache instance = _LogoCache._();
  static const int _maxBytes = 512 * 1024;
  static const int _maxEntries = 300;

  final Map<String, _LogoData?> _memory = {};
  final Map<String, Future<_LogoData?>> _pending = {};
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    responseType: ResponseType.bytes,
    maxRedirects: 3,
  ));
  Directory? _directory;

  _LogoData? peek(String url) => _memory[url];

  bool contains(String url) => _memory.containsKey(url);

  Future<_LogoData?> load(String url) {
    if (_memory.containsKey(url)) return Future.value(_memory[url]);
    return _pending[url] ??= _load(url).then((data) {
      if (_memory.length >= _maxEntries) {
        _memory.remove(_memory.keys.first);
      }
      _memory[url] = data;
      return data;
    }).whenComplete(() => _pending.remove(url));
  }

  static bool _looksLikeSvg(Uint8List bytes) {
    final head = utf8
        .decode(bytes.sublist(0, bytes.length < 512 ? bytes.length : 512),
            allowMalformed: true)
        .trimLeft()
        .toLowerCase();
    return head.startsWith('<svg') ||
        (head.startsWith('<?xml') && head.contains('<svg')) ||
        head.contains('<svg');
  }

  Future<File?> _file(String url) async {
    try {
      _directory ??= Directory(
          '${(await getTemporaryDirectory()).path}/cortex_app_logos');
      if (!await _directory!.exists()) {
        await _directory!.create(recursive: true);
      }
      final name = sha1.convert(utf8.encode(url)).toString();
      return File('${_directory!.path}/$name');
    } catch (_) {
      return null;
    }
  }

  Future<_LogoData?> _load(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') return null;

    final file = await _file(url);
    try {
      if (file != null && await file.exists()) {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) return _LogoData(bytes, _looksLikeSvg(bytes));
      }
    } catch (_) {}

    try {
      final response = await _dio.getUri<List<int>>(uri);
      final raw = response.data;
      if (response.statusCode != 200 || raw == null || raw.isEmpty) {
        return null;
      }
      if (raw.length > _maxBytes) return null;
      final bytes = Uint8List.fromList(raw);
      unawaited(file?.writeAsBytes(bytes).catchError((_) => file));
      return _LogoData(bytes, _looksLikeSvg(bytes));
    } catch (_) {
      return null;
    }
  }
}

class AppLogo extends StatefulWidget {
  final String name;
  final String? url;
  final double size;

  const AppLogo({
    super.key,
    required this.name,
    required this.url,
    this.size = 44,
  });

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> {
  _LogoData? _data;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant AppLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _data = null;
      _failed = false;
      _resolve();
    }
  }

  void _resolve() {
    final url = widget.url;
    if (url == null || url.isEmpty) {
      _failed = true;
      return;
    }
    final cache = _LogoCache.instance;
    if (cache.contains(url)) {
      _data = cache.peek(url);
      _failed = _data == null;
      return;
    }
    cache.load(url).then((data) {
      if (!mounted || widget.url != url) return;
      setState(() {
        _data = data;
        _failed = data == null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final radius = BorderRadius.circular(size * 0.26);
    final brightness = Theme.of(context).brightness;
    final tile = brightness == Brightness.dark
        ? const Color(0xFF1C1C1E)
        : Colors.white;
    final border = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.08);

    Widget child;
    final data = _data;
    if (data != null) {
      final inner = size * 0.64;
      child = data.isSvg
          ? SvgPicture.memory(
              data.bytes,
              width: inner,
              height: inner,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _Monogram(name: widget.name, size: size),
            )
          : Image.memory(
              data.bytes,
              width: inner,
              height: inner,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, _, _) => _Monogram(name: widget.name, size: size),
            );
    } else if (_failed) {
      return _Monogram(name: widget.name, size: size);
    } else {
      child = const SizedBox.shrink();
    }

    return Semantics(
      label: widget.name,
      image: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tile,
          borderRadius: radius,
          border: Border.all(color: border, width: 1),
        ),
        child: child,
      ),
    );
  }
}

/// Deterministic colored initial for apps without a usable logo.
class _Monogram extends StatelessWidget {
  final String name;
  final double size;

  const _Monogram({required this.name, required this.size});

  static const List<Color> _palette = [
    Color(0xFF4F7DF3),
    Color(0xFF14A38B),
    Color(0xFFE5674B),
    Color(0xFF9B59D0),
    Color(0xFFE0A11B),
    Color(0xFF2E9BD6),
    Color(0xFFD9467A),
    Color(0xFF5C6BC0),
  ];

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final letter = trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
    final color = _palette[trimmed.hashCode.abs() % _palette.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.26),
      ),
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.45,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
