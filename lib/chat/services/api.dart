// lib/chat/services/api.dart

import 'dart:convert';
import 'dart:async';
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

  final Dio _dio;
  CancelToken? _cancelToken;

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
    List<Map<String, dynamic>>? tools, // ADDED: Tools support
    Function(String textChunk)? onTextChunk,
    Function(String reasoning)? onReasoning, // ADDED: Reasoning support
    Function(String imageUrl)? onImageReceived,
    Function(List<dynamic> toolCalls)? onToolCall, // ADDED: Tool Calls
    required AppLocalizations localizations,
  }) async {
    _cancelToken = CancelToken();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw ApiException(localizations.errorUserNotAuthenticated,
          statusCode: 401, code: 'NO_USER');
    }

    Future<String> attemptRequest(String token) async {
      final completer = Completer<String>();
      final finalContent = StringBuffer();
      String currentEvent = '';

      // Buffers for accumulating streaming parts
      Map<int, Map<String, dynamic>> toolCallBuffer = {};

      try {
        debugPrint("[ApiService] Sending request. Model: $model");

        final response = await _dio.post<ResponseBody>(
          _proxyBaseUrl,
          data: jsonEncode({
            "model": model,
            "messages": messages,
            "isPremiumModel": isPremium,
            if (tools != null) "tools": tools,
            "tool_choice": (tools != null) ? "auto" : null,
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

        final stream = response.data?.stream;
        if (stream == null) {
          throw ApiException(localizations.errorServer, code: 'NULL_STREAM');
        }

        stream.map(utf8.decode).transform(const LineSplitter()).listen(
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
                      onReasoning?.call(reasoning);
                    }
                    break;

                  case 'image_chunk':
                    final url = data['url'] as String?;
                    if (url != null) onImageReceived?.call(url);
                    break;

                  case 'tool_calls':
                    // Accumulate tool call deltas
                    // OpenRouter/OpenAI streaming format: List of objects with index
                    if (data is List) {
                      for (var item in data) {
                        final index = item['index'] as int;
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
                    // Optional: Log usage or update provider
                    debugPrint("Usage Stats: $data");
                    break;
                }
              } catch (e) {
                // Ignore parse errors for individual chunks
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

    try {
      final idToken = await user.getIdToken(false);
      return await attemptRequest(idToken!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        final refreshedToken = await user.getIdToken(true);
        return await attemptRequest(refreshedToken!);
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
    Function(String)? onTextChunk,
    Function(String)? onReasoning,
    Function(String)? onImageReceived,
    required AppLocalizations localizations,
  }) async {
    // Character models usually don't use tools (for now), keeping simpler.
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
      onTextChunk: onTextChunk,
      onReasoning: onReasoning,
      onImageReceived: onImageReceived,
      // No tools for characters typically
    );
  }

  Future<String> getOnlineModelResponse({
    required String modelId,
    required bool isPremium,
    required String userInput,
    required List<Map<String, dynamic>> context,
    List<String> attachmentPaths = const [],
    Function(String)? onTextChunk,
    Function(String)? onReasoning,
    Function(String)? onImageReceived,
    Function(List<dynamic>)? onToolCall, // Exposed for logic loop
    required AppLocalizations localizations,
    required String langCode,
    bool useTools = true,
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

    // Attach Tools Definition
    final toolsJson = useTools
        ? ToolRegistry.getLocalizedToolsJson(langCode, localizations)
        : <Map<String, dynamic>>[];

    return _getResponse(
      localizations: localizations,
      messages: messages,
      model: modelId,
      isPremium: isPremium,
      tools: toolsJson.isNotEmpty ? toolsJson : null,
      onTextChunk: onTextChunk,
      onReasoning: onReasoning,
      onImageReceived: onImageReceived,
      onToolCall: onToolCall,
    );
  }
}
