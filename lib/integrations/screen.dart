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

  Future<void> _reconnect(IntegrationItem item) async {
    if (_busySlug != null) return;
    final id = item.connectedAccountId;
    if (id == null || id.isEmpty) {
      await _connect(item);
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _busySlug = item.slug);
    try {
      // Reconnect is intentionally implemented with the already-existing
      // Cortex/Fulcrum endpoints: remove the old account, clear remembered
      // permissions, then open a fresh OAuth connection. No Fulcrum change is
      // required for this UI flow.
      await _service.disconnect(id);
      await IntegrationPermissionStore.instance.clearToolkit(item.slug);
      final uri = await _service.createConnection(item.slug);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) throw StateError('Could not open connection URL.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _busySlug = null);
      _showMessage(IntegrationStrings.of(context).error);
      await _load(silent: true);
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

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.secondaryColor,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _IntegrationManagementSheet(
        item: item,
        onReconnect: () => _reconnect(item),
        onDisconnect: () => _disconnect(item),
      ),
    );
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
          // Installed plugins always stay first, directly below search.
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
                  item.connected
                      ? strings.connected
                      : strings.description(item.name),
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
  final Future<void> Function() onReconnect;
  final Future<void> Function() onDisconnect;

  const _IntegrationManagementSheet({
    required this.item,
    required this.onReconnect,
    required this.onDisconnect,
  });

  @override
  State<_IntegrationManagementSheet> createState() =>
      _IntegrationManagementSheetState();
}

class _IntegrationManagementSheetState
    extends State<_IntegrationManagementSheet> {
  IntegrationPermissionMode? _mode;
  Set<String>? _allowed;
  bool _changing = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final store = IntegrationPermissionStore.instance;
    final mode = await store.modeForToolkit(widget.item.slug);
    final rules = await store.alwaysAllowedTools(widget.item.slug);
    if (!mounted) return;
    setState(() {
      _mode = mode;
      _allowed = rules;
    });
  }

  Future<void> _setMode(IntegrationPermissionMode mode) async {
    if (_changing || _mode == mode) return;
    setState(() => _changing = true);
    try {
      await IntegrationPermissionStore.instance.setMode(widget.item.slug, mode);
      await _reload();
      HapticFeedback.selectionClick();
    } finally {
      if (mounted) setState(() => _changing = false);
    }
  }

  Future<void> _reset() async {
    if (_changing) return;
    setState(() => _changing = true);
    try {
      await IntegrationPermissionStore.instance.resetToolkit(widget.item.slug);
      await _reload();
    } finally {
      if (mounted) setState(() => _changing = false);
    }
  }

  Future<void> _remove(String toolSlug) async {
    await IntegrationPermissionStore.instance.setAlwaysAllowed(
      widget.item.slug,
      toolSlug,
      allowed: false,
    );
    await _reload();
  }

  Future<void> _reconnect() async {
    Navigator.of(context).pop();
    await widget.onReconnect();
  }

  Future<void> _disconnect() async {
    Navigator.of(context).pop();
    await widget.onDisconnect();
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
    final mode = _mode;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          18,
          4,
          18,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
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
                      const SizedBox(height: 2),
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
            const SizedBox(height: 20),
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
            const SizedBox(height: 12),
            if (mode == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: CircularProgressIndicator(strokeWidth: 1.7),
                ),
              )
            else ...[
              _PermissionModeTile(
                selected: mode == IntegrationPermissionMode.askEveryTime,
                title: copy.askEveryTimeTitle,
                description: copy.askEveryTimeDescription,
                enabled: !_changing,
                onTap: () => _setMode(IntegrationPermissionMode.askEveryTime),
              ),
              const SizedBox(height: 3),
              _PermissionModeTile(
                selected: mode == IntegrationPermissionMode.allowRead,
                title: copy.allowReadTitle,
                description: copy.allowReadDescription,
                enabled: !_changing,
                onTap: () => _setMode(IntegrationPermissionMode.allowRead),
              ),
              const SizedBox(height: 3),
              _PermissionModeTile(
                selected: mode == IntegrationPermissionMode.allowAll,
                title: copy.allowAllTitle,
                description: copy.allowAllDescription,
                enabled: !_changing,
                onTap: () => _setMode(IntegrationPermissionMode.allowAll),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _changing ? null : _reset,
                  style: TextButton.styleFrom(
                    alignment: AlignmentDirectional.centerStart,
                    backgroundColor: AppColors.background,
                    foregroundColor: foreground,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: Text(
                    copy.reset,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                copy.resetHint,
                style: TextStyle(
                  color: foreground.withValues(alpha: 0.46),
                  fontFamily: 'Inter',
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
            if ((_allowed ?? const <String>{}).isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                copy.individualPermissions,
                style: TextStyle(
                  color: foreground,
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              ..._allowed!.map(
                (tool) => SwitchListTile.adaptive(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: true,
                  onChanged: (_) => _remove(tool),
                  title: Text(
                    _humanize(tool),
                    style: TextStyle(
                      color: foreground,
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                    ),
                  ),
                  subtitle: Text(
                    copy.alwaysAllowed,
                    style: TextStyle(
                      color: foreground.withValues(alpha: 0.45),
                      fontFamily: 'Inter',
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
            Text(
              copy.connection,
              style: TextStyle(
                color: foreground,
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _ConnectionAction(
              icon: Icons.sync_rounded,
              title: copy.reconnect,
              subtitle: copy.reconnectDescription,
              destructive: false,
              onTap: _reconnect,
            ),
            const SizedBox(height: 4),
            _ConnectionAction(
              icon: Icons.link_off_rounded,
              title: copy.disconnect,
              subtitle: copy.disconnectDescription,
              destructive: true,
              onTap: _disconnect,
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionModeTile extends StatelessWidget {
  final bool selected;
  final String title;
  final String description;
  final bool enabled;
  final VoidCallback onTap;

  const _PermissionModeTile({
    required this.selected,
    required this.title,
    required this.description,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = AppColors.primaryColor.inverted;
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(11),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: foreground,
                        fontFamily: 'Inter',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        color: foreground.withValues(alpha: 0.52),
                        fontFamily: 'Inter',
                        fontSize: 11.7,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: foreground.withValues(alpha: selected ? 0.92 : 0.48),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: foreground,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool destructive;
  final VoidCallback onTap;

  const _ConnectionAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.destructive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = destructive
        ? AppColors.septenaryColor
        : AppColors.primaryColor.inverted;
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(11),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: foreground, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: foreground,
                        fontFamily: 'Inter',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.primaryColor.inverted
                            .withValues(alpha: 0.46),
                        fontFamily: 'Inter',
                        fontSize: 11.5,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: foreground.withValues(alpha: 0.55),
                size: 20,
              ),
            ],
          ),
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

  Map<String, String> get _v => _values[code] ?? _values['en']!;
  String _get(String key) => _v[key] ?? _values['en']![key] ?? key;

  String get connected => _get('connected');
  String get permissions => _get('permissions');
  String get permissionsHint => _get('permissionsHint');
  String get askEveryTimeTitle => _get('askEveryTimeTitle');
  String get askEveryTimeDescription => _get('askEveryTimeDescription');
  String get allowReadTitle => _get('allowReadTitle');
  String get allowReadDescription => _get('allowReadDescription');
  String get allowAllTitle => _get('allowAllTitle');
  String get allowAllDescription => _get('allowAllDescription');
  String get reset => _get('reset');
  String get resetHint => _get('resetHint');
  String get individualPermissions => _get('individualPermissions');
  String get alwaysAllowed => _get('alwaysAllowed');
  String get connection => _get('connection');
  String get reconnect => _get('reconnect');
  String get reconnectDescription => _get('reconnectDescription');
  String get disconnect => _get('disconnect');
  String get disconnectDescription => _get('disconnectDescription');

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'connected': 'Connected',
      'permissions': 'Permissions',
      'permissionsHint': 'Choose when Cortex should ask before using this plugin.',
      'askEveryTimeTitle': 'Always ask',
      'askEveryTimeDescription': 'Cortex asks before reading or making changes.',
      'allowReadTitle': 'Allow reading actions',
      'allowReadDescription': 'Cortex may read without asking, but asks before changes.',
      'allowAllTitle': 'Allow all actions',
      'allowAllDescription': 'Cortex can use this plugin without asking each time.',
      'reset': 'Reset to default',
      'resetHint': 'Returns this plugin to asking before actions.',
      'individualPermissions': 'Individual permissions',
      'alwaysAllowed': 'Always allowed',
      'connection': 'Connection',
      'reconnect': 'Reconnect',
      'reconnectDescription': 'Replace the current connection with a fresh sign-in.',
      'disconnect': 'Disconnect',
      'disconnectDescription': 'Remove this account from Cortex.',
    },
    'tr': {
      'connected': 'Bağlı',
      'permissions': 'İzinler',
      'permissionsHint': 'Cortex bu eklentiyi kullanırken ne zaman izin istemesi gerektiğini seç.',
      'askEveryTimeTitle': 'Her zaman sor',
      'askEveryTimeDescription': 'Cortex okumadan veya değişiklik yapmadan önce sorar.',
      'allowReadTitle': 'Okuma işlemlerine izin ver',
      'allowReadDescription': 'Cortex sormadan okuyabilir, değişiklik yapmadan önce sorar.',
      'allowAllTitle': 'Tüm işlemlere izin ver',
      'allowAllDescription': 'Cortex bu eklentiyi her işlemde tekrar sormadan kullanabilir.',
      'reset': 'Varsayılana sıfırla',
      'resetHint': 'Bu eklentiyi işlemlerden önce tekrar izin isteyen varsayılan ayara döndürür.',
      'individualPermissions': 'Tek tek izinler',
      'alwaysAllowed': 'Her zaman izin verildi',
      'connection': 'Bağlantı',
      'reconnect': 'Yeniden bağla',
      'reconnectDescription': 'Mevcut bağlantıyı yenileyip tekrar giriş yap.',
      'disconnect': 'Bağlantıyı kes',
      'disconnectDescription': 'Bu hesabın Cortex bağlantısını kaldır.',
    },
    'de': {
      'connected': 'Verbunden', 'permissions': 'Berechtigungen', 'permissionsHint': 'Wähle, wann Cortex vor der Nutzung dieser Erweiterung fragen soll.', 'askEveryTimeTitle': 'Immer fragen', 'askEveryTimeDescription': 'Cortex fragt vor dem Lesen oder Ändern.', 'allowReadTitle': 'Lesezugriffe erlauben', 'allowReadDescription': 'Lesen ohne Nachfrage, Änderungen nur nach Bestätigung.', 'allowAllTitle': 'Alle Aktionen erlauben', 'allowAllDescription': 'Cortex kann diese Erweiterung ohne erneute Nachfrage verwenden.', 'reset': 'Auf Standard zurücksetzen', 'resetHint': 'Stellt das Nachfragen vor Aktionen wieder her.', 'individualPermissions': 'Einzelberechtigungen', 'alwaysAllowed': 'Immer erlaubt', 'connection': 'Verbindung', 'reconnect': 'Neu verbinden', 'reconnectDescription': 'Verbindung erneuern und erneut anmelden.', 'disconnect': 'Trennen', 'disconnectDescription': 'Dieses Konto von Cortex trennen.',
    },
    'es': {
      'connected': 'Conectado', 'permissions': 'Permisos', 'permissionsHint': 'Elige cuándo Cortex debe pedir permiso para usar este complemento.', 'askEveryTimeTitle': 'Preguntar siempre', 'askEveryTimeDescription': 'Cortex pregunta antes de leer o cambiar datos.', 'allowReadTitle': 'Permitir lectura', 'allowReadDescription': 'Puede leer sin preguntar, pero pide permiso antes de cambios.', 'allowAllTitle': 'Permitir todas las acciones', 'allowAllDescription': 'Cortex puede usar este complemento sin preguntar cada vez.', 'reset': 'Restablecer', 'resetHint': 'Vuelve a pedir permiso antes de las acciones.', 'individualPermissions': 'Permisos individuales', 'alwaysAllowed': 'Siempre permitido', 'connection': 'Conexión', 'reconnect': 'Volver a conectar', 'reconnectDescription': 'Renueva la conexión e inicia sesión de nuevo.', 'disconnect': 'Desconectar', 'disconnectDescription': 'Quita esta cuenta de Cortex.',
    },
    'fr': {
      'connected': 'Connecté', 'permissions': 'Autorisations', 'permissionsHint': 'Choisissez quand Cortex doit demander avant d’utiliser cette extension.', 'askEveryTimeTitle': 'Toujours demander', 'askEveryTimeDescription': 'Cortex demande avant de lire ou de modifier.', 'allowReadTitle': 'Autoriser la lecture', 'allowReadDescription': 'Lecture sans demande, confirmation avant toute modification.', 'allowAllTitle': 'Autoriser toutes les actions', 'allowAllDescription': 'Cortex peut utiliser cette extension sans demander à chaque fois.', 'reset': 'Réinitialiser', 'resetHint': 'Rétablit la demande avant les actions.', 'individualPermissions': 'Autorisations individuelles', 'alwaysAllowed': 'Toujours autorisé', 'connection': 'Connexion', 'reconnect': 'Reconnecter', 'reconnectDescription': 'Renouveler la connexion et se reconnecter.', 'disconnect': 'Déconnecter', 'disconnectDescription': 'Retirer ce compte de Cortex.',
    },
    'it': {
      'connected': 'Connesso', 'permissions': 'Autorizzazioni', 'permissionsHint': 'Scegli quando Cortex deve chiedere prima di usare questo plugin.', 'askEveryTimeTitle': 'Chiedi sempre', 'askEveryTimeDescription': 'Cortex chiede prima di leggere o modificare.', 'allowReadTitle': 'Consenti lettura', 'allowReadDescription': 'Può leggere senza chiedere, ma chiede prima delle modifiche.', 'allowAllTitle': 'Consenti tutte le azioni', 'allowAllDescription': 'Cortex può usare questo plugin senza chiedere ogni volta.', 'reset': 'Ripristina predefinito', 'resetHint': 'Ripristina la richiesta prima delle azioni.', 'individualPermissions': 'Autorizzazioni singole', 'alwaysAllowed': 'Sempre consentito', 'connection': 'Connessione', 'reconnect': 'Riconnetti', 'reconnectDescription': 'Rinnova la connessione e accedi di nuovo.', 'disconnect': 'Disconnetti', 'disconnectDescription': 'Rimuovi questo account da Cortex.',
    },
    'pt': {
      'connected': 'Ligado', 'permissions': 'Permissões', 'permissionsHint': 'Escolha quando o Cortex deve pedir autorização para usar este plugin.', 'askEveryTimeTitle': 'Perguntar sempre', 'askEveryTimeDescription': 'O Cortex pergunta antes de ler ou alterar.', 'allowReadTitle': 'Permitir leitura', 'allowReadDescription': 'Pode ler sem perguntar, mas pede antes de alterações.', 'allowAllTitle': 'Permitir todas as ações', 'allowAllDescription': 'O Cortex pode usar este plugin sem perguntar sempre.', 'reset': 'Repor predefinição', 'resetHint': 'Volta a pedir autorização antes das ações.', 'individualPermissions': 'Permissões individuais', 'alwaysAllowed': 'Sempre permitido', 'connection': 'Ligação', 'reconnect': 'Voltar a ligar', 'reconnectDescription': 'Renovar a ligação e iniciar sessão novamente.', 'disconnect': 'Desligar', 'disconnectDescription': 'Remover esta conta do Cortex.',
    },
    'ru': {
      'connected': 'Подключено', 'permissions': 'Разрешения', 'permissionsHint': 'Выберите, когда Cortex должен спрашивать разрешение.', 'askEveryTimeTitle': 'Всегда спрашивать', 'askEveryTimeDescription': 'Cortex спрашивает перед чтением или изменениями.', 'allowReadTitle': 'Разрешить чтение', 'allowReadDescription': 'Можно читать без вопроса, изменения требуют подтверждения.', 'allowAllTitle': 'Разрешить все действия', 'allowAllDescription': 'Cortex может использовать плагин без повторного вопроса.', 'reset': 'Сбросить', 'resetHint': 'Вернуть запрос разрешения перед действиями.', 'individualPermissions': 'Отдельные разрешения', 'alwaysAllowed': 'Всегда разрешено', 'connection': 'Подключение', 'reconnect': 'Переподключить', 'reconnectDescription': 'Обновить подключение и войти снова.', 'disconnect': 'Отключить', 'disconnectDescription': 'Удалить подключение этого аккаунта к Cortex.',
    },
    'ar': {
      'connected': 'متصل', 'permissions': 'الأذونات', 'permissionsHint': 'اختر متى يجب على Cortex طلب الإذن قبل استخدام الإضافة.', 'askEveryTimeTitle': 'اسأل دائمًا', 'askEveryTimeDescription': 'يسأل Cortex قبل القراءة أو إجراء تغييرات.', 'allowReadTitle': 'السماح بعمليات القراءة', 'allowReadDescription': 'يمكنه القراءة دون سؤال، ويطلب الإذن قبل التغييرات.', 'allowAllTitle': 'السماح بكل العمليات', 'allowAllDescription': 'يمكن لـ Cortex استخدام الإضافة دون السؤال في كل مرة.', 'reset': 'إعادة إلى الافتراضي', 'resetHint': 'يعيد طلب الإذن قبل العمليات.', 'individualPermissions': 'أذونات فردية', 'alwaysAllowed': 'مسموح دائمًا', 'connection': 'الاتصال', 'reconnect': 'إعادة الاتصال', 'reconnectDescription': 'تجديد الاتصال وتسجيل الدخول مرة أخرى.', 'disconnect': 'قطع الاتصال', 'disconnectDescription': 'إزالة هذا الحساب من Cortex.',
    },
    'ja': {
      'connected': '接続済み', 'permissions': '権限', 'permissionsHint': 'Cortex がこのプラグインを使う前に確認するタイミングを選びます。', 'askEveryTimeTitle': '常に確認', 'askEveryTimeDescription': '読み取りや変更の前に確認します。', 'allowReadTitle': '読み取りを許可', 'allowReadDescription': '読み取りは確認なし、変更前には確認します。', 'allowAllTitle': 'すべての操作を許可', 'allowAllDescription': '毎回確認せずにこのプラグインを使用できます。', 'reset': 'デフォルトに戻す', 'resetHint': '操作前に確認する設定へ戻します。', 'individualPermissions': '個別の権限', 'alwaysAllowed': '常に許可', 'connection': '接続', 'reconnect': '再接続', 'reconnectDescription': '接続を更新して再度ログインします。', 'disconnect': '切断', 'disconnectDescription': 'このアカウントを Cortex から切断します。',
    },
    'ko': {
      'connected': '연결됨', 'permissions': '권한', 'permissionsHint': 'Cortex가 이 플러그인을 사용하기 전에 언제 권한을 물을지 선택하세요.', 'askEveryTimeTitle': '항상 묻기', 'askEveryTimeDescription': '읽기 또는 변경 전에 묻습니다.', 'allowReadTitle': '읽기 작업 허용', 'allowReadDescription': '읽기는 묻지 않고, 변경 전에는 묻습니다.', 'allowAllTitle': '모든 작업 허용', 'allowAllDescription': '매번 묻지 않고 플러그인을 사용할 수 있습니다.', 'reset': '기본값으로 재설정', 'resetHint': '작업 전 다시 묻는 설정으로 돌아갑니다.', 'individualPermissions': '개별 권한', 'alwaysAllowed': '항상 허용됨', 'connection': '연결', 'reconnect': '다시 연결', 'reconnectDescription': '연결을 새로 하고 다시 로그인합니다.', 'disconnect': '연결 해제', 'disconnectDescription': '이 계정을 Cortex에서 연결 해제합니다.',
    },
    'zh': {
      'connected': '已连接', 'permissions': '权限', 'permissionsHint': '选择 Cortex 在使用此插件前何时需要询问。', 'askEveryTimeTitle': '始终询问', 'askEveryTimeDescription': '读取或更改前都会询问。', 'allowReadTitle': '允许读取操作', 'allowReadDescription': '读取无需询问，更改前仍会询问。', 'allowAllTitle': '允许所有操作', 'allowAllDescription': 'Cortex 可在不每次询问的情况下使用此插件。', 'reset': '恢复默认', 'resetHint': '恢复为操作前询问。', 'individualPermissions': '单项权限', 'alwaysAllowed': '始终允许', 'connection': '连接', 'reconnect': '重新连接', 'reconnectDescription': '更新连接并重新登录。', 'disconnect': '断开连接', 'disconnectDescription': '从 Cortex 移除此账户。',
    },
  };
}
