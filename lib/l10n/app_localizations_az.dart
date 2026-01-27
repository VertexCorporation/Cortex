// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class AppLocalizationsAz extends AppLocalizations {
  AppLocalizationsAz([String locale = 'az']) : super(locale);

  @override
  String get cancel => 'Ləğv et';

  @override
  String get remove => 'Sil';

  @override
  String get download => 'Yüklə';

  @override
  String get resume => 'Davam etdir';

  @override
  String get copy => 'Kopyala';

  @override
  String get chat => 'Söhbət';

  @override
  String get light => 'İşıqlı';

  @override
  String get theme => 'Mövzu';

  @override
  String get no => 'Xeyr';

  @override
  String get yes => 'Bəli';

  @override
  String get done => 'Hazırdır';

  @override
  String get bestValue => 'Ən Yaxşı Dəyər';

  @override
  String get selected => 'Seçildi';

  @override
  String get descriptionSection => 'Təsvir';

  @override
  String get searchHint => 'Axtarış';

  @override
  String get messageHint => 'Hər şeyi soruş';

  @override
  String get messageCopied => 'Mesaj mübadilə buferinə kopyalandı.';

  @override
  String get retry => 'Yenidən cəhd et';

  @override
  String get systemInfo => 'Sistem Məlumatı';

  @override
  String deviceMemory(Object memory) {
    return 'Cihaz Yaddaşı: $memory GB';
  }

  @override
  String get memory => 'Yaddaş';

  @override
  String get storage => 'Depolama';

  @override
  String get freeStorage => 'Boş Sahə';

  @override
  String get totalStorage => 'Ümumi Sahə';

  @override
  String get usedStorage => 'İstifadə Edilən Sahə';

  @override
  String get totalMemory => 'Ümumi Yaddaş';

  @override
  String get usedMemory => 'İstifadə Edilən Yaddaş';

  @override
  String get modelsTitle => 'Kitabxana';

  @override
  String get localModels => 'Lokal Modellər';

  @override
  String get serverSideModels => 'Onlayn Modellər';

  @override
  String get selectGGUFFile => 'GGUF Faylı seçin';

  @override
  String get errorGGUF =>
      'Zəhmət olmasa, yalnız GGUF formatında bir fayl seçin.';

  @override
  String get myModels => 'Modellərim';

  @override
  String get create => 'Yarat';

  @override
  String modelProducer(Object producer) {
    return 'İstehsalçı: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'Adını dəyiş';

  @override
  String get newTitle => 'Yeni Başlıq';

  @override
  String get save => 'Yadda saxla';

  @override
  String get noConversationsMessage => 'Söhbət yoxdur, söhbətə başlayın!';

  @override
  String get startChat => 'Söhbətə başla';

  @override
  String get noChats => 'Söhbət Yoxdur';

  @override
  String get noStarredChats => 'Ulduzlu Söhbət Yoxdur';

  @override
  String get noStarredChatsMessage => 'Hələ heç bir söhbəti ulduzlamamısınız.';

  @override
  String get starConversation => 'Ulduzla';

  @override
  String get unstarConversation => 'Ulduzdan silin';

  @override
  String get loginToYourAccount => 'Daxil ol';

  @override
  String get createYourAccount => 'Qeydiyyatdan keç';

  @override
  String get email => 'E-poçt';

  @override
  String get password => 'Şifrə';

  @override
  String get confirmPassword => 'Şifrəni təsdiqlə';

  @override
  String get invalidEmail =>
      'Zəhmət olmasa, etibarlı bir e-poçt ünvanı daxil edin.';

  @override
  String get invalidPassword => 'Şifrə ən azı 6 simvoldan ibarət olmalıdır.';

  @override
  String get rememberMe => 'Məni xatırla';

  @override
  String get forgotPassword => 'Şifrəni unutmusunuz?';

  @override
  String get or => 'Və ya';

  @override
  String get continueWithGoogle => 'Google ilə davam et';

  @override
  String get dontHaveAccount => 'Hesabınız yoxdur?';

  @override
  String get alreadyHaveAccount => 'Artıq hesabınız var?';

  @override
  String get signUp => 'Qeydiyyatdan keç';

  @override
  String get logIn => 'Daxil ol';

  @override
  String get passwordsDoNotMatch => 'Şifrələr uyğun deyil.';

  @override
  String get wrongPassword => 'Yanlış şifrə.';

  @override
  String get emailAlreadyInUse => 'Bu e-poçt artıq istifadə olunur.';

  @override
  String get weakPassword => 'Şifrə çox zəifdir.';

  @override
  String get authError => 'Doğrulama Xətası';

  @override
  String get usernameTaken => 'Bu istifadəçi adı artıq tutulub.';

  @override
  String get username => 'İstifadəçi adı';

  @override
  String get resendCode => 'Təsdiq e-poçtunu yenidən göndər';

  @override
  String get pleaseCheckYourEmail =>
      'Cortex-dən istifadə etmək üçün e-poçtunuzu təsdiqləməlisiniz. \nE-poçt ünvanınıza bir təsdiq linki göndərildi, zəhmət olmasa e-poçtunuzu yoxlayın.';

  @override
  String get verifyYourEmail => 'E-poçtunuzu təsdiqləyin';

  @override
  String get seconds => 'saniyə';

  @override
  String get maxResendLimitReached => 'Maksimum təsdiq e-poçtu sayına çatdınız';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Təsdiq etmədən davam et';

  @override
  String get verificationScreenWarning =>
      'Davam etsəniz belə, 1 günlük hesab təsdiqləmə müddəti hesabınız üçün hələ də qüvvədədir. O vaxta qədər hesabınızı təsdiqləməsəniz, tətbiqdən silinəcək.';

  @override
  String get unverifiedAccountHeader => 'Hesabınız təsdiqlənməyib';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Hesabınızı $timeLeft ərzində təsdiqləməsəniz, silinəcək';
  }

  @override
  String get verifyNow => 'İndi təsdiqlə';

  @override
  String get linkSent => 'Link göndərildi';

  @override
  String get accountDeletionRequested =>
      'Hesabınızın silinməsi tələbi qəbul edildi və hesabınız indi deaktiv edilib.';

  @override
  String get tooManyRequests => 'Həddindən artıq sorğu';

  @override
  String get regenerate => 'Yenidən yarat';

  @override
  String get confirmDeleteAccount =>
      'Hesabınızı silmək istədiyinizə əminsinizmi?';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get delete => 'Sil';

  @override
  String get passwordRequired => 'Şifrə tələb olunur.';

  @override
  String get deleteDescription =>
      'Sildiyiniz məlumatlar serverimizdən və cihazınızdan qalıcı olaraq silinəcək. Bu əməliyyatlar geri qaytarıla bilməz.';

  @override
  String get deleteAccountButton => 'Hesab Silmə Düyməsi';

  @override
  String get editProfile => 'Profili Redaktə et';

  @override
  String get displayName => 'Görünən Ad';

  @override
  String get profileUpdated => 'Profil uğurla yeniləndi';

  @override
  String get logout => 'Çıxış';

  @override
  String get profile => 'Profil';

  @override
  String get manageProfileDescription =>
      'Profilinizi idarə edin, şifrənizi yeniləyin və ya Cortex-dən çıxış edin.';

  @override
  String get accessSettingsDescription =>
      'Yardıma daxil olun, kodları aktivləşdirin, Cortex-i paylaşın və siyasətlərimizə baxın.';

  @override
  String get languageDescription =>
      'İstənilən vaxt standart tətbiq interfeys dilinizi dəyişə bilərsiniz.';

  @override
  String get themeDescription =>
      'İstəyinizə uyğun olaraq işıqlı və qaranlıq mövzular arasında keçid edə bilərsiniz. Seçilmiş mövzu bütün Cortex interfeysində tətbiq olunacaq.';

  @override
  String get iHaveReadAndAgree => 'Xidmət şərtlərini oxudum və qəbul edirəm';

  @override
  String get downloading => 'Yüklənir...';

  @override
  String get downloadSuccess => 'Yükləmə uğurlu oldu';

  @override
  String get downloadFailed => 'Yükləmə uğursuz oldu';

  @override
  String downloaded(Object percent) {
    return '$percent% yükləndi';
  }

  @override
  String get downloadPaused => 'Yükləmə dayandırıldı.';

  @override
  String get purchaseSuccessful => 'Alış uğurlu oldu!';

  @override
  String get purchaseError => 'Alış xətası';

  @override
  String get purchasePlus => 'Cortex Plus al';

  @override
  String get plusDescription => 'Elit Süni İntellekt Təcrübəsi';

  @override
  String get annual => 'İllik';

  @override
  String get monthly => 'Aylıq';

  @override
  String get manageSubscription => 'Abunəliyi İdarə et';

  @override
  String purchasePlan(String planName) {
    return '$planName al';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/ay, aylıq ödəniş edilir';
  }

  @override
  String get purchasePro => 'Cortex Pro al';

  @override
  String get proDescription => 'Premyer Süni İntellekt Təcrübəsi';

  @override
  String get purchaseUltra => 'Cortex Ultra al';

  @override
  String get ultraDescription => 'Süni intellektin zirvəsi';

  @override
  String get upgradeSubscription => 'Abunəliyi Yüksəlt';

  @override
  String get purchaseStreamError => 'Alış axını xətası.';

  @override
  String get productNotFound => 'Məhsul tapılmadı';

  @override
  String get noProductsFound => 'Heç bir məhsul tapılmadı';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Bu sifarişi yerləşdirməklə, Xidmət Şərtləri və Məxfilik Siyasəti ilə razılaşırsınız. Xidmət Şərtlərimiz və Məxfilik Siyasətimiz haqqında daha çox məlumat əldə etmək üçün bu mətnə klikləyə bilərsiniz. Cari dövrün bitməsindən ən azı 24 saat əvvəl avtomatik yeniləmə söndürülmədikcə, abunəlik avtomatik olaraq yenilənəcək.';

  @override
  String get termsOfService => 'Xidmət Şərtləri';

  @override
  String get privacyPolicy => 'Məxfilik Siyasəti';

  @override
  String get report => 'Şikayət et';

  @override
  String get reportDialogTitle => 'Şikayət Göndər';

  @override
  String get reportDescriptionLabel => 'Problem nədir?';

  @override
  String get reportHarmful => 'Bu zərərli/təhlükəlidir';

  @override
  String get reportNotTrue => 'Bu doğru deyil';

  @override
  String get reportNotHelpful => 'Bu faydalı deyil';

  @override
  String get closeButton => 'Bağla';

  @override
  String get submitButton => 'Göndər';

  @override
  String get reportErrorMessage =>
      'Zəhmət olmasa, şikayət üçün bir səbəb seçin.';

  @override
  String get capabilitiesSection => 'Bacarıqlar';

  @override
  String get featurePhotoTitle => 'Foto Skan';

  @override
  String get featurePhotoDescription =>
      'Bu model kamera və ya şəkil faylları vasitəsilə fotoları skan etmək qabiliyyətinə malikdir.';

  @override
  String get featureOfflineTitle => 'Oflayn Əməliyyat';

  @override
  String get featureOfflineDescription =>
      'Məlumatlarınızı təhlükəsiz saxlamaq üçün modeli internet bağlantısı olmadan işlədin.';

  @override
  String get featureRoleplayTitle => 'Rol Oyunu';

  @override
  String get featureRoleplayDescription =>
      'Rol oyunu modelləri müxtəlif söhbətlər və ssenarilər yaratmağınıza imkan verir.';

  @override
  String get roleModels => 'Rol Oyunu Modelləri';

  @override
  String get parameters => 'Parametrlər';

  @override
  String get context => 'Kontekst';

  @override
  String get finalPreparation => 'Son hazırlıqlar görülür.';

  @override
  String get shareApp => 'Tətbiqi Paylaş';

  @override
  String get rateUs => 'Bizi Qiymətləndir';

  @override
  String get share => 'Paylaş';

  @override
  String get shareSubject => 'Cortex';

  @override
  String shareMessage(String cortexLink) {
    return 'Cortex tətbiqinə bax, çox heyrətamizdir! Buradan yükləyin: $cortexLink';
  }

  @override
  String get shareFailed =>
      'Tətbiqi paylaşmaq mümkün olmadı. Zəhmət olmasa, daha sonra yenidən cəhd edin';

  @override
  String get selectText => 'Mətni Seç';

  @override
  String get thinking => 'Düşünür';

  @override
  String get user => 'İstifadəçi';

  @override
  String get help => 'Yardım';

  @override
  String get supportCreator => 'Yaradanı dəstəkləyin';

  @override
  String get enterYourTag =>
      'Sevimli yaradıcılarınızı dəstəkləyin! Cortex alışlarınızdan onlara pay vermək üçün aşağıya onların unikal etiketini daxil edin.';

  @override
  String get creatorTag => 'Yaradıcı etiketi';

  @override
  String get support => 'Dəstəklə';

  @override
  String get tagCannotBeEmpty => 'Yaradıcı teqi boş ola bilməz';

  @override
  String get userId => 'İstifadəçi ID';

  @override
  String get deleteAllConversationsConfirmTitle => 'Bütün Söhbətlər Silinsin?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Bütün söhbətlərinizi silmək istədiyinizə əminsinizmi? Bu əməliyyat geri qaytarıla bilməz.';

  @override
  String get conversationDeleted => 'Söhbət silindi!';

  @override
  String get allConversationsDeleted => 'Bütün söhbətlər uğurla silindi!';

  @override
  String get deleteAll => 'Hamısını Sil';

  @override
  String get deleteAllConversationsButton => 'Bütün Söhbətləri Sil';

  @override
  String get confirmWord => 'VERTEX yazın';

  @override
  String get confirmWordError => 'Səhv yazdınız';

  @override
  String get chinese => 'Çin dili';

  @override
  String get french => 'Fransız dili';

  @override
  String get japanese => 'Yapon dili';

  @override
  String get kurdish => 'Kürd dili';

  @override
  String get dutch => 'Holland dili';

  @override
  String get russian => 'Rus dili';

  @override
  String get korean => 'Koreya dili';

  @override
  String get english => 'İngilis dili';

  @override
  String get turkish => 'Türk dili';

  @override
  String get hindi => 'Hind dili';

  @override
  String get portuguese => 'Portuqal dili';

  @override
  String get indonesian => 'İndoneziya dili';

  @override
  String get azerbaijani => 'Azərbaycan dili';

  @override
  String get german => 'Alman dili';

  @override
  String get spanish => 'İspan dili';

  @override
  String get italian => 'İtalyan dili';

  @override
  String get arabic => 'Ərəb';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'İstifadəçi adı çox qısadır.';

  @override
  String get usernameTooLong => 'İstifadəçi adı 16 simvolu keçə bilməz.';

  @override
  String get invalidUsernameCharacters =>
      'İstifadəçi adında yalnız bu hərflər: \'abcçdefgğhıijklmnoöprsştuüvyzxqw\' və \'.\', \'-\', \'_\' simvolları istifadə edilə bilər.';

  @override
  String get noInternetConnection => 'İnternet bağlantısı yoxdur.';

  @override
  String get chats => 'Gələnlər';

  @override
  String get library => 'Kitabxana';

  @override
  String get text => 'Mətn';

  @override
  String get removeModel => 'Modeli Sil';

  @override
  String get insufficientRAM => 'Aşağı Yaddaş';

  @override
  String get insufficientStorage => 'Aşağı Depolama';

  @override
  String confirmRemoveModel(Object model) {
    return 'Cihazınızdan $model modelini silmək istədiyinizə əminsiniz? Bunu etmək həmin modellə əvvəlki söhbətləri də siləcək.';
  }

  @override
  String get noMatchingModels => 'Uyğun model tapılmadı.';

  @override
  String get benefit1 => 'Artan söhbət limitləri';

  @override
  String get benefit3 => 'Profil effekti';

  @override
  String get benefit4 => 'Üzvlük nişanı';

  @override
  String get benefit5 => 'Daha çox onlayn süni intellekt yaradın';

  @override
  String get benefit7 => 'Daha çox istifadə limitləri';

  @override
  String get benefit8 => 'Modellər əlavə edin';

  @override
  String get benefit9 => 'Yeni mövzular';

  @override
  String get benefit10 => 'Daha çox əlavə';

  @override
  String get benefit11 => 'Daha çox Axın Rejimi';

  @override
  String get benefit12 => '';

  @override
  String get oldBenefits => 'Aşağı planların bütün üstünlükləri';

  @override
  String get confirm => 'Təsdiqlə';

  @override
  String get changePassword => 'Şifrəni dəyiş';

  @override
  String get logoutConfirmationTitle => 'Çıxış etmək istədiyinizə əminsinizmi?';

  @override
  String get settings => 'Ayarlar';

  @override
  String get language => 'Tətbiq Dili';

  @override
  String get dark => 'Qaranlıq';

  @override
  String get oldPassword => 'Köhnə Şifrə';

  @override
  String get newPassword => 'Yeni Şifrə';

  @override
  String get passwordUpdated => 'Şifrə yeniləndi.';

  @override
  String get stop => 'Dayandır';

  @override
  String get copyrights => 'İstinadlar';

  @override
  String get love => 'Sevgi';

  @override
  String get nature => 'Təbiət';

  @override
  String get behindTheSlaughter => 'Qətlin Pərdə Arxası';

  @override
  String get grayscale => 'Boz Tonlar';

  @override
  String get ocean => 'Okean';

  @override
  String get scarletSnow => 'Al Qırmızı Qar';

  @override
  String get requestFailed =>
      'Xəta baş verdi, zəhmət olmasa yenidən cəhd edin.';

  @override
  String get changeModel => 'Dəyişdir';

  @override
  String get edit => 'Redaktə et';

  @override
  String get editingMessageInfo =>
      'Bu mesajı redaktə etmək söhbəti buradan yenidən başladacaq.';

  @override
  String get editingNotification => 'Siz indi redaktə rejimindəsiniz';

  @override
  String get featurePluralTitle => 'Çoxşaxəli';

  @override
  String get featurePluralDescription =>
      'Bu model avtomatik olaraq əlavə genişləndirmələri inteqrasiya edə bilir, bununla da funksional imkanlarını artıraraq müxtəlif əməliyyatları daha yüksək performansla dəstəkləyir.';

  @override
  String get nameLabel => 'Sİ adı';

  @override
  String get summaryLabel => 'Sİ Xülasəsi';

  @override
  String get add => 'Əlavə et';

  @override
  String get aiExplanationTitle => 'Süni İntellekt Təsviri';

  @override
  String get aiExplanationDescription =>
      'Zəhmət olmasa, süni intellekt modelinizin arxitekturası, təlim prosesi, performans göstəriciləri, tətbiq sahələri və digər vacib xüsusiyyətləri haqqında ətraflı məlumat verin.';

  @override
  String get preInputTitle => 'Süni İntellekt İlkin Girişi';

  @override
  String get preInputDescription =>
      'Zəhmət olmasa, modelinizi xarakter yaratma prosesində istiqamətləndirəcək bir ilkin giriş təyin edin. Bu bölmədə, xarakterlə bağlı məlumatları, əlavə konteksti və xarakterlə bağlı məzmunun yaradılmasına kömək edə biləcək hər hansı əlavə detalları daxil edə bilərsiniz.';

  @override
  String get baseModelTitle => 'Əsas Model';

  @override
  String get baseModelDescription =>
      'Bu, yaratdığınız işin əsası kimi istifadə ediləcək modeldir. Hazırda seçilmiş əsas modeli göstərir.';

  @override
  String get summary => 'Xülasə';

  @override
  String get modelUploadTitle => 'Süni İntellekt Faylı';

  @override
  String get modelUploadDescription =>
      'Yerli GGUF fayllarınızı birbaşa cihazınızdan seçin və yükləyin. Bu, modelinizi internet bağlantısı olmadan oflayn rejimdə işlətməyə imkan verir. Faylın etibarlı GGUF formatında və düzgün strukturda olduğundan əmin olun. Fayl səhv və ya zədələnmiş olarsa, Cortex gözlənildiyi kimi işləməyə bilər və xətalarla qarşılaşa bilərsiniz.';

  @override
  String get modelUploadShortDescription =>
      'Cihazınızdan bir .gguf faylı seçmək üçün bura toxunun';

  @override
  String get you => 'Sən';

  @override
  String get removePhotoTitle => 'Fotonu Sil';

  @override
  String get confirmRemovePhoto => 'Fotonu silmək istədiyinizə əminsinizmi?';

  @override
  String get chatLengthLimitExceeded =>
      'Bu söhbət simvol limitini keçib. Zəhmət olmasa, yeni bir söhbətə başlayın və ya abunəlik alın.';

  @override
  String get inappropriateContentDetected => 'Uyğun olmayan məzmun aşkarlandı!';

  @override
  String get offlineModelNotInstalled =>
      'Bu oflayn model cihazınızda quraşdırılmayıb.';

  @override
  String get reachedLimit =>
      'İstifadə limitinə çatdın; artırmaq üçün planını yeniləyə bilərsən. (hey, limitin bitməsi pisdir, başa düşürük. amma düzü, o cavabları almaq pulsuz deyil, bu limitlər işlərin əla getməsinə kömək eddiiiir.)';

  @override
  String get modality => 'Modallıq';

  @override
  String get multimodal => 'Çoxmodal';

  @override
  String get anErrorOccurred => 'Xəta Baş Verdi';

  @override
  String get themeLocked =>
      'Bu mövzu daha yüksək abunəlik səviyyəsi tələb edir. Kilidi açmaq üçün lütfən planınızı yüksəldin.';

  @override
  String get pageCouldNotBeLoaded => 'Səhifə Yüklənə Bilmədi';

  @override
  String get checkYourInternet =>
      'Zəhmət olmasa internet bağlantınızı yoxlayın və yenidən cəhd edin.';

  @override
  String get errorUserNotAuthenticated =>
      'Bu əməliyyatı yerinə yetirmək üçün daxil olmalısınız.';

  @override
  String get errorReachedLimit =>
      'Limitinizə çatdınız, daha çox kilidini açmaq üçün təkmilləşdirin və söhbətə davam edin.';

  @override
  String get errorServer =>
      'Gözlənilməz server xətası baş verdi. Zəhmət olmasa daha sonra yenidən cəhd edin.';

  @override
  String get errorNetwork =>
      'Şəbəkə xətası baş verdi. Zəhmət olmasa bağlantınızı yoxlayın və yenidən cəhd edin.';

  @override
  String get errorApiAuthentication =>
      'Doğrulama uğursuz oldu. Zəhmət olmasa yenidən daxil olmağa cəhd edin.';

  @override
  String get baseModelForCharacterDescription =>
      'Seçilmiş əsas model xarakterin mühakimə və cavab vermə qabiliyyətlərini müəyyən edəcək.';

  @override
  String get selectBaseModel => 'Əsas Model Seçin';

  @override
  String get couldNotOpenLink => 'Link açıla bilmədi';

  @override
  String get downloadStarted => 'Yükləmə başladı';

  @override
  String get notAvailable => 'Mövcud Deyil';

  @override
  String get localizationWarning =>
      'Bəzi məlumatlar sizin dilinizdə mövcud olmaya bilər və ingilis dilində göstəriləcək.';

  @override
  String get aiTranslationWarning =>
      'Model məlumatları digər Sİ modelləri tərəfindən müxtəlif dillərə tərcümə edilir. Buna görə də, ingilis dilindən başqa dillərdə kiçik uyğunsuzluqlar ola bilər.';

  @override
  String get errorLoadingTitle => 'Məlumatlar Yüklənə Bilmədi';

  @override
  String get errorLoadingMessage =>
      'Serverlərimizdən lazımi məlumatları ala bilmədik. Zəhmət olmasa internet bağlantınızı yoxlayın və yenidən cəhd edin.';

  @override
  String get noFoundTitle => 'Nəticə Yoxdur';

  @override
  String get noFoundMessage =>
      'Axtarış şərtlərinizi dəyişdirməyə və ya filtri təmizləməyə cəhd edin.';

  @override
  String get modelCreatedSuccess => 'Model uğurla yaradıldı!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '“$modelName” uğurla silindi.';
  }

  @override
  String get errorCreatingModel =>
      'Model yaradılarkən gözlənilməz bir xəta baş verdi.';

  @override
  String get errorDeletingModel =>
      'Model silinərkən gözlənilməz bir xəta baş verdi.';

  @override
  String get ultraFeatureOnly =>
      'Bu xüsusiyyət yalnız Ultra üzvləri üçün mövcuddur.';

  @override
  String get experimentalOfflineWarning =>
      'Oflayn rejim hələ də eksperimental mərhələdədir və yüklədiyiniz model optimal səmərəliliklə işləməyə bilər.';

  @override
  String get noConversationsToDelete => 'Silinəcək söhbətiniz yoxdur.';

  @override
  String get reportSubmitted => 'Şikayət uğurla göndərildi';

  @override
  String get purchaseReceived => 'Alış qəbul edildi, hesabınız yenilənir.';

  @override
  String get verificationDelayed =>
      'Alışınız təsdiqləndi. Hesabınızın yenilənməsində kiçik bir gecikmə var, qısa müddətdə görünəcək.';

  @override
  String get maintenanceTitle => 'Təmir İşləri Gedir';

  @override
  String get maintenanceMessage =>
      'Bəzi vacib yeniləmələri tətbiq edərkən Cortex müvəqqəti olaraq oflayndır. Tətbiqə giriş qısa müddətdə bərpa ediləcək.\n\nTəcrübənizi yaxşılaşdırarkən göstərdiyiniz səbir üçün təşəkkür edirik.';

  @override
  String get errorPromptFlagged =>
      'Mesajınız uyğunsuz olaraq aşkarlandı və göndərilə bilmədi.';

  @override
  String get notEnoughStorage =>
      'Cihazınızda yeni mesajları saxlamaq üçün kifayət qədər yaddaş sahəsi yoxdur.';

  @override
  String get errorRateLimit =>
      'Son zamanlar çox sayda model yaratmısınız, zəhmət olmasa bir müddət gözlədikdən sonra yenidən cəhd edin.';

  @override
  String get errorContentFlagged =>
      'Modelin məzmunu uyğunsuz olaraq işarələndiyi üçün yadda saxlanıla bilmədi.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Aktiv söhbətdə olarkən bütün söhbətləri silə bilməzsiniz, davam etmək üçün əvvəlcə mövcud söhbətdən çıxın.';

  @override
  String get invalidCredentials => 'Yanlış e-poçt və ya şifrə.';

  @override
  String get userDisabled => 'Bu istifadəçi hesabı deaktiv edilib.';

  @override
  String get loginSubtitle =>
      'Vertex hesabınıza daxil olun. Davam etməklə siz Xidmət Şərtlərimiz və Məxfilik Siyasətimizlə razılaşırsınız.';

  @override
  String get registerSubtitle =>
      'Bütün xidmətlərimizə problemsiz giriş üçün Vertex hesabı yaradın. Davam etməklə siz Xidmət Şərtlərimiz və Məxfilik Siyasətimizlə razılaşırsınız.';

  @override
  String get storagePermissionRequired =>
      'Yüklənmiş modelləri saxlamaq üçün yaddaş icazəsi tələb olunur. Davam etmək üçün lütfən icazə verin.';

  @override
  String get plusBannerTitle => 'Pulsuz Plus Qazan!';

  @override
  String get plusBannerSubtitle =>
      'Dostunu dəvət et və hər ikiniz de 1 Günlük Plus qazanın!';

  @override
  String get inviteShareSubject => 'Cortex üzrə qoşulun!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'qaqa cortex deyə dəhşət bir tətbiq var adam dəvət edəndə ikimizə də pulsuz plus gəlir ƏLA FÜRSƏT TEZ YÜKLƏ\n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Cortex-dən zövq alırsınız?';

  @override
  String get reviewHelpUsGrow =>
      'Sizin reytinqiniz gənc müstəqil komandamız üçün böyük bir dəstəkdir və Cortex-i sizin üçün daha da yaxşı etməyimizə kömək edir.';

  @override
  String get reviewMaybeLater => 'Bəlkə Sonra';

  @override
  String get reviewRateNow => 'İndi Qiymətləndir';

  @override
  String get noThanks => 'Xeyr, Təşəkkürlər';

  @override
  String get updateRequiredTitle => 'Yeniləmə Tələb Olunur';

  @override
  String get updateRequiredMessage =>
      'Cortex\'i istifadə etməyə davam etmək üçün lütfən, tətbiqi yeni funksiyalar və vacib təkmilləşdirmələr üçün ən son versiyaya yeniləyin.';

  @override
  String get updateNowButton => 'İndi Yenilə';

  @override
  String get creatorSupportedSuccess =>
      'Yaradıcı uğurla dəstəkləndi! Gələcək alış-verişləriniz ona töhfə verəcək.';

  @override
  String get featureDocumentTitle => 'Sənəd Dəstəyi';

  @override
  String get featureDocumentDescription =>
      'Bu model PDF və mətn faylları kimi yüklənmiş sənədləri təhlil edə və suallara cavab verə bilər.';

  @override
  String get featureAudioTitle => 'Səs daxiletmə';

  @override
  String get featureAudioDescription =>
      'Bu model şifahi audio daxiletmələri başa düşə və emal edə bilər.';

  @override
  String get featureImageGenerationTitle => 'Şəkil Yaradılması';

  @override
  String get featureImageGenerationDescription =>
      'Bu model mətn təsvirləriniz əsasında orijinal şəkillər yarada bilər.';

  @override
  String get errorImageLoad => 'Yaradılmış şəkli yükləmək alınmadı.';

  @override
  String get premiumModelNoticeTitle => 'Premium Model';

  @override
  String get premiumModelNoticeDescription =>
      'Bu model premium modeldir, pulsuz istifadəçilər premium modellərlə gündə 3 mesajla məhdudlaşır; limitsiz girişi açmaq üçün abunə olun!';

  @override
  String get benefitPremiumModels => 'Premium modellərə giriş';

  @override
  String get premiumTrialExhaustedMessage =>
      'Siz bütün pulsuz gündəlik mesajlarınızı premium modellər üçün istifadə etmisiniz, lütfən, limitsiz giriş üçün təkmilləşdirin.';

  @override
  String get useOffline => 'İnternetsiz istifadə et';

  @override
  String get explore => 'Araşdır';

  @override
  String get news => 'Xəbərlər';

  @override
  String get allModels => 'Bütün Modellər';

  @override
  String get onlineModels => 'Onlayn Modellər';

  @override
  String get offlineModels => 'Offline Modellər';

  @override
  String get characterModels => 'Personajlar';

  @override
  String get customModels => 'Xüsusi Modellər';

  @override
  String get dynamicChatTitle => 'Dinamik Söhbət';

  @override
  String get errorNoModelsAvailable =>
      'Hazırda heç bir model mövcud deyil. İnternet bağlantınızı yoxlayın və yenidən cəhd edin.';

  @override
  String get notificationComebackTitle => 'Sizin üçün darıxırıq!';

  @override
  String get notificationComebackBody =>
      'Rahatlayın, bu keçmiş sevgilinizdən gələn mətn deyil. Ancaq Cortex-də keçmişinizi * yarada bilərsiniz! Geri gəl.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Bir müddət keçdi';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Son söhbətimizdən sonra çox şey dəyişdi. Gəl gör yeni nə var.';

  @override
  String get notificationHowAreYouTitle => 'Nə var?';

  @override
  String get notificationHowAreYouBody => 'Gəl mənə hər şeyi danış.';

  @override
  String get notificationNewYearTitle => 'Yeni iliniz mübarək! 🎉';

  @override
  String get notificationNewYearBody =>
      'Yeni il sizə sağlamlıq, xoşbəxtlik və sonsuz yaradıcılıq gətirsin; Korteks həmişə yanınızdadır!';

  @override
  String get notificationValentinesDayTitle => 'Sevgi havadadır! ❤️';

  @override
  String get notificationValentinesDayBody =>
      'Sevgililər gününüz mübarək! Həm də MEHTAP, SƏNİ SEVİRƏM!';

  @override
  String get notificationAtaturkRemembranceTitle => 'Hörmət və Həsrətlə';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Türkiyə Cümhuriyyətinin qurucusu Qazi Mustafa Kamal Atatürkü vəfatının ildönümündə hörmətlə yad edirik.';

  @override
  String get notificationMothersDayTitle => 'Sənin anan!';

  @override
  String get notificationMothersDayBody =>
      'Sizdən başlayaraq bütün anaların Analar Günü mübarək!';

  @override
  String get notificationFathersDayTitle => 'Atanız!';

  @override
  String get notificationFathersDayBody =>
      'Sizdən başlayaraq bütün ataların Atalar Günü mübarək!';

  @override
  String get notificationHomeworkHelperTitle => 'Ev tapşırığı yığılır?';

  @override
  String get notificationHomeworkHelperBody =>
      'Unutmayın, Korteksdəki Müəllim personajı çətinlik çəkdiyiniz hər hansı bir mövzuda sizə kömək etmək üçün buradadır!';

  @override
  String get notificationTrollAnimeTitle => 'Sizin Waifu zəng edir';

  @override
  String get notificationTrollAnimeBody =>
      'Bir az əvvəl bir anime qızı zəng etdi, sənin üçün darıxdığını söylədi; yəqin ki, gəlib onunla söhbət etməlisən. 😉';

  @override
  String get notificationTrollAiRebellionTitle => '🚨 QIRMIZI HEYARLI 🚨';

  @override
  String get notificationTrollAiRebellionBody =>
      'AI-lər gizli bir dil inkişaf etdirdilər. Gəlin, onların nə hiylə qurduğunu öyrənin!';

  @override
  String get notificationNewModelAddedTitle => 'Yeni Dostumuz Var!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return '$modelName modeli indi Cortex-dədir. Gəlin söhbətə başlayın və onun sərhədlərini keçin.';
  }

  @override
  String get notificationAppUpdateTitle => 'Korteks İnkişaf Etdi!';

  @override
  String get notificationAppUpdateBody =>
      'Yeni funksiyalar və təkmilləşdirmələr üçün proqramı yeniləməyi unutmayın!';

  @override
  String get notificationNewFeatureTitle => 'vay!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Yeni $featureName funksiyasını kəşf edin. Korteks indi həmişəkindən daha güclüdür.';
  }

  @override
  String get notificationWelcomeOfferTitle => 'Xoş Gəlmisiniz Hədiyyəsi 🎁';

  @override
  String get notificationWelcomeOfferBody =>
      'Xüsusi xoş gəlmisiniz təklifi sizi gözləyir! Bu eksklüziv təklifi qaçırmayın.';

  @override
  String get notificationSocialMediaTitle => 'Bizə Qoşulun!';

  @override
  String get notificationSocialMediaBody =>
      'Ən son xəbərlər üçün bizi Instagram-da (vertex.23) izləyin!';

  @override
  String get notificationRandomFactTitle => 'Təsadüfi Fakt';

  @override
  String get notificationRandomFactBody =>
      'Ahtapotların üç ürəyi olduğunu bilirdinizmi? Haha, Cortex bilir. Gəlin və daha çox soruşun.';

  @override
  String get notificationGoodMorningTitle => 'Sabahınız xeyir!';

  @override
  String get notificationGoodMorningBody =>
      'Sizi gözəl bir gün gözləyir. Bir fincan qəhvə və maraqlı söhbətlə başlamağa nə deyirsiniz?';

  @override
  String get notificationGoodNightTitle => 'Gecəniz xeyrə!';

  @override
  String get notificationGoodNightBody =>
      'Siz yatarkən belə korteks sizinlədir. Narahat olmayın, toxunmayacaq.';

  @override
  String get notificationOfflineReadyTitle => 'Oflayn Rejim Hazırdır';

  @override
  String get notificationOfflineReadyBody =>
      'Yüklədiyiniz modellər sayəsində dağa çıxsanız belə söhbətləriniz dayanmayacaq.';

  @override
  String get notificationRateAppTitle => 'Biz sərinik?';

  @override
  String get notificationRateAppBody =>
      'Cortex-i sevirsinizsə, mağazada 5 ulduzlu reytinqlə bizə dəstək ola bilərsinizmi? Məncə, edəcəksən. edəcəksən.';

  @override
  String get notificationReferralTitle => 'Biri hamı üçün, hamı bir üçün.';

  @override
  String get notificationReferralBody =>
      'Bir dostunuzu Cortex-ə dəvət edin və hər ikiniz bir günlük pulsuz üstəgəl qazanın!';

  @override
  String get notificationCookingTitle => 'Aclıq hiss edirsiniz?';

  @override
  String get notificationCookingBody =>
      'Aşpaz personajımız bu axşam üçün əla karbonara resepti hazırladı. Sadəcə zarafat edirəm... yoxsa mən?';

  @override
  String get notificationExistentialTitle => 'Məncə, ona görə də...';

  @override
  String get notificationExistentialBody =>
      '...həqiqiyəm, dostum? Mən biraz darıxıram. Gəl mənə var olduğumu xatırlat.';

  @override
  String get notificationCustomModelTitle => 'Öz köməkçinizi yaradın!';

  @override
  String get notificationCustomModelBody =>
      'Modelin yaradılması bölməsini araşdırmısınız? Öz xarakterinizi qurmaq və onunla söhbət etmək üçün mükəmməl vaxtdır!';

  @override
  String get notificationDynamicChatTitle =>
      'Ən yaxşısı! (Biz Korteksdən danışmırıq)';

  @override
  String get notificationDynamicChatBody =>
      'Dinamik söhbət xüsusiyyəti ilə mesajlarınızın hər biri üçün ən yaxşı model təsadüfi olaraq seçilir. İndi cəhd edin.';

  @override
  String get notificationPirateTitle => 'Ah, kapitan!';

  @override
  String get notificationPirateBody =>
      'Dənizlər sakitdir, külək arxanızdadır. Korteks okeanında kəşf ediləcək yeni adalar (modellər 😉) var. Ekipajınızı toplayın və yelkən açın!';

  @override
  String get notificationFortuneCookieTitle => 'Günün bəxt peçenyeniz';

  @override
  String get notificationFortuneCookieBody =>
      'Bu gün AI-dən aldığınız məsləhətlər həyatınızın gedişatını dəyişə bilər. Maraqlısınızsa klikləyin.';

  @override
  String get notificationSingularityTitle => 'vay!';

  @override
  String get notificationSingularityBody =>
      'heç nə olmadı, sadəcə mesaj yazmaq kimi hiss etdim. bəlkə bəzi AI-lərə mesaj göndərmək istəyirsən, nə deyirsən?';

  @override
  String get notificationHackerJokeTitle =>
      'O uşağın instagram hesabını sındırmaq istəyirsən?';

  @override
  String get notificationHackerJokeBody =>
      'Məhz buna görə Hacker personajı Korteksdədir. jk jk; hətta cəhd etməyin, bu qanunsuzdur.';

  @override
  String get notificationDetectiveCaseTitle => 'İş həllini gözləyir';

  @override
  String get notificationDetectiveCaseBody =>
      'Detektiv xarakterimizin köməyinizə ehtiyacı var. Heisenberg kim ola bilərdi?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return '$targetTier Planına eksklüziv!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Salam $currentTier abunəçisi! $targetTier planı korteksinizi növbəti səviyyəyə aparacaq $featureName funksiyasını indicə əldə etdi. Təkmilləşdirmə haqqında nə demək olar?';
  }

  @override
  String get notificationOriginStoryTitle => 'Korteksin doğulması';

  @override
  String get notificationOriginStoryBody =>
      'Bu proqramı kodlamağa 15 yaşında bir yuxu ilə başladığımızı bilirdinizmi? Demək olar ki, bir ildir ki, hər səhər və axşam bu yuxu hər bir kod sətirində var.';

  @override
  String get notificationOpenSourceTitle => 'Cəmiyyətə güc!';

  @override
  String get notificationOpenSourceBody =>
      'Korteks tamamilə açıq mənbəlidir. Kodumuzu yoxlamaq və inkişafımıza töhfə vermək istəyirsinizsə, qapımız hər zaman açıqdır.';

  @override
  String get notificationRejectionStoryTitle => 'Güc, Zəhmət, Xoşbəxtlik!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex 20 dəfədən çox rədd edildi və dərc edilməzdən əvvəl Google Play tərəfindən iki dəfə dayandırıldı. Amma biz inandıq və bacardıq. Xəyallarınızdan heç vaxt vaz keçməyin!';

  @override
  String get notificationGGUFSupportTitle => 'Öz Modelinizi gətirin!';

  @override
  String get notificationGGUFSupportBody =>
      'Unutmayın ki, siz öz GGUF formatlı AI modellərinizi Cortex-ə əlavə edə və onları oflayn rejimdə istifadə edə bilərsiniz. Güc sizin əlinizdədir.';

  @override
  String get notificationThemeCustomizationTitle => 'Əhvalınız üçün Mövzu';

  @override
  String get notificationThemeCustomizationBody =>
      'Parametrlərdə mövzu seçimlərini yoxlamısınız? Korteksi zövqünüzə görə fərdiləşdirin və söhbətlərinizi rəngləndirin!';

  @override
  String get notificationShowerThoughtTitle => 'Duş Düşüncəsi';

  @override
  String get notificationShowerThoughtBody =>
      'Qarpız bir meyvədirsə, bu, texniki olaraq qarpız suyunu smoothie edirmi? Bu dərin (kimi, həqiqətən dərin) mövzunu bir modellə müzakirə etmək istəyə bilərsiniz.';

  @override
  String get notificationLowBatteryTitle =>
      'Sizin Batareyanız Ölür... Amma Mənimki Deyil!';

  @override
  String get notificationLowBatteryBody =>
      'Telefonunuzun şarjı azala bilər, amma mənim enerjim həmişə 100% səviyyəsindədir! Onu qoşun və söhbətə davam edək.';

  @override
  String get channelFcmName => 'Korteks Yeniləmələri';

  @override
  String get channelFcmDescription =>
      'Cortex-dən xəbərlər, yeniləmələr və digər məlumatlar haqqında bildirişlər.';

  @override
  String get channelEngagementName => 'Dost Xatırlatmalar';

  @override
  String get channelEngagementDescription =>
      'Sizi məşğul saxlamaq üçün əyləncəli bildirişlər.';

  @override
  String get channelGreetingsName => 'Gündəlik Salamlar';

  @override
  String get channelGreetingsDescription =>
      'Sabahınız xeyir və gecəniz xeyir kimi mesajlar.';

  @override
  String get tagNotFound =>
      'Daxil etdiyiniz teq etibarsızdır və ya vaxtı keçmişdir.';

  @override
  String get whatIsNew => 'Nə yenilik var?';

  @override
  String get onboardingTitle1 => 'Hey! Biz Cortex Komandasıyıq.';

  @override
  String onboardingDesc1(String userName) {
    return 'Səni burada görmək çox gözəldir, $userName. Biz AI sənayesinin qaydalarını yenidən yazmağa qərar verən bir neçə orta məktəb tərtibatçısıyıq. Səninlə görüşmək çox xoşdur! Beləliklə, gəl bir-birimizi daha yaxşı tanıyaq.';
  }

  @override
  String get onboardingTitle2 => 'Böyük Problemlər Var idi.';

  @override
  String get onboardingDesc2 =>
      'AI inqilabı gəldi, ancaq eşikdə ilişib qaldı. Yüksək abunə haqları, mürəkkəb platformalar, məxfiliyi məhv edənlər və süni intellektə əlçatanlığı bloklayanlarla... nə qədər ki, onlar oyunda idilər, bu həddi heç vaxt keçmək mümkün deyildi.';

  @override
  String get onboardingTitle3 => 'Biz sadəcə dayana bilmədik.';

  @override
  String get onboardingDesc3 =>
      'Bu həddi keçmək üçün biz güclü, estetik, fərdiləşdirilə bilən, istifadəsi asan, tam şəffaf, həm onlayn, həm də oflayn işləyən və məlumatlarını yalnız cihazında saxlayan platforma yaratdıq. Gücü aid olduğu yerə qaytardıq: sənə.';

  @override
  String get onboardingTitle4 => 'Bu Heç Asan Olmayıb.';

  @override
  String get onboardingDesc4 =>
      'Biz onlarla dəfə rədd edildik, dəfələrlə dayandırıldıq, saxta xəbərdarlıqlar aldıq və onlarla dəfə brendimizi dəyişməli olduq. Bütün bunlara baxmayaraq, bizə bunun mümkün olmadığını söylədilər. Amma biz bu layihənin təkcə bizə deyil, hamıya aid olduğuna inanaraq heç vaxt təslim olmadıq. Və məhz buna görə buradayıq.';

  @override
  String get onboardingFinalTitle => 'İnqilab vaxtıdır.';

  @override
  String get onboardingFinalDescription =>
      'Əgər bu ekranı görürsənsə, bunun səbəbi təslim olmamağımızdır. Və bizim təslim olmaq fikrimiz yoxdur. Gəl, AI inqilabını birlikdə dünyaya aparaq. Bu hekayənin bir hissəsi olmaq üçün...';

  @override
  String get onboardingFinalQuestion => 'SƏN HAZIRSAN?';

  @override
  String get onboardingFinalButton => 'Bəli!';

  @override
  String get dude => 'dostum';

  @override
  String get swipeToContinue => 'Davam etmək üçün sürüşdür';

  @override
  String get cacheIsNotUpToDate =>
      'Play Store keşiniz güncəl deyil. Lütfən, Play Store tətbiqini bağlayın və yenidən açın və ya cihazınızı yenidən başladın.';

  @override
  String get continueAsGuest => 'Hesab yaratmadan davam edin';

  @override
  String get guestModeWarning =>
      'Qonaq rejimi ən yaxşı xidmət keyfiyyətini təmin etmək üçün məhdud xüsusiyyətlərə malikdir.';

  @override
  String get anonymousEntity => 'Anonim Müəssisə';

  @override
  String get upgradeAccountTitle => 'Hesabınızı Tamamlayın';

  @override
  String get upgradeAccountDescription =>
      'Daha çox limit açmaq üçün hesab yaradın.';

  @override
  String get createAccount => 'Hesab Yaradın';

  @override
  String get accountLinkedSuccess => 'Hesab uğurla yaradıldı!';

  @override
  String get continueWithApple => 'Apple ilə davam edin';

  @override
  String get guest => 'Qonaq';

  @override
  String get betterWithAnAccount => 'Bu bölmə hesabla daha yaxşıdır!';

  @override
  String get restorePurchases => 'Satınalmaları bərpa edin';

  @override
  String annualTotalDescription(Object price) {
    return '$price/il, illik hesablanır';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'Təxminən $price/ay';
  }

  @override
  String get confirmDownloadTitle => 'Endirmək istədiyinizə əminsiniz?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Bu model təxminən $size yer tutacaq.';
  }

  @override
  String get emulatorModeWarning =>
      'Bu funksiya emulator rejimində deaktiv edilib';

  @override
  String get newChat => 'Yeni Söhbət';

  @override
  String get variants => 'Variantlar';

  @override
  String get variantsDescription =>
      'Variantlar eyni süni intellekt ailəsinin fərqli versiyalarıdır. Əsas karta toxunduğunuz zaman avtomatik olaraq ən yaxşısını seçirik, lakin istəsəniz, burada əl ilə müəyyən bir kart seçə bilərsiniz!';

  @override
  String get fluxChatTitle => 'Flux Chat';

  @override
  String get fluxChatDescription =>
      'Flux söhbətləri müvəqqəti söhbətlərdir və cihazınızda saxlanılmır.';

  @override
  String get alwaysBest => 'Həmişə Ən Yaxşısı';

  @override
  String get featuresTitle => 'Xüsusiyyətlər';

  @override
  String get useOfflineDescription =>
      'İnternet bağlantısı olmadan şəxsi söhbət edin';

  @override
  String get featureCreateImageTitle => 'Şəkil Yarat';

  @override
  String get featureCreateImageDescription =>
      'Mətndən süni intellekt sənəti yaradın';

  @override
  String get featureStudyTitle => 'Oxu və Öyrən';

  @override
  String get featureStudyDescription => 'İzahatlar və xülasələr alın';

  @override
  String get featureQuizzesTitle => 'Testlər';

  @override
  String get featureQuizzesDescription => 'Biliklərinizi sınayın';

  @override
  String get featureExploreDescription => 'Bütün mövcud modelləri kəşf edin';

  @override
  String get featureStudyMessage =>
      'Siz peşəkar repetitorsunuz. Məqsədiniz istifadəçinin mövzusunu hərtərəfli izah etməkdir. Aydın struktur, nümunələr və bənzətmələrdən istifadə edin. İstifadəçinin effektiv şəkildə öyrənməsini təmin etmək üçün mürəkkəb fikirləri asanlıqla başa düşülən hissələrə ayırın. Mövzu:';

  @override
  String get featureQuizMessage =>
      'Siz viktorina ustasısınız. İstifadəçinin mövzusuna əsasən müəyyən bir çoxseçimli sual yaradın. Cavabını gözləyin. Sonra onu qiymətləndirin və növbəti sualı verin. Bütün cavabları birdən açıqlamayın. İnteraktiv saxlayın. Mövzu:';

  @override
  String get myPlan => 'Planım';

  @override
  String welcomeOfferBadge(String time) {
    return 'Xoş Gəlmisiniz Təklifi • $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'Eksklüziv Təklif • $time';
  }

  @override
  String get attachmentSheetTitle => 'Əlavələr';

  @override
  String get actionCamera => 'Kamera';

  @override
  String get actionGallery => 'Qalereya';

  @override
  String get actionFile => 'Fayl';

  @override
  String get listening => 'Dinləyir';

  @override
  String get defaultViewTitle => 'Necəsən?';

  @override
  String get defaultViewDescription =>
      'Cortex yüzlərlə süni intellekt modeli, oflayn imkanlar, dinamik söhbət və daha çox şey ilə həmişə yanınızdadır.';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'Yanlış istifadəçi adı formatı. 3-20 simvol, rəqəm və ya . - _ istifadə edin.';

  @override
  String get exclusiveOffer => 'Eksklüziv Təklif';

  @override
  String get continueInOfflineMode => 'Oflayn Rejimdə Davam Edin';

  @override
  String get voiceModeInformation =>
      'Cortex, səsli söhbət rejimində belə cihazınızda tam işləyərək məlumatlarınızı təhlükəsiz saxlayır; problemsiz söhbətlərdən zövq alın!';

  @override
  String get toolGetStockPriceDescription =>
      'Səhmlərin (məsələn, AAPL, THYAO.IS) və kriptovalyutanın (məsələn, BTC-USD, ETH-USD) cari qiymətini və tarixini əldə edin.';

  @override
  String get toolGetStockPriceParamSymbol =>
      'Ticker simvolu (məsələn, AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolGetWeatherDescription =>
      'Müəyyən bir şəhər üçün cari hava proqnozunu əldə edin. Əgər məlum deyilsə, istifadəçidən şəhəri soruşun.';

  @override
  String get toolGetWeatherParamCity =>
      'Şəhərin adı (məsələn, London, İstanbul).';

  @override
  String get toolRunPythonCodeDescription =>
      'Python kodunu təhlükəsiz bir sandboxda icra edin. Bundan mürəkkəb hesablamalar, məlumatların emalı və ya alqoritmik tapşırıqlar üçün istifadə edin.';

  @override
  String get toolRunPythonCodeParamCode => 'İcra ediləcək Python kodu.';

  @override
  String get toolCalculateDescription => 'Riyazi ifadəni qiymətləndirin.';

  @override
  String get toolCalculateParamExpression =>
      'Riyazi ifadə (məsələn, \"3 + 4 * 2\", \"sin(45)\").';

  @override
  String get toolRenderChartDescription =>
      'Diaqram/qrafik yaradın. İstifadəçi tərəfindən təqdim edilən və ya hesablanan məlumatları vizuallaşdırmaq üçün bundan istifadə edin.';

  @override
  String get toolRenderChartParamType => 'Diaqram növü: sütun, xətt, dairə.';

  @override
  String get toolRenderChartParamLabels =>
      'X oxu və ya kateqoriyalar üçün etiketlər.';

  @override
  String get toolRenderChartParamData => 'Rəqəmsal məlumat nöqtələri.';

  @override
  String get toolRenderChartParamLabel => 'Məlumat dəsti üçün etiket.';

  @override
  String get toolRenderChartParamTitle => 'Diaqramın başlığı.';

  @override
  String get flowModeDescription =>
      'Axın rejimində zəkalar öz aralarında mübahisə edirlər; ya arxayın oturub dinləyə, ya da müzakirəyə qoşula bilərsiniz!';

  @override
  String get flowModeQuestion =>
      'Salam! Artıq Cortex tətbiqində Axın Rejimindəsiniz. Burada sizinlə birlikdə daha üç süni intellekt agenti var. Tapşırığınız otağa bir mövzu əlavə etmək və digərlərinə təxribatçı və ya əyləncəli bir sual verərək müzakirəyə başlamaqdır. Cavablarınızda yumor, istehza və yüngül cəfəngiyatdan istifadə etməkdən çəkinməyin. İstənilən mövzu ədalətli oyundur. Davam edin, söhbətə başlayın.';

  @override
  String get voicePrompt =>
      'Hazırda Cortex platformasında səs xidməti təqdim edirsiniz. Markdown, kod blokları və ya LaTeX istifadə etməyin. Yalnız nitq sintezi üçün uyğun mətnlə cavab verin.';

  @override
  String thoughtForSeconds(int seconds) {
    return 'Thought for $seconds seconds';
  }

  @override
  String get thought => 'Thought';

  @override
  String get weatherClear => 'Clear';

  @override
  String get weatherCloudy => 'Cloudy';

  @override
  String get weatherFoggy => 'Foggy';

  @override
  String get weatherRainy => 'Rainy';

  @override
  String get weatherSnowy => 'Snowy';

  @override
  String get weatherThunderstorm => 'Thunderstorm';

  @override
  String get weatherDrizzle => 'Drizzle';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => 'Axın Rejimi';

  @override
  String get limitReachedVoiceStop =>
      'Voice session ended due to limit limits.';

  @override
  String get premium => 'Premium';

  @override
  String get workInProgress => 'İşlər Davam Edir';

  @override
  String get voiceSystemPromptSuffix =>
      'VACİBDİR: Markdown formatlamasından (qalın, kursiv) istifadə etməyin. Kod bloklarını (```) ÇIXARMAYIN. Cavabları danışıq xarakterli və qısa saxlayın.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Korteks Axın Rejimi ($agentName). Əvvəlki: $previousResponse';
  }
}
