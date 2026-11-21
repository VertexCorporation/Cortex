import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/notifications/extrovert/service.dart';
import 'package:cortex/tasks/service.dart';
import 'package:cortex/tasks/task.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Offers a reminder only when a user explicitly mentions an upcoming exam.
class ExamReminderSuggestion {
  ExamReminderSuggestion._();

  static final RegExp _examIntent = RegExp(
    r'\b(sınav|sinav|exam|test)\b',
    caseSensitive: false,
  );

  static bool matches(String message) => _examIntent.hasMatch(message);

  static void offer(BuildContext context, String message) {
    if (!context.mounted || !matches(message)) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.examReminderSuggestion),
          action: SnackBarAction(
            label: l10n.examReminderAction,
            onPressed: () => _chooseTime(context),
          ),
        ),
      );
  }

  static Future<void> _chooseTime(BuildContext context) async {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null || !context.mounted) return;
    final reminder = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!reminder.isAfter(DateTime.now())) return;

    final title = l10n.examReminderTaskTitle;
    final notifications = context.read<ExtrovertNotificationService>();
    int? notificationId;
    try {
      if (await notifications.requestTaskReminderPermission()) {
        notificationId = DateTime.now().microsecondsSinceEpoch & 0x7fffffff;
        await notifications.scheduleTaskReminder(
          notificationId: notificationId,
          title: l10n.examReminderNotification,
          scheduledAt: reminder,
        );
      }
    } catch (_) {
      notificationId = null;
    }

    final taskService = TaskService();
    final tasks = await taskService.load();
    tasks.insert(
      0,
      CortexTask(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        dueAt: reminder,
        notificationId: notificationId,
      ),
    );
    await taskService.save(tasks);
    if (context.mounted && notificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.taskReminderPermissionNeeded)),
      );
    }
  }
}
