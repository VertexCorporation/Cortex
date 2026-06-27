import re

with open('lib/chat/screen/widgets/bottom/input/input.dart', 'r') as f:
    content = f.read()

old_str = """                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: isTablet ? screenWidth * 0.02 : 8.0),
                                child: _TextFieldSection(
                                  key: const ValueKey('textfield'),
                                  controller: widget.controller,
                                  focusNode: widget.textFieldFocusNode,
                                  localizations: widget.localizations,
                                  screenWidth: screenWidth,
                                  isTablet: isTablet,
                                  showHintText: true,
                                  onEnterPressed: () {
                                    if (isSendButtonEnabled) {
                                      widget.onSend();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      start: isTablet ? screenWidth * 0.02 : 12.0,
                                      bottom: 4.0,
                                    ),
                                    child: AddPhotoButton(
                                      isLimitExceeded: widget.isLimitExceeded,
                                      isPhotoLoading: widget.isPhotoLoading,
                                      localizations: widget.localizations,
                                      controller: widget.controller,
                                    ),
                                  ),

                                  const Spacer(),"""

new_str = """                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      start: isTablet ? screenWidth * 0.02 : 12.0,
                                      bottom: 4.0,
                                    ),
                                    child: AddPhotoButton(
                                      isLimitExceeded: widget.isLimitExceeded,
                                      isPhotoLoading: widget.isPhotoLoading,
                                      localizations: widget.localizations,
                                      controller: widget.controller,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: isTablet ? screenWidth * 0.02 : 8.0),
                                      child: _TextFieldSection(
                                        key: const ValueKey('textfield'),
                                        controller: widget.controller,
                                        focusNode: widget.textFieldFocusNode,
                                        localizations: widget.localizations,
                                        screenWidth: screenWidth,
                                        isTablet: isTablet,
                                        showHintText: true,
                                        onEnterPressed: () {
                                          if (isSendButtonEnabled) {
                                            widget.onSend();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  const Spacer(),"""

# Use string replace to be safe
new_content = content.replace(old_str, new_str)
if new_content == content:
    print("Replace failed!")
else:
    with open('lib/chat/screen/widgets/bottom/input/input.dart', 'w') as f:
        f.write(new_content)
    print("Success")
