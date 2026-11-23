import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/notifications/extrovert/service.dart';
import 'package:cortex/tasks/service.dart';
import 'package:cortex/tasks/task.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Contextual, opt-in follow-up suggestions based on an upcoming commitment.
/// The app proposes a time; it never schedules a reminder without a tap.
class ExamReminderSuggestion {
  ExamReminderSuggestion._();

  static final RegExp _explicitReminder = RegExp(
    r'\b(remind me|remember to|don.t let me forget|i need to|i have to|i must|hatırlat|hatirlat|unutmayayım|unutmayalim|yapmam gerek|gitmem gerekiyor)',
    caseSensitive: false,
  );
  static final RegExp _futureContext = RegExp(
    r'\b(today|tonight|tomorrow|this evening|this morning|next week|next month|monday|tuesday|wednesday|thursday|friday|saturday|sunday|bugün|bu akşam|bu aksam|akşam|aksam|sabah|yarın|yarin|haftaya|gelecek ay|pazartesi|salı|sali|çarşamba|carsamba|perşembe|persembe|cuma|cumartesi|pazar)\b',
    caseSensitive: false,
  );
  static final RegExp _commitment = RegExp(
    r'\b(meeting|appointment|interview|exam|test|presentation|deadline|due|flight|trip|class|doctor|dentist|call|submit|project|toplantı|toplanti|randevu|görüşme|gorusme|sınav|sinav|sunum|teslim|uçuş|ucus|seyahat|ders|doktor|dişçi|disci|ara|arayacağım|arayacagim|ödev|odev|proje|iş görüşmesi|is gorusmesi)',
    caseSensitive: false,
  );

  static bool matches(String message) {
    final text = message.trim();
    if (text.isEmpty) return false;
    return _explicitReminder.hasMatch(text) ||
        (_futureContext.hasMatch(text) && _commitment.hasMatch(text));
  }

  /// Returns a reasonable upcoming time from explicit wording, defaulting to
  /// 9am tomorrow when the user asked for a reminder without a time.
  static DateTime suggestedTime(String message, {DateTime? now}) {
    final current = now ?? DateTime.now();
    var day = DateTime(current.year, current.month, current.day);
    final text = message.toLowerCase();

    if (RegExp(r'\b(tomorrow|yarın|yarin)\b').hasMatch(text)) {
      day = day.add(const Duration(days: 1));
    } else if (RegExp(r'\b(next month|gelecek ay)\b').hasMatch(text)) {
      day = DateTime(current.year, current.month + 1, current.day);
    } else if (RegExp(r'\b(next week|haftaya)\b').hasMatch(text)) {
      day = day.add(const Duration(days: 7));
    } else {
      const weekdays = <String, int>{
        'monday': DateTime.monday,
        'pazartesi': DateTime.monday,
        'tuesday': DateTime.tuesday,
        'salı': DateTime.tuesday,
        'sali': DateTime.tuesday,
        'wednesday': DateTime.wednesday,
        'çarşamba': DateTime.wednesday,
        'carsamba': DateTime.wednesday,
        'thursday': DateTime.thursday,
        'perşembe': DateTime.thursday,
        'persembe': DateTime.thursday,
        'friday': DateTime.friday,
        'cuma': DateTime.friday,
        'saturday': DateTime.saturday,
        'cumartesi': DateTime.saturday,
        'sunday': DateTime.sunday,
        'pazar': DateTime.sunday,
      };
      for (final entry in weekdays.entries) {
        if (RegExp('\\b${entry.key}\\b').hasMatch(text)) {
          var daysAhead = (entry.value - current.weekday) % 7;
          if (daysAhead == 0) daysAhead = 7;
          day = day.add(Duration(days: daysAhead));
          break;
        }
      }
    }

    var hour = 9;
    var minute = 0;
    if (RegExp(r'\b(tonight|bu akşam|bu aksam|akşam|aksam)\b').hasMatch(text)) {
      hour = 19;
    } else if (RegExp(r'\b(this morning|sabah)\b').hasMatch(text)) {
      hour = 9;
    } else if (RegExp(r'\b(afternoon|öğleden sonra|ogleden sonra)\b')
        .hasMatch(text)) {
      hour = 14;
    }

    final time = RegExp(r'\b(?:at|saat)\s*(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\b')
        .firstMatch(text);
    if (time != null) {
      hour = int.parse(time.group(1)!);
      minute = int.tryParse(time.group(2) ?? '') ?? 0;
      if (time.group(3) == 'pm' && hour < 12) hour += 12;
      if (time.group(3) == 'am' && hour == 12) hour = 0;
      if (hour > 23 || minute > 59) {
        hour = 9;
        minute = 0;
      }
    }

    var result = DateTime(day.year, day.month, day.day, hour, minute);
    if (!result.isAfter(current)) {
      result = DateTime(day.year, day.month, day.day)
          .add(const Duration(days: 1))
          .add(Duration(hours: hour, minutes: minute));
    }
    return result;
  }

  static void offer(BuildContext context, String message) {
    if (!context.mounted || !matches(message)) return;
    final l10n = AppLocalizations.of(context)!;
    final scheduledAt = suggestedTime(message);
    final local = Localizations.localeOf(context).languageCode;
    final timeLabel = MaterialLocalizations.of(context)
        .formatMediumDate(scheduledAt);
    final clockLabel = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(scheduledAt));
    final suggestion = local == 'tr'
        ? '$timeLabel saat $clockLabel için hatırlatma kurayım mı?'
        : 'Want me to remind you on $timeLabel at $clockLabel?';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(suggestion),
          action: SnackBarAction(
            label: l10n.examReminderAction,
            onPressed: () => _schedule(context, message, scheduledAt),
          ),
        ),
      );
  }

  static Future<void> _schedule(
    BuildContext context,
    String message,
    DateTime reminder,
  ) async {
    if (!context.mounted || !reminder.isAfter(DateTime.now())) return;
    final l10n = AppLocalizations.of(context)!;
    final title = _taskTitle(message);
    final notifications = context.read<ExtrovertNotificationService>();
    int? notificationId;
    var reminderMayBeDelayed = false;
    try {
      if (await notifications.requestTaskReminderPermission()) {
        notificationId = DateTime.now().microsecondsSinceEpoch & 0x7fffffff;
        await notifications.scheduleTaskReminder(
          notificationId: notificationId,
          title: '$title — ${l10n.examReminderNotification}',
          scheduledAt: reminder,
        );
        reminderMayBeDelayed = !await notifications
            .canScheduleTaskReminderExactly();
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
    } else if (context.mounted && reminderMayBeDelayed) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.taskReminderMayBeDelayed)));
    }
  }

  static String _taskTitle(String message) {
    final compact = message.replaceAll(RegExp(r'\s+'), ' ').trim();
    return compact.length <= 72 ? compact : '${compact.substring(0, 69)}…';
  }
}
