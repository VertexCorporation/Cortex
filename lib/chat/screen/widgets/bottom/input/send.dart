part of 'input.dart';

class _SendButtonSection extends StatelessWidget {
  final double? recordingProgress;
  final double screenWidth;
  final bool isTablet;
  final InputField widget;
  final bool isEnabled;
  final bool isActionPermitted;
  final TextEditingController controller;
  final double bubbleScale;
  const _SendButtonSection({
    this.recordingProgress,
    required this.screenWidth,
    required this.isTablet,
    required this.widget,
    required this.isEnabled,
    required this.isActionPermitted,
    required this.controller,
    this.bubbleScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isConnected = context.watch<InternetProvider>().isConnected;
    final inputProvider = context.watch<InputProvider>();
    final speechService = context.watch<SpeechService>();

    bool effectiveEnabled = isEnabled;
    if ((widget.isServerSideModel || widget.isDynamicChatMode) &&
        !isConnected) {
      effectiveEnabled = false;
    }

    VoidCallback? effectiveOnStop;
    if (inputProvider.isVoiceRecording) {
      effectiveOnStop = () async {
        inputProvider.setVoiceRecording(false);
        await speechService.stopListening();
      };
    } else {
      effectiveOnStop = widget.onStop;
    }

    // Only the detachable action bubble. The microphone is a separate,
    // permanently-anchored control placed by the composer row itself and
    // never merges with this button.
    return ActionButtonWidget(
      isEnabled: effectiveEnabled,
      isActionPermitted: isActionPermitted,
      isSending: widget.isSending,
      isRecording: inputProvider.isVoiceRecording,
      recordingProgress: recordingProgress,
      isTextEmpty: controller.text.trim().isEmpty,
      onSend: widget.onSend,
      onStop: effectiveOnStop,
      controller: controller,
      includeMic: false,
      bubbleScale: bubbleScale,
    );
  }
}
