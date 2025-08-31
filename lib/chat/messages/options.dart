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

// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow

// Ensure these import paths are correct for your project structure
// import '../../main.dart'; // Assuming main.dart exports necessary globals like mainScreenKey or similar.
// If main.dart is not needed here directly, consider removing to reduce coupling.
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

/// Defines UI proportionality constants relative to screen dimensions.
/// This helps in creating responsive UI elements.
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

/// A panel that displays message options with a scale animation.
///
/// The panel's visibility and the options displayed can be dynamic,
/// reacting to internet connectivity, AI thinking state, and other factors.
/// It positions itself relative to a tap [position] on the screen.
class AnimatedMessageOptionsPanel extends StatefulWidget {
  /// The text content of the message for which options are being shown.
  /// Used, for example, by the 'Copy' and 'Report' options.
  final String messageText;

  /// A [ValueNotifier] for the message text. If the message text can change
  /// while the panel is open (e.g., streaming response), this allows the
  /// 'Select Text' screen to get the most up-to-date text.
  final ValueNotifier<String> messageNotifier;

  /// The list of [MessageOption] enums that should potentially be displayed.
  /// The actual visible options are a subset of these, filtered by internal logic.
  final List<MessageOption> options;

  /// Flag indicating if the message has already been reported.
  /// If true, the 'Report' option might be disabled or hidden.
  final bool isReported;

  /// Callback triggered when the 'Report' option is selected.
  final VoidCallback? onReport;

  /// Callback triggered when the panel is dismissed, either by tapping outside
  /// or by selecting an option that closes the panel.
  final VoidCallback onDismiss;

  /// The global screen coordinates where the tap/event occurred, used as a basis
  /// for positioning the panel. The panel will attempt to adjust its position
  /// to stay within screen bounds.
  final Offset position;

  /// The current model ID, potentially including an extension identifier
  /// (e.g., "gemini-1.5-pro" or "gpt-4-browsing").
  /// This is crucial for determining model-specific capabilities and available extensions.
  final String? modelIdAndExtension;

  /// Callback triggered when the 'Regenerate' option is selected.
  final VoidCallback? onRegenerate;

  /// Callback triggered when the 'Change Model' option results in a new model/extension selection.
  /// The `String` argument is the ID of the newly selected model/extension.
  final ValueChanged<String>? onChangeModel;

  /// Callback triggered when the 'Stop' option is selected.
  final VoidCallback? onStop;

  /// Callback triggered when the 'Edit' option is selected.
  final VoidCallback? onEdit;

  /// Flag indicating if the conversation involves a photo.
  /// This affects which models/extensions can be selected via 'Change Model'.
  final bool conversationHasPhoto;

  /// A direct flag indicating if the AI is currently processing or "thinking".
  /// Used if a [ValueListenable] is not available.
  final bool? isThinking;

  /// A [ValueListenable] that reflects the AI's "thinking" state.
  /// If provided, the panel can reactively dismiss itself or change options
  /// when the thinking state changes.
  final ValueListenable<bool>? isThinkingNotifier;

  /// A [ValueNotifier] indicating if the chat screen is globally waiting for a response.
  /// This can influence the visibility of options like 'Regenerate' or 'Change Model'.
  final ValueNotifier<bool>? isWaitingForResponseNotifier;
  final bool isSubscribed;
  /// The number of premium model trial uses for the current day.
  final int premiumTrialUses;


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
  }) : super(key: key);

  @override
  _AnimatedMessageOptionsPanelState createState() =>
      _AnimatedMessageOptionsPanelState();
}

class _AnimatedMessageOptionsPanelState extends State<AnimatedMessageOptionsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _hasInternet = true; // Assume internet initially, will be checked.
  late String _currentModelId; // Effective model ID used internally.

  // Listeners for reactive state changes.
  VoidCallback? _thinkingListenerCallback;
  VoidCallback? _waitingListenerCallback;
  bool _wasWaitingForResponse = false; // Tracks previous waiting state.

  // UI dimensions, initialized in build based on screen size.
  double _panelWidth = 0;
  double _optionHeight = 0;

  @override
  void initState() {
    super.initState();
    const String logPrefix = "[AnimatedMessageOptionsPanel.initState]";
    debugPrint("$logPrefix Initializing...");

    // Set the current model ID, cleaning it if necessary and defaulting if null.
    _initializeCurrentModelId(widget.modelIdAndExtension, logPrefix);

    _animationController = AnimationController(
      duration: _kShortAnimationDuration, // Short duration for quick appearance
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

  /// Asynchronously checks for internet connectivity and updates `_hasInternet`.
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

  /// Reverses the panel animation and calls `widget.onDismiss` upon completion.
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
      // If already dismissed (animation-wise) but onDismiss might not have been called
      // (e.g., due to rapid state changes or external dismissal not through this method).
      debugPrint("$logPrefix Panel was already in dismissed animation state. Calling onDismiss directly.");
      widget.onDismiss();
    } else {
      debugPrint("$logPrefix Panel in an intermediate animation state (${_animationController.status}). Reverse not initiated.");
    }
  }

  /// Determines which of the `widget.options` should be visible based on current app state.
  List<MessageOption> _calculateVisibleOptions(bool isChatScreenWaiting, bool isMessageCurrentlyThinking) {
    const String logPrefix = "[AnimatedMessageOptionsPanel._calculateVisibleOptions]";
    if (!mounted) {
      debugPrint("$logPrefix Not mounted. Returning empty list of options.");
      return [];
    }

    final modelSeriesData = _findParentSeriesData();
    final bool isOfflineModel = (modelSeriesData['type'] as String? ?? 'online') == 'offline';
    final bool currentModelCanHandleImages = ModelData.hasModality(_currentModelId, 'image');

    final bool hasPremiumAccess = widget.isSubscribed || widget.premiumTrialUses < 3;

    final bool isCurrentModelPremium = (ModelData.getPreciseModelData(_currentModelId)['tier'] as String? ?? 'free') == 'premium';


    return widget.options.where((option) {
      String reason = ""; // For debugging
      bool shouldShow = true;

      if (isChatScreenWaiting &&
          (option == MessageOption.regenerate || option == MessageOption.changeModel || option == MessageOption.edit)) {
        shouldShow = false;
        reason = "Chat screen is globally waiting for a response.";
      }

      if (shouldShow && option == MessageOption.stop && !isMessageCurrentlyThinking) {
        shouldShow = false;
        reason = "Message is not currently thinking.";
      }

      if (shouldShow && option == MessageOption.regenerate) {
        if (isCurrentModelPremium && !hasPremiumAccess) {
          shouldShow = false;
          reason = "Regenerate is hidden. The model is premium and the user has no subscription or trial uses left.";
        } else if (isOfflineModel || !_hasInternet) {
          shouldShow = false;
          reason = "Regenerate is not supported for offline models or without an internet connection.";
        }
      }

      if (shouldShow && widget.conversationHasPhoto && !currentModelCanHandleImages) {
        if (option == MessageOption.regenerate || option == MessageOption.edit || option == MessageOption.changeModel) {
          shouldShow = false;
          reason = "Conversation contains a photo, but the current model ('$_currentModelId') cannot process images, so destructive actions are disabled.";
        }
      }

      if (shouldShow && option == MessageOption.changeModel) {
        final int validExtCount = _validExtensionCountForChangingModel(modelSeriesData);
        if (validExtCount <= 1) {
          shouldShow = false;
          reason = "Not enough other extensions to change to (found $validExtCount).";
        }
      }

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

  /// Retrieves the base model series data for the currently active model extension.
  /// This function is now the single, authoritative source for finding the parent series.
  /// It searches the entire model cache to find which series contains the current extension.
  Map<String, dynamic> _findParentSeriesData() {
    const String logPrefix = "[AnimatedMessageOptionsPanel._findParentSeriesData]";
    if (!mounted || _currentModelId == _kDefaultModelId) return {};

    final allCachedModels = ModelData.getCachedModelsSync();
    if (allCachedModels.isEmpty) {
      debugPrint("$logPrefix ModelData cache is empty. Cannot find parent series for '$_currentModelId'.");
      return {};
    }

    // Iterate through all top-level model series.
    for (final seriesData in allCachedModels) {
      final extensionsMap = seriesData['extensions'] as Map<String, dynamic>?;
      // Check if this series has an 'extensions' map and if our current model ID is a key in it.
      if (extensionsMap?.containsKey(_currentModelId) ?? false) {
        debugPrint("$logPrefix Found parent series '${seriesData['id']}' for extension '$_currentModelId'.");
        return seriesData; // Return the entire data map for the parent series.
      }
    }

    // Fallback if no parent is found (e.g., for a model without extensions).
    // Try to find a direct match for the model ID itself.
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

    // The rest of the logic is correct and remains the same.
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

  /// Checks if the currently selected model (including its specific extension) can handle images.
  /// --- FIX: This now accepts the pre-fetched parent series data. ---
  bool _currentExtCanHandleImage(Map<String, dynamic> parentSeriesData) {
    const String logPrefix = "[AnimatedMessageOptionsPanel._currentExtCanHandleImage]";

    if (parentSeriesData.isEmpty) {
      debugPrint("$logPrefix No parent series data provided. Assuming cannot handle images.");
      return false;
    }

    final seriesId = parentSeriesData['id'] ?? 'unknown_series';
    debugPrint("$logPrefix Checking for full model ID: '$_currentModelId' within series: '$seriesId'");

    final extensionsMap = parentSeriesData['extensions'] as Map<String, dynamic>?;
    if (extensionsMap == null || extensionsMap.isEmpty) {
      bool seriesCanHandle = parentSeriesData['canHandleImage'] as bool? ?? false;
      debugPrint("$logPrefix No extensions map for '$seriesId'. Series canHandleImage: $seriesCanHandle");
      return seriesCanHandle;
    }

    final currentExtensionData = extensionsMap[_currentModelId];
    if (currentExtensionData is Map) {
      bool extCanHandle = (currentExtensionData['canHandleImage'] as bool?) ?? false;
      debugPrint("$logPrefix Found data for extension '$_currentModelId'. Its canHandleImage: $extCanHandle");
      return extCanHandle;
    } else {
      debugPrint("$logPrefix CRITICAL: Data for full model ID '$_currentModelId' not found as a key in 'extensions' map of '$seriesId'. Assuming cannot handle images.");
      return false;
    }
  }

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

  /// Shows a dialog for selecting a model extension (variant) for the current base model series.
  ///
  /// [currentFullModelId] is the ID of the currently active model/extension.
  /// Returns the ID of the selected extension, or null if cancelled.
  Future<String?> _showModelExtensionsDialog(BuildContext context, String currentFullModelId) async {
    const String logPrefix = "[AnimatedMessageOptionsPanel._showModelExtensionsDialog]";

    final modelSeriesData = _findParentSeriesData();
    final seriesId = modelSeriesData['id'] ?? 'unknown_series';
    debugPrint("$logPrefix Showing dialog for series '$seriesId', current full ID: '$currentFullModelId'");

    final bool hasPremiumAccess = widget.isSubscribed || widget.premiumTrialUses < 3;
    debugPrint("$logPrefix User premium access status: $hasPremiumAccess (Subscribed: ${widget.isSubscribed}, Trials Used: ${widget.premiumTrialUses})");

    List<Map<String, dynamic>> extensionsListForDialog = [];
    final allExtensionsMap = modelSeriesData['extensions'] as Map<String, dynamic>?;

    if (allExtensionsMap != null) {
      debugPrint("$logPrefix Found ${allExtensionsMap.length} extensions in model data for '$seriesId'. Filtering for dialog...");

      extensionsListForDialog = allExtensionsMap.entries.where((entry) {
        final dynamic extData = entry.value;
        if (extData is Map) {
          final bool isExtensionPremium = (extData['tier'] as String? ?? 'free') == 'premium';
          if (isExtensionPremium && !hasPremiumAccess) {
            debugPrint("$logPrefix   - Excluding premium extension '${entry.key}' due to lack of access.");
            return false;
          }

          if (widget.conversationHasPhoto) {
            return (extData['canHandleImage'] as bool?) == true;
          }
          return true;
        }
        debugPrint("$logPrefix   Extension entry '${entry.key}' has non-Map value: $extData. Excluding.");
        return false;
      }).map((entry) {
        final String extensionKey = entry.key;
        final Map<String,dynamic> extensionData = entry.value as Map<String,dynamic>;
        final String displayName = extensionData['title'] as String? ?? formatModelId(extensionKey);
        debugPrint("$logPrefix   + Adding to dialog: code='$extensionKey', name='$displayName'");
        return { 'code': extensionKey, 'name': displayName, 'enabled': true };
      }).toList();
      debugPrint("$logPrefix Filtered ${extensionsListForDialog.length} extensions for dialog display.");
    } else {
      debugPrint("$logPrefix No 'extensions' found in model data for '$seriesId', or model data is empty.");
    }

    if (extensionsListForDialog.length < 2) {
      debugPrint("$logPrefix Less than 2 suitable extensions (${extensionsListForDialog.length}). Dialog not shown.");
      return null;
    }

    String initialSelectedExtensionCodeInDialog;

    final currentModelData = allExtensionsMap?[currentFullModelId] as Map<String, dynamic>?;
    final bool isCurrentModelPremium = (currentModelData?['tier'] as String? ?? 'free') == 'premium';

    if (isCurrentModelPremium && !hasPremiumAccess) {
      debugPrint("$logPrefix Current model '$currentFullModelId' is premium and user lacks access. Forcing a different initial selection.");
      initialSelectedExtensionCodeInDialog = extensionsListForDialog.first['code'] as String;
    } else {
      initialSelectedExtensionCodeInDialog = currentFullModelId;
      bool currentSelectionIsValidForDialog = extensionsListForDialog.any((ext) => ext['code'] == initialSelectedExtensionCodeInDialog);

      if (!currentSelectionIsValidForDialog && extensionsListForDialog.isNotEmpty) {
        debugPrint("$logPrefix Current selection '$initialSelectedExtensionCodeInDialog' is not in the valid dialog list. Picking first available.");
        initialSelectedExtensionCodeInDialog = extensionsListForDialog.first['code'] as String;
      } else if (extensionsListForDialog.isEmpty) {
        debugPrint("$logPrefix CRITICAL: No valid options available in dialog after filter. Aborting dialog.");
        return null;
      }
    }

    debugPrint("$logPrefix Initial selected extension code for dialog: '$initialSelectedExtensionCodeInDialog'");

    String tempSelectedExtensionInDialog = initialSelectedExtensionCodeInDialog; // For StatefulBuilder

    // --- System UI for Dialog ---
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
    // --- End System UI ---

    bool? confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: _kMediumAnimationDuration,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        final AppLocalizations innerL10n = AppLocalizations.of(dialogContext)!;
        final dialogScreenSize = MediaQuery.of(dialogContext).size;
        final dialogScreenWidth = dialogScreenSize.width;
        final dialogScreenHeight = dialogScreenSize.height;

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: dialogScreenWidth * _UIFactors.dialogWidthFactor,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor, // Dialog background
                borderRadius: BorderRadius.circular(dialogScreenWidth * _UIFactors.borderRadiusFactor * 1.5),
              ),
              child: ClipRRect( // Clip content to rounded corners
                borderRadius: BorderRadius.circular(dialogScreenWidth * _UIFactors.borderRadiusFactor * 1.5),
                child: StatefulBuilder( // To manage radio button selection state within the dialog
                  builder: (innerDialogCtx, setDialogState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: dialogScreenHeight * _UIFactors.dialogVerticalSpacingFactor),
                        SvgPicture.asset( // Dialog icon
                          'assets/icons/extension.svg',
                          width: dialogScreenWidth * _UIFactors.dialogIconSizeFactor,
                          height: dialogScreenWidth * _UIFactors.dialogIconSizeFactor,
                          colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
                        ),
                        SizedBox(height: dialogScreenHeight * _UIFactors.dialogSmallVerticalSpacingFactor),
                        Text( // Dialog title
                          innerL10n.changeModel,
                          style: TextStyle(
                            fontSize: dialogScreenWidth * _UIFactors.dialogTitleFontSizeFactor,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor.inverted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Divider(thickness: 0.5, color: AppColors.border.withOpacity(0.5)), // Separator
                        ConstrainedBox( // Limit height of the scrollable list
                          constraints: BoxConstraints(maxHeight: dialogScreenHeight * _UIFactors.dialogMaxContentHeightFactor),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: extensionsListForDialog.length,
                            separatorBuilder: (_, __) => SizedBox(height: dialogScreenHeight * _UIFactors.dialogItemVerticalSpacingFactor / 2), // Reduced separator
                            itemBuilder: (_, index) {
                              final item = extensionsListForDialog[index];
                              final bool isEnabled = item['enabled'] as bool? ?? true;
                              return Theme( // Remove splash/highlight from RadioListTile
                                data: Theme.of(innerDialogCtx).copyWith(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                ),
                                child: RadioListTile<String>(
                                  title: Text(
                                    item['name'] as String,
                                    style: TextStyle(
                                      fontSize: dialogScreenWidth * _UIFactors.dialogItemFontSizeFactor,
                                      color: isEnabled ? AppColors.primaryColor.inverted : Colors.grey,
                                    ),
                                  ),
                                  value: item['code'] as String,
                                  groupValue: tempSelectedExtensionInDialog,
                                  onChanged: isEnabled ? (String? value) {
                                    if (value != null) {
                                      debugPrint("$logPrefix Dialog: User selected extension: '$value'");
                                      setDialogState(() => tempSelectedExtensionInDialog = value);
                                    }
                                  } : null,
                                  activeColor: AppColors.primaryColor.inverted,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.symmetric(horizontal: dialogScreenWidth * _UIFactors.dialogHorizontalPaddingFactor),
                                ),
                              );
                            },
                          ),
                        ),
                        Material( // For InkWell splash on the confirm button
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: AppColors.senaryColor.withOpacity(0.1),
                            highlightColor: AppColors.senaryColor.withOpacity(0.1),
                            onTap: () {
                              debugPrint("$logPrefix Dialog: Confirm button tapped. Returning selected: '$tempSelectedExtensionInDialog'");
                              Navigator.of(innerDialogCtx).pop(true); // Confirm selection
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: dialogScreenHeight * _UIFactors.dialogButtonVerticalPaddingFactor),
                              decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.5), width: 0.5))),
                              child: Text(
                                innerL10n.changeModel, // Confirm button text
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
      // Restore original system UI overlay style for navigation bar when dialog closes.
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: originalNavBarColor,
        systemNavigationBarIconBrightness: originalIconBrightness,
      ));
      debugPrint("$logPrefix Dialog closed. Confirmed: $value. Selected extension if confirmed: '$tempSelectedExtensionInDialog'");
      return value; // Propagate the dialog's result (true if confirmed)
    });

    return confirmed == true ? tempSelectedExtensionInDialog : null;
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
}) async {
  const String functionName = "[Global.showMessageOptions]"; // For logging
  debugPrint(
      "$functionName CALLED. Message (start): '${messageText.substring(0, math.min(20, messageText.length))}', "
          "ModelID: '$modelIdAndExtension', Options provided: ${options.length}, Photo: $conversationHasPhoto, Thinking: $isThinking, "
          "Subscribed: $isSubscribed, Trials: $premiumTrialUses"); // Log'a eklendi

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
      );
    },
  );

  overlay.insert(_currentMessageOptionsEntry!);
  debugPrint("$functionName New OverlayEntry inserted into the overlay.");
}


// Helper extension for logging list of strings or providing empty string if null/empty
extension _StringListLogHelper on List<String>? {
  String joinToStringOrEmpty() {
    if (this == null || this!.isEmpty) return "[]";
    return "[${this!.join(', ')}]";
  }
}