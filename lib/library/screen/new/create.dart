// lib/screens/models/screen/new/create.dart

// This file contains the VIEW for the "Create Roleplay Model" screen.
// It is now a StatefulWidget to manage its own ScrollController, which enables a
// scroll-aware fog effect. This enhances the UI without compromising the
// separation of concerns, as all business logic remains in the ModelCreationProvider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../fog.dart'; // Import the ScrollFog widget.
import '../../../../l10n/app_localizations.dart';
import '../../../../theme.dart';
import '../../providers/new.dart';
import 'widgets/form.dart';
import 'widgets/header.dart';
import 'widgets/selector.dart';

/// A widget that builds the body of the "Create Roleplay Model" form.
class CreateForm extends StatefulWidget {
  const CreateForm({super.key});

  @override
  State<CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {
  // A controller to manage the scroll position for the fog effect.
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ModelCreationProvider>();
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
      // The ScrollFog is now configured to show the effect only at the top.
      child: ScrollFog(
        scrollController: _scrollController,
        fogColor: AppColors.background,
        topFogHeight: screenHeight * 0.02,
        showTop: true,     // Explicitly enable the top fog.
        showBottom: false,  // Explicitly disable the bottom fog.
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              CreationProfileHeader(
                nameController: provider.nameController,
                summaryController: provider.summaryController,
                pickedImage: provider.pickedImage,
                onPickImage: provider.isPickerActive ? () {} : provider.pickImage,
                onRemoveImage: provider.removeImage,
                nameShakeController: provider.nameShakeController,
              ),
              SizedBox(height: screenHeight * 0.02),

              BaseModelSelector(
                availableBaseModels: provider.availableBaseModels,
                selectedBaseModelId: provider.selectedBaseModelId,
                selectedBaseModelDisplayTitle: provider.selectedBaseModelDisplayTitle,
                isPanelExpanded: provider.isBaseModelPanelExpanded,
                onTogglePanel: provider.toggleBaseModelPanel,
                onSelectBaseModel: provider.selectBaseModel,
              ),
              SizedBox(height: screenHeight * 0.02),

              CreationFormSection(
                title: localizations.preInputTitle,
                description: localizations.preInputDescription,
                controller: provider.aiPromptController,
                hintText: localizations.preInputTitle,
                maxLength: 200,
                maxLines: 3,
              ),
              SizedBox(height: screenHeight * 0.02),

              CreationFormSection(
                title: localizations.aiExplanationTitle,
                description: localizations.aiExplanationDescription,
                controller: provider.modelExplanationController,
                hintText: localizations.aiExplanationTitle,
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}