// chat/screen/selected/input/input.dart

import 'dart:io';
import 'package:cortex/app.dart';
import 'package:cortex/chat/screen/selected/input/buttons.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../internet.dart';
import '../../../../notifications.dart';
import '../../../../theme.dart';
import 'package:cortex/l10n/app_localizations.dart';

/// A widget that represents the chat input area including
/// a text field for message input, photo selection with preview,
/// and the action buttons (send / add photo).
///
/// This widget supports editing mode by detecting changes in both
/// the message text and photo. It uses a comparison that factors in:
///   - The presence or absence of content,
///   - Whether the text has been altered (via the [originalMessageText])
///   - Whether the photo has changed. The photo comparison includes a check for:
///       • File path differences,
///       • File size differences,
///       • Differences in the file’s content hash.
/// In addition, if the user removes the original photo (by tapping the X)
/// the widget clears its internal [_originalPhoto] variable so that any
/// newly selected photo is automatically treated as different from the original.
class InputField extends StatefulWidget {
  final AppLocalizations localizations;
  final bool isModelSelected;
  final bool isDynamicChatMode;
  final bool isLimitExceeded;
  final TextEditingController controller;
  final FocusNode textFieldFocusNode;
  final Future<void> Function() onSend;
  final Future<void> Function() onApplyEditedMessage;
  final bool isPhotoLoading;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final bool isSending;
  final bool isPremiumModel;
  final bool isSubscribed;
  final int premiumTrialUses;
  final String? originalMessageText;
  final bool isStorageSufficient;
  final int totalCredits;
  final String? role;
  final bool isServerSideModel;
  final VoidCallback onStop;
  final ValueChanged<File?>? onPhotoSelected;
  final bool canHandleImage;
  final bool isEditingMode;
  final File? preselectedPhoto;
  final bool modelMissing;
  final VoidCallback onCancelEditing;

  const InputField({
    super.key,
    required this.localizations,
    required this.isModelSelected,
    required this.isDynamicChatMode,
    required this.isLimitExceeded,
    required this.controller,
    required this.textFieldFocusNode,
    required this.onSend,
    required this.onApplyEditedMessage,
    required this.isPhotoLoading,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.isSending,
    required this.isPremiumModel,
    required this.isSubscribed,
    required this.premiumTrialUses,
    this.originalMessageText,
    required this.isStorageSufficient,
    required this.totalCredits,
    this.role,
    required this.isServerSideModel,
    required this.onStop,
    this.onPhotoSelected,
    required this.canHandleImage,
    this.isEditingMode = false,
    this.preselectedPhoto,
    required this.modelMissing,
    required this.onCancelEditing,
  });

  @override
  InputFieldState createState() => InputFieldState();
}

/// The state for the [InputField] widget.
/// This class handles photo selection, deletion, preview display,
/// and determining whether the send button should be enabled.
class InputFieldState extends State<InputField> {
  double _inputFieldHeight = 0.0;
  final GlobalKey _inputFieldKey = GlobalKey();
  File? _selectedPhoto;
  final ImagePicker _imagePicker = ImagePicker();
  Key _photoKey = UniqueKey();
  /// Stores the original photo (if any) that came with the message in editing mode.
  /// This is used to compare against a new selection. Once the original photo is removed,
  /// this variable is cleared, so any new photo is considered a change.
  File? _originalPhoto;


  @override
  void initState() {
    super.initState();
    if (widget.isEditingMode && widget.preselectedPhoto != null) {
      _selectedPhoto = widget.preselectedPhoto;
      _originalPhoto = widget.preselectedPhoto;
    }
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant InputField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isEditingMode && widget.isEditingMode) {
      setState(() {
        _selectedPhoto = widget.preselectedPhoto;
        _originalPhoto = widget.preselectedPhoto;
        _photoKey = UniqueKey();
      });
    }

    // When exiting edit mode, clear everything.
    if (oldWidget.isEditingMode && !widget.isEditingMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) clearPhotoPanel();
      });
    }
  }

  /// Opens the image picker to allow the user to select a photo from the gallery.
  Future<void> _pickPhoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedPhoto = File(pickedFile.path);
          _photoKey = UniqueKey();
        });
        widget.onPhotoSelected?.call(_selectedPhoto);
      }
    } catch (e) {
      debugPrint("Error picking photo: $e");
    }
  }

  /// Removes the currently selected photo by setting _selectedPhoto to null,
  /// marking _photoRemoved, and clearing the stored _originalPhoto.
  void _removeSelectedPhoto() {
    setState(() {
      _selectedPhoto = null;
      if (!widget.isEditingMode) {
        _originalPhoto = null;
      }
    });
    widget.onPhotoSelected?.call(null);
  }

  /// Clears the photo selection panel and resets internal flags.
  void clearPhotoPanel() {
    setState(() {
      _selectedPhoto = null;
      _originalPhoto = null;
    });
    widget.onPhotoSelected?.call(null);
  }

  /// Triggers the onStop callback from the parent.
  void _handleStop() {
    widget.onStop();
  }

  // --- 🔥 THE FINAL, ALIGNED, AND STABLE SOLUTION 🔥 ---

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (!widget.isModelSelected && !widget.isDynamicChatMode) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => updateInputFieldHeight());

        return Container(
          key: _inputFieldKey,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            border: Border(
              top: BorderSide(color: AppColors.border, width: 1.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.canHandleImage)
                _buildPhotoPreview(screenWidth),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildAnimatedAddPhotoButton(screenWidth),
                        Expanded(
                          child: _buildTextField(screenWidth),
                        ),
                      ],
                    ),
                  ),
                  _buildSendButton(screenWidth),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the add photo button wrapped in an `AnimatedContainer`.
  /// The container animates its width to create the slide effect.
  Widget _buildAnimatedAddPhotoButton(double screenWidth) {
    final double targetWidth = widget.canHandleImage ? 48.0 : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: targetWidth,
      child: ClipRect(
        child: SizedBox(
          width: 48.0,
          child: _buildAddPhotoButtonContent(screenWidth),
        ),
      ),
    );
  }

  /// The content of the add photo button, now simplified.
  /// Its vertical alignment is handled entirely by the parent Row.
  Widget _buildAddPhotoButtonContent(double screenWidth) {
    final bool hasPhoto = _selectedPhoto != null;
    final bool buttonDisabled = widget.isLimitExceeded || hasPhoto;

    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Ensures the whole area is tappable
      onTap: widget.isPhotoLoading
          ? null
          : () {
        if (hasPhoto) {
          Provider.of<NotificationService>(context, listen: false)
              .showNotification(
            message: widget.localizations.photoLimitReachedMessage,
            isSuccess: false,
            bottomOffset: 0.22,
            fontSize: 0.032,
          );
        } else {
          _pickPhoto();
        }
      },
      child: Opacity(
        opacity: (buttonDisabled || widget.isPhotoLoading) ? 0.5 : 1.0,
        // The icon is now simply centered by the parent Row.
        child: Icon(
          Icons.add,
          color: AppColors.primaryColor.inverted,
          size: 28, // Slightly larger for better visual balance
        ),
      ),
    );
  }

  /// Builds the main text input field.
  Widget _buildTextField(double screenWidth) {
    const Key textFieldKey = ValueKey('chat_input_field');
    return TextField(
      key: textFieldKey,
      focusNode: widget.textFieldFocusNode,
      cursorColor: AppColors.primaryColor.inverted,
      controller: widget.controller,
      maxLength: 4000,
      minLines: 1,
      maxLines: 6,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        hintText: widget.localizations.messageHint,
        hintStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: screenWidth * 0.04,
        ),
        border: InputBorder.none,
        counterText: '',
      ),
      style: TextStyle(
        color: AppColors.primaryColor.inverted,
        fontSize: screenWidth * 0.04,
      ),
      onSubmitted: (value) async {
        if (isSendButtonEnabled) await widget.onSend();
      },
    );
  }

  /// Builds the Send/Stop action button.
  Widget _buildSendButton(double screenWidth) {
    final bool isConnected = context.watch<InternetProvider>().isConnected;

    return Padding(
      padding: EdgeInsets.only(
        right: screenWidth * 0.02,
        bottom: 8.0,
      ),
      child: Builder(
        builder: (context) {
          bool calculatedIsEnabled = isSendButtonEnabled;

          if ((widget.isServerSideModel || widget.isDynamicChatMode) && !isConnected) {
            calculatedIsEnabled = false;
          }

          return ActionButtonWidget(
            isEnabled: calculatedIsEnabled,
            isSending: widget.isSending,
            onSend: widget.onSend,
            onStop: _handleStop,
          );
        },
      ),
    );
  }

  /// Builds the photo preview panel which displays the selected photo with a close button.
  bool _isPngFile(File file) {
    try {
      final bytes = file.readAsBytesSync();
      if (bytes.length < 8) return false;
      final pngSignature = [137, 80, 78, 71, 13, 10, 26, 10];
      for (int i = 0; i < pngSignature.length; i++) {
        if (bytes[i] != pngSignature[i]) return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Builds the photo preview panel which displays the selected photo with a close button.
  Widget _buildPhotoPreview(double screenWidth) {
    final double previewSize = screenWidth * 0.25;
    final bool hasPhoto = _selectedPhoto != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: hasPhoto ? previewSize + (screenWidth * 0.03 * 2) : 0,
      width: double.infinity,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: hasPhoto ? 1.0 : 0.0,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            key: _photoKey,
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: SizedBox(
                    width: previewSize,
                    height: previewSize,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_selectedPhoto != null && _isPngFile(_selectedPhoto!))
                          Container(
                            color: AppColors.primaryColor.inverted.withValues(alpha: 0.5),
                          ),
                        if (_selectedPhoto != null)
                          Image.file(
                            _selectedPhoto!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.broken_image, color: AppColors.tertiaryColor),
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -8,
                  left: previewSize - 16,
                  child: GestureDetector(
                    onTap: _removeSelectedPhoto,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 1)),
                        ],
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: screenWidth * 0.04,
                        color: Colors.white,
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

  /// Updates the input field container height if it changes.
  void updateInputFieldHeight() {
    final RenderBox? renderBox =
    _inputFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final newHeight = renderBox.size.height;
      if (newHeight != _inputFieldHeight) {
        setState(() {
          _inputFieldHeight = newHeight;
        });
      }
    }
  }

  /// Computes the MD5 hash of the given file’s contents.
  String computeFileHash(File file) {
    final bytes = file.readAsBytesSync();
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  int _requiredCredits() {
    if (widget.isDynamicChatMode) {
      return 0;
    }

    if (widget.isServerSideModel) {
      final base = widget.isPremiumModel ? 20 : 10;
      final photo = (_selectedPhoto != null) ? 30 : 0;
      return base + photo;
    }

    return 0;
  }

  /// Determines whether the send button should be enabled, with detailed logging.
  /// Now correctly handles premium trials for free users.
  bool get isSendButtonEnabled {
    // Basic checks first (these are unchanged)
    if (widget.modelMissing || widget.isSending || !widget.isStorageSufficient || widget.isLimitExceeded) {
      return false;
    }

    // If it's a premium model, the user is NOT subscribed, AND their trials are used up, disable the button.
    if (widget.isPremiumModel && !widget.isSubscribed && widget.premiumTrialUses >= 3) {
      return false;
    }

    final String currentText = widget.controller.text.trim();
    final bool hasPhoto = _selectedPhoto != null;

    final needed = _requiredCredits();
    if ((widget.isDynamicChatMode || widget.isServerSideModel) && widget.totalCredits < needed) {
      return false;
    }

    if (widget.isEditingMode) {
      final String originalText = widget.originalMessageText ?? '';
      final bool textChanged = currentText != originalText;
      final bool photoChanged = _originalPhoto?.path != _selectedPhoto?.path;
      if (!textChanged && !photoChanged) {
        return false;
      }
      return currentText.isNotEmpty || hasPhoto;
    } else {
      return currentText.isNotEmpty || hasPhoto;
    }
  }
}