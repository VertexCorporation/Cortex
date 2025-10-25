// lib/chat/screen/selected/screen.dart

import 'package:cortex/app.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cortex/chat/screen/selected/tiles.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme.dart';
import '../../providers/conversation.dart';
import '../../providers/input.dart';
import '../../providers/session.dart';

/// Displays the active chat conversation, including the message list
/// and the initial "empty state" for a new chat.
///
/// This widget is now self-contained. It reads all the necessary state
/// directly from the providers (`ChatSessionProvider`, `ConversationProvider`,
/// `UserInputProvider`) instead of receiving numerous parameters.
class SelectedScreen extends StatelessWidget {
  // It only needs things that are truly owned by the parent State, like controllers and callbacks.
  final ScrollController scrollController;
  final VoidCallback onStop;
  final Function(int index) onEdit;
  final Function(int index) onFadeOutComplete;
  final Function(int index) onRegenerate;
  final Function(int index, String newExtension) onChangeModel;
  final Function(int index) onReport;

  const SelectedScreen({
    super.key,
    required this.scrollController,
    required this.onStop,
    required this.onEdit,
    required this.onFadeOutComplete,
    required this.onRegenerate,
    required this.onChangeModel,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    // Read all necessary providers using `watch` to listen for changes.
    final sessionProvider = context.watch<ChatSessionProvider>();
    final conversationProvider = context.watch<ConversationProvider>();
    final inputProvider = context.watch<InputProvider>();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // The message list is now read directly from the ConversationProvider.
    final currentMessages = conversationProvider.messages;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: currentMessages.isEmpty
      // --- BUILD EMPTY STATE ---
          ? SizedBox(
        key: const ValueKey('empty_state'),
        child: _buildEmptyState(context, screenWidth, screenHeight, sessionProvider),
      )
      // --- BUILD MESSAGE LIST ---
          : Builder(
        key: const ValueKey('message_list'),
        builder: (context) {
          final bool conversationHasPhoto = currentMessages.any((m) => m.photoPath != null);
          final isWaitingNotifier = ValueNotifier<bool>(conversationProvider.isWaitingForResponse);

          return Column(
            children: [
              Expanded(
                child: Tiles.buildMessagesList(
                  context: context,
                  messages: currentMessages.toList(),
                  scrollController: scrollController,
                  isEditingMode: inputProvider.isEditingMode,
                  editingMessageIndex: inputProvider.editingMessageIndex,
                  modelId: sessionProvider.modelId ?? '',
                  isPersistentlyDynamic: sessionProvider.isDynamicChat,
                  isUserSubscribed: sessionProvider.isUserSubscribed,
                  premiumTrialUses: sessionProvider.premiumTrialUses,
                  isWaitingForResponseNotifier: isWaitingNotifier,
                  conversationHasPhoto: conversationHasPhoto,
                  onStop: onStop,
                  onEdit: onEdit,
                  onFadeOutComplete: onFadeOutComplete,
                  onRegenerate: onRegenerate,
                  onChangeModel: onChangeModel,
                  onReport: onReport,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// A private helper method to build the UI for an empty chat screen.
  Widget _buildEmptyState(
      BuildContext context,
      double screenWidth,
      double screenHeight,
      ChatSessionProvider sessionProvider,
      ) {
    if (sessionProvider.isDynamicChat || (sessionProvider.isExitingChat && sessionProvider.wasDynamicOnExit)) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: screenWidth * 0.4,
                height: screenWidth * 0.4,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/cortex.svg',
                    fit: BoxFit.contain,
                    colorFilter: const ColorFilter.matrix([
                      -1, 0, 0, 0, 255,
                      0,-1, 0, 0, 255,
                      0, 0,-1, 0, 255,
                      0, 0, 0, 1, 0,
                    ]),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                AppLocalizations.of(context)!.selectionScreenGreetingGeneric,
                style: GoogleFonts.heebo(
                  fontSize: screenWidth * 0.06,
                  color: AppColors.primaryColor.inverted,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      );
    }

    final double imageSize = screenWidth * 0.25;

    final fallbackImage = SvgPicture.asset(
      'assets/icons/self.svg',
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(
        AppColors.primaryColor.inverted,
        BlendMode.srcIn,
      ),
    );

    Widget imageWidget;
    final path = sessionProvider.modelImagePath;

    if (path == null || path.isEmpty || path.endsWith('self.svg')) {
      imageWidget = fallbackImage;
    } else {
      final bool isSvg = path.toLowerCase().endsWith('.svg');
      if (isSvg) {
        imageWidget = path.startsWith('assets/')
            ? SvgPicture.asset(path, fit: BoxFit.contain)
            : SvgPicture.file(File(path), fit: BoxFit.contain, placeholderBuilder: (_) => fallbackImage);
      } else {
        final provider = path.startsWith('assets/')
            ? AssetImage(path) as ImageProvider
            : FileImage(File(path));
        imageWidget = Image(
          image: provider,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallbackImage,
        );
      }
    }

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: imageSize,
              height: imageSize,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: AppColors.background,
                ),
                child: imageWidget,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            if (sessionProvider.modelTitle != null)
              Text(
                sessionProvider.modelTitle!,
                style: GoogleFonts.heebo(
                  fontSize: screenWidth * 0.05,
                  color: AppColors.primaryColor.inverted,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }
}