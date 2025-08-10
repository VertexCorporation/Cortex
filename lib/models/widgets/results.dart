// results.dart

import 'package:flutter/cupertino.dart';

class SearchResultItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final bool isExiting;

  const SearchResultItem({
    Key? key,
    required this.child,
    required this.index,
    required this.delay,
    this.isExiting = false,
  }) : super(key: key);

  @override
  _SearchResultItemState createState() => _SearchResultItemState();
}

class _SearchResultItemState extends State<SearchResultItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    if (!widget.isExiting) {
      // Enter animation
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    } else {
      // Start exit animation immediately
      _controller.value = 1.0;
      _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(SearchResultItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExiting && !oldWidget.isExiting) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}