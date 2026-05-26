// lib/library/screen/models/widgets/appbar.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../app.dart';
import '../../../../appbar.dart';
import '../../../../l10n/app_localizations.dart';
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
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isTablet = screenWidth >= 600;
    final bool isDesktop = screenWidth >= 800;

    // Icon size matches the rest of the app
    final double iconSize = isTablet ? 18.0 : 15.0;

    final loc = AppLocalizations.of(context)!;

    return CortexAppBar(
      // Hide leading button on desktop since sidebar is fixed
      leadingMode: isDesktop ? CortexLeadingMode.none : CortexLeadingMode.auto,

      // Standard title with scroll listener (passed from controller)
      titleText: title,
      scrollController: scrollController,

      // [IMPROVED] Prominent "Create" pill button with icon + label
      // Previously was just a small icon — now clearly communicates its purpose
      actionButton: AppBarButton(
        isTitle: true,
        onTap: onOpenCreateScreen,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/add.svg',
              width: iconSize,
              height: iconSize,
              colorFilter: ColorFilter.mode(
                AppColors.primaryColor.inverted,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              loc.create,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 14.0 : 13.0,
                color: AppColors.primaryColor.inverted,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
