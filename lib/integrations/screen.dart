import 'dart:async';

import 'package:cortex/app.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'logo.dart';
import 'model.dart';
import 'permission_store.dart';
import 'service.dart';
import 'strings.dart';

class IntegrationsScreen extends StatefulWidget {
  final String initialSearch;

  const IntegrationsScreen({
    super.key,
    this.initialSearch = '',
  });

  @override
  State<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends State<IntegrationsScreen>
    with WidgetsBindingObserver {
  late final TextEditingController _searchController;
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
    _searchController = TextEditingController(text: widget.initialSearch);
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
    setState(() {});
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
      await IntegrationPermissionStore.instance.clearToolkit(item.slug);
      await _load(silent: true);
    } catch (_) {
      if (mounted) _showMessage(IntegrationStrings.of(context).error);
    } finally {
      if (mounted) setState(() => _busySlug = null);
    }
  }

  Future<void> _manageInstalled(IntegrationItem item) async {
    if (!item.connected) {
      await _connect(item);
      return;
    }

    final removed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.secondaryColor,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _IntegrationManagementSheet(
        item: item,
        onDisconnect: () async {
          Navigator.of(context).pop(true);
        },
      ),
    );
    if (removed == true && mounted) {
      await _disconnect(item);
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
      builder: (sheetContext) => SafeArea(
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
                  Navigator.pop(sheetContext);
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
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
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
                            setState(() {});
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
          // Installed plugins are deliberately ALWAYS first, directly under
          // search, even while the user is searching the catalog.
          _SectionTitle(strings.installed),
          const SizedBox(height: 11),
          _InstalledStrip(
            items: catalog.installed,
            strings: strings,
            busySlug: _busySlug,
            onTap: _manageInstalled,
          ),
          const SizedBox(height: 26),
          if (query.isNotEmpty) ...[
            ...catalog.items.map(
              (item) => _IntegrationRow(
                item: item,
                strings: strings,
                busy: _busySlug == item.slug,
                onConnect: () => _connect(item),
                onManage: () => _manageInstalled(item),
              ),
            ),
            if (catalog.items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 54),
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
          ] else ...[
            _SectionTitle(strings.popular),
            const SizedBox(height: 8),
            ...catalog.items.take(12).map(
              (item) => _IntegrationRow(
                item: item,
                strings: strings,
                busy: _busySlug == item.slug,
                onConnect: () => _connect(item),
                onManage: () => _manageInstalled(item),
              ),
            ),
            ..._buildCategorySections(catalog.items, strings),
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
              onManage: () => _manageInstalled(item),
            ),
          ),
        );
    }
    return widgets;
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
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: busySlug == null ? () => onTap(item) : null,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IntegrationLogo(name: item.name, logoUrl: item.logo, size: 48),
                PositionedDirectional(
                  end: -2,
                  bottom: -2,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2FBF71),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                  ),
                ),
              ],
            ),
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
  final VoidCallback onManage;

  const _IntegrationRow({
    required this.item,
    required this.strings,
    required this.busy,
    required this.onConnect,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = AppColors.primaryColor.inverted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          IntegrationLogo(name: item.name, logoUrl: item.logo, size: 46),
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
                  item.connected ? strings.connected : strings.description(item.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground.withValues(alpha: 0.52),
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          if (busy)
            const SizedBox(
              width: 32,
              height: 32,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(strokeWidth: 1.7),
              ),
            )
          else
            IconButton(
              onPressed: item.connected ? onManage : onConnect,
              icon: Icon(
                item.connected ? Icons.more_horiz_rounded : Icons.add_rounded,
                color: foreground,
                size: 23,
              ),
            ),
        ],
      ),
    );
  }
}

class _IntegrationManagementSheet extends StatefulWidget {
  final IntegrationItem item;
  final Future<void> Function() onDisconnect;

  const _IntegrationManagementSheet({
    required this.item,
    required this.onDisconnect,
  });

  @override
  State<_IntegrationManagementSheet> createState() =>
      _IntegrationManagementSheetState();
}

class _IntegrationManagementSheetState
    extends State<_IntegrationManagementSheet> {
  Set<String>? _allowed;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final rules = await IntegrationPermissionStore.instance
        .alwaysAllowedTools(widget.item.slug);
    if (mounted) setState(() => _allowed = rules);
  }

  Future<void> _remove(String toolSlug) async {
    await IntegrationPermissionStore.instance.setAlwaysAllowed(
      widget.item.slug,
      toolSlug,
      allowed: false,
    );
    await _reload();
  }

  String _humanize(String slug) {
    final prefix = '${widget.item.slug.toUpperCase()}_';
    final value = slug.startsWith(prefix) ? slug.substring(prefix.length) : slug;
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0]}${part.substring(1).toLowerCase()}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final copy = _ManageStrings.of(context);
    final foreground = AppColors.primaryColor.inverted;
    final allowed = _allowed;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IntegrationLogo(
                  name: widget.item.name,
                  logoUrl: widget.item.logo,
                  size: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: TextStyle(
                          color: foreground,
                          fontFamily: 'Inter',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        copy.connected,
                        style: TextStyle(
                          color: foreground.withValues(alpha: 0.50),
                          fontFamily: 'Inter',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              copy.permissions,
              style: TextStyle(
                color: foreground,
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              copy.permissionsHint,
              style: TextStyle(
                color: foreground.withValues(alpha: 0.55),
                fontFamily: 'Inter',
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            if (allowed == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(strokeWidth: 1.7),
                ),
              )
            else if (allowed.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  copy.askEveryTime,
                  style: TextStyle(
                    color: foreground.withValues(alpha: 0.60),
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView(
                  shrinkWrap: true,
                  children: allowed
                      .map(
                        (tool) => SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: true,
                          onChanged: (_) => _remove(tool),
                          title: Text(
                            _humanize(tool),
                            style: TextStyle(
                              color: foreground,
                              fontFamily: 'Inter',
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(
                            copy.alwaysAllowed,
                            style: TextStyle(
                              color: foreground.withValues(alpha: 0.48),
                              fontFamily: 'Inter',
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onDisconnect,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.septenaryColor.withValues(alpha: 0.55),
                  ),
                  foregroundColor: AppColors.septenaryColor,
                ),
                child: Text(copy.disconnect),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageStrings {
  final String code;
  const _ManageStrings(this.code);

  factory _ManageStrings.of(BuildContext context) =>
      _ManageStrings(Localizations.localeOf(context).languageCode);

  bool get _tr => code == 'tr';
  String get connected => _tr ? 'Bağlı' : 'Connected';
  String get permissions => _tr ? 'İzinler' : 'Permissions';
  String get permissionsHint => _tr
      ? 'Her zaman izin verdiğin işlemleri buradan kapatabilirsin. Diğer işlemler çalışırken Cortex tekrar sorar.'
      : 'Turn off actions you previously allowed permanently. Cortex asks again for every other action.';
  String get askEveryTime => _tr
      ? 'Kalıcı izin yok. İşlem gerektiğinde Cortex senden izin isteyecek.'
      : 'No permanent permissions. Cortex will ask when an action is needed.';
  String get alwaysAllowed => _tr ? 'Her zaman izin verildi' : 'Always allowed';
  String get disconnect => _tr ? 'Bağlantıyı kaldır' : 'Disconnect';
}
