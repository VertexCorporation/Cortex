class IntegrationCategory {
  final String id;
  final String name;

  const IntegrationCategory({required this.id, required this.name});

  factory IntegrationCategory.fromJson(Map<String, dynamic> json) {
    return IntegrationCategory(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class IntegrationItem {
  final String slug;
  final String name;
  final String? logo;
  final List<IntegrationCategory> categories;
  final int toolsCount;
  final int triggersCount;
  final bool connected;
  final String? connectionStatus;
  final String? connectedAccountId;

  const IntegrationItem({
    required this.slug,
    required this.name,
    required this.logo,
    required this.categories,
    required this.toolsCount,
    required this.triggersCount,
    required this.connected,
    required this.connectionStatus,
    required this.connectedAccountId,
  });

  factory IntegrationItem.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'];
    return IntegrationItem(
      slug: (json['slug'] ?? '').toString(),
      name: (json['name'] ?? json['slug'] ?? '').toString(),
      logo: json['logo']?.toString(),
      categories: rawCategories is List
          ? rawCategories
              .whereType<Map>()
              .map((value) => IntegrationCategory.fromJson(
                    Map<String, dynamic>.from(value),
                  ))
              .toList(growable: false)
          : const <IntegrationCategory>[],
      toolsCount: _asInt(json['toolsCount']),
      triggersCount: _asInt(json['triggersCount']),
      connected: json['connected'] == true,
      connectionStatus: json['connectionStatus']?.toString(),
      connectedAccountId: json['connectedAccountId']?.toString(),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class IntegrationCatalogPage {
  final List<IntegrationItem> items;
  final List<IntegrationItem> installed;
  final String? nextCursor;
  final int totalItems;

  const IntegrationCatalogPage({
    required this.items,
    required this.installed,
    required this.nextCursor,
    required this.totalItems,
  });

  factory IntegrationCatalogPage.fromJson(Map<String, dynamic> json) {
    List<IntegrationItem> readItems(dynamic value) {
      if (value is! List) return const <IntegrationItem>[];
      return value
          .whereType<Map>()
          .map((item) => IntegrationItem.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .where((item) => item.slug.isNotEmpty)
          .toList(growable: false);
    }

    return IntegrationCatalogPage(
      items: readItems(json['items']),
      installed: readItems(json['installed']),
      nextCursor: json['nextCursor']?.toString(),
      totalItems: IntegrationItem._asInt(json['totalItems']),
    );
  }
}
