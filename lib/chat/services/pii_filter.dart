class LocalPiiRedactionFilter {
  static final RegExp _emailRegExp = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b',
  );

  static final RegExp _phoneRegExp = RegExp(
    r'\b(?:\+?\d{1,3}[- ]?)?\(?\d{3}\)?[- ]?\d{3}[- ]?\d{4}\b',
  );

  static final RegExp _creditCardRegExp = RegExp(
    r'\b\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?\d{4}\b',
  );

  static final RegExp _tcknRegExp = RegExp(
    r'\b[1-9]\d{10}\b',
  );

  /// Redacts sensitive personal data (PII) from user prompts locally before transmission.
  static String redact(String text) {
    if (text.isEmpty) return text;

    String sanitized = text;
    sanitized = sanitized.replaceAllMapped(
        _emailRegExp, (match) => '[E-POSTA MASKELENDİ]');
    sanitized = sanitized.replaceAllMapped(
        _creditCardRegExp, (match) => '[KREDİ KARTI MASKELENDİ]');
    sanitized = sanitized.replaceAllMapped(
        _phoneRegExp, (match) => '[TELEFON MASKELENDİ]');
    sanitized = sanitized.replaceAllMapped(
        _tcknRegExp, (match) => '[TC KİMLİK MASKELENDİ]');

    return sanitized;
  }
}
