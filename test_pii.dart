import 'lib/chat/services/pii_filter.dart';
void main() {
  final input = "E-posta adresim test@example.com ve telefon numaram +90 555 123 4567. Kredi kartı numaram ise 1234-5678-9012-3456. TCKN: 12345678901.";
  print(LocalPiiRedactionFilter.redact(input));
}
