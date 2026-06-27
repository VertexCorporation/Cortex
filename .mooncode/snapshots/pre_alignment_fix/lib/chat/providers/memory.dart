import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserMemoryProvider extends ChangeNotifier {
  static const String _memoryKey = 'cortex_user_portable_memory';
  static const String _instructionKey = 'cortex_user_custom_instruction';
  static const int memoryCharLimit = 2048;

  List<String> _memoryList = [];
  String _customInstruction = "";

  List<String> get memoryList => _memoryList;
  String get memory => _memoryList.join('\n'); // Backward compatibility
  String get customInstruction => _customInstruction;
  bool get isMemoryLimitReached => memory.length >= memoryCharLimit;

  UserMemoryProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final memoryStr = prefs.getString(_memoryKey) ?? "";
    
    if (memoryStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(memoryStr);
        if (decoded is List) {
          _memoryList = decoded.cast<String>();
        } else {
          _memoryList = memoryStr.split('\n').where((s) => s.trim().isNotEmpty).toList();
        }
      } catch (e) {
        _memoryList = memoryStr.split('\n').where((s) => s.trim().isNotEmpty).toList();
      }
    } else {
      _memoryList = [];
    }

    _customInstruction = prefs.getString(_instructionKey) ?? "";
    notifyListeners();
  }

  Future<void> _saveMemory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_memoryKey, jsonEncode(_memoryList));
  }

  Future<void> addMemory(String memory) async {
    final trimmed = memory.trim();
    if (trimmed.isEmpty) return;
    if (!_memoryList.contains(trimmed)) {
      _memoryList.add(trimmed);
      await _saveMemory();
      notifyListeners();
    }
  }

  Future<void> removeMemory(int index) async {
    if (index >= 0 && index < _memoryList.length) {
      _memoryList.removeAt(index);
      await _saveMemory();
      notifyListeners();
    }
  }

  Future<void> editMemory(int index, String newMemory) async {
    if (index >= 0 && index < _memoryList.length) {
      final trimmed = newMemory.trim();
      if (trimmed.isEmpty) {
        _memoryList.removeAt(index);
      } else {
        _memoryList[index] = trimmed;
      }
      await _saveMemory();
      notifyListeners();
    }
  }

  Future<void> updateMemory(String newMemory) async {
    final newMemories = newMemory.split('\n').where((s) => s.trim().isNotEmpty).toList();
    if (_memoryList.join('\n') == newMemories.join('\n')) return;
    _memoryList = newMemories;
    await _saveMemory();
    notifyListeners();
  }

  Future<void> clearMemory() async {
    _memoryList.clear();
    await _saveMemory();
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
