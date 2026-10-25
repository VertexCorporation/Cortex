// lib/apps/categories.dart
//
// Groups Composio's free-form catalog categories into a fixed, localized
// set of shelves for the Apps screen.

import 'package:cortex/l10n/app_localizations.dart';

import 'models.dart';

enum AppGroup {
  productivity(['productiv', 'note', 'document', 'workspace', 'office']),
  communication(['communicat', 'messag', 'chat', 'email', 'mail', 'meeting', 'video-conf']),
  scheduling(['calendar', 'schedul', 'booking', 'appointment']),
  projects(['project', 'task', 'issue', 'collaborat', 'workflow']),
  files(['file', 'storage', 'drive']),
  developer(['developer', 'dev-tool', 'devops', 'code', 'git', 'database', 'api', 'hosting', 'cloud', 'monitor']),
  sales(['crm', 'sales', 'lead']),
  marketing(['marketing', 'advertis', 'seo', 'newsletter', 'survey', 'form']),
  support(['support', 'helpdesk', 'help-desk', 'customer', 'ticket']),
  finance(['financ', 'account', 'payment', 'invoice', 'billing', 'bank', 'crypto', 'tax']),
  commerce(['commerce', 'shop', 'store', 'retail', 'inventory']),
  social(['social']),
  analytics(['analytic', 'data', 'business-intelligence', 'reporting', 'bi']),
  ai(['artificial', 'ai', 'machine-learning', 'automation', 'llm']),
  design(['design', 'image', 'photo', 'creative']),
  education(['educat', 'learning', 'school', 'course']),
  entertainment(['entertain', 'media', 'music', 'video', 'gaming', 'stream', 'news']);

  const AppGroup(this.keywords);

  final List<String> keywords;

  static AppGroup? of(AppCategory category) {
    final id = category.id.toLowerCase();
    final name = category.name.toLowerCase().replaceAll(' ', '-');
    for (final group in values) {
      for (final keyword in group.keywords) {
        // Short keywords ("ai", "bi", "hr") must match a whole segment.
        if (keyword.length <= 3) {
          final segments = {...id.split(RegExp(r'[-_&/ ]+')), ...name.split(RegExp(r'[-_&/ ]+'))};
          if (segments.contains(keyword)) return group;
        } else if (id.contains(keyword) || name.contains(keyword)) {
          return group;
        }
      }
    }
    return null;
  }

  /// First matching shelf for an app, in catalog category order.
  static AppGroup? forApp(CortexApp app) {
    for (final category in app.categories) {
      final group = of(category);
      if (group != null) return group;
    }
    return null;
  }

  String label(AppLocalizations l10n) {
    switch (this) {
      case AppGroup.productivity:
        return l10n.appsCategoryProductivity;
      case AppGroup.communication:
        return l10n.appsCategoryCommunication;
      case AppGroup.scheduling:
        return l10n.appsCategoryScheduling;
      case AppGroup.projects:
        return l10n.appsCategoryProjects;
      case AppGroup.developer:
        return l10n.appsCategoryDeveloper;
      case AppGroup.files:
        return l10n.appsCategoryFiles;
      case AppGroup.sales:
        return l10n.appsCategorySales;
      case AppGroup.marketing:
        return l10n.appsCategoryMarketing;
      case AppGroup.support:
        return l10n.appsCategorySupport;
      case AppGroup.finance:
        return l10n.appsCategoryFinance;
      case AppGroup.commerce:
        return l10n.appsCategoryCommerce;
      case AppGroup.social:
        return l10n.appsCategorySocial;
      case AppGroup.analytics:
        return l10n.appsCategoryAnalytics;
      case AppGroup.ai:
        return l10n.appsCategoryAi;
      case AppGroup.design:
        return l10n.appsCategoryDesign;
      case AppGroup.education:
        return l10n.appsCategoryEducation;
      case AppGroup.entertainment:
        return l10n.appsCategoryEntertainment;
    }
  }
}
