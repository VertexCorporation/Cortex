// lib/chat/news.dart (FINAL, FULLY FEATURED)

import 'package:cortex/cache.dart';
import 'package:cortex/main.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../initialization.dart';

/// Represents a single news article with full content for expansion.
class NewsArticle {
  final String id;
  final Map<String, String> title;
  final Map<String, String> summary;
  final Map<String, String> content; // NEW: Added full content for expandable card
  final String? link;
  final Map<String, String>? coverImagePaths;
  final DateTime publishedAt;

  NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.content, // NEW
    this.link,
    this.coverImagePaths,
    required this.publishedAt,
  });

  /// Factory constructor updated to parse the full 'content' field.
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final translations = json['translations'] as Map<String, dynamic>? ?? {};
    final Map<String, String> titleMap = {};
    final Map<String, String> summaryMap = {};
    final Map<String, String> contentMap = {}; // NEW

    translations.forEach((langCode, translationData) {
      if (translationData is Map<String, dynamic>) {
        titleMap[langCode] = translationData['title'] as String? ?? '';
        summaryMap[langCode] = translationData['summary'] as String? ?? '';
        contentMap[langCode] = translationData['content'] as String? ?? ''; // NEW
      }
    });

    final references = json['references'] as List<dynamic>?;
    String? link;
    if (references != null && references.isNotEmpty) {
      link = references.first as String?;
    }

    return NewsArticle(
      id: json['id'] ?? 'unknown_id',
      title: titleMap,
      summary: summaryMap,
      content: contentMap, // NEW
      link: link,
      coverImagePaths: json['cover'] != null ? Map<String, String>.from(json['cover']) : null,
      publishedAt: json['publishedAt'] != null ? DateTime.parse(json['publishedAt']) : DateTime.now(),
    );
  }

  /// Retrieves the localized string, defaulting to 'en' for any language other than 'tr'.
  String getLocalized(BuildContext context, Map<String, String> field) {
    final languageCode = Localizations.localeOf(context).languageCode;
    // CRITICAL FIX for language handling: Use 'tr' if available, otherwise default to 'en'.
    return field[languageCode] ?? field['en'] ?? '';
  }
}

/// A service class to handle fetching and caching news data.
/// Now includes a `forceRefresh` method to be called on language change.
class NewsService with ChangeNotifier {
  List<NewsArticle> _articles = [];
  List<NewsArticle> get articles => _articles;
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;
  static const String _cacheKey = 'news_cache_data_v3'; // Incremented version for new structure
  static const String _timestampKey = 'news_cache_timestamp_v3';
  final String _getCacheUrlEndpoint = "https://europe-west1-vertex-ai-1618.cloudfunctions.net/getNewsCacheUrl";

  /// Public method to force a reload of news, bypassing the 7-day cache.
  /// This should be called after a language change.
  Future<void> forceRefresh(BuildContext context) async { // <-- CONTEXT EKLE
    debugPrint("[NewsService] Force refresh triggered. Fetching fresh news data...");

    // Set loading state to ensure UI shows shimmer during the refresh.
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    final appInitializer = Provider.of<AppInitializer>(context, listen: false);
    await appInitializer.onCoreServicesReady;
    debugPrint("[NewsService] Core services are ready for force refresh.");

    await _fetchAndCacheNews();
  }

  /// This is the primary entry point for fetching news.
  /// It now requires a `BuildContext` to safely access the `AppInitializer`
  /// and ensure core services like Firebase are ready before proceeding.
  /// This method should be called from `initState` within a `WidgetsBinding.instance.addPostFrameCallback`.
  Future<void> loadNews(BuildContext context) async {
    // Prevent redundant fetches if data is already loaded or is currently loading.
    if (_articles.isNotEmpty || !_isLoading) return;

    // --- CRITICAL SAFETY LOCK ---
    // Await the signal from AppInitializer that core services are ready.
    // This prevents any race conditions with Firebase initialization.
    final appInitializer = Provider.of<AppInitializer>(context, listen: false);
    await appInitializer.onCoreServicesReady;
    debugPrint("[NewsService] Core services are ready. Proceeding to load news.");

    // Check SharedPreferences for valid cached data (within 7 days).
    final prefs = await SharedPreferences.getInstance();
    final lastFetchTimestamp = prefs.getInt(_timestampKey);
    if (lastFetchTimestamp != null) {
      final lastFetchDate = DateTime.fromMillisecondsSinceEpoch(lastFetchTimestamp);
      if (DateTime.now().difference(lastFetchDate).inDays < 7) {
        final cachedData = prefs.getString(_cacheKey);
        if (cachedData != null) {
          debugPrint("[NewsService] Loading news from valid cache.");
          _parseAndSetArticles(cachedData);
          _isLoading = false;
          notifyListeners();
          return; // Exit if loaded from cache
        }
      }
    }

    // If cache is invalid or missing, fetch from the network.
    debugPrint("[NewsService] Cache is invalid or missing. Fetching from network.");
    await _fetchAndCacheNews();
  }

  /// This private method now solely focuses on the network request logic.
  /// It can safely assume that Firebase is already initialized because the
  /// public `loadNews` method has already performed that check.
  Future<void> _fetchAndCacheNews() async {
    _error = null;
    try {
      // It's safe to access FirebaseAuth here.
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User is not authenticated for news fetch.");

      final idToken = await user.getIdToken();

      final urlResponse = await http.post(
          Uri.parse(_getCacheUrlEndpoint),
          headers: {
            "Authorization": "Bearer $idToken",
            "Content-Type": "application/json"
          },
          body: jsonEncode({'data': null})
      );

      if (urlResponse.statusCode != 200) {
        throw Exception("Failed to get cache URL. Status: ${urlResponse.statusCode}, Body: ${urlResponse.body}");
      }

      final jsonBody = jsonDecode(urlResponse.body);
      final String? signedUrl = jsonBody['result']?['signedUrl'];

      if (signedUrl == null) {
        throw Exception("Backend did not return a 'signedUrl'.");
      }

      final newsResponse = await http.get(Uri.parse(signedUrl));

      if (newsResponse.statusCode == 200) {
        final newsJsonString = utf8.decode(newsResponse.bodyBytes);
        _parseAndSetArticles(newsJsonString);

        // Save the fresh data and timestamp to cache.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, newsJsonString);
        await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
        debugPrint("[NewsService] Successfully fetched and cached new news data.");
      } else {
        throw Exception('Failed to load news content from signed URL. Status: ${newsResponse.statusCode}');
      }
    } catch (e) {
      _error = 'Could not fetch news updates.';
      debugPrint('[NewsService] An error occurred during fetch: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _parseAndSetArticles(String jsonString) {
    try {
      final List<dynamic> jsonData = json.decode(jsonString);
      _articles = jsonData.map((json) => NewsArticle.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      _error = 'Failed to display news.';
      _articles = [];
      debugPrint('[NewsService] Failed to parse articles: $e');
    }
  }
}

/// A widget to securely load and display an image from Firebase Storage using an in-memory cache.
class FirebaseStorageImage extends StatefulWidget {
  final String imagePath;
  const FirebaseStorageImage({super.key, required this.imagePath});
  @override
  State<FirebaseStorageImage> createState() => _FirebaseStorageImageState();
}

class _FirebaseStorageImageState extends State<FirebaseStorageImage> {
  Future<String?>? _imageUrlFuture;
  final String _getDownloadUrlEndpoint = "https://europe-west1-vertex-ai-1618.cloudfunctions.net/getCoverDownloadUrl";

  @override
  void initState() {
    super.initState();
    _imageUrlFuture = _getCachedOrFetchDownloadUrl();
  }

  Future<String?> _getCachedOrFetchDownloadUrl() async {
    // 1. CACHE CHECK: Immediately check our in-memory cache first.
    final cachedUrl = CacheService.cachedNewsImageUrls?[widget.imagePath];
    if (cachedUrl != null) return cachedUrl;

    final appInitializer = Provider.of<AppInitializer>(context, listen: false);
    await appInitializer.onCoreServicesReady;

    debugPrint("[FirebaseStorageImage] CACHE MISS. Fetching from network for: ${widget.imagePath}");
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = user == null ? null : await user.getIdToken();

      final response = await http.post(
        Uri.parse(_getDownloadUrlEndpoint),
        headers: {if (idToken != null) "Authorization": "Bearer $idToken", "Content-Type": "application/json"},
        body: jsonEncode({'data': {'filePath': widget.imagePath}}),
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final newUrl = jsonBody['result']?['signedUrl'] as String?;

        if (newUrl != null) {
          CacheService.cachedNewsImageUrls ??= {};
          CacheService.cachedNewsImageUrls![widget.imagePath] = newUrl;
          CacheService.startNewsImageCacheTimer();
        }
        return newUrl;
      }
      return null;
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
        if (snapshot.connectionState == ConnectionState.waiting) return const _ShimmerPlaceholder();
        if (!snapshot.hasData || snapshot.data == null) return Container(color: AppColors.border.withOpacity(0.5));
        return CachedNetworkImage(imageUrl: snapshot.data!, fit: BoxFit.cover, placeholder: (context, url) => const _ShimmerPlaceholder(), errorWidget: (context, url, error) => Container(color: AppColors.border.withOpacity(0.5), child: Icon(Icons.error_outline, color: AppColors.primaryColor.inverted.withOpacity(0.4))));
      },
    );
  }
}

/// Main widget to display a list of news articles.
class NewsSection extends StatelessWidget {
  const NewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // This widget now listens for locale changes to trigger a news refresh.
    // This is a robust way to handle language changes from settings.
    final locale = Localizations.localeOf(context);
    final newsService = Provider.of<NewsService>(context);

    // This is a bit advanced: we use a post-frame callback to avoid calling
    // a state-changing method during a build cycle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Logic to detect if a refresh is needed will be handled by listening
      // to the LocaleProvider higher up in the widget tree, like in chat.dart.
      // This Consumer is now just for displaying the data.
    });

    if (newsService.isLoading && newsService.articles.isEmpty) return const _ShimmerNewsList();
    if (newsService.error != null && newsService.articles.isEmpty) return const SizedBox.shrink();

    return Column(
      children: newsService.articles.map((article) => NewsArticleCard(article: article)).toList(),
    );
  }
}

/// A stateful card that displays a single news article and can be expanded.
/// FINAL VERSION with perfect ripple, advanced animations, and minimalist interaction.
class NewsArticleCard extends StatefulWidget {
  final NewsArticle article;
  const NewsArticleCard({super.key, required this.article});
  @override
  State<NewsArticleCard> createState() => _NewsArticleCardState();
}

class _NewsArticleCardState extends State<NewsArticleCard> {
  bool _isExpanded = false;

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  // --- REFINED TAP LOGIC FOR THE ICON ---
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
    final screenWidth = MediaQuery.of(context).size.width;
    final locale = Localizations.localeOf(context).toLanguageTag();

    final title = widget.article.getLocalized(context, widget.article.title);
    final summary = widget.article.getLocalized(context, widget.article.summary);
    final fullContent = widget.article.getLocalized(context, widget.article.content);
    final coverPath = widget.article.getLocalized(context, widget.article.coverImagePaths ?? {});

    final hasLink = widget.article.link != null && widget.article.link!.isNotEmpty;
    final hasExpandableContent = fullContent.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      // --- FINAL RIPPLE & INTERACTION FIX ---
      // A clean Material -> InkWell -> Content structure.
      // The InkWell now correctly handles both the ripple and the expansion toggle.
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias, // Ensures the ripple is clipped to the rounded corners.
        child: InkWell(
          onTap: hasExpandableContent ? _toggleExpansion : null, // The entire card toggles expansion.
          splashColor: AppColors.primaryColor.inverted.withOpacity(0.1),
          highlightColor: AppColors.primaryColor.inverted.withOpacity(0.05),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 350), // Slightly longer for a smoother feel.
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: Container(
              decoration: BoxDecoration(
                // No color here, Material provides it.
                // Border is now inside to not interfere with InkWell.
                border: Border.all(color: AppColors.border, width: 1.0),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (coverPath.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: FirebaseStorageImage(imagePath: coverPath),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted, height: 1.3),
                              ),
                            ),
                            if (hasLink)
                            // The link icon is now its own clickable button.
                              IconButton(
                                icon: Icon(Icons.touch_app, size: 20, color: AppColors.primaryColor.inverted.withOpacity(0.8)),
                                onPressed: _launchLink,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.yMd(locale).format(widget.article.publishedAt),
                          style: TextStyle(fontSize: screenWidth * 0.032, color: AppColors.primaryColor.inverted.withOpacity(0.6)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          summary,
                          style: TextStyle(fontSize: screenWidth * 0.038, color: AppColors.primaryColor.inverted.withOpacity(0.85), height: 1.5),
                        ),
                        // --- ADVANCED EXPANSION ANIMATION ---
                        // AnimatedSwitcher provides a beautiful fade/slide transition for the full content.
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, -0.1),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _isExpanded && hasExpandableContent
                              ? Padding(
                            key: ValueKey(widget.article.id), // Unique key for the switcher
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              fullContent,
                              style: TextStyle(fontSize: screenWidth * 0.038, color: AppColors.primaryColor.inverted.withOpacity(0.85), height: 1.5),
                            ),
                          )
                              : const SizedBox.shrink(key: ValueKey('empty')), // Switch to an empty box when collapsed
                        ),
                      ],
                    ),
                  ),
                  // The arrow button has been completely removed for a cleaner look.
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Shimmer widgets remain unchanged ---
class _ShimmerPlaceholder extends StatelessWidget {
  const _ShimmerPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(baseColor: AppColors.border.withOpacity(0.5), highlightColor: AppColors.border.withOpacity(0.2), child: Container(color: AppColors.border));
  }
}

class _ShimmerNewsList extends StatelessWidget {
  const _ShimmerNewsList();
  @override
  Widget build(BuildContext context) {
    return Column(children: List.generate(2, (index) => const _ShimmerNewsCard()));
  }
}

class _ShimmerNewsCard extends StatelessWidget {
  const _ShimmerNewsCard();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border, width: 1.0)),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
              child: AspectRatio(aspectRatio: 16 / 9, child: Shimmer.fromColors(baseColor: AppColors.border, highlightColor: AppColors.background, child: Container(color: Colors.white))),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerLine(context, 0.8, 18),
                  const SizedBox(height: 8),
                  _buildShimmerLine(context, 0.4, 12),
                  const SizedBox(height: 16),
                  _buildShimmerLine(context, 1.0, 14),
                  const SizedBox(height: 6),
                  _buildShimmerLine(context, 0.7, 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildShimmerLine(BuildContext context, double widthFactor, double height) {
    return Shimmer.fromColors(baseColor: AppColors.border, highlightColor: AppColors.background, child: Container(width: MediaQuery.of(context).size.width * widthFactor, height: height, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))));
  }
}