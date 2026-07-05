old_text = """                      if (memoryProvider.memoryList.isNotEmpty)
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              _showClearMemoryDialog(context);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 8 * scale),
                              child: Text(
                                l10n.clearMemory,
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13 * scale,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),"""

new_text = """                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.read<UserMemoryProvider>().addMemory("");
                            },
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 8 * scale),
                              child: Icon(
                                Icons.add_circle_outline,
                                color: AppColors.primaryColor.inverted,
                                size: 20 * scale,
                              ),
                            ),
                          ),
                          if (memoryProvider.memoryList.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _showClearMemoryDialog(context);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 8 * scale),
                                child: Text(
                                  l10n.clearMemory,
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 13 * scale,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),"""

with open('lib/settings/sections/personalization.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace(old_text, new_text)

with open('lib/settings/sections/personalization.dart', 'w', encoding='utf-8') as f:
    f.write(content)
