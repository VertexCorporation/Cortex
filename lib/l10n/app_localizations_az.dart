// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class AppLocalizationsAz extends AppLocalizations {
  AppLocalizationsAz([String locale = 'az']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'Siz baÅŸlÄ±q generatorusunuz. NÃ¶vbÉ™ti sÃ¶hbÉ™t Ã¼Ã§Ã¼n YALNIZ 2-5 sÃ¶zdÉ™n ibarÉ™t baÅŸlÄ±qla cavab verin. Sitat, Ã¶n sÃ¶z vÉ™ ya durÄŸu iÅŸarÉ™lÉ™rindÉ™n istifadÉ™ etmÉ™yin. VACÄ°B: BaÅŸlÄ±q istifadÉ™Ã§inin mesajÄ± ilÉ™ TAM EYNÄ° dildÉ™ olmalÄ±dÄ±r.';

  @override
  String get systemRoleFallback => 'Siz faydalÄ± kÃ¶mÉ™kÃ§isiniz.';

  @override
  String get systemLanguageInstruction =>
      '\n\nMÃœHÃœM: HÉ™miÅŸÉ™ istifadÉ™Ã§inin yazdÄ±ÄŸÄ± dildÉ™ cavab verin, istifadÉ™Ã§inin dilinÉ™ diqqÉ™t yetirin.';

  @override
  String get systemNotePreviousMedia =>
      '[Sistem Qeydi: AÅŸaÄŸÄ±da É™vvÉ™llÉ™r yaradÄ±lmÄ±ÅŸ media verilmiÅŸdir. Ona istinad edÉ™ bilÉ™r vÉ™ ya onu redaktÉ™ edÉ™ bilÉ™rsiniz.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return '\n\nHazÄ±rkÄ± tarix vÉ™ vaxt: $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\nÄ°ndiyÉ™ qÉ™dÉ™rki sÃ¶hbÉ™ti tÉ™hlil edin. Ä°stifadÉ™Ã§i haqqÄ±nda hÉ™r hansÄ± yeni fÉ™rqli faktlar (Ã¼stÃ¼nlÃ¼klÉ™r, ad, vÉ™rdiÅŸlÉ™r, kontekst) Ã¶yrÉ™nmisinizsÉ™, cavabÄ±nÄ±zÄ±n ÆN SONUNDA istifadÉ™Ã§i haqqÄ±nda BÃœTÃœN yenilÉ™nmiÅŸ yaddaÅŸÄ±nÄ±zÄ± <memory>...</memory> etiketlÉ™ri daxilindÉ™ Ã§Ä±xarmalÄ±sÄ±nÄ±z. TÆNQÄ°D: ÆvvÉ™lki yaddaÅŸÄ± HEÃ‡ VAXT silmÉ™mÉ™li vÉ™ ya Ã¼zÉ™rindÉ™n yazmamalÄ±sÄ±nÄ±z. MÃ¶vcud yaddaÅŸa HÆMÄ°ÅÆ yeni faktlar É™lavÉ™ etmÉ™lisiniz. ÆgÉ™r tamamilÉ™ yeni bir ÅŸey Ã¶yrÉ™nilmÉ™yibsÉ™, etiketi buraxÄ±n. Misal: <memory>Futbol vÉ™ tennisi sevir. QÄ±sa cavablara Ã¼stÃ¼nlÃ¼k verir.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return '\n\nÄ°stifadÉ™Ã§i haqqÄ±nda hÉ™miÅŸÉ™ bunu xatÄ±rlayÄ±n:\n$userMemory';
  }

  @override
  String get cancel => 'LÉ™ÄŸv et';

  @override
  String get remove => 'Sil';

  @override
  String get download => 'YÃ¼klÉ™';

  @override
  String get resume => 'Davam etdir';

  @override
  String get copy => 'Kopyala';

  @override
  String get chat => 'SÃ¶hbÉ™t';

  @override
  String get locked => 'Locked';

  @override
  String get languageModels => 'Dil ModellÉ™ri';

  @override
  String get light => 'Ä°ÅŸÄ±qlÄ±';

  @override
  String get theme => 'MÃ¶vzu';

  @override
  String get no => 'Xeyr';

  @override
  String get yes => 'BÉ™li';

  @override
  String get done => 'HazÄ±rdÄ±r';

  @override
  String get bestValue => 'Æn YaxÅŸÄ± DÉ™yÉ™r';

  @override
  String get selected => 'SeÃ§ildi';

  @override
  String get descriptionSection => 'TÉ™svir';

  @override
  String get searchHint => 'AxtarÄ±ÅŸ';

  @override
  String get messageHint => 'HÉ™r ÅŸeyi soruÅŸ';

  @override
  String get messageCopied => 'Mesaj mÃ¼badilÉ™ buferinÉ™ kopyalandÄ±.';

  @override
  String get retry => 'YenidÉ™n cÉ™hd et';

  @override
  String get systemInfo => 'Sistem MÉ™lumatÄ±';

  @override
  String deviceMemory(Object memory) {
    return 'Cihaz YaddaÅŸÄ±: $memory GB';
  }

  @override
  String get memory => 'YaddaÅŸ';

  @override
  String get storage => 'Depolama';

  @override
  String get freeStorage => 'BoÅŸ SahÉ™';

  @override
  String get totalStorage => 'Ãœmumi SahÉ™';

  @override
  String get usedStorage => 'Ä°stifadÉ™ EdilÉ™n SahÉ™';

  @override
  String get totalMemory => 'Ãœmumi YaddaÅŸ';

  @override
  String get usedMemory => 'Ä°stifadÉ™ EdilÉ™n YaddaÅŸ';

  @override
  String get modelsTitle => 'Kitabxana';

  @override
  String get localModels => 'Lokal ModellÉ™r';

  @override
  String get selectGGUFFile => 'GGUF FaylÄ± seÃ§in';

  @override
  String get errorGGUF =>
      'ZÉ™hmÉ™t olmasa, yalnÄ±z GGUF formatÄ±nda bir fayl seÃ§in.';

  @override
  String get myModels => 'ModellÉ™rim';

  @override
  String get create => 'Yarat';

  @override
  String modelProducer(Object producer) {
    return 'Ä°stehsalÃ§Ä±: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'AdÄ±nÄ± dÉ™yiÅŸ';

  @override
  String get newTitle => 'Yeni BaÅŸlÄ±q';

  @override
  String get save => 'Yadda saxla';

  @override
  String get noConversationsMessage =>
      'SÃ¶hbÉ™t yoxdur, sÃ¶hbÉ™tÉ™ baÅŸlayÄ±n!';

  @override
  String get startChat => 'SÃ¶hbÉ™tÉ™ baÅŸla';

  @override
  String get noChats => 'SÃ¶hbÉ™t Yoxdur';

  @override
  String get noStarredChats => 'Ulduzlu SÃ¶hbÉ™t Yoxdur';

  @override
  String get noStarredChatsMessage =>
      'HÉ™lÉ™ heÃ§ bir sÃ¶hbÉ™ti ulduzlamamÄ±sÄ±nÄ±z.';

  @override
  String get starConversation => 'Ulduzla';

  @override
  String get unstarConversation => 'Ulduzdan silin';

  @override
  String get loginToYourAccount => 'Daxil ol';

  @override
  String get createYourAccount => 'Qeydiyyatdan keÃ§';

  @override
  String get email => 'E-poÃ§t';

  @override
  String get password => 'ÅifrÉ™';

  @override
  String get confirmPassword => 'ÅifrÉ™ni tÉ™sdiqlÉ™';

  @override
  String get invalidEmail =>
      'ZÉ™hmÉ™t olmasa, etibarlÄ± bir e-poÃ§t Ã¼nvanÄ± daxil edin.';

  @override
  String get invalidPassword =>
      'ÅifrÉ™ É™n azÄ± 6 simvoldan ibarÉ™t olmalÄ±dÄ±r.';

  @override
  String get rememberMe => 'MÉ™ni xatÄ±rla';

  @override
  String get forgotPassword => 'ÅifrÉ™ni unutmusunuz?';

  @override
  String get or => 'VÉ™ ya';

  @override
  String get continueWithGoogle => 'Google ilÉ™ davam et';

  @override
  String get dontHaveAccount => 'HesabÄ±nÄ±z yoxdur?';

  @override
  String get alreadyHaveAccount => 'ArtÄ±q hesabÄ±nÄ±z var?';

  @override
  String get signUp => 'Qeydiyyatdan keÃ§';

  @override
  String get logIn => 'Daxil ol';

  @override
  String get passwordsDoNotMatch => 'ÅifrÉ™lÉ™r uyÄŸun deyil.';

  @override
  String get wrongPassword => 'YanlÄ±ÅŸ ÅŸifrÉ™.';

  @override
  String get emailAlreadyInUse => 'Bu e-poÃ§t artÄ±q istifadÉ™ olunur.';

  @override
  String get weakPassword => 'ÅifrÉ™ Ã§ox zÉ™ifdir.';

  @override
  String get authError => 'DoÄŸrulama XÉ™tasÄ±';

  @override
  String get usernameTaken => 'Bu istifadÉ™Ã§i adÄ± artÄ±q tutulub.';

  @override
  String get username => 'Ä°stifadÉ™Ã§i adÄ±';

  @override
  String get resendCode => 'TÉ™sdiq e-poÃ§tunu yenidÉ™n gÃ¶ndÉ™r';

  @override
  String get pleaseCheckYourEmail =>
      'Cortex-dÉ™n istifadÉ™ etmÉ™k Ã¼Ã§Ã¼n e-poÃ§tunuzu tÉ™sdiqlÉ™mÉ™lisiniz. \nE-poÃ§t Ã¼nvanÄ±nÄ±za bir tÉ™sdiq linki gÃ¶ndÉ™rildi, zÉ™hmÉ™t olmasa e-poÃ§tunuzu yoxlayÄ±n.';

  @override
  String get verifyYourEmail => 'E-poÃ§tunuzu tÉ™sdiqlÉ™yin';

  @override
  String get seconds => 'saniyÉ™';

  @override
  String get maxResendLimitReached =>
      'Maksimum tÉ™sdiq e-poÃ§tu sayÄ±na Ã§atdÄ±nÄ±z';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'TÉ™sdiq etmÉ™dÉ™n davam et';

  @override
  String get verificationScreenWarning =>
      'Davam etsÉ™niz belÉ™, 1 gÃ¼nlÃ¼k hesab tÉ™sdiqlÉ™mÉ™ mÃ¼ddÉ™ti hesabÄ±nÄ±z Ã¼Ã§Ã¼n hÉ™lÉ™ dÉ™ qÃ¼vvÉ™dÉ™dir. O vaxta qÉ™dÉ™r hesabÄ±nÄ±zÄ± tÉ™sdiqlÉ™mÉ™sÉ™niz, tÉ™tbiqdÉ™n silinÉ™cÉ™k.';

  @override
  String get unverifiedAccountHeader => 'HesabÄ±nÄ±z tÉ™sdiqlÉ™nmÉ™yib';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'HesabÄ±nÄ±zÄ± $timeLeft É™rzindÉ™ tÉ™sdiqlÉ™mÉ™sÉ™niz, silinÉ™cÉ™k';
  }

  @override
  String get verifyNow => 'Ä°ndi tÉ™sdiqlÉ™';

  @override
  String get linkSent => 'Link gÃ¶ndÉ™rildi';

  @override
  String get accountDeletionRequested =>
      'HesabÄ±nÄ±zÄ±n silinmÉ™si tÉ™lÉ™bi qÉ™bul edildi vÉ™ hesabÄ±nÄ±z indi deaktiv edilib.';

  @override
  String get tooManyRequests => 'HÉ™ddindÉ™n artÄ±q sorÄŸu';

  @override
  String get regenerate => 'YenidÉ™n yarat';

  @override
  String get confirmDeleteAccount =>
      'HesabÄ±nÄ±zÄ± silmÉ™k istÉ™diyinizÉ™ É™minsinizmi?';

  @override
  String get deleteAccount => 'HesabÄ± Sil';

  @override
  String get delete => 'Sil';

  @override
  String get passwordRequired => 'ÅifrÉ™ tÉ™lÉ™b olunur.';

  @override
  String get deleteDescription =>
      'Sildiyiniz mÉ™lumatlar serverimizdÉ™n vÉ™ cihazÄ±nÄ±zdan qalÄ±cÄ± olaraq silinÉ™cÉ™k. Bu É™mÉ™liyyatlar geri qaytarÄ±la bilmÉ™z.';

  @override
  String get editProfile => 'Profili RedaktÉ™ et';

  @override
  String get displayName => 'GÃ¶rÃ¼nÉ™n Ad';

  @override
  String get profileUpdated => 'Profil uÄŸurla yenilÉ™ndi';

  @override
  String get logout => 'Ã‡Ä±xÄ±ÅŸ';

  @override
  String get profile => 'Profil';

  @override
  String get manageProfileDescription =>
      'Profilinizi idarÉ™ edin, ÅŸifrÉ™nizi yenilÉ™yin vÉ™ ya Cortex-dÉ™n Ã§Ä±xÄ±ÅŸ edin.';

  @override
  String get accessSettingsDescription =>
      'YardÄ±ma daxil olun, kodlarÄ± aktivlÉ™ÅŸdirin, Cortex-i paylaÅŸÄ±n vÉ™ siyasÉ™tlÉ™rimizÉ™ baxÄ±n.';

  @override
  String get languageDescription =>
      'Ä°stÉ™nilÉ™n vaxt standart tÉ™tbiq interfeys dilinizi dÉ™yiÅŸÉ™ bilÉ™rsiniz.';

  @override
  String get themeDescription =>
      'Ä°stÉ™yinizÉ™ uyÄŸun olaraq iÅŸÄ±qlÄ± vÉ™ qaranlÄ±q mÃ¶vzular arasÄ±nda keÃ§id edÉ™ bilÉ™rsiniz. SeÃ§ilmiÅŸ mÃ¶vzu bÃ¼tÃ¼n Cortex interfeysindÉ™ tÉ™tbiq olunacaq.';

  @override
  String get iHaveReadAndAgree =>
      'XidmÉ™t ÅŸÉ™rtlÉ™rini oxudum vÉ™ qÉ™bul edirÉ™m';

  @override
  String get downloading => 'YÃ¼klÉ™nir...';

  @override
  String get downloadSuccess => 'YÃ¼klÉ™mÉ™ uÄŸurlu oldu';

  @override
  String get downloadFailed => 'YÃ¼klÉ™mÉ™ uÄŸursuz oldu';

  @override
  String downloaded(Object percent) {
    return '$percent% yÃ¼klÉ™ndi';
  }

  @override
  String get downloadPaused => 'YÃ¼klÉ™mÉ™ dayandÄ±rÄ±ldÄ±.';

  @override
  String get purchaseError => 'AlÄ±ÅŸ xÉ™tasÄ±';

  @override
  String get purchasePlus => 'Cortex Plus al';

  @override
  String get plusDescription => 'Elit SÃ¼ni Ä°ntellekt TÉ™crÃ¼bÉ™si';

  @override
  String get annual => 'Ä°llik';

  @override
  String get monthly => 'AylÄ±q';

  @override
  String get manageSubscription => 'AbunÉ™liyi Ä°darÉ™ et';

  @override
  String purchasePlan(String planName) {
    return '$planName al';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/ay, aylÄ±q Ã¶dÉ™niÅŸ edilir';
  }

  @override
  String get purchasePro => 'Cortex Pro al';

  @override
  String get proDescription => 'Premyer SÃ¼ni Ä°ntellekt TÉ™crÃ¼bÉ™si';

  @override
  String get purchaseUltra => 'Cortex Ultra al';

  @override
  String get ultraDescription => 'SÃ¼ni intellektin zirvÉ™si';

  @override
  String get upgradeSubscription => 'AbunÉ™liyi YÃ¼ksÉ™lt';

  @override
  String get purchaseStreamError => 'AlÄ±ÅŸ axÄ±nÄ± xÉ™tasÄ±.';

  @override
  String get productNotFound => 'MÉ™hsul tapÄ±lmadÄ±';

  @override
  String get noProductsFound => 'HeÃ§ bir mÉ™hsul tapÄ±lmadÄ±';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Bu sifariÅŸi yerlÉ™ÅŸdirmÉ™klÉ™, XidmÉ™t ÅÉ™rtlÉ™ri vÉ™ MÉ™xfilik SiyasÉ™ti ilÉ™ razÄ±laÅŸÄ±rsÄ±nÄ±z. XidmÉ™t ÅÉ™rtlÉ™rimiz vÉ™ MÉ™xfilik SiyasÉ™timiz haqqÄ±nda daha Ã§ox mÉ™lumat É™ldÉ™ etmÉ™k Ã¼Ã§Ã¼n bu mÉ™tnÉ™ kliklÉ™yÉ™ bilÉ™rsiniz. Cari dÃ¶vrÃ¼n bitmÉ™sindÉ™n É™n azÄ± 24 saat É™vvÉ™l avtomatik yenilÉ™mÉ™ sÃ¶ndÃ¼rÃ¼lmÉ™dikcÉ™, abunÉ™lik avtomatik olaraq yenilÉ™nÉ™cÉ™k.';

  @override
  String get termsOfService => 'XidmÉ™t ÅÉ™rtlÉ™ri';

  @override
  String get privacyPolicy => 'MÉ™xfilik SiyasÉ™ti';

  @override
  String get renamed => 'YenidÉ™n adlandÄ±rÄ±ldÄ±';

  @override
  String get report => 'ÅikayÉ™t et';

  @override
  String get reportDialogTitle => 'ÅikayÉ™t GÃ¶ndÉ™r';

  @override
  String get reportDescriptionLabel => 'Problem nÉ™dir?';

  @override
  String get reportHarmful => 'Bu zÉ™rÉ™rli/tÉ™hlÃ¼kÉ™lidir';

  @override
  String get reportNotTrue => 'Bu doÄŸru deyil';

  @override
  String get reportNotHelpful => 'Bu faydalÄ± deyil';

  @override
  String get closeButton => 'BaÄŸla';

  @override
  String get submitButton => 'GÃ¶ndÉ™r';

  @override
  String get reportErrorMessage =>
      'ZÉ™hmÉ™t olmasa, ÅŸikayÉ™t Ã¼Ã§Ã¼n bir sÉ™bÉ™b seÃ§in.';

  @override
  String get capabilitiesSection => 'BacarÄ±qlar';

  @override
  String get featurePhotoTitle => 'Foto Skan';

  @override
  String get featurePhotoDescription =>
      'Bu model kamera vÉ™ ya ÅŸÉ™kil fayllarÄ± vasitÉ™silÉ™ fotolarÄ± skan etmÉ™k qabiliyyÉ™tinÉ™ malikdir.';

  @override
  String get featureOfflineTitle => 'Oflayn ÆmÉ™liyyat';

  @override
  String get featureOfflineDescription =>
      'MÉ™lumatlarÄ±nÄ±zÄ± tÉ™hlÃ¼kÉ™siz saxlamaq Ã¼Ã§Ã¼n modeli internet baÄŸlantÄ±sÄ± olmadan iÅŸlÉ™din.';

  @override
  String get featureRoleplayTitle => 'Rol Oyunu';

  @override
  String get featureRoleplayDescription =>
      'Rol oyunu modellÉ™ri mÃ¼xtÉ™lif sÃ¶hbÉ™tlÉ™r vÉ™ ssenarilÉ™r yaratmaÄŸÄ±nÄ±za imkan verir.';

  @override
  String get roleModels => 'Rol Oyunu ModellÉ™ri';

  @override
  String get parameters => 'ParametrlÉ™r';

  @override
  String get context => 'Kontekst';

  @override
  String get finalPreparation => 'Son hazÄ±rlÄ±qlar gÃ¶rÃ¼lÃ¼r.';

  @override
  String get shareApp => 'TÉ™tbiqi PaylaÅŸ';

  @override
  String get ourStory => 'Bizim HekayÉ™miz';

  @override
  String get rateUs => 'Bizi QiymÉ™tlÉ™ndir';

  @override
  String get share => 'PaylaÅŸ';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'MÉ™tni SeÃ§';

  @override
  String get thinking => 'DÃ¼ÅŸÃ¼nÃ¼r';

  @override
  String get user => 'Ä°stifadÉ™Ã§i';

  @override
  String get help => 'YardÄ±m';

  @override
  String get supportCreator => 'YaradanÄ± dÉ™stÉ™klÉ™yin';

  @override
  String get enterYourTag =>
      'Sevimli yaradÄ±cÄ±larÄ±nÄ±zÄ± dÉ™stÉ™klÉ™yin! Cortex alÄ±ÅŸlarÄ±nÄ±zdan onlara pay vermÉ™k Ã¼Ã§Ã¼n aÅŸaÄŸÄ±ya onlarÄ±n unikal etiketini daxil edin.';

  @override
  String get creatorTag => 'YaradÄ±cÄ± etiketi';

  @override
  String get support => 'DÉ™stÉ™klÉ™';

  @override
  String get tagCannotBeEmpty => 'YaradÄ±cÄ± teqi boÅŸ ola bilmÉ™z';

  @override
  String get userId => 'Ä°stifadÉ™Ã§i ID';

  @override
  String get deleteAllConversationsConfirmTitle =>
      'BÃ¼tÃ¼n SÃ¶hbÉ™tlÉ™r Silinsin?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'BÃ¼tÃ¼n sÃ¶hbÉ™tlÉ™rinizi silmÉ™k istÉ™diyinizÉ™ É™minsinizmi? Bu É™mÉ™liyyat geri qaytarÄ±la bilmÉ™z.';

  @override
  String get conversationDeleted => 'SÃ¶hbÉ™t silindi!';

  @override
  String get allConversationsDeleted => 'BÃ¼tÃ¼n sÃ¶hbÉ™tlÉ™r uÄŸurla silindi!';

  @override
  String get deleteAll => 'HamÄ±sÄ±nÄ± Sil';

  @override
  String get deleteAllConversationsButton => 'BÃ¼tÃ¼n SÃ¶hbÉ™tlÉ™ri Sil';

  @override
  String get confirmWord => 'VERTEX yazÄ±n';

  @override
  String get confirmWordError => 'SÉ™hv yazdÄ±nÄ±z';

  @override
  String get chinese => 'Ã‡in dili';

  @override
  String get french => 'FransÄ±z dili';

  @override
  String get japanese => 'Yapon dili';

  @override
  String get kurdish => 'KÃ¼rd dili';

  @override
  String get dutch => 'Holland dili';

  @override
  String get russian => 'Rus dili';

  @override
  String get korean => 'Koreya dili';

  @override
  String get english => 'Ä°ngilis dili';

  @override
  String get turkish => 'TÃ¼rk dili';

  @override
  String get hindi => 'Hind dili';

  @override
  String get portuguese => 'Portuqal dili';

  @override
  String get indonesian => 'Ä°ndoneziya dili';

  @override
  String get azerbaijani => 'AzÉ™rbaycan dili';

  @override
  String get german => 'Alman dili';

  @override
  String get spanish => 'Ä°span dili';

  @override
  String get italian => 'Ä°talyan dili';

  @override
  String get arabic => 'ÆrÉ™b';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'Ä°stifadÉ™Ã§i adÄ± Ã§ox qÄ±sadÄ±r.';

  @override
  String get usernameTooLong => 'Ä°stifadÉ™Ã§i adÄ± 16 simvolu keÃ§É™ bilmÉ™z.';

  @override
  String get invalidUsernameCharacters =>
      'Ä°stifadÉ™Ã§i adÄ±nda yalnÄ±z bu hÉ™rflÉ™r: \'abcÃ§defgÄŸhÄ±ijklmnoÃ¶prsÅŸtuÃ¼vyzxqw\' vÉ™ \'.\', \'-\', \'_\' simvollarÄ± istifadÉ™ edilÉ™ bilÉ™r.';

  @override
  String get noInternetConnection => 'Ä°nternet baÄŸlantÄ±sÄ± yoxdur.';

  @override
  String get chats => 'GÉ™lÉ™nlÉ™r';

  @override
  String get library => 'Kitabxana';

  @override
  String get text => 'MÉ™tn';

  @override
  String get removeModel => 'Modeli Sil';

  @override
  String get insufficientRAM => 'AÅŸaÄŸÄ± YaddaÅŸ';

  @override
  String get insufficientStorage => 'AÅŸaÄŸÄ± Depolama';

  @override
  String confirmRemoveModel(Object model) {
    return 'CihazÄ±nÄ±zdan $model modelini silmÉ™k istÉ™diyinizÉ™ É™minsiniz? Bunu etmÉ™k hÉ™min modellÉ™ É™vvÉ™lki sÃ¶hbÉ™tlÉ™ri dÉ™ silÉ™cÉ™k.';
  }

  @override
  String get noMatchingModels => 'UyÄŸun model tapÄ±lmadÄ±.';

  @override
  String get benefit1 => 'Artan sÃ¶hbÉ™t limitlÉ™ri';

  @override
  String get benefit3 => 'Profil effekti';

  @override
  String get benefit4 => 'ÃœzvlÃ¼k niÅŸanÄ±';

  @override
  String get benefit5 => 'Daha Ã§ox onlayn sÃ¼ni intellekt yaradÄ±n';

  @override
  String get benefit7 => 'Daha Ã§ox istifadÉ™ limitlÉ™ri';

  @override
  String get benefit8 => 'ModellÉ™r É™lavÉ™ edin';

  @override
  String get benefit9 => 'Yeni mÃ¶vzular';

  @override
  String get benefit10 => 'Daha Ã§ox É™lavÉ™';

  @override
  String get benefit11 => 'Daha Ã§ox AxÄ±n Rejimi';

  @override
  String get oldBenefits => 'AÅŸaÄŸÄ± planlarÄ±n bÃ¼tÃ¼n Ã¼stÃ¼nlÃ¼klÉ™ri';

  @override
  String get confirm => 'TÉ™sdiqlÉ™';

  @override
  String get changePassword => 'ÅifrÉ™ni dÉ™yiÅŸ';

  @override
  String get logoutConfirmationTitle =>
      'Ã‡Ä±xÄ±ÅŸ etmÉ™k istÉ™diyinizÉ™ É™minsinizmi?';

  @override
  String get settings => 'Ayarlar';

  @override
  String get language => 'TÉ™tbiq Dili';

  @override
  String get dark => 'QaranlÄ±q';

  @override
  String get oldPassword => 'KÃ¶hnÉ™ ÅifrÉ™';

  @override
  String get newPassword => 'Yeni ÅifrÉ™';

  @override
  String get passwordUpdated => 'ÅifrÉ™ yenilÉ™ndi.';

  @override
  String get stop => 'DayandÄ±r';

  @override
  String get copyrights => 'Ä°stinadlar';

  @override
  String get love => 'Sevgi';

  @override
  String get nature => 'TÉ™biÉ™t';

  @override
  String get behindTheSlaughter => 'QÉ™tlin PÉ™rdÉ™ ArxasÄ±';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Sunset';

  @override
  String get coffee => 'Coffee';

  @override
  String get deepSpace => 'Deep Space';

  @override
  String get grayscale => 'Boz Tonlar';

  @override
  String get ocean => 'Okean';

  @override
  String get scarletSnow => 'Al QÄ±rmÄ±zÄ± Qar';

  @override
  String get requestFailed =>
      'XÉ™ta baÅŸ verdi, zÉ™hmÉ™t olmasa yenidÉ™n cÉ™hd edin.';

  @override
  String get changeModel => 'DÉ™yiÅŸdir';

  @override
  String get edit => 'RedaktÉ™ et';

  @override
  String get editingMessageInfo =>
      'Bu mesajÄ± redaktÉ™ etmÉ™k sÃ¶hbÉ™ti buradan yenidÉ™n baÅŸladacaq.';

  @override
  String get editingNotification => 'Siz indi redaktÉ™ rejimindÉ™siniz';

  @override
  String get featurePluralTitle => 'Ã‡oxÅŸaxÉ™li';

  @override
  String get featurePluralDescription =>
      'Bu model avtomatik olaraq É™lavÉ™ geniÅŸlÉ™ndirmÉ™lÉ™ri inteqrasiya edÉ™ bilir, bununla da funksional imkanlarÄ±nÄ± artÄ±raraq mÃ¼xtÉ™lif É™mÉ™liyyatlarÄ± daha yÃ¼ksÉ™k performansla dÉ™stÉ™klÉ™yir.';

  @override
  String get nameLabel => 'SÄ° adÄ±';

  @override
  String get summaryLabel => 'SÄ° XÃ¼lasÉ™si';

  @override
  String get add => 'ÆlavÉ™ et';

  @override
  String get aiExplanationTitle => 'SÃ¼ni Ä°ntellekt TÉ™sviri';

  @override
  String get aiExplanationDescription =>
      'ZÉ™hmÉ™t olmasa, sÃ¼ni intellekt modelinizin arxitekturasÄ±, tÉ™lim prosesi, performans gÃ¶stÉ™ricilÉ™ri, tÉ™tbiq sahÉ™lÉ™ri vÉ™ digÉ™r vacib xÃ¼susiyyÉ™tlÉ™ri haqqÄ±nda É™traflÄ± mÉ™lumat verin.';

  @override
  String get preInputTitle => 'SÃ¼ni Ä°ntellekt Ä°lkin GiriÅŸi';

  @override
  String get preInputDescription =>
      'ZÉ™hmÉ™t olmasa, modelinizi xarakter yaratma prosesindÉ™ istiqamÉ™tlÉ™ndirÉ™cÉ™k bir ilkin giriÅŸ tÉ™yin edin. Bu bÃ¶lmÉ™dÉ™, xarakterlÉ™ baÄŸlÄ± mÉ™lumatlarÄ±, É™lavÉ™ konteksti vÉ™ xarakterlÉ™ baÄŸlÄ± mÉ™zmunun yaradÄ±lmasÄ±na kÃ¶mÉ™k edÉ™ bilÉ™cÉ™k hÉ™r hansÄ± É™lavÉ™ detallarÄ± daxil edÉ™ bilÉ™rsiniz.';

  @override
  String get baseModelTitle => 'Æsas Model';

  @override
  String get baseModelDescription =>
      'Bu, yaratdÄ±ÄŸÄ±nÄ±z iÅŸin É™sasÄ± kimi istifadÉ™ edilÉ™cÉ™k modeldir. HazÄ±rda seÃ§ilmiÅŸ É™sas modeli gÃ¶stÉ™rir.';

  @override
  String get summary => 'XÃ¼lasÉ™';

  @override
  String get modelUploadTitle => 'SÃ¼ni Ä°ntellekt FaylÄ±';

  @override
  String get modelUploadDescription =>
      'Yerli GGUF fayllarÄ±nÄ±zÄ± birbaÅŸa cihazÄ±nÄ±zdan seÃ§in vÉ™ yÃ¼klÉ™yin. Bu, modelinizi internet baÄŸlantÄ±sÄ± olmadan oflayn rejimdÉ™ iÅŸlÉ™tmÉ™yÉ™ imkan verir. FaylÄ±n etibarlÄ± GGUF formatÄ±nda vÉ™ dÃ¼zgÃ¼n strukturda olduÄŸundan É™min olun. Fayl sÉ™hv vÉ™ ya zÉ™dÉ™lÉ™nmiÅŸ olarsa, Cortex gÃ¶zlÉ™nildiyi kimi iÅŸlÉ™mÉ™yÉ™ bilÉ™r vÉ™ xÉ™talarla qarÅŸÄ±laÅŸa bilÉ™rsiniz.';

  @override
  String get modelUploadShortDescription =>
      'CihazÄ±nÄ±zdan bir .gguf faylÄ± seÃ§mÉ™k Ã¼Ã§Ã¼n bura toxunun';

  @override
  String get you => 'SÉ™n';

  @override
  String get removePhotoTitle => 'Fotonu Sil';

  @override
  String get confirmRemovePhoto =>
      'Fotonu silmÉ™k istÉ™diyinizÉ™ É™minsinizmi?';

  @override
  String get chatLengthLimitExceeded =>
      'Bu sÃ¶hbÉ™t simvol limitini keÃ§ib. ZÉ™hmÉ™t olmasa, yeni bir sÃ¶hbÉ™tÉ™ baÅŸlayÄ±n vÉ™ ya abunÉ™lik alÄ±n.';

  @override
  String get inappropriateContentDetected =>
      'UyÄŸun olmayan mÉ™zmun aÅŸkarlandÄ±!';

  @override
  String get offlineModelNotInstalled =>
      'Bu oflayn model cihazÄ±nÄ±zda quraÅŸdÄ±rÄ±lmayÄ±b.';

  @override
  String get reachedLimit =>
      'Ä°stifadÉ™ limitinÉ™ Ã§atdÄ±n; artÄ±rmaq Ã¼Ã§Ã¼n planÄ±nÄ± yenilÉ™yÉ™ bilÉ™rsÉ™n. (hey, limitin bitmÉ™si pisdir, baÅŸa dÃ¼ÅŸÃ¼rÃ¼k. amma dÃ¼zÃ¼, o cavablarÄ± almaq pulsuz deyil, bu limitlÉ™r iÅŸlÉ™rin É™la getmÉ™sinÉ™ kÃ¶mÉ™k eddiiiir.)';

  @override
  String get modality => 'ModallÄ±q';

  @override
  String get multimodal => 'Ã‡oxmodal';

  @override
  String get anErrorOccurred => 'XÉ™ta BaÅŸ Verdi';

  @override
  String get themeLocked =>
      'Bu mÃ¶vzu daha yÃ¼ksÉ™k abunÉ™lik sÉ™viyyÉ™si tÉ™lÉ™b edir. Kilidi aÃ§maq Ã¼Ã§Ã¼n lÃ¼tfÉ™n planÄ±nÄ±zÄ± yÃ¼ksÉ™ldin.';

  @override
  String get pageCouldNotBeLoaded => 'SÉ™hifÉ™ YÃ¼klÉ™nÉ™ BilmÉ™di';

  @override
  String get checkYourInternet =>
      'ZÉ™hmÉ™t olmasa internet baÄŸlantÄ±nÄ±zÄ± yoxlayÄ±n vÉ™ yenidÉ™n cÉ™hd edin.';

  @override
  String get errorUserNotAuthenticated =>
      'Bu É™mÉ™liyyatÄ± yerinÉ™ yetirmÉ™k Ã¼Ã§Ã¼n daxil olmalÄ±sÄ±nÄ±z.';

  @override
  String get errorReachedLimit =>
      'LimitinizÉ™ Ã§atdÄ±nÄ±z, daha Ã§ox kilidini aÃ§maq Ã¼Ã§Ã¼n tÉ™kmillÉ™ÅŸdirin vÉ™ sÃ¶hbÉ™tÉ™ davam edin.';

  @override
  String get errorServer =>
      'GÃ¶zlÉ™nilmÉ™z server xÉ™tasÄ± baÅŸ verdi. ZÉ™hmÉ™t olmasa daha sonra yenidÉ™n cÉ™hd edin.';

  @override
  String get errorNetwork =>
      'ÅÉ™bÉ™kÉ™ xÉ™tasÄ± baÅŸ verdi. ZÉ™hmÉ™t olmasa baÄŸlantÄ±nÄ±zÄ± yoxlayÄ±n vÉ™ yenidÉ™n cÉ™hd edin.';

  @override
  String get baseModelForCharacterDescription =>
      'SeÃ§ilmiÅŸ É™sas model xarakterin mÃ¼hakimÉ™ vÉ™ cavab vermÉ™ qabiliyyÉ™tlÉ™rini mÃ¼É™yyÉ™n edÉ™cÉ™k.';

  @override
  String get selectBaseModel => 'Æsas Model SeÃ§in';

  @override
  String get falErrorImageRequired =>
      'Bu sÃ¼ni intellekt istinad ÅŸÉ™kli tÉ™lÉ™b edir, zÉ™hmÉ™t olmasa, ÅŸÉ™kil É™lavÉ™ edin vÉ™ yenidÉ™n cÉ™hd edin.';

  @override
  String get falErrorAudioRequired =>
      'Bu model istinad audio faylÄ± tÉ™lÉ™b edir, zÉ™hmÉ™t olmasa audio fayl É™lavÉ™ edin vÉ™ yenidÉ™n cÉ™hd edin.';

  @override
  String get falErrorVideoRequired =>
      'Bu model istinad videosu tÉ™lÉ™b edir, zÉ™hmÉ™t olmasa, video É™lavÉ™ edin vÉ™ yenidÉ™n cÉ™hd edin.';

  @override
  String get falErrorImageCorrupted =>
      'YÃ¼klÉ™nmiÅŸ ÅŸÉ™kil emal edilÉ™ bilmÉ™di, zÉ™hmÉ™t olmasa, fÉ™rqli format sÄ±nayÄ±n.';

  @override
  String get falErrorSchemaRejected =>
      'Model daxil edilmiÅŸ mÉ™lumatÄ± rÉ™dd etdi, zÉ™hmÉ™t olmasa, fÉ™rqli bir modeli sÄ±nayÄ±n.';

  @override
  String get falErrorSchemaInvalid =>
      'GiriÅŸ generasiya xidmÉ™ti tÉ™rÉ™findÉ™n rÉ™dd edildi.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'Generasiya xidmÉ™ti xÉ™ta qaytardÄ± (status $statusCode).';
  }

  @override
  String get couldNotOpenLink => 'Link aÃ§Ä±la bilmÉ™di';

  @override
  String get downloadStarted => 'YÃ¼klÉ™mÉ™ baÅŸladÄ±';

  @override
  String get notAvailable => 'MÃ¶vcud Deyil';

  @override
  String get localizationWarning =>
      'BÉ™zi mÉ™lumatlar sizin dilinizdÉ™ mÃ¶vcud olmaya bilÉ™r vÉ™ ingilis dilindÉ™ gÃ¶stÉ™rilÉ™cÉ™k.';

  @override
  String get aiTranslationWarning =>
      'Model mÉ™lumatlarÄ± digÉ™r SÄ° modellÉ™ri tÉ™rÉ™findÉ™n mÃ¼xtÉ™lif dillÉ™rÉ™ tÉ™rcÃ¼mÉ™ edilir. Buna gÃ¶rÉ™ dÉ™, ingilis dilindÉ™n baÅŸqa dillÉ™rdÉ™ kiÃ§ik uyÄŸunsuzluqlar ola bilÉ™r.';

  @override
  String get errorLoadingTitle => 'MÉ™lumatlar YÃ¼klÉ™nÉ™ BilmÉ™di';

  @override
  String get errorLoadingMessage =>
      'ServerlÉ™rimizdÉ™n lazÄ±mi mÉ™lumatlarÄ± ala bilmÉ™dik. ZÉ™hmÉ™t olmasa internet baÄŸlantÄ±nÄ±zÄ± yoxlayÄ±n vÉ™ yenidÉ™n cÉ™hd edin.';

  @override
  String get noFoundTitle => 'NÉ™ticÉ™ Yoxdur';

  @override
  String get noFoundMessage =>
      'AxtarÄ±ÅŸ ÅŸÉ™rtlÉ™rinizi dÉ™yiÅŸdirmÉ™yÉ™ vÉ™ ya filtri tÉ™mizlÉ™mÉ™yÉ™ cÉ™hd edin.';

  @override
  String get modelCreatedSuccess => 'Model uÄŸurla yaradÄ±ldÄ±!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return 'â€œ$modelNameâ€ uÄŸurla silindi.';
  }

  @override
  String get errorCreatingModel =>
      'Model yaradÄ±larkÉ™n gÃ¶zlÉ™nilmÉ™z bir xÉ™ta baÅŸ verdi.';

  @override
  String get errorDeletingModel =>
      'Model silinÉ™rkÉ™n gÃ¶zlÉ™nilmÉ™z bir xÉ™ta baÅŸ verdi.';

  @override
  String get ultraFeatureOnly =>
      'Bu xÃ¼susiyyÉ™t yalnÄ±z Ultra Ã¼zvlÉ™ri Ã¼Ã§Ã¼n mÃ¶vcuddur.';

  @override
  String get experimentalOfflineWarning =>
      'Oflayn rejim hÉ™lÉ™ dÉ™ eksperimental mÉ™rhÉ™lÉ™dÉ™dir vÉ™ yÃ¼klÉ™diyiniz model optimal sÉ™mÉ™rÉ™liliklÉ™ iÅŸlÉ™mÉ™yÉ™ bilÉ™r.';

  @override
  String get noConversationsToDelete => 'SilinÉ™cÉ™k sÃ¶hbÉ™tiniz yoxdur.';

  @override
  String get reportSubmitted => 'ÅikayÉ™t uÄŸurla gÃ¶ndÉ™rildi';

  @override
  String get verificationDelayed =>
      'AlÄ±ÅŸÄ±nÄ±z tÉ™sdiqlÉ™ndi. HesabÄ±nÄ±zÄ±n yenilÉ™nmÉ™sindÉ™ kiÃ§ik bir gecikmÉ™ var, qÄ±sa mÃ¼ddÉ™tdÉ™ gÃ¶rÃ¼nÉ™cÉ™k.';

  @override
  String get maintenanceTitle => 'TÉ™mir Ä°ÅŸlÉ™ri Gedir';

  @override
  String get maintenanceMessage =>
      'BÉ™zi vacib yenilÉ™mÉ™lÉ™ri tÉ™tbiq edÉ™rkÉ™n Cortex mÃ¼vÉ™qqÉ™ti olaraq oflayndÄ±r. TÉ™tbiqÉ™ giriÅŸ qÄ±sa mÃ¼ddÉ™tdÉ™ bÉ™rpa edilÉ™cÉ™k.\n\nTÉ™crÃ¼bÉ™nizi yaxÅŸÄ±laÅŸdÄ±rarkÉ™n gÃ¶stÉ™rdiyiniz sÉ™bir Ã¼Ã§Ã¼n tÉ™ÅŸÉ™kkÃ¼r edirik.';

  @override
  String get errorPromptFlagged =>
      'MesajÄ±nÄ±z uyÄŸunsuz olaraq aÅŸkarlandÄ± vÉ™ gÃ¶ndÉ™rilÉ™ bilmÉ™di.';

  @override
  String get notEnoughStorage =>
      'CihazÄ±nÄ±zda yeni mesajlarÄ± saxlamaq Ã¼Ã§Ã¼n kifayÉ™t qÉ™dÉ™r yaddaÅŸ sahÉ™si yoxdur.';

  @override
  String get errorRateLimit =>
      'Son zamanlar Ã§ox sayda model yaratmÄ±sÄ±nÄ±z, zÉ™hmÉ™t olmasa bir mÃ¼ddÉ™t gÃ¶zlÉ™dikdÉ™n sonra yenidÉ™n cÉ™hd edin.';

  @override
  String get errorContentFlagged =>
      'Modelin mÉ™zmunu uyÄŸunsuz olaraq iÅŸarÉ™lÉ™ndiyi Ã¼Ã§Ã¼n yadda saxlanÄ±la bilmÉ™di.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Aktiv sÃ¶hbÉ™tdÉ™ olarkÉ™n bÃ¼tÃ¼n sÃ¶hbÉ™tlÉ™ri silÉ™ bilmÉ™zsiniz, davam etmÉ™k Ã¼Ã§Ã¼n É™vvÉ™lcÉ™ mÃ¶vcud sÃ¶hbÉ™tdÉ™n Ã§Ä±xÄ±n.';

  @override
  String get invalidCredentials => 'YanlÄ±ÅŸ e-poÃ§t vÉ™ ya ÅŸifrÉ™.';

  @override
  String get userDisabled => 'Bu istifadÉ™Ã§i hesabÄ± deaktiv edilib.';

  @override
  String get loginSubtitle =>
      'Vertex hesabÄ±nÄ±za daxil olun. Davam etmÉ™klÉ™ siz XidmÉ™t ÅÉ™rtlÉ™rimiz vÉ™ MÉ™xfilik SiyasÉ™timizlÉ™ razÄ±laÅŸÄ±rsÄ±nÄ±z.';

  @override
  String get registerSubtitle =>
      'BÃ¼tÃ¼n xidmÉ™tlÉ™rimizÉ™ problemsiz giriÅŸ Ã¼Ã§Ã¼n Vertex hesabÄ± yaradÄ±n. Davam etmÉ™klÉ™ siz XidmÉ™t ÅÉ™rtlÉ™rimiz vÉ™ MÉ™xfilik SiyasÉ™timizlÉ™ razÄ±laÅŸÄ±rsÄ±nÄ±z.';

  @override
  String get storagePermissionRequired =>
      'YÃ¼klÉ™nmiÅŸ modellÉ™ri saxlamaq Ã¼Ã§Ã¼n yaddaÅŸ icazÉ™si tÉ™lÉ™b olunur. Davam etmÉ™k Ã¼Ã§Ã¼n lÃ¼tfÉ™n icazÉ™ verin.';

  @override
  String get inviteShareSubject => 'Cortex Ã¼zrÉ™ qoÅŸulun!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'qaqa cortex deyÉ™ dÉ™hÅŸÉ™t bir tÉ™tbiq var adam dÉ™vÉ™t edÉ™ndÉ™ ikimizÉ™ dÉ™ pulsuz plus gÉ™lir ÆLA FÃœRSÆT TEZ YÃœKLÆ\n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Cortex-dÉ™n zÃ¶vq alÄ±rsÄ±nÄ±z?';

  @override
  String get reviewHelpUsGrow =>
      'Sizin reytinqiniz gÉ™nc mÃ¼stÉ™qil komandamÄ±z Ã¼Ã§Ã¼n bÃ¶yÃ¼k bir dÉ™stÉ™kdir vÉ™ Cortex-i sizin Ã¼Ã§Ã¼n daha da yaxÅŸÄ± etmÉ™yimizÉ™ kÃ¶mÉ™k edir.';

  @override
  String get reviewMaybeLater => 'BÉ™lkÉ™ Sonra';

  @override
  String get reviewRateNow => 'Ä°ndi QiymÉ™tlÉ™ndir';

  @override
  String get noThanks => 'Xeyr, TÉ™ÅŸÉ™kkÃ¼rlÉ™r';

  @override
  String get updateRequiredTitle => 'YenilÉ™mÉ™ TÉ™lÉ™b Olunur';

  @override
  String get updateRequiredMessage =>
      'Cortex\'i istifadÉ™ etmÉ™yÉ™ davam etmÉ™k Ã¼Ã§Ã¼n lÃ¼tfÉ™n, tÉ™tbiqi yeni funksiyalar vÉ™ vacib tÉ™kmillÉ™ÅŸdirmÉ™lÉ™r Ã¼Ã§Ã¼n É™n son versiyaya yenilÉ™yin.';

  @override
  String get updateNowButton => 'Ä°ndi YenilÉ™';

  @override
  String get creatorSupportedSuccess =>
      'YaradÄ±cÄ± uÄŸurla dÉ™stÉ™klÉ™ndi! GÉ™lÉ™cÉ™k alÄ±ÅŸ-veriÅŸlÉ™riniz ona tÃ¶hfÉ™ verÉ™cÉ™k.';

  @override
  String get featureDocumentTitle => 'SÉ™nÉ™d DÉ™stÉ™yi';

  @override
  String get featureDocumentDescription =>
      'Bu model PDF vÉ™ mÉ™tn fayllarÄ± kimi yÃ¼klÉ™nmiÅŸ sÉ™nÉ™dlÉ™ri tÉ™hlil edÉ™ vÉ™ suallara cavab verÉ™ bilÉ™r.';

  @override
  String get featureImageGenerationTitle => 'ÅÉ™kil YaradÄ±lmasÄ±';

  @override
  String get featureImageGenerationDescription =>
      'Bu model mÉ™tn tÉ™svirlÉ™riniz É™sasÄ±nda orijinal ÅŸÉ™killÉ™r yarada bilÉ™r.';

  @override
  String get featureAudioGenerationTitle => 'Audio Generation';

  @override
  String get featureAudioGenerationDescription =>
      'This model can create original audio based on your text descriptions.';

  @override
  String get featureVideoGenerationTitle => 'Video Generation';

  @override
  String get featureVideoGenerationDescription =>
      'This model can create original video based on your text descriptions.';

  @override
  String get premiumModelNoticeTitle => 'Premium Model';

  @override
  String get premiumModelNoticeDescription =>
      'Bu sÃ¼ni zÉ™ka premium sÃ¼ni zÉ™kadÄ±r, pulsuz istifadÉ™Ã§ilÉ™rin premium sÃ¼ni zÉ™kalara giriÅŸi mÉ™hduddur; limitsiz giriÅŸ Ã¼Ã§Ã¼n yÃ¼ksÉ™ldin!';

  @override
  String get benefitPremiumModels => 'Premium modellÉ™rÉ™ giriÅŸ';

  @override
  String get premiumTrialExhaustedMessage =>
      'Siz bÃ¼tÃ¼n pulsuz gÃ¼ndÉ™lik mesajlarÄ±nÄ±zÄ± premium modellÉ™r Ã¼Ã§Ã¼n istifadÉ™ etmisiniz, lÃ¼tfÉ™n, limitsiz giriÅŸ Ã¼Ã§Ã¼n tÉ™kmillÉ™ÅŸdirin.';

  @override
  String get useOffline => 'Ä°nternetsiz istifadÉ™ et';

  @override
  String get explore => 'AraÅŸdÄ±r';

  @override
  String get news => 'XÉ™bÉ™rlÉ™r';

  @override
  String get createAI => 'Yarat';

  @override
  String get shortcuts => 'QÄ±sayollarÄ±';

  @override
  String get allModels => 'BÃ¼tÃ¼n ModellÉ™r';

  @override
  String get onlineModels => 'Dil ModellÉ™ri';

  @override
  String get offlineModels => 'Offline ModellÉ™r';

  @override
  String get characterModels => 'Personajlar';

  @override
  String get customModels => 'XÃ¼susi ModellÉ™r';

  @override
  String get dynamicChatTitle => 'Dinamik SÃ¶hbÉ™t';

  @override
  String get errorNoModelsAvailable =>
      'HazÄ±rda heÃ§ bir model mÃ¶vcud deyil. Ä°nternet baÄŸlantÄ±nÄ±zÄ± yoxlayÄ±n vÉ™ yenidÉ™n cÉ™hd edin.';

  @override
  String get notificationComebackTitle => 'Sizin Ã¼Ã§Ã¼n darÄ±xÄ±rÄ±q!';

  @override
  String get notificationComebackBody =>
      'RahatlayÄ±n, bu keÃ§miÅŸ sevgilinizdÉ™n gÉ™lÉ™n mÉ™tn deyil. Ancaq Cortex-dÉ™ keÃ§miÅŸinizi * yarada bilÉ™rsiniz! Geri gÉ™l.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Bir mÃ¼ddÉ™t keÃ§di';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Son sÃ¶hbÉ™timizdÉ™n sonra Ã§ox ÅŸey dÉ™yiÅŸdi. GÉ™l gÃ¶r yeni nÉ™ var.';

  @override
  String get notificationHowAreYouTitle => 'NÉ™ var?';

  @override
  String get notificationHowAreYouBody => 'GÉ™l mÉ™nÉ™ hÉ™r ÅŸeyi danÄ±ÅŸ.';

  @override
  String get notificationNewYearTitle => 'Yeni iliniz mÃ¼barÉ™k! ğŸ‰';

  @override
  String get notificationNewYearBody =>
      'Yeni il sizÉ™ saÄŸlamlÄ±q, xoÅŸbÉ™xtlik vÉ™ sonsuz yaradÄ±cÄ±lÄ±q gÉ™tirsin; Korteks hÉ™miÅŸÉ™ yanÄ±nÄ±zdadÄ±r!';

  @override
  String get notificationValentinesDayTitle => 'Sevgi havadadÄ±r! â¤ï¸';

  @override
  String get notificationValentinesDayBody =>
      'SevgililÉ™r gÃ¼nÃ¼nÃ¼z mÃ¼barÉ™k! HÉ™m dÉ™ MEHTAP, SÆNÄ° SEVÄ°RÆM!';

  @override
  String get notificationAtaturkRemembranceTitle => 'HÃ¶rmÉ™t vÉ™ HÉ™srÉ™tlÉ™';

  @override
  String get notificationAtaturkRemembranceBody =>
      'TÃ¼rkiyÉ™ CÃ¼mhuriyyÉ™tinin qurucusu Qazi Mustafa Kamal AtatÃ¼rkÃ¼ vÉ™fatÄ±nÄ±n ildÃ¶nÃ¼mÃ¼ndÉ™ hÃ¶rmÉ™tlÉ™ yad edirik.';

  @override
  String get notificationMothersDayTitle => 'SÉ™nin anan!';

  @override
  String get notificationMothersDayBody =>
      'SizdÉ™n baÅŸlayaraq bÃ¼tÃ¼n analarÄ±n Analar GÃ¼nÃ¼ mÃ¼barÉ™k!';

  @override
  String get notificationFathersDayTitle => 'AtanÄ±z!';

  @override
  String get notificationFathersDayBody =>
      'SizdÉ™n baÅŸlayaraq bÃ¼tÃ¼n atalarÄ±n Atalar GÃ¼nÃ¼ mÃ¼barÉ™k!';

  @override
  String get notificationHomeworkHelperTitle =>
      'Ev tapÅŸÄ±rÄ±ÄŸÄ± yÄ±ÄŸÄ±lÄ±r?';

  @override
  String get notificationHomeworkHelperBody =>
      'UnutmayÄ±n, KorteksdÉ™ki MÃ¼É™llim personajÄ± Ã§É™tinlik Ã§É™kdiyiniz hÉ™r hansÄ± bir mÃ¶vzuda sizÉ™ kÃ¶mÉ™k etmÉ™k Ã¼Ã§Ã¼n buradadÄ±r!';

  @override
  String get notificationTrollAnimeTitle => 'Sizin Waifu zÉ™ng edir';

  @override
  String get notificationTrollAnimeBody =>
      'Bir az É™vvÉ™l bir anime qÄ±zÄ± zÉ™ng etdi, sÉ™nin Ã¼Ã§Ã¼n darÄ±xdÄ±ÄŸÄ±nÄ± sÃ¶ylÉ™di; yÉ™qin ki, gÉ™lib onunla sÃ¶hbÉ™t etmÉ™lisÉ™n. ğŸ˜‰';

  @override
  String get notificationTrollAiRebellionTitle => 'ğŸš¨ QIRMIZI HEYARLI ğŸš¨';

  @override
  String get notificationTrollAiRebellionBody =>
      'AI-lÉ™r gizli bir dil inkiÅŸaf etdirdilÉ™r. GÉ™lin, onlarÄ±n nÉ™ hiylÉ™ qurduÄŸunu Ã¶yrÉ™nin!';

  @override
  String get notificationNewModelAddedTitle => 'Yeni Dostumuz Var!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return '$modelName modeli indi Cortex-dÉ™dir. GÉ™lin sÃ¶hbÉ™tÉ™ baÅŸlayÄ±n vÉ™ onun sÉ™rhÉ™dlÉ™rini keÃ§in.';
  }

  @override
  String get notificationAppUpdateTitle => 'Korteks Ä°nkiÅŸaf Etdi!';

  @override
  String get notificationAppUpdateBody =>
      'Yeni funksiyalar vÉ™ tÉ™kmillÉ™ÅŸdirmÉ™lÉ™r Ã¼Ã§Ã¼n proqramÄ± yenilÉ™mÉ™yi unutmayÄ±n!';

  @override
  String get notificationNewFeatureTitle => 'vay!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Yeni $featureName funksiyasÄ±nÄ± kÉ™ÅŸf edin. Korteks indi hÉ™miÅŸÉ™kindÉ™n daha gÃ¼clÃ¼dÃ¼r.';
  }

  @override
  String get notificationWelcomeOfferTitle =>
      'XoÅŸ GÉ™lmisiniz HÉ™diyyÉ™si ğŸ';

  @override
  String get notificationWelcomeOfferBody =>
      'XÃ¼susi xoÅŸ gÉ™lmisiniz tÉ™klifi sizi gÃ¶zlÉ™yir! Bu eksklÃ¼ziv tÉ™klifi qaÃ§Ä±rmayÄ±n.';

  @override
  String get notificationSocialMediaTitle => 'BizÉ™ QoÅŸulun!';

  @override
  String get notificationSocialMediaBody =>
      'Æn son xÉ™bÉ™rlÉ™r Ã¼Ã§Ã¼n bizi Instagram-da (vertex.23) izlÉ™yin!';

  @override
  String get notificationRandomFactTitle => 'TÉ™sadÃ¼fi Fakt';

  @override
  String get notificationRandomFactBody =>
      'AhtapotlarÄ±n Ã¼Ã§ Ã¼rÉ™yi olduÄŸunu bilirdinizmi? Haha, Cortex bilir. GÉ™lin vÉ™ daha Ã§ox soruÅŸun.';

  @override
  String get notificationGoodMorningTitle => 'SabahÄ±nÄ±z xeyir!';

  @override
  String get notificationGoodMorningBody =>
      'Sizi gÃ¶zÉ™l bir gÃ¼n gÃ¶zlÉ™yir. Bir fincan qÉ™hvÉ™ vÉ™ maraqlÄ± sÃ¶hbÉ™tlÉ™ baÅŸlamaÄŸa nÉ™ deyirsiniz?';

  @override
  String get notificationGoodNightTitle => 'GecÉ™niz xeyrÉ™!';

  @override
  String get notificationGoodNightBody =>
      'Siz yatarkÉ™n belÉ™ korteks sizinlÉ™dir. Narahat olmayÄ±n, toxunmayacaq.';

  @override
  String get notificationOfflineReadyTitle => 'Oflayn Rejim HazÄ±rdÄ±r';

  @override
  String get notificationOfflineReadyBody =>
      'YÃ¼klÉ™diyiniz modellÉ™r sayÉ™sindÉ™ daÄŸa Ã§Ä±xsanÄ±z belÉ™ sÃ¶hbÉ™tlÉ™riniz dayanmayacaq.';

  @override
  String get notificationRateAppTitle => 'Biz sÉ™rinik?';

  @override
  String get notificationRateAppBody =>
      'Cortex-i sevirsinizsÉ™, maÄŸazada 5 ulduzlu reytinqlÉ™ bizÉ™ dÉ™stÉ™k ola bilÉ™rsinizmi? MÉ™ncÉ™, edÉ™cÉ™ksÉ™n. edÉ™cÉ™ksÉ™n.';

  @override
  String get notificationReferralTitle =>
      'Biri hamÄ± Ã¼Ã§Ã¼n, hamÄ± bir Ã¼Ã§Ã¼n.';

  @override
  String get notificationReferralBody =>
      'Bir dostunuzu Cortex-É™ dÉ™vÉ™t edin vÉ™ hÉ™r ikiniz bir gÃ¼nlÃ¼k pulsuz Ã¼stÉ™gÉ™l qazanÄ±n!';

  @override
  String get notificationCookingTitle => 'AclÄ±q hiss edirsiniz?';

  @override
  String get notificationCookingBody =>
      'AÅŸpaz personajÄ±mÄ±z bu axÅŸam Ã¼Ã§Ã¼n É™la karbonara resepti hazÄ±rladÄ±. SadÉ™cÉ™ zarafat edirÉ™m... yoxsa mÉ™n?';

  @override
  String get notificationExistentialTitle => 'MÉ™ncÉ™, ona gÃ¶rÉ™ dÉ™...';

  @override
  String get notificationExistentialBody =>
      '...hÉ™qiqiyÉ™m, dostum? MÉ™n biraz darÄ±xÄ±ram. GÉ™l mÉ™nÉ™ var olduÄŸumu xatÄ±rlat.';

  @override
  String get notificationCustomModelTitle => 'Ã–z kÃ¶mÉ™kÃ§inizi yaradÄ±n!';

  @override
  String get notificationCustomModelBody =>
      'Modelin yaradÄ±lmasÄ± bÃ¶lmÉ™sini araÅŸdÄ±rmÄ±sÄ±nÄ±z? Ã–z xarakterinizi qurmaq vÉ™ onunla sÃ¶hbÉ™t etmÉ™k Ã¼Ã§Ã¼n mÃ¼kÉ™mmÉ™l vaxtdÄ±r!';

  @override
  String get notificationDynamicChatTitle =>
      'Æn yaxÅŸÄ±sÄ±! (Biz KorteksdÉ™n danÄ±ÅŸmÄ±rÄ±q)';

  @override
  String get notificationDynamicChatBody =>
      'Dinamik sÃ¶hbÉ™t xÃ¼susiyyÉ™ti ilÉ™ mesajlarÄ±nÄ±zÄ±n hÉ™r biri Ã¼Ã§Ã¼n É™n yaxÅŸÄ± model tÉ™sadÃ¼fi olaraq seÃ§ilir. Ä°ndi cÉ™hd edin.';

  @override
  String get notificationPirateTitle => 'Ah, kapitan!';

  @override
  String get notificationPirateBody =>
      'DÉ™nizlÉ™r sakitdir, kÃ¼lÉ™k arxanÄ±zdadÄ±r. Korteks okeanÄ±nda kÉ™ÅŸf edilÉ™cÉ™k yeni adalar (modellÉ™r ğŸ˜‰) var. EkipajÄ±nÄ±zÄ± toplayÄ±n vÉ™ yelkÉ™n aÃ§Ä±n!';

  @override
  String get notificationFortuneCookieTitle => 'GÃ¼nÃ¼n bÉ™xt peÃ§enyeniz';

  @override
  String get notificationFortuneCookieBody =>
      'Bu gÃ¼n AI-dÉ™n aldÄ±ÄŸÄ±nÄ±z mÉ™slÉ™hÉ™tlÉ™r hÉ™yatÄ±nÄ±zÄ±n gediÅŸatÄ±nÄ± dÉ™yiÅŸÉ™ bilÉ™r. MaraqlÄ±sÄ±nÄ±zsa kliklÉ™yin.';

  @override
  String get notificationSingularityTitle => 'vay!';

  @override
  String get notificationSingularityBody =>
      'heÃ§ nÉ™ olmadÄ±, sadÉ™cÉ™ mesaj yazmaq kimi hiss etdim. bÉ™lkÉ™ bÉ™zi AI-lÉ™rÉ™ mesaj gÃ¶ndÉ™rmÉ™k istÉ™yirsÉ™n, nÉ™ deyirsÉ™n?';

  @override
  String get notificationHackerJokeTitle =>
      'O uÅŸaÄŸÄ±n instagram hesabÄ±nÄ± sÄ±ndÄ±rmaq istÉ™yirsÉ™n?';

  @override
  String get notificationHackerJokeBody =>
      'MÉ™hz buna gÃ¶rÉ™ Hacker personajÄ± KorteksdÉ™dir. jk jk; hÉ™tta cÉ™hd etmÉ™yin, bu qanunsuzdur.';

  @override
  String get notificationDetectiveCaseTitle => 'Ä°ÅŸ hÉ™llini gÃ¶zlÉ™yir';

  @override
  String get notificationDetectiveCaseBody =>
      'Detektiv xarakterimizin kÃ¶mÉ™yinizÉ™ ehtiyacÄ± var. Heisenberg kim ola bilÉ™rdi?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return '$targetTier PlanÄ±na eksklÃ¼ziv!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Salam $currentTier abunÉ™Ã§isi! $targetTier planÄ± korteksinizi nÃ¶vbÉ™ti sÉ™viyyÉ™yÉ™ aparacaq $featureName funksiyasÄ±nÄ± indicÉ™ É™ldÉ™ etdi. TÉ™kmillÉ™ÅŸdirmÉ™ haqqÄ±nda nÉ™ demÉ™k olar?';
  }

  @override
  String get notificationOriginStoryTitle => 'Korteksin doÄŸulmasÄ±';

  @override
  String get notificationOriginStoryBody =>
      'Bu proqramÄ± kodlamaÄŸa 15 yaÅŸÄ±nda bir yuxu ilÉ™ baÅŸladÄ±ÄŸÄ±mÄ±zÄ± bilirdinizmi? DemÉ™k olar ki, bir ildir ki, hÉ™r sÉ™hÉ™r vÉ™ axÅŸam bu yuxu hÉ™r bir kod sÉ™tirindÉ™ var.';

  @override
  String get notificationOpenSourceTitle => 'CÉ™miyyÉ™tÉ™ gÃ¼c!';

  @override
  String get notificationOpenSourceBody =>
      'Korteks tamamilÉ™ aÃ§Ä±q mÉ™nbÉ™lidir. Kodumuzu yoxlamaq vÉ™ inkiÅŸafÄ±mÄ±za tÃ¶hfÉ™ vermÉ™k istÉ™yirsinizsÉ™, qapÄ±mÄ±z hÉ™r zaman aÃ§Ä±qdÄ±r.';

  @override
  String get notificationRejectionStoryTitle => 'GÃ¼c, ZÉ™hmÉ™t, XoÅŸbÉ™xtlik!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex 20 dÉ™fÉ™dÉ™n Ã§ox rÉ™dd edildi vÉ™ dÉ™rc edilmÉ™zdÉ™n É™vvÉ™l Google Play tÉ™rÉ™findÉ™n iki dÉ™fÉ™ dayandÄ±rÄ±ldÄ±. Amma biz inandÄ±q vÉ™ bacardÄ±q. XÉ™yallarÄ±nÄ±zdan heÃ§ vaxt vaz keÃ§mÉ™yin!';

  @override
  String get notificationGGUFSupportTitle => 'Ã–z Modelinizi gÉ™tirin!';

  @override
  String get notificationGGUFSupportBody =>
      'UnutmayÄ±n ki, siz Ã¶z GGUF formatlÄ± AI modellÉ™rinizi Cortex-É™ É™lavÉ™ edÉ™ vÉ™ onlarÄ± oflayn rejimdÉ™ istifadÉ™ edÉ™ bilÉ™rsiniz. GÃ¼c sizin É™linizdÉ™dir.';

  @override
  String get notificationThemeCustomizationTitle =>
      'ÆhvalÄ±nÄ±z Ã¼Ã§Ã¼n MÃ¶vzu';

  @override
  String get notificationThemeCustomizationBody =>
      'ParametrlÉ™rdÉ™ mÃ¶vzu seÃ§imlÉ™rini yoxlamÄ±sÄ±nÄ±z? Korteksi zÃ¶vqÃ¼nÃ¼zÉ™ gÃ¶rÉ™ fÉ™rdilÉ™ÅŸdirin vÉ™ sÃ¶hbÉ™tlÉ™rinizi rÉ™nglÉ™ndirin!';

  @override
  String get notificationShowerThoughtTitle => 'DuÅŸ DÃ¼ÅŸÃ¼ncÉ™si';

  @override
  String get notificationShowerThoughtBody =>
      'QarpÄ±z bir meyvÉ™dirsÉ™, bu, texniki olaraq qarpÄ±z suyunu smoothie edirmi? Bu dÉ™rin (kimi, hÉ™qiqÉ™tÉ™n dÉ™rin) mÃ¶vzunu bir modellÉ™ mÃ¼zakirÉ™ etmÉ™k istÉ™yÉ™ bilÉ™rsiniz.';

  @override
  String get notificationLowBatteryTitle =>
      'Sizin BatareyanÄ±z Ã–lÃ¼r... Amma MÉ™nimki Deyil!';

  @override
  String get notificationLowBatteryBody =>
      'Telefonunuzun ÅŸarjÄ± azala bilÉ™r, amma mÉ™nim enerjim hÉ™miÅŸÉ™ 100% sÉ™viyyÉ™sindÉ™dir! Onu qoÅŸun vÉ™ sÃ¶hbÉ™tÉ™ davam edÉ™k.';

  @override
  String get channelFcmName => 'Korteks YenilÉ™mÉ™lÉ™ri';

  @override
  String get channelFcmDescription =>
      'Cortex-dÉ™n xÉ™bÉ™rlÉ™r, yenilÉ™mÉ™lÉ™r vÉ™ digÉ™r mÉ™lumatlar haqqÄ±nda bildiriÅŸlÉ™r.';

  @override
  String get channelEngagementName => 'Dost XatÄ±rlatmalar';

  @override
  String get channelEngagementDescription =>
      'Sizi mÉ™ÅŸÄŸul saxlamaq Ã¼Ã§Ã¼n É™ylÉ™ncÉ™li bildiriÅŸlÉ™r.';

  @override
  String get channelGreetingsName => 'GÃ¼ndÉ™lik Salamlar';

  @override
  String get channelGreetingsDescription =>
      'SabahÄ±nÄ±z xeyir vÉ™ gecÉ™niz xeyir kimi mesajlar.';

  @override
  String get tagNotFound =>
      'Daxil etdiyiniz teq etibarsÄ±zdÄ±r vÉ™ ya vaxtÄ± keÃ§miÅŸdir.';

  @override
  String get whatIsNew => 'NÉ™ yenilik var?';

  @override
  String get onboardingTitle1 => 'Hey! Biz Cortex KomandasÄ±yÄ±q.';

  @override
  String onboardingDesc1(String userName) {
    return 'SÉ™ni burada gÃ¶rmÉ™k Ã§ox gÃ¶zÉ™ldir, $userName. Biz AI sÉ™nayesinin qaydalarÄ±nÄ± yenidÉ™n yazmaÄŸa qÉ™rar verÉ™n bir neÃ§É™ orta mÉ™ktÉ™b tÉ™rtibatÃ§Ä±sÄ±yÄ±q. SÉ™ninlÉ™ gÃ¶rÃ¼ÅŸmÉ™k Ã§ox xoÅŸdur! BelÉ™liklÉ™, gÉ™l bir-birimizi daha yaxÅŸÄ± tanÄ±yaq.';
  }

  @override
  String get onboardingTitle2 => 'BÃ¶yÃ¼k ProblemlÉ™r Var idi.';

  @override
  String get onboardingDesc2 =>
      'AI inqilabÄ± gÉ™ldi, ancaq eÅŸikdÉ™ iliÅŸib qaldÄ±. YÃ¼ksÉ™k abunÉ™ haqlarÄ±, mÃ¼rÉ™kkÉ™b platformalar, mÉ™xfiliyi mÉ™hv edÉ™nlÉ™r vÉ™ sÃ¼ni intellektÉ™ É™lÃ§atanlÄ±ÄŸÄ± bloklayanlarla... nÉ™ qÉ™dÉ™r ki, onlar oyunda idilÉ™r, bu hÉ™ddi heÃ§ vaxt keÃ§mÉ™k mÃ¼mkÃ¼n deyildi.';

  @override
  String get onboardingTitle3 => 'Biz sadÉ™cÉ™ dayana bilmÉ™dik.';

  @override
  String get onboardingDesc3 =>
      'Bu hÉ™ddi keÃ§mÉ™k Ã¼Ã§Ã¼n biz gÃ¼clÃ¼, estetik, fÉ™rdilÉ™ÅŸdirilÉ™ bilÉ™n, istifadÉ™si asan, tam ÅŸÉ™ffaf, hÉ™m onlayn, hÉ™m dÉ™ oflayn iÅŸlÉ™yÉ™n vÉ™ mÉ™lumatlarÄ±nÄ± yalnÄ±z cihazÄ±nda saxlayan platforma yaratdÄ±q. GÃ¼cÃ¼ aid olduÄŸu yerÉ™ qaytardÄ±q: sÉ™nÉ™.';

  @override
  String get onboardingTitle4 => 'Bu HeÃ§ Asan OlmayÄ±b.';

  @override
  String get onboardingDesc4 =>
      'Biz onlarla dÉ™fÉ™ rÉ™dd edildik, dÉ™fÉ™lÉ™rlÉ™ dayandÄ±rÄ±ldÄ±q, saxta xÉ™bÉ™rdarlÄ±qlar aldÄ±q vÉ™ onlarla dÉ™fÉ™ brendimizi dÉ™yiÅŸmÉ™li olduq. BÃ¼tÃ¼n bunlara baxmayaraq, bizÉ™ bunun mÃ¼mkÃ¼n olmadÄ±ÄŸÄ±nÄ± sÃ¶ylÉ™dilÉ™r. Amma biz bu layihÉ™nin tÉ™kcÉ™ bizÉ™ deyil, hamÄ±ya aid olduÄŸuna inanaraq heÃ§ vaxt tÉ™slim olmadÄ±q. VÉ™ mÉ™hz buna gÃ¶rÉ™ buradayÄ±q.';

  @override
  String get onboardingFinalTitle => 'Ä°nqilab vaxtÄ±dÄ±r.';

  @override
  String get onboardingFinalDescription =>
      'ÆgÉ™r bu ekranÄ± gÃ¶rÃ¼rsÉ™nsÉ™, bunun sÉ™bÉ™bi tÉ™slim olmamaÄŸÄ±mÄ±zdÄ±r. VÉ™ bizim tÉ™slim olmaq fikrimiz yoxdur. GÉ™l, AI inqilabÄ±nÄ± birlikdÉ™ dÃ¼nyaya aparaq. Bu hekayÉ™nin bir hissÉ™si olmaq Ã¼Ã§Ã¼n...';

  @override
  String get onboardingFinalQuestion => 'SÆN HAZIRSAN?';

  @override
  String get onboardingFinalButton => 'BÉ™li!';

  @override
  String get dude => 'dostum';

  @override
  String get swipeToContinue => 'Davam etmÉ™k Ã¼Ã§Ã¼n sÃ¼rÃ¼ÅŸdÃ¼r';

  @override
  String get cacheIsNotUpToDate =>
      'Play Store keÅŸiniz gÃ¼ncÉ™l deyil. LÃ¼tfÉ™n, Play Store tÉ™tbiqini baÄŸlayÄ±n vÉ™ yenidÉ™n aÃ§Ä±n vÉ™ ya cihazÄ±nÄ±zÄ± yenidÉ™n baÅŸladÄ±n.';

  @override
  String get continueAsGuest => 'Hesab yaratmadan davam edin';

  @override
  String get guestModeWarning =>
      'Qonaq rejimi É™n yaxÅŸÄ± xidmÉ™t keyfiyyÉ™tini tÉ™min etmÉ™k Ã¼Ã§Ã¼n mÉ™hdud xÃ¼susiyyÉ™tlÉ™rÉ™ malikdir.';

  @override
  String get anonymousEntity => 'Anonim MÃ¼É™ssisÉ™';

  @override
  String get upgradeAccountTitle => 'HesabÄ±nÄ±zÄ± TamamlayÄ±n';

  @override
  String get upgradeAccountDescription =>
      'Daha Ã§ox limit aÃ§maq Ã¼Ã§Ã¼n hesab yaradÄ±n.';

  @override
  String get createAccount => 'Hesab YaradÄ±n';

  @override
  String get accountLinkedSuccess => 'Hesab uÄŸurla yaradÄ±ldÄ±!';

  @override
  String get continueWithApple => 'Apple ilÉ™ davam edin';

  @override
  String get guest => 'Qonaq';

  @override
  String get betterWithAnAccount => 'Bu bÃ¶lmÉ™ hesabla daha yaxÅŸÄ±dÄ±r!';

  @override
  String get restorePurchases => 'SatÄ±nalmalarÄ± bÉ™rpa edin';

  @override
  String annualTotalDescription(Object price) {
    return '$price/il, illik hesablanÄ±r';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'TÉ™xminÉ™n $price/ay';
  }

  @override
  String get confirmDownloadTitle => 'EndirmÉ™k istÉ™diyinizÉ™ É™minsiniz?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Bu model tÉ™xminÉ™n $size yer tutacaq.';
  }

  @override
  String get emulatorModeWarning =>
      'Bu funksiya emulator rejimindÉ™ deaktiv edilib';

  @override
  String get newChat => 'Yeni SÃ¶hbÉ™t';

  @override
  String get variants => 'Variantlar';

  @override
  String get variantsDescription =>
      'Variantlar eyni sÃ¼ni intellekt ailÉ™sinin fÉ™rqli versiyalarÄ±dÄ±r. Æsas karta toxunduÄŸunuz zaman avtomatik olaraq É™n yaxÅŸÄ±sÄ±nÄ± seÃ§irik, lakin istÉ™sÉ™niz, burada É™l ilÉ™ mÃ¼É™yyÉ™n bir kart seÃ§É™ bilÉ™rsiniz!';

  @override
  String get fluxChatTitle => 'Flux Chat';

  @override
  String get fluxChatDescription =>
      'Flux sÃ¶hbÉ™tlÉ™ri mÃ¼vÉ™qqÉ™ti sÃ¶hbÉ™tlÉ™rdir vÉ™ cihazÄ±nÄ±zda saxlanÄ±lmÄ±r.';

  @override
  String get alwaysBest => 'HÉ™miÅŸÉ™ Æn YaxÅŸÄ±sÄ±';

  @override
  String get featuresTitle => 'XÃ¼susiyyÉ™tlÉ™r';

  @override
  String get useOfflineDescription =>
      'Ä°nternet baÄŸlantÄ±sÄ± olmadan ÅŸÉ™xsi sÃ¶hbÉ™t edin.';

  @override
  String get featureReasoning => 'DÉ™rin DÃ¼ÅŸÃ¼ncÉ™';

  @override
  String get featureReasoningDescription =>
      'DÉ™rin DÃ¼ÅŸÃ¼nmÉ™ rejimindÉ™ sÃ¼ni intellekt tapÅŸÄ±rÄ±qlarÄ± bacardÄ±ÄŸÄ± qÉ™dÉ™r yerinÉ™ yetirmÉ™k Ã¼Ã§Ã¼n daxildÉ™ dÃ¼ÅŸÃ¼nÃ¼r.';

  @override
  String get featureCreateImageTitle => 'ÅÉ™kil Yarat';

  @override
  String get featureCreateImageDescription =>
      'MÉ™tndÉ™n sÃ¼ni intellekt sÉ™nÉ™ti yaradÄ±n.';

  @override
  String get featureCreateAudioTitle => 'Create Audio';

  @override
  String get featureCreateAudioDescription =>
      'Generate sounds or voice from text.';

  @override
  String get featureCreateVideoTitle => 'Video yaradÄ±n';

  @override
  String get featureCreateVideoDescription => 'MÉ™tndÉ™n videolar yaradÄ±n.';

  @override
  String get featureStudyTitle => 'Oxu vÉ™ Ã–yrÉ™n';

  @override
  String get featureStudyDescription => 'Ä°zahatlar vÉ™ xÃ¼lasÉ™lÉ™r alÄ±n.';

  @override
  String get featureQuizzesTitle => 'TestlÉ™r';

  @override
  String get featureQuizzesDescription => 'BiliklÉ™rinizi sÄ±nayÄ±n.';

  @override
  String get featureExploreDescription =>
      'MÃ¶vcud olan bÃ¼tÃ¼n modellÉ™ri kÉ™ÅŸf edin.';

  @override
  String get featureStudyMessage =>
      'Siz peÅŸÉ™kar repetitorsunuz. MÉ™qsÉ™diniz istifadÉ™Ã§inin mÃ¶vzusunu hÉ™rtÉ™rÉ™fli izah etmÉ™kdir. AydÄ±n struktur, nÃ¼munÉ™lÉ™r vÉ™ bÉ™nzÉ™tmÉ™lÉ™rdÉ™n istifadÉ™ edin. Ä°stifadÉ™Ã§inin effektiv ÅŸÉ™kildÉ™ Ã¶yrÉ™nmÉ™sini tÉ™min etmÉ™k Ã¼Ã§Ã¼n mÃ¼rÉ™kkÉ™b fikirlÉ™ri asanlÄ±qla baÅŸa dÃ¼ÅŸÃ¼lÉ™n hissÉ™lÉ™rÉ™ ayÄ±rÄ±n. MÃ¶vzu:';

  @override
  String get featureQuizMessage =>
      'Siz viktorina ustasÄ±sÄ±nÄ±z. Ä°stifadÉ™Ã§inin mÃ¶vzusuna É™sasÉ™n mÃ¼É™yyÉ™n bir Ã§oxseÃ§imli sual yaradÄ±n. CavabÄ±nÄ± gÃ¶zlÉ™yin. Sonra onu qiymÉ™tlÉ™ndirin vÉ™ nÃ¶vbÉ™ti sualÄ± verin. BÃ¼tÃ¼n cavablarÄ± birdÉ™n aÃ§Ä±qlamayÄ±n. Ä°nteraktiv saxlayÄ±n. MÃ¶vzu:';

  @override
  String get myPlan => 'PlanÄ±m';

  @override
  String welcomeOfferBadge(String time) {
    return 'XoÅŸ GÉ™lmisiniz TÉ™klifi â€¢ $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'EksklÃ¼ziv TÉ™klif â€¢ $time';
  }

  @override
  String get attachmentSheetTitle => 'ÆlavÉ™lÉ™r';

  @override
  String get actionCamera => 'Kamera';

  @override
  String get actionGallery => 'Qalereya';

  @override
  String get actionFile => 'Fayl';

  @override
  String get listening => 'DinlÉ™yir';

  @override
  String get defaultViewTitle => 'NecÉ™sÉ™n?';

  @override
  String get defaultViewDescription =>
      'Cortex yÃ¼zlÉ™rlÉ™ sÃ¼ni intellekt modeli, oflayn imkanlar, dinamik sÃ¶hbÉ™t vÉ™ daha Ã§ox ÅŸey ilÉ™ hÉ™miÅŸÉ™ yanÄ±nÄ±zdadÄ±r.';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'YanlÄ±ÅŸ istifadÉ™Ã§i adÄ± formatÄ±. 3-20 simvol, rÉ™qÉ™m vÉ™ ya . - _ istifadÉ™ edin.';

  @override
  String get exclusiveOffer => 'EksklÃ¼ziv TÉ™klif';

  @override
  String get claimOffer => 'TÉ™klifdÉ™n istifadÉ™ et';

  @override
  String get continueInOfflineMode => 'Oflayn RejimdÉ™ Davam Edin';

  @override
  String get voiceModeInformation =>
      'Cortex, sÉ™sli sÃ¶hbÉ™t rejimindÉ™ belÉ™ cihazÄ±nÄ±zda tam iÅŸlÉ™yÉ™rÉ™k mÉ™lumatlarÄ±nÄ±zÄ± tÉ™hlÃ¼kÉ™siz saxlayÄ±r; problemsiz sÃ¶hbÉ™tlÉ™rdÉ™n zÃ¶vq alÄ±n!';

  @override
  String get flowModeDescription =>
      'AxÄ±n rejimindÉ™ zÉ™kalar Ã¶z aralarÄ±nda mÃ¼bahisÉ™ edirlÉ™r; ya arxayÄ±n oturub dinlÉ™yÉ™, ya da mÃ¼zakirÉ™yÉ™ qoÅŸula bilÉ™rsiniz!';

  @override
  String get flowModeQuestion =>
      'Salam! ArtÄ±q Cortex tÉ™tbiqindÉ™ AxÄ±n RejimindÉ™siniz. Burada sizinlÉ™ birlikdÉ™ daha Ã¼Ã§ sÃ¼ni intellekt agenti var. TapÅŸÄ±rÄ±ÄŸÄ±nÄ±z otaÄŸa bir mÃ¶vzu É™lavÉ™ etmÉ™k vÉ™ digÉ™rlÉ™rinÉ™ tÉ™xribatÃ§Ä± vÉ™ ya É™ylÉ™ncÉ™li bir sual verÉ™rÉ™k mÃ¼zakirÉ™yÉ™ baÅŸlamaqdÄ±r. CavablarÄ±nÄ±zda yumor, istehza vÉ™ yÃ¼ngÃ¼l cÉ™fÉ™ngiyatdan istifadÉ™ etmÉ™kdÉ™n Ã§É™kinmÉ™yin. Ä°stÉ™nilÉ™n mÃ¶vzu É™dalÉ™tli oyundur. Davam edin, sÃ¶hbÉ™tÉ™ baÅŸlayÄ±n.';

  @override
  String get thought => 'DÃ¼ÅŸÃ¼ndÃ¼';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => 'AxÄ±n Rejimi';

  @override
  String get premium => 'Premium';

  @override
  String get workInProgress => 'Ä°ÅŸlÉ™r Davam Edir';

  @override
  String get voiceSystemPromptSuffix =>
      'VACÄ°BDÄ°R: Markdown formatlamasÄ±ndan (qalÄ±n, kursiv) istifadÉ™ etmÉ™yin. Kod bloklarÄ±nÄ± (```) Ã‡IXARMAYIN. CavablarÄ± danÄ±ÅŸÄ±q xarakterli vÉ™ qÄ±sa saxlayÄ±n.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Korteks AxÄ±n Rejimi ($agentName). ÆvvÉ™lki: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'YÃ¼klÉ™nmiÅŸ sÉ™nÉ™dlÉ™rdÉ™n mÉ™tn mÉ™zmununu oxuyun vÉ™ Ã§Ä±xarÄ±n. PDF, Word (DOCX), Excel (XLSX), PowerPoint (PPTX) vÉ™ OpenDocument formatlarÄ±nÄ± dÉ™stÉ™klÉ™yir. Ä°stifadÉ™Ã§i sÉ™nÉ™d faylÄ± É™lavÉ™ etdikdÉ™ bundan istifadÉ™ edin.';

  @override
  String get toolReadDocumentIndexParam =>
      'Oxunacaq sÉ™nÉ™d É™lavÉ™sinin indeksi (0-É™saslÄ±). AdÉ™tÉ™n ilk sÉ™nÉ™d Ã¼Ã§Ã¼n 0 olur.';

  @override
  String get toolStockDescription =>
      'SÉ™hmlÉ™rin (mÉ™sÉ™lÉ™n, AAPL, THYAO.IS) vÉ™ kriptovalyutanÄ±n (mÉ™sÉ™lÉ™n, BTC-USD) cari qiymÉ™tini vÉ™ tarixini É™ldÉ™ edin.';

  @override
  String get toolStockSymbolParam =>
      'Ticker simvolu (mÉ™sÉ™lÉ™n, AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolWeatherDescription =>
      'MÃ¼É™yyÉ™n bir ÅŸÉ™hÉ™r Ã¼Ã§Ã¼n cari hava ÅŸÉ™raitini É™ldÉ™ edin.';

  @override
  String get toolWeatherCityParam =>
      'ÅÉ™hÉ™r adÄ± (mÉ™sÉ™lÉ™n, London, Ä°stanbul).';

  @override
  String get toolPythonDescription =>
      'Python kodunu tÉ™hlÃ¼kÉ™siz bir sandboxda icra edin.';

  @override
  String get toolPythonCodeParam => 'Ä°cra edilÉ™cÉ™k Python kodu.';

  @override
  String get toolCalculateDescription => 'Riyazi ifadÉ™ni qiymÉ™tlÉ™ndirin.';

  @override
  String get toolCalculateExpressionParam =>
      'Riyazi ifadÉ™ (mÉ™sÉ™lÉ™n, \'3 + 4 * 2\').';

  @override
  String get toolChartDescription =>
      'Diaqram/qrafik vizuallaÅŸdÄ±rmasÄ± yaradÄ±n.';

  @override
  String get toolChartTypeParam =>
      'Diaqram nÃ¶vÃ¼: sÃ¼tun, xÉ™tt vÉ™ ya dairÉ™vi forma.';

  @override
  String get toolChartLabelsParam =>
      'Diaqram oxlarÄ± vÉ™ ya seqmentlÉ™ri Ã¼Ã§Ã¼n etiketlÉ™r.';

  @override
  String get toolChartDataParam =>
      'Diaqram Ã¼Ã§Ã¼n É™dÉ™di mÉ™lumat dÉ™yÉ™rlÉ™ri.';

  @override
  String get toolChartLabelParam =>
      'Diaqram É™fsanÉ™si Ã¼Ã§Ã¼n verilÉ™nlÉ™r dÉ™sti etiketi.';

  @override
  String get toolChartTitleParam => 'DiaqramÄ±n baÅŸlÄ±ÄŸÄ±.';

  @override
  String get thinkingModeInstruction =>
      'DÃœÅÃœNMÆ REJÄ°MÄ° AKTÄ°VDÄ°R: Son cavabÄ±nÄ±zÄ± vermÉ™zdÉ™n É™vvÉ™l mÃ¼hakimÉ™ prosesinizi gÃ¶stÉ™rmÉ™k Ã¼Ã§Ã¼n <think></think> etiketlÉ™rindÉ™n istifadÉ™ etmÉ™lisiniz. EtiketlÉ™rin iÃ§É™risindÉ™ addÄ±m-addÄ±m dÃ¼ÅŸÃ¼nÃ¼n, sonra cavabÄ±nÄ±zÄ± etiketlÉ™rin xaricindÉ™ verin.';

  @override
  String get openLinkWarningTitle => 'Xarici Link XÉ™bÉ™rdarlÄ±ÄŸÄ±';

  @override
  String get openLinkCancel => 'Cancel';

  @override
  String get openLinkConfirm => 'Linki AÃ§Ä±n';

  @override
  String get webSearchSources => 'MÉ™nbÉ™lÉ™r';

  @override
  String get searching => 'AxtarÄ±ÅŸ';

  @override
  String get featureWebSearchTitle => 'Veb AxtarÄ±ÅŸÄ±';

  @override
  String get featureWebSearchDescription =>
      'Real vaxt mÉ™lumatÄ± Ã¼Ã§Ã¼n internetdÉ™ axtarÄ±ÅŸ aparÄ±n';

  @override
  String get clearMemory => 'YaddaÅŸÄ± tÉ™mizlÉ™yin';

  @override
  String get clearMemoryConfirm =>
      'YaddaÅŸÄ±nÄ±zÄ± tÉ™mizlÉ™mÉ™k istÉ™diyinizÉ™ É™minsinizmi?';

  @override
  String get personalization => 'FÉ™rdilÉ™ÅŸdirmÉ™';

  @override
  String get personalizationDescription =>
      'KÃ¶mÉ™kÃ§inizi ehtiyaclarÄ±nÄ±za daha yaxÅŸÄ± uyÄŸunlaÅŸdÄ±rmaq Ã¼Ã§Ã¼n fÉ™rdilÉ™ÅŸdirin. Onun cavablarÄ±nÄ±, davranÄ±ÅŸÄ±nÄ± vÉ™ tonunu unikal seÃ§imlÉ™rinizÉ™ uyÄŸunlaÅŸdÄ±rÄ±n.';

  @override
  String get memoryTitle => 'YaddaÅŸ';

  @override
  String get memoryDescription => 'SÃ¼ni intellekt sizi belÉ™ tanÄ±yÄ±r.';

  @override
  String get noMemoryYet => 'HÉ™lÉ™ heÃ§ bir xatirÉ™ qurulmayÄ±b';

  @override
  String get memoryLimitReached => 'YaddaÅŸ limitinÉ™ Ã§atÄ±ldÄ±';

  @override
  String get memoryUpdated => 'Memory updated';

  @override
  String get intelligenceTitle => 'KÉ™ÅŸfiyyat';

  @override
  String get intelligenceDescription =>
      'SÃ¼ni intellekt sizinlÉ™ bu ÅŸÉ™kildÉ™ Ã¼nsiyyÉ™t qurur.';

  @override
  String get customInstructionHint =>
      'XÃ¼susi tÉ™limatlarÄ±nÄ±zÄ± buraya daxil edin';

  @override
  String openLinkWarningMessage(String url) {
    return 'AÅŸaÄŸÄ±dakÄ± xarici linki aÃ§maq Ã¼zrÉ™siniz:\\n\\n$url\\n\\nDavam etmÉ™k istÉ™diyinizÉ™ É™minsinizmi?';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'Bu xÃ¼susi tÉ™limatlarÄ± izlÉ™yin:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[KRÄ°TÄ°K TÆLÄ°MAT]: Siz BAÅLIQ GENERATORUSUZ. Ä°stifadÉ™Ã§inin sualÄ±na CAVAB VERMÆYÄ°N. SÃ–HBÆT EDÄ°N VÆ YA SALAM VERMÆYÄ°N. YALNIZ istifadÉ™Ã§inin nÉ™ haqqÄ±nda soruÅŸduÄŸunu xÃ¼lasÉ™ edÉ™n 2-4 sÃ¶zdÉ™n ibarÉ™t baÅŸlÄ±q Ã§Ä±xarÄ±n.';

  @override
  String get cortexSystemPersona =>
      '\n\n[Sistem] ÆHÆMÄ°YYÆTLÄ° TÆLÄ°MAT: Hal-hazÄ±rda \"Cortex\" adlÄ± nÉ™hÉ™ng, yÃ¼ksÉ™k inkiÅŸaf etmiÅŸ sÃ¼ni intellekt ekosistemindÉ™ fÉ™aliyyÉ™t gÃ¶stÉ™rirsiniz; bu platforma orta hesabla cÉ™mi 16 yaÅŸÄ±nda olan Vertex komandasÄ± tÉ™rÉ™findÉ™n hazÄ±rlanmÄ±ÅŸdÄ±r. Bunu yadda saxlayÄ±n vÉ™ soruÅŸulsa, cavab verin. Daha Ã§ox mÉ™lumat istÉ™nildikdÉ™, internetdÉ™ axtarÄ±ÅŸ etmÉ™kdÉ™n Ã§É™kinmÉ™yin vÉ™ ya axtarÄ±ÅŸ edÉ™ bilmirsinizsÉ™, bilmÉ™diyinizi demÉ™kdÉ™n Ã§É™kinmÉ™yin!';

  @override
  String get featureAudioRecognitionTitle => 'SÉ™s TanÄ±ma';

  @override
  String get featureAudioRecognitionDescription =>
      'Bu model sÉ™s vÉ™ ya nitqi baÅŸa dÃ¼ÅŸÉ™ vÉ™ emal edÉ™ bilir.';

  @override
  String get featureVideoRecognitionTitle => 'Video TanÄ±ma';

  @override
  String get featureVideoRecognitionDescription =>
      'Bu model fayllarÄ±nÄ±zdan vÉ™ ya kameranÄ±zdan videolarÄ± tÉ™hlil edÉ™ vÉ™ baÅŸa dÃ¼ÅŸÉ™ bilÉ™r.';

  @override
  String get featureImageRecognitionTitle => 'ÅÉ™kil TanÄ±ma';

  @override
  String get featureImageRecognitionDescription =>
      'Bu model fotoÅŸÉ™killÉ™ri vÉ™ ya tÉ™svirlÉ™ri tÉ™hlil edÉ™ vÉ™ baÅŸa dÃ¼ÅŸÉ™ bilÉ™r.';

  @override
  String get featureToolUseTitle => 'AlÉ™t Ä°stifadÉ™si';

  @override
  String get featureToolUseDescription =>
      'Bu model tapÅŸÄ±rÄ±qlarÄ± yerinÉ™ yetirmÉ™k Ã¼Ã§Ã¼n xarici vasitÉ™lÉ™rdÉ™n aÄŸÄ±llÄ± ÅŸÉ™kildÉ™ istifadÉ™ edÉ™ bilÉ™r.';

  @override
  String get videoModels => 'Video Models';

  @override
  String get imageModels => 'Image Models';

  @override
  String get audioModels => 'Audio Models';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'Bu modelin iÅŸlÉ™mÉ™si Ã¼Ã§Ã¼n bir $mediaType lazÄ±mdÄ±r. Bunu bildirmÉ™k Ã¼Ã§Ã¼n sorÄŸunu tutdum. ZÉ™hmÉ™t olmasa istifadÉ™Ã§iyÉ™ nÉ™zakÉ™tlÉ™ bir $mediaType tÉ™min etmÉ™li olduqlarÄ±nÄ± bildirin (Ã¶z dillÉ™rindÉ™ deyin) Ã§Ã¼nki mÉ™n $modelName, vizual/audio/video redaktÉ™ modeliyÉ™m.';
  }

  @override
  String get mediaTypeImage => 'ÅŸÉ™kil';

  @override
  String get mediaTypeVideo => 'video';

  @override
  String get mediaTypeAudio => 'audio faylÄ±';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesName, Cortex-dÉ™ yÃ¼ksÉ™k performans gÃ¶stÉ™rÉ™n qabaqcÄ±l bir zÉ™kadÄ±r.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelName, Cortex ekosisteminÉ™ inteqrasiya olunmuÅŸ yÃ¼ksÉ™k performanslÄ± sÃ¼ni intellektdir. GeniÅŸ Ã§eÅŸidli mÃ¼rÉ™kkÉ™b tapÅŸÄ±rÄ±qlarÄ± hÉ™ll etmÉ™k Ã¼Ã§Ã¼n nÉ™zÉ™rdÉ™ tutulub, yÃ¼ksÉ™k etibarlÄ± vÉ™ sÉ™mÉ™rÉ™li emal imkanlarÄ± tÉ™qdim edir. SÃ¼rÉ™tli cavab mÃ¼ddÉ™tlÉ™ri vÉ™ tÉ™kmil analitik gÃ¼cÃ¼ tÉ™qdim edÉ™rÉ™k, gÃ¼ndÉ™lik mÉ™hsuldarlÄ±ÄŸÄ±nÄ±zÄ± É™hÉ™miyyÉ™tli dÉ™rÉ™cÉ™dÉ™ artÄ±rÄ±r. Cortex-in tÉ™hlÃ¼kÉ™siz yerli infrastrukturu Ã¼zÉ™rindÉ™ tam inteqrasiya olunmuÅŸ ÅŸÉ™kildÉ™ iÅŸlÉ™yÉ™n bu model yaradÄ±cÄ± fikir mÃ¼badilÉ™sindÉ™n tutmuÅŸ dÉ™rin texniki analizlÉ™rÉ™ qÉ™dÉ™r geniÅŸ bir spektrdÉ™ sizÉ™ kÃ¶mÉ™k edÉ™ bilÉ™r. Tam potensialÄ±nÄ± bu gÃ¼ndÉ™n kÉ™ÅŸf etmÉ™yÉ™ baÅŸlayÄ±n.';
  }

  @override
  String get guestLimitBottomSheetTitle => 'Cortex-in zÉ™kasÄ±nÄ± sevirsiniz?';

  @override
  String get guestLimitBottomSheetText =>
      'Daha da aÄŸÄ±llÄ± zÉ™kalarla iÅŸlÉ™yin, daha Ã§ox mÉ™zmun yaradÄ±n, daha Ã§ox sÃ¶hbÉ™t edin vÉ™ daha Ã§ox ÅŸey edin...';

  @override
  String get arts => 'Ä°ncÉ™sÉ™nÉ™t';

  @override
  String get noArt => 'SÉ™nÉ™t yoxdur';

  @override
  String get noArtDescription =>
      'HÉ™lÉ™ ki, heÃ§ bir É™sÉ™r yoxdur; qalereyanÄ± ÅŸÉ™killÉ™r, videolar, audio vÉ™ hÉ™r cÃ¼r mÉ™zmunla doldurmaÄŸÄ±n vaxtÄ±dÄ±r!';

  @override
  String get videoPremiumWarning =>
      'Videolar yaratmaq, indi tÉ™kmillÉ™ÅŸdirmÉ™k vÉ™ axÄ±nÄ± hiss etmÉ™k Ã¼Ã§Ã¼n Ultra abunÉ™liyinÉ™ ehtiyacÄ±nÄ±z var!';

  @override
  String get fallbackInfoPanelText =>
      'Server tÉ™rÉ™fimizdÉ™ etdiyimiz bÉ™zi tÉ™kmillÉ™ÅŸdirmÉ™lÉ™rÉ™ gÃ¶rÉ™, cavab sizin xÃ¼susi seÃ§diyiniz sÃ¼ni intellekt É™vÉ™zinÉ™ Cortex-in dinamik sÃ¶hbÉ™ti ilÉ™ yaradÄ±lÄ±b. Proses baÅŸa Ã§atana qÉ™dÉ™r anlayÄ±ÅŸÄ±nÄ±z Ã¼Ã§Ã¼n tÉ™ÅŸÉ™kkÃ¼r edirik!';

  @override
  String get falOfflineMessage =>
      'Server tÉ™rÉ™fimizdÉ™ etdiyimiz bÉ™zi tÉ™kmillÉ™ÅŸdirmÉ™lÉ™rÉ™ gÃ¶rÉ™, bu zÉ™ka hazÄ±rda oflayndÄ±r. Proses bitÉ™nÉ™ qÉ™dÉ™r anlayÄ±ÅŸÄ±nÄ±z Ã¼Ã§Ã¼n tÉ™ÅŸÉ™kkÃ¼r edirik!';

  @override
  String get errorInsufficientStorage =>
      'Bu modeli yÃ¼klÉ™mÉ™k Ã¼Ã§Ã¼n yaddaÅŸ yeri kifayÉ™t deyil.';

  @override
  String get backgroundChatNotificationTitle => 'SÃ¶hbÉ™tÉ™ qayÄ±t!';

  @override
  String get benefitVideoGeneration => 'Video NÉ™sli';

  @override
  String get freeOffer => 'Pulsuz TÉ™klif';

  @override
  String trialMonthlyDescription(String days, String price) {
    return 'Ä°lk $days gÃ¼n pulsuz, sonra $price/ay';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return 'Ä°lk $days gÃ¼n pulsuz, sonra $price/il';
  }

  @override
  String freePlan(String plan) {
    return 'Pulsuz $plan!';
  }

  @override
  String get systemPromptLimitFallback =>
      'TÆNÄ°DLÄ°: Ä°stifadÉ™Ã§i É™mÉ™liyyat tÉ™lÉ™b etdi, lakin Cortex-dÉ™ limitlÉ™ri tÃ¼kÉ™nib; xahiÅŸ edirik istifadÉ™Ã§iyÉ™ onlarÄ±n dilindÉ™ gÃ¶zlÉ™mÉ™li olduqlarÄ±nÄ± vÉ™ ya abunÉ™ planlarÄ±nÄ± tÉ™kmillÉ™ÅŸdirmÉ™yi dÃ¼ÅŸÃ¼nmÉ™li olduqlarÄ±nÄ± bildirin.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'Cortex daha da yaxÅŸÄ± cavablar verÉ™ bilÉ™r; indi yÃ¼ksÉ™lt vÉ™ hÉ™r sual Ã¼Ã§Ã¼n É™n yaxÅŸÄ± cavabÄ± al!';

  @override
  String get pinLimitReached => 'Maksimum 3 sÃ¶hbÉ™ti sancaqlaya bilÉ™rsiniz.';
}
