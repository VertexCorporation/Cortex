// lib/chat/screen/selected/widgets/input/input.dart

import 'dart:io';
import 'package:cortex/app.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../internet.dart';
import '../../../../../notifications/introvert.dart';
import '../../../../../theme.dart';
import 'package:cortex/l10n/app_localizations.dart';

import 'buttons.dart';

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

class InputFieldState extends State<InputField> {
  double _inputFieldHeight = 0.0;
  final GlobalKey _inputFieldKey = GlobalKey();
  File? _selectedPhoto;
  final ImagePicker _imagePicker = ImagePicker();
  Key _photoKey = UniqueKey();
  File? _originalPhoto;
  bool _photoRemoved = false;

  @override
  void initState() {
    super.initState();
    _photoRemoved = false;
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
        _photoRemoved = false;
      });
    }

    if (oldWidget.isEditingMode && !widget.isEditingMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) clearPhotoPanel();
      });
    }
  }

  void _removeSelectedPhoto() {
    setState(() {
      _selectedPhoto = null;
      _photoRemoved = true;
    });
    widget.onPhotoSelected?.call(null);
  }

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

  void clearPhotoPanel() {
    setState(() {
      _selectedPhoto = null;
      _originalPhoto = null;
    });
    widget.onPhotoSelected?.call(null);
  }

  void _handleStop() {
    widget.onStop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    if (!widget.isModelSelected && !widget.isDynamicChatMode) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => updateInputFieldHeight());

        // --- DYNAMIC BORDER RADIUS ---
        final double radius = isTablet ? screenWidth * 0.025 : 16.0;

        return Container(
          key: _inputFieldKey,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
            ),
            border: Border(
              top: BorderSide(color: AppColors.border, width: 1.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.canHandleImage)
                _buildPhotoPreview(screenWidth, isTablet),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildAnimatedAddPhotoButton(screenWidth, isTablet),
                        Expanded(
                          child: _buildTextField(screenWidth, isTablet),
                        ),
                      ],
                    ),
                  ),
                  _buildSendButton(screenWidth, isTablet),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedAddPhotoButton(double screenWidth, bool isTablet) {
    // Dynamic width for the button container
    final double buttonWidth = isTablet ? screenWidth * 0.08 : 48.0;
    final double targetWidth = widget.canHandleImage ? buttonWidth : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: targetWidth,
      child: ClipRect(
        child: SizedBox(
          width: buttonWidth,
          child: _buildAddPhotoButtonContent(screenWidth, isTablet),
        ),
      ),
    );
  }

  Widget _buildAddPhotoButtonContent(double screenWidth, bool isTablet) {
    final bool hasPhoto = _selectedPhoto != null;
    final bool buttonDisabled = widget.isLimitExceeded || hasPhoto;

    // --- DYNAMIC ICON SIZE ---
    // Tablet: 3.5% of width. Phone: Fixed 28.
    final double iconSize = isTablet ? screenWidth * 0.035 : 28.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.isPhotoLoading
          ? null
          : () {
        if (hasPhoto) {
          Provider.of<IntrovertNotificationService>(context, listen: false)
              .showNotification(
            message: widget.localizations.photoLimitReachedMessage,
            type: NotificationType.error,
            bottomOffset: 0.22,
            fontSize: 0.032,
          );
        } else {
          _pickPhoto();
        }
      },
      child: Opacity(
        opacity: (buttonDisabled || widget.isPhotoLoading) ? 0.5 : 1.0,
        child: Icon(
          Icons.add,
          color: AppColors.primaryColor.inverted,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildTextField(double screenWidth, bool isTablet) {
    const Key textFieldKey = ValueKey('chat_input_field');

    // --- DYNAMIC FONT SIZE ---
    // Tablet: 2.5% of width (~20px on 800w). Phone: 4% of width (~16px on 400w).
    final double fontSize = isTablet ? screenWidth * 0.025 : screenWidth * 0.04;

    // Dynamic Padding
    final double verticalPadding = isTablet ? screenWidth * 0.02 : 10.0;
    final double horizontalPadding = isTablet ? screenWidth * 0.015 : 8.0;

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
        contentPadding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
        hintText: widget.localizations.messageHint,
        hintStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: fontSize,
        ),
        border: InputBorder.none,
        counterText: '',
      ),
      style: TextStyle(
        color: AppColors.primaryColor.inverted,
        fontSize: fontSize,
      ),
      onSubmitted: (value) async {
        if (isSendButtonEnabled) await widget.onSend();
      },
    );
  }

  Widget _buildSendButton(double screenWidth, bool isTablet) {
    final bool isConnected = context.watch<InternetProvider>().isConnected;

    return Padding(
      padding: EdgeInsets.only(
        right: isTablet ? screenWidth * 0.02 : screenWidth * 0.02,
        bottom: isTablet ? screenWidth * 0.015 : 8.0,
      ),
      child: Builder(
        builder: (context) {
          bool calculatedIsEnabled = isSendButtonEnabled;

          if ((widget.isServerSideModel || widget.isDynamicChatMode) && !isConnected) {
            calculatedIsEnabled = false;
          }

          // ActionButtonWidget handles its own sizing, but typically relies on parent limits
          // or its own defaults. Ensure it scales if needed or let it be standard size.
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

  Widget _buildPhotoPreview(double screenWidth, bool isTablet) {
    // --- DYNAMIC PREVIEW SIZE ---
    // Tablet: 18% of screen. Phone: 25%.
    final double previewSize = isTablet ? screenWidth * 0.18 : screenWidth * 0.25;
    final bool hasPhoto = _selectedPhoto != null;
    final double padding = isTablet ? screenWidth * 0.02 : screenWidth * 0.03;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: hasPhoto ? previewSize + (padding * 2) : 0,
      width: double.infinity,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: hasPhoto ? 1.0 : 0.0,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            key: _photoKey,
            padding: EdgeInsets.all(padding),
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
                        // Dynamic close icon
                        size: isTablet ? screenWidth * 0.025 : screenWidth * 0.04,
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

  String computeFileHash(File file) {
    final bytes = file.readAsBytesSync();
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  int _requiredCredits() {
    if (!widget.isServerSideModel) return 0;

    if (widget.isDynamicChatMode) {
      const base = 20;
      final photo = (_selectedPhoto != null) ? 30 : 0;
      return base + photo;
    }

    if (widget.isServerSideModel) {
      final base = widget.isPremiumModel ? 20 : 5;
      final photo = (_selectedPhoto != null) ? 30 : 0;
      return base + photo;
    }

    return 0;
  }

  bool get isSendButtonEnabled {
    if (widget.modelMissing) return false;
    if (widget.isSending) return false;
    if (!widget.isStorageSufficient) return false;
    if (widget.isLimitExceeded) return false;

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

      bool photoChanged;
      if (_photoRemoved) {
        photoChanged = true;
      } else {
        photoChanged = _originalPhoto?.path != _selectedPhoto?.path;
      }

      if (!textChanged && !photoChanged) {
        return false;
      }
      return currentText.isNotEmpty || hasPhoto;
    } else {
      return currentText.isNotEmpty || hasPhoto;
    }
  }
}