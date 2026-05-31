part of 'input.dart';

class _SendButtonSection extends StatelessWidget {
  final double screenWidth;
  final bool isTablet;
  final InputField widget;
  final bool isEnabled;
  final bool isActionPermitted;
  final TextEditingController controller;

  const _SendButtonSection({
    required this.screenWidth,
    required this.isTablet,
    required this.widget,
    required this.isEnabled,
    required this.isActionPermitted,
    required this.controller,
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

    return Padding(
      padding: EdgeInsetsDirectional.only(
        end: isTablet ? screenWidth * 0.02 : 16.0,
      ),
      child: ActionButtonWidget(
        isEnabled: effectiveEnabled,
        isActionPermitted: isActionPermitted,
        isSending: widget.isSending,
        isRecording: inputProvider.isVoiceRecording,
        isTextEmpty: controller.text.trim().isEmpty,
        onSend: widget.onSend,
        onStop: effectiveOnStop,
        controller: controller,
      ),
    );
  }
}
