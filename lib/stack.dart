// lib/stack.dart

import 'package:flutter/material.dart';

class FadeIndexedStack extends StatelessWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  Widget build(BuildContext context) {
    final idx = index;
    final list = children;
    return Stack(
      fit: StackFit.expand,
      children: List<Widget>.generate(list.length, (int i) {
        final isActive = idx == i;
        return IgnorePointer(
          ignoring: !isActive,
          child: AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.0,
            duration: duration,
            child: TickerMode(
              enabled: isActive,
              // Keep the same element shape while a screen becomes active or
              // inactive. Swapping this MediaQuery wrapper in and out tears
              // down descendants (including inherited-widget dependents and
              // GlobalKey subtrees) on every tab change.
              child: MediaQuery(
                data: isActive
                    ? MediaQuery.of(context)
                    : MediaQuery.of(context)
                          .copyWith(viewInsets: EdgeInsets.zero),
                child: list[i],
              ),
            ),
          ),
        );
      }),
    );
  }
}
