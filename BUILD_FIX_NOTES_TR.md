# Cortex Android / iOS build onarımı ve log kılavuzu

## Yapılan düzeltmeler

- `.github/workflows/flutter_build.yml`: Android CI Java 17'den Java 21'e çıkarıldı. Projenin `android/app/build.gradle` ve `android/llama/build.gradle.kts` dosyaları Java 21 hedefliyor.
- Android imzalama: `CORTEX_JKS` ve `JKS_PASSWORD` birlikte yoksa **debug APK** üretilir; eksik / hatalı keystore durumunda anlaşılır hata verilir. Release APK ve AAB yalnızca geçerli anahtarla üretilir. JKS içindeki alias `ai` olmalı ve anahtar şifresi store şifresiyle aynı olmalı (mevcut proje beklentisi).
- iOS imzalama: dört secret birlikte mevcutsa `.p12` ve `.mobileprovision` doğrulanır; profile'dan Team ID, bundle ID ve profil adı alınarak runner üzerindeki Xcode projesi uyarlanır; export plist güvenli biçimde oluşturulur. Hiç secret yoksa imzasız iOS uygulaması derlenir, **IPA üretilmiş gibi gösterilmez**. Secret'ların bir kısmı varsa sebebi açık bir hata üretilir.
- `ios/Podfile.lock` artık her çalıştırmada silinmiyor; CocoaPods kurulumu mevcut kilitli bağımlılıklarla yapılır.
- Build logları hem Android hem iOS için `build-logs/` içinde dosyalanır; hata alsa bile Actions artifact'ı olarak yüklenir.
- Native llama kaynak dosyaları için basit CI ön kontrolü eklendi. Mevcut uygulama mantığına, Flutter paket sürümlerine ve native C++/Swift kaynaklarına dokunulmadı.

## GitHub Actions logu nerede?

1. GitHub'da **VertexCorporation/Cortex** reposunu aç.
2. **Actions** sekmesi → **Flutter Build & Release**.
3. Hatalı çalıştırmayı seç; kırmızı **Build Android (APK & AAB)** veya **Build iOS (IPA)** job'una tıkla.
4. İlk kırmızı adıma tıklayarak asıl `ERROR` / `FAILURE` satırlarını görüntüle; job menüsünden raw logları veya log arşivini indirebilirsin.
5. Güncellenmiş workflow çalıştığında, run sayfasında **Artifacts** altında `android-build-logs` ve `ios-build-logs` dosyaları ayrıca bulunur. Başarısız adımların logu bu dosyalarda da saklanır.

## GitHub Actions Secrets

Repo **Settings → Secrets and variables → Actions → Repository secrets**:

Android dağıtım için:
- `CORTEX_JKS`: `Cortex.jks` dosyasının base64 içeriği.
- `JKS_PASSWORD`: hem keystore hem de alias `ai` anahtarının şifresi.

iOS dağıtım için:
- `APPLE_CERTIFICATE_P12_BASE64`: Apple Distribution `.p12` dosyasının base64 içeriği.
- `APPLE_CERTIFICATE_PASS`: `.p12` şifresi.
- `APPLE_PROVISIONING_PROFILE_BASE64`: `com.vertex.cortex` için App Store dağıtım `.mobileprovision` dosyasının base64 içeriği.
- `KEYCHAIN_PASSWORD`: CI temporary keychain için güçlü, geçici depolanan parola.

**Uyarı:** İmzalama anahtarlarını veya parolalarını sohbet içinde veya ZIP'e koyma. Yalnızca GitHub Secrets'a ekle.

## Yeni build'i çalıştırma

1. Düzeltilmiş projeyi ilgili GitHub repo dalına push et.
2. **Actions → Flutter Build & Release → Run workflow**.
3. İş bittikten sonra **Artifacts** bölümündeki release dosyalarını veya hatada logları indir.

Android sırf debug APK üretmişse bunu Play Store'a yükleyemezsin. iOS imzasız `.app` de gerçek kullanıcıya gönderilecek `.ipa` değildir. Distribütif yayın için secrets gereklidir.

## Doğrulama sınırı

Orijinal çalışmanın tam GitHub Actions logları ZIP'te yok. Burada Windows/Android Flutter SDK, Android NDK veya macOS/Xcode CI runner'ı olmadığı için yeni APK/AAB/IPA derlemesi yapılarak başarı doğrulanmadı. Bu değişiklikler CI yapılandırmasını ve teşhisi iyileştirir; uygulama kaynaklarından veya harici servislerden gelebilecek diğer build hataları ancak yeni CI loguyla kesinleşir.


## v2 - Derleme hatasi duzeltmesi (GitHub Actions run 43494809918)

- lib/notifications/extrovert/handlers.dart dosyasinda bolunmus RegExp ifadesi tamamlandi.
- _reportNotificationReceipt metodu ile _showLocalizedNotification metodu dogru ayristirildi.
- Eski/tekrar eden _showLocalizedNotification implementasyonu kaldirildi.
- Yeni Future<bool> metodu background ve original parametrelerini destekliyor.
- iOS logundaki Dart parser ve named-parameter hatalarini gidermeyi hedefler; Flutter derlemesi burada calistirilamadi.
