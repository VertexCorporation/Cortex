import 'package:cortex/chat/services/database.dart';
import 'package:sqflite/sqflite.dart';

class SemanticMemoryService {
  final DbHelper _dbHelper = DbHelper();

  /// Automatically parses a memory block, splits it into individual memory lines,
  /// extracts a key phrase from each line, and saves it to the SQLite database.
  Future<void> saveFromMemoryBlock(String memoryBlock) async {
    final lines = memoryBlock
        .split(RegExp(r'[\n\r]+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty);
    for (final line in lines) {
      // Clean and use the first 3-4 words as a key phrase
      final words = line
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .split(RegExp(r'\s+'))
          .where((w) => w.length > 2)
          .take(4)
          .join(' ');
      final key = words.isNotEmpty ? words : 'general';
      await saveMemory(key, line);
    }
  }

  /// Saves or updates a memory in the local database.
  Future<void> saveMemory(String keyPhrase, String content,
      {String category = 'general', int importance = 3}) async {
    final db = await _dbHelper.db;
    await db.insert(
      'semantic_memories',
      {
        'category': category,
        'key_phrase': keyPhrase.toLowerCase().trim(),
        'content': content,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'importance': importance,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Deletes a memory by its key phrase.
  Future<void> deleteMemory(String keyPhrase) async {
    final db = await _dbHelper.db;
    await db.delete(
      'semantic_memories',
      where: 'key_phrase = ?',
      whereArgs: [keyPhrase.toLowerCase().trim()],
    );
  }

  /// Queries all saved memories.
  Future<List<Map<String, dynamic>>> getAllMemories() async {
    final db = await _dbHelper.db;
    return await db.query('semantic_memories', orderBy: 'created_at DESC');
  }

  /// Finds and retrieves the most relevant memories for the given user prompt.
  /// Uses a fast local TF-IDF style term frequency intersection.
  Future<List<Map<String, dynamic>>> queryRelevantMemories(String userPrompt,
      {int limit = 5}) async {
    final db = await _dbHelper.db;
    final memories = await db.query('semantic_memories');
    if (memories.isEmpty) return [];

    // Clean and tokenize user prompt
    final promptWords = userPrompt
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2) // skip short words/stop words
        .toSet();

    if (promptWords.isEmpty) return [];

    final List<Map<String, dynamic>> scoredMemories = [];

    for (final memory in memories) {
      final keyPhrase = (memory['key_phrase'] as String? ?? '').toLowerCase();
      final content = (memory['content'] as String? ?? '').toLowerCase();
      final importance = memory['importance'] as int? ?? 3;

      // Score based on word intersections in key phrase and content
      int score = 0;
      for (final word in promptWords) {
        if (keyPhrase.contains(word)) {
          score += 10; // high weight for key phrase matches
        }
        if (content.contains(word)) {
          score += 3; // normal weight for content matches
        }
      }

      if (score > 0) {
        final finalScore = score * importance;
        scoredMemories.add({
          ...memory,
          'relevance_score': finalScore,
        });
      }
    }

    if (scoredMemories.isEmpty) return [];

    // Sort by score descending
    scoredMemories.sort((a, b) =>
        (b['relevance_score'] as int).compareTo(a['relevance_score'] as int));

    return scoredMemories.take(limit).toList();
  }
}
