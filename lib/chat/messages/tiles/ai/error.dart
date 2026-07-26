part of '../ai.dart';

class _AiErrorWidget extends StatefulWidget {
  final Message message;
  final double scale;
  const _AiErrorWidget({required this.message, required this.scale});

  @override
  State<_AiErrorWidget> createState() => _AiErrorWidgetState();
}

class _AiErrorWidgetState extends State<_AiErrorWidget> with SingleTickerProviderStateMixin {
  bool _isExpandedError = false;
  late AnimationController _animCtl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  List<InlineSpan> _buildBoldSpans(String text, TextStyle baseStyle) {
    final parts = text.split('**');
    final spans = <InlineSpan>[];
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i],
          style: i % 2 == 1 ? baseStyle.copyWith(fontWeight: FontWeight.bold) : baseStyle));
    }
    return spans;
  }

  @override
  void initState() {
    super.initState();
    _animCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animCtl, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animCtl, curve: Curves.easeOutQuad));
    _animCtl.forward();
  }

  @override
  void dispose() { _animCtl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dynamicFontSize = screenWidth * 0.04;
    final iconSize = screenWidth * 0.06;

    return GestureDetector(
      onTap: () => setState(() => _isExpandedError = !_isExpandedError),
      child: FadeTransition(
        opacity: _fadeAnim,
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
                    Icon(Icons.error_rounded, color: AppColors.septenaryColor, size: iconSize),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Text(AppLocalizations.of(context)!.requestFailed,
                        style: TextStyle(color: AppColors.septenaryColor, fontSize: dynamicFontSize)),
                    ),
                    AnimatedRotation(
                      turns: _isExpandedError ? 0.50 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutQuad,
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.septenaryColor, size: iconSize),
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
                            opacity: _isExpandedError ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: SlideTransition(
                              position: _slideAnim,
                              child: Padding(
                                padding: EdgeInsets.only(top: screenWidth * 0.02),
                                child: SelectionArea(
                                  child: Text.rich(
                                    TextSpan(
                                      children: _buildBoldSpans(
                                        widget.message.displayableText,
                                        TextStyle(color: AppColors.septenaryColor,
                                            fontSize: dynamicFontSize * 0.9),
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
