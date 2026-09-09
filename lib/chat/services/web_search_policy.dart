/// Conservative, on-device intent hints. This is not a semantic classifier:
/// unsupported languages/ambiguous requests may need an explicit web request.
class WebSearchPolicy {
  static String _normalize(String text) => text.toLowerCase()
      .replaceAll('ı', 'i').replaceAll('ş', 's').replaceAll('ğ', 'g')
      .replaceAll('ü', 'u').replaceAll('ö', 'o').replaceAll('ç', 'c')
      .replaceAll('i\u0307', 'i');

  static final _optOut = RegExp(
      r'\b(webde arama|internette arama|interneti kullanma|web kullanma|'
      r'internetsiz|cevrimdisi|do not search|don.t search|without (web|internet))\b');
  static final _explicit = RegExp(
      r'\b(webde|internette|internetten|webden|web search|search the web|'
      r'look up online|kaynaklariyla|kaynak goster|kaynak bul|cite sources)\b');
  static final _current = RegExp(
      r'\b(guncel|bugun|su an|simdiki|son dakika|son haberler|hava durumu|'
      r'latest|currently|current|today|breaking news|weather forecast)\b');
  static final _price = RegExp(
      r'\b(dolar|euro|altin|bitcoin|btc)\b.*\b(kac|fiyat|kur|price|rate)\b');
  static final _selfContained = RegExp(
      r'\b(cevir|translate|siir yaz|hikaye yaz|write a poem|write a story)\b');

  static bool shouldSearch(String query, {required bool enabled}) {
    if (!enabled) return false;
    final text = _normalize(query).trim();
    if (text.isEmpty || _optOut.hasMatch(text)) return false;
    if (_explicit.hasMatch(text)) return true;
    if (_selfContained.hasMatch(text)) return false;
    return _current.hasMatch(text) || _price.hasMatch(text);
  }
}
