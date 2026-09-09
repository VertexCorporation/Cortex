/// Normalizes the URL strings and URL/title objects returned by the gateway.
/// Citation payloads are untrusted: never pass executable URI schemes to UI.
List<Map<String, String>> mergeWebSources(
    Iterable<dynamic> existing, dynamic incoming) {
  final entries = incoming is Map ? incoming['citations'] : incoming;
  final result = <String, Map<String, String>>{};
  void add(dynamic source) {
    final raw = source is String ? source : (source is Map ? source['url'] : null);
    if (raw is! String || raw.length > 8192) return;
    final uri = Uri.tryParse(raw.trim());
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty || uri.userInfo.isNotEmpty) return;
    final url = uri.toString();
    final title = source is Map ? source['title'] : null;
    final previous = result[url];
    final displayTitle = title is String && title.trim().isNotEmpty
        ? title.trim() : uri.host;
    // Streaming gateways can send the URL before its title. Enrich that
    // placeholder without reordering cards or replacing an established title.
    if (previous != null) {
      if (previous['title'] == uri.host && displayTitle != uri.host) {
        result[url] = {'url': url, 'title': displayTitle};
      }
      return;
    }
    result[url] = {
      'url': url,
      'title': displayTitle,
    };
  }
  for (final source in existing) {
    add(source);
  }
  if (entries is List) {
    for (final source in entries) {
      add(source);
    }
  }
  return result.values.toList(growable: false);
}
