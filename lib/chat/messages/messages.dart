// messages.dart

import 'package:flutter/material.dart';

class Message {
  String text;
  late final bool isUserMessage;
  double opacity;
  bool isReported;
  bool isError;
  String? photoPath;
  bool isPhotoUploading;
  List<InlineSpan>? parsedSpans;
  final ValueNotifier<String> notifier;
  bool includeInContext;
  String? model;
  bool isThinking;

  Message({
    required this.text,
    required this.isUserMessage,
    this.opacity = 1.0,
    this.isReported = false,
    this.isError = false,
    this.isPhotoUploading = false,
    this.photoPath,
    this.parsedSpans,
    this.includeInContext = true,
    this.model,
    this.isThinking = false,
  }) : notifier = ValueNotifier(text);
}