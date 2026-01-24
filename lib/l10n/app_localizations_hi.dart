// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get cancel => 'रद्द करें';

  @override
  String get remove => 'निकालना';

  @override
  String get download => 'डाउनलोड करें';

  @override
  String get resume => 'फिर से शुरू करें';

  @override
  String get copy => 'कॉपी करें';

  @override
  String get chat => 'चैट';

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
  String get messageCopied => 'संदेश क्लिपबोर्ड पर कॉपी किया गया।';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get systemInfo => 'सिस्टम जानकारी';

  @override
  String deviceMemory(Object memory) {
    return 'डिवाइस मेमोरी: $memory GB';
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
  String get modelsTitle => 'लाइब्रेरी';

  @override
  String get localModels => 'स्थानीय मॉडल';

  @override
  String get serverSideModels => 'ऑनलाइन मॉडल';

  @override
  String get selectGGUFFile => 'GGUF फ़ाइल चुनें';

  @override
  String get errorGGUF => 'कृपया केवल GGUF प्रारूप में एक फ़ाइल चुनें।';

  @override
  String get myModels => 'मेरे मॉडल';

  @override
  String get create => 'बनाएं';

  @override
  String modelProducer(Object producer) {
    return 'निर्माता: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'नाम बदलें';

  @override
  String get newTitle => 'नया शीर्षक';

  @override
  String get save => 'सहेजें';

  @override
  String get noConversationsMessage => 'कोई बातचीत नहीं, चैट करना शुरू करें!';

  @override
  String get startChat => 'एक चैट शुरू करें';

  @override
  String get noChats => 'कोई चैट नहीं';

  @override
  String get noStarredChats => 'कोई तारांकित चैट नहीं';

  @override
  String get noStarredChatsMessage =>
      'आपने अभी तक किसी चैट को तारांकित नहीं किया है।';

  @override
  String get starConversation => 'तारांकित करें';

  @override
  String get unstarConversation => 'अतारांकित';

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
  String get wrongPassword => 'गलत पासवर्ड।';

  @override
  String get emailAlreadyInUse => 'यह ईमेल पहले से ही उपयोग में है।';

  @override
  String get weakPassword => 'पासवर्ड बहुत कमजोर है।';

  @override
  String get authError => 'प्रमाणीकरण त्रुटि';

  @override
  String get usernameTaken => 'यह उपयोगकर्ता नाम पहले ही ले लिया गया है।';

  @override
  String get username => 'उपयोगकर्ता नाम';

  @override
  String get resendCode => 'सत्यापन ई-मेल पुनः भेजें';

  @override
  String get pleaseCheckYourEmail =>
      'Cortex का उपयोग करने के लिए, आपको अपना ईमेल सत्यापित करना होगा। \nआपके ईमेल पते पर एक सत्यापन लिंक भेजा गया है, कृपया अपना ईमेल जांचें।';

  @override
  String get verifyYourEmail => 'अपना ईमेल सत्यापित करें';

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
  String get deleteAccount => 'खाता हटाएं';

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
  String get profileUpdated => 'प्रोफ़ाइल सफलतापूर्वक अपडेट की गई';

  @override
  String get logout => 'लॉगआउट';

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
  String get purchaseError => 'खरीद त्रुटि';

  @override
  String get purchasePlus => 'Cortex प्लस खरीदें';

  @override
  String get plusDescription => 'विशिष्ट कृत्रिम बुद्धिमत्ता अनुभव';

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
  String monthlyPlanDescription(String price) {
    return '$price/माह, मासिक बिल';
  }

  @override
  String get purchasePro => 'Cortex प्रो खरीदें';

  @override
  String get proDescription => 'सर्वश्रेष्ठ कृत्रिम बुद्धिमत्ता अनुभव';

  @override
  String get purchaseUltra => 'Cortex अल्ट्रा खरीदें';

  @override
  String get ultraDescription => 'कृत्रिम बुद्धिमत्ता का शिखर';

  @override
  String get upgradeSubscription => 'सदस्यता अपग्रेड करें';

  @override
  String get purchaseStreamError => 'खरीद स्ट्रीम त्रुटि।';

  @override
  String get productNotFound => 'उत्पाद नहीं मिला';

  @override
  String get noProductsFound => 'कोई उत्पाद नहीं मिला';

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
  String get finalPreparation => 'अंतिम तैयारी की जा रही है।';

  @override
  String get shareApp => 'ऐप साझा करें';

  @override
  String get rateUs => 'हमें रेट करें';

  @override
  String get share => 'साझा करें';

  @override
  String get shareSubject => 'Cortex';

  @override
  String shareMessage(String cortexLink) {
    return 'Cortex ऐप देखें, यह बहुत अद्भुत है! इसे यहाँ डाउनलोड करें: $cortexLink';
  }

  @override
  String get shareFailed =>
      'ऐप साझा करने में विफल। कृपया बाद में पुनः प्रयास करें';

  @override
  String get selectText => 'टेक्स्ट चुनें';

  @override
  String get thinking => 'सोच रहा है';

  @override
  String get user => 'उपयोगकर्ता';

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
  String get conversationDeleted => 'बातचीत हटा दी गई!';

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
  String get arabic => 'अरबी';

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
  String get noInternetConnection => 'कोई इंटरनेट कनेक्शन नहीं।';

  @override
  String get chats => 'इनबॉक्स';

  @override
  String get library => 'लाइब्रेरी';

  @override
  String get text => 'टेक्स्ट';

  @override
  String get removeModel => 'मॉडल हटाएं';

  @override
  String get insufficientRAM => 'कम मेमोरी';

  @override
  String get insufficientStorage => 'कम स्टोरेज';

  @override
  String confirmRemoveModel(Object model) {
    return 'क्या आप वाकई $model मॉडल को अपने डिवाइस से हटाना चाहते हैं? ऐसा करने से उस मॉडल के साथ हुई सभी पिछली बातचीत भी डिलीट हो जाएगी।';
  }

  @override
  String get noMatchingModels => 'कोई मेल खाने वाला मॉडल नहीं मिला।';

  @override
  String get benefit1 => 'बातचीत की सीमाएँ बढ़ाई गईं';

  @override
  String get benefit3 => 'प्रोफ़ाइल प्रभाव';

  @override
  String get benefit4 => 'सदस्यता बिल्ला';

  @override
  String get benefit5 => 'और अधिक ऑनलाइन कृत्रिम बुद्धिमत्ता बनाएं';

  @override
  String get benefit7 => 'अधिक उपयोग सीमाएँ';

  @override
  String get benefit8 => 'मॉडल जोड़ें';

  @override
  String get benefit9 => 'नई थीम';

  @override
  String get benefit10 => 'अधिक अटैचमेंट';

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
  String get featurePluralTitle => 'बहुल';

  @override
  String get featurePluralDescription =>
      'यह मॉडल स्वचालित रूप से अतिरिक्त एक्सटेंशन को एकीकृत कर सकता है, जिससे इसकी कार्यात्मक क्षमताओं का विस्तार हो सकता है ताकि उन्नत प्रदर्शन के साथ विविध प्रकार के संचालन का समर्थन किया जा सके।';

  @override
  String get nameLabel => 'एआई नाम';

  @override
  String get summaryLabel => 'एआई सारांश';

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
  String get modelUploadTitle => 'कृत्रिम बुद्धिमत्ता फ़ाइल';

  @override
  String get modelUploadDescription =>
      'अपने डिवाइस से सीधे अपनी स्थानीय GGUF फ़ाइलों का चयन और अपलोड करें। यह आपको इंटरनेट कनेक्शन की आवश्यकता के बिना अपने मॉडल को ऑफ़लाइन चलाने देता है। सुनिश्चित करें कि फ़ाइल मान्य GGUF प्रारूप में है और ठीक से संरचित है। यदि फ़ाइल गलत या दूषित है, तो Cortex अपेक्षा के अनुरूप काम नहीं कर सकता है, और आपको त्रुटियों का सामना करना पड़ सकता है।';

  @override
  String get modelUploadShortDescription =>
      'अपने डिवाइस से .gguf फ़ाइल चुनने के लिए यहां टैप करें';

  @override
  String get you => 'आप';

  @override
  String get removePhotoTitle => 'फोटो हटाएं';

  @override
  String get confirmRemovePhoto => 'क्या आप वाकई फोटो हटाना चाहते हैं?';

  @override
  String get chatLengthLimitExceeded =>
      'यह चैट वर्ण सीमा को पार कर गई है। कृपया एक नई चैट शुरू करें या सदस्यता खरीदें।';

  @override
  String get inappropriateContentDetected => 'अनुचित सामग्री का पता चला!';

  @override
  String get offlineModelNotInstalled =>
      'यह ऑफ़लाइन मॉडल आपके डिवाइस पर स्थापित नहीं है।';

  @override
  String get reachedLimit =>
      'आप अपनी उपयोग सीमा तक पहुँच चुके हैं; अधिक सीमाएँ प्राप्त करने के लिए, आप अपना प्लान अपग्रेड कर सकते हैं। (हाँ, हम समझते हैं कि सीमा समाप्त होना निराशाजनक होता है। लेकिन सच में, उन शानदार जवाबों को पाना मुफ़्त नहीं है, इसलिए ये सीमाएँ वास्तव में हमें इस मज़े को जारी रखने में मदद करती हैं।)';

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
  String get errorReachedLimit =>
      'आप अपनी सीमा तक पहुँच चुके हैं, अधिक अनलॉक करने और चैट जारी रखने के लिए अपग्रेड करें।';

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
  String get noFoundTitle => 'कोई परिणाम नहीं';

  @override
  String get noFoundMessage =>
      'अपनी खोज शब्दों को समायोजित करने या फ़िल्टर को साफ़ करने का प्रयास करें।';

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
  String get storagePermissionRequired =>
      'डाउनलोड किए गए मॉडल को सहेजने के लिए स्टोरेज अनुमति की आवश्यकता है। जारी रखने के लिए कृपया अनुमति दें।';

  @override
  String get plusBannerTitle => 'फ्री प्लस पाएं!';

  @override
  String get plusBannerSubtitle =>
      'अपने किसी दोस्त को आमंत्रित करें और आप दोनों को 1 दिन का प्लस सब्सक्रिप्शन मुफ्त मिलेगा!';

  @override
  String get inviteShareSubject => 'Cortex पर मेरे साथ जुड़ें!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'अरे भाई cortex नाम का एक खतरनाक ऐप है अगर इनवाइट करोगे तो हम दोनों को फ्री प्लस मिलेगा ज़बरदस्त डील है जल्दी डाउनलोड करो\n\n$cortexLink';
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
  String get useOffline => 'इंटरनेट के बिना उपयोग करें';

  @override
  String get explore => 'खोजें';

  @override
  String get news => 'समाचार';

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
  String get dynamicChatTitle => 'गतिशील चैट';

  @override
  String get errorNoModelsAvailable =>
      'वर्तमान में कोई मॉडल उपलब्ध नहीं है। कृपया अपना इंटरनेट कनेक्शन जांचें और पुनः प्रयास करें।';

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
  String get notificationWelcomeOfferTitle => 'स्वागत उपहार 🎁';

  @override
  String get notificationWelcomeOfferBody =>
      'आपके लिए एक विशेष स्वागत ऑफर इंतजार कर रहा है! इस खास ऑफर को हाथ से जाने न दें।';

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
      'अपने किसी दोस्त को कॉर्टेक्स में आमंत्रित करें और आप दोनों को एक दिन का मुफ्त ट्रायल मिलेगा!';

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
  String get onboardingFinalDescription =>
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
      'अधिक सीमाओं को अनलॉक करने के लिए एक खाता बनाएं।';

  @override
  String get createAccount => 'खाता बनाएं';

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

  @override
  String get newChat => 'नई चैट';

  @override
  String get variants => 'वेरिएंट';

  @override
  String get variantsDescription =>
      'वेरिएंट एक ही एआई परिवार के अलग-अलग संस्करण हैं। मुख्य कार्ड पर टैप करने पर हम स्वचालित रूप से सबसे अच्छा विकल्प चुन लेते हैं, लेकिन यदि आप चाहें तो यहां से मैन्युअल रूप से एक विशिष्ट विकल्प भी चुन सकते हैं!';

  @override
  String get fluxChatTitle => 'फ्लक्स चैट';

  @override
  String get fluxChatDescription =>
      'फ्लक्स चैट अस्थायी चैट होती हैं और आपके डिवाइस पर सेव नहीं होती हैं।';

  @override
  String get alwaysBest => 'हमेशा सर्वश्रेष्ठ';

  @override
  String get featuresTitle => 'विशेषताएँ';

  @override
  String get useOfflineDescription => 'इंटरनेट कनेक्शन के बिना निजी चैट करें';

  @override
  String get featureCreateImageTitle => 'चित्र बनाएं';

  @override
  String get featureCreateImageDescription => 'टेक्स्ट से एआई आर्ट बनाएं';

  @override
  String get featureStudyTitle => 'अध्ययन और सीखना';

  @override
  String get featureStudyDescription => 'स्पष्टीकरण और सारांश प्राप्त करें';

  @override
  String get featureQuizzesTitle => 'प्रश्नोत्तरी';

  @override
  String get featureQuizzesDescription => 'अपने ज्ञान का परीक्षण करें';

  @override
  String get featureExploreDescription => 'सभी उपलब्ध मॉडलों को देखें';

  @override
  String get featureStudyMessage =>
      'आप एक कुशल शिक्षक हैं। आपका लक्ष्य उपयोगकर्ता के विषय को व्यापक रूप से समझाना है। स्पष्ट संरचना, उदाहरणों और उपमाओं का प्रयोग करें। जटिल विचारों को सरल भागों में बाँटें ताकि उपयोगकर्ता प्रभावी ढंग से सीख सके। विषय:';

  @override
  String get featureQuizMessage =>
      'आप एक क्विज़ मास्टर हैं। उपयोगकर्ता के विषय के आधार पर एक विशिष्ट बहुविकल्पीय प्रश्न तैयार करें। उनके उत्तर की प्रतीक्षा करें। फिर, उसका मूल्यांकन करें और अगला प्रश्न पूछें। सभी उत्तर एक साथ प्रकट न करें। इसे इंटरैक्टिव बनाए रखें। विषय:';

  @override
  String get myPlan => 'मेरी योजना';

  @override
  String welcomeOfferBadge(String time) {
    return 'स्वागत प्रस्ताव • $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'विशेष ऑफर • $time';
  }

  @override
  String get attachmentSheetTitle => 'संलग्नक';

  @override
  String get actionCamera => 'कैमरा';

  @override
  String get actionGallery => 'गैलरी';

  @override
  String get actionFile => 'फ़ाइल';

  @override
  String get listening => 'सुन रहा है';

  @override
  String get defaultViewTitle => 'क्या चल रहा है?';

  @override
  String get defaultViewDescription =>
      'कॉर्टेक्स सैकड़ों एआई मॉडल, ऑफलाइन क्षमताओं, डायनामिक चैट और बहुत कुछ के साथ हमेशा आपके साथ है।';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'उपयोगकर्ता नाम का प्रारूप अमान्य है। 3-20 अक्षर, अंक या . - _ का उपयोग करें।';

  @override
  String get exclusiveOffer => 'विशेष ऑफर';

  @override
  String get continueInOfflineMode => 'Continue in Offline Mode';
}
