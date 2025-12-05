// lib/screens/models/screen/new/add.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../fog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme.dart';
import '../../providers/new.dart';
import 'widgets/file.dart';
import 'widgets/form.dart';
import 'widgets/header.dart';

class AddForm extends StatefulWidget {
  const AddForm({super.key});

  @override
  State<AddForm> createState() => _AddFormState();
}

class _AddFormState extends State<AddForm> {
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context)!;
    final provider = context.watch<ModelCreationProvider>();

    final double horizontalPadding = screenWidth * 0.04;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: ScrollFog(
        scrollController: _scrollController,
        fogColor: AppColors.background,
        topFogHeight: screenHeight * 0.02,
        showTop: true,
        showBottom: false,
        child: SingleChildScrollView(
          controller: _scrollController,
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
      ),
    );
  }
}