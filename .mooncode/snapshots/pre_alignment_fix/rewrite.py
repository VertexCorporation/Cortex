import re

with open('lib/chat/screen/widgets/bottom/input/input.dart', 'r', encoding='utf-8') as f:
    text = f.read()

old_block = """                              Padding(
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

new_block = """                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      start: isTablet ? screenWidth * 0.02 : 12.0,
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

pattern = re.compile(re.escape(old_block).replace(r'\ ', r'\s+').replace(r'\n', r'\s*'), re.MULTILINE)
matches = pattern.findall(text)

if len(matches) > 0:
    new_text = pattern.sub(new_block, text, count=1)
    with open('lib/chat/screen/widgets/bottom/input/input.dart', 'w', encoding='utf-8') as f:
        f.write(new_text)
    print("Success")
else:
    print("Not found")
