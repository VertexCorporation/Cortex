// lib/chat/services/offline.dart

import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A service to manage communication with the native (Kotlin/Swift) layer
/// for handling on-device, offline model interactions via a platform channel.
class OfflineService {
  final ResponseService _responseService;
  final ChatSessionProvider _sessionProvider;

  // The platform channel must be static to ensure a single communication
  // channel is used throughout the app's lifecycle.
  static const MethodChannel _llamaChannel = MethodChannel('com.vertex.cortex/llama');

  /// Constructs the OfflineService with its required dependencies.
  ///
  /// - [responseService]: To forward message stream data from the native side.
  /// - [sessionProvider]: To update the session state, e.g., when a local model is loaded.
  OfflineService({
    required ResponseService responseService,
    required ChatSessionProvider sessionProvider,
  })  : _responseService = responseService,
        _sessionProvider = sessionProvider {
    // Set the handler for messages coming from the native platform to this service instance.
    _llamaChannel.setMethodCallHandler(methodCallHandler);
  }

  /// Sends a user's prompt to the native layer to be processed by the local model.
  Future<void> sendMessage(String text, String? photoPath) async {
    debugPrint("[OfflineService] Invoking 'sendMessage' on the native side.");
    await _llamaChannel.invokeMethod<void>(
      'sendMessage',
      {'message': text, 'photoPath': photoPath},
    );
  }

  /// Sends a command to the native layer to stop any ongoing text generation.
  Future<void> stopGeneration() async {
    debugPrint("[OfflineService] Invoking 'stopGeneration' on the native side.");
    await _llamaChannel.invokeMethod('stopGeneration');
  }

  /// Sends a command to the native layer to unload the current model from memory.
  Future<void> unloadModel() async {
    debugPrint("[OfflineService] Invoking 'unloadModel' on the native side.");
    await _llamaChannel.invokeMethod('unloadModel');
  }

  /// The central handler for all method calls received from the native platform.
  /// The '@pragma' annotation ensures this method can be found by the Flutter engine
  /// even in release mode or when running in the background.
  @pragma('vm:entry-point')
  Future<void> methodCallHandler(MethodCall call) async {
    switch (call.method) {
    // Called for each token of the streaming response.
      case 'onMessageResponse':
        final String token = call.arguments as String? ?? '';
        if (token.isNotEmpty) {
          // Forward the token to the ResponseService, which will handle updating the ConversationProvider.
          _responseService.onMessageResponse(token);
        }
        break;

    // Called when the native model finishes generating a full response.
      case 'onMessageComplete':
        debugPrint("[OfflineService] Received 'onMessageComplete'. Finalizing response.");
        // Tell the ResponseService to finalize the message in the ConversationProvider.
        _responseService.finalizeResponse();
        break;

    // Called when the native layer has successfully loaded the model into memory.
      case 'onModelLoaded':
        debugPrint("[OfflineService] Received 'onModelLoaded'. Updating provider state.");
        // Update the central state to reflect that the local model is ready.
        // The UI will reactively update based on this change.
        _sessionProvider.setLocalModelLoaded(true);
        break;

      default:
        debugPrint("[OfflineService] Received unknown method call from native: ${call.method}");
        break;
    }
  }
}