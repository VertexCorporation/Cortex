// test/sorting_test.dart

import 'package:cortex/axon/inbox/logic/general.dart';
import 'package:cortex/axon/inbox/logic/manager.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Inbox Sorting Tests', () {
    late ConversationManager Function({
      required String id,
      required bool isStarred,
      required DateTime lastMessageDate,
      DateTime? starredDate,
    }) makeManager;

    setUp(() {
      makeManager = ({
        required String id,
        required bool isStarred,
        required DateTime lastMessageDate,
        DateTime? starredDate,
      }) {
        return ConversationManager(
          conversationID: id,
          conversationTitle: id == '1' ? 'First' : 'Second',
          initialModelId: 'gpt-4',
          isStarred: isStarred,
          starredDate: starredDate,
          lastMessageDate: lastMessageDate,
          langCode: 'en',
          modelService: FakeModelService(),
        );
      };
    });

    test('Sorting Logic: Starred vs Unstarred', () {
      final now = DateTime.now();

      final m1 = makeManager(
          id: '1', isStarred: false, lastMessageDate: now);
      final m2 = makeManager(
          id: '2', isStarred: true, lastMessageDate: now);

      final result = InboxViewModel.compareConversationManagers(m2, m1);
      expect(result, lessThan(0));
    });

    test('Sorting Logic: Recently Starred', () {
      final now = DateTime.now();
      final newerStar = now.add(const Duration(minutes: 5));
      final olderStar = now;

      final m1 = makeManager(
          id: '1', isStarred: true, starredDate: olderStar, lastMessageDate: now);
      final m2 = makeManager(
          id: '2', isStarred: true, starredDate: newerStar, lastMessageDate: now);

      final result = InboxViewModel.compareConversationManagers(m2, m1);
      expect(result, lessThan(0));
    });
  });
}

class FakeModelService implements ModelService {
  @override
  bool hasModelInCache(String modelId) => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
