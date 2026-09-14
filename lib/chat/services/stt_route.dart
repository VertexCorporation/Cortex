import 'dart:convert';

/// Session language is deliberately independent from the provider route.
enum VoiceLanguageMode { automatic, explicit }

class VoiceLanguageState {
  const VoiceLanguageState({
    this.mode = VoiceLanguageMode.automatic,
    this.currentLanguage,
    this.confidence = 0,
    this.candidateLanguage,
    this.candidateConfidence = 0,
    this.stableObservations = 0,
  });

  final VoiceLanguageMode mode;
  final String? currentLanguage;
  final double confidence;
  final String? candidateLanguage;
  final double candidateConfidence;
  final int stableObservations;

  VoiceLanguageState observe(String? language, double confidence) {
    if (mode == VoiceLanguageMode.explicit ||
        language == null ||
        language.isEmpty) {
      return this;
    }
    final normalized = language.toLowerCase();
    final score = confidence.clamp(0, 1).toDouble();
    if (currentLanguage == normalized && score >= confidence) {
      return VoiceLanguageState(
        mode: mode,
        currentLanguage: currentLanguage,
        confidence: score,
        stableObservations: stableObservations + 1,
      );
    }
    final sameCandidate = candidateLanguage == normalized;
    final nextObservations = sameCandidate ? stableObservations + 1 : 1;
    if (score >= 0.82 && nextObservations >= 2) {
      return VoiceLanguageState(
        mode: mode,
        currentLanguage: normalized,
        confidence: score,
        stableObservations: nextObservations,
      );
    }
    return VoiceLanguageState(
      mode: mode,
      currentLanguage: currentLanguage,
      confidence: confidence,
      candidateLanguage: normalized,
      candidateConfidence: score,
      stableObservations: nextObservations,
    );
  }

  String? get modeName =>
      mode == VoiceLanguageMode.explicit ? 'explicit' : 'automatic';

  Map<String, dynamic> toJson() => {
    'languageMode': modeName,
    if (currentLanguage != null) 'language': currentLanguage,
  };
}

class SttRoute {
  const SttRoute({
    required this.provider,
    required this.model,
    required this.token,
    this.sessionId,
    this.routeId,
    this.expiresAt,
    this.languageMode = VoiceLanguageMode.automatic,
    this.language,
    this.audioFormat = 'linear16',
    this.sampleRate = 16000,
    this.channels = 1,
    this.explain,
    this.allowanceVoiceSeconds,
    this.remainingVoiceSeconds,
    this.reservedVoiceSeconds,
  });

  final String provider;
  final String model;
  final String token;
  final String? sessionId;
  final String? routeId;
  final DateTime? expiresAt;
  final VoiceLanguageMode languageMode;
  final String? language;
  final String audioFormat;
  final int sampleRate;
  final int channels;
  final Map<String, dynamic>? explain;
  final int? allowanceVoiceSeconds;
  final int? remainingVoiceSeconds;
  final int? reservedVoiceSeconds;

  static SttRoute? fromBody(dynamic body) {
    if (body is! Map) return null;
    String? string(String key) =>
        body[key] is String && (body[key] as String).isNotEmpty
        ? body[key] as String
        : null;
    final provider = string('provider');
    final model = string('model');
    final token = string('token');
    if (provider == null || model == null || token == null) return null;
    final language = body['language'];
    final audio = body['audio'];
    final voice = body['voice'];
    int? voiceInt(String key) =>
        voice is Map && voice[key] is num ? (voice[key] as num).round() : null;
    final parsedLanguage = language is Map ? language['currentLanguage'] : null;
    final mode = language is Map && language['mode'] == 'explicit'
        ? VoiceLanguageMode.explicit
        : VoiceLanguageMode.automatic;
    final expiresRaw = string('expiresAt');
    return SttRoute(
      provider: provider,
      model: model,
      token: token,
      sessionId: string('sessionId'),
      routeId: string('routeId'),
      expiresAt: expiresRaw == null ? null : DateTime.tryParse(expiresRaw),
      languageMode: mode,
      language: parsedLanguage is String ? parsedLanguage : null,
      audioFormat: audio is Map && audio['format'] is String
          ? audio['format'] as String
          : 'linear16',
      sampleRate: audio is Map && audio['sampleRate'] is num
          ? (audio['sampleRate'] as num).round()
          : 16000,
      channels: audio is Map && audio['channels'] is num
          ? (audio['channels'] as num).round()
          : 1,
      explain: body['explain'] is Map
          ? Map<String, dynamic>.from(body['explain'] as Map)
          : null,
      allowanceVoiceSeconds: voiceInt('allowanceSeconds'),
      remainingVoiceSeconds: voiceInt('remainingSeconds'),
      reservedVoiceSeconds: voiceInt('reservedSeconds'),
    );
  }

  Map<String, dynamic> toRequestJson() => {
    'provider': provider,
    'model': model,
    if (routeId != null) 'routeId': routeId,
  };
}

Map<String, dynamic>? decodeSttRouteBody(dynamic body) {
  if (body is Map<String, dynamic>) return body;
  if (body is String) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }
  return null;
}
