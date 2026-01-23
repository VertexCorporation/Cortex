// lib/library/screen/new/controller.dart

import 'package:cortex/app.dart';
import 'package:cortex/appbar.dart';
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

class _ModelCreationHostState extends State<ModelCreationHost>
    with TickerProviderStateMixin {
  bool _showCreateScreen = true;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _switchScreen() {
    setState(() {
      _showCreateScreen = !_showCreateScreen;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final localeName = localizations.localeName;

    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final bool isTablet = screenWidth >= 600;

    final double transitionIconSize = isTablet ? 24.0 : 20.0;
    final double titleFontSize = isTablet ? 20.0 : 18.0;

    final titleStyle = TextStyle(
      color: AppColors.primaryColor.inverted,
      fontSize: titleFontSize,
      fontWeight: FontWeight.w500,
      fontFamily: 'Ubuntu',
    );

    final currentTitleText =
    _showCreateScreen ? localizations.create : localizations.add;

    return ChangeNotifierProvider(
      create: (ctx) {
        return ModelCreationProvider(
          this,
          widget.availableBaseModels,
          modelService: context.read<ModelService>(),
          localeName: localeName,
          localizations: localizations,
        );
      },
      child: Consumer<ModelCreationProvider>(
        builder: (context, provider, child) {
          return PopScope(
            canPop: !provider.isSaving,
            child: AbsorbPointer(
              absorbing: provider.isSaving,
              child: Scaffold(
                backgroundColor: AppColors.background,
                extendBodyBehindAppBar: true,
                appBar: CortexAppBar(
                  leadingMode: CortexLeadingMode.back,
                  showGradient: true,
                  onLeadingPressed: provider.isSaving
                      ? () {}
                      : () => Navigator.of(context).pop(),
                  title: AnimatedBuilder(
                    animation: _scrollController,
                    builder: (context, child) {
                      final bool isVisible = !_scrollController.hasClients ||
                          _scrollController.offset <= 20.0;

                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isVisible ? 1.0 : 0.0,
                        child: child,
                      );
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.2),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        currentTitleText,
                        key: ValueKey<String>(currentTitleText),
                        style: titleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  actionButton: AppBarButton(
                    onTap: provider.isSaving ? () {} : _switchScreen,
                    child: Opacity(
                      opacity: provider.isSaving ? 0.5 : 1.0,
                      child: SvgPicture.asset(
                        'assets/icons/transition.svg',
                        width: transitionIconSize,
                        height: transitionIconSize,
                        colorFilter: ColorFilter.mode(
                          AppColors.primaryColor.inverted,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                body: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _showCreateScreen
                      ? CreateForm(
                    key: const ValueKey('CreateForm'),
                    scrollController: _scrollController,
                  )
                      : AddForm(
                    key: const ValueKey('AddForm'),
                    scrollController: _scrollController,
                  ),
                ),
                bottomNavigationBar: IntrinsicHeight(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: _showCreateScreen
                        ? CreationSaveButton(
                      key: const ValueKey('CreateButton'),
                      isEnabled: provider.isCreateSaveEnabled,
                      isSaving: provider.isSaving,
                      onPressed: () async {
                        final success =
                        await provider.saveRoleplayModel(context);
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
                        final success =
                        await provider.saveOfflineModel(context);
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