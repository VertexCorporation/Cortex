// lib/screens/models/screen/new/add.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/new.dart';
import 'widgets/file.dart';
import 'widgets/form.dart';
import 'widgets/header.dart';

class AddForm extends StatelessWidget {
  final ScrollController scrollController;

  const AddForm({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context)!;
    final provider = context.watch<ModelCreationProvider>();

    final double horizontalPadding = screenWidth * 0.04;

    final double topContentPadding = MediaQuery.of(context).padding.top;

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
              onPickImage: provider.pickImage,
              onRemoveImage: provider.removeImage,
              nameShakeController: provider.nameShakeController,
            ),
            SizedBox(height: screenHeight * 0.02),
            GgufFilePicker(
              ggufFile: provider.ggufFile,
              onPickFile: () => provider.pickGgufFile(context),
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
