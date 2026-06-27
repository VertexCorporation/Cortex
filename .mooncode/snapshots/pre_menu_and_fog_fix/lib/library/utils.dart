// lib/library/utils.dart

import 'package:cortex/library/backend/data/service.dart';
import 'backend/data/entity.dart';

/// A utility class containing static helper methods for processing model data.
///
class ModelDataUtils {
  // Private constructor to prevent instantiation of this utility class.
  ModelDataUtils._();

  static String cleanTitle(String? t) {
    if (t == null) return '';
    var s = t.trimLeft();
    while (s.isNotEmpty &&
        (s.startsWith('-') || s.startsWith('_') || s.startsWith(' '))) {
      s = s.substring(1).trimLeft();
    }
    return s;
  }

  /// Finds and returns the optimal variant URL with the lowest RAM (and size) requirements.
  static String? getOptimalDownloadUrl(ModelEntity model) {
    if (model.isServerSide) return model.url;
    if (model.variants == null || model.variants!.isEmpty) return model.url;

    var lowestVariantKey = model.variants!.keys.first;
    int lowestRam = 9999999;
    
    for (var entry in model.variants!.entries) {
      final variantData = entry.value as Map<String, dynamic>;
      final ram = int.tryParse(variantData['ram']?.toString() ?? '') ?? 999999;
      final size = int.tryParse(variantData['size']?.toString() ?? '') ?? 999999;
      
      if (ram < lowestRam) {
         lowestRam = ram;
         lowestVariantKey = entry.key;
      } else if (ram == lowestRam && ram != 999999) {
         final currentLowestData = model.variants![lowestVariantKey] as Map<String, dynamic>;
         final currentLowestSize = int.tryParse(currentLowestData['size']?.toString() ?? '') ?? 999999;
         if (size < currentLowestSize) {
           lowestVariantKey = entry.key;
         }
      }
    }
    return model.variants![lowestVariantKey]['url'] as String?;
  }

  /// Finds and returns the optimal variant ID with the lowest RAM (and size) requirements.
  static String? getOptimalVariantId(ModelEntity model) {
    if (model.isServerSide) return model.id;
    if (model.variants == null || model.variants!.isEmpty) return model.id;

    var lowestVariantKey = model.variants!.keys.first;
    int lowestRam = 9999999;
    
    for (var entry in model.variants!.entries) {
      final variantData = entry.value as Map<String, dynamic>;
      final ram = int.tryParse(variantData['ram']?.toString() ?? '') ?? 999999;
      final size = int.tryParse(variantData['size']?.toString() ?? '') ?? 999999;
      
      if (ram < lowestRam) {
         lowestRam = ram;
         lowestVariantKey = entry.key;
      } else if (ram == lowestRam && ram != 999999) {
         final currentLowestData = model.variants![lowestVariantKey] as Map<String, dynamic>;
         final currentLowestSize = int.tryParse(currentLowestData['size']?.toString() ?? '') ?? 999999;
         if (size < currentLowestSize) {
           lowestVariantKey = entry.key;
         }
      }
    }
    return lowestVariantKey;
  }

  /// Finds the parent series [ModelEntity] for a given model variant ID.
  ///
  /// For example, given 'gemini-1.5-pro', it will find and return the main
  /// 'gemini' series entity. Returns `null` if no parent is found.
  /// If the provided ID is already a base series ID, it returns that entity directly.
  static ModelEntity? findParentSeriesData(
    String modelId, {
    required String langCode,
    required ModelService modelService, // <-- NEW PARAMETER
  }) {
    // Use the provided modelService instance instead of the singleton.
    final allCachedModels = modelService.getCachedModelsSync(); // CORRECTED
    if (allCachedModels.isEmpty) return null;

    // First, check if the ID itself is a parent series.
    try {
      final directMatch =
          allCachedModels.firstWhere((model) => model.id == modelId);
      return directMatch;
    } catch (e) {
      // Not a direct match, proceed to check variants.
    }

    // Next, search within the variants of each series.
    for (final seriesEntity in allCachedModels) {
      if (seriesEntity.variants?.containsKey(modelId) ?? false) {
        return seriesEntity; // Found the parent.
      }
    }

    // If no parent is found anywhere, return null.
    return null;
  }

  /// Calculates the number of valid model variants a user can switch to.
  ///
  /// This is used to determine if the "Change Model" option should be displayed.
  /// If a conversation contains a photo, it only counts variants that can handle images.
  /// Returns 0 if there are no other valid options to switch to.
  static int validVariantCountForChangingModel({
    required ModelEntity parentSeries,
    required bool conversationHasPhoto,
  }) {
    final extMap = parentSeries.variants;
    if (extMap == null || extMap.isEmpty) {
      return 0;
    }

    int count = 0;
    for (var entry in extMap.entries) {
      final data = entry.value;
      if (data is Map<String, dynamic>) {
        if (conversationHasPhoto) {
          // In a photo chat, only count variants that support images.
          final modalities = data['modalities'] as Map<String, dynamic>? ?? {};
          if (modalities['image'] == true) {
            count++;
          }
        } else {
          // In a text-only chat, all variants are valid.
          count++;
        }
      }
    }
    return count;
  }

  /// Takes a raw model ID (e.g., "google/gemma-7b" or "gpt-4-turbo")
  /// and formats it into a human-readable title (e.g., "Google Gemma 7B" or "GPT 4 Turbo").
  static String formatModelName(String modelName) {
    if (modelName.isEmpty) {
      return "";
    }
    String spacedId = modelName
        .replaceAll('/', ' ')
        .replaceAll('-', ' ')
        .replaceAll('_', ' ');
    List<String> parts =
        spacedId.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return "";
    }
    List<String> formattedParts = [];
    for (String segment in parts) {
      String segmentLower = segment.toLowerCase();
      String formattedSegment;
      if (segmentLower == 'chatgpt') {
        formattedSegment = 'ChatGPT';
      } else if (segmentLower == 'gpt') {
        formattedSegment = 'GPT';
      } else if (segmentLower == 'ai') {
        formattedSegment = 'AI';
      } else if (segment.length > 1 &&
          segmentLower.endsWith('b') &&
          int.tryParse(segment.substring(0, segment.length - 1)) != null) {
        formattedSegment = '${segment.substring(0, segment.length - 1)}B';
      } else if (segment.toUpperCase() == segment &&
          RegExp(r'[A-Z]').hasMatch(segment)) {
        // If it's already an uppercase acronym (and not just numbers), keep it
        // However, if the word is longer than 4 chars, it's likely a mistake (like CHATGPT),
        // so we format it normally unless it's a known acronym.
        if (segment.length > 4) {
          formattedSegment =
              segment[0].toUpperCase() + segment.substring(1).toLowerCase();
          if (segmentLower.endsWith('ai')) {
            formattedSegment =
                '${formattedSegment.substring(0, formattedSegment.length - 2)}AI';
          }
        } else {
          formattedSegment = segment;
        }
      } else {
        formattedSegment =
            segment[0].toUpperCase() + segment.substring(1).toLowerCase();
        if (segmentLower.endsWith('ai')) {
          formattedSegment =
              '${formattedSegment.substring(0, formattedSegment.length - 2)}AI';
        }
      }
      formattedParts.add(formattedSegment);
    }
    return formattedParts.join(' ');
  }
}
