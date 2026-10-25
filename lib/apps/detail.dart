// lib/apps/detail.dart
//
// Bottom sheet for one app: connect / disconnect and the per-app permission
// that decides how Cortex may use it in chats.

import 'package:cortex/app.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';

import 'categories.dart';
import 'controller.dart';
import 'logo.dart';
import 'models.dart';

Future<void> showAppDetail(BuildContext context, CortexApp app) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.secondaryColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => AppDetailSheet(app: app),
  );
}

class AppDetailSheet extends StatefulWidget {
  final CortexApp app;

  const AppDetailSheet({super.key, required this.app});

  @override
  State<AppDetailSheet> createState() => _AppDetailSheetState();
}

class _AppDetailSheetState extends State<AppDetailSheet> {
  final AppsController _controller = AppsController.instance;
  bool _busy = false;

  void _toast(String message) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ));
  }

  Future<void> _connect(CortexApp app) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await _controller.connect(app);
    } catch (_) {
      if (mounted) _toast(l10n.appsConnectFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnect(CortexApp app) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.secondaryColor,
        content: Text(
          l10n.appsDisconnectConfirm(app.name),
          style: TextStyle(color: AppColors.primaryColor.inverted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.appsDisconnect,
              style: const TextStyle(color: Color(0xFFE5484D)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await _controller.disconnect(app);
    } catch (_) {
      if (mounted) _toast(l10n.appsDisconnectFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setPermission(CortexApp app, AppPermission permission) async {
    if (app.permission == permission) return;
    final l10n = AppLocalizations.of(context)!;
    try {
      await _controller.setPermission(app.slug, permission);
    } catch (_) {
      if (mounted) _toast(l10n.appsPermissionSaveFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final app = _controller.resolve(widget.app);
        final text = AppColors.primaryColor.inverted;
        final muted = AppColors.tertiaryColor;
        final awaiting = _controller.awaitingConnection == app.slug;
        final groups = <String>{
          for (final category in app.categories)
            AppGroup.of(category)?.label(l10n) ?? category.name,
        }.where((label) => label.isNotEmpty).take(3).toList();

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: app.connected ? 0.82 : 0.56,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: muted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  AppLogo(name: app.name, url: app.logo, size: 68),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.name,
                          style: TextStyle(
                            color: text,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            if (app.connected) l10n.appsConnected,
                            if (app.toolsCount > 0)
                              l10n.appsActionsCount(app.toolsCount),
                          ].join(' · '),
                          style: TextStyle(color: muted, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (app.description.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  app.description,
                  style: TextStyle(color: text, fontSize: 15, height: 1.4),
                ),
              ],
              if (groups.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final label in groups)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(label,
                            style: TextStyle(color: muted, fontSize: 13)),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 22),
              SizedBox(
                height: 50,
                child: app.connected
                    ? OutlinedButton(
                        onPressed: _busy ? null : () => _disconnect(app),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE5484D),
                          side: BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: _busy
                            ? const _Spinner()
                            : Text(l10n.appsDisconnect,
                                style: const TextStyle(fontSize: 16)),
                      )
                    : FilledButton(
                        onPressed: _busy ? null : () => _connect(app),
                        style: FilledButton.styleFrom(
                          backgroundColor: text,
                          foregroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: _busy
                            ? const _Spinner()
                            : Text(l10n.appsConnect,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
              ),
              if (!app.connected) ...[
                const SizedBox(height: 12),
                Text(
                  awaiting
                      ? l10n.appsConnectBrowserHint(app.name)
                      : l10n.appsConnectToUse(app.name),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 13, height: 1.4),
                ),
              ],
              if (app.connected) ...[
                const SizedBox(height: 26),
                Text(
                  l10n.appsPermissions,
                  style: TextStyle(
                    color: text,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                for (final permission in AppPermission.values)
                  _PermissionTile(
                    permission: permission,
                    selected: app.permission == permission,
                    onTap: () => _setPermission(app, permission),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
}

class _PermissionTile extends StatelessWidget {
  final AppPermission permission;
  final bool selected;
  final VoidCallback onTap;

  const _PermissionTile({
    required this.permission,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (title, description, icon) = switch (permission) {
      AppPermission.ask => (
          l10n.appsPermissionAsk,
          l10n.appsPermissionAskDescription,
          Icons.front_hand_outlined,
        ),
      AppPermission.allow => (
          l10n.appsPermissionAllow,
          l10n.appsPermissionAllowDescription,
          Icons.bolt_rounded,
        ),
      AppPermission.readOnly => (
          l10n.appsPermissionReadOnly,
          l10n.appsPermissionReadOnlyDescription,
          Icons.visibility_outlined,
        ),
      AppPermission.off => (
          l10n.appsPermissionOff,
          l10n.appsPermissionOffDescription,
          Icons.block_rounded,
        ),
    };
    final accent = AppColors.senaryColor;
    final text = AppColors.primaryColor.inverted;
    final muted = AppColors.tertiaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? accent : AppColors.border,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: selected ? accent : muted, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                            color: text,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 2),
                      Text(description,
                          style: TextStyle(
                              color: muted, fontSize: 13, height: 1.35)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? accent : muted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
