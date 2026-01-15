// lib/news/appbar.dart

import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/screen.dart';
import '../app.dart';

class NewsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const NewsAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final Color contentColor = AppColors.primaryColor.inverted;

    // --- Responsive Logic ---
    final double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final bool isTablet = screenWidth >= 600;

    final double iconSize = isTablet ? 32.0 : 26.0;

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leadingWidth: 70,
      leading: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                onPressed: () {
                  final canPop = Navigator.of(context).canPop();
                  if (canPop) {
                    Navigator.of(context).pop();
                  } else {
                    context
                        .findAncestorStateOfType<MainScreenState>()
                        ?.toggleAxon();
                  }
                },
                icon: SvgPicture.asset(
                  'assets/icons/sidebar.svg',
                  width: iconSize,
                  height: iconSize,
                  colorFilter: ColorFilter.mode(
                    contentColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            );
          }
      ),
      title: Text(
        title,
        style: TextStyle(
          color: contentColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}