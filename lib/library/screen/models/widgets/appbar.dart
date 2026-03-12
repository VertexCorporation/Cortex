// lib/library/screen/models/widgets/appbar.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../app.dart';
import '../../../../appbar.dart';
import '../../../../theme.dart';

class ModelsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onOpenCreateScreen;
  final ScrollController? scrollController;

  const ModelsAppBar({
    super.key,
    required this.title,
    required this.onOpenCreateScreen,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;
    final bool isDesktop = screenWidth >= 800; // [NEW] Desktop breakpoint

    // Consistent icon sizing
    final double iconSize = isTablet ? 26.0 : 22.0;

    return CortexAppBar(
      // Hide leading button on desktop since sidebar is fixed
      leadingMode: isDesktop ? CortexLeadingMode.none : CortexLeadingMode.auto,

      // Standard title with scroll listener (passed from controller)
      titleText: title,
      scrollController: scrollController,

      // Standard Action Button (Add)
      actionButton: AppBarButton(
        onTap: onOpenCreateScreen,
        child: SvgPicture.asset(
          'assets/icons/add.svg',
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(
            AppColors.primaryColor.inverted,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
