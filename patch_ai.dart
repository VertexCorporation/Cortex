import 'dart:io';

void main() {
  final file = File('lib/chat/messages/tiles/ai.dart');
  var content = file.readAsStringSync();
  
  if (content.contains('widget.message.timestamp')) {
    print('Already patched ai tile');
    return;
  }
  
  final target = '''
                                    _AiBodyContent(
                                      message: widget.message,
                                      embeddedMedia: widget.embeddedMedia,
                                      mediaAboveText: widget.mediaAboveText,
                                      stableText: _stableText,
                                      animatingText: _animatingText,
                                      textAnimCtl: _textAnimCtl,
                                      scale: scale,
                                      parseCache: _parseCache,
                                    ),''';
                                    
  final replacement = '''
                                    _AiBodyContent(
                                      message: widget.message,
                                      embeddedMedia: widget.embeddedMedia,
                                      mediaAboveText: widget.mediaAboveText,
                                      stableText: _stableText,
                                      animatingText: _animatingText,
                                      textAnimCtl: _textAnimCtl,
                                      scale: scale,
                                      parseCache: _parseCache,
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
                                    ],''';
                                    
  content = content.replaceFirst(target, replacement);
  file.writeAsStringSync(content);
  print('Ai tile patched');
}
