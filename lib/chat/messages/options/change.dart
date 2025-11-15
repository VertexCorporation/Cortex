import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/darkener.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../library/backend/data/entity.dart';
import '../../../library/backend/data/service.dart';
import '../../../library/backend/data/user.dart';

// --- UI Metrics (Constants) ---
class _UIFactors {
  static const double dialogWidthFactor = 0.70;
  static const double borderRadiusFactor = 0.03;
  static const double iconSizeFactor = 0.08;
  static const double titleFontSizeFactor = 0.04;
  static const double itemFontSizeFactor = 0.035;
  static const double maxContentHeightFactor = 0.3;
  static const double verticalSpacingFactor = 0.02;
  static const double smallVerticalSpacingFactor = 0.008;
  static const double itemVerticalSpacingFactor = 0.01;
  static const double buttonVerticalPaddingFactor = 0.016;
  static const double horizontalPaddingFactor = 0.02;
}


/// Displays a customized dialog for changing the active chat model.
///
/// This function is self-contained and handles the entire model selection and
/// regeneration flow. It fetches necessary state via Providers and, upon a
/// successful selection, invokes the provided `onRegenerate` callback.
///
/// [REFACTOR] The function now accepts the `onRegenerate` callback directly
/// and has a `void` return type, as it is responsible for triggering the
/// action itself rather than returning a value to the caller.
///
/// Parameters:
/// - `context`: The build context from which to show the dialog.
/// - `currentModelId`: The ID of the currently active model to pre-select.
/// - `onRegenerate`: The callback to execute with the newly selected model ID.
/// Displays a customized dialog for changing the active chat model.
Future<void> showModelSelectionDialog({
  required BuildContext context,
  required String currentModelId,
  required void Function({String? newModelId})? onRegenerate,
}) async {
  // --- 1. State Acquisition & langCode ---
  final session = context.read<ChatSessionProvider>();
  final conversation = context.read<ConversationProvider>();
  final l10n = AppLocalizations.of(context)!;
  final modelService = context.read<ModelService>();
  final langCode = Localizations.localeOf(context).languageCode;

  final bool isDynamicMode = session.isDynamicChat;
  final bool hasPhoto = conversation.messages.any((m) => m.photoPath != null);
  final bool hasPremiumAccess = session.isUserSubscribed || session.premiumTrialUses < 3;
  final Set<String> downloadedModelIds = (await UserModels.loadDownloadedModelPaths()).keys.toSet();

  // --- 2. Data Preparation ---
  final modelSeriesData = _findParentSeriesData(currentModelId, langCode: langCode, modelService: modelService);
  List<Map<String, dynamic>> itemsForDialog;

  if (isDynamicMode) {
    itemsForDialog = _buildCategorizedModelList(l10n, downloadedModelIds, langCode, modelService: modelService);
  } else if (modelSeriesData != null) {
    itemsForDialog = _buildExtensionList(modelSeriesData, langCode: langCode, modelService: modelService);
  } else {
    itemsForDialog = [];
  }

  // --- 3. Filtering ---
  final filteredItems = _filterDialogItems(
    items: itemsForDialog,
    hasPhoto: hasPhoto,
    hasPremiumAccess: hasPremiumAccess,
    langCode: langCode,
    modelService: modelService,
  );

  if (filteredItems.where((i) => i['isHeader'] != true).length < 2) {
    return;
  }

  String initialSelectedCode = currentModelId;
  if (!filteredItems.any((item) => item['code'] == initialSelectedCode)) {
    initialSelectedCode = filteredItems.firstWhere((i) => i['isHeader'] != true, orElse: () => {})['code'] as String? ?? '';
  }

  // --- 4. UI Presentation ---
  final restoreNavBar = Darkener.darken();
  String tempSelectedCode = initialSelectedCode;

  if (!context.mounted) return;
  final modalBarrierLabel = MaterialLocalizations.of(context).modalBarrierDismissLabel;

  final confirmed = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: modalBarrierLabel,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (dialogContext, _, __) {
      return _ModelSelectionDialogContent(
        title: l10n.changeModel,
        items: filteredItems,
        initialSelection: tempSelectedCode,
        onSelectionChanged: (newCode) => tempSelectedCode = newCode,
      );
    },
    transitionBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
  ).whenComplete(() {
    restoreNavBar();
  });

  // --- 5. Action Execution ---
  if (confirmed == true) {
    debugPrint("[Dialog] A model was selected: '$tempSelectedCode'. Firing onRegenerate.");
    onRegenerate?.call(newModelId: tempSelectedCode);
  } else {
    debugPrint("[Dialog] Dialog was cancelled or returned null.");
  }
}

// ===========================================================================
// SECTION: Private Helper Functions for Data Logic
// ===========================================================================

/// Finds the parent series data for a given model ID.
ModelEntity? _findParentSeriesData(String modelId, {required String langCode, required ModelService modelService}) {
  final allCachedModels = modelService.getCachedModelsSync();
  if (allCachedModels.isEmpty) return null;

  // First, check if the ID is a parent series itself
  try {
    return allCachedModels.firstWhere((model) => model.id == modelId);
  } catch (e) {
    // Not a direct match, check extensions
  }

  // If not, search within extensions
  for (final seriesEntity in allCachedModels) {
    if (seriesEntity.extensions?.containsKey(modelId) ?? false) {
      return seriesEntity;
    }
  }
  return null; // Not found
}

/// Formats a raw model ID string into a display-friendly format.
String _formatModelId(String rawText) {
  if (rawText.isEmpty) return "";
  String processedText = rawText.startsWith('google/') ? rawText.substring('google/'.length) : rawText;
  final parts = processedText.split('-').map((segment) {
    if (segment.isEmpty) return segment;
    if (segment.toLowerCase() == 'gb') return 'GB';
    return segment[0].toUpperCase() + segment.substring(1);
  }).toList();
  return parts.join(' ');
}

/// Builds the list of model extensions for Standard Mode.
List<Map<String, dynamic>> _buildExtensionList(ModelEntity modelSeries, {required String langCode, required ModelService modelService}) {
  final allExtensionsMap = modelSeries.extensions ?? {};
  final items = allExtensionsMap.entries.map((entry) {
    final data = entry.value as Map<String, dynamic>;
    return {
      'code': entry.key,
      'name': data['title'] as String? ?? _formatModelId(entry.key),
      'isPremium': (data['tier'] as String? ?? 'free') == 'premium',
      'canHandleImage': modelService.hasModality(entry.key, langCode: langCode, modality: 'image'),
    };
  }).toList();
  items.sort((a, b) => (a['name'] as String).toLowerCase().compareTo((b['name'] as String).toLowerCase()));
  return items;
}

/// Builds the categorized list of all models for Dynamic Mode.
List<Map<String, dynamic>> _buildCategorizedModelList(
    AppLocalizations l10n,
    Set<String> downloadedModelIds,
    String langCode, {
      required ModelService modelService,
    }) {
  final allModelSeries = modelService.getCachedModelsSync();
  final Map<String, List<ModelEntity>> categories = {
    'online': [], 'offline': [], 'roleplay': [], 'self': []
  };

  for (final series in allModelSeries) {
    if (series.type == 'offline') {
      if (downloadedModelIds.contains(series.id)) {
        categories['offline']!.add(series);
      }
    } else {
      final targetCategory = categories[series.category] ?? categories['online']!;
      if (series.extensions != null && series.extensions!.isNotEmpty) {
        for (final extId in series.extensions!.keys) {
          targetCategory.add(modelService.getPreciseModelData(extId, langCode: langCode));
        }
      } else {
        targetCategory.add(series);
      }
    }
  }

  int sorter(ModelEntity a, ModelEntity b) => a.displayTitle.toLowerCase().compareTo(b.displayTitle.toLowerCase());
  categories.forEach((_, list) => list.sort(sorter));

  final List<Map<String, dynamic>> assembledList = [];
  void addCategory(String title, List<ModelEntity> models) {
    if (models.isNotEmpty) {
      assembledList.add({'isHeader': true, 'name': title});
      assembledList.addAll(models.map((m) => {
        'code': m.id, 'name': m.displayTitle,
        'isPremium': m.isPremium,
        'canHandleImage': modelService.hasModality(m.id, langCode: langCode, modality: 'image'),
      }));
    }
  }

  addCategory(l10n.onlineModels, categories['online']!);
  addCategory(l10n.offlineModels, categories['offline']!);
  addCategory(l10n.characterModels, categories['roleplay']!);
  addCategory(l10n.customModels, categories['self']!);

  return assembledList;
}

/// Filters the list of dialog items based on the current chat context.
List<Map<String, dynamic>> _filterDialogItems({
  required List<Map<String, dynamic>> items,
  required bool hasPhoto,
  required bool hasPremiumAccess,
  required String langCode,
  required ModelService modelService,
}) {
  final filtered = items.where((item) {
    if (item['isHeader'] == true) return true;
    if ((item['isPremium'] == true) && !hasPremiumAccess) return false;
    final canHandleImage = modelService.hasModality(item['code'], langCode: langCode, modality: 'image');
    if (hasPhoto && !canHandleImage) return false;
    return true;
  }).toList();

  for (int i = filtered.length - 1; i >= 0; i--) {
    if (filtered[i]['isHeader'] == true) {
      if (i == filtered.length - 1 || filtered[i + 1]['isHeader'] == true) {
        filtered.removeAt(i);
      }
    }
  }
  return filtered;
}

// ===========================================================================
// SECTION: Private UI Widget for the Dialog Content
// (No changes below this line, implementation is correct)
// ===========================================================================

class _ModelSelectionDialogContent extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String initialSelection;
  final ValueChanged<String> onSelectionChanged;

  const _ModelSelectionDialogContent({
    required this.title,
    required this.items,
    required this.initialSelection,
    required this.onSelectionChanged,
  });

  @override
  State<_ModelSelectionDialogContent> createState() => _ModelSelectionDialogContentState();
}

class _ModelSelectionDialogContentState extends State<_ModelSelectionDialogContent> {
  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: screenWidth * _UIFactors.dialogWidthFactor,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(screenWidth * _UIFactors.borderRadiusFactor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * _UIFactors.borderRadiusFactor),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: screenHeight * _UIFactors.verticalSpacingFactor),
                SvgPicture.asset(
                  'assets/icons/extension.svg',
                  width: screenWidth * _UIFactors.iconSizeFactor,
                  height: screenWidth * _UIFactors.iconSizeFactor,
                  colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
                ),
                SizedBox(height: screenHeight * _UIFactors.smallVerticalSpacingFactor),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: screenWidth * _UIFactors.titleFontSizeFactor,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor.inverted,
                  ),
                ),
                Divider(thickness: 0.5, color: AppColors.border.withValues(alpha:0.5)),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: screenHeight * _UIFactors.maxContentHeightFactor),
                  child: RadioGroup<String>(
                    groupValue: _selectedCode,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCode = value);
                        widget.onSelectionChanged(value);
                      }
                    },
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: widget.items.length,
                      itemBuilder: (_, index) {
                        final item = widget.items[index];
                        if (item['isHeader'] == true) {
                          return Padding(
                            padding: EdgeInsets.only(
                              left: screenWidth * _UIFactors.horizontalPaddingFactor * 1.5,
                              top: screenHeight * _UIFactors.itemVerticalSpacingFactor * (index == 0 ? 0.5 : 1.5),
                              bottom: screenHeight * _UIFactors.itemVerticalSpacingFactor * 0.5,
                            ),
                            child: Text(
                              item['name'] as String,
                              style: TextStyle(
                                color: AppColors.tertiaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * _UIFactors.itemFontSizeFactor * 0.9,
                              ),
                            ),
                          );
                        }

                        final String itemCode = item['code'] as String;
                        return ListTile(
                          title: Text(
                            item['name'] as String,
                            style: TextStyle(
                              fontSize: screenWidth * _UIFactors.itemFontSizeFactor,
                              color: AppColors.primaryColor.inverted,
                            ),
                          ),
                          leading: Radio<String>(
                            value: itemCode,
                            activeColor: AppColors.primaryColor.inverted,
                          ),
                          onTap: () {
                            if (_selectedCode != itemCode) {
                              setState(() => _selectedCode = itemCode);
                              widget.onSelectionChanged(itemCode);
                            }
                          },
                          contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * _UIFactors.horizontalPaddingFactor),
                        );
                      },
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(true),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: screenHeight * _UIFactors.buttonVerticalPaddingFactor),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.border.withValues(alpha:0.5), width: 0.5)),
                    ),
                    child: Text(
                      l10n.changeModel,
                      style: TextStyle(
                        fontSize: screenWidth * _UIFactors.itemFontSizeFactor,
                        color: AppColors.senaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}