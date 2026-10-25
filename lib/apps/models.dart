// lib/apps/models.dart
//
// Data models for Cortex Apps: third-party services (Gmail, Notion, GitHub…)
// the user connects through Fulcrum's Composio integration endpoints.

/// How freely Cortex may use a connected app in chats. Mirrors the
/// `permission` values stored and enforced by Fulcrum.
enum AppPermission {
  ask('ask'),
  allow('allow'),
  readOnly('read_only'),
  off('off');

  const AppPermission(this.wire);

  final String wire;

  static AppPermission fromWire(Object? value) {
    for (final permission in values) {
      if (permission.wire == value) return permission;
    }
    return AppPermission.ask;
  }
}

class AppCategory {
  final String id;
  final String name;

  const AppCategory({required this.id, required this.name});

  factory AppCategory.fromJson(Map<String, dynamic> json) => AppCategory(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
      );
}

class CortexApp {
  final String slug;
  final String name;
  final String? logo;
  final String description;
  final List<AppCategory> categories;
  final int toolsCount;
  final bool connected;
  final String? connectionStatus;
  final String? connectedAccountId;
  final AppPermission permission;

  /// Position in Fulcrum's usage-sorted catalog; lower is more popular.
  final int rank;

  const CortexApp({
    required this.slug,
    required this.name,
    required this.logo,
    required this.description,
    required this.categories,
    required this.toolsCount,
    required this.connected,
    required this.connectionStatus,
    required this.connectedAccountId,
    required this.permission,
    required this.rank,
  });

  factory CortexApp.fromJson(Map<String, dynamic> json, {int rank = 0}) {
    final logo = json['logo']?.toString();
    final categories = json['categories'];
    return CortexApp(
      slug: (json['slug'] ?? '').toString(),
      name: (json['name'] ?? json['slug'] ?? '').toString(),
      logo: logo != null && logo.startsWith('https://') ? logo : null,
      description: (json['description'] ?? '').toString().trim(),
      categories: categories is List
          ? categories
              .whereType<Map>()
              .map((c) => AppCategory.fromJson(Map<String, dynamic>.from(c)))
              .where((c) => c.id.isNotEmpty || c.name.isNotEmpty)
              .toList()
          : const [],
      toolsCount: (json['toolsCount'] as num?)?.toInt() ?? 0,
      connected: json['connected'] == true,
      connectionStatus: json['connectionStatus']?.toString(),
      connectedAccountId: json['connectedAccountId']?.toString(),
      permission: AppPermission.fromWire(json['permission']),
      rank: rank,
    );
  }

  /// A connection that started but never finished OAuth.
  bool get isPending =>
      !connected &&
      connectedAccountId != null &&
      const {'INITIATED', 'INITIALIZING'}.contains(connectionStatus);

  CortexApp copyWith({
    bool? connected,
    String? connectionStatus,
    String? connectedAccountId,
    bool clearAccount = false,
    AppPermission? permission,
  }) {
    return CortexApp(
      slug: slug,
      name: name,
      logo: logo,
      description: description,
      categories: categories,
      toolsCount: toolsCount,
      connected: connected ?? this.connected,
      connectionStatus:
          clearAccount ? null : connectionStatus ?? this.connectionStatus,
      connectedAccountId:
          clearAccount ? null : connectedAccountId ?? this.connectedAccountId,
      permission: permission ?? this.permission,
      rank: rank,
    );
  }
}

/// An app action discovered for the current chat request.
class AppAction {
  final String slug;
  final String name;
  final String description;
  final String toolkitSlug;
  final String toolkitName;
  final String? toolkitLogo;
  final bool readOnly;
  final Map<String, dynamic> inputParameters;

  const AppAction({
    required this.slug,
    required this.name,
    required this.description,
    required this.toolkitSlug,
    required this.toolkitName,
    required this.toolkitLogo,
    required this.readOnly,
    required this.inputParameters,
  });

  factory AppAction.fromJson(Map<String, dynamic> json) {
    final params = json['inputParameters'];
    return AppAction(
      slug: (json['slug'] ?? '').toString(),
      name: (json['name'] ?? json['slug'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      toolkitSlug: (json['toolkitSlug'] ?? '').toString(),
      toolkitName: (json['toolkitName'] ?? json['toolkitSlug'] ?? '').toString(),
      toolkitLogo: json['toolkitLogo']?.toString(),
      readOnly: json['readOnly'] == true,
      inputParameters:
          params is Map ? Map<String, dynamic>.from(params) : const {},
    );
  }
}

class AppsCatalogPage {
  final List<CortexApp> items;
  final String? nextCursor;

  const AppsCatalogPage({required this.items, required this.nextCursor});
}
