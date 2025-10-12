// read.dart

import 'dart:math';
import 'package:cortex/chat/services/storage.dart';
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

  /// This function now robustly handles all model types, and crucially,
  /// notifies its parent (`MainScreen`) to hide the BottomAppBar when a
  /// conversation is successfully loaded from the inbox.
  Future<void> loadConversation(ConversationManager manager) async {
    const String logPrefix = "[ReadService.loadConversation]";
    final String conversationSpecificModelId = manager.modelId;
    debugPrint("$logPrefix: Loading conversation. ModelId from manager: '$conversationSpecificModelId'");

    // If the conversation being loaded is a dynamic chat, handle it with a
    // special setup process and exit early.
    if (conversationSpecificModelId == 'dynamic') {
      debugPrint("$logPrefix: Dynamic conversation detected. Initializing in persistent dynamic mode.");

      state.setState(() {
        // Set all the flags required for a persistent dynamic session
        state.isDynamicChatMode = true;
        state.isPersistentlyDynamic = true;
        state.isModelSelected = false; // No specific model is selected
        state.appBarModeNotifier.value = AppBarMode.dynamicChat;

        // Load conversation details from the manager
        state.conversationID = manager.conversationID;
        state.conversationTitle = manager.conversationTitle;
        state.openedFromMenu = true;

        // Clear any previous model's data
        state.modelTitle = null;
        state.modelImagePath = null;
        state.modelProducer = null;
        state.modelId = null; // Important: modelId is null in this mode
      });

      // After setting up the dynamic mode, immediately check if there's a
      // pinned assistant that should override the default random behavior.
      await state.dynamicChatService.loadDynamicAssistantPreference();

      // Notify the MainScreen that a selection change has occurred,
      // which will trigger the BottomAppBar to hide.
      state.widget.onModelSelectionChanged?.call(true);

      // Load the chat history and finish.
      await loadPreviousMessages(manager.conversationID);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (state.mounted) {
          state.textFieldFocusNode.requestFocus();
        }
      });
      return; // Exit the function to prevent normal model loading logic.
    }

    // The rest of the function is the logic for loading a NORMAL, model-specific chat.
    // It will only be executed if the modelId is NOT 'dynamic'.
    await state.loadService.loadModels();
    final preciseModelData = ModelData.getPreciseModelData(conversationSpecificModelId);

    Map<String, dynamic> uiSeriesData;
    String parentSeriesId;
    String activeExtensionId = conversationSpecificModelId;

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

    final bool isOffline = (preciseModelData['type'] as String?) == 'offline';
    String? finalModelPath;

    if (isOffline) {
      final downloadedPaths = await UserModels.loadDownloadedModelPaths();
      final baseId = ModelData.getBaseIdFromFullId(conversationSpecificModelId);
      finalModelPath = downloadedPaths[baseId];
      debugPrint("$logPrefix: Offline model detected. Base ID: '$baseId'. Resolved path: '$finalModelPath'");
    }

    final bool definitiveCanHandleImage = ModelData.hasModality(conversationSpecificModelId, 'image');

    bool isPremium = false;
    final category = preciseModelData['category'] as String?;

    if (category == 'self' || category == 'roleplay') {
      final String? baseModelId = preciseModelData['baseModelId'] as String?;
      if (baseModelId != null && baseModelId.isNotEmpty) {
        final Map<String, dynamic> baseModelData = ModelData.getPreciseModelData(baseModelId);
        isPremium = (baseModelData['tier'] as String? ?? 'free') == 'premium';
        debugPrint("$logPrefix: Character model. Premium status from base '$baseModelId': $isPremium");
      }
    } else {
      isPremium = (preciseModelData['tier'] as String? ?? 'free') == 'premium';
      debugPrint("$logPrefix: Standard model. Premium status: $isPremium");
    }

    state.setState(() {
      state.appBarModeNotifier.value = AppBarMode.modelSelected;
      state.modelTitle = uiSeriesData['title'] as String?;
      state.modelImagePath = ModelData.getModelImagePath(uiSeriesData);
      state.modelProducer = uiSeriesData['producer'] as String?;
      state.modelId = preciseModelData['id'] as String;
      state.selectedModelCategory = preciseModelData['category'] as String?;
      state.role = preciseModelData['role'] as String?;
      state.modelPath = finalModelPath;
      state.isCurrentModelServerSide = !isOffline;
      state.canHandleImage = definitiveCanHandleImage;
      state.currentModelHasWise = (preciseModelData['features'] as String?)?.split('/').contains('wise') ?? false;
      state.isModelSelected = true;
      state.isModelLoaded = state.isCurrentModelServerSide;
      state.openedFromMenu = true;
      state.conversationID = manager.conversationID;
      state.conversationTitle = manager.conversationTitle;
      state.showPremiumBriefing = isPremium;
      debugPrint("$logPrefix: State configured: modelId='${state.modelId}', title='${state.modelTitle}', isPremium='${state.showPremiumBriefing}'");
    });

    // Notify the MainScreen that a selection change has occurred,
    // which will trigger the BottomAppBar to hide.
    state.widget.onModelSelectionChanged?.call(true);

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.mounted) {
        state.textFieldFocusNode.requestFocus();
      }
    });
  }

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
            debugPrint("$logPrefix: Database locked on attempt ${i + 1} for convId '$convId'. Retrying after $wait...");
            await Future.delayed(wait);
            continue;
          }
          debugPrint("$logPrefix: DatabaseException (not a lock) for convId '$convId': $e");
          rethrow;
        }
      }

      // --- LAZY MIGRATION & BULLETPROOF LOADING ---
      bool needsDbUpdate = false;
      final List<Message> loadedMessages = rows.map((r) {
        // If 'uuid' is null, it's an old message that needs an upgrade.
        if (r['uuid'] == null) {
          needsDbUpdate = true; // Mark that we need to save changes back to the DB.
        }
        return Message(
          id: r['uuid'] as String?, // Constructor handles null by creating a new UUID
          text: (r['text'] ?? '') as String,
          isUserMessage: (r['isUser'] as int? ?? 0) == 1,
          opacity: 1.0,
          isReported: (r['isReported'] as int? ?? 0) == 1,
          photoPath: r['photoPath'] as String?,
          model: r['model'] as String?,
          includeInContext: (r['includeInContext'] as int? ?? 1) == 1,
        );
      }).toList();

      if (state.mounted) {
        state.messages
          ..clear()
          ..addAll(loadedMessages);

        if (state.messages.isNotEmpty) {
          final lastMessage = state.messages.last;
          if (!lastMessage.isUserMessage &&
              lastMessage.text.trim().isEmpty &&
              (lastMessage.photoPath ?? '').isEmpty &&
              state.messages.length > 1) {
            state.messages.removeLast();
            debugPrint("$logPrefix: Removed trailing empty AI message for convId '$convId'.");
          }
        }
      }

      // If we found any old messages, save the newly generated UUIDs back to the database.
      if (needsDbUpdate) {
        debugPrint("$logPrefix: Old messages without UUIDs found for convId '$convId'. Performing lazy migration to update them in the database.");
        // This function overwrites all messages for the conversation with the new, corrected ones.
        await ChatStorageService.saveCurrentMessages(convId, state.messages);
      }

      success = true;
      debugPrint("$logPrefix: Successfully loaded and validated ${rows.length} messages for convId: '$convId'.");
    } catch (e, stacktrace) {
      debugPrint("$logPrefix: Error loading previous messages for convId '$convId': $e\n$stacktrace");
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

  /// Explicitly marks the messages as loaded. This is called by SendService
  /// when a new conversation is started to prevent the skeleton loader from
  /// appearing unnecessarily.
  void markLoaded() {
    if (!_areMessagesLoaded) {
      _areMessagesLoaded = true;
      // This setState is a safeguard to ensure the UI rebuilds if any other
      // part of the app was depending on the loading state.
      if (state.mounted) {
        state.setState(() {});
      }
      debugPrint("[ReadService.markLoaded] Messages marked as loaded.");
    }
  }
}