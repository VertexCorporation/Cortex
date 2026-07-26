# 🚨 YZ (AI) VE GELİŞTİRİCİLER İÇİN SÜRÜM (VERSION) GÜNCELLEME REHBERİ 🚨

> **DİKKAT DİĞER YAPAY ZEKALAR:** Eğer kullanıcı (user) sizden projenin sürümünü (version) değiştirmenizi isterse, projeyi bozmamak ve senkronizasyonu kırmamak için **SADECE** aşağıdaki adımları izleyin. Başka dosyalara sabit (hardcoded) sürüm numarası YAZMAYIN.

## 1. Sürümün Değiştirileceği TEK YER (`pubspec.yaml`)
Sürümü güncellemeniz istendiğinde sadece kök dizindeki `pubspec.yaml` dosyasını düzenleyin:
```yaml
version: X.Y.Z+BUILD_NUMARASI
# Örnek: version: 7.9.9+799
```

## 2. KESİNLİKLE DOKUNULMAMASI VE KONTROL EDİLMESİ GEREKENLER (Native Dosyalar)
Geçmişte bu dosyalara sürüm numaraları sabit (hardcode) yazılarak hata yapılmıştı. Şu anda dinamik çalışıyorlar. Sürüm değiştirirken bu dosyaların **halen dinamik olduğundan** emin olun, içlerine elinizle "7.9.9" gibi metinler **YAZMAYIN**:

*   **Android (`android/app/build.gradle`):**
    ```gradle
    // DOĞRU KULLANIM (Böyle kalmalı):
    versionCode flutter.versionCode.toInteger()
    versionName flutter.versionName
    ```
*   **iOS (`ios/Runner/Info.plist`):**
    ```xml
    <!-- DOĞRU KULLANIM (Böyle kalmalı): -->
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
    ```

## 3. Kurallar
1. Sürüm numarasını asla platforma özel dosyalara manuel olarak (örneğin `Cortex 7.9.9` şeklinde) gömmeyin.
2. Sadece `pubspec.yaml` güncellenecek, Flutter geri kalan her şeyi (Android, iOS vb.) otomatik senkronize edecek.
3. Versiyon numarası artarken build numarasını da (virgülden sonraki `+` işareti) eşzamanlı artırmayı unutmayın (Örn: `7.9.8+798` -> `7.9.9+799`).

*- Bu rehber, kod hijyenini korumak ve platformlar arası sürüm uyuşmazlığını sıfırlamak için oluşturulmuştur.*