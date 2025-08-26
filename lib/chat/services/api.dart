// ================ api.dart ================
// This service is the single point of contact for all external AI model communications.
// It abstracts away the complexities of network requests, authentication, and
// response streaming, providing a clean and secure interface for the rest of the application.
//
// Key Features:
// - Handles communication with a secure backend proxy.
// - Supports streaming responses for real-time message updates.
// - Implements robust error handling for various API and network issues.
// - Includes a mechanism to gracefully handle user-initiated request cancellations
//   without showing an error message.

import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cortex/l10n/app_localizations.dart';
import 'package:mime/mime.dart';

/// Represents an exception thrown when the user intentionally cancels an API request.
/// This is NOT treated as an error by the UI, but as a controlled flow interruption.
/// It allows the application to stop processing without displaying a scary error dialog.
class UserCancelledException implements Exception {
  final String message = "Request was cancelled by the user.";
  @override
  String toString() => message;
}

/// A generic exception for API-related errors that should be shown to the user.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  ApiException(this.message, {this.statusCode, this.code});

  @override
  String toString() => message;
}

/// The primary service for interacting with AI models via the backend proxy.
class ApiService {
  final AppLocalizations localizations;
  final String _proxyBaseUrl = "https://proxyopenrouterrequest-o5h7dmtija-ew.a.run.app";

  http.Client? _client;
  /// A state flag to distinguish between a genuine network error and a
  /// user-initiated cancellation.
  bool _isCancelled = false;

  ApiService({required this.localizations});

  /// Cancels any ongoing HTTP request.
  /// It sets a flag and immediately closes the HTTP client, which will cause
  /// the ongoing network operation to throw an exception.
  void cancelRequests() {
    debugPrint("[ApiService] Cancellation requested. Setting flag and closing client.");
    _isCancelled = true;
    _client?.close();
  }

  /// A static utility function to read an image file, encode it to Base64,
  /// and format it as a data URL string.
  ///
  /// This method is pure and has no side effects, making it ideal as a static function.
  /// It can be called from anywhere without needing an `ApiService` instance.
  static Future<String?> formatBase64Image(String photoPath) async {
    try {
      final imageFile = File(photoPath);
      if (await imageFile.exists()) {
        final imageBytes = await imageFile.readAsBytes();
        final mimeType = lookupMimeType(photoPath, headerBytes: imageBytes);

        // Ensure the image is of a supported type before sending.
        if (mimeType == null || !['image/png', 'image/jpeg', 'image/webp'].contains(mimeType)) {
          debugPrint("Unsupported image type '$mimeType' for file: $photoPath");
          return null;
        }

        final base64Image = base64Encode(imageBytes);
        return 'data:$mimeType;base64,$base64Image';
      }
    } catch (e) {
      debugPrint("Error reading or encoding photo file: $e");
    }
    return null;
  }

  /// This version correctly handles the hybrid SSE stream from the server.
  /// 1.  It uses a `Completer` to wait for a definitive success (`event: moderation`)
  ///     or failure (`event: error`) signal from the server.
  /// 2.  It uses a custom line-by-line processing logic that can distinguish
  ///     between our custom control events and the raw, piped data from the AI provider.
  /// 3.  It fully implements the pre-flight error handling for immediate feedback.
  Future<String> _getResponse({
    required List<Map<String, dynamic>> messages,
    required String model,
    Function(String chunk)? onStreamChunk,
  }) async {
    _isCancelled = false;
    _client = http.Client();

    final completer = Completer<String>();
    final finalContent = StringBuffer();
    String currentEvent = 'message'; // Default event type is raw message content

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw ApiException(localizations.errorUserNotAuthenticated, statusCode: 401);
      }
      final idToken = await user.getIdToken();

      final url = Uri.parse(_proxyBaseUrl);
      final request = http.Request('POST', url)
        ..headers.addAll({
          "Authorization": "Bearer $idToken",
          "Content-Type": "application/json",
        })
        ..body = jsonEncode({
          "model": model,
          "messages": messages,
        });

      final streamedResponse = await _client!.send(request);

      if (streamedResponse.statusCode != 200) {
        // --- FIX: The complete pre-flight error handling logic is now included. ---
        final errorBodyString = await streamedResponse.stream.bytesToString();
        debugPrint("Proxy Pre-flight Error [${streamedResponse.statusCode}]: $errorBodyString");

        String? errorCode;
        String finalErrorMessage = localizations.errorServer;

        try {
          final errorJson = jsonDecode(errorBodyString);
          if (errorJson['error'] is Map) {
            final errorObject = errorJson['error'];
            errorCode = errorObject['code']?.toString();
            finalErrorMessage = errorObject['message'] ?? finalErrorMessage;
          }
        } catch (e) {
          // Ignore parse error, use defaults.
        }

        switch (errorCode) {
          case 'TOKEN_MISSING':
          case 'TOKEN_INVALID':
            throw ApiException(localizations.errorApiAuthentication, statusCode: streamedResponse.statusCode, code: errorCode);
          case 'INSUFFICIENT_USER_CREDITS':
            throw ApiException(localizations.errorInsufficientCredits, statusCode: streamedResponse.statusCode, code: errorCode);
        // Add other specific cases if needed
          default:
            throw ApiException(finalErrorMessage, statusCode: streamedResponse.statusCode, code: errorCode);
        }
      }

      streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {

          debugPrint("[CLIENT_LINE_RECEIVER] Received line: $line");

          if (completer.isCompleted) return;

          if (line.startsWith('event: ')) {
            currentEvent = line.substring(7).trim();
            return; // The next line will be the data for this event.
          }

          if (line.startsWith('data: ')) {
            final dataString = line.substring(6).trim();

            switch (currentEvent) {
              case 'moderation':
                try {
                  final data = jsonDecode(dataString);
                  if (data['flagged'] == true) {
                    debugPrint("[ApiService] Received moderation event: FLAGGED.");
                    final message = data['message'] ?? localizations.errorPromptFlagged;
                    completer.completeError(ApiException(message, code: data['code']?.toString()));
                  } else {
                    debugPrint("[ApiService] Received moderation event: PASSED.");
                    completer.complete(finalContent.toString());
                  }
                } catch (e) {
                  completer.completeError(ApiException(localizations.errorServer, code: 'CLIENT_PARSE_ERROR'));
                }
                break;

              case 'error':
                try {
                  final data = jsonDecode(dataString);
                  final message = data['message'] ?? localizations.errorServer;
                  completer.completeError(ApiException(message, code: data['code']?.toString()));
                } catch (e) {
                  completer.completeError(ApiException(localizations.errorServer, code: 'CLIENT_PARSE_ERROR'));
                }
                break;

            // Default case handles the raw AI content stream
              default: // 'message'
                if (dataString == "[DONE]") return; // Ignore OpenRouter's done signal
                try {
                  final chunkData = jsonDecode(dataString);
                  final delta = chunkData['choices']?[0]?['delta'];
                  if (delta?['content'] != null) {
                    final String contentChunk = delta['content'];
                    onStreamChunk?.call(contentChunk);
                    finalContent.write(contentChunk);
                  }
                } catch(e) {
                  debugPrint("Could not parse AI content chunk, ignoring. Chunk: $dataString");
                }
                break;
            }
            // Reset event to default after processing data
            currentEvent = 'message';
          }
        },
        onError: (error) {
          if (!completer.isCompleted) {
            if (_isCancelled) {
              completer.completeError(UserCancelledException());
            } else {
              completer.completeError(ApiException(localizations.errorNetwork));
            }
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            debugPrint("[ApiService] Stream ended prematurely without a final confirmation event.");
            completer.completeError(ApiException(localizations.errorNetwork, code: 'PREMATURE_CLOSE'));
          }
        },
        cancelOnError: true,
      );

      return completer.future;

    } catch (e) {
      if (_isCancelled) throw UserCancelledException();
      if (e is ApiException) rethrow;
      debugPrint("Unhandled client-side API error in _getResponse: $e");
      throw ApiException(localizations.errorNetwork);
    } finally {
      completer.future.whenComplete(() {
        _client?.close();
        _isCancelled = false;
        debugPrint("[ApiService] Request lifecycle complete. Client closed.");
      });
    }
  }


  /// A public method to get a response for a character-based model.
  Future<String> getCharacterResponse({
    required String userInput,
    required List<Map<String, dynamic>> context,
    required String characterId,
    required String baseModelId,
    String? photoPath,
    Function(String chunk)? onStreamChunk,
  }) async {
    List<Map<String, dynamic>> messages = List.from(context);
    List<Map<String, dynamic>> userMessageContent = [];

    if (userInput.isNotEmpty) {
      userMessageContent.add({"type": "text", "text": userInput});
    }
    if (photoPath != null) {
      String? base64Image = await ApiService.formatBase64Image(photoPath);
      if (base64Image != null) {
        userMessageContent.add({"type": "image_url", "image_url": {"url": base64Image}});
      }
    }
    if (userMessageContent.isNotEmpty) {
      messages.add({"role": "user", "content": userMessageContent});
    }

    return _getResponse(
      messages: messages,
      model: baseModelId, // Use the base model for the actual API call.
      onStreamChunk: onStreamChunk,
    );
  }

  /// A public method to get a response for a standard online model.
  Future<String> getOnlineModelResponse({
    required String modelId,
    required String userInput,
    required List<Map<String, dynamic>> context,
    String? photoPath,
    Function(String chunk)? onStreamChunk,
  }) async {
    List<Map<String, dynamic>> messages = List.from(context);
    List<Map<String, dynamic>> userMessageContent = [];

    if (userInput.isNotEmpty) {
      userMessageContent.add({"type": "text", "text": userInput});
    }
    if (photoPath != null) {
      String? base64Image = await ApiService.formatBase64Image(photoPath);
      if (base64Image != null) {
        userMessageContent.add({"type": "image_url", "image_url": {"url": base64Image}});
      }
    }
    if (userMessageContent.isNotEmpty) {
      messages.add({"role": "user", "content": userMessageContent});
    }

    return _getResponse(
      messages: messages,
      model: modelId,
      onStreamChunk: onStreamChunk,
    );
  }
}