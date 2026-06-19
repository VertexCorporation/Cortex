import 'dart:io';

void main() {
  final file = File('lib/chat/messages/messages.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains('final DateTime? timestamp;')) {
    content = content.replaceFirst('final bool isServerFallback;', 'final bool isServerFallback;\n  final DateTime? timestamp;');
    content = content.replaceFirst('this.isServerFallback = false,', 'this.isServerFallback = false,\n    this.timestamp,');
    content = content.replaceFirst('this.isServerFallback = false,', 'this.isServerFallback = false,\n    this.timestamp,');
    content = content.replaceFirst('timestamp: DateTime.now(),', '');
    content = content.replaceFirst('model: model,', 'model: model,\n      timestamp: DateTime.now(),');
    content = content.replaceFirst('isServerFallback: isServerFallback,', 'isServerFallback: isServerFallback,\n      timestamp: DateTime.now(),');
    
    // In copyWith
    content = content.replaceFirst('bool? isServerFallback,', 'bool? isServerFallback,\n    DateTime? timestamp,');
    content = content.replaceFirst('isServerFallback: isServerFallback ?? this.isServerFallback,', 'isServerFallback: isServerFallback ?? this.isServerFallback,\n      timestamp: timestamp ?? this.timestamp,');
    
    // In fromMap
    content = content.replaceFirst("return Message(", "DateTime? ts;\n    if (map['ts'] != null) ts = DateTime.fromMillisecondsSinceEpoch(map['ts'] as int);\n    return Message(");
    content = content.replaceFirst("isServerFallback: (map['isServerFallback'] ?? 0) == 1,", "isServerFallback: (map['isServerFallback'] ?? 0) == 1,\n      timestamp: ts,");
    
    // In toMap
    content = content.replaceFirst("'isServerFallback': isServerFallback ? 1 : 0,", "'isServerFallback': isServerFallback ? 1 : 0,\n      'ts': timestamp?.millisecondsSinceEpoch,");
    
    file.writeAsStringSync(content);
    print('Messages patched');
  } else {
    print('Already patched');
  }
}
