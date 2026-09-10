part of 'input.dart';

class _TextFieldSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final AppLocalizations localizations;
  final double screenWidth;
  final bool isTablet;
  final VoidCallback onEnterPressed;
  final bool showHintText;

  const _TextFieldSection({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.localizations,
    required this.screenWidth,
    required this.isTablet,
    required this.onEnterPressed,
    this.showHintText = true,
  });

  @override
  Widget build(BuildContext context) {
    final double fontSize = isTablet ? screenWidth * 0.025 : screenWidth * 0.04;
    final double verticalPadding = 8.0;
    final double horizontalPadding = 4.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.0),
      child: Stack(
        children: [
          TextField(
            key: const ValueKey('chat_input_field'),
            focusNode: focusNode,
            cursorColor: AppColors.primaryColor.inverted,
            controller: controller,
            maxLength: 4000,
            minLines: 1,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                  vertical: verticalPadding, horizontal: horizontalPadding),
              // An invisible twin of the hint, kept purely for semantics:
              // it is what the screen reader announces for the field. The
              // visible hint is the centered overlay below instead, because
              // the decorator places its hint inside the editor's baseline
              // slot — which is what left unequal space above and below the
              // text.
              hintText: showHintText ? localizations.messageHint : null,
              hintStyle: TextStyle(
                color: const Color(0x00000000),
                fontSize: fontSize,
              ),
              hintMaxLines: 1,
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
          // The visible hint, with mathematically equal padding: the
          // overlay spans exactly the field's box, so the space above and
          // below the text is equal at every width, scale factor and line
          // count. It never intercepts touches and never duplicates the
          // field's semantics, so hit-testing and screen readers are
          // unaffected.
          if (showHintText)
            Positioned.fill(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, _) {
                      if (value.text.isNotEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              localizations.messageHint,
                              key: const ValueKey('hint_overlay'),
                              maxLines: 1,
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: fontSize),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
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
