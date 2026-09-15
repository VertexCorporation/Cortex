import 'package:cortex/app.dart';
import 'package:cortex/funds/routing.dart';
import 'package:cortex/main.dart' show navigatorKey;
import 'package:cortex/navigation.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'logo.dart';
import 'permission_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screen.dart';

/// Per-action decision used by integration execution.
enum IntegrationPermissionDecision {
  alwaysAllow,
  allowOnce,
  reject,
}

class IntegrationDialogs {
  IntegrationDialogs._();

  static Future<IntegrationPermissionDecision> requestActionPermission({
    required String toolkitSlug,
    required String toolkitName,
    required String? logoUrl,
    required String toolSlug,
    required String actionDescription,
  }) async {
    final requestUserId = FirebaseAuth.instance.currentUser?.uid;
    if (requestUserId == null) return IntegrationPermissionDecision.reject;
    final store = IntegrationPermissionStore.instance;
    if (await store.isAlwaysAllowed(toolkitSlug, toolSlug)) {
      if (requestUserId != FirebaseAuth.instance.currentUser?.uid) {
        return IntegrationPermissionDecision.reject;
      }
      return IntegrationPermissionDecision.alwaysAllow;
    }

    final context = navigatorKey.currentContext;
    if (context == null) return IntegrationPermissionDecision.reject;
    final strings = _PromptStrings.of(context);

    final result = await showDialog<IntegrationPermissionDecision>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.08),
      useRootNavigator: true,
      builder: (dialogContext) {
        return _FloatingPromptShell(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IntegrationLogo(
                    name: toolkitName,
                    logoUrl: logoUrl,
                    size: 38,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      strings.permissionTitle(toolkitName),
                      style: TextStyle(
                        color: AppColors.primaryColor.inverted,
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                actionDescription.trim().isEmpty
                    ? strings.permissionDescription
                    : actionDescription.trim(),
                style: TextStyle(
                  color: AppColors.primaryColor.inverted.withValues(alpha: 0.70),
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              _PromptButton(
                text: strings.alwaysAllow,
                filled: false,
                onTap: () => Navigator.of(dialogContext).pop(
                  IntegrationPermissionDecision.alwaysAllow,
                ),
              ),
              const SizedBox(height: 7),
              _PromptButton(
                text: strings.allowOnce,
                filled: true,
                onTap: () => Navigator.of(dialogContext).pop(
                  IntegrationPermissionDecision.allowOnce,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(
                    IntegrationPermissionDecision.reject,
                  ),
                  child: Text(
                    strings.reject,
                    style: TextStyle(
                      color: AppColors.tertiaryColor,
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    final decision = result ?? IntegrationPermissionDecision.reject;
    if (requestUserId != FirebaseAuth.instance.currentUser?.uid) {
      return IntegrationPermissionDecision.reject;
    }
    if (decision == IntegrationPermissionDecision.alwaysAllow) {
      await store.setAlwaysAllowed(toolkitSlug, toolSlug, allowed: true);
    }
    return decision;
  }

  static Future<void> showConnectionRequired({
    required String toolkitSlug,
    required String toolkitName,
    required String? logoUrl,
    String? search,
  }) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    final strings = _PromptStrings.of(context);

    final connect = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.06),
      useRootNavigator: true,
      builder: (dialogContext) => _FloatingPromptShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IntegrationLogo(
                  name: toolkitName,
                  logoUrl: logoUrl,
                  size: 38,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    strings.connectionTitle(toolkitName),
                    style: TextStyle(
                      color: AppColors.primaryColor.inverted,
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              strings.connectionDescription(toolkitName),
              style: TextStyle(
                color: AppColors.primaryColor.inverted.withValues(alpha: 0.66),
                fontFamily: 'Inter',
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: _PromptButton(
                    text: strings.notNow,
                    filled: false,
                    onTap: () => Navigator.of(dialogContext).pop(false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PromptButton(
                    text: strings.connect,
                    filled: true,
                    onTap: () => Navigator.of(dialogContext).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (connect == true) {
      HapticFeedback.lightImpact();
      await navigateToScreen(
        IntegrationsScreen(initialSearch: search ?? toolkitSlug),
        direction: const Offset(1, 0),
      );
    }
  }

  static Future<void> showDailyLimitReached() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    final strings = _PromptStrings.of(context);

    final upgrade = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.06),
      useRootNavigator: true,
      builder: (dialogContext) => _FloatingPromptShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.limitTitle,
              style: TextStyle(
                color: AppColors.primaryColor.inverted,
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              strings.limitDescription,
              style: TextStyle(
                color: AppColors.primaryColor.inverted.withValues(alpha: 0.66),
                fontFamily: 'Inter',
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: _PromptButton(
                    text: strings.ok,
                    filled: false,
                    onTap: () => Navigator.of(dialogContext).pop(false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PromptButton(
                    text: strings.viewPlans,
                    filled: true,
                    onTap: () => Navigator.of(dialogContext).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (upgrade == true && context.mounted) {
      openNextSubscriptionStep(context);
    }
  }
}

class _FloatingPromptShell extends StatelessWidget {
  final Widget child;

  const _FloatingPromptShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            width > 650 ? width * 0.26 : 16,
            16,
            width > 650 ? width * 0.26 : 16,
            104,
          ),
          child: Material(
            color: AppColors.secondaryColor,
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primaryColor.inverted.withValues(alpha: 0.10),
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _PromptButton extends StatelessWidget {
  final String text;
  final bool filled;
  final VoidCallback onTap;

  const _PromptButton({
    required this.text,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = AppColors.primaryColor.inverted;
    return SizedBox(
      height: 38,
      child: Material(
        color: filled ? foreground : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: foreground.withValues(alpha: filled ? 0 : 0.18),
              ),
            ),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: filled ? AppColors.primaryColor : foreground,
                fontFamily: 'Inter',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PromptStrings {
  final String code;

  const _PromptStrings(this.code);

  factory _PromptStrings.of(BuildContext context) =>
      _PromptStrings(Localizations.localeOf(context).languageCode);

  Map<String, String> get _v => _values[code] ?? _values['en']!;
  String _get(String key) => _v[key] ?? _values['en']![key] ?? key;

  String permissionTitle(String name) =>
      _get('permissionTitle').replaceAll('{name}', name);
  String connectionTitle(String name) =>
      _get('connectionTitle').replaceAll('{name}', name);
  String connectionDescription(String name) =>
      _get('connectionDescription').replaceAll('{name}', name);

  String get permissionDescription => _get('permissionDescription');
  String get alwaysAllow => _get('alwaysAllow');
  String get allowOnce => _get('allowOnce');
  String get reject => _get('reject');
  String get connect => _get('connect');
  String get notNow => _get('notNow');
  String get limitTitle => _get('limitTitle');
  String get limitDescription => _get('limitDescription');
  String get viewPlans => _get('viewPlans');
  String get ok => _get('ok');

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'permissionTitle': '{name} wants permission',
      'permissionDescription': 'Cortex is about to use this plugin for the requested action.',
      'alwaysAllow': 'Always allow', 'allowOnce': 'Allow once', 'reject': 'Reject',
      'connectionTitle': '{name} is not connected',
      'connectionDescription': 'Connect {name} to let Cortex complete this request.',
      'connect': 'Connect', 'notNow': 'Not now',
      'limitTitle': 'Today’s plugin usage limit has been reached',
      'limitDescription': 'Upgrade your plan for more plugin-powered messages.',
      'viewPlans': 'View plans', 'ok': 'OK',
    },
    'tr': {
      'permissionTitle': '{name} izin istiyor',
      'permissionDescription': 'Cortex bu işlem için eklentiyi kullanmak üzere.',
      'alwaysAllow': 'Her zaman izin ver', 'allowOnce': 'Bir kez izin ver', 'reject': 'Reddet',
      'connectionTitle': '{name} bağlı değil',
      'connectionDescription': 'Bu isteği tamamlamak için {name} eklentisini bağla.',
      'connect': 'Bağla', 'notNow': 'Şimdilik değil',
      'limitTitle': 'Bugünkü eklenti kullanım limitine ulaştın',
      'limitDescription': 'Daha fazla eklenti destekli mesaj için planını yükseltebilirsin.',
      'viewPlans': 'Planları gör', 'ok': 'Tamam',
    },
    'de': {
      'permissionTitle': '{name} benötigt eine Berechtigung', 'permissionDescription': 'Cortex möchte dieses Plugin für die angeforderte Aktion verwenden.', 'alwaysAllow': 'Immer erlauben', 'allowOnce': 'Einmal erlauben', 'reject': 'Ablehnen', 'connectionTitle': '{name} ist nicht verbunden', 'connectionDescription': 'Verbinde {name}, damit Cortex diese Anfrage ausführen kann.', 'connect': 'Verbinden', 'notNow': 'Nicht jetzt', 'limitTitle': 'Das heutige Plugin-Limit ist erreicht', 'limitDescription': 'Upgrade deinen Plan für mehr Nachrichten mit Plugins.', 'viewPlans': 'Pläne ansehen', 'ok': 'OK',
    },
    'es': {
      'permissionTitle': '{name} solicita permiso', 'permissionDescription': 'Cortex va a usar este complemento para la acción solicitada.', 'alwaysAllow': 'Permitir siempre', 'allowOnce': 'Permitir una vez', 'reject': 'Rechazar', 'connectionTitle': '{name} no está conectado', 'connectionDescription': 'Conecta {name} para que Cortex complete esta solicitud.', 'connect': 'Conectar', 'notNow': 'Ahora no', 'limitTitle': 'Has alcanzado el límite de complementos de hoy', 'limitDescription': 'Mejora tu plan para usar complementos en más mensajes.', 'viewPlans': 'Ver planes', 'ok': 'Aceptar',
    },
    'fr': {
      'permissionTitle': '{name} demande une autorisation', 'permissionDescription': 'Cortex va utiliser cette extension pour l’action demandée.', 'alwaysAllow': 'Toujours autoriser', 'allowOnce': 'Autoriser une fois', 'reject': 'Refuser', 'connectionTitle': '{name} n’est pas connecté', 'connectionDescription': 'Connectez {name} pour permettre à Cortex de terminer cette demande.', 'connect': 'Connecter', 'notNow': 'Pas maintenant', 'limitTitle': 'La limite d’extensions du jour est atteinte', 'limitDescription': 'Passez à un forfait supérieur pour davantage de messages avec extensions.', 'viewPlans': 'Voir les forfaits', 'ok': 'OK',
    },
    'it': {
      'permissionTitle': '{name} richiede un’autorizzazione', 'permissionDescription': 'Cortex sta per usare questo plugin per l’azione richiesta.', 'alwaysAllow': 'Consenti sempre', 'allowOnce': 'Consenti una volta', 'reject': 'Rifiuta', 'connectionTitle': '{name} non è connesso', 'connectionDescription': 'Connetti {name} per permettere a Cortex di completare la richiesta.', 'connect': 'Connetti', 'notNow': 'Non ora', 'limitTitle': 'Hai raggiunto il limite plugin di oggi', 'limitDescription': 'Aggiorna il piano per più messaggi con plugin.', 'viewPlans': 'Vedi piani', 'ok': 'OK',
    },
    'pt': {
      'permissionTitle': '{name} pede permissão', 'permissionDescription': 'O Cortex vai usar este plugin para a ação pedida.', 'alwaysAllow': 'Permitir sempre', 'allowOnce': 'Permitir uma vez', 'reject': 'Rejeitar', 'connectionTitle': '{name} não está ligado', 'connectionDescription': 'Ligue {name} para o Cortex concluir este pedido.', 'connect': 'Ligar', 'notNow': 'Agora não', 'limitTitle': 'O limite de plugins de hoje foi atingido', 'limitDescription': 'Atualize o plano para mais mensagens com plugins.', 'viewPlans': 'Ver planos', 'ok': 'OK',
    },
    'ru': {
      'permissionTitle': '{name} запрашивает разрешение', 'permissionDescription': 'Cortex собирается использовать этот плагин для запрошенного действия.', 'alwaysAllow': 'Всегда разрешать', 'allowOnce': 'Разрешить один раз', 'reject': 'Отклонить', 'connectionTitle': '{name} не подключён', 'connectionDescription': 'Подключите {name}, чтобы Cortex выполнил запрос.', 'connect': 'Подключить', 'notNow': 'Не сейчас', 'limitTitle': 'Дневной лимит плагинов достигнут', 'limitDescription': 'Обновите тариф для большего числа сообщений с плагинами.', 'viewPlans': 'Тарифы', 'ok': 'OK',
    },
    'ar': {
      'permissionTitle': '{name} يطلب الإذن', 'permissionDescription': 'سيستخدم Cortex هذه الإضافة لتنفيذ الإجراء المطلوب.', 'alwaysAllow': 'السماح دائمًا', 'allowOnce': 'السماح مرة واحدة', 'reject': 'رفض', 'connectionTitle': '{name} غير متصل', 'connectionDescription': 'اربط {name} ليتمكن Cortex من إكمال الطلب.', 'connect': 'ربط', 'notNow': 'ليس الآن', 'limitTitle': 'تم بلوغ حد الإضافات اليومي', 'limitDescription': 'قم بترقية خطتك لمزيد من الرسائل المدعومة بالإضافات.', 'viewPlans': 'عرض الخطط', 'ok': 'حسنًا',
    },
    'zh': {
      'permissionTitle': '{name} 请求权限', 'permissionDescription': 'Cortex 将使用此插件执行所请求的操作。', 'alwaysAllow': '始终允许', 'allowOnce': '允许一次', 'reject': '拒绝', 'connectionTitle': '{name} 尚未连接', 'connectionDescription': '连接 {name} 以便 Cortex 完成此请求。', 'connect': '连接', 'notNow': '暂不', 'limitTitle': '今日插件使用已达上限', 'limitDescription': '升级套餐可获得更多插件消息。', 'viewPlans': '查看套餐', 'ok': '确定',
    },
    'ja': {
      'permissionTitle': '{name} が許可を求めています', 'permissionDescription': 'Cortex がこの操作のためにプラグインを使用します。', 'alwaysAllow': '常に許可', 'allowOnce': '今回のみ許可', 'reject': '拒否', 'connectionTitle': '{name} は未接続です', 'connectionDescription': '{name} を接続すると Cortex がこのリクエストを完了できます。', 'connect': '接続', 'notNow': '今はしない', 'limitTitle': '本日のプラグイン利用上限に達しました', 'limitDescription': 'プランをアップグレードすると、より多くのメッセージでプラグインを使えます。', 'viewPlans': 'プランを見る', 'ok': 'OK',
    },
    'ko': {
      'permissionTitle': '{name} 권한 요청', 'permissionDescription': 'Cortex가 요청한 작업을 위해 이 플러그인을 사용합니다.', 'alwaysAllow': '항상 허용', 'allowOnce': '한 번 허용', 'reject': '거부', 'connectionTitle': '{name}이 연결되지 않았습니다', 'connectionDescription': '{name}을 연결하면 Cortex가 요청을 완료할 수 있습니다.', 'connect': '연결', 'notNow': '나중에', 'limitTitle': '오늘의 플러그인 사용 한도에 도달했습니다', 'limitDescription': '플랜을 업그레이드하면 더 많은 메시지에서 플러그인을 사용할 수 있습니다.', 'viewPlans': '플랜 보기', 'ok': '확인',
    },
    'nl': {
      'permissionTitle': '{name} vraagt toestemming', 'permissionDescription': 'Cortex gaat deze plug-in gebruiken voor de gevraagde actie.', 'alwaysAllow': 'Altijd toestaan', 'allowOnce': 'Eenmalig toestaan', 'reject': 'Weigeren', 'connectionTitle': '{name} is niet verbonden', 'connectionDescription': 'Verbind {name} zodat Cortex dit verzoek kan uitvoeren.', 'connect': 'Verbinden', 'notNow': 'Niet nu', 'limitTitle': 'De plug-inlimiet van vandaag is bereikt', 'limitDescription': 'Upgrade je abonnement voor meer berichten met plug-ins.', 'viewPlans': 'Abonnementen', 'ok': 'OK',
    },
    'sv': {
      'permissionTitle': '{name} begär behörighet', 'permissionDescription': 'Cortex kommer att använda tillägget för den begärda åtgärden.', 'alwaysAllow': 'Tillåt alltid', 'allowOnce': 'Tillåt en gång', 'reject': 'Neka', 'connectionTitle': '{name} är inte ansluten', 'connectionDescription': 'Anslut {name} så att Cortex kan slutföra begäran.', 'connect': 'Anslut', 'notNow': 'Inte nu', 'limitTitle': 'Dagens gräns för tillägg är nådd', 'limitDescription': 'Uppgradera planen för fler meddelanden med tillägg.', 'viewPlans': 'Visa planer', 'ok': 'OK',
    },
    'no': {
      'permissionTitle': '{name} ber om tillatelse', 'permissionDescription': 'Cortex skal bruke programtillegget for den forespurte handlingen.', 'alwaysAllow': 'Tillat alltid', 'allowOnce': 'Tillat én gang', 'reject': 'Avvis', 'connectionTitle': '{name} er ikke tilkoblet', 'connectionDescription': 'Koble til {name} slik at Cortex kan fullføre forespørselen.', 'connect': 'Koble til', 'notNow': 'Ikke nå', 'limitTitle': 'Dagens grense for programtillegg er nådd', 'limitDescription': 'Oppgrader planen for flere meldinger med programtillegg.', 'viewPlans': 'Se planer', 'ok': 'OK',
    },
    'id': {
      'permissionTitle': '{name} meminta izin', 'permissionDescription': 'Cortex akan menggunakan plugin ini untuk tindakan yang diminta.', 'alwaysAllow': 'Selalu izinkan', 'allowOnce': 'Izinkan sekali', 'reject': 'Tolak', 'connectionTitle': '{name} belum terhubung', 'connectionDescription': 'Hubungkan {name} agar Cortex dapat menyelesaikan permintaan ini.', 'connect': 'Hubungkan', 'notNow': 'Nanti', 'limitTitle': 'Batas penggunaan plugin hari ini tercapai', 'limitDescription': 'Tingkatkan paket untuk lebih banyak pesan dengan plugin.', 'viewPlans': 'Lihat paket', 'ok': 'OK',
    },
    'hi': {
      'permissionTitle': '{name} अनुमति चाहता है', 'permissionDescription': 'Cortex अनुरोधित काम के लिए इस प्लगइन का उपयोग करने वाला है।', 'alwaysAllow': 'हमेशा अनुमति दें', 'allowOnce': 'एक बार अनुमति दें', 'reject': 'अस्वीकार करें', 'connectionTitle': '{name} कनेक्ट नहीं है', 'connectionDescription': 'यह अनुरोध पूरा करने के लिए {name} कनेक्ट करें।', 'connect': 'कनेक्ट करें', 'notNow': 'अभी नहीं', 'limitTitle': 'आज की प्लगइन उपयोग सीमा पूरी हो गई', 'limitDescription': 'अधिक प्लगइन संदेशों के लिए अपना प्लान अपग्रेड करें।', 'viewPlans': 'प्लान देखें', 'ok': 'ठीक है',
    },
    'hu': {
      'permissionTitle': '{name} engedélyt kér', 'permissionDescription': 'A Cortex ezt a bővítményt fogja használni a kért művelethez.', 'alwaysAllow': 'Mindig engedélyez', 'allowOnce': 'Egyszer engedélyez', 'reject': 'Elutasítás', 'connectionTitle': '{name} nincs csatlakoztatva', 'connectionDescription': 'Csatlakoztasd a(z) {name} szolgáltatást a kérés teljesítéséhez.', 'connect': 'Csatlakozás', 'notNow': 'Most nem', 'limitTitle': 'Elérted a mai bővítménylimitet', 'limitDescription': 'Frissítsd a csomagod több bővítményes üzenetért.', 'viewPlans': 'Csomagok', 'ok': 'OK',
    },
    'cs': {
      'permissionTitle': '{name} žádá o oprávnění', 'permissionDescription': 'Cortex použije tento doplněk pro požadovanou akci.', 'alwaysAllow': 'Vždy povolit', 'allowOnce': 'Povolit jednou', 'reject': 'Odmítnout', 'connectionTitle': '{name} není připojen', 'connectionDescription': 'Připojte {name}, aby Cortex mohl požadavek dokončit.', 'connect': 'Připojit', 'notNow': 'Teď ne', 'limitTitle': 'Dnešní limit doplňků byl dosažen', 'limitDescription': 'Upgradujte tarif pro více zpráv s doplňky.', 'viewPlans': 'Zobrazit tarify', 'ok': 'OK',
    },
    'az': {
      'permissionTitle': '{name} icazə istəyir', 'permissionDescription': 'Cortex tələb olunan əməliyyat üçün bu əlavədən istifadə edəcək.', 'alwaysAllow': 'Həmişə icazə ver', 'allowOnce': 'Bir dəfə icazə ver', 'reject': 'Rədd et', 'connectionTitle': '{name} qoşulmayıb', 'connectionDescription': 'Cortex sorğunu tamamlaya bilsin deyə {name} qoşun.', 'connect': 'Qoş', 'notNow': 'İndi yox', 'limitTitle': 'Bugünkü əlavə istifadə limitinə çatdınız', 'limitDescription': 'Daha çox əlavəli mesaj üçün planınızı yüksəldin.', 'viewPlans': 'Planlara bax', 'ok': 'OK',
    },
  };
}
