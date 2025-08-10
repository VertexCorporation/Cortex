// read.dart

import 'dart:math';
import 'package:cortex/models/backend/utils.dart'; // <-- REQUIRED IMPORT
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shimmer/shimmer.dart';

import '../../conversations/manager.dart';
import '../../models/backend/data.dart';
import '../../theme.dart';
import '../chat.dart';
import '../messages/messages.dart';
import 'database.dart';

class ReadService {
  final ChatScreenState state;
  bool _areMessagesLoaded = false;
  bool get areMessagesLoaded => _areMessagesLoaded;

  ReadService(this.state);

  /// --- THE FINAL, UNIFIED FIX for loading conversations ---
  /// This function now robustly handles all model types and correctly
  /// resolves the file path for offline models when loading a conversation.
  Future<void> loadConversation(ConversationManager manager) async {
    const String logPrefix = "[ReadService.loadConversation]";
    final String conversationSpecificModelId = manager.modelId;
    debugPrint("$logPrefix: Loading conversation. Specific modelId from manager: '$conversationSpecificModelId'");

    // Ensure model data is available
    await state.loadService.loadModels();
    final preciseModelData = ModelData.getPreciseModelData(conversationSpecificModelId);

    // Prepare necessary variables
    Map<String, dynamic> uiSeriesData;
    Map<String, dynamic> technicalVariantData = preciseModelData;
    String parentSeriesId;
    String activeExtensionId = conversationSpecificModelId;

    // Check if the model is an extension of a parent series
    final parentSeriesCandidate = state.loadService.allModels.firstWhere(
          (m) => (m.extensions?.containsKey(conversationSpecificModelId) ?? false),
      orElse: () => ModelInfo(id: '', title: '', imagePath: '', producer: ''),
    );

    if (parentSeriesCandidate.id.isNotEmpty) {
      debugPrint("$logPrefix: Model '$conversationSpecificModelId' is an extension of '${parentSeriesCandidate.id}'.");
      parentSeriesId = parentSeriesCandidate.id;
      uiSeriesData = ModelData.getPreciseModelData(parentSeriesId);
    } else {
      debugPrint("$logPrefix: Model '$conversationSpecificModelId' is a standalone or character model.");
      final baseModelId = preciseModelData['baseModelId'] as String? ?? conversationSpecificModelId;
      parentSeriesId = ModelData.getBaseIdFromFullId(baseModelId);
      uiSeriesData = preciseModelData;
      activeExtensionId = baseModelId;
    }

    // --- THE PERFECT FIX IS HERE ---
    // 1. Check if the model is supposed to be offline.
    final bool isOffline = (technicalVariantData['type'] as String?) == 'offline';
    String? finalModelPath;

    if (isOffline) {
      // 2. If it's offline, actively fetch the downloaded paths from SharedPreferences.
      final downloadedPaths = await UserModels.loadDownloadedModelPaths();

      // 3. Use the model's base ID to look up its actual, current file path on disk.
      // This handles variants correctly, e.g., getting the path for 'phi-3-mini-instruct'
      // even if the full ID is 'phi-3-mini-instruct-128k'.
      final baseId = ModelData.getBaseIdFromFullId(conversationSpecificModelId);
      finalModelPath = downloadedPaths[baseId];
      debugPrint("$logPrefix: Offline model detected. Base ID: '$baseId'. Resolved path: '$finalModelPath'");
    }
    // For online models, `finalModelPath` will correctly remain null.
    // --- END OF FIX ---

    final bool definitiveCanHandleImage = ModelData.getDefinitiveImageHandling(conversationSpecificModelId);

    // Set the ChatScreen's state with the correct, resolved data
    state.setState(() {
      state.modelTitle = uiSeriesData['title'] as String?;
      state.modelImagePath = ModelData.getModelImagePath(uiSeriesData); // Use helper for safety
      state.modelProducer = uiSeriesData['producer'] as String?;
      state.modelId = technicalVariantData['id'] as String;
      state.selectedModelCategory = technicalVariantData['category'] as String?;
      state.role = technicalVariantData['role'] as String?;

      // 4. Set the ChatScreen's `modelPath` to the correctly resolved path.
      // This will be null for online models and the correct disk path for offline models.
      state.modelPath = finalModelPath;

      state.isCurrentModelServerSide = !isOffline;
      state.canHandleImage = definitiveCanHandleImage;
      state.currentModelHasWise = (technicalVariantData['features'] as String?)?.split('/').contains('wise') ?? false;
      state.isModelSelected = true;
      state.isModelLoaded = state.isCurrentModelServerSide;
      state.openedFromMenu = true;
      state.conversationID = manager.conversationID;
      state.conversationTitle = manager.conversationTitle;
      debugPrint("$logPrefix: State configured: modelId='${state.modelId}', title='${state.modelTitle}', category='${state.selectedModelCategory}', path='${state.modelPath}'");
    });

    // Initialize the extensions panel
    state.extensions.initialize(
      mainId: parentSeriesId,
      ext: activeExtensionId,
      modelData: ModelData.getPreciseModelData(parentSeriesId),
      updateCanHandleImage: (bool value) {
        if (state.mounted && state.canHandleImage != value) {
          state.setState(() => state.canHandleImage = value);
        }
      },
    );

    debugPrint("$logPrefix: Chat state successfully configured for conversation '${manager.conversationID}' with model '$conversationSpecificModelId'.");
    await loadPreviousMessages(manager.conversationID);
  }

  // ... (The rest of the code in the file remains unchanged)
  int _toInt(dynamic v, [int def = 0]) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? def;

  bool _toBool(dynamic v) => _toInt(v) == 1;

  Future<void> loadPreviousMessages(String convId) async {
    const String logPrefix = "[ReadService.loadPreviousMessages]";
    debugPrint("$logPrefix: Called for convId: '$convId'");

    if (!state.mounted) {
      debugPrint("$logPrefix: State not mounted. Aborting message loading.");
      return;
    }
    bool success = false;

    try {
      final db = await DbHelper().db;
      const retries = 20;
      const wait = Duration(milliseconds: 100);
      List<Map<String, Object?>> rows = [];

      for (var i = 0; i < retries; i++) {
        try {
          rows = await db.query(
            'messages',
            where: 'conversationId = ?',
            whereArgs: [convId],
            orderBy: 'idx ASC, id ASC',
          );
          break;
        } on DatabaseException catch (e) {
          if (e.toString().toLowerCase().contains('database is locked')) {
            debugPrint(
                "$logPrefix: Database locked on attempt ${i + 1} for convId '$convId'. Retrying after $wait...");
            await Future.delayed(wait);
            continue;
          }
          debugPrint(
              "$logPrefix: DatabaseException (not a lock) for convId '$convId': $e");
          rethrow;
        }
      }

      if (state.mounted) {
        state.messages
          ..clear()
          ..addAll(rows.map((r) => Message(
            text: (r['text'] ?? '') as String,
            isUserMessage: _toBool(r['isUser']),
            opacity: 1.0,
            isReported: _toBool(r['isReported']),
            photoPath: r['photoPath'] as String?,
            model: r['model'] as String?,
            includeInContext: _toBool(r['includeInContext']),
          )));

        if (state.messages.isNotEmpty) {
          final lastMessage = state.messages.last;
          if (!lastMessage.isUserMessage &&
              lastMessage.text.trim().isEmpty &&
              (lastMessage.photoPath ?? '').isEmpty &&
              state.messages.length > 1) {
            state.messages.removeLast();
            debugPrint(
                "$logPrefix: Removed trailing empty AI message for convId '$convId'.");
          }
        }
      }
      success = true;
      debugPrint(
          "$logPrefix: Successfully loaded ${rows.length} messages for convId: '$convId'.");
    } catch (e, stacktrace) {
      debugPrint(
          "$logPrefix: Error loading previous messages for convId '$convId': $e\n$stacktrace");
      success = false;
    } finally {
      if (state.mounted) {
        state.setState(() => _areMessagesLoaded = success);
      }
    }

    if (success && state.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (state.mounted) {
          state.scrollService.jumpToBottom();
          debugPrint("$logPrefix: Scrolled to bottom for convId '$convId'.");
        }
      });
    }
  }

  Widget buildSkeletonChatMessages() {
    final screenWidth = MediaQuery.of(state.context).size.width;
    final screenHeight = MediaQuery.of(state.context).size.height;
    final random = Random();

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      itemCount: 20,
      itemBuilder: (context, index) {
        bool isUserMessage = index % 2 == 0;
        double height;
        double width;

        if (isUserMessage) {
          height = screenHeight * (0.05 + random.nextDouble() * 0.03);
          width = screenWidth * (0.4 + random.nextDouble() * 0.3);
        } else {
          width = screenWidth * (0.7 + random.nextDouble() * 0.2);
          height = screenHeight * (0.08 + random.nextDouble() * 0.07);
        }

        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.008,
            horizontal: screenWidth * 0.04,
          ),
          child: Align(
            alignment:
            isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
            child: Shimmer.fromColors(
              baseColor: AppColors.shimmerBase,
              highlightColor: AppColors.shimmerHighlight,
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryColor,
                  borderRadius:
                  BorderRadius.circular(isUserMessage ? (height / 2) : 12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void markLoaded() {
    if (!_areMessagesLoaded) {
      _areMessagesLoaded = true;
      if (state.mounted) {
        state.setState(() {});
      }
      debugPrint("[ReadService.markLoaded] Messages marked as loaded.");
    }
  }
}