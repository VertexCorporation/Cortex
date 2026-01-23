import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Diff Algorithm Logic', () {
    // Replicating the logic from AxonConversationList._calculateDiffs
    // to verify it handles deletions correctly without crashing.

    List<String> diffLogic(
        List<String> currentDisplayed, List<String> newList) {
      final displayedIds = List<String>.from(currentDisplayed);

      // 1. Deletions
      for (int i = displayedIds.length - 1; i >= 0; i--) {
        final item = displayedIds[i];
        if (!newList.contains(item)) {
          displayedIds.removeAt(i);
        }
      }

      // 2. Insertions / Sync
      int index = 0;
      while (index < newList.length) {
        final newItem = newList[index];

        if (index >= displayedIds.length) {
          displayedIds.insert(index, newItem);
        } else {
          final currentItem = displayedIds[index];
          if (currentItem != newItem) {
            final existingIndex = displayedIds.indexOf(newItem, index);
            if (existingIndex != -1) {
              final movedItem = displayedIds.removeAt(existingIndex);
              displayedIds.insert(index, movedItem);
            } else {
              displayedIds.insert(index, newItem);
            }
          }
        }
        index++;
      }

      // Cleanup
      while (displayedIds.length > newList.length) {
        displayedIds.removeLast();
      }

      return displayedIds;
    }

    test('Deletion from middle', () {
      final oldList = ['A', 'B', 'C'];
      final newList = ['A', 'C'];

      final result = diffLogic(oldList, newList);

      expect(result, ['A', 'C']);
      expect(result.length, 2);
    });

    test('Deletion from end', () {
      final oldList = ['A', 'B'];
      final newList = ['A'];

      final result = diffLogic(oldList, newList);
      expect(result, ['A']);
    });

    test('Deletion from start', () {
      final oldList = ['A', 'B'];
      final newList = ['B'];

      final result = diffLogic(oldList, newList);
      expect(result, ['B']);
    });

    test('Multiple deletions', () {
      final oldList = ['A', 'B', 'C', 'D'];
      final newList = ['A', 'D'];

      final result = diffLogic(oldList, newList);
      expect(result, ['A', 'D']);
    });

    test('Deletion and move', () {
      final oldList = ['A', 'B', 'C'];
      final newList = ['C', 'A']; // B deleted, C moved to top

      final result = diffLogic(oldList, newList);
      expect(result, ['C', 'A']);
    });
  });
}
