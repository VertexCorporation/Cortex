import 'package:cortex/tasks/exam_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('contextual reminder suggestions', () {
    test('recognizes upcoming commitments beyond exams', () {
      expect(ExamReminderSuggestion.matches('Akşam sınavım var'), isTrue);
      expect(ExamReminderSuggestion.matches('I have an exam tomorrow'), isTrue);
      expect(ExamReminderSuggestion.matches('Yarın sunumum var'), isTrue);
      expect(
        ExamReminderSuggestion.matches('My project deadline is Friday'),
        isTrue,
      );
      expect(ExamReminderSuggestion.matches('I need to call mom'), isTrue);
    });

    test('does not suggest reminders for unrelated messages', () {
      expect(
        ExamReminderSuggestion.matches('Let us review the notes'),
        isFalse,
      );
      expect(
        ExamReminderSuggestion.matches('I have a meeting next month'),
        isTrue,
      );
      expect(ExamReminderSuggestion.matches('I like presentations'), isFalse);
    });

    test('suggests a time from the conversation', () {
      final now = DateTime(2026, 11, 21, 10);
      expect(
        ExamReminderSuggestion.suggestedTime('Yarın sunumum var', now: now),
        DateTime(2026, 11, 22, 9),
      );
      expect(
        ExamReminderSuggestion.suggestedTime('Akşam sınavım var', now: now),
        DateTime(2026, 11, 21, 19),
      );
      expect(
        ExamReminderSuggestion.suggestedTime('Remind me at 8 pm', now: now),
        DateTime(2026, 11, 21, 20),
      );
    });
  });
}
