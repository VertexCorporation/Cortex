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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  ApiException(this.message, {this.statusCode});

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

  /// The core private method that communicates with the secure backend proxy.
  /// It handles request creation, response streaming, and all error conditions.
  Future<String> _getResponse({
    required List<Map<String, dynamic>> messages,
    required String model,
    Function(String chunk)? onStreamChunk,
  }) async {
    // At the beginning of every new request, reset the cancellation state and create a new client.
    _isCancelled = false;
    _client = http.Client();

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

      if (streamedResponse.statusCode == 200) {
        final finalContent = StringBuffer();
        final stream = streamedResponse.stream.transform(utf8.decoder).transform(const LineSplitter());

        await for (final line in stream) {
          if (line.startsWith("data: ")) {
            final jsonString = line.substring(6).trim();
            if (jsonString == "[DONE]") break;
            try {
              final Map<String, dynamic> event = jsonDecode(jsonString);
              final delta = event['choices']?[0]?['delta'];
              if (delta?['content'] != null) {
                final String contentChunk = delta['content'];
                onStreamChunk?.call(contentChunk);
                finalContent.write(contentChunk);
              }
            } catch (e) {
              debugPrint("Stream JSON parse error: $e, on line: $jsonString");
            }
          }
        }
        return finalContent.toString();
      }       else {
        // --- ROBUST ERROR HANDLING LOGIC ---
        // This logic is enhanced to parse nested errors from different providers.
        final errorBodyString = await streamedResponse.stream.bytesToString();
        debugPrint("Proxy Error [${streamedResponse.statusCode}]: $errorBodyString");

        String? errorCode;
        // Start with a generic default error message.
        String finalErrorMessage = localizations.errorServer;

        try {
          final errorJson = jsonDecode(errorBodyString);
          if (errorJson['error'] is Map) {
            final errorObject = errorJson['error'];
            errorCode = errorObject['code']?.toString();

            // --- NEW: LAYERED ERROR MESSAGE PARSING ---
            // 1. Attempt to find a more specific error message nested inside 'raw' metadata.
            // This handles cases where the proxy wraps the original provider's error.
            bool foundSpecificError = false;
            if (errorObject['metadata']?['raw'] is String) {
              try {
                final rawErrorString = errorObject['metadata']['raw'];
                final nestedErrorJson = jsonDecode(rawErrorString);
                if (nestedErrorJson['error']?['message'] is String) {
                  finalErrorMessage = nestedErrorJson['error']['message'];
                  foundSpecificError = true;
                  debugPrint("[ApiService] Parsed a specific error from metadata: $finalErrorMessage");
                }
              } catch (e) {
                // The 'raw' string was not valid JSON or didn't have the expected structure.
                // This is not a critical failure; we'll just fall back.
                debugPrint("[ApiService] Could not parse nested raw error. Falling back. Error: $e");
              }
            }

            // 2. If no specific error was found, fall back to the top-level error message.
            if (!foundSpecificError && errorObject['message'] is String) {
              finalErrorMessage = errorObject['message'];
            }
          }
        } catch (e) {
          // The entire response was not valid JSON. Use the default message.
          debugPrint("Could not parse error JSON from proxy: $e. Body: $errorBodyString");
          throw ApiException(finalErrorMessage, statusCode: streamedResponse.statusCode);
        }

        // Now, use the final determined error message to throw the correct ApiException.
        switch (errorCode) {
          case 'TOKEN_MISSING':
          case 'TOKEN_INVALID':
          case '401':
          case '403':
            throw ApiException(localizations.errorApiAuthentication, statusCode: streamedResponse.statusCode);
          case 'INSUFFICIENT_USER_CREDITS':
          case '402':
            throw ApiException(localizations.errorInsufficientCredits, statusCode: streamedResponse.statusCode);
          case 'RATE_LIMIT_EXCEEDED':
          case '429':
            throw ApiException(localizations.errorRateLimitExceeded, statusCode: streamedResponse.statusCode);
          case 'CONTENT_FLAGGED':
          case 'PROMPT_FLAGGED':
          case '422':
            throw ApiException(localizations.errorPromptFlagged, statusCode: streamedResponse.statusCode);
          default:
          // For all other errors, use the message we worked hard to find.
            throw ApiException(finalErrorMessage, statusCode: streamedResponse.statusCode);
        }
      }
    } catch (e) {
      // --- ROBUST CANCELLATION & ERROR HANDLING ---
      // This is the most critical part of the error logic.
      if (_isCancelled) {
        // If an exception occurs *after* a cancellation was requested, it's almost certainly
        // a `ClientException` from closing the connection. We treat this as an intentional
        // stop, not an error. We throw a special exception that the UI knows to ignore.
        debugPrint("[ApiService] Caught exception, identified as user cancellation. Throwing UserCancelledException.");
        throw UserCancelledException();
      }

      // If the exception is already one of our specific types, just pass it up.
      if (e is ApiException || e is UserCancelledException) rethrow;

      // For any other exception (e.g., SocketException for no internet, ClientException
      // for other reasons), wrap it in a generic, user-friendly network error.
      debugPrint("Unhandled client-side API error in _getResponse: $e");
      throw ApiException(localizations.errorNetwork);
    } finally {
      // Always close the client and reset the cancellation flag to ensure the
      // service is in a clean state for the next request.
      _client?.close();
      _isCancelled = false;
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