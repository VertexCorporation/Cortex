part of 'input.dart';

class _SequencedToolsTransition extends StatefulWidget {
  final bool isVisible;
  final Widget child;

  const _SequencedToolsTransition({
    required this.isVisible,
    required this.child,
  });

  @override
  State<_SequencedToolsTransition> createState() =>
      _SequencedToolsTransitionState();
}

class _SequencedToolsTransitionState extends State<_SequencedToolsTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Fade Out: 0.0 - 0.4 progress
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
        reverseCurve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Shrink: 0.4 - 1.0 progress
    _sizeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOutCubic),
        reverseCurve: const Interval(0.4, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    if (!widget.isVisible) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_SequencedToolsTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _sizeAnimation,
          axis: Axis.vertical,
          axisAlignment: -1.0,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _ToolsSection extends StatelessWidget {
  final double screenWidth;
  final bool isTablet;
  final InputField widget;
  final bool isActionPermitted;

  const _ToolsSection(
      {required this.screenWidth,
      required this.isTablet,
      required this.isActionPermitted,
      required this.widget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: isTablet ? screenWidth * 0.02 : 12.0,
        end: 8.0,
        top: 2.0,
        bottom: isTablet ? screenWidth * 0.015 : 12.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AddPhotoButton(
            isLimitExceeded: widget.isLimitExceeded,
            isPhotoLoading: widget.isPhotoLoading,
            localizations: widget.localizations,
          ),
          SizedBox(width: screenWidth * 0.02),
          FeaturesButton(
            controller: widget.controller,
            isLimitExceeded: widget.isLimitExceeded,
            isActionPermitted: isActionPermitted,
          ),
          SizedBox(width: screenWidth * 0.02),
          ModelSelectButton(
            screenWidth: screenWidth,
            isTablet: isTablet,
            localizations: widget.localizations,
            onSelectionComplete: () => widget.textFieldFocusNode.requestFocus(),
          ),
        ],
      ),
    );
  }
}
