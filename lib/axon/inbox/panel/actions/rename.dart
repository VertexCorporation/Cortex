import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';

class ConversationRenameDialog extends StatefulWidget {
  const ConversationRenameDialog({super.key, required this.initialTitle});
  final String initialTitle;
  @override
  State<ConversationRenameDialog> createState() =>
      _ConversationRenameDialogState();
}

class _ConversationRenameDialogState extends State<ConversationRenameDialog> {
  late final TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: AppColors.secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border),
      ),
      title: Text(
        l10n.renameConversation,
        style: TextStyle(color: AppColors.primaryColor.inverted),
      ),
      content: Material(
        color: Colors.transparent,
        child: TextField(
          controller: _controller,
          autofocus: true,
          style: TextStyle(color: AppColors.primaryColor.inverted),
          decoration: InputDecoration(
            hintText: l10n.conversationName,
            hintStyle: TextStyle(
              color: AppColors.primaryColor.inverted.withValues(alpha: 0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor.inverted),
            ),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.of(context).pop(value.trim());
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.cancel,
            style: TextStyle(
              color: AppColors.primaryColor.inverted.withValues(alpha: 0.7),
            ),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryColor.inverted,
            foregroundColor: AppColors.primaryColor,
          ),
          onPressed: () {
            final value = _controller.text.trim();
            if (value.isNotEmpty) {
              Navigator.of(context).pop(value);
            }
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
