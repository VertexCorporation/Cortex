import 'package:flutter/widgets.dart';

class IntegrationStrings {
  final String languageCode;

  const IntegrationStrings(this.languageCode);

  factory IntegrationStrings.of(BuildContext context) =>
      IntegrationStrings(Localizations.localeOf(context).languageCode);

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'title': 'Plugins', 'search': 'Search plugins', 'installed': 'Installed',
      'popular': 'Popular', 'emptyInstalled': 'No plugins installed yet',
      'connect': 'Connect', 'disconnect': 'Disconnect', 'refresh': 'Refresh',
      'retry': 'Try again', 'error': 'Plugins are unavailable right now',
      'connecting': 'Opening connection…', 'connected': 'Connected',
      'settings': 'Plugin settings', 'all': 'All',
      'description': 'Connect and use {name} in Cortex',
    },
    'tr': {
      'title': 'Eklentiler', 'search': 'Eklentileri ara', 'installed': 'Kurulanlar',
      'popular': 'Popüler', 'emptyInstalled': 'Henüz eklenti kurulmadı',
      'connect': 'Bağla', 'disconnect': 'Bağlantıyı kaldır', 'refresh': 'Yenile',
      'retry': 'Tekrar dene', 'error': 'Eklentiler şu anda kullanılamıyor',
      'connecting': 'Bağlantı açılıyor…', 'connected': 'Bağlı',
      'settings': 'Eklenti ayarları', 'all': 'Tümü',
      'description': '{name} bağlantısını Cortex ile kullan',
    },
    'ar': {
      'title': 'الإضافات', 'search': 'البحث في الإضافات', 'installed': 'المثبتة',
      'popular': 'الشائعة', 'emptyInstalled': 'لا توجد إضافات مثبتة بعد',
      'connect': 'اتصال', 'disconnect': 'قطع الاتصال', 'refresh': 'تحديث',
      'retry': 'إعادة المحاولة', 'error': 'الإضافات غير متاحة الآن',
      'connecting': 'جارٍ فتح الاتصال…', 'connected': 'متصل',
      'settings': 'إعدادات الإضافات', 'all': 'الكل',
      'description': 'اربط {name} واستخدمه في Cortex',
    },
    'az': {
      'title': 'Əlavələr', 'search': 'Əlavələri axtar', 'installed': 'Quraşdırılanlar',
      'popular': 'Populyar', 'emptyInstalled': 'Hələ əlavə quraşdırılmayıb',
      'connect': 'Qoş', 'disconnect': 'Ayır', 'refresh': 'Yenilə',
      'retry': 'Yenidən cəhd et', 'error': 'Əlavələr hazırda əlçatan deyil',
      'connecting': 'Bağlantı açılır…', 'connected': 'Qoşulub',
      'settings': 'Əlavə ayarları', 'all': 'Hamısı',
      'description': '{name} xidmətini Cortex ilə qoş və istifadə et',
    },
    'cs': {
      'title': 'Doplňky', 'search': 'Hledat doplňky', 'installed': 'Nainstalované',
      'popular': 'Oblíbené', 'emptyInstalled': 'Zatím nejsou nainstalované žádné doplňky',
      'connect': 'Připojit', 'disconnect': 'Odpojit', 'refresh': 'Obnovit',
      'retry': 'Zkusit znovu', 'error': 'Doplňky teď nejsou dostupné',
      'connecting': 'Otevírám připojení…', 'connected': 'Připojeno',
      'settings': 'Nastavení doplňků', 'all': 'Vše',
      'description': 'Připojte {name} a používejte jej v Cortexu',
    },
    'de': {
      'title': 'Erweiterungen', 'search': 'Erweiterungen suchen', 'installed': 'Installiert',
      'popular': 'Beliebt', 'emptyInstalled': 'Noch keine Erweiterungen installiert',
      'connect': 'Verbinden', 'disconnect': 'Trennen', 'refresh': 'Aktualisieren',
      'retry': 'Erneut versuchen', 'error': 'Erweiterungen sind derzeit nicht verfügbar',
      'connecting': 'Verbindung wird geöffnet…', 'connected': 'Verbunden',
      'settings': 'Erweiterungseinstellungen', 'all': 'Alle',
      'description': '{name} mit Cortex verbinden und verwenden',
    },
    'es': {
      'title': 'Complementos', 'search': 'Buscar complementos', 'installed': 'Instalados',
      'popular': 'Populares', 'emptyInstalled': 'Aún no hay complementos instalados',
      'connect': 'Conectar', 'disconnect': 'Desconectar', 'refresh': 'Actualizar',
      'retry': 'Reintentar', 'error': 'Los complementos no están disponibles ahora',
      'connecting': 'Abriendo conexión…', 'connected': 'Conectado',
      'settings': 'Ajustes de complementos', 'all': 'Todos',
      'description': 'Conecta y usa {name} en Cortex',
    },
    'fr': {
      'title': 'Extensions', 'search': 'Rechercher des extensions', 'installed': 'Installées',
      'popular': 'Populaires', 'emptyInstalled': 'Aucune extension installée',
      'connect': 'Connecter', 'disconnect': 'Déconnecter', 'refresh': 'Actualiser',
      'retry': 'Réessayer', 'error': 'Les extensions sont indisponibles pour le moment',
      'connecting': 'Ouverture de la connexion…', 'connected': 'Connecté',
      'settings': 'Réglages des extensions', 'all': 'Toutes',
      'description': 'Connectez et utilisez {name} dans Cortex',
    },
    'hi': {
      'title': 'प्लगइन्स', 'search': 'प्लगइन्स खोजें', 'installed': 'इंस्टॉल किए गए',
      'popular': 'लोकप्रिय', 'emptyInstalled': 'अभी कोई प्लगइन इंस्टॉल नहीं है',
      'connect': 'कनेक्ट करें', 'disconnect': 'डिस्कनेक्ट करें', 'refresh': 'रीफ़्रेश',
      'retry': 'फिर प्रयास करें', 'error': 'प्लगइन्स अभी उपलब्ध नहीं हैं',
      'connecting': 'कनेक्शन खोला जा रहा है…', 'connected': 'कनेक्टेड',
      'settings': 'प्लगइन सेटिंग्स', 'all': 'सभी',
      'description': '{name} को Cortex से जोड़ें और उपयोग करें',
    },
    'hu': {
      'title': 'Bővítmények', 'search': 'Bővítmények keresése', 'installed': 'Telepítve',
      'popular': 'Népszerű', 'emptyInstalled': 'Még nincs telepített bővítmény',
      'connect': 'Csatlakozás', 'disconnect': 'Leválasztás', 'refresh': 'Frissítés',
      'retry': 'Újra', 'error': 'A bővítmények most nem érhetők el',
      'connecting': 'Kapcsolat megnyitása…', 'connected': 'Csatlakoztatva',
      'settings': 'Bővítménybeállítások', 'all': 'Mind',
      'description': 'A(z) {name} csatlakoztatása és használata a Cortexben',
    },
    'id': {
      'title': 'Plugin', 'search': 'Cari plugin', 'installed': 'Terpasang',
      'popular': 'Populer', 'emptyInstalled': 'Belum ada plugin yang terpasang',
      'connect': 'Hubungkan', 'disconnect': 'Putuskan', 'refresh': 'Muat ulang',
      'retry': 'Coba lagi', 'error': 'Plugin sedang tidak tersedia',
      'connecting': 'Membuka koneksi…', 'connected': 'Terhubung',
      'settings': 'Pengaturan plugin', 'all': 'Semua',
      'description': 'Hubungkan dan gunakan {name} di Cortex',
    },
    'it': {
      'title': 'Plugin', 'search': 'Cerca plugin', 'installed': 'Installati',
      'popular': 'Popolari', 'emptyInstalled': 'Nessun plugin installato',
      'connect': 'Connetti', 'disconnect': 'Disconnetti', 'refresh': 'Aggiorna',
      'retry': 'Riprova', 'error': 'I plugin non sono disponibili al momento',
      'connecting': 'Apertura connessione…', 'connected': 'Connesso',
      'settings': 'Impostazioni plugin', 'all': 'Tutti',
      'description': 'Connetti e usa {name} in Cortex',
    },
    'ja': {
      'title': 'プラグイン', 'search': 'プラグインを検索', 'installed': 'インストール済み',
      'popular': '人気', 'emptyInstalled': 'インストール済みのプラグインはありません',
      'connect': '接続', 'disconnect': '切断', 'refresh': '更新',
      'retry': '再試行', 'error': '現在プラグインを利用できません',
      'connecting': '接続を開いています…', 'connected': '接続済み',
      'settings': 'プラグイン設定', 'all': 'すべて',
      'description': '{name} を Cortex に接続して使用',
    },
    'ko': {
      'title': '플러그인', 'search': '플러그인 검색', 'installed': '설치됨',
      'popular': '인기', 'emptyInstalled': '설치된 플러그인이 없습니다',
      'connect': '연결', 'disconnect': '연결 해제', 'refresh': '새로고침',
      'retry': '다시 시도', 'error': '현재 플러그인을 사용할 수 없습니다',
      'connecting': '연결 여는 중…', 'connected': '연결됨',
      'settings': '플러그인 설정', 'all': '전체',
      'description': '{name}을 Cortex에 연결하여 사용',
    },
    'nl': {
      'title': 'Plug-ins', 'search': 'Plug-ins zoeken', 'installed': 'Geïnstalleerd',
      'popular': 'Populair', 'emptyInstalled': 'Nog geen plug-ins geïnstalleerd',
      'connect': 'Verbinden', 'disconnect': 'Loskoppelen', 'refresh': 'Vernieuwen',
      'retry': 'Opnieuw proberen', 'error': 'Plug-ins zijn momenteel niet beschikbaar',
      'connecting': 'Verbinding openen…', 'connected': 'Verbonden',
      'settings': 'Plug-ininstellingen', 'all': 'Alles',
      'description': 'Verbind en gebruik {name} in Cortex',
    },
    'no': {
      'title': 'Programtillegg', 'search': 'Søk etter programtillegg', 'installed': 'Installert',
      'popular': 'Populært', 'emptyInstalled': 'Ingen programtillegg er installert ennå',
      'connect': 'Koble til', 'disconnect': 'Koble fra', 'refresh': 'Oppdater',
      'retry': 'Prøv igjen', 'error': 'Programtillegg er ikke tilgjengelige nå',
      'connecting': 'Åpner tilkobling…', 'connected': 'Tilkoblet',
      'settings': 'Innstillinger for programtillegg', 'all': 'Alle',
      'description': 'Koble til og bruk {name} i Cortex',
    },
    'pt': {
      'title': 'Plugins', 'search': 'Pesquisar plugins', 'installed': 'Instalados',
      'popular': 'Populares', 'emptyInstalled': 'Ainda não há plugins instalados',
      'connect': 'Ligar', 'disconnect': 'Desligar', 'refresh': 'Atualizar',
      'retry': 'Tentar novamente', 'error': 'Os plugins não estão disponíveis agora',
      'connecting': 'A abrir ligação…', 'connected': 'Ligado',
      'settings': 'Definições de plugins', 'all': 'Todos',
      'description': 'Ligue e use {name} no Cortex',
    },
    'ru': {
      'title': 'Плагины', 'search': 'Поиск плагинов', 'installed': 'Установленные',
      'popular': 'Популярные', 'emptyInstalled': 'Пока нет установленных плагинов',
      'connect': 'Подключить', 'disconnect': 'Отключить', 'refresh': 'Обновить',
      'retry': 'Повторить', 'error': 'Плагины сейчас недоступны',
      'connecting': 'Открываем подключение…', 'connected': 'Подключено',
      'settings': 'Настройки плагинов', 'all': 'Все',
      'description': 'Подключите и используйте {name} в Cortex',
    },
    'sv': {
      'title': 'Tillägg', 'search': 'Sök tillägg', 'installed': 'Installerade',
      'popular': 'Populära', 'emptyInstalled': 'Inga tillägg installerade ännu',
      'connect': 'Anslut', 'disconnect': 'Koppla från', 'refresh': 'Uppdatera',
      'retry': 'Försök igen', 'error': 'Tillägg är inte tillgängliga just nu',
      'connecting': 'Öppnar anslutning…', 'connected': 'Ansluten',
      'settings': 'Tilläggsinställningar', 'all': 'Alla',
      'description': 'Anslut och använd {name} i Cortex',
    },
    'zh': {
      'title': '插件', 'search': '搜索插件', 'installed': '已安装',
      'popular': '热门', 'emptyInstalled': '尚未安装插件',
      'connect': '连接', 'disconnect': '断开连接', 'refresh': '刷新',
      'retry': '重试', 'error': '插件暂时不可用',
      'connecting': '正在打开连接…', 'connected': '已连接',
      'settings': '插件设置', 'all': '全部',
      'description': '在 Cortex 中连接并使用 {name}',
    },
  };

  Map<String, String> get _current => _values[languageCode] ?? _values['en']!;
  String _get(String key) => _current[key] ?? _values['en']![key] ?? key;

  String get title => _get('title');
  String get search => _get('search');
  String get installed => _get('installed');
  String get popular => _get('popular');
  String get emptyInstalled => _get('emptyInstalled');
  String get connect => _get('connect');
  String get disconnect => _get('disconnect');
  String get refresh => _get('refresh');
  String get retry => _get('retry');
  String get error => _get('error');
  String get connecting => _get('connecting');
  String get connected => _get('connected');
  String get settings => _get('settings');
  String get all => _get('all');

  String description(String name) => _get('description').replaceAll('{name}', name);

  String category(String id, String fallback) {
    const labels = {
      'developer-tools': {'en': 'Developer Tools', 'tr': 'Geliştirici Araçları', 'de': 'Entwicklertools', 'es': 'Herramientas de desarrollo', 'fr': 'Outils de développement', 'pt': 'Ferramentas de desenvolvimento'},
      'productivity': {'en': 'Productivity', 'tr': 'Üretkenlik', 'de': 'Produktivität', 'es': 'Productividad', 'fr': 'Productivité', 'pt': 'Produtividade'},
      'communication': {'en': 'Communication', 'tr': 'İletişim', 'de': 'Kommunikation', 'es': 'Comunicación', 'fr': 'Communication', 'pt': 'Comunicação'},
      'data-analytics': {'en': 'Data & Analytics', 'tr': 'Veri ve Analitik', 'de': 'Daten & Analysen', 'es': 'Datos y analítica', 'fr': 'Données et analytique', 'pt': 'Dados e análise'},
      'marketing': {'en': 'Marketing', 'tr': 'Pazarlama', 'de': 'Marketing', 'es': 'Marketing', 'fr': 'Marketing', 'pt': 'Marketing'},
      'sales': {'en': 'Sales', 'tr': 'Satış', 'de': 'Vertrieb', 'es': 'Ventas', 'fr': 'Ventes', 'pt': 'Vendas'},
      'design': {'en': 'Creativity', 'tr': 'Yaratıcılık', 'de': 'Kreativität', 'es': 'Creatividad', 'fr': 'Créativité', 'pt': 'Criatividade'},
      'crm': {'en': 'Business & Operations', 'tr': 'İşletme ve Operasyonlar', 'de': 'Geschäft & Betrieb', 'es': 'Negocio y operaciones', 'fr': 'Entreprise et opérations', 'pt': 'Negócios e operações'},
    };
    final localized = labels[id]?[languageCode] ?? labels[id]?['en'];
    return localized ?? fallback;
  }
}
