// lib/library/backend/data/entity.dart

import 'format.dart';

/// Represents a unified, type-safe model entity in the application.
///
/// This class serves as the single source of truth for a model's data structure.
/// It is a "dumb" data object that expects to be instantiated with display-ready,
/// pre-localized data from the service or repository layer.
class ModelEntity {
  /// The unique identifier for the model (e.g., 'gpt-4', 'neuro').
  final String id;

  /// The display-ready, localized title.
  final String displayTitle;

  /// The name of the entity or company that produced the model.
  final String producer;

  /// The type of the model (e.g., 'online', 'offline').
  final String type;

  /// The category of the model (e.g., 'roleplay', 'self', 'assistant').
  final String category;

  /// The system prompt or persona definition for roleplay models.
  final String? role;

  /// The display-ready, localized summary.
  final String displaySummary;

  /// The display-ready, localized detailed description.
  final String displayDescription;

  /// The ID of the base model this model is derived from.
  final String? baseModelId;

  /// The raw path to the model's image asset (local file path, asset path, or URL).
  final String? imagePath;

  /// The path to the GGUF file for offline models.
  final String? ggufPath;

  /// The tier of the model (e.g., 'free', 'premium').
  final String tier;

  /// The size of the model in megabytes (MB).
  final int? size;

  /// The required RAM in megabytes (MB) to run the model.
  final int? ram;

  /// A map defining the input modalities supported by the model (e.g., {'image': true}).
  final Map<String, dynamic> modalities;

  /// A map defining the output capabilities of the model (e.g., {'text': true}).
  final Map<String, dynamic> outputs;

  /// A map containing extension data for variant models.
  final Map<String, dynamic>? extensions;

  /// The URL for downloading the model.
  final String? url;

  /// The context window or other technical context for the model (e.g., "8k", "128k").
  final String? context;

  /// Indicates if all main text fields were successfully localized
  /// for the current non-English language, or if an English fallback was used.
  /// This is calculated and provided by the ModelRepository.
  final bool isFullyLocalized;

  /// The chat format configuration for offline models.
  final ChatFormat? chatFormat;

  const ModelEntity({
    required this.id,
    required this.displayTitle,
    required this.producer,
    required this.type,
    required this.category,
    this.role,
    required this.displaySummary,
    required this.displayDescription,
    this.baseModelId,
    this.imagePath,
    this.ggufPath,
    required this.tier,
    this.size,
    this.ram,
    required this.modalities,
    required this.outputs,
    this.extensions,
    this.url,
    this.context,
    required this.isFullyLocalized,
    this.chatFormat,
  });

  /// Factory constructor to create a [ModelEntity] from a raw map.
  factory ModelEntity.fromMap(Map<String, dynamic> map, String langCode) {

    String? getStringOrLocalized(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map) {
        final localizedMap = Map<String, String>.from(value.map((key, val) => MapEntry(key.toString(), val.toString())));
        return localizedMap[langCode] ?? localizedMap['en'];
      }
      return value.toString();
    }

    return ModelEntity(
      id: map['id'] as String,
      displayTitle: map['title'] as String? ?? map['id'] as String,
      producer: map['producer'] as String? ?? 'Unknown',
      type: map['type'] as String? ?? 'online',
      category: map['category'] as String? ?? 'online',
      role: getStringOrLocalized(map['role']),
      displaySummary: map['summary'] as String? ?? '',
      displayDescription: map['description'] as String? ?? '',
      baseModelId: getStringOrLocalized(map['baseModelId']),
      imagePath: getStringOrLocalized(map['imagePath']),
      ggufPath: getStringOrLocalized(map['ggufPath']),
      tier: map['tier'] as String? ?? 'free',
      size: map['size'] as int?,
      ram: map['ram'] as int?,
      modalities: Map<String, dynamic>.from(map['modalities'] as Map? ?? {}),
      outputs: Map<String, dynamic>.from(map['outputs'] as Map? ?? {}),
      extensions: map['extensions'] as Map<String, dynamic>?,
      url: getStringOrLocalized(map['url']),
      context: getStringOrLocalized(map['context']),
      isFullyLocalized: map['isFullyLocalized'] as bool? ?? true,
      chatFormat: map['chatFormat'] != null
          ? ChatFormat.fromMap(map['chatFormat'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Creates a copy of this [ModelEntity] but with the given fields replaced.
  ModelEntity copyWith({
    String? id,
    String? displayTitle,
    String? producer,
    String? type,
    String? category,
    String? role,
    String? displaySummary,
    String? displayDescription,
    String? baseModelId,
    String? imagePath,
    String? ggufPath,
    String? tier,
    int? size,
    int? ram,
    Map<String, dynamic>? modalities,
    Map<String, dynamic>? outputs,
    Map<String, dynamic>? extensions,
    String? url,
    String? context,
    bool? isFullyLocalized,
    ChatFormat? chatFormat,
  }) {
    return ModelEntity(
      id: id ?? this.id,
      displayTitle: displayTitle ?? this.displayTitle,
      producer: producer ?? this.producer,
      type: type ?? this.type,
      category: category ?? this.category,
      role: role ?? this.role,
      displaySummary: displaySummary ?? this.displaySummary,
      displayDescription: displayDescription ?? this.displayDescription,
      baseModelId: baseModelId ?? this.baseModelId,
      imagePath: imagePath ?? this.imagePath,
      ggufPath: ggufPath ?? this.ggufPath,
      tier: tier ?? this.tier,
      size: size ?? this.size,
      ram: ram ?? this.ram,
      modalities: modalities ?? this.modalities,
      outputs: outputs ?? this.outputs,
      extensions: extensions ?? this.extensions,
      url: url ?? this.url,
      context: context ?? this.context,
      isFullyLocalized: isFullyLocalized ?? this.isFullyLocalized,
      chatFormat: chatFormat ?? this.chatFormat,
    );
  }

  /// Converts the [ModelEntity] back to a generic map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': displayTitle,
      'producer': producer,
      'type': type,
      'category': category,
      'role': role,
      'baseModelId': baseModelId,
      'imagePath': imagePath,
      'ggufPath': ggufPath,
      'tier': tier,
      'size': size,
      'ram': ram,
      'modalities': modalities,
      'outputs': outputs,
      'extensions': extensions,
      'url': url,
      'context': context,
      'isFullyLocalized': isFullyLocalized,
    };
  }

  // --- Getters for convenience ---

  bool get isCustomModel => id.startsWith('self_') || id.startsWith('local_');
  bool get isServerSide => type != 'offline';
  bool get isPremium => tier == 'premium';

  @override
  String toString() => 'ModelEntity(id: $id, title: $displayTitle, type: $type)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModelEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}