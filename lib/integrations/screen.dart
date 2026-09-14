import 'dart:async';
import 'dart:typed_data';

import 'package:cortex/app.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'model.dart';
import 'service.dart';
import 'strings.dart';

class IntegrationsScreen extends StatefulWidget {
  const IntegrationsScreen({super.key});

  @override
  State<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends State<IntegrationsScreen>
    with WidgetsBindingObserver {
  final _searchController = TextEditingController();
  final _service = IntegrationService.instance;

  IntegrationCatalogPage? _catalog;
  Timer? _debounce;
  bool _loading = true;
  bool _silentRefreshing = false;
  String? _error;
  String? _busySlug;

  static const _preferredCategories = <String>[
    'productivity',
    'developer-tools',
    'communication',
    'data-analytics',
    'design',
    'crm',
    'marketing',
    'sales',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted && _busySlug != null) {
      _busySlug = null;
      _load(silent: true);
    }
  }

  Future<void> _load({bool silent = false}) async {
    if (!mounted) return;
    setState(() {
      if (silent) {
        _silentRefreshing = true;
      } else {
        _loading = true;
      }
      _error = null;
    });

    try {
      final catalog = await _service.fetchCatalog(
        search: _searchController.text,
        limit: _searchController.text.trim().isEmpty ? 220 : 120,
      );
      if (!mounted) return;
      setState(() => _catalog = catalog);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = IntegrationStrings.of(context).error);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _silentRefreshing = false;
        });
      }
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), _load);
  }

  Future<void> _connect(IntegrationItem item) async {
    if (_busySlug != null) return;
    HapticFeedback.lightImpact();
    setState(() => _busySlug = item.slug);
    try {
      final uri = await _service.createConnection(item.slug);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) throw StateError('Could not open connection URL.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _busySlug = null);
      _showMessage(IntegrationStrings.of(context).error);
    }
  }

  Future<void> _disconnect(IntegrationItem item) async {
    final id = item.connectedAccountId;
    if (id == null || id.isEmpty || _busySlug != null) return;
    HapticFeedback.mediumImpact();
    setState(() => _busySlug = item.slug);
    try {
      await _service.disconnect(id);
      await _load(silent: true);
    } catch (_) {
      if (mounted) _showMessage(IntegrationStrings.of(context).error);
    } finally {
      if (mounted) setState(() => _busySlug = null);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openSettings() {
    final strings = IntegrationStrings.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.secondaryColor,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${strings.installed}: ${_catalog?.installed.length ?? 0}',
                  style: TextStyle(
                    color: AppColors.primaryColor.inverted,
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _load(silent: true);
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(strings.refresh),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = IntegrationStrings.of(context);
    final foreground = AppColors.primaryColor.inverted;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _RoundIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.maybePop(context),
                      ),
                    ),
                    Text(
                      strings.title,
                      style: TextStyle(
                        color: foreground,
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: _RoundIconButton(
                        icon: Icons.settings_outlined,
                        onTap: _openSettings,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(
                  color: foreground,
                  fontFamily: 'Inter',
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: strings.search,
                  hintStyle: TextStyle(
                    color: foreground.withValues(alpha: 0.45),
                    fontFamily: 'Inter',
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: foreground.withValues(alpha: 0.55),
                    size: 21,
                  ),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _load();
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: foreground.withValues(alpha: 0.55),
                            size: 19,
                          ),
                        ),
                  filled: true,
                  fillColor: AppColors.secondaryColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: foreground.withValues(alpha: 0.10),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: foreground.withValues(alpha: 0.22),
                    ),
                  ),
                ),
              ),
            ),
            if (_silentRefreshing)
              const LinearProgressIndicator(minHeight: 1),
            Expanded(child: _buildBody(strings)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(IntegrationStrings strings) {
    if (_loading && _catalog == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_error != null && _catalog == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryColor.inverted.withValues(alpha: 0.7),
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: _load, child: Text(strings.retry)),
            ],
          ),
        ),
      );
    }

    final catalog = _catalog;
    if (catalog == null) return const SizedBox.shrink();
    final query = _searchController.text.trim();

    return RefreshIndicator(
      onRefresh: () => _load(silent: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          if (query.isEmpty) ...[
            _SectionTitle(strings.installed),
            const SizedBox(height: 12),
            _InstalledStrip(
              items: catalog.installed,
              strings: strings,
              busySlug: _busySlug,
              onTap: _handleItemTap,
            ),
            const SizedBox(height: 28),
            _SectionTitle(strings.popular),
            const SizedBox(height: 8),
            ...catalog.items.take(12).map(
                  (item) => _IntegrationRow(
                    item: item,
                    strings: strings,
                    busy: _busySlug == item.slug,
                    onConnect: () => _connect(item),
                    onDisconnect: () => _disconnect(item),
                  ),
                ),
            ..._buildCategorySections(catalog.items, strings),
          ] else ...[
            ...catalog.items.map(
              (item) => _IntegrationRow(
                item: item,
                strings: strings,
                busy: _busySlug == item.slug,
                onConnect: () => _connect(item),
                onDisconnect: () => _disconnect(item),
              ),
            ),
            if (catalog.items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(
                  child: Text(
                    strings.search,
                    style: TextStyle(
                      color: AppColors.primaryColor.inverted.withValues(alpha: 0.45),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildCategorySections(
    List<IntegrationItem> items,
    IntegrationStrings strings,
  ) {
    final byCategory = <String, List<IntegrationItem>>{};
    final names = <String, String>{};

    for (final item in items) {
      for (final category in item.categories) {
        if (category.id.isEmpty) continue;
        names[category.id] = category.name;
        (byCategory[category.id] ??= <IntegrationItem>[]).add(item);
      }
    }

    final ordered = <String>[
      ..._preferredCategories.where(byCategory.containsKey),
      ...byCategory.keys.where((id) => !_preferredCategories.contains(id)),
    ].take(8);

    final widgets = <Widget>[];
    for (final id in ordered) {
      final sectionItems = byCategory[id]!;
      if (sectionItems.length < 2) continue;
      widgets
        ..add(const SizedBox(height: 26))
        ..add(_SectionTitle(strings.category(id, names[id] ?? id)))
        ..add(const SizedBox(height: 8))
        ..addAll(
          sectionItems.take(10).map(
                (item) => _IntegrationRow(
                  item: item,
                  strings: strings,
                  busy: _busySlug == item.slug,
                  onConnect: () => _connect(item),
                  onDisconnect: () => _disconnect(item),
                ),
              ),
        );
    }
    return widgets;
  }

  void _handleItemTap(IntegrationItem item) {
    if (item.connected) {
      _disconnect(item);
    } else {
      _connect(item);
    }
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final foreground = AppColors.primaryColor.inverted;
    return Material(
      color: AppColors.secondaryColor,
      shape: CircleBorder(
        side: BorderSide(color: foreground.withValues(alpha: 0.12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: foreground, size: 23),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.primaryColor.inverted,
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _InstalledStrip extends StatelessWidget {
  final List<IntegrationItem> items;
  final IntegrationStrings strings;
  final String? busySlug;
  final ValueChanged<IntegrationItem> onTap;

  const _InstalledStrip({
    required this.items,
    required this.strings,
    required this.busySlug,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        strings.emptyInstalled,
        style: TextStyle(
          color: AppColors.primaryColor.inverted.withValues(alpha: 0.48),
          fontFamily: 'Inter',
          fontSize: 13,
        ),
      );
    }

    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: busySlug == null ? () => onTap(item) : null,
            child: _IntegrationLogo(item: item, size: 48),
          );
        },
      ),
    );
  }
}

class _IntegrationRow extends StatelessWidget {
  final IntegrationItem item;
  final IntegrationStrings strings;
  final bool busy;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const _IntegrationRow({
    required this.item,
    required this.strings,
    required this.busy,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = AppColors.primaryColor.inverted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          _IntegrationLogo(item: item, size: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.connected
                      ? strings.connected
                      : strings.description(item.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground.withValues(alpha: 0.48),
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (busy)
            const SizedBox(
              width: 34,
              height: 34,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (item.connected)
            PopupMenuButton<String>(
              tooltip: strings.settings,
              color: AppColors.secondaryColor,
              icon: Icon(Icons.more_horiz_rounded, color: foreground, size: 22),
              onSelected: (value) {
                if (value == 'disconnect') onDisconnect();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'disconnect',
                  child: Text(strings.disconnect),
                ),
              ],
            )
          else
            IconButton(
              tooltip: strings.connect,
              onPressed: onConnect,
              icon: Icon(Icons.add_rounded, color: foreground, size: 25),
            ),
        ],
      ),
    );
  }
}

class _IntegrationLogo extends StatelessWidget {
  final IntegrationItem item;
  final double size;

  const _IntegrationLogo({required this.item, required this.size});

  @override
  Widget build(BuildContext context) {
    final foreground = AppColors.primaryColor.inverted;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(size * 0.24),
        border: Border.all(color: foreground.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: FutureBuilder<Uint8List?>(
        future: IntegrationService.instance.loadLogo(item.logo),
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes != null && bytes.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.all(size * 0.10),
              child: Image.memory(
                bytes,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
              ),
            );
          }
          final initial = item.name.trim().isEmpty
              ? '•'
              : item.name.trim().characters.first.toUpperCase();
          return Center(
            child: Text(
              initial,
              style: TextStyle(
                color: foreground,
                fontFamily: 'Inter',
                fontSize: size * 0.34,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        },
      ),
    );
  }
}
