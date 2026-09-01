// lib/settings/sections/voice.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../chat/services/tts_remote.dart';
import '../../chat/services/voice_catalog.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';

/// Lets the user choose which voice Cortex speaks with in voice mode.
///
/// The list is published in Firestore rather than built into the app, so this
/// section hides itself entirely when no voices are configured — an empty
/// picker is worse than no picker, and the server falls back to its default
/// either way.
class VoiceSection extends StatelessWidget {
  const VoiceSection({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final catalog = context.watch<VoiceCatalogProvider>();
    final localizations = AppLocalizations.of(context)!;

    if (catalog.voices.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final selected = catalog.selectedVoice;
    final currentName = selected?.name ?? localizations.voiceDefaultOption;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.voiceSelection,
          style: TextStyle(
            color: AppColors.primaryColor.inverted,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          localizations.voiceSelectionDescription,
          style: TextStyle(
            color: AppColors.quinaryColor,
            fontSize: screenWidth * 0.035,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Material(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(10.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              _showVoiceSelectionDialog(context);
            },
            borderRadius: BorderRadius.circular(10.0),
            splashColor: AppColors.quaternaryColor.withValues(alpha: 0.3),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.02,
                horizontal: screenWidth * 0.04,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      currentName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.primaryColor.inverted,
                        fontSize: screenWidth * 0.041,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primaryColor.inverted,
                    size: screenWidth * 0.04,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showVoiceSelectionDialog(BuildContext context) async {
    final catalog = context.read<VoiceCatalogProvider>();
    final localizations = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _VoiceSelectionDialog(
        catalog: catalog,
        localizations: localizations,
      ),
    );
  }
}

class _VoiceSelectionDialog extends StatefulWidget {
  const _VoiceSelectionDialog({
    required this.catalog,
    required this.localizations,
  });

  final VoiceCatalogProvider catalog;
  final AppLocalizations localizations;

  @override
  State<_VoiceSelectionDialog> createState() => _VoiceSelectionDialogState();
}

class _VoiceSelectionDialogState extends State<_VoiceSelectionDialog> {
  /// Which row is currently fetching or playing its sample. Only one at a time
  /// — overlapping samples are unlistenable and each one costs credits.
  String? _previewingId;

  @override
  void dispose() {
    // Leaving the dialog mid-sample should stop it, not let it play on over
    // whatever the user opened next.
    RemoteTtsService.instance.stop();
    super.dispose();
  }

  Future<void> _preview(String voiceId) async {
    if (_previewingId != null) {
      await RemoteTtsService.instance.stop();
      if (_previewingId == voiceId) {
        if (mounted) setState(() => _previewingId = null);
        return;
      }
    }

    setState(() => _previewingId = voiceId);

    final audio = await RemoteTtsService.instance.synthesize(
      widget.localizations.voicePreviewText,
      voiceId: voiceId,
    );

    if (!mounted) return;
    if (audio == null) {
      setState(() => _previewingId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.localizations.voicePreviewFailed)),
      );
      return;
    }

    await RemoteTtsService.instance.play(audio);
    if (mounted && _previewingId == voiceId) {
      setState(() => _previewingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final voices = widget.catalog.voices;
    final selectedId = widget.catalog.effectiveVoiceId;

    return Dialog(
      backgroundColor: AppColors.secondaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.05,
                screenHeight * 0.025,
                screenWidth * 0.05,
                screenHeight * 0.012,
              ),
              child: Text(
                widget.localizations.voiceSelection,
                style: TextStyle(
                  color: AppColors.primaryColor.inverted,
                  fontSize: screenWidth * 0.048,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: screenHeight * 0.012),
                itemCount: voices.length,
                itemBuilder: (context, index) {
                  final voice = voices[index];
                  final isSelected = voice.id == selectedId;
                  final isPreviewing = _previewingId == voice.id;

                  return InkWell(
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      await widget.catalog.select(voice.id);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.015,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  voice.name,
                                  style: TextStyle(
                                    color: AppColors.primaryColor.inverted,
                                    fontSize: screenWidth * 0.042,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                                if (voice.description != null) ...[
                                  SizedBox(height: screenHeight * 0.004),
                                  Text(
                                    voice.description!,
                                    style: TextStyle(
                                      color: AppColors.quinaryColor,
                                      fontSize: screenWidth * 0.033,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: widget.localizations.voicePreview,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _preview(voice.id);
                            },
                            icon: isPreviewing
                                ? SizedBox(
                                    width: screenWidth * 0.045,
                                    height: screenWidth * 0.045,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryColor.inverted,
                                    ),
                                  )
                                : Icon(
                                    Icons.play_circle_outline,
                                    color: AppColors.primaryColor.inverted,
                                    size: screenWidth * 0.055,
                                  ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check,
                              color: AppColors.primaryColor.inverted,
                              size: screenWidth * 0.05,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
