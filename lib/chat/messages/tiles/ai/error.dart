part of '../ai.dart';

class _AiErrorWidget extends StatefulWidget {
  final Message message;
  final double scale;

  const _AiErrorWidget({required this.message, required this.scale});

  @override
  State<_AiErrorWidget> createState() => _AiErrorWidgetState();
}

class _AiErrorWidgetState extends State<_AiErrorWidget> with TickerProviderStateMixin {
  bool _isExpandedError = false;
  bool _showErrorText = false;
  late AnimationController _errorSlideCtl;
  late Animation<Offset> _errorSlideAnim;
  late AnimationController _errorFadeOutCtl;
  late Animation<double> _errorFadeOutAnim;

  List<InlineSpan> _buildBoldSpans(String text, TextStyle baseStyle) {
    final parts = text.split('**');
    final spans = <InlineSpan>[];
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: i % 2 == 1 ? baseStyle.copyWith(fontWeight: FontWeight.bold) : baseStyle,
      ));
    }
    return spans;
  }

  @override
  void initState() {
    super.initState();
    _errorSlideCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _errorSlideAnim = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _errorSlideCtl, curve: Curves.easeOutQuad));

    _errorFadeOutCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _errorFadeOutAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _errorFadeOutCtl, curve: Curves.easeOut),
    );

    // Initial fade in
    _errorFadeOutCtl.forward();
  }

  @override
  void dispose() {
    _errorSlideCtl.dispose();
    _errorFadeOutCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dynamicFontSize = screenWidth * 0.04;
    final iconSize = screenWidth * 0.06;

    return GestureDetector(
      onTap: () => setState(() {
        if (_isExpandedError) {
          _errorSlideCtl.reverse().then((_) {
            if (mounted) {
              setState(() {
                _isExpandedError = false;
                _showErrorText = false;
              });
            }
          });
        } else {
          _isExpandedError = true;
          _errorSlideCtl.forward().whenComplete(() {
            if (mounted) setState(() => _showErrorText = true);
          });
        }
      }),
      child: FadeTransition(
        opacity: _errorFadeOutAnim,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.septenaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                border: Border.all(color: AppColors.septenaryColor, width: 0.5)),
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.error_rounded,
                      color: AppColors.septenaryColor,
                      size: iconSize,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.requestFailed,
                        style: TextStyle(
                          color: AppColors.septenaryColor,
                          fontSize: dynamicFontSize,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpandedError ? 0.50 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutQuad,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.septenaryColor,
                        size: iconSize,
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutQuad,
                  alignment: Alignment.topCenter,
                  child: !_isExpandedError
                      ? const SizedBox.shrink()
                      : ClipRect(
                          child: AnimatedOpacity(
                            opacity: _showErrorText ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: SlideTransition(
                              position: _errorSlideAnim,
                              child: Padding(
                                padding: EdgeInsets.only(top: screenWidth * 0.02),
                                child: SelectionArea(
                                  child: Text.rich(
                                    TextSpan(
                                      children: _buildBoldSpans(
                                        widget.message.displayableText,
                                        TextStyle(
                                          color: AppColors.septenaryColor,
                                          fontSize: dynamicFontSize * 0.9,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
