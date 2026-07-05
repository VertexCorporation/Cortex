// lib/screens/models/screen/new/create.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/new.dart';
import 'widgets/form.dart';
import 'widgets/header.dart';
import 'widgets/selector.dart';

class CreateForm extends StatelessWidget {
  final ScrollController scrollController;

  const CreateForm({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ModelCreationProvider>();
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final localizations = AppLocalizations.of(context)!;

    final double horizontalPadding = screenWidth * 0.04;

    final double topContentPadding = MediaQuery
        .of(context)
        .padding
        .top;

    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.only(
        top: topContentPadding,
        bottom: screenHeight * 0.05,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
              selectedBaseModelDisplayTitle: provider
                  .selectedBaseModelDisplayTitle,
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
    );
  }
}