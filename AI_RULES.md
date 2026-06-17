# 🤖 AI — BUNU KESINLIKLE OKU

Bu dosya **Cortex** projesinin değişmez kurallarını içerir.  
Yeni kod yazarken, refactor yaparken veya hata düzeltirken **BU KURALLARA KESINLIKLE UY**.

---

## 1. STATE MANAGEMENT

- **SADECE Provider + ChangeNotifier** kullanılır. Riverpod, Bloc, GetX, Redux **KESINLIKLE YASAKTIR**.
- Her domain için ayrı bir `ChangeNotifier` sınıfı açılır.
- Stateless servisler `Provider<T>()` ile, state tutanlar `ChangeNotifierProvider<T>()` ile kaydedilir.
- Bağımlılıklar `ProxyProvider` / `ChangeNotifierProxyProvider` ile enjekte edilir.
- Tüm provider'lar `lib/main.dart` içindeki `MultiProvider` ağacına eklenir (core → settings → chat+library sırasıyla).

## 2. DOSYA VE KLASÖR YAPISI

```
lib/{modul}/
├── providers/     # ChangeNotifier state'leri
├── services/      # Stateless business logic
├── screen/        # UI widget'ları
│   ├── widgets/   # Alt bileşenler
│   └── ...
└── backend/       # Repository + data layer
```

- Her modül **feature-first** olarak kendi klasöründe yaşar.
- Dosya adları: `snake_case.dart`
- Sınıf adları: `PascalCase`
- Metod/değişken adları: `camelCase`
- Private üyeler: `_underscore` prefix

## 3. MIMARI KATMANLAR (DEĞIŞMEZ)

```
Repository (raw data) → Service (business logic) → Provider (state) → Widget (UI)
```

- **Repository**: Sadece veri çekme/kaydetme (Firestore, Dio, SQLite). `ModelEntity` veya `Map<String, dynamic>` döner.
- **Service**: İş mantığı, dönüşümler, API çağrıları. Stateless olmalıdır.
- **Provider**: `ChangeNotifier`. UI'ın dinlediği state'i tutar. Servisleri enjekte alır.
- **Widget**: Sadece `Consumer<T>`, `context.watch<T>()`, `context.read<T>()` ile provider'a bağlanır.

**İstisna**: `LoginController` bir ViewModel pattern'i uygular — `ChangeNotifier` + `TickerProvider` ile çalışır.

## 4. SERVICE TASARIMI

- Servisler **constructor injection** ile alır. `context.read<T>()` sadece provider'larda kullanılır.
- Singleton servisler `factory` constructor + `_internal` private constructor ile yapılır:
  ```dart
  static final MyService _instance = MyService._internal();
  factory MyService() => _instance;
  MyService._internal();
  ```
- Servisler **asla** direkt widget tree'e bağımlı olmaz.

## 5. MODELLEME (ModelEntity)

- `ModelEntity` **immutable**'dır. Tüm field'lar `final`.
- `displayTitle`, `displaySummary`, `displayDescription` alanları **önceden lokalize edilmiş** olarak gelir.
- Her modelin bir `category` (assistant, roleplay, self, image, video, audio, code) ve `source` (openrouter, fal, huggingface, groq, manual) değeri vardır.
- Variant sistemi: Bir model birden çok `variant`'a sahip olabilir (farklı RAM/boyut/URL).

## 6. CHAT MOTORU KURALLARI

- `SendService` mesaj gönderiminin **tek merkezidir**. Asla bypass edilmez.
- `ConversationProvider` mesaj listesini tutar, stream 60fps throttle ile UI'a yansıtır.
- `ApiService` **sadece** HTTPS streaming yapar. Doğrudan Firebase Function çağrısı yok.
- `OfflineService` **sadece** platform channel (llama.cpp) ile iletişim kurar.
- `BackgroundTaskService` arka planda devam eden AI yanıtlarını takip eder.
- `InputProvider` feature mode'ları yönetir: `ChatInputMode` (none, study, code, roleplay, offline, flux_mobile, flux_desktop).

## 7. HATA YÖNETIMI

- Kullanıcıya gösterilen hatalar **ASLA** raw backend mesajı içermez. Localized string kullanılır.
- `FirebaseCrashlytics` tüm hataları kaydeder. Network/Image hataları filtrelenir (SocketException, ClientException, DioException, Invalid image data).
- AppInitializer'ın `_determineUserFlow()` metodu "bulletproof" mantığıyla çalışır: offline durumda kullanıcıyı içeri al, captive portal/403 HTML tespitinde session'ı temizle.

## 8. FIREBASE KULLANIMI

| Servis | Kullanım Amacı |
|--------|----------------|
| Firestore | Kullanıcı profili, abonelik, modeller, haberler, server durumu |
| Auth | Email/password, anonymous, Google sign-in, auto-login |
| Cloud Functions | Proxy API, purchase verification, model registration, offer logic |
| Remote Config | Moderasyon regex, min version, fallback modeller |
| Analytics | Tüm kullanıcı etkinlikleri (screen tracking, events) |
| Crashlytics | Tüm hatalar (network noise hariç) |
| Messaging | FCM push notifications + engagement scheduler |

## 9. VERITABANI KULLANIMI

| Depolama | İçerik |
|----------|--------|
| SQLite (`chat.sqlite`) | Conversations, messages, ux_state (schema v8) |
| SQLite (`models_v2.db`) | Model kataloğu (JSON column stratejisi) |
| SharedPreferences | Tema, dil, onboarding, model cache, user cache, FCM token |
| FlutterSecureStorage | Email/password, remember_me |

## 10. LOCALIZASYON

- Tüm kullanıcıya dönük string'ler `lib/l10n/app_XX.arb` dosyalarından gelir.
- Sadece `AppLocalizations.of(context)!` veya servislere enjekte edilen `localizations` parametresi ile erişilir.
- Desteklenen diller: en, tr, ar, az, de, es, fr, hi, id, it, ja, ko, ku, nl, pt, ru, zh (17 dil).
- Yeni bir dil eklerken `lib/language.dart` içindeki `LocaleProvider`'a da ekleme yapılmalıdır.

## 11. TEMA SISTEMI

- `AppColors` statik sınıfı 8 tema tanımını içerir: `light`, `dark`, `love`, `nature`, `behindTheSlaughter`, `grayscale`, `ocean`, `scarletSnow`.
- Yeni tema eklemek: `AppColors._themeDefinitions` map'ine yeni bir `ThemeColors` ekle + `ThemeProvider`'a theme name'i tanıt.
- Tema değişikliği `SharedPreferences`'e `'selectedTheme'` key'i ile kaydedilir.
- Color değerleri `InvertedColor` extension ile ters çevrilebilir.

## 12. TEST KURALLARI

- Test dosyaları `test/` altında `{konu}_test.dart` şeklinde adlandırılır.
- `mockito` kullanılır.
- Provider/Service birim testlerinde mock'lar tercih edilir.
- Her yeni özellik için test eklenmelidir.

## 13. YENI ÖZELLIK EKLEME AKIŞI (DEĞIŞMEZ)

```
1. lib/{modul}/ altında yeni dosyalar oluştur
2. Service katmanını yaz (stateless)
3. Provider'ı yaz (ChangeNotifier)
4. Provider'ı main.dart MultiProvider ağacına ekle
5. Widget'ları yaz (Consumer/context.watch)
6. ARB dosyalarına lokalizasyon ekle
7. Test ekle
8. Mevcut naming convention'ları birebir takip et
```

## 14. GENEL YASAKLAR

- ❌ Riverpod, Bloc, GetX, Redux, MobX kullanmak
- ❌ Doğrudan Firebase instance'ı widget içinde çağırmak
- ❌ Raw backend hata mesajlarını kullanıcıya göstermek
- ❌ `setState()` ile büyük state yönetimi (Provider kullan)
- ❌ Servislerde context saklamak
- ❌ `async` fonksiyonları `Firebase.initializeApp()` öncesinde çağırmak
- ❌ ARB dosyası dışında hardcoded string bırakmak
- ❌ `BuildContext`'i servis constructor'ında tutmak
- ❌ `pubspec.yaml`'ı gereksiz yere değiştirmek

## 15. PERFORMANS KURALLARI

- `Future.wait()` ile bağımsız başlatmaları paralelleştir.
- Ağır kütüphaneleri (timezone, moderator) `_performPostStartupTasks` içinde arkada yükle.
- SVG'leri `_precacheCoreSvgs()` ile önceden cache'le.
- Tekrar kullanılan widget'lar için `const` constructor kullan.
- Stream'lerde throttle uygula (chat response 16ms).
- `MediaQuery.of(context).size` yerine `MediaQuery.sizeOf(context)` tercih et.
- Arka plan sekmelerinde `viewInsets: EdgeInsets.zero` ile gereksiz rebuild'leri engelle.

---

**Bu kuralların değişmesi için proje sahibinin onayı gerekir.**  
Herhangi bir kural ihlali halinde code review'da reddedilir.
