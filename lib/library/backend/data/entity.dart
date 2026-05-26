// lib/library/backend/data/entity.dart

import 'format.dart';

/// Represents a unified, type-safe model entity in the application.
///
/// This class serves as the single source of truth for a model's data structure.
/// It is a "dumb" data object that expects to be instantiated with display-ready,
/// pre-localized data from the service or repository layer.
class ModelEntity {
  /// Strips wrapping quotes and asterisks from text fields.
  /// Handles: "text", 'text', **text**, *text*, and lone leading/trailing " or *.
  static String _stripWrappedQuotes(String value) {
    String result = value.trim();

    const wrappers = [
      ['"', '"'],
      ["'", "'"],
      ['\u201c', '\u201d'],
      ['\u201e', '\u201d'],
      ['\u00ab', '\u00bb'],
      ['**', '**'],
      ['*', '*'],
    ];

    bool changed = true;
    while (changed && result.length >= 2) {
      changed = false;
      for (final pair in wrappers) {
        if (result.startsWith(pair[0]) && result.endsWith(pair[1])) {
          result = result
              .substring(pair[0].length, result.length - pair[1].length)
              .trim();
          changed = true;
          break;
        }
      }
    }

    // Strip lone leading/trailing formatting chars
    result = result.replaceAll(RegExp(r'^["*]+'), '');
    result = result.replaceAll(RegExp(r'["*]+$'), '');
    return result.trim();
  }

  /// The unique identifier for the model (e.g., 'gpt-5', 'neuro').
  final String id;

  /// The display-ready, localized title.
  final String displayTitle;

  /// The series of the model.
  final String? series;

  /// The name of the entity or company that produced the model.
  final String producer;

  /// The type of the model (e.g., 'online', 'offline').
  final String type;

  /// The source/provider of the model (e.g., 'openrouter', 'fal', 'huggingface').
  final String source;

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

  /// Whether the model supports tool use.
  final bool toolUse;

  /// A map containing variant data for variant models.
  final Map<String, dynamic>? variants;

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
    this.series,
    required this.producer,
    required this.type,
    required this.source,
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
    required this.toolUse,
    this.variants,
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
        for (final key in _languageFallbackKeys(langCode)) {
          final localizedValue = value[key]?.toString().trim();
          if (localizedValue != null && localizedValue.isNotEmpty) {
            return localizedValue;
          }
        }
        return value.values.firstOrNull?.toString();
      }
      return value.toString();
    }

    String? getLocalizedFieldFromDetails(String field) {
      final details = map['details'];
      if (details is! Map) return null;

      for (final key in _languageFallbackKeys(langCode)) {
        final localizedDetails = details[key];
        if (localizedDetails is Map) {
          final value = localizedDetails[field]?.toString().trim();
          if (value != null && value.isNotEmpty) {
            return value;
          }
        }
      }
      return null;
    }

    final id = map['id']?.toString() ?? 'unknown';
    final seriesSource = getStringOrLocalized(map['series']);
    final rawTitleCandidate = getLocalizedFieldFromDetails('title') ??
        getStringOrLocalized(map['title']);
    final rawTitle =
    rawTitleCandidate
        ?.trim()
        .isNotEmpty == true ? rawTitleCandidate : null;
    final hasUsableSeriesTitle = seriesSource != null &&
        seriesSource
            .trim()
            .isNotEmpty &&
        !_looksLikeRawId(seriesSource, id);
    final titleSource = _looksLikeRawId(rawTitle, id) && hasUsableSeriesTitle
        ? seriesSource
        : rawTitle ?? seriesSource ?? id;

    return ModelEntity(
      id: id,
      displayTitle: titleSource.isNotEmpty
          ? formatName(
        titleSource,
        isOfflineVariant: map['type'] == 'offline',
      )
          : 'Unknown Model',
      series: formatName(seriesSource),
      producer: formatName(getStringOrLocalized(map['producer'])) != ""
          ? formatName(getStringOrLocalized(map['producer']))
          : 'Unknown',
      type: getStringOrLocalized(map['type']) ?? 'online',
      source: getStringOrLocalized(map['source']) ?? 'openrouter',
      category: getStringOrLocalized(map['category']) ?? 'online',
      role: getLocalizedFieldFromDetails('role') ??
          getStringOrLocalized(map['role']),
      displaySummary: _stripWrappedQuotes(
          getLocalizedFieldFromDetails('summary') ??
              getStringOrLocalized(map['summary']) ??
              ''),
      displayDescription: _stripWrappedQuotes(
          getLocalizedFieldFromDetails('description') ??
              getStringOrLocalized(map['description']) ??
              ''),
      baseModelId: getStringOrLocalized(map['baseModelId']),
      imagePath: getStringOrLocalized(map['imagePath']),
      ggufPath: getStringOrLocalized(map['ggufPath']),
      tier: getStringOrLocalized(map['tier']) ?? 'free',
      size: int.tryParse(map['size']?.toString() ?? ''),
      ram: int.tryParse(map['ram']?.toString() ?? ''),
      modalities: _safeStringKeyMap(map['modalities']),
      outputs: _safeStringKeyMap(map['outputs']),
      toolUse: map['toolUse'] == true,
      variants: map['variants'] is Map
          ? Map<String, dynamic>.from(map['variants'] as Map)
          : null,
      url: getStringOrLocalized(map['url']),
      context: getStringOrLocalized(map['context']),
      isFullyLocalized: map['isFullyLocalized'] as bool? ?? true,
      chatFormat: map['chatFormat'] != null
          ? ChatFormat.fromMap(map['chatFormat'] as Map<String, dynamic>)
          : null,
    );
  }

  static bool _looksLikeRawId(String? value, String id) {
    if (value == null || value
        .trim()
        .isEmpty) {
      return false;
    }
    String normalize(String input) =>
        input.replaceAll(RegExp(r'[\s_\-/]+'), '').toLowerCase();
    return normalize(value) == normalize(id);
  }

  static String _normalizedLangCode(String langCode) =>
      langCode
          .split(RegExp(r'[-_]'))
          .first
          .toLowerCase();

  static List<String> _languageFallbackKeys(String langCode) {
    final normalized = _normalizedLangCode(langCode);
    final keys = <String>[
      normalized,
      if (normalized == 'zh') 'cn',
      if (normalized == 'cn') 'zh',
      'en',
    ];
    return keys.toSet().toList();
  }

  static Map<String, dynamic> _safeStringKeyMap(dynamic value) {
    if (value is! Map) return {};
    return Map<String, dynamic>.from(value);
  }

  /// Creates a copy of this [ModelEntity] but with the given fields replaced.
  ModelEntity copyWith({
    String? id,
    String? displayTitle,
    String? series,
    String? producer,
    String? type,
    String? source,
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
    bool? toolUse,
    Map<String, dynamic>? variants,
    String? url,
    String? context,
    bool? isFullyLocalized,
    ChatFormat? chatFormat,
  }) {
    return ModelEntity(
      id: id ?? this.id,
      displayTitle: displayTitle ?? this.displayTitle,
      series: series ?? this.series,
      producer: producer ?? this.producer,
      type: type ?? this.type,
      source: source ?? this.source,
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
      toolUse: toolUse ?? this.toolUse,
      variants: variants ?? this.variants,
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
      'series': series,
      'producer': producer,
      'type': type,
      'category': category,
      'role': role,
      'summary': displaySummary,
      'description': displayDescription,
      'baseModelId': baseModelId,
      'imagePath': imagePath,
      'ggufPath': ggufPath,
      'tier': tier,
      'size': size,
      'ram': ram,
      'modalities': modalities,
      'outputs': outputs,
      'toolUse': toolUse,
      'variants': variants,
      'url': url,
      'context': context,
      'isFullyLocalized': isFullyLocalized,
      'chatFormat': chatFormat?.toMap(),
    };
  }

  // --- Getters for convenience ---

  bool get isCustomModel => id.startsWith('self_') || id.startsWith('local_');

  bool get isServerSide => type != 'offline';

  bool get isPremium => tier == 'premium';

  @override
  String toString() =>
      'ModelEntity(id: $id, title: $displayTitle, type: $type)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModelEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
