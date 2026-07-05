// lib/news/view.dart

import 'package:cortex/app.dart';
import 'package:cortex/news/service.dart';
import 'package:cortex/news/skeleton.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/fog.dart';
import 'package:cortex/news/search.dart';
import '../../../../../cache.dart';
import '../../../../../initialization.dart';
import '../error.dart';
import 'appbar.dart';
import 'cards.dart';
import 'data.dart';

extension NewsArticleLocalization on NewsArticle {
  String titleFor(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return title[languageCode] ?? title['en'] ?? '';
  }

  String summaryFor(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return summary[languageCode] ?? summary['en'] ?? '';
  }

  String contentFor(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return content[languageCode] ?? content['en'] ?? '';
  }

  String coverPathFor(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final paths = coverImagePaths ?? {};
    return paths[languageCode] ?? paths['en'] ?? '';
  }
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase().trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    context.watch<ThemeProvider>();
    final newsService = Provider.of<NewsService>(context);
    final l10n = AppLocalizations.of(context);

    final Size screenSize = MediaQuery.sizeOf(context);
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    // Background Blob Constants
    final double blobTop = screenHeight * 0.00;
    final double blobLeft = -screenWidth * 0.2;
    final double blobWidth = screenWidth * 0.82;
    final double blobHeight = screenHeight * 0.83;

    // Spacing Constants
    final double horizontalPadding = screenWidth * 0.041;
    final double searchGap = screenHeight * 0.02;

    final double topSafeArea = MediaQuery.paddingOf(context).top;
    final double appBarHeight = kToolbarHeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,

      // --- UPDATED APP BAR ---
      appBar: NewsAppBar(
        scrollController: _scrollController,
      ),

      body: Stack(
        children: [
          // 1. Background Gradient Blob
          Positioned(
            top: blobTop,
            left: blobLeft,
            child: Container(
              width: blobWidth,
              height: blobHeight,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.senaryColor.withValues(alpha: 0.4),
                    AppColors.background.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.7],
                  center: Alignment.center,
                  radius: 0.8,
                ),
              ),
            ),
          ),

          // 2. Scrollable Content
          ScrollFog(
            scrollController: _scrollController,
            topFogHeight: 0,
            bottomFogHeight: screenHeight * 0.05,
            child: CustomScrollView(
              controller: _scrollController,
              // ignore: deprecated_member_use
              cacheExtent: screenHeight * 0.8,
              slivers: [
                // --- TOP SPACER ---
                SliverToBoxAdapter(
                  child: SizedBox(height: topSafeArea + appBarHeight + 10),
                ),

                // C. Search Bar
                SliverToBoxAdapter(
                  child: NewsSearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onClear: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                    hintText: l10n!.searchHint,
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: searchGap)),

                // D. Content List
                _buildContent(
                  newsService,
                  l10n,
                  screenWidth,
                  screenHeight,
                  horizontalPadding,
                ),

                SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 24.0)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    NewsService newsService,
    AppLocalizations l10n,
    double screenWidth,
    double screenHeight,
    double horizontalPadding,
  ) {
    final double itemSpacing = screenHeight * 0.01;

    if (newsService.state == NewsState.initial ||
        newsService.state == NewsState.loading) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        sliver: const SliverToBoxAdapter(
          key: ValueKey('loading'),
          child: ShimmerNewsList(),
        ),
      );
    }

    final articles = newsService.articles.where((article) {
      if (_searchQuery.isEmpty) return true;
      final title = article.titleFor(context).toLowerCase();
      final summary = article.summaryFor(context).toLowerCase();
      return title.contains(_searchQuery) || summary.contains(_searchQuery);
    }).toList();

    if (articles.isEmpty) {
      return SliverToBoxAdapter(
        key: const ValueKey('empty'),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, opacity, child) {
            return Opacity(
              opacity: opacity,
              child: child,
            );
          },
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.1),
              ErrorView(
                title: l10n.noFoundTitle,
                message: l10n.noFoundMessage,
              ),
            ],
          ),
        ),
      );
    }

    final bool isDesktop = screenWidth >= 800;

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: isDesktop
          ? SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double availableWidth = constraints.maxWidth;
                  // 3 items across, meaning 2 gaps. We subtract 2.1 gaps to prevent rounding overflow.
                  final double itemWidth =
                      (availableWidth - (itemSpacing * 2.1)) / 3.0;

                  return Wrap(
                    spacing: itemSpacing,
                    runSpacing: itemSpacing,
                    children: articles.map((article) {
                      final index = articles.indexOf(article);
                      return SizedBox(
                        width: itemWidth,
                        child: NewsArticleCard(
                          key: ValueKey(article.id),
                          article: article,
                          index: index,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final isLast = index == articles.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : itemSpacing),
                    child: NewsArticleCard(
                      key: ValueKey(articles[index].id),
                      article: articles[index],
                      index: index,
                    ),
                  );
                },
                childCount: articles.length,
              ),
            ),
    );
  }
}

// --- Firebase Image Loader & Error State ---
class FirebaseStorageImage extends StatefulWidget {
  final String imagePath;

  const FirebaseStorageImage({super.key, required this.imagePath});

  @override
  State<FirebaseStorageImage> createState() => _FirebaseStorageImageState();
}

class _FirebaseStorageImageState extends State<FirebaseStorageImage> {
  Future<String?>? _imageUrlFuture;
  static const String _getDownloadUrlEndpoint =
      "https://europe-west1-vertex-ai-1618.cloudfunctions.net/getCoverDownloadUrl";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _imageUrlFuture ??= _getCachedOrFetchDownloadUrl();
  }

  void _retry() {
    if (mounted) {
      setState(() {
        _imageUrlFuture = null;
      });
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
        final inMemoryUrls =
            CacheService.get<Map<String, String>>(CacheKey.newsImageUrls);
        if (inMemoryUrls?[widget.imagePath] != null) {
          return inMemoryUrls![widget.imagePath];
        }

        final prefs = await SharedPreferences.getInstance();
        final String cacheKey = 'news_image_url_${widget.imagePath}';
        final String? cachedDataJson = prefs.getString(cacheKey);
        if (cachedDataJson != null) {
          try {
            final Map<String, dynamic> cachedData = jsonDecode(cachedDataJson);
            if (DateTime.now().millisecondsSinceEpoch <
                (cachedData['expires'] as int)) {
              final String persistentUrl = cachedData['url'] as String;
              final currentInMemoryUrls = CacheService.get<Map<String, String>>(
                      CacheKey.newsImageUrls) ??
                  {};
              currentInMemoryUrls[widget.imagePath] = persistentUrl;
              CacheService.set(CacheKey.newsImageUrls, currentInMemoryUrls);
              return persistentUrl;
            }
          } catch (_) {}
        }

        if (!mounted) return null;
        final appInitializer =
            Provider.of<AppInitializer>(context, listen: false);
        final dio = Provider.of<Dio>(context, listen: false);

        await appInitializer.onCoreServicesReady;
        if (!mounted) return null;

        final user = await FirebaseAuth.instance.authStateChanges().first;
        if (user == null) return null;
        final idToken = await user.getIdToken();
        if (!mounted) return null;

        final response = await dio.post(
          _getDownloadUrlEndpoint,
          data: jsonEncode({
            'data': {'filePath': widget.imagePath}
          }),
          options: Options(headers: {
            "Authorization": "Bearer $idToken",
            "Content-Type": "application/json"
          }),
        );

        if (!mounted) return null;

        if (response.statusCode == 200 && response.data != null) {
          final newUrl = response.data['result']?['signedUrl'] as String?;
          if (newUrl != null) {
            final currentUrls =
                CacheService.get<Map<String, String>>(CacheKey.newsImageUrls) ??
                    {};
            currentUrls[widget.imagePath] = newUrl;
            CacheService.set(CacheKey.newsImageUrls, currentUrls);

            final expiryTime = DateTime.now()
                .add(const Duration(minutes: 8))
                .millisecondsSinceEpoch;
            await prefs.setString(
                cacheKey, jsonEncode({'url': newUrl, 'expires': expiryTime}));
          }
          return newUrl;
        }
        return null;
      }).timeout(const Duration(seconds: 25));
    } catch (e) {
      debugPrint("Failed to get image download URL: $e");
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
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          child = _ErrorState(key: const ValueKey('error'), onRetry: _retry);
        } else {
          child = CachedNetworkImage(
            key: ValueKey(snapshot.data!),
            imageUrl: snapshot.data!,
            fit: BoxFit.cover,
            memCacheHeight: 400,
            placeholder: (context, url) => const ShimmerPlaceholder(),
            errorWidget: (context, url, error) => _ErrorState(onRetry: _retry),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: SizedBox.expand(child: child),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final iconSize = screenWidth * 0.08;
    return Material(
      color: AppColors.border.withValues(alpha: 0.5),
      child: InkWell(
        onTap: onRetry,
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/warning.svg',
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(
                AppColors.primaryColor.inverted.withValues(alpha: 0.6),
                BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
