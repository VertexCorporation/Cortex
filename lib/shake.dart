// shake.dart

import 'dart:math';

import 'package:flutter/cupertino.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final AnimationController controller;
  const ShakeWidget({super.key, required this.child, required this.controller});

  @override
  ShakeWidgetState createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget> {
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
        final dx = sin(pi * _offsetAnimation.value * 1) * 8;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}