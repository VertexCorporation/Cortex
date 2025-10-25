// lib/chat/widgets/options/utils.dart

import 'package:flutter/cupertino.dart';

import '../../backend/data/data.dart';
import '../../backend/data/entity.dart'; // --- IMPORT ModelEntity ---

/// A utility class containing static helper methods for processing model data.
///
class ModelDataUtils {
  // Private constructor to prevent instantiation of this utility class.
  ModelDataUtils._();

  /// Finds the parent series [ModelEntity] for a given model variant ID.
  ///
  /// For example, given 'gemini-1.5-pro', it will find and return the main
  /// 'gemini' series entity. Returns `null` if no parent is found.
  /// If the provided ID is already a base series ID, it returns that entity directly.
  static ModelEntity? findParentSeriesData(String modelId, {required String langCode}) {
    final allCachedModels = ModelData.getCachedModelsSync();
    if (allCachedModels.isEmpty) return null;

    // First, check if the ID itself is a parent series.
    try {
      final directMatch = allCachedModels.firstWhere((model) => model.id == modelId);
      return directMatch;
    } catch(e) {
      // Not a direct match, proceed to check extensions.
    }

    // Next, search within the extensions of each series.
    for (final seriesEntity in allCachedModels) {
      if (seriesEntity.extensions?.containsKey(modelId) ?? false) {
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
  static int validExtensionCountForChangingModel({
    required ModelEntity parentSeries,
    required bool conversationHasPhoto,
  }) {
    final extMap = parentSeries.extensions;
    if (extMap == null || extMap.isEmpty) {
      return 0;
    }

    int count = 0;
    for (var entry in extMap.entries) {
      final data = entry.value;
      if (data is Map<String, dynamic>) {
        if (conversationHasPhoto) {
          // In a photo chat, only count extensions that support images.
          // REFACTORED: Safe access to the nested map.
          final modalities = data['modalities'] as Map<String, dynamic>? ?? {};
          if (modalities['image'] == true) {
            count++;
          }
        } else {
          // In a text-only chat, all extensions are valid.
          count++;
        }
      }
    }
    return count;
  }

  /// Takes a raw model ID (e.g., "google/gemma-7b" or "gpt-4-turbo")
  /// and formats it into a human-readable title (e.g., "Google Gemma 7B" or "GPT 4 Turbo").
  static String formatModelId(String rawId) {
    if (rawId.isEmpty) {
      return "";
    }
    String spacedId = rawId.replaceAll('/', ' ').replaceAll('-', ' ');
    List<String> parts = spacedId.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return "";
    }
    List<String> formattedParts = [];
    for (String segment in parts) {
      String segmentLower = segment.toLowerCase();
      String formattedSegment;

      if (segmentLower == 'gpt') {
        formattedSegment = 'GPT';
      } else if (segmentLower == 'ai') {
        formattedSegment = 'AI';
      } else if (segment.length > 1 &&
          segmentLower.endsWith('b') &&
          int.tryParse(segment.substring(0, segment.length - 1)) != null) {
        formattedSegment = '${segment.substring(0, segment.length - 1)}B';
      } else {
        formattedSegment = segment[0].toUpperCase() + segment.substring(1).toLowerCase();
        if (segmentLower.endsWith('ai')) {
          formattedSegment = '${formattedSegment.substring(0, formattedSegment.length - 2)}AI';
        }
      }
      formattedParts.add(formattedSegment);
    }
    return formattedParts.join(' ');
  }
}

class SlideRightRoute extends PageRouteBuilder<bool> {
  final Widget page;
  SlideRightRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}