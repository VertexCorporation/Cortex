import 'dart:convert';

/// Explicit single-symbol price requests only; never guesses company tickers.
class LocalFinance {
  static String? symbolFor(String query) {
    final text = query.toLowerCase().replaceAll('ı', 'i')
        .replaceAll('ş', 's').replaceAll('ç', 'c').replaceAll('i\u0307', 'i');
    if (RegExp(r'\b(cevir|translate|siir|poem|story)\b').hasMatch(text)) return null;
    if (RegExp(r'\b(internetsiz|cevrimdisi|web kullanma|internette arama|do not search|without internet)\b')
        .hasMatch(text)) return null;
    if (!RegExp(r'\b(fiyat\w*|kac|price|quote)\b').hasMatch(text)) return null;
    final symbols = <String>{};
    final aliases = {'bitcoin': 'BTC-USD', 'btc': 'BTC-USD',
      'ethereum': 'ETH-USD', 'eth': 'ETH-USD'};
    for (final entry in aliases.entries) {
      if (RegExp('\\b${entry.key}\\b').hasMatch(text)) symbols.add(entry.value);
    }
    for (final match in RegExp(r'(?<![A-Za-z0-9])\$?([A-Z]{1,6}(?:[.-][A-Z]{1,4})?)(?![A-Za-z0-9])')
        .allMatches(query)) {
      final value = match.group(1)!;
      if (['TL', 'USD', 'EUR', 'TRY', 'IS'].contains(value)) continue;
      symbols.add(aliases[value.toLowerCase()] ?? value);
    }
    return symbols.length == 1 ? symbols.single : null;
  }

  static String? summary(String symbol, String response, DateTime fetchedAt) {
    try {
      final result = jsonDecode(response);
      if (result is! Map || result['error'] != null) return null;
      final data = result['data'];
      if (data is! Map) return null;
      final price = data['price'];
      final currency = data['currency'];
      if (price is! num || !price.isFinite || price < 0 ||
          currency is! String || !RegExp(r'^[A-Za-z]{3}$').hasMatch(currency)) {
        return null;
      }
      return jsonEncode({'source': 'Yahoo Finance', 'requestedSymbol': symbol,
        'price': price, 'currency': currency,
        'retrievedAtUtc': fetchedAt.toUtc().toIso8601String(),
        'marketTimestamp': null,
        'note': 'Market timestamp unavailable; this may be delayed or a previous '
            'market-session quote. Retrieval time is not the price timestamp. '
            'Do not describe it as a guaranteed live price.'});
    } catch (_) {
      return null;
    }
  }
}
