import 'package:flutter/material.dart';
import '../../../../theme.dart';

class PremiumBadge extends StatefulWidget {
  final double size;
  const PremiumBadge({super.key, this.size = 24.0});

  @override
  State<PremiumBadge> createState() => _PremiumBadgeState();
}

class _PremiumBadgeState extends State<PremiumBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _opacityAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnim,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: Container(
            padding: EdgeInsets.all(widget.size * 0.15),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.premium.withValues(alpha: 0.6),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.premium.withValues(alpha: 0.4 * _opacityAnim.value),
                  blurRadius: 8.0,
                  spreadRadius: 0.5,
                )
              ]
            ),
            child: Icon(
              Icons.workspace_premium_rounded, 
              color: AppColors.premium,
              size: widget.size * 0.6,
            ),
          ),
        );
      },
    );
  }
}
