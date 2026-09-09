import 'dart:ui' show lerpDouble;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Measures both modes every frame and interpolates their actual heights using
/// the composer's master animation. Neither mode is inserted/removed on exit.
class RecordingLayout extends MultiChildRenderObjectWidget {
  RecordingLayout(
      {super.key,
      required this.progress,
      required Widget input,
      required Widget waveform})
      : super(children: [input, waveform]);

  final double progress;

  @override
  RenderStack createRenderObject(BuildContext context) =>
      _RenderRecordingLayout(progress);

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderStack renderObject) {
    (renderObject as _RenderRecordingLayout).progress = progress;
  }
}

class _RenderRecordingLayout extends RenderStack {
  _RenderRecordingLayout(this._progress)
      : super(
            alignment: Alignment.bottomCenter,
            textDirection: TextDirection.ltr);

  double _progress;
  set progress(double value) {
    if (_progress == value) return;
    _progress = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    super.performLayout();
    final input = firstChild!;
    final waveform = lastChild!;
    size = constraints.constrain(Size(size.width,
        lerpDouble(input.size.height, waveform.size.height, _progress)!));
    for (final child in [input, waveform]) {
      final data = child.parentData! as StackParentData;
      data.offset = Offset(
          (size.width - child.size.width) / 2, size.height - child.size.height);
    }
  }
}
