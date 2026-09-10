part of 'input.dart';

class _TextFieldSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final AppLocalizations localizations;
  final double screenWidth;
  final bool isTablet;
  final VoidCallback onEnterPressed;
  final bool showHintText;

  const _TextFieldSection({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.localizations,
    required this.screenWidth,
    required this.isTablet,
    required this.onEnterPressed,
    this.showHintText = true,
  });

  @override
  Widget build(BuildContext context) {
    final double fontSize = isTablet ? screenWidth * 0.025 : screenWidth * 0.04;
    final double verticalPadding = 8.0;
    final double horizontalPadding = 4.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.0),
      child: TextField(
        key: const ValueKey('chat_input_field'),
        focusNode: focusNode,
        cursorColor: AppColors.primaryColor.inverted,
        controller: controller,
        maxLength: 4000,
        minLines: 1,
        maxLines: 6,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
              vertical: verticalPadding, horizontal: horizontalPadding),
          // The localized hint scales itself down to whatever width the
          // compact capsule gives the field instead of clipping or wrapping,
          // and returns to its natural size once the field is wide enough.
          hint: showHintText
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    localizations.messageHint,
                    maxLines: 1,
                    style:
                        TextStyle(color: Colors.grey[600], fontSize: fontSize),
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          counterText: '',
        ),
        style: TextStyle(
            color: AppColors.primaryColor.inverted, fontSize: fontSize),
        onSubmitted: (_) => onEnterPressed(),
      ),
    );
  }
}
