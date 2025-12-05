// lib/screens/models/screen/new/controller.dart

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

class ModelCreationHost extends StatefulWidget {
  final List<ModelEntity> availableBaseModels;

  const ModelCreationHost({super.key, required this.availableBaseModels});

  @override
  State<ModelCreationHost> createState() => _ModelCreationHostState();
}

class _ModelCreationHostState extends State<ModelCreationHost> with TickerProviderStateMixin {
  bool _showCreateScreen = true;

  void _switchScreen() {
    setState(() {
      _showCreateScreen = !_showCreateScreen;
    });
  }

  Size _getTextSize(String text, TextStyle style, BuildContext context) {
    final defaultStyle = Theme.of(context).appBarTheme.titleTextStyle ?? Theme.of(context).textTheme.titleLarge;
    final effectiveStyle = defaultStyle?.merge(style) ?? style;
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
    final bool isTablet = screenWidth >= 600;

    final double appBarHeight = isTablet ? screenWidth * 0.14 : kToolbarHeight;

    final double backIconSize = isTablet ? 32.0 : 24.0;
    final double transitionIconSize = isTablet ? 32.0 : screenWidth * 0.06;

    final double titleFontSize = isTablet ? 24.0 : 20.0;

    final titleStyle = TextStyle(
      color: AppColors.primaryColor.inverted,
      fontSize: titleFontSize,
      fontWeight: FontWeight.normal,
    );

    final currentTitleText = _showCreateScreen ? localizations.create : localizations.add;
    final titleWidth = _getTextSize(currentTitleText, titleStyle, context).width;

    return ChangeNotifierProvider(
      create: (ctx) => ModelCreationProvider(this, ctx, widget.availableBaseModels, modelService: context.read<ModelService>(),),
      child: Consumer<ModelCreationProvider>(
        builder: (context, provider, child) {
          return PopScope(
            canPop: !provider.isSaving,
            child: AbsorbPointer(
              absorbing: provider.isSaving,
              child: Scaffold(
                appBar: AppBar(
                  scrolledUnderElevation: 0,
                  toolbarHeight: appBarHeight,
                  title: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: titleWidth,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Text(
                          currentTitleText,
                          key: ValueKey<String>(currentTitleText),
                          style: titleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ),
                  backgroundColor: AppColors.background,
                  elevation: 0,
                  iconTheme: IconThemeData(
                    color: AppColors.primaryColor.inverted,
                    size: backIconSize,
                  ),
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
                          width: transitionIconSize,
                          height: transitionIconSize,
                          colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
                        ),
                        onPressed: provider.isSaving ? null : _switchScreen,
                      ),
                    ),
                    SizedBox(width: isTablet ? 16.0 : 0),
                  ],
                ),
                backgroundColor: AppColors.background,
                body: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _showCreateScreen
                      ? CreateForm(key: const ValueKey('CreateForm'))
                      : AddForm(key: const ValueKey('AddForm')),
                ),
                bottomNavigationBar: IntrinsicHeight(
                  child: AnimatedSwitcher(
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
            ),
          );
        },
      ),
    );
  }
}