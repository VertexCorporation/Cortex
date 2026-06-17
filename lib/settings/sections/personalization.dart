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
                                  _memoryController.clear();
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

    if (!_memoryFocusNode.hasFocus &&
        _memoryController.text != memoryProvider.memory) {
      _memoryController.text = memoryProvider.memory;
    }
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
        SizedBox(height: 8 * scale),
        Text(
          l10n.personalizationDescription,
          style: TextStyle(color: AppColors.quinaryColor, fontSize: 14 * scale),
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
              TextField(
                controller: _memoryController,
                focusNode: _memoryFocusNode,
                maxLength: 2048,
                buildCounter: (BuildContext context, { int? currentLength, int? maxLength, bool? isFocused }) => null,
                maxLines: 10,
                minLines: 7,
                style: TextStyle(
                  color: AppColors.primaryColor.inverted,
                  fontSize: 13 * scale,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: l10n.noMemoryYet,
                  hintStyle: TextStyle(
                    color: AppColors.quinaryColor,
                    fontSize: 14 * scale,
                  ),
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
                onChanged: (val) {
                  // Keep provider in sync for length check or UI updates if any,
                  // but we mainly write on focus lost or submit.
                  context.read<UserMemoryProvider>().updateMemory(val);
                },
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
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: memoryProvider.memory.isNotEmpty
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Padding(
                  padding: EdgeInsets.only(top: 10 * scale),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        _showClearMemoryDialog(context);
                      },
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
                ),
 secondChild: const SizedBox(width: double.infinity, height: 0),
 ),
 Container(
  margin: EdgeInsets.only(top: 14 * scale),
  padding: EdgeInsets.all(12 * scale),
  decoration: BoxDecoration(
   color: AppColors.background.withValues(alpha: 0.5),
   borderRadius: BorderRadius.circular(8 * scale),
   border: Border.all(
    color: AppColors.quinaryColor.withValues(alpha: 0.2),
    width: 0.5,
   ),
  ),
  child: Column(
   crossAxisAlignment: CrossAxisAlignment.start,
   children: [
    Row(
     children: [
      Icon(
       Icons.memory_outlined,
       color: AppColors.septenaryColor,
       size: 16 * scale,
      ),
      SizedBox(width: 8 * scale),
      Expanded(
       child: Text(
        "Hiyerarşik Semantik Bellek (MemGPT)",
        style: TextStyle(
         color: AppColors.primaryColor.inverted,
         fontSize: 12 * scale,
         fontWeight: FontWeight.bold,
        ),
       ),
      ),
     ],
    ),
    SizedBox(height: 8 * scale),
    Text(
     "Sohbet geçmişinin tamamı gönderilmez. Sistem; Kısa Süreli Bellek (aktif bağlam), Epizodik Bellek (son olaylar) ve Semantik Bellek (kalıcı bilgi tabanı - Vector DB) olarak üçe ayrılır. Yapay zeka, bilgiye ihtiyaç duyduğunda yerel bir veritabanından sadece ilgili semantik vektörleri çeker.",
     style: TextStyle(
      color: AppColors.primaryColor.inverted.withValues(alpha: 0.8),
      fontSize: 11.5 * scale,
      height: 1.4,
     ),
    ),
    SizedBox(height: 12 * scale),
    Row(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
      Expanded(
       child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Text(
          "Token & Maliyet Tasarrufu",
          style: TextStyle(
           color: AppColors.quinaryColor,
           fontSize: 10 * scale,
           fontWeight: FontWeight.w600,
          ),
         ),
         SizedBox(height: 4 * scale),
         Text(
          "%70 - %90 Tasarruf. 100 sayfalık sohbet geçmişi yerine sadece o anki konuyu ilgilendiren 2-3 paragraf gönderilir.",
          style: TextStyle(
           color: AppColors.primaryColor.inverted.withValues(alpha: 0.75),
           fontSize: 10.5 * scale,
           height: 1.35,
          ),
         ),
        ],
       ),
      ),
      SizedBox(width: 12 * scale),
      Expanded(
       child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Text(
          "Düşünme & Hız Avantajı",
          style: TextStyle(
           color: AppColors.quinaryColor,
           fontSize: 10 * scale,
           fontWeight: FontWeight.w600,
          ),
         ),
         SizedBox(height: 4 * scale),
         Text(
          "Modelin bağlamı şişmediği için dikkati dağılmaz, aylar önceki konuşmaları dahi tutarlı bir şekilde hatırlar.",
          style: TextStyle(
           color: AppColors.primaryColor.inverted.withValues(alpha: 0.75),
           fontSize: 10.5 * scale,
           height: 1.35,
          ),
         ),
        ],
       ),
      ),
     ],
    ),
   ],
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
            buildCounter: (BuildContext context, { int? currentLength, int? maxLength, bool? isFocused }) => null,
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
