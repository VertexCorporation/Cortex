import 'package:cortex/tasks/exam_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExamReminderSuggestion.matches', () {
    test('recognizes Turkish and English exam mentions', () {
      expect(ExamReminderSuggestion.matches('Akşam sınavım var'), isTrue);
      expect(ExamReminderSuggestion.matches('I have an exam tomorrow'), isTrue);
    });

    test('does not suggest reminders for unrelated messages', () {
      expect(
        ExamReminderSuggestion.matches('Let us review the notes'),
        isFalse,
      );
    });
  });
}
