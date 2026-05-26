// lib/library/screen/model/widgets/body.dart

import 'package:flutter/material.dart';
import '../../../providers/details.dart';
import 'header.dart';
import 'sections.dart';

/// The main scrollable body of the Model Detail screen.
class BodyContent extends StatelessWidget {
  final ModelDetailProvider provider;
  final ScrollController scrollController;

  const BodyContent({
    super.key,
    required this.provider,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.mainModel == null) {
      return const Center(
          child: Text("Error: Model data could not be loaded."));
    }

    final double horizontalPadding = MediaQuery
        .of(context)
        .size
        .width * 0.04;

    return SingleChildScrollView(
      key: const ValueKey('model_detail_scroll_view'),
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding, // Left
        MediaQuery
            .of(context)
            .padding
            .top, // Top
        horizontalPadding, // Right
        MediaQuery
            .of(context)
            .size
            .height * 0.02,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        transitionBuilder: (child, animation) {
          final expectedKey = ValueKey(provider.selectedVariantName ?? 'default');
          final isIncoming = child.key is ValueKey &&
              (child.key as ValueKey).value == expectedKey.value;

          final slideAnimation = Tween<Offset>(
            begin: isIncoming ? const Offset(0.5, 0) : const Offset(-0.5, 0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

          return FadeTransition(
            opacity:
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
        child: Column(
          key: ValueKey(provider.selectedVariantName ?? 'default'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModelHeader(provider: provider),
            const _Spacing(),
            if (provider.displaySummary
                .trim()
                .isNotEmpty) ...[
              SummarySection(provider: provider),
              const _Spacing(),
            ],
            if (provider.isCharacterModel) ...[
              BaseModelSelectionSection(provider: provider),
              const _Spacing(),
            ],
            if (provider.displayDescription
                .trim()
                .isNotEmpty) ...[
              DescriptionSection(provider: provider),
              const _Spacing(),
            ],
            if (provider.parsedFeatures.isNotEmpty) ...[
              FeaturesSection(provider: provider),
            ],
          ],
        ),
      ),
    );
  }
}

/// A simple, consistent spacing widget used between sections.
class _Spacing extends StatelessWidget {
  const _Spacing();

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: MediaQuery
        .of(context)
        .size
        .height * 0.015);
  }
}