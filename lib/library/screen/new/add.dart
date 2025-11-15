// lib/screens/models/screen/new/add.dart

// This file contains the VIEW for the "Add Local Model" screen.
// It is now a StatefulWidget to manage its own ScrollController, enabling a
// visually pleasing fog effect at the top and bottom of the scrollable content area.
// All business logic remains delegated to the `ModelCreationProvider`.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../fog.dart'; // Import the ScrollFog widget.
import '../../../../l10n/app_localizations.dart';
import '../../../../theme.dart';
import '../../providers/new.dart';
import 'widgets/file.dart';
import 'widgets/form.dart';
import 'widgets/header.dart';

/// A widget that builds the body of the "Add Local Model" (GGUF) form.
class AddForm extends StatefulWidget {
  const AddForm({super.key});

  @override
  State<AddForm> createState() => _AddFormState();
}

class _AddFormState extends State<AddForm> {
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
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context)!;
    final provider = context.watch<ModelCreationProvider>();

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