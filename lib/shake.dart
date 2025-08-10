import 'package:flutter/cupertino.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  const ShakeWidget({
    Key? key,
    required this.child,
    required this.controller,
  }) : super(key: key);

  @override
  _ShakeWidgetState createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget> {
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _offsetAnimation = Tween<double>(begin: 0, end: 1)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(widget.controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        final dx =
            8 * (0.5 - 0.5 * (1 + (0.5 * _offsetAnimation.value)).abs());
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}