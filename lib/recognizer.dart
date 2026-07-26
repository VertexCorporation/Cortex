import 'package:flutter/gestures.dart';

class ShortLongPressGestureRecognizer extends LongPressGestureRecognizer {
  ShortLongPressGestureRecognizer({
    required Object debugOwner,
    this.shortPressDuration = const Duration(milliseconds: 50),
  }) : super(debugOwner: debugOwner);

  final Duration shortPressDuration;

  @override
  Duration get deadline => shortPressDuration;
}
