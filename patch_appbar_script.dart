import 'dart:io';

void main() {
  final file = File('lib/chat/screen/appbar/appbar.dart');
  var content = file.readAsStringSync();

  final dualActionPillCode = '''
 actionButton: DualActionPill(
 size: buttonSize,
 // Always dual mode now.
 isDual: true,

 // --- MAIN ICON (Right Side) ---
 // If chat active -> New Chat Icon
 // If chat empty -> Flux Icon (On/Off)
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

 // --- SECONDARY ICON (Left Side) ---
 // If chat active -> Share button
 // If chat empty -> Offline Mode Toggle
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
 key: ValueKey('offline_\${session.selectedModel?.type == 'offline'}'),
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
 ),''';

  final replacement = '''
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
 key: ValueKey('offline_\${session.selectedModel?.type == 'offline'}'),
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
 mainScreenKey.currentState?.pushScreen(MainScreenPage.settings);
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
 ],''';

  content = content.replaceFirst(dualActionPillCode, replacement);
  file.writeAsStringSync(content);
}
