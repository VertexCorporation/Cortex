// ================ api.dart ================
// This service is the single point of contact for all external AI model communications.
// It abstracts away the complexities of network requests, authentication, and
// response streaming, providing a clean and secure interface for the rest of the application.
//
// Key Features:
// - Manages its own dedicated Dio instance, configured specifically for long-running stream requests.
// - Handles communication with the secure backend proxy.
// - Natively supports streaming of text chunks and image data via SSE.
// - Implements robust error handling and a graceful cancellation mechanism.

import 'dart:convert';
import 'dart:async';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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
  final String _proxyBaseUrl = "https://proxyopenrouterrequest-o5h7dmtija-ew.a.run.app";

  /// A dedicated Dio instance for this service, configured for streaming.
  /// It does NOT use the global RetryInterceptor to avoid conflicts with long-lived streams.
  final Dio _dio;

  CancelToken? _cancelToken;

  ApiService()
      : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    // A long receive timeout is crucial for Server-Sent Events (SSE)
    // as the model might "think" for a long time before sending the next chunk.
    receiveTimeout: const Duration(minutes: 5),
  ));

  /// Cancels any ongoing Dio request using the CancelToken.
  void cancelRequests() {
    debugPrint("[ApiService] Cancellation requested. Firing CancelToken.");
    _cancelToken?.cancel("Request was cancelled by the user.");
  }

  /// The core private method for handling streaming API responses using its dedicated Dio instance.
  /// Implements an intelligent "try fast, retry smart" token refresh strategy.
  Future<String> _getResponse({
    required List<Map<String, dynamic>> messages,
    required String model,
    required bool isPremium,
    Function(String textChunk)? onTextChunk,
    Function(String imageUrl)? onImageReceived,
    required AppLocalizations localizations,
  }) async {
    _cancelToken = CancelToken();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw ApiException(localizations.errorUserNotAuthenticated, statusCode: 401, code: 'NO_USER');
    }

    // This nested function contains the actual request logic.
    // It is designed to be called once for the initial attempt, and a second time for a retry if needed.
    Future<String> attemptRequest(String token) async {
      final completer = Completer<String>();
      final finalContent = StringBuffer();
      String currentEvent = '';

      // The try block inside the attempt is only to re-throw DioExceptions
      // so the outer logic can decide whether to retry.
      try {
        debugPrint("[ApiService] Attempting request with a token.");
        final response = await _dio.post<ResponseBody>(
          _proxyBaseUrl,
          data: jsonEncode({
            "model": model,
            "messages": messages,
            "isPremiumModel": isPremium,
          }),
          cancelToken: _cancelToken,
          options: Options(
            responseType: ResponseType.stream,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'text/event-stream',
              'Cache-Control': 'no-cache',
            },
            sendTimeout: const Duration(seconds: 30),
          ),
        );

        debugPrint("[ApiService] Request sent. Status Code: ${response.statusCode}. Waiting for stream...");

        final stream = response.data?.stream;
        if (stream == null) {
          throw ApiException(localizations.errorServer, code: 'NULL_STREAM');
        }

        stream
            .map(utf8.decode)
            .transform(const LineSplitter())
            .listen(
              (line) {
            if (completer.isCompleted) return;

            if (line.startsWith('event: ')) {
              currentEvent = line.substring(7).trim();
              return;
            }

            if (line.startsWith('data: ')) {
              final dataString = line.substring(6).trim();
              if (dataString.isEmpty) return;

              switch (currentEvent) {
                case 'moderation':
                  try {
                    final data = jsonDecode(dataString);
                    if (data['flagged'] == true) {
                      final message = data['message'] ?? localizations.errorPromptFlagged;
                      completer.completeError(ApiException(message, code: data['code']?.toString()));
                    } else {
                      // This is the final success event, but onDone will handle completion.
                      // We can just wait for the stream to close.
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
                  } catch (e) {/* Ignore parse error */}
                  break;
                case 'image_chunk':
                  try {
                    final data = jsonDecode(dataString);
                    final url = data['url'] as String?;
                    if (url != null) {
                      onImageReceived?.call(url);
                    }
                  } catch (e) {/* Ignore parse error */}
                  break;
                default:
                  break;
              }
              currentEvent = '';
            }
          },
          onError: (error) {
            if (completer.isCompleted) return;
            debugPrint("[ApiService] Stream listener error: $error");

            if (error is DioException && error.type == DioExceptionType.cancel) {
              completer.completeError(UserCancelledException());
            } else {
              completer.completeError(ApiException(localizations.errorNetwork));
            }
          },
          onDone: () {
            if (!completer.isCompleted) {
              // For SSE, the stream closing without an error event
              // means the model has finished sending its response. This is a SUCCESS case.
              debugPrint("[ApiService] Stream ended successfully. Completing with final content.");
              completer.complete(finalContent.toString());
            }
          },
          cancelOnError: true,
        );

        return completer.future;

      } on DioException {
        // Re-throw the exception so the outer catch block can analyze it and decide to retry.
        rethrow;
      }
    }

    try {
      // === ATTEMPT 1: Use the cached token for maximum performance ===
      debugPrint("[ApiService] Getting cached Firebase ID Token (attempt 1)...");
      final idToken = await user.getIdToken(false);
      return await attemptRequest(idToken!);

    } on DioException catch (e) {
      // === FAILURE ANALYSIS: Check if it's an auth error (401/403) ===
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        debugPrint("[ApiService] Auth error on attempt 1 (status ${e.response?.statusCode}). Refreshing token for attempt 2...");

        try {
          // === ATTEMPT 2: Force refresh the token and retry the request ===
          final refreshedToken = await user.getIdToken(true);
          return await attemptRequest(refreshedToken!);
        } catch (retryError) {
          // If the second attempt also fails, it's a genuine error.
          debugPrint("[ApiService] Second attempt also failed: $retryError");
          if (retryError is DioException) {
            throw ApiException(localizations.errorApiAuthentication, statusCode: retryError.response?.statusCode, code: 'AUTH_RETRY_FAILED');
          }
          throw ApiException(localizations.errorNetwork, code: 'RETRY_UNHANDLED_ERROR');
        }
      }

      // If it was a different DioException (e.g., network, timeout, etc.), handle it directly.
      if (e.type == DioExceptionType.cancel) {
        throw UserCancelledException();
      }

      // Handle Dio exceptions with a response but not related to auth
      if (e.response != null) {
        throw ApiException(localizations.errorServer, statusCode: e.response!.statusCode);
      }

      // Handle Dio exceptions without a response (network issues)
      debugPrint("DioException without response (Network Error): ${e.message}");
      throw ApiException(localizations.errorNetwork, code: 'CONNECTION_ERROR');

    } catch (e) {
      // Catch any other unexpected errors that were not DioExceptions.
      if (e is UserCancelledException || e is ApiException) rethrow; // Keep original custom exceptions.
      debugPrint("Unhandled client-side API error in _getResponse: $e");
      throw ApiException(localizations.errorNetwork, code: 'UNHANDLED_CLIENT_ERROR');
    } finally {
      _cancelToken = null;
      debugPrint("[ApiService] Request lifecycle complete.");
    }
  }

  /// Public method for character-based models.
  Future<String> getCharacterResponse({
    required String userInput,
    required List<Map<String, dynamic>> context,
    required String characterId,
    required bool isPremium,
    required String baseModelId,
    String? photoPath,
    Function(String textChunk)? onTextChunk,
    Function(String imageUrl)? onImageReceived,
    required AppLocalizations localizations,
  }) async {
    List<Map<String, dynamic>> messages = List.from(context);
    List<Map<String, dynamic>> userMessageContent = [];

    if (userInput.isNotEmpty) {
      userMessageContent.add({"type": "text", "text": userInput});
    }
    if (photoPath != null) {
      String? base64Image = await Utils.formatBase64Image(photoPath);
      if (base64Image != null) {
        userMessageContent.add({"type": "image_url", "image_url": {"url": base64Image}});
      }
    }
    if (userMessageContent.isNotEmpty) {
      messages.add({"role": "user", "content": userMessageContent});
    }

    return _getResponse(
      localizations: localizations,
      messages: messages,
      model: baseModelId,
      isPremium: isPremium,
      onTextChunk: onTextChunk,
      onImageReceived: onImageReceived,
    );
  }

  /// Public method for standard online models.
  Future<String> getOnlineModelResponse({
    required String modelId,
    required bool isPremium,
    required String userInput,
    required List<Map<String, dynamic>> context,
    String? photoPath,
    Function(String textChunk)? onTextChunk,
    Function(String imageUrl)? onImageReceived,
    required AppLocalizations localizations,
  }) async {
    List<Map<String, dynamic>> messages = List.from(context);
    List<Map<String, dynamic>> userMessageContent = [];

    if (userInput.isNotEmpty) {
      userMessageContent.add({"type": "text", "text": userInput});
    }
    if (photoPath != null) {
      String? base64Image = await Utils.formatBase64Image(photoPath);
      if (base64Image != null) {
        userMessageContent.add({"type": "image_url", "image_url": {"url": base64Image}});
      }
    }
    if (userMessageContent.isNotEmpty) {
      messages.add({"role": "user", "content": userMessageContent});
    }

    return _getResponse(
      localizations: localizations,
      messages: messages,
      model: modelId,
      isPremium: isPremium,
      onTextChunk: onTextChunk,
      onImageReceived: onImageReceived,
    );
  }
}