// conversations/tiles.dart

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:cortex/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../darkener.dart';
import '../overflow.dart';
import '../theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'manager.dart';

class ConversationTile extends StatefulWidget {
  final ConversationManager manager;
  final VoidCallback onDelete;
  final ValueChanged<String> onEdit;
  final VoidCallback onToggleStar;
  final bool hideWhenUnstarred;

  const ConversationTile({
    Key? key,
    required this.manager,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleStar,
    this.hideWhenUnstarred = false,
  }) : super(key: key);

  @override
  _ConversationTileState createState() => _ConversationTileState();
}

class _ConversationTileState extends State<ConversationTile>
    with TickerProviderStateMixin {
  final GlobalKey _threeDotKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  bool _isDisposed = false;
  Timer? _longPressTimer;
  bool _isLongPress = false;
  static _ConversationTileState? _currentlyOpenTileState;
  bool _isDialogOpen = false;

  String _displayedTitle = "";
  String _oldTitle = "";
  late AnimationController _fadeOutController;
  late AnimationController _fadeInController;
  bool _isTitleUpdated = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _displayedTitle = widget.manager.conversationTitle;
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
      if (!mounted) return;
      setState(() {});
    });
    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
      if (!mounted) return;
      setState(() {});
    });

    // --- THE PERFECT FIX ---
    // Add the listener that will rebuild the widget whenever the manager notifies of any change.
    widget.manager.addListener(_onManagerChanged);
  }

  // --- THE PERFECT FIX ---
  /// This listener is now robust. It handles title changes with animation
  /// and triggers a general rebuild for any other change (like imagePath or modelTitle).
  void _onManagerChanged() {
    // Handle animated title change specifically
    if (widget.manager.conversationTitle != _displayedTitle) {
      _isTitleUpdated = true;
      _fadeOutController.reset();
      _fadeInController.reset();
      _oldTitle = _displayedTitle;

      _fadeOutController.forward(from: 0).whenComplete(() {
        if (!mounted) return;
        setState(() {
          _displayedTitle = widget.manager.conversationTitle;
        });

        _fadeInController.forward(from: 0).whenComplete(() {
          if (!mounted) return;
          setState(() => _isTitleUpdated = false);
        });
      });
    }

    // This generic setState will handle all other changes from the manager,
    // such as the modelImagePath, modelTitle, lastMessageText, etc.
    // It's safe to call even if the title is already being handled above.
    if (mounted) {
      setState(() {});
    }
  }


  @override
  void dispose() {
    _isDisposed = true;
    _longPressTimer?.cancel();
    if (_currentlyOpenTileState == this) {
      _currentlyOpenTileState = null;
    }
    _overlayEntry?.remove();
    _overlayEntry = null;
    _fadeOutController.dispose();
    _fadeInController.dispose();

    // --- THE PERFECT FIX ---
    // Always remove the listener in dispose to prevent memory leaks.
    widget.manager.removeListener(_onManagerChanged);

    _animationController.dispose();
    super.dispose();
  }

  // ... (The rest of the file from _buildAnimatedTitleWidget onwards is perfect and remains unchanged) ...
  // ... I will include it for completeness.

  Widget _buildAnimatedTitleWidget() {
    final screenWidth = MediaQuery.of(context).size.width;
    TextStyle textStyle = GoogleFonts.poppins(
      fontSize: screenWidth * 0.045,
      fontWeight: FontWeight.w500,
      height: 1.2,
      color: AppColors.primaryColor.inverted,
    );

    if (_isTitleUpdated) {
      return Stack(
        children: [
          _buildAnimatedTitle(_oldTitle, _fadeOutController, true),
          _buildAnimatedTitle(_displayedTitle, _fadeInController, false),
        ],
      );
    }

    return OverflowText(
      text: _displayedTitle,
      style: textStyle,
      maxLines: 1,
      animation: AlwaysStoppedAnimation(1.0),
    );
  }

  void _removeOverlay({bool animate = true}) {
    if (_overlayEntry != null) {
      if (animate && !_isDisposed) {
        _animationController.reverse().then((_) {
          if (mounted) {
            _overlayEntry?.remove();
            _overlayEntry = null;
          }
          if (_currentlyOpenTileState == this) {
            _currentlyOpenTileState = null;
          }
        });
      } else {
        _overlayEntry?.remove();
        _overlayEntry = null;
        if (_currentlyOpenTileState == this) {
          _currentlyOpenTileState = null;
        }
      }
    }
  }

  Widget _buildAnimatedTitle(String text, AnimationController controller, bool reverse) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.045;
    final double lineHeight = 1.2;
    final double fixedHeight = fontSize * lineHeight;
    int n = text.length;
    double delayNormalized = n > 8 ? 0.8 / (n - 1) : 0.05;
    List<InlineSpan> spans = [];
    for (int i = 0; i < n; i++) {
      double start, end;
      if (reverse) {
        int j = n - 1 - i;
        start = j * delayNormalized;
        end = start + 0.2;
      } else {
        start = i * delayNormalized;
        end = start + 0.2;
      }
      double t = controller.value;
      double opacity;
      if (!reverse) {
        if (t < start)
          opacity = 0.0;
        else if (t > end)
          opacity = 1.0;
        else
          opacity = (t - start) / (end - start);
      } else {
        if (t < start)
          opacity = 1.0;
        else if (t > end)
          opacity = 0.0;
        else
          opacity = 1.0 - (t - start) / (end - start);
      }
      spans.add(TextSpan(
        text: text[i],
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          height: lineHeight,
          color: (AppColors.primaryColor.inverted).withOpacity(opacity),
        ),
      ));
    }
    Widget richTextWidget = SizedBox(
      height: fixedHeight,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          SizedBox(height: fixedHeight),
          RichText(
            text: TextSpan(children: spans),
            maxLines: 1,
            overflow: TextOverflow.clip,
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
          ),
        ],
      ),
    );
    return FadeTransition(
      opacity: controller,
      child: richTextWidget,
    );
  }

  void _showActionPanel() {
    if (_overlayEntry != null) return;
    if (_currentlyOpenTileState != null && _currentlyOpenTileState != this) {
      _currentlyOpenTileState?._removeOverlayWithAnimation();
      _currentlyOpenTileState = null;
    }
    final loc = AppLocalizations.of(context)!;
    final renderBox = _threeDotKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final double panelHeight = screenHeight * 0.2;
    final double panelWidth = screenWidth * 0.3;
    final bool openUpwards = (offset.dy + size.height + panelHeight + 20) > screenHeight;
    double panelTop = openUpwards ? (offset.dy - panelHeight) : (offset.dy + size.height);
    double panelRight = screenWidth - (offset.dx + size.width);
    final chatCardBackgroundColor = AppColors.quaternaryColor;
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _removeOverlayWithAnimation,
          onVerticalDragEnd: (_) => _removeOverlayWithAnimation(),
          child: Stack(
            children: [
              Positioned(
                top: panelTop,
                right: panelRight,
                child: FadeTransition(
                  opacity: _animationController,
                  child: ScaleTransition(
                    scale: _animationController,
                    alignment: openUpwards ? Alignment.bottomRight : Alignment.topRight,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.01,
                          horizontal: screenWidth * 0.02,
                        ),
                        decoration: BoxDecoration(
                            color: chatCardBackgroundColor,
                            borderRadius: BorderRadius.circular(screenWidth * 0.02),
                            border: Border.all(
                              color: AppColors.border,
                              width: 0.5,
                            )
                        ),
                        child: IntrinsicWidth(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: panelWidth),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _ActionPanelButton(
                                  iconAsset: widget.manager.isStarred
                                      ? 'assets/icons/star.svg'
                                      : 'assets/icons/starBordered.svg',
                                  iconColor: widget.manager.isStarred
                                      ? Colors.amber
                                      : AppColors.primaryColor.inverted,
                                  text: loc.starConversation,
                                  textColor: AppColors.primaryColor.inverted,
                                  onPressed: () async {
                                    await _removeOverlayWithAnimation();
                                    widget.onToggleStar();
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                _ActionPanelButton(
                                  iconAsset: 'assets/icons/edit.svg',
                                  iconColor: AppColors.primaryColor.inverted,
                                  text: loc.editConversationTitle,
                                  textColor: AppColors.primaryColor.inverted,
                                  onPressed: () {
                                    _showEditDialog(loc);
                                    _removeOverlay();
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                _ActionPanelButton(
                                  iconAsset: 'assets/icons/delete.svg',
                                  iconColor: Colors.red,
                                  text: loc.remove,
                                  textColor: Colors.red,
                                  onPressed: () {
                                    widget.onDelete();
                                    _removeOverlay();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
    _currentlyOpenTileState = this;
  }

  Future<void> _removeOverlayWithAnimation() async {
    if (_overlayEntry != null && !_isDisposed) {
      await _animationController.reverse();
      if (mounted) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
      if (_currentlyOpenTileState == this) {
        _currentlyOpenTileState = null;
      }
    }
  }

  Color darkenWithBlack(Color color, double factor) {
    assert(factor >= 0 && factor <= 1);
    final r = (color.red * (1.0 - factor)).round();
    final g = (color.green * (1.0 - factor)).round();
    final b = (color.blue * (1.0 - factor)).round();
    return Color.fromARGB(color.alpha, r, g, b);
  }

  void _showEditDialog(AppLocalizations loc) {
    if (_isDialogOpen) return;
    _isDialogOpen = true;
    final RestoreCallback restoreNavBar = Darkener.darken(factor: 0.5);
    final TextEditingController controller = TextEditingController(
      text: widget.manager.conversationTitle,
    );
    final screenWidth = MediaQuery.of(context).size.width;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "EditConversationTitle",
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return StatefulBuilder(
            builder: (context, setStateDialog) {
              String currentText = controller.text.trim();
              bool isChanged = currentText.isNotEmpty && currentText != widget.manager.conversationTitle;
              return Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: screenWidth * 0.8,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Column(
                            children: [
                              Text(
                                loc.editConversationTitle,
                                style: TextStyle(
                                  color: AppColors.primaryColor.inverted,
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenWidth * 0.04),
                              TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  labelText: loc.newTitle,
                                  labelStyle: TextStyle(
                                    color: AppColors.primaryColor.inverted,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.border,
                                    ),
                                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.primaryColor.inverted,
                                    ),
                                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                  ),
                                ),
                                style: TextStyle(
                                  color: AppColors.primaryColor.inverted,
                                ),
                                onChanged: (value) {
                                  setStateDialog(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: AppColors.quinaryColor,
                          thickness: 0.5,
                          height: 1,
                        ),
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    splashColor: AppColors.septenaryColor.withOpacity(0.1),
                                    highlightColor: AppColors.septenaryColor.withOpacity(0.1),
                                    onTap: () => Navigator.of(ctx).pop(),
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                                      child: Text(
                                        loc.cancel,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          color: AppColors.septenaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                color: AppColors.quinaryColor,
                                thickness: 0.5,
                                width: 1,
                              ),
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    splashColor: isChanged
                                        ? AppColors.senaryColor.withOpacity(0.1)
                                        : Colors.transparent,
                                    highlightColor: isChanged
                                        ? AppColors.senaryColor.withOpacity(0.1)
                                        : Colors.transparent,
                                    onTap: isChanged
                                        ? () {
                                      String newText = controller.text.trim();
                                      if (newText.isNotEmpty && newText != widget.manager.conversationTitle) {
                                        widget.onEdit(newText);
                                      }
                                      Navigator.of(ctx).pop();
                                    }
                                        : null,
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                                      child: AnimatedOpacity(
                                        duration: const Duration(milliseconds: 250),
                                        opacity: isChanged ? 1.0 : 0.5,
                                        child: Text(
                                          loc.save,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            color: AppColors.senaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
        );
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ).then((_) {
      restoreNavBar();
      _isDialogOpen = false;
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inHours <= 24) {
      return AppLocalizations.of(context)!.today;
    } else if (difference.inHours < 48) {
      return AppLocalizations.of(context)!.yesterday;
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  Widget _getLastMessageSnippet(String lastMessageText, String lastPhotoPath) {
    final screenWidth = MediaQuery.of(context).size.width;
    TextStyle messageStyle = TextStyle(
      color: AppColors.tertiaryColor,
      fontSize: screenWidth * 0.03,
    );
    if (lastPhotoPath.isNotEmpty) {
      if (lastMessageText.trim().isNotEmpty) {
        return Row(
          children: [
            SvgPicture.asset(
              'assets/icons/image.svg',
              width: screenWidth * 0.04,
              height: screenWidth * 0.04,
              color: AppColors.tertiaryColor,
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: OverflowText(
                text: lastMessageText,
                style: messageStyle,
                maxLines: 1,
              ),
            ),
          ],
        );
      } else {
        return Align(
          alignment: Alignment.centerLeft,
          child: SvgPicture.asset(
            'assets/icons/image.svg',
            width: screenWidth * 0.04,
            height: screenWidth * 0.04,
            color: AppColors.tertiaryColor,
          ),
        );
      }
    } else {
      return OverflowText(
        text: lastMessageText,
        style: messageStyle,
        maxLines: 1,
      );
    }
  }

  void _navigateToChatScreen() {
    mainScreenKey.currentState?.openConversation(widget.manager);
  }

  String formatExtension(String ext) {
    List<String> parts = ext.split('-');
    List<String> capitalizedParts = parts.map((s) {
      if (s.isEmpty) return s;
      return s[0].toUpperCase() + s.substring(1);
    }).toList();
    return capitalizedParts.join(" ");
  }

  Widget _buildImageWidget(String imagePath, double size) {
    if (imagePath.toLowerCase().endsWith('.svg')) {
      if (imagePath.startsWith('assets/')) {
        return SvgPicture.asset(
          imagePath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(
            AppColors.primaryColor.inverted,
            BlendMode.srcIn,
          ),
        );
      } else {
        final file = File(imagePath);
        if (file.existsSync()) {
          return SvgPicture.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.contain,
          );
        }
      }
    } else {
      if (imagePath.startsWith('assets/')) {
        return Image.asset(
          imagePath,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      } else {
        final file = File(imagePath);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
          );
        }
      }
    }

    return Icon(
      Icons.broken_image_outlined,
      color: AppColors.tertiaryColor,
      size: size * 0.6,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final Color backgroundColor = AppColors.quaternaryColor;

    // These values are now read on every build, ensuring they are always fresh.
    final String displayImagePath = widget.manager.modelImagePath;
    final String displayModelTitle = widget.manager.modelTitle;

    return GestureDetector(
      onTapDown: (_) {
        if (_overlayEntry != null) return;
        _isLongPress = false;
        _longPressTimer = Timer(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _isLongPress = true;
            });
            _showActionPanel();
          }
        });
      },
      onTapUp: (_) {
        if (_overlayEntry != null) return;
        _longPressTimer?.cancel();
      },
      onTapCancel: () {
        if (_overlayEntry != null) return;
        _longPressTimer?.cancel();
      },
      onTap: () {
        if (_overlayEntry != null) return;
        if (!_isLongPress) {
          _navigateToChatScreen();
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenHeight * 0.008,
        ),
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04, vertical: screenWidth * 0.03),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: screenWidth * 0.16,
                  height: screenWidth * 0.16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    color: AppColors.secondaryColor,
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: _buildImageWidget(displayImagePath, screenWidth * 0.16),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildAnimatedTitleWidget(),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.003),
                            child: Text(
                              _formatDate(widget.manager.lastMessageDate),
                              style: TextStyle(
                                color: AppColors.tertiaryColor.withOpacity(0.8),
                                fontSize: screenWidth * 0.03,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.001),
                      Text(
                        displayModelTitle,
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primaryColor.inverted.withOpacity(0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: screenHeight * 0.001),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _getLastMessageSnippet(
                              widget.manager.lastMessageText,
                              widget.manager.lastMessagePhotoPath,
                            ),
                          ),
                          GestureDetector(
                            key: _threeDotKey,
                            onTap: _showActionPanel,
                            child: Container(
                              child: Icon(
                                Icons.more_horiz_rounded,
                                size: screenWidth * 0.055,
                                color: AppColors.tertiaryColor.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionPanelButton extends StatelessWidget {
  final String? iconAsset;
  final Color iconColor;
  final String text;
  final Color textColor;
  final VoidCallback onPressed;

  const _ActionPanelButton({
    Key? key,
    this.iconAsset,
    required this.iconColor,
    required this.text,
    required this.textColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double defaultIconContainerSize = screenWidth * 0.05;
    final double iconSize = (iconAsset != null &&
        (iconAsset == 'assets/icons/star.svg' || iconAsset == 'assets/icons/starBordered.svg'))
        ? screenWidth * 0.04
        : defaultIconContainerSize;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.03,
          horizontal: screenWidth * 0.03,
        ),
        minimumSize: Size(0, screenWidth * 0.1),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (iconAsset != null)
            Container(
              width: defaultIconContainerSize,
              height: defaultIconContainerSize,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                iconAsset!,
                color: iconColor,
                width: iconSize,
                height: iconSize,
              ),
            ),
          SizedBox(width: screenWidth * 0.03),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: screenWidth * 0.035,
            ),
          ),
        ],
      ),
    );
  }
}