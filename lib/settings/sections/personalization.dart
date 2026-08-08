// lib/settings/sections/personalization.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app.dart';
import '../../chat/providers/memory.dart';
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

  late final TextEditingController _memoryController;
  final FocusNode _memoryFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final memoryProvider = context.read<UserMemoryProvider>();
    _instructionController =
        TextEditingController(text: memoryProvider.customInstruction);
    _instructionFocusNode.addListener(_onInstructionFocusLost);

    _memoryController = TextEditingController(text: memoryProvider.memory);
    _memoryFocusNode.addListener(_onMemoryFocusLost);
  }

  @override
  void dispose() {
    _instructionFocusNode.removeListener(_onInstructionFocusLost);
    _instructionFocusNode.dispose();
    _instructionController.dispose();

    _memoryFocusNode.removeListener(_onMemoryFocusLost);
    _memoryFocusNode.dispose();
    _memoryController.dispose();

    super.dispose();
  }

  void _onInstructionFocusLost() {
    if (!_instructionFocusNode.hasFocus) {
      final newText = _instructionController.text.trim();
      context.read<UserMemoryProvider>().updateCustomInstruction(newText);
    }
  }

  void _onMemoryFocusLost() {
    if (!_memoryFocusNode.hasFocus) {
      final newText = _memoryController.text.trim();
      context.read<UserMemoryProvider>().updateMemory(newText);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery
        .sizeOf(context)
        .width;
    final double scale = screenWidth / 400.0;
    final memoryProvider = context.watch<UserMemoryProvider>();

    if (!_instructionFocusNode.hasFocus &&
        _instructionController.text != memoryProvider.customInstruction) {
      _instructionController.text = memoryProvider.customInstruction;
    }
    if (!_memoryFocusNode.hasFocus &&
        _memoryController.text != memoryProvider.memory) {
      _memoryController.text = memoryProvider.memory;
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
                ],
              ),
              TextField(
                controller: _memoryController,
                focusNode: _memoryFocusNode,
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
                  hintText: l10n.noMemoryYet,
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
                  context.read<UserMemoryProvider>().updateMemory(value.trim());
                },
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

  Widget _buildPanel(BuildContext context, {
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

