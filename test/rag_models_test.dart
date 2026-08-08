import 'package:cortex/rag/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('new chunks leave the SQLite autoincrement id unset', () {
    const chunk = RagChunk(
      id: 0,
      documentId: 'doc-1',
      chunkIndex: 0,
      text: 'İçerik',
      charStart: 0,
      charEnd: 6,
    );

    expect(chunk.toMap(), isNot(contains('id')));
  });

  test('persisted chunks retain their database id', () {
    const chunk = RagChunk(
      id: 7,
      documentId: 'doc-1',
      chunkIndex: 0,
      text: 'İçerik',
      charStart: 0,
      charEnd: 6,
    );

    expect(chunk.toMap()['id'], 7);
  });
}
