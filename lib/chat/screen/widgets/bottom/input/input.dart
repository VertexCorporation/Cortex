// lib/chat/screen/selected/widgets/input/input.dart

import 'dart:io';
import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../internet.dart';
import '../../../../../theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'buttons.dart';
import 'service.dart';

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
  final InputService _inputService = InputService();
  double _inputFieldHeight = 0.0;
  final GlobalKey _inputFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Rebuild on text change to update Send button state
    widget.controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void clearPhotoPanel() {
    context.read<InputProvider>().selectPhoto(null);
  }

  // Exposed getter for the parent widget to check validity
  bool get isSendButtonEnabled {
    return _inputService.isSendButtonEnabled(
      context: context,
      controller: widget.controller,
      isServerSideModel: widget.isServerSideModel,
      isDynamicChatMode: widget.isDynamicChatMode,
      isLimitExceeded: widget.isLimitExceeded,
      isSending: widget.isSending,
      modelMissing: widget.modelMissing,
      isStorageSufficient: widget.isStorageSufficient,
      isPremiumModel: widget.isPremiumModel,
      isSubscribed: widget.isSubscribed,
      premiumTrialUses: widget.premiumTrialUses,
      totalCredits: widget.totalCredits,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final bool isTablet = screenWidth >= 600;

    if (!widget.isModelSelected && !widget.isDynamicChatMode) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());

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
                top: BorderSide(color: AppColors.border, width: 1.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.canHandleImage)
                _PhotoPreviewSection(
                    screenWidth: screenWidth, isTablet: isTablet),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TextFieldSection(
                          controller: widget.controller,
                          focusNode: widget.textFieldFocusNode,
                          localizations: widget.localizations,
                          screenWidth: screenWidth,
                          isTablet: isTablet,
                          onEnterPressed: () {
                            if (isSendButtonEnabled) widget.onSend();
                          },
                        ),
                        _ToolsSection(
                          screenWidth: screenWidth,
                          isTablet: isTablet,
                          widget: widget,
                        ),
                      ],
                    ),
                  ),
                  _SendButtonSection(
                    screenWidth: screenWidth,
                    isTablet: isTablet,
                    widget: widget,
                    isEnabled: isSendButtonEnabled,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateHeight() {
    final RenderBox? renderBox =
    _inputFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final newHeight = renderBox.size.height;
      if (newHeight != _inputFieldHeight) {
        setState(() => _inputFieldHeight = newHeight);
      }
    }
  }
}

// -----------------------------------------------------------------------------
// INTERNAL WIDGET COMPONENTS
// -----------------------------------------------------------------------------

class _PhotoPreviewSection extends StatelessWidget {
  final double screenWidth;
  final bool isTablet;

  const _PhotoPreviewSection(
      {required this.screenWidth, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final inputProvider = context.watch<InputProvider>();
    final File? photo = inputProvider.selectedPhoto;
    final bool hasPhoto = photo != null;

    final double previewSize = isTablet ? screenWidth * 0.18 : screenWidth *
        0.25;
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
            padding: EdgeInsets.all(padding),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: SizedBox(
                    width: previewSize,
                    height: previewSize,
                    child: hasPhoto
                        ? Image.file(
                      photo,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) =>
                          Icon(
                              Icons.broken_image,
                              color: AppColors.tertiaryColor),
                    )
                        : null,
                  ),
                ),
                Positioned(
                  top: -8,
                  left: previewSize - 16,
                  child: GestureDetector(
                    onTap: () =>
                        context.read<InputProvider>().selectPhoto(null),
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black38,
                              blurRadius: 4,
                              offset: Offset(0, 1))
                        ],
                      ),
                      child: Icon(Icons.close_rounded,
                          size: isTablet
                              ? screenWidth * 0.025
                              : screenWidth * 0.04,
                          color: Colors.white),
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

class _TextFieldSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final AppLocalizations localizations;
  final double screenWidth;
  final bool isTablet;
  final VoidCallback onEnterPressed;

  const _TextFieldSection({
    required this.controller,
    required this.focusNode,
    required this.localizations,
    required this.screenWidth,
    required this.isTablet,
    required this.onEnterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double fontSize = isTablet ? screenWidth * 0.025 : screenWidth * 0.04;
    final double verticalPadding = isTablet ? screenWidth * 0.015 : 12.0;
    final double horizontalPadding = isTablet ? screenWidth * 0.015 : 8.0;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isTablet ? screenWidth * 0.02 : screenWidth * 0.02),
      child: TextField(
        key: const ValueKey('chat_input_field'),
        focusNode: focusNode,
        cursorColor: AppColors.primaryColor.inverted,
        controller: controller,
        maxLength: 4000,
        minLines: 1,
        maxLines: 6,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
              vertical: verticalPadding, horizontal: horizontalPadding),
          hintText: localizations.messageHint,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: fontSize),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          counterText: '',
        ),
        style: TextStyle(
            color: AppColors.primaryColor.inverted, fontSize: fontSize),
        onSubmitted: (_) => onEnterPressed(),
      ),
    );
  }
}

class _ToolsSection extends StatelessWidget {
  final double screenWidth;
  final bool isTablet;
  final InputField widget;

  const _ToolsSection({required this.screenWidth,
    required this.isTablet,
    required this.widget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isTablet ? screenWidth * 0.02 : 12.0,
        right: 8.0,
        top: 2.0,
        bottom: isTablet ? screenWidth * 0.015 : 12.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Add Photo Button
          AddPhotoButton(
            isLimitExceeded: widget.isLimitExceeded,
            isPhotoLoading: widget.isPhotoLoading,
            localizations: widget.localizations,
          ),
          SizedBox(width: screenWidth * 0.02),

          // 2. Features Button
          FeaturesButton(controller: widget.controller),
          SizedBox(width: screenWidth * 0.02),

          // 3. Model Select Button
          ModelSelectButton(
            screenWidth: screenWidth,
            isTablet: isTablet,
            localizations: widget.localizations,
          ),
        ],
      ),
    );
  }
}

class _SendButtonSection extends StatelessWidget {
  final double screenWidth;
  final bool isTablet;
  final InputField widget;
  final bool isEnabled;

  const _SendButtonSection({
    required this.screenWidth,
    required this.isTablet,
    required this.widget,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final bool isConnected = context
        .watch<InternetProvider>()
        .isConnected;
    bool effectiveEnabled = isEnabled;

    if ((widget.isServerSideModel || widget.isDynamicChatMode) &&
        !isConnected) {
      effectiveEnabled = false;
    }

    return Padding(
      padding: EdgeInsets.only(
        right: isTablet ? screenWidth * 0.02 : 16.0,
        bottom: isTablet ? screenWidth * 0.015 : 12.0,
      ),
      child: ActionButtonWidget(
        isEnabled: effectiveEnabled,
        isSending: widget.isSending,
        onSend: widget.onSend,
        onStop: widget.onStop,
      ),
    );
  }
}