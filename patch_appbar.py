import re

with open('lib/chat/screen/appbar/appbar.dart', 'r') as f:
    content = f.read()

replacement = """actions: [
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
                      key: ValueKey('ghost_${session.isFluxMode}'),
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
                      key: ValueKey('offline_${session.selectedModel?.type == 'offline'}'),
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
          ],
"""

content = re.sub(r'actionButton:\s*DualActionPill\([\s\S]*?onSecondaryTap:\s*\(\)\s*\{[\s\S]*?\}\s*,\s*\)\s*,\s*\n\s*\),', replacement + '\n        ),', content)

if 'import \'package:cortex/settings/controller.dart\';' not in content:
    content = 'import \'package:cortex/settings/controller.dart\';\n' + content

with open('lib/chat/screen/appbar/appbar.dart', 'w') as f:
    f.write(content)
