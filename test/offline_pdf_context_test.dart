import 'package:cortex/rag/offline_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OfflinePdfProfile', () {
    test('keeps sub-1B context intentionally small', () {
      final tiny = OfflinePdfProfile.forModelSize(600);
      final twoB = OfflinePdfProfile.forModelSize(2000);

      expect(tiny.contextCharBudget, 1200);
      expect(tiny.maxChunks, 2);
      expect(tiny.neighborRadius, 0);
      expect(twoB.contextCharBudget, greaterThan(tiny.contextCharBudget));
      expect(twoB.maxChunks, greaterThanOrEqualTo(tiny.maxChunks));
    });
  });

  group('OfflinePdfContextService', () {
    test('retrieves the numeric page instead of flooding the model', () {
      final service = OfflinePdfContextService();
      final context = service.debugBuildContextFromPages(
        queryText: '2025 geliri kaç?',
        modelSize: 600,
        fileName: 'finance.pdf',
        pages: const [
          'ACME 2025 RAPORU\nGiriş\nŞirket bu yıl yeni pazarlara açıldı.\n1',
          'ACME 2025 RAPORU\n2025 FİNANSAL SONUÇLAR\nRevenue 42.5 milyon TL\nEBITDA 8.2 milyon TL\n2',
          'ACME 2025 RAPORU\nOperasyonlar\nYeni tesis devreye alındı.\n3',
          'ACME 2025 RAPORU\nSonuç\nYönetim büyümenin süreceğini bekliyor.\n4',
        ],
      );

      expect(context, isNotNull);
      expect(context, contains('42.5 milyon TL'));
      expect(context, contains('SAYFA 2'));
      expect(context!.length, lessThanOrEqualTo(1200));
      // Repeated header and bare page number should not be useful context.
      expect(RegExp(r'\n1\n|\n2\n|\n3\n|\n4\n').hasMatch(context), isFalse);
    });

    test('specific page questions do not fall into broad-summary routing', () {
      final service = OfflinePdfContextService();
      final context = service.debugBuildContextFromPages(
        queryText: '3. sayfada ne anlatılıyor?',
        modelSize: 1500,
        pages: const [
          'Giriş\nAlpha konusu.',
          'Yöntem\nBeta yöntemi.',
          'SONUÇLAR\nGamma sonucu 93 puandır.',
          'Ekler\nDelta bilgisi.',
        ],
      );

      expect(context, isNotNull);
      expect(context, contains('SAYFA 3'));
      expect(context, contains('93 puandır'));
    });

    test('summary mode uses document coverage within the tiny budget', () {
      final service = OfflinePdfContextService();
      final context = service.debugBuildContextFromPages(
        queryText: 'Bu PDFyi özetle',
        modelSize: 600,
        pages: const [
          'GİRİŞ\nBaşlangıç bilgisi ve amaç.',
          'YÖNTEM\nDeney yöntemi ve ölçümler.',
          'BULGULAR\nAna bulgular burada.',
          'SONUÇ\nÇalışmanın sonucu burada.',
        ],
      );

      expect(context, isNotNull);
      expect(context, contains('SAYFA 1'));
      expect(context!.length, lessThanOrEqualTo(1200));
    });
  });
}
