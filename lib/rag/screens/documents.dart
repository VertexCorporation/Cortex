// lib/rag/screens/document_library_screen.dart
//
// Full-screen document library for RAG ("Document Chat"):
// - Lists indexed documents with status (ready / indexing / failed).
// - Adds new documents via the system file picker and indexes them on-device.
// - Lets the user select documents for toggle-mode chat and enable/disable
//   document chat, syncing the choice into [InputProvider].

import 'dart:io';
import 'package:cortex/app.dart';
import 'package:cortex/appbar.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/rag/chat.dart';
import 'package:cortex/rag/models.dart';
import 'package:cortex/rag/provider.dart';
import 'package:cortex/theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DocumentLibraryScreen extends StatelessWidget {
  const DocumentLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DocumentLibraryScreenView();
  }
}

class _DocumentLibraryScreenView extends StatefulWidget {
  const _DocumentLibraryScreenView();

  @override
  State<_DocumentLibraryScreenView> createState() =>
      _DocumentLibraryScreenViewState();
}

class _DocumentLibraryScreenViewState
    extends State<_DocumentLibraryScreenView> {
  static const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ragProvider = context.read<RagProvider>();
      final inputProvider = context.read<InputProvider>();
      // Reflect the currently active document chat selection (if any).
      if (inputProvider.ragEnabled && inputProvider.ragDocumentIds.isNotEmpty) {
        ragProvider.setSelection(inputProvider.ragDocumentIds.toSet());
      }
      ragProvider.loadDocuments();
    });
  }

  void _onToggleSelection(String id) {
    final ragProvider = context.read<RagProvider>();
    ragProvider.toggleSelection(id);
    // Keep InputProvider in sync so live changes apply immediately while
    // document chat is already enabled.
    final inputProvider = context.read<InputProvider>();
    if (inputProvider.ragEnabled) {
      inputProvider.setRagDocuments(ragProvider.selectedDocumentIds.toList());
    }
  }

  // ---------------------------------------------------------------------
  // Adding documents
  // ---------------------------------------------------------------------

  Future<void> _addDocuments() async {
    final ragProvider = context.read<RagProvider>();
    final l10n = AppLocalizations.of(context)!;

    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: kRagDocumentExtensions.toList(),
        allowMultiple: true,
      );
    } catch (e) {
      debugPrint('[RagLibrary] pick failed: $e');
      return;
    }

    if (result == null || result.files.isEmpty) return;

    for (final picked in result.files) {
      final path = picked.path;
      if (path == null || path.isEmpty) continue;

      final ext = _extensionOf(path);
      if (!kRagDocumentExtensions.contains(ext)) {
        _showToast(l10n.ragUnsupportedType);
        continue;
      }

      final size = await File(path).length();
      if (size > _maxFileSizeBytes) {
        _showToast(l10n.ragFileTooBig);
        continue;
      }

      final doc = await ragProvider.indexFile(
        filePath: path,
        title: _stripExtension(picked.name),
      );
      if (doc == null) {
        _showToast(l10n.ragStatusFailed);
        continue;
      }

      // Auto-select freshly indexed documents so toggle mode is immediately
      // useful without an extra tap.
      if (!ragProvider.selectedDocumentIds.contains(doc.id)) {
        _onToggleSelection(doc.id);
      }
      _showToast(l10n.ragAddedToChat);
    }
  }

  // ---------------------------------------------------------------------
  // Deleting / re-indexing
  // ---------------------------------------------------------------------

  Future<void> _confirmDelete(RagDocument doc) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.secondaryColor,
        title: Text(
          l10n.ragDeleteConfirm,
          style: TextStyle(color: AppColors.primaryColor.inverted),
        ),
        content: Text(
          doc.title,
          style: TextStyle(
            color: AppColors.primaryColor.inverted.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: AppColors.primaryColor.inverted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.delete,
              style: const TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final ragProvider = context.read<RagProvider>();
    final inputProvider = context.read<InputProvider>();
    await ragProvider.removeDocument(doc.id);
    // Drop the deleted document from the active document chat selection.
    if (inputProvider.ragEnabled) {
      inputProvider.setRagDocuments(
        ragProvider.selectedDocumentIds.toList(),
      );
    }
  }

  void _reindex(RagDocument doc) {
    context.read<RagProvider>().indexFile(
          filePath: doc.filePath,
          title: doc.title,
        );
  }

  // ---------------------------------------------------------------------
  // Enable / disable chat
  // ---------------------------------------------------------------------

  void _applySelection() {
    final ragProvider = context.read<RagProvider>();
    final inputProvider = context.read<InputProvider>();
    final selected = ragProvider.selectedDocumentIds.toList();

    if (selected.isEmpty) return;

    inputProvider.setRagDocuments(selected);
    inputProvider.setRagEnabled(true);
    Navigator.of(context).pop();
  }

  void _disableChat() {
    context.read<InputProvider>().clearRag();
    Navigator.of(context).pop();
  }

  // ---------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ragProvider = context.watch<RagProvider>();
    final inputProvider = context.watch<InputProvider>();
    final documents = ragProvider.documents;
    final selectedIds = ragProvider.selectedDocumentIds;
    final isEnabled = inputProvider.ragEnabled;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CortexAppBar(
        leadingMode: CortexLeadingMode.back,
        titleText: l10n.ragScreenTitle,
        actions: [
          IconButton(
            onPressed: _addDocuments,
            tooltip: l10n.ragAddDocuments,
            icon: SvgPicture.asset(
              'assets/icons/add.svg',
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                AppColors.primaryColor.inverted,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ragProvider.isLoading && documents.isEmpty
                ? const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  )
                : documents.isEmpty
                    ? _EmptyState(
                        icon: SvgPicture.asset(
                          'assets/icons/attachment.svg',
                          width: 64,
                          height: 64,
                          colorFilter: ColorFilter.mode(
                            AppColors.primaryColor.inverted
                                .withValues(alpha: 0.2),
                            BlendMode.srcIn,
                          ),
                        ),
                        title: l10n.ragEmptyTitle,
                        description: l10n.ragEmptyDescription,
                        actionLabel: l10n.ragAddDocuments,
                        onAction: _addDocuments,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final doc = documents[index];
                          return _DocumentTile(
                            document: doc,
                            isSelected: selectedIds.contains(doc.id) &&
                                doc.status == RagDocumentStatus.indexed,
                            isIndexing: ragProvider.isIndexing(doc.filePath),
                            onTap: () {
                              if (doc.status != RagDocumentStatus.indexed) {
                                _reindex(doc);
                              } else {
                                _onToggleSelection(doc.id);
                              }
                            },
                            onDelete: () => _confirmDelete(doc),
                          );
                        },
                      ),
          ),
          if (documents.isNotEmpty)
            _BottomBar(
              selectedCount: selectedIds.length,
              isEnabled: isEnabled,
              onApply: _applySelection,
              onDisable: _disableChat,
            ),
        ],
      ),
    );
  }

  String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return '';
    return path.substring(dot + 1).toLowerCase();
  }

  String _stripExtension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    return dot > 0 ? fileName.substring(0, dot) : fileName;
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ));
  }
}

// ---------------------------------------------------------------------
// Document tile
// ---------------------------------------------------------------------

class _DocumentTile extends StatelessWidget {
  final RagDocument document;
  final bool isSelected;
  final bool isIndexing;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DocumentTile({
    required this.document,
    required this.isSelected,
    required this.isIndexing,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final inverted = AppColors.primaryColor.inverted;
    final ext = _extensionOf(document.filePath);
    final icon = _iconFor(ext);
    final color = inverted;

    final String statusText = switch (document.status) {
      RagDocumentStatus.pending => l10n.ragStatusIndexing,
      RagDocumentStatus.indexed => l10n.ragStatusReady,
      RagDocumentStatus.failed => l10n.ragStatusFailed,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isSelected
            ? AppColors.primaryColor.withValues(alpha: 0.08)
            : AppColors.primaryColor.withValues(alpha: 0.03),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected
                ? AppColors.primaryColor.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.title.isEmpty
                            ? l10n.ragEmptyTitle
                            : document.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: inverted,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_formatBytes(document.sizeBytes)} · $statusText',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: inverted.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isIndexing || document.status == RagDocumentStatus.pending)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (document.status == RagDocumentStatus.failed)
                  IconButton(
                    onPressed: onTap,
                    tooltip: l10n.ragStatusFailed,
                    icon: SvgPicture.asset(
                      'assets/icons/regenerate.svg',
                      width: 20,
                      height: 20,
                      colorFilter:
                          ColorFilter.mode(Colors.redAccent, BlendMode.srcIn),
                    ),
                  )
                else if (isSelected)
                  SvgPicture.asset(
                    'assets/icons/checkmark.svg',
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      AppColors.primaryColor,
                      BlendMode.srcIn,
                    ),
                  )
                else
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: inverted.withValues(alpha: 0.25),
                        width: 2,
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: onDelete,
                  tooltip: l10n.delete,
                  icon: SvgPicture.asset(
                    'assets/icons/delete.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      inverted.withValues(alpha: 0.45),
                      BlendMode.srcIn,
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

  String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return '';
    return path.substring(dot + 1).toLowerCase();
  }

  IconData _iconFor(String ext) {
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
      case 'csv':
      case 'tsv':
        return Icons.table_chart_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'txt':
      case 'md':
      case 'rtf':
        return Icons.article_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ---------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final Widget icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final inverted = AppColors.primaryColor.inverted;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: inverted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: inverted.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 22),
            _StadiumButton(label: actionLabel, onTap: onAction),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Bottom bar (selection + enable/disable)
// ---------------------------------------------------------------------

class _BottomBar extends StatelessWidget {
  final int selectedCount;
  final bool isEnabled;
  final VoidCallback onApply;
  final VoidCallback onDisable;

  const _BottomBar({
    required this.selectedCount,
    required this.isEnabled,
    required this.onApply,
    required this.onDisable,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final inverted = AppColors.primaryColor.inverted;
    final canApply = selectedCount > 0;

    final String label;
    if (isEnabled) {
      label = l10n.ragDisableChat;
    } else {
      label = l10n.ragEnableChat;
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.6),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                canApply
                    ? l10n.ragSelected(selectedCount)
                    : l10n.ragNoSelectionHint,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: inverted.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _StadiumButton(
              label: label,
              onTap: isEnabled ? onDisable : (canApply ? onApply : () {}),
              isEnabled: isEnabled || canApply,
              isDestructive: isEnabled,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Shared stadium button
// ---------------------------------------------------------------------

class _StadiumButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isEnabled;
  final bool isDestructive;

  const _StadiumButton({
    required this.label,
    required this.onTap,
    this.isEnabled = true,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final inverted = AppColors.primaryColor.inverted;

    return Material(
      color: !isEnabled
          ? inverted.withValues(alpha: 0.12)
          : isDestructive
              ? Colors.redAccent.withValues(alpha: 0.15)
              : inverted,
      shape: StadiumBorder(
        side: isDestructive
            ? BorderSide(color: Colors.redAccent.withValues(alpha: 0.6))
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: !isEnabled
                  ? inverted.withValues(alpha: 0.4)
                  : isDestructive
                      ? Colors.redAccent
                      : AppColors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
