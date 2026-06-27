// lib/news/appbar.dart

import 'package:cortex/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../appbar.dart';

class NewsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ScrollController? scrollController;

  const NewsAppBar({
    super.key,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isDesktop = MediaQuery.sizeOf(context).width >= 800; // [NEW]

    return CortexAppBar(
      // Hide leading button on desktop since sidebar is fixed
      leadingMode: isDesktop ? CortexLeadingMode.none : CortexLeadingMode.auto,

      titleText: l10n.news,
      scrollController: scrollController,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
