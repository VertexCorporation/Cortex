// lib/news/cards.dart

import 'package:cortex/news/view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app.dart';
import '../theme.dart';
import 'data.dart';

/// A heavily optimized card widget with GPU-accelerated entry animations.
class NewsArticleCard extends StatefulWidget {
  final NewsArticle article;
  final int index;

  const NewsArticleCard({
    super.key,
    required this.article,
    required this.index,
  });

  @override
  State<NewsArticleCard> createState() => _NewsArticleCardState();
}

class _NewsArticleCardState extends State<NewsArticleCard>
    with SingleTickerProviderStateMixin {

  // Animation controller for the entry effect
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    // OPTIMIZATION 1: Explicit Controller
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    // OPTIMIZATION 2: SlideTransition Logic
    // Moving from Offset(0, 0.1) to Offset.zero allows us to use
    // SlideTransition, which is a GPU operation, unlike changing margin/padding.
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutQuart,
    ));

    // Staggered start based on index
    // Note: Since the parent uses KeepAlive, this only runs ONCE per session.
    final delay = Duration(milliseconds: 50 * (widget.index % 5));
    Future.delayed(delay, () {
      if (mounted) {
        _entryController.forward();
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Future<void> _launchLink() async {
    final link = widget.article.link;
    if (link != null && link.isNotEmpty) {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // OPTIMIZATION 3: RepaintBoundary
    // This isolates the card's painting layer. When the image inside loads,
    // only this specific box repaints, not the entire scroll view.
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildCardContent(context),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final double cardRadius = screenWidth * 0.04;
    final double basePadding = screenWidth * 0.04;
    final double mediumSpacing = screenWidth * 0.03;
    final double smallSpacing = screenWidth * 0.01;
    final double iconSize = screenWidth * 0.05;

    final title = widget.article.titleFor(context);
    final summary = widget.article.summaryFor(context);
    final fullContent = widget.article.contentFor(context);
    final coverPath = widget.article.coverPathFor(context);

    final locale = Localizations.localeOf(context).toLanguageTag();
    final hasLink = widget.article.link != null &&
        widget.article.link!.isNotEmpty;
    final hasExpandableContent = fullContent.isNotEmpty;

    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(cardRadius),
      // Optimization: No antiAlias clip here unless strictly necessary to avoid off-screen rendering
      child: InkWell(
        onTap: hasExpandableContent ? _toggleExpansion : null,
        borderRadius: BorderRadius.circular(cardRadius),
        splashColor: AppColors.primaryColor.inverted.withValues(alpha: 0.1),
        highlightColor: AppColors.primaryColor.inverted.withValues(alpha: 0.05),
        child: AnimatedSize(
          // AnimatedSize does cause layout changes, but only on user tap,
          // so it's acceptable here (unlike in the entry animation).
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border, width: 1.0),
              borderRadius: BorderRadius.circular(cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (coverPath.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(cardRadius - 1.0)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: FirebaseStorageImage(imagePath: coverPath),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(basePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryColor.inverted,
                                      height: 1.3),
                                ),
                                SizedBox(height: smallSpacing),
                                Text(
                                  DateFormat.yMd(locale)
                                      .format(widget.article.publishedAt),
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.032,
                                      color: AppColors.primaryColor.inverted
                                          .withValues(alpha: 0.6)),
                                ),
                              ],
                            ),
                          ),
                          if (hasLink)
                            IconButton(
                              icon: Icon(Icons.touch_app,
                                  size: iconSize,
                                  color: AppColors.primaryColor.inverted
                                      .withValues(alpha: 0.8)),
                              onPressed: _launchLink,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                      SizedBox(height: mediumSpacing),
                      Text(
                        summary,
                        style: TextStyle(
                            fontSize: screenWidth * 0.038,
                            color: AppColors.primaryColor.inverted
                                .withValues(alpha: 0.85),
                            height: 1.5),
                      ),
                      // Expandable Content
                      if (_isExpanded && hasExpandableContent)
                        Padding(
                          key: ValueKey(widget.article.id),
                          padding: EdgeInsets.only(top: mediumSpacing),
                          child: AnimatedOpacity(
                            opacity: _isExpanded ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              fullContent,
                              style: TextStyle(
                                  fontSize: screenWidth * 0.038,
                                  color: AppColors.primaryColor.inverted
                                      .withValues(alpha: 0.85),
                                  height: 1.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}