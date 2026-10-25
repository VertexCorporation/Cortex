// lib/apps/widgets.dart
//
// Shared building blocks for the Apps screens: section header, app row,
// round back button and the bottom search field.

import 'package:cortex/app.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';

import 'logo.dart';
import 'models.dart';

class AppsSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const AppsSectionHeader({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.tertiaryColor;
    return Semantics(
      header: true,
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, size: 22, color: color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppRow extends StatelessWidget {
  final CortexApp app;
  final VoidCallback onTap;
  final VoidCallback? onAction;

  const AppRow({
    super.key,
    required this.app,
    required this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.primaryColor.inverted;
    final muted = AppColors.tertiaryColor;

    final Widget trailing;
    if (app.connected && app.permission == AppPermission.off) {
      trailing = Icon(Icons.lock_outline_rounded, color: muted, size: 24);
    } else if (app.connected) {
      trailing = Icon(Icons.check_circle_rounded,
          color: AppColors.senaryColor, size: 24);
    } else {
      trailing = Icon(Icons.add_rounded, color: muted, size: 28);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            AppLogo(name: app.name, url: app.logo, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (app.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      app.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: muted, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onAction ?? onTap,
              icon: trailing,
              splashRadius: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class AppsBackButton extends StatelessWidget {
  const AppsBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondaryColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.of(context).maybePop(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.primaryColor.inverted,
            semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
          ),
        ),
      ),
    );
  }
}

class AppsTopBar extends StatelessWidget {
  final String title;

  const AppsTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppsBackButton(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 56),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.primaryColor.inverted,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppsSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final ValueChanged<String> onChanged;

  const AppsSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.tertiaryColor;
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: muted, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                color: AppColors.primaryColor.inverted,
                fontSize: 16,
              ),
              cursorColor: AppColors.senaryColor,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(color: muted, fontSize: 16),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : GestureDetector(
                    onTap: () {
                      controller.clear();
                      onChanged('');
                    },
                    child: Icon(Icons.close_rounded, color: muted, size: 22),
                  ),
          ),
        ],
      ),
    );
  }
}
