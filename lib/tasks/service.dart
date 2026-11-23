import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/src/home_widget/cortex_tasks.home_widget.dart'
    if (dart.library.html) 'package:cortex/platform/tasks_home_widget_stub.dart';

import 'task.dart';

class TaskService {
  String get _storageKey =>
      'cortex_tasks_v1_${FirebaseAuth.instance.currentUser?.uid ?? 'guest'}';

  Future<List<CortexTask>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      await _syncWidget(const []);
      return [];
    }
    try {
      final tasks = (jsonDecode(raw) as List)
          .map((item) => CortexTask.fromJson(item as Map<String, dynamic>))
          .toList();
      await _syncWidget(tasks);
      return tasks;
    } catch (_) {
      await _syncWidget(const []);
      return [];
    }
  }

  Future<void> save(List<CortexTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(tasks.map((task) => task.toJson()).toList()),
    );
    await _syncWidget(tasks);
  }

  Future<void> _syncWidget(List<CortexTask> tasks) async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    final openTasks = tasks.where((task) => !task.isDone).toList();
    openTasks.sort((a, b) {
      if (a.dueAt == null) return b.dueAt == null ? 0 : 1;
      if (b.dueAt == null) return -1;
      return a.dueAt!.compareTo(b.dueAt!);
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'en';
      final localizations = lookupAppLocalizations(Locale(languageCode));
      await CortexTasksSchemaHomeWidget.saveData(
        widgetTitle: localizations.tasksTitle,
        nextTask: openTasks.isEmpty
            ? localizations.tasksEmptyTitle
            : openTasks.first.title,
        taskCount: openTasks.isEmpty
            ? localizations.taskInputHint
            : '${openTasks.length} · ${localizations.tasksTitle}',
      );
      await CortexTasksSchemaHomeWidget.updateWidget();
    } catch (_) {
      // Widgets are an optional surface; task persistence must still succeed.
    }
  }
}
