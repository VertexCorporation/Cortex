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

  // PERF: Reuse a single Dio instance for title generation to avoid
  // creating a new HTTP connection pool on every new conversation.
  late final Dio _titleDio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
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
    String? source,
    List<Map<String, dynamic>>? tools,
    bool enablefeatureReasoning = false,
    bool enableWebSearch = false,
    bool isCharacterModel = false,
    Function(String textChunk)? onTextChunk,
    Function(String featureReasoning)? onfeatureReasoning,
    FutureOr<void> Function(String imageUrl)? onImageReceived,
    FutureOr<void> Function(String videoUrl)? onVideoReceived,
    FutureOr<void> Function(String audioUrl)? onAudioReceived,
    FutureOr<void> Function(String mediaType)? onMediaGenerating,
    Function(List<dynamic> toolCalls)? onToolCall,
    Function(List<dynamic> citations)? onCitations,
    Function(bool active)? onWebSearchActive,
    Function()? onServerFallback,
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
      final List<Future<void>> pendingEventTasks = [];

      // Buffers for accumulating streaming parts
      Map<int, Map<String, dynamic>> toolCallBuffer = {};

      void trackCallback(FutureOr<void>? callbackResult) {
        if (callbackResult is Future) {
          pendingEventTasks.add(
            callbackResult.then((_) {}).catchError((e) {
              if (kDebugMode) {
                debugPrint("[SSE] Media callback error: $e");
              }
            }),
          );
        }
      }

      String? extractString(dynamic value, List<String> keys) {
        if (value == null) return null;
        if (value is String) return value;
        if (value is! Map) return null;

        for (final key in keys) {
          final direct = value[key];
          if (direct is String && direct.isNotEmpty) return direct;
          if (direct is Map) {
            final nested = extractString(direct, keys);
            if (nested != null && nested.isNotEmpty) return nested;
          }
        }

        final delta = value['delta'];
        if (delta is Map) {
          final nested = extractString(delta, keys);
          if (nested != null && nested.isNotEmpty) return nested;
        }

        final choices = value['choices'];
        if (choices is List && choices.isNotEmpty) {
          final first = choices.first;
          if (first is Map) {
            final nested = extractString(first, keys);
            if (nested != null && nested.isNotEmpty) return nested;
          }
        }

        return null;
      }

      String? extractTextChunk(dynamic value) {
        return extractString(value, const [
          'text',
          'content',
          'delta',
          'output_text',
          'message',
        ]);
      }

      String? extractReasoningChunk(dynamic value) {
        return extractString(value, const [
          'text',
          'reasoning',
          'reasoning_content',
          'thinking',
          'thought',
          'content',
          'delta',
        ]);
      }

      bool extractSearchActive(dynamic value, bool fallback) {
        if (value is bool) return value;
        if (value is num) return value != 0;
        if (value is String) {
          final normalized = value.toLowerCase();
          if (['true', '1', 'yes', 'started', 'active', 'searching']
              .contains(normalized)) {
            return true;
          }
          if (['false', '0', 'no', 'finished', 'complete', 'done', 'idle']
              .contains(normalized)) {
            return false;
          }
        }
        if (value is Map) {
          for (final key in const [
            'active',
            'isActive',
            'searching',
            'started',
            'enabled',
            'value',
          ]) {
            if (value.containsKey(key)) {
              return extractSearchActive(value[key], fallback);
            }
          }
        }
        return fallback;
      }

      bool isSearchFinishedEvent(String eventName) {
        final event = eventName.toLowerCase();
        return event.contains('finish') ||
            event.contains('complete') ||
            event.contains('done') ||
            event.contains('end') ||
            event.contains('stop');
      }

      bool containsWebSearchToolCall(dynamic value) {
        try {
          final encoded = jsonEncode(value).toLowerCase();
          return encoded.contains('need_web_search') ||
              encoded.contains('web_search');
        } catch (_) {
          return false;
        }
      }

      bool isProviderLimitFailure(String? code, String? message) {
        final normalizedCode = (code ?? '').toUpperCase();
        const limitCodes = {
          'PREMIUM_TRIAL_EXHAUSTED',
          'PREDIT_EXHAUSTED',
          'DREDIT_EXHAUSTED',
          'INSUFFICIENT_USER_CREDITS',
          'LIMIT_IMAGE_INSUFFICIENT',
          'LIMIT_VIDEO_INSUFFICIENT',
          'LIMIT_AUDIO_INSUFFICIENT',
          'LIMIT_MEDIA_INSUFFICIENT',
          'INSUFFICIENT_CREDITS',
          'INSUFFICIENT_BALANCE',
          'CREDITS_EXHAUSTED',
          'CREDIT_EXHAUSTED',
          'QUOTA_EXCEEDED',
          'PAYMENT_REQUIRED',
        };

        if (limitCodes.contains(normalizedCode)) return true;

        final haystack = '${code ?? ''} ${message ?? ''}'.toLowerCase();
        if (haystack.isEmpty) return false;

        final mentionsProviderLimit = haystack.contains('credit') ||
            haystack.contains('predit') ||
            haystack.contains('dredit') ||
            haystack.contains('balance') ||
            haystack.contains('quota') ||
            haystack.contains('billing') ||
            haystack.contains('payment required') ||
            haystack.contains('top up');

        final isLimitLanguage = haystack.contains('insufficient') ||
            haystack.contains('not enough') ||
            haystack.contains('out of') ||
            haystack.contains('exhausted') ||
            haystack.contains('exceeded') ||
            haystack.contains('ran out') ||
            haystack.contains('top up');

        return mentionsProviderLimit && isLimitLanguage;
      }

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
            if (source != null) "source": source,
            if (tools != null) "tools": tools,
            "tool_choice": (tools != null) ? "auto" : null,
            "enableReasoning": enablefeatureReasoning,
            "enableWebSearch": enableWebSearch,
            "isCharacterModel": isCharacterModel,
            "systemPromptLimitFallback":
                localizations.systemPromptLimitFallback,
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
        stream
            .cast<List<int>>()
            .transform(utf8.decoder)
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

                  if (isProviderLimitFailure(code, message)) {
                    completer.completeError(ApiException(
                      localizations.errorReachedLimit,
                      code: code ?? 'PROVIDER_LIMIT_REACHED',
                    ));
                    return;
                  }

                  switch (code) {
                    case 'PREMIUM_TRIAL_EXHAUSTED':
                    case 'PREDIT_EXHAUSTED':
                      userMsg = localizations.errorReachedLimit;
                      break;
                    case 'VIDEO_ULTRA_ONLY':
                      userMsg = localizations.premiumTrialExhaustedMessage;
                      break;
                    case 'DREDIT_EXHAUSTED':
                      userMsg = localizations.errorReachedLimit;
                      break;
                    case 'INSUFFICIENT_USER_CREDITS':
                      userMsg = localizations.errorReachedLimit;
                      break;
                    case 'CONTENT_FLAGGED':
                      userMsg = localizations.errorPromptFlagged;
                      break;
                    case 'FAL_IMAGE_REQUIRED':
                      userMsg = localizations.falErrorImageRequired;
                      break;
                    case 'FAL_AUDIO_REQUIRED':
                      userMsg = localizations.falErrorAudioRequired;
                      break;
                    case 'FAL_VIDEO_REQUIRED':
                      userMsg = localizations.falErrorVideoRequired;
                      break;
                    case 'FAL_IMAGE_CORRUPTED':
                      userMsg = localizations.falErrorImageCorrupted;
                      break;
                    case 'FAL_SCHEMA_REJECTED':
                      userMsg = localizations.falErrorSchemaRejected;
                      break;
                    case 'FAL_SCHEMA_INVALID':
                      userMsg = localizations.falErrorSchemaInvalid;
                      break;
                    case 'LIMIT_IMAGE_INSUFFICIENT':
                      userMsg = localizations.errorReachedLimit;
                      break;
                    case 'LIMIT_VIDEO_INSUFFICIENT':
                      userMsg = localizations.errorReachedLimit;
                      break;
                    case 'LIMIT_AUDIO_INSUFFICIENT':
                      userMsg = localizations.errorReachedLimit;
                      break;
                    case 'LIMIT_MEDIA_INSUFFICIENT':
                      userMsg = localizations.errorReachedLimit;
                      break;
                    case 'FAL_GENERIC_ERROR':
                      final statusCode = int.tryParse(message ?? '') ?? 0;
                      userMsg = localizations.falErrorGenericStatus(statusCode);
                      break;
                    case 'AI_SERVICE_ERROR':
                      // Always use localized error — never show raw backend messages
                      userMsg = localizations.errorServer;
                      break;
                    default:
                      userMsg = localizations.errorServer;
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
                  case 'text_delta':
                  case 'message_delta':
                    final text = extractTextChunk(data);
                    if (text != null) {
                      onWebSearchActive?.call(false);
                      onTextChunk?.call(text);
                      finalContent.write(text);
                    }
                    break;

                  case 'reasoning':
                  case 'reasoning_chunk':
                  case 'reasoning_delta':
                  case 'thinking':
                  case 'thinking_chunk':
                  case 'thought':
                  case 'thought_chunk':
                    final reasoning = extractReasoningChunk(data);
                    if (reasoning != null) {
                      onfeatureReasoning?.call(reasoning);
                    }
                    break;

                  case 'image_chunk':
                    final url = data['url'] as String?;
                    if (url != null) {
                      trackCallback(onImageReceived?.call(url));
                    }
                    break;

                  case 'audio_chunk':
                    final audioUrl = data['url'] as String?;
                    if (audioUrl != null) {
                      trackCallback(onAudioReceived?.call(audioUrl));
                    }
                    break;

                  case 'video_chunk':
                    final videoUrl = data['url'] as String?;
                    if (videoUrl != null) {
                      trackCallback(onVideoReceived?.call(videoUrl));
                    }
                    break;

                  case 'generating_audio':
                    trackCallback(onMediaGenerating?.call('audio'));
                    break;

                  case 'generating_image':
                    trackCallback(onMediaGenerating?.call('image'));
                    break;

                  case 'generating_video':
                    trackCallback(onMediaGenerating?.call('video'));
                    break;

                  case 'server_fallback':
                    trackCallback(onServerFallback?.call());
                    break;

                  case 'citations':
                    onWebSearchActive?.call(false);
                    if (data['citations'] is List && onCitations != null) {
                      onCitations(data['citations'] as List<dynamic>);
                    }
                    break;

                  case 'web_search_started':
                  case 'web_search_triggered':
                  case 'search_started':
                  case 'searching':
                  case 'search_start':
                    onWebSearchActive?.call(extractSearchActive(data, true));
                    break;

                  case 'web_search_finished':
                  case 'search_finished':
                  case 'search_done':
                  case 'search_end':
                    onWebSearchActive?.call(extractSearchActive(data, false));
                    break;

                  case 'tool_calls':
                    if (containsWebSearchToolCall(data)) {
                      onWebSearchActive?.call(true);
                    }
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

                  default:
                    final normalizedEvent = currentEvent.toLowerCase();
                    if (normalizedEvent.contains('search')) {
                      onWebSearchActive?.call(extractSearchActive(
                          data, !isSearchFinishedEvent(normalizedEvent)));
                    } else if (normalizedEvent.contains('reason')) {
                      final reasoning = extractReasoningChunk(data);
                      if (reasoning != null) {
                        onfeatureReasoning?.call(reasoning);
                      }
                    }
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
              () async {
                if (pendingEventTasks.isNotEmpty) {
                  await Future.wait(pendingEventTasks);
                }

                // Trigger onToolCall with fully accumulated tools if any exist
                if (toolCallBuffer.isNotEmpty && onToolCall != null) {
                  final List<dynamic> finalTools =
                      toolCallBuffer.values.toList();
                  onToolCall(finalTools);
                }
                completer.complete(finalContent.toString());
              }();
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
              final fallbacks =
                  List<Map<String, dynamic>>.from(jsonDecode(fallbackJson));
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
    String? source,
    List<String> attachmentPaths = const [],
    bool enablefeatureReasoning = false,
    Function(String)? onTextChunk,
    Function(String)? onfeatureReasoning,
    Function(String)? onImageReceived,
    Function(String)? onVideoReceived,
    Function(String)? onAudioReceived,
    Function(String)? onMediaGenerating,
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
      source: source,
      enablefeatureReasoning: enablefeatureReasoning,
      enableWebSearch: false,
      isCharacterModel: true,
      // Characters usually don't need web search, or pass it if needed
      onTextChunk: onTextChunk,
      onfeatureReasoning: onfeatureReasoning,
      onVideoReceived: onVideoReceived,
      onImageReceived: onImageReceived,
      onAudioReceived: onAudioReceived,
      onMediaGenerating: onMediaGenerating,
    );
  }

  /// Silently generates a title for a new conversation using the backend's fast new title endpoint.
  Future<String?> generateChatTitle(
      String userInput, String systemPrompt, String criticalInstruction,
      {bool isRetry = false}) async {
    try {
      debugPrint(
          '[TitleGen] 🚀 Starting title generation for: "${userInput.length > 20 ? userInput.substring(0, 20) : userInput}..."');
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
            "content":
                "$systemPrompt\n\n[CRITICAL INSTRUCTION]: $criticalInstruction",
          },
          {"role": "user", "content": userInput}
        ]
      };

      debugPrint('[TitleGen] 🚀 Sending DIO POST request to fast endpoint...');

      final dioForTitle = _titleDio;
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
        debugPrint(
            '[TitleGen] ⚠️ 401 Unauthorized detected! Refreshing token silently and retrying...');
        return generateChatTitle(userInput, systemPrompt, criticalInstruction,
            isRetry: true);
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
    String? source,
    List<String> attachmentPaths = const [],
    bool enablefeatureReasoning = false,
    Function(String)? onTextChunk,
    Function(String)? onfeatureReasoning,
    Function(String)? onImageReceived,
    Function(String)? onVideoReceived,
    Function(String)? onAudioReceived,
    Function(String)? onMediaGenerating,
    Function(List<dynamic>)? onToolCall,
    Function(List<dynamic>)? onCitations,
    Function(bool)? onWebSearchActive,
    Function()? onServerFallback,
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
      source: source,
      enablefeatureReasoning: enablefeatureReasoning,
      enableWebSearch: enableWebSearch,
      tools: toolsJson.isNotEmpty ? toolsJson : null,
      onTextChunk: onTextChunk,
      onfeatureReasoning: onfeatureReasoning,
      onVideoReceived: onVideoReceived,
      onImageReceived: onImageReceived,
      onAudioReceived: onAudioReceived,
      onMediaGenerating: onMediaGenerating,
      onToolCall: onToolCall,
      onCitations: onCitations,
      onWebSearchActive: onWebSearchActive,
      onServerFallback: onServerFallback,
    );
  }
}
