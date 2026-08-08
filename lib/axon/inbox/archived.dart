import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/app.dart';
import 'package:cortex/chat/services/storage.dart';
import 'logic/general.dart';

class ArchivedConversationsDialog extends StatefulWidget {
  const ArchivedConversationsDialog({super.key});

  @override
  State<ArchivedConversationsDialog> createState() =>
      _ArchivedConversationsDialogState();
}

class _ArchivedConversationsDialogState
    extends State<ArchivedConversationsDialog> {
  List<Map<String, dynamic>> _archivedConversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArchivedConversations();
  }

  Future<void> _loadArchivedConversations() async {
    final results = await ChatStorageService.getArchivedConversations();
    if (mounted) {
      setState(() {
        _archivedConversations = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool isTablet = screenWidth > 600;
    final textColor = AppColors.primaryColor.inverted;

    return Dialog(
      backgroundColor: AppColors.secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 400 : screenWidth * 0.85,
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.archivedConversations,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: textColor.withValues(alpha: 0.6),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _archivedConversations.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            l10n.noArchivedConversations,
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _archivedConversations.length,
                          itemBuilder: (context, index) {
                            final conv = _archivedConversations[index];
                            final title = conv['title'] as String? ?? '';
                            final modelTitle =
                                conv['modelTitle'] as String? ?? '';

                            return ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              title: Text(
                                title,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                modelTitle,
                                style: TextStyle(
                                  color: textColor.withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.unarchive,
                                  color: textColor.withValues(alpha: 0.6),
                                ),
                                tooltip: l10n.unarchive,
                                onPressed: () async {
                                  final inboxViewModel =
                                      context.read<InboxViewModel>();
                                  await inboxViewModel.unarchiveConversation(
                                      conv['id'] as String);
                                  await _loadArchivedConversations();
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
