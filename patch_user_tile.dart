import 'dart:io';

void main() {
  final file = File('lib/chat/messages/tiles/user.dart');
  var content = file.readAsStringSync();
  
  if (content.contains('widget.message.timestamp')) {
    print('Already patched user tile');
    return;
  }
  
  final target = '''
                              child: Text(
                                widget.message.text,
                                style: TextStyle(
                                  color: AppColors.primaryColor.inverted,
                                  fontSize: 16 * scale,
                                ),
                              ),''';
                              
  final replacement = '''
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    widget.message.text,
                                    style: TextStyle(
                                      color: AppColors.primaryColor.inverted,
                                      fontSize: 16 * scale,
                                    ),
                                  ),
                                  if (widget.message.timestamp != null) ...[
                                    SizedBox(height: 4 * scale),
                                    Text(
                                      "\${widget.message.timestamp!.hour.toString().padLeft(2, '0')}:\${widget.message.timestamp!.minute.toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        color: AppColors.primaryColor.inverted.withValues(alpha: 0.5),
                                        fontSize: 10 * scale,
                                        fontFamily: 'Impact',
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ],
                              ),''';
                              
  content = content.replaceFirst(target, replacement);
  file.writeAsStringSync(content);
  print('User tile patched');
}
