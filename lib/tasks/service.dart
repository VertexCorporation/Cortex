import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'task.dart';

class TaskService {
  String get _storageKey =>
      'cortex_tasks_v1_${FirebaseAuth.instance.currentUser?.uid ?? 'guest'}';

  Future<List<CortexTask>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((item) => CortexTask.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<CortexTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(tasks.map((task) => task.toJson()).toList()),
    );
  }
}
