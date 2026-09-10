part of 'input.dart';

class _TextFieldSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final AppLocalizations localizations;
  final double screenWidth;
  final bool isTablet;
  final VoidCallback onEnterPressed;
  final bool showHintText;

  /// Whether the composer is in the expanded capsule state. Selects which
  /// of the two semantic placeholder labels the field shows — the same
  /// state that drives the capsule morph, so label and geometry move
  /// together.
  final bool isComposerExpanded;

  /// Whether dictation is covering the field with the live waveform. The
  /// placeholder — and therefore its overflow fog — is not on stage then.
  final bool isDictating;

  const _TextFieldSection({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.localizations,
    required this.screenWidth,
    required this.isTablet,
    required this.onEnterPressed,
    this.showHintText = true,
    this.isComposerExpanded = false,
    this.isDictating = false,
  });

  @override
  Widget build(BuildContext context) {
    final double fontSize = isTablet ? screenWidth * 0.025 : screenWidth * 0.04;
    const double verticalPadding = 8.0;
    const double horizontalPadding = 4.0;
    final String hintLabel = isComposerExpanded
        ? localizations.messageHint
        : localizations.messageHintShort;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: LayoutBuilder(builder: (context, constraints) {
        // Boolean does-the-label-fit probe: the placeholder's own text
        // metrics against the decorator's content box. It never sizes or
        // positions anything (the decorator owns all hint geometry) — it
        // only decides whether the seam-covering fog strip below is needed
        // for locales whose label outgrows the pill.
        final TextPainter probe = TextPainter(
          text: TextSpan(
            text: hintLabel,
            style: TextStyle(color: Colors.grey[600], fontSize: fontSize),
          ),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        final bool labelOverflows =
            probe.width > constraints.maxWidth - 2 * horizontalPadding + 2.0;
        probe.dispose();

        // The fog belongs to the placeholder state alone: it lifts as soon
        // as the user types (the decorator swaps the hint out) and stands
        // down while dictation covers the slot with the waveform. Its
        // strips are painted, pointer-transparent and hard-clipped to the
        // field's box, so hit-testing, the caret and the composer geometry
        // are untouched.
        final bool showFog = labelOverflows &&
            showHintText &&
            controller.text.isEmpty &&
            !isDictating;

        return EdgeFog(
          showStart: false,
          showEnd: showFog,
          endFogWidth: fontSize * 0.75,
          endStripKey: const ValueKey('hint_fog_end'),
          child: TextField(
            key: const ValueKey('chat_input_field'),
            focusNode: focusNode,
            cursorColor: AppColors.primaryColor.inverted,
            controller: controller,
            // The caret stroke is a dynamic fraction of the field's responsive
            // font size — never a fixed pixel width. The hairline, plus the
            // framework's own caret anchoring, stays inside the first glyph's
            // natural left side bearing, so the blinking bar reads as sitting
            // immediately before the hint/typed glyph instead of painting over
            // its ink.
            cursorWidth: fontSize * 0.04,
            cursorRadius: Radius.circular(fontSize * 0.02),
            maxLength: 4000,
            minLines: 1,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: verticalPadding, horizontal: horizontalPadding),
              // One layout system for hint, caret and typed text: the
              // placeholder lives in the decorator's own hint slot with the
              // field's exact responsive style, so it shares the editable's
              // origin, line metrics and caret geometry instead of drawing a
              // separately scaled twin over the field. The placeholder has
              // two semantic labels — the short collapsed one and the full
              // expanded one — cross-faded by [_ComposerHint] on a shared
              // start edge: no FittedBox, no scaling, no ellipsis (a label
              // wider than the slot clips at the slot edge and dissolves
              // into the fog strip above).
              hint: showHintText
                  ? _ComposerHint(
                      short: localizations.messageHintShort,
                      full: localizations.messageHint,
                      expanded: isComposerExpanded,
                      fontSize: fontSize,
                      color: Colors.grey[600]!,
                    )
                  : null,
              hintStyle:
                  TextStyle(color: Colors.grey[600], fontSize: fontSize),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              counterText: '',
            ),
            style: TextStyle(
                color: AppColors.primaryColor.inverted, fontSize: fontSize),
            onSubmitted: (_) => onEnterPressed(),
          ),
        );
      }),
    );
  }
}

/// The composer's two-state placeholder. Both labels render at the field's
/// normal responsive font size — no FittedBox, no scaling, no ellipsis —
/// and the state change is a cross-fade anchored to the shared start edge
/// (direction-aware): the labels' common leading run occupies the same
/// pixels in both children, so expanding reads as the trailing portion
/// fading in beside an unmoving prefix and collapsing reverses it. Labels
/// are capped at one line with the default clip — never
/// [TextOverflow.ellipsis]; the slot's hard edge is dissolved by the
/// [_TextFieldSection] fog strip when a locale's label needs it.
class _ComposerHint extends StatefulWidget {
  const _ComposerHint({
    required this.short,
    required this.full,
    required this.expanded,
    required this.fontSize,
    required this.color,
  });

  final String short;
  final String full;
  final bool expanded;
  final double fontSize;
  final Color color;

  @override
  State<_ComposerHint> createState() => _ComposerHintState();
}

class _ComposerHintState extends State<_ComposerHint> {
  // Monotonic arrival counter: every label change produces a brand-new
  // key, so a rapid expand→collapse→expand can never collide with a
  // previous child that is still fading out (the duplicate-key crash that
  // destabilised the whole composer), while label-preserving rebuilds —
  // the morph's animation ticks — keep the same key and never restart
  // the fade.
  int _generation = 0;

  String get _label => widget.expanded ? widget.full : widget.short;

  @override
  void didUpdateWidget(_ComposerHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String oldLabel = oldWidget.expanded ? oldWidget.full : oldWidget.short;
    if (_label != oldLabel) _generation++;
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style =
        TextStyle(color: widget.color, fontSize: widget.fontSize);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      // Both children share one start-anchored stack: the outgoing label
      // keeps its exact position while the incoming one fades in over it.
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: AlignmentDirectional.centerStart,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: Text(
        _label,
        key: ValueKey<int>(_generation),
        style: style,
        maxLines: 1,
      ),
    );
  }
}

/// The dictation state of the input field: an opaque, capsule-colored sheet
/// carrying the live waveform. It covers the transcript-in-progress the way
/// the retired recording layout used to take over the whole bar, while the
/// composer around it keeps the expanded shape. The wave enters and exits
/// through the parent [AnimatedSwitcher]'s fade and undulates with the
/// detected sound level via [WaveformVisualizer]'s ticker, dissolving into
/// symmetric [EdgeFog] at both horizontal edges of the slot.
class _DictationWave extends StatelessWidget {
  const _DictationWave({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.background),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        // Symmetric fog on both edges so the wave dissolves into the
        // sheet at the field's sides instead of ending abruptly. The
        // strips reuse the app's single fog recipe and the sheet's own
        // color, ignore pointers and stay clipped to the wave's box —
        // controls, geometry and hit-testing are untouched.
        child: const EdgeFog(
          startFogWidth: 32.0,
          endFogWidth: 32.0,
          child: WaveformVisualizer(
            origin: WaveOrigin.right,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
