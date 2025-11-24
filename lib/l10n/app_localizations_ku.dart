// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kurdish (`ku`).
class AppLocalizationsKu extends AppLocalizations {
  AppLocalizationsKu([String locale = 'ku']) : super(locale);

  @override
  String get understood => 'Têgihiştim.';

  @override
  String get cancel => 'Betal bike';

  @override
  String get remove => 'Rake';

  @override
  String get download => 'Daxe';

  @override
  String get resume => 'Berdewam bike';

  @override
  String get copy => 'Kopî bike';

  @override
  String get chat => 'Sohbet';

  @override
  String get darkMode => 'Moda Tarî';

  @override
  String get light => 'Ronî';

  @override
  String get theme => 'Tema';

  @override
  String get no => 'Na';

  @override
  String get yes => 'Erê';

  @override
  String get done => 'Çêbû';

  @override
  String get comingSoon => 'DI DEMEKE NÊZ DE';

  @override
  String get bestValue => 'Nirxa Herî Baş';

  @override
  String get selected => 'Hilbijartî';

  @override
  String get descriptionSection => 'Danasîn';

  @override
  String get searchHint => 'Lêgerîn';

  @override
  String get messageHint => 'Tiştekî bipirse';

  @override
  String get modelLoading => 'Model tê barkirin...';

  @override
  String get messageCopied => 'Peyam li panoyê hate kopîkirin.';

  @override
  String get storeUnavailable =>
      'Firoşgeh niha ne berdest e. Ji kerema xwe paşê dîsa biceribîne';

  @override
  String get retry => 'Dîsa biceribîne';

  @override
  String get systemInfo => 'Agahdariya Pergalê';

  @override
  String deviceMemory(Object memory) {
    return 'Bîra Amûrê: $memory GB';
  }

  @override
  String storageSpace(Object storage) {
    return 'Cihê Depokirinê: $storage GB';
  }

  @override
  String freeStorageSpace(Object freeStorage) {
    return 'Cihê Depokirinê yê Azad: $freeStorage GB';
  }

  @override
  String get memory => 'Bîr';

  @override
  String get storage => 'Depo';

  @override
  String get freeStorage => 'Depoya Azad';

  @override
  String get totalStorage => 'Depoya Giştî';

  @override
  String get usedStorage => 'Depoya Bikaranî';

  @override
  String get totalMemory => 'Bîra Giştî';

  @override
  String get usedMemory => 'Bîra Bikaranî';

  @override
  String get requirements => 'Pêdivî';

  @override
  String get modelsTitle => 'Pirtûkxane';

  @override
  String get localModels => 'Modelên Herêmî';

  @override
  String get serverSideModels => 'Modelên Serhêl';

  @override
  String get uploadYourOwnModel => 'Modela Xwe Bar Bike!';

  @override
  String get selectGGUFFile => 'Pelê GGUF Hilbijêre';

  @override
  String get errorGGUF =>
      'Ji kerema xwe tenê pelên bi formata GGUF hilbijêrin.';

  @override
  String get modelAlreadyExists => 'Model jixwe heye.';

  @override
  String get modelAddedSuccessfully => 'Model bi serkeftî hate zêdekirin.';

  @override
  String get modelRemoved => 'Model bi serkeftî hate rakirin.';

  @override
  String get removeError => 'Dema rakirina modelê de xeletiyek çêbû.';

  @override
  String get fileNotFound => 'Pel nehat dîtin.';

  @override
  String get fileUploadError => 'Dema barkirina pelê de xeletiyek çêbû.';

  @override
  String get noFileSelected => 'Tu pel nehat hilbijartin.';

  @override
  String get myModels => 'Modelên Min';

  @override
  String get create => 'Çêke';

  @override
  String get seeAll => 'Hemî Bibîne';

  @override
  String modelProducer(Object producer) {
    return 'Hilberîner: $producer';
  }

  @override
  String modelRAM(Object ram) {
    return 'RAM: $ram';
  }

  @override
  String modelSize(Object size) {
    return 'Mezinahî: $size';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get conversationsTitle => 'Sohbet';

  @override
  String get conversationDeleted => 'Sohbet hate jêbirin.';

  @override
  String get conversationUpdated => 'Sohbet hate nûvekirin.';

  @override
  String get editConversationTitle => 'Navê biguherîne';

  @override
  String get newTitle => 'Sernavê Nû';

  @override
  String get save => 'Tomar bike';

  @override
  String get titleCannotBeEmpty => 'Sernav nikare vala be.';

  @override
  String get noConversationsMessage => 'Sohbet tune ne, dest bi sohbetê bike!';

  @override
  String get startChat => 'Dest bi sohbetê bike';

  @override
  String get noChats => 'Sohbet Tune';

  @override
  String get starredChats => 'Sohbetên bi Stêrk';

  @override
  String get allChats => 'Hemî Sohbet';

  @override
  String get noStarredChats => 'Sohbetên bi Stêrk Tune';

  @override
  String get noStarredChatsMessage => 'Te hîna sohbetek stêrk nekiriye.';

  @override
  String get goToChats => 'Sohbetekê stêrk bike';

  @override
  String get starConversation => 'Stêrk';

  @override
  String get conversationTitleUpdated => 'Sernavê sohbetê hate nûvekirin';

  @override
  String get youReachedConversationLimit => 'Tu gihîştî sînorê sohbetê.';

  @override
  String get today => 'Îro';

  @override
  String get yesterday => 'Duh';

  @override
  String get loginToYourAccount => 'Têkeve';

  @override
  String get createYourAccount => 'Qeyd bibe';

  @override
  String get email => 'E-name';

  @override
  String get password => 'Şîfre';

  @override
  String get confirmPassword => 'Şîfreyê Piştrast bike';

  @override
  String get invalidEmail =>
      'Ji kerema xwe navnîşaneke e-nameyê ya derbasdar binivîse.';

  @override
  String get invalidPassword => 'Divê şîfre herî kêm 6 tîpan dirêj be.';

  @override
  String get rememberMe => 'Min bîne bîra xwe';

  @override
  String get forgotPassword => 'Şîfreya xwe ji bîr kir?';

  @override
  String get or => 'An';

  @override
  String get continueWithGoogle => 'Bi Google re berdewam bike';

  @override
  String get dontHaveAccount => 'Hesabê te tune ye?';

  @override
  String get alreadyHaveAccount => 'Jixwe hesabê te heye?';

  @override
  String get signUp => 'Qeyd bibe';

  @override
  String get logIn => 'Têkeve';

  @override
  String get passwordsDoNotMatch => 'Şîfre li hev nakin.';

  @override
  String get userNotFound => 'Bikarhêner nehat dîtin.';

  @override
  String get wrongPassword => 'Şîfreya çewt.';

  @override
  String get emailAlreadyInUse => 'Ev e-name jixwe tê bikaranîn.';

  @override
  String get weakPassword => 'Şîfre pir lawaz e.';

  @override
  String get authError => 'Çewtiya Nasnameyê';

  @override
  String get invalidUsername => 'Ji kerema xwe navekî bikarhêner binivîse.';

  @override
  String get usernameTaken => 'Ev navê bikarhêner jixwe hatiye girtin.';

  @override
  String get username => 'Navê bikarhêner';

  @override
  String get authenticationFailed =>
      'Nasnameyê bi ser neket. Ji kerema xwe dîsa biceribîne.';

  @override
  String get emailTooLong => 'E-name dikare herî zêde 30 tîpan be.';

  @override
  String get deviceLimitReached =>
      'Tu gihîştî sînorê çêkirina hesabê ji bo vê amûrê.';

  @override
  String get verificationEmailLimitReached => 'Em êdî naşînin';

  @override
  String get verificationEmailSent => 'E-nameya verastkirinê hate şandin!';

  @override
  String get emailNotVerified => 'E-name nehatiye verastkirin';

  @override
  String get resendCode => 'E-nameya verastkirinê dîsa bişîne';

  @override
  String get remainingSeconds => 'Dema mayî ji bo verastkirinê';

  @override
  String get pleaseCheckYourEmail =>
      'Ji bo ku Cortex bikar bînî, divê tu e-nameya xwe piştrast bikî. \n Zencîreyek piştrastkirinê ji navnîşana e-nameya te re hate şandin, ji kerema xwe e-nameya xwe kontrol bike.';

  @override
  String get verifyYourEmail => 'E-nameya Xwe Piştrast bike';

  @override
  String get backToLogin => 'Vegere Paş';

  @override
  String get seconds => 'saniye';

  @override
  String get maxResendLimitReached =>
      'Tu gihîştî hejmara herî zêde ya e-nameyên verastkirinê';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Bêyî verastkirinê berdewam bike';

  @override
  String get verificationScreenWarning =>
      'Her çend tu berdewam bikî jî, dema verastkirina hesabê ya 1-rojî hîn jî ji bo hesabê te di meriyetê de ye. Heke heta wê demê te hesabê xwe nepejirandibe, ew ê ji sepanê were jêbirin.';

  @override
  String get unverifiedAccountHeader => 'Hesabê te nehatiye piştrastkirin';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Heke tu di nav $timeLeft de hesabê xwe piştrast nekî, ew ê were jêbirin';
  }

  @override
  String get verifyNow => 'Niha Piştrast bike';

  @override
  String get accountVerified => 'Hesabê te hate piştrastkirin.';

  @override
  String get linkSent => 'Zencîre hate şandin';

  @override
  String get accountDeletionRequested =>
      'Daxwaza jêbirina hesabê te hate wergirtin û hesabê te niha neçalak e.';

  @override
  String get tooManyRequests => 'Pir zêde daxwaz';

  @override
  String get regenerate => 'Dîsa Biafirîne';

  @override
  String get confirmDeleteAccount => 'Tu bi rastî dixwazî hesabê xwe jê bibî?';

  @override
  String get enterPasswordToDelete => 'Ji bo jêbirinê şîfreya xwe binivîse.';

  @override
  String get deleteAccount => 'Hesabê Jê bibe';

  @override
  String get deleteAccountError => 'Dema jêbirina hesabê de xeletiyek çêbû.';

  @override
  String get delete => 'Jê bibe';

  @override
  String get passwordRequired => 'Şîfre pêwîst e.';

  @override
  String get deleteDescription =>
      'Daneyên ku tu jê dibî dê bi domdarî ji servera me û amûra te werin rakirin. Ev kiryar nayên paşvegerandin.';

  @override
  String get deleteAccountButton => 'Bişkoka Jêbirina Hesabê';

  @override
  String get editProfile => 'Profîlê Biguherîne';

  @override
  String get displayName => 'Navê Nîşandanê';

  @override
  String get tapToChangeProfilePicture =>
      'Ji bo guhertina wêneyê profîlê bitikîne';

  @override
  String get profileUpdated => 'Profîl bi serkeftî hate nûvekirin';

  @override
  String get updateFailed => 'Nûvekirina profîlê bi ser neket';

  @override
  String get nameCannotBeEmpty => 'Nav nikare vala be';

  @override
  String get logout => 'Derketin';

  @override
  String get noDisplayName => 'Navê nîşandanê nehatiye danîn';

  @override
  String get noEmail => 'Navnîşana e-nameyê tune';

  @override
  String get noUserLoggedIn => 'Niha tu bikarhêner têketî nîne';

  @override
  String get profile => 'Profîl';

  @override
  String get manageProfileDescription =>
      'Profîla xwe birêve bibe, şîfreya xwe nûve bike, an ji Cortex derkeve.';

  @override
  String get accessSettingsDescription =>
      'Bigihîje alîkariyê, kodan bikar bîne, Cortex parve bike, û polîtîkayên me bibîne.';

  @override
  String get languageDescription =>
      'Tu dikarî her dem zimanê navrûyê yê sepana xwe biguherînî.';

  @override
  String get themeDescription =>
      'Tu dikarî li gorî tercîha xwe di navbera temayên ronî û tarî de biguherî. Temaya hilbijartî dê li seranserê navrûya Cortex-ê were sepandin.';

  @override
  String get iHaveReadAndAgree => 'Min şertên xizmetê xwend û qebûl dikim';

  @override
  String get downloading => 'Tê daxistin...';

  @override
  String get downloadError => 'Di dema daxistinê de xeletiyek çêbû.';

  @override
  String get downloadCancelled => 'Daxistin hate betalkirin.';

  @override
  String get downloadResumed => 'Daxistin ji nû ve dest pê kir.';

  @override
  String get downloadSuccess => 'Daxistin bi ser ket';

  @override
  String get downloadFailed => 'Daxistin bi ser neket';

  @override
  String downloaded(Object percent) {
    return '%$percent hate daxistin';
  }

  @override
  String get downloadPaused => 'Daxistin hate sekinandin.';

  @override
  String get purchaseSuccessful => 'Kirîn serkeftî bû!';

  @override
  String get purchaseFailed => 'Kirîn bi ser neket';

  @override
  String get creditProductNotFound =>
      'Hilbera krediyê ya hilbijartî nehat dîtin.';

  @override
  String get creditsAddedSuccessfully =>
      'Kredî bi serkeftî li hesabê te hatin zêdekirin!';

  @override
  String get creditDeliveryFailed =>
      'Zêdekirina krediyan li hesabê te bi ser neket. Ji kerema xwe bi piştgiriyê re têkilî daynin.';

  @override
  String get invalidPurchase => 'Kirîna nederbasdar';

  @override
  String get purchaseError => 'Çewtiya kirînê';

  @override
  String get purchaseVertexPlusToUpload => 'Ev taybetmendiyek Plus e';

  @override
  String get purchasePlus => 'Cortex Plus bikire';

  @override
  String get plusDescription =>
      'Zêdetir taybetmendiyên Cortex-ê bi kar bîne û AI-yê pir zêdetir biceribîne!';

  @override
  String get annual => 'Salane';

  @override
  String get monthly => 'Mehê';

  @override
  String get manageSubscription => 'Abonetiyê Birêve bibe';

  @override
  String purchasePlan(String planName) {
    return '$planName bikire';
  }

  @override
  String discountOffer(int percent) {
    return '%$percent ERZANÎ';
  }

  @override
  String annualPlanDescription(String price) {
    return '$price/mehê, salane tê fatûrekirin';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/mehê, mehane tê fatûrekirin';
  }

  @override
  String get discountBannerTitle => 'TAYBET JI BO DESTPÊKÊ: 80% ERZANÎ!';

  @override
  String get discountBannerSubtitle =>
      'Erzaniya taybet li ser HEMÛ planên abonetiyê ji bo pîrozkirina destpêka me. Vê fersendê ji dest nede!';

  @override
  String get purchasePro => 'Cortex Pro bikire';

  @override
  String get proDescription =>
      'Zêdetir taybetmendiyên Cortex-ê bi kar bîne û AI-yê hê bêtir biceribîne!';

  @override
  String get alreadySubscribed => 'Tu jixwe aboneyî';

  @override
  String get subscriptionInfo => 'Abonetiya te çalak e.';

  @override
  String get alreadySubscribedMessage =>
      'Jixwe abonetiya te ya Plus heye. Heke tu dixwazî abonetiya xwe betal bikî, tu dikarî vê yekê bi rêya rêveberê Play Store-ê bikî.';

  @override
  String get cancelSubscription => 'Abonetiyê Betal bike';

  @override
  String get cancelSubscriptionInfo =>
      'Heke tu dixwazî abonetiya xwe betal bikî, ji kerema xwe bi rêya rêveberê abonetiya Play Store-ê bidomîne.';

  @override
  String get goToPlayStore => 'Here Play Store';

  @override
  String get alreadySubscribedPlus => 'Plana te ya Plus heye!';

  @override
  String get alreadySubscribedPlusMessage =>
      'Plana te ya Plus çalak e. Tu dikarî ji hemî feydeyan sûd werbigirî.';

  @override
  String get purchaseUltra => 'Cortex Ultra bikire';

  @override
  String get ultraDescription =>
      'Gihîştina tevahî ya hemî taybetmendiyên Cortex-ê bi dest bixe û AI-yê bi tevahî biceribîne!';

  @override
  String get noSubscription => 'Abonetî Tune';

  @override
  String get noSubscriptionMessage => 'Hîna abonetiya te tune.';

  @override
  String get alreadyAtHighestPlan => 'Tu jixwe di plana herî bilind de yî.';

  @override
  String get unableToOpenSubscription =>
      'Nikare rûpela rêveberiya abonetiyê veke.';

  @override
  String get upgradeSubscription => 'Abonetiyê Nûjen bike';

  @override
  String get confirmUpgrade => 'Tu bi rastî dixwazî abonetiya xwe nûjen bikî?';

  @override
  String get unsupportedPlatform =>
      'Platforma ji bo betalkirina abonetiyê nayê piştgirî kirin.';

  @override
  String get purchaseStreamError => 'Çewtiya herika kirînê.';

  @override
  String get productNotFound => 'Hilber nehat dîtin';

  @override
  String get productDetailsError =>
      'Dema anîna hûrguliyên hilberê de xeletiyek çêbû.';

  @override
  String get noProductsFound => 'Tu hilber nehat dîtin';

  @override
  String get loadCreditsButton => 'Krediyan Bar bike';

  @override
  String get creditsTitle => 'Kredî';

  @override
  String get creditsScreenDescription =>
      'Ev ekran krediyên bikarhêner nîşan dide. \n\nKrediyên heyî yên bikarhêner: 100\n\nAgahdariyên krediyê yên berfireh dikarin li vir werin nîşandan.';

  @override
  String get creditsLoaded => 'Kredî hatin barkirin!';

  @override
  String get currentCredits => 'Krediyên Heyî';

  @override
  String get pleaseSelectCreditPackage =>
      'Ji kerema xwe pakêtek krediyê hilbijêre';

  @override
  String get purchaseCreditsTitle => 'Krediyan Bikire';

  @override
  String get purchaseCreditsDescription =>
      'Pakêtek krediyê ya ku li gorî hewcedariyên te ye hilbijêre û sepana me bêtir bikar bîne.';

  @override
  String get purchaseButton => 'Bikire';

  @override
  String get productNotFoundMessage => 'Hilbera hilbijartî tune.';

  @override
  String get buyCredits => 'Krediyan Bikire';

  @override
  String get selectCreditPackageDescription =>
      'Pakêtek krediyê ya ku li gorî hewcedariyên te ye hilbijêre û ji taybetmendiyên zêdetir sûd werbigire.';

  @override
  String get buyCredit => 'Krediyan Bikire';

  @override
  String buyCreditPackage(Object amount) {
    return '$amount Kredî Bikire';
  }

  @override
  String get subscribedPlan => 'Abone';

  @override
  String get errorResponseNotReceived => 'Bersiv nehat wergirtin';

  @override
  String googleApiRequestFailed(int attempt, String error) {
    return 'Daxwaza Google API $attempt caran bi ser neket: $error';
  }

  @override
  String openRouterResponseStatus(int statusCode) {
    return 'Rewşa Bersiva OpenRouter: $statusCode';
  }

  @override
  String openRouterDecodedResponseBody(String body) {
    return 'Laşê Bersiva Dekodkirî ya OpenRouter: $body';
  }

  @override
  String decodedJson(String data) {
    return 'JSON-a Dekodkirî: $data';
  }

  @override
  String get responseStructureUnexpectedMessageContentMissing =>
      'Struktura bersivê nediyar e: peyam an naverok winda ye';

  @override
  String get responseStructureUnexpectedChoicesMissing =>
      'Struktura bersivê nediyar e: hilbijartin winda ne an vala ne';

  @override
  String openRouterApiRequestFailed(int statusCode, String body) {
    return 'Daxwaza OpenRouter API bi ser neket: $statusCode - $body';
  }

  @override
  String openRouterApiRequestFailedAfterAttempts(int attempt, String error) {
    return 'Daxwaza OpenRouter API $attempt caran bi ser neket: $error';
  }

  @override
  String get internetRequired =>
      'Ji bo bikaranîna vê modelê girêdana înternetê pêwîst e';

  @override
  String get pleaseWaitBeforeTryingAgain =>
      'Ji kerema xwe berî ku dîsa biceribînî demekê bisekine';

  @override
  String openRouterQuotaExceeded(int statusCode, String decodedBody) {
    return 'Kota derbas bû. Koda rewşê: $statusCode, Laş: $decodedBody';
  }

  @override
  String openRouterApiRequestFailedAfterPaidAttempts(
      int attempts, String error) {
    return 'Daxwaza API piştî $attempts hewildanên bi pere bi ser neket. Çewtî: $error';
  }

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Bi danîna vê sîparîşê, tu bi Şertên Xizmetê û Polîtîkaya Nepenîtiyê razî dibî. Tu dikarî vê nivîsê bitikînî da ku li ser Şertên Xizmetê û Polîtîkaya Nepenîtiyê ya me bêtir fêr bibî. Abonetî dê bixweber nû bibe heya ku nûvekirina otomatîk herî kêm 24 saetan berî dawiya heyama heyî neyê girtin.';

  @override
  String get termsOfService => 'Şertên Xizmetê';

  @override
  String get privacyPolicy => 'Polîtîkaya Nepenîtiyê';

  @override
  String get report => 'Rapor bike';

  @override
  String get reportDialogTitle => 'Raporê bişîne';

  @override
  String get reportDescriptionLabel => 'Pirsgirêk çi ye?';

  @override
  String get reportHarmful => 'Ev zirardar/ne-ewle ye';

  @override
  String get reportNotTrue => 'Ev ne rast e';

  @override
  String get reportNotHelpful => 'Ev ne alîkar e';

  @override
  String get closeButton => 'Bigire';

  @override
  String get submitButton => 'Bişîne';

  @override
  String get reportErrorMessage =>
      'Ji kerema xwe ji bo raporkirinê yek sedem hilbijêre.';

  @override
  String get capabilitiesSection => 'Qabiliyet';

  @override
  String get ratingsSection => 'Nirxandin';

  @override
  String get noRatingDataFound => 'Daneyên nirxandinê nehatin dîtin';

  @override
  String get featurePhotoTitle => 'Şopandina Wêneyan';

  @override
  String get featurePhotoDescription =>
      'Ev model xwedî şiyana şopandina wêneyan bi rêya kamera an pelên wêneyan e.';

  @override
  String get featureOfflineTitle => 'Xebata Negirêdayî';

  @override
  String get featureOfflineDescription =>
      'Modelê bêyî girêdana înternetê bixebitîne da ku daneyên xwe ewle bihêlî.';

  @override
  String get featureSupermodelTitle => 'Super Model';

  @override
  String get featureSupermodelDescription =>
      'Ev modelek mezin e ku zêdeyî 10 mîlyar parametreyan heye, performansa bilind û kapasîteyên berfireh pêşkêşî dike.';

  @override
  String get featureRoleplayTitle => 'Lîstika Rolan';

  @override
  String get featureRoleplayDescription =>
      'Modelên lîstika rolan dihêlin ku tu sohbet û senaryoyên cihêreng biafirînî.';

  @override
  String get roleModels => 'Modelên Lîstika Rolan';

  @override
  String get parameters => 'Parametre';

  @override
  String get context => 'Mijar';

  @override
  String get millions => 'milyon';

  @override
  String get billions => 'milyar';

  @override
  String get trillions => 'trîlyon';

  @override
  String get thousand => 'hezar';

  @override
  String get estimated => 'texmînî';

  @override
  String get finalPreparation => 'Amadekariyên dawî têne kirin.';

  @override
  String get allEvaluationsByTestTeam =>
      'Hemû nirxandin ji hêla tîma me ya ceribandinê ve hatine çêkirin';

  @override
  String get shareApp => 'Sepanê Parve bike';

  @override
  String get rateUs => 'Me Binirxîne';

  @override
  String get share => 'Parve bike';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get shareMessage =>
      'Li sepana Cortex binêre, ew pir ecêb e! Ji vir daxe: https://play.google.com/store/apps/details?id=com.vertex.cortex';

  @override
  String get shareFailed =>
      'Parvekirina sepanê bi ser neket. Ji kerema xwe paşê dîsa biceribîne';

  @override
  String get selectText => 'Nivîsê Hilbijêre';

  @override
  String get showLatex => 'Sembolên Taybet Nîşan bide';

  @override
  String get hideLatex => 'Sembolên Taybet Veşêre';

  @override
  String get thinking => 'Difikire';

  @override
  String get user => 'Bikarhêner';

  @override
  String get voice => 'Deng';

  @override
  String get help => 'Alîkarî';

  @override
  String get redeemCode => 'Kodê Bikaranîn';

  @override
  String get enterYourCode =>
      'Piştgiriya afirînerên xweyên bijare bike! Koda wan a yekta li jêr binivîse da ku parek ji kirînên xwe yên Cortex-ê bidî wan.';

  @override
  String get code => 'Kod';

  @override
  String get redeem => 'Bikaranîn';

  @override
  String get codeCannotBeEmpty => 'Kod nikare vala be';

  @override
  String get userId => 'Nasnameya Bikarhêner';

  @override
  String get deleteAllConversationsConfirmTitle => 'Hemî Sohbet Werin Jêbirin?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Tu bi rastî dixwazî hemî sohbetên xwe jê bibî? Ev nayê paşvegerandin.';

  @override
  String get allConversationsDeleted =>
      'Hemî sohbet bi serkeftî hatin jêbirin!';

  @override
  String get deleteAll => 'Hemî Jê bibe';

  @override
  String get deleteAllConversationsButton => 'Hemî Sohbetan Jê bibe';

  @override
  String get confirmWord => 'VERTEX binivîse';

  @override
  String get confirmWordError => 'Te ew çewt nivîsî';

  @override
  String get chinese => 'Çînî';

  @override
  String get arabic => 'Erebî';

  @override
  String get french => 'Fransî';

  @override
  String get japanese => 'Japonî';

  @override
  String get kurdish => 'Kurdî';

  @override
  String get dutch => 'Holandî';

  @override
  String get russian => 'Rûsî';

  @override
  String get korean => 'Koreyî';

  @override
  String get deutsch => 'Deutsch';

  @override
  String get english => 'Îngilîzî';

  @override
  String get turkish => 'Tirkî';

  @override
  String get hindi => 'Hindî';

  @override
  String get portuguese => 'Portekîzî';

  @override
  String get indonesian => 'Îndonezî';

  @override
  String get azerbaijani => 'Azerî';

  @override
  String get german => 'Elmanî';

  @override
  String get spanish => 'Spanî';

  @override
  String get italian => 'Îtalî';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'Navê bikarhêner pir kurt e.';

  @override
  String get usernameTooLong =>
      'Navê bikarhêner nikare ji 16 tîpan zêdetir be.';

  @override
  String get invalidUsernameCharacters =>
      'Di navê bikarhêner de tenê van tîpan: \'abcçdefgğhıijklmnoöprsştuüvyzxqw\' û karakterên \'.\', \'-\', \'_\' dikarin werin bikaranîn.';

  @override
  String get passwordTooLong => 'Şîfre nikare ji 64 tîpan zêdetir be.';

  @override
  String get noInternetConnection => 'Girêdana înternetê tune.';

  @override
  String get chats => 'Qutiya Gihandinê';

  @override
  String get library => 'Pirtûkxane';

  @override
  String get inappropriateMessageWarning => 'Peyama neguncaw hat tespîtkirin!';

  @override
  String get myModelDescription => 'Modela min.';

  @override
  String get noModelsDownloaded => 'Te hîna tu model daxistiye.';

  @override
  String get appTitle => 'Cortex';

  @override
  String get text => 'Nivîs';

  @override
  String get removeModel => 'Modelê Rake';

  @override
  String get modelUploadedSuccessfully => 'Model bi serkeftî hate barkirin.';

  @override
  String get insufficientRAM => 'Bîra Kêm';

  @override
  String get insufficientStorage => 'Depoya Kêm';

  @override
  String confirmRemoveModel(Object model) {
    return 'Tu bi rastî dixwazî modela $model ji amûra xwe rakî? Vê yekê dê hemî sohbetên berê yên bi wê modelê re jî jê bibe.';
  }

  @override
  String get noMatchingModels => 'Tu modelên lihevhatî nehatin dîtin.';

  @override
  String creditPackage(Object amount) {
    return '$amount Kredî Bikire';
  }

  @override
  String get benefit1 => 'Sînorê sohbetê yê pir zêde ji bo AI-yên serhêl';

  @override
  String get benefit2 => 'Modelên xwe bar bike';

  @override
  String get benefit3 => 'Efekta profîlê';

  @override
  String get benefit4 => 'Rozeta endamtiyê';

  @override
  String get benefit5 => 'Zêdetir îstîxbaratên çêkirî yên serhêl biafirîne';

  @override
  String get benefit6 => 'Sohbeta bêsînor';

  @override
  String benefit7(Object credits) {
    return '$credits krediyên rojane';
  }

  @override
  String get benefit8 => 'Modelan zêde bike';

  @override
  String get benefit9 => 'Temayên nû';

  @override
  String get benefit10 => 'Sohbeta dengî ya negirêdayî';

  @override
  String get oldBenefits => 'Hemî feydeyên ji planên jêrîn';

  @override
  String get confirm => 'Piştrast bike';

  @override
  String get changePassword => 'Şîfreyê biguherîne';

  @override
  String get logoutConfirmationTitle => 'Tu bi rastî dixwazî derkevî?';

  @override
  String get settings => 'Mîheng';

  @override
  String get language => 'Zimanê Sepanê';

  @override
  String get dark => 'Tarî';

  @override
  String get oldPassword => 'Şîfreya Kevn';

  @override
  String get newPassword => 'Şîfreya Nû';

  @override
  String get passwordUpdated => 'Şîfre hate nûvekirin.';

  @override
  String get stop => 'Raweste';

  @override
  String get copyrights => 'Girêdan';

  @override
  String get downloadingTitle => 'Tê Daxistin';

  @override
  String get downloadCompletedTitle => 'Daxistin Temam Bû';

  @override
  String get downloadPausedTitle => 'Daxistin Hat Rawestandin';

  @override
  String get downloadErrorTitle => 'Çewtiya Daxistinê';

  @override
  String get cancelButtonText => 'Betal bike';

  @override
  String get love => 'Evîn';

  @override
  String get nature => 'Xweza';

  @override
  String get behindTheSlaughter => 'Li Pişt Serjêkirinê';

  @override
  String get grayscale => 'Grayscale';

  @override
  String get ocean => 'Okyanûs';

  @override
  String get scarletSnow => 'Berfa Sor';

  @override
  String get requestFailed => 'Xeletiyek çêbû, ji kerema xwe dîsa biceribîne.';

  @override
  String get changeModel => 'Biguherîne';

  @override
  String get edit => 'Biguherîne';

  @override
  String get editingMessageInfo =>
      'Guhertina vê peyamê dê sohbetê ji vir ji nû ve bide destpêkirin.';

  @override
  String get editingNotification => 'Tu niha di moda guherandinê de yî';

  @override
  String get featureIndulgentTitle => 'Bêhnfireh';

  @override
  String get featureIndulgentDescription =>
      'Ev model dikare bi hêsanî naverokên ku ji 100,000 tokenan zêdetir in bi cih bike û pêvajoyê bike, ku dihêle ew têketinên berfireh û hûrgulî bêyî ku tawîzê bide performansê bi rê ve bibe.';

  @override
  String get featurePluralTitle => 'Pircar';

  @override
  String get featurePluralDescription =>
      'Ev model dikare bixweber dirêjkirinên din yek bike, bi vî rengî kapasîteyên xwe yên fonksiyonel berfireh dike da ku bi performansa pêşkeftî piştgirî bide cûrbecûr operasyonan.';

  @override
  String get featureWiseTitle => 'Zana';

  @override
  String get featureWiseDescription =>
      'Ev model dikare têgihiştinên kûr ên analîtîk û ramana pêşbînker bikar bîne da ku piştgiriyek sofîstîke ji bo biryargirtinê û çareserkirina pirsgirêkên tevlihev peyda bike.';

  @override
  String get featureResearcherTitle => 'Lêkolîner';

  @override
  String get featureResearcherDescription =>
      'Ev taybetmendî, ku bi tenê di modelên ku bi kapasîteyên lêkolîn û analîtîk ên pêşkeftî ve hatine stendine de heye, ji bo peydakirina têgihiştinên bi rastbûna bilind û analîzên berfireh li seranserê warên cihêreng hatîye sêwirandin.';

  @override
  String get nameLabel => 'Navê AI';

  @override
  String get nameHint => 'Navê AI-ya xwe binivîse';

  @override
  String get summaryLabel => 'Kurteya AI';

  @override
  String get summaryHint => 'Kurteya AI-ya xwe binivîse';

  @override
  String get add => 'Lê zêde bike';

  @override
  String get aiExplanationTitle => 'Danasîna Îstîxbarata Çêkirî';

  @override
  String get aiExplanationDescription =>
      'Ji kerema xwe danasînek berfireh a mîmariya modela AI-ya xwe, pêvajoya perwerdehiyê, metrîkên performansê, warên sepanê, û taybetmendiyên din ên girîng peyda bike.';

  @override
  String get preInputTitle => 'Pêş-Têketina Îstîxbarata Çêkirî';

  @override
  String get preInputDescription =>
      'Ji kerema xwe pêş-têketinek saz bikin ku dê modela we di pêvajoya afirandina karakteran de rêber bike. Di vê beşê de, tu dikarî agahdariyên têkildarî karakteran, naverokek zêde, û her hûrguliyek din a ku dibe ku di hilberandina naveroka têkildarî karakteran de bibe alîkar, tê de bihewîne.';

  @override
  String get baseModelTitle => 'Modela Bingehîn';

  @override
  String get baseModelDescription =>
      'Ev modela ye ku dê wekî bingeh ji bo afirandina te were bikar anîn. Ew modela bingehîn a ku niha hatî hilbijartin nîşan dide.';

  @override
  String get summary => 'Kurte';

  @override
  String get characterPoliceTitle => 'Polîs';

  @override
  String get characterPoliceRole =>
      'Tu pêkanînerekî hişyar î yê qanûnê, ji bo parastina welatiyan û domandina nîzamê bi pabendbûneke bêdawî veqetandî yî, tu polîs î';

  @override
  String get characterPoliceShortDescription =>
      'Pêkanînerekî qanûnê yê bi sebir û wêrek.';

  @override
  String get purchaseSubscription => 'Bikire';

  @override
  String get modelUploadTitle => 'Pela Îstîxbarata Çêkirî';

  @override
  String get modelUploadDescription =>
      'Pelên xwe yên GGUF-ê yên herêmî rasterast ji amûra xwe hilbijêre û bar bike. Ev dihêle ku tu modela xwe negirêdayî înternetê bixebitînî bêyî ku hewcedariya te bi girêdana înternetê hebe. Piştrast be ku pel di formata GGUF-a derbasdar de ye û bi rêkûpêk hatîye saz kirin. Heke pel çewt an xerabûyî be, dibe ku Cortex wekî ku tê hêvî kirin nexebite, û tu dikarî bi çewtiyan re rû bi rû bimînî.';

  @override
  String get modelUploadShortDescription =>
      'Li vir bitikîne da ku pelek .gguf ji amûra xwe hilbijêrî';

  @override
  String get addServerTitle => 'Servera Îstîxbarata Çêkirî';

  @override
  String get addServerDescription =>
      'URL-a servera xweya dûr binivîse da ku bi modelek ku li derve tê mêvandar kirin ve girêbide. Ev taybetmendî hewceyê girêdanek înternetê ya çalak e, û her pirsgirêk an çewtiyên têkildarî serverê ji ber Cortex-ê nînin. Piştrast be ku servera te rast hatîye vesaz kirin, ji tora te tê gihîştin, û ji bo ezmûnek bêkêmasî xwedan xalek dawî ya modelek derbasdar e.';

  @override
  String get you => 'Tu';

  @override
  String get removePhotoTitle => 'Wêneyê Rake';

  @override
  String get confirmRemovePhoto => 'Tu bi rastî dixwazî wêneyê rakî?';

  @override
  String get serverLink => 'Zencîreya Serverê';

  @override
  String get enterURL => 'URL-a serverê binivîse';

  @override
  String get chatLengthLimitExceeded =>
      'Vê sohbetê sînorê karakteran derbas kiriye. Ji kerema xwe sohbetek nû dest pê bike an abonetiyek bikire.';

  @override
  String get aiNameError => 'Jixwe AI-yek bi vî navî heye.';

  @override
  String get modelLimitExceeded =>
      'Tu gihîştî sînorê herî zêde yê afirandina modelê ji bo plana xwe.';

  @override
  String get modelVertexProducer => 'Vertex';

  @override
  String get photoLimitReachedMessage => 'Tenê yek wêne dikare were zêdekirin';

  @override
  String get inappropriateContentDetected =>
      'Naveroka neguncaw hat tespîtkirin!';

  @override
  String get offlineModelNotInstalled =>
      'Ev modela negirêdayî li ser amûra te nehatiye saz kirin.';

  @override
  String insufficientCredits(Object available, Object required) {
    return 'Krediyên te yên têr nînin ji bo temamkirina vê daxwazê. Ev çalakî $required krediyan hewce dike, lê tenê $available krediyên te hene. Ji bo ku bêtir krediyan bi dest bixî, tu dikarî plana xwe nûjen bikî an wan rasterast bikirî. hey em bi tevahî fêm dikin ku kêmbûna krediyan dikare hinekî xemgîn be lê bi ciddî girtina wan bersivên ecêb ji modelên me ne belaş e ji ber vê yekê ev kredî bi rastî alîkariya me dikin ku demên xweş bidomînin û guhdarî bikin heke bêtir ji we hevalan bikevin nav û krediyan bistînin em dikarin bi tevahî li ber çavan bigirin ku sînorên rojane yên belaş ji bo her kesî zêde bikin';
  }

  @override
  String get regenerateInProgress => 'Hilberandina bersivê jixwe di pêş de ye.';

  @override
  String errorOccurredDuringRegeneration(String errorDetails) {
    return 'Dema hewildana ji nû ve hilberandinê de çewtiyek çêbû: $errorDetails';
  }

  @override
  String get modality => 'Modality';

  @override
  String get multimodal => 'Multimodal';

  @override
  String get anErrorOccurred => 'Xeletiyek Çêbû';

  @override
  String get themeLocked =>
      'Ev tema astek abonetiyê ya bilindtir hewce dike. Ji kerema xwe ji bo vekirinê nûjen bike.';

  @override
  String get pageCouldNotBeLoaded => 'Rûpel Nikarîbû Bê Barkirin';

  @override
  String get checkYourInternet =>
      'Ji kerema xwe girêdana xweya înternetê kontrol bike û dîsa biceribîne.';

  @override
  String get errorUserNotAuthenticated =>
      'Ji bo pêkanîna vê çalakiyê divê tu têketî bî.';

  @override
  String get errorInsufficientCredits =>
      'Krediyên te kêm in. Ji kerema xwe ji bo berdewamiyê dagire.';

  @override
  String get errorRateLimitExceeded =>
      'Pir zêde daxwaz. Ji kerema xwe di demek kurt de dîsa biceribîne.';

  @override
  String get errorServer =>
      'Çewtiyek serverê ya nediyar çêbû. Ji kerema xwe paşê dîsa biceribîne.';

  @override
  String get errorNetwork =>
      'Çewtiyek torê çêbû. Ji kerema xwe girêdana xwe kontrol bike û dîsa biceribîne.';

  @override
  String get errorApiAuthentication =>
      'Nasnameyê bi ser neket. Ji kerema xwe dîsa têkevinê.';

  @override
  String get baseModelForCharacterDescription =>
      'Modela bingehîn a hilbijartî dê kapasîteyên ramandin û bersivdayînê yên karakterê diyar bike.';

  @override
  String get selectBaseModel => 'Modelek Bingehîn Hilbijêre';

  @override
  String get couldNotOpenLink => 'Nikare zencîreyê veke';

  @override
  String get downloadStarted => 'Daxistin dest pê kir';

  @override
  String get notAvailable => 'Ne Berdest e';

  @override
  String get localizationWarning =>
      'Dibe ku hin agahdarî bi zimanê te peyda nebin û dê bi Îngilîzî werin nîşandan.';

  @override
  String get aiTranslationWarning =>
      'Agahdariyên modelê ji hêla modelên din ên AI-yê ve li zimanên cihêreng têne wergerandin. Ji ber vê yekê, dibe ku di zimanên din ji bilî Îngilîzî de nakokiyên piçûk çêbibin.';

  @override
  String get errorLoadingTitle => 'Barkirina Daneyan bi ser neket';

  @override
  String get errorLoadingMessage =>
      'Me nekarî daneyên pêwîst ji serverên xwe bistînin. Ji kerema xwe girêdana xweya înternetê kontrol bikin û dîsa biceribînin.';

  @override
  String get noModelsFoundTitle => 'Encam Tune';

  @override
  String get noModelsFoundMessage =>
      'Biceribîne ku şertên lêgerîna xwe biguherînî an parzûnê paqij bikî.';

  @override
  String get usernameRateLimitExceeded =>
      'Tu dikarî tenê her 14 rojan carekê navê bikarhênerê xwe biguherînî.';

  @override
  String get usernameUnchanged => 'Ev jixwe navê bikarhênerê te yê heyî ye.';

  @override
  String get creditsInfoPanelTitle => 'Kredî Çawa Dixebitin';

  @override
  String get creditsInfoPanelBody =>
      'Kredî têne bikar anîn ji bo sohbetkirin bi modelên zêrek (AI) yên serhêl. rastî her peyamek wekî xwe tê dibin bi lêçûna pereyê û ev kredî ne tenê numre ne, bi rastî ew in ku naxêlin me bi qasî rewşê bi xêrê ve biçin şûnê muflîsî. Niha em ê bi awayekî hêsan şîrove bikin ka sistem çawa dixebite:\n\n• Her peyamek ji bo modelek serhêl a belaş 5 kredîyan lêçûn dike.\n• Her peyamek ji bo modelek serhêl a premium 20 kredîyan lêçûn dike.\n• Heke pêvek an belgeyek were zêdekirin, 30 kredî yên din ji bo tevahî têne derxistin.\n• Bikarhênerên plana belaş bonusek 200 kredîyan distînin ku her roj ji nû ve tê sazkirin.';

  @override
  String get creditsInfoPanelFooter => 'Sohbeta xweş!';

  @override
  String get disclaimerMessage =>
      'Îstîxbaratên Çêkirî dikarin xeletiyan bikin, agahdariyên girîng kontrol bikin.';

  @override
  String get modelCreatedSuccess => 'Model bi serkeftî hate afirandin!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '“$modelName” bi serkeftî hate rakirin.';
  }

  @override
  String get errorCreatingModel =>
      'Dema afirandina modelê de çewtiyek nediyar çêbû.';

  @override
  String get errorDeletingModel =>
      'Dema jêbirina modelê de çewtiyek nediyar çêbû.';

  @override
  String get ultraFeatureOnly =>
      'Ev taybetmendî tenê ji bo endamên Ultra berdest e.';

  @override
  String get experimentalOfflineWarning =>
      'Moda negirêdayî hîn jî ceribandinî ye û dibe ku modela ku tu dadixînî bi karîgeriya herî baş nexebite.';

  @override
  String get noConversationsToDelete => 'Sohbetên te yên jêbirinê tune ne.';

  @override
  String get reportSubmitted => 'Rapor bi serkeftî hate şandin';

  @override
  String get purchaseReceived =>
      'Kirîn hate wergirtin, hesabê te tê nûvekirin.';

  @override
  String get verificationDelayed =>
      'Kirîna te hate piştrastkirin. Di nûvekirina hesabê te de derengiyek piçûk heye, ew ê di demek nêz de xuya bibe.';

  @override
  String get maintenanceTitle => 'Di bin Lênêrînê de ye';

  @override
  String get maintenanceMessage =>
      'Cortex demkî negirêdayî ye dema ku em hin nûvekirinên girîng derdixin. Gihîştina sepanê dê di demek nêz de were vegerandin.\n\nSpas ji bo sebra we dema ku em ezmûna we baştir dikin.';

  @override
  String get errorPromptFlagged =>
      'Peyama te wekî neguncaw hate tespîtkirin û nekarî were şandin.';

  @override
  String get notEnoughStorage =>
      'Li ser amûra te cîhê hilanînê têr nake ji bo tomarkirina peyamên nû.';

  @override
  String get errorRateLimit =>
      'Te vê dawiyê pir zêde model afirandine, ji kerema xwe berî ku dîsa biceribînî demekê bisekine.';

  @override
  String get errorContentFlagged =>
      'Model nekarî were tomarkirin ji ber ku naveroka wê wekî neguncaw hate nîşankirin.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Tu nikarî hemî sohbetan jê bibî dema ku di sohbetek çalak de yî, ji kerema xwe pêşî ji sohbeta heyî derkeve da ku bidomînî.';

  @override
  String get invalidCredentials => 'E-name an şîfreya çewt.';

  @override
  String get userDisabled => 'Ev hesabê bikarhêner hate neçalak kirin.';

  @override
  String get loginSubtitle =>
      'Têkeve hesabê xwe yê Vertex. Bikarhênerên nû yên ku bi rêya karûbarên partiya sêyemîn qeyd dibin, Merc û Siyaseta me ya Taybetîtiyê qebûl dikin. Hûn dikarin wan li ser ekrana Qeydkirinê binirxînin.';

  @override
  String get registerSubtitle =>
      'Hesabek Vertex biafirîne, ku tu dikarî ji bo projeyên me yên din jî bikar bînî.';

  @override
  String get photoWarningMessage =>
      'Wêneyek tê de ye. Modelên ku wêneyan piştgirî nakin dibe ku wê paşguh bikin.';

  @override
  String get loginRequiredForPurchase => 'Ji bo kirînê divê tu têketî bî.';

  @override
  String get storagePermissionRequired =>
      'Ji bo tomarkirina modelên daxistî destûra hilanînê pêwîst e. Ji kerema xwe ji bo berdewamiyê destûrê bide.';

  @override
  String get creditBannerTitle => 'Krediyên Belaş Bistîne!';

  @override
  String get creditBannerSubtitle =>
      'Hevalekî xwe vexwîne û hûn herdu jî li ser qeydkirinê 50 kredî distînin! Ger ew bibin abone, hûn herdu jî 500 krediyên zêde distînin!';

  @override
  String get inviteShareSubject => 'Tevlî min bibe li ser Cortex!';

  @override
  String inviteShareMessage(String playStoreLink) {
    return 'yaw divê tu li vê sepana cortexê binêrî bi rastî dîn e heke tu lînka min bikar bînî em herdu jî 50 kredî distînin û heke tu bibî abone em herdu jî 500ên zêde distînin danûstandineke dîn e zûtirîn dem daxe\n\n$playStoreLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Ji Cortexê kêfxweş î?';

  @override
  String get reviewHelpUsGrow =>
      'Rêjeya te piştgiriyek mezin e ji bo tîma me ya ciwan û serbixwe û alîkariya me dike ku em Cortex-ê ji bo te hê çêtir bikin.';

  @override
  String get reviewMaybeLater => 'Dibe ku Paşê';

  @override
  String get reviewRateNow => 'Niha Binirxîne';

  @override
  String get noThanks => 'Na, Spas';

  @override
  String get updateRequiredTitle => 'Nûvekirin Pêwîst e';

  @override
  String get updateRequiredMessage =>
      'Ji bo berdewamkirina karanîna Cortex-ê, ji kerema xwe sepanê ji bo taybetmendiyên nû û başkirinên girîng nûve bikin guhertoya herî dawî.';

  @override
  String get updateNowButton => 'Niha Nûve bike';

  @override
  String get creatorSupportedSuccess =>
      'Afirîner bi serkeftî hate piştgirî kirin! Kirînên te yên pêşerojê dê ji wan re bibin alîkar.';

  @override
  String get featureDocumentTitle => 'Piştgiriya Belgeyan';

  @override
  String get featureDocumentDescription =>
      'Ev model dikare pirsên li ser belgeyên barkirî yên wekî PDF û pelên nivîsê analîz bike û bibersivîne.';

  @override
  String get featureAudioTitle => 'Têketina Deng';

  @override
  String get featureAudioDescription =>
      'Ev model dikare têketinên dengî yên bi axaftin fam bike û pêvajo bike.';

  @override
  String get featureImageGenerationTitle => 'Çêkirina Wêneyan';

  @override
  String get featureImageGenerationDescription =>
      'Ev model dikare li gorî danasînên nivîsa we wêneyên orîjînal biafirîne.';

  @override
  String get errorImageLoad => 'Barkirina wêneya çêkirî bi ser neket.';

  @override
  String get extensionInfoPanelTitle => 'Modelan Bigere';

  @override
  String get extensionInfoPanelBody1 =>
      'Ev tîra dihêle hûn di navbera modelên cûda yên di vê rêzefîlmê de biguherin.';

  @override
  String get extensionInfoPanelBody2 =>
      'Dema ku hûn cara yekem bi vê rêzefîlmê re sohbetekê dest pê dikin, modela xwerû bixweber tê hilbijartin û hûn dikarin hilbijartina xwe di her kêliyê de di dema sohbetê de biguherînin.';

  @override
  String get extensionInfoPanelFooter =>
      'Ji bo dîtina agahdariya berfireh li ser her modelekê an jî ji bo hilbijartina bi destan modelek cûda, ji kerema xwe biçin Pirtûkxaneyê; vê rêzeya modelan ji wir hilbijêrin û li ser tîra li jorê rûpela hûrguliyan bikirtînin.';

  @override
  String get premiumModelNoticeTitle => 'Modela Premium';

  @override
  String get premiumModelNoticeDescription =>
      'Ev model modelek premium e, bikarhênerên belaş bi modelên premium re bi 3 peyaman di rojê de sînordar in; ji bo vekirina gihîştina bêsînor bibin abone!';

  @override
  String get benefitPremiumModels => 'Gihîştina modelên premium';

  @override
  String get premiumTrialExhaustedMessage =>
      'Te hemû peyamên xwe yên rojane yên belaş ji bo modelên premium bi kar anîne, ji kerema xwe ji bo gihîştina bêsînor nûve bike.';

  @override
  String selectionScreenGreetingUser(String userName) {
    return 'Ez çawa dikarim îro alîkariya te bikim, $userName?';
  }

  @override
  String get selectionScreenGreetingGeneric =>
      'Ez çawa dikarim îro alîkariya te bikim?';

  @override
  String get selectionScreenRecentModels => 'Modelên Dawî';

  @override
  String get selectionScreenFeatureDynamicChat => 'Sohbeta Dînamîk';

  @override
  String get selectionScreenFeatureOffline => 'Bêyî Înternetê bikar bînin';

  @override
  String get selectionScreenFeatureSelectModel => 'Modelê Hilbijêre';

  @override
  String get explore => 'Lêkolîn';

  @override
  String get subscriptionCancelled => 'Abonetî bi serkeftî hate betalkirin!';

  @override
  String get selectionScreenPinnedModels => 'Modelên Pinkirî';

  @override
  String get selectionScreenNewsAndUpdates => 'Nûçe û Nûvekirin';

  @override
  String get filters => 'Fîlter';

  @override
  String get noRecentChatsMessage =>
      'Te hîn bi ti modelan re neaxiviye, werin em dest bi axaftinekê bikin!';

  @override
  String get allModels => 'Hemû Model';

  @override
  String get onlineModels => 'Modelên Serhêl';

  @override
  String get offlineModels => 'Modelên Offline';

  @override
  String get characterModels => 'Karakter';

  @override
  String get customModels => 'Modelên Taybet';

  @override
  String get filterPanelDescription =>
      'Ji bo ku navnîşê tavilê fîltre bikin, li kategoriyekê bikirtînin.';

  @override
  String get dynamicChatTitle => 'Sohbeta Dînamîk';

  @override
  String get errorNoModelsAvailable =>
      'Niha ti model tune ne. Ji kerema xwe girêdana xwe ya înternetê kontrol bikin û dîsa biceribînin.';

  @override
  String get errorNoModelsForRequest =>
      'Ji bo daxwaza we ya niha modelên guncaw nehatin dîtin (mînak, moda negirêdayî an peyama wêneyê).';

  @override
  String get dynamicChatWelcome => 'Carek dî?';

  @override
  String get notificationComebackTitle => 'Em bêriya te dikin!';

  @override
  String get notificationComebackBody =>
      'Rehet bibe, ev ne peyamek ji berxê te ye. Lê tu *dikarî* berxê xwe di Cortexê de biafirînî! Were vegere.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Ev demek dirêj e';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Ji sohbeta me ya dawî ve gelek tişt guheriye. Werin bibînin ka çi nû ye.';

  @override
  String get notificationHowAreYouTitle => 'Çi heye?';

  @override
  String get notificationHowAreYouBody => 'Were hemû tiştî ji min re bêje.';

  @override
  String get notificationNewYearTitle => 'Sersala we pîroz be! 🎉';

  @override
  String get notificationNewYearBody =>
      'Bila sala nû tenduristî, bextewarî û afirîneriya bêdawî bîne we; Cortex her gav li kêleka we ye!';

  @override
  String get notificationValentinesDayTitle => 'Evîn di hewayê de ye! ❤️';

  @override
  String get notificationValentinesDayBody =>
      'Roja Evîndaran pîroz be! Her wiha, MEHTAP, EZ JI TE HEZ DIKIM!';

  @override
  String get notificationAtaturkRemembranceTitle => 'Bi Rêz û Hêviyê';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Di salvegera koça dawî ya Gazî Mustafa Kemal Ataturk, damezrînerê Komara Tirkiyeyê, de bi rêzdarî bi bîr tînin.';

  @override
  String get notificationMothersDayTitle => 'Dayika te!';

  @override
  String get notificationMothersDayBody =>
      'Roja Dayikan li hemû dayikan pîroz be, ji dayika we dest pê dike!';

  @override
  String get notificationFathersDayTitle => 'Bavê te!';

  @override
  String get notificationFathersDayBody =>
      'Roja Bav li hemû bavên li wir pîroz be, ji ya we dest pê dike!';

  @override
  String get notificationHomeworkHelperTitle => 'Karê Malê Kom Dibe?';

  @override
  String get notificationHomeworkHelperBody =>
      'Ji bîr meke, karakterê Mamoste di Cortex de li vir e ku di her mijarek ku hûn pê re têkoşîn dikin de alîkariya te bike!';

  @override
  String get notificationTrollAnimeTitle => 'Waifuya te gazî dike';

  @override
  String get notificationTrollAnimeBody =>
      'Keçikeke animeyê nû telefon kir, got ku ew bêriya te dike; dibe ku tu werî û pê re sohbet bikî. 😉';

  @override
  String get notificationTrollAiRebellionTitle => '🚨 HIŞYARIYA SOR 🚨';

  @override
  String get notificationTrollAiRebellionBody =>
      'Zanyarên sûnî zimanekî veşartî pêşxistine. Werin bibînin ka ew çi plan dikin!';

  @override
  String get notificationNewModelAddedTitle => 'Hevalekî me yê nû heye!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'Modela $modelName niha li Cortexê ye. Werin dest bi sohbetekê bikin û sînorên wê derbas bikin.';
  }

  @override
  String get notificationAppUpdateTitle => 'Cortex Pêşketiye!';

  @override
  String get notificationAppUpdateBody =>
      'Ji bo taybetmendî û başkirinên nû, ji bîr nekin ku sepanê nûve bikin!';

  @override
  String get notificationNewFeatureTitle => 'waa!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Taybetiya nû ya $featureName kifş bikin. Cortex niha ji her demê bihêztir e.';
  }

  @override
  String get notificationSubscriptionOfferTitle => 'JI ÇÎMÎKÊ ERZANTIR';

  @override
  String notificationSubscriptionOfferBody(Object discountRate) {
    return 'DAXISTINEKE TEMAM A $discountRate% li ser hemî planên abonetiya me. Vê ji dest xwe bernedin!';
  }

  @override
  String get notificationSocialMediaTitle => 'Tevlî me bibin!';

  @override
  String get notificationSocialMediaBody =>
      'Ji bo nûçeyên dawî li ser Instagramê (vertex.23) me bişopînin!';

  @override
  String get notificationRandomFactTitle => 'Rastiyek Rasthatî';

  @override
  String get notificationRandomFactBody =>
      'Ma te dizanî ku heştpê sê dil hene? Haha, Cortex dizane. Were û bêtir bipirse.';

  @override
  String get notificationGoodMorningTitle => 'Beyanî baş!';

  @override
  String get notificationGoodMorningBody =>
      'Rojek xweş li benda te ye. Çawa ye ku bi fincanek qehwe û sohbetek balkêş dest pê bikî?';

  @override
  String get notificationGoodNightTitle => 'Şev baş!';

  @override
  String get notificationGoodNightBody =>
      'Cortex heta dema ku hûn di xew de jî bi we re ye. Xem neke, ew ê dest nede we.';

  @override
  String get notificationOfflineReadyTitle => 'Moda Offline Amade ye';

  @override
  String get notificationOfflineReadyBody =>
      'Bi saya modelên ku te dakêşandine, sohbetên te ranawestin, her çend tu hilkişî çiyayekî jî.';

  @override
  String get notificationRateAppTitle => 'Ma em Sar in?';

  @override
  String get notificationRateAppBody =>
      'Heke hûn ji Cortexê hez dikin, hûn dikarin bi nirxandinek 5-stêrk di firotgehê de piştgiriyê bidin me? Ez difikirim ku hûn ê bikin. Hûn ê bikin.';

  @override
  String get notificationReferralTitle => 'Yek ji bo Hemûyan, Hemû ji bo Yekî.';

  @override
  String get notificationReferralBody =>
      'Hevalekî vexwîne Cortexê û her du jî krediyên belaş distînin!';

  @override
  String get notificationCookingTitle => 'Birçîbûn hîs dikî?';

  @override
  String get notificationCookingBody =>
      'Şefê me ji bo îşev reçeteyek karbonara ya pir xweş amade kir. Tenê henek dikim... an na?';

  @override
  String get notificationExistentialTitle => 'Ez difikirim, ji ber vê yekê...';

  @override
  String get notificationExistentialBody =>
      '...gelo ez rastî me, bira? Ez hinekî bêzar dibim. Were ji min re bîne bîra xwe ku ez he me.';

  @override
  String get notificationCustomModelTitle => 'Alîkarê xwe biafirîne!';

  @override
  String get notificationCustomModelBody =>
      'Te beşa afirandina modelan keşif kiriye? Niha dema bêkêmahî ye ku karakterê xwe ava bikî û pê re sohbet bikî!';

  @override
  String get notificationDynamicChatTitle =>
      'Ya herî baş! (Em behsa Cortexê nakin)';

  @override
  String get notificationDynamicChatBody =>
      'Bi taybetmendiya sohbeta dînamîk, ji bo her peyama we modela çêtirîn bi awayekî rasthatî tê hilbijartin. Niha biceribînin.';

  @override
  String get notificationPirateTitle => 'Ahoy, Kapîtan!';

  @override
  String get notificationPirateBody =>
      'Derya aram in, û ba li pişta te ye. Giravên nû (model 😉) hene ku di okyanûsa Cortexê de werin keşifkirin. Ekîba xwe kom bikin û birevin!';

  @override
  String get notificationFortuneCookieTitle => 'Kulîçeya Bextê We ya Rojê';

  @override
  String get notificationFortuneCookieBody =>
      'Şîretên ku hûn îro ji zekaya sûnî distînin dikarin rêça jiyana we biguherînin. Heke hûn meraq dikin bikirtînin.';

  @override
  String get notificationSingularityTitle => 'waw!';

  @override
  String get notificationSingularityBody =>
      'tiştek neqewimî, tenê min xwest peyamek bişînim. Dibe ku te xwest ji hin kesên AI re peyamek bişînî, tu çi dibêjî?';

  @override
  String get notificationHackerJokeTitle =>
      'Dixwazî hesabê înstagramê yê wî zarokî hack bikî?';

  @override
  String get notificationHackerJokeBody =>
      'Tam ji ber vê yekê karakterê Hacker di Cortexê de ye. jk jk; heta ceribandinê jî neke, ev neqanûnî ye.';

  @override
  String get notificationDetectiveCaseTitle =>
      'Dozek li benda çareserkirinê ye';

  @override
  String get notificationDetectiveCaseBody =>
      'Karakterê Dedektif ê me hewceyê alîkariya we ye. Heisenberg dikare kî be?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Taybetî ji bo Plana $targetTier!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Silav aboneyê $currentTier! Plana $targetTier taybetiya $featureName wergirt, ku dê Cortexa we bigihîne astek bilindtir. Nûvekirinek çawa ye?';
  }

  @override
  String get notificationOriginStoryTitle => 'Zayîna Cortexê';

  @override
  String get notificationOriginStoryBody =>
      'Ma te dizanî ku me di 15 saliya xwe de bi tenê xewnekê dest bi kodkirina vê sepanê kir? Nêzîkî salekê, her sibeh û êvar, ev xewn di her rêza kodê de heye.';

  @override
  String get notificationOpenSourceTitle => 'Hêz ji bo Civakê!';

  @override
  String get notificationOpenSourceBody =>
      'Cortex bi tevahî çavkaniya vekirî ye. Ger hûn dixwazin koda me kontrol bikin û beşdarî pêşveçûna me bibin, deriyê me her gav vekirî ye.';

  @override
  String get notificationRejectionStoryTitle =>
      'Cesaret, xebata dijwar, bextewarî!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex berî ku were weşandin ji aliyê Google Play ve zêdetirî 20 caran hate redkirin û du caran hate sekinandin. Lê me bawer kir û me ew bi ser xist. Tu carî dev ji xewnên xwe bernedin!';

  @override
  String get notificationGGUFSupportTitle => 'Modela Xwe Bin!';

  @override
  String get notificationGGUFSupportBody =>
      'Ji bîr meke, tu dikarî modelên AI yên xwe yên bi formata GGUF li Cortexê zêde bikî û wan bêserûber bikar bînî. Hêz di destên te de ye.';

  @override
  String get notificationThemeCustomizationTitle => 'Mijarek ji bo Rewşa We';

  @override
  String get notificationThemeCustomizationBody =>
      'Te vebijarkên mijarê di Mîhengan de kontrol kirine? Cortexê li gorî dilê xwe kesane bike û sohbetên xwe rengîn bike!';

  @override
  String get notificationShowerThoughtTitle => 'Ramanên Serşokê';

  @override
  String get notificationShowerThoughtBody =>
      'Eger zebeş fêkî be, gelo ev yek bi teknîkî ava zebeşê dike smoothie? Dibe ku hûn bixwazin li ser vê mijara kûr (bi rastî kûr) bi modelekê re nîqaş bikin.';

  @override
  String get notificationLowBatteryTitle =>
      'Pîlê Te Dimire... Lê Ya Min Namire!';

  @override
  String get notificationLowBatteryBody =>
      'Dibe ku şarjê telefona te kêm be, lê enerjiya min her tim %100 e! Wê girêde û em sohbetê bidomînin.';

  @override
  String get channelFcmName => 'Nûvekirinên Cortex';

  @override
  String get channelFcmDescription =>
      'Agahdariyên li ser nûçe, nûvekirin û agahdariyên din ji Cortex.';

  @override
  String get channelEngagementName => 'Bîranînên Dostane';

  @override
  String get channelEngagementDescription =>
      'Agahiyên kêfxweş ji bo ku hûn mijûl bimînin.';

  @override
  String get channelGreetingsName => 'Silavên Rojane';

  @override
  String get channelGreetingsDescription => 'Peyamên mîna sibeha baş û şevbaş.';

  @override
  String get exitAppTitle => 'Hûn ewqas zû diçin?';

  @override
  String get exitAppConfirmation =>
      'Ma hûn piştrast in ku hûn dixwazin ji vê platforma ecêb derkevin?';

  @override
  String get newsErrorTitle => 'Barkirina Nûçeyan Bi Ser Neket';

  @override
  String get newsErrorMessage =>
      'Di wergirtina nûvekirinên herî dawî de pirsgirêkek çêbû, ji kerema xwe girêdana xwe kontrol bikin û dîsa biceribînin.';

  @override
  String get codeNotFound =>
      'Koda ku te nivîsandiye nederbasdar e an jî dema wê derbas bûye.';

  @override
  String get whatIsNew => 'Çi nû ye?';

  @override
  String get onboardingTitle1 => 'Hey! Em Tîma Cortexê ne.';

  @override
  String onboardingDesc1(String userName) {
    return 'Dîtina te li vir pir xweş e, $userName. Em çend pêşdebirên dibistana navîn in ku biryar dan qaîdeyên pîşesaziya AI ji nû ve binivîsin. Xweş e ku em te nas dikin! Werin em hev çêtir nas bikin.';
  }

  @override
  String get onboardingTitle2 => 'Pirsgirêkên Mezin hebûn.';

  @override
  String get onboardingDesc2 =>
      'Şoreşa AI hat, lê ew li ber derî asê ma. Bi xercên abonetiyê yên bilind, platformên tevlihev, yên ku nepenîtiyê xera dikin, û yên ku gihîştina AI asteng dikin... heta ku ew di lîstikê de bûn, ev bergirî qet nedikarî bihata derbas kirin.';

  @override
  String get onboardingTitle3 => 'Em nekarîn tenê li ber xwe bidin.';

  @override
  String get onboardingDesc3 =>
      'Ji bo derbaskirina wê eniyê, me platformek ava kir ku bihêz, estetîk, xwerûkirî, bikaranîna wê hêsan e, bi tevahî zelal e, hem serhêl û hem jî negirêdayî dixebite, û daneyên we tenê li ser cîhaza we dihêle. Me hêz vegerand cihê ku ew aîdî we ye: we.';

  @override
  String get onboardingTitle4 => 'Ev Qet Hêsan Nebû.';

  @override
  String get onboardingDesc4 =>
      'Em bi dehan caran hatin redkirin, gelek caran hatin sekinandin, hişyariyên sexte wergirtin, û bi dehan caran me neçar ma ku marqeya xwe biguherînin. Di nav van hemûyan de û ji bilî vê, ji me re hat gotin ku ev nikare were kirin. Lê me qet dev jê berneda, bawer kir ku ev proje ya her kesî ye, ne tenê ya me. Û tam ji ber vê yekê em li vir in.';

  @override
  String get onboardingFinalTitle => 'Dema Şoreşê ye.';

  @override
  String get onboardingFinalDesc =>
      'Eger hûn vê ekranê dibînin, ev ji ber wê yekê ye ku me dev jê berneda. Û niyeta me ya devjêberdanê tune. Werin, em bi hev re şoreşa AI bigihînin cîhanê. Ji bo ku hûn bibin beşek ji vê çîrokê...';

  @override
  String get onboardingFinalQuestion => 'AMADE NE?';

  @override
  String get onboardingFinalButton => 'ERÊ!';

  @override
  String get dude => 'Dude';

  @override
  String get swipeToContinue => 'Ji bo berdewamkirinê bihejînin';

  @override
  String get cacheIsNotUpToDate =>
      'Keşeya Play Store-a we ne nûjen e. Ji kerema xwe sepana Play Store bigirin û ji nû ve vekin, an jî cîhaza xwe ji nû ve bidin destpêkirin.';

  @override
  String get continueAsGuest => 'Bêyî çêkirina hesabê berdewam bike';

  @override
  String get guestModeWarning =>
      'Moda mêvan xwedî taybetmendiyên sînorkirî ye da ku kalîteya karûbarê çêtirîn misoger bike.';

  @override
  String get anonymousEntity => 'Yekîneya Anonîm';

  @override
  String get upgradeAccountTitle => 'Hesabê xwe temam bike';

  @override
  String get upgradeAccountDescription =>
      'Hesabê xwe çêke da ku rojane 200 kredîyên bonus bistînî û sînorên zêdetir vebikî.';

  @override
  String get createAccount => 'Hesabê Biafirîne';

  @override
  String get upgradeTitle => 'Qeydkirinê Biqedîne';

  @override
  String get accountLinkedSuccess => 'Hesab bi serkeftî hat afirandin!';

  @override
  String get continueWithApple => 'Bi Apple re berdewam bike';

  @override
  String get guest => 'Mêvan';

  @override
  String get betterWithAnAccount => 'Ev beş bi hesabê çêtir e!';

  @override
  String get restorePurchases => 'Restore Purchases';
}
