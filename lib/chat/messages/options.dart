// options.dart

import 'dart:ui' as ui; // For ImageFilter.blur
import 'dart:math' as math; // For math.min
import 'package:cortex/main.dart';
import 'package:flutter/foundation.dart'; // For ValueListenable and kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard and SystemChrome
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart'; // For NotificationService
import 'package:cortex/l10n/app_localizations.dart'; // For localizations
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../notifications.dart';
import '../../theme.dart'; // For AppColors
import '../../models/backend/data.dart'; // For ModelData
import '../messages/select.dart'; // For SelectTextScreen

// Durations for animations used within this file.
const Duration _kShortAnimationDuration = Duration(milliseconds: 100);
const Duration _kMediumAnimationDuration = Duration(milliseconds: 150);
const Duration _kLongAnimationDuration = Duration(milliseconds: 200);

// Default value for model IDs if none is provided or resolvable.
const String _kDefaultModelId = 'default_model_id'; // Used as a fallback

class _UIFactors {
  // General Panel and Option Metrics
  static const double panelWidthFactor = 0.4;          // Panel width as a factor of screen width
  static const double optionHeightFactor = 0.06;       // Default option item height as a factor of screen height
  static const double marginFactor = 0.04;             // General margin as a factor of screen width
  static const double borderRadiusFactor = 0.02;       // Border radius for panels/options as a factor of screen width
  static const double iconSizeFactor = 0.055;          // Default icon size as a factor of screen width
  static const double largerIconSizeFactor = 0.065;    // Larger icon size (e.g., for report) as a factor of screen width
  static const double horizontalPaddingFactor = 0.04;  // Horizontal padding within options as a factor of screen width
  static const double changeModelVerticalPaddingFactor = 0.012; // Specific vertical padding for 'Change Model' option
  static const double defaultFontSizeFactor = 0.035;   // Default font size for option text as a factor of screen width
  static const double iconTextSpacingFactor = 0.025;   // Space between icon and text in an option as a factor of screen width
  static const double reportIconOffsetFactor = -0.01;  // Horizontal offset for the report icon as a factor of screen width

  // Dialog Specific Metrics
  static const double dialogWidthFactor = 0.70;        // Dialog width as a factor of screen width
  static const double dialogIconSizeFactor = 0.08;     // Icon size within dialogs as a factor of screen width
  static const double dialogTitleFontSizeFactor = 0.04;// Font size for dialog titles as a factor of screen width
  static const double dialogItemFontSizeFactor = 0.035;// Font size for items within dialogs (e.g., radio list tiles)
  static const double dialogMaxContentHeightFactor = 0.3; // Max height for scrollable content in dialogs (e.g., model list)

  // Dialog Spacing Metrics
  static const double dialogVerticalSpacingFactor = 0.02;    // General vertical spacing in dialogs (e.g., around title)
  static const double dialogSmallVerticalSpacingFactor = 0.008; // Smaller vertical spacing in dialogs
  static const double dialogItemVerticalSpacingFactor = 0.01; // Vertical spacing between items in a list within a dialog
  static const double dialogButtonVerticalPaddingFactor = 0.016; // Vertical padding for buttons in dialogs
  static const double dialogHorizontalPaddingFactor = 0.02; // Horizontal padding within dialog content areas
}


/// Enum representing the available actions (options) for a message.
enum MessageOption {
  /// Option to copy the message text to the clipboard.
  copy,
  /// Option to report the message.
  report,
  /// Option to request regeneration of the AI's response.
  regenerate,
  /// Option to open a screen for selecting parts of the message text.
  select,
  /// Option to stop an ongoing AI response generation.
  stop,
  /// Option to change the model or model extension for the current context.
  changeModel,
  /// Option to edit the user's own message.
  edit,
}


class AnimatedMessageOptionsPanel extends StatefulWidget {
  final String messageText;
  final ValueNotifier<String> messageNotifier;
  final List<MessageOption> options;
  final bool isReported;
  final VoidCallback? onReport;
  final VoidCallback onDismiss;
  final Offset position;
  final String? modelIdAndExtension;
  final VoidCallback? onRegenerate;
  final ValueChanged<String>? onChangeModel;
  final VoidCallback? onStop;
  final VoidCallback? onEdit;
  final bool conversationHasPhoto;
  final bool? isThinking;
  final ValueListenable<bool>? isThinkingNotifier;
  final ValueNotifier<bool>? isWaitingForResponseNotifier;
  final bool isSubscribed;
  final int premiumTrialUses;
  final bool? isPersistentlyDynamic;

  const AnimatedMessageOptionsPanel({
    Key? key,
    required this.messageText,
    required this.messageNotifier,
    required this.options,
    this.isReported = false,
    this.onReport,
    required this.onDismiss,
    required this.position,
    this.modelIdAndExtension,
    this.onRegenerate,
    this.onStop,
    this.onChangeModel,
    this.onEdit,
    this.isThinking,
    this.isThinkingNotifier,
    required this.conversationHasPhoto,
    this.isWaitingForResponseNotifier,
    required this.isSubscribed,
    required this.premiumTrialUses,
    this.isPersistentlyDynamic,
  }) : super(key: key);

  @override
  _AnimatedMessageOptionsPanelState createState() =>
      _AnimatedMessageOptionsPanelState();
}

class _AnimatedMessageOptionsPanelState extends State<AnimatedMessageOptionsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _hasInternet = true;
  late String _currentModelId;

  VoidCallback? _thinkingListenerCallback;
  VoidCallback? _waitingListenerCallback;
  bool _wasWaitingForResponse = false;

  double _panelWidth = 0;
  double _optionHeight = 0;

  @override
  void initState() {
    super.initState();
    const String logPrefix = "[AnimatedMessageOptionsPanel.initState]";
    debugPrint("$logPrefix Initializing...");

    _initializeCurrentModelId(widget.modelIdAndExtension, logPrefix);

    _animationController = AnimationController(
      duration: _kShortAnimationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _checkInternetConnection();
    _setupListeners(logPrefix);

    _animationController.forward();
    debugPrint("$logPrefix Initialization complete. Animation controller forwarded.");
  }

  void _initializeCurrentModelId(String? rawModelIdFromWidget, String logPrefix) {
    _currentModelId = rawModelIdFromWidget ?? _kDefaultModelId;
    debugPrint("$logPrefix Effective _currentModelId set to: '$_currentModelId' (prefixes protected)");
  }

  void _setupListeners(String logPrefix) {
    if (widget.isThinkingNotifier != null) {
      _thinkingListenerCallback = () {
        if (mounted && widget.isThinkingNotifier!.value == false && _animationController.status != AnimationStatus.reverse) {
          debugPrint("$logPrefix isThinkingNotifier changed to false. Dismissing panel.");
          _dismissPanel();
        }
      };
      widget.isThinkingNotifier!.addListener(_thinkingListenerCallback!);
      debugPrint("$logPrefix Added listener to isThinkingNotifier.");
    }

    if (widget.isWaitingForResponseNotifier != null) {
      _wasWaitingForResponse = widget.isWaitingForResponseNotifier!.value;
      _waitingListenerCallback = () {
        if (mounted) {
          final bool isCurrentlyWaiting = widget.isWaitingForResponseNotifier!.value;
          bool shouldDismissPanel = false;

          if (_wasWaitingForResponse && !isCurrentlyWaiting && _animationController.status != AnimationStatus.reverse) {
            debugPrint("$logPrefix isWaitingForResponseNotifier: Was waiting, now not waiting. Flagging for dismissal.");
            shouldDismissPanel = true;
          }
          _wasWaitingForResponse = isCurrentlyWaiting;

          // Recalculate visible options based on the new waiting state.
          final List<MessageOption> newVisibleOptions = _calculateVisibleOptions(
              isCurrentlyWaiting,
              widget.isThinkingNotifier?.value ?? widget.isThinking ?? false);

          if (newVisibleOptions.isEmpty && _animationController.status != AnimationStatus.reverse) {
            debugPrint("$logPrefix isWaitingForResponseNotifier: No visible options remain. Flagging for dismissal.");
            shouldDismissPanel = true;
          }

          if (shouldDismissPanel) {
            _dismissPanel();
          } else if (mounted) {
            // If not dismissing, options might have changed, so trigger a rebuild.
            debugPrint("$logPrefix isWaitingForResponseNotifier: State changed, visible options might differ. Triggering setState.");
            setState(() {});
          }
        }
      };
      widget.isWaitingForResponseNotifier!.addListener(_waitingListenerCallback!);
      debugPrint("$logPrefix Added listener to isWaitingForResponseNotifier. Initial _wasWaitingForResponse: $_wasWaitingForResponse");
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedMessageOptionsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    const String logPrefix = "[AnimatedMessageOptionsPanel.didUpdateWidget]";
    debugPrint("$logPrefix Widget updated.");

    if (widget.modelIdAndExtension != oldWidget.modelIdAndExtension) {
      debugPrint("$logPrefix modelIdAndExtension changed from '${oldWidget.modelIdAndExtension}' to '${widget.modelIdAndExtension}'.");
      _initializeCurrentModelId(widget.modelIdAndExtension, logPrefix);
    }

    // Handle direct isThinking prop change if notifier is not used primarily for this.
    final bool oldThinkingProp = oldWidget.isThinking ?? false;
    final bool newThinkingProp = widget.isThinking ?? false;
    if (oldThinkingProp && !newThinkingProp && _animationController.status != AnimationStatus.reverse) {
      debugPrint("$logPrefix Direct 'isThinking' prop changed from true to false. Dismissing panel.");
      _dismissPanel();
    }

    // Update isThinkingNotifier listener if it has changed.
    if (oldWidget.isThinkingNotifier != widget.isThinkingNotifier) {
      debugPrint("$logPrefix isThinkingNotifier instance changed. Re-assigning listener.");
      if (_thinkingListenerCallback != null) {
        oldWidget.isThinkingNotifier?.removeListener(_thinkingListenerCallback!);
      }
      if (widget.isThinkingNotifier != null) {
        _thinkingListenerCallback = () { // Re-define to capture new widget instance
          if (mounted && widget.isThinkingNotifier!.value == false && _animationController.status != AnimationStatus.reverse) {
            debugPrint("$logPrefix (New) isThinkingNotifier changed to false. Dismissing panel.");
            _dismissPanel();
          }
        };
        widget.isThinkingNotifier!.addListener(_thinkingListenerCallback!);
      } else {
        _thinkingListenerCallback = null;
      }
    }

    // Update isWaitingForResponseNotifier listener if it has changed.
    if (oldWidget.isWaitingForResponseNotifier != widget.isWaitingForResponseNotifier) {
      debugPrint("$logPrefix isWaitingForResponseNotifier instance changed. Re-assigning listener.");
      if (_waitingListenerCallback != null) {
        oldWidget.isWaitingForResponseNotifier?.removeListener(_waitingListenerCallback!);
      }
      if (widget.isWaitingForResponseNotifier != null) {
        _wasWaitingForResponse = widget.isWaitingForResponseNotifier!.value; // Reset state with new notifier
        _waitingListenerCallback = () { // Re-define to capture new widget instance
          if (mounted) {
            final bool isCurrentlyWaiting = widget.isWaitingForResponseNotifier!.value;
            bool dismiss = false;
            if (_wasWaitingForResponse && !isCurrentlyWaiting && _animationController.status != AnimationStatus.reverse) {
              debugPrint("$logPrefix (New) isWaitingForResponseNotifier: Was waiting, now not. Dismissing.");
              dismiss = true;
            }
            _wasWaitingForResponse = isCurrentlyWaiting;

            if (!dismiss) { // Avoid redundant calculation if already dismissing
              final List<MessageOption> newVisibleOptions = _calculateVisibleOptions(
                  isCurrentlyWaiting,
                  widget.isThinkingNotifier?.value ?? widget.isThinking ?? false);
              if (newVisibleOptions.isEmpty && _animationController.status != AnimationStatus.reverse) {
                debugPrint("$logPrefix (New) isWaitingForResponseNotifier: No visible options. Dismissing.");
                dismiss = true;
              }
            }

            if (dismiss) {
              _dismissPanel();
            } else if (mounted) {
              debugPrint("$logPrefix (New) isWaitingForResponseNotifier: State changed. Triggering setState.");
              setState(() {});
            }
          }
        };
        widget.isWaitingForResponseNotifier!.addListener(_waitingListenerCallback!);
      } else {
        _waitingListenerCallback = null;
      }
    }
  }

  Future<void> _checkInternetConnection() async {
    const String logPrefix = "[AnimatedMessageOptionsPanel._checkInternetConnection]";
    try {
      final hasInternet = await InternetConnection().hasInternetAccess;
      if (mounted) {
        setState(() {
          _hasInternet = hasInternet;
        });
        debugPrint("$logPrefix Internet access: $_hasInternet. State updated.");
      } else {
        debugPrint("$logPrefix Not mounted after check. Internet access: $hasInternet.");
      }
    } catch (e) {
      debugPrint("$logPrefix Error checking internet: $e. Assuming no internet for safety.");
      if (mounted) {
        setState(() {
          _hasInternet = false;
        });
      }
    }
  }

  void _dismissPanel() {
    const String logPrefix = "[AnimatedMessageOptionsPanel._dismissPanel]";
    if (!mounted) {
      debugPrint("$logPrefix Attempted to dismiss but not mounted. Aborting.");
      return;
    }
    debugPrint("$logPrefix Dismissing panel. Current animation status: ${_animationController.status}");

    if (_animationController.status == AnimationStatus.forward ||
        _animationController.status == AnimationStatus.completed) {
      _animationController.reverse().then((_) {
        if (mounted) {
          debugPrint("$logPrefix Animation reversed. Calling onDismiss.");
          widget.onDismiss();
        } else {
          debugPrint("$logPrefix Not mounted after animation reverse. onDismiss not called.");
        }
      });
    } else if (_animationController.status == AnimationStatus.dismissed) {
      debugPrint("$logPrefix Panel was already in dismissed animation state. Calling onDismiss directly.");
      widget.onDismiss();
    } else {
      debugPrint("$logPrefix Panel in an intermediate animation state (${_animationController.status}). Reverse not initiated.");
    }
  }

  /// [REBUILT] Determines which options should be visible based on the current app state.
  /// This now correctly handles the "Change Model" option for dynamic chats.
  List<MessageOption> _calculateVisibleOptions(bool isChatScreenWaiting, bool isMessageCurrentlyThinking) {
    const String logPrefix = "[AnimatedMessageOptionsPanel._calculateVisibleOptions]";
    if (!mounted) {
      debugPrint("$logPrefix Not mounted. Returning empty list.");
      return [];
    }

    final modelSeriesData = _findParentSeriesData();
    // This is our key condition to identify a dynamic chat context.
    final bool isDynamicContext = modelSeriesData.isEmpty;

    final bool isOfflineModel = (modelSeriesData['type'] as String? ?? 'online') == 'offline';
    final bool currentModelCanHandleImages = ModelData.hasModality(_currentModelId, 'image');
    final bool hasPremiumAccess = widget.isSubscribed || widget.premiumTrialUses < 3;
    final bool isCurrentModelPremium = (ModelData.getPreciseModelData(_currentModelId)['tier'] as String? ?? 'free') == 'premium';

    return widget.options.where((option) {
      String reason = "";
      bool shouldShow = true;

      // Universal rule: Don't show destructive/new actions while the app is busy.
      if (isChatScreenWaiting && (option == MessageOption.regenerate || option == MessageOption.changeModel || option == MessageOption.edit)) {
        shouldShow = false;
        reason = "Chat screen is globally waiting for a response.";
      }

      // 'Stop' should only appear when the AI is actively generating a response.
      if (shouldShow && option == MessageOption.stop && !isMessageCurrentlyThinking) {
        shouldShow = false;
        reason = "Message is not currently thinking.";
      }

      // Rules for 'Regenerate'.
      if (shouldShow && option == MessageOption.regenerate) {
        if (isCurrentModelPremium && !hasPremiumAccess) {
          shouldShow = false;
          reason = "Model is premium and user has no access.";
        } else if (isOfflineModel || !_hasInternet) {
          shouldShow = false;
          reason = "Regenerate is not supported for offline models or without internet.";
        }
      }

      // Universal rule for actions that would break if a photo is present but the model can't handle it.
      if (shouldShow && widget.conversationHasPhoto && !currentModelCanHandleImages) {
        if (option == MessageOption.regenerate || option == MessageOption.edit || option == MessageOption.changeModel) {
          shouldShow = false;
          reason = "Conversation has a photo, but current model ('$_currentModelId') cannot process images.";
        }
      }

      // --- THE CORE LOGIC FIX ---
      if (shouldShow && option == MessageOption.changeModel) {
        if (isDynamicContext) {
          // In a dynamic chat, ALWAYS allow changing the model. The dialog will show all available models.
          shouldShow = true;
        } else {
          // In a standard chat, only show if there are other extensions to switch to.
          final int validExtCount = _validExtensionCountForChangingModel(modelSeriesData);
          if (validExtCount <= 1) {
            shouldShow = false;
            reason = "Standard chat: Not enough other extensions to change to (found $validExtCount).";
          }
        }
      }

      // 'Report' should not appear if already reported.
      if (shouldShow && option == MessageOption.report && widget.isReported) {
        shouldShow = false;
        reason = "Message has already been reported.";
      }

      if (!shouldShow && kDebugMode) {
        debugPrint("$logPrefix   Option $option WILL NOT be shown. Reason: $reason");
      }

      return shouldShow;
    }).toList();
  }

  // ... (_findParentSeriesData, _validExtensionCountForChangingModel are unchanged)
  Map<String, dynamic> _findParentSeriesData() {
    const String logPrefix = "[AnimatedMessageOptionsPanel._findParentSeriesData]";
    if (!mounted || _currentModelId == _kDefaultModelId) return {};

    final allCachedModels = ModelData.getCachedModelsSync();
    if (allCachedModels.isEmpty) {
      debugPrint("$logPrefix ModelData cache is empty. Cannot find parent series for '$_currentModelId'.");
      return {};
    }

    for (final seriesData in allCachedModels) {
      final extensionsMap = seriesData['extensions'] as Map<String, dynamic>?;
      if (extensionsMap?.containsKey(_currentModelId) ?? false) {
        debugPrint("$logPrefix Found parent series '${seriesData['id']}' for extension '$_currentModelId'.");
        return seriesData;
      }
    }

    final directMatch = allCachedModels.firstWhere((m) => m['id'] == _currentModelId, orElse: () => {});
    if (directMatch.isNotEmpty) {
      debugPrint("$logPrefix Found direct match for '$_currentModelId' (it's a base model itself).");
      return directMatch;
    }

    debugPrint("$logPrefix CRITICAL: Could not find any parent series or direct match for '$_currentModelId'.");
    return {};
  }

  int _validExtensionCountForChangingModel(Map<String, dynamic> parentSeriesData) {
    const String logPrefix = "[AnimatedMessageOptionsPanel._validExtensionCountForChangingModel]";

    if (parentSeriesData.isEmpty) {
      debugPrint("$logPrefix No parent series data provided. Returning 0.");
      return 0;
    }

    final seriesId = parentSeriesData['id'] ?? 'unknown_series';
    debugPrint("$logPrefix Calculating for series: '$seriesId', conversationHasPhoto: ${widget.conversationHasPhoto}");

    final extMap = parentSeriesData['extensions'] as Map<String, dynamic>?;
    if (extMap == null || extMap.isEmpty) {
      debugPrint("$logPrefix No 'extensions' map for '$seriesId'. Returning 0.");
      return 0;
    }

    debugPrint("$logPrefix Found ${extMap.length} total extensions for '$seriesId'.");

    int count = 0;
    extMap.entries.forEach((entry) {
      final dynamic extensionData = entry.value;
      bool isValidForChange = false;

      if (extensionData is Map) {
        if (widget.conversationHasPhoto) {
          isValidForChange = (extensionData['canHandleImage'] ?? false) == true;
        } else {
          isValidForChange = true;
        }
      }
      if (isValidForChange) count++;
    });

    debugPrint("$logPrefix Final valid extension count for '$seriesId': $count");
    return count;
  }

  // ... (build and all other methods are unchanged from your provided code, as they were already correct)
  @override
  Widget build(BuildContext context) {
    const String logPrefix = "[AnimatedMessageOptionsPanel.build]";
    debugPrint("$logPrefix Building panel. Current _currentModelId: '$_currentModelId'");

    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom; // For positioning above keyboard

    // Initialize panel dimensions based on screen size
    _panelWidth = screenWidth * _UIFactors.panelWidthFactor;
    _optionHeight = screenHeight * _UIFactors.optionHeightFactor; // Default height for an option
    final double optionBorderRadius = screenWidth * _UIFactors.borderRadiusFactor;
    final double margin = screenWidth * _UIFactors.marginFactor; // Margin from screen edges

    // Determine currently active states for filtering options
    final bool isCurrentlyWaiting = widget.isWaitingForResponseNotifier?.value ?? false;
    final bool isMessageThinking = widget.isThinkingNotifier?.value ?? widget.isThinking ?? false;
    debugPrint("$logPrefix States for _calculateVisibleOptions: isCurrentlyWaiting=$isCurrentlyWaiting, isMessageThinking=$isMessageThinking");

    final List<MessageOption> visibleOpts = _calculateVisibleOptions(isCurrentlyWaiting, isMessageThinking);
    debugPrint("$logPrefix Calculated ${visibleOpts.length} visible options: $visibleOpts");


    if (visibleOpts.isEmpty) {
      // If no options are visible (e.g., due to state changes after panel opened),
      // schedule dismissal for after the current frame.
      debugPrint("$logPrefix No visible options. Scheduling panel dismissal.");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dismissPanel();
      });
      return const SizedBox.shrink(); // Render nothing while preparing to dismiss
    }

    // Approximate panel height based on number of options and default option height.
    // Note: _buildChangeModelOption might have a different height due to longer text.
    // For precise height, one might need to measure or use intrinsic height widgets if significantly variable.
    final double estimatedPanelHeight = visibleOpts.fold(0.0, (sum, opt) {
      if (opt == MessageOption.changeModel) {
        // A more accurate height for changeModel if its padding is different
        return sum + (_optionHeight.clamp(
            screenHeight * _UIFactors.optionHeightFactor, // Min
            screenHeight * (_UIFactors.optionHeightFactor + _UIFactors.changeModelVerticalPaddingFactor * 2) // Max approx
        ));
      }
      return sum + _optionHeight;
    });
    debugPrint("$logPrefix Estimated panel height: $estimatedPanelHeight based on ${visibleOpts.length} options.");


    // Calculate panel position, ensuring it stays within screen bounds.
    double targetLeft = widget.position.dx;
    double targetTop = widget.position.dy;

    // Adjust horizontally if panel overflows right edge
    if (targetLeft + _panelWidth > screenWidth - margin) {
      targetLeft = widget.position.dx - _panelWidth; // Try to position to the left of tap
      if (targetLeft < margin) targetLeft = margin; // Clamp to left margin
    }
    // Adjust vertically if panel overflows bottom edge (considering keyboard)
    if (targetTop + estimatedPanelHeight > screenHeight - margin - keyboardHeight) {
      targetTop = widget.position.dy - estimatedPanelHeight; // Try to position above tap
      if (targetTop < margin) targetTop = margin; // Clamp to top margin
    }
    debugPrint("$logPrefix Final panel position: Left=$targetLeft, Top=$targetTop");


    // Construct the panel content with visible options
    Widget panelContainer = Container(
      width: _panelWidth,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor, // Theme-dependent background
        borderRadius: BorderRadius.circular(optionBorderRadius),
        boxShadow: const [ // Standard shadow for depth
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Panel should only be as tall as its content
        children: visibleOpts.map((opt) {
          // Build a specific widget for each option type
          switch (opt) {
            case MessageOption.copy: return _buildCopyOption(context, optionBorderRadius);
            case MessageOption.report: return _buildReportOption(context, optionBorderRadius);
            case MessageOption.regenerate: return _buildRegenerateOption(context, optionBorderRadius);
            case MessageOption.select: return _buildSelectOption(context, optionBorderRadius);
            case MessageOption.changeModel: return _buildChangeModelOption(context, optionBorderRadius);
            case MessageOption.stop: return _buildStopOption(context, optionBorderRadius);
            case MessageOption.edit: return _buildEditOption(context, optionBorderRadius);
          }
        }).toList(),
      ),
    );

    // Apply blur effect to the panel using BackdropFilter
    Widget finalPanelWithBlur = ClipRRect( // ClipRRect ensures blur doesn't bleed outside rounded corners
      borderRadius: BorderRadius.circular(optionBorderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0), // Standard blur values
        child: panelContainer,
      ),
    );

    // The main structure: a transparent overlay for tap-outside-to-dismiss,
    // and the animated panel itself.
    return Material(
      color: Colors.transparent, // Material widget for InkWell and theming
      child: Stack(
        children: [
          // Full-screen GestureDetector to dismiss the panel when tapping outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                debugPrint("$logPrefix Tapped outside panel. Dismissing.");
                _dismissPanel();
              },
              behavior: HitTestBehavior.opaque, // Catches taps on transparent areas
              child: Container(color: Colors.transparent),
            ),
          ),
          // The animated panel, positioned and scaled
          AnimatedPositioned(
            duration: _kLongAnimationDuration, // Smooth repositioning
            curve: Curves.easeOut,
            left: targetLeft,
            top: targetTop,
            child: ScaleTransition(
              scale: _scaleAnimation, // Appearance/disappearance scale animation
              child: finalPanelWithBlur,
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a raw model ID string (e.g., "gemini-1.5-pro") into a display-friendly format
  /// (e.g., "Gemini 1.5 Pro").
  String formatModelId(String rawText) {
    if (rawText.isEmpty) return "";
    // Handle common prefixes or specific model name formatting if needed
    String processedText = rawText;
    if (rawText.startsWith('google/')) {
      processedText = rawText.substring('google/'.length);
    }
    // Add more prefix removals if necessary (e.g., 'openai/')

    final parts = processedText.split('-').map((segment) {
      if (segment.isEmpty) return segment;
      // Capitalize common terms correctly
      if (segment.toLowerCase() == 'gb') return 'GB';
      if (segment.toLowerCase() == 'mb') return 'MB';
      if (segment.toLowerCase() == 'kb') return 'KB';
      // Basic capitalization for other segments
      return segment[0].toUpperCase() + segment.substring(1);
    }).toList();
    return parts.join(' ');
  }

  /// Darkens a given [Color] by a [factor] (0.0 to 1.0) towards black.
  Color darkenWithBlack(Color color, double factor) {
    assert(factor >= 0 && factor <= 1, "Factor must be between 0.0 and 1.0");
    final r = (color.red * (1.0 - factor)).round().clamp(0, 255);
    final g = (color.green * (1.0 - factor)).round().clamp(0, 255);
    final b = (color.blue * (1.0 - factor)).round().clamp(0, 255);
    return Color.fromARGB(color.alpha, r, g, b);
  }

  /// Shows a dialog for selecting a model.
  ///
  /// DUAL MODE OPERATION:
  /// 1. STANDARD MODE: If a parent model series is found, it lists the extensions of that series.
  /// 2. DYNAMIC MODE: If no parent series is found (typical for dynamic chat), it lists ALL
  ///    available models, categorized and sorted alphabetically. It now correctly filters
  ///    offline models to show ONLY those that are downloaded.
  ///
  /// [currentFullModelId] is the ID of the currently active model/extension.
  /// Returns the ID of the selected model/extension, or null if cancelled.
  Future<String?> _showModelExtensionsDialog(BuildContext context, String currentFullModelId) async {
    const String logPrefix = "[AnimatedMessageOptionsPanel._showModelExtensionsDialog]";

    // 1. Get the IDs of all offline models that are actually downloaded on the device.
    // This is now possible thanks to a static method in the `UserModels` class.
    final downloadedModelPaths = await UserModels.loadDownloadedModelPaths();
    final Set<String> downloadedModelIds = downloadedModelPaths.keys.toSet();
    debugPrint("$logPrefix Found ${downloadedModelIds.length} downloaded offline models on device.");

    final modelSeriesData = _findParentSeriesData();
    // Determine if we are in dynamic chat mode.
    final bool isDynamicModeDialog = widget.isPersistentlyDynamic!;
    final String dialogTitle = AppLocalizations.of(context)!.changeModel;

    debugPrint("$logPrefix Showing dialog. Is Dynamic Mode: $isDynamicModeDialog. Current full ID: '$currentFullModelId'");

    final bool hasPremiumAccess = widget.isSubscribed || widget.premiumTrialUses < 3;
    debugPrint("$logPrefix User premium access status: $hasPremiumAccess (Subscribed: ${widget.isSubscribed}, Trials Used: ${widget.premiumTrialUses})");

    List<Map<String, dynamic>> itemsForDialog = [];

    if (isDynamicModeDialog) {
      // --- DYNAMIC MODE: LIST ALL AVAILABLE MODELS (FILTERED) ---
      debugPrint("$logPrefix Dynamic Mode: Building list of all available models with correct filtering.");
      final allModelInfos = ModelData.getCachedModelsSync();
      final List<Map<String, dynamic>> onlineOptions = [];
      final List<Map<String, dynamic>> offlineOptions = []; // Start with an empty list
      final List<Map<String, dynamic>> characterOptions = [];
      final List<Map<String, dynamic>> selfOptions = [];
      final localizations = AppLocalizations.of(context)!;

      for (final modelMap in allModelInfos) {
        final preciseData = ModelData.getPreciseModelData(modelMap['id'] as String);
        final String category = preciseData['category'] as String? ?? 'online';
        final String type = preciseData['type'] as String? ?? 'online';
        final String modelId = preciseData['id'] as String;

        if (category == 'roleplay') {
          characterOptions.add(preciseData);
        } else if (category == 'self') {
          selfOptions.add(preciseData);
        }
        // *** CHANGE START: OFFLINE MODEL FILTER ***
        // 2. If a model's type is 'offline', add it to the list ONLY if its ID exists in the `downloadedModelIds` set.
        else if (type == 'offline') {
          if (downloadedModelIds.contains(modelId)) {
            offlineOptions.add(preciseData);
            debugPrint("$logPrefix   - Adding downloaded offline model to list: '$modelId'");
          } else {
            debugPrint("$logPrefix   - SKIPPING offline model, not downloaded: '$modelId'");
          }
        }
        // *** CHANGE END ***
        else if (type == 'online') {
          final extensions = preciseData['extensions'] as Map<String, dynamic>?;
          if (extensions != null && extensions.isNotEmpty) {
            for (final extId in extensions.keys) {
              onlineOptions.add(ModelData.getPreciseModelData(extId));
            }
          } else {
            onlineOptions.add(preciseData);
          }
        }
      }

      // Sort alphabetically
      final sorter = (Map<String, dynamic> a, Map<String, dynamic> b) =>
          (a['title'] as String).toLowerCase().compareTo((b['title'] as String).toLowerCase());

      onlineOptions.sort(sorter);
      offlineOptions.sort(sorter); // The downloaded models are sorted amongst themselves
      characterOptions.sort(sorter);
      selfOptions.sort(sorter);

      // Add categories (The header won't even be added if a category is empty)
      void addCategory(String title, List<Map<String, dynamic>> models) {
        if (models.isNotEmpty) {
          itemsForDialog.add({'isHeader': true, 'name': title});
          itemsForDialog.addAll(models.map((m) => {
            'code': m['id'],
            'name': m['title'],
            'isPremium': (m['tier'] as String? ?? 'free') == 'premium',
            'canHandleImage': ModelData.hasModality(m['id'], 'image'),
          }));
        }
      }

      addCategory(localizations.onlineModels, onlineOptions);
      addCategory(localizations.offlineModels, offlineOptions);
      addCategory(localizations.characterModels, characterOptions);
      addCategory(localizations.customModels, selfOptions);

    } else {
      // --- STANDARD MODE: LIST EXTENSIONS OF A SERIES (Unchanged) ---
      debugPrint("$logPrefix Standard Mode: Listing extensions for series '${modelSeriesData['id']}'.");
      final allExtensionsMap = modelSeriesData['extensions'] as Map<String, dynamic>?;
      if (allExtensionsMap != null) {
        itemsForDialog = allExtensionsMap.entries.map((entry) {
          final String extensionKey = entry.key;
          final Map<String, dynamic> extensionData = entry.value as Map<String, dynamic>;
          return {
            'code': extensionKey,
            'name': extensionData['title'] as String? ?? formatModelId(extensionKey),
            'isPremium': (extensionData['tier'] as String? ?? 'free') == 'premium',
            'canHandleImage': ModelData.hasModality(extensionKey, 'image'),
          };
        }).toList();

        itemsForDialog.sort((a, b) => (a['name'] as String).toLowerCase().compareTo((b['name'] as String).toLowerCase()));
      }
    }

    // --- (The rest of the universal filtering and dialog presentation logic remains the same) ---
    final List<Map<String, dynamic>> filteredItemsForDialog = itemsForDialog.where((item) {
      if (item['isHeader'] == true) return true;

      final bool isItemPremium = item['isPremium'] as bool? ?? false;
      if (isItemPremium && !hasPremiumAccess) {
        debugPrint("$logPrefix   - Excluding premium model '${item['code']}' due to lack of access.");
        return false;
      }

      final bool canItemHandleImage = item['canHandleImage'] as bool? ?? false;
      if (widget.conversationHasPhoto && !canItemHandleImage) {
        debugPrint("$logPrefix   - Excluding model '${item['code']}' because conversation has a photo and model cannot handle images.");
        return false;
      }

      return true;
    }).toList();

    // Remove headers that have no items under them after filtering
    for (int i = filteredItemsForDialog.length - 1; i >= 0; i--) {
      if (filteredItemsForDialog[i]['isHeader'] == true) {
        if (i == filteredItemsForDialog.length - 1 || filteredItemsForDialog[i + 1]['isHeader'] == true) {
          filteredItemsForDialog.removeAt(i);
        }
      }
    }

    if (filteredItemsForDialog.where((i) => i['isHeader'] != true).length < 2) {
      debugPrint("$logPrefix Less than 2 suitable models/extensions after filtering. Dialog not shown.");
      return null;
    }

    String initialSelectedCode = currentFullModelId;
    bool currentSelectionIsValid = filteredItemsForDialog.any((ext) => ext['code'] == initialSelectedCode);

    if (!currentSelectionIsValid && filteredItemsForDialog.isNotEmpty) {
      final firstSelectableItem = filteredItemsForDialog.firstWhere((i) => i['isHeader'] != true, orElse: () => {});
      if(firstSelectableItem.isNotEmpty) {
        initialSelectedCode = firstSelectableItem['code'] as String;
      } else {
        return null; // No selectable items at all.
      }
    }

    debugPrint("$logPrefix Initial selected code for dialog: '$initialSelectedCode'");

    String tempSelectedCode = initialSelectedCode;

    final themeSettings = AppColors.getSystemUIOverlayStyleForTheme(AppColors.currentTheme);
    final Color originalNavBarColor = themeSettings['navigationBarColor'] as Color;
    final Brightness originalIconBrightness = themeSettings['navigationBarIconBrightness'] as Brightness;
    final Color darkenedNavBarColor = darkenWithBlack(originalNavBarColor, 0.5);
    final Brightness darkenedIconBrightness = ThemeData.estimateBrightnessForColor(darkenedNavBarColor) == Brightness.dark
        ? Brightness.light : Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: darkenedNavBarColor,
      systemNavigationBarIconBrightness: darkenedIconBrightness,
    ));

    bool? confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: _kMediumAnimationDuration,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        final innerL10n = AppLocalizations.of(dialogContext)!;
        final dialogScreenSize = MediaQuery.of(dialogContext).size;
        final dialogScreenWidth = dialogScreenSize.width;
        final dialogScreenHeight = dialogScreenSize.height;

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: dialogScreenWidth * _UIFactors.dialogWidthFactor,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(dialogScreenWidth * _UIFactors.borderRadiusFactor * 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(dialogScreenWidth * _UIFactors.borderRadiusFactor * 1.5),
                child: StatefulBuilder(
                  builder: (innerDialogCtx, setDialogState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: dialogScreenHeight * _UIFactors.dialogVerticalSpacingFactor),
                        SvgPicture.asset(
                          'assets/icons/extension.svg',
                          width: dialogScreenWidth * _UIFactors.dialogIconSizeFactor,
                          height: dialogScreenWidth * _UIFactors.dialogIconSizeFactor,
                          colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
                        ),
                        SizedBox(height: dialogScreenHeight * _UIFactors.dialogSmallVerticalSpacingFactor),
                        Text(
                          dialogTitle,
                          style: TextStyle(
                            fontSize: dialogScreenWidth * _UIFactors.dialogTitleFontSizeFactor,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor.inverted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Divider(thickness: 0.5, color: AppColors.border.withOpacity(0.5)),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: dialogScreenHeight * _UIFactors.dialogMaxContentHeightFactor),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: filteredItemsForDialog.length,
                            itemBuilder: (_, index) {
                              final item = filteredItemsForDialog[index];
                              if (item['isHeader'] == true) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: dialogScreenWidth * _UIFactors.dialogHorizontalPaddingFactor * 1.5,
                                    top: dialogScreenHeight * _UIFactors.dialogItemVerticalSpacingFactor * (index == 0 ? 0.5 : 1.5),
                                    bottom: dialogScreenHeight * _UIFactors.dialogItemVerticalSpacingFactor * 0.5,
                                  ),
                                  child: Text(
                                    item['name'] as String,
                                    style: TextStyle(
                                      color: AppColors.tertiaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: dialogScreenWidth * _UIFactors.dialogItemFontSizeFactor * 0.9,
                                    ),
                                  ),
                                );
                              }
                              return Theme(
                                data: Theme.of(innerDialogCtx).copyWith(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                ),
                                child: RadioListTile<String>(
                                  title: Text(
                                    item['name'] as String,
                                    style: TextStyle(
                                      fontSize: dialogScreenWidth * _UIFactors.dialogItemFontSizeFactor,
                                      color: AppColors.primaryColor.inverted,
                                    ),
                                  ),
                                  value: item['code'] as String,
                                  groupValue: tempSelectedCode,
                                  onChanged: (String? value) {
                                    if (value != null) {
                                      debugPrint("$logPrefix Dialog: User selected: '$value'");
                                      setDialogState(() => tempSelectedCode = value);
                                    }
                                  },
                                  activeColor: AppColors.primaryColor.inverted,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.symmetric(horizontal: dialogScreenWidth * _UIFactors.dialogHorizontalPaddingFactor),
                                ),
                              );
                            },
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: AppColors.senaryColor.withOpacity(0.1),
                            highlightColor: AppColors.senaryColor.withOpacity(0.1),
                            onTap: () {
                              debugPrint("$logPrefix Dialog: Confirm tapped. Returning: '$tempSelectedCode'");
                              Navigator.of(innerDialogCtx).pop(true);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: dialogScreenHeight * _UIFactors.dialogButtonVerticalPaddingFactor),
                              decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.5), width: 0.5))),
                              child: Text(
                                innerL10n.changeModel,
                                style: TextStyle(
                                  fontSize: dialogScreenWidth * _UIFactors.dialogItemFontSizeFactor,
                                  color: AppColors.senaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
    ).then((value) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: originalNavBarColor,
        systemNavigationBarIconBrightness: originalIconBrightness,
      ));
      debugPrint("$logPrefix Dialog closed. Confirmed: $value. Selected code if confirmed: '$tempSelectedCode'");
      return value;
    });

    return confirmed == true ? tempSelectedCode : null;
  }

  /// Builds a generic base widget for an option item in the panel.
  Widget _buildOptionBase({
    required BuildContext context,
    required String label,
    required String iconAsset,
    required VoidCallback? onTap,
    bool isDisabled = false,
    double? iconSizeOverride,
    Offset iconOffset = Offset.zero,
    double optionBorderRadius = 0.0, // For InkWell ripple effect
    double? minHeight,      // Minimum height for the option container
    EdgeInsets? padding,    // Custom padding for the option
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double iconSize = iconSizeOverride ?? screenWidth * _UIFactors.iconSizeFactor;
    final double defaultHorizontalPadding = screenWidth * _UIFactors.horizontalPaddingFactor;
    final double iconTextSpacing = screenWidth * _UIFactors.iconTextSpacingFactor;
    final double fontSize = screenWidth * _UIFactors.defaultFontSizeFactor;

    final EdgeInsets effectivePadding = padding ?? EdgeInsets.symmetric(horizontal: defaultHorizontalPadding, vertical: screenWidth * 0.02); // Added default vertical padding

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(optionBorderRadius),
        splashColor: AppColors.primaryColor.inverted.withOpacity(0.1),
        highlightColor: AppColors.primaryColor.inverted.withOpacity(0.05),
        onTap: isDisabled ? null : onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight ?? _optionHeight), // Ensure minimum height
          padding: effectivePadding,
          alignment: Alignment.centerLeft,
          child: Opacity( // Dim if disabled
            opacity: isDisabled ? 0.5 : 1.0,
            child: Transform.translate( // For fine-tuning icon position
              offset: iconOffset,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    iconAsset,
                    colorFilter: ColorFilter.mode( // Standard way to color SVG
                        AppColors.primaryColor.inverted, // Color is fixed, opacity handles disabled
                        BlendMode.srcIn),
                    width: iconSize,
                    height: iconSize,
                  ),
                  SizedBox(width: iconTextSpacing),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                          color: AppColors.primaryColor.inverted, // Color is fixed
                          fontSize: fontSize),
                      softWrap: true, // Allow text to wrap if needed
                      maxLines: 4,    // Max lines before ellipsis
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Specific Option Builder Methods ---
  // Each of these uses _buildOptionBase for consistency.

  Widget _buildCopyOption(BuildContext context, double borderRadius) {
    final localizations = AppLocalizations.of(context)!;
    return _buildOptionBase(
      context: context,
      label: localizations.copy,
      iconAsset: 'assets/icons/copy.svg',
      optionBorderRadius: borderRadius,
      onTap: () {
        debugPrint("[AnimatedMessageOptionsPanel] Copy option tapped.");
        Clipboard.setData(ClipboardData(text: widget.messageText));
        Provider.of<NotificationService>(context, listen: false).showNotification(
          message: localizations.messageCopied,
          isSuccess: true,
          bottomOffset: 0.07,
        );
        _dismissPanel();
      },
    );
  }


  Widget _buildReportOption(BuildContext context, double borderRadius) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    // Option is disabled if it's already reported or if no handler was provided.
    final bool isEffectivelyDisabled = widget.isReported || widget.onReport == null;

    return _buildOptionBase(
      context: context,
      label: localizations.report,
      iconAsset: 'assets/icons/warning.svg',
      isDisabled: isEffectivelyDisabled,
      optionBorderRadius: borderRadius,
      iconSizeOverride: screenWidth * _UIFactors.largerIconSizeFactor,
      iconOffset: Offset(screenWidth * _UIFactors.reportIconOffsetFactor, 0),
      onTap: () {
        debugPrint("[AnimatedMessageOptionsPanel] Report option tapped. Delegating action.");

        // 1. Paneli kapat.
        _dismissPanel();

        // 2. Üst widget'a haber ver. Dialog gösterme işi artık onun sorumluluğunda.
        // Hiçbir `async`, `await` veya `Future.delayed` YOK.
        widget.onReport?.call();
      },
    );
  }

  Widget _buildRegenerateOption(BuildContext context, double borderRadius) {
    final localizations = AppLocalizations.of(context)!;
    return _buildOptionBase(
      context: context,
      label: localizations.regenerate,
      iconAsset: 'assets/icons/regenerate.svg',
      optionBorderRadius: borderRadius,
      onTap: () {
        debugPrint("[AnimatedMessageOptionsPanel] Regenerate option tapped.");
        _dismissPanel();
        widget.onRegenerate?.call();
      },
    );
  }

  Widget _buildSelectOption(BuildContext context, double borderRadius) {
    final localizations = AppLocalizations.of(context)!;
    return _buildOptionBase(
      context: context,
      label: localizations.selectText,
      iconAsset: 'assets/icons/select.svg',
      optionBorderRadius: borderRadius,
      onTap: () {
        debugPrint("[AnimatedMessageOptionsPanel] Select Text option tapped.");
        _dismissPanel();
        _navigateToScreen(context, SelectTextScreen(messageNotifier: widget.messageNotifier), direction: const Offset(1.0, 0.0));
      },
    );
  }

  Widget _buildChangeModelOption(BuildContext context, double borderRadius) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    String baseDisplayName = localizations.changeModel;
    if (_currentModelId.trim().isNotEmpty && _currentModelId != _kDefaultModelId) {
      String modelNameToFormat = _currentModelId;
      String suffixState = "";

      if (modelNameToFormat.endsWith(':thinking')) {
        modelNameToFormat = modelNameToFormat.substring(0, modelNameToFormat.lastIndexOf(':thinking'));
      } else if (modelNameToFormat.endsWith(':free')) {
        modelNameToFormat = modelNameToFormat.substring(0, modelNameToFormat.lastIndexOf(':free'));
      }
      baseDisplayName = "${localizations.changeModel} (${formatModelId(modelNameToFormat)})$suffixState";
    }
    debugPrint("[AnimatedMessageOptionsPanel._buildChangeModelOption] Display text: '$baseDisplayName'");


    return _buildOptionBase(
      context: context,
      label: baseDisplayName,
      iconAsset: 'assets/icons/extension.svg',
      optionBorderRadius: borderRadius,
      minHeight: _optionHeight,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * _UIFactors.horizontalPaddingFactor,
        vertical: screenHeight * _UIFactors.changeModelVerticalPaddingFactor,
      ),
      onTap: () async {
        debugPrint("[AnimatedMessageOptionsPanel] Change Model option tapped. Current full model ID: '$_currentModelId'");
        _dismissPanel();
        String? selectedFullExtensionId = await _showModelExtensionsDialog(context, _currentModelId);
        if (selectedFullExtensionId != null) {
          debugPrint("[AnimatedMessageOptionsPanel] Model extension dialog returned: '$selectedFullExtensionId'. Calling onChangeModel.");
          widget.onChangeModel?.call(selectedFullExtensionId);
        } else {
          debugPrint("[AnimatedMessageOptionsPanel] Model extension dialog cancelled or returned null.");
        }
      },
    );
  }

  Widget _buildStopOption(BuildContext context, double borderRadius) {
    final localizations = AppLocalizations.of(context)!;
    return _buildOptionBase(
      context: context,
      label: localizations.stop,
      iconAsset: 'assets/icons/stop.svg',
      optionBorderRadius: borderRadius,
      onTap: () {
        debugPrint("[AnimatedMessageOptionsPanel] Stop option tapped.");
        _dismissPanel();
        widget.onStop?.call();
      },
    );
  }

  Widget _buildEditOption(BuildContext context, double borderRadius) {
    final localizations = AppLocalizations.of(context)!;
    return _buildOptionBase(
      context: context,
      label: localizations.edit,
      iconAsset: 'assets/icons/edit.svg',
      optionBorderRadius: borderRadius,
      onTap: () {
        debugPrint("[AnimatedMessageOptionsPanel] Edit option tapped.");
        _dismissPanel();
        widget.onEdit?.call();
      },
    );
  }

  /// Helper to navigate to a new screen with a slide transition.
  void _navigateToScreen(BuildContext context, Widget screen, {required Offset direction}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => screen,
        transitionsBuilder: (_, animation, __, child) {
          final tween = Tween(begin: direction, end: Offset.zero).chain(CurveTween(curve: Curves.easeOut));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: _kMediumAnimationDuration,
        reverseTransitionDuration: _kMediumAnimationDuration,
      ),
    );
  }

  @override
  void dispose() {
    const String logPrefix = "[AnimatedMessageOptionsPanel.dispose]";
    debugPrint("$logPrefix Disposing panel state.");
    // Remove listeners to prevent memory leaks.
    if (_thinkingListenerCallback != null && widget.isThinkingNotifier != null) {
      widget.isThinkingNotifier!.removeListener(_thinkingListenerCallback!);
      debugPrint("$logPrefix Removed listener from isThinkingNotifier.");
    }
    if (_waitingListenerCallback != null && widget.isWaitingForResponseNotifier != null) {
      widget.isWaitingForResponseNotifier!.removeListener(_waitingListenerCallback!);
      debugPrint("$logPrefix Removed listener from isWaitingForResponseNotifier.");
    }
    _animationController.dispose();
    debugPrint("$logPrefix AnimationController disposed.");
    super.dispose();
  }
}

/// Global variable to keep track of the currently displayed message options overlay.
/// This ensures only one panel is shown at a time.
OverlayEntry? _currentMessageOptionsEntry;

/// Dismisses the currently shown message options panel, if any.
///
/// Safe to call even if no panel is currently visible.
void dismissCurrentMessageOptions() {
  const String logPrefix = "[Global.dismissCurrentMessageOptions]";
  if (_currentMessageOptionsEntry != null) {
    debugPrint("$logPrefix Attempting to remove current message options overlay.");
    try {
      // It's possible the overlay entry was already removed or disposed by Flutter's tree changes
      // (e.g., during navigation). Checking `mounted` before `remove` is a good practice.
      if (_currentMessageOptionsEntry!.mounted) {
        _currentMessageOptionsEntry!.remove();
        debugPrint("$logPrefix Overlay entry removed successfully.");
      } else {
        debugPrint("$logPrefix Overlay entry was not mounted. No removal needed or already removed.");
      }
    } catch (e) {
      // Log error if removal fails for an unexpected reason.
      debugPrint("$logPrefix Error removing overlay entry: $e. This might happen if already disposed.");
    }
    _currentMessageOptionsEntry = null; // Clear the reference
  } else {
    // debugPrint("$logPrefix No current message options overlay to dismiss.");
  }
}

/// Shows a panel with context-specific options for a given message.
///
/// Displays the panel near the [tapPosition]. Ensures that only one such
/// panel is visible globally at any time by dismissing any pre-existing panel.
///
/// Parameters:
/// - `context`: The build context from which to show the overlay.
/// - `tapPosition`: The global coordinates of the tap/event that triggered showing options.
/// - `messageText`: The text of the message.
/// - `messageNotifier`: Optional notifier for reactive message text updates.
/// - `options`: List of [MessageOption] enums to potentially display.
/// - `isReported`: Whether the message has already been reported.
/// - `onReport`: Callback for the 'Report' action.
/// - `onRegenerate`: Callback for the 'Regenerate' action.
/// - `onStop`: Callback for the 'Stop' action.
/// - `modelIdAndExtension`: The ID of the current model/extension.
/// - `onChangeModel`: Callback for when a new model/extension is selected.
/// - `onEdit`: Callback for the 'Edit' action.
/// - `conversationHasPhoto`: True if the conversation contains photos.
/// - `isThinking`: Direct flag for AI thinking state.
/// - `isThinkingNotifier`: Reactive notifier for AI thinking state.
/// - `isWaitingForResponseNotifier`: Reactive notifier for global chat response waiting state.
/// Shows a panel with context-specific options for a given message.
Future<void> showMessageOptions({
  required BuildContext context,
  required Offset tapPosition,
  required String messageText,
  ValueNotifier<String>? messageNotifier,
  required List<MessageOption> options,
  bool isReported = false,
  VoidCallback? onReport,
  VoidCallback? onRegenerate,
  VoidCallback? onStop,
  String? modelIdAndExtension,
  ValueChanged<String>? onChangeModel,
  VoidCallback? onEdit,
  required bool conversationHasPhoto,
  bool? isThinking,
  ValueListenable<bool>? isThinkingNotifier,
  ValueNotifier<bool>? isWaitingForResponseNotifier,
  required bool isSubscribed,
  required int premiumTrialUses,
  bool? isPersistentlyDynamic,
}) async {
  const String functionName = "[Global.showMessageOptions]"; // For logging
  debugPrint(
      "$functionName CALLED. Message (start): '${messageText.substring(0, math.min(20, messageText.length))}', "
          "ModelID: '$modelIdAndExtension', Options provided: ${options.length}, Photo: $conversationHasPhoto, Thinking: $isThinking, "
          "Subscribed: $isSubscribed, Trials: $premiumTrialUses");

  dismissCurrentMessageOptions(); // Ensure any previous panel is dismissed first

  final resolvedMessageNotifier = messageNotifier ?? ValueNotifier<String>(messageText);
  final overlay = Overlay.of(context);

  final RenderBox? overlayBox = overlay.context.findRenderObject() as RenderBox?;
  if (overlayBox == null) {
    debugPrint("$functionName ERROR: overlayBox is null. Cannot determine local position or show options.");
    return;
  }
  final Offset localPosition = overlayBox.globalToLocal(tapPosition);
  debugPrint("$functionName Tap position (global): $tapPosition, Converted to local: $localPosition");

  _currentMessageOptionsEntry = OverlayEntry(
    builder: (overlayContext) {
      debugPrint("$functionName OverlayEntry builder CALLED. Creating AnimatedMessageOptionsPanel instance.");
      return AnimatedMessageOptionsPanel(
        messageText: messageText,
        messageNotifier: resolvedMessageNotifier,
        options: options,
        isReported: isReported,
        onReport: onReport,
        onDismiss: dismissCurrentMessageOptions,
        position: localPosition,
        modelIdAndExtension: modelIdAndExtension,
        onRegenerate: onRegenerate,
        onChangeModel: onChangeModel,
        onStop: onStop,
        onEdit: onEdit,
        conversationHasPhoto: conversationHasPhoto,
        isThinking: isThinking,
        isThinkingNotifier: isThinkingNotifier,
        isWaitingForResponseNotifier: isWaitingForResponseNotifier,
        isSubscribed: isSubscribed,
        premiumTrialUses: premiumTrialUses,
        isPersistentlyDynamic: isPersistentlyDynamic,
      );
    },
  );

  overlay.insert(_currentMessageOptionsEntry!);
  debugPrint("$functionName New OverlayEntry inserted into the overlay.");
}

/// wow
/// wow
/// wow
/// wow
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///