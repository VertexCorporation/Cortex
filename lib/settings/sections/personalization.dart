// lib/settings/sections/personalization.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app.dart';
import '../../chat/providers/memory.dart';
import '../../darkener.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';

/// A settings section for Personalization, containing Memory and Intelligence panels.
class PersonalizationSection extends StatefulWidget {
  const PersonalizationSection({super.key});

  @override
  State<PersonalizationSection> createState() => _PersonalizationSectionState();
}

class _PersonalizationSectionState extends State<PersonalizationSection> {
  late final TextEditingController _instructionController;
  final FocusNode _instructionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final memoryProvider = context.read<UserMemoryProvider>();
    _instructionController =
        TextEditingController(text: memoryProvider.customInstruction);
    _instructionFocusNode.addListener(_onInstructionFocusLost);
  }

  @override
  void dispose() {
    _instructionFocusNode.removeListener(_onInstructionFocusLost);
    _instructionFocusNode.dispose();
    _instructionController.dispose();

    super.dispose();
  }

  void _onInstructionFocusLost() {
    if (!_instructionFocusNode.hasFocus) {
      final newText = _instructionController.text.trim();
      context.read<UserMemoryProvider>().updateCustomInstruction(newText);
    }
  }

  void _showClearMemoryDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final memoryProvider = context.read<UserMemoryProvider>();
    final RestoreCallback restoreNavBar = Darkener.darken();
    final screenWidth = MediaQuery.sizeOf(context).width;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ClearMemoryDialog',
      pageBuilder: (ctx, _, __) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: screenWidth * 0.8,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: Column(
                        children: [
                          Text(
                            l10n.clearMemory,
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor.inverted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenWidth * 0.03),
                          Text(
                            l10n.clearMemoryConfirm,
                            style: TextStyle(
                              color: AppColors.quinaryColor,
                              fontSize: screenWidth * 0.035,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                        color: AppColors.quinaryColor,
                        thickness: 0.5,
                        height: 1),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: AppColors.senaryColor
                                    .withValues(alpha: 0.1),
                                highlightColor: AppColors.senaryColor
                                    .withValues(alpha: 0.1),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.of(ctx).pop();
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenWidth * 0.04),
                                  child: Text(
                                    l10n.cancel,
                                    style: TextStyle(
                                      color: AppColors.senaryColor,
                                      fontSize: screenWidth * 0.04,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          VerticalDivider(
                              width: 1,
                              thickness: 0.5,
                              color: AppColors.quinaryColor),
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: AppColors.septenaryColor
                                    .withValues(alpha: 0.1),
                                highlightColor: AppColors.septenaryColor
                                    .withValues(alpha: 0.1),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  memoryProvider.clearMemory();
                                  Navigator.of(ctx).pop();
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenWidth * 0.04),
                                  child: Text(
                                    l10n.delete,
                                    style: TextStyle(
                                      color: AppColors.septenaryColor,
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
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
          ),
        );
      },
    ).whenComplete(() {
      restoreNavBar();
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = screenWidth / 400.0;
    final memoryProvider = context.watch<UserMemoryProvider>();

    if (!_instructionFocusNode.hasFocus &&
        _instructionController.text != memoryProvider.customInstruction) {
      _instructionController.text = memoryProvider.customInstruction;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Section Header ---
        Text(
          l10n.personalization,
          style: TextStyle(
            color: AppColors.primaryColor.inverted,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16 * scale),

        // --- Memory Panel ---
        _buildPanel(
          context,
          scale: scale,
          title: l10n.memoryTitle,
          subtitle: l10n.memoryDescription,
          icon: SvgPicture.asset(
            'assets/icons/context.svg',
            colorFilter: ColorFilter.mode(
                AppColors.primaryColor.inverted, BlendMode.srcIn),
            width: 24 * scale,
            height: 24 * scale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.read<UserMemoryProvider>().addMemory("");
                    },
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8 * scale),
                      child: Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primaryColor.inverted,
                        size: 20 * scale,
                      ),
                    ),
                  ),
                  if (memoryProvider.memoryList.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _showClearMemoryDialog(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8 * scale),
                        child: Text(
                          l10n.clearMemory,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (memoryProvider.memoryList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8 * scale),
                  ),
                  child: Text(
                    l10n.noMemoryYet,
                    style: TextStyle(
                      color: AppColors.quinaryColor,
                      fontSize: 14 * scale,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Column(
                  children:
                      List.generate(memoryProvider.memoryList.length, (index) {
                    final memory = memoryProvider.memoryList[index];
                    return _MemoryListItem(
                      initialMemory: memory,
                      scale: scale,
                      onChanged: (newVal) {
                        memoryProvider.editMemory(index, newVal);
                      },
                      onDelete: () {
                        memoryProvider.removeMemory(index);
                      },
                    );
                  }),
                ),
              if (memoryProvider.isMemoryLimitReached)
                Padding(
                  padding: EdgeInsets.only(top: 8 * scale),
                  child: Text(
                    l10n.memoryLimitReached,
                    style: TextStyle(
                      color: AppColors.septenaryColor,
                      fontSize: 11 * scale,
                    ),
                  ),
                ),
            ],
          ),
        ),

        SizedBox(height: 12 * scale),

        // --- Intelligence Panel ---
        _buildPanel(
          context,
          scale: scale,
          title: l10n.intelligenceTitle,
          subtitle: l10n.intelligenceDescription,
          icon: SvgPicture.asset(
            'assets/icons/test.svg',
            colorFilter: ColorFilter.mode(
                AppColors.primaryColor.inverted, BlendMode.srcIn),
            width: 24 * scale,
            height: 24 * scale,
          ),
          child: TextField(
            controller: _instructionController,
            focusNode: _instructionFocusNode,
            maxLength: 2048,
            buildCounter: (BuildContext context,
                    {int? currentLength, int? maxLength, bool? isFocused}) =>
                null,
            maxLines: 10,
            minLines: 7,
            style: TextStyle(
              color: AppColors.primaryColor.inverted,
              fontSize: 13 * scale,
            ),
            decoration: InputDecoration(
              hintText: l10n.customInstructionHint,
              hintStyle: TextStyle(
                  color: AppColors.quinaryColor, fontSize: 14 * scale),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: EdgeInsets.all(12 * scale),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: AppColors.primaryColor.inverted, width: 0.5),
                borderRadius: BorderRadius.circular(8 * scale),
              ),
            ),
            onSubmitted: (value) {
              context
                  .read<UserMemoryProvider>()
                  .updateCustomInstruction(value.trim());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPanel(
    BuildContext context, {
    required double scale,
    required String title,
    required String subtitle,
    required Widget icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              SizedBox(width: 10 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.primaryColor.inverted,
                        fontSize: 17 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.quinaryColor,
                        fontSize: 13 * scale,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          child,
        ],
      ),
    );
  }
}

class _MemoryListItem extends StatefulWidget {
  final String initialMemory;
  final double scale;
  final ValueChanged<String> onChanged;
  final VoidCallback onDelete;

  const _MemoryListItem({
    required this.initialMemory,
    required this.scale,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_MemoryListItem> createState() => _MemoryListItemState();
}

class _MemoryListItemState extends State<_MemoryListItem> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialMemory);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant _MemoryListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && _controller.text != widget.initialMemory) {
      _controller.text = widget.initialMemory;
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      widget.onChanged(_controller.text);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8 * widget.scale),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8 * widget.scale),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              style: TextStyle(
                color: AppColors.primaryColor.inverted,
                fontSize: 13 * widget.scale,
                height: 1.5,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(12 * widget.scale),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: widget.onChanged,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close,
                size: 16 * widget.scale, color: AppColors.quinaryColor),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}
