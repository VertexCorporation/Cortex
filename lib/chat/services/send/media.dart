// lib/chat/services/send/media.dart

import 'package:flutter/foundation.dart';
import '../../../../library/backend/data/entity.dart';
import '../../../../library/backend/data/service.dart';

enum MediaIntent {
  none,
  understand,
  editImage,
  editVideo,
  editAudio,
  generateImage,
  generateVideo,
  generateAudio,
}

class MediaRouter {
  final ModelService _modelService;

  MediaRouter(this._modelService);

  bool isImageFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  bool isVideoFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.avi');
  }

  bool isAudioFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp3') ||
        lower.endsWith('.wav') ||
        lower.endsWith('.m4a') ||
        lower.endsWith('.aac') ||
        lower.endsWith('.ogg');
  }

  String _normalizeIntentText(String text) {
    return text
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _containsAny(String text, List<String> terms) {
    return terms.any((term) => text.contains(term));
  }

  bool _isNegativeIntent(String text) {
    return text.contains("yapma") ||
        text.contains("cizme") ||
        text.contains("uretme") ||
        text.contains("don't") ||
        text.contains("dont") ||
        text.contains("do not");
  }

  MediaIntent inferMediaIntentFromText({
    required String text,
    required bool hasImage,
    required bool hasVideo,
    required bool hasAudio,
  }) {
    final normalized = _normalizeIntentText(text);
    if (normalized.trim().isEmpty) return MediaIntent.none;
    if (_isNegativeIntent(normalized)) return MediaIntent.none;

    const editTerms = [
      'edit',
      'modify',
      'change',
      'replace',
      'remove',
      'erase',
      'add ',
      'upscale',
      'enhance',
      'restore',
      'colorize',
      'background',
      'better',
      'beautify',
      'prettier',
      'style',
      'stylize',
      'turn into',
      'make it',
      'duzenle',
      'degistir',
      'sil',
      'kaldir',
      'ekle',
      'iyilestir',
      'netlestir',
      'renklendir',
      'arka plan',
      'fon',
      'restor',
      'stille',
      'stilize',
      'tarz',
      'tarzi',
      'guzel',
      'daha iyi',
      'daha kaliteli',
      'kaliteli yap',
      'canlandir',
      'kirp',
      'dondur',
      'buyut',
      'kucult',
    ];
    const imageTerms = [
      'image',
      'picture',
      'photo',
      'gorsel',
      'resim',
      'fotograf',
      'foto'
    ];
    const videoTerms = [
      'video',
      'clip',
      'animation',
      'animate',
      'motion',
      'animasyon',
      'hareket',
      'hareketlendir',
      'canlandir'
    ];
    const audioTerms = ['audio', 'voice', 'sound', 'music', 'ses', 'muzik'];
    const generateTerms = [
      'generate',
      'create',
      'draw',
      'make',
      'produce',
      'olustur',
      'uret',
      'ciz',
      'yap'
    ];
    const understandTerms = [
      'what',
      'describe',
      'explain',
      'analyze',
      'read',
      'transcribe',
      'summarize',
      'ne',
      'nedir',
      'acikla',
      'anlat',
      'analiz',
      'oku',
      'cevir',
      'ozetle'
    ];

    final edits = _containsAny(normalized, editTerms);
    final generates = _containsAny(normalized, generateTerms);
    final mentionsImage = _containsAny(normalized, imageTerms);
    final mentionsVideo = _containsAny(normalized, videoTerms);
    final mentionsAudio = _containsAny(normalized, audioTerms);

    if (hasImage && !hasVideo && mentionsVideo && (edits || generates)) {
      return MediaIntent.generateVideo;
    }
    if (hasImage &&
        (edits ||
            (generates &&
                (mentionsImage || !mentionsVideo && !mentionsAudio)))) {
      return MediaIntent.editImage;
    }
    if (hasVideo && (edits || (generates && mentionsVideo))) {
      return MediaIntent.editVideo;
    }
    if (hasAudio && (edits || (generates && mentionsAudio))) {
      return MediaIntent.editAudio;
    }
    if (generates && mentionsVideo) return MediaIntent.generateVideo;
    if (generates && mentionsAudio) return MediaIntent.generateAudio;
    if (generates) return MediaIntent.generateImage;
    if (_containsAny(normalized, understandTerms)) {
      return MediaIntent.understand;
    }

    return MediaIntent.understand;
  }

  Iterable<ModelEntity> iterPreciseModels(String langCode) sync* {
    final seen = <String>{};
    for (final model in _modelService.getCachedModelsSync()) {
      if (seen.add(model.id)) {
        yield _modelService.getPreciseModelData(model.id, langCode: langCode);
      }
      final variants = model.variants;
      if (variants == null) continue;
      for (final entry in variants.entries) {
        final variantId = entry.key;
        if (seen.add(variantId)) {
          yield _modelService.getPreciseModelData(variantId,
              langCode: langCode);
        }
      }
    }
  }

  ModelEntity? pickModel(
    String langCode,
    bool isUserSubscribed,
    bool Function(ModelEntity model) predicate,
  ) {
    final candidates = iterPreciseModels(langCode).where((model) {
      if (!model.isServerSide) return false;
      final id = model.id.toLowerCase();
      if (id.contains('guard')) return false;
      return predicate(model);
    }).toList();

    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      int score(ModelEntity model) {
        var value = 0;
        if (model.source.toLowerCase() == 'openrouter') value += 20;
        if (model.source.toLowerCase() == 'fal') value += 20;
        if (model.tier.toLowerCase() == 'free') value += 10;
        return value;
      }

      return score(b).compareTo(score(a));
    });
    return candidates.first;
  }

  ModelEntity? findFalMediaModel({
    required String langCode,
    required bool isUserSubscribed,
    required String outputType,
    String? requiredInputType,
    Set<String> excludeIds = const {},
  }) {
    return pickModel(
      langCode,
      isUserSubscribed,
      (model) {
        if (excludeIds.contains(model.id)) return false;
        if (model.source.toLowerCase() != 'fal') return false;
        if (model.outputs[outputType] != true && model.category != outputType) {
          return false;
        }
        if (requiredInputType != null &&
            model.modalities[requiredInputType] != true) {
          return false;
        }
        return true;
      },
    );
  }

  ModelEntity? findAttachmentUnderstandingModel({
    required String langCode,
    required bool isUserSubscribed,
    required bool hasImage,
    required bool hasVideo,
    required bool hasAudio,
  }) {
    return pickModel(
      langCode,
      isUserSubscribed,
      (model) {
        final category = model.category.toLowerCase();
        if (category == 'image' || category == 'video' || category == 'audio') {
          return false;
        }
        if (model.source.toLowerCase() == 'fal') return false;
        if (hasImage && model.modalities['image'] != true) return false;
        if (hasVideo && model.modalities['video'] != true) return false;
        if (hasAudio && model.modalities['audio'] != true) return false;
        return model.outputs['text'] == true || model.outputs.isEmpty;
      },
    );
  }

  String? resolveAttachmentIntentModelId({
    required String currentModelId,
    required String text,
    required List<String> attachments,
    required String langCode,
    required bool isUserSubscribed,
  }) {
    if (text.trim().isEmpty) return null;
    if (currentModelId != 'cortex/auto' && currentModelId != 'dynamic') {
      return null;
    }

    // Do not pin a dynamic turn to a local attachment model when the current
    // message has no attachment. The backend can then inspect the complete
    // conversation context (including a previously generated image) and
    // choose the correct FAL or text model for a mid-conversation request.
    if (attachments.isEmpty) return null;

    final hasImage = attachments.any(isImageFile);
    final hasVideo = attachments.any(isVideoFile);
    final hasAudio = attachments.any(isAudioFile);

    final intent = inferMediaIntentFromText(
      text: text,
      hasImage: hasImage,
      hasVideo: hasVideo,
      hasAudio: hasAudio,
    );

    ModelEntity? routed;
    switch (intent) {
      case MediaIntent.editImage:
        routed = findFalMediaModel(
          langCode: langCode,
          isUserSubscribed: isUserSubscribed,
          outputType: 'image',
          requiredInputType: 'image',
        );
        break;
      case MediaIntent.editVideo:
        routed = findFalMediaModel(
          langCode: langCode,
          isUserSubscribed: isUserSubscribed,
          outputType: 'video',
          requiredInputType: hasVideo ? 'video' : null,
        );
        break;
      case MediaIntent.editAudio:
        routed = findFalMediaModel(
          langCode: langCode,
          isUserSubscribed: isUserSubscribed,
          outputType: 'audio',
          requiredInputType: hasAudio ? 'audio' : null,
        );
        break;
      case MediaIntent.generateImage:
        routed = findFalMediaModel(
          langCode: langCode,
          isUserSubscribed: isUserSubscribed,
          outputType: 'image',
          requiredInputType: hasImage ? 'image' : null,
        );
        break;
      case MediaIntent.generateVideo:
        routed = findFalMediaModel(
          langCode: langCode,
          isUserSubscribed: isUserSubscribed,
          outputType: 'video',
          requiredInputType: hasVideo
              ? 'video'
              : hasImage
                  ? 'image'
                  : null,
        );
        break;
      case MediaIntent.generateAudio:
        routed = findFalMediaModel(
          langCode: langCode,
          isUserSubscribed: isUserSubscribed,
          outputType: 'audio',
          requiredInputType: hasAudio ? 'audio' : null,
        );
        break;
      case MediaIntent.understand:
      case MediaIntent.none:
        routed = findAttachmentUnderstandingModel(
          langCode: langCode,
          isUserSubscribed: isUserSubscribed,
          hasImage: hasImage,
          hasVideo: hasVideo,
          hasAudio: hasAudio,
        );
        break;
    }

    if (routed == null) return null;
    debugPrint(
        "[MediaRouter] Attachment intent '$intent' routed dynamic chat to '${routed.id}'.");
    return routed.id;
  }

  bool isFalMediaModel(ModelEntity model, String outputType) {
    return model.source.toLowerCase() == 'fal' &&
        (model.outputs[outputType] == true || model.category == outputType);
  }
}
