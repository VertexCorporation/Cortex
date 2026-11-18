import 'package:cortex/tasks/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('task survives JSON round trip with reminder and completion state', () {
    final task = CortexTask(
      id: 'task-1',
      title: 'Call the team',
      dueAt: DateTime(2026, 11, 16, 15, 30),
      notificationId: 42,
      isDone: true,
    );

    final decoded = CortexTask.fromJson(task.toJson());

    expect(decoded.id, task.id);
    expect(decoded.title, task.title);
    expect(decoded.dueAt, task.dueAt);
    expect(decoded.notificationId, task.notificationId);
    expect(decoded.isDone, isTrue);
  });
}
