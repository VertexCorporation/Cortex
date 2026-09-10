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

class _AttachmentListWithFogState extends State<_AttachmentListWithFog>
    with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();
  late List<InputAttachment> _displayedItems;

  // The whole strip rides in on fade + motion together: one reveal clock
  // drives both the vertical grow and the opacity, while each item layers
  // its own fade + horizontal slide on top of that.
  late final AnimationController _revealController;
  late final Animation<double> _reveal;

  @override
  void initState() {
    super.initState();
    _displayedItems = List.from(widget.attachments);
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _reveal = CurvedAnimation(
        parent: _revealController, curve: Curves.easeOutCubic);
    // Mounting with content already in hand (a restored draft): show it
    // settled instead of replaying an entrance the user never saw begin.
    _revealController.value = widget.attachments.isNotEmpty ? 1.0 : 0.0;
  }

  /// Grows-and-fades the strip in when content appears, and back out when
  /// the list empties. Guarded like the composer's expand sync so a change
  /// mid-reveal simply retargets the same clock.
  void _syncReveal() {
    if (widget.attachments.isNotEmpty) {
      if (_revealController.status != AnimationStatus.forward &&
          _revealController.status != AnimationStatus.completed) {
        _revealController.forward();
      }
    } else {
      if (_revealController.status != AnimationStatus.reverse &&
          _revealController.status != AnimationStatus.dismissed) {
        _revealController.reverse();
      }
    }
  }

  @override
  void didUpdateWidget(_AttachmentListWithFog oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncList();
    _syncReveal();
  }

  void _syncList() {
    final newItems = widget.attachments;

    if (newItems.length > _displayedItems.length) {
      for (int i = 0; i < newItems.length; i++) {
        if (i >= _displayedItems.length || newItems[i] != _displayedItems[i]) {
          _displayedItems.insert(i, newItems[i]);
          _listKey.currentState?.insertItem(
            i,
            duration: const Duration(milliseconds: 200),
          );

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
    } else if (newItems.length < _displayedItems.length) {
      for (int i = 0; i < _displayedItems.length; i++) {
        if (i >= newItems.length || _displayedItems[i] != newItems[i]) {
          final removedItem = _displayedItems[i];
          _displayedItems.removeAt(i);
          _listKey.currentState?.removeItem(
            i,
            (context, animation) =>
                _buildItem(removedItem, animation, i, isRemoving: true),
            duration: const Duration(milliseconds: 200),
          );
          if (newItems.length == _displayedItems.length) break;
          i--;
        }
      }
    }
  }

  @override
  void dispose() {
    _revealController.dispose();
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
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.3),
                        ),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2))
                        ],
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: CortexDesign.icon,
                        color: AppColors.primaryColor.inverted,
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
    // SizeTransition + FadeTransition on one clock: the strip rises and
    // dissolves in together — and collapses and dissolves out together — so
    // it never pops or blinks at either end of the ride. The EdgeFogs below
    // are static strips, so they simply ride along with this reveal.
    return SizeTransition(
      key: const ValueKey('attachment_strip_reveal'),
      sizeFactor: _reveal,
      axis: Axis.vertical,
      child: FadeTransition(
        // Keyed for tests: the composer subtree already mounts several
        // FadeTransitions above this strip (idle overlays, the placeholder
        // fog) that an ancestor search would happily catch instead.
        key: const ValueKey('attachment_strip_fade'),
        opacity: _reveal,
        child: SizedBox(
          height: widget.attachments.isNotEmpty
              ? widget.itemSize + (widget.padding * 2)
              : 0,
          width: double.infinity,
          child: EdgeFog(
            startFogWidth: 24.0,
            endFogWidth: 24.0,
            // Static edge fogs: the strip's far ends dissolve into the bar
            // background even at rest, so a scrolled strip never reads as
            // hard-cut at the screen edge. The composer subtree mounts other
            // EdgeFogs with the shared default strip keys (the placeholder's,
            // the dictation wave's) — the strip claims its own pair.
            startStripKey: const ValueKey('attachment_fog_start'),
            endStripKey: const ValueKey('attachment_fog_end'),
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
      // Square 1:1 thumbnail (spec: unified preview) — the same footprint
      // the remove bubble is anchored to, themed like the composer.
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
              color: AppColors.border.withValues(alpha: 0.2), width: 1.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.file(
            attachment.file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => Icon(
                size: CortexDesign.icon,
                Icons.broken_image,
                color: AppColors.tertiaryColor),
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
              size: CortexDesign.icon,
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
