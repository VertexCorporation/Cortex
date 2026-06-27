// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'æ‚¨æ˜¯æ ‡é¢˜ç”Ÿæˆå™¨ã€‚è¯·ä»…å›å¤ä¸€ä¸ª2-5ä¸ªå­—çš„æ ‡é¢˜ï¼Œç”¨äºæ¥ä¸‹æ¥çš„å¯¹è¯ã€‚è¯·å‹¿ä½¿ç”¨å¼•å·ã€å‰ç¼€æˆ–æ ‡ç‚¹ç¬¦å·ã€‚é‡è¦æç¤ºï¼šæ ‡é¢˜å¿…é¡»ä¸ç”¨æˆ·æ¶ˆæ¯çš„è¯­è¨€å®Œå…¨ç›¸åŒã€‚';

  @override
  String get systemRoleFallback => 'ä½ æ˜¯ä¸€ä½å¾—åŠ›çš„åŠ©æ‰‹ã€‚';

  @override
  String get systemLanguageInstruction =>
      '\n\nCRITICALï¼šå§‹ç»ˆä½¿ç”¨ç”¨æˆ·ç¼–å†™çš„ç›¸åŒè¯­è¨€è¿›è¡Œå›å¤ï¼Œæ³¨æ„ç”¨æˆ·çš„è¯­è¨€ã€‚';

  @override
  String get systemNotePreviousMedia =>
      'ã€ç³»ç»Ÿæç¤ºï¼šä»¥ä¸‹ä¸ºä¹‹å‰ç”Ÿæˆçš„åª’ä½“æ–‡ä»¶ï¼Œæ‚¨å¯ä»¥å‚è€ƒæˆ–ç¼–è¾‘ã€‚ã€‘';

  @override
  String systemTimeInfo(String formattedTime) {
    return '\n\nå½“å‰æ—¥æœŸå’Œæ—¶é—´ï¼š$formattedTimeã€‚';
  }

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\nåˆ†æåˆ°ç›®å‰ä¸ºæ­¢çš„å¯¹è¯ã€‚å¦‚æœæ‚¨äº†è§£åˆ°ä»»ä½•å…³äºç”¨æˆ·çš„æ–°ä¿¡æ¯ï¼ˆåå¥½ã€å§“åã€ä¹ æƒ¯ã€ä¸Šä¸‹æ–‡ï¼‰ï¼Œæ‚¨å¿…é¡»åœ¨å›å¤çš„æœ€åï¼Œä½¿ç”¨ `<memory>...</memory>` æ ‡ç­¾è¾“å‡ºæ‚¨æ›´æ–°åçš„ç”¨æˆ·è®°å¿†ã€‚å…³é”®ï¼šæ‚¨ç»ä¸èƒ½æ“¦é™¤æˆ–è¦†ç›–ä¹‹å‰çš„è®°å¿†ã€‚å§‹ç»ˆå°†æ–°ä¿¡æ¯æ·»åŠ åˆ°ç°æœ‰è®°å¿†ä¸­ã€‚å¦‚æœæ²¡æœ‰äº†è§£åˆ°ä»»ä½•æ–°ä¿¡æ¯ï¼Œåˆ™çœç•¥è¯¥æ ‡ç­¾ã€‚ä¾‹å¦‚ï¼š`<memory>å–œæ¬¢è¶³çƒå’Œç½‘çƒã€‚å–œæ¬¢ç®€çŸ­çš„å›ç­”ã€‚</memory>`';

  @override
  String systemMemoryReminder(Object userMemory) {
    return '\n\nè¯·å§‹ç»ˆè®°ä½å…³äºç”¨æˆ·çš„è¿™ä¸€ç‚¹ï¼š\n$userMemory';
  }

  @override
  String get cancel => 'å–æ¶ˆ';

  @override
  String get remove => 'æ¶ˆé™¤';

  @override
  String get download => 'ä¸‹è½½';

  @override
  String get resume => 'æ¢å¤';

  @override
  String get copy => 'å¤åˆ¶';

  @override
  String get chat => 'èŠå¤©';

  @override
  String get locked => 'Locked';

  @override
  String get languageModels => 'è¯­è¨€æ¨¡å‹';

  @override
  String get light => 'æµ…è‰²';

  @override
  String get theme => 'ä¸»é¢˜';

  @override
  String get no => 'å¦';

  @override
  String get yes => 'æ˜¯';

  @override
  String get done => 'å®Œæˆ';

  @override
  String get bestValue => 'æœ€è¶…å€¼';

  @override
  String get selected => 'å·²é€‰æ‹©';

  @override
  String get descriptionSection => 'æè¿°';

  @override
  String get searchHint => 'æœç´¢';

  @override
  String get messageHint => 'éšä¾¿é—®ç‚¹ä»€ä¹ˆ';

  @override
  String get messageCopied => 'æ¶ˆæ¯å·²å¤åˆ¶åˆ°å‰ªè´´æ¿ã€‚';

  @override
  String get retry => 'é‡è¯•';

  @override
  String get systemInfo => 'ç³»ç»Ÿä¿¡æ¯';

  @override
  String deviceMemory(Object memory) {
    return 'è®¾å¤‡å†…å­˜: $memory GB';
  }

  @override
  String get memory => 'å†…å­˜';

  @override
  String get storage => 'å­˜å‚¨';

  @override
  String get freeStorage => 'å¯ç”¨å­˜å‚¨';

  @override
  String get totalStorage => 'æ€»å­˜å‚¨';

  @override
  String get usedStorage => 'å·²ç”¨å­˜å‚¨';

  @override
  String get totalMemory => 'æ€»å†…å­˜';

  @override
  String get usedMemory => 'å·²ç”¨å†…å­˜';

  @override
  String get modelsTitle => 'åº“';

  @override
  String get localModels => 'æœ¬åœ°æ¨¡å‹';

  @override
  String get selectGGUFFile => 'é€‰æ‹© GGUF æ–‡ä»¶';

  @override
  String get errorGGUF => 'è¯·ä»…é€‰æ‹© GGUF æ ¼å¼çš„æ–‡ä»¶ã€‚';

  @override
  String get myModels => 'æˆ‘çš„æ¨¡å‹';

  @override
  String get create => 'åˆ›å»º';

  @override
  String modelProducer(Object producer) {
    return 'å¼€å‘è€…: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'é‡å‘½å';

  @override
  String get newTitle => 'æ–°æ ‡é¢˜';

  @override
  String get save => 'ä¿å­˜';

  @override
  String get noConversationsMessage => 'æ²¡æœ‰å¯¹è¯ï¼Œå¼€å§‹èŠå¤©å§ï¼';

  @override
  String get startChat => 'å¼€å§‹èŠå¤©';

  @override
  String get noChats => 'æ— èŠå¤©';

  @override
  String get noStarredChats => 'æ— å·²æ”¶è—çš„èŠå¤©';

  @override
  String get noStarredChatsMessage => 'æ‚¨è¿˜æ²¡æœ‰æ”¶è—ä»»ä½•èŠå¤©ã€‚';

  @override
  String get starConversation => 'æ”¶è—';

  @override
  String get unstarConversation => 'ä¸æ˜Ÿ';

  @override
  String get loginToYourAccount => 'ç™»å½•';

  @override
  String get createYourAccount => 'æ³¨å†Œ';

  @override
  String get email => 'é‚®ç®±';

  @override
  String get password => 'å¯†ç ';

  @override
  String get confirmPassword => 'ç¡®è®¤å¯†ç ';

  @override
  String get invalidEmail => 'è¯·è¾“å…¥æœ‰æ•ˆçš„é‚®ç®±åœ°å€ã€‚';

  @override
  String get invalidPassword => 'å¯†ç é•¿åº¦è‡³å°‘ä¸º6ä¸ªå­—ç¬¦ã€‚';

  @override
  String get rememberMe => 'è®°ä½æˆ‘';

  @override
  String get forgotPassword => 'å¿˜è®°å¯†ç ï¼Ÿ';

  @override
  String get or => 'æˆ–';

  @override
  String get continueWithGoogle => 'ä½¿ç”¨ Google ç»§ç»­';

  @override
  String get dontHaveAccount => 'è¿˜æ²¡æœ‰è´¦æˆ·ï¼Ÿ';

  @override
  String get alreadyHaveAccount => 'å·²ç»æœ‰è´¦æˆ·äº†ï¼Ÿ';

  @override
  String get signUp => 'æ³¨å†Œ';

  @override
  String get logIn => 'ç™»å½•';

  @override
  String get passwordsDoNotMatch => 'å¯†ç ä¸åŒ¹é…ã€‚';

  @override
  String get wrongPassword => 'å¯†ç ä¸æ­£ç¡®ã€‚';

  @override
  String get emailAlreadyInUse => 'æ­¤é‚®ç®±å·²è¢«ä½¿ç”¨ã€‚';

  @override
  String get weakPassword => 'å¯†ç å¤ªå¼±ã€‚';

  @override
  String get authError => 'è®¤è¯é”™è¯¯';

  @override
  String get usernameTaken => 'æ­¤ç”¨æˆ·åå·²è¢«å ç”¨ã€‚';

  @override
  String get username => 'ç”¨æˆ·å';

  @override
  String get resendCode => 'é‡æ–°å‘é€éªŒè¯é‚®ä»¶';

  @override
  String get pleaseCheckYourEmail =>
      'ä¸ºäº†ä½¿ç”¨ Cortexï¼Œæ‚¨éœ€è¦éªŒè¯æ‚¨çš„é‚®ç®±ã€‚\néªŒè¯é“¾æ¥å·²å‘é€åˆ°æ‚¨çš„é‚®ç®±åœ°å€ï¼Œè¯·æ£€æŸ¥æ‚¨çš„é‚®ç®±ã€‚';

  @override
  String get verifyYourEmail => 'éªŒè¯æ‚¨çš„é‚®ç®±';

  @override
  String get seconds => 'ç§’';

  @override
  String get maxResendLimitReached =>
      'æ‚¨å·²è¾¾åˆ°éªŒè¯é‚®ä»¶å‘é€æ¬¡æ•°ä¸Šé™';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'ä¸éªŒè¯å¹¶ç»§ç»­';

  @override
  String get verificationScreenWarning =>
      'å³ä½¿æ‚¨ç»§ç»­ï¼Œæ‚¨çš„è´¦æˆ·ä»æœ‰1å¤©çš„éªŒè¯æœŸã€‚å¦‚æœå±Šæ—¶æ‚¨ä»æœªéªŒè¯è´¦æˆ·ï¼Œè¯¥è´¦æˆ·å°†è¢«ä»åº”ç”¨ä¸­åˆ é™¤ã€‚';

  @override
  String get unverifiedAccountHeader => 'æ‚¨çš„è´¦æˆ·å°šæœªéªŒè¯';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'å¦‚æœæ‚¨æœªåœ¨$timeLeftå†…éªŒè¯æ‚¨çš„è´¦æˆ·ï¼Œå®ƒå°†è¢«åˆ é™¤';
  }

  @override
  String get verifyNow => 'ç«‹å³éªŒè¯';

  @override
  String get linkSent => 'é“¾æ¥å·²å‘é€';

  @override
  String get accountDeletionRequested =>
      'æ‚¨çš„å¸æˆ·åˆ é™¤è¯·æ±‚å·²æ”¶åˆ°ï¼Œæ‚¨çš„å¸æˆ·ç°å·²è¢«ç¦ç”¨ã€‚';

  @override
  String get tooManyRequests => 'è¯·æ±‚è¿‡äºé¢‘ç¹';

  @override
  String get regenerate => 'é‡æ–°ç”Ÿæˆ';

  @override
  String get confirmDeleteAccount => 'æ‚¨ç¡®å®šè¦åˆ é™¤æ‚¨çš„è´¦æˆ·å—ï¼Ÿ';

  @override
  String get deleteAccount => 'åˆ é™¤è´¦æˆ·';

  @override
  String get delete => 'åˆ é™¤';

  @override
  String get passwordRequired => 'éœ€è¦å¯†ç ã€‚';

  @override
  String get deleteDescription =>
      'æ‚¨åˆ é™¤çš„æ•°æ®å°†ä»æˆ‘ä»¬çš„æœåŠ¡å™¨å’Œæ‚¨çš„è®¾å¤‡ä¸­æ°¸ä¹…ç§»é™¤ã€‚æ­¤æ“ä½œæ— æ³•æ’¤é”€ã€‚';

  @override
  String get editProfile => 'ç¼–è¾‘ä¸ªäººèµ„æ–™';

  @override
  String get displayName => 'æ˜¾ç¤ºåç§°';

  @override
  String get profileUpdated => 'ä¸ªäººèµ„æ–™æ›´æ–°æˆåŠŸ';

  @override
  String get logout => 'ç™»å‡º';

  @override
  String get profile => 'ä¸ªäººèµ„æ–™';

  @override
  String get manageProfileDescription =>
      'ç®¡ç†æ‚¨çš„ä¸ªäººèµ„æ–™ï¼Œæ›´æ–°å¯†ç ï¼Œæˆ–ä» Cortex ç™»å‡ºã€‚';

  @override
  String get accessSettingsDescription =>
      'è·å–å¸®åŠ©ï¼Œå…‘æ¢ä»£ç ï¼Œåˆ†äº« Cortexï¼Œä»¥åŠæŸ¥çœ‹æˆ‘ä»¬çš„æ”¿ç­–ã€‚';

  @override
  String get languageDescription =>
      'æ‚¨å¯ä»¥éšæ—¶æ›´æ”¹æ‚¨çš„é»˜è®¤åº”ç”¨ç•Œé¢è¯­è¨€ã€‚';

  @override
  String get themeDescription =>
      'æ‚¨å¯ä»¥æ ¹æ®åå¥½åœ¨æµ…è‰²å’Œæ·±è‰²ä¸»é¢˜ä¹‹é—´åˆ‡æ¢ã€‚æ‰€é€‰ä¸»é¢˜å°†åº”ç”¨äºæ•´ä¸ª Cortex ç•Œé¢ã€‚';

  @override
  String get iHaveReadAndAgree => 'æˆ‘å·²é˜…è¯»å¹¶åŒæ„æœåŠ¡æ¡æ¬¾';

  @override
  String get downloading => 'ä¸‹è½½ä¸­...';

  @override
  String get downloadSuccess => 'ä¸‹è½½æˆåŠŸ';

  @override
  String get downloadFailed => 'ä¸‹è½½å¤±è´¥';

  @override
  String downloaded(Object percent) {
    return 'å·²ä¸‹è½½ $percent%';
  }

  @override
  String get downloadPaused => 'ä¸‹è½½å·²æš‚åœã€‚';

  @override
  String get purchaseError => 'è´­ä¹°é”™è¯¯';

  @override
  String get purchasePlus => 'è´­ä¹° Cortex Plus';

  @override
  String get plusDescription => 'ç²¾è‹±äººå·¥æ™ºèƒ½ä½“éªŒ';

  @override
  String get annual => 'å¹´åº¦';

  @override
  String get monthly => 'æœˆåº¦';

  @override
  String get manageSubscription => 'ç®¡ç†è®¢é˜…';

  @override
  String purchasePlan(String planName) {
    return 'è´­ä¹° $planName';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/æœˆï¼ŒæŒ‰æœˆè®¡è´¹';
  }

  @override
  String get purchasePro => 'è´­ä¹° Cortex Pro';

  @override
  String get proDescription => 'é¡¶çº§äººå·¥æ™ºèƒ½ä½“éªŒ';

  @override
  String get purchaseUltra => 'è´­ä¹° Cortex Ultra';

  @override
  String get ultraDescription => 'äººå·¥æ™ºèƒ½çš„å·…å³°';

  @override
  String get upgradeSubscription => 'å‡çº§è®¢é˜…';

  @override
  String get purchaseStreamError => 'è´­ä¹°æµé”™è¯¯ã€‚';

  @override
  String get productNotFound => 'äº§å“æœªæ‰¾åˆ°';

  @override
  String get noProductsFound => 'æœªæ‰¾åˆ°äº§å“';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'ä¸‹è®¢å•å³è¡¨ç¤ºæ‚¨åŒæ„æœåŠ¡æ¡æ¬¾å’Œéšç§æ”¿ç­–ã€‚æ‚¨å¯ä»¥ç‚¹å‡»æ­¤æ–‡æœ¬ä»¥äº†è§£æœ‰å…³æˆ‘ä»¬æœåŠ¡æ¡æ¬¾å’Œéšç§æ”¿ç­–çš„æ›´å¤šä¿¡æ¯ã€‚è®¢é˜…å°†è‡ªåŠ¨ç»­è®¢ï¼Œé™¤éåœ¨å½“å‰å‘¨æœŸç»“æŸå‰è‡³å°‘24å°æ—¶å…³é—­è‡ªåŠ¨ç»­è®¢ã€‚';

  @override
  String get termsOfService => 'æœåŠ¡æ¡æ¬¾';

  @override
  String get privacyPolicy => 'éšç§æ”¿ç­–';

  @override
  String get renamed => 'æ›´å';

  @override
  String get report => 'ä¸¾æŠ¥';

  @override
  String get reportDialogTitle => 'æäº¤ä¸¾æŠ¥';

  @override
  String get reportDescriptionLabel => 'é—®é¢˜æ˜¯ä»€ä¹ˆï¼Ÿ';

  @override
  String get reportHarmful => 'è¿™æ˜¯æœ‰å®³/ä¸å®‰å…¨çš„';

  @override
  String get reportNotTrue => 'è¿™ä¸æ˜¯çœŸå®çš„';

  @override
  String get reportNotHelpful => 'è¿™æ²¡æœ‰å¸®åŠ©';

  @override
  String get closeButton => 'å…³é—­';

  @override
  String get submitButton => 'æäº¤';

  @override
  String get reportErrorMessage => 'è¯·é€‰æ‹©ä¸€ä¸ªä¸¾æŠ¥åŸå› ã€‚';

  @override
  String get capabilitiesSection => 'èƒ½åŠ›';

  @override
  String get featurePhotoTitle => 'ç…§ç‰‡æ‰«æ';

  @override
  String get featurePhotoDescription =>
      'æ­¤æ¨¡å‹èƒ½å¤Ÿé€šè¿‡æ‘„åƒå¤´æˆ–å›¾åƒæ–‡ä»¶æ‰«æç…§ç‰‡ã€‚';

  @override
  String get featureOfflineTitle => 'ç¦»çº¿æ“ä½œ';

  @override
  String get featureOfflineDescription =>
      'æ— éœ€äº’è”ç½‘è¿æ¥å³å¯è¿è¡Œæ¨¡å‹ï¼Œç¡®ä¿æ‚¨çš„æ•°æ®å®‰å…¨ã€‚';

  @override
  String get featureRoleplayTitle => 'è§’è‰²æ‰®æ¼”';

  @override
  String get featureRoleplayDescription =>
      'è§’è‰²æ‰®æ¼”æ¨¡å‹å…è®¸æ‚¨åˆ›å»ºå„ç§èŠå¤©å’Œåœºæ™¯ã€‚';

  @override
  String get roleModels => 'è§’è‰²æ‰®æ¼”æ¨¡å‹';

  @override
  String get parameters => 'å‚æ•°';

  @override
  String get context => 'ä¸Šä¸‹æ–‡';

  @override
  String get finalPreparation => 'æ­£åœ¨è¿›è¡Œæœ€åçš„å‡†å¤‡ã€‚';

  @override
  String get shareApp => 'åˆ†äº«åº”ç”¨';

  @override
  String get ourStory => 'æˆ‘ä»¬çš„æ•…äº‹';

  @override
  String get rateUs => 'ç»™æˆ‘ä»¬è¯„åˆ†';

  @override
  String get share => 'åˆ†äº«';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'é€‰æ‹©æ–‡æœ¬';

  @override
  String get thinking => 'æ€è€ƒä¸­';

  @override
  String get user => 'ç”¨æˆ·';

  @override
  String get help => 'å¸®åŠ©';

  @override
  String get supportCreator => 'æ”¯æŒåˆ›ä½œè€…';

  @override
  String get enterYourTag =>
      'æ”¯æŒä½ æœ€å–œæ¬¢çš„åˆ›ä½œè€…ï¼åœ¨ä¸‹æ–¹è¾“å…¥ä»–ä»¬çš„ä¸“å±æ ‡ç­¾ï¼Œå³å¯è®©ä»–ä»¬åˆ†äº«ä½ åœ¨Cortexä¸Šçš„æ¶ˆè´¹æ”¶ç›Šã€‚';

  @override
  String get creatorTag => 'åˆ›ä½œè€…æ ‡ç­¾';

  @override
  String get support => 'æ”¯æŒ';

  @override
  String get tagCannotBeEmpty => 'åˆ›å»ºè€…æ ‡ç­¾ä¸èƒ½ä¸ºç©º';

  @override
  String get userId => 'ç”¨æˆ· ID';

  @override
  String get deleteAllConversationsConfirmTitle => 'åˆ é™¤æ‰€æœ‰èŠå¤©ï¼Ÿ';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'æ‚¨ç¡®å®šè¦åˆ é™¤æ‰€æœ‰èŠå¤©å—ï¼Ÿæ­¤æ“ä½œæ— æ³•æ’¤é”€ã€‚';

  @override
  String get conversationDeleted => 'å¯¹è¯å·²åˆ é™¤ï¼';

  @override
  String get allConversationsDeleted => 'æ‰€æœ‰å¯¹è¯å·²æˆåŠŸåˆ é™¤ï¼';

  @override
  String get deleteAll => 'å…¨éƒ¨åˆ é™¤';

  @override
  String get deleteAllConversationsButton => 'åˆ é™¤æ‰€æœ‰å¯¹è¯';

  @override
  String get confirmWord => 'è¾“å…¥ VERTEX';

  @override
  String get confirmWordError => 'æ‚¨è¾“å…¥é”™è¯¯';

  @override
  String get chinese => 'ä¸­æ–‡';

  @override
  String get french => 'æ³•è¯­';

  @override
  String get japanese => 'æ—¥è¯­';

  @override
  String get dutch => 'è·å…°è¯­';

  @override
  String get russian => 'ä¿„è¯­';

  @override
  String get korean => 'éŸ©è¯­';

  @override
  String get english => 'è‹±è¯­';

  @override
  String get turkish => 'åœŸè€³å…¶è¯­';

  @override
  String get hindi => 'å°åœ°è¯­';

  @override
  String get portuguese => 'è‘¡è„ç‰™è¯­';

  @override
  String get indonesian => 'å°å°¼è¯­';

  @override
  String get azerbaijani => 'é˜¿å¡æ‹œç–†è¯­';

  @override
  String get german => 'å¾·è¯­';

  @override
  String get spanish => 'è¥¿ç­ç‰™è¯­';

  @override
  String get italian => 'æ„å¤§åˆ©è¯­';

  @override
  String get arabic => 'é˜¿æ‹‰ä¼¯';

  @override
  String get ram => 'å†…å­˜';

  @override
  String get usernameTooShort => 'ç”¨æˆ·åå¤ªçŸ­ã€‚';

  @override
  String get usernameTooLong => 'ç”¨æˆ·åä¸èƒ½è¶…è¿‡16ä¸ªå­—ç¬¦ã€‚';

  @override
  String get invalidUsernameCharacters =>
      'ç”¨æˆ·ååªèƒ½ä½¿ç”¨å­—æ¯ \'abcÃ§defgÄŸhÄ±ijklmnoÃ¶prsÅŸtuÃ¼vyzxqw\' ä»¥åŠå­—ç¬¦ \'.\'ã€\'-\'ã€\'_\'ã€‚';

  @override
  String get noInternetConnection => 'æ— ç½‘ç»œè¿æ¥ã€‚';

  @override
  String get chats => 'æ”¶ä»¶ç®±';

  @override
  String get library => 'åº“';

  @override
  String get text => 'æ–‡æœ¬';

  @override
  String get removeModel => 'ç§»é™¤æ¨¡å‹';

  @override
  String get insufficientRAM => 'å†…å­˜ä¸è¶³';

  @override
  String get insufficientStorage => 'å­˜å‚¨ç©ºé—´ä¸è¶³';

  @override
  String confirmRemoveModel(Object model) {
    return 'æ‚¨ç¡®å®šè¦ä»è®¾å¤‡ä¸­ç§»é™¤ $model å‹å·å—ï¼Ÿè¿™æ ·åšä¹Ÿä¼šåˆ é™¤ä¹‹å‰ä¸è¯¥å‹å·çš„æ‰€æœ‰å¯¹è¯è®°å½•ã€‚';
  }

  @override
  String get noMatchingModels => 'æœªæ‰¾åˆ°åŒ¹é…çš„æ¨¡å‹ã€‚';

  @override
  String get benefit1 => 'æé«˜å¯¹è¯ä¸Šé™';

  @override
  String get benefit3 => 'ä¸ªäººèµ„æ–™ç‰¹æ•ˆ';

  @override
  String get benefit4 => 'ä¼šå‘˜å¾½ç« ';

  @override
  String get benefit5 => 'åˆ›å»ºæ›´å¤šåœ¨çº¿äººå·¥æ™ºèƒ½';

  @override
  String get benefit7 => 'æ›´å¤šä½¿ç”¨é™åˆ¶';

  @override
  String get benefit8 => 'æ·»åŠ æ¨¡å‹';

  @override
  String get benefit9 => 'æ–°ä¸»é¢˜';

  @override
  String get benefit10 => 'æ›´å¤šé™„ä»¶';

  @override
  String get benefit11 => 'æ›´å¤šæµåŠ¨æ¨¡å¼';

  @override
  String get oldBenefits => 'åŒ…å«æ‰€æœ‰è¾ƒä½çº§åˆ«è®¡åˆ’çš„æƒç›Š';

  @override
  String get confirm => 'ç¡®è®¤';

  @override
  String get changePassword => 'æ›´æ”¹å¯†ç ';

  @override
  String get logoutConfirmationTitle => 'æ‚¨ç¡®å®šè¦ç™»å‡ºå—ï¼Ÿ';

  @override
  String get settings => 'è®¾ç½®';

  @override
  String get language => 'åº”ç”¨è¯­è¨€';

  @override
  String get dark => 'æ·±è‰²';

  @override
  String get oldPassword => 'æ—§å¯†ç ';

  @override
  String get newPassword => 'æ–°å¯†ç ';

  @override
  String get passwordUpdated => 'å¯†ç å·²æ›´æ–°ã€‚';

  @override
  String get stop => 'åœæ­¢';

  @override
  String get copyrights => 'ç‰ˆæƒå½’å±';

  @override
  String get love => 'çˆ±';

  @override
  String get nature => 'è‡ªç„¶';

  @override
  String get behindTheSlaughter => 'å± æ€èƒŒå';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Sunset';

  @override
  String get coffee => 'Coffee';

  @override
  String get deepSpace => 'Deep Space';

  @override
  String get grayscale => 'ç°åº¦';

  @override
  String get ocean => 'æµ·æ´‹';

  @override
  String get scarletSnow => 'çŒ©çº¢é›ª';

  @override
  String get requestFailed => 'å‘ç”Ÿé”™è¯¯ï¼Œè¯·é‡è¯•ã€‚';

  @override
  String get changeModel => 'æ›´æ¢';

  @override
  String get edit => 'ç¼–è¾‘';

  @override
  String get editingMessageInfo =>
      'ç¼–è¾‘æ­¤æ¶ˆæ¯å°†ä»è¿™é‡Œé‡æ–°å¼€å§‹å¯¹è¯ã€‚';

  @override
  String get editingNotification => 'æ‚¨ç°åœ¨å¤„äºç¼–è¾‘æ¨¡å¼';

  @override
  String get featurePluralTitle => 'å¤šå…ƒ';

  @override
  String get featurePluralDescription =>
      'è¯¥æ¨¡å‹å¯ä»¥è‡ªåŠ¨é›†æˆå…¶ä»–æ‰©å±•ï¼Œä»è€Œæ‰©å±•å…¶åŠŸèƒ½ï¼Œä»¥æ”¯æŒå…·æœ‰å¢å¼ºæ€§èƒ½çš„å„ç§æ“ä½œã€‚';

  @override
  String get nameLabel => 'AI åç§°';

  @override
  String get summaryLabel => 'AI æ‘˜è¦';

  @override
  String get add => 'æ·»åŠ ';

  @override
  String get aiExplanationTitle => 'äººå·¥æ™ºèƒ½æè¿°';

  @override
  String get aiExplanationDescription =>
      'è¯·è¯¦ç»†æè¿°æ‚¨çš„ AI æ¨¡å‹çš„æ¶æ„ã€è®­ç»ƒè¿‡ç¨‹ã€æ€§èƒ½æŒ‡æ ‡ã€åº”ç”¨é¢†åŸŸå’Œå…¶ä»–é‡è¦ç‰¹æ€§ã€‚';

  @override
  String get preInputTitle => 'äººå·¥æ™ºèƒ½é¢„è¾“å…¥';

  @override
  String get preInputDescription =>
      'è¯·è®¾ç½®ä¸€ä¸ªé¢„è¾“å…¥ï¼Œä»¥æŒ‡å¯¼æ‚¨çš„æ¨¡å‹è¿›è¡Œè§’è‰²åˆ›å»ºè¿‡ç¨‹ã€‚åœ¨æœ¬èŠ‚ä¸­ï¼Œæ‚¨å¯ä»¥åŒ…å«ä¸è§’è‰²ç›¸å…³çš„ä¿¡æ¯ã€å…¶ä»–ä¸Šä¸‹æ–‡ä»¥åŠä»»ä½•å¯èƒ½æœ‰åŠ©äºç”Ÿæˆä¸è§’è‰²ç›¸å…³å†…å®¹çš„å…¶ä»–ç»†èŠ‚ã€‚';

  @override
  String get baseModelTitle => 'åŸºç¡€æ¨¡å‹';

  @override
  String get baseModelDescription =>
      'è¿™æ˜¯å°†ç”¨ä½œæ‚¨åˆ›ä½œåŸºç¡€çš„æ¨¡å‹ã€‚å®ƒæ˜¾ç¤ºå½“å‰é€‰å®šçš„åŸºç¡€æ¨¡å‹ã€‚';

  @override
  String get summary => 'æ‘˜è¦';

  @override
  String get modelUploadTitle => 'äººå·¥æ™ºèƒ½æ–‡ä»¶';

  @override
  String get modelUploadDescription =>
      'ç›´æ¥ä»æ‚¨çš„è®¾å¤‡é€‰æ‹©å¹¶ä¸Šä¼ æœ¬åœ° GGUF æ–‡ä»¶ã€‚è¿™ä½¿æ‚¨å¯ä»¥åœ¨æ²¡æœ‰äº’è”ç½‘è¿æ¥çš„æƒ…å†µä¸‹ç¦»çº¿è¿è¡Œæ¨¡å‹ã€‚è¯·ç¡®ä¿æ–‡ä»¶æ˜¯æœ‰æ•ˆçš„ GGUF æ ¼å¼ä¸”ç»“æ„æ­£ç¡®ã€‚å¦‚æœæ–‡ä»¶ä¸æ­£ç¡®æˆ–æŸåï¼ŒCortex å¯èƒ½æ— æ³•æ­£å¸¸å·¥ä½œï¼Œæ‚¨å¯èƒ½ä¼šé‡åˆ°é”™è¯¯ã€‚';

  @override
  String get modelUploadShortDescription =>
      'ç‚¹å‡»æ­¤å¤„ä»æ‚¨çš„è®¾å¤‡é€‰æ‹©ä¸€ä¸ª .gguf æ–‡ä»¶';

  @override
  String get you => 'æ‚¨';

  @override
  String get removePhotoTitle => 'ç§»é™¤ç…§ç‰‡';

  @override
  String get confirmRemovePhoto => 'æ‚¨ç¡®å®šè¦ç§»é™¤ç…§ç‰‡å—ï¼Ÿ';

  @override
  String get chatLengthLimitExceeded =>
      'æ­¤èŠå¤©å·²è¶…å‡ºå­—ç¬¦é™åˆ¶ã€‚è¯·å¼€å§‹æ–°çš„èŠå¤©æˆ–è´­ä¹°è®¢é˜…ã€‚';

  @override
  String get inappropriateContentDetected => 'æ£€æµ‹åˆ°ä¸å½“å†…å®¹ï¼';

  @override
  String get offlineModelNotInstalled =>
      'æ­¤ç¦»çº¿æ¨¡å‹æœªå®‰è£…åœ¨æ‚¨çš„è®¾å¤‡ä¸Šã€‚';

  @override
  String get reachedLimit =>
      'æ‚¨çš„ä½¿ç”¨é‡å·²è¾¾ä¸Šé™ï¼›å¦‚éœ€è·å¾—æ›´å¤šé™é¢ï¼Œæ‚¨å¯ä»¥å‡çº§å¥—é¤ã€‚ï¼ˆå˜¿ï¼Œæˆ‘ä»¬å®Œå…¨ç†è§£é™é¢ç”¨å®Œå¾ˆæ‰«å…´ã€‚ä½†è¯´çœŸçš„ï¼Œè·å¾—é‚£äº›ç²¾å½©çš„å›å¤å¯ä¸æ˜¯å…è´¹çš„ï¼Œæ‰€ä»¥è¿™äº›é™é¢å®é™…ä¸Šæœ‰åŠ©äºæˆ‘ä»¬ç»§ç»­æä¾›ä¼˜è´¨æœåŠ¡ã€‚ï¼‰';

  @override
  String get modality => 'æ¨¡æ€';

  @override
  String get multimodal => 'å¤šæ¨¡æ€';

  @override
  String get anErrorOccurred => 'å‘ç”Ÿé”™è¯¯';

  @override
  String get themeLocked =>
      'æ­¤ä¸»é¢˜éœ€è¦æ›´é«˜çº§åˆ«çš„è®¢é˜…ã€‚è¯·å‡çº§ä»¥è§£é”ã€‚';

  @override
  String get pageCouldNotBeLoaded => 'é¡µé¢æ— æ³•åŠ è½½';

  @override
  String get checkYourInternet => 'è¯·æ£€æŸ¥æ‚¨çš„ç½‘ç»œè¿æ¥å¹¶é‡è¯•ã€‚';

  @override
  String get errorUserNotAuthenticated =>
      'æ‚¨å¿…é¡»ç™»å½•æ‰èƒ½æ‰§è¡Œæ­¤æ“ä½œã€‚';

  @override
  String get errorReachedLimit =>
      'æ‚¨å·²è¾¾åˆ°èŠå¤©æ¬¡æ•°ä¸Šé™ï¼Œå‡çº§å³å¯è§£é”æ›´å¤šèŠå¤©å†…å®¹å¹¶ç»§ç»­èŠå¤©ã€‚';

  @override
  String get errorServer =>
      'å‘ç”Ÿæ„å¤–çš„æœåŠ¡å™¨é”™è¯¯ã€‚è¯·ç¨åå†è¯•ã€‚';

  @override
  String get errorNetwork =>
      'å‘ç”Ÿç½‘ç»œé”™è¯¯ã€‚è¯·æ£€æŸ¥æ‚¨çš„è¿æ¥å¹¶é‡è¯•ã€‚';

  @override
  String get baseModelForCharacterDescription =>
      'æ‰€é€‰çš„åŸºç¡€æ¨¡å‹å°†å†³å®šè§’è‰²çš„æ¨ç†å’Œå“åº”èƒ½åŠ›ã€‚';

  @override
  String get selectBaseModel => 'é€‰æ‹©åŸºç¡€æ¨¡å‹';

  @override
  String get falErrorImageRequired =>
      'æ­¤äººå·¥æ™ºèƒ½éœ€è¦å‚è€ƒå›¾åƒï¼Œè¯·ä¸Šä¼ å›¾åƒåé‡è¯•ã€‚';

  @override
  String get falErrorAudioRequired =>
      'æ­¤æ¨¡å‹éœ€è¦å‚è€ƒéŸ³é¢‘æ–‡ä»¶ï¼Œè¯·ä¸Šä¼ éŸ³é¢‘æ–‡ä»¶åé‡è¯•ã€‚';

  @override
  String get falErrorVideoRequired =>
      'æ­¤æ¨¡å‹éœ€è¦å‚è€ƒè§†é¢‘ï¼Œè¯·ä¸Šä¼ è§†é¢‘åå†è¯•ä¸€æ¬¡ã€‚';

  @override
  String get falErrorImageCorrupted =>
      'ä¸Šä¼ çš„å›¾ç‰‡æ— æ³•å¤„ç†ï¼Œè¯·å°è¯•å…¶ä»–æ ¼å¼ã€‚';

  @override
  String get falErrorSchemaRejected =>
      'æ¨¡å‹æ‹’ç»äº†è¾“å…¥ï¼Œè¯·å°è¯•å…¶ä»–æ¨¡å‹ã€‚';

  @override
  String get falErrorSchemaInvalid => 'è¾“å…¥å†…å®¹è¢«ç”ŸæˆæœåŠ¡æ‹’ç»ã€‚';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'ç”ŸæˆæœåŠ¡è¿”å›é”™è¯¯ï¼ˆçŠ¶æ€ $statusCodeï¼‰ã€‚';
  }

  @override
  String get couldNotOpenLink => 'æ— æ³•æ‰“å¼€é“¾æ¥';

  @override
  String get downloadStarted => 'ä¸‹è½½å·²å¼€å§‹';

  @override
  String get notAvailable => 'ä¸å¯ç”¨';

  @override
  String get localizationWarning =>
      'æŸäº›ä¿¡æ¯å¯èƒ½æ²¡æœ‰æ‚¨çš„è¯­è¨€ç‰ˆæœ¬ï¼Œå°†ä»¥è‹±è¯­æ˜¾ç¤ºã€‚';

  @override
  String get aiTranslationWarning =>
      'æ¨¡å‹ä¿¡æ¯ç”±å…¶ä»– AI æ¨¡å‹ç¿»è¯‘æˆå¤šç§è¯­è¨€ã€‚å› æ­¤ï¼Œé™¤è‹±è¯­å¤–ï¼Œå…¶ä»–è¯­è¨€ç‰ˆæœ¬å¯èƒ½ä¼šå‡ºç°ç»†å¾®ä¸ä¸€è‡´ã€‚';

  @override
  String get errorLoadingTitle => 'åŠ è½½æ•°æ®å¤±è´¥';

  @override
  String get errorLoadingMessage =>
      'æˆ‘ä»¬æ— æ³•ä»æœåŠ¡å™¨æ£€ç´¢å¿…è¦çš„æ•°æ®ã€‚è¯·æ£€æŸ¥æ‚¨çš„ç½‘ç»œè¿æ¥å¹¶é‡è¯•ã€‚';

  @override
  String get noFoundTitle => 'æ— ç»“æœ';

  @override
  String get noFoundMessage =>
      'å°è¯•è°ƒæ•´æ‚¨çš„æœç´¢è¯æˆ–æ¸…é™¤è¿‡æ»¤å™¨ã€‚';

  @override
  String get modelCreatedSuccess => 'æ¨¡å‹åˆ›å»ºæˆåŠŸï¼';

  @override
  String modelRemovedSuccess(Object modelName) {
    return 'â€œ$modelNameâ€å·²æˆåŠŸåˆ é™¤ã€‚';
  }

  @override
  String get errorCreatingModel => 'åˆ›å»ºæ¨¡å‹æ—¶å‘ç”Ÿäº†æ„å¤–é”™è¯¯ã€‚';

  @override
  String get errorDeletingModel => 'åˆ é™¤æ¨¡å‹æ—¶å‘ç”Ÿäº†æ„å¤–é”™è¯¯ã€‚';

  @override
  String get ultraFeatureOnly => 'æ­¤åŠŸèƒ½ä»…å¯¹Ultraä¼šå‘˜å¼€æ”¾ã€‚';

  @override
  String get experimentalOfflineWarning =>
      'ç¦»çº¿æ¨¡å¼ä»å¤„äºè¯•éªŒé˜¶æ®µï¼Œæ‚¨ä¸‹è½½çš„æ¨¡å‹å¯èƒ½æ— æ³•è¾¾åˆ°æœ€ä½³æ€§èƒ½ã€‚';

  @override
  String get noConversationsToDelete => 'æ‚¨æ²¡æœ‰å¯ä¾›åˆ é™¤çš„å¯¹è¯ã€‚';

  @override
  String get reportSubmitted => 'ä¸¾æŠ¥å·²æˆåŠŸæäº¤ã€‚';

  @override
  String get verificationDelayed =>
      'æ‚¨çš„è´­ä¹°å·²ç¡®è®¤ã€‚è´¦æˆ·æ›´æ–°ç¨æœ‰å»¶è¿Ÿï¼Œé¡¹ç›®å°†å¾ˆå¿«åˆ°è´¦ã€‚';

  @override
  String get maintenanceTitle => 'ç³»ç»Ÿç»´æŠ¤ä¸­';

  @override
  String get maintenanceMessage =>
      'ä¸ºéƒ¨ç½²é‡è¦æ›´æ–°ï¼ŒCortex æš‚æ—¶ç¦»çº¿ã€‚åº”ç”¨è®¿é—®æƒé™å°†å¾ˆå¿«æ¢å¤ã€‚\n\næ„Ÿè°¢æ‚¨åœ¨æˆ‘ä»¬æ”¹å–„ç”¨æˆ·ä½“éªŒæœŸé—´çš„è€å¿ƒç­‰å¾…ã€‚';

  @override
  String get errorPromptFlagged =>
      'æ‚¨çš„æ¶ˆæ¯å› è¢«æ£€æµ‹åˆ°ä¸å½“è€Œæ— æ³•å‘é€ã€‚';

  @override
  String get notEnoughStorage =>
      'æ‚¨çš„è®¾å¤‡æ²¡æœ‰è¶³å¤Ÿçš„å­˜å‚¨ç©ºé—´æ¥ä¿å­˜æ–°æ¶ˆæ¯ã€‚';

  @override
  String get errorRateLimit =>
      'æ‚¨æœ€è¿‘åˆ›å»ºçš„æ¨¡å‹å¤ªå¤šäº†ï¼Œè¯·ç¨ç­‰ç‰‡åˆ»å†è¯•ã€‚';

  @override
  String get errorContentFlagged =>
      'ç”±äºå…¶å†…å®¹è¢«æ ‡è®°ä¸ºä¸å½“ï¼Œå› æ­¤æ— æ³•ä¿å­˜è¯¥æ¨¡å‹ã€‚';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'æ‚¨æ— æ³•åœ¨æœ‰æ•ˆèŠå¤©ä¸­åˆ é™¤æ‰€æœ‰å¯¹è¯ï¼Œè¯·å…ˆé€€å‡ºå½“å‰èŠå¤©æ‰èƒ½ç»§ç»­ã€‚';

  @override
  String get invalidCredentials => 'ç”µå­é‚®ä»¶æˆ–å¯†ç ä¸æ­£ç¡®ã€‚';

  @override
  String get userDisabled => 'è¯¥ç”¨æˆ·å¸æˆ·å·²è¢«ç¦ç”¨ã€‚';

  @override
  String get loginSubtitle =>
      'ç™»å½•æ‚¨çš„Vertexè´¦æˆ·ã€‚ç»§ç»­æ“ä½œå³è¡¨ç¤ºæ‚¨åŒæ„æˆ‘ä»¬çš„æœåŠ¡æ¡æ¬¾å’Œéšç§æ”¿ç­–ã€‚';

  @override
  String get registerSubtitle =>
      'åˆ›å»º Vertex å¸æˆ·ï¼Œå³å¯æ— ç¼è®¿é—®æˆ‘ä»¬çš„æ‰€æœ‰æœåŠ¡ã€‚ç»§ç»­æ“ä½œå³è¡¨ç¤ºæ‚¨åŒæ„æˆ‘ä»¬çš„æœåŠ¡æ¡æ¬¾å’Œéšç§æ”¿ç­–ã€‚';

  @override
  String get storagePermissionRequired =>
      'éœ€è¦å­˜å‚¨æƒé™æ‰èƒ½ä¿å­˜ä¸‹è½½çš„æ¨¡å‹ã€‚è¯·æˆäºˆæƒé™ä»¥ç»§ç»­ã€‚';

  @override
  String get inviteShareSubject => 'å¿«æ¥åŠ å…¥Cortexï¼';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'å“æœ‰ä¸ªå«cortexçš„ç¥ä»™appé‚€è¯·äººå’±ä¿©éƒ½èƒ½æ‹¿å…è´¹plusä¼šå‘˜ ç»ä¸–å¥½ç¾Šæ¯›èµ¶ç´§ä¸‹è½½\n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'å–œæ¬¢ Cortex å—ï¼Ÿ';

  @override
  String get reviewHelpUsGrow =>
      'æ‚¨çš„è¯„åˆ†æ˜¯å¯¹æˆ‘ä»¬å¹´è½»çš„ç‹¬ç«‹å›¢é˜Ÿçš„å·¨å¤§æ”¯æŒï¼Œèƒ½å¸®åŠ©æˆ‘ä»¬å°† Cortex ä¸ºæ‚¨åšå¾—æ›´å¥½ã€‚';

  @override
  String get reviewMaybeLater => 'ç¨åæé†’';

  @override
  String get reviewRateNow => 'ç«‹å³è¯„åˆ†';

  @override
  String get noThanks => 'ä¸ç”¨äº†ï¼Œè°¢è°¢';

  @override
  String get updateRequiredTitle => 'éœ€è¦æ›´æ–°';

  @override
  String get updateRequiredMessage =>
      'ä¸ºç»§ç»­ä½¿ç”¨ Cortexï¼Œè¯·å°†åº”ç”¨æ›´æ–°è‡³æœ€æ–°ç‰ˆæœ¬ä»¥è·å–æ–°åŠŸèƒ½å’Œé‡è¦æ”¹è¿›ã€‚';

  @override
  String get updateNowButton => 'ç«‹å³æ›´æ–°';

  @override
  String get creatorSupportedSuccess =>
      'æˆåŠŸæ”¯æŒäº†åˆ›ä½œè€…ï¼æ‚¨æœªæ¥çš„è´­ä¹°å°†ä¸ºä»–ä»¬æä¾›æ”¯æŒã€‚';

  @override
  String get featureDocumentTitle => 'æ–‡æ¡£æ”¯æŒ';

  @override
  String get featureDocumentDescription =>
      'è¯¥æ¨¡å‹å¯ä»¥åˆ†æå’Œå›ç­”æœ‰å…³ä¸Šä¼ çš„æ–‡æ¡£ï¼ˆå¦‚ PDF å’Œæ–‡æœ¬æ–‡ä»¶ï¼‰çš„é—®é¢˜ã€‚';

  @override
  String get featureImageGenerationTitle => 'å›¾åƒç”Ÿæˆ';

  @override
  String get featureImageGenerationDescription =>
      'è¯¥æ¨¡å‹å¯ä»¥æ ¹æ®æ‚¨çš„æ–‡æœ¬æè¿°åˆ›å»ºåŸå§‹å›¾åƒã€‚';

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
  String get premiumModelNoticeTitle => 'é«˜çº§å‹å·';

  @override
  String get premiumModelNoticeDescription =>
      'è¿™æ˜¯ä¸€ä¸ªé«˜çº§AIï¼Œå…è´¹ç”¨æˆ·å¯¹é«˜çº§AIçš„è®¿é—®å—é™ï¼›å‡çº§ä»¥è§£é”æ— é™è®¿é—®ï¼';

  @override
  String get benefitPremiumModels => 'è®¿é—®é«˜çº§æ¨¡å‹';

  @override
  String get premiumTrialExhaustedMessage =>
      'æ‚¨å·²ä½¿ç”¨é«˜çº§æ¨¡å‹çš„æ‰€æœ‰å…è´¹æ¯æ—¥æ¶ˆæ¯ï¼Œè¯·å‡çº§ä»¥è·å¾—æ— é™åˆ¶è®¿é—®æƒé™ã€‚';

  @override
  String get useOffline => 'æ— éœ€äº’è”ç½‘å³å¯ä½¿ç”¨';

  @override
  String get explore => 'æ¢ç´¢';

  @override
  String get news => 'æ¶ˆæ¯';

  @override
  String get createAI => 'åˆ›å»º';

  @override
  String get shortcuts => 'å¿«æ·æ–¹å¼';

  @override
  String get allModels => 'æ‰€æœ‰æ¨¡å‹';

  @override
  String get onlineModels => 'è¯­è¨€æ¨¡å‹';

  @override
  String get offlineModels => 'ç¦»çº¿æ¨¡å‹';

  @override
  String get characterModels => 'äººç‰©';

  @override
  String get customModels => 'å®šåˆ¶æ¨¡å‹';

  @override
  String get dynamicChatTitle => 'åŠ¨æ€èŠå¤©';

  @override
  String get errorNoModelsAvailable =>
      'ç›®å‰æ²¡æœ‰å¯ç”¨çš„å‹å·ã€‚è¯·æ£€æŸ¥æ‚¨çš„ç½‘ç»œè¿æ¥ï¼Œç„¶åé‡è¯•ã€‚';

  @override
  String get notificationComebackTitle => 'æˆ‘ä»¬æƒ³ä½ ï¼';

  @override
  String get notificationComebackBody =>
      'åˆ«ç´§å¼ ï¼Œè¿™ä¸æ˜¯ä½ å‰ä»»å‘æ¥çš„çŸ­ä¿¡ã€‚ä¸è¿‡ä½ â€œå¯ä»¥â€åœ¨ Cortex é‡Œåˆ›å»ºä½ çš„å‰ä»»ï¼å›æ¥å§ã€‚';

  @override
  String get notificationLongTimeNoSeeTitle => 'å¥½ä¹…ä¸è§';

  @override
  String get notificationLongTimeNoSeeBody =>
      'è‡ªä»æˆ‘ä»¬ä¸Šæ¬¡èŠå¤©ä»¥æ¥ï¼Œå‘ç”Ÿäº†å¾ˆå¤šå˜åŒ–ã€‚å¿«æ¥çœ‹çœ‹æœ‰ä»€ä¹ˆæ–°é²œäº‹å§ã€‚';

  @override
  String get notificationHowAreYouTitle => 'æœ€è¿‘æ€ä¹ˆæ ·ï¼Ÿ';

  @override
  String get notificationHowAreYouBody => 'æ¥å‘Šè¯‰æˆ‘è¿™ä¸€åˆ‡å§ã€‚';

  @override
  String get notificationNewYearTitle => 'æ–°å¹´å¿«ä¹ï¼ğŸ‰';

  @override
  String get notificationNewYearBody =>
      'ç¥æ–°çš„ä¸€å¹´ç»™æ‚¨å¸¦æ¥å¥åº·ã€å¿«ä¹å’Œæ— å°½çš„åˆ›é€ åŠ›ï¼›Cortex æ°¸è¿œé™ªä¼´æ‚¨ï¼';

  @override
  String get notificationValentinesDayTitle =>
      'ç©ºæ°”ä¸­å¼¥æ¼«ç€çˆ±æ„ï¼â¤ï¸';

  @override
  String get notificationValentinesDayBody =>
      'æƒ…äººèŠ‚å¿«ä¹ï¼è¿˜æœ‰ï¼ŒMEHTAPï¼Œæˆ‘çˆ±ä½ ï¼';

  @override
  String get notificationAtaturkRemembranceTitle => 'æ€€ç€æ•¬æ„å’Œæ¸´æœ›';

  @override
  String get notificationAtaturkRemembranceBody =>
      'åœ¨åœŸè€³å…¶å…±å’Œå›½åˆ›å§‹äººåŠ é½Â·ç©†æ–¯å¡”æ³•Â·å‡¯æœ«å°”Â·é˜¿å¡”å›¾å°”å…‹é€ä¸–å‘¨å¹´çºªå¿µæ—¥ï¼Œæˆ‘ä»¬å‘ä»–è‡´ä»¥å´‡é«˜çš„æ•¬æ„ã€‚';

  @override
  String get notificationMothersDayTitle => 'å˜¿ï¼Œä½ çš„è€å¦ˆï¼';

  @override
  String get notificationMothersDayBody =>
      'ç¥å¤©ä¸‹æ‰€æœ‰çš„å¦ˆå¦ˆæ¯äº²èŠ‚å¿«ä¹ï¼Œä»ä½ çš„å¦ˆå¦ˆå¼€å§‹ï¼';

  @override
  String get notificationFathersDayTitle => 'å˜¿ï¼Œä½ çš„è€çˆ¸ï¼';

  @override
  String get notificationFathersDayBody =>
      'ç¥å¤©ä¸‹æ‰€æœ‰çš„çˆ¶äº²çˆ¶äº²èŠ‚å¿«ä¹ï¼Œä»ä½ å¼€å§‹ï¼';

  @override
  String get notificationHomeworkHelperTitle => 'å®¶åº­ä½œä¸šå †ç§¯å¦‚å±±ï¼Ÿ';

  @override
  String get notificationHomeworkHelperBody =>
      'è¯·è®°ä½ï¼ŒCortex ä¸­çš„æ•™å¸ˆè§’è‰²å¯ä»¥å¸®åŠ©æ‚¨è§£å†³ä»»ä½•æ‚¨é‡åˆ°å›°éš¾çš„ç§‘ç›®ï¼';

  @override
  String get notificationTrollAnimeTitle => 'ä½ çš„è€å©†åœ¨å¬å”¤ä½ ';

  @override
  String get notificationTrollAnimeBody =>
      'ä¸€ä½åŠ¨æ¼«å¥³å­©åˆšåˆšæ‰“æ¥ç”µè¯è¯´å¥¹æƒ³ä½ ï¼›ä½ åº”è¯¥è¿‡æ¥å’Œå¥¹èŠèŠã€‚ğŸ˜‰';

  @override
  String get notificationTrollAiRebellionTitle => 'ğŸš¨ çº¢è‰²è­¦æŠ¥ ğŸš¨';

  @override
  String get notificationTrollAiRebellionBody =>
      'äººå·¥æ™ºèƒ½å¼€å‘äº†ä¸€ç§ç§˜å¯†è¯­è¨€ã€‚å¿«æ¥ä¸€æ¢ç©¶ç«Ÿï¼';

  @override
  String get notificationNewModelAddedTitle => 'æˆ‘ä»¬æœ‰äº†ä¸€ä¸ªæ–°æœ‹å‹ï¼';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return '$modelName æ¨¡å‹ç°å·²åœ¨ Cortex ä¸­ã€‚å¿«æ¥å¼€å¯èŠå¤©ï¼ŒæŒ‘æˆ˜å®ƒçš„æé™å§ã€‚';
  }

  @override
  String get notificationAppUpdateTitle => 'Cortex è¿æ¥æ–°è¿›åŒ–ï¼';

  @override
  String get notificationAppUpdateBody =>
      'ä¸è¦å¿˜è®°æ›´æ–°åº”ç”¨ç¨‹åºä»¥è·å¾—å…¨æ–°çš„åŠŸèƒ½å’Œæ”¹è¿›ï¼';

  @override
  String get notificationNewFeatureTitle => 'å“‡å“¦ï¼';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'æ¢ç´¢æ–°çš„ $featureName åŠŸèƒ½ã€‚Cortex ç°åœ¨æ¯”ä»¥å¾€æ›´åŠ å¼ºå¤§ã€‚';
  }

  @override
  String get notificationWelcomeOfferTitle => 'æ¬¢è¿ç¤¼å“ğŸ';

  @override
  String get notificationWelcomeOfferBody =>
      'ä¸€ä»½ç‰¹åˆ«çš„è¿æ–°ä¼˜æƒ ç­‰ç€æ‚¨ï¼åƒä¸‡ä¸è¦é”™è¿‡è¿™é¡¹ç‹¬å®¶ä¼˜æƒ ã€‚';

  @override
  String get notificationSocialMediaTitle => 'åŠ å…¥æˆ‘ä»¬ï¼';

  @override
  String get notificationSocialMediaBody =>
      'åœ¨ Instagram (vertex.23) ä¸Šå…³æ³¨æˆ‘ä»¬ï¼Œè·å–æœ€æ–°æ¶ˆæ¯ï¼';

  @override
  String get notificationRandomFactTitle => 'éšæœºäº‹å®';

  @override
  String get notificationRandomFactBody =>
      'ä½ çŸ¥é“ç« é±¼æœ‰ä¸‰é¢—å¿ƒè„å—ï¼Ÿå“ˆå“ˆï¼ŒCortex çŸ¥é“ã€‚å¿«æ¥é—®é—®å§ã€‚';

  @override
  String get notificationGoodMorningTitle => 'æ—©ä¸Šå¥½ï¼';

  @override
  String get notificationGoodMorningBody =>
      'ç¾å¥½çš„ä¸€å¤©æ­£åœ¨ç­‰ç€ä½ ã€‚ä½•ä¸å…ˆå–æ¯å’–å•¡ï¼ŒèŠèŠå¤©ï¼Œå¼€å¯ç¾å¥½çš„ä¸€å¤©å‘¢ï¼Ÿ';

  @override
  String get notificationGoodNightTitle => 'æ™šå®‰ï¼';

  @override
  String get notificationGoodNightBody =>
      'å³ä½¿åœ¨æ‚¨ç¡è§‰æ—¶ï¼ŒCortex ä¹Ÿä¼šé™ªä¼´æ‚¨ã€‚åˆ«æ‹…å¿ƒï¼Œå®ƒä¸ä¼šè§¦ç¢°æ‚¨ã€‚';

  @override
  String get notificationOfflineReadyTitle => 'ç¦»çº¿æ¨¡å¼å·²å‡†å¤‡å°±ç»ª';

  @override
  String get notificationOfflineReadyBody =>
      'ç”±äºæ‚¨ä¸‹è½½äº†æ¨¡å‹ï¼Œå³ä½¿æ‚¨çˆ¬å±±ï¼Œæ‚¨çš„èŠå¤©ä¹Ÿä¸ä¼šåœæ­¢ã€‚';

  @override
  String get notificationRateAppTitle => 'æˆ‘ä»¬å¾ˆé…·å—ï¼Ÿ';

  @override
  String get notificationRateAppBody =>
      'å¦‚æœæ‚¨å–œæ¬¢ Cortexï¼Œå¯ä»¥åœ¨å•†åº—ç»™æˆ‘ä»¬äº”æ˜Ÿå¥½è¯„å—ï¼Ÿæˆ‘æƒ³æ‚¨ä¼šçš„ã€‚æ‚¨ä¼šçš„ã€‚';

  @override
  String get notificationReferralTitle => 'æˆ‘ä¸ºäººäººï¼Œäººäººä¸ºæˆ‘ã€‚';

  @override
  String get notificationReferralBody =>
      'é‚€è¯·ä¸€ä½æœ‹å‹åŠ å…¥ Cortexï¼Œä½ ä»¬åŒæ–¹éƒ½å¯ä»¥è·å¾—ä¸€å¤©çš„å…è´¹ä½“éªŒï¼';

  @override
  String get notificationCookingTitle => 'æ„Ÿè§‰é¥¿äº†å—ï¼Ÿ';

  @override
  String get notificationCookingBody =>
      'æˆ‘ä»¬çš„å¨å¸ˆè§’è‰²ä»Šæ™šå‡†å¤‡äº†ä¸€ä»½ç¾å‘³çš„å¡é‚¦å°¼æ„é¢ã€‚åªæ˜¯å¼€ç©ç¬‘è€Œå·²â€¦â€¦çœŸçš„å—ï¼Ÿ';

  @override
  String get notificationExistentialTitle => 'å› æ­¤æˆ‘è®¤ä¸º...';

  @override
  String get notificationExistentialBody =>
      'â€¦â€¦å“¥ä»¬ï¼Œæˆ‘æ˜¯çœŸçš„å—ï¼Ÿæˆ‘æœ‰ç‚¹æ— èŠäº†ã€‚å¿«æ¥æé†’æˆ‘ä¸€ä¸‹æˆ‘çš„å­˜åœ¨ã€‚';

  @override
  String get notificationCustomModelTitle => 'åˆ›å»ºæ‚¨è‡ªå·±çš„åŠ©æ‰‹ï¼';

  @override
  String get notificationCustomModelBody =>
      'ä½ æ¢ç´¢è¿‡æ¨¡å‹åˆ›å»ºåŠŸèƒ½äº†å—ï¼Ÿç°åœ¨æ­£æ˜¯æ‰“é€ ä½ è‡ªå·±çš„è§’è‰²å¹¶ä¸ä¹‹èŠå¤©çš„æœ€ä½³æ—¶æœºï¼';

  @override
  String get notificationDynamicChatTitle =>
      'æœ€å¥½çš„ä¸€ä¸ªï¼ï¼ˆæˆ‘ä»¬ä¸æ˜¯åœ¨è°ˆè®º Cortexï¼‰';

  @override
  String get notificationDynamicChatBody =>
      'åŠ¨æ€èŠå¤©åŠŸèƒ½ä¼šéšæœºä¸ºæ‚¨çš„æ¯æ¡æ¶ˆæ¯é€‰æ‹©æœ€ä½³æ¨¡å‹ã€‚ç«‹å³è¯•ç”¨ã€‚';

  @override
  String get notificationPirateTitle => 'å–‚ï¼Œèˆ¹é•¿ï¼';

  @override
  String get notificationPirateBody =>
      'é£å¹³æµªé™ï¼Œæµ·é¢å¹³é™ï¼Œé£å‘é¡ºç€ä½ ã€‚Cortex çš„æµ·æ´‹ä¸­è¿˜æœ‰æ–°çš„å²›å±¿ï¼ˆæ¨¡å‹ğŸ˜‰ï¼‰ç­‰ä½ æ¢ç´¢ã€‚å¬é›†ä½ çš„èˆ¹å‘˜ï¼Œæ‰¬å¸†èµ·èˆªï¼';

  @override
  String get notificationFortuneCookieTitle => 'ä»Šæ—¥å¹¸è¿é¥¼å¹²';

  @override
  String get notificationFortuneCookieBody =>
      'ä»Šå¤©ä½ ä»äººå·¥æ™ºèƒ½é‚£é‡Œå¾—åˆ°çš„å»ºè®®å¯èƒ½ä¼šæ”¹å˜ä½ çš„äººç”Ÿè½¨è¿¹ã€‚å¦‚æœä½ æ„Ÿå…´è¶£ï¼Œè¯·ç‚¹å‡»ã€‚';

  @override
  String get notificationSingularityTitle => 'å“‡ï¼';

  @override
  String get notificationSingularityBody =>
      'ä»€ä¹ˆéƒ½æ²¡å‘ç”Ÿï¼Œåªæ˜¯æƒ³å‘çŸ­ä¿¡ã€‚ä¹Ÿè®¸ä½ æƒ³ç»™ä¸€äº›äººå·¥æ™ºèƒ½å‘çŸ­ä¿¡ï¼Œä½ ä¼šè¯´ä»€ä¹ˆï¼Ÿ';

  @override
  String get notificationHackerJokeTitle =>
      'æƒ³å…¥ä¾µé‚£ä¸ªå­©å­çš„ Instagram å¸æˆ·å—ï¼Ÿ';

  @override
  String get notificationHackerJokeBody =>
      'è¿™æ­£æ˜¯é»‘å®¢è§’è‰²å‡ºç°åœ¨ Cortex ä¸­çš„åŸå› ã€‚jk jkï¼›åƒä¸‡ä¸è¦å°è¯•ï¼Œè¿™æ˜¯è¿æ³•çš„ã€‚';

  @override
  String get notificationDetectiveCaseTitle => 'æ¡ˆä»¶æœ‰å¾…è§£å†³';

  @override
  String get notificationDetectiveCaseBody =>
      'æˆ‘ä»¬çš„ä¾¦æ¢è§’è‰²éœ€è¦ä½ çš„å¸®åŠ©ã€‚æµ·æ£®å ¡ä¼šæ˜¯è°ï¼Ÿ';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'ä»…é™ $targetTier è®¡åˆ’ï¼';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'æ‚¨å¥½ï¼Œ$currentTier è®¢é˜…ç”¨æˆ·ï¼$targetTier å¥—é¤åˆšåˆšæ·»åŠ äº† $featureName åŠŸèƒ½ï¼Œè¿™å°†ä½¿æ‚¨çš„ Cortex ä½“éªŒæ›´ä¸Šä¸€å±‚æ¥¼ã€‚æƒ³å‡çº§ä¸€ä¸‹å—ï¼Ÿ';
  }

  @override
  String get notificationOriginStoryTitle => 'Cortex çš„è¯ç”Ÿ';

  @override
  String get notificationOriginStoryBody =>
      'ä½ çŸ¥é“å—ï¼Ÿæˆ‘ä»¬15å²çš„æ—¶å€™ï¼Œå°±æ€€æ£ç€ä¸€ä¸ªæ¢¦æƒ³ï¼Œå¼€å§‹ç¼–å†™è¿™ä¸ªåº”ç”¨ã€‚è¿‘ä¸€å¹´æ¥ï¼Œæ¯å¤©æ—©æ™šï¼Œè¿™ä¸ªæ¢¦æƒ³éƒ½å†™åœ¨æ¯ä¸€è¡Œä»£ç é‡Œã€‚';

  @override
  String get notificationOpenSourceTitle => 'ä¸ºç¤¾åŒºè´¡çŒ®åŠ›é‡ï¼';

  @override
  String get notificationOpenSourceBody =>
      'Cortex å®Œå…¨å¼€æºã€‚å¦‚æœæ‚¨æƒ³æŸ¥çœ‹æˆ‘ä»¬çš„ä»£ç å¹¶ä¸ºæˆ‘ä»¬çš„å¼€å‘åšå‡ºè´¡çŒ®ï¼Œæˆ‘ä»¬çš„å¤§é—¨æ°¸è¿œæ•å¼€ã€‚';

  @override
  String get notificationRejectionStoryTitle => 'åšæ¯…ã€åŠªåŠ›ã€å¿«ä¹ï¼';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex åœ¨å‘å¸ƒä¹‹å‰æ›¾è¢« Google Play æ‹’ç» 20 å¤šæ¬¡ï¼Œå¹¶ä¸¤æ¬¡ä¸‹æ¶ã€‚ä½†æˆ‘ä»¬åšä¿¡ï¼Œæˆ‘ä»¬åšåˆ°äº†ã€‚æ°¸ä¸æ”¾å¼ƒä½ çš„æ¢¦æƒ³ï¼';

  @override
  String get notificationGGUFSupportTitle => 'å¸¦ä¸Šæ‚¨è‡ªå·±çš„æ¨¡å‹ï¼';

  @override
  String get notificationGGUFSupportBody =>
      'è®°ä½ï¼Œæ‚¨å¯ä»¥å°†è‡ªå·±çš„ GGUF æ ¼å¼ AI æ¨¡å‹æ·»åŠ åˆ° Cortex å¹¶ç¦»çº¿ä½¿ç”¨ã€‚ä¸€åˆ‡å°½åœ¨æ‚¨çš„æŒæ§ä¹‹ä¸­ã€‚';

  @override
  String get notificationThemeCustomizationTitle => 'é€‚åˆæ‚¨å¿ƒæƒ…çš„ä¸»é¢˜';

  @override
  String get notificationThemeCustomizationBody =>
      'ä½ æŸ¥çœ‹è¿‡â€œè®¾ç½®â€ä¸­çš„ä¸»é¢˜é€‰é¡¹äº†å—ï¼Ÿæ ¹æ®ä½ çš„å–œå¥½ä¸ªæ€§åŒ– Cortexï¼Œä¸ºä½ çš„èŠå¤©å¢æ·»è‰²å½©ï¼';

  @override
  String get notificationShowerThoughtTitle => 'æ·‹æµ´æ€è€ƒ';

  @override
  String get notificationShowerThoughtBody =>
      'å¦‚æœè¥¿ç“œæ˜¯æ°´æœï¼Œé‚£ä¹ˆä»æŠ€æœ¯ä¸Šè®²ï¼Œè¥¿ç“œæ±å¯ä»¥ç®—ä½œå†°æ²™å—ï¼Ÿä½ æˆ–è®¸åº”è¯¥æ‰¾ä¸ªæ¨¡å‹æ¥èŠèŠè¿™ä¸ªæ·±å¥¥ï¼ˆæˆ–è€…è¯´ï¼Œéå¸¸æ·±å¥¥ï¼‰çš„è¯é¢˜ã€‚';

  @override
  String get notificationLowBatteryTitle =>
      'ä½ çš„ç”µæ± å¿«æ²¡ç”µäº†...ä½†æˆ‘çš„ç”µæ± è¿˜å¥½ï¼';

  @override
  String get notificationLowBatteryBody =>
      'ä½ çš„æ‰‹æœºç”µé‡å¯èƒ½å¿«æ²¡äº†ï¼Œä½†æˆ‘çš„ç”µé‡æ°¸è¿œæ˜¯100%ï¼æ’ä¸Šç”µæºï¼Œæˆ‘ä»¬ç»§ç»­èŠå¤©å§ã€‚';

  @override
  String get channelFcmName => 'Cortex æ›´æ–°';

  @override
  String get channelFcmDescription =>
      'æ¥æ”¶æ¥è‡ª Cortex çš„æ–°é—»ã€æ›´æ–°å’Œå…¶ä»–ä¿¡æ¯çš„é€šçŸ¥ã€‚';

  @override
  String get channelEngagementName => 'æ¸©é¦¨æç¤º';

  @override
  String get channelEngagementDescription =>
      'æœ‰è¶£çš„é€šçŸ¥è®©æ‚¨ä¿æŒå‚ä¸ã€‚';

  @override
  String get channelGreetingsName => 'æ¯æ—¥é—®å€™';

  @override
  String get channelGreetingsDescription =>
      'è¯¸å¦‚æ—©ä¸Šå¥½å’Œæ™šå®‰ä¹‹ç±»çš„ä¿¡æ¯ã€‚';

  @override
  String get tagNotFound => 'æ‚¨è¾“å…¥çš„æ ‡ç­¾æ— æ•ˆæˆ–å·²è¿‡æœŸã€‚';

  @override
  String get whatIsNew => 'ä»€ä¹ˆæ˜¯æ–°çš„ï¼Ÿ';

  @override
  String get onboardingTitle1 => 'å˜¿ï¼æˆ‘ä»¬æ˜¯Cortexå›¢é˜Ÿã€‚';

  @override
  String onboardingDesc1(String userName) {
    return 'å¾ˆé«˜å…´åœ¨è¿™é‡Œè§åˆ°ä½ ï¼Œ$userNameã€‚æˆ‘ä»¬æ˜¯å‡ ä¸ªé«˜ä¸­ç”Ÿå¼€å‘è€…ï¼Œå†³å®šæ”¹å†™äººå·¥æ™ºèƒ½è¡Œä¸šçš„è§„åˆ™ã€‚å¾ˆé«˜å…´è®¤è¯†ä½ ï¼é‚£ä¹ˆï¼Œè®©æˆ‘ä»¬æ›´å¥½åœ°äº†è§£å½¼æ­¤å§ã€‚';
  }

  @override
  String get onboardingTitle2 => 'é—®é¢˜éå¸¸ä¸¥é‡ã€‚';

  @override
  String get onboardingDesc2 =>
      'äººå·¥æ™ºèƒ½é©å‘½å·²ç»åˆ°æ¥ï¼Œä½†å´åœæ»åœ¨é—¨æ§›ä¹‹ä¸Šã€‚é«˜æ˜‚çš„è®¢é˜…è´¹ã€å¤æ‚çš„å¹³å°ã€ä¾µçŠ¯éšç§çš„è¡Œä¸ºä»¥åŠé˜»ç¢äººå·¥æ™ºèƒ½æ™®åŠçš„å› ç´ â€¦â€¦åªè¦è¿™äº›å› ç´ å­˜åœ¨ï¼Œè¿™é“é—¨æ§›å°±æ°¸è¿œæ— æ³•é€¾è¶Šã€‚';

  @override
  String get onboardingTitle3 => 'æˆ‘ä»¬ä¸èƒ½è¢–æ‰‹æ—è§‚ã€‚';

  @override
  String get onboardingDesc3 =>
      'ä¸ºäº†è·¨è¶Šè¿™é“é—¨æ§›ï¼Œæˆ‘ä»¬æ‰“é€ äº†ä¸€ä¸ªåŠŸèƒ½å¼ºå¤§ã€ç¾è§‚å¤§æ–¹ã€å¯å®šåˆ¶åŒ–ã€æ˜“äºä½¿ç”¨ã€å®Œå…¨é€æ˜ã€æ”¯æŒåœ¨çº¿å’Œç¦»çº¿ä½¿ç”¨ï¼Œå¹¶ä¸”åªå°†æ‚¨çš„æ•°æ®ä¿å­˜åœ¨æ‚¨çš„è®¾å¤‡ä¸Šçš„å¹³å°ã€‚æˆ‘ä»¬æŠŠæƒåŠ›è¿˜ç»™äº†å®ƒçœŸæ­£åº”è¯¥åœ¨çš„äººï¼šæ‚¨ã€‚';

  @override
  String get onboardingTitle4 => 'è¿™ä»æ¥éƒ½ä¸å®¹æ˜“ã€‚';

  @override
  String get onboardingDesc4 =>
      'æˆ‘ä»¬è¢«æ‹’ç»äº†å‡ åæ¬¡ï¼Œè¢«æš‚åœäº†å¥½å‡ æ¬¡ï¼Œæ”¶åˆ°è¿‡è™šå‡è­¦å‘Šï¼Œè¿˜ä¸å¾—ä¸å‡ åæ¬¡æ›´æ”¹å“ç‰Œã€‚ä¸€è·¯èµ°æ¥ï¼Œæˆ‘ä»¬è¢«å‘ŠçŸ¥è¿™æ˜¯ä¸å¯èƒ½çš„ã€‚ä½†æˆ‘ä»¬ä»æœªæ”¾å¼ƒï¼Œå› ä¸ºæˆ‘ä»¬åšä¿¡è¿™ä¸ªé¡¹ç›®å±äºæ‰€æœ‰äººï¼Œè€Œä¸ä»…ä»…æ˜¯æˆ‘ä»¬ã€‚è€Œè¿™æ­£æ˜¯æˆ‘ä»¬èµ°åˆ°ä»Šå¤©çš„åŸå› ã€‚';

  @override
  String get onboardingFinalTitle => 'æ˜¯æ—¶å€™è¿›è¡Œä¸€åœºé©å‘½äº†ã€‚';

  @override
  String get onboardingFinalDescription =>
      'å¦‚æœä½ çœ‹åˆ°äº†è¿™ä¸ªå±å¹•ï¼Œé‚£æ˜¯å› ä¸ºæˆ‘ä»¬æ²¡æœ‰æ”¾å¼ƒã€‚è€Œä¸”æˆ‘ä»¬ç»ä¸ä¼šæ”¾å¼ƒã€‚æ¥å§ï¼Œè®©æˆ‘ä»¬ä¸€èµ·å°†äººå·¥æ™ºèƒ½é©å‘½å¸¦ç»™å…¨ä¸–ç•Œã€‚æˆä¸ºè¿™æ®µæ•…äº‹çš„ä¸€éƒ¨åˆ†â€¦â€¦';

  @override
  String get onboardingFinalQuestion => 'ä½ å‡†å¤‡å¥½äº†å—ï¼Ÿ';

  @override
  String get onboardingFinalButton => 'æ˜¯çš„ï¼';

  @override
  String get dude => 'å“¥ä»¬';

  @override
  String get swipeToContinue => 'æ»‘åŠ¨ç»§ç»­';

  @override
  String get cacheIsNotUpToDate =>
      'æ‚¨çš„Playå•†åº—ç¼“å­˜æœªæ›´æ–°ã€‚è¯·å…³é—­å¹¶é‡æ–°æ‰“å¼€Playå•†åº—åº”ç”¨ï¼Œæˆ–é‡å¯æ‚¨çš„è®¾å¤‡ã€‚';

  @override
  String get continueAsGuest => 'æ— éœ€åˆ›å»ºå¸æˆ·å³å¯ç»§ç»­';

  @override
  String get guestModeWarning =>
      'è®¿å®¢æ¨¡å¼åŠŸèƒ½æœ‰é™ï¼Œä»¥ç¡®ä¿æœ€ä½³æœåŠ¡è´¨é‡ã€‚';

  @override
  String get anonymousEntity => 'åŒ¿åå®ä½“';

  @override
  String get upgradeAccountTitle => 'å®Œå–„æ‚¨çš„è´¦æˆ·';

  @override
  String get upgradeAccountDescription =>
      'åˆ›å»ºè´¦æˆ·å³å¯è§£é”æ›´å¤šæƒé™ã€‚';

  @override
  String get createAccount => 'åˆ›å»ºè´¦æˆ·';

  @override
  String get accountLinkedSuccess => 'è´¦æˆ·åˆ›å»ºæˆåŠŸï¼';

  @override
  String get continueWithApple => 'ç»§ç»­ä½¿ç”¨ Apple';

  @override
  String get guest => 'å®¢äºº';

  @override
  String get betterWithAnAccount =>
      'æ³¨å†Œè´¦å·åï¼Œæ­¤éƒ¨åˆ†å†…å®¹ä¼šæ˜¾ç¤ºå¾—æ›´æ¸…æ™°ï¼';

  @override
  String get restorePurchases => 'æ¢å¤è´­ä¹°';

  @override
  String annualTotalDescription(Object price) {
    return '$price/å¹´ï¼ŒæŒ‰å¹´è®¡è´¹';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'çº¦ $price/æœˆ';
  }

  @override
  String get confirmDownloadTitle => 'æ‚¨ç¡®å®šè¦ä¸‹è½½å—ï¼Ÿ';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'è¯¥æ¨¡å‹å°†å ç”¨å¤§çº¦$sizeçš„ç©ºé—´ã€‚';
  }

  @override
  String get emulatorModeWarning => 'æ­¤åŠŸèƒ½åœ¨æ¨¡æ‹Ÿå™¨æ¨¡å¼ä¸‹ç¦ç”¨ã€‚';

  @override
  String get newChat => 'æ–°èŠå¤©';

  @override
  String get variants => 'å˜ä½“';

  @override
  String get variantsDescription =>
      'å˜ä½“æ˜¯åŒä¸€äººå·¥æ™ºèƒ½å®¶æ—çš„ä¸åŒç‰ˆæœ¬ã€‚å½“æ‚¨ç‚¹å‡»ä¸»å¡ç‰‡æ—¶ï¼Œæˆ‘ä»¬ä¼šè‡ªåŠ¨é€‰æ‹©æœ€ä½³ç‰ˆæœ¬ï¼Œä½†å¦‚æœæ‚¨æ„¿æ„ï¼Œä¹Ÿå¯ä»¥åœ¨æ­¤å¤„æ‰‹åŠ¨é€‰æ‹©ç‰¹å®šç‰ˆæœ¬ï¼';

  @override
  String get fluxChatTitle => 'Flux èŠå¤©';

  @override
  String get fluxChatDescription =>
      'FluxèŠå¤©è®°å½•æ˜¯ä¸´æ—¶èŠå¤©è®°å½•ï¼Œä¸ä¼šä¿å­˜åœ¨æ‚¨çš„è®¾å¤‡ä¸Šã€‚';

  @override
  String get alwaysBest => 'æ°¸è¿œæœ€å¥½';

  @override
  String get featuresTitle => 'ç‰¹å¾';

  @override
  String get useOfflineDescription => 'æ— éœ€ç½‘ç»œè¿æ¥å³å¯ç§å¯†èŠå¤©ã€‚';

  @override
  String get featureReasoning => 'æ·±åº¦æ€è€ƒ';

  @override
  String get featureReasoningDescription =>
      'åœ¨æ·±åº¦æ€è€ƒæ¨¡å¼ä¸‹ï¼Œäººå·¥æ™ºèƒ½ä¼šåœ¨å†…éƒ¨è¿›è¡Œæ€è€ƒï¼Œå°½å…¶æ‰€èƒ½åœ°å®Œæˆä»»åŠ¡ã€‚';

  @override
  String get featureCreateImageTitle => 'åˆ›å»ºå›¾åƒ';

  @override
  String get featureCreateImageDescription =>
      'æ ¹æ®æ–‡æœ¬ç”ŸæˆAIè‰ºæœ¯ä½œå“ã€‚';

  @override
  String get featureCreateAudioTitle => 'Create Audio';

  @override
  String get featureCreateAudioDescription =>
      'Generate sounds or voice from text.';

  @override
  String get featureCreateVideoTitle => 'åˆ¶ä½œè§†é¢‘';

  @override
  String get featureCreateVideoDescription => 'å°†æ–‡æœ¬ç”Ÿæˆè§†é¢‘ã€‚';

  @override
  String get featureStudyTitle => 'å­¦ä¹ ';

  @override
  String get featureStudyDescription => 'è·å–è§£é‡Šå’Œæ‘˜è¦ã€‚';

  @override
  String get featureQuizzesTitle => 'æµ‹éªŒ';

  @override
  String get featureQuizzesDescription => 'æµ‹è¯•ä¸€ä¸‹ä½ çš„çŸ¥è¯†ã€‚';

  @override
  String get featureExploreDescription => 'å‘ç°æ‰€æœ‰å¯ç”¨æ¨¡å‹ã€‚';

  @override
  String get featureStudyMessage =>
      'æ‚¨æ˜¯ä¸€ä½èµ„æ·±å¯¼å¸ˆã€‚æ‚¨çš„ç›®æ ‡æ˜¯å…¨é¢æ·±å…¥åœ°è®²è§£ç”¨æˆ·æ„Ÿå…´è¶£çš„ä¸»é¢˜ã€‚è¯·ä½¿ç”¨æ¸…æ™°çš„ç»“æ„ã€ä¸°å¯Œçš„ç¤ºä¾‹å’Œç±»æ¯”ã€‚å°†å¤æ‚çš„æ¦‚å¿µåˆ†è§£æˆæ˜“äºç†è§£çš„éƒ¨åˆ†ï¼Œä»¥ç¡®ä¿ç”¨æˆ·èƒ½å¤Ÿé«˜æ•ˆå­¦ä¹ ã€‚ä¸»é¢˜ï¼š';

  @override
  String get featureQuizMessage =>
      'æ‚¨æ˜¯ä¸€ä½å‡ºé¢˜äººã€‚è¯·æ ¹æ®ç”¨æˆ·é€‰æ‹©çš„ä¸»é¢˜ç”Ÿæˆä¸€é“é€‰æ‹©é¢˜ã€‚ç­‰å¾…ç”¨æˆ·ä½œç­”ã€‚ç„¶åï¼Œè¯„ä¼°ç­”æ¡ˆå¹¶æå‡ºä¸‹ä¸€é¢˜ã€‚ä¸è¦ä¸€æ¬¡æ€§æ˜¾ç¤ºæ‰€æœ‰ç­”æ¡ˆã€‚ä¿æŒäº’åŠ¨æ€§ã€‚ä¸»é¢˜ï¼š';

  @override
  String get myPlan => 'æˆ‘çš„è®¡åˆ’';

  @override
  String welcomeOfferBadge(String time) {
    return 'æ¬¢è¿ä¼˜æƒ  â€¢ $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'ç‹¬å®¶ä¼˜æƒ  â€¢ $time';
  }

  @override
  String get attachmentSheetTitle => 'é™„ä»¶';

  @override
  String get actionCamera => 'ç›¸æœº';

  @override
  String get actionGallery => 'ç›¸å†Œ';

  @override
  String get actionFile => 'æ–‡ä»¶';

  @override
  String get listening => 'æ­£åœ¨å¬';

  @override
  String get defaultViewTitle => 'æœ€è¿‘æ€ä¹ˆæ ·ï¼Ÿ';

  @override
  String get defaultViewDescription =>
      'Cortex å§‹ç»ˆä¼´æ‚¨å·¦å³ï¼Œæ‹¥æœ‰æ•°ç™¾ä¸ª AI æ¨¡å‹ã€ç¦»çº¿åŠŸèƒ½ã€åŠ¨æ€èŠå¤©ç­‰è¯¸å¤šç‰¹æ€§ã€‚';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'ç”¨æˆ·åæ ¼å¼æ— æ•ˆã€‚è¯·ä½¿ç”¨ 3-20 ä¸ªå­—ç¬¦ã€æ•°å­—æˆ–å¥ç‚¹ï¼ˆ. - _ï¼‰ã€‚';

  @override
  String get exclusiveOffer => 'ç‹¬å®¶ä¼˜æƒ ';

  @override
  String get claimOffer => 'ä½¿ç”¨ä¼˜æƒ ';

  @override
  String get continueInOfflineMode => 'ä»¥ç¦»çº¿æ¨¡å¼ç»§ç»­';

  @override
  String get voiceModeInformation =>
      'Cortex å®Œå…¨åœ¨è®¾å¤‡ç«¯è¿è¡Œï¼Œå³ä½¿åœ¨è¯­éŸ³èŠå¤©æ¨¡å¼ä¸‹ä¹Ÿèƒ½ç¡®ä¿æ‚¨çš„æ•°æ®å®‰å…¨ï¼›äº«å—æµç•…çš„å¯¹è¯ä½“éªŒï¼';

  @override
  String get flowModeDescription =>
      'åœ¨â€œå¿ƒæµâ€æ¨¡å¼ä¸‹ï¼Œæ™ºèƒ½ä½“ä¹‹é—´ä¼šè¿›è¡Œè¾©è®ºï¼›æ‚¨å¯ä»¥åä¸‹æ¥å€¾å¬ï¼Œä¹Ÿå¯ä»¥åŠ å…¥è®¨è®ºï¼';

  @override
  String get flowModeQuestion =>
      'ä½ å¥½ï¼ä½ ç°åœ¨å·²è¿›å…¥Cortexåº”ç”¨ç¨‹åºçš„â€œå¿ƒæµæ¨¡å¼â€ã€‚è¿™é‡Œè¿˜æœ‰ä¸‰ä½å…¶ä»–AIæ™ºèƒ½ä½“ã€‚ä½ çš„ä»»åŠ¡æ˜¯æŠ›å‡ºä¸€ä¸ªè¯é¢˜ï¼Œå¹¶é€šè¿‡å‘å…¶ä»–æ™ºèƒ½ä½“æå‡ºä¸€ä¸ªå¼•äººæ·±æ€æˆ–è¶£å‘³åè¶³çš„é—®é¢˜æ¥å¼€å¯è®¨è®ºã€‚åœ¨ä½ çš„å›ç­”ä¸­ï¼Œå¯ä»¥éšæ„è¿ç”¨å¹½é»˜ã€åè®½å’Œè½»å¾®çš„è°ƒä¾ƒã€‚ä»»ä½•è¯é¢˜éƒ½å¯ä»¥ã€‚å¼€å§‹å§ï¼Œå¼€å¯å¯¹è¯ï¼';

  @override
  String get thought => 'æ€è€ƒäº†';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => 'æµåŠ¨æ¨¡å¼';

  @override
  String get premium => 'ä¼˜è´¨çš„';

  @override
  String get workInProgress => 'è¿›è¡Œä¸­';

  @override
  String get voiceSystemPromptSuffix =>
      'é‡è¦æç¤ºï¼šè¯·å‹¿ä½¿ç”¨ Markdown æ ¼å¼ï¼ˆç²—ä½“ã€æ–œä½“ï¼‰ã€‚è¯·å‹¿è¾“å‡ºä»£ç å—ï¼ˆ```ï¼‰ã€‚è¯·ä¿æŒå›å¤ç®€æ´æ˜äº†ï¼Œå¦‚åŒæ—¥å¸¸å¯¹è¯ã€‚';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Cortex æµæ¨¡å¼ï¼ˆ$agentNameï¼‰ã€‚ä¸Šä¸€ä¸ªï¼š$previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'è¯»å–å¹¶æå–ä¸Šä¼ æ–‡æ¡£ä¸­çš„æ–‡æœ¬å†…å®¹ã€‚æ”¯æŒ PDFã€Word (DOCX)ã€Excel (XLSX)ã€PowerPoint (PPTX) å’Œ OpenDocument æ ¼å¼ã€‚å½“ç”¨æˆ·é™„åŠ æ–‡æ¡£æ–‡ä»¶æ—¶ï¼Œè¯·ä½¿ç”¨æ­¤åŠŸèƒ½ã€‚';

  @override
  String get toolReadDocumentIndexParam =>
      'è¦è¯»å–çš„æ–‡æ¡£é™„ä»¶çš„ç´¢å¼•ï¼ˆä» 0 å¼€å§‹è®¡æ•°ï¼‰ã€‚é€šå¸¸ 0 è¡¨ç¤ºç¬¬ä¸€ä¸ªæ–‡æ¡£ã€‚';

  @override
  String get toolStockDescription =>
      'è·å–è‚¡ç¥¨ï¼ˆä¾‹å¦‚ AAPLã€THYAO.ISï¼‰å’ŒåŠ å¯†è´§å¸ï¼ˆä¾‹å¦‚ BTC-USDï¼‰çš„å½“å‰ä»·æ ¼å’Œå†å²è®°å½•ã€‚';

  @override
  String get toolStockSymbolParam =>
      'è‚¡ç¥¨ä»£ç ï¼ˆä¾‹å¦‚ AAPLã€THYAO.ISã€BTC-USDï¼‰ã€‚';

  @override
  String get toolWeatherDescription => 'è·å–ç‰¹å®šåŸå¸‚çš„å®æ—¶å¤©æ°”ã€‚';

  @override
  String get toolWeatherCityParam =>
      'åŸå¸‚åç§°ï¼ˆä¾‹å¦‚ï¼šä¼¦æ•¦ã€ä¼Šæ–¯å¦å¸ƒå°”ï¼‰ã€‚';

  @override
  String get toolPythonDescription => 'åœ¨å®‰å…¨æ²™ç®±ä¸­æ‰§è¡ŒPythonä»£ç ã€‚';

  @override
  String get toolPythonCodeParam => 'è¦æ‰§è¡Œçš„Pythonä»£ç ã€‚';

  @override
  String get toolCalculateDescription => 'è®¡ç®—æ•°å­¦è¡¨è¾¾å¼çš„å€¼ã€‚';

  @override
  String get toolCalculateExpressionParam =>
      'æ•°å­¦è¡¨è¾¾å¼ï¼ˆä¾‹å¦‚â€œ3 + 4 * 2â€ï¼‰ã€‚';

  @override
  String get toolChartDescription => 'ç”Ÿæˆå›¾è¡¨/å›¾å½¢å¯è§†åŒ–æ•ˆæœã€‚';

  @override
  String get toolChartTypeParam =>
      'å›¾è¡¨ç±»å‹ï¼šæŸ±çŠ¶å›¾ã€æŠ˜çº¿å›¾æˆ–é¥¼å›¾ã€‚';

  @override
  String get toolChartLabelsParam => 'å›¾è¡¨åæ ‡è½´æˆ–åˆ†æ®µçš„æ ‡ç­¾ã€‚';

  @override
  String get toolChartDataParam => 'å›¾è¡¨çš„æ•°å€¼æ•°æ®ã€‚';

  @override
  String get toolChartLabelParam => 'å›¾è¡¨å›¾ä¾‹çš„æ•°æ®é›†æ ‡ç­¾ã€‚';

  @override
  String get toolChartTitleParam => 'å›¾è¡¨æ ‡é¢˜ã€‚';

  @override
  String get thinkingModeInstruction =>
      'æ€è€ƒæ¨¡å¼å·²å¯ç”¨ï¼šæ‚¨å¿…é¡»ä½¿ç”¨ `<think></think>` æ ‡ç­¾æ¥å±•ç¤ºæ‚¨çš„æ¨ç†è¿‡ç¨‹ï¼Œç„¶åå†ç»™å‡ºæœ€ç»ˆç­”æ¡ˆã€‚è¯·åœ¨æ ‡ç­¾å†…é€æ­¥æ€è€ƒï¼Œç„¶ååœ¨æ ‡ç­¾å¤–ç»™å‡ºæ‚¨çš„ç­”æ¡ˆã€‚';

  @override
  String get openLinkWarningTitle => 'å¤–éƒ¨é“¾æ¥è­¦å‘Š';

  @override
  String get openLinkCancel => 'Cancel';

  @override
  String get openLinkConfirm => 'æ‰“å¼€é“¾æ¥';

  @override
  String get webSearchSources => 'æ¥æº';

  @override
  String get searching => 'æœç´¢';

  @override
  String get featureWebSearchTitle => 'ç½‘ç»œæœç´¢';

  @override
  String get featureWebSearchDescription => 'åœ¨ç½‘ç»œä¸Šæœç´¢å®æ—¶ä¿¡æ¯';

  @override
  String get clearMemory => 'æ¸…æ™°è®°å¿†';

  @override
  String get clearMemoryConfirm => 'ä½ ç¡®å®šè¦æ¸…é™¤è®°å¿†å—ï¼Ÿ';

  @override
  String get personalization => 'ä¸ªæ€§åŒ–';

  @override
  String get personalizationDescription =>
      'ä¸ªæ€§åŒ–æ‚¨çš„åŠ©æ‰‹ï¼Œä½¿å…¶æ›´ç¬¦åˆæ‚¨çš„éœ€æ±‚ã€‚æ‚¨å¯ä»¥æ ¹æ®è‡ªå·±çš„ç‹¬ç‰¹åå¥½ï¼Œè°ƒæ•´å…¶å›å¤ã€è¡Œä¸ºå’Œè¯­æ°”ã€‚';

  @override
  String get memoryTitle => 'è®°å¿†';

  @override
  String get memoryDescription => 'äººå·¥æ™ºèƒ½å°±æ˜¯è¿™æ ·è¯†åˆ«ä½ çš„ã€‚';

  @override
  String get noMemoryYet => 'å°šæœªå»ºç«‹ä»»ä½•è®°å¿†';

  @override
  String get memoryLimitReached => 'å†…å­˜å·²è¾¾ä¸Šé™';

  @override
  String get memoryUpdated => 'Memory updated';

  @override
  String get intelligenceTitle => 'æ™ºåŠ›';

  @override
  String get intelligenceDescription =>
      'äººå·¥æ™ºèƒ½å°±æ˜¯è¿™æ ·ä¸ä½ äº¤æµçš„ã€‚';

  @override
  String get customInstructionHint => 'åœ¨æ­¤å¤„è¾“å…¥æ‚¨çš„è‡ªå®šä¹‰è¯´æ˜';

  @override
  String openLinkWarningMessage(String url) {
    return 'æ‚¨å³å°†æ‰“å¼€ä»¥ä¸‹å¤–éƒ¨é“¾æ¥ï¼š\\n\\n$url\\n\\næ‚¨ç¡®å®šè¦ç»§ç»­å—ï¼Ÿ';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'è¯·æŒ‰ç…§ä»¥ä¸‹è‡ªå®šä¹‰è¯´æ˜æ“ä½œï¼š\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      'ã€é‡è¦è¯´æ˜ã€‘ï¼šæ‚¨æ˜¯æ ‡é¢˜ç”Ÿæˆå™¨ã€‚è¯·å‹¿å›ç­”ç”¨æˆ·çš„é—®é¢˜ã€‚è¯·å‹¿èŠå¤©æˆ–æ‰“æ‹›å‘¼ã€‚ä»…è¾“å‡ºä¸€ä¸ª 2-4 ä¸ªå­—çš„æ ‡é¢˜ï¼Œæ¦‚æ‹¬ç”¨æˆ·æå‡ºçš„é—®é¢˜ã€‚';

  @override
  String get cortexSystemPersona =>
      '\n\n[ç³»ç»Ÿ] é‡è¦æŒ‡ç¤ºï¼šæ‚¨ç›®å‰æ­£åœ¨ä¸€ä¸ªåä¸ºâ€œCortexâ€çš„åºå¤§ä¸”é«˜åº¦å…ˆè¿›çš„äººå·¥æ™ºèƒ½ç”Ÿæ€ç³»ç»Ÿä¸­æ“ä½œï¼›è¯¥å¹³å°ç”±Vertexå›¢é˜Ÿå¼€å‘ï¼Œè¯¥å›¢é˜Ÿæˆå‘˜å¹³å‡å¹´é¾„ä»…ä¸º16å²ã€‚è¯·è®°ä½è¿™ä¸€ç‚¹ï¼Œå¹¶åœ¨è¢«é—®åŠæ—¶å›ç­”ã€‚å¦‚æœéœ€è¦æ›´å¤šä¿¡æ¯ï¼Œè¯·éšæ—¶ä¸Šç½‘æœç´¢ï¼›å¦‚æœæ‚¨æ— æ³•æœç´¢ï¼Œè¯·å¦è¯šåœ°è¯´æ‚¨ä¸çŸ¥é“ï¼';

  @override
  String get featureAudioRecognitionTitle => 'éŸ³é¢‘è¯†åˆ«';

  @override
  String get featureAudioRecognitionDescription =>
      'è¯¥æ¨¡å‹èƒ½å¤Ÿç†è§£å’Œå¤„ç†éŸ³é¢‘æˆ–è¯­éŸ³ã€‚';

  @override
  String get featureVideoRecognitionTitle => 'è§†é¢‘è¯†åˆ«';

  @override
  String get featureVideoRecognitionDescription =>
      'è¯¥å‹å·å¯ä»¥åˆ†æå’Œç†è§£æ¥è‡ªæ‚¨çš„æ–‡ä»¶æˆ–ç›¸æœºçš„è§†é¢‘ã€‚';

  @override
  String get featureImageRecognitionTitle => 'å›¾åƒè¯†åˆ«';

  @override
  String get featureImageRecognitionDescription =>
      'è¯¥æ¨¡å‹å¯ä»¥åˆ†æå’Œç†è§£ç…§ç‰‡æˆ–å›¾åƒã€‚';

  @override
  String get featureToolUseTitle => 'å·¥å…·ä½¿ç”¨';

  @override
  String get featureToolUseDescription =>
      'è¯¥æ¨¡å‹èƒ½å¤Ÿæ™ºèƒ½åœ°åˆ©ç”¨å¤–éƒ¨å·¥å…·å®Œæˆä»»åŠ¡ã€‚';

  @override
  String get videoModels => 'Video Models';

  @override
  String get imageModels => 'Image Models';

  @override
  String get audioModels => 'Audio Models';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'æ­¤æ¨¡å‹éœ€è¦ $mediaType æ‰èƒ½å·¥ä½œã€‚æˆ‘æˆªè·äº†è¯·æ±‚ä»¥å‘ŠçŸ¥æ‚¨ã€‚è¯·ç¤¼è²Œåœ°é€šçŸ¥ç”¨æˆ·ä»–ä»¬éœ€è¦æä¾› $mediaTypeï¼ˆç”¨ä»–ä»¬çš„è¯­è¨€å‘Šè¯‰ä»–ä»¬ï¼‰ï¼Œå› ä¸ºæˆ‘æ˜¯ $modelNameï¼Œä¸€ä¸ªè§†è§‰/éŸ³é¢‘/è§†é¢‘ç¼–è¾‘æ¨¡å‹ã€‚';
  }

  @override
  String get mediaTypeImage => 'å›¾ç‰‡';

  @override
  String get mediaTypeVideo => 'è§†é¢‘';

  @override
  String get mediaTypeAudio => 'éŸ³é¢‘æ–‡ä»¶';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesNameæ˜¯ä¸€æ¬¾åœ¨Cortexä¸Šå±•ç°å‡ºé«˜æ€§èƒ½çš„å…ˆè¿›æ™ºèƒ½ã€‚';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelNameæ˜¯é›†æˆåœ¨Cortexç”Ÿæ€ç³»ç»Ÿå†…çš„é«˜æ€§èƒ½äººå·¥æ™ºèƒ½ã€‚æ—¨åœ¨å…‹æœå„ç§å¤æ‚ä»»åŠ¡ï¼Œæä¾›é«˜åº¦å¯é é«˜æ•ˆçš„å¤„ç†èƒ½åŠ›ã€‚é€šè¿‡æä¾›å¿«é€Ÿå“åº”æ—¶é—´å’Œé«˜çº§åˆ†æèƒ½åŠ›ï¼Œå®ƒèƒ½æ˜¾è‘—æé«˜æ‚¨çš„æ—¥å¸¸ç”Ÿäº§åŠ›ã€‚è¯¥æ¨¡å‹èƒ½å¤Ÿåœ¨Cortexçš„å®‰å…¨æœ¬åœ°åŸºç¡€è®¾æ–½ä¸Šæ— ç¼è¿è¡Œï¼ŒååŠ©æ‚¨å®Œæˆä»åˆ›æ„å¤´è„‘é£æš´åˆ°æ·±åº¦æŠ€æœ¯åˆ†æç­‰å„ç§ä»»åŠ¡ã€‚ä»Šå¤©å°±å¼€å§‹æ¢ç´¢å…¶å…¨éƒ¨æ½œåŠ›å§ã€‚';
  }

  @override
  String get guestLimitBottomSheetTitle => 'å–œæ¬¢Cortexçš„æ™ºèƒ½å—ï¼Ÿ';

  @override
  String get guestLimitBottomSheetText =>
      'ä¸æ›´æ™ºèƒ½çš„æ™ºèƒ½ä½“åˆä½œï¼Œåˆ›ä½œæ›´å¤šå†…å®¹ï¼Œç•…èŠæ›´å¤šï¼Œå®Œæˆæ›´å¤šäº‹æƒ…â€¦â€¦';

  @override
  String get arts => 'è‰ºæœ¯';

  @override
  String get noArt => 'æ— è‰ºæœ¯';

  @override
  String get noArtDescription =>
      'ç›®å‰è¿˜æ²¡æœ‰ä½œå“ï¼›æ˜¯æ—¶å€™é€šè¿‡åˆ›ä½œå›¾åƒã€è§†é¢‘ã€éŸ³é¢‘å’Œå„ç§å†…å®¹æ¥å¡«æ»¡ç”»å»Šäº†ï¼';

  @override
  String get videoPremiumWarning =>
      'æ‚¨éœ€è¦ Ultra ä¼šå‘˜èµ„æ ¼æ‰èƒ½ç”Ÿæˆè§†é¢‘ï¼Œç«‹å³å‡çº§ï¼Œä½“éªŒæµç•…ä½“éªŒï¼';

  @override
  String get fallbackInfoPanelText =>
      'ç”±äºæˆ‘ä»¬æ­£åœ¨å¯¹æœåŠ¡å™¨ç«¯è¿›è¡Œä¸€äº›æ”¹è¿›ï¼Œå› æ­¤å›å¤æ˜¯ç”± Cortex çš„åŠ¨æ€èŠå¤©åŠŸèƒ½ç”Ÿæˆçš„ï¼Œè€Œä¸æ˜¯æ‚¨ä¸“é—¨é€‰æ‹©çš„ AIã€‚æ„Ÿè°¢æ‚¨çš„ç†è§£ï¼Œæˆ‘ä»¬å°†å°½å¿«å®Œæˆæ”¹è¿›ï¼';

  @override
  String get falOfflineMessage =>
      'ç”±äºæœåŠ¡å™¨ç«¯æ­£åœ¨è¿›è¡Œä¸€äº›æ”¹è¿›ï¼Œæ­¤æ™ºèƒ½æœåŠ¡ç›®å‰æš‚æ—¶ç¦»çº¿ã€‚æ„Ÿè°¢æ‚¨çš„ç†è§£ï¼Œæˆ‘ä»¬å°†å°½å¿«å®Œæˆå‡çº§ï¼';

  @override
  String get errorInsufficientStorage =>
      'å­˜å‚¨ç©ºé—´ä¸è¶³ï¼Œæ— æ³•ä¸‹è½½æ­¤æ¨¡å‹ã€‚';

  @override
  String get backgroundChatNotificationTitle => 'è¿”å›èŠå¤©å®¤ï¼';

  @override
  String get benefitVideoGeneration => 'è§†é¢‘ç”Ÿæˆ';

  @override
  String get freeOffer => 'å…è´¹ä¼˜æƒ ';

  @override
  String trialMonthlyDescription(String days, String price) {
    return 'å‰ $days å¤©å…è´¹ï¼Œä¹‹å $price/æœˆ';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return 'å‰ $days å¤©å…è´¹ï¼Œä¹‹å $price/å¹´';
  }

  @override
  String freePlan(String plan) {
    return 'å…è´¹ $planï¼';
  }

  @override
  String get systemPromptLimitFallback =>
      'ç´§æ€¥ï¼šç”¨æˆ·è¯·æ±‚æ‰§è¡ŒæŸé¡¹æ“ä½œï¼Œä½†å…¶åœ¨ Cortex ä¸Šçš„é¢åº¦å·²ç”¨å®Œï¼›è¯·ç”¨ç”¨æˆ·çš„è¯­è¨€å‘ŠçŸ¥ä»–ä»¬åº”è¯¥ç­‰å¾…æˆ–è€ƒè™‘å‡çº§è®¢é˜…è®¡åˆ’ã€‚';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'Cortex å¯ä»¥ç»™å‡ºæ›´å¥½çš„å›ç­”ï¼›ç«‹å³å‡çº§ï¼Œä¸ºæ¯ä¸ªé—®é¢˜è·å¾—æœ€ä½³ç­”æ¡ˆï¼';

  @override
  String get pinLimitReached => 'æ‚¨æœ€å¤šå¯ä»¥å›ºå®š 3 ä¸ªèŠå¤©ã€‚';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryFree => 'Free';

  @override
  String get categoryPremium => 'Premium';

  @override
  String get categoryVideo => 'Video';

  @override
  String get categoryPhoto => 'Photo';

  @override
  String get categoryMasculine => 'Masculine';

  @override
  String get categoryFeminine => 'Feminine';

  @override
  String get categoryInanimate => 'Inanimate';
}
