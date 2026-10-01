import 'dart:math' as math;
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/system.dart';

/// Automatic setup uses verified catalogue requirements, never model names.
/// Unknown device/model requirements require a manual choice instead.
ModelEntity? recommendOfflineModel({
  required Iterable<ModelEntity> models,
  required SystemInfoData device,
  Set<String> installedIds = const {},
}) {
  if (device.deviceMemory <= 0 || device.freeStorage < 0) return null;
  final freeMemory = device.usedMemory >= 0
      ? device.deviceMemory - device.usedMemory
      : device.deviceMemory * 0.55;
  final memoryBudget = math.min(device.deviceMemory * 0.7,
      math.max(0, freeMemory - 512));
  final candidates = models.where((model) {
    if (model.type != 'offline' || model.tier.toLowerCase() != 'free') return false;
    final ram = model.ram;
    final size = model.size;
    if (ram == null || ram <= 0 || size == null || size <= 0) return false;
    if (ram > memoryBudget) return false;
    if (installedIds.contains(model.id)) return true;
    final uri = Uri.tryParse(model.url ?? '');
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return false;
    return device.freeStorage >= size + (size * 0.1).clamp(100, 500);
  }).toList();
  candidates.sort((a, b) {
    // Reuse an installed model when suitable; avoid an unnecessary download.
    final installed = (installedIds.contains(b.id) ? 1 : 0)
        .compareTo(installedIds.contains(a.id) ? 1 : 0);
    if (installed != 0) return installed;
    final ram = b.ram!.compareTo(a.ram!);
    if (ram != 0) return ram;
    final size = b.size!.compareTo(a.size!);
    return size != 0 ? size : a.id.compareTo(b.id);
  });
  return candidates.isEmpty ? null : candidates.first;
}
