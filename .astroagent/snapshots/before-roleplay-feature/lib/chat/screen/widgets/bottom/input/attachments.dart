part of 'input.dart';

// --- Multi-File Attachment Preview ---
class _AttachmentPreviewSection extends StatelessWidget {
  final double screenWidth;
  final bool isTablet;

  const _AttachmentPreviewSection(
      {required this.screenWidth, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final inputProvider = context.watch<InputProvider>();
    final attachments = inputProvider.attachments;

    final double itemSize = isTablet ? screenWidth * 0.15 : screenWidth * 0.20;
    // Reverted padding to standard
    final double padding = isTablet ? screenWidth * 0.02 : 12.0;

    return _AttachmentListWithFog(
      attachments: attachments,
      itemSize: itemSize,
      padding: padding,
      onRemove: (index) => inputProvider.removeAttachmentAt(index),
    );
  }
}

class _AttachmentListWithFog extends StatefulWidget {
  final List<InputAttachment> attachments;
  final double itemSize;
  final double padding;
  final Function(int) onRemove;

  const _AttachmentListWithFog({
    required this.attachments,
    required this.itemSize,
    required this.padding,
    required this.onRemove,
  });

  @override
  State<_AttachmentListWithFog> createState() => _AttachmentListWithFogState();
}

class _AttachmentListWithFogState extends State<_AttachmentListWithFog> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();
  late List<InputAttachment> _displayedItems;

  @override
  void initState() {
    super.initState();
    _displayedItems = List.from(widget.attachments);
  }

  @override
  void didUpdateWidget(_AttachmentListWithFog oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncList();
  }

  void _syncList() {
    final newItems = widget.attachments;

    if (newItems.length > _displayedItems.length) {
      for (int i = 0; i < newItems.length; i++) {
        if (i >= _displayedItems.length || newItems[i] != _displayedItems[i]) {
          _displayedItems.insert(i, newItems[i]);
          _listKey.currentState?.insertItem(i);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });

          if (newItems.length == _displayedItems.length) break;
        }
      }
    }
    else if (newItems.length < _displayedItems.length) {
      for (int i = 0; i < _displayedItems.length; i++) {
        if (i >= newItems.length || _displayedItems[i] != newItems[i]) {
          final removedItem = _displayedItems[i];
          _displayedItems.removeAt(i);
          _listKey.currentState?.removeItem(
            i,
            (context, animation) =>
                _buildItem(removedItem, animation, i, isRemoving: true),
            duration: const Duration(milliseconds: 300),
          );
          if (newItems.length == _displayedItems.length) break;
          i--; 
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildItem(
      InputAttachment attachment, Animation<double> animation, int index,
      {bool isRemoving = false}) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        axis: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _AttachmentItem(attachment: attachment, size: widget.itemSize),
              if (!isRemoving)
                Positioned(
                  top: widget.itemSize * 0.1,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => widget.onRemove(index),
                    child: Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2))
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: widget.attachments.isNotEmpty
            ? widget.itemSize + (widget.padding * 2)
            : 0,
        width: double.infinity,
        child: ScrollFogHorizontal(
          scrollController: _scrollController,
          child: AnimatedList(
            key: _listKey,
            controller: _scrollController,
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
                horizontal: widget.padding, vertical: widget.padding),
            initialItemCount: _displayedItems.length,
            itemBuilder: (context, index, animation) {
              if (index >= _displayedItems.length) {
                return const SizedBox.shrink();
              }
              return _buildItem(_displayedItems[index], animation, index);
            },
          ),
        ),
      ),
    );
  }
}

class _AttachmentItem extends StatelessWidget {
  final InputAttachment attachment;
  final double size;

  const _AttachmentItem({required this.attachment, required this.size});

  @override
  Widget build(BuildContext context) {
    if (attachment.type == AttachmentType.image) {
      return Container(
        width: size * 2.0, // Make it pill shaped (wider)
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0), // Fully rounded pill
          border: Border.all(color: AppColors.border.withValues(alpha: 0.2), width: 1.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100.0),
          child: Image.file(
            attachment.file,
            width: size * 2.0,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) =>
                Icon(Icons.broken_image, color: AppColors.tertiaryColor),
          ),
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.tertiaryColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getFileIcon(attachment.extension),
              size: size * 0.4,
              color: AppColors.primaryColor.inverted,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                attachment.extension.replaceAll('.', '').toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor.inverted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      );
    }
  }

  IconData _getFileIcon(String ext) {
    switch (ext) {
      case '.pdf':
        return Icons.picture_as_pdf_rounded;
      case '.doc':
      case '.docx':
        return Icons.description_rounded;
      case '.xls':
      case '.xlsx':
      case '.csv':
        return Icons.table_chart_rounded;
      case '.txt':
      case '.md':
        return Icons.text_snippet_rounded;
      case '.json':
      case '.xml':
      case '.html':
      case '.dart':
      case '.js':
      case '.py':
        return Icons.code_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}
