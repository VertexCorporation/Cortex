import 'package:cortex/design.dart';

import 'dart:async';
import 'dart:ui' show lerpDouble;
import 'dart:io';

import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:cortex/internet.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/chat/services/speech.dart';

import '../../wave.dart';

import 'package:cortex/chat/screen/widgets/bottom/input/buttons.dart';
import 'package:cortex/chat/screen/widgets/bottom/input/service.dart';
import 'package:cortex/server/subscription.dart';
import 'package:cortex/fog.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/navigation.dart';
import 'package:cortex/rag/screens/documents.dart';
import 'package:flutter_svg/flutter_svg.dart';

part 'attachments.dart';

part 'rag.dart';

part 'field.dart';

part 'send.dart';

/// The horizontal inset of the composer capsule's border from the edge of
/// the reading band — the exact geometry build() paints for the pill in its
/// two morph states. Shared with the edit-mode banner so the banner hugs
/// the capsule instead of spanning the full bar.
double composerCapsuleInset(double viewportWidth, {required bool expanded}) {
  final double screenWidth = viewportWidth.clamp(
    0.0,
    CortexDesign.readingWidth,
  );
  final double available =
      viewportWidth - 2 * CortexDesign.readingInset(viewportWidth);
  if (available <= 0) return 0;

  final double share;
  if (expanded) {
    share = InputFieldState.expandedCapsuleShare;
  } else {
    // The collapsed pill is drawn at 85% of the share it used to fill
    // (0.68 -> 0.578 of the reading band), so the morph visibly grows
    // the capsule itself; the expanded share is untouched. On narrow
    // phones the share is floored: the three buttons, their gaps and
    // the field's own paddings consume a fixed ~150px of the pill's
    // interior, so the pill only shrinks as far as a livable field
    // (a few ems of the responsive font plus padding) allows. The
    // floor derives from the same responsive font and button sizes
    // the row uses — no fixed pixels.
    final double buttonSize = InputFieldState.buttonSizeFor(screenWidth);
    final double collapsedControlInsets =
        (InputFieldState.edgeGap + buttonSize + InputFieldState.inputGap) +
        (InputFieldState.edgeGap +
            buttonSize * 2 +
            InputFieldState.buttonGap +
            InputFieldState.inputGap);
    final double responsiveFont = screenWidth >= 600
        ? screenWidth * 0.025
        : screenWidth * 0.04;
    // A livable collapsed field: 1.2em of glyph room plus the field's
    // own horizontal paddings (2x4 content + 2x2 section). A hint that
    // outgrows it clips into the section's fog strip by design.
    final double minCollapsedField = responsiveFont * 1.2 + 12.0;
    // 6.0 = the capsule's 1px border gap plus the section's 2px
    // horizontal padding, per side.
    final double minCollapsedShare =
        (collapsedControlInsets + 6.0 + minCollapsedField) / available;
    share =
        (InputFieldState.collapsedCapsuleShare *
                InputFieldState.collapsedCapsuleShrink)
            .clamp(minCollapsedShare, 1.0);
  }
  return available * (1.0 - share) / 2.0;
}

class InputField extends StatefulWidget {
  final AppLocalizations localizations;
  final bool isDynamicChatMode;
  final bool isLimitExceeded;
  final TextEditingController controller;
  final FocusNode textFieldFocusNode;
  final Future<void> Function() onSend;
  final Future<void> Function() onApplyEditedMessage;
  final bool isPhotoLoading;
  final bool isSending;
  final bool isPremiumModel;
  final bool isSubscribed;
  final SubscriptionTier userTier;
  final String? originalMessageText;
  final bool isStorageSufficient;
  final int? totalCredits;
  final String? role;
  final bool isServerSideModel;
  final VoidCallback onStop;
  final bool canHandleImage; // Maintained for legacy check logic
  final bool isEditingMode;
  final File?
  preselectedPhoto; // Deprecated but kept for signature compatibility
  final bool modelMissing;
  final VoidCallback onCancelEditing;

  const InputField({
    super.key,
    required this.localizations,
    required this.isDynamicChatMode,
    required this.isLimitExceeded,
    required this.controller,
    required this.textFieldFocusNode,
    required this.onSend,
    required this.onApplyEditedMessage,
    required this.isPhotoLoading,
    required this.isSending,
    required this.isPremiumModel,
    required this.isSubscribed,
    required this.userTier,
    this.originalMessageText,
    required this.isStorageSufficient,
    required this.totalCredits,
    this.role,
    required this.isServerSideModel,
    required this.onStop,
    this.onPhotoSelected, // Deprecated parameter, unused
    required this.canHandleImage,
    this.isEditingMode = false,
    this.preselectedPhoto,
    required this.modelMissing,
    required this.onCancelEditing,
  });

  // Deprecated parameter kept for signature compatibility
  final ValueChanged<File?>? onPhotoSelected;

  @override
  InputFieldState createState() => InputFieldState();
}

class InputFieldState extends State<InputField> with TickerProviderStateMixin {
  final InputService _inputService = InputService();

  // Shared composer geometry. The capsule occupies a share of the
  // available reading width: a compact pill while collapsed (every
  // control inside), opening to a slightly wider share once expanded.
  // The detachable bubbles float outside its border in the freed space
  // on both sides. Collapsed share bumped from 0.6: the compact pill
  // was starving the text field (the hint scaled to under half size),
  // so the pill keeps a bit more width and the collapsed/expanded gap
  // narrows. The share the collapsed pill is actually DRAWN at is
  // derived by composerCapsuleInset(): 85% of this base, floored on
  // narrow phones where the fixed control footprint would crush the
  // pill's interior.
  static const double collapsedCapsuleShare = 0.68;
  static const double expandedCapsuleShare = 0.7;
  // The collapsed pill is drawn at this fraction of the share above, so
  // the morph visibly grows the capsule itself (expanded untouched).
  static const double collapsedCapsuleShrink = 0.85;
  // Control gaps, shared by the capsule share math in build() and the
  // row's own layout below.
  static const double edgeGap = 8.0; // control -> capsule interior edge
  static const double buttonGap = 4.0; // mic -> action while both are inside
  static const double inputGap = 14.0; // breathing room around the text field
  static const double inputEdgeGap =
      14.0; // text field -> capsule border (expanded)
  static const double screenEdgeGap = 8.0; // detached bubble -> screen edge
  static const double detachedScreenShare = 0.75;
  static const double expandedButtonGrow = 1.25;

  static double buttonSizeFor(double screenWidth) =>
      (screenWidth * 0.086).clamp(32.0, 38.0);

  // Morphing composer expand/collapse animation
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  /// Voice entry shrinks/fades the capsule while Flow/X move outward.
  /// This clock is independent of compact/expanded orb presentation.
  late AnimationController _voiceMorphController;
  late Animation<double> _voiceMorphAnimation;

  @override
  void initState() {
    super.initState();

    // Composer expand/collapse animation (ChatGPT-style morph)
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _voiceMorphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _voiceMorphAnimation = CurvedAnimation(
      parent: _voiceMorphController,
      curve: Curves.easeInOutCubic,
    );

    widget.textFieldFocusNode.addListener(_onFocusChange);

    // PERFORMANCE: Only rebuild when the send button enabled state actually changes,
    // not on every single keystroke. This prevents full widget tree rebuilds during typing.
    bool lastSendEnabled = isSendButtonEnabled;
    bool lastHasTypedContent = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(() {
      if (!mounted) return;
      final nowEnabled = isSendButtonEnabled;
      final nowHasTypedContent = widget.controller.text.trim().isNotEmpty;
      if (nowEnabled != lastSendEnabled ||
          nowHasTypedContent != lastHasTypedContent) {
        lastSendEnabled = nowEnabled;
        lastHasTypedContent = nowHasTypedContent;
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant InputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textFieldFocusNode != widget.textFieldFocusNode) {
      oldWidget.textFieldFocusNode.removeListener(_onFocusChange);
      widget.textFieldFocusNode.addListener(_onFocusChange);
    }
    if (oldWidget.isSending != widget.isSending ||
        oldWidget.isLimitExceeded != widget.isLimitExceeded ||
        oldWidget.modelMissing != widget.modelMissing ||
        oldWidget.totalCredits != widget.totalCredits ||
        oldWidget.isServerSideModel != widget.isServerSideModel ||
        oldWidget.isDynamicChatMode != widget.isDynamicChatMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _voiceMorphController.dispose();
    _speechService?.removeListener(_onSpeechStatusChange);
    _featureProvider?.removeListener(_onFeatureModeChanged);
    widget.textFieldFocusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  SpeechService? _speechService;

  // The composer capsule reacts to the SELECTED FEATURE state too: a feature
  // (image/video/audio/offline/reasoning) keeps the composer visually ACTIVE
  // even with an empty field and no focus. Feature mode can change WITHOUT a
  // route transition (model-change rewrites in ChatView, the offline chip in
  // the + button, post-send clears), so the composer must re-evaluate on the
  // provider's notification itself — never only when a sheet/route rebuild
  // happens to pass by. Without this listener the capsule's expanded state
  // went stale (stuck expanded after a clear, stuck collapsed after a
  // selection made outside the sheet).
  InputProvider? _featureProvider;
  ChatInputMode? _lastFeatureMode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newService = context.read<SpeechService>();
    if (_speechService != newService) {
      _speechService?.removeListener(_onSpeechStatusChange);
      _speechService = newService;
      _speechService?.addListener(_onSpeechStatusChange);
    }
    final newProvider = context.read<InputProvider>();
    if (_featureProvider != newProvider) {
      _featureProvider?.removeListener(_onFeatureModeChanged);
      _featureProvider = newProvider;
      _lastFeatureMode = newProvider.featureMode;
      _featureProvider?.addListener(_onFeatureModeChanged);
    }
  }

  void _onFeatureModeChanged() {
    final provider = _featureProvider;
    if (provider == null) return;
    if (provider.featureMode == _lastFeatureMode) return;
    _lastFeatureMode = provider.featureMode;
    _rebuildComposerState();
  }

  void _onSpeechStatusChange() {
    if (!mounted) return;
    final inputProvider = context.read<InputProvider>();
    final speechService = _speechService;

    if (speechService == null) return;

    if (inputProvider.isVoiceRecording && !speechService.isListening) {
      inputProvider.setVoiceRecording(false);
    }
  }

  /// Scheduler-safe re-evaluation of the composer state (focus changes,
  /// feature-mode changes): setState during layout/paint is deferred to the
  /// next frame instead of asserting.
  void _rebuildComposerState() {
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  void _onFocusChange() {
    _rebuildComposerState();
  }

  /// Drives the Voice Mode entry morph from the provider flag. Guarded
  /// like [_syncExpandAnimation]: never starts an animation from inside a
  /// layout/paint phase.
  void _syncVoiceMorphAnimation(bool expanded) {
    void animate() {
      if (expanded) {
        if (_voiceMorphController.status != AnimationStatus.forward &&
            _voiceMorphController.status != AnimationStatus.completed) {
          _voiceMorphController.forward();
        }
      } else {
        if (_voiceMorphController.status != AnimationStatus.reverse &&
            _voiceMorphController.status != AnimationStatus.dismissed) {
          _voiceMorphController.reverse();
        }
      }
    }

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) animate();
      });
    } else {
      animate();
    }
  }

  void _syncExpandAnimation(bool shouldExpand) {
    void animate() {
      if (shouldExpand) {
        if (_expandController.status != AnimationStatus.forward &&
            _expandController.status != AnimationStatus.completed) {
          _expandController.forward();
        }
      } else {
        if (_expandController.status != AnimationStatus.reverse &&
            _expandController.status != AnimationStatus.dismissed) {
          _expandController.reverse();
        }
      }
    }

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) animate();
      });
    } else {
      animate();
    }
  }

  void clearPhotoPanel() {
    context.read<InputProvider>().clearAttachments();
  }

  bool get isActionPermitted {
    final sessionProvider = context.read<ChatSessionProvider>();
    final currentModel = sessionProvider.selectedModel;
    final isVideoModel =
        !widget.isDynamicChatMode &&
        currentModel != null &&
        (currentModel.outputs['video'] == true ||
            currentModel.category == 'video');

    return _inputService.isActionPermitted(
      context: context,
      isServerSideModel: widget.isServerSideModel,
      isDynamicChatMode: widget.isDynamicChatMode,
      isLimitExceeded: widget.isLimitExceeded,
      isSending: widget.isSending,
      modelMissing: widget.modelMissing,
      isStorageSufficient: widget.isStorageSufficient,
      isPremiumModel: widget.isPremiumModel,
      isSubscribed: widget.isSubscribed,
      isVideoModel: isVideoModel,
      userTier: widget.userTier,
      totalCredits: widget.totalCredits,
    );
  }

  bool get isSendButtonEnabled {
    final sessionProvider = context.read<ChatSessionProvider>();
    final currentModel = sessionProvider.selectedModel;
    final isVideoModel =
        !widget.isDynamicChatMode &&
        currentModel != null &&
        (currentModel.outputs['video'] == true ||
            currentModel.category == 'video');

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
      isVideoModel: isVideoModel,
      userTier: widget.userTier,
      totalCredits: widget.totalCredits,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.of(context).size.width;
    final screenWidth = viewportWidth.clamp(0.0, CortexDesign.readingWidth);
    final bool isTablet = screenWidth >= 600;

    // Watched so provider flips (dictation, feature modes, VOICE MODE and
    // its activation) rebuild this subtree: the row reads the
    // provider directly, but the capsule expansion trigger inside it and
    // the voice morphs below depend on this rebuild.
    final inputProvider = context.watch<InputProvider>();
    final bool isVoiceMode = inputProvider.isVoiceModeActive;
    // Voice activation owns this clock; orb expansion cannot reverse it.
    _syncVoiceMorphAnimation(isVoiceMode);

    final double radius = CortexDesign.cardRadius;

    // Keep layout and side-control hit regions mounted as the capsule fades.
    return AnimatedBuilder(
      animation: Listenable.merge([_expandAnimation, _voiceMorphAnimation]),
      builder: (context, child) {
        final double t = _expandAnimation.value;
        // Voice Mode entry morph progress (0 = normal chat, 1 = voice).
        final double voiceT = _voiceMorphAnimation.value;
        // The collapsed pill is drawn at the share composerCapsuleInset()
        // computes (85% of the old share, floored on narrow phones); the
        // expanded share is untouched, so the morph visibly grows the
        // capsule itself. The helper is shared with the edit-mode banner,
        // which hugs the pill exactly.
        final double capsuleInset = lerpDouble(
          composerCapsuleInset(viewportWidth, expanded: false),
          composerCapsuleInset(viewportWidth, expanded: true),
          t,
        )!;
        // The capsule is a painted backdrop: the interactive row beneath
        // it spans the full bar width so the detached "+" and action
        // bubbles stay inside the hit-test bounds of every ancestor.
        // (Painting outside a box is legal with Clip.none, but hit
        // testing is bounds-checked at every level — a control that
        // paints outside its parent simply cannot receive taps.)
        return Padding(
          padding: const EdgeInsets.only(
            bottom: 12.0, // Daha az margin (1-2 cm aşağı çekilmiş hali)
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Painted capsule border/background, inset exactly where the
              // old container sat. The ±1 matches the 1px border that used
              // to wrap this box around the 4px vertical padding.
              //
              // Voice Mode entry: the capsule shrinks inward and fades
              // — the composer keeps its geometry (the compact orb anchors
              // to the panel's top edge) while its visual dissolves to make
              // room for the expanded orb stage.
              Positioned(
                left: CortexDesign.readingInset(viewportWidth) + capsuleInset,
                right: CortexDesign.readingInset(viewportWidth) + capsuleInset,
                top: -1.0,
                bottom: -1.0,
                child: Transform.scale(
                  scaleX: 1.0 - 0.45 * voiceT,
                  scaleY: 1.0 - 0.06 * voiceT,
                  child: Opacity(
                    opacity: 1.0 - voiceT,
                    child: DecoratedBox(
                      key: const ValueKey('composer_capsule'),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(radius),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                    ),
                  ),
                ),
              ),
              // Interactive content. Attachments and the RAG chip are
              // pinned to the capsule interior; the composer row below
              // is deliberately full bar width so its detached bubbles
              // remain inside the hit-test region.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            CortexDesign.readingInset(viewportWidth) +
                            capsuleInset +
                            1.0,
                      ),
                      // Attachments and the RAG chip dissolve with the
                      // capsule in the fullscreen voice stage.
                      child: Opacity(
                        opacity: 1.0 - voiceT,
                        child: IgnorePointer(
                          ignoring: voiceT > 0.05,
                          child: child!,
                        ),
                      ),
                    ),
                    // The composer row is the only mode now. Dictation
                    // keeps the row and the capsule expansion, dims the
                    // "+" for the duration, turns the action button into
                    // Stop, and overlays the field itself with the live
                    // waveform (see [_DictationWave]) — the transcript
                    // reappears once the session ends.
                    _buildExpandingComposerRow(
                      context,
                      screenWidth,
                      isTablet,
                      isSendButtonEnabled,
                      isActionPermitted,
                      0.0,
                      capsuleInset,
                      isVoiceMode: isVoiceMode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      // Attachments and the RAG chip stay off the animation's rebuild
      // path; the composer row is built inside the builder because it
      // needs the animated capsule inset to re-anchor its geometry.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AttachmentPreviewSection(
            screenWidth: screenWidth,
            isTablet: isTablet,
          ),

          _RagStatusChip(screenWidth: screenWidth),
        ],
      ),
    );
  }

  Widget _buildExpandingComposerRow(
    BuildContext context,
    double screenWidth,
    bool isTablet,
    bool isSendButtonEnabled,
    bool isActionPermitted,
    // Pinned to 0 since the waveform swap was retired: a non-null value
    // keeps the microphone visible while dictation runs, and the mic dims
    // and ignores taps for the duration.
    double recordingProgress,
    // Animated inset between the bar edge and the capsule border. The row
    // is wider than the capsule, so it re-anchors every interior-relative
    // control back to the capsule with this.
    double capsuleInset, {
    // Voice Mode V2: locks the text field (the voice session owns the
    // input path) and drives the fullscreen outward control shift.
    required bool isVoiceMode,
  }) {
    final inputProvider = context.read<InputProvider>();
    // Dictation expands the capsule as well, so the speech transcript
    // lands in the roomy field instead of the compact pill.
    final bool isDictating = inputProvider.isVoiceRecording;
    // So does content sitting in the field: words must never be dropped
    // back into the compact pill — not even once the field loses focus.
    // (initState listens to the controller and rebuilds exactly when the
    // empty↔non-empty flip happens, so the capsule animates once here,
    // not on every keystroke.)
    final bool hasText = widget.controller.text.trim().isNotEmpty;
    // The CANONICAL "+" active-feature state (see [composerFeatureActive] in
    // buttons.dart) — the same state that turns the bubble's border/background
    // inverted. An active feature selection (a `+` feature, web search, RAG,
    // or a model-implied mode like offline/image/video/audio) is meaningful
    // input state: the capsule stays open with the keyboard closed, the field
    // unfocused and empty, and no dictation, so the active `+` control can
    // never be collapsed away. Collapse is legal only when it AND every other
    // activity signal are all absent.
    final bool hasActiveFeature = composerFeatureActive(
      inputProvider,
      context.read<ChatSessionProvider>().selectedModel,
    );
    final bool isComposerExpanded =
        widget.textFieldFocusNode.hasFocus ||
        isDictating ||
        hasText ||
        hasActiveFeature;
    final bool hasSelectedFeature = hasActiveFeature;

    _syncExpandAnimation(isComposerExpanded);

    // Shared composer geometry. The capsule is compact while collapsed (all
    // controls inside) and opens slightly once expanded, at which point the
    // detachable "+" and action bubbles float outside its border while the
    // microphone stays anchored inside.
    final double buttonSize = buttonSizeFor(screenWidth);

    return LayoutBuilder(
      builder: (context, constraints) {
        // The row spans the FULL bar width (the capsule is only a painted
        // backdrop behind it), so the detached bubbles stay inside the
        // hit-test bounds of the row and of every ancestor above it.
        //
        // Offset from the row edge to the capsule interior — reading inset
        // + animated capsule inset + the 1px capsule border — which is
        // also the horizontal room between the capsule border and the
        // screen edge, per side. Every interior-relative control below is
        // re-anchored to the capsule border with it.
        final double base =
            CortexDesign.readingInset(MediaQuery.sizeOf(context).width) +
            capsuleInset +
            1.0;
        final double outerMargin = base;

        return AnimatedBuilder(
          animation: Listenable.merge([_expandAnimation, _voiceMorphAnimation]),
          builder: (context, child) {
            final double t = _expandAnimation.value;
            // Voice Mode entry morph progress (0 = normal chat, 1 = voice).
            final double voiceT = _voiceMorphAnimation.value;

            // The detachable bubbles swell slowly along with the expansion.
            final double buttonScale = lerpDouble(1.0, expandedButtonGrow, t)!;
            final double grownButtonSize = buttonSize * buttonScale;

            // Detached bubbles ride in the margin between the capsule border
            // and the screen edge, offset so the screen-side gap is ~3x the
            // capsule-side gap (0.25 / 0.75 of the free space). The clamp
            // keeps them inside the screen on narrow viewports.
            final double freeSpace = outerMargin - 1 - grownButtonSize;
            final double screenSideGap = freeSpace * detachedScreenShare;
            final double detach =
                outerMargin -
                (screenSideGap > screenEdgeGap ? screenSideGap : screenEdgeGap);

            // Reuse the normal composer's detached control destination.
            // Voice entry owns this movement independently of orb expansion.
            final double controlOffset = lerpDouble(
              lerpDouble(edgeGap, -detach, t)!,
              -detach,
              voiceT,
            )!;
            final double plusLeft = controlOffset;
            final double actionRight = controlOffset;
            // The microphone never detaches; it slides to the interior right
            // edge once the action button vacates its collapsed slot.
            final double micRight = lerpDouble(
              edgeGap + buttonSize + buttonGap,
              edgeGap,
              t,
            )!;

            // The text field fills the space left between the controls; the
            // compact capsule itself provides the small overall footprint.
            final double inputLeft = lerpDouble(
              edgeGap + buttonSize + inputGap,
              inputEdgeGap,
              t,
            )!;
            final double inputRight = lerpDouble(
              edgeGap + buttonSize * 2 + buttonGap + inputGap,
              edgeGap + buttonSize + inputGap,
              t,
            )!;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: base + inputLeft,
                    right: base + inputRight,
                  ),
                  // The text field dissolves with the capsule in the
                  // fullscreen voice stage (the orb owns the interaction),
                  // and in compact voice mode it is read-only: the voice
                  // session owns the input path and the keyboard may never
                  // reopen over it.
                  child: Opacity(
                    opacity: 1.0 - voiceT,
                    child: IgnorePointer(
                      ignoring: isVoiceMode,
                      child: Stack(
                        children: [
                          _TextFieldSection(
                            key: const ValueKey('textfield'),
                            controller: widget.controller,
                            focusNode: widget.textFieldFocusNode,
                            localizations: widget.localizations,
                            screenWidth: screenWidth,
                            isTablet: isTablet,
                            showHintText: true,
                            isComposerExpanded: isComposerExpanded,
                            isDictating: isDictating,
                            isVoiceLocked: isVoiceMode,
                            onEnterPressed: () {
                              if (isSendButtonEnabled) {
                                widget.onSend();
                              }
                            },
                          ),
                          // While dictation runs the field is covered by the
                          // animated waveform — the takeover the retired
                          // recording layout used to perform, now confined to
                          // the field slot so the capsule, the dimmed "+" and
                          // Stop all stay where they were. The switcher gives
                          // the sheet its fade in/out; the wave itself
                          // undulates with the detected sound level.
                          Positioned.fill(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              switchInCurve: Curves.easeOutQuad,
                              switchOutCurve: Curves.easeInQuad,
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                              child: isDictating
                                  ? const _DictationWave(
                                      key: ValueKey('dictation_wave'),
                                    )
                                  : const SizedBox.shrink(
                                      key: ValueKey('dictation_idle'),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: base + plusLeft,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: AddPhotoButton(
                      isLimitExceeded: widget.isLimitExceeded,
                      isPhotoLoading: widget.isPhotoLoading,
                      localizations: widget.localizations,
                      controller: widget.controller,
                      hasSelectedFeature: hasSelectedFeature,
                      isDimmed: isDictating,
                      bubbleProgress: t,
                      bubbleScale: buttonScale,
                    ),
                  ),
                ),
                Positioned(
                  right: base + micRight,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: MicButton(
                      controller: widget.controller,
                      isSending: widget.isSending,
                      recordingProgress: recordingProgress,
                    ),
                  ),
                ),
                Positioned(
                  right: base + actionRight,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _SendButtonSection(
                      screenWidth: screenWidth,
                      isTablet: isTablet,
                      widget: widget,
                      recordingProgress: recordingProgress,
                      isEnabled: isSendButtonEnabled,
                      isActionPermitted: isActionPermitted,
                      controller: widget.controller,
                      bubbleScale: buttonScale,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
