// lib/screens/models/screen/new/controller.dart

// This file acts as the "Host" or "Scaffold Controller" for the entire model
// creation process. Its single responsibility is to manage the main UI scaffold
// (AppBar, body, BottomNavigationBar) and the animated transition between the
// "Create" and "Add" form screens.
//
// By centralizing the scaffold and transition logic here, the actual form files
// (`create.dart`, `add.dart`) can be simple, stateless content widgets. This
// promotes code reusability, readability, and maintainability.

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme.dart';
import '../../backend/data/entity.dart';
import '../../backend/data/service.dart';
import '../../providers/new.dart';
import 'add.dart';
import 'create.dart';
import 'widgets/button.dart';

/// The main widget that hosts the model creation flow.
/// It provides the `ModelCreationProvider` and manages the state for switching
/// between the `CreateForm` and `AddForm`.
class ModelCreationHost extends StatefulWidget {
  final List<ModelEntity> availableBaseModels;

  const ModelCreationHost({super.key, required this.availableBaseModels});

  @override
  State<ModelCreationHost> createState() => _ModelCreationHostState();
}

class _ModelCreationHostState extends State<ModelCreationHost> with TickerProviderStateMixin {
  /// The boolean state that determines which form is currently visible.
  bool _showCreateScreen = true;

  /// Toggles the screen state and triggers a rebuild to animate the transition.
  void _switchScreen() {
    setState(() {
      _showCreateScreen = !_showCreateScreen;
    });
  }

  /// A precise utility function to calculate the exact render size of a given text.
  ///
  /// This is crucial for the AppBar title animation. It emulates the way Flutter's
  /// `Text` widget merges a provided style with the theme's default style,
  /// ensuring a pixel-perfect width calculation and preventing text clipping or
  /// layout jumps during animation.
  /// [context] is required to access the `ThemeData`.
  Size _getTextSize(String text, TextStyle style, BuildContext context) {
    // 1. Get the default text style for the AppBar from the current theme.
    final defaultStyle = Theme.of(context).appBarTheme.titleTextStyle ?? Theme.of(context).textTheme.titleLarge;

    // 2. Merge our custom style on top of the default style.
    // This is the same process the Text widget performs internally.
    final effectiveStyle = defaultStyle?.merge(style) ?? style;

    // 3. Use a TextPainter with the final, effective style to calculate the exact size.
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: effectiveStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    // Define the style for the AppBar title once.
    final titleStyle = TextStyle(color: AppColors.primaryColor.inverted);
    // Determine the current title text based on the screen state.
    final currentTitleText = _showCreateScreen ? localizations.create : localizations.add;
    // Calculate the precise width for the current title to drive the animation.
    final titleWidth = _getTextSize(currentTitleText, titleStyle, context).width;

    // The `ChangeNotifierProvider` is placed at the top level of this feature,
    // making the `ModelCreationProvider` available to this host widget and all
    // its children (i.e., the forms).
    return ChangeNotifierProvider(
      create: (ctx) => ModelCreationProvider(this, ctx, widget.availableBaseModels, modelService: context.read<ModelService>(),),
      child: Consumer<ModelCreationProvider>(
        builder: (context, provider, child) {
          // The main scaffold is wrapped in `PopScope` and `AbsorbPointer` to
          // manage back navigation and disable user input while saving.
          return PopScope(
            canPop: !provider.isSaving,
            child: AbsorbPointer(
              absorbing: provider.isSaving,
              child: Scaffold(
                appBar: AppBar(
                  scrolledUnderElevation: 0,
                  // The title is an `AnimatedContainer` that smoothly animates its width
                  // to match the calculated size of the incoming/outgoing text.
                  title: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: titleWidth,
                    child: Center(
                      // An `AnimatedSwitcher` inside handles the fading between the two text widgets.
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Text(
                          currentTitleText,
                          key: ValueKey<String>(currentTitleText), // Key is crucial for AnimatedSwitcher
                          style: titleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.visible, // No clipping needed as width is correct
                        ),
                      ),
                    ),
                  ),
                  backgroundColor: AppColors.background,
                  elevation: 0,
                  iconTheme: IconThemeData(color: AppColors.primaryColor.inverted),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: provider.isSaving ? null : () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    Opacity(
                      opacity: provider.isSaving ? 0.5 : 1.0,
                      child: IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/transition.svg',
                          width: screenWidth * 0.06,
                          height: screenWidth * 0.06,
                          colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
                        ),
                        onPressed: provider.isSaving ? null : _switchScreen,
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.background,
                // The body uses an `AnimatedSwitcher` to fade between the two form widgets.
                body: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _showCreateScreen
                      ? CreateForm(key: const ValueKey('CreateForm')) // Show Create Form
                      : AddForm(key: const ValueKey('AddForm')),      // Show Add Form
                ),
                // The bottom navigation bar also switches between the two save buttons.
                bottomNavigationBar: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _showCreateScreen
                      ? CreationSaveButton(
                    key: const ValueKey('CreateButton'),
                    isEnabled: provider.isCreateSaveEnabled,
                    isSaving: provider.isSaving,
                    onPressed: () async {
                      final success = await provider.saveRoleplayModel(context);
                      if (success && context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                  )
                      : CreationSaveButton(
                    key: const ValueKey('AddButton'),
                    isEnabled: provider.isAddSaveEnabled,
                    isSaving: provider.isSaving,
                    onPressed: () async {
                      final success = await provider.saveOfflineModel(context);
                      if (success && context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}