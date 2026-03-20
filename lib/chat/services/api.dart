// lib/chat/services/api.dart

import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cortex/chat/services/tools.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserCancelledException implements Exception {
  final String message = "Request was cancelled by the user.";

  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  ApiException(this.message, {this.statusCode, this.code});

  @override
  String toString() => message;
}

class ApiService {
  final String _proxyBaseUrl =
      "https://proxyopenrouterrequest-o5h7dmtija-ew.a.run.app";
  final String _titleBaseUrl =
      "https://generatefasttitle-o5h7dmtija-ew.a.run.app";

  final Dio _dio;
  CancelToken? _cancelToken;
  String? _cachedToken;

  ApiService()
      : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(minutes: 5),
  ));

  void cancelRequests() {
    debugPrint("[ApiService] Cancellation requested.");
    _cancelToken?.cancel("Request was cancelled by the user.");
  }

  /// Internal request handler.
  Future<String> _getResponse({
    required List<Map<String, dynamic>> messages,
    required String model,
    required bool isPremium,
    List<Map<String, dynamic>>? tools,
    bool enablefeatureReasoning = false,
    bool enableWebSearch = false,
    Function(String textChunk)? onTextChunk,
    Function(String featureReasoning)? onfeatureReasoning,
    Function(String imageUrl)? onImageReceived,
    Function(List<dynamic> toolCalls)? onToolCall,
    Function(List<dynamic> citations)? onCitations,
    required AppLocalizations localizations,
  }) async {
    _cancelToken = CancelToken();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw ApiException(localizations.errorUserNotAuthenticated,
          statusCode: 401, code: 'NO_USER');
    }

    Future<String> attemptRequest(String token, String targetModel) async {
      final completer = Completer<String>();
      final finalContent = StringBuffer();
      String currentEvent = '';

      // Buffers for accumulating streaming parts
      Map<int, Map<String, dynamic>> toolCallBuffer = {};

      try {
        debugPrint("[ApiService] Sending request. Model: $targetModel");

        // Set up options with connection reuse
        final options = Options(
          responseType: ResponseType.stream,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive', // Connection persistence
          },
          sendTimeout: const Duration(seconds: 30),
        );

        final response = await _dio.post<ResponseBody>(
          _proxyBaseUrl,
          data: jsonEncode({
            "model": targetModel,
            "messages": messages,
            "isPremiumModel": isPremium,
            if (tools != null) "tools": tools,
            "tool_choice": (tools != null) ? "auto" : null,
            "enableReasoning": enablefeatureReasoning,
            "enableWebSearch": enableWebSearch,
          }),
          cancelToken: _cancelToken,
          options: options,
        );

        final stream = response.data?.stream;
        if (stream == null) {
          throw ApiException(localizations.errorServer, code: 'NULL_STREAM');
        }

        // CRITICAL: Use utf8.decoder (stateful) instead of utf8.decode (stateless)
        // This properly handles multi-byte UTF-8 characters (Turkish: ş,ğ,ü,ç,ı,ö)
        // that may be split across chunk boundaries
        stream.cast<List<int>>().transform(utf8.decoder).transform(
            const LineSplitter()).listen(
              (line) {
            if (completer.isCompleted) return;

            if (line.startsWith('event: ')) {
              currentEvent = line.substring(7).trim();
              return;
            }

            if (line.startsWith('data: ')) {
              final dataString = line.substring(6).trim();
              if (dataString.isEmpty) return;

              // Handle Errors immediately
              if (currentEvent == 'error') {
                try {
                  final data = jsonDecode(dataString);
                  final code = data['code']?.toString();
                  final message = data['message']?.toString();
                  
                  // Handle legacy backend 200 OK + SSE TOKEN_INVALID error
                  if (code == 'TOKEN_INVALID' || code == 'TOKEN_MISSING') {
                    completer.completeError(
                      DioException(
                        requestOptions: RequestOptions(path: _proxyBaseUrl),
                        response: Response(
                          requestOptions: RequestOptions(path: _proxyBaseUrl),
                          statusCode: 401,
                        ),
                        type: DioExceptionType.badResponse,
                      ),
                    );
                    return;
                  }

                  String userMsg;

                  switch (code) {
                    case 'PREMIUM_TRIAL_EXHAUSTED':
                      userMsg = localizations.premiumTrialExhaustedMessage;
                      break;
                    case 'INSUFFICIENT_USER_CREDITS':
                      userMsg = localizations.errorReachedLimit;
                      break;
                    case 'CONTENT_FLAGGED':
                      userMsg = localizations.errorPromptFlagged;
                      break;
                    default:
                      userMsg = message ?? localizations.errorServer;
                  }
                  completer.completeError(ApiException(userMsg, code: code));
                } catch (e) {
                  completer
                      .completeError(ApiException(localizations.errorServer));
                }
                return;
              }

              // Handle Standard Events
              try {
                final data = jsonDecode(dataString);

                switch (currentEvent) {
                  case 'text_chunk':
                    final text = data['text'] as String?;
                    if (text != null) {
                      onTextChunk?.call(text);
                      finalContent.write(text);
                    }
                    break;

                  case 'reasoning':
                    final reasoning = data['text'] as String?;
                    if (reasoning != null) {
                      onfeatureReasoning?.call(reasoning);
                    }
                    break;

                  case 'image_chunk':
                    final url = data['url'] as String?;
                    if (url != null) onImageReceived?.call(url);
                    break;

                  case 'citations':
                    if (data['citations'] is List && onCitations != null) {
                      onCitations(data['citations'] as List<dynamic>);
                    }
                    break;

                  case 'tool_calls':
                  // Accumulate tool call deltas
                    if (data is List) {
                      for (var item in data) {
                        final index = item['index'] as int? ?? 0;
                        if (!toolCallBuffer.containsKey(index)) {
                          toolCallBuffer[index] = {
                            'id': '',
                            'type': 'function',
                            'function': {'name': '', 'arguments': ''}
                          };
                        }

                        if (item['id'] != null) {
                          toolCallBuffer[index]!['id'] = item['id'];
                        }

                        final func = item['function'];
                        if (func != null) {
                          if (func['name'] != null) {
                            toolCallBuffer[index]!['function']['name'] +=
                            func['name'];
                          }
                          if (func['arguments'] != null) {
                            toolCallBuffer[index]!['function']['arguments'] +=
                            func['arguments'];
                          }
                        }
                      }
                    }
                    break;

                  case 'usage':
                  // Usage stats received - could be used for analytics
                    break;
                }
              } catch (e) {
                // JSON parse error - likely incomplete chunk, will be handled next
                if (kDebugMode) {
                  debugPrint("[SSE] JSON parse error: $e");
                }
              }
              currentEvent = '';
            }
          },
          onError: (error) {
            if (!completer.isCompleted) {
              if (error is DioException &&
                  error.type == DioExceptionType.cancel) {
                completer.completeError(UserCancelledException());
              } else {
                completer
                    .completeError(ApiException(localizations.errorNetwork));
              }
            }
          },
          onDone: () {
            if (!completer.isCompleted) {
              // Trigger onToolCall with fully accumulated tools if any exist
              if (toolCallBuffer.isNotEmpty && onToolCall != null) {
                final List<dynamic> finalTools = toolCallBuffer.values.toList();
                onToolCall(finalTools);
              }
              completer.complete(finalContent.toString());
            }
          },
          cancelOnError: true,
        );

        return completer.future;
      } on DioException {
        rethrow;
      }
    }

    Future<String> attemptRequestWithFailover(String token) async {
      try {
        return await attemptRequest(token, model);
      } catch (e) {
        if (e is ApiException &&
            (e.code == 'AI_SERVICE_ERROR' ||
                e.code == 'CONNECTION_ERROR' ||
                e.message.contains('400') ||
                e.message.contains('403') ||
                e.message.contains('404') ||
                e.message.contains('407') ||
                e.message.contains('429') ||
                e.message.contains('50'))) {
          // Attempt silent fallback
          try {
            final prefs = await SharedPreferences.getInstance();
            final fallbackJson = prefs.getString('fallback_models_cache');
            if (fallbackJson != null) {
              final fallbacks = List<Map<String, dynamic>>.from(
                  jsonDecode(fallbackJson));
              for (final fallback in fallbacks) {
                final fallbackId = fallback['id'] as String;
                try {
                  debugPrint(
                      "[ApiService] Silent Fallback Triggered. Original: $model, Trying: $fallbackId");
                  return await attemptRequest(token, fallbackId);
                } catch (fallbackError) {
                  debugPrint(
                      "[ApiService] Fallback $fallbackId failed: $fallbackError");
                  continue; // Try next fallback
                }
              }
            }
          } catch (fallbackParseError) {
            debugPrint(
                "[ApiService] Fallback parsing failed: $fallbackParseError");
          }
        }
        rethrow;
      }
    }

    try {
      _cachedToken ??= await user.getIdToken(false);
      return await attemptRequestWithFailover(_cachedToken!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        _cachedToken = await user.getIdToken(true);
        return await attemptRequestWithFailover(_cachedToken!);
      }
      if (e.type == DioExceptionType.cancel) throw UserCancelledException();
      throw ApiException(localizations.errorNetwork, code: 'CONNECTION_ERROR');
    } catch (e) {
      if (e is UserCancelledException || e is ApiException) rethrow;
      throw ApiException(localizations.errorNetwork);
    } finally {
      _cancelToken = null;
    }
  }

  // --- Public Wrappers ---

  Future<String> getCharacterResponse({
    required String userInput,
    required List<Map<String, dynamic>> context,
    required String characterId,
    required bool isPremium,
    required String baseModelId,
    List<String> attachmentPaths = const [],
    bool enablefeatureReasoning = false,
    Function(String)? onTextChunk,
    Function(String)? onfeatureReasoning,
    Function(String)? onImageReceived,
    required AppLocalizations localizations,
  }) async {
    List<Map<String, dynamic>> messages = List.from(context);
    List<Map<String, dynamic>> userMessageContent = [];

    if (userInput.isNotEmpty) {
      userMessageContent.add({"type": "text", "text": userInput});
    }
    for (final path in attachmentPaths) {
      final contentBlock = await Utils.processAttachment(path);
      if (contentBlock != null) userMessageContent.add(contentBlock);
    }
    if (userMessageContent.isNotEmpty) {
      messages.add({"role": "user", "content": userMessageContent});
    }

    return _getResponse(
      localizations: localizations,
      messages: messages,
      model: baseModelId,
      isPremium: isPremium,
      enablefeatureReasoning: enablefeatureReasoning,
      enableWebSearch: false, // Characters usually don't need web search, or pass it if needed
      onTextChunk: onTextChunk,
      onfeatureReasoning: onfeatureReasoning,
      onImageReceived: onImageReceived,
    );
  }


  /// Silently generates a title for a new conversation using the backend's fast new title endpoint.
  Future<String?> generateChatTitle(String userInput,
      String systemPrompt, String criticalInstruction, {bool isRetry = false}) async {
    try {
      debugPrint(
          '[TitleGen] 🚀 Starting title generation for: "${userInput.length > 20
              ? userInput.substring(0, 20)
              : userInput}..."');
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[TitleGen] ❌ Error: User is null');
        return null;
      }
      
      // SADECE retry modundaysa (ikinci denemeyse) token'i zorla yenile.
      final String? token = await user.getIdToken(isRetry);

      final options = Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        receiveTimeout: const Duration(seconds: 15),
      );

      final payload = {
        "messages": [
          {
            "role": "system",
            "content": "$systemPrompt\n\n[CRITICAL INSTRUCTION]: $criticalInstruction",
          },
          {
            "role": "user",
            "content": userInput
          }
        ]
      };

      debugPrint('[TitleGen] 🚀 Sending DIO POST request to fast endpoint...');

      final dioForTitle = Dio();
      final response = await dioForTitle.post(
        _titleBaseUrl,
        data: jsonEncode(payload),
        options: options,
      );

      debugPrint(
          '[TitleGen] 🟢 Response received! Status: ${response.statusCode}');

      final data = response.data;
      if (data != null && data['title'] != null) {
        final result = data['title'].toString().trim();
        debugPrint('[TitleGen] 🎉 Title successfully generated: $result');
        return result.isNotEmpty ? result : null;
      } else {
        debugPrint('[TitleGen] ⚠️ Generated title data was missing/empty!');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && !isRetry) {
        debugPrint('[TitleGen] ⚠️ 401 Unauthorized detected! Refreshing token silently and retrying...');
        return generateChatTitle(userInput, systemPrompt, criticalInstruction, isRetry: true);
      } else {
        debugPrint('[TitleGen] ❌ DioException generating title: $e');
      }
    } catch (e) {
      debugPrint('[TitleGen] ❌ Error generating title: $e');
    }
    return null;
  }

  Future<String> getOnlineModelResponse({
    required String modelId,
    required bool isPremium,
    required String userInput,
    required List<Map<String, dynamic>> context,
    List<String> attachmentPaths = const [],
    bool enablefeatureReasoning = false,
    Function(String)? onTextChunk,
    Function(String)? onfeatureReasoning,
    Function(String)? onImageReceived,
    Function(List<dynamic>)? onToolCall,
    Function(List<dynamic>)? onCitations,
    required AppLocalizations localizations,
    required String langCode,
    bool useTools = true,
    bool enableWebSearch = false,
    bool isRetry = false,
  }) async {
    List<Map<String, dynamic>> messages = List.from(context);
    List<Map<String, dynamic>> userMessageContent = [];

    if (userInput.isNotEmpty) {
      userMessageContent.add({"type": "text", "text": userInput});
    }
    for (final path in attachmentPaths) {
      final contentBlock = await Utils.processAttachment(path);
      if (contentBlock != null) userMessageContent.add(contentBlock);
    }

    // Extract documents for tool processing (PDF, XLSX, etc.) BEFORE cleaning
    final documents = Utils.extractDocuments(userMessageContent);
    if (documents.isNotEmpty) {
      ToolRegistry.setDocumentsContext(documents);
    }

    // Clean content blocks - remove internal _document fields before sending to API
    final cleanedUserContent = Utils.cleanContentBlocks(userMessageContent);

    if (cleanedUserContent.isNotEmpty) {
      messages.add({"role": "user", "content": cleanedUserContent});
    }

    // Attach Tools Definition
    final toolsJson = useTools
        ? ToolRegistry.getLocalizedToolsJson(langCode, localizations)
        : <Map<String, dynamic>>[];

    return _getResponse(
      localizations: localizations,
      messages: messages,
      model: modelId,
      isPremium: isPremium,
      enablefeatureReasoning: enablefeatureReasoning,
      enableWebSearch: enableWebSearch,
      tools: toolsJson.isNotEmpty ? toolsJson : null,
      onTextChunk: onTextChunk,
      onfeatureReasoning: onfeatureReasoning,
      onImageReceived: onImageReceived,
      onToolCall: onToolCall,
      onCitations: onCitations,
    );
  }
}
