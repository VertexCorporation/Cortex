// lib/apps/screen.dart
//
// Apps directory: connected apps, popular apps and category shelves from
// Fulcrum's Composio catalog, with a search field pinned to the bottom.

import 'dart:async';

import 'package:cortex/app.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/routes.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';

import 'categories.dart';
import 'controller.dart';
import 'detail.dart';
import 'logo.dart';
import 'models.dart';
import 'widgets.dart';

const double _maxContentWidth = 720;
const int _shelfSize = 4;

class AppsScreen extends StatefulWidget {
  const AppsScreen({super.key});

  @override
  State<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> with WidgetsBindingObserver {
  final AppsController _controller = AppsController.instance;
  final TextEditingController _search = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _debounce;
  String _query = '';
  List<CortexApp>? _remoteResults;
  bool _searching = false;
  int _searchGeneration = 0;

  String get _language => Localizations.localeOf(context).languageCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.load(language: _language);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.refreshAfterConnection();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    final query = value.trim();
    _debounce?.cancel();
    setState(() {
      _query = query;
      _remoteResults = null;
      _searching = query.length >= 2;
    });
    if (query.length < 2) return;
    final generation = ++_searchGeneration;
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final results = await _controller.search(query, language: _language);
        if (!mounted || generation != _searchGeneration) return;
        setState(() {
          _remoteResults = results;
          _searching = false;
        });
      } catch (_) {
        if (!mounted || generation != _searchGeneration) return;
        setState(() => _searching = false);
      }
    });
  }

  void _open(CortexApp app) {
    _searchFocus.unfocus();
    showAppDetail(context, app);
  }

  void _openList(String title, List<CortexApp> apps) {
    _searchFocus.unfocus();
    Navigator.of(context).push(SlideRightRoute(
      page: AppsListScreen(title: title, apps: apps),
    ));
  }

  List<CortexApp> _localMatches(List<CortexApp> apps) {
    final query = _query.toLowerCase();
    return apps
        .where((app) =>
            app.name.toLowerCase().contains(query) ||
            app.slug.contains(query) ||
            app.description.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            AppsTopBar(title: l10n.appsTitle),
            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => _query.isEmpty
                    ? _buildDirectory(l10n)
                    : _buildSearch(l10n),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxContentWidth + 160),
                  child: AppsSearchField(
                    controller: _search,
                    focusNode: _searchFocus,
                    hint: l10n.appsSearchHint,
                    onChanged: _onQueryChanged,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _centered(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final inset = constraints.maxWidth > _maxContentWidth + 40
            ? (constraints.maxWidth - _maxContentWidth) / 2
            : 20.0;
        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(inset, 8, inset, 24),
          children: children,
        );
      },
    );
  }

  Widget _buildDirectory(AppLocalizations l10n) {
    final apps = _controller.apps;
    if (apps.isEmpty && _controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (apps.isEmpty && _controller.error != null) {
      return _ErrorState(
        message: l10n.appsLoadError,
        retry: l10n.appsRetry,
        onRetry: () => _controller.load(language: _language, force: true),
      );
    }

    final installed = _controller.installed;
    final popular = apps.take(_shelfSize).toList();
    final shelves = <AppGroup, List<CortexApp>>{};
    for (final app in apps) {
      final group = AppGroup.forApp(app);
      if (group != null) (shelves[group] ??= []).add(app);
    }
    final orderedShelves = shelves.entries
        .where((entry) => entry.value.length >= 2)
        .toList()
      ..sort((a, b) {
        final bySize = b.value.length.compareTo(a.value.length);
        return bySize != 0 ? bySize : a.key.index.compareTo(b.key.index);
      });

    return RefreshIndicator(
      onRefresh: () => _controller.load(language: _language, force: true),
      child: _centered([
        if (installed.isNotEmpty) ...[
          AppsSectionHeader(
            title: l10n.appsInstalled,
            onTap: () => _openList(l10n.appsInstalled, installed),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: installed.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final app = installed[index];
                return Tooltip(
                  message: app.name,
                  child: InkWell(
                    onTap: () => _open(app),
                    borderRadius: BorderRadius.circular(16),
                    child: AppLogo(name: app.name, url: app.logo, size: 60),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
        ],
        AppsSectionHeader(
          title: l10n.appsPopular,
          onTap: () => _openList(l10n.appsPopular, apps.take(40).toList()),
        ),
        for (final app in popular) AppRow(app: app, onTap: () => _open(app)),
        for (final shelf in orderedShelves) ...[
          const SizedBox(height: 28),
          AppsSectionHeader(
            title: shelf.key.label(l10n),
            onTap: () => _openList(shelf.key.label(l10n), shelf.value),
          ),
          for (final app in shelf.value.take(_shelfSize))
            AppRow(app: app, onTap: () => _open(app)),
        ],
        const SizedBox(height: 28),
        AppsSectionHeader(
          title: l10n.appsAll,
          onTap: () => _openList(l10n.appsAll, apps),
        ),
        if (_controller.isLoading)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
      ]),
    );
  }

  Widget _buildSearch(AppLocalizations l10n) {
    final local = _localMatches(_controller.apps);
    final seen = <String>{};
    final results = <CortexApp>[
      for (final app in [...local, ...?_remoteResults])
        if (seen.add(app.slug)) _controller.resolve(app),
    ];

    if (results.isEmpty) {
      if (_searching) return const Center(child: CircularProgressIndicator());
      return Center(
        child: Text(
          l10n.appsNoResults,
          style: TextStyle(color: AppColors.tertiaryColor, fontSize: 15),
        ),
      );
    }

    return _centered([
      for (final app in results) AppRow(app: app, onTap: () => _open(app)),
      if (_searching)
        const Padding(
          padding: EdgeInsets.all(12),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
    ]);
  }
}

/// Full list for one shelf ("Popular", a category, installed apps…).
class AppsListScreen extends StatelessWidget {
  final String title;
  final List<CortexApp> apps;

  const AppsListScreen({super.key, required this.title, required this.apps});

  @override
  Widget build(BuildContext context) {
    final controller = AppsController.instance;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppsTopBar(title: title),
            Expanded(
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) => LayoutBuilder(
                  builder: (context, constraints) {
                    final inset = constraints.maxWidth > _maxContentWidth + 40
                        ? (constraints.maxWidth - _maxContentWidth) / 2
                        : 20.0;
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(inset, 8, inset, 24),
                      itemCount: apps.length,
                      itemBuilder: (context, index) {
                        final app = controller.resolve(apps[index]);
                        return AppRow(
                          app: app,
                          onTap: () => showAppDetail(context, app),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final String retry;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.retry,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.tertiaryColor),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: 15),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: Text(retry)),
          ],
        ),
      ),
    );
  }
}
