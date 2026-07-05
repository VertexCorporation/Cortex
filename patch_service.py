import re

with open('lib/library/backend/data/service.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add _pendingFetch variable
content = re.sub(
    r'  String\? _cachedEntitiesLangCode;\n',
    r'  String? _cachedEntitiesLangCode;\n\n  Future<List<ModelEntity>?>? _pendingFetch;\n',
    content
)

old_method_start = r'Future<List<ModelEntity>\?> getModels\(\{required String langCode\}\) async \{'
new_method_start = r'''Future<List<ModelEntity>?> getModels({required String langCode}) {
    if (_pendingFetch != null) return _pendingFetch!;
    _pendingFetch = _getModelsInternal(langCode: langCode).whenComplete(() {
      _pendingFetch = null;
    });
    return _pendingFetch!;
  }

  Future<List<ModelEntity>?> _getModelsInternal({required String langCode}) async {'''

content = content.replace('Future<List<ModelEntity>?> getModels({required String langCode}) async {', new_method_start)

with open('lib/library/backend/data/service.dart', 'w', encoding='utf-8') as f:
    f.write(content)
