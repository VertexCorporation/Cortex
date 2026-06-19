import 'package:flutter/foundation.dart';

class RagMemorySystem extends ChangeNotifier {
  final List<String> _memories = [];

  List<String> get memories => _memories;

  void addMemory(String memory) {
    _memories.add(memory);
    notifyListeners();
  }

  void clearMemory() {
    _memories.clear();
    notifyListeners();
  }

  List<String> retrieveContext(String query) {
    // Simple mock RAG retrieval logic
    if (_memories.isEmpty) return [];
    return _memories.where((m) => m.toLowerCase().contains(query.toLowerCase())).toList();
  }
}
