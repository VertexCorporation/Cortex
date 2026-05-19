import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserMemoryProvider extends ChangeNotifier {
  static const String _memoryKey = 'cortex_user_portable_memory';
  static const String _instructionKey = 'cortex_user_custom_instruction';
  static const int memoryCharLimit = 2048;

  String _memory = "";
  String _customInstruction = "";

  String get memory => _memory;
  String get customInstruction => _customInstruction;
  bool get isMemoryLimitReached => _memory.length >= memoryCharLimit;

  UserMemoryProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _memory = prefs.getString(_memoryKey) ?? "";
    _customInstruction = prefs.getString(_instructionKey) ?? "";
    notifyListeners();
  }

  Future<void> updateMemory(String newMemory) async {
    if (_memory == newMemory) return;
    _memory = newMemory;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_memoryKey, _memory);
    notifyListeners();
  }

  Future<void> clearMemory() async {
    _memory = "";
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_memoryKey);
    notifyListeners();
  }

  Future<void> updateCustomInstruction(String newInstruction) async {
    if (_customInstruction == newInstruction) return;
    _customInstruction = newInstruction;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_instructionKey, _customInstruction);
    notifyListeners();
  }
}
