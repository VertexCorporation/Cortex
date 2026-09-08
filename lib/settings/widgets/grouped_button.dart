import 'package:flutter/material.dart';

import '../../theme.dart';

/// The position of a row inside a thin, vertically stacked settings group.
enum SettingsRowPosition { standalone, first, middle, last }

/// A compact settings row with stable side borders and splash clipping.
class SettingsGroupedRow extends StatelessWidget {
  const SettingsGroupedRow({
    super.key,
    required this.position,
    required this.child,
    this.onTap,
    this.scale = 1,
    this.backgroundColor,
    this.verticalPadding,
    this.horizontalPadding,
    this.borderColor,
  });

  final SettingsRowPosition position;
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Color? backgroundColor;
  final double? verticalPadding;
  final double? horizontalPadding;
  final Color? borderColor;

  BorderRadius get _radius {
    final radius = Radius.circular(10 * scale);
    switch (position) {
      case SettingsRowPosition.first:
        return BorderRadius.only(topLeft: radius, topRight: radius);
      case SettingsRowPosition.last:
        return BorderRadius.only(bottomLeft: radius, bottomRight: radius);
      case SettingsRowPosition.standalone:
        return BorderRadius.all(radius);
      case SettingsRowPosition.middle:
        return BorderRadius.zero;
    }
  }

  Border get _border {
    final side = BorderSide(
      color: borderColor ?? AppColors.border,
      width: scale.clamp(0.8, 1.25),
    );
    return Border(
      left: side,
      right: side,
      top: position == SettingsRowPosition.first ||
              position == SettingsRowPosition.standalone
          ? side
          : BorderSide.none,
      bottom: position == SettingsRowPosition.last ||
              position == SettingsRowPosition.standalone
          ? side
          : BorderSide.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = _radius;
    return ClipRRect(
      borderRadius: radius,
      child: Material(
        color: backgroundColor ?? AppColors.background,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: AppColors.quaternaryColor.withValues(alpha: 0.3),
          highlightColor: AppColors.quaternaryColor.withValues(alpha: 0.08),
          child: Container(
            decoration: BoxDecoration(
              border: _border,
              // Keep the border geometry in sync with the clip and ink shape.
              // Without this, the outer ClipRRect cuts the stroke at corners.
              borderRadius: radius,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding ?? 16 * scale,
              vertical: verticalPadding ?? 11 * scale,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class SettingsGroupedColumn extends StatelessWidget {
  const SettingsGroupedColumn({
    super.key,
    required this.children,
    this.scale = 1,
    this.borderColor,
  });

  final List<Widget> children;
  final double scale;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10 * scale);
    final lineColor = borderColor ?? AppColors.border;
    final separatorColor = lineColor.withValues(alpha: 0.7);
    final separatorThickness = scale.clamp(0.8, 1.25);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: lineColor,
          width: separatorThickness,
        ),
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Column(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index < children.length - 1) ...[
                SizedBox(height: 3 * scale),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                  child: SizedBox(
                    height: separatorThickness,
                    child: ColoredBox(color: separatorColor),
                  ),
                ),
                SizedBox(height: 3 * scale),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
