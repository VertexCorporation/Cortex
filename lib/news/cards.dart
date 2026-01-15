// lib/news/cards.dart

import 'package:cortex/news/view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app.dart';
import '../theme.dart';
import 'data.dart';

/// A stateful card that displays a single news article.
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

class _NewsArticleCardState extends State<NewsArticleCard> {
  bool _isExpanded = false;
  bool _isAnimated = false;

  @override
  void initState() {
    super.initState();
    // Staggered animation effect
    Future.delayed(Duration(milliseconds: 50 * (widget.index % 5)), () {
      if (mounted) {
        setState(() {
          _isAnimated = true;
        });
      }
    });
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
      } else {
        debugPrint("Could not launch URL: $link");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return AnimatedOpacity(
      opacity: _isAnimated ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(
          top: _isAnimated ? 0 : 20,
          bottom: basePadding,
        ),
        transform: Matrix4.translationValues(0, _isAnimated ? 0 : 20, 0),
        child: Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(cardRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: hasExpandableContent ? _toggleExpansion : null,
            splashColor: AppColors.primaryColor.inverted.withValues(alpha: 0.1),
            highlightColor: AppColors.primaryColor.inverted.withValues(
                alpha: 0.05),
            child: AnimatedSize(
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
                                          color: AppColors.primaryColor
                                              .inverted,
                                          height: 1.3
                                      ),
                                    ),
                                    SizedBox(height: smallSpacing),
                                    Text(
                                      DateFormat.yMd(locale).format(
                                          widget.article.publishedAt),
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.032,
                                          color: AppColors.primaryColor.inverted
                                              .withValues(alpha: 0.6)
                                      ),
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
                                height: 1.5
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                        begin: const Offset(0.0, -0.1),
                                        end: Offset.zero).animate(animation),
                                    child: child,
                                  ),
                                ),
                            child: _isExpanded && hasExpandableContent
                                ? Padding(
                              key: ValueKey(widget.article.id),
                              padding: EdgeInsets.only(top: mediumSpacing),
                              child: Text(
                                fullContent,
                                style: TextStyle(
                                    fontSize: screenWidth * 0.038,
                                    color: AppColors.primaryColor.inverted
                                        .withValues(alpha: 0.85),
                                    height: 1.5
                                ),
                              ),
                            )
                                : const SizedBox.shrink(key: ValueKey('empty')),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}