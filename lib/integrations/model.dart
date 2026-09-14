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

class IntegrationToolInfo {
  final String slug;
  final String name;
  final String description;
  final String toolkitSlug;
  final String toolkitName;
  final String? toolkitLogo;
  final String? version;
  final Map<String, dynamic> inputParameters;

  const IntegrationToolInfo({
    required this.slug,
    required this.name,
    required this.description,
    required this.toolkitSlug,
    required this.toolkitName,
    required this.toolkitLogo,
    required this.version,
    required this.inputParameters,
  });

  factory IntegrationToolInfo.fromJson(Map<String, dynamic> json) {
    return IntegrationToolInfo(
      slug: (json['slug'] ?? '').toString(),
      name: (json['name'] ?? json['slug'] ?? '').toString(),
      description: (json['description'] ?? json['humanDescription'] ?? '').toString(),
      toolkitSlug: (json['toolkitSlug'] ?? '').toString(),
      toolkitName: (json['toolkitName'] ?? json['toolkitSlug'] ?? '').toString(),
      toolkitLogo: json['toolkitLogo']?.toString(),
      version: json['version']?.toString(),
      inputParameters: json['inputParameters'] is Map
          ? Map<String, dynamic>.from(json['inputParameters'] as Map)
          : const <String, dynamic>{},
    );
  }

  Map<String, dynamic> compactForModel() => {
        'tool_slug': slug,
        'name': name,
        'description': description,
        'toolkit_slug': toolkitSlug,
        'toolkit_name': toolkitName,
        if (version != null && version!.isNotEmpty) 'version': version,
        'input_parameters': inputParameters,
      };
}

class IntegrationToolDiscovery {
  final bool connectionRequired;
  final String? suggestedToolkitSlug;
  final String? suggestedToolkitName;
  final String? suggestedToolkitLogo;
  final List<IntegrationToolInfo> tools;

  const IntegrationToolDiscovery({
    required this.connectionRequired,
    required this.suggestedToolkitSlug,
    required this.suggestedToolkitName,
    required this.suggestedToolkitLogo,
    required this.tools,
  });

  factory IntegrationToolDiscovery.fromJson(Map<String, dynamic> json) {
    final suggested = json['suggestedToolkit'];
    final suggestedMap = suggested is Map
        ? Map<String, dynamic>.from(suggested)
        : const <String, dynamic>{};
    final rawTools = json['tools'];
    return IntegrationToolDiscovery(
      connectionRequired: json['connectionRequired'] == true,
      suggestedToolkitSlug: suggestedMap['slug']?.toString(),
      suggestedToolkitName: suggestedMap['name']?.toString(),
      suggestedToolkitLogo: suggestedMap['logo']?.toString(),
      tools: rawTools is List
          ? rawTools
              .whereType<Map>()
              .map((item) => IntegrationToolInfo.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .where((item) => item.slug.isNotEmpty)
              .toList(growable: false)
          : const <IntegrationToolInfo>[],
    );
  }
}

class IntegrationExecutionResult {
  final bool success;
  final dynamic data;
  final String? error;
  final String? code;
  final String toolkitSlug;
  final String toolkitName;
  final String? toolkitLogo;

  const IntegrationExecutionResult({
    required this.success,
    required this.data,
    required this.error,
    required this.code,
    required this.toolkitSlug,
    required this.toolkitName,
    required this.toolkitLogo,
  });

  factory IntegrationExecutionResult.fromJson(Map<String, dynamic> json) {
    final toolkit = json['toolkit'];
    final toolkitMap = toolkit is Map
        ? Map<String, dynamic>.from(toolkit)
        : const <String, dynamic>{};
    return IntegrationExecutionResult(
      success: json['success'] == true,
      data: json['data'],
      error: json['error']?.toString(),
      code: json['code']?.toString(),
      toolkitSlug: (toolkitMap['slug'] ?? '').toString(),
      toolkitName: (toolkitMap['name'] ?? toolkitMap['slug'] ?? '').toString(),
      toolkitLogo: toolkitMap['logo']?.toString(),
    );
  }
}
