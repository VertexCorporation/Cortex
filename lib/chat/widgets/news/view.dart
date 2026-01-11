// lib/chat/screen/unselected/widgets/news/view.dart

import 'package:cortex/app.dart';
import 'package:cortex/chat/widgets/news/service.dart';
import 'package:cortex/chat/widgets/news/skeleton.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../cache.dart';
import '../../../../../initialization.dart';
import '../../../../../theme.dart';
import 'data.dart';

/// An extension on the [NewsArticle] model to handle localization logic.
///
/// This keeps the core model class pure and free from any `BuildContext` or
/// UI-layer dependencies, promoting better separation of concerns.
extension NewsArticleLocalization on NewsArticle {
  /// Retrieves the localized title for the current context.
  String titleFor(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return title[languageCode] ?? title['en'] ?? '';
  }

  /// Retrieves the localized summary for the current context.
  String summaryFor(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return summary[languageCode] ?? summary['en'] ?? '';
  }

  /// Retrieves the localized full content for the current context.
  String contentFor(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return content[languageCode] ?? content['en'] ?? '';
  }

  /// Retrieves the localized cover image path for the current context.
  String coverPathFor(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final paths = coverImagePaths ?? {};
    return paths[languageCode] ?? paths['en'] ?? '';
  }
}

/// The main UI widget that displays the news section.
///
/// It listens to the [NewsService] and uses an [AnimatedSwitcher] to smoothly
/// transition between loading, error, and content states.
class NewsSection extends StatelessWidget {
  const NewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    // Listen to the state changes in NewsService.
    final newsService = Provider.of<NewsService>(context);

    // A builder function to determine which widget to show based on the current state.
    Widget buildChild() {
      switch (newsService.state) {
        case NewsState.initial:
        case NewsState.loading:
          return const ShimmerNewsList(key: ValueKey('news_loading'));

        case NewsState.success:
          if (newsService.articles.isNotEmpty) {
            return Column(
              key: const ValueKey('news_content'),
              children: newsService.articles
                  .asMap()
                  .entries
                  .map((entry) => NewsArticleCard(
                article: entry.value,
                index: entry.key,
              ))
                  .toList(),
            );
          } else {

            return const SizedBox.shrink(key: ValueKey('news_empty'));
          }
      }
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: animation,
          axis: Axis.vertical,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: buildChild(),
    );
  }
}

/// A stateful card that displays a single news article.
///
/// It handles its own animations, such as the staggered fade-in effect and the
/// expansion animation for showing full content.
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
    // Creates a staggered animation effect for each card in the list.
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
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
    // All layout values are calculated based on screen width for a responsive UI.
    final screenWidth = MediaQuery.of(context).size.width;
    final double cardRadius = screenWidth * 0.06;
    final double basePadding = screenWidth * 0.04;
    final double mediumSpacing = screenWidth * 0.03;
    final double smallSpacing = screenWidth * 0.01;
    final double iconSize = screenWidth * 0.05;

    // Use the new extension methods for clean and readable localization.
    final title = widget.article.titleFor(context);
    final summary = widget.article.summaryFor(context);
    final fullContent = widget.article.contentFor(context);
    final coverPath = widget.article.coverPathFor(context);

    final locale = Localizations.localeOf(context).toLanguageTag();
    final hasLink = widget.article.link != null && widget.article.link!.isNotEmpty;
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
        child: Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(cardRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: hasExpandableContent ? _toggleExpansion : null,
            splashColor: AppColors.primaryColor.inverted.withValues(alpha: 0.1),
            highlightColor: AppColors.primaryColor.inverted.withValues(alpha: 0.05),
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
                        borderRadius: BorderRadius.vertical(top: Radius.circular(cardRadius - 1.0)),
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
                                      style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted, height: 1.3),
                                    ),
                                    SizedBox(height: smallSpacing),
                                    Text(
                                      DateFormat.yMd(locale).format(widget.article.publishedAt),
                                      style: TextStyle(fontSize: screenWidth * 0.032, color: AppColors.primaryColor.inverted.withValues(alpha: 0.6)),
                                    ),
                                  ],
                                ),
                              ),
                              if (hasLink)
                                IconButton(
                                  icon: Icon(Icons.touch_app, size: iconSize, color: AppColors.primaryColor.inverted.withValues(alpha: 0.8)),
                                  onPressed: _launchLink,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                          SizedBox(height: mediumSpacing),
                          Text(
                            summary,
                            style: TextStyle(fontSize: screenWidth * 0.038, color: AppColors.primaryColor.inverted.withValues(alpha: 0.85), height: 1.5),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) => FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(begin: const Offset(0.0, -0.1), end: Offset.zero).animate(animation),
                                child: child,
                              ),
                            ),
                            child: _isExpanded && hasExpandableContent
                                ? Padding(
                              key: ValueKey(widget.article.id),
                              padding: EdgeInsets.only(top: mediumSpacing),
                              child: Text(
                                fullContent,
                                style: TextStyle(fontSize: screenWidth * 0.038, color: AppColors.primaryColor.inverted.withValues(alpha: 0.85), height: 1.5),
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

/// A widget to securely load and display an image from Firebase Storage.
///
/// It implements a robust three-tier caching strategy:
/// 1. In-memory cache for immediate access.
/// 2. Persistent SharedPreferences cache for session-to-session reuse.
/// 3. Network fetch as a final fallback.
class FirebaseStorageImage extends StatefulWidget {
  final String imagePath;
  const FirebaseStorageImage({super.key, required this.imagePath});
  @override
  State<FirebaseStorageImage> createState() => _FirebaseStorageImageState();
}

class _FirebaseStorageImageState extends State<FirebaseStorageImage> {
  Future<String?>? _imageUrlFuture;
  static const String _getDownloadUrlEndpoint = "https://europe-west1-vertex-ai-1618.cloudfunctions.net/getCoverDownloadUrl";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the future only if it's currently null.
    _imageUrlFuture ??= _getCachedOrFetchDownloadUrl();
  }

  void _retry() {
    // To retry, we nullify the future and call setState.
    // This will cause the FutureBuilder to re-evaluate and fetch the URL again.
    if (mounted) {
      setState(() {
        _imageUrlFuture = null;
      });
      // Re-initialize after the current build frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _imageUrlFuture = _getCachedOrFetchDownloadUrl();
          });
        }
      });
    }
  }

  Future<String?> _getCachedOrFetchDownloadUrl() async {
    try {
      return await Future.sync(() async {
        // TIER 1: In-memory cache check (fastest)
        final inMemoryUrls = CacheService.get<Map<String, String>>(CacheKey.newsImageUrls);
        if (inMemoryUrls?[widget.imagePath] != null) {
          return inMemoryUrls![widget.imagePath];
        }

        // TIER 2: Persistent cache check (SharedPreferences)
        final prefs = await SharedPreferences.getInstance();
        final String cacheKey = 'news_image_url_${widget.imagePath}';
        final String? cachedDataJson = prefs.getString(cacheKey);
        if (cachedDataJson != null) {
          try {
            final Map<String, dynamic> cachedData = jsonDecode(cachedDataJson);
            if (DateTime.now().millisecondsSinceEpoch < (cachedData['expires'] as int)) {
              final String persistentUrl = cachedData['url'] as String;
              final currentInMemoryUrls = CacheService.get<Map<String, String>>(CacheKey.newsImageUrls) ?? {};
              currentInMemoryUrls[widget.imagePath] = persistentUrl;
              CacheService.set(CacheKey.newsImageUrls, currentInMemoryUrls);
              return persistentUrl;
            }
          } catch (_) {}
        }

        // TIER 3: Network fetch (fallback)
        if (!mounted) return null;
        debugPrint("[FirebaseStorageImage] CACHE MISS. Fetching from network for: ${widget.imagePath}");

        final appInitializer = Provider.of<AppInitializer>(context, listen: false);
        final dio = Provider.of<Dio>(context, listen: false);

        await appInitializer.onCoreServicesReady;
        if (!mounted) return null;

        final user = await FirebaseAuth.instance.authStateChanges().first;
        if (user == null) return null;
        final idToken = await user.getIdToken();
        if (!mounted) return null;

        final response = await dio.post(
          _getDownloadUrlEndpoint,
          data: jsonEncode({'data': {'filePath': widget.imagePath}}),
          options: Options(headers: {"Authorization": "Bearer $idToken", "Content-Type": "application/json"}),
        );

        if (!mounted) return null;

        if (response.statusCode == 200 && response.data != null) {
          final newUrl = response.data['result']?['signedUrl'] as String?;
          if (newUrl != null) {
            // Cache the new URL in memory and persistent storage.
            final currentUrls = CacheService.get<Map<String, String>>(CacheKey.newsImageUrls) ?? {};
            currentUrls[widget.imagePath] = newUrl;
            CacheService.set(CacheKey.newsImageUrls, currentUrls);

            final expiryTime = DateTime.now().add(const Duration(minutes: 8)).millisecondsSinceEpoch;
            await prefs.setString(cacheKey, jsonEncode({'url': newUrl, 'expires': expiryTime}));
          }
          return newUrl;
        }
        return null;
      }).timeout(const Duration(seconds: 25));
    } catch (e) {
      debugPrint("Failed to get image download URL within timeout: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _imageUrlFuture,
      builder: (context, snapshot) {
        Widget child;
        if (snapshot.connectionState == ConnectionState.waiting) {
          child = const ShimmerPlaceholder(key: ValueKey('loading'));
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          child = _ErrorState(key: const ValueKey('error'), onRetry: _retry);
        } else {
          child = CachedNetworkImage(
            key: ValueKey(snapshot.data!),
            imageUrl: snapshot.data!,
            fit: BoxFit.cover,
            placeholder: (context, url) => const ShimmerPlaceholder(),
            errorWidget: (context, url, error) => _ErrorState(onRetry: _retry),
          );
        }

        // The AnimatedSwitcher handles the smooth fade between states.
        // Because all children (Shimmer, Error, Image) are designed to fill their
        // parent space, and the parent is a fixed-size AspectRatio, there is
        // zero possibility of a layout jump.
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: SizedBox.expand(child: child), // Ensures child always fills the AspectRatio
        );
      },
    );
  }
}

/// A private helper widget for the image error state, now with a retry button.
/// A private helper widget for the image error state.
/// It now displays a single icon and handles retry logic via onTap.
/// The state change (icon <-> shimmer) is animated.
class _ErrorState extends StatefulWidget {
  final VoidCallback onRetry;
  const _ErrorState({super.key, required this.onRetry});

  @override
  State<_ErrorState> createState() => __ErrorStateState();
}

class __ErrorStateState extends State<_ErrorState> {
  bool _isRetrying = false;

  void _handleTap() {
    if (_isRetrying) return; // Prevent multiple taps while retrying

    setState(() {
      _isRetrying = true;
    });

    // A small delay ensures the user sees the transition to the shimmer effect
    // before the actual network request is fired by the parent.
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.onRetry();
      // We don't need to set _isRetrying back to false here,
      // because the entire FutureBuilder in the parent will rebuild
      // and this widget will be replaced by either the image or a new error state.
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // The widget to show based on the retrying state.
    Widget child;
    if (_isRetrying) {
      // While retrying, show the shimmer placeholder for instant feedback.
      child = const ShimmerPlaceholder(key: ValueKey('retrying_shimmer'));
    } else {
      // Default error state: show the warning icon.
      child = Center(
        key: const ValueKey('error_icon'),
        child: SvgPicture.asset(
          'assets/icons/warning.svg',
          width: screenWidth * 0.08,
          height: screenWidth * 0.08,
          colorFilter: ColorFilter.mode(
              AppColors.primaryColor.inverted.withValues(alpha: 0.6),
              BlendMode.srcIn),
        ),
      );
    }

    return Material(
      color: AppColors.border.withValues(alpha: 0.5),
      child: InkWell(
        onTap: _handleTap,
        // AnimatedSwitcher will handle the smooth transition between the
        // error icon and the shimmer placeholder when the user taps to retry.
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: child,
        ),
      ),
    );
  }
}