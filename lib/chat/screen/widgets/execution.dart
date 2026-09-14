import 'dart:io';

import 'package:cortex/design.dart';
import 'package:cortex/app.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../messages/codeblocks.dart';

class CodeExecutionWidget extends StatefulWidget {
  final Map<String, dynamic> data;

  const CodeExecutionWidget({super.key, required this.data});

  @override
  State<CodeExecutionWidget> createState() => _CodeExecutionWidgetState();
}

class _CodeExecutionWidgetState extends State<CodeExecutionWidget> {
  bool _isExpanded = true;

  bool get _isDocumentArtifact {
    final path = widget.data['artifact_path']?.toString() ?? '';
    return path.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (_isDocumentArtifact) {
      return _DocumentArtifactCard(data: widget.data);
    }

    final code = widget.data['code'] ?? '';
    final output = widget.data['output'] ?? '';
    final error = widget.data['error'];
    final bool hasError = error != null && error.toString().isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError
              ? AppColors.septenaryColor.withValues(alpha: 0.5)
              : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.terminal_rounded,
                    size: CortexDesign.icon,
                    color: hasError
                        ? AppColors.septenaryColor
                        : AppColors.tertiaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Python Code',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: hasError
                          ? AppColors.septenaryColor
                          : AppColors.primaryColor.inverted,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: CortexDesign.icon,
                    color: AppColors.tertiaryColor,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: CodeBlockWidget(
                          code: code,
                          language: 'python',
                        ),
                      ),
                      if (output.isNotEmpty || hasError) ...[
                        const Divider(height: 1),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OUTPUT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (hasError)
                                SelectableText(
                                  error.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                    color: Color(0xFFEF5350),
                                  ),
                                ),
                              if (output.isNotEmpty)
                                SelectableText(
                                  output.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                    color: Color(0xFFE0E0E0),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Reuses the existing `code_execution` widget channel for document files so
/// SendService can keep its stable widget protocol. The local path never goes
/// back to the online model: it is embedded only in the UI widget payload.
class _DocumentArtifactCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const _DocumentArtifactCard({required this.data});

  @override
  State<_DocumentArtifactCard> createState() => _DocumentArtifactCardState();
}

class _DocumentArtifactCardState extends State<_DocumentArtifactCard> {
  bool _sharing = false;

  IconData _iconFor(String format) {
    return switch (format.toLowerCase()) {
      'pdf' => Icons.picture_as_pdf_rounded,
      'xlsx' || 'csv' => Icons.table_chart_rounded,
      'pptx' => Icons.slideshow_rounded,
      'docx' => Icons.description_rounded,
      'json' => Icons.data_object_rounded,
      _ => Icons.insert_drive_file_rounded,
    };
  }

  Future<void> _share() async {
    if (_sharing) return;
    final path = widget.data['artifact_path']?.toString() ?? '';
    if (path.isEmpty) return;

    final file = File(path);
    if (!await file.exists()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document file is no longer available.')),
      );
      return;
    }

    setState(() => _sharing = true);
    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(path)]),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.data['file_name']?.toString() ?? 'Document';
    final format = widget.data['format']?.toString().toUpperCase() ?? 'FILE';
    final warning = widget.data['warning']?.toString();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.45),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _iconFor(format),
                  color: AppColors.primaryColor.inverted,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.primaryColor.inverted,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      format,
                      style: TextStyle(
                        color: AppColors.tertiaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Share / Save',
                onPressed: _sharing ? null : _share,
                icon: _sharing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.ios_share_rounded),
              ),
            ],
          ),
          if (warning != null && warning.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              warning,
              style: TextStyle(
                color: AppColors.tertiaryColor,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
