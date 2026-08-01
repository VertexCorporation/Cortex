// lib/rag/models.dart
//
// Entity models for the RAG (Retrieval-Augmented Generation) document system.

/// Lifecycle status of a document inside the RAG index.
enum RagDocumentStatus {
  pending, // queued / currently being indexed
  indexed, // fully processed, ready for retrieval
  failed, // extraction or chunking failed
}

/// A single document registered in the RAG index.
class RagDocument {
  final String id; // uuid
  final String title; // display name (file name without extension)
  final String filePath; // absolute path on device
  final int sizeBytes;
  final String mimeType;
  final RagDocumentStatus status;
  final int chunkCount;
  final int createdAt;
  final int updatedAt;

  const RagDocument({
    required this.id,
    required this.title,
    required this.filePath,
    required this.sizeBytes,
    required this.mimeType,
    required this.status,
    required this.chunkCount,
    required this.createdAt,
    required this.updatedAt,
  });

  RagDocument copyWith({
    String? title,
    String? filePath,
    int? sizeBytes,
    String? mimeType,
    RagDocumentStatus? status,
    int? chunkCount,
    int? updatedAt,
  }) {
    return RagDocument(
      id: id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      mimeType: mimeType ?? this.mimeType,
      status: status ?? this.status,
      chunkCount: chunkCount ?? this.chunkCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'sizeBytes': sizeBytes,
      'mimeType': mimeType,
      'status': status.name,
      'chunkCount': chunkCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static RagDocument fromMap(Map<String, dynamic> map) {
    return RagDocument(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      filePath: map['filePath'] as String? ?? '',
      sizeBytes: (map['sizeBytes'] as num?)?.toInt() ?? 0,
      mimeType: map['mimeType'] as String? ?? '',
      status: RagDocumentStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => RagDocumentStatus.pending,
      ),
      chunkCount: (map['chunkCount'] as num?)?.toInt() ?? 0,
      createdAt: (map['createdAt'] as num?)?.toInt() ?? 0,
      updatedAt: (map['updatedAt'] as num?)?.toInt() ?? 0,
    );
  }

  static RagDocumentStatus parseStatus(String? value) {
    return RagDocumentStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => RagDocumentStatus.pending,
    );
  }
}

/// A single text chunk belonging to a [RagDocument].
class RagChunk {
  final int id; // sqflite autoincrement
  final String documentId;
  final int chunkIndex;
  final String text;
  final int charStart;
  final int charEnd;

  const RagChunk({
    required this.id,
    required this.documentId,
    required this.chunkIndex,
    required this.text,
    required this.charStart,
    required this.charEnd,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'documentId': documentId,
      'chunkIndex': chunkIndex,
      'text': text,
      'charStart': charStart,
      'charEnd': charEnd,
    };
  }

  static RagChunk fromMap(Map<String, dynamic> map) {
    return RagChunk(
      id: (map['id'] as num?)?.toInt() ?? 0,
      documentId: map['documentId'] as String? ?? '',
      chunkIndex: (map['chunkIndex'] as num?)?.toInt() ?? 0,
      text: map['text'] as String? ?? '',
      charStart: (map['charStart'] as num?)?.toInt() ?? 0,
      charEnd: (map['charEnd'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A retrieval hit combining a chunk with its matching document title.
class RagRetrievalResult {
  final RagChunk chunk;
  final RagDocument document;
  final double score;

  const RagRetrievalResult({
    required this.chunk,
    required this.document,
    required this.score,
  });
}
