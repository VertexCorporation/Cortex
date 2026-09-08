import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'reveal_timeline.dart';

/// Keeps normal RichText layout, selection and recognizers. Only the recent
/// glyphs are painted separately; the shared clock never rebuilds Markdown.
class RevealText extends StatefulWidget {
  final InlineSpan text;
  final RevealTimeline timeline;
  final bool enableVerticalReveal;
  const RevealText(
      {super.key,
      required this.text,
      required this.timeline,
      this.enableVerticalReveal = true});
  @override
  State<RevealText> createState() => _RevealTextState();
}

class _RevealTextState extends State<RevealText> {
  String _previous = '';
  List<double> _births = [];
  int _generation = -1;
  static final _whitespace = RegExp(r'^\s+$');

  @override
  Widget build(BuildContext context) {
    final timeline = widget.timeline;
    final plain = widget.text.toPlainText(includeSemanticsLabels: false);
    if (_generation != timeline.generation) {
      _previous = '';
      _births = [];
      _generation = timeline.generation;
    }
    // Markdown can remove delimiters while retaining the text between them.
    // Preserve both unchanged ends so closing a delimiter never re-fades them.
    var prefix = 0;
    while (prefix < _previous.length &&
        prefix < plain.length &&
        _previous.codeUnitAt(prefix) == plain.codeUnitAt(prefix)) {
      prefix++;
    }
    var suffix = 0;
    while (suffix < _previous.length - prefix &&
        suffix < plain.length - prefix &&
        _previous.codeUnitAt(_previous.length - suffix - 1) ==
            plain.codeUnitAt(plain.length - suffix - 1)) {
      suffix++;
    }
    final births = List<double>.filled(plain.length, timeline.clock.value);
    for (var i = 0; i < prefix; i++) {
      births[i] = _births[i];
    }
    final newCount = (plain.length - suffix) - prefix;
    final now = timeline.clock.value;
    for (var i = 0; i < newCount; i++) {
      final stagger = newCount > 1 ? (i / newCount) * 50.0 : 0.0;
      births[prefix + i] = now - 50.0 + stagger;
    }
    for (var i = 0; i < suffix; i++) {
      births[plain.length - i - 1] = _births[_births.length - i - 1];
    }
    _births = births;
    _previous = plain;
    var offset = 0;
    final glyphs = <RevealGlyph>[];
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    InlineSpan visit(InlineSpan span, TextStyle inherited) {
      final style = inherited.merge(span.style);
      if (span is WidgetSpan) {
        offset++;
        // Preserve code blocks, citations and controls as real Flutter widgets.
        return span;
      }
      if (span is! TextSpan) return span;
      final children = <InlineSpan>[];
      final source = span.text ?? '';
      var stable = StringBuffer();
      void flushStable() {
        if (stable.isNotEmpty) {
          children.add(
              TextSpan(text: stable.toString(), recognizer: span.recognizer));
          stable = StringBuffer();
        }
      }

      for (final character in source.characters) {
        final birth = births[offset];
        final fresh = !timeline.isSettled &&
            !_whitespace.hasMatch(character) &&
            timeline.clock.value - birth < RevealTimeline.fadeMilliseconds;
        if (fresh) {
          flushStable();
          glyphs.add(RevealGlyph(
              offset,
              offset + character.length,
              birth,
              TextPainter(
                  text: TextSpan(text: character, style: style),
                  textDirection: direction,
                  textScaler: scaler)
                ..layout()));
          // Transparent glyph still participates in shaping, wrapping, hit
          // testing and accessibility at its final location.
          children.add(TextSpan(
              text: character,
              recognizer: span.recognizer,
              style: TextStyle(
                  foreground: Paint()..color = Colors.transparent,
                  background: Paint()..color = Colors.transparent,
                  decorationColor: Colors.transparent)));
        } else {
          stable.write(character);
        }
        offset += character.length;
      }
      flushStable();
      for (final child in span.children ?? const <InlineSpan>[]) {
        children.add(visit(child, style));
      }
      return TextSpan(
          style: span.style,
          children: children,
          recognizer: span.recognizer,
          mouseCursor: span.mouseCursor,
          onEnter: span.onEnter,
          onExit: span.onExit,
          semanticsLabel: span.semanticsLabel,
          locale: span.locale,
          spellOut: span.spellOut);
    }

    final text = visit(widget.text, DefaultTextStyle.of(context).style);
    return _GlyphPaint(
      clock: timeline.clock,
      glyphs: glyphs,
      verticalReveal: widget.enableVerticalReveal && timeline.verticalReveal,
      child: RichText(
          text: text,
          textScaler: scaler,
          textDirection: direction,
          selectionRegistrar: SelectionContainer.maybeOf(context),
          selectionColor: DefaultSelectionStyle.of(context).selectionColor),
    );
  }
}

class RevealGlyph {
  final int start;
  final int end;
  final double bornAt;
  final TextPainter painter;
  List<Rect> boxes = const [];
  RevealGlyph(this.start, this.end, this.bornAt, this.painter);
}

class _GlyphPaint extends SingleChildRenderObjectWidget {
  final ValueNotifier<double> clock;
  final List<RevealGlyph> glyphs;
  final bool verticalReveal;
  const _GlyphPaint(
      {required this.clock,
      required this.glyphs,
      required this.verticalReveal,
      required super.child});
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderGlyphPaint(clock, glyphs, verticalReveal);
  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderGlyphPaint renderObject) {
    renderObject.update(clock, glyphs, verticalReveal);
  }
}

class _RenderGlyphPaint extends RenderProxyBox {
  ValueNotifier<double> _clock;
  List<RevealGlyph> _glyphs;
  bool _verticalReveal;
  final Map<double, double> _lineBirths = {};
  _RenderGlyphPaint(this._clock, this._glyphs, this._verticalReveal);
  static const _curve = Cubic(.2, .8, .25, 1);

  void update(ValueNotifier<double> clock, List<RevealGlyph> glyphs,
      bool verticalReveal) {
    _verticalReveal = verticalReveal;
    if (_clock != clock) {
      if (attached) _clock.removeListener(markNeedsPaint);
      _clock = clock;
      if (attached) _clock.addListener(markNeedsPaint);
    }
    for (final glyph in _glyphs) {
      glyph.painter.dispose();
    }
    _glyphs = glyphs;
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _clock.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _clock.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void dispose() {
    for (final glyph in _glyphs) {
      glyph.painter.dispose();
    }
    super.dispose();
  }

  @override
  void performLayout() {
    super.performLayout();
    _lineBirths.clear();
    final paragraph = child;
    if (paragraph is RenderParagraph) {
      for (final glyph in _glyphs) {
        glyph.boxes = paragraph
            .getBoxesForSelection(
                TextSelection(baseOffset: glyph.start, extentOffset: glyph.end))
            .map((box) => box.toRect())
            .toList(growable: false);
        if (glyph.boxes.isNotEmpty) {
          final top = glyph.boxes.first.top;
          final previous = _lineBirths[top];
          if (previous == null || glyph.bornAt < previous) {
            _lineBirths[top] = glyph.bornAt;
          }
        }
      }
    }
  }

  @override
  Rect get paintBounds => super.paintBounds.inflate(6);
  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    // Share one shader per active line. The mask uses the existing small
    // glyph layer, never a second offscreen surface covering the message.
    final masks = <double, Paint>{};
    final visibleBounds = context.canvas.getLocalClipBounds().inflate(6);
    for (final glyph in _glyphs) {
      final progress = _curve.transform(
          ((_clock.value - glyph.bornAt) / RevealTimeline.fadeMilliseconds)
              .clamp(0.0, 1.0));
      if (progress == 0 || glyph.boxes.isEmpty) continue;
      final box = glyph.boxes.first;
      final position = offset +
          Offset(
              box.left - 3.5 * (1 - progress),
              box.top +
                  (box.height - glyph.painter.height) / 2 +
                  1.5 * (1 - progress));
      final canvas = context.canvas;
      // Old devices need not composite animated glyphs outside the viewport.
      if (!visibleBounds.overlaps((position & glyph.painter.size).inflate(4))) {
        continue;
      }
      if (progress < 1) {
        canvas.saveLayer((position & glyph.painter.size).inflate(4),
            Paint()..color = Color.fromRGBO(255, 255, 255, progress));
      }
      glyph.painter.paint(canvas, position);
      if (_verticalReveal && progress < 1) {
        final mask = masks.putIfAbsent(box.top, () {
          final age = ((_clock.value - (_lineBirths[box.top] ?? glyph.bornAt)) /
                  RevealTimeline.fadeMilliseconds)
              .clamp(0.0, 1.0);
          // A full line-height feather moves from above to below the line.
          // Opacity is continuous at both ends; there is no clipping edge.
          final front = offset.dy + box.top + box.height * (2 * age - 1);
          return Paint()
            ..blendMode = BlendMode.dstIn
            ..shader = ui.Gradient.linear(
                Offset(0, front),
                Offset(0, front + box.height),
                const [Colors.white, Colors.transparent]);
        });
        canvas.drawRect((position & glyph.painter.size).inflate(4), mask);
      }
      if (progress < 1) canvas.restore();
    }
  }
}
