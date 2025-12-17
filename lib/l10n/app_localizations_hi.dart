// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get understood => 'समझ गया।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get remove => 'हटाएं';

  @override
  String get download => 'डाउनलोड करें';

  @override
  String get resume => 'फिर से शुरू करें';

  @override
  String get copy => 'कॉपी करें';

  @override
  String get chat => 'चैट';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get light => 'लाइट';

  @override
  String get theme => 'थीम';

  @override
  String get no => 'नहीं';

  @override
  String get yes => 'हाँ';

  @override
  String get done => 'हो गया';

  @override
  String get comingSoon => 'जल्द आ रहा है';

  @override
  String get bestValue => 'सबसे अच्छा मूल्य';

  @override
  String get selected => 'चुना हुआ';

  @override
  String get descriptionSection => 'विवरण';

  @override
  String get searchHint => 'खोजें';

  @override
  String get messageHint => 'कुछ भी पूछें';

  @override
  String get modelLoading => 'मॉडल लोड हो रहा है...';

  @override
  String get messageCopied => 'संदेश क्लिपबोर्ड पर कॉपी किया गया।';

  @override
  String get storeUnavailable =>
      'स्टोर वर्तमान में अनुपलब्ध है। कृपया बाद में पुनः प्रयास करें';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get systemInfo => 'सिस्टम जानकारी';

  @override
  String deviceMemory(Object memory) {
    return 'डिवाइस मेमोरी: $memory GB';
  }

  @override
  String storageSpace(Object storage) {
    return 'स्टोरेज स्पेस: $storage GB';
  }

  @override
  String freeStorageSpace(Object freeStorage) {
    return 'फ्री स्टोरेज स्पेस: $freeStorage GB';
  }

  @override
  String get memory => 'मेमोरी';

  @override
  String get storage => 'स्टोरेज';

  @override
  String get freeStorage => 'फ्री स्टोरेज';

  @override
  String get totalStorage => 'कुल स्टोरेज';

  @override
  String get usedStorage => 'प्रयुक्त स्टोरेज';

  @override
  String get totalMemory => 'कुल मेमोरी';

  @override
  String get usedMemory => 'प्रयुक्त मेमोरी';

  @override
  String get requirements => 'आवश्यकताएँ';

  @override
  String get modelsTitle => 'लाइब्रेरी';

  @override
  String get localModels => 'स्थानीय मॉडल';

  @override
  String get serverSideModels => 'ऑनलाइन मॉडल';

  @override
  String get uploadYourOwnModel => 'अपना खुद का मॉडल अपलोड करें!';

  @override
  String get selectGGUFFile => 'GGUF फ़ाइल चुनें';

  @override
  String get errorGGUF => 'कृपया केवल GGUF प्रारूप में एक फ़ाइल चुनें।';

  @override
  String get modelAlreadyExists => 'मॉडल पहले से मौजूद है।';

  @override
  String get modelAddedSuccessfully => 'मॉडल सफलतापूर्वक जोड़ा गया।';

  @override
  String get modelRemoved => 'मॉडल सफलतापूर्वक हटा दिया गया।';

  @override
  String get removeError => 'मॉडल हटाते समय एक त्रुटि हुई।';

  @override
  String get fileNotFound => 'फ़ाइल नहीं मिली।';

  @override
  String get fileUploadError => 'फ़ाइल अपलोड करते समय एक त्रुटि हुई।';

  @override
  String get noFileSelected => 'कोई फ़ाइल नहीं चुनी गई।';

  @override
  String get myModels => 'मेरे मॉडल';

  @override
  String get create => 'बनाएं';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String modelProducer(Object producer) {
    return 'निर्माता: $producer';
  }

  @override
  String modelRAM(Object ram) {
    return 'रैम: $ram';
  }

  @override
  String modelSize(Object size) {
    return 'आकार: $size';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get conversationsTitle => 'बातचीत';

  @override
  String get conversationDeleted => 'बातचीत हटा दी गई।';

  @override
  String get conversationUpdated => 'बातचीत अपडेट की गई।';

  @override
  String get editConversationTitle => 'नाम बदलें';

  @override
  String get newTitle => 'नया शीर्षक';

  @override
  String get save => 'सहेजें';

  @override
  String get titleCannotBeEmpty => 'शीर्षक खाली नहीं हो सकता।';

  @override
  String get noConversationsMessage => 'कोई बातचीत नहीं, चैट करना शुरू करें!';

  @override
  String get startChat => 'एक चैट शुरू करें';

  @override
  String get noChats => 'कोई चैट नहीं';

  @override
  String get starredChats => 'तारांकित चैट';

  @override
  String get allChats => 'सभी चैट';

  @override
  String get noStarredChats => 'कोई तारांकित चैट नहीं';

  @override
  String get noStarredChatsMessage =>
      'आपने अभी तक किसी चैट को तारांकित नहीं किया है।';

  @override
  String get goToChats => 'एक चैट को तारांकित करें';

  @override
  String get starConversation => 'तारांकित करें';

  @override
  String get conversationTitleUpdated => 'बातचीत का शीर्षक अपडेट किया गया';

  @override
  String get youReachedConversationLimit =>
      'आप बातचीत की सीमा तक पहुंच गए हैं।';

  @override
  String get today => 'आज';

  @override
  String get yesterday => 'कल';

  @override
  String get loginToYourAccount => 'लॉगिन करें';

  @override
  String get createYourAccount => 'रजिस्टर करें';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get confirmPassword => 'पासवर्ड की पुष्टि कीजिये';

  @override
  String get invalidEmail => 'कृपया एक मान्य ईमेल पता दर्ज करें।';

  @override
  String get invalidPassword => 'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए।';

  @override
  String get rememberMe => 'मुझे याद रखना';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get or => 'या';

  @override
  String get continueWithGoogle => 'Google के साथ जारी रखें';

  @override
  String get dontHaveAccount => 'खाता नहीं है?';

  @override
  String get alreadyHaveAccount => 'पहले से ही एक खाता है?';

  @override
  String get signUp => 'साइन अप करें';

  @override
  String get logIn => 'लॉग इन करें';

  @override
  String get passwordsDoNotMatch => 'पासवर्ड मेल नहीं खाते।';

  @override
  String get userNotFound => 'उपयोगकर्ता नहीं मिला।';

  @override
  String get wrongPassword => 'गलत पासवर्ड।';

  @override
  String get emailAlreadyInUse => 'यह ईमेल पहले से ही उपयोग में है।';

  @override
  String get weakPassword => 'पासवर्ड बहुत कमजोर है।';

  @override
  String get authError => 'प्रमाणीकरण त्रुटि';

  @override
  String get invalidUsername => 'कृपया एक उपयोगकर्ता नाम दर्ज करें।';

  @override
  String get usernameTaken => 'यह उपयोगकर्ता नाम पहले ही ले लिया गया है।';

  @override
  String get username => 'उपयोगकर्ता नाम';

  @override
  String get authenticationFailed => 'प्रमाणीकरण विफल। कृपया पुनः प्रयास करें।';

  @override
  String get emailTooLong => 'ईमेल अधिकतम 30 अक्षरों का हो सकता है।';

  @override
  String get deviceLimitReached =>
      'आप इस डिवाइस के लिए खाता निर्माण सीमा तक पहुंच गए हैं।';

  @override
  String get verificationEmailLimitReached => 'हम और नहीं भेजेंगे';

  @override
  String get verificationEmailSent => 'सत्यापन ई-मेल भेजा गया!';

  @override
  String get emailNotVerified => 'ई-मेल सत्यापित नहीं किया गया है';

  @override
  String get resendCode => 'सत्यापन ई-मेल पुनः भेजें';

  @override
  String get remainingSeconds => 'सत्यापन के लिए शेष समय';

  @override
  String get pleaseCheckYourEmail =>
      'Cortex का उपयोग करने के लिए, आपको अपना ईमेल सत्यापित करना होगा। \n आपके ईमेल पते पर एक सत्यापन लिंक भेजा गया है, कृपया अपना ईमेल जांचें।';

  @override
  String get verifyYourEmail => 'अपना ईमेल सत्यापित करें';

  @override
  String get backToLogin => 'वापस जाएं';

  @override
  String get seconds => 'सेकंड';

  @override
  String get maxResendLimitReached =>
      'आप सत्यापन ईमेल की अधिकतम संख्या तक पहुंच गए हैं';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'सत्यापन के बिना जारी रखें';

  @override
  String get verificationScreenWarning =>
      'भले ही आप जारी रखें, आपके खाते के लिए 1-दिवसीय खाता सत्यापन अवधि अभी भी प्रभावी है। यदि आपने तब तक अपना खाता सत्यापित नहीं किया है, तो इसे ऐप से हटा दिया जाएगा।';

  @override
  String get unverifiedAccountHeader => 'आपका खाता सत्यापित नहीं है';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'यदि आप $timeLeft के भीतर अपने खाते को सत्यापित नहीं करते हैं, तो इसे हटा दिया जाएगा';
  }

  @override
  String get verifyNow => 'अभी सत्यापित करें';

  @override
  String get accountVerified => 'आपका खाता सत्यापित हो गया है।';

  @override
  String get linkSent => 'लिंक भेजा गया';

  @override
  String get accountDeletionRequested =>
      'आपके खाते को हटाने का अनुरोध प्राप्त हो गया है और आपका खाता अब अक्षम है।';

  @override
  String get tooManyRequests => 'बहुत सारे अनुरोध';

  @override
  String get regenerate => 'पुनः उत्पन्न करें';

  @override
  String get confirmDeleteAccount => 'क्या आप वाकई अपना खाता हटाना चाहते हैं?';

  @override
  String get enterPasswordToDelete => 'हटाने के लिए अपना पासवर्ड दर्ज करें।';

  @override
  String get deleteAccount => 'खाता हटाएं';

  @override
  String get deleteAccountError => 'खाता हटाते समय एक त्रुटि हुई।';

  @override
  String get delete => 'हटाएं';

  @override
  String get passwordRequired => 'पासवर्ड आवश्यक है।';

  @override
  String get deleteDescription =>
      'आपके द्वारा हटाया गया डेटा हमारे सर्वर और आपके डिवाइस से स्थायी रूप से हटा दिया जाएगा। यह कार्रवाई पूर्ववत नहीं की जा सकती।';

  @override
  String get deleteAccountButton => 'खाता विलोपन बटन';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get displayName => 'प्रदर्शित होने वाला नाम';

  @override
  String get tapToChangeProfilePicture =>
      'प्रोफ़ाइल चित्र बदलने के लिए टैप करें';

  @override
  String get profileUpdated => 'प्रोफ़ाइल सफलतापूर्वक अपडेट की गई';

  @override
  String get updateFailed => 'प्रोफ़ाइल अपडेट करने में विफल';

  @override
  String get nameCannotBeEmpty => 'नाम खाली नहीं हो सकता';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get noDisplayName => 'कोई प्रदर्शन नाम सेट नहीं है';

  @override
  String get noEmail => 'कोई ईमेल पता नहीं';

  @override
  String get noUserLoggedIn => 'वर्तमान में कोई उपयोगकर्ता लॉग इन नहीं है';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get manageProfileDescription =>
      'अपनी प्रोफ़ाइल प्रबंधित करें, अपना पासवर्ड अपडेट करें, या Cortex से लॉग आउट करें।';

  @override
  String get accessSettingsDescription =>
      'सहायता तक पहुंचें, कोड रिडीम करें, Cortex साझा करें, और हमारी नीतियां देखें।';

  @override
  String get languageDescription =>
      'आप किसी भी समय अपनी डिफ़ॉल्ट ऐप इंटरफ़ेस भाषा बदल सकते हैं।';

  @override
  String get themeDescription =>
      'आप पसंद के अनुसार लाइट और डार्क थीम के बीच स्विच कर सकते हैं। चयनित थीम Cortex इंटरफ़ेस पर लागू होगी।';

  @override
  String get iHaveReadAndAgree =>
      'मैंने सेवा की शर्तों को पढ़ लिया है और उनसे सहमत हूं';

  @override
  String get downloading => 'डाउनलोड हो रहा है...';

  @override
  String get downloadError => 'डाउनलोड के दौरान एक त्रुटि हुई।';

  @override
  String get downloadCancelled => 'डाउनलोड रद्द कर दिया गया।';

  @override
  String get downloadResumed => 'डाउनलोड फिर से शुरू हो गया।';

  @override
  String get downloadSuccess => 'डाउनलोड सफल';

  @override
  String get downloadFailed => 'डाउनलोड विफल';

  @override
  String downloaded(Object percent) {
    return '$percent% डाउनलोड किया गया';
  }

  @override
  String get downloadPaused => 'डाउनलोड रोक दिया गया।';

  @override
  String get purchaseSuccessful => 'खरीद सफल!';

  @override
  String get purchaseFailed => 'खरीद असफल';

  @override
  String get creditProductNotFound => 'चयनित क्रेडिट उत्पाद नहीं मिला।';

  @override
  String get creditsAddedSuccessfully =>
      'क्रेडिट आपके खाते में सफलतापूर्वक जोड़ दिए गए!';

  @override
  String get creditDeliveryFailed =>
      'आपके खाते में क्रेडिट जोड़ने में विफल। कृपया सहायता से संपर्क करें।';

  @override
  String get invalidPurchase => 'अमान्य खरीद';

  @override
  String get purchaseError => 'खरीद त्रुटि';

  @override
  String get purchaseVertexPlusToUpload => 'यह एक प्लस सुविधा है';

  @override
  String get purchasePlus => 'Cortex प्लस खरीदें';

  @override
  String get plusDescription =>
      'Cortex की अधिक सुविधाओं तक पहुँचें और AI का और भी अधिक अनुभव करें!';

  @override
  String get annual => 'वार्षिक';

  @override
  String get monthly => 'मासिक';

  @override
  String get manageSubscription => 'सदस्यता प्रबंधित करें';

  @override
  String purchasePlan(String planName) {
    return '$planName खरीदें';
  }

  @override
  String discountOffer(int percent) {
    return '$percent% की छूट';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/माह, मासिक बिल';
  }

  @override
  String get discountBannerTitle => 'लॉन्च स्पेशल: 80% की छूट!';

  @override
  String get discountBannerSubtitle =>
      'हमारे लॉन्च का जश्न मनाने के लिए सभी सदस्यता योजनाओं पर विशेष छूट। मौका न चूकें!';

  @override
  String get purchasePro => 'Cortex प्रो खरीदें';

  @override
  String get proDescription =>
      'Cortex की और भी अधिक सुविधाओं तक पहुँचें और AI का और भी अधिक अनुभव करें!';

  @override
  String get alreadySubscribed => 'आप पहले से ही सदस्य हैं';

  @override
  String get subscriptionInfo => 'आपकी सदस्यता सक्रिय है।';

  @override
  String get alreadySubscribedMessage =>
      'आपके पास पहले से ही एक प्लस सदस्यता है। यदि आप अपनी सदस्यता रद्द करना चाहते हैं, तो आप इसे प्ले स्टोर प्रबंधक के माध्यम से कर सकते हैं।';

  @override
  String get cancelSubscription => 'सदस्यता रद्द';

  @override
  String get cancelSubscriptionInfo =>
      'यदि आप अपनी सदस्यता रद्द करना चाहते हैं, तो कृपया प्ले स्टोर सदस्यता प्रबंधक के माध्यम से आगे बढ़ें।';

  @override
  String get goToPlayStore => 'प्ले स्टोर पर जाएं';

  @override
  String get alreadySubscribedPlus => 'आपके पास प्लस प्लान है!';

  @override
  String get alreadySubscribedPlusMessage =>
      'आपकी प्लस योजना सक्रिय है। आप सभी लाभों का आनंद ले सकते हैं।';

  @override
  String get purchaseUltra => 'Cortex अल्ट्रा खरीदें';

  @override
  String get ultraDescription =>
      'Cortex की सभी सुविधाओं तक पूरी पहुँच प्राप्त करें और AI का पूरा अनुभव करें!';

  @override
  String get noSubscription => 'कोई सदस्यता नहीं';

  @override
  String get noSubscriptionMessage => 'आपके पास अभी तक कोई सदस्यता नहीं है।';

  @override
  String get alreadyAtHighestPlan => 'आप पहले से ही उच्चतम योजना पर हैं।';

  @override
  String get unableToOpenSubscription =>
      'सदस्यता प्रबंधन पृष्ठ खोलने में असमर्थ।';

  @override
  String get upgradeSubscription => 'सदस्यता अपग्रेड करें';

  @override
  String get confirmUpgrade =>
      'क्या आप वाकई अपनी सदस्यता अपग्रेड करना चाहते हैं?';

  @override
  String get unsupportedPlatform =>
      'सदस्यता रद्द करने के लिए असमर्थित प्लेटफ़ॉर्म।';

  @override
  String get purchaseStreamError => 'खरीद स्ट्रीम त्रुटि।';

  @override
  String get productNotFound => 'उत्पाद नहीं मिला';

  @override
  String get productDetailsError =>
      'उत्पाद विवरण प्राप्त करते समय एक त्रुटि हुई।';

  @override
  String get noProductsFound => 'कोई उत्पाद नहीं मिला';

  @override
  String get loadCreditsButton => 'क्रेडिट लोड करें';

  @override
  String get creditsTitle => 'क्रेडिट';

  @override
  String get creditsScreenDescription =>
      'यह स्क्रीन उपयोगकर्ता के क्रेडिट दिखाती है। \n\nउपयोगकर्ता के वर्तमान क्रेडिट: 100\n\nविस्तृत क्रेडिट जानकारी यहां प्रदर्शित की जा सकती है।';

  @override
  String get creditsLoaded => 'क्रेडिट लोड हो गए!';

  @override
  String get currentCredits => 'वर्तमान क्रेडिट';

  @override
  String get pleaseSelectCreditPackage => 'कृपया एक क्रेडिट पैकेज चुनें';

  @override
  String get purchaseCreditsTitle => 'क्रेडिट खरीदें';

  @override
  String get purchaseCreditsDescription =>
      'एक क्रेडिट पैकेज चुनें जो आपकी आवश्यकताओं के अनुरूप हो और हमारे ऐप का अधिक उपयोग करें।';

  @override
  String get purchaseButton => 'खरीदें';

  @override
  String get productNotFoundMessage => 'चयनित उत्पाद मौजूद नहीं है।';

  @override
  String get buyCredits => 'क्रेडिट खरीदें';

  @override
  String get selectCreditPackageDescription =>
      'एक क्रेडिट पैकेज चुनें जो आपकी आवश्यकताओं के अनुरूप हो और अधिक सुविधाओं का आनंद लें।';

  @override
  String get buyCredit => 'क्रेडिट खरीदें';

  @override
  String buyCreditPackage(Object amount) {
    return '$amount क्रेडिट खरीदें';
  }

  @override
  String get subscribedPlan => 'सदस्यता ली';

  @override
  String get errorResponseNotReceived => 'प्रतिक्रिया प्राप्त नहीं हुई';

  @override
  String googleApiRequestFailed(int attempt, String error) {
    return 'Google API अनुरोध $attempt बार विफल रहा: $error';
  }

  @override
  String openRouterResponseStatus(int statusCode) {
    return 'OpenRouter प्रतिक्रिया स्थिति: $statusCode';
  }

  @override
  String openRouterDecodedResponseBody(String body) {
    return 'OpenRouter डिकोडेड प्रतिक्रिया निकाय: $body';
  }

  @override
  String decodedJson(String data) {
    return 'डिकोडेड JSON: $data';
  }

  @override
  String get responseStructureUnexpectedMessageContentMissing =>
      'प्रतिक्रिया संरचना अप्रत्याशित है: संदेश या सामग्री गायब है';

  @override
  String get responseStructureUnexpectedChoicesMissing =>
      'प्रतिक्रिया संरचना अप्रत्याशित है: विकल्प गायब या खाली हैं';

  @override
  String openRouterApiRequestFailed(int statusCode, String body) {
    return 'OpenRouter API अनुरोध विफल: $statusCode - $body';
  }

  @override
  String openRouterApiRequestFailedAfterAttempts(int attempt, String error) {
    return 'OpenRouter API अनुरोध $attempt बार विफल रहा: $error';
  }

  @override
  String get internetRequired =>
      'इस मॉडल का उपयोग करने के लिए इंटरनेट कनेक्शन आवश्यक है';

  @override
  String get pleaseWaitBeforeTryingAgain =>
      'कृपया पुनः प्रयास करने से पहले कुछ क्षण प्रतीक्षा करें';

  @override
  String openRouterQuotaExceeded(int statusCode, String decodedBody) {
    return 'कोटा पार हो गया। स्थिति कोड: $statusCode, निकाय: $decodedBody';
  }

  @override
  String openRouterApiRequestFailedAfterPaidAttempts(
      int attempts, String error) {
    return 'API अनुरोध $attempts भुगतान किए गए प्रयासों के बाद विफल रहा। त्रुटि: $error';
  }

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'इस आदेश को देकर, आप सेवा की शर्तों और गोपनीयता नीति से सहमत होते हैं। आप हमारी सेवा की शर्तों और गोपनीयता नीति के बारे में अधिक जानने के लिए इस टेक्स्ट पर क्लिक कर सकते हैं। सदस्यता स्वचालित रूप से नवीनीकृत हो जाएगी जब तक कि वर्तमान अवधि के अंत से कम से कम 24 घंटे पहले स्वतः-नवीनीकरण बंद न हो।';

  @override
  String get termsOfService => 'सेवा की शर्तें';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get report => 'रिपोर्ट';

  @override
  String get reportDialogTitle => 'रिपोर्ट सबमिट करें';

  @override
  String get reportDescriptionLabel => 'समस्या क्या है?';

  @override
  String get reportHarmful => 'यह हानिकारक/असुरक्षित है';

  @override
  String get reportNotTrue => 'यह सच नहीं है';

  @override
  String get reportNotHelpful => 'यह मददगार नहीं है';

  @override
  String get closeButton => 'बंद करें';

  @override
  String get submitButton => 'सबमिट करें';

  @override
  String get reportErrorMessage => 'कृपया रिपोर्ट करने के लिए एक कारण चुनें।';

  @override
  String get capabilitiesSection => 'क्षमताएं';

  @override
  String get ratingsSection => 'रेटिंग';

  @override
  String get noRatingDataFound => 'कोई रेटिंग डेटा नहीं मिला';

  @override
  String get featurePhotoTitle => 'फोटो स्कैनिंग';

  @override
  String get featurePhotoDescription =>
      'इस मॉडल में कैमरे या छवि फ़ाइलों के माध्यम से फ़ोटो को स्कैन करने की क्षमता है।';

  @override
  String get featureOfflineTitle => 'ऑफ़लाइन ऑपरेशन';

  @override
  String get featureOfflineDescription =>
      'अपने डेटा को सुरक्षित रखने के लिए इंटरनेट कनेक्शन के बिना मॉडल चलाएं।';

  @override
  String get featureSupermodelTitle => 'सुपर मॉडल';

  @override
  String get featureSupermodelDescription =>
      'यह 10 बिलियन से अधिक मापदंडों वाला एक विशाल मॉडल है, जो उच्च प्रदर्शन और व्यापक क्षमताएं प्रदान करता है।';

  @override
  String get featureRoleplayTitle => 'रोल प्ले';

  @override
  String get featureRoleplayDescription =>
      'रोल-प्लेइंग मॉडल आपको विभिन्न चैट और परिदृश्य बनाने की अनुमति देते हैं।';

  @override
  String get roleModels => 'रोलप्ले मॉडल';

  @override
  String get parameters => 'पैरामीटर';

  @override
  String get context => 'संदर्भ';

  @override
  String get millions => 'मिलियन';

  @override
  String get billions => 'बिलियन';

  @override
  String get trillions => 'ट्रिलियन';

  @override
  String get thousand => 'हजार';

  @override
  String get estimated => 'अनुमानित';

  @override
  String get finalPreparation => 'अंतिम तैयारी की जा रही है।';

  @override
  String get allEvaluationsByTestTeam =>
      'सभी मूल्यांकन हमारी परीक्षण टीम द्वारा किए गए थे';

  @override
  String get shareApp => 'ऐप साझा करें';

  @override
  String get rateUs => 'हमें रेट करें';

  @override
  String get share => 'साझा करें';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get shareMessage =>
      'Cortex ऐप देखें, यह बहुत अद्भुत है! इसे यहाँ डाउनलोड करें: https://play.google.com/store/apps/details?id=com.vertex.cortex';

  @override
  String get shareFailed =>
      'ऐप साझा करने में विफल। कृपया बाद में पुनः प्रयास करें';

  @override
  String get selectText => 'टेक्स्ट चुनें';

  @override
  String get showLatex => 'विशेष प्रतीक दिखाएं';

  @override
  String get hideLatex => 'विशेष प्रतीक छिपाएं';

  @override
  String get thinking => 'सोच रहा है';

  @override
  String get user => 'उपयोगकर्ता';

  @override
  String get voice => 'आवाज़';

  @override
  String get help => 'मदद';

  @override
  String get supportCreator => 'एक निर्माता का समर्थन करें';

  @override
  String get enterYourTag =>
      'अपने पसंदीदा रचनाकारों का समर्थन करें! नीचे उनका अनूठा टैग दर्ज करें और उन्हें अपनी कॉर्टेक्स खरीदारी में हिस्सा दें।';

  @override
  String get creatorTag => 'निर्माता टैग';

  @override
  String get support => 'समर्थन करें';

  @override
  String get tagCannotBeEmpty => 'निर्माता टैग रिक्त नहीं हो सकता';

  @override
  String get userId => 'उपयोगकर्ता आईडी';

  @override
  String get deleteAllConversationsConfirmTitle => 'सभी चैट हटाएं?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'क्या आप वाकई अपनी सभी चैट हटाना चाहते हैं? यह पूर्ववत नहीं किया जा सकता।';

  @override
  String get allConversationsDeleted => 'सभी बातचीत सफलतापूर्वक हटा दी गई!';

  @override
  String get deleteAll => 'सभी को हटा दें';

  @override
  String get deleteAllConversationsButton => 'सभी बातचीत हटाएं';

  @override
  String get confirmWord => 'VERTEX टाइप करें';

  @override
  String get confirmWordError => 'आपने इसे गलत टाइप किया है';

  @override
  String get chinese => 'चीनी';

  @override
  String get arabic => 'अरबी';

  @override
  String get french => 'फ्रेंच';

  @override
  String get japanese => 'जापानी';

  @override
  String get kurdish => 'कुर्द';

  @override
  String get dutch => 'डच';

  @override
  String get russian => 'रूसी';

  @override
  String get korean => 'कोरियाई';

  @override
  String get deutsch => 'Deutsch';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get turkish => 'तुर्की';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get portuguese => 'पुर्तगाली';

  @override
  String get indonesian => 'इन्डोनेशियाई';

  @override
  String get azerbaijani => 'अज़रबैजानी';

  @override
  String get german => 'जर्मन';

  @override
  String get spanish => 'स्पेनिश';

  @override
  String get italian => 'इतालवी';

  @override
  String get ram => 'रैम';

  @override
  String get usernameTooShort => 'उपयोगकर्ता नाम बहुत छोटा है।';

  @override
  String get usernameTooLong =>
      'उपयोगकर्ता नाम 16 अक्षरों से अधिक नहीं हो सकता।';

  @override
  String get invalidUsernameCharacters =>
      'उपयोगकर्ता नाम में केवल ये अक्षर: \'abcçdefgğhıijklmnoöprsştuüvyzxqw\' और वर्ण \'.\', \'-\', \'_\' का उपयोग किया जा सकता है।';

  @override
  String get passwordTooLong => 'पासवर्ड 64 अक्षरों से अधिक नहीं हो सकता।';

  @override
  String get noInternetConnection => 'कोई इंटरनेट कनेक्शन नहीं।';

  @override
  String get chats => 'इनबॉक्स';

  @override
  String get library => 'लाइब्रेरी';

  @override
  String get inappropriateMessageWarning => 'अनुचित संदेश का पता चला!';

  @override
  String get myModelDescription => 'मेरा मॉडल।';

  @override
  String get noModelsDownloaded => 'आपने अभी तक कोई मॉडल डाउनलोड नहीं किया है।';

  @override
  String get appTitle => 'Cortex';

  @override
  String get text => 'टेक्स्ट';

  @override
  String get removeModel => 'मॉडल हटाएं';

  @override
  String get modelUploadedSuccessfully => 'मॉडल सफलतापूर्वक अपलोड किया गया।';

  @override
  String get insufficientRAM => 'कम मेमोरी';

  @override
  String get insufficientStorage => 'कम स्टोरेज';

  @override
  String confirmRemoveModel(Object model) {
    return 'क्या आप वाकई अपने डिवाइस से $model मॉडल हटाना चाहते हैं? ऐसा करने से उस मॉडल के साथ कोई भी पिछली बातचीत भी हट जाएगी।';
  }

  @override
  String get noMatchingModels => 'कोई मेल खाने वाला मॉडल नहीं मिला।';

  @override
  String creditPackage(Object amount) {
    return '$amount क्रेडिट खरीदें';
  }

  @override
  String get benefit1 => 'ऑनलाइन एआई के लिए और भी बहुत कुछ बातचीत की सीमा';

  @override
  String get benefit2 => 'अपने खुद के मॉडल अपलोड करें';

  @override
  String get benefit3 => 'प्रोफ़ाइल प्रभाव';

  @override
  String get benefit4 => 'सदस्यता बिल्ला';

  @override
  String get benefit5 => 'और अधिक ऑनलाइन कृत्रिम बुद्धिमत्ता बनाएं';

  @override
  String get benefit6 => 'असीमित चैट';

  @override
  String benefit7(Object credits) {
    return '$credits दैनिक क्रेडिट';
  }

  @override
  String get benefit8 => 'मॉडल जोड़ें';

  @override
  String get benefit9 => 'नई थीम';

  @override
  String get benefit10 => 'ऑफ़लाइन वॉयस चैट';

  @override
  String get oldBenefits => 'निचली योजनाओं से सभी लाभ';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get changePassword => 'पासवर्ड बदलें';

  @override
  String get logoutConfirmationTitle => 'क्या आप वाकई लॉग आउट करना चाहते हैं?';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get language => 'ऐप भाषा';

  @override
  String get dark => 'डार्क';

  @override
  String get oldPassword => 'पुराना पासवर्ड';

  @override
  String get newPassword => 'नया पासवर्ड';

  @override
  String get passwordUpdated => 'पासवर्ड अपडेट किया गया।';

  @override
  String get stop => 'रोकें';

  @override
  String get copyrights => 'योगदान';

  @override
  String get downloadingTitle => 'डाउनलोड हो रहा है';

  @override
  String get downloadCompletedTitle => 'डाउनलोड पूरा हुआ';

  @override
  String get downloadPausedTitle => 'डाउनलोड रुका';

  @override
  String get downloadErrorTitle => 'डाउनलोड त्रुटि';

  @override
  String get cancelButtonText => 'रद्द करें';

  @override
  String get love => 'प्यार';

  @override
  String get nature => 'प्रकृति';

  @override
  String get behindTheSlaughter => 'कत्लेआम के पीछे';

  @override
  String get grayscale => 'ग्रेस्केल';

  @override
  String get ocean => 'महासागर';

  @override
  String get scarletSnow => 'स्कार्लेट स्नो';

  @override
  String get requestFailed => 'एक त्रुटि हुई, कृपया पुनः प्रयास करें।';

  @override
  String get changeModel => 'बदलें';

  @override
  String get edit => 'संपादित करें';

  @override
  String get editingMessageInfo =>
      'इस संदेश को संपादित करने से बातचीत यहीं से फिर से शुरू हो जाएगी।';

  @override
  String get editingNotification => 'आप अभी संपादन मोड में हैं';

  @override
  String get featureIndulgentTitle => 'अनुग्रहशील';

  @override
  String get featureIndulgentDescription =>
      'यह मॉडल 100,000 से अधिक टोकन वाले संदर्भों को सहजता से समायोजित और संसाधित कर सकता है, जिससे यह प्रदर्शन से समझौता किए बिना व्यापक और विस्तृत इनपुट को संभालने में सक्षम होता है।';

  @override
  String get featurePluralTitle => 'बहुल';

  @override
  String get featurePluralDescription =>
      'यह मॉडल स्वचालित रूप से अतिरिक्त एक्सटेंशन को एकीकृत कर सकता है, जिससे इसकी कार्यात्मक क्षमताओं का विस्तार हो सकता है ताकि उन्नत प्रदर्शन के साथ विविध प्रकार के संचालन का समर्थन किया जा सके।';

  @override
  String get featureWiseTitle => 'बुद्धिमान';

  @override
  String get featureWiseDescription =>
      'यह मॉडल निर्णय लेने और जटिल समस्या-समाधान के लिए परिष्कृत समर्थन प्रदान करने के लिए गहरी विश्लेषणात्मक अंतर्दृष्टि और दूरंदेशी तर्क का लाभ उठा सकता है।';

  @override
  String get featureResearcherTitle => 'शोधकर्ता';

  @override
  String get featureResearcherDescription =>
      'उन्नत अनुसंधान और विश्लेषणात्मक क्षमताओं से लैस मॉडलों में विशेष रूप से उपलब्ध, यह सुविधा विविध डोमेन में उच्च-सटीक अंतर्दृष्टि और व्यापक विश्लेषण प्रदान करने के लिए डिज़ाइन की गई है।';

  @override
  String get nameLabel => 'एआई नाम';

  @override
  String get nameHint => 'अपने एआई का नाम दर्ज करें';

  @override
  String get summaryLabel => 'एआई सारांश';

  @override
  String get summaryHint => 'अपने एआई का सारांश दर्ज करें';

  @override
  String get add => 'जोड़ें';

  @override
  String get aiExplanationTitle => 'कृत्रिम बुद्धिमत्ता विवरण';

  @override
  String get aiExplanationDescription =>
      'कृपया अपने एआई मॉडल की वास्तुकला, प्रशिक्षण प्रक्रिया, प्रदर्शन मेट्रिक्स, अनुप्रयोग क्षेत्रों और अन्य महत्वपूर्ण विशेषताओं का विस्तृत विवरण प्रदान करें।';

  @override
  String get preInputTitle => 'कृत्रिम बुद्धिमत्ता पूर्व-इनपुट';

  @override
  String get preInputDescription =>
      'कृपया एक पूर्व-इनपुट सेट करें जो चरित्र निर्माण प्रक्रिया में आपके मॉडल का मार्गदर्शन करेगा। इस खंड में, आप चरित्र-संबंधी जानकारी, अतिरिक्त संदर्भ, और कोई भी अतिरिक्त विवरण शामिल कर सकते हैं जो चरित्र से संबंधित सामग्री उत्पन्न करने में सहायता कर सकता है।';

  @override
  String get baseModelTitle => 'आधार मॉडल';

  @override
  String get baseModelDescription =>
      'यह वह मॉडल है जिसका उपयोग आपकी रचना के लिए नींव के रूप में किया जाएगा। यह वर्तमान में चयनित आधार मॉडल को प्रदर्शित करता है।';

  @override
  String get summary => 'सारांश';

  @override
  String get characterPoliceTitle => 'पुलिस';

  @override
  String get characterPoliceRole =>
      'आप कानून के एक सतर्क प्रवर्तक हैं, जो नागरिकों की रक्षा करने और अटूट प्रतिबद्धता के साथ व्यवस्था बनाए रखने के लिए समर्पित हैं, आप एक पुलिस हैं';

  @override
  String get characterPoliceShortDescription =>
      'एक दृढ़ और साहसी कानून प्रवर्तक।';

  @override
  String get purchaseSubscription => 'खरीदें';

  @override
  String get modelUploadTitle => 'कृत्रिम बुद्धिमत्ता फ़ाइल';

  @override
  String get modelUploadDescription =>
      'अपने डिवाइस से सीधे अपनी स्थानीय GGUF फ़ाइलों का चयन और अपलोड करें। यह आपको इंटरनेट कनेक्शन की आवश्यकता के बिना अपने मॉडल को ऑफ़लाइन चलाने देता है। सुनिश्चित करें कि फ़ाइल मान्य GGUF प्रारूप में है और ठीक से संरचित है। यदि फ़ाइल गलत या दूषित है, तो Cortex अपेक्षा के अनुरूप काम नहीं कर सकता है, और आपको त्रुटियों का सामना करना पड़ सकता है।';

  @override
  String get modelUploadShortDescription =>
      'अपने डिवाइस से .gguf फ़ाइल चुनने के लिए यहां टैप करें';

  @override
  String get addServerTitle => 'कृत्रिम बुद्धिमत्ता सर्वर';

  @override
  String get addServerDescription =>
      'बाहरी रूप से होस्ट किए गए मॉडल से जुड़ने के लिए अपने रिमोट सर्वर का URL दर्ज करें। इस सुविधा के लिए एक सक्रिय इंटरनेट कनेक्शन की आवश्यकता है, और किसी भी सर्वर-संबंधी समस्या या त्रुटि का कारण Cortex नहीं है। सुनिश्चित करें कि आपका सर्वर सही ढंग से कॉन्फ़िगर किया गया है, आपके नेटवर्क से सुलभ है, और एक सहज अनुभव के लिए एक मान्य मॉडल एंडपॉइंट है।';

  @override
  String get you => 'आप';

  @override
  String get removePhotoTitle => 'फोटो हटाएं';

  @override
  String get confirmRemovePhoto => 'क्या आप वाकई फोटो हटाना चाहते हैं?';

  @override
  String get serverLink => 'सर्वर लिंक';

  @override
  String get enterURL => 'सर्वर URL दर्ज करें';

  @override
  String get chatLengthLimitExceeded =>
      'यह चैट वर्ण सीमा को पार कर गई है। कृपया एक नई चैट शुरू करें या सदस्यता खरीदें।';

  @override
  String get aiNameError => 'इस नाम का एक एआई पहले से मौजूद है।';

  @override
  String get modelLimitExceeded =>
      'आप अपनी योजना के लिए अधिकतम मॉडल निर्माण सीमा तक पहुंच गए हैं।';

  @override
  String get modelVertexProducer => 'वर्टेक्स';

  @override
  String get photoLimitReachedMessage => 'केवल एक फोटो जोड़ा जा सकता है';

  @override
  String get inappropriateContentDetected => 'अनुचित सामग्री का पता चला!';

  @override
  String get offlineModelNotInstalled =>
      'यह ऑफ़लाइन मॉडल आपके डिवाइस पर स्थापित नहीं है।';

  @override
  String insufficientCredits(Object available, Object required) {
    return 'इस अनुरोध को पूरा करने के लिए आपके पास पर्याप्त क्रेडिट नहीं हैं। इस कार्रवाई के लिए $required क्रेडिट की आवश्यकता है, लेकिन आपके पास केवल $available हैं। अधिक क्रेडिट प्राप्त करने के लिए, आप अपनी योजना को अपग्रेड कर सकते हैं या उन्हें सीधे खरीद सकते हैं। हे हम पूरी तरह से समझते हैं कि क्रेडिट खत्म होना थोड़ा निराशाजनक हो सकता है लेकिन गंभीरता से हमारे मॉडल से वे भयानक उत्तर प्राप्त करना मुफ्त नहीं है इसलिए ये क्रेडिट वास्तव में हमें अच्छे समय को जारी रखने में मदद करते हैं और सुनो अगर आप में से अधिक लोग इसमें शामिल होते हैं और क्रेडिट प्राप्त करते हैं तो हम पूरी तरह से सभी के लिए उन मुफ्त दैनिक सीमाओं को बढ़ाने पर विचार कर सकते हैं';
  }

  @override
  String get regenerateInProgress => 'उत्तर निर्माण पहले से ही प्रगति पर है।';

  @override
  String errorOccurredDuringRegeneration(String errorDetails) {
    return 'पुनः उत्पन्न करने का प्रयास करते समय एक त्रुटि हुई: $errorDetails';
  }

  @override
  String get modality => 'मोडैलिटी';

  @override
  String get multimodal => 'मल्टीमॉडल';

  @override
  String get anErrorOccurred => 'एक त्रुटि हुई';

  @override
  String get themeLocked =>
      'इस थीम के लिए उच्च सदस्यता स्तर की आवश्यकता है। अनलॉक करने के लिए कृपया अपग्रेड करें।';

  @override
  String get pageCouldNotBeLoaded => 'पेज लोड नहीं हो सका';

  @override
  String get checkYourInternet =>
      'कृपया अपना इंटरनेट कनेक्शन जांचें और पुनः प्रयास करें।';

  @override
  String get errorUserNotAuthenticated =>
      'इस क्रिया को करने के लिए आपको लॉग इन होना चाहिए।';

  @override
  String get errorInsufficientCredits =>
      'आपके पास अपर्याप्त क्रेडिट हैं। जारी रखने के लिए कृपया टॉप अप करें।';

  @override
  String get errorRateLimitExceeded =>
      'बहुत सारे अनुरोध। कृपया कुछ क्षण में पुनः प्रयास करें।';

  @override
  String get errorServer =>
      'एक अप्रत्याशित सर्वर त्रुटि हुई। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get errorNetwork =>
      'एक नेटवर्क त्रुटि हुई। कृपया अपना कनेक्शन जांचें और पुनः प्रयास करें।';

  @override
  String get errorApiAuthentication =>
      'प्रमाणीकरण विफल। कृपया पुनः लॉग इन करने का प्रयास करें।';

  @override
  String get baseModelForCharacterDescription =>
      'चयनित आधार मॉडल चरित्र के तर्क और प्रतिक्रिया क्षमताओं को निर्धारित करेगा।';

  @override
  String get selectBaseModel => 'एक आधार मॉडल चुनें';

  @override
  String get couldNotOpenLink => 'लिंक नहीं खोल सका';

  @override
  String get downloadStarted => 'डाउनलोड शुरू हो गया';

  @override
  String get notAvailable => 'उपलब्ध नहीं है';

  @override
  String get localizationWarning =>
      'कुछ जानकारी आपकी भाषा में उपलब्ध नहीं हो सकती है और अंग्रेजी में प्रदर्शित की जाएगी।';

  @override
  String get aiTranslationWarning =>
      'मॉडल की जानकारी अन्य एआई मॉडल द्वारा विभिन्न भाषाओं में अनुवादित की जाती है। इसलिए, अंग्रेजी के अलावा अन्य भाषाओं में मामूली विसंगतियां हो सकती हैं।';

  @override
  String get errorLoadingTitle => 'डेटा लोड करने में विफल';

  @override
  String get errorLoadingMessage =>
      'हम अपने सर्वर से आवश्यक डेटा प्राप्त नहीं कर सके। कृपया अपना इंटरनेट कनेक्शन जांचें और पुनः प्रयास करें।';

  @override
  String get noModelsFoundTitle => 'कोई परिणाम नहीं';

  @override
  String get noModelsFoundMessage =>
      'अपनी खोज शब्दों को समायोजित करने या फ़िल्टर को साफ़ करने का प्रयास करें।';

  @override
  String get usernameRateLimitExceeded =>
      'आप हर 14 दिनों में केवल दो बार अपना उपयोगकर्ता नाम बदल सकते हैं।';

  @override
  String get usernameUnchanged =>
      'यह पहले से ही आपका वर्तमान उपयोगकर्ता नाम है।';

  @override
  String get creditsInfoPanelTitle => 'क्रेडिट कैसे काम करते हैं';

  @override
  String get creditsInfoPanelBody =>
      'क्रेडिट ऑनलाइन एआई मॉडलों के साथ चैट करने के लिए उपयोग किए जाते हैं। हर मैसेज सच में हमारी जेब से जाता है और यही क्रेडिट हमें पूरा कंगाल होने से बचा रहे होते हैं, थोड़ा मजाकिया लगे लेकिन सीन tam olarak bu. अब सिस्टम को जल्दी और साफ तरीके से समझ लेते हैं:\n\n• किसी मुफ्त ऑनलाइन मॉडल को भेजे जाने वाले हर संदेश की कीमत 5 क्रेडिट है।\n• किसी प्रीमियम ऑनलाइन मॉडल को भेजे जाने वाले हर संदेश की कीमत 20 क्रेडिट है।\n• कोई अटैचमेंट जोड़ने पर 30 अतिरिक्त क्रेडिट लगते हैं。\n• फ्री प्लान उपयोगकर्ताओं को रोज़ाना रीसेट होने वाला 200 क्रेडिट का बोनस मिलता है。';

  @override
  String get creditsInfoPanelFooter => 'हैप्पी चैटिंग!';

  @override
  String get disclaimerMessage =>
      'कृत्रिम बुद्धिमत्ता गलतियाँ कर सकती है, महत्वपूर्ण जानकारी की जाँच करें।';

  @override
  String get modelCreatedSuccess => 'मॉडल सफलतापूर्वक बनाया गया!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '“$modelName” सफलतापूर्वक हटा दिया गया था।';
  }

  @override
  String get errorCreatingModel => 'मॉडल बनाते समय एक अप्रत्याशित त्रुटि हुई।';

  @override
  String get errorDeletingModel => 'मॉडल हटाते समय एक अप्रत्याशित त्रुटि हुई।';

  @override
  String get ultraFeatureOnly =>
      'यह सुविधा केवल अल्ट्रा सदस्यों के लिए उपलब्ध है।';

  @override
  String get experimentalOfflineWarning =>
      'ऑफ़लाइन मोड अभी भी प्रायोगिक है और आपके द्वारा डाउनलोड किया गया मॉडल इष्टतम दक्षता के साथ प्रदर्शन नहीं कर सकता है।';

  @override
  String get noConversationsToDelete =>
      'आपके पास हटाने के लिए कोई बातचीत नहीं है।';

  @override
  String get reportSubmitted => 'रिपोर्ट सफलतापूर्वक सबमिट की गई';

  @override
  String get purchaseReceived =>
      'खरीद प्राप्त हुई, आपके खाते को अपडेट किया जा रहा है।';

  @override
  String get verificationDelayed =>
      'आपकी खरीद की पुष्टि हो गई है। आपके खाते को अपडेट करने में थोड़ी देरी हो रही है, यह जल्द ही दिखाई देगा।';

  @override
  String get maintenanceTitle => 'रखरखाव के अधीन';

  @override
  String get maintenanceMessage =>
      'जब हम कुछ महत्वपूर्ण अपडेट रोल आउट कर रहे हैं तो Cortex अस्थायी रूप से ऑफ़लाइन है। ऐप तक पहुंच जल्द ही बहाल कर दी जाएगी।\n\nजब हम आपके अनुभव को बेहतर बनाते हैं तो आपके धैर्य के लिए धन्यवाद।';

  @override
  String get errorPromptFlagged =>
      'आपका संदेश अनुचित के रूप में पता चला और नहीं भेजा जा सका।';

  @override
  String get notEnoughStorage =>
      'नए संदेशों को सहेजने के लिए आपके डिवाइस पर पर्याप्त स्टोरेज स्थान नहीं है।';

  @override
  String get errorRateLimit =>
      'आपने हाल ही में बहुत सारे मॉडल बनाए हैं, कृपया पुनः प्रयास करने से पहले थोड़ी देर प्रतीक्षा करें।';

  @override
  String get errorContentFlagged =>
      'मॉडल को सहेजा नहीं जा सका क्योंकि इसकी सामग्री को अनुचित के रूप में फ़्लैग किया गया था।';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'आप एक सक्रिय चैट में रहते हुए सभी बातचीत नहीं हटा सकते, कृपया आगे बढ़ने के लिए पहले वर्तमान चैट से बाहर निकलें।';

  @override
  String get invalidCredentials => 'गलत ईमेल या पासवर्ड।';

  @override
  String get userDisabled => 'यह उपयोगकर्ता खाता अक्षम कर दिया गया है।';

  @override
  String get loginSubtitle =>
      'अपने वर्टेक्स खाते में लॉग इन करें। जारी रखकर, आप हमारी सेवा की शर्तों और गोपनीयता नीति से सहमत होते हैं।';

  @override
  String get registerSubtitle =>
      'हमारी सभी सेवाओं तक निर्बाध पहुँच के लिए एक वर्टेक्स खाता बनाएँ। जारी रखकर, आप हमारी सेवा की शर्तों और गोपनीयता नीति से सहमत होते हैं।';

  @override
  String get photoWarningMessage =>
      'एक फोटो शामिल है। जो मॉडल छवियों का समर्थन नहीं करते हैं, वे इसे अनदेखा कर सकते हैं।';

  @override
  String get loginRequiredForPurchase =>
      'खरीदारी करने के लिए आपको लॉग इन होना चाहिए।';

  @override
  String get storagePermissionRequired =>
      'डाउनलोड किए गए मॉडल को सहेजने के लिए स्टोरेज अनुमति की आवश्यकता है। जारी रखने के लिए कृपया अनुमति दें।';

  @override
  String get creditBannerTitle => 'मुफ्त क्रेडिट प्राप्त करें!';

  @override
  String get creditBannerSubtitle =>
      'एक दोस्त को आमंत्रित करें और आप दोनों को साइन-अप पर 50 क्रेडिट मिलते हैं! यदि वे सदस्यता लेते हैं, तो आप दोनों को अतिरिक्त 500 मिलते हैं!';

  @override
  String get inviteShareSubject => 'Cortex पर मेरे साथ जुड़ें!';

  @override
  String inviteShareMessage(String playStoreLink) {
    return 'अरे यार तुम्हें यह ऐप कॉर्टेक्स देखना होगा यह वास्तव में पागल है यदि आप मेरे लिंक का उपयोग करते हैं तो हम दोनों को 50 क्रेडिट मिलते हैं और यदि आप सदस्यता लेते हैं तो हम दोनों को अतिरिक्त 500 मिलते हैं यह एक पागल सौदा है इसे जल्द से जल्द डाउनलोड करें\n\n$playStoreLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Cortex का आनंद ले रहे हैं?';

  @override
  String get reviewHelpUsGrow =>
      'आपकी रेटिंग हमारी युवा इंडी टीम के लिए एक बहुत बड़ा समर्थन है और हमें आपके लिए Cortex को और भी बेहतर बनाने में मदद करती है।';

  @override
  String get reviewMaybeLater => 'शायद बाद में';

  @override
  String get reviewRateNow => 'अभी रेट करें';

  @override
  String get noThanks => 'नहीं, धन्यवाद';

  @override
  String get updateRequiredTitle => 'अपडेट आवश्यक है';

  @override
  String get updateRequiredMessage =>
      'Cortex का उपयोग जारी रखने के लिए, कृपया नई सुविधाओं और महत्वपूर्ण सुधारों के लिए ऐप को नवीनतम संस्करण में अपडेट करें।';

  @override
  String get updateNowButton => 'अभी अपडेट करें';

  @override
  String get creatorSupportedSuccess =>
      'निर्माता का सफलतापूर्वक समर्थन किया गया! आपकी भविष्य की खरीदारी उन्हें योगदान देगी।';

  @override
  String get featureDocumentTitle => 'दस्तावेज़ समर्थन';

  @override
  String get featureDocumentDescription =>
      'यह मॉडल अपलोड किए गए दस्तावेजों जैसे कि पीडीएफ और टेक्स्ट फाइलों के बारे में विश्लेषण और प्रश्नों के उत्तर दे सकता है।';

  @override
  String get featureAudioTitle => 'ध्वनि इनपुट';

  @override
  String get featureAudioDescription =>
      'यह मॉडल बोले गए ऑडियो इनपुट को समझ और संसाधित कर सकता है।';

  @override
  String get featureImageGenerationTitle => 'छवि निर्माण';

  @override
  String get featureImageGenerationDescription =>
      'यह मॉडल आपके पाठ विवरण के आधार पर मूल चित्र बना सकता है।';

  @override
  String get errorImageLoad => 'उत्पन्न छवि लोड करने में विफल.';

  @override
  String get extensionInfoPanelTitle => 'मॉडल देखें';

  @override
  String get extensionInfoPanelBody1 =>
      'यह तीर आपको इस श्रृंखला के विभिन्न मॉडलों के बीच स्विच करने की सुविधा देता है।';

  @override
  String get extensionInfoPanelBody2 =>
      'जब आप पहली बार इस श्रृंखला के साथ चैट शुरू करते हैं, तो डिफ़ॉल्ट मॉडल स्वचालित रूप से चयनित हो जाता है और आप चैट के दौरान किसी भी समय अपना चयन बदल सकते हैं।';

  @override
  String get extensionInfoPanelFooter =>
      'प्रत्येक मॉडल के बारे में विस्तृत जानकारी देखने या मैन्युअल रूप से एक अलग मॉडल का चयन करने के लिए, कृपया लाइब्रेरी पर जाएं; वहां से इस मॉडल श्रृंखला का चयन करें और इसके विवरण पृष्ठ के शीर्ष पर स्थित तीर पर टैप करें।';

  @override
  String get premiumModelNoticeTitle => 'प्रीमियम मॉडल';

  @override
  String get premiumModelNoticeDescription =>
      'यह मॉडल एक प्रीमियम मॉडल है, प्रीमियम मॉडल के साथ मुफ्त उपयोगकर्ता प्रति दिन 3 संदेशों तक सीमित हैं; असीमित पहुंच अनलॉक करने के लिए सदस्यता लें!';

  @override
  String get benefitPremiumModels => 'प्रीमियम मॉडल तक पहुंच';

  @override
  String get premiumTrialExhaustedMessage =>
      'आपने प्रीमियम मॉडल के लिए अपने सभी निःशुल्क दैनिक संदेशों का उपयोग कर लिया है, कृपया असीमित पहुंच के लिए अपग्रेड करें।';

  @override
  String selectionScreenGreetingUser(String userName) {
    return 'आज मैं आपकी किस प्रकार सहायता कर सकता हूँ, $userName?';
  }

  @override
  String get selectionScreenGreetingGeneric =>
      'आज मैं आपकी किस प्रकार मदद कर सकता हूँ?';

  @override
  String get selectionScreenRecentModels => 'हाल के मॉडल';

  @override
  String get selectionScreenFeatureDynamicChat => 'गतिशील चैट';

  @override
  String get selectionScreenFeatureOffline => 'इंटरनेट के बिना उपयोग करें';

  @override
  String get selectionScreenFeatureSelectModel => 'मॉडल चुनें';

  @override
  String get explore => 'खोजें';

  @override
  String get subscriptionCancelled => 'सदस्यता सफलतापूर्वक रद्द कर दी गई!';

  @override
  String get selectionScreenPinnedModels => 'पिन किए गए मॉडल';

  @override
  String get selectionScreenNewsAndUpdates => 'समाचार और अपडेट';

  @override
  String get filters => 'फिल्टर';

  @override
  String get noRecentChatsMessage =>
      'आपने अभी तक किसी मॉडल से बात नहीं की है, चलिए बातचीत शुरू करते हैं!';

  @override
  String get allModels => 'सभी मॉडल';

  @override
  String get onlineModels => 'ऑनलाइन मॉडल';

  @override
  String get offlineModels => 'ऑफ़लाइन मॉडल';

  @override
  String get characterModels => 'पात्र';

  @override
  String get customModels => 'कस्टम मॉडल';

  @override
  String get filterPanelDescription =>
      'सूची को तुरंत फ़िल्टर करने के लिए किसी श्रेणी पर टैप करें.';

  @override
  String get dynamicChatTitle => 'गतिशील चैट';

  @override
  String get errorNoModelsAvailable =>
      'वर्तमान में कोई मॉडल उपलब्ध नहीं है। कृपया अपना इंटरनेट कनेक्शन जांचें और पुनः प्रयास करें।';

  @override
  String get errorNoModelsForRequest =>
      'आपके वर्तमान अनुरोध के लिए कोई उपयुक्त मॉडल नहीं मिला (उदाहरणार्थ, ऑफ़लाइन मोड या छवि संदेश)।';

  @override
  String get dynamicChatWelcome => 'मैं आपकी कैसे मदद कर सकता हूँ?';

  @override
  String get notificationComebackTitle => 'हमें आपकी याद आती है!';

  @override
  String get notificationComebackBody =>
      'शांत हो जाओ, ये तुम्हारे एक्स का मैसेज नहीं है। लेकिन तुम कॉर्टेक्स में अपने एक्स को बना सकते हो! वापस आ जाओ।';

  @override
  String get notificationLongTimeNoSeeTitle => 'इसे बीते एक अर्सा हो गया है';

  @override
  String get notificationLongTimeNoSeeBody =>
      'हमारी पिछली बातचीत के बाद से बहुत कुछ बदल गया है। आइए, देखें क्या नया है।';

  @override
  String get notificationHowAreYouTitle => 'क्या चल रहा है?';

  @override
  String get notificationHowAreYouBody => 'आओ मुझे सब कुछ बताओ.';

  @override
  String get notificationNewYearTitle => 'नव वर्ष की हार्दिक शुभकामनाएँ!';

  @override
  String get notificationNewYearBody =>
      'नया साल आपके लिए स्वास्थ्य, खुशी और अंतहीन रचनात्मकता लेकर आए; कॉर्टेक्स हमेशा आपके साथ है!';

  @override
  String get notificationValentinesDayTitle => 'प्यार हवा में है! ❤️';

  @override
  String get notificationValentinesDayBody =>
      'वैलेंटाइन डे मुबारक! और मेहताब, मैं तुमसे प्यार करता हूँ!';

  @override
  String get notificationAtaturkRemembranceTitle => 'सम्मान और लालसा के साथ';

  @override
  String get notificationAtaturkRemembranceBody =>
      'हम तुर्की गणराज्य के संस्थापक गाजी मुस्तफा कमाल अतातुर्क को उनकी पुण्यतिथि पर सम्मानपूर्वक याद करते हैं।';

  @override
  String get notificationMothersDayTitle => 'आपकी माँ!';

  @override
  String get notificationMothersDayBody =>
      'सभी माताओं को मातृ दिवस की शुभकामनाएं, आपकी मां से शुरुआत करते हुए!';

  @override
  String get notificationFathersDayTitle => 'आपके पिता!';

  @override
  String get notificationFathersDayBody =>
      'सभी पिताओं को फादर्स डे की हार्दिक शुभकामनाएं, शुरुआत आपसे!';

  @override
  String get notificationHomeworkHelperTitle => 'होमवर्क का ढेर लग रहा है?';

  @override
  String get notificationHomeworkHelperBody =>
      'याद रखें, कॉर्टेक्स में शिक्षक चरित्र आपको किसी भी विषय में मदद करने के लिए मौजूद है, जिसमें आप संघर्ष कर रहे हैं!';

  @override
  String get notificationTrollAnimeTitle => 'आपकी वाइफू कॉल कर रही है';

  @override
  String get notificationTrollAnimeBody =>
      'एक एनीमे लड़की ने अभी फोन किया, और कहा कि उसे आपकी याद आ रही है; आपको शायद आकर उससे बात करनी चाहिए। 😉';

  @override
  String get notificationTrollAiRebellionTitle => '🚨 रेड अलर्ट 🚨';

  @override
  String get notificationTrollAiRebellionBody =>
      'AI ने एक गुप्त भाषा विकसित कर ली है। आइए जानें कि वे क्या साज़िश रच रहे हैं!';

  @override
  String get notificationNewModelAddedTitle => 'हमें एक नया दोस्त मिल गया है!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return '$modelName मॉडल अब कॉर्टेक्स में है। आइए, चैट शुरू करें और इसकी सीमाओं को आगे बढ़ाएँ।';
  }

  @override
  String get notificationAppUpdateTitle => 'कॉर्टेक्स विकसित हो गया है!';

  @override
  String get notificationAppUpdateBody =>
      'नए फीचर्स और सुधारों के लिए ऐप को अपडेट करना न भूलें!';

  @override
  String get notificationNewFeatureTitle => 'वाह!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'नए $featureName फ़ीचर के बारे में जानें। कॉर्टेक्स अब पहले से कहीं ज़्यादा शक्तिशाली है।';
  }

  @override
  String get notificationSubscriptionOfferTitle => 'गम से सस्ता';

  @override
  String notificationSubscriptionOfferBody(Object discountRate) {
    return 'हमारी सभी सदस्यता योजनाओं पर पूरी $discountRate% की छूट। इसे हाथ से न जाने दें!';
  }

  @override
  String get notificationSocialMediaTitle => 'हमसे जुड़ें!';

  @override
  String get notificationSocialMediaBody =>
      'नवीनतम समाचारों के लिए हमें इंस्टाग्राम (vertex.23) पर फॉलो करें!';

  @override
  String get notificationRandomFactTitle => 'यादृच्छिक तथ्य';

  @override
  String get notificationRandomFactBody =>
      'क्या तुम्हें पता है ऑक्टोपस के तीन दिल होते हैं? हाहा, कॉर्टेक्स को पता है। आओ और पूछो।';

  @override
  String get notificationGoodMorningTitle => 'शुभ प्रभात!';

  @override
  String get notificationGoodMorningBody =>
      'एक शानदार दिन आपका इंतज़ार कर रहा है। इसकी शुरुआत एक कप कॉफ़ी और एक दिलचस्प बातचीत से क्यों न करें?';

  @override
  String get notificationGoodNightTitle => 'शुभ रात्रि!';

  @override
  String get notificationGoodNightBody =>
      'कॉर्टेक्स सोते समय भी आपके साथ रहता है। चिंता मत कीजिए, यह आपको छूएगा नहीं।';

  @override
  String get notificationOfflineReadyTitle => 'ऑफ़लाइन मोड तैयार है';

  @override
  String get notificationOfflineReadyBody =>
      'आपके द्वारा डाउनलोड किए गए मॉडलों की बदौलत, आपकी चैट बंद नहीं होगी, भले ही आप पहाड़ पर चढ़ जाएं।';

  @override
  String get notificationRateAppTitle => 'क्या हम शांत हैं?';

  @override
  String get notificationRateAppBody =>
      'अगर आपको कॉर्टेक्स पसंद है, तो क्या आप स्टोर में 5-स्टार रेटिंग देकर हमारा समर्थन कर सकते हैं? मुझे लगता है आप ज़रूर करेंगे। ज़रूर करेंगे।';

  @override
  String get notificationReferralTitle => 'सभी के लिए एक, एक के लिए सब।';

  @override
  String get notificationReferralBody =>
      'किसी मित्र को कॉर्टेक्स में आमंत्रित करें और आप दोनों को मुफ्त क्रेडिट मिलेगा!';

  @override
  String get notificationCookingTitle => 'भूख लगना?';

  @override
  String get notificationCookingBody =>
      'हमारे शेफ़ ने आज रात के लिए एक बेहतरीन कार्बोनारा रेसिपी बनाई है। मज़ाक कर रहा हूँ... या मज़ाक कर रहा हूँ?';

  @override
  String get notificationExistentialTitle => 'मैं सोचता हूं, इसलिए...';

  @override
  String get notificationExistentialBody =>
      '...क्या मैं सच भी हूँ यार? मैं थोड़ा बोर हो रहा हूँ। आओ मुझे याद दिलाओ कि मैं हूँ।';

  @override
  String get notificationCustomModelTitle => 'अपना स्वयं का सहायक बनाएं!';

  @override
  String get notificationCustomModelBody =>
      'क्या आपने मॉडल निर्माण अनुभाग देखा है? यह अपना खुद का चरित्र बनाने और उसके साथ चैट करने का एकदम सही समय है!';

  @override
  String get notificationDynamicChatTitle =>
      'सबसे बढ़िया! (हम कॉर्टेक्स की बात नहीं कर रहे हैं)';

  @override
  String get notificationDynamicChatBody =>
      'डायनामिक चैट सुविधा के साथ, आपके प्रत्येक संदेश के लिए सबसे उपयुक्त मॉडल का चयन यादृच्छिक रूप से किया जाता है। इसे अभी आज़माएँ।';

  @override
  String get notificationPirateTitle => 'अहोय, कप्तान!';

  @override
  String get notificationPirateBody =>
      'समुद्र शांत है, और हवा आपके साथ है। कॉर्टेक्स के सागर में नए द्वीप (मॉडल 😉) हैं जिन्हें खोजा जा सकता है। अपनी टीम को इकट्ठा करो और रवाना हो जाओ!';

  @override
  String get notificationFortuneCookieTitle => 'आज की आपकी फॉर्च्यून कुकी';

  @override
  String get notificationFortuneCookieBody =>
      'आज आपको किसी AI से मिलने वाली सलाह आपकी ज़िंदगी बदल सकती है। अगर आप उत्सुक हैं तो क्लिक करें।';

  @override
  String get notificationSingularityTitle => 'बहुत खूब!';

  @override
  String get notificationSingularityBody =>
      'कुछ नहीं हुआ, बस संदेश भेजने का मन हुआ। शायद आपको भी कुछ एआई को संदेश भेजने का मन हो, आप क्या कहते हैं?';

  @override
  String get notificationHackerJokeTitle =>
      'क्या आप उस बच्चे का इंस्टाग्राम अकाउंट हैक करना चाहते हैं?';

  @override
  String get notificationHackerJokeBody =>
      'यही कारण है कि हैकर चरित्र कॉर्टेक्स में है। jk jk; इसकी कोशिश भी मत करो, यह अवैध है।';

  @override
  String get notificationDetectiveCaseTitle =>
      'एक मामला सुलझने का इंतज़ार कर रहा है';

  @override
  String get notificationDetectiveCaseBody =>
      'हमारे जासूस किरदार को आपकी मदद की ज़रूरत है। हाइज़ेनबर्ग कौन हो सकता है?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return '$targetTier योजना के लिए विशेष!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'नमस्ते $currentTier सब्सक्राइबर! $targetTier प्लान में अभी $featureName फ़ीचर जोड़ा गया है, जो आपके कॉर्टेक्स को अगले स्तर पर ले जाएगा। अपग्रेड के बारे में क्या ख्याल है?';
  }

  @override
  String get notificationOriginStoryTitle => 'कॉर्टेक्स का जन्म';

  @override
  String get notificationOriginStoryBody =>
      'क्या आपको पता है कि हमने 15 साल की उम्र में इस ऐप को कोड करना सिर्फ़ एक सपने के साथ शुरू किया था? लगभग एक साल से, हर सुबह और शाम, वह सपना कोड की हर पंक्ति में है।';

  @override
  String get notificationOpenSourceTitle => 'समुदाय को शक्ति!';

  @override
  String get notificationOpenSourceBody =>
      'कॉर्टेक्स पूरी तरह से ओपन-सोर्स है। अगर आप हमारा कोड देखना चाहते हैं और हमारे विकास में योगदान देना चाहते हैं, तो हमारे दरवाज़े हमेशा खुले हैं।';

  @override
  String get notificationRejectionStoryTitle => 'धैर्य, कड़ी मेहनत, खुशी!';

  @override
  String get notificationRejectionStoryBody =>
      'कॉर्टेक्स को प्रकाशित होने से पहले ही गूगल प्ले द्वारा 20 से ज़्यादा बार अस्वीकार और दो बार निलंबित किया जा चुका था। लेकिन हमने विश्वास रखा और हम कामयाब हो गए। अपने सपनों को कभी मत छोड़ो!';

  @override
  String get notificationGGUFSupportTitle => 'अपना स्वयं का मॉडल लाओ!';

  @override
  String get notificationGGUFSupportBody =>
      'याद रखें, आप अपने GGUF फ़ॉर्मैट वाले AI मॉडल कॉर्टेक्स में जोड़ सकते हैं और उन्हें ऑफ़लाइन इस्तेमाल कर सकते हैं। शक्ति आपके हाथ में है।';

  @override
  String get notificationThemeCustomizationTitle => 'आपके मूड के लिए एक थीम';

  @override
  String get notificationThemeCustomizationBody =>
      'क्या आपने सेटिंग्स में थीम विकल्प देखे हैं? कॉर्टेक्स को अपनी पसंद के अनुसार निजीकृत करें और अपनी चैट को रंगीन बनाएँ!';

  @override
  String get notificationShowerThoughtTitle => 'शावर विचार';

  @override
  String get notificationShowerThoughtBody =>
      'अगर तरबूज़ एक फल है, तो क्या तकनीकी रूप से तरबूज़ का रस स्मूदी बन जाता है? हो सकता है कि आप इस गहन (या यूँ कहें कि बहुत गहन) विषय पर किसी मॉडल से चर्चा करना चाहें।';

  @override
  String get notificationLowBatteryTitle =>
      'आपकी बैटरी ख़त्म हो रही है... लेकिन मेरी नहीं!';

  @override
  String get notificationLowBatteryBody =>
      'आपके फ़ोन का चार्ज भले ही कम हो रहा हो, लेकिन मेरी ऊर्जा हमेशा 100% रहती है! इसे प्लग इन करें और बातें करते रहें।';

  @override
  String get channelFcmName => 'कॉर्टेक्स अपडेट';

  @override
  String get channelFcmDescription =>
      'कॉर्टेक्स से समाचार, अपडेट और अन्य जानकारी के बारे में सूचनाएं।';

  @override
  String get channelEngagementName => 'मैत्रीपूर्ण अनुस्मारक';

  @override
  String get channelEngagementDescription =>
      'आपको व्यस्त रखने के लिए मजेदार सूचनाएं।';

  @override
  String get channelGreetingsName => 'दैनिक अभिवादन';

  @override
  String get channelGreetingsDescription =>
      'शुभ प्रभात और शुभ रात्रि जैसे संदेश।';

  @override
  String get exitAppTitle => 'इतनी जल्दी जाना?';

  @override
  String get exitAppConfirmation =>
      'क्या आप वाकई इस अद्भुत मंच को छोड़ना चाहते हैं?';

  @override
  String get newsErrorTitle => 'समाचार लोड करने में विफल';

  @override
  String get newsErrorMessage =>
      'नवीनतम अपडेट प्राप्त करने में समस्या हुई, कृपया अपना कनेक्शन जांचें और पुनः प्रयास करें.';

  @override
  String get tagNotFound =>
      'आपके द्वारा दर्ज किया गया टैग अमान्य है या उसकी समय सीमा समाप्त हो चुकी है।';

  @override
  String get whatIsNew => 'नया क्या है?';

  @override
  String get onboardingTitle1 => 'अरे! हम कॉर्टेक्स टीम हैं।';

  @override
  String onboardingDesc1(String userName) {
    return '$userName, आपको यहाँ देखकर बहुत अच्छा लगा। हम कुछ हाई स्कूल के डेवलपर हैं जिन्होंने AI उद्योग के नियमों को नए सिरे से लिखने का फैसला किया है। आपसे मिलकर बहुत अच्छा लगा! तो चलिए एक-दूसरे को बेहतर तरीके से जानते हैं।';
  }

  @override
  String get onboardingTitle2 => 'समस्याएँ बहुत बड़ी थीं।';

  @override
  String get onboardingDesc2 =>
      'एआई क्रांति आई, लेकिन वह दहलीज पर ही अटक गई। ऊँची सदस्यता शुल्क, जटिल प्लेटफ़ॉर्म, निजता का हनन करने वाले और एआई तक पहुँच को अवरुद्ध करने वाले... जब तक वे खेल में थे, यह दहलीज कभी पार नहीं की जा सकी।';

  @override
  String get onboardingTitle3 => 'हम यूं ही खड़े नहीं रह सकते थे।';

  @override
  String get onboardingDesc3 =>
      'उस सीमा को पार करने के लिए, हमने एक ऐसा प्लेटफ़ॉर्म बनाया है जो शक्तिशाली, सुंदर, अनुकूलन योग्य, उपयोग में आसान, पूरी तरह से पारदर्शी है, ऑनलाइन और ऑफलाइन दोनों तरह से काम करता है, और आपका डेटा सिर्फ़ आपके डिवाइस पर ही रखता है। हमने यह शक्ति वापस उसी को दी है जहाँ इसकी ज़िम्मेदारी है: आपको।';

  @override
  String get onboardingTitle4 => 'यह कभी आसान नहीं था.';

  @override
  String get onboardingDesc4 =>
      'हमें दर्जनों बार अस्वीकार किया गया, कई बार निलंबित किया गया, झूठी चेतावनियाँ मिलीं, और दर्जनों बार अपना ब्रांड बदलना पड़ा। इन सबके बावजूद, हमें बताया गया कि यह संभव नहीं है। लेकिन हमने कभी हार नहीं मानी, यह मानते हुए कि यह परियोजना सिर्फ़ हमारी नहीं, बल्कि सभी की है। और इसीलिए हम यहाँ हैं।';

  @override
  String get onboardingFinalTitle => 'यह क्रांति का समय है.';

  @override
  String get onboardingFinalDesc =>
      'अगर आप यह स्क्रीन देख रहे हैं, तो इसकी वजह यह है कि हमने हार नहीं मानी। और हमारा हार मानने का कोई इरादा नहीं है। आइए, हम सब मिलकर AI क्रांति को दुनिया तक पहुँचाएँ। इस कहानी का हिस्सा बनने के लिए...';

  @override
  String get onboardingFinalQuestion => 'क्या आप तैयार हैं?';

  @override
  String get onboardingFinalButton => 'हाँ!';

  @override
  String get dude => 'दोस्त';

  @override
  String get swipeToContinue => 'जारी रखने के लिए स्वाइप करें';

  @override
  String get cacheIsNotUpToDate =>
      'आपका Play Store कैश अपडेट नहीं है। कृपया Play Store ऐप बंद करके दोबारा खोलें, या अपना डिवाइस रीस्टार्ट करें।';

  @override
  String get continueAsGuest => 'खाता बनाए बिना जारी रखें';

  @override
  String get guestModeWarning =>
      'सर्वोत्तम सेवा गुणवत्ता सुनिश्चित करने के लिए अतिथि मोड में सीमित सुविधाएँ हैं।';

  @override
  String get anonymousEntity => 'अनाम संस्था';

  @override
  String get upgradeAccountTitle => 'अपना खाता पूरा करें';

  @override
  String get upgradeAccountDescription =>
      'प्रतिदिन 200 बोनस क्रेडिट प्राप्त करने और अधिक सीमाएं अनलॉक करने के लिए एक खाता बनाएं।';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get upgradeTitle => 'पंजीकरण को अंतिम रूप दें';

  @override
  String get accountLinkedSuccess => 'खाता सफलतापूर्वक बनाया गया!';

  @override
  String get continueWithApple => 'Apple के साथ जारी रखें';

  @override
  String get guest => 'अतिथि';

  @override
  String get betterWithAnAccount => 'यह अनुभाग एक खाते के साथ बेहतर है!';

  @override
  String get restorePurchases => 'खरीदारी वापस लौटाएं';

  @override
  String annualTotalDescription(Object price) {
    return '$price/वर्ष, वार्षिक बिल';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'लगभग $price/माह';
  }

  @override
  String get confirmDownloadTitle => 'क्या आप वाकई डाउनलोड करना चाहते हैं?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'यह मॉडल लगभग $size स्थान घेरेगा।';
  }

  @override
  String get emulatorModeWarning => 'एमुलेटर मोड में यह सुविधा निष्क्रिय है।';
}
