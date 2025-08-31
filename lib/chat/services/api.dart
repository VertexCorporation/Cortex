// ================ api.dart ================
// This service is the single point of contact for all external AI model communications.
// It abstracts away the complexities of network requests, authentication, and
// response streaming, providing a clean and secure interface for the rest of the application.
//
// Key Features:
// - Handles communication with the secure backend proxy (v2.2+).
// - Natively supports streaming of both text chunks and image data.
// - Implements robust error handling for various API and network issues.
// - Includes a mechanism to gracefully handle user-initiated request cancellations.

import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cortex/l10n/app_localizations.dart';
import 'package:mime/mime.dart';

/// Represents an exception thrown when the user intentionally cancels an API request.
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
  bool _isCancelled = false;

  ApiService({required this.localizations});

  /// Cancels any ongoing HTTP request.
  void cancelRequests() {
    debugPrint("[ApiService] Cancellation requested. Setting flag and closing client.");
    _isCancelled = true;
    _client?.close();
  }

  /// A static utility function to read an image file, encode it to Base64,
  /// and format it as a data URL string.
  static Future<String?> formatBase64Image(String photoPath) async {
    try {
      final imageFile = File(photoPath);
      if (await imageFile.exists()) {
        final imageBytes = await imageFile.readAsBytes();
        final mimeType = lookupMimeType(photoPath, headerBytes: imageBytes);

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

  /// It now accepts an `isPremium` flag and sends it to the backend for
  /// correct credit deduction and trial management.
  Future<String> _getResponse({
    required List<Map<String, dynamic>> messages,
    required String model,
    required bool isPremium,
    Function(String textChunk)? onTextChunk,
    Function(String imageUrl)? onImageReceived,
  }) async {
    _isCancelled = false;
    _client = http.Client();

    final completer = Completer<String>();
    final finalContent = StringBuffer();
    String currentEvent = '';

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
          "isPremiumModel": isPremium,
        });

      final streamedResponse = await _client!.send(request);

      if (streamedResponse.statusCode != 200) {
        final errorBodyString = await streamedResponse.stream.bytesToString();
        debugPrint("Proxy Pre-flight Error [${streamedResponse.statusCode}]: $errorBodyString");

        String? errorCode;
        String serverMessage = localizations.errorServer;

        try {
          final errorJson = jsonDecode(errorBodyString);
          if (errorJson['error'] is Map) {
            final errorObject = errorJson['error'];
            errorCode = errorObject['code']?.toString();
            serverMessage = errorObject['message'] ?? serverMessage;
          }
        } catch (e) { /* Ignore parse error, use defaults. */ }

        String finalUserMessage;
        switch (errorCode) {
          case 'TOKEN_MISSING':
          case 'TOKEN_INVALID':
            finalUserMessage = localizations.errorApiAuthentication;
            break;
          case 'INSUFFICIENT_USER_CREDITS':
            finalUserMessage = localizations.errorInsufficientCredits;
            break;
          case 'PREMIUM_TRIAL_EXHAUSTED':
            finalUserMessage = localizations.premiumTrialExhaustedMessage;
            break;
          default:
            finalUserMessage = serverMessage;
        }
        throw ApiException(finalUserMessage, statusCode: streamedResponse.statusCode, code: errorCode);
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
            if (dataString.isEmpty) return;

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
                  final code = data['code']?.toString();
                  final serverMessage = data['message']?.toString();
                  String finalMessage;

                  switch (code) {
                    case 'PREMIUM_TRIAL_EXHAUSTED':
                      finalMessage = localizations.premiumTrialExhaustedMessage;
                      break;
                    case 'INSUFFICIENT_USER_CREDITS':
                      finalMessage = localizations.errorInsufficientCredits;
                      break;
                    case 'CONTENT_FLAGGED':
                      finalMessage = localizations.errorPromptFlagged;
                      break;
                    case 'TOKEN_MISSING':
                    case 'TOKEN_INVALID':
                      finalMessage = localizations.errorApiAuthentication;
                      break;
                    default:
                      finalMessage = serverMessage ?? localizations.errorServer;
                  }
                  completer.completeError(ApiException(finalMessage, code: code));
                } catch (e) {
                  completer.completeError(ApiException(localizations.errorServer, code: 'CLIENT_PARSE_ERROR'));
                }
                break;

              case 'text_chunk':
                try {
                  final data = jsonDecode(dataString);
                  final text = data['text'] as String?;
                  if (text != null) {
                    onTextChunk?.call(text);
                    finalContent.write(text);
                  }
                } catch (e) {
                  debugPrint("[ApiService] Could not parse text_chunk, ignoring. Chunk: $dataString");
                }
                break;

              case 'image_chunk':
                try {
                  final data = jsonDecode(dataString);
                  final url = data['url'] as String?;
                  if (url != null) {
                    onImageReceived?.call(url);
                  }
                } catch (e) {
                  debugPrint("[ApiService] Could not parse image_chunk, ignoring. Chunk: $dataString");
                }
                break;

              default:
              // Ignore any unknown or empty events.
                break;
            }
            // Reset event name after processing data
            currentEvent = '';
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

  /// Public method for character-based models, now supporting image outputs.
  Future<String> getCharacterResponse({
    required String userInput,
    required List<Map<String, dynamic>> context,
    required String characterId,
    required bool isPremium,
    required String baseModelId,
    String? photoPath,
    Function(String textChunk)? onTextChunk,
    Function(String imageUrl)? onImageReceived,
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
      model: baseModelId,
      isPremium: isPremium,
      onTextChunk: onTextChunk,
      onImageReceived: onImageReceived,
    );
  }

  /// Public method for standard online models, now supporting image outputs.
  Future<String> getOnlineModelResponse({
    required String modelId,
    required bool isPremium,
    required String userInput,
    required List<Map<String, dynamic>> context,
    String? photoPath,
    Function(String textChunk)? onTextChunk,
    Function(String imageUrl)? onImageReceived,
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
      isPremium: isPremium,
      onTextChunk: onTextChunk,
      onImageReceived: onImageReceived,
    );
  }
}