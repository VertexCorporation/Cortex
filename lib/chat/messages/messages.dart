// lib/chat/messages/messages.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Message {
  /// A unique identifier for the message. Can be null for very old messages
  /// from the database before UUIDs were introduced. A new UUID is generated
  /// for brand-new messages.
  final String? id;

  final String text;
  final bool isUserMessage;

  /// The path to an attached photo, if one exists.
  final String? photoPath;

  /// The model ID used to generate this message (if it's an AI message).
  final String? model;

  /// Indicates if this message should be included in the context for future API calls.
  final bool includeInContext;

  // --- PERSISTENT STATE (Stored in the database) ---

  /// True if the user has reported this message.
  final bool isReported;

  // --- TRANSIENT STATE (Used for UI rendering and interactions, not stored) ---

  /// Indicates that an AI response is currently being generated.
  final bool isThinking;

  /// Indicates that this message represents an error.
  final bool isError;

  /// A UI-specific property for fade animations. Defaults to 1.0.
  final double opacity;

  /// A UI-specific property to show a loading indicator on a photo.
  final bool isPhotoUploading;

  /// Pre-parsed text spans for rich text rendering in the UI.
  final List<InlineSpan>? parsedSpans;

  /// A UI-specific notifier to efficiently update only the text of this message
  /// without rebuilding the entire message widget.
  final ValueNotifier<String> notifier;

  Message({
    this.id,
    required this.text,
    required this.isUserMessage,
    this.photoPath,
    this.model,
    this.includeInContext = true,
    this.isReported = false,
    this.isThinking = false,
    this.isError = false,
    this.opacity = 1.0,
    this.isPhotoUploading = false,
    this.parsedSpans,
  }) : notifier = ValueNotifier(text);

  /// Private constructor used by `copyWith` and `fromMap` to bypass
  /// the default UUID generation and notifier creation.
  Message._private({
    required this.id,
    required this.text,
    required this.isUserMessage,
    required this.photoPath,
    required this.model,
    required this.includeInContext,
    required this.isReported,
    required this.isThinking,
    required this.isError,
    required this.opacity,
    required this.isPhotoUploading,
    required this.parsedSpans,
    required this.notifier,
  });

  /// Creates a brand new user message, automatically generating a UUID.
  static Message user({
    required String text,
    String? photoPath,
    String? model, // The model the user is sending the message to
  }) {
    return Message(
      id: const Uuid().v4(),
      text: text,
      isUserMessage: true,
      photoPath: photoPath,
      model: model,
    );
  }

  Message copyWith({
    String? id,
    bool forceNewId = false, // If true, a new UUID will be generated, ignoring the 'id' parameter.
    String? text,
    bool? isUserMessage,
    String? photoPath,
    String? model,
    bool? includeInContext,
    bool? isReported,
    bool? isThinking,
    bool? isError,
    double? opacity,
    bool? isPhotoUploading,
    List<InlineSpan>? parsedSpans,
  }) {
    // If the text is changing, the notifier's value must be updated.
    // Otherwise, we reuse the existing notifier for efficiency.
    final newNotifier = (text != null && text != this.text)
        ? ValueNotifier(text)
        : notifier;

    // If the text is updated, we also update the notifier's value just in case
    // the new notifier was not created (e.g., text became the same).
    if (text != null) {
      newNotifier.value = text;
    }

    // Determine the final ID for the new message object.
    // Priority:
    // 1. If forceNewId is true, always generate a new UUID.
    // 2. If an 'id' is passed as a parameter, use it.
    // 3. Otherwise, fall back to the existing message's ID.
    final String? finalId = forceNewId ? const Uuid().v4() : (id ?? this.id);

    return Message._private(
      id: finalId,
      text: text ?? this.text,
      isUserMessage: isUserMessage ?? this.isUserMessage,
      photoPath: photoPath ?? this.photoPath,
      model: model ?? this.model,
      includeInContext: includeInContext ?? this.includeInContext,
      isReported: isReported ?? this.isReported,
      isThinking: isThinking ?? this.isThinking,
      isError: isError ?? this.isError,
      opacity: opacity ?? this.opacity,
      isPhotoUploading: isPhotoUploading ?? this.isPhotoUploading,
      parsedSpans: parsedSpans ?? this.parsedSpans,
      notifier: newNotifier,
    );
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    final text = (map['text'] ?? '') as String;
    return Message._private(
      // The 'uuid' column in the DB corresponds to the 'id' property.
      // It's now correctly handled as nullable.
      id: map['uuid'] as String?,

      text: text,
      isUserMessage: (map['isUser'] as int? ?? 0) == 1,
      photoPath: map['photoPath'] as String?,
      model: map['model'] as String?,
      includeInContext: (map['includeInContext'] as int? ?? 1) == 1,
      isReported: (map['isReported'] as int? ?? 0) == 1,

      // Transient properties are initialized to their default non-db state.
      isThinking: (map['isThinking'] as int? ?? 0) == 1, // Handle if stored, but default to false.
      isError: (map['isError'] as int? ?? 0) == 1,
      opacity: 1.0,
      isPhotoUploading: false,
      parsedSpans: null,

      // A new notifier is created with the text from the database.
      notifier: ValueNotifier(text),
    );
  }
}