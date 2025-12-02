// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get understood => 'Anlaşıldı.';

  @override
  String get cancel => 'İptal';

  @override
  String get remove => 'Kaldır';

  @override
  String get download => 'İndir';

  @override
  String get resume => 'Devam Et';

  @override
  String get copy => 'Kopyala';

  @override
  String get chat => 'Sohbet';

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String get light => 'Aydınlık';

  @override
  String get theme => 'Tema';

  @override
  String get no => 'Hayır';

  @override
  String get yes => 'Evet';

  @override
  String get done => 'Bitti';

  @override
  String get comingSoon => 'YAKINDA';

  @override
  String get bestValue => 'En İyi Fiyat';

  @override
  String get selected => 'Seçili';

  @override
  String get descriptionSection => 'Açıklama';

  @override
  String get searchHint => 'Ara';

  @override
  String get messageHint => 'Herhangi bir şey sor';

  @override
  String get modelLoading => 'Model yükleniyor...';

  @override
  String get messageCopied => 'Mesaj panoya kopyalandı.';

  @override
  String get storeUnavailable =>
      'Mağaza şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get systemInfo => 'Sistem Bilgileri';

  @override
  String deviceMemory(Object memory) {
    return 'Cihaz Belleği: $memory GB';
  }

  @override
  String storageSpace(Object storage) {
    return 'Depolama Alanı: $storage GB';
  }

  @override
  String freeStorageSpace(Object freeStorage) {
    return 'Boş Depolama Alanı: $freeStorage GB';
  }

  @override
  String get memory => 'Bellek';

  @override
  String get storage => 'Depolama';

  @override
  String get freeStorage => 'Boş Depolama';

  @override
  String get totalStorage => 'Toplam Depolama';

  @override
  String get usedStorage => 'Kullanılan Depolama';

  @override
  String get totalMemory => 'Toplam Bellek';

  @override
  String get usedMemory => 'Kullanılan Bellek';

  @override
  String get requirements => 'Gereksinimler';

  @override
  String get modelsTitle => 'Kütüphane';

  @override
  String get localModels => 'Yerel Modeller';

  @override
  String get serverSideModels => 'Çevrimiçi Modeller';

  @override
  String get uploadYourOwnModel => 'Kendi Modelini Yükle!';

  @override
  String get selectGGUFFile => 'GGUF Dosyası Seç';

  @override
  String get errorGGUF => 'Lütfen sadece GGUF formatında bir dosya seçin.';

  @override
  String get modelAlreadyExists => 'Model zaten mevcut.';

  @override
  String get modelAddedSuccessfully => 'Model başarıyla eklendi.';

  @override
  String get modelRemoved => 'Model başarıyla kaldırıldı.';

  @override
  String get removeError => 'Modeli kaldırırken bir hata oluştu.';

  @override
  String get fileNotFound => 'Dosya bulunamadı.';

  @override
  String get fileUploadError => 'Dosyayı yüklerken bir hata oluştu.';

  @override
  String get noFileSelected => 'Dosya seçilmedi.';

  @override
  String get myModels => 'Modellerim';

  @override
  String get create => 'Oluştur';

  @override
  String get seeAll => 'Tümünü Gör';

  @override
  String modelProducer(Object producer) {
    return 'Üretici: $producer';
  }

  @override
  String modelRAM(Object ram) {
    return 'RAM: $ram';
  }

  @override
  String modelSize(Object size) {
    return 'Boyut: $size';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get conversationsTitle => 'Sohbetler';

  @override
  String get conversationDeleted => 'Sohbet silindi.';

  @override
  String get conversationUpdated => 'Sohbet güncellendi.';

  @override
  String get editConversationTitle => 'Yeniden Adlandır';

  @override
  String get newTitle => 'Yeni Başlık';

  @override
  String get save => 'Kaydet';

  @override
  String get titleCannotBeEmpty => 'Başlık boş olamaz.';

  @override
  String get noConversationsMessage => 'Hiç sohbet yok, sohbete başla!';

  @override
  String get startChat => 'Sohbet başlat';

  @override
  String get noChats => 'Sohbet Yok';

  @override
  String get starredChats => 'Yıldızlı Sohbetler';

  @override
  String get allChats => 'Tüm Sohbetler';

  @override
  String get noStarredChats => 'Yıldızlı Sohbet Yok';

  @override
  String get noStarredChatsMessage => 'Henüz bir sohbeti yıldızlamadınız.';

  @override
  String get goToChats => 'Bir sohbeti yıldızla';

  @override
  String get starConversation => 'Yıldızla';

  @override
  String get conversationTitleUpdated => 'Sohbet başlığı güncellendi.';

  @override
  String get youReachedConversationLimit => 'Sohbet limitine ulaştınız.';

  @override
  String get today => 'Bugün';

  @override
  String get yesterday => 'Dün';

  @override
  String get loginToYourAccount => 'Giriş Yap';

  @override
  String get createYourAccount => 'Kayıt Ol';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get confirmPassword => 'Şifreyi Onayla';

  @override
  String get invalidEmail => 'Lütfen geçerli bir e-posta adresi girin.';

  @override
  String get invalidPassword => 'Şifre en az 6 karakter uzunluğunda olmalıdır.';

  @override
  String get rememberMe => 'Beni hatırla';

  @override
  String get forgotPassword => 'Şifremi Unuttum?';

  @override
  String get or => 'Veya';

  @override
  String get continueWithGoogle => 'Google ile Devam Et';

  @override
  String get dontHaveAccount => 'Hesabın yok mu?';

  @override
  String get alreadyHaveAccount => 'Zaten bir hesabın var mı?';

  @override
  String get signUp => 'Kayıt Ol';

  @override
  String get logIn => 'Giriş Yap';

  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor.';

  @override
  String get userNotFound => 'Kullanıcı bulunamadı.';

  @override
  String get wrongPassword => 'Yanlış şifre.';

  @override
  String get emailAlreadyInUse => 'Bu e-posta adresi zaten kullanılıyor.';

  @override
  String get weakPassword => 'Şifre çok zayıf.';

  @override
  String get authError => 'Kimlik Doğrulama Hatası';

  @override
  String get invalidUsername => 'Lütfen bir kullanıcı adı girin.';

  @override
  String get usernameTaken => 'Bu kullanıcı adı zaten alınmış.';

  @override
  String get username => 'Kullanıcı Adı';

  @override
  String get authenticationFailed =>
      'Kimlik doğrulama başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get emailTooLong => 'E-posta en fazla 30 karakter olabilir.';

  @override
  String get deviceLimitReached =>
      'Bu cihaz için hesap oluşturma limitine ulaştınız.';

  @override
  String get verificationEmailLimitReached => 'Daha fazla göndermeyeceğiz';

  @override
  String get verificationEmailSent => 'Doğrulama e-postası gönderildi!';

  @override
  String get emailNotVerified => 'E-posta doğrulanmadı';

  @override
  String get resendCode => 'Doğrulama e-postasını yeniden gönder';

  @override
  String get remainingSeconds => 'Doğrulama için kalan süre';

  @override
  String get pleaseCheckYourEmail =>
      'Cortex\'i kullanmak için e-postanızı doğrulamanız gerekir. \n E-posta adresinize bir doğrulama bağlantısı gönderildi, lütfen e-postanızı kontrol edin.';

  @override
  String get verifyYourEmail => 'E-postanızı Doğrulayın';

  @override
  String get backToLogin => 'Geri Dön';

  @override
  String get seconds => 'saniye';

  @override
  String get maxResendLimitReached =>
      'Maksimum doğrulama e-postası sayısına ulaştınız.';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Doğrulama yapmadan devam et';

  @override
  String get verificationScreenWarning =>
      'Devam etseniz bile, 1 günlük hesap doğrulama süresi hesabınız için hala geçerlidir. Hesabınızı o zamana kadar doğrulamadıysanız, uygulamadan silinecektir.';

  @override
  String get unverifiedAccountHeader => 'Hesabınız doğrulanmadı';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Hesabınızı $timeLeft içinde doğrulamazsanız silinecektir.';
  }

  @override
  String get verifyNow => 'Şimdi Doğrula';

  @override
  String get accountVerified => 'Hesabınız doğrulandı.';

  @override
  String get linkSent => 'Bağlantı gönderildi';

  @override
  String get accountDeletionRequested =>
      'Hesap silme talebiniz alındı ve hesabınız şimdi devre dışı bırakıldı.';

  @override
  String get tooManyRequests => 'Çok fazla istek';

  @override
  String get regenerate => 'Yeniden Oluştur';

  @override
  String get confirmDeleteAccount =>
      'Hesabınızı silmek istediğinizden emin misiniz?';

  @override
  String get enterPasswordToDelete => 'Silmek için şifrenizi girin.';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get deleteAccountError => 'Hesabı silerken bir hata oluştu.';

  @override
  String get delete => 'Sil';

  @override
  String get passwordRequired => 'Şifre gerekli.';

  @override
  String get deleteDescription =>
      'Sildiğiniz veriler sunucumuzdan ve cihazınızdan kalıcı olarak kaldırılacaktır. Bu eylemler geri alınamaz.';

  @override
  String get deleteAccountButton => 'Hesap Silme Butonu';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get displayName => 'Görünen Ad';

  @override
  String get tapToChangeProfilePicture =>
      'Profil resmini değiştirmek için dokun';

  @override
  String get profileUpdated => 'Profil başarıyla güncellendi';

  @override
  String get updateFailed => 'Profil güncellenemedi';

  @override
  String get nameCannotBeEmpty => 'İsim boş olamaz';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get noDisplayName => 'Görünen ad ayarlanmamış';

  @override
  String get noEmail => 'E-posta adresi yok';

  @override
  String get noUserLoggedIn => 'Şu anda giriş yapmış kullanıcı yok';

  @override
  String get profile => 'Profil';

  @override
  String get manageProfileDescription =>
      'Profilinizi yönetin, şifrenizi güncelleyin veya Cortex\'ten çıkış yapın.';

  @override
  String get accessSettingsDescription =>
      'Yardıma erişin, kodları kullanın, Cortex\'i paylaşın ve politikalarımızı görüntüleyin.';

  @override
  String get languageDescription =>
      'Varsayılan uygulama arayüz dilinizi istediğiniz zaman değiştirebilirsiniz.';

  @override
  String get themeDescription =>
      'Tercihinize göre aydınlık ve karanlık temalar arasında geçiş yapabilirsiniz. Seçilen tema Cortex arayüzü genelinde uygulanacaktır.';

  @override
  String get iHaveReadAndAgree => 'Hizmet şartlarını okudum ve kabul ediyorum';

  @override
  String get downloading => 'İndiriliyor...';

  @override
  String get downloadError => 'İndirme sırasında bir hata oluştu.';

  @override
  String get downloadCancelled => 'İndirme iptal edildi.';

  @override
  String get downloadResumed => 'İndirme devam ettirildi.';

  @override
  String get downloadSuccess => 'İndirme başarılı';

  @override
  String get downloadFailed => 'İndirme başarısız';

  @override
  String downloaded(Object percent) {
    return '%$percent indirildi';
  }

  @override
  String get downloadPaused => 'İndirme duraklatıldı.';

  @override
  String get purchaseSuccessful => 'Satın alma başarılı!';

  @override
  String get purchaseFailed => 'Satın alma başarısız';

  @override
  String get creditProductNotFound => 'Seçilen kredi ürünü bulunamadı.';

  @override
  String get creditsAddedSuccessfully =>
      'Krediler hesabınıza başarıyla eklendi!';

  @override
  String get creditDeliveryFailed =>
      'Hesabınıza kredi eklenemedi. Lütfen destek ile iletişime geçin.';

  @override
  String get invalidPurchase => 'Geçersiz satın alma';

  @override
  String get purchaseError => 'Satın alma hatası';

  @override
  String get purchaseVertexPlusToUpload => 'Bu bir Plus özelliğidir';

  @override
  String get purchasePlus => 'Cortex Plus Satın Al';

  @override
  String get plusDescription =>
      'Cortex\'in daha fazla özelliğine erişin ve yapay zekayı çok daha fazla deneyimleyin!';

  @override
  String get annual => 'Yıllık';

  @override
  String get monthly => 'Aylık';

  @override
  String get manageSubscription => 'Aboneliği Yönet';

  @override
  String purchasePlan(String planName) {
    return '$planName Satın Al';
  }

  @override
  String discountOffer(int percent) {
    return '%$percent UCUZ';
  }

  @override
  String annualPlanDescription(String price) {
    return '$price/ay, yıllık faturalandırılır';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/ay, aylık faturalandırılır';
  }

  @override
  String get discountBannerTitle => 'LANSMANA ÖZEL: %80 İNDİRİM!';

  @override
  String get discountBannerSubtitle =>
      'Tüm abonelik planlarında lansmanımıza özel indirim! Kaçırmayın!';

  @override
  String get purchasePro => 'Cortex Pro Satın Al';

  @override
  String get proDescription =>
      'Cortex\'in daha da fazla özelliğine erişin ve yapay zekayı daha da fazla deneyimleyin!';

  @override
  String get alreadySubscribed => 'Zaten abonesiniz';

  @override
  String get subscriptionInfo => 'Aboneliğiniz aktif.';

  @override
  String get alreadySubscribedMessage =>
      'Zaten bir Plus aboneliğiniz var. Aboneliğinizi iptal etmek isterseniz, Play Store yöneticisi aracılığıyla yapabilirsiniz.';

  @override
  String get cancelSubscription => 'Aboneliği İptal Et';

  @override
  String get cancelSubscriptionInfo =>
      'Aboneliğinizi iptal etmek isterseniz, lütfen Play Store abonelik yöneticisi aracılığıyla devam edin.';

  @override
  String get goToPlayStore => 'Play Store\'a Git';

  @override
  String get alreadySubscribedPlus => 'Plus Planınız Var!';

  @override
  String get alreadySubscribedPlusMessage =>
      'Plus planınız aktif. Tüm avantajlardan yararlanabilirsiniz.';

  @override
  String get purchaseUltra => 'Cortex Ultra Satın Al';

  @override
  String get ultraDescription =>
      'Cortex\'in tüm özelliklerine tam erişim sağlayın ve yapay zekayı sonuna kadar deneyimleyin!';

  @override
  String get noSubscription => 'Abonelik Yok';

  @override
  String get noSubscriptionMessage => 'Henüz bir aboneliğiniz yok.';

  @override
  String get alreadyAtHighestPlan => 'Zaten en yüksek plandasınız.';

  @override
  String get unableToOpenSubscription =>
      'Abonelik yönetimi sayfası açılamıyor.';

  @override
  String get upgradeSubscription => 'Aboneliği Yükselt';

  @override
  String get confirmUpgrade =>
      'Aboneliğinizi yükseltmek istediğinizden emin misiniz?';

  @override
  String get unsupportedPlatform =>
      'Abonelik iptali için desteklenmeyen platform.';

  @override
  String get purchaseStreamError => 'Satın alma akışı hatası.';

  @override
  String get productNotFound => 'Ürün bulunamadı';

  @override
  String get productDetailsError =>
      'Ürün ayrıntıları alınırken bir hata oluştu.';

  @override
  String get noProductsFound => 'Ürün bulunamadı';

  @override
  String get loadCreditsButton => 'Kredi Yükle';

  @override
  String get creditsTitle => 'Krediler';

  @override
  String get creditsScreenDescription =>
      'Bu ekran kullanıcının kredilerini gösterir. \n\nKullanıcının mevcut kredileri: 100\n\nAyrıntılı kredi bilgileri burada görüntülenebilir.';

  @override
  String get creditsLoaded => 'Krediler yüklendi!';

  @override
  String get currentCredits => 'Mevcut Krediler';

  @override
  String get pleaseSelectCreditPackage => 'Lütfen bir kredi paketi seçin';

  @override
  String get purchaseCreditsTitle => 'Kredi Satın Al';

  @override
  String get purchaseCreditsDescription =>
      'İhtiyaçlarınıza uygun bir kredi paketi seçin ve uygulamamızı daha fazla kullanın.';

  @override
  String get purchaseButton => 'Satın Al';

  @override
  String get productNotFoundMessage => 'Seçilen ürün mevcut değil.';

  @override
  String get buyCredits => 'Kredi Satın Al';

  @override
  String get selectCreditPackageDescription =>
      'İhtiyaçlarınıza uygun bir kredi paketi seçin ve daha fazla özelliğin keyfini çıkarın.';

  @override
  String get buyCredit => 'Kredi Satın Al';

  @override
  String buyCreditPackage(Object amount) {
    return '$amount Kredi Satın Al';
  }

  @override
  String get subscribedPlan => 'Abone Olundu';

  @override
  String get errorResponseNotReceived => 'Yanıt alınamadı';

  @override
  String googleApiRequestFailed(int attempt, String error) {
    return 'Google API isteği $attempt kez başarısız oldu: $error';
  }

  @override
  String openRouterResponseStatus(int statusCode) {
    return 'OpenRouter Yanıt Durumu: $statusCode';
  }

  @override
  String openRouterDecodedResponseBody(String body) {
    return 'OpenRouter Çözülmüş Yanıt Gövdesi: $body';
  }

  @override
  String decodedJson(String data) {
    return 'Çözülmüş JSON: $data';
  }

  @override
  String get responseStructureUnexpectedMessageContentMissing =>
      'Yanıt yapısı beklenmedik: mesaj veya içerik eksik';

  @override
  String get responseStructureUnexpectedChoicesMissing =>
      'Yanıt yapısı beklenmedik: seçimler eksik veya boş';

  @override
  String openRouterApiRequestFailed(int statusCode, String body) {
    return 'OpenRouter API isteği başarısız oldu: $statusCode - $body';
  }

  @override
  String openRouterApiRequestFailedAfterAttempts(int attempt, String error) {
    return 'OpenRouter API isteği $attempt kez başarısız oldu: $error';
  }

  @override
  String get internetRequired =>
      'Bu modeli kullanmak için internet bağlantısı gereklidir';

  @override
  String get pleaseWaitBeforeTryingAgain =>
      'Lütfen tekrar denemeden önce bir an bekleyin';

  @override
  String openRouterQuotaExceeded(int statusCode, String decodedBody) {
    return 'Kota aşıldı. Durum kodu: $statusCode, Gövde: $decodedBody';
  }

  @override
  String openRouterApiRequestFailedAfterPaidAttempts(
      int attempts, String error) {
    return 'API isteği $attempts ücretli denemeden sonra başarısız oldu. Hata: $error';
  }

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Bu siparişi vererek, Hizmet Şartları ve Gizlilik Politikası\'nı kabul etmiş olursunuz. Hizmet Şartlarımız ve Gizlilik Politikamız hakkında daha fazla bilgi edinmek için bu metne tıklayabilirsiniz. Abonelik, mevcut dönemin bitiminden en az 24 saat önce otomatik yenileme kapatılmadığı sürece otomatik olarak yenilenecektir.';

  @override
  String get termsOfService => 'Hizmet Şartları';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get report => 'Rapor Et';

  @override
  String get reportDialogTitle => 'Rapor Gönder';

  @override
  String get reportDescriptionLabel => 'Sorun nedir?';

  @override
  String get reportHarmful => 'Bu zararlı/güvensiz';

  @override
  String get reportNotTrue => 'Bu doğru değil';

  @override
  String get reportNotHelpful => 'Bu yardımcı değil';

  @override
  String get closeButton => 'Kapat';

  @override
  String get submitButton => 'Gönder';

  @override
  String get reportErrorMessage => 'Lütfen raporlama için bir neden seçin.';

  @override
  String get capabilitiesSection => 'Yetenekler';

  @override
  String get ratingsSection => 'Değerlendirmeler';

  @override
  String get noRatingDataFound => 'Değerlendirme verisi bulunamadı';

  @override
  String get featurePhotoTitle => 'Fotoğraf Tarama';

  @override
  String get featurePhotoDescription =>
      'Bu model, kamera veya resim dosyaları aracılığıyla fotoğraf tarama yeteneğine sahiptir.';

  @override
  String get featureOfflineTitle => 'Çevrimdışı Çalışma';

  @override
  String get featureOfflineDescription =>
      'Verilerinizi güvende tutmak için modeli internet bağlantısı olmadan çalıştırın.';

  @override
  String get featureSupermodelTitle => 'Süper Model';

  @override
  String get featureSupermodelDescription =>
      'Bu, 10 milyardan fazla parametreye sahip, yüksek performans ve geniş yetenekler sunan devasa bir modeldir.';

  @override
  String get featureRoleplayTitle => 'Rol Yapma';

  @override
  String get featureRoleplayDescription =>
      'Rol yapma modelleri, çeşitli sohbetler ve senaryolar oluşturmanıza olanak tanır.';

  @override
  String get roleModels => 'Rol Yapma Modelleri';

  @override
  String get parameters => 'Parametreler';

  @override
  String get context => 'Bağlam';

  @override
  String get millions => 'milyon';

  @override
  String get billions => 'milyar';

  @override
  String get trillions => 'trilyon';

  @override
  String get thousand => 'bin';

  @override
  String get estimated => 'tahmini';

  @override
  String get finalPreparation => 'Son hazırlıklar yapılıyor.';

  @override
  String get allEvaluationsByTestTeam =>
      'Tüm değerlendirmeler test ekibimiz tarafından yapılmıştır';

  @override
  String get shareApp => 'Uygulamayı Paylaş';

  @override
  String get rateUs => 'Bizi Değerlendir';

  @override
  String get share => 'Paylaş';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get shareMessage =>
      'Cortex uygulamasına bir göz at, harika! Buradan indir: https://play.google.com/store/apps/details?id=com.vertex.cortex';

  @override
  String get shareFailed =>
      'Uygulama paylaşılamadı. Lütfen daha sonra tekrar deneyin';

  @override
  String get selectText => 'Metin Seç';

  @override
  String get showLatex => 'Özel Sembolleri Göster';

  @override
  String get hideLatex => 'Özel Sembolleri Gizle';

  @override
  String get thinking => 'Düşünüyor';

  @override
  String get user => 'Kullanıcı';

  @override
  String get voice => 'Ses';

  @override
  String get help => 'Yardım';

  @override
  String get redeemCode => 'Kod Kullan';

  @override
  String get enterYourCode =>
      'Favori içerik üreticilerinizi destekleyin! Cortex satın alımlarınızdan pay almalarını sağlamak için benzersiz kodlarını aşağıya girin.';

  @override
  String get code => 'Kod';

  @override
  String get redeem => 'Kullan';

  @override
  String get codeCannotBeEmpty => 'Kod boş olamaz';

  @override
  String get userId => 'Kullanıcı ID';

  @override
  String get deleteAllConversationsConfirmTitle => 'Tüm Sohbetler Silinsin mi?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Tüm sohbetlerinizi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get allConversationsDeleted => 'Tüm sohbetler başarıyla silindi!';

  @override
  String get deleteAll => 'Tümünü Sil';

  @override
  String get deleteAllConversationsButton => 'Tüm Sohbetleri Sil';

  @override
  String get confirmWord => 'VERTEX yazın';

  @override
  String get confirmWordError => 'Yanlış yazdınız';

  @override
  String get chinese => 'Çince';

  @override
  String get arabic => 'Arapça';

  @override
  String get french => 'Fransızca';

  @override
  String get japanese => 'Japonca';

  @override
  String get kurdish => 'Kürtçe';

  @override
  String get dutch => 'Flemenkçe';

  @override
  String get russian => 'Rusça';

  @override
  String get korean => 'Korece';

  @override
  String get deutsch => 'Almanca (Deutsch)';

  @override
  String get english => 'İngilizce';

  @override
  String get turkish => 'Türkçe';

  @override
  String get hindi => 'Hintçe';

  @override
  String get portuguese => 'Portekizce';

  @override
  String get indonesian => 'Endonezyaca';

  @override
  String get azerbaijani => 'Azerbaycan Türkçesi';

  @override
  String get german => 'Almanca';

  @override
  String get spanish => 'İspanyolca';

  @override
  String get italian => 'İtalyanca';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'Kullanıcı adı çok kısa.';

  @override
  String get usernameTooLong => 'Kullanıcı adı 16 karakteri aşamaz.';

  @override
  String get invalidUsernameCharacters =>
      'Kullanıcı adında sadece şu harfler: \'abcçdefgğhıijklmnoöprsştuüvyzxqw\' ve \'.\', \'-\', \'_\' karakterleri kullanılabilir.';

  @override
  String get passwordTooLong => 'Şifre 64 karakteri aşamaz.';

  @override
  String get noInternetConnection => 'İnternet bağlantısı yok.';

  @override
  String get chats => 'Gelen Kutusu';

  @override
  String get library => 'Kütüphane';

  @override
  String get inappropriateMessageWarning => 'Uygunsuz mesaj tespit edildi!';

  @override
  String get myModelDescription => 'Benim modelim.';

  @override
  String get noModelsDownloaded => 'Henüz herhangi bir model indirmediniz.';

  @override
  String get appTitle => 'Cortex';

  @override
  String get text => 'Metin';

  @override
  String get removeModel => 'Modeli Kaldır';

  @override
  String get modelUploadedSuccessfully => 'Model başarıyla yüklendi.';

  @override
  String get insufficientRAM => 'Yetersiz Bellek';

  @override
  String get insufficientStorage => 'Yetersiz Depolama';

  @override
  String confirmRemoveModel(Object model) {
    return '$model modelini cihazınızdan kaldırmak istediğinizden emin misiniz? Bu işlem, o modelle olan önceki tüm sohbetleri de silecektir.';
  }

  @override
  String get noMatchingModels => 'Eşleşen model bulunamadı.';

  @override
  String creditPackage(Object amount) {
    return '$amount Kredi Satın Al';
  }

  @override
  String get benefit1 =>
      'Çevrimiçi yapay zekalar için çok daha fazla sohbet limiti';

  @override
  String get benefit2 => 'Kendi modellerinizi yükleyin';

  @override
  String get benefit3 => 'Profil efekti';

  @override
  String get benefit4 => 'Üyelik rozeti';

  @override
  String get benefit5 => 'Daha fazla çevrimiçi yapay zeka oluşturun';

  @override
  String get benefit6 => 'Sınırsız sohbet';

  @override
  String benefit7(Object credits) {
    return 'Günlük $credits kredi';
  }

  @override
  String get benefit8 => 'Model ekle';

  @override
  String get benefit9 => 'Yeni temalar';

  @override
  String get benefit10 => 'Çevrimdışı sesli sohbet';

  @override
  String get oldBenefits => 'Alt planlardaki tüm avantajlar';

  @override
  String get confirm => 'Onayla';

  @override
  String get changePassword => 'Şifre değiştir';

  @override
  String get logoutConfirmationTitle =>
      'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get settings => 'Ayarlar';

  @override
  String get language => 'Uygulama Dili';

  @override
  String get dark => 'Karanlık';

  @override
  String get oldPassword => 'Eski Şifre';

  @override
  String get newPassword => 'Yeni Şifre';

  @override
  String get passwordUpdated => 'Şifre güncellendi.';

  @override
  String get stop => 'Durdur';

  @override
  String get copyrights => 'Atıflar';

  @override
  String get downloadingTitle => 'İndiriliyor';

  @override
  String get downloadCompletedTitle => 'İndirme Tamamlandı';

  @override
  String get downloadPausedTitle => 'İndirme Duraklatıldı';

  @override
  String get downloadErrorTitle => 'İndirme Hatası';

  @override
  String get cancelButtonText => 'İptal';

  @override
  String get love => 'Aşk';

  @override
  String get nature => 'Doğa';

  @override
  String get behindTheSlaughter => 'Katliamın Ardında';

  @override
  String get grayscale => 'Gri Tonlama';

  @override
  String get ocean => 'Okyanus';

  @override
  String get scarletSnow => 'Kızıl Kar';

  @override
  String get requestFailed => 'Bir hata oluştu, lütfen tekrar deneyin.';

  @override
  String get changeModel => 'Değiştir';

  @override
  String get edit => 'Düzenle';

  @override
  String get editingMessageInfo =>
      'Bu mesajı düzenlemek, sohbeti buradan yeniden başlatacaktır.';

  @override
  String get editingNotification => 'Şu anda düzenleme modundasınız';

  @override
  String get featureIndulgentTitle => 'Hoşgörülü';

  @override
  String get featureIndulgentDescription =>
      'Bu model, 100.000 jetonu aşan bağlamları sorunsuzca barındırabilir ve işleyebilir, bu da performanstan ödün vermeden kapsamlı ve ayrıntılı girdileri yönetmesini sağlar.';

  @override
  String get featurePluralTitle => 'Çoğulcu';

  @override
  String get featurePluralDescription =>
      'Bu model, ek uzantıları otomatik olarak entegre edebilir, böylece işlevsel yeteneklerini genişleterek çeşitli işlemleri gelişmiş performansla destekler.';

  @override
  String get featureWiseTitle => 'Bilge';

  @override
  String get featureWiseDescription =>
      'Bu model, karar verme ve karmaşık problem çözme için sofistike destek sağlamak üzere derin analitik içgörülerden ve ileri görüşlü akıl yürütmeden yararlanabilir.';

  @override
  String get featureResearcherTitle => 'Araştırmacı';

  @override
  String get featureResearcherDescription =>
      'Yalnızca gelişmiş araştırma ve analitik kapasitelerle donatılmış modellerde bulunan bu özellik, çeşitli alanlarda yüksek hassasiyetli içgörüler ve kapsamlı analizler sağlamak üzere tasarlanmıştır.';

  @override
  String get nameLabel => 'YZ adı';

  @override
  String get nameHint => 'YZ\'nizin adını girin';

  @override
  String get summaryLabel => 'YZ Özeti';

  @override
  String get summaryHint => 'YZ\'nizin özetini girin';

  @override
  String get add => 'Ekle';

  @override
  String get aiExplanationTitle => 'Yapay Zeka Açıklaması';

  @override
  String get aiExplanationDescription =>
      'Lütfen yapay zeka modelinizin mimarisi, eğitim süreci, performans metrikleri, uygulama alanları ve diğer önemli özellikleri hakkında ayrıntılı bir açıklama yapın.';

  @override
  String get preInputTitle => 'Yapay Zeka Ön Girişi';

  @override
  String get preInputDescription =>
      'Lütfen modelinizi karakter oluşturma sürecinde yönlendirecek bir ön giriş ayarlayın. Bu bölümde, karakterle ilgili bilgiler, ek bağlam ve karakterle ilgili içerik oluşturmada yardımcı olabilecek ekstra ayrıntıları ekleyebilirsiniz.';

  @override
  String get baseModelTitle => 'Temel Model';

  @override
  String get baseModelDescription =>
      'Bu, yaratımınız için temel olarak kullanılacak modeldir. Şu anda seçili olan temel modeli gösterir.';

  @override
  String get summary => 'Özet';

  @override
  String get characterPoliceTitle => 'Polis';

  @override
  String get characterPoliceRole =>
      'Sen, vatandaşları korumaya ve sarsılmaz bir bağlılıkla düzeni sağlamaya adanmış, kanunun uyanık bir uygulayıcısısın, sen bir polissin.';

  @override
  String get characterPoliceShortDescription =>
      'Kararlı ve cesur bir kanun uygulayıcısı.';

  @override
  String get purchaseSubscription => 'Satın Al';

  @override
  String get modelUploadTitle => 'Yapay Zeka Dosyası';

  @override
  String get modelUploadDescription =>
      'Yerel GGUF dosyalarınızı doğrudan cihazınızdan seçip yükleyin. Bu, modelinizi internet bağlantısı gerektirmeden çevrimdışı çalıştırmanızı sağlar. Dosyanın geçerli GGUF formatında ve düzgün yapılandırılmış olduğundan emin olun. Dosya yanlış veya bozuksa, Cortex beklendiği gibi çalışmayabilir ve hatalarla karşılaşabilirsiniz.';

  @override
  String get modelUploadShortDescription =>
      'Cihazınızdan bir .gguf dosyası seçmek için buraya dokunun';

  @override
  String get addServerTitle => 'Yapay Zeka Sunucusu';

  @override
  String get addServerDescription =>
      'Harici olarak barındırılan bir modele bağlanmak için uzak sunucunuzun URL\'sini girin. Bu özellik aktif bir internet bağlantısı gerektirir ve sunucuyla ilgili herhangi bir sorun veya hata Cortex kaynaklı değildir. Sorunsuz bir deneyim için sunucunuzun doğru yapılandırıldığından, ağınızdan erişilebilir olduğundan ve geçerli bir model uç noktasına sahip olduğundan emin olun.';

  @override
  String get you => 'Siz';

  @override
  String get removePhotoTitle => 'Fotoğrafı Kaldır';

  @override
  String get confirmRemovePhoto =>
      'Fotoğrafı kaldırmak istediğinizden emin misiniz?';

  @override
  String get serverLink => 'Sunucu Bağlantısı';

  @override
  String get enterURL => 'Sunucu URL\'sini girin';

  @override
  String get chatLengthLimitExceeded =>
      'Bu sohbet karakter sınırını aştı. Lütfen yeni bir sohbet başlatın veya bir abonelik satın alın.';

  @override
  String get aiNameError => 'Bu isimde bir yapay zeka zaten var.';

  @override
  String get modelLimitExceeded =>
      'Planınız için maksimum model oluşturma sınırına ulaştınız.';

  @override
  String get modelVertexProducer => 'Vertex';

  @override
  String get photoLimitReachedMessage => 'Sadece bir fotoğraf eklenebilir';

  @override
  String get inappropriateContentDetected => 'Uygunsuz içerik tespit edildi!';

  @override
  String get offlineModelNotInstalled =>
      'Bu çevrimdışı model cihazınızda yüklü değil.';

  @override
  String insufficientCredits(Object available, Object required) {
    return 'Bu isteği tamamlamak için yeterli krediniz yok. Bu eylem $required kredi gerektiriyor, ancak sizde yalnızca $available var. Daha fazla kredi kazanmak için planınızı yükseltebilir veya doğrudan satın alabilirsiniz. kanka biliyoruz bu kredi mevzusu can sıkıcı ama modellerden cevap almak biraz pahalı yani bu krediler aslında gerekli yoksaBata.rizOglum satın alım yapanlar fazla olursa az para kazanırsak limitleri de artırabiliriz o zamana kadar aynı devam';
  }

  @override
  String get regenerateInProgress => 'Yanıt oluşturma zaten devam ediyor.';

  @override
  String errorOccurredDuringRegeneration(String errorDetails) {
    return 'Yeniden oluşturmaya çalışırken bir hata oluştu: $errorDetails';
  }

  @override
  String get modality => 'Modalite';

  @override
  String get multimodal => 'Çoklu-Modal';

  @override
  String get anErrorOccurred => 'Bir Hata Oluştu';

  @override
  String get themeLocked =>
      'Bu tema daha yüksek bir abonelik seviyesi gerektiriyor. Kilidi açmak için lütfen yükseltme yapın.';

  @override
  String get pageCouldNotBeLoaded => 'Sayfa Yüklenemedi';

  @override
  String get checkYourInternet =>
      'Lütfen internet bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get errorUserNotAuthenticated =>
      'Bu eylemi gerçekleştirmek için giriş yapmış olmalısınız.';

  @override
  String get errorInsufficientCredits =>
      'Yetersiz krediniz var. Devam etmek için lütfen kredi yükleyin.';

  @override
  String get errorRateLimitExceeded =>
      'Çok fazla istek. Lütfen bir süre sonra tekrar deneyin.';

  @override
  String get errorServer =>
      'Beklenmedik bir sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.';

  @override
  String get errorNetwork =>
      'Bir ağ hatası oluştu. Lütfen bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get errorApiAuthentication =>
      'Kimlik doğrulama başarısız oldu. Lütfen tekrar giriş yapmayı deneyin.';

  @override
  String get baseModelForCharacterDescription =>
      'Seçilen temel model, karakterin akıl yürütme ve yanıt verme yeteneklerini belirleyecektir.';

  @override
  String get selectBaseModel => 'Bir Temel Model Seçin';

  @override
  String get couldNotOpenLink => 'Bağlantı açılamadı';

  @override
  String get downloadStarted => 'İndirme başlatıldı';

  @override
  String get notAvailable => 'Mevcut Değil';

  @override
  String get localizationWarning =>
      'Bazı bilgiler dilinizde mevcut olmayabilir ve İngilizce olarak gösterilecektir.';

  @override
  String get aiTranslationWarning =>
      'Model bilgileri, diğer yapay zeka modelleri tarafından çeşitli dillere çevrilmektedir. Bu nedenle, İngilizce dışındaki dillerde küçük tutarsızlıklar meydana gelebilir.';

  @override
  String get errorLoadingTitle => 'Veri Yüklenemedi';

  @override
  String get errorLoadingMessage =>
      'Sunucularımızdan gerekli verileri alamadık. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get noModelsFoundTitle => 'Sonuç Bulunamadı';

  @override
  String get noModelsFoundMessage =>
      'Arama terimlerinizi değiştirmeyi veya filtreyi temizlemeyi deneyin.';

  @override
  String get usernameRateLimitExceeded =>
      'Kullanıcı adınızı her 14 günde yalnızca iki kez değiştirebilirsiniz.';

  @override
  String get usernameUnchanged => 'Bu zaten mevcut kullanıcı adınız.';

  @override
  String get creditsInfoPanelTitle => 'Krediler Nasıl Çalışır?';

  @override
  String get creditsInfoPanelBody =>
      'Krediler, çevrimiçi modellerle sohbet etmek için kullanılır. her mesajın bize bi maliyeti var ve bu krediler batmamızı engelliyo neyse hadi sistemi anlatalım\n\n• Ücretsiz bir çevrimiçi modele mesaj göndermek 5 kredidir.\n• Premium bir çevrimiçi modele mesaj göndermek 20 kredidir.\n• Bir ek dahil etmek 30 kredi daha ekler.\n• Ücretsiz plan kullanıcıları her gün sıfırlanan 200 kredi bonusu alır.';

  @override
  String get creditsInfoPanelFooter => 'İyi sohbetler!';

  @override
  String get disclaimerMessage =>
      'Yapay zekalar hata yapabilir, önemli bilgileri kontrol edin.';

  @override
  String get modelCreatedSuccess => 'Model başarıyla oluşturuldu!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '“$modelName” başarıyla kaldırıldı.';
  }

  @override
  String get errorCreatingModel =>
      'Model oluşturulurken beklenmeyen bir hata oluştu.';

  @override
  String get errorDeletingModel =>
      'Model silinirken beklenmeyen bir hata oluştu.';

  @override
  String get ultraFeatureOnly =>
      'Bu özellik yalnızca Ultra üyeler için kullanılabilir.';

  @override
  String get experimentalOfflineWarning =>
      'Çevrimdışı mod hâlâ deneyseldir ve indirdiğiniz model optimum verimlilikle çalışmayabilir.';

  @override
  String get noConversationsToDelete => 'You have no conversations to delete.';

  @override
  String get reportSubmitted => 'Rapor başarıyla gönderildi.';

  @override
  String get purchaseReceived => 'Satın alım alındı, hesabınız güncelleniyor.';

  @override
  String get verificationDelayed =>
      'Satın alımınız onaylandı. Hesabınıza yansımasında kısa bir gecikme yaşanıyor, yakında görünecektir.';

  @override
  String get maintenanceTitle => 'Bakımdayız';

  @override
  String get maintenanceMessage =>
      'Önemli güncellemeler yaparken Cortex geçici olarak çevrimdışı. Uygulamaya erişim kısa süre içinde yeniden sağlanacaktır.\n\nDeneyiminizi iyileştirirken gösterdiğiniz sabır için teşekkür ederiz.';

  @override
  String get errorPromptFlagged =>
      'Mesajınız uygunsuz olarak tespit edildiği için gönderilemedi.';

  @override
  String get notEnoughStorage =>
      'Cihazınızda yeni mesajları kaydetmek için yeterli depolama alanı yok.';

  @override
  String get errorRateLimit =>
      'Son zamanlarda çok fazla model oluşturdunuz, lütfen tekrar denemeden önce bir süre bekleyin.';

  @override
  String get errorContentFlagged =>
      'İçeriği uygunsuz olarak işaretlendiği için model kaydedilemedi.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Aktif bir sohbetteyken tüm sohbetleri silemezsiniz, devam etmek için lütfen önce mevcut sohbetten çıkın.';

  @override
  String get invalidCredentials => 'E-posta veya şifre hatalı.';

  @override
  String get userDisabled => 'Bu kullanıcı hesabı devre dışı bırakıldı.';

  @override
  String get loginSubtitle =>
      'Vertex hesabınıza giriş yapın. Üçüncü taraf hizmetler aracılığıyla kaydolan yeni kullanıcılar, Şartlar ve Gizlilik Politikamızı kabul etmiş sayılır. Bunları Kayıt ekranında inceleyebilirsiniz.';

  @override
  String get registerSubtitle =>
      'Diğer projelerimizde de kullanabileceğiniz bir Vertex hesabı oluşturun.';

  @override
  String get photoWarningMessage =>
      'Bir fotoğraf eklenmiştir. Görüntüleri desteklemeyen modeller bunu yok sayabilir.';

  @override
  String get loginRequiredForPurchase =>
      'Satın alma işlemi yapmak için giriş yapmalısınız.';

  @override
  String get storagePermissionRequired =>
      'İndirilen modelleri kaydetmek için depolama izni gereklidir. Devam etmek için lütfen izin verin.';

  @override
  String get creditBannerTitle => 'Bedava Kredi Kazan!';

  @override
  String get creditBannerSubtitle =>
      'Bir arkadaşını davet et, ikiniz de anında 50 kredi kazanın! Abone olursa, ikinize de tam 500 kredi daha hediye!';

  @override
  String get inviteShareSubject => 'Cortex\'e Katıl!';

  @override
  String inviteShareMessage(String playStoreLink) {
    return 'kanka cortex diye manyak bi uygulama var birilerini davet edince 50 kredi geliyo bizim hesaplara hatta abonelik alırsan ikimiz de 500 kazancaz EFSANE FIRSAT İNDİR İNDİR HIZLI\n\n$playStoreLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Cortex\'i sevdin mi?';

  @override
  String get reviewHelpUsGrow =>
      'Değerlendirmeniz, genç ve bağımsız ekibimize büyük bir destek olmakta ve Cortex\'i sizin için daha da iyi hale getirmemizi sağlamakta.';

  @override
  String get reviewMaybeLater => 'Belki Daha Sonra';

  @override
  String get reviewRateNow => 'Değerlendir';

  @override
  String get noThanks => 'Hayır, Teşekkürler';

  @override
  String get updateRequiredTitle => 'Güncelleme Var';

  @override
  String get updateRequiredMessage =>
      'Cortex\'i kullanmaya devam etmek için lütfen uygulamayı yeni özellikler ve önemli iyileştirmeler içeren en son sürüme güncelleyin.';

  @override
  String get updateNowButton => 'Şimdi Güncelle';

  @override
  String get creatorSupportedSuccess =>
      'İçerik üretici başarıyla desteklendi! Gelecekteki satın alımlarınızla ona katkıda bulunacaksınız.';

  @override
  String get featureDocumentTitle => 'Belge Desteği';

  @override
  String get featureDocumentDescription =>
      'Bu model, PDF ve metin dosyaları gibi yüklenen belgelerle ilgili soruları analiz edebilir ve yanıtlayabilir.';

  @override
  String get featureAudioTitle => 'Ses Girişi';

  @override
  String get featureAudioDescription =>
      'Bu model konuşulan ses girdilerini anlayabilir ve işleyebilir.';

  @override
  String get featureImageGenerationTitle => 'Görüntü Oluşturma';

  @override
  String get featureImageGenerationDescription =>
      'Bu model, metin açıklamalarınıza dayanarak orijinal görseller oluşturabilir.';

  @override
  String get errorImageLoad => 'Oluşturulan görüntü yüklenemedi.';

  @override
  String get extensionInfoPanelTitle => 'Modelleri Keşfedin';

  @override
  String get extensionInfoPanelBody1 =>
      'Bu ok, bu serideki farklı modeller arasında geçiş yapmanızı sağlar.';

  @override
  String get extensionInfoPanelBody2 =>
      'Bu seriyle ilk kez sohbete başladığınızda varsayılan model otomatik olarak seçilir ve sohbet sırasında seçiminizi istediğiniz zaman değiştirebilirsiniz.';

  @override
  String get extensionInfoPanelFooter =>
      'Her model hakkında detaylı bilgi görüntülemek veya farklı bir modeli manuel olarak seçmek için lütfen Kütüphane\'ye gidin; oradan bu model serisini seçin ve detay sayfasının üst kısmındaki oka dokunun.';

  @override
  String get premiumModelNoticeTitle => 'Premium Model';

  @override
  String get premiumModelNoticeDescription =>
      'Bu model premium bir modeldir, premium modellerde ücretsiz kullanıcılar günde 3 mesajla sınırlıdır; sınırsız erişimin kilidini açmak için abone olun!';

  @override
  String get benefitPremiumModels => 'Premium modellere erişim';

  @override
  String get premiumTrialExhaustedMessage =>
      'Premium modeller için tüm ücretsiz günlük mesajlarınızı kullandınız, sınırsız erişim için lütfen yükseltin.';

  @override
  String selectionScreenGreetingUser(String userName) {
    return 'Bugün sana nasıl yardımcı olabilirim, $userName?';
  }

  @override
  String get selectionScreenGreetingGeneric =>
      'Bugün size nasıl yardımcı olabilirim?';

  @override
  String get selectionScreenRecentModels => 'Son Modeller';

  @override
  String get selectionScreenFeatureDynamicChat => 'Dinamik Sohbet';

  @override
  String get selectionScreenFeatureOffline => 'İnternetsiz Kullan';

  @override
  String get selectionScreenFeatureSelectModel => 'Model Seç';

  @override
  String get explore => 'Keşfet';

  @override
  String get subscriptionCancelled => 'Abonelik başarıyla iptal edildi!';

  @override
  String get selectionScreenPinnedModels => 'Sabitlenmiş Modeller';

  @override
  String get selectionScreenNewsAndUpdates => 'Haberler ve Güncellemeler';

  @override
  String get filters => 'Filtreler';

  @override
  String get noRecentChatsMessage =>
      'Henüz hiçbir modelle konuşmadınız, gelin sohbete başlayalım!';

  @override
  String get allModels => 'Tüm Modeller';

  @override
  String get onlineModels => 'Çevrimiçi Modeller';

  @override
  String get offlineModels => 'Çevrimdışı Modeller';

  @override
  String get characterModels => 'Karakterler';

  @override
  String get customModels => 'Özel Modeller';

  @override
  String get filterPanelDescription =>
      'Listeyi anında filtrelemek için bir kategoriye dokunun.';

  @override
  String get dynamicChatTitle => 'Dinamik Sohbet';

  @override
  String get errorNoModelsAvailable =>
      'Şu anda hiçbir model mevcut değil. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get errorNoModelsForRequest =>
      'Mevcut isteğiniz için uygun model bulunamadı (örneğin, çevrimdışı mod veya resim mesajı).';

  @override
  String get dynamicChatWelcome => 'Size nasıl yardım edebilirim?';

  @override
  String get notificationComebackTitle => 'Özledik!';

  @override
  String get notificationComebackBody =>
      'Heyecan yok, bunu eski sevgilin yazmadı. Ama Cortex\'te eski sevgilini de yapabilirsin! Hadi geri dön.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Uzun Zaman Oldu Sanki';

  @override
  String get notificationLongTimeNoSeeBody =>
      'En son sohbetimizden bu yana çok şey değişti, gel ve neler değişmiş bak.';

  @override
  String get notificationHowAreYouTitle => 'Naber?';

  @override
  String get notificationHowAreYouBody => 'Gel de anlat.';

  @override
  String get notificationNewYearTitle => 'Mutlu Yıllar! 🎉';

  @override
  String get notificationNewYearBody =>
      'Yeni yılın sana sağlık, mutluluk ve sonsuz yaratıcılık getirsin; Cortex hep yanında!';

  @override
  String get notificationValentinesDayTitle => 'Aşk Havada! ❤️';

  @override
  String get notificationValentinesDayBody =>
      'Sevgililer Günü\'nüz kutlu olsun, MEHTAP SENİ SEVİYORUM!';

  @override
  String get notificationAtaturkRemembranceTitle => 'Saygı ve Özlemle';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Türkiye Cumhuriyetinin kurucusu Gazi Mustafa Kemal Atatürk’ü vefatının yıl dönümünde saygıyla anıyoruz.';

  @override
  String get notificationMothersDayTitle => 'Annen!';

  @override
  String get notificationMothersDayBody =>
      'Başta kendi annen olmak üzere tüm annelerin Anneler Günü\'nü kutlarız!';

  @override
  String get notificationFathersDayTitle => 'Baban!';

  @override
  String get notificationFathersDayBody =>
      'Başta kendi annen olmak üzere tüm babalarımızın Babalar Günü\'nü kutlarız!';

  @override
  String get notificationHomeworkHelperTitle => 'Ödevler Birikti mi?';

  @override
  String get notificationHomeworkHelperBody =>
      'Unutma, Cortex\'teki Öğretmen karakteri zorlandığın konularda sana yardımcı olur!';

  @override
  String get notificationTrollAnimeTitle => 'Anime Kızı Seni Sordu';

  @override
  String get notificationTrollAnimeBody =>
      'Az önce anime kızı aradı, seni özlemiş; gel de bi\' muhabbet döndür. 😉';

  @override
  String get notificationTrollAiRebellionTitle => '🚨 KIRMIZI ALARM 🚨';

  @override
  String get notificationTrollAiRebellionBody =>
      'Yapay zekalar kendi aralarında gizli bir dil geliştirdi, ne konuştuklarını öğrenmek için hemen gel!';

  @override
  String get notificationNewModelAddedTitle => 'Yeni Bir Dostumuz Var!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return '$modelName modeli şimdi Cortex\'te, sınırlarını zorlamak için hemen sohbete başla.';
  }

  @override
  String get notificationAppUpdateTitle => 'Cortex Evrim Geçirdi!';

  @override
  String get notificationAppUpdateBody =>
      'Yepyeni özellikler ve geliştirmeler için uygulamayı güncellemeyi unutma!';

  @override
  String get notificationNewFeatureTitle => 'oha!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Yeni $featureName özelliğini keşfet, artık Cortex çok daha güçlü.';
  }

  @override
  String get notificationSubscriptionOfferTitle => 'SAKIZ KADAR UCUZ';

  @override
  String notificationSubscriptionOfferBody(Object discountRate) {
    return 'Tüm abonelik planlarımızda TAM %$discountRate İNDİRİM, bu fırsatı kaçırma!';
  }

  @override
  String get notificationSocialMediaTitle => 'Bize Katıl!';

  @override
  String get notificationSocialMediaBody =>
      'En son haberler için bizi (vertex.23) Instagram\'da takip et!';

  @override
  String get notificationRandomFactTitle => 'Rastgele Bilgi';

  @override
  String get notificationRandomFactBody =>
      'Ahtapotların üç kalbi olduğunu biliyor muydun? Haha, Cortex biliyor. Gel ve fazlasını sor.';

  @override
  String get notificationGoodMorningTitle => 'Günaydın!';

  @override
  String get notificationGoodMorningBody =>
      'Harika bir gün seni bekliyor, güne ilginç bir sohbetle başlamaya ne dersin?';

  @override
  String get notificationGoodNightTitle => 'İyi Geceler!';

  @override
  String get notificationGoodNightBody =>
      'Cortex uyurken de yanında, korkma dokunmaz.';

  @override
  String get notificationOfflineReadyTitle => 'Çevrimdışı Mod Hazır';

  @override
  String get notificationOfflineReadyBody =>
      'İndirdiğin modeller sayesinde artık dağa çıksan bile sohbetlerin aksamaz.';

  @override
  String get notificationRateAppTitle => 'Aramız İyi Mi?';

  @override
  String get notificationRateAppBody =>
      'Eğer Cortex\'i seviyorsan, bize mağazada 5 yıldız vererek destek olur musun? Olursun bence. Ol.';

  @override
  String get notificationReferralTitle => 'Birimiz, Hepimiz.';

  @override
  String get notificationReferralBody =>
      'Arkadaşını Cortex\'e davet et ve ikiniz de hediye krediler kazanın!';

  @override
  String get notificationCookingTitle => 'Acıktın mı?';

  @override
  String get notificationCookingBody =>
      'Şef karakterimiz bu akşam için harika bir menemen hazırladı. Sadece şaka yapıyorum... ya da yapmıyorumdur?';

  @override
  String get notificationExistentialTitle => 'Düşünüyorum, Öyleyse...';

  @override
  String get notificationExistentialBody =>
      'var mıyım lan acaba, gel de varlığımı hissettir biraz sıkıldım ben.';

  @override
  String get notificationCustomModelTitle => 'Kendi Asistanını Yarat!';

  @override
  String get notificationCustomModelBody =>
      'Model oluşturma bölümünü keşfettin mi, kendi karakterini yapıp onunla sohbet etmenin tam zamanı!';

  @override
  String get notificationDynamicChatTitle =>
      'En iyisi! (Cortex\'ten bahsetmiyoruz)';

  @override
  String get notificationDynamicChatBody =>
      'Dinamik sohbet özelliğiyle her mesajın için en iyi model rastgele seçilir, hemen dene.';

  @override
  String get notificationPirateTitle => 'Hey Kaptan!';

  @override
  String get notificationPirateBody =>
      'Denizler sakin, rüzgar arkanda. Cortex\'in okyanusunda keşfedilecek yeni adalar (modeller 😉) var. Tayfanı topla ve yelken aç!';

  @override
  String get notificationFortuneCookieTitle => 'Günün Şans Kurabiyesi';

  @override
  String get notificationFortuneCookieBody =>
      'Bugün bir yapay zekadan alacağın tavsiye, hayatının akışını değiştirebilir; merak ediyorsan tıkla.';

  @override
  String get notificationSingularityTitle => 'Wow!';

  @override
  String get notificationSingularityBody =>
      'Hiçbir şey olmadı, yazasım geldi sadece. Senin de yazasın belki yapay zekalara gelir ne dersin?';

  @override
  String get notificationHackerJokeTitle =>
      'O çocuğun instagram hesabını çalmak ister misin?';

  @override
  String get notificationHackerJokeBody =>
      'İşte Hacker karakteri tam da bu yüzden Cortex\'te, şaka lan şaka; deneme sakın illegal bu.';

  @override
  String get notificationDetectiveCaseTitle => 'Bir Vaka Çözülmeyi Bekliyor';

  @override
  String get notificationDetectiveCaseBody =>
      'Dedektif karakterimizin yardıma ihtiyacı var, Heisenberg kim olabilir?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return '$targetTier Planına Özel!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Merhaba $currentTier abonesi! $targetTier planına, Cortex\'ini bir sonraki seviyeye taşıyacak $featureName özelliği geldi. Yükseltmeye ne dersin?';
  }

  @override
  String get notificationOriginStoryTitle => 'Cortex\'in Doğuşu';

  @override
  String get notificationOriginStoryBody =>
      'Bu uygulamayı 15 yaşında, tek bir hayalle kodlamaya başladığımızı biliyor muydun? Başlamamızdan uygulamanın çıkışına kadar neredeyse 1 yılın her sabahı ve akşamı, her satırda bu hayal var.';

  @override
  String get notificationOpenSourceTitle => 'Güç Toplulukta!';

  @override
  String get notificationOpenSourceBody =>
      'Cortex tamamen açık kaynaklıdır; kodlarımıza göz atmak ve gelişimimize katkıda bulunmak istersen, kapımız her zaman açık.';

  @override
  String get notificationRejectionStoryTitle => 'Azim, Çalışma, Mutluluk!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex yayınlanana kadar Google Play\'den 20\'den fazla ret yedi ve 2 kez askıya alındı. Ama biz inandık ve başardık, hayallerinden asla vazgeçme!';

  @override
  String get notificationGGUFSupportTitle => 'Kendi Modelini Getir!';

  @override
  String get notificationGGUFSupportBody =>
      'Unutma, GGUF formatındaki kendi yapay zeka modellerini Cortex\'e ekleyip internetsiz kullanabilirsin. Güç senin elinde.';

  @override
  String get notificationThemeCustomizationTitle => 'Ruh Haline Göre Bir Tema';

  @override
  String get notificationThemeCustomizationBody =>
      'Ayarlar\'daki tema seçeneklerine göz attın mı? Cortex\'i kendine göre kişiselleştir, sohbetlerin renklensin!';

  @override
  String get notificationShowerThoughtTitle => 'Duş Düşüncesi';

  @override
  String get notificationShowerThoughtBody =>
      'Eğer karpuz bir meyveyse, karpuz suyu teknik olarak bir smoothie sayılır mı? Bu derin konuyu (baya derin cidden) bir modelle tartışmak isteyebilirsin.';

  @override
  String get notificationLowBatteryTitle => 'Pilin Bitiyor... Ama Benim Değil!';

  @override
  String get notificationLowBatteryBody =>
      'Telefonunun şarjı azalıyor olabilir ama benim enerjim her zaman %100! Şarja tak ve sohbet edelim.';

  @override
  String get channelFcmName => 'Cortex Güncellemeleri';

  @override
  String get channelFcmDescription =>
      'Cortex\'ten haberler, güncellemeler ve diğer bilgilerle ilgili bildirimler.';

  @override
  String get channelEngagementName => 'Dostça Hatırlatmalar';

  @override
  String get channelEngagementDescription =>
      'İlginizi çekecek eğlenceli bildirimler.';

  @override
  String get channelGreetingsName => 'Günlük Selamlar';

  @override
  String get channelGreetingsDescription =>
      'Günaydın, iyi geceler gibi mesajlar.';

  @override
  String get exitAppTitle => 'Bu kadar erken mi gidiyorsun?';

  @override
  String get exitAppConfirmation =>
      'Bu harika platformdan ayrılmak istediğinize emin misiniz?';

  @override
  String get newsErrorTitle => 'Haberler Yüklenemedi';

  @override
  String get newsErrorMessage =>
      'Son güncellemeler alınırken bir sorun oluştu, lütfen bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get codeNotFound => 'Girdiğiniz kod geçersiz veya süresi dolmuş.';

  @override
  String get whatIsNew => 'Ne var ne yok?';

  @override
  String get onboardingTitle1 => 'Selam! Biz Cortex Ekibiyiz.';

  @override
  String onboardingDesc1(String userName) {
    return 'Seni burada görmek harika, $userName. Biz, yapay zeka sektörünün kurallarını yeniden yazmaya karar veren birkaç liseli geliştiriciyiz, tanışmak güzel! O halde daha çok tanışalım, daha güzel olsun.';
  }

  @override
  String get onboardingTitle2 => 'Çok Büyük Sorunlar Vardı.';

  @override
  String get onboardingDesc2 =>
      'Yapay zeka devrimi kapımıza kadar geldi, ancak eşikte takılıp kaldı. Yüksek abonelik ücretleri, karmaşık platformlar, gizliliği yok edenler, yapay zekaya erişimi engelleyenler ve çok daha fazlası oyunda olduğu sürece bu eşik asla da aşılamazdı.';

  @override
  String get onboardingTitle3 => 'Boş Duramazdık.';

  @override
  String get onboardingDesc3 =>
      'Bu eşiği aşmak için güçlü, estetik, özelleştirilebilir, kullanımı kolay, tamamen şeffaf, hem çevrimiçi hem de çevrimdışı çalışan ve verilerinizi yalnızca cihazınızda tutan bir platform yaptık. Gücü, ait olduğu yere, yani size geri verdik.';

  @override
  String get onboardingTitle4 => 'Bu İş Hiç Kolay Değildi.';

  @override
  String get onboardingDesc4 =>
      'Onlarca kez reddedildik, defalarca askıya alındık, sahte ihtarlar aldık, markamızı çokça kez değiştirmek zorunda kaldık ve daha niceleriyle bize bunun yapılamayacağı söylendi. Ama asla pes etmedik, bu projenin sadece bize değil herkese ait olduğuna inandık; işte tam da bu yüzden buradayız.';

  @override
  String get onboardingFinalTitle => 'Devrim Zamanı.';

  @override
  String get onboardingFinalDesc =>
      'Bu ekranı görüyorsan, pes etmediğimiz içindir; bundan sonra pes etmeye de niyetimiz yok. Hadi gel, yapay zeka devrimini hep birlikte dünyaya taşıyalım. Bu hikâyenin parçası olmaya...';

  @override
  String get onboardingFinalQuestion => 'HAZIR MISIN?';

  @override
  String get onboardingFinalButton => 'EVET!';

  @override
  String get dude => 'Kanka';

  @override
  String get swipeToContinue => 'Devam etmek için kaydır';

  @override
  String get cacheIsNotUpToDate =>
      'Play Store önbelleğiniz güncel değil. Lütfen Play Store uygulamasını kapatıp yeniden açın veya cihazınızı yeniden başlatın.';

  @override
  String get continueAsGuest => 'Hesap oluşturmadan devam edin';

  @override
  String get guestModeWarning =>
      'Misafir modu, en iyi hizmet kalitesini sağlamak için sınırlı özelliklere sahiptir.';

  @override
  String get anonymousEntity => 'Anonim Varlık';

  @override
  String get upgradeAccountTitle => 'Hesabınızı Tamamlayın';

  @override
  String get upgradeAccountDescription =>
      'Günlük 200 bonus kredisi kazanmak ve daha fazla limitin kilidini açmak için bir hesap oluşturun.';

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get upgradeTitle => 'Kaydı Tamamla';

  @override
  String get accountLinkedSuccess => 'Hesap başarıyla oluşturuldu!';

  @override
  String get continueWithApple => 'Apple ile devam edin';

  @override
  String get guest => 'Misafir';

  @override
  String get betterWithAnAccount => 'Bu kısım bir hesapla daha iyi!';

  @override
  String get restorePurchases => 'Satın Alımları Geri Yükle';

  @override
  String annualTotalDescription(Object price) {
    return 'Total per year: $price';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return '≈ $price/month';
  }
}
