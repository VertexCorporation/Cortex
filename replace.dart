import 'dart:io';

void main() {
  final file = File('lib/chat/screen/appbar/appbar.dart');
  var content = file.readAsStringSync();
  final startStr = 'actionButton: DualActionPill(';
  
  int startIdx = content.indexOf(startStr);
  if (startIdx == -1) return;
  
  int endIdx = content.indexOf('),', startIdx + startStr.length);
  // Need to find the closing parenthesis of DualActionPill.
  // A simple way is to use regex or find 'onSecondaryTap' block.
  
  final endStr = 'onSecondaryTap: () {\n                if (isChatActive) {\n                  _handleShare(context);\n                } else {\n                  _handleOfflineModeToggle(context, session);\n                }\n              },\n            ),\n          ),';
  
  final regex = RegExp(r'actionButton: DualActionPill\([\s\S]*?onSecondaryTap: \(\) \{[\s\S]*?\},[\s\S]*?\),');
  
  final match = regex.firstMatch(content);
  if (match != null) {
    content = content.replaceRange(match.start, match.end, '''
actions: [
            DualActionPill(
              size: buttonSize,
              isDual: true,
              mainIcon: isChatActive
                  ? SvgPicture.asset(
                      'assets/icons/new.svg',
                      key: const ValueKey('new_chat_icon'),
                      width: iconSize,
                      height: iconSize,
                      colorFilter: ColorFilter.mode(
                        AppColors.primaryColor.inverted,
                        BlendMode.srcIn,
                      ),
                    )
                  : SvgPicture.asset(
                      session.isFluxMode
                          ? 'assets/icons/on/ghost.svg'
                          : 'assets/icons/off/ghost.svg',
                      key: ValueKey('ghost_\${session.isFluxMode}'),
                      width: iconSize,
                      height: iconSize,
                      colorFilter: ColorFilter.mode(
                        AppColors.primaryColor.inverted,
                        BlendMode.srcIn,
                      ),
                    ),
              onMainTap: () {
                if (isChatActive) {
                  _handleNewChat(context);
                } else {
                  _handleFluxModeToggle(context);
                }
              },
              secondaryIcon: isChatActive
                  ? SvgPicture.asset(
                      'assets/icons/world.svg',
                      width: iconSize - 2,
                      height: iconSize - 2,
                      colorFilter: ColorFilter.mode(
                        AppColors.primaryColor.inverted,
                        BlendMode.srcIn,
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/icons/storage.svg',
                      key: ValueKey('offline_\${session.selectedModel?.type == \'offline\'}'),
                      width: iconSize - 2,
                      height: iconSize - 2,
                      colorFilter: ColorFilter.mode(
                        session.selectedModel?.type == 'offline'
                            ? AppColors.primaryColor.inverted
                            : AppColors.primaryColor.inverted.withValues(alpha: 0.5),
                        BlendMode.srcIn,
                      ),
                    ),
              onSecondaryTap: () {
                if (isChatActive) {
                  _handleShare(context);
                } else {
                  _handleOfflineModeToggle(context, session);
                }
              },
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                navigateToScreen(const SettingsScreen());
              },
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  border: Border.all(color: AppColors.border, width: 2),
                  borderRadius: BorderRadius.zero,
                ),
                child: Center(
                  child: Text(
                    userProvider.profileInitial,
                    style: TextStyle(
                      color: AppColors.primaryColor.inverted,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Impact',
                    ),
                  ),
                ),
              ),
            ),
          ]''');
          
    if (!content.contains('package:cortex/settings/controller.dart')) {
      content = "import 'package:cortex/settings/controller.dart';\n" + content;
    }
    file.writeAsStringSync(content);
    print('Patched successfully');
  } else {
    print('No match found');
  }
}
