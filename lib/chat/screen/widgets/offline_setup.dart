import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/offline_setup.dart';
import 'package:cortex/chat/services/select.dart';
import 'package:cortex/funds/routing.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/library/backend/system.dart';
import 'package:cortex/library/providers/local.dart';
import 'package:cortex/main.dart';
import 'package:cortex/theme.dart';
import '../appbar/premium.dart';

Future<void> showOfflineSetup(BuildContext context) async {
  if (context.read<ConversationProvider>().messages.isNotEmpty) {
    handleUseOfflineAction(context);
    return;
  }
  FocusScope.of(context).unfocus();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppColors.background,
    builder: (_) => const OfflineSetupSheet(),
  );
}

class OfflineSetupSheet extends StatefulWidget {
  const OfflineSetupSheet({super.key});

  @override
  State<OfflineSetupSheet> createState() => _OfflineSetupSheetState();
}

class _OfflineSetupSheetState extends State<OfflineSetupSheet> {
  int _page = 0;
  int _generation = 0;
  bool _loading = false;
  bool _startingDownload = false;
  bool _downloadFailed = false;
  ModelEntity? _model;

  Future<void> _recommend() async {
    final generation = ++_generation;
    final service = context.read<ModelService>();
    final local = context.read<ModelLocalStateProvider>();
    final language = Localizations.localeOf(context).languageCode;
    setState(() { _page = 2; _loading = true; _model = null; });
    try {
      final device = await SystemInfoProvider.fetchSystemInfo();
      final catalogue = await service.getModels(langCode: language) ?? <ModelEntity>[];
      if (!mounted || generation != _generation) return;
      final candidates = <String, ModelEntity>{};
      for (final family in catalogue) {
        if (family.type == 'offline' && family.variants?.isNotEmpty != true) {
          candidates[family.id] = family;
        }
        for (final id in family.variants?.keys ?? const <String>[]) {
          final variant = service.getPreciseModelData(id, langCode: language);
          if (variant.type == 'offline') candidates[id] = variant;
        }
      }
      final installed = local.downloadCompleted.entries
          .where((entry) => entry.value && local.isModelOnDisk(local.getFilePathById(entry.key)))
          .map((entry) => entry.key).toSet();
      final model = recommendOfflineModel(
        models: candidates.values, device: device, installedIds: installed,
      );
      setState(() { _loading = false; _model = model; });
    } catch (_) {
      if (mounted && generation == _generation) setState(() { _loading = false; });
    }
  }

  void _openLibrary() {
    Navigator.pop(context);
    mainScreenKey.currentState?.switchToLibrary(pulse: true);
  }

  Future<void> _download() async {
    final model = _model;
    if (model == null || _startingDownload) return;
    setState(() { _startingDownload = true; _downloadFailed = false; });
    var started = false;
    try {
      started = await context.read<ModelLocalStateProvider>()
          .requestPermissionAndStartDownload(context: context, id: model.id, url: model.url);
    } catch (_) {
      // Keep the panel retryable if permission or download setup fails.
    } finally {
      if (mounted) {
        setState(() { _startingDownload = false; _downloadFailed = !started; });
      }
    }
  }

  void _useModel() {
    final model = _model;
    if (model == null) return;
    final local = context.read<ModelLocalStateProvider>();
    if (local.downloadCompleted[model.id] != true ||
        !local.isModelOnDisk(local.getFilePathById(model.id))) {
      return;
    }
    final input = context.read<InputProvider>();
    input.clearWebSearch();
    input.setFeatureMode(ChatInputMode.offline);
    context.read<SelectionService>().switchActiveModel(model, context: context);
    Navigator.pop(context);
  }

  @override
  void dispose() { _generation++; super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subscribed = context.select<ChatSessionProvider, bool>((s) => s.isUserSubscribed);
    final local = context.watch<ModelLocalStateProvider>();
    final model = _model;
    final manager = model == null ? null : local.downloadManagers[model.id];
    final ready = model != null && local.downloadCompleted[model.id] == true &&
        local.isModelOnDisk(local.getFilePathById(model.id));
    final missingRegisteredFile = model != null &&
        local.downloadCompleted[model.id] == true && !ready;
    final downloading = manager?.isDownloading == true;
    final paused = manager?.isPaused == true;
    final title = switch (_page) {
      0 => l10n.offlineSetupWelcome,
      1 => l10n.offlineSetupChoiceTitle,
      _ => _loading ? l10n.offlineSetupChecking : l10n.offlineSetupReadyTitle,
    };
    final description = switch (_page) {
      0 => l10n.offlineSetupWelcomeBody,
      1 => l10n.offlineSetupChoiceBody,
      _ => _loading ? l10n.offlineSetupCheckingBody
          : model == null ? l10n.offlineSetupNoMatch : l10n.offlineSetupReadyBody,
    };
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.65,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(children: [
            Row(children: [
              if (_page > 0) IconButton(
                onPressed: downloading || _startingDownload ? null : () {
                  _generation++;
                  setState(() { _page--; _loading = false; });
                }, icon: const Icon(Icons.arrow_back),
              ),
              const Spacer(),
              Text('${_page + 1} / 3'),
              IconButton(tooltip: l10n.cancel, onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close)),
            ]),
            Expanded(child: SingleChildScrollView(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Icon(_loading ? Icons.memory : Icons.offline_bolt_outlined, size: 48),
                const SizedBox(height: 20),
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(description, style: Theme.of(context).textTheme.bodyLarge),
                if (_page == 2 && _loading) const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24), child: LinearProgressIndicator()),
                if (_page == 2 && model != null) ...[
                  const SizedBox(height: 24),
                  ListTile(contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.smart_toy_outlined),
                    title: Text(model.displayTitle),
                    subtitle: Text('${model.size} MB • ${model.ram} MB RAM'),
                  ),
                  if (downloading) ...[
                    LinearProgressIndicator(value: (manager!.progress / 100).clamp(0, 1)),
                    Text(l10n.downloaded(manager.progress.round())),
                  ],
                  if (paused) Text(l10n.downloadPaused),
                  if (_downloadFailed && !downloading && !ready && !paused)
                    Text(l10n.downloadFailed),
                ],
              ],
            ))),
            const SizedBox(height: 16),
            if (_page == 1) Row(children: [
              Expanded(child: PremiumButton(label: l10n.offlineSetupChooseSpecific,
                height: 48, onTap: () {
                  if (subscribed) { _openLibrary(); } else {
                    openNextSubscriptionStep(context);
                  }
                })),
              const SizedBox(width: 12),
              Expanded(child: FilledButton(onPressed: _recommend,
                child: Text(l10n.offlineSetupContinue))),
            ]) else if (_page == 0) SizedBox(width: double.infinity,
              child: FilledButton(onPressed: () => setState(() { _page = 1; }),
                child: Text(l10n.offlineSetupContinue))),
            if (_page == 2 && !_loading)
              SizedBox(width: double.infinity, child: FilledButton(
                onPressed: _startingDownload || downloading ? null
                    : model == null || paused || missingRegisteredFile
                        ? _openLibrary : ready ? _useModel : _download,
                child: Text(model == null || paused || missingRegisteredFile ? l10n.offlineModels
                    : ready ? l10n.useOffline : downloading || _startingDownload
                        ? l10n.downloading : l10n.download),
              )),
          ]),
        ),
      ),
    );
  }
}
