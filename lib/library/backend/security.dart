import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

/// Security and consistency checks for data received from the model catalog.
///
/// Synapse is a remote data source. Even though it is operated by Cortex, the
/// mobile client must treat catalog fields as untrusted input before using them
/// as URLs, file-system paths, or destructive synchronization state.
class ModelSecurity {
  static const List<int> _ggufMagic = <int>[0x47, 0x47, 0x55, 0x46]; // GGUF

  /// Accepts only HTTPS URLs that resolve to a public host.
  ///
  /// This prevents catalog entries from making the device fetch clear-text,
  /// loopback, link-local, or private-network resources.
  static Uri requireTrustedDownloadUri(String rawUrl) {
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null ||
        uri.scheme.toLowerCase() != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      throw const FormatException('Model download URL must be a valid HTTPS URL.');
    }

    if (_isBlockedHost(uri.host)) {
      throw const FormatException('Model download URL points to a local or private host.');
    }

    return uri;
  }

  /// Resolves a model ID to a path that can never escape [filesDir].
  ///
  /// Existing safe/legacy IDs keep their current path. Only an ID that would
  /// traverse outside the model directory is mapped to a deterministic digest
  /// filename, preserving app stability without trusting the unsafe path text.
  static String resolveModelFilePath({
    required String filesDir,
    required String modelId,
  }) {
    if (filesDir.trim().isEmpty) {
      throw ArgumentError.value(filesDir, 'filesDir', 'must not be empty');
    }
    if (modelId.trim().isEmpty) {
      throw ArgumentError.value(modelId, 'modelId', 'must not be empty');
    }

    final base = p.normalize(p.absolute(filesDir));
    final candidate =
        p.normalize(p.absolute(p.join(base, '${modelId.trim()}.gguf')));

    if (p.isWithin(base, candidate)) {
      return candidate;
    }

    final digest = sha256.convert(utf8.encode(modelId)).toString().substring(0, 32);
    return p.join(base, 'model_$digest.gguf');
  }

  /// Validates the GGUF magic header before the app marks a model downloaded.
  static Future<bool> isValidGgufFile(File file) async {
    try {
      if (!await file.exists() || await file.length() < _ggufMagic.length) {
        return false;
      }

      final handle = await file.open();
      try {
        final header = await handle.read(_ggufMagic.length);
        if (header.length != _ggufMagic.length) return false;
        for (var i = 0; i < _ggufMagic.length; i++) {
          if (header[i] != _ggufMagic[i]) return false;
        }
        return true;
      } finally {
        await handle.close();
      }
    } catch (_) {
      return false;
    }
  }

  /// Rejects suspiciously large catalog drops before stale-model cleanup.
  ///
  /// Small catalogs during first-run/development are allowed. Once the client
  /// already has a meaningful catalog, a response containing less than half of
  /// the existing public entries is treated as partial/corrupt and retried later.
  static bool isPlausibleCatalogReplacement({
    required int existingCount,
    required int incomingCount,
  }) {
    if (incomingCount <= 0) return false;
    if (existingCount < 20) return true;
    return incomingCount >= (existingCount * 0.5).ceil();
  }

  /// Makes top-level catalog IDs unique without changing non-conflicting IDs.
  ///
  /// Multi-variant series historically derive their top-level ID from only the
  /// series name, so two producers can otherwise overwrite one another in the
  /// SQLite table where `id` is the primary key.
  static List<Map<String, dynamic>> disambiguateDuplicateModelIds(
      List<Map<String, dynamic>> models) {
    final counts = <String, int>{};
    for (final model in models) {
      final id = model['id']?.toString().trim() ?? '';
      if (id.isNotEmpty) counts[id] = (counts[id] ?? 0) + 1;
    }

    final used = <String>{};
    final result = <Map<String, dynamic>>[];

    for (final source in models) {
      final model = Map<String, dynamic>.from(source);
      final originalId = model['id']?.toString().trim() ?? '';
      if (originalId.isEmpty) continue;

      var finalId = originalId;
      if ((counts[originalId] ?? 0) > 1) {
        final producer = _slug(model['producer']?.toString() ?? 'producer');
        final idSlug = _slug(originalId);
        final prefix = producer.isEmpty ? 'producer' : producer;
        final suffix = idSlug.isEmpty ? 'model' : idSlug;
        finalId = '$prefix--$suffix';
      }

      var uniqueId = finalId;
      var n = 2;
      while (used.contains(uniqueId)) {
        uniqueId = '$finalId-$n';
        n++;
      }
      used.add(uniqueId);
      model['id'] = uniqueId;
      result.add(model);
    }

    return result;
  }

  static bool _isBlockedHost(String rawHost) {
    final host = rawHost.toLowerCase().replaceAll(RegExp(r'^\[|\]$'), '');
    final isIpv6Literal = host.contains(':');

    if (host == 'localhost' ||
        host.endsWith('.localhost') ||
        host.endsWith('.local') ||
        host == '::1' ||
        (isIpv6Literal &&
            (host.startsWith('fc') ||
                host.startsWith('fd') ||
                host.startsWith('fe80:')))) {
      return true;
    }

    final parts = host.split('.');
    if (parts.length != 4) return false;
    final octets = parts.map(int.tryParse).toList();
    if (octets.any((value) => value == null)) return false;
    if (octets.any((value) {
      final octet = value!;
      return octet < 0 || octet > 255;
    })) {
      return false;
    }

    final a = octets[0]!;
    final b = octets[1]!;
    return a == 10 ||
        a == 127 ||
        (a == 169 && b == 254) ||
        (a == 172 && b >= 16 && b <= 31) ||
        (a == 192 && b == 168) ||
        a == 0;
  }

  static String _slug(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}