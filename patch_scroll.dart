import 'dart:io';

void main() {
  final file = File('lib/chat/services/scroll.dart');
  var content = file.readAsStringSync();
  
  final target = '''
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.025),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.95),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                'assets/icons/arrov.svg',
                width: screenWidth * 0.045,
                height: screenWidth * 0.045,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),''';
            
  final replacement = '''
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.025),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(
                  color: AppColors.border,
                  width: 2,
                ),
                borderRadius: BorderRadius.zero,
              ),
              child: SvgPicture.asset(
                'assets/icons/arrov.svg',
                width: screenWidth * 0.045,
                height: screenWidth * 0.045,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),''';
            
  content = content.replaceFirst(target, replacement);
  file.writeAsStringSync(content);
  print('Scroll patched');
}
