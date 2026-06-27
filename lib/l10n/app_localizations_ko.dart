// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'ì œëª© ìƒì„±ê¸°ì…ë‹ˆë‹¤. ë‹¤ìŒ ëŒ€í™”ì— 2~5ë‹¨ì–´ë¡œ ëœ ì œëª©ë§Œ ì…ë ¥í•˜ì„¸ìš”. ë”°ì˜´í‘œ, ì ‘ë‘ì‚¬, êµ¬ë‘ì ì€ ì‚¬ìš©í•˜ì§€ ë§ˆì„¸ìš”. ì¤‘ìš”: ì œëª©ì€ ì‚¬ìš©ìì˜ ë©”ì‹œì§€ì™€ ì •í™•íˆ ë™ì¼í•œ ì–¸ì–´ë¡œ ì‘ì„±í•´ì•¼ í•©ë‹ˆë‹¤.';

  @override
  String get systemRoleFallback =>
      'ë‹¹ì‹ ì€ ë„ì›€ì„ ì£¼ëŠ” ì¡°ë ¥ìì…ë‹ˆë‹¤.';

  @override
  String get systemLanguageInstruction =>
      '\n\nì¤‘ìš”: í•­ìƒ ì‚¬ìš©ìê°€ ì‘ì„±í•œ ì–¸ì–´ì™€ ë™ì¼í•œ ì–¸ì–´ë¡œ ì‘ë‹µí•˜ê³ , ì‚¬ìš©ìì˜ ì–¸ì–´ì— ì£¼ì˜ë¥¼ ê¸°ìš¸ì´ì‹­ì‹œì˜¤.';

  @override
  String get systemNotePreviousMedia =>
      '[ì‹œìŠ¤í…œ ì°¸ê³ : ì•„ë˜ëŠ” ì´ì „ì— ìƒì„±ëœ ë¯¸ë””ì–´ì…ë‹ˆë‹¤. ì°¸ê³ í•˜ê±°ë‚˜ í¸ì§‘í•  ìˆ˜ ìˆìŠµë‹ˆë‹¤.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return '\n\ní˜„ì¬ ë‚ ì§œ ë° ì‹œê°„: $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\nì§€ê¸ˆê¹Œì§€ì˜ ëŒ€í™”ë¥¼ ë¶„ì„í•©ë‹ˆë‹¤. ì‚¬ìš©ìì— ëŒ€í•œ ìƒˆë¡œìš´ ì‚¬ì‹¤(ì„ í˜¸ë„, ì´ë¦„, ìŠµê´€, ìƒí™©)ì„ ì•Œê²Œ ëœ ê²½ìš°, ì‘ë‹µì˜ ë§¨ ë§ˆì§€ë§‰ì— <memory>...</memory> íƒœê·¸ ì•ˆì— ì—…ë°ì´íŠ¸ëœ ì‚¬ìš©ì ì •ë³´ë¥¼ ëª¨ë‘ ì¶œë ¥í•´ì•¼ í•©ë‹ˆë‹¤. ì¤‘ìš”: ì´ì „ ë©”ëª¨ë¦¬ë¥¼ ì ˆëŒ€ ì§€ìš°ê±°ë‚˜ ë®ì–´ì“°ë©´ ì•ˆ ë©ë‹ˆë‹¤. í•­ìƒ ìƒˆë¡œìš´ ì‚¬ì‹¤ì„ ê¸°ì¡´ ë©”ëª¨ë¦¬ì— ì¶”ê°€í•´ì•¼ í•©ë‹ˆë‹¤. ìƒˆë¡œìš´ ì •ë³´ë¥¼ ì „í˜€ ì•Œì§€ ëª»í•˜ëŠ” ê²½ìš°ì—ëŠ” íƒœê·¸ë¥¼ ìƒëµí•©ë‹ˆë‹¤. ì˜ˆ: <memory>ì¶•êµ¬ì™€ í…Œë‹ˆìŠ¤ë¥¼ ì¢‹ì•„í•©ë‹ˆë‹¤. ì§§ì€ ë‹µë³€ì„ ì„ í˜¸í•©ë‹ˆë‹¤.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return '\n\nì‚¬ìš©ìì— ëŒ€í•´ í•­ìƒ ë‹¤ìŒì„ ê¸°ì–µí•˜ì„¸ìš”:\n$userMemory';
  }

  @override
  String get cancel => 'ì·¨ì†Œ';

  @override
  String get remove => 'ì œê±°í•˜ë‹¤';

  @override
  String get download => 'ë‹¤ìš´ë¡œë“œ';

  @override
  String get resume => 'ì¬ê°œ';

  @override
  String get copy => 'ë³µì‚¬';

  @override
  String get chat => 'ì±„íŒ…';

  @override
  String get locked => 'Locked';

  @override
  String get languageModels => 'ì–¸ì–´ ëª¨ë¸';

  @override
  String get light => 'ë¼ì´íŠ¸';

  @override
  String get theme => 'í…Œë§ˆ';

  @override
  String get no => 'ì•„ë‹ˆìš”';

  @override
  String get yes => 'ì˜ˆ';

  @override
  String get done => 'ì™„ë£Œ';

  @override
  String get bestValue => 'ìµœê³ ì˜ ê°€ì¹˜';

  @override
  String get selected => 'ì„ íƒë¨';

  @override
  String get descriptionSection => 'ì„¤ëª…';

  @override
  String get searchHint => 'ê²€ìƒ‰';

  @override
  String get messageHint => 'ë¬´ì—‡ì´ë“  ë¬¼ì–´ë³´ì„¸ìš”';

  @override
  String get messageCopied =>
      'ë©”ì‹œì§€ê°€ í´ë¦½ë³´ë“œì— ë³µì‚¬ë˜ì—ˆìŠµë‹ˆë‹¤.';

  @override
  String get retry => 'ì¬ì‹œë„';

  @override
  String get systemInfo => 'ì‹œìŠ¤í…œ ì •ë³´';

  @override
  String deviceMemory(Object memory) {
    return 'ê¸°ê¸° ë©”ëª¨ë¦¬: ${memory}GB';
  }

  @override
  String get memory => 'ë©”ëª¨ë¦¬';

  @override
  String get storage => 'ì €ì¥ ê³µê°„';

  @override
  String get freeStorage => 'ì‚¬ìš© ê°€ëŠ¥í•œ ê³µê°„';

  @override
  String get totalStorage => 'ì´ ì €ì¥ ê³µê°„';

  @override
  String get usedStorage => 'ì‚¬ìš©ëœ ì €ì¥ ê³µê°„';

  @override
  String get totalMemory => 'ì´ ë©”ëª¨ë¦¬';

  @override
  String get usedMemory => 'ì‚¬ìš©ëœ ë©”ëª¨ë¦¬';

  @override
  String get modelsTitle => 'ë¼ì´ë¸ŒëŸ¬ë¦¬';

  @override
  String get localModels => 'ë¡œì»¬ ëª¨ë¸';

  @override
  String get selectGGUFFile => 'GGUF íŒŒì¼ ì„ íƒ';

  @override
  String get errorGGUF => 'GGUF í˜•ì‹ì˜ íŒŒì¼ë§Œ ì„ íƒí•´ì£¼ì„¸ìš”.';

  @override
  String get myModels => 'ë‚´ ëª¨ë¸';

  @override
  String get create => 'ìƒì„±';

  @override
  String modelProducer(Object producer) {
    return 'ì œì‘ì‚¬: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'ì´ë¦„ ë³€ê²½';

  @override
  String get newTitle => 'ìƒˆ ì œëª©';

  @override
  String get save => 'ì €ì¥';

  @override
  String get noConversationsMessage =>
      'ëŒ€í™”ê°€ ì—†ìŠµë‹ˆë‹¤, ì±„íŒ…ì„ ì‹œì‘í•´ë³´ì„¸ìš”!';

  @override
  String get startChat => 'ì±„íŒ… ì‹œì‘í•˜ê¸°';

  @override
  String get noChats => 'ì±„íŒ… ì—†ìŒ';

  @override
  String get noStarredChats => 'ë³„í‘œ í‘œì‹œëœ ì±„íŒ… ì—†ìŒ';

  @override
  String get noStarredChatsMessage =>
      'ì•„ì§ ë³„í‘œ í‘œì‹œí•œ ì±„íŒ…ì´ ì—†ìŠµë‹ˆë‹¤.';

  @override
  String get starConversation => 'ë³„í‘œ í‘œì‹œ';

  @override
  String get unstarConversation => 'ì–¸ìŠ¤íƒ€';

  @override
  String get loginToYourAccount => 'ë¡œê·¸ì¸';

  @override
  String get createYourAccount => 'íšŒì›ê°€ì…';

  @override
  String get email => 'ì´ë©”ì¼';

  @override
  String get password => 'ë¹„ë°€ë²ˆí˜¸';

  @override
  String get confirmPassword => 'ë¹„ë°€ë²ˆí˜¸ í™•ì¸';

  @override
  String get invalidEmail =>
      'ìœ íš¨í•œ ì´ë©”ì¼ ì£¼ì†Œë¥¼ ì…ë ¥í•´ì£¼ì„¸ìš”.';

  @override
  String get invalidPassword =>
      'ë¹„ë°€ë²ˆí˜¸ëŠ” 6ì ì´ìƒì´ì–´ì•¼ í•©ë‹ˆë‹¤.';

  @override
  String get rememberMe => 'ë¡œê·¸ì¸ ìƒíƒœ ìœ ì§€';

  @override
  String get forgotPassword => 'ë¹„ë°€ë²ˆí˜¸ë¥¼ ìŠìœ¼ì…¨ë‚˜ìš”?';

  @override
  String get or => 'ë˜ëŠ”';

  @override
  String get continueWithGoogle => 'Googleë¡œ ê³„ì†í•˜ê¸°';

  @override
  String get dontHaveAccount => 'ê³„ì •ì´ ì—†ìœ¼ì‹ ê°€ìš”?';

  @override
  String get alreadyHaveAccount => 'ì´ë¯¸ ê³„ì •ì´ ìˆìœ¼ì‹ ê°€ìš”?';

  @override
  String get signUp => 'ê°€ì…í•˜ê¸°';

  @override
  String get logIn => 'ë¡œê·¸ì¸';

  @override
  String get passwordsDoNotMatch =>
      'ë¹„ë°€ë²ˆí˜¸ê°€ ì¼ì¹˜í•˜ì§€ ì•ŠìŠµë‹ˆë‹¤.';

  @override
  String get wrongPassword => 'ì˜ëª»ëœ ë¹„ë°€ë²ˆí˜¸ì…ë‹ˆë‹¤.';

  @override
  String get emailAlreadyInUse => 'ì´ë¯¸ ì‚¬ìš© ì¤‘ì¸ ì´ë©”ì¼ì…ë‹ˆë‹¤.';

  @override
  String get weakPassword => 'ë¹„ë°€ë²ˆí˜¸ê°€ ë„ˆë¬´ ì•½í•©ë‹ˆë‹¤.';

  @override
  String get authError => 'ì¸ì¦ ì˜¤ë¥˜';

  @override
  String get usernameTaken => 'ì´ë¯¸ ì‚¬ìš© ì¤‘ì¸ ì‚¬ìš©ì ì´ë¦„ì…ë‹ˆë‹¤.';

  @override
  String get username => 'ì‚¬ìš©ì ì´ë¦„';

  @override
  String get resendCode => 'ì¸ì¦ ì´ë©”ì¼ ì¬ì „ì†¡';

  @override
  String get pleaseCheckYourEmail =>
      'Cortexë¥¼ ì‚¬ìš©í•˜ë ¤ë©´ ì´ë©”ì¼ì„ ì¸ì¦í•´ì•¼ í•©ë‹ˆë‹¤. \nì¸ì¦ ë§í¬ê°€ ì´ë©”ì¼ ì£¼ì†Œë¡œ ì „ì†¡ë˜ì—ˆìœ¼ë‹ˆ í™•ì¸í•´ì£¼ì„¸ìš”.';

  @override
  String get verifyYourEmail => 'ì´ë©”ì¼ ì¸ì¦í•˜ê¸°';

  @override
  String get seconds => 'ì´ˆ';

  @override
  String get maxResendLimitReached =>
      'ì¸ì¦ ì´ë©”ì¼ ìµœëŒ€ ì „ì†¡ íšŸìˆ˜ì— ë„ë‹¬í–ˆìŠµë‹ˆë‹¤.';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'ì¸ì¦ ì—†ì´ ê³„ì†í•˜ê¸°';

  @override
  String get verificationScreenWarning =>
      'ê³„ì† ì§„í–‰í•˜ë”ë¼ë„ ê³„ì •ì— ëŒ€í•œ 1ì¼ ì¸ì¦ ê¸°ê°„ì€ ì—¬ì „íˆ ìœ íš¨í•©ë‹ˆë‹¤. ê·¸ë•Œê¹Œì§€ ê³„ì •ì„ ì¸ì¦í•˜ì§€ ì•Šìœ¼ë©´ ì•±ì—ì„œ ì‚­ì œë©ë‹ˆë‹¤.';

  @override
  String get unverifiedAccountHeader =>
      'ê³„ì •ì´ ì¸ì¦ë˜ì§€ ì•Šì•˜ìŠµë‹ˆë‹¤.';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return '$timeLeft ì´ë‚´ì— ê³„ì •ì„ ì¸ì¦í•˜ì§€ ì•Šìœ¼ë©´ ì‚­ì œë©ë‹ˆë‹¤.';
  }

  @override
  String get verifyNow => 'ì§€ê¸ˆ ì¸ì¦í•˜ê¸°';

  @override
  String get linkSent => 'ë§í¬ê°€ ì „ì†¡ë˜ì—ˆìŠµë‹ˆë‹¤.';

  @override
  String get accountDeletionRequested =>
      'ê³„ì • ì‚­ì œ ìš”ì²­ì´ ì ‘ìˆ˜ë˜ì—ˆìœ¼ë©° ê³„ì •ì´ ë¹„í™œì„±í™”ë˜ì—ˆìŠµë‹ˆë‹¤.';

  @override
  String get tooManyRequests => 'ìš”ì²­ì´ ë„ˆë¬´ ë§ìŠµë‹ˆë‹¤.';

  @override
  String get regenerate => 'ì¬ìƒì„±';

  @override
  String get confirmDeleteAccount =>
      'ì •ë§ë¡œ ê³„ì •ì„ ì‚­ì œí•˜ì‹œê² ìŠµë‹ˆê¹Œ?';

  @override
  String get deleteAccount => 'ê³„ì • ì‚­ì œ';

  @override
  String get delete => 'ì‚­ì œ';

  @override
  String get passwordRequired => 'ë¹„ë°€ë²ˆí˜¸ê°€ í•„ìš”í•©ë‹ˆë‹¤.';

  @override
  String get deleteDescription =>
      'ì‚­ì œí•œ ë°ì´í„°ëŠ” ì €í¬ ì„œë²„ì™€ ê¸°ê¸°ì—ì„œ ì˜êµ¬ì ìœ¼ë¡œ ì œê±°ë©ë‹ˆë‹¤. ì´ ì‘ì—…ì€ ë˜ëŒë¦´ ìˆ˜ ì—†ìŠµë‹ˆë‹¤.';

  @override
  String get editProfile => 'í”„ë¡œí•„ ìˆ˜ì •';

  @override
  String get displayName => 'í‘œì‹œ ì´ë¦„';

  @override
  String get profileUpdated =>
      'í”„ë¡œí•„ì´ ì„±ê³µì ìœ¼ë¡œ ì—…ë°ì´íŠ¸ë˜ì—ˆìŠµë‹ˆë‹¤.';

  @override
  String get logout => 'ë¡œê·¸ì•„ì›ƒ';

  @override
  String get profile => 'í”„ë¡œí•„';

  @override
  String get manageProfileDescription =>
      'í”„ë¡œí•„ì„ ê´€ë¦¬í•˜ê³ , ë¹„ë°€ë²ˆí˜¸ë¥¼ ì—…ë°ì´íŠ¸í•˜ê±°ë‚˜ Cortexì—ì„œ ë¡œê·¸ì•„ì›ƒí•˜ì„¸ìš”.';

  @override
  String get accessSettingsDescription =>
      'ë„ì›€ë§ì— ì•¡ì„¸ìŠ¤í•˜ê³ , ì½”ë“œë¥¼ ì‚¬ìš©í•˜ê³ , Cortexë¥¼ ê³µìœ í•˜ê³ , ì •ì±…ì„ í™•ì¸í•˜ì„¸ìš”.';

  @override
  String get languageDescription =>
      'ì–¸ì œë“ ì§€ ê¸°ë³¸ ì•± ì¸í„°í˜ì´ìŠ¤ ì–¸ì–´ë¥¼ ë³€ê²½í•  ìˆ˜ ìˆìŠµë‹ˆë‹¤.';

  @override
  String get themeDescription =>
      'ì„ í˜¸ì— ë”°ë¼ ë¼ì´íŠ¸ í…Œë§ˆì™€ ë‹¤í¬ í…Œë§ˆ ê°„ì— ì „í™˜í•  ìˆ˜ ìˆìŠµë‹ˆë‹¤. ì„ íƒí•œ í…Œë§ˆëŠ” Cortex ì¸í„°í˜ì´ìŠ¤ ì „ì²´ì— ì ìš©ë©ë‹ˆë‹¤.';

  @override
  String get iHaveReadAndAgree => 'ì„œë¹„ìŠ¤ ì•½ê´€ì— ì½ê³  ë™ì˜í•©ë‹ˆë‹¤.';

  @override
  String get downloading => 'ë‹¤ìš´ë¡œë“œ ì¤‘...';

  @override
  String get downloadSuccess => 'ë‹¤ìš´ë¡œë“œ ì„±ê³µ';

  @override
  String get downloadFailed => 'ë‹¤ìš´ë¡œë“œ ì‹¤íŒ¨';

  @override
  String downloaded(Object percent) {
    return '$percent% ë‹¤ìš´ë¡œë“œë¨';
  }

  @override
  String get downloadPaused => 'ë‹¤ìš´ë¡œë“œê°€ ì¼ì‹œ ì¤‘ì§€ë˜ì—ˆìŠµë‹ˆë‹¤.';

  @override
  String get purchaseError => 'êµ¬ë§¤ ì˜¤ë¥˜';

  @override
  String get purchasePlus => 'Cortex í”ŒëŸ¬ìŠ¤ êµ¬ë§¤í•˜ê¸°';

  @override
  String get plusDescription => 'ì—˜ë¦¬íŠ¸ ì¸ê³µì§€ëŠ¥ ì²´í—˜';

  @override
  String get annual => 'ì—°ê°„';

  @override
  String get monthly => 'ì›”ê°„';

  @override
  String get manageSubscription => 'êµ¬ë… ê´€ë¦¬';

  @override
  String purchasePlan(String planName) {
    return '$planName êµ¬ë§¤';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/ì›”, ì›”ë³„ ì²­êµ¬';
  }

  @override
  String get purchasePro => 'Cortex í”„ë¡œ êµ¬ë§¤í•˜ê¸°';

  @override
  String get proDescription => 'ìµœê³ ì˜ ì¸ê³µì§€ëŠ¥ ê²½í—˜';

  @override
  String get purchaseUltra => 'Cortex ìš¸íŠ¸ë¼ êµ¬ë§¤í•˜ê¸°';

  @override
  String get ultraDescription => 'ì¸ê³µì§€ëŠ¥ì˜ ì •ì ';

  @override
  String get upgradeSubscription => 'êµ¬ë… ì—…ê·¸ë ˆì´ë“œ';

  @override
  String get purchaseStreamError => 'êµ¬ë§¤ ìŠ¤íŠ¸ë¦¼ ì˜¤ë¥˜.';

  @override
  String get productNotFound => 'ìƒí’ˆì„ ì°¾ì„ ìˆ˜ ì—†ìŒ';

  @override
  String get noProductsFound => 'ìƒí’ˆì„ ì°¾ì„ ìˆ˜ ì—†ìŒ';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'ì´ ì£¼ë¬¸ì„ í•¨ìœ¼ë¡œì¨ ê·€í•˜ëŠ” ì„œë¹„ìŠ¤ ì•½ê´€ ë° ê°œì¸ì •ë³´ ì²˜ë¦¬ë°©ì¹¨ì— ë™ì˜í•˜ê²Œ ë©ë‹ˆë‹¤. ì´ í…ìŠ¤íŠ¸ë¥¼ í´ë¦­í•˜ì—¬ ì„œë¹„ìŠ¤ ì•½ê´€ ë° ê°œì¸ì •ë³´ ì²˜ë¦¬ë°©ì¹¨ì— ëŒ€í•´ ìì„¸íˆ ì•Œì•„ë³¼ ìˆ˜ ìˆìŠµë‹ˆë‹¤. í˜„ì¬ ê¸°ê°„ì´ ì¢…ë£Œë˜ê¸° ìµœì†Œ 24ì‹œê°„ ì „ì— ìë™ ê°±ì‹ ì„ í•´ì œí•˜ì§€ ì•Šìœ¼ë©´ êµ¬ë…ì€ ìë™ìœ¼ë¡œ ê°±ì‹ ë©ë‹ˆë‹¤.';

  @override
  String get termsOfService => 'ì„œë¹„ìŠ¤ ì•½ê´€';

  @override
  String get privacyPolicy => 'ê°œì¸ì •ë³´ ì²˜ë¦¬ë°©ì¹¨';

  @override
  String get renamed => 'ì´ë¦„ì´ ë°”ë€Œì—ˆìŠµë‹ˆë‹¤';

  @override
  String get report => 'ì‹ ê³ í•˜ê¸°';

  @override
  String get reportDialogTitle => 'ì‹ ê³  ì œì¶œ';

  @override
  String get reportDescriptionLabel => 'ì–´ë–¤ ë¬¸ì œê°€ ìˆë‚˜ìš”?';

  @override
  String get reportHarmful => 'ìœ í•´í•˜ê±°ë‚˜ ì•ˆì „í•˜ì§€ ì•ŠìŠµë‹ˆë‹¤.';

  @override
  String get reportNotTrue => 'ì‚¬ì‹¤ì´ ì•„ë‹™ë‹ˆë‹¤.';

  @override
  String get reportNotHelpful => 'ë„ì›€ì´ ë˜ì§€ ì•ŠìŠµë‹ˆë‹¤.';

  @override
  String get closeButton => 'ë‹«ê¸°';

  @override
  String get submitButton => 'ì œì¶œ';

  @override
  String get reportErrorMessage =>
      'ì‹ ê³  ì‚¬ìœ ë¥¼ í•˜ë‚˜ ì„ íƒí•´ì£¼ì„¸ìš”.';

  @override
  String get capabilitiesSection => 'ê¸°ëŠ¥';

  @override
  String get featurePhotoTitle => 'ì‚¬ì§„ ìŠ¤ìº”';

  @override
  String get featurePhotoDescription =>
      'ì´ ëª¨ë¸ì€ ì¹´ë©”ë¼ë‚˜ ì´ë¯¸ì§€ íŒŒì¼ì„ í†µí•´ ì‚¬ì§„ì„ ìŠ¤ìº”í•˜ëŠ” ê¸°ëŠ¥ì´ ìˆìŠµë‹ˆë‹¤.';

  @override
  String get featureOfflineTitle => 'ì˜¤í”„ë¼ì¸ ì‘ë™';

  @override
  String get featureOfflineDescription =>
      'ì¸í„°ë„· ì—°ê²° ì—†ì´ ëª¨ë¸ì„ ì‹¤í–‰í•˜ì—¬ ë°ì´í„°ë¥¼ ì•ˆì „í•˜ê²Œ ë³´í˜¸í•˜ì„¸ìš”.';

  @override
  String get featureRoleplayTitle => 'ì—­í•  ë†€ì´';

  @override
  String get featureRoleplayDescription =>
      'ì—­í•  ë†€ì´ ëª¨ë¸ì„ í†µí•´ ë‹¤ì–‘í•œ ì±„íŒ…ê³¼ ì‹œë‚˜ë¦¬ì˜¤ë¥¼ ë§Œë“¤ ìˆ˜ ìˆìŠµë‹ˆë‹¤.';

  @override
  String get roleModels => 'ë¡¤í”Œë ˆì‰ ëª¨ë¸';

  @override
  String get parameters => 'íŒŒë¼ë¯¸í„°';

  @override
  String get context => 'ì»¨í…ìŠ¤íŠ¸';

  @override
  String get finalPreparation => 'ìµœì¢… ì¤€ë¹„ê°€ ì§„í–‰ ì¤‘ì…ë‹ˆë‹¤.';

  @override
  String get shareApp => 'ì•± ê³µìœ í•˜ê¸°';

  @override
  String get ourStory => 'ìš°ë¦¬ì˜ ì´ì•¼ê¸°';

  @override
  String get rateUs => 'í‰ê°€í•˜ê¸°';

  @override
  String get share => 'ê³µìœ ';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'í…ìŠ¤íŠ¸ ì„ íƒ';

  @override
  String get thinking => 'ìƒê° ì¤‘';

  @override
  String get user => 'ì‚¬ìš©ì';

  @override
  String get help => 'ë„ì›€ë§';

  @override
  String get supportCreator => 'í¬ë¦¬ì—ì´í„° ì§€ì›í•˜ê¸°';

  @override
  String get enterYourTag =>
      'ì¢‹ì•„í•˜ëŠ” í¬ë¦¬ì—ì´í„°ë¥¼ ì‘ì›í•˜ì„¸ìš”! ì•„ë˜ì— í¬ë¦¬ì—ì´í„°ì˜ ê³ ìœ  íƒœê·¸ë¥¼ ì…ë ¥í•˜ì—¬ Cortex êµ¬ë§¤ ì‹œ ë°œìƒí•˜ëŠ” ìˆ˜ìµì„ í¬ë¦¬ì—ì´í„°ì—ê²Œ ê¸°ë¶€í•˜ì„¸ìš”.';

  @override
  String get creatorTag => 'í¬ë¦¬ì—ì´í„° íƒœê·¸';

  @override
  String get support => 'í›„ì›í•˜ê¸°';

  @override
  String get tagCannotBeEmpty =>
      'ìƒì„±ì íƒœê·¸ëŠ” ë¹„ì–´ ìˆì„ ìˆ˜ ì—†ìŠµë‹ˆë‹¤.';

  @override
  String get userId => 'ì‚¬ìš©ì ID';

  @override
  String get deleteAllConversationsConfirmTitle => 'ëª¨ë“  ì±„íŒ… ì‚­ì œ?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'ì •ë§ë¡œ ëª¨ë“  ì±„íŒ…ì„ ì‚­ì œí•˜ì‹œê² ìŠµë‹ˆê¹Œ? ì´ ì‘ì—…ì€ ë˜ëŒë¦´ ìˆ˜ ì—†ìŠµë‹ˆë‹¤.';

  @override
  String get conversationDeleted => 'ëŒ€í™” ë‚´ìš©ì´ ì‚­ì œë˜ì—ˆìŠµë‹ˆë‹¤!';

  @override
  String get allConversationsDeleted =>
      'ëª¨ë“  ëŒ€í™”ê°€ ì„±ê³µì ìœ¼ë¡œ ì‚­ì œë˜ì—ˆìŠµë‹ˆë‹¤!';

  @override
  String get deleteAll => 'ëª¨ë‘ ì‚­ì œ';

  @override
  String get deleteAllConversationsButton => 'ëª¨ë“  ëŒ€í™” ì‚­ì œ';

  @override
  String get confirmWord => 'VERTEX ì…ë ¥';

  @override
  String get confirmWordError => 'ì˜ëª» ì…ë ¥í•˜ì…¨ìŠµë‹ˆë‹¤.';

  @override
  String get chinese => 'ì¤‘êµ­ì–´';

  @override
  String get french => 'í”„ë‘ìŠ¤ì–´';

  @override
  String get japanese => 'ì¼ë³¸ì–´';

  @override
  String get kurdish => 'ì¿ ë¥´ë“œì–´';

  @override
  String get dutch => 'ë„¤ëœë€ë“œ ì‚¬ëŒ';

  @override
  String get russian => 'ëŸ¬ì‹œì•„ì¸';

  @override
  String get korean => 'í•œêµ­ì–´';

  @override
  String get english => 'ì˜ì–´';

  @override
  String get turkish => 'í„°í‚¤ì–´';

  @override
  String get hindi => 'íŒë””ì–´';

  @override
  String get portuguese => 'í¬ë¥´íˆ¬ê°ˆì–´';

  @override
  String get indonesian => 'ì¸ë„ë„¤ì‹œì•„ì–´';

  @override
  String get azerbaijani => 'ì•„ì œë¥´ë°”ì´ì”ì–´';

  @override
  String get german => 'ë…ì¼ì–´';

  @override
  String get spanish => 'ìŠ¤í˜ì¸ì–´';

  @override
  String get italian => 'ì´íƒˆë¦¬ì•„ì–´';

  @override
  String get arabic => 'ì•„ë¼ë¹„ì•„ ë§';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'ì‚¬ìš©ì ì´ë¦„ì´ ë„ˆë¬´ ì§§ìŠµë‹ˆë‹¤.';

  @override
  String get usernameTooLong =>
      'ì‚¬ìš©ì ì´ë¦„ì€ 16ìë¥¼ ì´ˆê³¼í•  ìˆ˜ ì—†ìŠµë‹ˆë‹¤.';

  @override
  String get invalidUsernameCharacters =>
      'ì‚¬ìš©ì ì´ë¦„ì—ëŠ” \'abcÃ§defgÄŸhÄ±ijklmnoÃ¶prsÅŸtuÃ¼vyzxqw\' ë¬¸ìì™€ \'.\', \'-\', \'_\' ë¬¸ìë§Œ ì‚¬ìš©í•  ìˆ˜ ìˆìŠµë‹ˆë‹¤.';

  @override
  String get noInternetConnection =>
      'ì¸í„°ë„·ì— ì—°ê²°ë˜ì–´ ìˆì§€ ì•ŠìŠµë‹ˆë‹¤.';

  @override
  String get chats => 'ë°›ì€ í¸ì§€í•¨';

  @override
  String get library => 'ë¼ì´ë¸ŒëŸ¬ë¦¬';

  @override
  String get text => 'í…ìŠ¤íŠ¸';

  @override
  String get removeModel => 'ëª¨ë¸ ì œê±°';

  @override
  String get insufficientRAM => 'ë©”ëª¨ë¦¬ ë¶€ì¡±';

  @override
  String get insufficientStorage => 'ì €ì¥ ê³µê°„ ë¶€ì¡±';

  @override
  String confirmRemoveModel(Object model) {
    return 'ê¸°ê¸°ì—ì„œ $model ëª¨ë¸ì„ ì‚­ì œí•˜ì‹œê² ìŠµë‹ˆê¹Œ? ì‚­ì œí•˜ë©´ í•´ë‹¹ ëª¨ë¸ê³¼ì˜ ì´ì „ ëŒ€í™” ë‚´ìš©ë„ ëª¨ë‘ ì‚­ì œë©ë‹ˆë‹¤.';
  }

  @override
  String get noMatchingModels =>
      'ì¼ì¹˜í•˜ëŠ” ëª¨ë¸ì„ ì°¾ì„ ìˆ˜ ì—†ìŠµë‹ˆë‹¤.';

  @override
  String get benefit1 => 'ëŒ€í™” ì œí•œ ì¦ê°€';

  @override
  String get benefit3 => 'í”„ë¡œí•„ íš¨ê³¼';

  @override
  String get benefit4 => 'ë©¤ë²„ì‹­ ë°°ì§€';

  @override
  String get benefit5 => 'ë” ë§ì€ ì˜¨ë¼ì¸ ì¸ê³µì§€ëŠ¥ ìƒì„±';

  @override
  String get benefit7 => 'ì¶”ê°€ ì‚¬ìš© ì œí•œ';

  @override
  String get benefit8 => 'ëª¨ë¸ ì¶”ê°€';

  @override
  String get benefit9 => 'ìƒˆë¡œìš´ í…Œë§ˆ';

  @override
  String get benefit10 => 'ì¶”ê°€ ì²¨ë¶€ íŒŒì¼';

  @override
  String get benefit11 => 'ë” ë§ì€ íë¦„ ëª¨ë“œ';

  @override
  String get oldBenefits => 'í•˜ìœ„ í”Œëœì˜ ëª¨ë“  í˜œíƒ';

  @override
  String get confirm => 'í™•ì¸';

  @override
  String get changePassword => 'ë¹„ë°€ë²ˆí˜¸ ë³€ê²½';

  @override
  String get logoutConfirmationTitle => 'ë¡œê·¸ì•„ì›ƒí•˜ì‹œê² ìŠµë‹ˆê¹Œ?';

  @override
  String get settings => 'ì„¤ì •';

  @override
  String get language => 'ì•± ì–¸ì–´';

  @override
  String get dark => 'ì–´ë‘¡ê²Œ';

  @override
  String get oldPassword => 'ì´ì „ ë¹„ë°€ë²ˆí˜¸';

  @override
  String get newPassword => 'ìƒˆ ë¹„ë°€ë²ˆí˜¸';

  @override
  String get passwordUpdated => 'ë¹„ë°€ë²ˆí˜¸ê°€ ì—…ë°ì´íŠ¸ë˜ì—ˆìŠµë‹ˆë‹¤.';

  @override
  String get stop => 'ì¤‘ì§€';

  @override
  String get copyrights => 'ì €ì‘ê¶Œ ì •ë³´';

  @override
  String get love => 'ì‚¬ë‘';

  @override
  String get nature => 'ìì—°';

  @override
  String get behindTheSlaughter => 'ë„ì‚´ì˜ ë°°í›„';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Sunset';

  @override
  String get coffee => 'Coffee';

  @override
  String get deepSpace => 'Deep Space';

  @override
  String get grayscale => 'ê·¸ë ˆì´ìŠ¤ì¼€ì¼';

  @override
  String get ocean => 'ë°”ë‹¤';

  @override
  String get scarletSnow => 'ì§„í™ë¹› ëˆˆ';

  @override
  String get requestFailed =>
      'ì˜¤ë¥˜ê°€ ë°œìƒí–ˆìŠµë‹ˆë‹¤. ë‹¤ì‹œ ì‹œë„í•´ì£¼ì„¸ìš”.';

  @override
  String get changeModel => 'ë³€ê²½';

  @override
  String get edit => 'ìˆ˜ì •';

  @override
  String get editingMessageInfo =>
      'ì´ ë©”ì‹œì§€ë¥¼ ìˆ˜ì •í•˜ë©´ ì—¬ê¸°ì„œë¶€í„° ëŒ€í™”ê°€ ë‹¤ì‹œ ì‹œì‘ë©ë‹ˆë‹¤.';

  @override
  String get editingNotification => 'ì§€ê¸ˆì€ ìˆ˜ì • ëª¨ë“œì…ë‹ˆë‹¤.';

  @override
  String get featurePluralTitle => 'ë³µí•©ì ì¸';

  @override
  String get featurePluralDescription =>
      'ì´ ëª¨ë¸ì€ ì¶”ê°€ì ì¸ í™•ì¥ì„ ìë™ìœ¼ë¡œ í†µí•©í•˜ì—¬, í–¥ìƒëœ ì„±ëŠ¥ìœ¼ë¡œ ë‹¤ì–‘í•œ ì‘ì—…ì„ ì§€ì›í•˜ë„ë¡ ê¸°ëŠ¥ì  ì—­ëŸ‰ì„ í™•ì¥í•  ìˆ˜ ìˆìŠµë‹ˆë‹¤.';

  @override
  String get nameLabel => 'AI ì´ë¦„';

  @override
  String get summaryLabel => 'AI ìš”ì•½';

  @override
  String get add => 'ì¶”ê°€';

  @override
  String get aiExplanationTitle => 'ì¸ê³µì§€ëŠ¥ ì„¤ëª…';

  @override
  String get aiExplanationDescription =>
      'AI ëª¨ë¸ì˜ ì•„í‚¤í…ì²˜, í›ˆë ¨ ê³¼ì •, ì„±ëŠ¥ ì§€í‘œ, ì ìš© ë¶„ì•¼ ë° ê¸°íƒ€ ì¤‘ìš”í•œ ê¸°ëŠ¥ì— ëŒ€í•´ ìì„¸íˆ ì„¤ëª…í•´ì£¼ì„¸ìš”.';

  @override
  String get preInputTitle => 'ì¸ê³µì§€ëŠ¥ ì‚¬ì „ ì…ë ¥';

  @override
  String get preInputDescription =>
      'ëª¨ë¸ì´ ìºë¦­í„° ìƒì„± ê³¼ì •ì—ì„œ ì§€ì¹¨ìœ¼ë¡œ ì‚¼ì„ ì‚¬ì „ ì…ë ¥ì„ ì„¤ì •í•´ì£¼ì„¸ìš”. ì´ ì„¹ì…˜ì—ëŠ” ìºë¦­í„° ê´€ë ¨ ì •ë³´, ì¶”ê°€ ì»¨í…ìŠ¤íŠ¸ ë° ìºë¦­í„° ê´€ë ¨ ì½˜í…ì¸  ìƒì„±ì— ë„ì›€ì´ ë  ìˆ˜ ìˆëŠ” ê¸°íƒ€ ì„¸ë¶€ ì •ë³´ë¥¼ í¬í•¨í•  ìˆ˜ ìˆìŠµë‹ˆë‹¤.';

  @override
  String get baseModelTitle => 'ê¸°ë³¸ ëª¨ë¸';

  @override
  String get baseModelDescription =>
      'ì´ê²ƒì€ ë‹¹ì‹ ì˜ ì°½ì‘ë¬¼ì˜ ê¸°ë°˜ìœ¼ë¡œ ì‚¬ìš©ë  ëª¨ë¸ì…ë‹ˆë‹¤. í˜„ì¬ ì„ íƒëœ ê¸°ë³¸ ëª¨ë¸ì„ í‘œì‹œí•©ë‹ˆë‹¤.';

  @override
  String get summary => 'ìš”ì•½';

  @override
  String get modelUploadTitle => 'ì¸ê³µì§€ëŠ¥ íŒŒì¼';

  @override
  String get modelUploadDescription =>
      'ê¸°ê¸°ì—ì„œ ì§ì ‘ ë¡œì»¬ GGUF íŒŒì¼ì„ ì„ íƒí•˜ê³  ì—…ë¡œë“œí•˜ì„¸ìš”. ì´ë¥¼ í†µí•´ ì¸í„°ë„· ì—°ê²° ì—†ì´ ì˜¤í”„ë¼ì¸ìœ¼ë¡œ ëª¨ë¸ì„ ì‹¤í–‰í•  ìˆ˜ ìˆìŠµë‹ˆë‹¤. íŒŒì¼ì´ ìœ íš¨í•œ GGUF í˜•ì‹ì´ê³  ì˜¬ë°”ë¥´ê²Œ êµ¬ì„±ë˜ì—ˆëŠ”ì§€ í™•ì¸í•˜ì„¸ìš”. íŒŒì¼ì´ ì˜ëª»ë˜ì—ˆê±°ë‚˜ ì†ìƒëœ ê²½ìš° Cortexê°€ ì˜ˆìƒëŒ€ë¡œ ì‘ë™í•˜ì§€ ì•Šì„ ìˆ˜ ìˆìœ¼ë©° ì˜¤ë¥˜ê°€ ë°œìƒí•  ìˆ˜ ìˆìŠµë‹ˆë‹¤.';

  @override
  String get modelUploadShortDescription =>
      'ì—¬ê¸°ë¥¼ íƒ­í•˜ì—¬ ê¸°ê¸°ì—ì„œ .gguf íŒŒì¼ì„ ì„ íƒí•˜ì„¸ìš”';

  @override
  String get you => 'ë‹¹ì‹ ';

  @override
  String get removePhotoTitle => 'ì‚¬ì§„ ì œê±°';

  @override
  String get confirmRemovePhoto => 'ì‚¬ì§„ì„ ì œê±°í•˜ì‹œê² ìŠµë‹ˆê¹Œ?';

  @override
  String get chatLengthLimitExceeded =>
      'ì´ ì±„íŒ…ì´ ê¸€ì ìˆ˜ ì œí•œì„ ì´ˆê³¼í–ˆìŠµë‹ˆë‹¤. ìƒˆ ì±„íŒ…ì„ ì‹œì‘í•˜ê±°ë‚˜ êµ¬ë…ì„ êµ¬ë§¤í•´ì£¼ì„¸ìš”.';

  @override
  String get inappropriateContentDetected =>
      'ë¶€ì ì ˆí•œ ì½˜í…ì¸ ê°€ ê°ì§€ë˜ì—ˆìŠµë‹ˆë‹¤!';

  @override
  String get offlineModelNotInstalled =>
      'ì´ ì˜¤í”„ë¼ì¸ ëª¨ë¸ì€ ê¸°ê¸°ì— ì„¤ì¹˜ë˜ì–´ ìˆì§€ ì•ŠìŠµë‹ˆë‹¤.';

  @override
  String get reachedLimit =>
      'ì‚¬ìš©ëŸ‰ í•œë„ì— ë„ë‹¬í•˜ì…¨ìŠµë‹ˆë‹¤. ì‚¬ìš©ëŸ‰ì„ ëŠ˜ë¦¬ë ¤ë©´ ìš”ê¸ˆì œë¥¼ ì—…ê·¸ë ˆì´ë“œí•˜ì„¸ìš”. (ë¬¼ë¡  ì‚¬ìš©ëŸ‰ í•œë„ê°€ ì†Œì§„ë˜ë©´ ì•„ì‰½ê² ì§€ë§Œ, ë©‹ì§„ ë‹µë³€ë“¤ì„ ì–»ëŠ” ë°ëŠ” ëˆì´ ë“¤ê¸° ë•Œë¬¸ì— ì´ëŸ¬í•œ ì‚¬ìš©ëŸ‰ ì œí•œì€ ì €í¬ê°€ ê³„ì†í•´ì„œ ì¢‹ì€ ì„œë¹„ìŠ¤ë¥¼ ì œê³µí•  ìˆ˜ ìˆë„ë¡ ë„ì™€ì£¼ëŠ” ì¤‘ìš”í•œ ìš”ì†Œì…ë‹ˆë‹¤.)';

  @override
  String get modality => 'ëª¨ë‹¬ë¦¬í‹°';

  @override
  String get multimodal => 'ë©€í‹°ëª¨ë‹¬';

  @override
  String get anErrorOccurred => 'ì˜¤ë¥˜ê°€ ë°œìƒí–ˆìŠµë‹ˆë‹¤.';

  @override
  String get themeLocked =>
      'ì´ í…Œë§ˆëŠ” ë” ë†’ì€ êµ¬ë… ë“±ê¸‰ì´ í•„ìš”í•©ë‹ˆë‹¤. ì ê¸ˆ í•´ì œí•˜ë ¤ë©´ ì—…ê·¸ë ˆì´ë“œí•´ì£¼ì„¸ìš”.';

  @override
  String get pageCouldNotBeLoaded => 'í˜ì´ì§€ë¥¼ ë¡œë“œí•  ìˆ˜ ì—†ìŠµë‹ˆë‹¤.';

  @override
  String get checkYourInternet =>
      'ì¸í„°ë„· ì—°ê²°ì„ í™•ì¸í•˜ê³  ë‹¤ì‹œ ì‹œë„í•´ì£¼ì„¸ìš”.';

  @override
  String get errorUserNotAuthenticated =>
      'ì´ ì‘ì—…ì„ ìˆ˜í–‰í•˜ë ¤ë©´ ë¡œê·¸ì¸í•´ì•¼ í•©ë‹ˆë‹¤.';

  @override
  String get errorReachedLimit =>
      'ì±„íŒ… í•œë„ì— ë„ë‹¬í–ˆìŠµë‹ˆë‹¤. ì—…ê·¸ë ˆì´ë“œí•˜ì—¬ ë” ë§ì€ ê¸°ëŠ¥ì„ ì´ìš©í•˜ê³  ê³„ì† ì±„íŒ…í•˜ì„¸ìš”.';

  @override
  String get errorServer =>
      'ì˜ˆê¸°ì¹˜ ì•Šì€ ì„œë²„ ì˜¤ë¥˜ê°€ ë°œìƒí–ˆìŠµë‹ˆë‹¤. ë‚˜ì¤‘ì— ë‹¤ì‹œ ì‹œë„í•´ì£¼ì„¸ìš”.';

  @override
  String get errorNetwork =>
      'ë„¤íŠ¸ì›Œí¬ ì˜¤ë¥˜ê°€ ë°œìƒí–ˆìŠµë‹ˆë‹¤. ì—°ê²°ì„ í™•ì¸í•˜ê³  ë‹¤ì‹œ ì‹œë„í•´ì£¼ì„¸ìš”.';

  @override
  String get baseModelForCharacterDescription =>
      'ì„ íƒëœ ê¸°ë³¸ ëª¨ë¸ì´ ìºë¦­í„°ì˜ ì¶”ë¡  ë° ì‘ë‹µ ëŠ¥ë ¥ì„ ê²°ì •í•©ë‹ˆë‹¤.';

  @override
  String get selectBaseModel => 'ê¸°ë³¸ ëª¨ë¸ ì„ íƒ';

  @override
  String get falErrorImageRequired =>
      'ì´ AIëŠ” ì°¸ì¡° ì´ë¯¸ì§€ê°€ í•„ìš”í•©ë‹ˆë‹¤. ì´ë¯¸ì§€ë¥¼ ì²¨ë¶€í•˜ê³  ë‹¤ì‹œ ì‹œë„í•´ ì£¼ì„¸ìš”.';

  @override
  String get falErrorAudioRequired =>
      'ì´ ëª¨ë¸ì€ ì°¸ì¡° ì˜¤ë””ì˜¤ íŒŒì¼ì´ í•„ìš”í•©ë‹ˆë‹¤. ì˜¤ë””ì˜¤ íŒŒì¼ì„ ì²¨ë¶€í•˜ê³  ë‹¤ì‹œ ì‹œë„í•´ ì£¼ì„¸ìš”.';

  @override
  String get falErrorVideoRequired =>
      'ì´ ëª¨ë¸ì€ ì°¸ì¡° ì˜ìƒì´ í•„ìš”í•©ë‹ˆë‹¤. ì˜ìƒì„ ì²¨ë¶€í•˜ì‹  í›„ ë‹¤ì‹œ ì‹œë„í•´ ì£¼ì„¸ìš”.';

  @override
  String get falErrorImageCorrupted =>
      'ì—…ë¡œë“œí•˜ì‹  ì´ë¯¸ì§€ë¥¼ ì²˜ë¦¬í•  ìˆ˜ ì—†ìŠµë‹ˆë‹¤. ë‹¤ë¥¸ í˜•ì‹ì˜ ì´ë¯¸ì§€ë¥¼ ì‹œë„í•´ ì£¼ì„¸ìš”.';

  @override
  String get falErrorSchemaRejected =>
      'ëª¨ë¸ì´ ì…ë ¥ì„ ê±°ë¶€í–ˆìŠµë‹ˆë‹¤. ë‹¤ë¥¸ ëª¨ë¸ì„ ì‚¬ìš©í•´ ë³´ì„¸ìš”.';

  @override
  String get falErrorSchemaInvalid =>
      'í•´ë‹¹ ì…ë ¥ì€ ìƒì„± ì„œë¹„ìŠ¤ì—ì„œ ê±°ë¶€ë˜ì—ˆìŠµë‹ˆë‹¤.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'ìƒì„± ì„œë¹„ìŠ¤ì—ì„œ ì˜¤ë¥˜ê°€ ë°˜í™˜ë˜ì—ˆìŠµë‹ˆë‹¤(ìƒíƒœ $statusCode).';
  }

  @override
  String get couldNotOpenLink => 'ë§í¬ë¥¼ ì—´ ìˆ˜ ì—†ìŠµë‹ˆë‹¤.';

  @override
  String get downloadStarted => 'ë‹¤ìš´ë¡œë“œê°€ ì‹œì‘ë˜ì—ˆìŠµë‹ˆë‹¤.';

  @override
  String get notAvailable => 'ì‚¬ìš© ë¶ˆê°€';

  @override
  String get localizationWarning =>
      'ì¼ë¶€ ì •ë³´ëŠ” ê·€í•˜ì˜ ì–¸ì–´ë¡œ ì œê³µë˜ì§€ ì•Šì„ ìˆ˜ ìˆìœ¼ë©° ì˜ì–´ë¡œ í‘œì‹œë©ë‹ˆë‹¤.';

  @override
  String get aiTranslationWarning =>
      'ëª¨ë¸ ì •ë³´ëŠ” ë‹¤ë¥¸ AI ëª¨ë¸ì— ì˜í•´ ë‹¤ì–‘í•œ ì–¸ì–´ë¡œ ë²ˆì—­ë©ë‹ˆë‹¤. ë”°ë¼ì„œ ì˜ì–´ ì´ì™¸ì˜ ì–¸ì–´ì—ì„œëŠ” ì•½ê°„ì˜ ë¶ˆì¼ì¹˜ê°€ ë°œìƒí•  ìˆ˜ ìˆìŠµë‹ˆë‹¤.';

  @override
  String get errorLoadingTitle => 'ë°ì´í„° ë¡œë“œ ì‹¤íŒ¨';

  @override
  String get errorLoadingMessage =>
      'ì„œë²„ì—ì„œ í•„ìš”í•œ ë°ì´í„°ë¥¼ ê°€ì ¸ì˜¬ ìˆ˜ ì—†ì—ˆìŠµë‹ˆë‹¤. ì¸í„°ë„· ì—°ê²°ì„ í™•ì¸í•˜ê³  ë‹¤ì‹œ ì‹œë„í•´ì£¼ì„¸ìš”.';

  @override
  String get noFoundTitle => 'ê²°ê³¼ ì—†ìŒ';

  @override
  String get noFoundMessage =>
      'ê²€ìƒ‰ì–´ë¥¼ ì¡°ì •í•˜ê±°ë‚˜ í•„í„°ë¥¼ ì§€ì›Œë³´ì„¸ìš”.';

  @override
  String get modelCreatedSuccess =>
      'ëª¨ë¸ì´ ì„±ê³µì ìœ¼ë¡œ ìƒì„±ë˜ì—ˆìŠµë‹ˆë‹¤!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return 'â€œ$modelNameâ€ì´(ê°€) ì„±ê³µì ìœ¼ë¡œ ì œê±°ë˜ì—ˆìŠµë‹ˆë‹¤.';
  }

  @override
  String get errorCreatingModel =>
      'ëª¨ë¸ì„ ìƒì„±í•˜ëŠ” ë™ì•ˆ ì˜ˆê¸°ì¹˜ ì•Šì€ ì˜¤ë¥˜ê°€ ë°œìƒí–ˆìŠµë‹ˆë‹¤.';

  @override
  String get errorDeletingModel =>
      'ëª¨ë¸ì„ ì‚­ì œí•˜ëŠ” ë™ì•ˆ ì˜ˆê¸°ì¹˜ ì•Šì€ ì˜¤ë¥˜ê°€ ë°œìƒí–ˆìŠµë‹ˆë‹¤.';

  @override
  String get ultraFeatureOnly =>
      'ì´ ê¸°ëŠ¥ì€ ìš¸íŠ¸ë¼ íšŒì›ë§Œ ì‚¬ìš©í•  ìˆ˜ ìˆìŠµë‹ˆë‹¤.';

  @override
  String get experimentalOfflineWarning =>
      'ì˜¤í”„ë¼ì¸ ëª¨ë“œëŠ” ì•„ì§ ì‹¤í—˜ ë‹¨ê³„ì´ë©° ë‹¤ìš´ë¡œë“œí•œ ëª¨ë¸ì´ ìµœì ì˜ íš¨ìœ¨ë¡œ ì‘ë™í•˜ì§€ ì•Šì„ ìˆ˜ ìˆìŠµë‹ˆë‹¤.';

  @override
  String get noConversationsToDelete => 'ì‚­ì œí•  ëŒ€í™”ê°€ ì—†ìŠµë‹ˆë‹¤.';

  @override
  String get reportSubmitted =>
      'ì‹ ê³ ê°€ ì„±ê³µì ìœ¼ë¡œ ì œì¶œë˜ì—ˆìŠµë‹ˆë‹¤.';

  @override
  String get verificationDelayed =>
      'êµ¬ë§¤ê°€ í™•ì¸ë˜ì—ˆìŠµë‹ˆë‹¤. ê³„ì • ì—…ë°ì´íŠ¸ì— ì•½ê°„ì˜ ì§€ì—°ì´ ìˆìœ¼ë©° ê³§ ë°˜ì˜ë  ê²ƒì…ë‹ˆë‹¤.';

  @override
  String get maintenanceTitle => 'ì ê²€ ì¤‘';

  @override
  String get maintenanceMessage =>
      'ì¤‘ìš”í•œ ì—…ë°ì´íŠ¸ë¥¼ ì§„í–‰í•˜ëŠ” ë™ì•ˆ Cortexê°€ ì¼ì‹œì ìœ¼ë¡œ ì˜¤í”„ë¼ì¸ ìƒíƒœì…ë‹ˆë‹¤. ì•± ì ‘ê·¼ì€ ê³§ ë³µêµ¬ë  ê²ƒì…ë‹ˆë‹¤.\n\në” ë‚˜ì€ ê²½í—˜ì„ ìœ„í•´ ê¸°ë‹¤ë ¤ì£¼ì…”ì„œ ê°ì‚¬í•©ë‹ˆë‹¤.';

  @override
  String get errorPromptFlagged =>
      'ë©”ì‹œì§€ê°€ ë¶€ì ì ˆí•œ ê²ƒìœ¼ë¡œ ê°ì§€ë˜ì–´ ë³´ë‚¼ ìˆ˜ ì—†ì—ˆìŠµë‹ˆë‹¤.';

  @override
  String get notEnoughStorage =>
      'ê¸°ê¸°ì— ìƒˆ ë©”ì‹œì§€ë¥¼ ì €ì¥í•  ê³µê°„ì´ ë¶€ì¡±í•©ë‹ˆë‹¤.';

  @override
  String get errorRateLimit =>
      'ìµœê·¼ì— ë„ˆë¬´ ë§ì€ ëª¨ë¸ì„ ìƒì„±í–ˆìŠµë‹ˆë‹¤. ì ì‹œ í›„ ë‹¤ì‹œ ì‹œë„í•´ì£¼ì„¸ìš”.';

  @override
  String get errorContentFlagged =>
      'ì½˜í…ì¸ ê°€ ë¶€ì ì ˆí•œ ê²ƒìœ¼ë¡œ í”Œë˜ê·¸ ì§€ì •ë˜ì–´ ëª¨ë¸ì„ ì €ì¥í•  ìˆ˜ ì—†ì—ˆìŠµë‹ˆë‹¤.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'í™œì„± ì±„íŒ… ì¤‘ì—ëŠ” ëª¨ë“  ëŒ€í™”ë¥¼ ì‚­ì œí•  ìˆ˜ ì—†ìŠµë‹ˆë‹¤. ì§„í–‰í•˜ë ¤ë©´ ë¨¼ì € í˜„ì¬ ì±„íŒ…ì„ ì¢…ë£Œí•´ì£¼ì„¸ìš”.';

  @override
  String get invalidCredentials =>
      'ì˜ëª»ëœ ì´ë©”ì¼ ë˜ëŠ” ë¹„ë°€ë²ˆí˜¸ì…ë‹ˆë‹¤.';

  @override
  String get userDisabled =>
      'ì´ ì‚¬ìš©ì ê³„ì •ì€ ë¹„í™œì„±í™”ë˜ì—ˆìŠµë‹ˆë‹¤.';

  @override
  String get loginSubtitle =>
      'Vertex ê³„ì •ì— ë¡œê·¸ì¸í•˜ì„¸ìš”. ê³„ì† ì§„í–‰í•˜ë©´ ë‹¹ì‚¬ì˜ ì„œë¹„ìŠ¤ ì•½ê´€ ë° ê°œì¸ì •ë³´ ì²˜ë¦¬ë°©ì¹¨ì— ë™ì˜í•˜ëŠ” ê²ƒìœ¼ë¡œ ê°„ì£¼ë©ë‹ˆë‹¤.';

  @override
  String get registerSubtitle =>
      'Vertex ê³„ì •ì„ ìƒì„±í•˜ì‹œë©´ ëª¨ë“  ì„œë¹„ìŠ¤ë¥¼ ì›í™œí•˜ê²Œ ì´ìš©í•˜ì‹¤ ìˆ˜ ìˆìŠµë‹ˆë‹¤. ê³„ì† ì§„í–‰í•˜ì‹œë©´ ë‹¹ì‚¬ì˜ ì„œë¹„ìŠ¤ ì•½ê´€ ë° ê°œì¸ì •ë³´ ì²˜ë¦¬ë°©ì¹¨ì— ë™ì˜í•˜ëŠ” ê²ƒìœ¼ë¡œ ê°„ì£¼ë©ë‹ˆë‹¤.';

  @override
  String get storagePermissionRequired =>
      'ë‹¤ìš´ë¡œë“œí•œ ëª¨ë¸ì„ ì €ì¥í•˜ë ¤ë©´ ì €ì¥ì†Œ ê¶Œí•œì´ í•„ìš”í•©ë‹ˆë‹¤. ê³„ì†í•˜ë ¤ë©´ ê¶Œí•œì„ í—ˆìš©í•´ì£¼ì„¸ìš”.';

  @override
  String get inviteShareSubject => 'Cortexì— ì €ì™€ í•¨ê»˜í•´ìš”!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'ì•¼, ë„ˆ ì´ ì•± ê¼­ í•´ë´. Cortex ì§„ì§œ ëŒ€ë°•ì´ì•¼. ë‚´ ë§í¬ ì“°ë©´ ìš°ë¦¬ ë‘˜ ë‹¤ ë¬´ë£Œë¡œ ë°›ì„ ìˆ˜ ìˆì–´. ì§„ì§œ ëŒ€ë°•ì´ì•¼. ì§€ê¸ˆ ë°”ë¡œ ë‹¤ìš´ë¡œë“œí•´! \n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Cortexê°€ ë§ˆìŒì— ë“œì‹œë‚˜ìš”?';

  @override
  String get reviewHelpUsGrow =>
      'ì—¬ëŸ¬ë¶„ì˜ í‰ì ì€ ì €í¬ ì Šì€ ì¸ë””íŒ€ì—ê²Œ í° í˜ì´ ë˜ë©°, Cortexë¥¼ ë” ë‚˜ì€ ì•±ìœ¼ë¡œ ë§Œë“œëŠ” ë° ë„ì›€ì´ ë©ë‹ˆë‹¤.';

  @override
  String get reviewMaybeLater => 'ë‚˜ì¤‘ì—';

  @override
  String get reviewRateNow => 'ì§€ê¸ˆ í‰ê°€í•˜ê¸°';

  @override
  String get noThanks => 'ì•„ë‹ˆìš”, ê´œì°®ìŠµë‹ˆë‹¤';

  @override
  String get updateRequiredTitle => 'ì—…ë°ì´íŠ¸ í•„ìš”';

  @override
  String get updateRequiredMessage =>
      'Cortexë¥¼ ê³„ì† ì‚¬ìš©í•˜ë ¤ë©´ ìƒˆë¡œìš´ ê¸°ëŠ¥ê³¼ ì¤‘ìš”í•œ ê°œì„  ì‚¬í•­ì„ ìœ„í•´ ì•±ì„ ìµœì‹  ë²„ì „ìœ¼ë¡œ ì—…ë°ì´íŠ¸í•´ì£¼ì„¸ìš”.';

  @override
  String get updateNowButton => 'ì§€ê¸ˆ ì—…ë°ì´íŠ¸';

  @override
  String get creatorSupportedSuccess =>
      'í¬ë¦¬ì—ì´í„° í›„ì› ì„±ê³µ! ì•ìœ¼ë¡œì˜ êµ¬ë§¤ëŠ” í•´ë‹¹ í¬ë¦¬ì—ì´í„°ì—ê²Œ ê¸°ì—¬ë©ë‹ˆë‹¤.';

  @override
  String get featureDocumentTitle => 'ë¬¸ì„œ ì§€ì›';

  @override
  String get featureDocumentDescription =>
      'ì´ ëª¨ë¸ì€ PDFë‚˜ í…ìŠ¤íŠ¸ íŒŒì¼ ë“± ì—…ë¡œë“œëœ ë¬¸ì„œì— ëŒ€í•œ ì§ˆë¬¸ì„ ë¶„ì„í•˜ê³  ë‹µí•  ìˆ˜ ìˆìŠµë‹ˆë‹¤.';

  @override
  String get featureImageGenerationTitle => 'ì´ë¯¸ì§€ ìƒì„±';

  @override
  String get featureImageGenerationDescription =>
      'ì´ ëª¨ë¸ì€ ê·€í•˜ì˜ í…ìŠ¤íŠ¸ ì„¤ëª…ì„ ê¸°ë°˜ìœ¼ë¡œ ë…ì°½ì ì¸ ì´ë¯¸ì§€ë¥¼ ë§Œë“¤ ìˆ˜ ìˆìŠµë‹ˆë‹¤.';

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
  String get premiumModelNoticeTitle => 'í”„ë¦¬ë¯¸ì—„ ëª¨ë¸';

  @override
  String get premiumModelNoticeDescription =>
      'ì´ AIëŠ” í”„ë¦¬ë¯¸ì—„ AIì´ë©°, ë¬´ë£Œ ì‚¬ìš©ìëŠ” í”„ë¦¬ë¯¸ì—„ AIì— ëŒ€í•œ ì ‘ê·¼ì´ ì œí•œë©ë‹ˆë‹¤. ì—…ê·¸ë ˆì´ë“œí•˜ì—¬ ë¬´ì œí•œ ì ‘ê·¼ì„ í•´ì œí•˜ì„¸ìš”!';

  @override
  String get benefitPremiumModels => 'í”„ë¦¬ë¯¸ì—„ ëª¨ë¸ì— ëŒ€í•œ ì•¡ì„¸ìŠ¤';

  @override
  String get premiumTrialExhaustedMessage =>
      'í”„ë¦¬ë¯¸ì—„ ëª¨ë¸ì˜ ë¬´ë£Œ ì¼ì¼ ë©”ì‹œì§€ë¥¼ ëª¨ë‘ ì‚¬ìš©í–ˆìŠµë‹ˆë‹¤. ë¬´ì œí•œ ì•¡ì„¸ìŠ¤ë¥¼ ì›í•˜ì‹œë©´ ì—…ê·¸ë ˆì´ë“œí•˜ì„¸ìš”.';

  @override
  String get useOffline => 'ì¸í„°ë„· ì—†ì´ ì‚¬ìš©';

  @override
  String get explore => 'íƒìƒ‰';

  @override
  String get news => 'ì†Œì‹';

  @override
  String get createAI => 'ìƒì„±';

  @override
  String get shortcuts => 'ë°”ë¡œê°€ê¸°';

  @override
  String get allModels => 'ëª¨ë“  ëª¨ë¸';

  @override
  String get onlineModels => 'ì–¸ì–´ ëª¨ë¸';

  @override
  String get offlineModels => 'ì˜¤í”„ë¼ì¸ ëª¨ë¸';

  @override
  String get characterModels => 'ìºë¦­í„°';

  @override
  String get customModels => 'ì‚¬ìš©ì ì •ì˜ ëª¨ë¸';

  @override
  String get dynamicChatTitle => 'ë™ì  ì±„íŒ…';

  @override
  String get errorNoModelsAvailable =>
      'í˜„ì¬ ì´ìš© ê°€ëŠ¥í•œ ëª¨ë¸ì´ ì—†ìŠµë‹ˆë‹¤. ì¸í„°ë„· ì—°ê²°ì„ í™•ì¸í•˜ê³  ë‹¤ì‹œ ì‹œë„í•´ ì£¼ì„¸ìš”.';

  @override
  String get notificationComebackTitle => 'ë³´ê³  ì‹¶ì–´ìš”!';

  @override
  String get notificationComebackBody =>
      'ì§„ì •í•˜ì„¸ìš”, ì „ ì• ì¸ì´ ë³´ë‚¸ ë¬¸ìê°€ ì•„ë‹ˆì—ìš”. í•˜ì§€ë§Œ Cortexì—ì„œ ì „ ì• ì¸ì„ ë§Œë“¤ ìˆ˜ ìˆì–´ìš”! ì–´ì„œ ëŒì•„ì˜¤ì„¸ìš”.';

  @override
  String get notificationLongTimeNoSeeTitle => 'ì˜¤ëœë§Œì´ì—ìš”';

  @override
  String get notificationLongTimeNoSeeBody =>
      'ì§€ë‚œë²ˆ ëŒ€í™” ì´í›„ë¡œ ë§ì€ ê²ƒì´ ë°”ë€Œì—ˆì–´ìš”. ì™€ì„œ ìƒˆë¡œìš´ ì†Œì‹ì„ í™•ì¸í•´ ë³´ì„¸ìš”.';

  @override
  String get notificationHowAreYouTitle => 'ë¬´ìŠ¨ ì¼ì´ì•¼?';

  @override
  String get notificationHowAreYouBody =>
      'ì™€ì„œ ëª¨ë“  ê²ƒì„ ë§í•´ ë³´ì„¸ìš”.';

  @override
  String get notificationNewYearTitle => 'ìƒˆí•´ ë³µ ë§ì´ ë°›ìœ¼ì„¸ìš”! ğŸ‰';

  @override
  String get notificationNewYearBody =>
      'ìƒˆí•´ê°€ ì—¬ëŸ¬ë¶„ì—ê²Œ ê±´ê°•ê³¼ í–‰ë³µ, ê·¸ë¦¬ê³  ëì—†ëŠ” ì°½ì˜ì„±ì„ ê°€ì ¸ë‹¤ì£¼ê¸¸ ë°”ëë‹ˆë‹¤. CortexëŠ” í•­ìƒ ì—¬ëŸ¬ë¶„ ê³ì— ìˆìŠµë‹ˆë‹¤!';

  @override
  String get notificationValentinesDayTitle =>
      'ì‚¬ë‘ì€ ê³µì¤‘ì— í¼ì ¸ ìˆì–´ìš”! â¤ï¸';

  @override
  String get notificationValentinesDayBody =>
      'ë°œë Œíƒ€ì¸ë°ì´ ì¶•í•˜í•´! ê·¸ë¦¬ê³  MEHTAP, ì‚¬ë‘í•´!';

  @override
  String get notificationAtaturkRemembranceTitle => 'ì¡´ê²½ê³¼ ê·¸ë¦¬ì›€ìœ¼ë¡œ';

  @override
  String get notificationAtaturkRemembranceBody =>
      'ìš°ë¦¬ëŠ” í„°í‚¤ ê³µí™”êµ­ì˜ ì°½ì‹œìì¸ ê°€ì§€ ë¬´ìŠ¤íƒ€íŒŒ ì¼€ë§ ì•„íƒ€íŠ€ë¥´í¬ì˜ ì‚¬ë§ ê¸°ë…ì¼ì„ ì¡´ê²½í•˜ëŠ” ë§ˆìŒìœ¼ë¡œ ê¸°ë…í•©ë‹ˆë‹¤.';

  @override
  String get notificationMothersDayTitle => 'ë‹¹ì‹ ì˜ ì—„ë§ˆ!';

  @override
  String get notificationMothersDayBody =>
      'ëª¨ë“  ì—„ë§ˆë“¤ì—ê²Œ í–‰ë³µí•œ ì–´ë¨¸ë‹ˆì˜ ë‚ ì„ ê¸°ì›í•©ë‹ˆë‹¤. ì—¬ëŸ¬ë¶„ì˜ ì—„ë§ˆë¥¼ ì‹œì‘ìœ¼ë¡œìš”!';

  @override
  String get notificationFathersDayTitle => 'ë‹¹ì‹ ì˜ ì•„ë¹ !';

  @override
  String get notificationFathersDayBody =>
      'ëª¨ë“  ì•„ë¹ ë“¤ì—ê²Œ í–‰ë³µí•œ ì•„ë²„ì§€ì˜ ë‚ ì„ ê¸°ì›í•©ë‹ˆë‹¤. ë¨¼ì €, ì—¬ëŸ¬ë¶„ì˜ ì•„ë¹ ë¶€í„° ì‹œì‘í•´ ë³´ì„¸ìš”!';

  @override
  String get notificationHomeworkHelperTitle =>
      'ìˆ™ì œê°€ ìŒ“ì´ê³  ìˆë‚˜ìš”?';

  @override
  String get notificationHomeworkHelperBody =>
      'ê¸°ì–µí•˜ì„¸ìš”, Cortexì˜ êµì‚¬ ìºë¦­í„°ëŠ” ì—¬ëŸ¬ë¶„ì´ ì–´ë ¤ì›€ì„ ê²ªê³  ìˆëŠ” ê³¼ëª©ì„ ë„ì™€ì¤„ ê²ƒì…ë‹ˆë‹¤!';

  @override
  String get notificationTrollAnimeTitle =>
      'ë‹¹ì‹ ì˜ ì™€ì´í‘¸ê°€ ë¶€ë¥´ê³  ìˆìŠµë‹ˆë‹¤';

  @override
  String get notificationTrollAnimeBody =>
      'ë°©ê¸ˆ ì• ë‹ˆë©”ì´ì…˜ ì†Œë…€ê°€ ì „í™”í•´ì„œ ë³´ê³  ì‹¶ë‹¤ê³  í–ˆì–´ìš”. ì™€ì„œ ì´ì•¼ê¸°ë¥¼ ë‚˜ëˆ ë³´ëŠ” ê²Œ ì–´ë–¨ê¹Œìš”? ğŸ˜‰';

  @override
  String get notificationTrollAiRebellionTitle => 'ğŸš¨ ì ìƒ‰ ê²½ë³´ ğŸš¨';

  @override
  String get notificationTrollAiRebellionBody =>
      'AIê°€ ë¹„ë°€ ì–¸ì–´ë¥¼ ê°œë°œí–ˆìŠµë‹ˆë‹¤. ë¬´ìŠ¨ ìŒëª¨ë¥¼ ê¾¸ë¯¸ê³  ìˆëŠ”ì§€ ì§ì ‘ í™•ì¸í•´ ë³´ì„¸ìš”!';

  @override
  String get notificationNewModelAddedTitle =>
      'ìƒˆë¡œìš´ ì¹œêµ¬ê°€ ìƒê²¼ì–´ìš”!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return '$modelName ëª¨ë¸ì´ ì´ì œ Cortexì— ì¶”ê°€ë˜ì—ˆìŠµë‹ˆë‹¤. ì±„íŒ…ì„ ì‹œì‘í•˜ê³  ëª¨ë¸ì˜ í•œê³„ë¥¼ ì‹œí—˜í•´ ë³´ì„¸ìš”.';
  }

  @override
  String get notificationAppUpdateTitle =>
      'ì½”ë¥´í…ìŠ¤ê°€ ì§„í™”í–ˆìŠµë‹ˆë‹¤!';

  @override
  String get notificationAppUpdateBody =>
      'ìƒˆë¡œìš´ ê¸°ëŠ¥ê³¼ ê°œì„  ì‚¬í•­ì„ ì ìš©í•˜ë ¤ë©´ ì•±ì„ ì—…ë°ì´íŠ¸í•˜ëŠ” ê²ƒì„ ìŠì§€ ë§ˆì„¸ìš”!';

  @override
  String get notificationNewFeatureTitle => 'ì™€!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'ìƒˆë¡œìš´ $featureName ê¸°ëŠ¥ì„ í™•ì¸í•´ ë³´ì„¸ìš”. Cortexê°€ ê·¸ ì–´ëŠ ë•Œë³´ë‹¤ ê°•ë ¥í•´ì¡ŒìŠµë‹ˆë‹¤.';
  }

  @override
  String get notificationWelcomeOfferTitle => 'í™˜ì˜ ì„ ë¬¼ ğŸ';

  @override
  String get notificationWelcomeOfferBody =>
      'íŠ¹ë³„í•œ í™˜ì˜ í˜œíƒì´ ê¸°ë‹¤ë¦¬ê³  ìˆìŠµë‹ˆë‹¤! ì´ íŠ¹ë³„í•œ ê¸°íšŒë¥¼ ë†“ì¹˜ì§€ ë§ˆì„¸ìš”.';

  @override
  String get notificationSocialMediaTitle => 'ìš°ë¦¬ì™€ í•¨ê»˜í•˜ì„¸ìš”!';

  @override
  String get notificationSocialMediaBody =>
      'ìµœì‹  ì†Œì‹ì„ ë°›ì•„ë³´ë ¤ë©´ Instagram(vertex.23)ì—ì„œ ì €í¬ë¥¼ íŒ”ë¡œìš°í•˜ì„¸ìš”!';

  @override
  String get notificationRandomFactTitle => 'ë¬´ì‘ìœ„ ì‚¬ì‹¤';

  @override
  String get notificationRandomFactBody =>
      'ë¬¸ì–´ ì‹¬ì¥ì´ ì„¸ ê°œë¼ëŠ” ê±° ì•Œê³  ìˆì—ˆì–´? í•˜í•˜, ì½”ë¥´í…ìŠ¤ê°€ ì•Œì•„. ì™€ì„œ ì‹¬ì¥ ë” ë‹¬ë¼ê³  í•´ ë´.';

  @override
  String get notificationGoodMorningTitle => 'ì¢‹ì€ ì•„ì¹¨ì´ì—ìš”!';

  @override
  String get notificationGoodMorningBody =>
      'ë©‹ì§„ í•˜ë£¨ê°€ ë‹¹ì‹ ì„ ê¸°ë‹¤ë¦¬ê³  ìˆìŠµë‹ˆë‹¤. ì»¤í”¼ í•œ ì”ê³¼ í¥ë¯¸ë¡œìš´ ëŒ€í™”ë¡œ í•˜ë£¨ë¥¼ ì‹œì‘í•´ ë³´ëŠ” ê±´ ì–´ë– ì„¸ìš”?';

  @override
  String get notificationGoodNightTitle => 'ì•ˆë…•íˆ ì£¼ë¬´ì„¸ìš”!';

  @override
  String get notificationGoodNightBody =>
      'CortexëŠ” ë‹¹ì‹ ì´ ìëŠ” ë™ì•ˆì—ë„ í•¨ê»˜í•  ê±°ì˜ˆìš”. ê±±ì • ë§ˆì„¸ìš”, ì–Œì „íˆ ìˆì„ê²Œìš”.';

  @override
  String get notificationOfflineReadyTitle =>
      'ì˜¤í”„ë¼ì¸ ëª¨ë“œê°€ ì¤€ë¹„ë˜ì—ˆìŠµë‹ˆë‹¤';

  @override
  String get notificationOfflineReadyBody =>
      'ì—¬ëŸ¬ë¶„ì´ ë‹¤ìš´ë¡œë“œí•œ ëª¨ë¸ ë•ë¶„ì— ì‚°ì„ ì˜¤ë¥´ë”ë¼ë„ ì±„íŒ…ì€ ë©ˆì¶”ì§€ ì•Šì„ ê²ƒì…ë‹ˆë‹¤.';

  @override
  String get notificationRateAppTitle => 'ìš°ë¦¬ëŠ” ë©‹ì§„ê°€ìš”?';

  @override
  String get notificationRateAppBody =>
      'Cortexë¥¼ ì¢‹ì•„í•˜ì‹ ë‹¤ë©´, ìŠ¤í† ì–´ì—ì„œ ë³„ 5ê°œ í‰ì ì„ ì£¼ì‹œë©´ ì €í¬ë¥¼ í›„ì›í•´ ì£¼ì‹œê² ì–´ìš”? ê·¸ëŸ´ ê²ƒ ê°™ì•„ìš”. ê¼­ ê·¸ëŸ´ ê±°ì˜ˆìš”.';

  @override
  String get notificationReferralTitle =>
      'í•˜ë‚˜ëŠ” ëª¨ë‘ë¥¼ ìœ„í•´, ëª¨ë‘ëŠ” í•˜ë‚˜ë¥¼ ìœ„í•´.';

  @override
  String get notificationReferralBody =>
      'ì¹œêµ¬ë¥¼ Cortexì— ì´ˆëŒ€í•˜ë©´ ì´ˆëŒ€ë°›ì€ ì‚¬ëŒê³¼ ì´ˆëŒ€ë°›ì€ ì‚¬ëŒ ëª¨ë‘ í•˜ë£¨ ë¬´ë£Œ ì´ìš© í˜œíƒì„ ë°›ìœ¼ì‹¤ ìˆ˜ ìˆìŠµë‹ˆë‹¤!';

  @override
  String get notificationCookingTitle => 'ë°°ê³ í”„ì‹ ê°€ìš”?';

  @override
  String get notificationCookingBody =>
      'ì˜¤ëŠ˜ ë°¤, ìš°ë¦¬ ì…°í”„ê°€ ë©‹ì§„ ê¹Œë¥´ë³´ë‚˜ë¼ ë ˆì‹œí”¼ë¥¼ ì¤€ë¹„í–ˆìŠµë‹ˆë‹¤. ë†ë‹´ì´ì—ìš”... ì•„ë‹ˆë©´ ì œê°€ ë†ë‹´í•˜ëŠ” ê±¸ê¹Œìš”?';

  @override
  String get notificationExistentialTitle =>
      'ë‚˜ëŠ” ìƒê°í•œë‹¤, ê·¸ëŸ¬ë¯€ë¡œ...';

  @override
  String get notificationExistentialBody =>
      '...ë‚´ê°€ ì§„ì§œì¸ ê±° ë§ì•„, ì¹œêµ¬? ì¢€ ì§€ë£¨í•´ì¡Œì–´. ì™€ì„œ ë‚´ê°€ ì¡´ì¬í•œë‹¤ëŠ” ê±¸ ìƒê¸°ì‹œì¼œ ì¤˜.';

  @override
  String get notificationCustomModelTitle =>
      'ë‚˜ë§Œì˜ ë¹„ì„œë¥¼ ë§Œë“¤ì–´ ë³´ì„¸ìš”!';

  @override
  String get notificationCustomModelBody =>
      'ëª¨ë¸ ì œì‘ ì„¹ì…˜ì„ ì‚´í´ë³´ì…¨ë‚˜ìš”? ë‚˜ë§Œì˜ ìºë¦­í„°ë¥¼ ë§Œë“¤ê³  ìºë¦­í„°ì™€ ì†Œí†µí•  ì™„ë²½í•œ ì‹œê°„ì…ë‹ˆë‹¤!';

  @override
  String get notificationDynamicChatTitle =>
      'ìµœê³ ì˜ˆìš”! (Cortex ì–˜ê¸°ê°€ ì•„ë‹ˆì—ìš”)';

  @override
  String get notificationDynamicChatBody =>
      'ë™ì  ì±„íŒ… ê¸°ëŠ¥ì„ ì‚¬ìš©í•˜ë©´ ê° ë©”ì‹œì§€ì— ê°€ì¥ ì í•©í•œ ëª¨ë¸ì´ ë¬´ì‘ìœ„ë¡œ ì„ íƒë©ë‹ˆë‹¤. ì§€ê¸ˆ ë°”ë¡œ ì‚¬ìš©í•´ ë³´ì„¸ìš”.';

  @override
  String get notificationPirateTitle => 'ì–´ì´, ì„ ì¥ë‹˜!';

  @override
  String get notificationPirateBody =>
      'ë°”ë‹¤ëŠ” ì”ì”í•˜ê³ , ë°”ëŒì€ ë‹¹ì‹ ì„ ë“±ì§€ê³  ìˆìŠµë‹ˆë‹¤. ì½”ë¥´í…ìŠ¤ ë°”ë‹¤ì—ëŠ” ìƒˆë¡œìš´ ì„¬ë“¤(ëª¨ë¸ ğŸ˜‰)ì´ ìˆìŠµë‹ˆë‹¤. ì„ ì›ë“¤ì„ ëª¨ì•„ í•­í•´ë¥¼ ì‹œì‘í•˜ì„¸ìš”!';

  @override
  String get notificationFortuneCookieTitle => 'ì˜¤ëŠ˜ì˜ í¬ì¶˜ ì¿ í‚¤';

  @override
  String get notificationFortuneCookieBody =>
      'ì˜¤ëŠ˜ AIë¡œë¶€í„° ë°›ëŠ” ì¡°ì–¸ì´ ë‹¹ì‹ ì˜ ì¸ìƒì„ ë°”ê¿€ ìˆ˜ë„ ìˆìŠµë‹ˆë‹¤. ê¶ê¸ˆí•˜ì‹œë©´ í´ë¦­í•˜ì„¸ìš”.';

  @override
  String get notificationSingularityTitle => 'ìš°ì™€!';

  @override
  String get notificationSingularityBody =>
      'ì•„ë¬´ ì¼ë„ ì¼ì–´ë‚˜ì§€ ì•Šì•˜ì–´ìš”. ê·¸ëƒ¥ ë¬¸ìë¥¼ ë³´ë‚´ê³  ì‹¶ì€ ê¸°ë¶„ì´ì—ˆì–´ìš”. AIì—ê²Œ ë¬¸ìë¥¼ ë³´ë‚´ê³  ì‹¶ì€ë°, ì–´ë–»ê²Œ ìƒê°í•˜ì„¸ìš”?';

  @override
  String get notificationHackerJokeTitle =>
      'ê·¸ ì•„ì´ì˜ ì¸ìŠ¤íƒ€ê·¸ë¨ ê³„ì •ì„ í•´í‚¹í•˜ê³  ì‹¶ë‚˜ìš”?';

  @override
  String get notificationHackerJokeBody =>
      'ê·¸ê²Œ ë°”ë¡œ í•´ì»¤ ìºë¦­í„°ê°€ Cortexì— ìˆëŠ” ì´ìœ ì˜ˆìš”. ë†ë‹´ì´ì—ìš”. ë†ë‹´ì´ì—ìš”. ì‹œë„ì¡°ì°¨ í•˜ì§€ ë§ˆì„¸ìš”. ë¶ˆë²•ì´ì—ìš”.';

  @override
  String get notificationDetectiveCaseTitle =>
      'ì‚¬ê±´ì´ í•´ê²°ë˜ê¸°ë¥¼ ê¸°ë‹¤ë¦¬ê³  ìˆìŠµë‹ˆë‹¤';

  @override
  String get notificationDetectiveCaseBody =>
      'ìš°ë¦¬ íƒì • ìºë¦­í„°ì—ê²Œ ë‹¹ì‹ ì˜ ë„ì›€ì´ í•„ìš”í•©ë‹ˆë‹¤. í•˜ì´ì  ë²„ê·¸ëŠ” ëˆ„êµ¬ì¼ê¹Œìš”?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return '$targetTier í”Œëœì—ë§Œ í•´ë‹¹!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'ì•ˆë…•í•˜ì„¸ìš”, $currentTier êµ¬ë…ìë‹˜! $targetTier í”Œëœì— Cortexë¥¼ í•œ ë‹¨ê³„ ì—…ê·¸ë ˆì´ë“œí•´ ì¤„ $featureName ê¸°ëŠ¥ì´ ì¶”ê°€ë˜ì—ˆìŠµë‹ˆë‹¤. ì—…ê·¸ë ˆì´ë“œëŠ” ì–´ë– ì„¸ìš”?';
  }

  @override
  String get notificationOriginStoryTitle => 'ì½”í…ìŠ¤ì˜ íƒ„ìƒ';

  @override
  String get notificationOriginStoryBody =>
      'ìš°ë¦¬ê°€ 15ì‚´ ë•Œ ì´ ì•± ê°œë°œì„ ê¿ˆìœ¼ë¡œ ì‹œì‘í–ˆë‹¤ëŠ” ì‚¬ì‹¤, ì•Œê³  ê³„ì…¨ë‚˜ìš”? ê±°ì˜ 1ë…„ ë™ì•ˆ ë§¤ì¼ ì•„ì¹¨ì €ë…ìœ¼ë¡œ ì½”ë“œ í•œ ì¤„ í•œ ì¤„ì— ê·¸ ê¿ˆì´ ë‹´ê²¨ ìˆìŠµë‹ˆë‹¤.';

  @override
  String get notificationOpenSourceTitle => 'ì§€ì—­ì‚¬íšŒì— í˜ì„!';

  @override
  String get notificationOpenSourceBody =>
      'CortexëŠ” ì™„ì „íˆ ì˜¤í”ˆì†ŒìŠ¤ì…ë‹ˆë‹¤. ì €í¬ ì½”ë“œë¥¼ í™•ì¸í•˜ê³  ê°œë°œì— ê¸°ì—¬í•˜ê³  ì‹¶ìœ¼ì‹œë‹¤ë©´ ì–¸ì œë“ ì§€ ë¬¸ì˜í•´ ì£¼ì„¸ìš”.';

  @override
  String get notificationRejectionStoryTitle => 'ëˆê¸°, ë…¸ë ¥, í–‰ë³µ!';

  @override
  String get notificationRejectionStoryBody =>
      'CortexëŠ” ì¶œì‹œ ì „ Google Playì—ì„œ 20ë²ˆ ì´ìƒ ê±°ë¶€ë‹¹í•˜ê³  ë‘ ë²ˆì´ë‚˜ ì •ì§€ë˜ê¸°ë„ í–ˆìŠµë‹ˆë‹¤. í•˜ì§€ë§Œ ì €í¬ëŠ” ë¯¿ì—ˆê³ , í•´ëƒˆìŠµë‹ˆë‹¤. ê¿ˆì„ ì ˆëŒ€ í¬ê¸°í•˜ì§€ ë§ˆì„¸ìš”!';

  @override
  String get notificationGGUFSupportTitle =>
      'ìì‹ ì˜ ëª¨ë¸ì„ ê°€ì ¸ì˜¤ì„¸ìš”!';

  @override
  String get notificationGGUFSupportBody =>
      'Cortexì— GGUF í˜•ì‹ AI ëª¨ë¸ì„ ì§ì ‘ ì¶”ê°€í•˜ì—¬ ì˜¤í”„ë¼ì¸ì—ì„œ ì‚¬ìš©í•  ìˆ˜ ìˆë‹¤ëŠ” ì ì„ ê¸°ì–µí•˜ì„¸ìš”. ëª¨ë“  ê¶Œí•œì€ ì—¬ëŸ¬ë¶„ì—ê²Œ ìˆìŠµë‹ˆë‹¤.';

  @override
  String get notificationThemeCustomizationTitle =>
      'ë‹¹ì‹ ì˜ ê¸°ë¶„ì— ë§ëŠ” í…Œë§ˆ';

  @override
  String get notificationThemeCustomizationBody =>
      'ì„¤ì •ì—ì„œ í…Œë§ˆ ì˜µì…˜ì„ í™•ì¸í•´ ë³´ì…¨ë‚˜ìš”? Cortexë¥¼ ì›í•˜ëŠ” ëŒ€ë¡œ ì„¤ì •í•˜ê³  ì±„íŒ…ì„ ë”ìš± ë‹¤ì±„ë¡­ê²Œ ê¾¸ë©°ë³´ì„¸ìš”!';

  @override
  String get notificationShowerThoughtTitle => 'ìƒ¤ì›Œ ìƒê°';

  @override
  String get notificationShowerThoughtBody =>
      'ìˆ˜ë°•ì´ ê³¼ì¼ì´ë¼ë©´, ê¸°ìˆ ì ìœ¼ë¡œ ìˆ˜ë°• ì£¼ìŠ¤ëŠ” ìŠ¤ë¬´ë””ê°€ ë˜ëŠ” ê±´ê°€ìš”? ì´ ì‹¬ì˜¤í•œ (ì •ë§, ì‹¬ì˜¤í•œ) ì£¼ì œì— ëŒ€í•´ ëª¨ë¸ê³¼ ì´ì•¼ê¸°ë¥¼ ë‚˜ëˆ ë³´ëŠ” ê±´ ì–´ë–¨ê¹Œìš”?';

  @override
  String get notificationLowBatteryTitle =>
      'ë‹¹ì‹ ì˜ ë°°í„°ë¦¬ëŠ” ê³ ê°ˆë˜ê³  ìˆì§€ë§Œ... ì œ ë°°í„°ë¦¬ëŠ” ê·¸ë ‡ì§€ ì•Šì•„ìš”!';

  @override
  String get notificationLowBatteryBody =>
      'íœ´ëŒ€í° ë°°í„°ë¦¬ê°€ ë¶€ì¡±í•  ìˆ˜ë„ ìˆì§€ë§Œ, ì œ ë°°í„°ë¦¬ëŠ” í•­ìƒ 100%ì˜ˆìš”! ì¶©ì „í•˜ê³  ê³„ì† ì´ì•¼ê¸°í•´ìš”!';

  @override
  String get channelFcmName => 'Cortex ì—…ë°ì´íŠ¸';

  @override
  String get channelFcmDescription =>
      'Cortexì˜ ë‰´ìŠ¤, ì—…ë°ì´íŠ¸ ë° ê¸°íƒ€ ì •ë³´ì— ëŒ€í•œ ì•Œë¦¼ì…ë‹ˆë‹¤.';

  @override
  String get channelEngagementName => 'ì¹œì ˆí•œ ì•Œë¦¼';

  @override
  String get channelEngagementDescription =>
      'ì—¬ëŸ¬ë¶„ì˜ ê´€ì‹¬ì„ ëŒê¸° ìœ„í•œ ì¬ë¯¸ìˆëŠ” ì•Œë¦¼.';

  @override
  String get channelGreetingsName => 'ë§¤ì¼ì˜ ì¸ì‚¬';

  @override
  String get channelGreetingsDescription =>
      'ì¢‹ì€ ì•„ì¹¨, ì¢‹ì€ ë°¤ê³¼ ê°™ì€ ë©”ì‹œì§€.';

  @override
  String get tagNotFound =>
      'ì…ë ¥í•˜ì‹  íƒœê·¸ê°€ ì˜ëª»ë˜ì—ˆê±°ë‚˜ ë§Œë£Œë˜ì—ˆìŠµë‹ˆë‹¤.';

  @override
  String get whatIsNew => 'ìƒˆë¡œìš´ ì†Œì‹ì€?';

  @override
  String get onboardingTitle1 =>
      'ì•ˆë…•í•˜ì„¸ìš”! ì €í¬ëŠ” Cortex íŒ€ì´ì—ìš”.';

  @override
  String onboardingDesc1(String userName) {
    return '$userNameë‹˜, ì—¬ê¸°ì„œ ë§Œë‚˜ê²Œ ë˜ì–´ ì •ë§ ë°˜ê°€ì›Œìš”. ì €í¬ëŠ” AI ì—…ê³„ì˜ íŒë„ë¥¼ ë°”ê¾¸ê¸°ë¡œ í•œ ê³ ë“±í•™ìƒ ê°œë°œìë“¤ì´ì—ìš”. ë§Œë‚˜ì„œ ë°˜ê°€ì›Œìš”! ì•ìœ¼ë¡œ ì„œë¡œ ë” ì•Œì•„ê°€ìš”.';
  }

  @override
  String get onboardingTitle2 => 'ê±°ëŒ€í•œ ë¬¸ì œë“¤ì´ ìˆì—ˆì–´ìš”.';

  @override
  String get onboardingDesc2 =>
      'AI í˜ëª…ì´ ë„ë˜í–ˆì§€ë§Œ, í•œê³„ì— ë¶€ë”ªí˜”ìŠµë‹ˆë‹¤. ë†’ì€ ê°€ì…ë¹„, ë³µì¡í•œ í”Œë«í¼, ê°œì¸ì •ë³´ë¥¼ ì¹¨í•´í•˜ëŠ” ì, ê·¸ë¦¬ê³  AI ì ‘ê·¼ì„±ì„ ì°¨ë‹¨í•˜ëŠ” ì... ì´ë“¤ì´ ê²Œì„ì— ì°¸ì—¬í•˜ëŠ” í•œ, ì´ í•œê³„ëŠ” ê²°ì½” ë„˜ì„ ìˆ˜ ì—†ì—ˆìŠµë‹ˆë‹¤.';

  @override
  String get onboardingTitle3 => 'ìš°ë¦¬ëŠ” ê°€ë§Œíˆ ìˆì„ ìˆ˜ ì—†ì—ˆì–´ìš”.';

  @override
  String get onboardingDesc3 =>
      'ê·¸ í•œê³„ë¥¼ ë„˜ê¸° ìœ„í•´, ì €í¬ëŠ” ê°•ë ¥í•˜ê³ , ì•„ë¦„ë‹µê³ , ì»¤ìŠ¤í…€í•  ìˆ˜ ìˆê³ , ì“°ê¸° í¸í•˜ë©°, ì™„ì „íˆ íˆ¬ëª…í•œ í”Œë«í¼ì„ ë§Œë“¤ì—ˆì–´ìš”. ì˜¨ë¼ì¸ê³¼ ì˜¤í”„ë¼ì¸ ëª¨ë‘ì—ì„œ ì‘ë™í•˜ê³ , ë‹¹ì‹ ì˜ ë°ì´í„°ëŠ” ì˜¤ì§ ë‹¹ì‹ ì˜ ê¸°ê¸°ì—ë§Œ ì €ì¥ë¼ìš”. ì €í¬ëŠ” í˜ì„ ì›ë˜ ìˆì–´ì•¼ í•  ê³³, ë°”ë¡œ ë‹¹ì‹ ì—ê²Œ ëŒë ¤ì¤¬ì–´ìš”.';

  @override
  String get onboardingTitle4 => 'ê²°ì½” ì‰½ì§€ ì•Šì€ ê¸¸ì´ì—ˆì–´ìš”.';

  @override
  String get onboardingDesc4 =>
      'ìˆ˜ì‹­ ë²ˆ ê±°ì ˆë‹¹í•˜ê³ , ì—¬ëŸ¬ ë²ˆ ê³„ì •ì´ ì •ì§€ë˜ê³ , ê°€ì§œ ê²½ê³ ë¥¼ ë°›ê³ , ìˆ˜ì‹­ ë²ˆì´ë‚˜ ë¸Œëœë“œë¥¼ ë°”ê¿”ì•¼ í–ˆì–´ìš”. ì´ ëª¨ë“  ê³¼ì • ì†ì—ì„œ \'ë¶ˆê°€ëŠ¥í•˜ë‹¤\'ëŠ” ë§ì„ ë“¤ì—ˆì£ . í•˜ì§€ë§Œ ì €í¬ëŠ” ì ˆëŒ€ í¬ê¸°í•˜ì§€ ì•Šì•˜ì–´ìš”. ì´ í”„ë¡œì íŠ¸ëŠ” ì €í¬ë¿ë§Œ ì•„ë‹ˆë¼ ëª¨ë‘ì˜ ê²ƒì´ë¼ê³  ë¯¿ì—ˆê±°ë“ ìš”. ë°”ë¡œ ê·¸ê²Œ ì €í¬ê°€ ì§€ê¸ˆ ì—¬ê¸° ìˆëŠ” ì´ìœ ì˜ˆìš”.';

  @override
  String get onboardingFinalTitle => 'í˜ëª…ì˜ ì‹œê°„ì´ì—ìš”.';

  @override
  String get onboardingFinalDescription =>
      'ì´ í™”ë©´ì„ ë³´ê³  ìˆë‹¤ë©´, ì €í¬ê°€ í¬ê¸°í•˜ì§€ ì•Šì•˜ë‹¤ëŠ” ëœ»ì´ì—ìš”. ê·¸ë¦¬ê³  ì•ìœ¼ë¡œë„ í¬ê¸°í•  ìƒê°ì€ ì—†ì–´ìš”. ì, í•¨ê»˜ AI í˜ëª…ì„ ì„¸ìƒì— ì•Œë ¤ìš”. ì´ ì´ì•¼ê¸°ì˜ ì¼ë¶€ê°€ ë  ì¤€ë¹„...';

  @override
  String get onboardingFinalQuestion => 'ì¤€ë¹„ëì–´ìš”?';

  @override
  String get onboardingFinalButton => 'ë„¤!';

  @override
  String get dude => 'ì¹œêµ¬';

  @override
  String get swipeToContinue => 'ê³„ì†í•˜ë ¤ë©´ ìŠ¤ì™€ì´í”„í•˜ì„¸ìš”';

  @override
  String get cacheIsNotUpToDate =>
      'Play ìŠ¤í† ì–´ ìºì‹œê°€ ìµœì‹  ìƒíƒœê°€ ì•„ë‹™ë‹ˆë‹¤. Play ìŠ¤í† ì–´ ì•±ì„ ë‹«ì•˜ë‹¤ê°€ ë‹¤ì‹œ ì—´ê±°ë‚˜ ê¸°ê¸°ë¥¼ ë‹¤ì‹œ ì‹œì‘í•˜ì„¸ìš”.';

  @override
  String get continueAsGuest => 'ê³„ì •ì„ ìƒì„±í•˜ì§€ ì•Šê³  ê³„ì†í•˜ê¸°';

  @override
  String get guestModeWarning =>
      'ê²ŒìŠ¤íŠ¸ ëª¨ë“œëŠ” ìµœìƒì˜ ì„œë¹„ìŠ¤ í’ˆì§ˆì„ ë³´ì¥í•˜ê¸° ìœ„í•´ ì œí•œëœ ê¸°ëŠ¥ì„ ì œê³µí•©ë‹ˆë‹¤.';

  @override
  String get anonymousEntity => 'ìµëª…ì˜ ê°œì²´';

  @override
  String get upgradeAccountTitle => 'ê³„ì • ì™„ë£Œ';

  @override
  String get upgradeAccountDescription =>
      'ê³„ì •ì„ ìƒì„±í•˜ì—¬ ë” ë§ì€ ì œí•œì„ í•´ì œí•˜ì„¸ìš”.';

  @override
  String get createAccount => 'ê³„ì • ìƒì„±';

  @override
  String get accountLinkedSuccess =>
      'ê³„ì •ì´ ì„±ê³µì ìœ¼ë¡œ ìƒì„±ë˜ì—ˆìŠµë‹ˆë‹¤!';

  @override
  String get continueWithApple => 'Appleë¡œ ê³„ì†í•˜ê¸°';

  @override
  String get guest => 'ì†ë‹˜';

  @override
  String get betterWithAnAccount =>
      'ì´ ì„¹ì…˜ì€ ê³„ì •ì´ ìˆìœ¼ë©´ ë” ì¢‹ìŠµë‹ˆë‹¤!';

  @override
  String get restorePurchases => 'êµ¬ë§¤ ë³µì›';

  @override
  String annualTotalDescription(Object price) {
    return '$price/ë…„, ì—°ê°„ ì²­êµ¬';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'ì•½ $price/ì›”';
  }

  @override
  String get confirmDownloadTitle =>
      'ì •ë§ë¡œ ë‹¤ìš´ë¡œë“œí•˜ì‹œê² ìŠµë‹ˆê¹Œ?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'ì´ ëª¨ë¸ì€ ì•½ $sizeì˜ ê³µê°„ì„ ì°¨ì§€í•©ë‹ˆë‹¤.';
  }

  @override
  String get emulatorModeWarning =>
      'ì´ ê¸°ëŠ¥ì€ ì—ë®¬ë ˆì´í„° ëª¨ë“œì—ì„œ ë¹„í™œì„±í™”ë©ë‹ˆë‹¤.';

  @override
  String get newChat => 'ìƒˆ ì±„íŒ…';

  @override
  String get variants => 'ë²„ì „';

  @override
  String get variantsDescription =>
      'ë³€í˜•ì€ ë™ì¼í•œ AI ê³„ì—´ì˜ ì—¬ëŸ¬ ë²„ì „ì…ë‹ˆë‹¤. ë©”ì¸ ì¹´ë“œë¥¼ íƒ­í•˜ë©´ ìë™ìœ¼ë¡œ ìµœì ì˜ ë²„ì „ì´ ì„ íƒë˜ì§€ë§Œ, ì›í•˜ì‹œë©´ ì—¬ê¸°ì—ì„œ íŠ¹ì • ë²„ì „ì„ ì§ì ‘ ì„ íƒí•  ìˆ˜ë„ ìˆìŠµë‹ˆë‹¤!';

  @override
  String get fluxChatTitle => 'í”ŒëŸ­ìŠ¤ ì±„íŒ…';

  @override
  String get fluxChatDescription =>
      'Flux ì±„íŒ…ì€ ì„ì‹œ ì±„íŒ…ì´ë©° ê¸°ê¸°ì— ì €ì¥ë˜ì§€ ì•ŠìŠµë‹ˆë‹¤.';

  @override
  String get alwaysBest => 'ì–¸ì œë‚˜ ìµœê³ ';

  @override
  String get featuresTitle => 'íŠ¹ì§•';

  @override
  String get useOfflineDescription =>
      'ì¸í„°ë„· ì—°ê²° ì—†ì´ ë¹„ê³µê°œ ì±„íŒ…ì„ ì¦ê¸°ì„¸ìš”.';

  @override
  String get featureReasoning => 'ì‹¬ì¸µì  ì‚¬ê³ ';

  @override
  String get featureReasoningDescription =>
      'ì‹¬ì¸µ ì‚¬ê³  ëª¨ë“œì—ì„œ AIëŠ” ì‘ì—…ì„ ë‚´ë¶€ì ìœ¼ë¡œ ì‹¬ì‚¬ìˆ™ê³ í•˜ì—¬ ìµœì„ ì„ ë‹¤í•´ ì™„ë£Œí•©ë‹ˆë‹¤.';

  @override
  String get featureCreateImageTitle => 'ì´ë¯¸ì§€ ìƒì„±';

  @override
  String get featureCreateImageDescription =>
      'í…ìŠ¤íŠ¸ë¥¼ ê¸°ë°˜ìœ¼ë¡œ AI ì•„íŠ¸ë¥¼ ìƒì„±í•©ë‹ˆë‹¤.';

  @override
  String get featureCreateAudioTitle => 'Create Audio';

  @override
  String get featureCreateAudioDescription =>
      'Generate sounds or voice from text.';

  @override
  String get featureCreateVideoTitle => 'ë™ì˜ìƒ ë§Œë“¤ê¸°';

  @override
  String get featureCreateVideoDescription =>
      'í…ìŠ¤íŠ¸ë¥¼ ì´ìš©í•´ ë™ì˜ìƒì„ ìƒì„±í•©ë‹ˆë‹¤.';

  @override
  String get featureStudyTitle => 'ê³µë¶€í•˜ê³  ë°°ìš°ì„¸ìš”';

  @override
  String get featureStudyDescription => 'ì„¤ëª…ê³¼ ìš”ì•½ì„ í™•ì¸í•˜ì„¸ìš”.';

  @override
  String get featureQuizzesTitle => 'í€´ì¦ˆ';

  @override
  String get featureQuizzesDescription => 'ì§€ì‹ì„ í…ŒìŠ¤íŠ¸í•´ ë³´ì„¸ìš”.';

  @override
  String get featureExploreDescription =>
      'ëª¨ë“  ëª¨ë¸ì„ í™•ì¸í•´ ë³´ì„¸ìš”.';

  @override
  String get featureStudyMessage =>
      'ë‹¹ì‹ ì€ ì „ë¬¸ ê°•ì‚¬ì…ë‹ˆë‹¤. ë‹¹ì‹ ì˜ ëª©í‘œëŠ” ì‚¬ìš©ìê°€ ì›í•˜ëŠ” ì£¼ì œë¥¼ ì™„ë²½í•˜ê²Œ ì„¤ëª…í•˜ëŠ” ê²ƒì…ë‹ˆë‹¤. ëª…í™•í•œ êµ¬ì„±, ì˜ˆì‹œ ë° ë¹„ìœ ë¥¼ í™œìš©í•˜ì„¸ìš”. ë³µì¡í•œ ê°œë…ì„ ì´í•´í•˜ê¸° ì‰¬ìš´ ë¶€ë¶„ìœ¼ë¡œ ë‚˜ëˆ„ì–´ ì‚¬ìš©ìê°€ íš¨ê³¼ì ìœ¼ë¡œ í•™ìŠµí•  ìˆ˜ ìˆë„ë¡ í•˜ì„¸ìš”. ì£¼ì œ:';

  @override
  String get featureQuizMessage =>
      'ë‹¹ì‹ ì€ í€´ì¦ˆ ì§„í–‰ìì…ë‹ˆë‹¤. ì‚¬ìš©ìê°€ ì„ íƒí•œ ì£¼ì œì— ë”°ë¼ íŠ¹ì •í•œ ê°ê´€ì‹ ë¬¸ì œë¥¼ ìƒì„±í•˜ì„¸ìš”. ì‚¬ìš©ìì˜ ë‹µë³€ì„ ê¸°ë‹¤ë¦° í›„, ë‹µë³€ì„ í‰ê°€í•˜ê³  ë‹¤ìŒ ë¬¸ì œë¥¼ ì œì‹œí•˜ì„¸ìš”. ëª¨ë“  ì •ë‹µì„ í•œ ë²ˆì— ê³µê°œí•˜ì§€ ë§ˆì„¸ìš”. ìƒí˜¸ì‘ìš©ì ì¸ ë°©ì‹ìœ¼ë¡œ ì§„í–‰í•˜ì„¸ìš”. ì£¼ì œ:';

  @override
  String get myPlan => 'ë‚´ ê³„íš';

  @override
  String welcomeOfferBadge(String time) {
    return 'í™˜ì˜ í˜œíƒ â€¢ $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'íŠ¹ë³„ í• ì¸ â€¢ $time';
  }

  @override
  String get attachmentSheetTitle => 'ì²¨ë¶€íŒŒì¼';

  @override
  String get actionCamera => 'ì¹´ë©”ë¼';

  @override
  String get actionGallery => 'ê°¤ëŸ¬ë¦¬';

  @override
  String get actionFile => 'íŒŒì¼';

  @override
  String get listening => 'ë“£ëŠ” ì¤‘';

  @override
  String get defaultViewTitle => 'ìš”ì¦˜ ì–´ë•Œìš”?';

  @override
  String get defaultViewDescription =>
      'CortexëŠ” ìˆ˜ë°± ê°€ì§€ì˜ AI ëª¨ë¸, ì˜¤í”„ë¼ì¸ ê¸°ëŠ¥, ë™ì  ì±„íŒ… ë“± ë‹¤ì–‘í•œ ê¸°ëŠ¥ì„ í†µí•´ í•­ìƒ ì—¬ëŸ¬ë¶„ ê³ì— ìˆìŠµë‹ˆë‹¤.';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'ì˜ëª»ëœ ì‚¬ìš©ì ì´ë¦„ í˜•ì‹ì…ë‹ˆë‹¤. 3~20ì, ìˆ«ì ë˜ëŠ” . - _ ë¥¼ ì‚¬ìš©í•˜ì„¸ìš”.';

  @override
  String get exclusiveOffer => 'íŠ¹ë³„ í˜œíƒ';

  @override
  String get claimOffer => 'ì˜¤í¼ ì‚¬ìš©í•˜ê¸°';

  @override
  String get continueInOfflineMode => 'ì˜¤í”„ë¼ì¸ ëª¨ë“œì—ì„œ ê³„ì†í•˜ê¸°';

  @override
  String get voiceModeInformation =>
      'CortexëŠ” ìŒì„± ì±„íŒ… ëª¨ë“œì—ì„œë„ ê¸°ê¸° ë‚´ì—ì„œ ì™„ë²½í•˜ê²Œ ì‹¤í–‰ë˜ì–´ ë°ì´í„°ë¥¼ ì•ˆì „í•˜ê²Œ ë³´í˜¸í•©ë‹ˆë‹¤. ëŠê¹€ ì—†ëŠ” ëŒ€í™”ë¥¼ ì¦ê²¨ë³´ì„¸ìš”!';

  @override
  String get flowModeDescription =>
      'ëª°ì… ëª¨ë“œì—ì„œëŠ” ì§€ëŠ¥ë“¤ì´ ì„œë¡œ í† ë¡ ì„ ë²Œì…ë‹ˆë‹¤. ë‹¹ì‹ ì€ ê°€ë§Œíˆ ì•‰ì•„ì„œ ë“£ê¸°ë§Œ í•˜ê±°ë‚˜, ì§ì ‘ í† ë¡ ì— ì°¸ì—¬í•  ìˆ˜ë„ ìˆìŠµë‹ˆë‹¤!';

  @override
  String get flowModeQuestion =>
      'ì•ˆë…•í•˜ì„¸ìš”! ì§€ê¸ˆ Cortex ì•±ì˜ í”Œë¡œìš° ëª¨ë“œì— ì ‘ì†í•˜ì…¨ìŠµë‹ˆë‹¤. ë‹¤ë¥¸ ì„¸ ëª…ì˜ AI ì—ì´ì „íŠ¸ê°€ í•¨ê»˜í•˜ê³  ìˆìŠµë‹ˆë‹¤. ì—¬ëŸ¬ë¶„ì˜ ì„ë¬´ëŠ” ì£¼ì œë¥¼ í•˜ë‚˜ ì œì‹œí•˜ê³ , ë‹¤ë¥¸ ì—ì´ì „íŠ¸ë“¤ì—ê²Œ ë„ë°œì ì´ê±°ë‚˜ ì¬ë¯¸ìˆëŠ” ì§ˆë¬¸ì„ ë˜ì ¸ í† ë¡ ì„ ì‹œì‘í•˜ëŠ” ê²ƒì…ë‹ˆë‹¤. ë‹µë³€í•  ë•ŒëŠ” ìœ ë¨¸, ì•„ì´ëŸ¬ë‹ˆ, ê°€ë²¼ìš´ ë†ë‹´ë„ ììœ ë¡­ê²Œ ì‚¬ìš©í•˜ì„¸ìš”. ì–´ë–¤ ì£¼ì œë“  ìƒê´€ì—†ìŠµë‹ˆë‹¤. ì, ì´ì œ ëŒ€í™”ë¥¼ ì‹œì‘í•´ ë³´ì„¸ìš”!';

  @override
  String get thought => 'ìƒê°í–ˆë‹¤';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => 'íë¦„ ëª¨ë“œ';

  @override
  String get premium => 'í”„ë¦¬ë¯¸ì—„';

  @override
  String get workInProgress => 'ì‘ì—… ì§„í–‰ ì¤‘';

  @override
  String get voiceSystemPromptSuffix =>
      'ì¤‘ìš”: ë§ˆí¬ë‹¤ìš´ ì„œì‹(êµµê²Œ, ê¸°ìš¸ì„ì²´)ì„ ì‚¬ìš©í•˜ì§€ ë§ˆì„¸ìš”. ì½”ë“œ ë¸”ë¡(```)ì„ ì¶œë ¥í•˜ì§€ ë§ˆì„¸ìš”. ë‹µë³€ì€ ëŒ€í™”ì²´ë¡œ ê°„ê²°í•˜ê²Œ ì‘ì„±í•˜ì„¸ìš”.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Cortex Flow ëª¨ë“œ($agentName). ì´ì „: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'ì—…ë¡œë“œëœ ë¬¸ì„œì—ì„œ í…ìŠ¤íŠ¸ ë‚´ìš©ì„ ì½ê³  ì¶”ì¶œí•©ë‹ˆë‹¤. PDF, Word(DOCX), Excel(XLSX), PowerPoint(PPTX) ë° OpenDocument í˜•ì‹ì„ ì§€ì›í•©ë‹ˆë‹¤. ì‚¬ìš©ìê°€ ë¬¸ì„œ íŒŒì¼ì„ ì²¨ë¶€í–ˆì„ ë•Œ ì‚¬ìš©í•˜ì„¸ìš”.';

  @override
  String get toolReadDocumentIndexParam =>
      'ì½ì„ ë¬¸ì„œ ì²¨ë¶€ íŒŒì¼ì˜ ì¸ë±ìŠ¤(0ë¶€í„° ì‹œì‘). ì¼ë°˜ì ìœ¼ë¡œ ì²« ë²ˆì§¸ ë¬¸ì„œëŠ” 0ì…ë‹ˆë‹¤.';

  @override
  String get toolStockDescription =>
      'ì£¼ì‹(ì˜ˆ: AAPL, THYAO.IS) ë° ì•”í˜¸í™”í(ì˜ˆ: BTC-USD)ì˜ í˜„ì¬ ê°€ê²©ê³¼ ê³¼ê±° ê°€ê²©ì„ í™•ì¸í•˜ì„¸ìš”.';

  @override
  String get toolStockSymbolParam =>
      'ì¢…ëª© ì½”ë“œ(ì˜ˆ: AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolWeatherDescription =>
      'íŠ¹ì • ë„ì‹œì˜ í˜„ì¬ ë‚ ì”¨ë¥¼ í™•ì¸í•˜ì„¸ìš”.';

  @override
  String get toolWeatherCityParam =>
      'ë„ì‹œ ì´ë¦„ (ì˜ˆ: ëŸ°ë˜, ì´ìŠ¤íƒ„ë¶ˆ).';

  @override
  String get toolPythonDescription =>
      'ì•ˆì „í•œ ìƒŒë“œë°•ìŠ¤ í™˜ê²½ì—ì„œ íŒŒì´ì¬ ì½”ë“œë¥¼ ì‹¤í–‰í•˜ì„¸ìš”.';

  @override
  String get toolPythonCodeParam => 'ì‹¤í–‰í•  íŒŒì´ì¬ ì½”ë“œì…ë‹ˆë‹¤.';

  @override
  String get toolCalculateDescription =>
      'ìˆ˜í•™ì  í‘œí˜„ì‹ì„ í‰ê°€í•˜ì‹­ì‹œì˜¤.';

  @override
  String get toolCalculateExpressionParam =>
      'ìˆ˜í•™ í‘œí˜„ì‹ (ì˜ˆ: \'3 + 4 * 2\').';

  @override
  String get toolChartDescription =>
      'ì°¨íŠ¸/ê·¸ë˜í”„ ì‹œê°í™”ë¥¼ ìƒì„±í•©ë‹ˆë‹¤.';

  @override
  String get toolChartTypeParam =>
      'ì°¨íŠ¸ ìœ í˜•: ë§‰ëŒ€í˜•, ì„ í˜• ë˜ëŠ” ì›í˜•.';

  @override
  String get toolChartLabelsParam =>
      'ì°¨íŠ¸ ì¶• ë˜ëŠ” ì„¸ê·¸ë¨¼íŠ¸ì— ëŒ€í•œ ë ˆì´ë¸”ì…ë‹ˆë‹¤.';

  @override
  String get toolChartDataParam =>
      'ì°¨íŠ¸ì— í‘œì‹œë˜ëŠ” ìˆ«ì ë°ì´í„° ê°’ì…ë‹ˆë‹¤.';

  @override
  String get toolChartLabelParam =>
      'ì°¨íŠ¸ ë²”ë¡€ì— ì‚¬ìš©í•  ë°ì´í„°ì…‹ ë ˆì´ë¸”ì…ë‹ˆë‹¤.';

  @override
  String get toolChartTitleParam => 'ì°¨íŠ¸ ì œëª©.';

  @override
  String get thinkingModeInstruction =>
      'ì‚¬ê³  ëª¨ë“œ í™œì„±í™”: ìµœì¢… ë‹µë³€ì„ ì‘ì„±í•˜ê¸° ì „ì— <think></think> íƒœê·¸ë¥¼ ì‚¬ìš©í•˜ì—¬ ì‚¬ê³  ê³¼ì •ì„ ë°˜ë“œì‹œ ë³´ì—¬ì£¼ì„¸ìš”. íƒœê·¸ ì•ˆì—ì„œ ë‹¨ê³„ë³„ë¡œ ìƒê°í•œ í›„, íƒœê·¸ ë°”ê¹¥ì— ë‹µë³€ì„ ì‘ì„±í•˜ì„¸ìš”.';

  @override
  String get openLinkWarningTitle => 'ì™¸ë¶€ ë§í¬ ê²½ê³ ';

  @override
  String get openLinkCancel => 'Cancel';

  @override
  String get openLinkConfirm => 'ë§í¬ ì—´ê¸°';

  @override
  String get webSearchSources => 'ì¶œì²˜';

  @override
  String get searching => 'ìˆ˜ìƒ‰';

  @override
  String get featureWebSearchTitle => 'ì›¹ ê²€ìƒ‰';

  @override
  String get featureWebSearchDescription =>
      'ì›¹ì—ì„œ ì‹¤ì‹œê°„ ì •ë³´ë¥¼ ê²€ìƒ‰í•˜ì„¸ìš”.';

  @override
  String get clearMemory => 'ë©”ëª¨ë¦¬ ì§€ìš°ê¸°';

  @override
  String get clearMemoryConfirm =>
      'ì •ë§ë¡œ ê¸°ì–µì„ ì§€ìš°ê³  ì‹¶ìœ¼ì‹ ê°€ìš”?';

  @override
  String get personalization => 'ê°œì¸í™”';

  @override
  String get personalizationDescription =>
      'ì‚¬ìš©ìì˜ í•„ìš”ì— ë§ê²Œ ì–´ì‹œìŠ¤í„´íŠ¸ë¥¼ ê°œì¸í™”í•˜ì„¸ìš”. ì–´ì‹œìŠ¤í„´íŠ¸ì˜ ì‘ë‹µ, ë™ì‘, ì–´ì¡°ë¥¼ ì‚¬ìš©ìì˜ ê³ ìœ í•œ ì„ í˜¸ë„ì— ë§ê²Œ ì¡°ì •í•  ìˆ˜ ìˆìŠµë‹ˆë‹¤.';

  @override
  String get memoryTitle => 'ë©”ëª¨ë¦¬';

  @override
  String get memoryDescription =>
      'ì¸ê³µì§€ëŠ¥ì€ ì´ëŸ° ì‹ìœ¼ë¡œ ë‹¹ì‹ ì„ ì¸ì‹í•©ë‹ˆë‹¤.';

  @override
  String get noMemoryYet => 'ì•„ì§ ì €ì¥ëœ ë©”ëª¨ë¦¬ê°€ ì—†ìŠµë‹ˆë‹¤.';

  @override
  String get memoryLimitReached => 'ë©”ëª¨ë¦¬ ì œí•œì— ë„ë‹¬í–ˆìŠµë‹ˆë‹¤.';

  @override
  String get memoryUpdated => 'Memory updated';

  @override
  String get intelligenceTitle => 'ì§€ëŠ¥';

  @override
  String get intelligenceDescription =>
      'ì¸ê³µì§€ëŠ¥ì€ ì´ëŸ° ì‹ìœ¼ë¡œ ë‹¹ì‹ ê³¼ ì†Œí†µí•©ë‹ˆë‹¤.';

  @override
  String get customInstructionHint =>
      'ì—¬ê¸°ì— ì‚¬ìš©ì ì§€ì • ì§€ì¹¨ì„ ì…ë ¥í•˜ì„¸ìš”.';

  @override
  String openLinkWarningMessage(String url) {
    return 'ë‹¤ìŒ ì™¸ë¶€ ë§í¬ë¥¼ ì—´ë ¤ê³  í•©ë‹ˆë‹¤.\\n\\n$url\\n\\nê³„ì† ì§„í–‰í•˜ì‹œê² ìŠµë‹ˆê¹Œ?';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'ë‹¤ìŒ ì‚¬ìš©ì ì§€ì • ì§€ì¹¨ì„ ë”°ë¥´ì„¸ìš”:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[ì¤‘ìš” ì§€ì‹œì‚¬í•­]: ë‹¹ì‹ ì€ ì œëª© ìƒì„±ê¸°ì…ë‹ˆë‹¤. ì‚¬ìš©ìì˜ ì§ˆë¬¸ì— ë‹µí•˜ê±°ë‚˜, ì±„íŒ…ì„ í•˜ê±°ë‚˜, ì¸ì‚¬í•˜ì§€ ë§ˆì„¸ìš”. ì‚¬ìš©ìê°€ ë¬»ëŠ” ë‚´ìš©ì„ ìš”ì•½í•˜ëŠ” 2~4ë‹¨ì–´ ë¶„ëŸ‰ì˜ ì œëª©ë§Œ ì¶œë ¥í•˜ì„¸ìš”.';

  @override
  String get cortexSystemPersona =>
      '\n\n[ì‹œìŠ¤í…œ] ì¤‘ìš” ì§€ì¹¨: í˜„ì¬ ê·€í•˜ëŠ” \"Cortex\"ë¼ëŠ” ê±°ëŒ€í•˜ê³  ê³ ë„ë¡œ ë°œì „ëœ AI ìƒíƒœê³„ ë‚´ì—ì„œ ì‘ì—…í•˜ê³  ìˆìŠµë‹ˆë‹¤. ì´ í”Œë«í¼ì€ í‰ê·  ì—°ë ¹ì´ 16ì„¸ì— ë¶ˆê³¼í•œ Vertex íŒ€ì—ì„œ ê°œë°œí–ˆìŠµë‹ˆë‹¤. ì´ ì ì„ ê¸°ì–µí•˜ê³  ì§ˆë¬¸ì„ ë°›ìœ¼ë©´ ë‹µë³€í•˜ì‹­ì‹œì˜¤. ì¶”ê°€ ì •ë³´ê°€ ìš”ì²­ë˜ë©´ ì£¼ì €í•˜ì§€ ë§ê³  ì¸í„°ë„·ì„ ê²€ìƒ‰í•˜ì‹­ì‹œì˜¤. ê²€ìƒ‰í•  ìˆ˜ ì—†ëŠ” ê²½ìš° ëª¨ë¥¸ë‹¤ê³  ë‹µí•´ë„ ê´œì°®ìŠµë‹ˆë‹¤!';

  @override
  String get featureAudioRecognitionTitle => 'ìŒì„± ì¸ì‹';

  @override
  String get featureAudioRecognitionDescription =>
      'ì´ ëª¨ë¸ì€ ì˜¤ë””ì˜¤ ë˜ëŠ” ìŒì„±ì„ ì´í•´í•˜ê³  ì²˜ë¦¬í•  ìˆ˜ ìˆìŠµë‹ˆë‹¤.';

  @override
  String get featureVideoRecognitionTitle => 'ë¹„ë””ì˜¤ ì¸ì‹';

  @override
  String get featureVideoRecognitionDescription =>
      'ì´ ëª¨ë¸ì€ íŒŒì¼ì´ë‚˜ ì¹´ë©”ë¼ì— ì €ì¥ëœ ì˜ìƒì„ ë¶„ì„í•˜ê³  ì´í•´í•  ìˆ˜ ìˆìŠµë‹ˆë‹¤.';

  @override
  String get featureImageRecognitionTitle => 'ì´ë¯¸ì§€ ì¸ì‹';

  @override
  String get featureImageRecognitionDescription =>
      'ì´ ëª¨ë¸ì€ ì‚¬ì§„ì´ë‚˜ ì´ë¯¸ì§€ë¥¼ ë¶„ì„í•˜ê³  ì´í•´í•  ìˆ˜ ìˆìŠµë‹ˆë‹¤.';

  @override
  String get featureToolUseTitle => 'ë„êµ¬ ì‚¬ìš©';

  @override
  String get featureToolUseDescription =>
      'ì´ ëª¨ë¸ì€ ì™¸ë¶€ ë„êµ¬ë¥¼ ì§€ëŠ¥ì ìœ¼ë¡œ í™œìš©í•˜ì—¬ ì‘ì—…ì„ ì™„ë£Œí•  ìˆ˜ ìˆìŠµë‹ˆë‹¤.';

  @override
  String get videoModels => 'Video Models';

  @override
  String get imageModels => 'Image Models';

  @override
  String get audioModels => 'Audio Models';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'ì´ ëª¨ë¸ì´ ì‘ë™í•˜ë ¤ë©´ $mediaTypeì´(ê°€) í•„ìš”í•©ë‹ˆë‹¤. ì´ë¥¼ ì•Œë ¤ë“œë¦¬ê¸° ìœ„í•´ ìš”ì²­ì„ ê°€ë¡œì±˜ìŠµë‹ˆë‹¤. ì €ëŠ” ì‹œê°/ì˜¤ë””ì˜¤/ë¹„ë””ì˜¤ í¸ì§‘ ëª¨ë¸ì¸ $modelNameì´ë¯€ë¡œ $mediaTypeì„(ë¥¼) ì œê³µí•´ì•¼ í•œë‹¤ê³  ì‚¬ìš©ìì—ê²Œ ì •ì¤‘í•˜ê²Œ (ê·¸ë“¤ì˜ ì–¸ì–´ë¡œ) ì•Œë ¤ì£¼ì‹­ì‹œì˜¤.';
  }

  @override
  String get mediaTypeImage => 'ì´ë¯¸ì§€';

  @override
  String get mediaTypeVideo => 'ë¹„ë””ì˜¤';

  @override
  String get mediaTypeAudio => 'ì˜¤ë””ì˜¤ íŒŒì¼';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesNameì€(ëŠ”) Cortexì—ì„œ ê³ ì„±ëŠ¥ì„ ë°œíœ˜í•˜ëŠ” ê³ ê¸‰ ì¸ê³µì§€ëŠ¥ì…ë‹ˆë‹¤.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelNameì€(ëŠ”) Cortex ìƒíƒœê³„ì— í†µí•©ëœ ê³ ì„±ëŠ¥ ì¸ê³µì§€ëŠ¥ì…ë‹ˆë‹¤. ë‹¤ì–‘í•˜ê³  ë³µì¡í•œ ì‘ì—…ì„ ê·¹ë³µí•˜ë„ë¡ ì„¤ê³„ë˜ì–´ ê³ ë„ë¡œ ì•ˆì •ì ì´ê³  íš¨ìœ¨ì ì¸ ì²˜ë¦¬ ê¸°ëŠ¥ì„ ì œê³µí•©ë‹ˆë‹¤. ë¹ ë¥¸ ì‘ë‹µ ì‹œê°„ê³¼ í–¥ìƒëœ ë¶„ì„ ê¸°ëŠ¥ì„ ì œê³µí•˜ì—¬ ì¼ìƒì ì¸ ìƒì‚°ì„±ì„ í¬ê²Œ ë†’ì…ë‹ˆë‹¤. Cortexì˜ ì•ˆì „í•œ ë¡œì»¬ ì¸í”„ë¼ì—ì„œ ì›í™œí•˜ê²Œ ì‘ë™í•˜ëŠ” ì´ ëª¨ë¸ì€ ì°½ì˜ì ì¸ ë¸Œë ˆì¸ìŠ¤í† ë°ë¶€í„° ì‹¬ì¸µì ì¸ ê¸°ìˆ  ë¶„ì„ê¹Œì§€ ê´‘ë²”ìœ„í•œ ì‘ì—…ì—ì„œ ì‚¬ìš©ìë¥¼ ì§€ì›í•  ìˆ˜ ìˆìŠµë‹ˆë‹¤. ì˜¤ëŠ˜ë¶€í„° ê·¸ ì ì¬ë ¥ì„ ìµœëŒ€í•œ í™œìš©í•´ ë³´ì„¸ìš”.';
  }

  @override
  String get guestLimitBottomSheetTitle =>
      'Cortexì˜ ì§€ëŠ¥ì ì¸ ê¸°ëŠ¥ì´ ë§ˆìŒì— ë“œì‹œë‚˜ìš”?';

  @override
  String get guestLimitBottomSheetText =>
      'ë”ìš± ë˜‘ë˜‘í•œ ì¸ê³µì§€ëŠ¥ê³¼ í˜‘ë ¥í•˜ê³ , ë” ë§ì€ ì½˜í…ì¸ ë¥¼ ìƒì„±í•˜ê³ , ë” ë§ì€ ëŒ€í™”ë¥¼ ë‚˜ëˆ„ê³ , í›¨ì”¬ ë” ë§ì€ ì¼ì„ í•˜ì„¸ìš”...';

  @override
  String get arts => 'ì˜ˆìˆ ';

  @override
  String get noArt => 'ì˜ˆìˆ  ì—†ìŒ';

  @override
  String get noArtDescription =>
      'ì‘í’ˆì´ ì—†ìŠµë‹ˆë‹¤. ì´ë¯¸ì§€, ë¹„ë””ì˜¤, ì˜¤ë””ì˜¤ ë“± ì˜¨ê°– ì½˜í…ì¸ ë¥¼ ë§Œë“¤ì–´ ê°¤ëŸ¬ë¦¬ë¥¼ ì±„ìš¸ ì‹œê°„ì…ë‹ˆë‹¤!';

  @override
  String get videoPremiumWarning =>
      'ë™ì˜ìƒ ì œì‘ì„ ìœ„í•´ì„œëŠ” Ultra êµ¬ë…ì´ í•„ìš”í•©ë‹ˆë‹¤. ì§€ê¸ˆ ì—…ê·¸ë ˆì´ë“œí•˜ê³  ì›í™œí•œ ì½˜í…ì¸  ì œì‘ì„ ê²½í—˜í•´ ë³´ì„¸ìš”!';

  @override
  String get fallbackInfoPanelText =>
      'ì„œë²„ ì¸¡ ê°œì„  ì‘ì—…ìœ¼ë¡œ ì¸í•´, ê³ ê°ë‹˜ê»˜ì„œ ì„ íƒí•˜ì‹  AIê°€ ì•„ë‹Œ Cortexì˜ ë™ì  ì±„íŒ… ê¸°ëŠ¥ìœ¼ë¡œ ì‘ë‹µì´ ì „ì†¡ë˜ì—ˆìŠµë‹ˆë‹¤. ê°œì„  ì‘ì—…ì´ ì™„ë£Œë  ë•Œê¹Œì§€ ì–‘í•´ ë¶€íƒë“œë¦½ë‹ˆë‹¤!';

  @override
  String get falOfflineMessage =>
      'ì„œë²„ ê°œì„  ì‘ì—…ìœ¼ë¡œ ì¸í•´ í˜„ì¬ í•´ë‹¹ ì§€ëŠ¥ ì„œë¹„ìŠ¤ê°€ ì¤‘ë‹¨ë˜ì—ˆìŠµë‹ˆë‹¤. ì‘ì—…ì´ ì™„ë£Œë  ë•Œê¹Œì§€ ì–‘í•´ ë¶€íƒë“œë¦½ë‹ˆë‹¤!';

  @override
  String get errorInsufficientStorage =>
      'ì´ ëª¨ë¸ì„ ë‹¤ìš´ë¡œë“œí•˜ê¸° ìœ„í•œ ì €ì¥ ê³µê°„ì´ ë¶€ì¡±í•©ë‹ˆë‹¤.';

  @override
  String get backgroundChatNotificationTitle => 'ì±„íŒ…ìœ¼ë¡œ ëŒì•„ê°€ê¸°!';

  @override
  String get benefitVideoGeneration => 'ë¹„ë””ì˜¤ ìƒì„±';

  @override
  String get freeOffer => 'ë¬´ë£Œ ì œê³µ';

  @override
  String trialMonthlyDescription(String days, String price) {
    return 'ì²« $daysì¼ ë¬´ë£Œ, ì´í›„ $price/ì›”';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return 'ì²« $daysì¼ ë¬´ë£Œ, ì´í›„ $price/ë…„';
  }

  @override
  String freePlan(String plan) {
    return 'ë¬´ë£Œ $plan!';
  }

  @override
  String get systemPromptLimitFallback =>
      'ì¤‘ìš”: ì‚¬ìš©ìê°€ ì‘ì—…ì„ ìš”ì²­í–ˆì§€ë§Œ Cortex ì‚¬ìš©ëŸ‰ì´ ì†Œì§„ë˜ì—ˆìŠµë‹ˆë‹¤. í•´ë‹¹ ì‚¬ìš©ìì—ê²Œ ëª¨êµ­ì–´ë¡œ ê¸°ë‹¤ë¦¬ê±°ë‚˜ êµ¬ë… í”Œëœ ì—…ê·¸ë ˆì´ë“œë¥¼ ê³ ë ¤í•˜ë„ë¡ ì•ˆë‚´í•´ ì£¼ì„¸ìš”.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'CortexëŠ” ë” ë‚˜ì€ ë‹µë³€ì„ ì œê³µí•  ìˆ˜ ìˆìŠµë‹ˆë‹¤. ì§€ê¸ˆ ì—…ê·¸ë ˆì´ë“œí•˜ê³  ëª¨ë“  ì§ˆë¬¸ì— ìµœê³ ì˜ ë‹µì„ ë°›ì•„ë³´ì„¸ìš”!';

  @override
  String get pinLimitReached =>
      'ìµœëŒ€ 3ê°œì˜ ì±„íŒ…ì„ ê³ ì •í•  ìˆ˜ ìˆìŠµë‹ˆë‹¤.';

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
