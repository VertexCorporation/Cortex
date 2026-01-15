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
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/fog.dart';
import 'package:cortex/news/search.dart';
import 'package:cortex/news/appbar.dart';
import '../../../../../cache.dart';
import '../../../../../initialization.dart';
import '../error.dart';
import 'cards.dart';
import 'data.dart';

/// An extension on the [NewsArticle] model to handle localization logic.
extension NewsArticleLocalization on NewsArticle {
  String titleFor(BuildContext context) {
    final languageCode = Localizations
        .localeOf(context)
        .languageCode;
    return title[languageCode] ?? title['en'] ?? '';
  }

  String summaryFor(BuildContext context) {
    final languageCode = Localizations
        .localeOf(context)
        .languageCode;
    return summary[languageCode] ?? summary['en'] ?? '';
  }

  String contentFor(BuildContext context) {
    final languageCode = Localizations
        .localeOf(context)
        .languageCode;
    return content[languageCode] ?? content['en'] ?? '';
  }

  String coverPathFor(BuildContext context) {
    final languageCode = Localizations
        .localeOf(context)
        .languageCode;
    final paths = coverImagePaths ?? {};
    return paths[languageCode] ?? paths['en'] ?? '';
  }
}

/// The main UI screen that displays the news feed with search and fog effects.
class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

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
    context.watch<ThemeProvider>();
    final newsService = Provider.of<NewsService>(context);
    final l10n = AppLocalizations.of(context);

    // Calculate dynamic dimensions based on screen size
    final Size screenSize = MediaQuery
        .of(context)
        .size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    // Dynamic layout constants
    final double blobTop = screenHeight * 0.12; // ~100px on 844h
    final double blobLeft = -screenWidth * 0.1; // ~-40px on 390w
    final double blobWidth = screenWidth * 0.82; // ~320px on 390w
    final double blobHeight = screenHeight * 0.83; // ~700px on 844h
    final double topSpacing = screenHeight * 0.015;
    final double searchGap = screenHeight * 0.012;
    final double fogTopHeight = screenHeight * 0.025;
    final double fogBottomHeight = screenHeight * 0.05;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NewsAppBar(
        title: l10n!.news,
      ),
      body: Stack(
        children: [
          // Dynamic Background Blob
          Positioned(
            top: blobTop,
            left: blobLeft,
            child: Container(
              width: blobWidth,
              height: blobHeight,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.senaryColor.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          ScrollFog(
            scrollController: _scrollController,
            fogColor: AppColors.background,
            topFogHeight: fogTopHeight,
            bottomFogHeight: fogBottomHeight,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  SizedBox(height: topSpacing),

                  NewsSearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onClear: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                    hintText: l10n.searchHint,
                  ),

                  SizedBox(height: searchGap),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    layoutBuilder: (Widget? currentChild,
                        List<Widget> previousChildren) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: <Widget>[
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    transitionBuilder: (Widget child,
                        Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: _buildContent(
                        newsService, l10n, screenWidth, screenHeight),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(NewsService newsService,
      AppLocalizations l10n,
      double screenWidth,
      double screenHeight) {
    // Dynamic horizontal padding (approx 4% of width)
    final double horizontalPadding = screenWidth * 0.041;
    final double itemSpacing = screenHeight * 0.01;

    switch (newsService.state) {
      case NewsState.initial:
      case NewsState.loading:
        return Padding(
          key: const ValueKey('loading'),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const ShimmerNewsList(),
        );

      case NewsState.success:
        final articles = newsService.articles.where((article) {
          if (_searchQuery.isEmpty) return true;
          final title = article.titleFor(context).toLowerCase();
          final summary = article.summaryFor(context).toLowerCase();
          return title.contains(_searchQuery) || summary.contains(_searchQuery);
        }).toList();

        if (articles.isNotEmpty) {
          return ListView.builder(
            key: ValueKey('list_${articles.length}_$_searchQuery'),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: itemSpacing),
                child: NewsArticleCard(
                  article: articles[index],
                  index: index,
                ),
              );
            },
          );
        } else {
          return Column(
            key: const ValueKey('empty'),
            children: [
              SizedBox(height: screenHeight * 0.15),
              ErrorView(
                title: l10n.noFoundTitle,
                message: l10n.noFoundMessage,
              ),
            ],
          );
        }
    }
  }
}

/// A widget to securely load and display an image from Firebase Storage.
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
        final inMemoryUrls = CacheService.get<Map<String, String>>(
            CacheKey.newsImageUrls);
        if (inMemoryUrls?[widget.imagePath] != null) {
          return inMemoryUrls![widget.imagePath];
        }

        final prefs = await SharedPreferences.getInstance();
        final String cacheKey = 'news_image_url_${widget.imagePath}';
        final String? cachedDataJson = prefs.getString(cacheKey);
        if (cachedDataJson != null) {
          try {
            final Map<String, dynamic> cachedData = jsonDecode(cachedDataJson);
            if (DateTime
                .now()
                .millisecondsSinceEpoch < (cachedData['expires'] as int)) {
              final String persistentUrl = cachedData['url'] as String;
              final currentInMemoryUrls = CacheService.get<Map<String, String>>(
                  CacheKey.newsImageUrls) ?? {};
              currentInMemoryUrls[widget.imagePath] = persistentUrl;
              CacheService.set(CacheKey.newsImageUrls, currentInMemoryUrls);
              return persistentUrl;
            }
          } catch (_) {}
        }

        if (!mounted) return null;
        final appInitializer = Provider.of<AppInitializer>(
            context, listen: false);
        final dio = Provider.of<Dio>(context, listen: false);

        await appInitializer.onCoreServicesReady;
        if (!mounted) return null;

        final user = await FirebaseAuth.instance
            .authStateChanges()
            .first;
        if (user == null) return null;
        final idToken = await user.getIdToken();
        if (!mounted) return null;

        final response = await dio.post(
          _getDownloadUrlEndpoint,
          data: jsonEncode({'data': {'filePath': widget.imagePath}}),
          options: Options(headers: {
            "Authorization": "Bearer $idToken",
            "Content-Type": "application/json"
          }),
        );

        if (!mounted) return null;

        if (response.statusCode == 200 && response.data != null) {
          final newUrl = response.data['result']?['signedUrl'] as String?;
          if (newUrl != null) {
            final currentUrls = CacheService.get<Map<String, String>>(
                CacheKey.newsImageUrls) ?? {};
            currentUrls[widget.imagePath] = newUrl;
            CacheService.set(CacheKey.newsImageUrls, currentUrls);

            final expiryTime = DateTime
                .now()
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
        } else
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
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

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: SizedBox.expand(child: child),
        );
      },
    );
  }
}

class _ErrorState extends StatefulWidget {
  final VoidCallback onRetry;

  const _ErrorState({super.key, required this.onRetry});

  @override
  State<_ErrorState> createState() => __ErrorStateState();
}

class __ErrorStateState extends State<_ErrorState> {
  bool _isRetrying = false;

  void _handleTap() {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      widget.onRetry();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic size for the error icon
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final iconSize = screenWidth * 0.08;

    Widget child;
    if (_isRetrying) {
      child = const ShimmerPlaceholder(key: ValueKey('retrying_shimmer'));
    } else {
      child = Center(
        key: const ValueKey('error_icon'),
        child: SvgPicture.asset(
          'assets/icons/warning.svg',
          width: iconSize,
          height: iconSize,
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: child,
        ),
      ),
    );
  }
}