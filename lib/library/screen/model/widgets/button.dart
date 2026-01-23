// lib/screens/models/screen/model/widgets/button.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../internet.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme.dart';
import '../../../backend/utils.dart';
import '../../../providers/details.dart';
import '../../../providers/local.dart';
import '../../models/widgets/cancel.dart';

/// The bottom navigation bar for the Model Detail screen, handling all user actions.
///
/// This widget adapts its appearance and functionality based on the model's
/// state: whether it's a server-side model, a downloadable offline model,
/// a user-created model, or currently in the process of being downloaded or deleted.
class BottomActionButtons extends StatelessWidget {
  const BottomActionButtons({super.key});

  /// A unified method to handle starting a chat and navigating away.
  void _startChat(BuildContext context, ModelDetailProvider provider) {
    // filePath is only relevant for downloaded offline models.
    final filePath = !provider.mainModel!.isServerSide && provider.isDownloaded
        ? context
        .read<ModelLocalStateProvider>()
        .getFilePathById(provider.mainModel!.id)
        : null;

    // Pop the screen and return a map containing the action and the necessary data.
    Navigator.of(context).pop({
      'action': 'start_chat',
      'modelId': provider.mainModel!.id,
      'filePath': filePath,
      'model_updated':
      provider.didBaseModelChange, // Pass along the update status
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final localizations = AppLocalizations.of(context)!;
    final provider = context.watch<ModelDetailProvider>();
    final mainModel = provider.mainModel;

    if (mainModel == null) {
      return const SizedBox.shrink();
    }

    // --- UNIFIED HEIGHT CONSTANT ---
    // All button widgets will be constrained to this height.
    final double buttonHeight = screenWidth * 0.125;

    Widget buildContainer(Widget child) {
      return SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.01,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 6, offset: Offset(0, -2))
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(screenWidth * 0.05),
              topRight: Radius.circular(screenWidth * 0.05),
            ),
          ),
          // Constrain the height of the child for consistency.
          child: SizedBox(height: buttonHeight, child: child),
        ),
      );
    }

    // --- DECISION LOGIC ---

    // CASE 1: The model is a user-created custom model.
    if (provider.isUserCreatedModel) {
      return buildContainer(
        _buildRemoveOrChatButtons(context, provider, localizations),
      );
    }
    // CASE 2: The model is a downloadable (offline) model.
    else if (!mainModel.isServerSide) {
      return buildContainer(
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: provider.isDownloaded
              ? _buildRemoveOrChatButtons(context, provider, localizations)
          // Pass the buttonHeight to ensure consistent sizing.
              : _buildDownloadOrCancelButtons(
              context, provider, localizations, buttonHeight),
        ),
      );
    }
    // CASE 3: It's a non-removable, server-side model.
    else {
      return buildContainer(
        _buildChatOnlyButton(context, provider, localizations),
      );
    }
  }

  /// Builds the "Remove / Chat" button row for downloaded or user-created models.
  Widget _buildRemoveOrChatButtons(BuildContext context,
      ModelDetailProvider provider,
      AppLocalizations localizations,) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Container(
      key: const ValueKey('removeAndChat'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: provider.isDeleting
                  ? null
                  : () async {
                HapticFeedback.lightImpact(); // Add haptic context
                final success = await provider.removeModel(context);
                if (success &&
                    provider.isUserCreatedModel &&
                    context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(screenWidth * 0.03),
                bottomLeft: Radius.circular(screenWidth * 0.03),
              ),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.septenaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(screenWidth * 0.03),
                    bottomLeft: Radius.circular(screenWidth * 0.03),
                  ),
                ),
                child: Text(
                  localizations.remove,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Container(width: 1.0, color: AppColors.border),
          Expanded(
            child: InkWell(
              onTap: provider.isDeleting
                  ? null
                  : () {
                HapticFeedback.lightImpact();
                _startChat(context, provider);
              },
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(screenWidth * 0.03),
                bottomRight: Radius.circular(screenWidth * 0.03),
              ),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.senaryColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(screenWidth * 0.03),
                    bottomRight: Radius.circular(screenWidth * 0.03),
                  ),
                ),
                child: Text(
                  localizations.chat,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the "Download" or "Cancel" button for models that are not yet downloaded.
  Widget _buildDownloadOrCancelButtons(BuildContext context,
      ModelDetailProvider provider,
      AppLocalizations localizations,
      // Accept buttonHeight as a parameter for consistent sizing.
      double buttonHeight,) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final localProvider = context.read<ModelLocalStateProvider>();

    if (provider.isDownloading || provider.isPaused) {
      return AnimatedCancelButton(
          key: const ValueKey('cancelButton'),
          onPressed: () => localProvider.cancelDownload(provider.mainModel!.id),
          width: double.infinity,
          height: buttonHeight,
          borderRadius: screenWidth * 0.03,
          borderColor: AppColors.primaryColor.inverted,
          text: localizations.cancel,
          fontSize: screenWidth * 0.04,
          strokeFactor: 0.004);
    }

    return StreamBuilder<bool>(
      key: const ValueKey('downloadButton'),
      stream: InternetService().onConnectivityChanged,
      initialData: InternetService().currentStatus,
      builder: (context, snapshot) {
        final hasInternet = snapshot.data ?? false;
        final compatibility =
        localProvider.getCompatibilityStatus(provider.mainModel!.size);
        final isCompatible = compatibility == CompatibilityStatus.compatible;

        String buttonText;
        if (!hasInternet) {
          buttonText = localizations.noInternetConnection;
        } else if (!isCompatible) {
          buttonText = compatibility == CompatibilityStatus.insufficientRAM
              ? localizations.insufficientRAM
              : localizations.insufficientStorage;
        } else {
          buttonText = localizations.download;
        }

        final isButtonEnabled = hasInternet && isCompatible;

        return SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: isButtonEnabled && !provider.isButtonLocked
                ? () {
              HapticFeedback.lightImpact();
              localProvider.requestPermissionAndStartDownload(
                context: context,
                id: provider.mainModel!.id,
                url: provider.mainModel!.url,
              );
            }
                : null,
            style: ElevatedButton.styleFrom(
              // Changed button color to primaryColor.inverted.
              backgroundColor: AppColors.primaryColor.inverted,
              foregroundColor: Colors.white,
              // Updated disabled color to match the new background color.
              disabledBackgroundColor:
              AppColors.primaryColor.inverted.withValues(alpha: 0.5),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03)),
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor),
            ),
          ),
        );
      },
    );
  }

  /// Builds a simple, full-width "Chat" button.
  Widget _buildChatOnlyButton(BuildContext context,
      ModelDetailProvider provider,
      AppLocalizations localizations,) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Container(
      key: const ValueKey('chatOnly'),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.03)),
      child: InkWell(
        onTap: provider.isDeleting
            ? null
            : () {
          HapticFeedback.lightImpact();
          _startChat(context, provider);
        },
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.senaryColor,
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
          child: Text(
            localizations.chat,
            style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
