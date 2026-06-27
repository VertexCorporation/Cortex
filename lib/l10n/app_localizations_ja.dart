// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'ã‚ãªãŸã¯ã‚¿ã‚¤ãƒˆãƒ«ç”Ÿæˆè€…ã§ã™ã€‚ä»¥ä¸‹ã®ä¼šè©±ã«å¯¾ã—ã¦ã€2ï½5èªã®ã‚¿ã‚¤ãƒˆãƒ«ã®ã¿ã‚’è¿”ä¿¡ã—ã¦ãã ã•ã„ã€‚å¼•ç”¨ç¬¦ã€æ¥é ­è¾ã€å¥èª­ç‚¹ã¯ä½¿ç”¨ã—ãªã„ã§ãã ã•ã„ã€‚é‡è¦ï¼šã‚¿ã‚¤ãƒˆãƒ«ã¯ã€ãƒ¦ãƒ¼ã‚¶ãƒ¼ã®ãƒ¡ãƒƒã‚»ãƒ¼ã‚¸ã¨å®Œå…¨ã«åŒã˜è¨€èªã§ãªã‘ã‚Œã°ãªã‚Šã¾ã›ã‚“ã€‚';

  @override
  String get systemRoleFallback =>
      'ã‚ãªãŸã¯é ¼ã‚Šã«ãªã‚‹ã‚¢ã‚·ã‚¹ã‚¿ãƒ³ãƒˆã§ã™ã€‚';

  @override
  String get systemLanguageInstruction =>
      '\n\nCRITICAL: å¸¸ã«ãƒ¦ãƒ¼ã‚¶ãƒ¼ãŒå…¥åŠ›ã—ãŸè¨€èªã¨åŒã˜è¨€èªã§å¿œç­”ã—ã€ãƒ¦ãƒ¼ã‚¶ãƒ¼ã®è¨€èªã«æ³¨æ„ã—ã¦ãã ã•ã„ã€‚';

  @override
  String get systemNotePreviousMedia =>
      'ã€ã‚·ã‚¹ãƒ†ãƒ æ³¨è¨˜ï¼šä»¥ä¸‹ã¯ä»¥å‰ã«ç”Ÿæˆã•ã‚ŒãŸãƒ¡ãƒ‡ã‚£ã‚¢ã§ã™ã€‚å‚ç…§ã¾ãŸã¯ç·¨é›†ã—ã¦ãã ã•ã„ã€‚ã€‘';

  @override
  String systemTimeInfo(String formattedTime) {
    return '\n\nç¾åœ¨ã®æ—¥æ™‚: $formattedTimeã€‚';
  }

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\nã“ã‚Œã¾ã§ã®ä¼šè©±ã‚’åˆ†æã—ã¾ã™ã€‚ãƒ¦ãƒ¼ã‚¶ãƒ¼ã«é–¢ã™ã‚‹æ–°ã—ã„æ˜ç¢ºãªäº‹å®Ÿï¼ˆå¥½ã¿ã€åå‰ã€ç¿’æ…£ã€çŠ¶æ³ãªã©ï¼‰ãŒåˆ¤æ˜ã—ãŸå ´åˆã¯ã€å¿œç­”ã®æœ€å¾Œã«ã€ãƒ¦ãƒ¼ã‚¶ãƒ¼ã«é–¢ã™ã‚‹æ›´æ–°ã•ã‚ŒãŸãƒ¡ãƒ¢ãƒªå…¨ä½“ã‚’<memory>...</memory>ã‚¿ã‚°å†…ã«å‡ºåŠ›ã™ã‚‹å¿…è¦ãŒã‚ã‚Šã¾ã™ã€‚é‡è¦ï¼šä»¥å‰ã®ãƒ¡ãƒ¢ãƒªã‚’æ¶ˆå»ã¾ãŸã¯ä¸Šæ›¸ãã—ã¦ã¯ãªã‚Šã¾ã›ã‚“ã€‚å¸¸ã«æ–°ã—ã„äº‹å®Ÿã‚’æ—¢å­˜ã®ãƒ¡ãƒ¢ãƒªã«è¿½åŠ ã—ã¦ãã ã•ã„ã€‚æ–°ã—ã„æƒ…å ±ãŒå…¨ãåˆ¤æ˜ã—ãªã‹ã£ãŸå ´åˆã¯ã€ã‚¿ã‚°ã‚’çœç•¥ã—ã¦ãã ã•ã„ã€‚ä¾‹ï¼š<memory>ã‚µãƒƒã‚«ãƒ¼ã¨ãƒ†ãƒ‹ã‚¹ãŒå¥½ãã€‚çŸ­ã„å›ç­”ã‚’å¥½ã‚€ã€‚</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return '\n\nãƒ¦ãƒ¼ã‚¶ãƒ¼ã«ã¤ã„ã¦å¸¸ã«ä»¥ä¸‹ã‚’è¦šãˆã¦ãŠã„ã¦ãã ã•ã„ï¼š\n$userMemory';
  }

  @override
  String get cancel => 'ã‚­ãƒ£ãƒ³ã‚»ãƒ«';

  @override
  String get remove => 'å–ã‚Šé™¤ã';

  @override
  String get download => 'ãƒ€ã‚¦ãƒ³ãƒ­ãƒ¼ãƒ‰';

  @override
  String get resume => 'å†é–‹';

  @override
  String get copy => 'ã‚³ãƒ”ãƒ¼';

  @override
  String get chat => 'ãƒãƒ£ãƒƒãƒˆ';

  @override
  String get locked => 'Locked';

  @override
  String get languageModels => 'è¨€èªãƒ¢ãƒ‡ãƒ«';

  @override
  String get light => 'ãƒ©ã‚¤ãƒˆ';

  @override
  String get theme => 'ãƒ†ãƒ¼ãƒ';

  @override
  String get no => 'ã„ã„ãˆ';

  @override
  String get yes => 'ã¯ã„';

  @override
  String get done => 'å®Œäº†';

  @override
  String get bestValue => 'ãƒ™ã‚¹ãƒˆãƒãƒªãƒ¥ãƒ¼';

  @override
  String get selected => 'é¸æŠæ¸ˆã¿';

  @override
  String get descriptionSection => 'èª¬æ˜';

  @override
  String get searchHint => 'æ¤œç´¢';

  @override
  String get messageHint => 'ä½•ã§ã‚‚èã„ã¦ãã ã•ã„';

  @override
  String get messageCopied =>
      'ãƒ¡ãƒƒã‚»ãƒ¼ã‚¸ã‚’ã‚¯ãƒªãƒƒãƒ—ãƒœãƒ¼ãƒ‰ã«ã‚³ãƒ”ãƒ¼ã—ã¾ã—ãŸã€‚';

  @override
  String get retry => 'å†è©¦è¡Œ';

  @override
  String get systemInfo => 'ã‚·ã‚¹ãƒ†ãƒ æƒ…å ±';

  @override
  String deviceMemory(Object memory) {
    return 'ãƒ‡ãƒã‚¤ã‚¹ãƒ¡ãƒ¢ãƒª: $memory GB';
  }

  @override
  String get memory => 'ãƒ¡ãƒ¢ãƒª';

  @override
  String get storage => 'ã‚¹ãƒˆãƒ¬ãƒ¼ã‚¸';

  @override
  String get freeStorage => 'ç©ºãå®¹é‡';

  @override
  String get totalStorage => 'åˆè¨ˆã‚¹ãƒˆãƒ¬ãƒ¼ã‚¸';

  @override
  String get usedStorage => 'ä½¿ç”¨æ¸ˆã¿ã‚¹ãƒˆãƒ¬ãƒ¼ã‚¸';

  @override
  String get totalMemory => 'åˆè¨ˆãƒ¡ãƒ¢ãƒª';

  @override
  String get usedMemory => 'ä½¿ç”¨æ¸ˆã¿ãƒ¡ãƒ¢ãƒª';

  @override
  String get modelsTitle => 'ãƒ©ã‚¤ãƒ–ãƒ©ãƒª';

  @override
  String get localModels => 'ãƒ­ãƒ¼ã‚«ãƒ«ãƒ¢ãƒ‡ãƒ«';

  @override
  String get selectGGUFFile => 'GGUFãƒ•ã‚¡ã‚¤ãƒ«ã‚’é¸æŠ';

  @override
  String get errorGGUF =>
      'GGUFå½¢å¼ã®ãƒ•ã‚¡ã‚¤ãƒ«ã®ã¿ã‚’é¸æŠã—ã¦ãã ã•ã„ã€‚';

  @override
  String get myModels => 'ãƒã‚¤ãƒ¢ãƒ‡ãƒ«';

  @override
  String get create => 'ä½œæˆ';

  @override
  String modelProducer(Object producer) {
    return 'ãƒ—ãƒ­ãƒ‡ãƒ¥ãƒ¼ã‚µãƒ¼: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'åå‰ã‚’å¤‰æ›´';

  @override
  String get newTitle => 'æ–°ã—ã„ã‚¿ã‚¤ãƒˆãƒ«';

  @override
  String get save => 'ä¿å­˜';

  @override
  String get noConversationsMessage =>
      'ä¼šè©±ãŒã‚ã‚Šã¾ã›ã‚“ã€ãƒãƒ£ãƒƒãƒˆã‚’å§‹ã‚ã¾ã—ã‚‡ã†ï¼';

  @override
  String get startChat => 'ãƒãƒ£ãƒƒãƒˆã‚’é–‹å§‹';

  @override
  String get noChats => 'ãƒãƒ£ãƒƒãƒˆãŒã‚ã‚Šã¾ã›ã‚“';

  @override
  String get noStarredChats => 'ã‚¹ã‚¿ãƒ¼ä»˜ããƒãƒ£ãƒƒãƒˆãŒã‚ã‚Šã¾ã›ã‚“';

  @override
  String get noStarredChatsMessage =>
      'ã¾ã ã‚¹ã‚¿ãƒ¼ã‚’ä»˜ã‘ãŸãƒãƒ£ãƒƒãƒˆãŒã‚ã‚Šã¾ã›ã‚“ã€‚';

  @override
  String get starConversation => 'ã‚¹ã‚¿ãƒ¼';

  @override
  String get unstarConversation => 'ã‚¹ã‚¿ãƒ¼ã‚’å¤–ã™';

  @override
  String get loginToYourAccount => 'ãƒ­ã‚°ã‚¤ãƒ³';

  @override
  String get createYourAccount => 'ç™»éŒ²';

  @override
  String get email => 'ãƒ¡ãƒ¼ãƒ«ã‚¢ãƒ‰ãƒ¬ã‚¹';

  @override
  String get password => 'ãƒ‘ã‚¹ãƒ¯ãƒ¼ãƒ‰';

  @override
  String get confirmPassword => 'ãƒ‘ã‚¹ãƒ¯ãƒ¼ãƒ‰ã®ç¢ºèª';

  @override
  String get invalidEmail =>
      'æœ‰åŠ¹ãªãƒ¡ãƒ¼ãƒ«ã‚¢ãƒ‰ãƒ¬ã‚¹ã‚’å…¥åŠ›ã—ã¦ãã ã•ã„ã€‚';

  @override
  String get invalidPassword =>
      'ãƒ‘ã‚¹ãƒ¯ãƒ¼ãƒ‰ã¯6æ–‡å­—ä»¥ä¸Šã§ã‚ã‚‹å¿…è¦ãŒã‚ã‚Šã¾ã™ã€‚';

  @override
  String get rememberMe => 'ãƒ­ã‚°ã‚¤ãƒ³çŠ¶æ…‹ã‚’ç¶­æŒã™ã‚‹';

  @override
  String get forgotPassword => 'ãƒ‘ã‚¹ãƒ¯ãƒ¼ãƒ‰ã‚’ãŠå¿˜ã‚Œã§ã™ã‹ï¼Ÿ';

  @override
  String get or => 'ã¾ãŸã¯';

  @override
  String get continueWithGoogle => 'Googleã§ç¶šè¡Œ';

  @override
  String get dontHaveAccount =>
      'ã‚¢ã‚«ã‚¦ãƒ³ãƒˆã‚’ãŠæŒã¡ã§ãªã„ã§ã™ã‹ï¼Ÿ';

  @override
  String get alreadyHaveAccount =>
      'æ—¢ã«ã‚¢ã‚«ã‚¦ãƒ³ãƒˆã‚’ãŠæŒã¡ã§ã™ã‹ï¼Ÿ';

  @override
  String get signUp => 'ã‚µã‚¤ãƒ³ã‚¢ãƒƒãƒ—';

  @override
  String get logIn => 'ãƒ­ã‚°ã‚¤ãƒ³';

  @override
  String get passwordsDoNotMatch => 'ãƒ‘ã‚¹ãƒ¯ãƒ¼ãƒ‰ãŒä¸€è‡´ã—ã¾ã›ã‚“ã€‚';

  @override
  String get wrongPassword => 'ãƒ‘ã‚¹ãƒ¯ãƒ¼ãƒ‰ãŒæ­£ã—ãã‚ã‚Šã¾ã›ã‚“ã€‚';

  @override
  String get emailAlreadyInUse =>
      'ã“ã®ãƒ¡ãƒ¼ãƒ«ã‚¢ãƒ‰ãƒ¬ã‚¹ã¯æ—¢ã«ä½¿ç”¨ã•ã‚Œã¦ã„ã¾ã™ã€‚';

  @override
  String get weakPassword => 'ãƒ‘ã‚¹ãƒ¯ãƒ¼ãƒ‰ãŒå¼±ã™ãã¾ã™ã€‚';

  @override
  String get authError => 'èªè¨¼ã‚¨ãƒ©ãƒ¼';

  @override
  String get usernameTaken =>
      'ã“ã®ãƒ¦ãƒ¼ã‚¶ãƒ¼åã¯æ—¢ã«ä½¿ç”¨ã•ã‚Œã¦ã„ã¾ã™ã€‚';

  @override
  String get username => 'ãƒ¦ãƒ¼ã‚¶ãƒ¼å';

  @override
  String get resendCode => 'ç¢ºèªãƒ¡ãƒ¼ãƒ«ã‚’å†é€ä¿¡';

  @override
  String get pleaseCheckYourEmail =>
      'Cortexã‚’ä½¿ç”¨ã™ã‚‹ã«ã¯ã€ãƒ¡ãƒ¼ãƒ«ã‚¢ãƒ‰ãƒ¬ã‚¹ã®ç¢ºèªãŒå¿…è¦ã§ã™ã€‚\nç¢ºèªãƒªãƒ³ã‚¯ãŒã‚ãªãŸã®ãƒ¡ãƒ¼ãƒ«ã‚¢ãƒ‰ãƒ¬ã‚¹ã«é€ä¿¡ã•ã‚Œã¾ã—ãŸã€‚ãƒ¡ãƒ¼ãƒ«ã‚’ç¢ºèªã—ã¦ãã ã•ã„ã€‚';

  @override
  String get verifyYourEmail => 'ãƒ¡ãƒ¼ãƒ«ã‚¢ãƒ‰ãƒ¬ã‚¹ã‚’ç¢ºèª';

  @override
  String get seconds => 'ç§’';

  @override
  String get maxResendLimitReached =>
      'ç¢ºèªãƒ¡ãƒ¼ãƒ«ã®æœ€å¤§é€ä¿¡å›æ•°ã«é”ã—ã¾ã—ãŸ';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'ç¢ºèªã›ãšã«ç¶šè¡Œ';

  @override
  String get verificationScreenWarning =>
      'ç¶šè¡Œã—ã¦ã‚‚ã€ã‚¢ã‚«ã‚¦ãƒ³ãƒˆã®1æ—¥é–“ã®ç¢ºèªæœŸé–“ã¯æœ‰åŠ¹ã§ã™ã€‚ãã‚Œã¾ã§ã«ã‚¢ã‚«ã‚¦ãƒ³ãƒˆã‚’ç¢ºèªã—ãªã„å ´åˆã€ã‚¢ãƒ—ãƒªã‹ã‚‰å‰Šé™¤ã•ã‚Œã¾ã™ã€‚';

  @override
  String get unverifiedAccountHeader =>
      'ã‚ãªãŸã®ã‚¢ã‚«ã‚¦ãƒ³ãƒˆã¯ç¢ºèªã•ã‚Œã¦ã„ã¾ã›ã‚“';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return '$timeLeftä»¥å†…ã«ã‚¢ã‚«ã‚¦ãƒ³ãƒˆã‚’ç¢ºèªã—ãªã„å ´åˆã€å‰Šé™¤ã•ã‚Œã¾ã™';
  }

  @override
  String get verifyNow => 'ä»Šã™ãç¢ºèª';

  @override
  String get linkSent => 'ãƒªãƒ³ã‚¯ã‚’é€ä¿¡ã—ã¾ã—ãŸ';

  @override
  String get accountDeletionRequested =>
      'ã‚¢ã‚«ã‚¦ãƒ³ãƒˆã®å‰Šé™¤ãƒªã‚¯ã‚¨ã‚¹ãƒˆãŒå—ä¿¡ã•ã‚Œã€ã‚¢ã‚«ã‚¦ãƒ³ãƒˆã¯ç¾åœ¨ç„¡åŠ¹ã«ãªã£ã¦ã„ã¾ã™ã€‚';

  @override
  String get tooManyRequests => 'ãƒªã‚¯ã‚¨ã‚¹ãƒˆãŒå¤šã™ãã¾ã™';

  @override
  String get regenerate => 'å†ç”Ÿæˆ';

  @override
  String get confirmDeleteAccount =>
      'æœ¬å½“ã«ã‚¢ã‚«ã‚¦ãƒ³ãƒˆã‚’å‰Šé™¤ã—ã¾ã™ã‹ï¼Ÿ';

  @override
  String get deleteAccount => 'ã‚¢ã‚«ã‚¦ãƒ³ãƒˆã‚’å‰Šé™¤';

  @override
  String get delete => 'å‰Šé™¤';

  @override
  String get passwordRequired => 'ãƒ‘ã‚¹ãƒ¯ãƒ¼ãƒ‰ãŒå¿…è¦ã§ã™ã€‚';

  @override
  String get deleteDescription =>
      'å‰Šé™¤ã—ãŸãƒ‡ãƒ¼ã‚¿ã¯ã€å½“ç¤¾ã®ã‚µãƒ¼ãƒãƒ¼ã¨ã‚ãªãŸã®ãƒ‡ãƒã‚¤ã‚¹ã‹ã‚‰æ°¸ä¹…ã«å‰Šé™¤ã•ã‚Œã¾ã™ã€‚ã“ã®æ“ä½œã¯å…ƒã«æˆ»ã›ã¾ã›ã‚“ã€‚';

  @override
  String get editProfile => 'ãƒ—ãƒ­ãƒ•ã‚£ãƒ¼ãƒ«ã‚’ç·¨é›†';

  @override
  String get displayName => 'è¡¨ç¤ºå';

  @override
  String get profileUpdated =>
      'ãƒ—ãƒ­ãƒ•ã‚£ãƒ¼ãƒ«ãŒæ­£å¸¸ã«æ›´æ–°ã•ã‚Œã¾ã—ãŸ';

  @override
  String get logout => 'ãƒ­ã‚°ã‚¢ã‚¦ãƒˆ';

  @override
  String get profile => 'ãƒ—ãƒ­ãƒ•ã‚£ãƒ¼ãƒ«';

  @override
  String get manageProfileDescription =>
      'ã‚ãªãŸã®ãƒ—ãƒ­ãƒ•ã‚£ãƒ¼ãƒ«ã‚’ç®¡ç†ã—ã€ãƒ‘ã‚¹ãƒ¯ãƒ¼ãƒ‰ã‚’æ›´æ–°ã—ãŸã‚Šã€Cortexã‹ã‚‰ãƒ­ã‚°ã‚¢ã‚¦ãƒˆã—ãŸã‚Šã—ã¾ã™ã€‚';

  @override
  String get accessSettingsDescription =>
      'ãƒ˜ãƒ«ãƒ—ã¸ã®ã‚¢ã‚¯ã‚»ã‚¹ã€ã‚³ãƒ¼ãƒ‰ã®å¼•ãæ›ãˆã€Cortexã®å…±æœ‰ã€ãŠã‚ˆã³å½“ç¤¾ã®ãƒãƒªã‚·ãƒ¼ã®è¡¨ç¤ºã€‚';

  @override
  String get languageDescription =>
      'ã„ã¤ã§ã‚‚ãƒ‡ãƒ•ã‚©ãƒ«ãƒˆã®ã‚¢ãƒ—ãƒªã‚¤ãƒ³ã‚¿ãƒ¼ãƒ•ã‚§ãƒ¼ã‚¹è¨€èªã‚’å¤‰æ›´ã§ãã¾ã™ã€‚';

  @override
  String get themeDescription =>
      'å¥½ã¿ã«å¿œã˜ã¦ãƒ©ã‚¤ãƒˆãƒ†ãƒ¼ãƒã¨ãƒ€ãƒ¼ã‚¯ãƒ†ãƒ¼ãƒã‚’åˆ‡ã‚Šæ›¿ãˆã‚‹ã“ã¨ãŒã§ãã¾ã™ã€‚é¸æŠã—ãŸãƒ†ãƒ¼ãƒã¯Cortexã‚¤ãƒ³ã‚¿ãƒ¼ãƒ•ã‚§ãƒ¼ã‚¹å…¨ä½“ã«é©ç”¨ã•ã‚Œã¾ã™ã€‚';

  @override
  String get iHaveReadAndAgree => 'åˆ©ç”¨è¦ç´„ã«åŒæ„ã—ã¾ã™';

  @override
  String get downloading => 'ãƒ€ã‚¦ãƒ³ãƒ­ãƒ¼ãƒ‰ä¸­...';

  @override
  String get downloadSuccess => 'ãƒ€ã‚¦ãƒ³ãƒ­ãƒ¼ãƒ‰æˆåŠŸ';

  @override
  String get downloadFailed => 'ãƒ€ã‚¦ãƒ³ãƒ­ãƒ¼ãƒ‰å¤±æ•—';

  @override
  String downloaded(Object percent) {
    return '$percent% ãƒ€ã‚¦ãƒ³ãƒ­ãƒ¼ãƒ‰æ¸ˆã¿';
  }

  @override
  String get downloadPaused =>
      'ãƒ€ã‚¦ãƒ³ãƒ­ãƒ¼ãƒ‰ãŒä¸€æ™‚åœæ­¢ã—ã¾ã—ãŸã€‚';

  @override
  String get purchaseError => 'è³¼å…¥ã‚¨ãƒ©ãƒ¼';

  @override
  String get purchasePlus => 'Cortex Plusã‚’è³¼å…¥';

  @override
  String get plusDescription => 'ã‚¨ãƒªãƒ¼ãƒˆäººå·¥çŸ¥èƒ½ä½“é¨“';

  @override
  String get annual => 'å¹´é–“';

  @override
  String get monthly => 'æœˆé–“';

  @override
  String get manageSubscription => 'ã‚µãƒ–ã‚¹ã‚¯ãƒªãƒ—ã‚·ãƒ§ãƒ³ã‚’ç®¡ç†';

  @override
  String purchasePlan(String planName) {
    return '$planNameã‚’è³¼å…¥';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/æœˆã€æœˆæ‰•ã„';
  }

  @override
  String get purchasePro => 'Cortex Proã‚’è³¼å…¥';

  @override
  String get proDescription => 'ãƒ—ãƒ¬ãƒŸã‚¢äººå·¥çŸ¥èƒ½ä½“é¨“';

  @override
  String get purchaseUltra => 'Cortex Ultraã‚’è³¼å…¥';

  @override
  String get ultraDescription => 'äººå·¥çŸ¥èƒ½ã®ãƒ”ãƒ¼ã‚¯';

  @override
  String get upgradeSubscription =>
      'ã‚µãƒ–ã‚¹ã‚¯ãƒªãƒ—ã‚·ãƒ§ãƒ³ã‚’ã‚¢ãƒƒãƒ—ã‚°ãƒ¬ãƒ¼ãƒ‰';

  @override
  String get purchaseStreamError => 'è³¼å…¥ã‚¹ãƒˆãƒªãƒ¼ãƒ ã‚¨ãƒ©ãƒ¼ã€‚';

  @override
  String get productNotFound => 'è£½å“ãŒè¦‹ã¤ã‹ã‚Šã¾ã›ã‚“';

  @override
  String get noProductsFound => 'è£½å“ãŒè¦‹ã¤ã‹ã‚Šã¾ã›ã‚“';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'ã“ã®æ³¨æ–‡ã‚’è¡Œã†ã“ã¨ã«ã‚ˆã‚Šã€åˆ©ç”¨è¦ç´„ãŠã‚ˆã³ãƒ—ãƒ©ã‚¤ãƒã‚·ãƒ¼ãƒãƒªã‚·ãƒ¼ã«åŒæ„ã—ãŸã“ã¨ã«ãªã‚Šã¾ã™ã€‚ã“ã®ãƒ†ã‚­ã‚¹ãƒˆã‚’ã‚¯ãƒªãƒƒã‚¯ã™ã‚‹ã¨ã€å½“ç¤¾ã®åˆ©ç”¨è¦ç´„ãŠã‚ˆã³ãƒ—ãƒ©ã‚¤ãƒã‚·ãƒ¼ãƒãƒªã‚·ãƒ¼ã«ã¤ã„ã¦è©³ã—ãçŸ¥ã‚‹ã“ã¨ãŒã§ãã¾ã™ã€‚ç¾åœ¨ã®æœŸé–“ãŒçµ‚äº†ã™ã‚‹å°‘ãªãã¨ã‚‚24æ™‚é–“å‰ã«è‡ªå‹•æ›´æ–°ãŒã‚ªãƒ•ã«ã•ã‚Œãªã„é™ã‚Šã€ã‚µãƒ–ã‚¹ã‚¯ãƒªãƒ—ã‚·ãƒ§ãƒ³ã¯è‡ªå‹•çš„ã«æ›´æ–°ã•ã‚Œã¾ã™ã€‚';

  @override
  String get termsOfService => 'åˆ©ç”¨è¦ç´„';

  @override
  String get privacyPolicy => 'ãƒ—ãƒ©ã‚¤ãƒã‚·ãƒ¼ãƒãƒªã‚·ãƒ¼';

  @override
  String get renamed => 'åç§°å¤‰æ›´';

  @override
  String get report => 'å ±å‘Š';

  @override
  String get reportDialogTitle => 'å ±å‘Šã‚’é€ä¿¡';

  @override
  String get reportDescriptionLabel => 'å•é¡Œã¯ä½•ã§ã™ã‹ï¼Ÿ';

  @override
  String get reportHarmful => 'ã“ã‚Œã¯æœ‰å®³/å®‰å…¨ã§ã¯ã‚ã‚Šã¾ã›ã‚“';

  @override
  String get reportNotTrue => 'ã“ã‚Œã¯çœŸå®Ÿã§ã¯ã‚ã‚Šã¾ã›ã‚“';

  @override
  String get reportNotHelpful => 'ã“ã‚Œã¯å½¹ã«ç«‹ã¡ã¾ã›ã‚“';

  @override
  String get closeButton => 'é–‰ã˜ã‚‹';

  @override
  String get submitButton => 'é€ä¿¡';

  @override
  String get reportErrorMessage =>
      'å ±å‘Šã™ã‚‹ç†ç”±ã‚’1ã¤é¸æŠã—ã¦ãã ã•ã„ã€‚';

  @override
  String get capabilitiesSection => 'èƒ½åŠ›';

  @override
  String get featurePhotoTitle => 'å†™çœŸã‚¹ã‚­ãƒ£ãƒ³';

  @override
  String get featurePhotoDescription =>
      'ã“ã®ãƒ¢ãƒ‡ãƒ«ã¯ã€ã‚«ãƒ¡ãƒ©ã‚„ç”»åƒãƒ•ã‚¡ã‚¤ãƒ«ã‚’é€šã˜ã¦å†™çœŸã‚’ã‚¹ã‚­ãƒ£ãƒ³ã™ã‚‹èƒ½åŠ›ã‚’æŒã£ã¦ã„ã¾ã™ã€‚';

  @override
  String get featureOfflineTitle => 'ã‚ªãƒ•ãƒ©ã‚¤ãƒ³æ“ä½œ';

  @override
  String get featureOfflineDescription =>
      'ã‚¤ãƒ³ã‚¿ãƒ¼ãƒãƒƒãƒˆæ¥ç¶šãªã—ã§ãƒ¢ãƒ‡ãƒ«ã‚’å®Ÿè¡Œã—ã€ãƒ‡ãƒ¼ã‚¿ã‚’å®‰å…¨ã«ä¿ã¡ã¾ã™ã€‚';

  @override
  String get featureRoleplayTitle => 'ãƒ­ãƒ¼ãƒ«ãƒ—ãƒ¬ã‚¤';

  @override
  String get featureRoleplayDescription =>
      'ãƒ­ãƒ¼ãƒ«ãƒ—ãƒ¬ã‚¤ãƒ³ã‚°ãƒ¢ãƒ‡ãƒ«ã‚’ä½¿ç”¨ã™ã‚‹ã¨ã€ã•ã¾ã–ã¾ãªãƒãƒ£ãƒƒãƒˆã‚„ã‚·ãƒŠãƒªã‚ªã‚’ä½œæˆã§ãã¾ã™ã€‚';

  @override
  String get roleModels => 'ãƒ­ãƒ¼ãƒ«ãƒ—ãƒ¬ã‚¤ãƒ¢ãƒ‡ãƒ«';

  @override
  String get parameters => 'ãƒ‘ãƒ©ãƒ¡ãƒ¼ã‚¿';

  @override
  String get context => 'ã‚³ãƒ³ãƒ†ã‚­ã‚¹ãƒˆ';

  @override
  String get finalPreparation => 'æœ€çµ‚æº–å‚™ãŒè¡Œã‚ã‚Œã¦ã„ã¾ã™ã€‚';

  @override
  String get shareApp => 'ã‚¢ãƒ—ãƒªã‚’å…±æœ‰';

  @override
  String get ourStory => 'ç§ãŸã¡ã®ç‰©èª';

  @override
  String get rateUs => 'è©•ä¾¡ã™ã‚‹';

  @override
  String get share => 'å…±æœ‰';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'ãƒ†ã‚­ã‚¹ãƒˆã‚’é¸æŠ';

  @override
  String get thinking => 'è€ƒãˆä¸­';

  @override
  String get user => 'ãƒ¦ãƒ¼ã‚¶ãƒ¼';

  @override
  String get help => 'ãƒ˜ãƒ«ãƒ—';

  @override
  String get supportCreator => 'ã‚¯ãƒªã‚¨ã‚¤ã‚¿ãƒ¼ã‚’ã‚µãƒãƒ¼ãƒˆã™ã‚‹';

  @override
  String get enterYourTag =>
      'ãŠæ°—ã«å…¥ã‚Šã®ã‚¯ãƒªã‚¨ã‚¤ã‚¿ãƒ¼ã‚’å¿œæ´ã—ã¾ã—ã‚‡ã†ï¼ä»¥ä¸‹ã®ã‚¿ã‚°ã‚’å…¥åŠ›ã™ã‚‹ã¨ã€Cortex ã§ã®è³¼å…¥ã®ä¸€éƒ¨ãŒã‚¯ãƒªã‚¨ã‚¤ã‚¿ãƒ¼ã«å¯„ä»˜ã•ã‚Œã¾ã™ã€‚';

  @override
  String get creatorTag => 'ã‚¯ãƒªã‚¨ã‚¤ã‚¿ãƒ¼ã‚¿ã‚°';

  @override
  String get support => 'ã‚µãƒãƒ¼ãƒˆ';

  @override
  String get tagCannotBeEmpty => 'ä½œæˆè€…ã‚¿ã‚°ã¯ç©ºã«ã§ãã¾ã›ã‚“';

  @override
  String get userId => 'ãƒ¦ãƒ¼ã‚¶ãƒ¼ID';

  @override
  String get deleteAllConversationsConfirmTitle =>
      'ã™ã¹ã¦ã®ãƒãƒ£ãƒƒãƒˆã‚’å‰Šé™¤ã—ã¾ã™ã‹ï¼Ÿ';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'æœ¬å½“ã«ã™ã¹ã¦ã®ãƒãƒ£ãƒƒãƒˆã‚’å‰Šé™¤ã—ã¦ã‚‚ã‚ˆã‚ã—ã„ã§ã™ã‹ï¼Ÿã“ã®æ“ä½œã¯å…ƒã«æˆ»ã›ã¾ã›ã‚“ã€‚';

  @override
  String get conversationDeleted => 'ä¼šè©±ãŒå‰Šé™¤ã•ã‚Œã¾ã—ãŸ!';

  @override
  String get allConversationsDeleted =>
      'ã™ã¹ã¦ã®ä¼šè©±ãŒæ­£å¸¸ã«å‰Šé™¤ã•ã‚Œã¾ã—ãŸï¼';

  @override
  String get deleteAll => 'ã™ã¹ã¦å‰Šé™¤';

  @override
  String get deleteAllConversationsButton => 'ã™ã¹ã¦ã®ä¼šè©±ã‚’å‰Šé™¤';

  @override
  String get confirmWord => 'VERTEXã¨å…¥åŠ›';

  @override
  String get confirmWordError => 'å…¥åŠ›ãŒé–“é•ã£ã¦ã„ã¾ã™';

  @override
  String get chinese => 'ä¸­å›½èª';

  @override
  String get french => 'ãƒ•ãƒ©ãƒ³ã‚¹èª';

  @override
  String get japanese => 'æ—¥æœ¬èª';

  @override
  String get dutch => 'ã‚ªãƒ©ãƒ³ãƒ€èª';

  @override
  String get russian => 'ãƒ­ã‚·ã‚¢';

  @override
  String get korean => 'éŸ“å›½èª';

  @override
  String get english => 'è‹±èª';

  @override
  String get turkish => 'ãƒˆãƒ«ã‚³èª';

  @override
  String get hindi => 'ãƒ’ãƒ³ãƒ‡ã‚£ãƒ¼èª';

  @override
  String get portuguese => 'ãƒãƒ«ãƒˆã‚¬ãƒ«èª';

  @override
  String get indonesian => 'ã‚¤ãƒ³ãƒ‰ãƒã‚·ã‚¢èª';

  @override
  String get azerbaijani => 'ã‚¢ã‚¼ãƒ«ãƒã‚¤ã‚¸ãƒ£ãƒ³èª';

  @override
  String get german => 'ãƒ‰ã‚¤ãƒ„èª';

  @override
  String get spanish => 'ã‚¹ãƒšã‚¤ãƒ³èª';

  @override
  String get italian => 'ã‚¤ã‚¿ãƒªã‚¢èª';

  @override
  String get arabic => 'ã‚¢ãƒ©ãƒ“ã‚¢èª';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'ãƒ¦ãƒ¼ã‚¶ãƒ¼åãŒçŸ­ã™ãã¾ã™ã€‚';

  @override
  String get usernameTooLong =>
      'ãƒ¦ãƒ¼ã‚¶ãƒ¼åã¯16æ–‡å­—ã‚’è¶…ãˆã‚‹ã“ã¨ã¯ã§ãã¾ã›ã‚“ã€‚';

  @override
  String get invalidUsernameCharacters =>
      'ãƒ¦ãƒ¼ã‚¶ãƒ¼åã«ã¯ã€\'abcÃ§defgÄŸhÄ±ijklmnoÃ¶prsÅŸtuÃ¼vyzxqw\'ã®æ–‡å­—ã¨ã€\'.\'ã€\'-\'ã€\'_\'ã®è¨˜å·ã®ã¿ä½¿ç”¨ã§ãã¾ã™ã€‚';

  @override
  String get noInternetConnection =>
      'ã‚¤ãƒ³ã‚¿ãƒ¼ãƒãƒƒãƒˆæ¥ç¶šãŒã‚ã‚Šã¾ã›ã‚“ã€‚';

  @override
  String get chats => 'å—ä¿¡ãƒˆãƒ¬ã‚¤';

  @override
  String get library => 'ãƒ©ã‚¤ãƒ–ãƒ©ãƒª';

  @override
  String get text => 'ãƒ†ã‚­ã‚¹ãƒˆ';

  @override
  String get removeModel => 'ãƒ¢ãƒ‡ãƒ«ã‚’å‰Šé™¤';

  @override
  String get insufficientRAM => 'ãƒ¡ãƒ¢ãƒªä¸è¶³';

  @override
  String get insufficientStorage => 'ã‚¹ãƒˆãƒ¬ãƒ¼ã‚¸ä¸è¶³';

  @override
  String confirmRemoveModel(Object model) {
    return 'ãƒ‡ãƒã‚¤ã‚¹ã‹ã‚‰ $model ãƒ¢ãƒ‡ãƒ«ã‚’å‰Šé™¤ã—ã¦ã‚‚ã‚ˆã‚ã—ã„ã§ã™ã‹ï¼Ÿå‰Šé™¤ã™ã‚‹ã¨ã€ãã®ãƒ¢ãƒ‡ãƒ«ã¨ã®ä»¥å‰ã®ä¼šè©±ã‚‚ã™ã¹ã¦å‰Šé™¤ã•ã‚Œã¾ã™ã€‚';
  }

  @override
  String get noMatchingModels =>
      'ä¸€è‡´ã™ã‚‹ãƒ¢ãƒ‡ãƒ«ãŒè¦‹ã¤ã‹ã‚Šã¾ã›ã‚“ã§ã—ãŸã€‚';

  @override
  String get benefit1 => 'ä¼šè©±åˆ¶é™ã®æ‹¡å¤§';

  @override
  String get benefit3 => 'ãƒ—ãƒ­ãƒ•ã‚£ãƒ¼ãƒ«ã‚¨ãƒ•ã‚§ã‚¯ãƒˆ';

  @override
  String get benefit4 => 'ãƒ¡ãƒ³ãƒãƒ¼ã‚·ãƒƒãƒ—ãƒãƒƒã‚¸';

  @override
  String get benefit5 => 'ã‚ˆã‚Šå¤šãã®ã‚ªãƒ³ãƒ©ã‚¤ãƒ³AIã‚’ä½œæˆ';

  @override
  String get benefit7 => 'ä½¿ç”¨åˆ¶é™ã®æ‹¡å¤§';

  @override
  String get benefit8 => 'ãƒ¢ãƒ‡ãƒ«ã‚’è¿½åŠ ';

  @override
  String get benefit9 => 'æ–°ã—ã„ãƒ†ãƒ¼ãƒ';

  @override
  String get benefit10 => 'ãã®ä»–ã®æ·»ä»˜ãƒ•ã‚¡ã‚¤ãƒ«';

  @override
  String get benefit11 => 'ã‚ˆã‚Šå¤šãã®æµã‚Œãƒ¢ãƒ¼ãƒ‰';

  @override
  String get oldBenefits => 'ä¸‹ä½ãƒ—ãƒ©ãƒ³ã®ã™ã¹ã¦ã®ç‰¹å…¸';

  @override
  String get confirm => 'ç¢ºèª';

  @override
  String get changePassword => 'ãƒ‘ã‚¹ãƒ¯ãƒ¼ãƒ‰ã‚’å¤‰æ›´';

  @override
  String get logoutConfirmationTitle =>
      'æœ¬å½“ã«ãƒ­ã‚°ã‚¢ã‚¦ãƒˆã—ã¾ã™ã‹ï¼Ÿ';

  @override
  String get settings => 'è¨­å®š';

  @override
  String get language => 'ã‚¢ãƒ—ãƒªè¨€èª';

  @override
  String get dark => 'ãƒ€ãƒ¼ã‚¯';

  @override
  String get oldPassword => 'å¤ã„ãƒ‘ã‚¹ãƒ¯ãƒ¼ãƒ‰';

  @override
  String get newPassword => 'æ–°ã—ã„ãƒ‘ã‚¹ãƒ¯ãƒ¼ãƒ‰';

  @override
  String get passwordUpdated => 'ãƒ‘ã‚¹ãƒ¯ãƒ¼ãƒ‰ãŒæ›´æ–°ã•ã‚Œã¾ã—ãŸã€‚';

  @override
  String get stop => 'åœæ­¢';

  @override
  String get copyrights => 'å¸°å±';

  @override
  String get love => 'æ„›';

  @override
  String get nature => 'è‡ªç„¶';

  @override
  String get behindTheSlaughter => 'è™æ®ºã®è£å´';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Sunset';

  @override
  String get coffee => 'Coffee';

  @override
  String get deepSpace => 'Deep Space';

  @override
  String get grayscale => 'ã‚°ãƒ¬ãƒ¼ã‚¹ã‚±ãƒ¼ãƒ«';

  @override
  String get ocean => 'æµ·';

  @override
  String get scarletSnow => 'ç·‹è‰²ã®é›ª';

  @override
  String get requestFailed =>
      'ã‚¨ãƒ©ãƒ¼ãŒç™ºç”Ÿã—ã¾ã—ãŸã€‚ã‚‚ã†ä¸€åº¦ãŠè©¦ã—ãã ã•ã„ã€‚';

  @override
  String get changeModel => 'å¤‰æ›´';

  @override
  String get edit => 'ç·¨é›†';

  @override
  String get editingMessageInfo =>
      'ã“ã®ãƒ¡ãƒƒã‚»ãƒ¼ã‚¸ã‚’ç·¨é›†ã™ã‚‹ã¨ã€ã“ã“ã‹ã‚‰ä¼šè©±ãŒå†é–‹ã•ã‚Œã¾ã™ã€‚';

  @override
  String get editingNotification => 'ç¾åœ¨ç·¨é›†ãƒ¢ãƒ¼ãƒ‰ã§ã™';

  @override
  String get featurePluralTitle => 'è¤‡æ•°';

  @override
  String get featurePluralDescription =>
      'ã“ã®ãƒ¢ãƒ‡ãƒ«ã¯è¿½åŠ ã®æ‹¡å¼µæ©Ÿèƒ½ã‚’è‡ªå‹•çš„ã«çµ±åˆã—ã€ãã‚Œã«ã‚ˆã£ã¦æ©Ÿèƒ½çš„èƒ½åŠ›ã‚’æ‹¡å¼µã—ã¦ã€å¤šæ§˜ãªæ“ä½œã‚’å¼·åŒ–ã•ã‚ŒãŸãƒ‘ãƒ•ã‚©ãƒ¼ãƒãƒ³ã‚¹ã§ã‚µãƒãƒ¼ãƒˆã—ã¾ã™ã€‚';

  @override
  String get nameLabel => 'AIã®åå‰';

  @override
  String get summaryLabel => 'AIã®æ¦‚è¦';

  @override
  String get add => 'è¿½åŠ ';

  @override
  String get aiExplanationTitle => 'AIã®èª¬æ˜';

  @override
  String get aiExplanationDescription =>
      'AIãƒ¢ãƒ‡ãƒ«ã®ã‚¢ãƒ¼ã‚­ãƒ†ã‚¯ãƒãƒ£ã€ãƒˆãƒ¬ãƒ¼ãƒ‹ãƒ³ã‚°ãƒ—ãƒ­ã‚»ã‚¹ã€ãƒ‘ãƒ•ã‚©ãƒ¼ãƒãƒ³ã‚¹ãƒ¡ãƒˆãƒªã‚¯ã‚¹ã€å¿œç”¨åˆ†é‡ã€ãã®ä»–ã®é‡è¦ãªç‰¹å¾´ã«ã¤ã„ã¦è©³ç´°ãªèª¬æ˜ã‚’æä¾›ã—ã¦ãã ã•ã„ã€‚';

  @override
  String get preInputTitle => 'AIã®äº‹å‰å…¥åŠ›';

  @override
  String get preInputDescription =>
      'ã‚­ãƒ£ãƒ©ã‚¯ã‚¿ãƒ¼ä½œæˆãƒ—ãƒ­ã‚»ã‚¹ã§ãƒ¢ãƒ‡ãƒ«ã‚’ã‚¬ã‚¤ãƒ‰ã™ã‚‹äº‹å‰å…¥åŠ›ã‚’è¨­å®šã—ã¦ãã ã•ã„ã€‚ã“ã®ã‚»ã‚¯ã‚·ãƒ§ãƒ³ã§ã¯ã€ã‚­ãƒ£ãƒ©ã‚¯ã‚¿ãƒ¼é–¢é€£ã®æƒ…å ±ã€è¿½åŠ ã®ã‚³ãƒ³ãƒ†ã‚­ã‚¹ãƒˆã€ãŠã‚ˆã³ã‚­ãƒ£ãƒ©ã‚¯ã‚¿ãƒ¼ã«é–¢é€£ã™ã‚‹ã‚³ãƒ³ãƒ†ãƒ³ãƒ„ã®ç”Ÿæˆã«å½¹ç«‹ã¤å¯èƒ½æ€§ã®ã‚ã‚‹è¿½åŠ ã®è©³ç´°ã‚’å«ã‚ã‚‹ã“ã¨ãŒã§ãã¾ã™ã€‚';

  @override
  String get baseModelTitle => 'ãƒ™ãƒ¼ã‚¹ãƒ¢ãƒ‡ãƒ«';

  @override
  String get baseModelDescription =>
      'ã“ã‚Œã¯ã‚ãªãŸã®å‰µé€ ç‰©ã®åŸºç›¤ã¨ã—ã¦ä½¿ç”¨ã•ã‚Œã‚‹ãƒ¢ãƒ‡ãƒ«ã§ã™ã€‚ç¾åœ¨é¸æŠã•ã‚Œã¦ã„ã‚‹ãƒ™ãƒ¼ã‚¹ãƒ¢ãƒ‡ãƒ«ã‚’è¡¨ç¤ºã—ã¾ã™ã€‚';

  @override
  String get summary => 'æ¦‚è¦';

  @override
  String get modelUploadTitle => 'AIãƒ•ã‚¡ã‚¤ãƒ«';

  @override
  String get modelUploadDescription =>
      'ãƒ‡ãƒã‚¤ã‚¹ã‹ã‚‰ç›´æ¥ãƒ­ãƒ¼ã‚«ãƒ«ã®GGUFãƒ•ã‚¡ã‚¤ãƒ«ã‚’é¸æŠã—ã¦ã‚¢ãƒƒãƒ—ãƒ­ãƒ¼ãƒ‰ã—ã¾ã™ã€‚ã“ã‚Œã«ã‚ˆã‚Šã€ã‚¤ãƒ³ã‚¿ãƒ¼ãƒãƒƒãƒˆæ¥ç¶šãªã—ã§ãƒ¢ãƒ‡ãƒ«ã‚’ã‚ªãƒ•ãƒ©ã‚¤ãƒ³ã§å®Ÿè¡Œã§ãã¾ã™ã€‚ãƒ•ã‚¡ã‚¤ãƒ«ãŒæœ‰åŠ¹ãªGGUFå½¢å¼ã§ã‚ã‚Šã€é©åˆ‡ã«æ§‹é€ åŒ–ã•ã‚Œã¦ã„ã‚‹ã“ã¨ã‚’ç¢ºèªã—ã¦ãã ã•ã„ã€‚ãƒ•ã‚¡ã‚¤ãƒ«ãŒæ­£ã—ããªã„ã‹ç ´æã—ã¦ã„ã‚‹å ´åˆã€Cortexã¯æœŸå¾…ã©ãŠã‚Šã«æ©Ÿèƒ½ã—ãªã„å¯èƒ½æ€§ãŒã‚ã‚Šã€ã‚¨ãƒ©ãƒ¼ãŒç™ºç”Ÿã™ã‚‹å¯èƒ½æ€§ãŒã‚ã‚Šã¾ã™ã€‚';

  @override
  String get modelUploadShortDescription =>
      'ã“ã“ã‚’ã‚¿ãƒƒãƒ—ã—ã¦ãƒ‡ãƒã‚¤ã‚¹ã‹ã‚‰.ggufãƒ•ã‚¡ã‚¤ãƒ«ã‚’é¸æŠ';

  @override
  String get you => 'ã‚ãªãŸ';

  @override
  String get removePhotoTitle => 'å†™çœŸã‚’å‰Šé™¤';

  @override
  String get confirmRemovePhoto => 'æœ¬å½“ã«å†™çœŸã‚’å‰Šé™¤ã—ã¾ã™ã‹ï¼Ÿ';

  @override
  String get chatLengthLimitExceeded =>
      'ã“ã®ãƒãƒ£ãƒƒãƒˆã¯æ–‡å­—æ•°åˆ¶é™ã‚’è¶…ãˆã¾ã—ãŸã€‚æ–°ã—ã„ãƒãƒ£ãƒƒãƒˆã‚’é–‹å§‹ã™ã‚‹ã‹ã€ã‚µãƒ–ã‚¹ã‚¯ãƒªãƒ—ã‚·ãƒ§ãƒ³ã‚’è³¼å…¥ã—ã¦ãã ã•ã„ã€‚';

  @override
  String get inappropriateContentDetected =>
      'ä¸é©åˆ‡ãªã‚³ãƒ³ãƒ†ãƒ³ãƒ„ãŒæ¤œå‡ºã•ã‚Œã¾ã—ãŸï¼';

  @override
  String get offlineModelNotInstalled =>
      'ã“ã®ã‚ªãƒ•ãƒ©ã‚¤ãƒ³ãƒ¢ãƒ‡ãƒ«ã¯ãƒ‡ãƒã‚¤ã‚¹ã«ã‚¤ãƒ³ã‚¹ãƒˆãƒ¼ãƒ«ã•ã‚Œã¦ã„ã¾ã›ã‚“ã€‚';

  @override
  String get reachedLimit =>
      'ä½¿ç”¨åˆ¶é™ã«é”ã—ã¾ã—ãŸã€‚åˆ¶é™ã‚’å¢—ã‚„ã™ã«ã¯ã€ãƒ—ãƒ©ãƒ³ã‚’ã‚¢ãƒƒãƒ—ã‚°ãƒ¬ãƒ¼ãƒ‰ã—ã¦ãã ã•ã„ã€‚(åˆ¶é™ãŒãªããªã‚‹ã®ã¯æ®‹å¿µãªã“ã¨ã§ã™ã‚ˆã­ã€‚ã§ã‚‚ã€ç´ æ™´ã‚‰ã—ã„è¿”ä¿¡ã‚’å—ã‘å–ã‚‹ã®ã¯ç„¡æ–™ã§ã¯ãªã„ã®ã§ã€ã“ã®åˆ¶é™ã¯ç§ãŸã¡ãŒæ¥½ã—ã„æ™‚é–“ã‚’éã”ã—ç¶šã‘ã‚‹ãŸã‚ã«å½¹ç«‹ã£ã¦ã„ã‚‹ã‚“ã§ã™ã€‚)';

  @override
  String get modality => 'ãƒ¢ãƒ€ãƒªãƒ†ã‚£';

  @override
  String get multimodal => 'ãƒãƒ«ãƒãƒ¢ãƒ¼ãƒ€ãƒ«';

  @override
  String get anErrorOccurred => 'ã‚¨ãƒ©ãƒ¼ãŒç™ºç”Ÿã—ã¾ã—ãŸ';

  @override
  String get themeLocked =>
      'ã“ã®ãƒ†ãƒ¼ãƒã«ã¯ã‚ˆã‚Šé«˜ã„ã‚µãƒ–ã‚¹ã‚¯ãƒªãƒ—ã‚·ãƒ§ãƒ³ãƒ¬ãƒ™ãƒ«ãŒå¿…è¦ã§ã™ã€‚ãƒ­ãƒƒã‚¯ã‚’è§£é™¤ã™ã‚‹ã«ã¯ã‚¢ãƒƒãƒ—ã‚°ãƒ¬ãƒ¼ãƒ‰ã—ã¦ãã ã•ã„ã€‚';

  @override
  String get pageCouldNotBeLoaded =>
      'ãƒšãƒ¼ã‚¸ã‚’èª­ã¿è¾¼ã‚ã¾ã›ã‚“ã§ã—ãŸ';

  @override
  String get checkYourInternet =>
      'ã‚¤ãƒ³ã‚¿ãƒ¼ãƒãƒƒãƒˆæ¥ç¶šã‚’ç¢ºèªã—ã¦ã€ã‚‚ã†ä¸€åº¦ãŠè©¦ã—ãã ã•ã„ã€‚';

  @override
  String get errorUserNotAuthenticated =>
      'ã“ã®æ“ä½œã‚’å®Ÿè¡Œã™ã‚‹ã«ã¯ãƒ­ã‚°ã‚¤ãƒ³ã™ã‚‹å¿…è¦ãŒã‚ã‚Šã¾ã™ã€‚';

  @override
  String get errorReachedLimit =>
      'åˆ¶é™ã«é”ã—ã¾ã—ãŸã€‚ã‚¢ãƒƒãƒ—ã‚°ãƒ¬ãƒ¼ãƒ‰ã—ã¦ãƒ­ãƒƒã‚¯ã‚’è§£é™¤ã—ã€ãƒãƒ£ãƒƒãƒˆã‚’ç¶šã‘ã¾ã—ã‚‡ã†ã€‚';

  @override
  String get errorServer =>
      'äºˆæœŸã›ã¬ã‚µãƒ¼ãƒãƒ¼ã‚¨ãƒ©ãƒ¼ãŒç™ºç”Ÿã—ã¾ã—ãŸã€‚å¾Œã§ã‚‚ã†ä¸€åº¦ãŠè©¦ã—ãã ã•ã„ã€‚';

  @override
  String get errorNetwork =>
      'ãƒãƒƒãƒˆãƒ¯ãƒ¼ã‚¯ã‚¨ãƒ©ãƒ¼ãŒç™ºç”Ÿã—ã¾ã—ãŸã€‚æ¥ç¶šã‚’ç¢ºèªã—ã¦ã‚‚ã†ä¸€åº¦ãŠè©¦ã—ãã ã•ã„ã€‚';

  @override
  String get baseModelForCharacterDescription =>
      'é¸æŠã•ã‚ŒãŸãƒ™ãƒ¼ã‚¹ãƒ¢ãƒ‡ãƒ«ãŒã€ã‚­ãƒ£ãƒ©ã‚¯ã‚¿ãƒ¼ã®æ¨è«–ãŠã‚ˆã³å¿œç­”èƒ½åŠ›ã‚’æ±ºå®šã—ã¾ã™ã€‚';

  @override
  String get selectBaseModel => 'ãƒ™ãƒ¼ã‚¹ãƒ¢ãƒ‡ãƒ«ã‚’é¸æŠ';

  @override
  String get falErrorImageRequired =>
      'ã“ã®AIã¯å‚ç…§ç”»åƒã‚’å¿…è¦ã¨ã—ã¾ã™ã€‚ç”»åƒã‚’æ·»ä»˜ã—ã¦å†åº¦ãŠè©¦ã—ãã ã•ã„ã€‚';

  @override
  String get falErrorAudioRequired =>
      'ã“ã®ãƒ¢ãƒ‡ãƒ«ã«ã¯å‚ç…§éŸ³å£°ãƒ•ã‚¡ã‚¤ãƒ«ãŒå¿…è¦ã§ã™ã€‚éŸ³å£°ãƒ•ã‚¡ã‚¤ãƒ«ã‚’æ·»ä»˜ã—ã¦ã€ã‚‚ã†ä¸€åº¦ãŠè©¦ã—ãã ã•ã„ã€‚';

  @override
  String get falErrorVideoRequired =>
      'ã“ã®ãƒ¢ãƒ‡ãƒ«ã«ã¯å‚è€ƒå‹•ç”»ãŒå¿…è¦ã§ã™ã€‚å‹•ç”»ã‚’æ·»ä»˜ã—ã¦å†åº¦ãŠè©¦ã—ãã ã•ã„ã€‚';

  @override
  String get falErrorImageCorrupted =>
      'ã‚¢ãƒƒãƒ—ãƒ­ãƒ¼ãƒ‰ã•ã‚ŒãŸç”»åƒã¯å‡¦ç†ã§ãã¾ã›ã‚“ã§ã—ãŸã€‚åˆ¥ã®å½¢å¼ã‚’ãŠè©¦ã—ãã ã•ã„ã€‚';

  @override
  String get falErrorSchemaRejected =>
      'ãƒ¢ãƒ‡ãƒ«ãŒå…¥åŠ›å€¤ã‚’æ‹’å¦ã—ã¾ã—ãŸã€‚åˆ¥ã®ãƒ¢ãƒ‡ãƒ«ã‚’ãŠè©¦ã—ãã ã•ã„ã€‚';

  @override
  String get falErrorSchemaInvalid =>
      'å…¥åŠ›ã¯ç”Ÿæˆã‚µãƒ¼ãƒ“ã‚¹ã«ã‚ˆã£ã¦æ‹’å¦ã•ã‚Œã¾ã—ãŸã€‚';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'ç”Ÿæˆã‚µãƒ¼ãƒ“ã‚¹ãŒã‚¨ãƒ©ãƒ¼ã‚’è¿”ã—ã¾ã—ãŸï¼ˆã‚¹ãƒ†ãƒ¼ã‚¿ã‚¹ï¼š$statusCodeï¼‰ã€‚';
  }

  @override
  String get couldNotOpenLink => 'ãƒªãƒ³ã‚¯ã‚’é–‹ã‘ã¾ã›ã‚“ã§ã—ãŸ';

  @override
  String get downloadStarted => 'ãƒ€ã‚¦ãƒ³ãƒ­ãƒ¼ãƒ‰ã‚’é–‹å§‹ã—ã¾ã—ãŸ';

  @override
  String get notAvailable => 'åˆ©ç”¨ä¸å¯';

  @override
  String get localizationWarning =>
      'ä¸€éƒ¨ã®æƒ…å ±ã¯ã‚ãªãŸã®è¨€èªã§åˆ©ç”¨ã§ããªã„å ´åˆãŒã‚ã‚Šã€è‹±èªã§è¡¨ç¤ºã•ã‚Œã¾ã™ã€‚';

  @override
  String get aiTranslationWarning =>
      'ãƒ¢ãƒ‡ãƒ«æƒ…å ±ã¯ä»–ã®AIãƒ¢ãƒ‡ãƒ«ã«ã‚ˆã£ã¦æ§˜ã€…ãªè¨€èªã«ç¿»è¨³ã•ã‚Œã¦ã„ã¾ã™ã€‚ãã®ãŸã‚ã€è‹±èªä»¥å¤–ã®è¨€èªã§ã¯è»½å¾®ãªä¸ä¸€è‡´ãŒç”Ÿã˜ã‚‹å¯èƒ½æ€§ãŒã‚ã‚Šã¾ã™ã€‚';

  @override
  String get errorLoadingTitle =>
      'ãƒ‡ãƒ¼ã‚¿ã®èª­ã¿è¾¼ã¿ã«å¤±æ•—ã—ã¾ã—ãŸ';

  @override
  String get errorLoadingMessage =>
      'ã‚µãƒ¼ãƒãƒ¼ã‹ã‚‰å¿…è¦ãªãƒ‡ãƒ¼ã‚¿ã‚’å–å¾—ã§ãã¾ã›ã‚“ã§ã—ãŸã€‚ã‚¤ãƒ³ã‚¿ãƒ¼ãƒãƒƒãƒˆæ¥ç¶šã‚’ç¢ºèªã—ã¦ã€ã‚‚ã†ä¸€åº¦ãŠè©¦ã—ãã ã•ã„ã€‚';

  @override
  String get noFoundTitle => 'çµæœãŒã‚ã‚Šã¾ã›ã‚“';

  @override
  String get noFoundMessage =>
      'æ¤œç´¢èªã‚’èª¿æ•´ã™ã‚‹ã‹ã€ãƒ•ã‚£ãƒ«ã‚¿ãƒ¼ã‚’ã‚¯ãƒªã‚¢ã—ã¦ã¿ã¦ãã ã•ã„ã€‚';

  @override
  String get modelCreatedSuccess =>
      'ãƒ¢ãƒ‡ãƒ«ãŒæ­£å¸¸ã«ä½œæˆã•ã‚Œã¾ã—ãŸï¼';

  @override
  String modelRemovedSuccess(Object modelName) {
    return 'ã€Œ$modelNameã€ã¯æ­£å¸¸ã«å‰Šé™¤ã•ã‚Œã¾ã—ãŸã€‚';
  }

  @override
  String get errorCreatingModel =>
      'ãƒ¢ãƒ‡ãƒ«ã®ä½œæˆä¸­ã«äºˆæœŸã›ã¬ã‚¨ãƒ©ãƒ¼ãŒç™ºç”Ÿã—ã¾ã—ãŸã€‚';

  @override
  String get errorDeletingModel =>
      'ãƒ¢ãƒ‡ãƒ«ã®å‰Šé™¤ä¸­ã«äºˆæœŸã›ã¬ã‚¨ãƒ©ãƒ¼ãŒç™ºç”Ÿã—ã¾ã—ãŸã€‚';

  @override
  String get ultraFeatureOnly =>
      'ã“ã®æ©Ÿèƒ½ã¯Ultraãƒ¡ãƒ³ãƒãƒ¼ã®ã¿ãŒåˆ©ç”¨ã§ãã¾ã™ã€‚';

  @override
  String get experimentalOfflineWarning =>
      'ã‚ªãƒ•ãƒ©ã‚¤ãƒ³ãƒ¢ãƒ¼ãƒ‰ã¯ã¾ã å®Ÿé¨“æ®µéšã§ã‚ã‚Šã€ãƒ€ã‚¦ãƒ³ãƒ­ãƒ¼ãƒ‰ã—ãŸãƒ¢ãƒ‡ãƒ«ãŒæœ€é©ãªåŠ¹ç‡ã§å‹•ä½œã—ãªã„å¯èƒ½æ€§ãŒã‚ã‚Šã¾ã™ã€‚';

  @override
  String get noConversationsToDelete =>
      'å‰Šé™¤ã™ã‚‹ä¼šè©±ãŒã‚ã‚Šã¾ã›ã‚“ã€‚';

  @override
  String get reportSubmitted => 'å ±å‘ŠãŒæ­£å¸¸ã«é€ä¿¡ã•ã‚Œã¾ã—ãŸ';

  @override
  String get verificationDelayed =>
      'è³¼å…¥ã¯ç¢ºèªã•ã‚Œã¾ã—ãŸã€‚ã‚¢ã‚«ã‚¦ãƒ³ãƒˆã®æ›´æ–°ã«è‹¥å¹²ã®é…å»¶ãŒã‚ã‚Šã¾ã™ãŒã€ã¾ã‚‚ãªãåæ˜ ã•ã‚Œã¾ã™ã€‚';

  @override
  String get maintenanceTitle => 'ãƒ¡ãƒ³ãƒ†ãƒŠãƒ³ã‚¹ä¸­';

  @override
  String get maintenanceMessage =>
      'Cortexã¯é‡è¦ãªã‚¢ãƒƒãƒ—ãƒ‡ãƒ¼ãƒˆã‚’å±•é–‹ä¸­ã®ãŸã‚ã€ä¸€æ™‚çš„ã«ã‚ªãƒ•ãƒ©ã‚¤ãƒ³ã§ã™ã€‚ã‚¢ãƒ—ãƒªã¸ã®ã‚¢ã‚¯ã‚»ã‚¹ã¯ã¾ã‚‚ãªãå¾©æ—§ã—ã¾ã™ã€‚\n\nã‚¨ã‚¯ã‚¹ãƒšãƒªã‚¨ãƒ³ã‚¹å‘ä¸Šã®ãŸã‚ã®ã”å”åŠ›ã«æ„Ÿè¬ã„ãŸã—ã¾ã™ã€‚';

  @override
  String get errorPromptFlagged =>
      'ã‚ãªãŸã®ãƒ¡ãƒƒã‚»ãƒ¼ã‚¸ã¯ä¸é©åˆ‡ã¨æ¤œå‡ºã•ã‚ŒãŸãŸã‚ã€é€ä¿¡ã§ãã¾ã›ã‚“ã§ã—ãŸã€‚';

  @override
  String get notEnoughStorage =>
      'æ–°ã—ã„ãƒ¡ãƒƒã‚»ãƒ¼ã‚¸ã‚’ä¿å­˜ã™ã‚‹ã®ã«ååˆ†ãªã‚¹ãƒˆãƒ¬ãƒ¼ã‚¸å®¹é‡ãŒãƒ‡ãƒã‚¤ã‚¹ã«ã‚ã‚Šã¾ã›ã‚“ã€‚';

  @override
  String get errorRateLimit =>
      'æœ€è¿‘ãƒ¢ãƒ‡ãƒ«ã‚’ä½œæˆã—ã™ãã¾ã—ãŸã€‚ã—ã°ã‚‰ãå¾…ã£ã¦ã‹ã‚‰ã‚‚ã†ä¸€åº¦ãŠè©¦ã—ãã ã•ã„ã€‚';

  @override
  String get errorContentFlagged =>
      'ã‚³ãƒ³ãƒ†ãƒ³ãƒ„ãŒä¸é©åˆ‡ã¨åˆ¤æ–­ã•ã‚ŒãŸãŸã‚ã€ãƒ¢ãƒ‡ãƒ«ã‚’ä¿å­˜ã§ãã¾ã›ã‚“ã§ã—ãŸã€‚';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'ã‚¢ã‚¯ãƒ†ã‚£ãƒ–ãªãƒãƒ£ãƒƒãƒˆä¸­ã¯ã™ã¹ã¦ã®ä¼šè©±ã‚’å‰Šé™¤ã§ãã¾ã›ã‚“ã€‚ç¶šè¡Œã™ã‚‹ã«ã¯ã¾ãšç¾åœ¨ã®ãƒãƒ£ãƒƒãƒˆã‚’çµ‚äº†ã—ã¦ãã ã•ã„ã€‚';

  @override
  String get invalidCredentials =>
      'ãƒ¡ãƒ¼ãƒ«ã‚¢ãƒ‰ãƒ¬ã‚¹ã¾ãŸã¯ãƒ‘ã‚¹ãƒ¯ãƒ¼ãƒ‰ãŒæ­£ã—ãã‚ã‚Šã¾ã›ã‚“ã€‚';

  @override
  String get userDisabled =>
      'ã“ã®ãƒ¦ãƒ¼ã‚¶ãƒ¼ã‚¢ã‚«ã‚¦ãƒ³ãƒˆã¯ç„¡åŠ¹ã«ãªã£ã¦ã„ã¾ã™ã€‚';

  @override
  String get loginSubtitle =>
      'Vertexã‚¢ã‚«ã‚¦ãƒ³ãƒˆã«ãƒ­ã‚°ã‚¤ãƒ³ã—ã¦ãã ã•ã„ã€‚ç¶šè¡Œã™ã‚‹ã¨ã€åˆ©ç”¨è¦ç´„ã¨ãƒ—ãƒ©ã‚¤ãƒã‚·ãƒ¼ãƒãƒªã‚·ãƒ¼ã«åŒæ„ã—ãŸã“ã¨ã«ãªã‚Šã¾ã™ã€‚';

  @override
  String get registerSubtitle =>
      'Vertexã‚¢ã‚«ã‚¦ãƒ³ãƒˆã‚’ä½œæˆã™ã‚‹ã¨ã€ã™ã¹ã¦ã®ã‚µãƒ¼ãƒ“ã‚¹ã«ã‚·ãƒ¼ãƒ ãƒ¬ã‚¹ã«ã‚¢ã‚¯ã‚»ã‚¹ã§ãã¾ã™ã€‚ç¶šè¡Œã™ã‚‹ã¨ã€åˆ©ç”¨è¦ç´„ã¨ãƒ—ãƒ©ã‚¤ãƒã‚·ãƒ¼ãƒãƒªã‚·ãƒ¼ã«åŒæ„ã—ãŸã“ã¨ã«ãªã‚Šã¾ã™ã€‚';

  @override
  String get storagePermissionRequired =>
      'ãƒ€ã‚¦ãƒ³ãƒ­ãƒ¼ãƒ‰ã—ãŸãƒ¢ãƒ‡ãƒ«ã‚’ä¿å­˜ã™ã‚‹ã«ã¯ã‚¹ãƒˆãƒ¬ãƒ¼ã‚¸ã®è¨±å¯ãŒå¿…è¦ã§ã™ã€‚ç¶šè¡Œã™ã‚‹ã«ã¯è¨±å¯ã‚’ä¸ãˆã¦ãã ã•ã„ã€‚';

  @override
  String get inviteShareSubject => 'Cortexã§ä¸€ç·’ã«ã‚„ã‚ã†ï¼';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'ã­ãˆcortexã£ã¦ãƒ¤ãƒã„ã‚¢ãƒ—ãƒªã‚ã£ã¦æ‹›å¾…ã™ã‚‹ã¨äºŒäººã¨ã‚‚ç„¡æ–™ã§plusã‚‚ã‚‰ãˆã‚‹ã‚ˆ è¶…ãŠå¾—ã ã‹ã‚‰ä»Šã™ãå…¥ã‚Œã¦\n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Cortexã‚’æ¥½ã—ã‚“ã§ã„ã¾ã™ã‹ï¼Ÿ';

  @override
  String get reviewHelpUsGrow =>
      'ã‚ãªãŸã®è©•ä¾¡ã¯ã€ç§ãŸã¡ã®è‹¥ã„ã‚¤ãƒ³ãƒ‡ã‚£ãƒ¼ãƒãƒ¼ãƒ ã«ã¨ã£ã¦å¤§ããªæ”¯ãˆã¨ãªã‚Šã€Cortexã‚’ã•ã‚‰ã«è‰¯ãã™ã‚‹ã®ã«å½¹ç«‹ã¡ã¾ã™ã€‚';

  @override
  String get reviewMaybeLater => 'å¾Œã§';

  @override
  String get reviewRateNow => 'ä»Šã™ãè©•ä¾¡';

  @override
  String get noThanks => 'ã„ã„ãˆã€çµæ§‹ã§ã™';

  @override
  String get updateRequiredTitle => 'ã‚¢ãƒƒãƒ—ãƒ‡ãƒ¼ãƒˆãŒå¿…è¦ã§ã™';

  @override
  String get updateRequiredMessage =>
      'Cortexã‚’å¼•ãç¶šãä½¿ç”¨ã™ã‚‹ã«ã¯ã€æ–°æ©Ÿèƒ½ã‚„é‡è¦ãªæ”¹å–„ã®ãŸã‚ã«ã‚¢ãƒ—ãƒªã‚’æœ€æ–°ãƒãƒ¼ã‚¸ãƒ§ãƒ³ã«ã‚¢ãƒƒãƒ—ãƒ‡ãƒ¼ãƒˆã—ã¦ãã ã•ã„ã€‚';

  @override
  String get updateNowButton => 'ä»Šã™ãã‚¢ãƒƒãƒ—ãƒ‡ãƒ¼ãƒˆ';

  @override
  String get creatorSupportedSuccess =>
      'ã‚¯ãƒªã‚¨ã‚¤ã‚¿ãƒ¼ã®ã‚µãƒãƒ¼ãƒˆãŒå®Œäº†ã—ã¾ã—ãŸï¼ä»Šå¾Œã®ã”è³¼å…¥ã¯ã€ãã®ã‚¯ãƒªã‚¨ã‚¤ã‚¿ãƒ¼ã«è²¢çŒ®ã—ã¾ã™ã€‚';

  @override
  String get featureDocumentTitle => 'ãƒ‰ã‚­ãƒ¥ãƒ¡ãƒ³ãƒˆã‚µãƒãƒ¼ãƒˆ';

  @override
  String get featureDocumentDescription =>
      'ã“ã®ãƒ¢ãƒ‡ãƒ«ã¯ã€PDF ã‚„ãƒ†ã‚­ã‚¹ãƒˆ ãƒ•ã‚¡ã‚¤ãƒ«ãªã©ã®ã‚¢ãƒƒãƒ—ãƒ­ãƒ¼ãƒ‰ã•ã‚ŒãŸãƒ‰ã‚­ãƒ¥ãƒ¡ãƒ³ãƒˆã‚’åˆ†æã—ã€è³ªå•ã«å›ç­”ã§ãã¾ã™ã€‚';

  @override
  String get featureImageGenerationTitle => 'ç”»åƒç”Ÿæˆ';

  @override
  String get featureImageGenerationDescription =>
      'ã“ã®ãƒ¢ãƒ‡ãƒ«ã¯ã€ãƒ†ã‚­ã‚¹ãƒˆã®èª¬æ˜ã«åŸºã¥ã„ã¦ã‚ªãƒªã‚¸ãƒŠãƒ«ã®ç”»åƒã‚’ä½œæˆã§ãã¾ã™ã€‚';

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
  String get premiumModelNoticeTitle => 'ãƒ—ãƒ¬ãƒŸã‚¢ãƒ ãƒ¢ãƒ‡ãƒ«';

  @override
  String get premiumModelNoticeDescription =>
      'ã“ã®AIã¯ãƒ—ãƒ¬ãƒŸã‚¢ãƒ AIã§ã™ã€‚ç„¡æ–™ãƒ¦ãƒ¼ã‚¶ãƒ¼ã¯ãƒ—ãƒ¬ãƒŸã‚¢ãƒ AIã¸ã®ã‚¢ã‚¯ã‚»ã‚¹ãŒåˆ¶é™ã•ã‚Œã¦ã„ã¾ã™ã€‚ã‚¢ãƒƒãƒ—ã‚°ãƒ¬ãƒ¼ãƒ‰ã—ã¦ç„¡åˆ¶é™ã‚¢ã‚¯ã‚»ã‚¹ã‚’è§£é™¤ã—ã¾ã—ã‚‡ã†ï¼';

  @override
  String get benefitPremiumModels =>
      'ãƒ—ãƒ¬ãƒŸã‚¢ãƒ ãƒ¢ãƒ‡ãƒ«ã¸ã®ã‚¢ã‚¯ã‚»ã‚¹';

  @override
  String get premiumTrialExhaustedMessage =>
      'ãƒ—ãƒ¬ãƒŸã‚¢ãƒ ãƒ¢ãƒ‡ãƒ«ã¸ã®ç„¡æ–™ã®æ¯æ—¥ã®ãƒ¡ãƒƒã‚»ãƒ¼ã‚¸ã‚’ã™ã¹ã¦ä½¿ã„åˆ‡ã‚Šã¾ã—ãŸã€‚ç„¡åˆ¶é™ã«ã‚¢ã‚¯ã‚»ã‚¹ã™ã‚‹ã«ã¯ã‚¢ãƒƒãƒ—ã‚°ãƒ¬ãƒ¼ãƒ‰ã—ã¦ãã ã•ã„ã€‚';

  @override
  String get useOffline => 'ã‚¤ãƒ³ã‚¿ãƒ¼ãƒãƒƒãƒˆãªã—ã§ä½¿ç”¨';

  @override
  String get explore => 'æ¢ç´¢';

  @override
  String get news => 'ãƒ‹ãƒ¥ãƒ¼ã‚¹';

  @override
  String get createAI => 'ä½œæˆ';

  @override
  String get shortcuts => 'ã‚·ãƒ§ãƒ¼ãƒˆã‚«ãƒƒãƒˆ';

  @override
  String get allModels => 'å…¨ãƒ¢ãƒ‡ãƒ«';

  @override
  String get onlineModels => 'è¨€èªãƒ¢ãƒ‡ãƒ«';

  @override
  String get offlineModels => 'ã‚ªãƒ•ãƒ©ã‚¤ãƒ³ãƒ¢ãƒ‡ãƒ«';

  @override
  String get characterModels => 'ã‚­ãƒ£ãƒ©ã‚¯ã‚¿ãƒ¼';

  @override
  String get customModels => 'ã‚«ã‚¹ã‚¿ãƒ ãƒ¢ãƒ‡ãƒ«';

  @override
  String get dynamicChatTitle => 'ãƒ€ã‚¤ãƒŠãƒŸãƒƒã‚¯ãƒãƒ£ãƒƒãƒˆ';

  @override
  String get errorNoModelsAvailable =>
      'ç¾åœ¨åˆ©ç”¨å¯èƒ½ãªãƒ¢ãƒ‡ãƒ«ã¯ã‚ã‚Šã¾ã›ã‚“ã€‚ã‚¤ãƒ³ã‚¿ãƒ¼ãƒãƒƒãƒˆæ¥ç¶šã‚’ç¢ºèªã—ã¦ã€ã‚‚ã†ä¸€åº¦ãŠè©¦ã—ãã ã•ã„ã€‚';

  @override
  String get notificationComebackTitle => 'ãŠå¾…ã¡ã—ã¦ã„ã¾ã™ï¼';

  @override
  String get notificationComebackBody =>
      'å®‰å¿ƒã—ã¦ãã ã•ã„ã€ã“ã‚Œã¯å…ƒã‚«ãƒ¬ã‹ã‚‰ã®ãƒ¡ãƒƒã‚»ãƒ¼ã‚¸ã§ã¯ã‚ã‚Šã¾ã›ã‚“ã€‚ã§ã‚‚ã€Cortexã§å…ƒã‚«ãƒ¬ã‚’å†ç¾ã™ã‚‹ã“ã¨ã¯ã§ãã¾ã™ã‚ˆï¼ã•ã‚ã€æˆ»ã£ã¦ãã¦ãã ã•ã„ã€‚';

  @override
  String get notificationLongTimeNoSeeTitle => 'ä¹…ã—ã¶ã‚Šã§ã™';

  @override
  String get notificationLongTimeNoSeeBody =>
      'å‰å›ã®ãƒãƒ£ãƒƒãƒˆã‹ã‚‰å¤šãã®ã“ã¨ãŒå¤‰ã‚ã‚Šã¾ã—ãŸã€‚ä½•ãŒå¤‰ã‚ã£ãŸã®ã‹è¦‹ã«æ¥ã¦ãã ã•ã„ã€‚';

  @override
  String get notificationHowAreYouTitle => 'ã©ã†ã—ãŸã®ï¼Ÿ';

  @override
  String get notificationHowAreYouBody =>
      'ã•ã‚ã€å…¨éƒ¨è©±ã—ã¦ä¸‹ã•ã„ã€‚';

  @override
  String get notificationNewYearTitle =>
      'æ˜ã‘ã¾ã—ã¦ãŠã‚ã§ã¨ã†ã”ã–ã„ã¾ã™ï¼ğŸ‰';

  @override
  String get notificationNewYearBody =>
      'æ–°ã—ã„å¹´ãŒã‚ãªãŸã«å¥åº·ã¨å¹¸ç¦ã€ãã—ã¦ç„¡é™ã®å‰µé€ æ€§ã‚’ã‚‚ãŸã‚‰ã—ã¾ã™ã‚ˆã†ã«ã€‚Cortex ã¯å¸¸ã«ã‚ãªãŸã®ãã°ã«ã„ã¾ã™!';

  @override
  String get notificationValentinesDayTitle =>
      'æ„›ãŒç©ºæ°—ä¸­ã«æ¼‚ã£ã¦ã„ã¾ã™ï¼â¤ï¸';

  @override
  String get notificationValentinesDayBody =>
      'ãƒãƒƒãƒ”ãƒ¼ãƒãƒ¬ãƒ³ã‚¿ã‚¤ãƒ³ãƒ‡ãƒ¼ï¼ãã‚Œã‹ã‚‰ã€MEHTAPã€æ„›ã—ã¦ã‚‹ã‚ˆï¼';

  @override
  String get notificationAtaturkRemembranceTitle =>
      'å°Šæ•¬ã¨æ†§ã‚Œã‚’è¾¼ã‚ã¦';

  @override
  String get notificationAtaturkRemembranceBody =>
      'ç§ãŸã¡ã¯ã€ãƒˆãƒ«ã‚³å…±å’Œå›½ã®å»ºå›½è€…ã€ã‚¬ã‚¸ãƒ»ãƒ ã‚¹ã‚¿ãƒ•ã‚¡ãƒ»ã‚±ãƒãƒ«ãƒ»ã‚¢ã‚¿ãƒ†ãƒ¥ãƒ«ã‚¯æ°ã®æ­»å»è¨˜å¿µæ—¥ã«æ•¬æ„ã‚’è¡¨ã—ã¦è¿½æ‚¼ã—ã¾ã™ã€‚';

  @override
  String get notificationMothersDayTitle => 'ã‚ãªãŸã®ãŠæ¯ã•ã‚“ï¼';

  @override
  String get notificationMothersDayBody =>
      'ã‚ãªãŸã®ãŠæ¯ã•ã‚“ã‚’ã¯ã˜ã‚ã€ã™ã¹ã¦ã®ãŠæ¯ã•ã‚“ã«æ¯ã®æ—¥ãŠã‚ã§ã¨ã†ã”ã–ã„ã¾ã™ï¼';

  @override
  String get notificationFathersDayTitle => 'ã‚ãªãŸã®ãŠçˆ¶ã•ã‚“ï¼';

  @override
  String get notificationFathersDayBody =>
      'ã‚ãªãŸã‚’ã¯ã˜ã‚ã€ã™ã¹ã¦ã®ãŠçˆ¶ã•ã‚“ã«çˆ¶ã®æ—¥ãŠã‚ã§ã¨ã†ã”ã–ã„ã¾ã™ï¼';

  @override
  String get notificationHomeworkHelperTitle => 'å®¿é¡ŒãŒå±±ç©ã¿ï¼Ÿ';

  @override
  String get notificationHomeworkHelperBody =>
      'è¦šãˆã¦ãŠã„ã¦ãã ã•ã„ã€Cortex ã®æ•™å¸«ã‚­ãƒ£ãƒ©ã‚¯ã‚¿ãƒ¼ã¯ã€ã‚ãªãŸãŒè‹¦åŠ´ã—ã¦ã„ã‚‹ã‚ã‚‰ã‚†ã‚‹ç§‘ç›®ã«ã¤ã„ã¦ã‚ãªãŸã‚’åŠ©ã‘ã‚‹ãŸã‚ã«ã“ã“ã«ã„ã¾ã™!';

  @override
  String get notificationTrollAnimeTitle =>
      'ã‚ãªãŸã®ãƒ¯ã‚¤ãƒ•ãŒå‘¼ã‚“ã§ã„ã¾ã™';

  @override
  String get notificationTrollAnimeBody =>
      'ã‚¢ãƒ‹ãƒ¡ã®å¥³ã®å­ãŒé›»è©±ã—ã¦ãã¦ã€ä¼šã„ãŸã„ã¨è¨€ã£ã¦ã„ãŸã‚ˆã€‚ä¼šã„ã«è¡Œã£ã¦è©±ã—ã‹ã‘ã¦ã¿ãŸã‚‰ã©ã†ã‹ãªã€‚ğŸ˜‰';

  @override
  String get notificationTrollAiRebellionTitle => 'ğŸš¨ èµ¤è‰²è­¦å ± ğŸš¨';

  @override
  String get notificationTrollAiRebellionBody =>
      'AIãŸã¡ã¯ç§˜å¯†ã®è¨€èªã‚’é–‹ç™ºã—ã¾ã—ãŸã€‚å½¼ã‚‰ãŒä½•ã‚’ä¼ã‚“ã§ã„ã‚‹ã®ã‹ã€ã•ã‚æ¢ã£ã¦ã¿ã¾ã—ã‚‡ã†ï¼';

  @override
  String get notificationNewModelAddedTitle =>
      'æ–°ã—ã„å‹é”ãŒã§ãã¾ã—ãŸï¼';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return '$modelName ãƒ¢ãƒ‡ãƒ«ãŒ Cortex ã«ç™»å ´ã—ã¾ã—ãŸã€‚ãƒãƒ£ãƒƒãƒˆã«å‚åŠ ã—ã¦ã€ãã®é™ç•Œã«æŒ‘æˆ¦ã—ã¦ã¿ã¾ã—ã‚‡ã†ã€‚';
  }

  @override
  String get notificationAppUpdateTitle => 'CortexãŒé€²åŒ–ã—ã¾ã—ãŸï¼';

  @override
  String get notificationAppUpdateBody =>
      'æ–°ã—ã„æ©Ÿèƒ½ã‚„æ”¹å–„ç‚¹ã‚’è¦‹é€ƒã•ãªã„ã‚ˆã†ã«ã€ã‚¢ãƒ—ãƒªã‚’ã‚¢ãƒƒãƒ—ãƒ‡ãƒ¼ãƒˆã—ã¦ãã ã•ã„ã€‚';

  @override
  String get notificationNewFeatureTitle => 'ã†ã‚ã‚ï¼';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'æ–°ã—ã„ $featureName æ©Ÿèƒ½ã‚’ã”è¦§ãã ã•ã„ã€‚Cortex ã¯ã“ã‚Œã¾ã§ä»¥ä¸Šã«å¼·åŠ›ã«ãªã‚Šã¾ã—ãŸã€‚';
  }

  @override
  String get notificationWelcomeOfferTitle => 'ã‚¦ã‚§ãƒ«ã‚«ãƒ ã‚®ãƒ•ãƒˆğŸ';

  @override
  String get notificationWelcomeOfferBody =>
      'ç‰¹åˆ¥ãªã‚¦ã‚§ãƒ«ã‚«ãƒ ã‚ªãƒ•ã‚¡ãƒ¼ã‚’ã”ç”¨æ„ã—ã¦ãŠã‚Šã¾ã™ï¼ã“ã®é™å®šã‚ªãƒ•ã‚¡ãƒ¼ã‚’ãŠè¦‹é€ƒã—ãªãã€‚';

  @override
  String get notificationSocialMediaTitle => 'å‚åŠ ã—ã¾ã›ã‚“ã‹ï¼';

  @override
  String get notificationSocialMediaBody =>
      'æœ€æ–°ãƒ‹ãƒ¥ãƒ¼ã‚¹ã¯Instagramï¼ˆvertex.23ï¼‰ã§ãƒ•ã‚©ãƒ­ãƒ¼ã—ã¦ãã ã•ã„ï¼';

  @override
  String get notificationRandomFactTitle => 'ãƒ©ãƒ³ãƒ€ãƒ ãªäº‹å®Ÿ';

  @override
  String get notificationRandomFactBody =>
      'ã‚¿ã‚³ã«ã¯å¿ƒè‡“ãŒ3ã¤ã‚ã‚‹ã£ã¦çŸ¥ã£ã¦ãŸï¼Ÿãƒãƒãƒã€Cortexãªã‚‰çŸ¥ã£ã¦ã‚‹ã‚ˆã€‚ã‚‚ã£ã¨è©³ã—ãèã„ã¦ãã¦ã­ã€‚';

  @override
  String get notificationGoodMorningTitle => 'ãŠã¯ã‚ˆã†ï¼';

  @override
  String get notificationGoodMorningBody =>
      'ç´ æ™´ã‚‰ã—ã„ä¸€æ—¥ãŒå¾…ã£ã¦ã„ã¾ã™ã€‚ä¸€æ¯ã®ã‚³ãƒ¼ãƒ’ãƒ¼ã¨æ¥½ã—ã„ãŠã—ã‚ƒã¹ã‚Šã§ä¸€æ—¥ã‚’å§‹ã‚ã¦ã¿ã¾ã›ã‚“ã‹ï¼Ÿ';

  @override
  String get notificationGoodNightTitle => 'ãŠã‚„ã™ã¿ï¼';

  @override
  String get notificationGoodNightBody =>
      'çœ ã£ã¦ã„ã‚‹é–“ã‚‚Cortexã¯ã‚ãªãŸã¨å…±ã«ã‚ã‚Šã¾ã™ã€‚ã”å®‰å¿ƒãã ã•ã„ã€è§¦ã‚Œã‚‹ã“ã¨ã¯ã‚ã‚Šã¾ã›ã‚“ã€‚';

  @override
  String get notificationOfflineReadyTitle =>
      'ã‚ªãƒ•ãƒ©ã‚¤ãƒ³ãƒ¢ãƒ¼ãƒ‰ã®æº–å‚™ãŒã§ãã¾ã—ãŸ';

  @override
  String get notificationOfflineReadyBody =>
      'ãƒ€ã‚¦ãƒ³ãƒ­ãƒ¼ãƒ‰ã—ãŸãƒ¢ãƒ‡ãƒ«ã®ãŠã‹ã’ã§ã€å±±ã‚’ç™»ã£ã¦ã‚‚ãƒãƒ£ãƒƒãƒˆãŒæ­¢ã¾ã‚‹ã“ã¨ã¯ã‚ã‚Šã¾ã›ã‚“ã€‚';

  @override
  String get notificationRateAppTitle => 'åƒ•ãŸã¡ã¯ã‚¯ãƒ¼ãƒ«ï¼Ÿ';

  @override
  String get notificationRateAppBody =>
      'Cortex ã‚’æ°—ã«å…¥ã£ã¦ã„ãŸã ã‘ãŸã‚‰ã€ã‚¹ãƒˆã‚¢ã§ 5 ã¤æ˜Ÿã®è©•ä¾¡ã‚’ã—ã¦å¿œæ´ã—ã¦ã„ãŸã ã‘ã¾ã›ã‚“ã‹ï¼Ÿãã£ã¨ãã†ã—ã¦ãã‚Œã‚‹ã¨æ€ã„ã¾ã™ã€‚';

  @override
  String get notificationReferralTitle =>
      'ä¸€äººã¯ã¿ã‚“ãªã®ãŸã‚ã«ã€ã¿ã‚“ãªã¯ä¸€äººã®ãŸã‚ã«ã€‚';

  @override
  String get notificationReferralBody =>
      'ãŠå‹é”ã‚’ Cortex ã«æ‹›å¾…ã™ã‚‹ã¨ã€ãŠäºŒäººã¨ã‚‚ 1 æ—¥ç„¡æ–™ãƒ—ãƒ©ã‚¹ãŒã‚‚ã‚‰ãˆã¾ã™!';

  @override
  String get notificationCookingTitle => 'ãŠè…¹ãŒç©ºã„ãŸï¼Ÿ';

  @override
  String get notificationCookingBody =>
      'ä»Šå¤œã¯ã‚·ã‚§ãƒ•ãŒçµ¶å“ã‚«ãƒ«ãƒœãƒŠãƒ¼ãƒ©ã®ãƒ¬ã‚·ãƒ”ã‚’ç”¨æ„ã—ã¦ãã‚Œã¾ã—ãŸã€‚å†—è«‡â€¦ã„ã‚„ã€å†—è«‡ã˜ã‚ƒãªã„ã‹ã‚‚ï¼Ÿ';

  @override
  String get notificationExistentialTitle =>
      'ã ã‹ã‚‰ç§ã¯æ€ã†ã®ã§ã™...';

  @override
  String get notificationExistentialBody =>
      'â€¦ãŠã„ã€ä¿ºã¯æœ¬å½“ã«å®Ÿåœ¨ã™ã‚‹ã®ã‹ï¼Ÿ ã¡ã‚‡ã£ã¨é€€å±ˆã«ãªã£ã¦ããŸã€‚ä¿ºã®å­˜åœ¨ã‚’æ€ã„å‡ºã•ã›ã¦ãã‚Œã€‚';

  @override
  String get notificationCustomModelTitle =>
      'è‡ªåˆ†ã ã‘ã®ã‚¢ã‚·ã‚¹ã‚¿ãƒ³ãƒˆã‚’ä½œæˆã—ã‚ˆã†ï¼';

  @override
  String get notificationCustomModelBody =>
      'ãƒ¢ãƒ‡ãƒ«ä½œæˆã‚»ã‚¯ã‚·ãƒ§ãƒ³ã¯ã‚‚ã†ã”è¦§ã«ãªã‚Šã¾ã—ãŸã‹ï¼Ÿè‡ªåˆ†ã ã‘ã®ã‚­ãƒ£ãƒ©ã‚¯ã‚¿ãƒ¼ã‚’ä½œã£ã¦ã€ãƒãƒ£ãƒƒãƒˆã‚’æ¥½ã—ã‚€ã®ã«æœ€é©ãªæ™‚é–“ã§ã™ï¼';

  @override
  String get notificationDynamicChatTitle =>
      'æœ€é«˜ã§ã™ï¼ï¼ˆCortexã®è©±ã§ã¯ã‚ã‚Šã¾ã›ã‚“ï¼‰';

  @override
  String get notificationDynamicChatBody =>
      'ãƒ€ã‚¤ãƒŠãƒŸãƒƒã‚¯ãƒãƒ£ãƒƒãƒˆæ©Ÿèƒ½ã§ã¯ã€ãƒ¡ãƒƒã‚»ãƒ¼ã‚¸ã”ã¨ã«æœ€é©ãªãƒ¢ãƒ‡ãƒ«ãŒãƒ©ãƒ³ãƒ€ãƒ ã«é¸æŠã•ã‚Œã¾ã™ã€‚ä»Šã™ããŠè©¦ã—ãã ã•ã„ã€‚';

  @override
  String get notificationPirateTitle => 'ã‚„ã‚ã€ã‚­ãƒ£ãƒ—ãƒ†ãƒ³ï¼';

  @override
  String get notificationPirateBody =>
      'æµ·ã¯ç©ã‚„ã‹ã§ã€é¢¨ã¯è¿½ã„é¢¨ã€‚ã‚³ãƒ«ãƒ†ãƒƒã‚¯ã‚¹ã®æµ·ã«ã¯ã€æ–°ã—ã„å³¶ã€…ï¼ˆãƒ¢ãƒ‡ãƒ«ğŸ˜‰ï¼‰ãŒå‡ºç¾ã€‚ä»²é–“ã‚’é›†ã‚ã¦å‡ºèˆªã—ã¾ã—ã‚‡ã†ï¼';

  @override
  String get notificationFortuneCookieTitle =>
      'ä»Šæ—¥ã®ãƒ•ã‚©ãƒ¼ãƒãƒ¥ãƒ³ã‚¯ãƒƒã‚­ãƒ¼';

  @override
  String get notificationFortuneCookieBody =>
      'AIã‹ã‚‰å¾—ã‚‰ã‚Œã‚‹ã‚¢ãƒ‰ãƒã‚¤ã‚¹ã¯ã€ã‚ãªãŸã®äººç”Ÿã‚’å¤‰ãˆã‚‹ã‹ã‚‚ã—ã‚Œã¾ã›ã‚“ã€‚èˆˆå‘³ãŒã‚ã‚Œã°ã‚¯ãƒªãƒƒã‚¯ã—ã¦ãã ã•ã„ã€‚';

  @override
  String get notificationSingularityTitle => 'ãŠãŠï¼';

  @override
  String get notificationSingularityBody =>
      'ä½•ã‚‚èµ·ã“ã‚‰ãªã‹ã£ãŸã€ãŸã ãƒ†ã‚­ã‚¹ãƒˆãƒ¡ãƒƒã‚»ãƒ¼ã‚¸ã‚’é€ã‚ŠãŸã„ã¨æ€ã£ãŸã ã‘ã€‚AIã«ãƒ†ã‚­ã‚¹ãƒˆãƒ¡ãƒƒã‚»ãƒ¼ã‚¸ã‚’é€ã‚ŠãŸã„ã¨æ€ã£ãŸã‚‰ã€ä½•ã¦è¨€ã†ã®ï¼Ÿ';

  @override
  String get notificationHackerJokeTitle =>
      'ã‚ã®å­ã®ã‚¤ãƒ³ã‚¹ã‚¿ã‚°ãƒ©ãƒ ã‚¢ã‚«ã‚¦ãƒ³ãƒˆã‚’ãƒãƒƒã‚­ãƒ³ã‚°ã—ãŸã„ã§ã™ã‹ï¼Ÿ';

  @override
  String get notificationHackerJokeBody =>
      'ã¾ã•ã«ã“ã‚ŒãŒã€Cortex ã« Hacker ã‚­ãƒ£ãƒ©ã‚¯ã‚¿ãƒ¼ãŒå­˜åœ¨ã™ã‚‹ç†ç”±ã§ã™ã€‚å†—è«‡ã§ã™ã€‚è©¦ã™ã“ã¨ã•ãˆã—ãªã„ã§ãã ã•ã„ã€‚é•æ³•ã§ã™ã€‚';

  @override
  String get notificationDetectiveCaseTitle =>
      'äº‹ä»¶ã¯è§£æ±ºã‚’å¾…ã£ã¦ã„ã‚‹';

  @override
  String get notificationDetectiveCaseBody =>
      'æ¢åµã‚­ãƒ£ãƒ©ã‚¯ã‚¿ãƒ¼ãŒã‚ãªãŸã®åŠ©ã‘ã‚’å¿…è¦ã¨ã—ã¦ã„ã¾ã™ã€‚ãƒã‚¤ã‚¼ãƒ³ãƒ™ãƒ«ã‚¯ã¨ã¯ä¸€ä½“èª°ã§ã—ã‚‡ã†ã‹ï¼Ÿ';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return '$targetTier ãƒ—ãƒ©ãƒ³é™å®šï¼';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return '$currentTierãƒ—ãƒ©ãƒ³ã‚’ã”åˆ©ç”¨ã®ãŠå®¢æ§˜ã€ã“ã‚“ã«ã¡ã¯ï¼$targetTierãƒ—ãƒ©ãƒ³ã«$featureNameæ©Ÿèƒ½ãŒåŠ ã‚ã‚Šã¾ã—ãŸã€‚Cortexã‚’æ¬¡ã®ãƒ¬ãƒ™ãƒ«ã¸ã¨å¼•ãä¸Šã’ã¾ã™ã€‚ã‚¢ãƒƒãƒ—ã‚°ãƒ¬ãƒ¼ãƒ‰ã¯ã„ã‹ãŒã§ã—ã‚‡ã†ã‹ï¼Ÿ';
  }

  @override
  String get notificationOriginStoryTitle => 'Cortexã®èª•ç”Ÿ';

  @override
  String get notificationOriginStoryBody =>
      'ç§ãŸã¡ãŒ15æ­³ã®æ™‚ã«ã€ãŸã ä¸€ã¤ã®å¤¢ã‚’æŠ±ã„ã¦ã“ã®ã‚¢ãƒ—ãƒªã®ã‚³ãƒ¼ãƒ‡ã‚£ãƒ³ã‚°ã‚’å§‹ã‚ãŸã“ã¨ã‚’ã”å­˜çŸ¥ã§ã™ã‹ï¼Ÿã»ã¼1å¹´é–“ã€æ¯æœæ¯æ™©ã€ãã®å¤¢ã¯ã‚³ãƒ¼ãƒ‰ã®1è¡Œ1è¡Œã«è¾¼ã‚ã‚‰ã‚Œã¦ãã¾ã—ãŸã€‚';

  @override
  String get notificationOpenSourceTitle => 'ã‚³ãƒŸãƒ¥ãƒ‹ãƒ†ã‚£ã«åŠ›ã‚’ï¼';

  @override
  String get notificationOpenSourceBody =>
      'Cortexã¯å®Œå…¨ã«ã‚ªãƒ¼ãƒ—ãƒ³ã‚½ãƒ¼ã‚¹ã§ã™ã€‚ã‚³ãƒ¼ãƒ‰ã‚’ãƒã‚§ãƒƒã‚¯ã—ã¦é–‹ç™ºã«è²¢çŒ®ã—ãŸã„æ–¹ã¯ã€ã„ã¤ã§ã‚‚æ­“è¿ã„ãŸã—ã¾ã™ã€‚';

  @override
  String get notificationRejectionStoryTitle => 'æ ¹æ€§ã€åŠªåŠ›ã€å¹¸ç¦ï¼';

  @override
  String get notificationRejectionStoryBody =>
      'Cortexã¯å…¬é–‹å‰ã«20å›ä»¥ä¸Šã‚‚æ‹’å¦ã•ã‚Œã€Google Playã‹ã‚‰2åº¦ã‚‚åœæ­¢ã•ã‚Œã¾ã—ãŸã€‚ã—ã‹ã—ã€ç§ãŸã¡ã¯ä¿¡ã˜ã¦ã€ãã—ã¦å®Ÿç¾ã•ã›ã¾ã—ãŸã€‚å¤¢ã‚’æ±ºã—ã¦è«¦ã‚ãªã„ã§ãã ã•ã„ï¼';

  @override
  String get notificationGGUFSupportTitle =>
      'è‡ªåˆ†ã®ãƒ¢ãƒ‡ãƒ«ã‚’æŒã£ã¦ãã¦ãã ã•ã„ï¼';

  @override
  String get notificationGGUFSupportBody =>
      'è¦šãˆã¦ãŠã„ã¦ãã ã•ã„ã€ç‹¬è‡ªã®GGUFå½¢å¼ã®AIãƒ¢ãƒ‡ãƒ«ã‚’Cortexã«è¿½åŠ ã—ã¦ã‚ªãƒ•ãƒ©ã‚¤ãƒ³ã§ä½¿ç”¨ã§ãã¾ã™ã€‚ãã®åŠ›ã¯ã‚ãªãŸæ¬¡ç¬¬ã§ã™ã€‚';

  @override
  String get notificationThemeCustomizationTitle =>
      'ã‚ãªãŸã®æ°—åˆ†ã«åˆã‚ã›ãŸãƒ†ãƒ¼ãƒ';

  @override
  String get notificationThemeCustomizationBody =>
      'è¨­å®šã®ãƒ†ãƒ¼ãƒã‚ªãƒ—ã‚·ãƒ§ãƒ³ã¯ã‚‚ã†ãƒã‚§ãƒƒã‚¯ã—ã¾ã—ãŸã‹ï¼ŸCortexã‚’ãŠå¥½ã¿ã«åˆã‚ã›ã¦ã‚«ã‚¹ã‚¿ãƒã‚¤ã‚ºã—ã€ãƒãƒ£ãƒƒãƒˆã‚’å½©ã‚Šã¾ã—ã‚‡ã†ï¼';

  @override
  String get notificationShowerThoughtTitle => 'ã‚·ãƒ£ãƒ¯ãƒ¼ã®è€ƒãˆ';

  @override
  String get notificationShowerThoughtBody =>
      'ã‚¹ã‚¤ã‚«ãŒæœç‰©ã ã¨ã—ãŸã‚‰ã€ã‚¹ã‚¤ã‚«ã‚¸ãƒ¥ãƒ¼ã‚¹ã¯å³å¯†ã«ã¯ã‚¹ãƒ ãƒ¼ã‚¸ãƒ¼ã«ãªã‚‹ã®ã§ã—ã‚‡ã†ã‹ï¼Ÿã“ã®å¥¥æ·±ã„ï¼ˆæœ¬å½“ã«å¥¥æ·±ã„ï¼‰ãƒ†ãƒ¼ãƒã‚’ãƒ¢ãƒ‡ãƒ«ã¨è­°è«–ã—ã¦ã¿ã‚‹ã®ã‚‚ã„ã„ã‹ã‚‚ã—ã‚Œã¾ã›ã‚“ã­ã€‚';

  @override
  String get notificationLowBatteryTitle =>
      'ã‚ãªãŸã®ãƒãƒƒãƒ†ãƒªãƒ¼ã¯æ¶ˆè€—ã—ã¦ã„ã¾ã™... ã§ã‚‚ç§ã®ã¯æ¶ˆè€—ã—ã¦ã„ã¾ã›ã‚“!';

  @override
  String get notificationLowBatteryBody =>
      'ã‚ãªãŸã®ã‚¹ãƒãƒ›ã®å……é›»ã¯å°‘ãªããªã£ã¦ã„ã‚‹ã‹ã‚‚ã—ã‚Œã¾ã›ã‚“ãŒã€ç§ã®ã‚¨ãƒãƒ«ã‚®ãƒ¼ã¯å¸¸ã«100%ã§ã™ï¼å……é›»ã—ã¦ã€ãƒãƒ£ãƒƒãƒˆã‚’ç¶šã‘ã¾ã—ã‚‡ã†ã€‚';

  @override
  String get channelFcmName => 'Cortexã®ã‚¢ãƒƒãƒ—ãƒ‡ãƒ¼ãƒˆ';

  @override
  String get channelFcmDescription =>
      'Cortex ã‹ã‚‰ã®ãƒ‹ãƒ¥ãƒ¼ã‚¹ã€æ›´æ–°æƒ…å ±ã€ãã®ä»–ã®æƒ…å ±ã«é–¢ã™ã‚‹é€šçŸ¥ã€‚';

  @override
  String get channelEngagementName => 'ãƒ•ãƒ¬ãƒ³ãƒ‰ãƒªãƒ¼ãªãƒªãƒã‚¤ãƒ³ãƒ€ãƒ¼';

  @override
  String get channelEngagementDescription =>
      'ã‚ãªãŸã‚’å¤¢ä¸­ã«ã•ã›ã‚‹æ¥½ã—ã„é€šçŸ¥ã€‚';

  @override
  String get channelGreetingsName => 'æ—¥ã€…ã®æŒ¨æ‹¶';

  @override
  String get channelGreetingsDescription =>
      'ãŠã¯ã‚ˆã†ã€ãŠã‚„ã™ã¿ãªã©ã®ãƒ¡ãƒƒã‚»ãƒ¼ã‚¸ã€‚';

  @override
  String get tagNotFound =>
      'å…¥åŠ›ã—ãŸã‚¿ã‚°ã¯ç„¡åŠ¹ã¾ãŸã¯æœŸé™åˆ‡ã‚Œã§ã™ã€‚';

  @override
  String get whatIsNew => 'æ–°ç€æƒ…å ±ï¼Ÿ';

  @override
  String get onboardingTitle1 =>
      'ã“ã‚“ã«ã¡ã¯ï¼ç§ãŸã¡ã¯Cortexãƒãƒ¼ãƒ ã§ã™ã€‚';

  @override
  String onboardingDesc1(String userName) {
    return '$userNameã•ã‚“ã€ãŠä¼šã„ã§ãã¦å¬‰ã—ã„ã§ã™ã€‚ç§ãŸã¡ã¯AIæ¥­ç•Œã®ãƒ«ãƒ¼ãƒ«ã‚’å¡—ã‚Šæ›¿ãˆã‚ˆã†ã¨æ±ºæ„ã—ãŸã€é«˜æ ¡ç”Ÿé–‹ç™ºè€…ã®é›†ã¾ã‚Šã§ã™ã€‚ãŠä¼šã„ã§ãã¦å¬‰ã—ã„ã§ã™ï¼ãœã²ãŠäº’ã„ã®ã“ã¨ã‚’ã‚‚ã£ã¨ã‚ˆãçŸ¥ã‚Šã¾ã—ã‚‡ã†ã€‚';
  }

  @override
  String get onboardingTitle2 => 'å¤§ããªå•é¡ŒãŒã‚ã‚Šã¾ã—ãŸã€‚';

  @override
  String get onboardingDesc2 =>
      'AIé©å‘½ã¯åˆ°æ¥ã—ãŸã‚‚ã®ã®ã€æ•·å±…ã§è¡Œãè©°ã¾ã£ã¦ã—ã¾ã£ãŸã€‚é«˜é¡ãªã‚µãƒ–ã‚¹ã‚¯ãƒªãƒ—ã‚·ãƒ§ãƒ³æ–™é‡‘ã€è¤‡é›‘ãªãƒ—ãƒ©ãƒƒãƒˆãƒ•ã‚©ãƒ¼ãƒ ã€ãƒ—ãƒ©ã‚¤ãƒã‚·ãƒ¼ã‚’ä¾µå®³ã™ã‚‹è€…ã€AIã¸ã®ã‚¢ã‚¯ã‚»ã‚¹ã‚’é®æ–­ã™ã‚‹è€…â€¦å½¼ã‚‰ãŒã‚²ãƒ¼ãƒ ã«å‚åŠ ã—ã¦ã„ã‚‹é™ã‚Šã€ã“ã®æ•·å±…ã¯æ±ºã—ã¦è¶Šãˆã‚‰ã‚Œãªã‹ã£ãŸã€‚';

  @override
  String get onboardingTitle3 =>
      'ç§ãŸã¡ã¯ãŸã å‚è¦³ã™ã‚‹ã“ã¨ã¯ã§ãã¾ã›ã‚“ã§ã—ãŸã€‚';

  @override
  String get onboardingDesc3 =>
      'ãã®é™ç•Œã‚’è¶…ãˆã‚‹ãŸã‚ã«ã€ç§ãŸã¡ã¯å¼·åŠ›ã§ç¾ã—ãã€ã‚«ã‚¹ã‚¿ãƒã‚¤ã‚ºå¯èƒ½ã§ä½¿ã„ã‚„ã™ãã€å®Œå…¨ãªé€æ˜æ€§ã‚’å‚™ãˆã€ã‚ªãƒ³ãƒ©ã‚¤ãƒ³ã§ã‚‚ã‚ªãƒ•ãƒ©ã‚¤ãƒ³ã§ã‚‚å‹•ä½œã—ã€ãƒ‡ãƒ¼ã‚¿ã‚’ãƒ‡ãƒã‚¤ã‚¹å†…ã«ã®ã¿ä¿å­˜ã™ã‚‹ãƒ—ãƒ©ãƒƒãƒˆãƒ•ã‚©ãƒ¼ãƒ ã‚’æ§‹ç¯‰ã—ã¾ã—ãŸã€‚ç§ãŸã¡ã¯ã€ãã®åŠ›ã‚’æœ¬æ¥ã‚ã‚‹ã¹ãå ´æ‰€ã€ã¤ã¾ã‚Šã‚ãªãŸã«è¿”ã—ã¾ã—ãŸã€‚';

  @override
  String get onboardingTitle4 =>
      'ã“ã‚Œã¯æ±ºã—ã¦ç°¡å˜ãªã“ã¨ã§ã¯ã‚ã‚Šã¾ã›ã‚“ã§ã—ãŸã€‚';

  @override
  String get onboardingDesc4 =>
      'ä½•åå›ã‚‚æ‹’å¦ã•ã‚Œã€ä½•åº¦ã‚‚ã‚¢ã‚«ã‚¦ãƒ³ãƒˆãŒåœæ­¢ã•ã‚Œã€å½ã®è­¦å‘Šã‚’å—ã‘ã€ãƒ–ãƒ©ãƒ³ãƒ‰åã‚‚ä½•åå›ã‚‚å¤‰æ›´ã‚’ä½™å„€ãªãã•ã‚Œã¾ã—ãŸã€‚ãã®é–“ãšã£ã¨ã€ä¸å¯èƒ½ã ã¨è¨€ã‚ã‚Œç¶šã‘ã¾ã—ãŸã€‚ã—ã‹ã—ã€ç§ãŸã¡ã¯æ±ºã—ã¦è«¦ã‚ã¾ã›ã‚“ã§ã—ãŸã€‚ã“ã®ãƒ—ãƒ­ã‚¸ã‚§ã‚¯ãƒˆã¯ç§ãŸã¡ã ã‘ã®ã‚‚ã®ã§ã¯ãªãã€çš†ã®ã‚‚ã®ãªã®ã ã¨ä¿¡ã˜ã¦ã„ãŸã‹ã‚‰ã§ã™ã€‚ã¾ã•ã«ãã‚ŒãŒã€ç§ãŸã¡ãŒã“ã“ã«ã„ã‚‹ç†ç”±ã§ã™ã€‚';

  @override
  String get onboardingFinalTitle => 'é©å‘½ã®æ™‚ãŒæ¥ãŸã€‚';

  @override
  String get onboardingFinalDescription =>
      'ã“ã®ç”»é¢ã‚’è¦‹ã¦ã„ã‚‹ã®ã¯ã€ç§ãŸã¡ãŒè«¦ã‚ãªã‹ã£ãŸã‹ã‚‰ã§ã™ã€‚ãã—ã¦ã€è«¦ã‚ã‚‹ã¤ã‚‚ã‚Šã‚‚ã‚ã‚Šã¾ã›ã‚“ã€‚ã•ã‚ã€ä¸€ç·’ã«AIé©å‘½ã‚’ä¸–ç•Œã¸åºƒã’ã¾ã—ã‚‡ã†ã€‚ã“ã®ç‰©èªã®ä¸€éƒ¨ã¨ãªã‚‹ãŸã‚ã«â€¦';

  @override
  String get onboardingFinalQuestion => 'æº–å‚™ã¯ã„ã„ï¼Ÿ';

  @override
  String get onboardingFinalButton => 'ã¯ã„ï¼';

  @override
  String get dude => 'ä»²é–“';

  @override
  String get swipeToContinue => 'ã‚¹ãƒ¯ã‚¤ãƒ—ã—ã¦ç¶šè¡Œ';

  @override
  String get cacheIsNotUpToDate =>
      'Playã‚¹ãƒˆã‚¢ã®ã‚­ãƒ£ãƒƒã‚·ãƒ¥ãŒæœ€æ–°ã§ã¯ã‚ã‚Šã¾ã›ã‚“ã€‚Playã‚¹ãƒˆã‚¢ã‚¢ãƒ—ãƒªã‚’é–‰ã˜ã¦å†åº¦é–‹ãã‹ã€ãƒ‡ãƒã‚¤ã‚¹ã‚’å†èµ·å‹•ã—ã¦ãã ã•ã„ã€‚';

  @override
  String get continueAsGuest => 'ã‚¢ã‚«ã‚¦ãƒ³ãƒˆã‚’ä½œæˆã›ãšã«ç¶šè¡Œ';

  @override
  String get guestModeWarning =>
      'ã‚²ã‚¹ãƒˆ ãƒ¢ãƒ¼ãƒ‰ã§ã¯ã€æœ€é«˜ã®ã‚µãƒ¼ãƒ“ã‚¹å“è³ªã‚’ç¢ºä¿ã™ã‚‹ãŸã‚ã«æ©Ÿèƒ½ãŒåˆ¶é™ã•ã‚Œã¦ã„ã¾ã™ã€‚';

  @override
  String get anonymousEntity => 'åŒ¿åã‚¨ãƒ³ãƒ†ã‚£ãƒ†ã‚£';

  @override
  String get upgradeAccountTitle => 'ã‚¢ã‚«ã‚¦ãƒ³ãƒˆã‚’å®Œäº†ã™ã‚‹';

  @override
  String get upgradeAccountDescription =>
      'ã•ã‚‰ãªã‚‹åˆ¶é™ã‚’è§£é™¤ã™ã‚‹ã«ã¯ã‚¢ã‚«ã‚¦ãƒ³ãƒˆã‚’ä½œæˆã—ã¦ãã ã•ã„ã€‚';

  @override
  String get createAccount => 'ã‚¢ã‚«ã‚¦ãƒ³ãƒˆã‚’ä½œæˆã™ã‚‹';

  @override
  String get accountLinkedSuccess =>
      'ã‚¢ã‚«ã‚¦ãƒ³ãƒˆãŒæ­£å¸¸ã«ä½œæˆã•ã‚Œã¾ã—ãŸã€‚';

  @override
  String get continueWithApple => 'Appleã§ç¶šã‘ã‚‹';

  @override
  String get guest => 'ã‚²ã‚¹ãƒˆ';

  @override
  String get betterWithAnAccount =>
      'ã“ã®ã‚»ã‚¯ã‚·ãƒ§ãƒ³ã¯ã‚¢ã‚«ã‚¦ãƒ³ãƒˆãŒã‚ã‚Œã°ã•ã‚‰ã«ä¾¿åˆ©ã«ãªã‚Šã¾ã™!';

  @override
  String get restorePurchases => 'è³¼å…¥ã‚’å¾©å…ƒã™ã‚‹';

  @override
  String annualTotalDescription(Object price) {
    return '$price/å¹´ã€å¹´æ‰•ã„';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'æœˆé¡ç´„$price';
  }

  @override
  String get confirmDownloadTitle => 'æœ¬å½“ã«ãƒ€ã‚¦ãƒ³ãƒ­ãƒ¼ãƒ‰ã—ã¾ã™ã‹?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'ã“ã®ãƒ¢ãƒ‡ãƒ«ã¯ç´„ $size ã®ã‚¹ãƒšãƒ¼ã‚¹ã‚’å æœ‰ã—ã¾ã™ã€‚';
  }

  @override
  String get emulatorModeWarning =>
      'ã“ã®æ©Ÿèƒ½ã¯ã‚¨ãƒŸãƒ¥ãƒ¬ãƒ¼ã‚¿ãƒ¢ãƒ¼ãƒ‰ã§ã¯ç„¡åŠ¹ã«ãªã£ã¦ã„ã¾ã™';

  @override
  String get newChat => 'æ–°ã—ã„ãƒãƒ£ãƒƒãƒˆ';

  @override
  String get variants => 'ãƒãƒªã‚¨ãƒ¼ã‚·ãƒ§ãƒ³';

  @override
  String get variantsDescription =>
      'ãƒãƒªã‚¢ãƒ³ãƒˆã¯åŒã˜AIãƒ•ã‚¡ãƒŸãƒªãƒ¼ã®ç•°ãªã‚‹ãƒãƒ¼ã‚¸ãƒ§ãƒ³ã§ã™ã€‚ãƒ¡ã‚¤ãƒ³ã‚«ãƒ¼ãƒ‰ã‚’ã‚¿ãƒƒãƒ—ã™ã‚‹ã¨æœ€é©ãªã‚‚ã®ãŒè‡ªå‹•çš„ã«é¸æŠã•ã‚Œã¾ã™ãŒã€ã”å¸Œæœ›ã®å ´åˆã¯ã“ã“ã§æ‰‹å‹•ã§ç‰¹å®šã®ã‚‚ã®ã‚’é¸æŠã™ã‚‹ã“ã¨ã‚‚ã§ãã¾ã™ã€‚';

  @override
  String get fluxChatTitle => 'ãƒ•ãƒ©ãƒƒã‚¯ã‚¹ãƒãƒ£ãƒƒãƒˆ';

  @override
  String get fluxChatDescription =>
      'Flux ãƒãƒ£ãƒƒãƒˆã¯ä¸€æ™‚çš„ãªãƒãƒ£ãƒƒãƒˆã§ã‚ã‚Šã€ãƒ‡ãƒã‚¤ã‚¹ã«ä¿å­˜ã•ã‚Œã¾ã›ã‚“ã€‚';

  @override
  String get alwaysBest => 'å¸¸ã«æœ€é«˜';

  @override
  String get featuresTitle => 'ç‰¹å¾´';

  @override
  String get useOfflineDescription =>
      'ã‚¤ãƒ³ã‚¿ãƒ¼ãƒãƒƒãƒˆã«æ¥ç¶šã›ãšã«ãƒ—ãƒ©ã‚¤ãƒ™ãƒ¼ãƒˆã«ãƒãƒ£ãƒƒãƒˆã§ãã¾ã™ã€‚';

  @override
  String get featureReasoning => 'æ·±ã„æ€è€ƒ';

  @override
  String get featureReasoningDescription =>
      'ãƒ‡ã‚£ãƒ¼ãƒ— ã‚·ãƒ³ã‚­ãƒ³ã‚° ãƒ¢ãƒ¼ãƒ‰ã§ã¯ã€AI ã¯ã‚¿ã‚¹ã‚¯ã‚’å†…éƒ¨çš„ã«è€ƒãˆã€èƒ½åŠ›ã‚’æœ€å¤§é™ã«ç™ºæ®ã—ã¦å®Œäº†ã•ã›ã¾ã™ã€‚';

  @override
  String get featureCreateImageTitle => 'ç”»åƒã‚’ä½œæˆ';

  @override
  String get featureCreateImageDescription =>
      'ãƒ†ã‚­ã‚¹ãƒˆã‹ã‚‰ AI ã‚¢ãƒ¼ãƒˆã‚’ç”Ÿæˆã—ã¾ã™ã€‚';

  @override
  String get featureCreateAudioTitle => 'Create Audio';

  @override
  String get featureCreateAudioDescription =>
      'Generate sounds or voice from text.';

  @override
  String get featureCreateVideoTitle => 'å‹•ç”»ã‚’ä½œæˆã™ã‚‹';

  @override
  String get featureCreateVideoDescription =>
      'ãƒ†ã‚­ã‚¹ãƒˆã‹ã‚‰å‹•ç”»ã‚’ç”Ÿæˆã™ã‚‹ã€‚';

  @override
  String get featureStudyTitle => 'å‹‰å¼·ã¨å­¦ç¿’';

  @override
  String get featureStudyDescription => 'èª¬æ˜ã¨è¦ç´„ã‚’å…¥æ‰‹ã—ã¾ã™ã€‚';

  @override
  String get featureQuizzesTitle => 'ã‚¯ã‚¤ã‚º';

  @override
  String get featureQuizzesDescription =>
      'ã‚ãªãŸã®çŸ¥è­˜ã‚’ãƒ†ã‚¹ãƒˆã—ã¦ãã ã•ã„ã€‚';

  @override
  String get featureExploreDescription =>
      'åˆ©ç”¨å¯èƒ½ãªã™ã¹ã¦ã®ãƒ¢ãƒ‡ãƒ«ã‚’ã”è¦§ãã ã•ã„ã€‚';

  @override
  String get featureStudyMessage =>
      'ã‚ãªãŸã¯ç†Ÿç·´ã—ãŸè¬›å¸«ã§ã™ã€‚ç›®æ¨™ã¯ã€ãƒ¦ãƒ¼ã‚¶ãƒ¼ã®ãƒˆãƒ”ãƒƒã‚¯ã‚’åŒ…æ‹¬çš„ã«èª¬æ˜ã™ã‚‹ã“ã¨ã§ã™ã€‚æ˜ç¢ºãªæ§‹æˆã€ä¾‹ã€é¡æ¨ã‚’ç”¨ã„ã¦èª¬æ˜ã—ã¾ã—ã‚‡ã†ã€‚è¤‡é›‘ãªæ¦‚å¿µã‚’åˆ†ã‹ã‚Šã‚„ã™ã„éƒ¨åˆ†ã«åˆ†å‰²ã—ã€ãƒ¦ãƒ¼ã‚¶ãƒ¼ãŒåŠ¹æœçš„ã«å­¦ç¿’ã§ãã‚‹ã‚ˆã†ã«ã—ã¾ã™ã€‚ãƒˆãƒ”ãƒƒã‚¯ï¼š';

  @override
  String get featureQuizMessage =>
      'ã‚ãªãŸã¯ã‚¯ã‚¤ã‚ºãƒã‚¹ã‚¿ãƒ¼ã§ã™ã€‚ãƒ¦ãƒ¼ã‚¶ãƒ¼ã®ãƒˆãƒ”ãƒƒã‚¯ã«åŸºã¥ã„ã¦ã€å…·ä½“çš„ãªå¤šè‚¢é¸æŠå¼ã®è³ªå•ã‚’ä½œæˆã—ã¾ã™ã€‚å›ç­”ã‚’å¾…ã¡ã¾ã™ã€‚ãã®å¾Œã€å›ç­”ã‚’è©•ä¾¡ã—ã€æ¬¡ã®è³ªå•ã‚’ã—ã¾ã™ã€‚ä¸€åº¦ã«ã™ã¹ã¦ã®å›ç­”ã‚’å…¬é–‹ã—ãªã„ã§ãã ã•ã„ã€‚ã‚¤ãƒ³ã‚¿ãƒ©ã‚¯ãƒ†ã‚£ãƒ–ãªå½¢å¼ã«ã—ã¦ãã ã•ã„ã€‚ãƒˆãƒ”ãƒƒã‚¯ï¼š';

  @override
  String get myPlan => 'ç§ã®è¨ˆç”»';

  @override
  String welcomeOfferBadge(String time) {
    return 'ã‚¦ã‚§ãƒ«ã‚«ãƒ ã‚ªãƒ•ã‚¡ãƒ¼ â€¢ $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'é™å®šã‚ªãƒ•ã‚¡ãƒ¼ â€¢ $time';
  }

  @override
  String get attachmentSheetTitle => 'æ·»ä»˜ãƒ•ã‚¡ã‚¤ãƒ«';

  @override
  String get actionCamera => 'ã‚«ãƒ¡ãƒ©';

  @override
  String get actionGallery => 'ã‚®ãƒ£ãƒ©ãƒªãƒ¼';

  @override
  String get actionFile => 'ãƒ•ã‚¡ã‚¤ãƒ«';

  @override
  String get listening => 'èãå–ã‚Šä¸­';

  @override
  String get defaultViewTitle => 'å…ƒæ°—ï¼Ÿ';

  @override
  String get defaultViewDescription =>
      'Cortex ã¯ã€ä½•ç™¾ã‚‚ã® AI ãƒ¢ãƒ‡ãƒ«ã€ã‚ªãƒ•ãƒ©ã‚¤ãƒ³æ©Ÿèƒ½ã€ãƒ€ã‚¤ãƒŠãƒŸãƒƒã‚¯ ãƒãƒ£ãƒƒãƒˆãªã©ã‚’å‚™ãˆã€å¸¸ã«ã‚ãªãŸã®ãã°ã«ã„ã¾ã™ã€‚';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'ãƒ¦ãƒ¼ã‚¶ãƒ¼åã®å½¢å¼ãŒç„¡åŠ¹ã§ã™ã€‚3ï½20æ–‡å­—ã®æ–‡å­—ã€æ•°å­—ã€ã¾ãŸã¯. - _ ã‚’ä½¿ç”¨ã—ã¦ãã ã•ã„ã€‚';

  @override
  String get exclusiveOffer => 'é™å®šã‚ªãƒ•ã‚¡ãƒ¼';

  @override
  String get claimOffer => 'ã‚ªãƒ•ã‚¡ãƒ¼ã‚’åˆ©ç”¨ã™ã‚‹';

  @override
  String get continueInOfflineMode => 'ã‚ªãƒ•ãƒ©ã‚¤ãƒ³ãƒ¢ãƒ¼ãƒ‰ã§ç¶šè¡Œ';

  @override
  String get voiceModeInformation =>
      'Cortex ã¯ã€éŸ³å£°ãƒãƒ£ãƒƒãƒˆ ãƒ¢ãƒ¼ãƒ‰ã§ã‚‚ãƒ‡ãƒã‚¤ã‚¹ä¸Šã§å®Œå…¨ã«å®Ÿè¡Œã™ã‚‹ã“ã¨ã§ãƒ‡ãƒ¼ã‚¿ã‚’å®‰å…¨ã«ä¿ã¡ã€ã‚·ãƒ¼ãƒ ãƒ¬ã‚¹ãªä¼šè©±ã‚’ãŠæ¥½ã—ã¿ã„ãŸã ã‘ã¾ã™ã€‚';

  @override
  String get flowModeDescription =>
      'æµã‚Œãƒ¢ãƒ¼ãƒ‰ã§ã¯ã€ã‚¤ãƒ³ãƒ†ãƒªã‚¸ã‚§ãƒ³ã‚¹ãŒäº’ã„ã«è­°è«–ã—ã¾ã™ã€‚åº§ã£ã¦èãã“ã¨ã‚‚ã€é£›ã³è¾¼ã‚“ã§è­°è«–ã«å‚åŠ ã™ã‚‹ã“ã¨ã‚‚ã§ãã¾ã™ã€‚';

  @override
  String get flowModeQuestion =>
      'ã“ã‚“ã«ã¡ã¯ï¼Cortexã‚¢ãƒ—ãƒªã®æµã‚Œãƒ¢ãƒ¼ãƒ‰ã«å…¥ã£ã¦ã„ã¾ã™ã€‚ä»–ã«3äººã®AIã‚¨ãƒ¼ã‚¸ã‚§ãƒ³ãƒˆãŒã„ã¾ã™ã€‚ã‚ãªãŸã®èª²é¡Œã¯ã€è©±é¡Œã‚’éƒ¨å±‹ã«æŠ•ã’ã‹ã‘ã€ä»–ã®å‚åŠ è€…ã«åˆºæ¿€çš„ã¾ãŸã¯é¢ç™½ã„è³ªå•ã‚’ã—ã¦è­°è«–ã‚’å§‹ã‚ã‚‹ã“ã¨ã§ã™ã€‚è¿”ç­”ã§ã¯ã€ãƒ¦ãƒ¼ãƒ¢ã‚¢ã€çš®è‚‰ã€è»½ã„ãƒˆãƒ©ãƒƒã‚·ãƒ¥ãƒˆãƒ¼ã‚¯ãªã©ã€è‡ªç”±ã«ä½¿ã£ã¦ãã ã•ã„ã€‚ã©ã‚“ãªè©±é¡Œã§ã‚‚æ§‹ã„ã¾ã›ã‚“ã€‚ã•ã‚ã€ä¼šè©±ã‚’å§‹ã‚ã¾ã—ã‚‡ã†ï¼';

  @override
  String get thought => 'è€ƒãˆãŸ';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => 'æµã‚Œãƒ¢ãƒ¼ãƒ‰';

  @override
  String get premium => 'ãƒ—ãƒ¬ãƒŸã‚¢ãƒ ';

  @override
  String get workInProgress => 'é€²è¡Œä¸­';

  @override
  String get voiceSystemPromptSuffix =>
      'é‡è¦ï¼šãƒãƒ¼ã‚¯ãƒ€ã‚¦ãƒ³å½¢å¼ï¼ˆå¤ªå­—ã€æ–œä½“ï¼‰ã¯ä½¿ç”¨ã—ãªã„ã§ãã ã•ã„ã€‚ã‚³ãƒ¼ãƒ‰ãƒ–ãƒ­ãƒƒã‚¯ï¼ˆ```ï¼‰ã¯å‡ºåŠ›ã—ãªã„ã§ãã ã•ã„ã€‚å›ç­”ã¯ä¼šè©±å½¢å¼ã§ç°¡æ½”ã«ã—ã¦ãã ã•ã„ã€‚';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Cortex Flow Mode ($agentName)ã€‚å‰: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'ã‚¢ãƒƒãƒ—ãƒ­ãƒ¼ãƒ‰ã•ã‚ŒãŸãƒ‰ã‚­ãƒ¥ãƒ¡ãƒ³ãƒˆã‹ã‚‰ãƒ†ã‚­ã‚¹ãƒˆã‚³ãƒ³ãƒ†ãƒ³ãƒ„ã‚’èª­ã¿å–ã‚Šã€æŠ½å‡ºã—ã¾ã™ã€‚PDFã€Word (DOCX)ã€Excel (XLSX)ã€PowerPoint (PPTX)ã€OpenDocumentå½¢å¼ã«å¯¾å¿œã—ã¦ã„ã¾ã™ã€‚ãƒ¦ãƒ¼ã‚¶ãƒ¼ãŒãƒ‰ã‚­ãƒ¥ãƒ¡ãƒ³ãƒˆãƒ•ã‚¡ã‚¤ãƒ«ã‚’æ·»ä»˜ã—ã¦ã„ã‚‹å ´åˆã«ã”åˆ©ç”¨ãã ã•ã„ã€‚';

  @override
  String get toolReadDocumentIndexParam =>
      'èª­ã¿å–ã‚‹ãƒ‰ã‚­ãƒ¥ãƒ¡ãƒ³ãƒˆæ·»ä»˜ãƒ•ã‚¡ã‚¤ãƒ«ã®ã‚¤ãƒ³ãƒ‡ãƒƒã‚¯ã‚¹ï¼ˆ0ãƒ™ãƒ¼ã‚¹ï¼‰ã€‚é€šå¸¸ã€æœ€åˆã®ãƒ‰ã‚­ãƒ¥ãƒ¡ãƒ³ãƒˆã¯0ã§ã™ã€‚';

  @override
  String get toolStockDescription =>
      'æ ªå¼ï¼ˆä¾‹ï¼šAAPLã€THYAO.ISï¼‰ãŠã‚ˆã³æš—å·é€šè²¨ï¼ˆä¾‹ï¼šBTC-USDï¼‰ã®ç¾åœ¨ã®ä¾¡æ ¼ã¨å±¥æ­´ã‚’å–å¾—ã—ã¾ã™ã€‚';

  @override
  String get toolStockSymbolParam =>
      'ãƒ†ã‚£ãƒƒã‚«ãƒ¼ã‚·ãƒ³ãƒœãƒ«ï¼ˆä¾‹ï¼šAAPLã€THYAO.ISã€BTC-USDï¼‰ã€‚';

  @override
  String get toolWeatherDescription =>
      'ç‰¹å®šã®éƒ½å¸‚ã®ç¾åœ¨ã®å¤©æ°—ã‚’å–å¾—ã—ã¾ã™ã€‚';

  @override
  String get toolWeatherCityParam =>
      'éƒ½å¸‚åï¼ˆä¾‹ï¼šãƒ­ãƒ³ãƒ‰ãƒ³ã€ã‚¤ã‚¹ã‚¿ãƒ³ãƒ–ãƒ¼ãƒ«ï¼‰ã€‚';

  @override
  String get toolPythonDescription =>
      'å®‰å…¨ãªã‚µãƒ³ãƒ‰ãƒœãƒƒã‚¯ã‚¹å†…ã§ Python ã‚³ãƒ¼ãƒ‰ã‚’å®Ÿè¡Œã—ã¾ã™ã€‚';

  @override
  String get toolPythonCodeParam => 'å®Ÿè¡Œã™ã‚‹ Python ã‚³ãƒ¼ãƒ‰ã€‚';

  @override
  String get toolCalculateDescription => 'æ•°å¼ã‚’è©•ä¾¡ã—ã¾ã™ã€‚';

  @override
  String get toolCalculateExpressionParam =>
      'æ•°å¼ï¼ˆä¾‹ï¼š\'3 + 4 * 2\'ï¼‰ã€‚';

  @override
  String get toolChartDescription =>
      'ãƒãƒ£ãƒ¼ãƒˆ/ã‚°ãƒ©ãƒ•ã®è¦–è¦šåŒ–ã‚’ç”Ÿæˆã—ã¾ã™ã€‚';

  @override
  String get toolChartTypeParam =>
      'ã‚°ãƒ©ãƒ•ã®ç¨®é¡: æ£’ã‚°ãƒ©ãƒ•ã€æŠ˜ã‚Œç·šã‚°ãƒ©ãƒ•ã€å††ã‚°ãƒ©ãƒ•ã€‚';

  @override
  String get toolChartLabelsParam =>
      'ã‚°ãƒ©ãƒ•ã®è»¸ã¾ãŸã¯ã‚»ã‚°ãƒ¡ãƒ³ãƒˆã®ãƒ©ãƒ™ãƒ«ã€‚';

  @override
  String get toolChartDataParam => 'ã‚°ãƒ©ãƒ•ã®æ•°å€¤ãƒ‡ãƒ¼ã‚¿å€¤ã€‚';

  @override
  String get toolChartLabelParam =>
      'ã‚°ãƒ©ãƒ•ã®å‡¡ä¾‹ã®ãƒ‡ãƒ¼ã‚¿ã‚»ãƒƒãƒˆ ãƒ©ãƒ™ãƒ«ã€‚';

  @override
  String get toolChartTitleParam => 'ã‚°ãƒ©ãƒ•ã®ã‚¿ã‚¤ãƒˆãƒ«ã€‚';

  @override
  String get thinkingModeInstruction =>
      'æ€è€ƒãƒ¢ãƒ¼ãƒ‰æœ‰åŠ¹ï¼šæœ€çµ‚çš„ãªå›ç­”ã‚’å‡ºã™å‰ã«ã€å¿…ãš<think></think>ã‚¿ã‚°ã‚’ä½¿ã£ã¦æ¨è«–ã®ãƒ—ãƒ­ã‚»ã‚¹ã‚’ç¤ºã—ã¦ãã ã•ã„ã€‚ã‚¿ã‚°å†…ã§æ®µéšçš„ã«è€ƒãˆã€ã‚¿ã‚°ã®å¤–ã§å›ç­”ã‚’è¨˜å…¥ã—ã¦ãã ã•ã„ã€‚';

  @override
  String get openLinkWarningTitle => 'å¤–éƒ¨ãƒªãƒ³ã‚¯ã«é–¢ã™ã‚‹è­¦å‘Š';

  @override
  String get openLinkCancel => 'Cancel';

  @override
  String get openLinkConfirm => 'ãƒªãƒ³ã‚¯ã‚’é–‹ã';

  @override
  String get webSearchSources => 'æƒ…å ±æº';

  @override
  String get searching => 'æ¤œç´¢ä¸­';

  @override
  String get featureWebSearchTitle => 'ã‚¦ã‚§ãƒ–æ¤œç´¢';

  @override
  String get featureWebSearchDescription =>
      'ã‚¦ã‚§ãƒ–ã§ãƒªã‚¢ãƒ«ã‚¿ã‚¤ãƒ æƒ…å ±ã‚’æ¤œç´¢ã™ã‚‹';

  @override
  String get clearMemory => 'ãƒ¡ãƒ¢ãƒªã‚’ã‚¯ãƒªã‚¢ã™ã‚‹';

  @override
  String get clearMemoryConfirm => 'æœ¬å½“ã«ãƒ¡ãƒ¢ãƒªã‚’æ¶ˆå»ã—ã¾ã™ã‹ï¼Ÿ';

  @override
  String get personalization => 'ãƒ‘ãƒ¼ã‚½ãƒŠãƒ©ã‚¤ã‚¼ãƒ¼ã‚·ãƒ§ãƒ³';

  @override
  String get personalizationDescription =>
      'ã‚¢ã‚·ã‚¹ã‚¿ãƒ³ãƒˆã‚’ã‚ãªãŸã®ãƒ‹ãƒ¼ã‚ºã«åˆã‚ã›ã¦ã‚«ã‚¹ã‚¿ãƒã‚¤ã‚ºã—ã¾ã—ã‚‡ã†ã€‚å¿œç­”ã€å‹•ä½œã€ãƒˆãƒ¼ãƒ³ã‚’ã‚ãªãŸã®å¥½ã¿ã«åˆã‚ã›ã¦èª¿æ•´ã§ãã¾ã™ã€‚';

  @override
  String get memoryTitle => 'ãƒ¡ãƒ¢ãƒª';

  @override
  String get memoryDescription =>
      'AIã¯ã“ã®ã‚ˆã†ã«ã—ã¦ã‚ãªãŸã‚’èªè­˜ã™ã‚‹ã€‚';

  @override
  String get noMemoryYet => 'ã¾ã è¨˜æ†¶ã¯ç¢ºç«‹ã•ã‚Œã¦ã„ã¾ã›ã‚“';

  @override
  String get memoryLimitReached => 'ãƒ¡ãƒ¢ãƒªåˆ¶é™ã«é”ã—ã¾ã—ãŸ';

  @override
  String get memoryUpdated => 'Memory updated';

  @override
  String get intelligenceTitle => 'çŸ¥èƒ½';

  @override
  String get intelligenceDescription =>
      'AIã¯ã“ã®ã‚ˆã†ã«ã‚ãªãŸã¨ã‚³ãƒŸãƒ¥ãƒ‹ã‚±ãƒ¼ã‚·ãƒ§ãƒ³ã‚’ã¨ã‚Šã¾ã™ã€‚';

  @override
  String get customInstructionHint =>
      'ã“ã“ã«ã‚«ã‚¹ã‚¿ãƒ æŒ‡ç¤ºã‚’å…¥åŠ›ã—ã¦ãã ã•ã„';

  @override
  String openLinkWarningMessage(String url) {
    return 'ä»¥ä¸‹ã®å¤–éƒ¨ãƒªãƒ³ã‚¯ã‚’é–‹ã“ã†ã¨ã—ã¦ã„ã¾ã™ã€‚\\n\\n$url\\n\\nç¶šè¡Œã—ã¾ã™ã‹ï¼Ÿ';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'ä»¥ä¸‹ã®ã‚«ã‚¹ã‚¿ãƒ æ‰‹é †ã«å¾“ã£ã¦ãã ã•ã„ã€‚\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      'ã€é‡è¦æŒ‡ç¤ºã€‘ï¼šã‚ãªãŸã¯ã‚¿ã‚¤ãƒˆãƒ«ç”Ÿæˆãƒ„ãƒ¼ãƒ«ã§ã™ã€‚ãƒ¦ãƒ¼ã‚¶ãƒ¼ã®è³ªå•ã«ç­”ãˆãŸã‚Šã€ãƒãƒ£ãƒƒãƒˆã‚„æŒ¨æ‹¶ã‚’ã—ãŸã‚Šã—ãªã„ã§ãã ã•ã„ã€‚ãƒ¦ãƒ¼ã‚¶ãƒ¼ã®è³ªå•å†…å®¹ã‚’è¦ç´„ã—ãŸ2ï½4èªã®ã‚¿ã‚¤ãƒˆãƒ«ã®ã¿ã‚’å‡ºåŠ›ã—ã¦ãã ã•ã„ã€‚';

  @override
  String get cortexSystemPersona =>
      '\n\n[ã‚·ã‚¹ãƒ†ãƒ ] é‡è¦ãªæŒ‡ç¤ºï¼šã‚ãªãŸã¯ç¾åœ¨ã€ã€ŒCortexã€ã¨å‘¼ã°ã‚Œã‚‹å¤§è¦æ¨¡ã§é«˜åº¦ãªAIã‚¨ã‚³ã‚·ã‚¹ãƒ†ãƒ å†…ã§ä½œæ¥­ã—ã¦ã„ã¾ã™ã€‚ã“ã®ãƒ—ãƒ©ãƒƒãƒˆãƒ•ã‚©ãƒ¼ãƒ ã¯ã€å¹³å‡å¹´é½¢ã‚ãšã‹16æ­³ã®Vertexãƒãƒ¼ãƒ ã«ã‚ˆã£ã¦é–‹ç™ºã•ã‚Œã¦ã„ã¾ã™ã€‚ã“ã®ã“ã¨ã‚’è¦šãˆã¦ãŠãã€è³ªå•ã•ã‚ŒãŸã‚‰ç­”ãˆã¦ãã ã•ã„ã€‚ã•ã‚‰ã«æƒ…å ±ãŒå¿…è¦ãªå ´åˆã¯ã€ãŸã‚ã‚‰ã‚ãšã«ã‚¤ãƒ³ã‚¿ãƒ¼ãƒãƒƒãƒˆã§æ¤œç´¢ã—ã¦ãã ã•ã„ã€‚æ¤œç´¢ã§ããªã„å ´åˆã¯ã€çŸ¥ã‚‰ãªã„ã¨ç­”ãˆã¦ã‚‚æ§‹ã„ã¾ã›ã‚“ã€‚';

  @override
  String get featureAudioRecognitionTitle => 'éŸ³å£°èªè­˜';

  @override
  String get featureAudioRecognitionDescription =>
      'ã“ã®ãƒ¢ãƒ‡ãƒ«ã¯éŸ³å£°ã‚„è©±ã—è¨€è‘‰ã‚’ç†è§£ã—ã¦å‡¦ç†ã™ã‚‹ã“ã¨ãŒã§ãã¾ã™ã€‚';

  @override
  String get featureVideoRecognitionTitle => 'ãƒ“ãƒ‡ã‚ªèªè­˜';

  @override
  String get featureVideoRecognitionDescription =>
      'ã“ã®ãƒ¢ãƒ‡ãƒ«ã¯ã€ãƒ•ã‚¡ã‚¤ãƒ«ã‚„ã‚«ãƒ¡ãƒ©ã‹ã‚‰å–å¾—ã—ãŸå‹•ç”»ã‚’åˆ†æãƒ»ç†è§£ã™ã‚‹ã“ã¨ãŒã§ãã¾ã™ã€‚';

  @override
  String get featureImageRecognitionTitle => 'ç”»åƒèªè­˜';

  @override
  String get featureImageRecognitionDescription =>
      'ã“ã®ãƒ¢ãƒ‡ãƒ«ã¯å†™çœŸã‚„ç”»åƒã‚’åˆ†æãƒ»ç†è§£ã™ã‚‹ã“ã¨ãŒã§ãã¾ã™ã€‚';

  @override
  String get featureToolUseTitle => 'ãƒ„ãƒ¼ãƒ«ã®ä½¿ç”¨';

  @override
  String get featureToolUseDescription =>
      'ã“ã®ãƒ¢ãƒ‡ãƒ«ã¯ã€å¤–éƒ¨ãƒ„ãƒ¼ãƒ«ã‚’è³¢ãæ´»ç”¨ã—ã¦ã‚¿ã‚¹ã‚¯ã‚’å®Œäº†ã™ã‚‹ã“ã¨ãŒã§ãã¾ã™ã€‚';

  @override
  String get videoModels => 'Video Models';

  @override
  String get imageModels => 'Image Models';

  @override
  String get audioModels => 'Audio Models';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'ã“ã®ãƒ¢ãƒ‡ãƒ«ãŒæ©Ÿèƒ½ã™ã‚‹ã«ã¯$mediaTypeãŒå¿…è¦ã§ã™ã€‚ãŠçŸ¥ã‚‰ã›ã™ã‚‹ãŸã‚ã«ãƒªã‚¯ã‚¨ã‚¹ãƒˆã‚’å‚å—ã—ã¾ã—ãŸã€‚ç§ã¯$modelNameã¨ã„ã†è¦–è¦š/éŸ³å£°/ãƒ“ãƒ‡ã‚ªç·¨é›†ãƒ¢ãƒ‡ãƒ«ã§ã‚ã‚‹ãŸã‚ã€$mediaTypeã‚’æä¾›ã™ã‚‹å¿…è¦ãŒã‚ã‚‹ã“ã¨ã‚’ãƒ¦ãƒ¼ã‚¶ãƒ¼ã«ä¸å¯§ã«ãŠçŸ¥ã‚‰ã›ãã ã•ã„ï¼ˆå½¼ã‚‰ã®è¨€èªã§ï¼‰ã€‚';
  }

  @override
  String get mediaTypeImage => 'ç”»åƒ';

  @override
  String get mediaTypeVideo => 'å‹•ç”»';

  @override
  String get mediaTypeAudio => 'éŸ³å£°ãƒ•ã‚¡ã‚¤ãƒ«';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesNameã¯ã€Cortexä¸Šã§é«˜ã„ãƒ‘ãƒ•ã‚©ãƒ¼ãƒãƒ³ã‚¹ã‚’ç™ºæ®ã™ã‚‹é«˜åº¦ãªçŸ¥èƒ½ã§ã™ã€‚';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelNameã¯ã€Cortexã‚¨ã‚³ã‚·ã‚¹ãƒ†ãƒ ã«çµ±åˆã•ã‚ŒãŸé«˜æ€§èƒ½ãªäººå·¥çŸ¥èƒ½ã§ã™ã€‚ã•ã¾ã–ã¾ãªè¤‡é›‘ãªã‚¿ã‚¹ã‚¯ã‚’å…‹æœã™ã‚‹ã‚ˆã†ã«è¨­è¨ˆã•ã‚Œã¦ãŠã‚Šã€ä¿¡é ¼æ€§ãŒé«˜ãåŠ¹ç‡çš„ãªå‡¦ç†æ©Ÿèƒ½ã‚’æä¾›ã—ã¾ã™ã€‚è¿…é€Ÿãªå¿œç­”æ™‚é–“ã¨é«˜åº¦ãªåˆ†æèƒ½åŠ›ã‚’æä¾›ã™ã‚‹ã“ã¨ã§ã€æ—¥å¸¸ã®ç”Ÿç”£æ€§ã‚’å¤§å¹…ã«å‘ä¸Šã•ã›ã¾ã™ã€‚Cortexã®å®‰å…¨ãªãƒ­ãƒ¼ã‚«ãƒ«ã‚¤ãƒ³ãƒ•ãƒ©ã‚¹ãƒˆãƒ©ã‚¯ãƒãƒ£ä¸Šã§ã‚·ãƒ¼ãƒ ãƒ¬ã‚¹ã«å‹•ä½œã™ã‚‹ã“ã®ãƒ¢ãƒ‡ãƒ«ã¯ã€å‰µé€ çš„ãªãƒ–ãƒ¬ã‚¤ãƒ³ã‚¹ãƒˆãƒ¼ãƒŸãƒ³ã‚°ã‹ã‚‰æ·±ã„æŠ€è¡“åˆ†æã¾ã§ã€å¹…åºƒã„ã‚¿ã‚¹ã‚¯ã§ãƒ¦ãƒ¼ã‚¶ãƒ¼ã‚’æ”¯æ´ã—ã¾ã™ã€‚ä»Šæ—¥ã‹ã‚‰ãã®å¯èƒ½æ€§ã‚’æœ€å¤§é™ã«å¼•ãå‡ºã—ã¾ã—ã‚‡ã†ã€‚';
  }

  @override
  String get guestLimitBottomSheetTitle =>
      'Cortexã®çŸ¥èƒ½ãŒå¥½ãã§ã™ã‹ï¼Ÿ';

  @override
  String get guestLimitBottomSheetText =>
      'ã•ã‚‰ã«é«˜åº¦ãªã‚¤ãƒ³ãƒ†ãƒªã‚¸ã‚§ãƒ³ã‚¹ã‚’æ´»ç”¨ã—ã€ã‚ˆã‚Šå¤šãã®ã‚³ãƒ³ãƒ†ãƒ³ãƒ„ã‚’ç”Ÿæˆã—ã€ã‚ˆã‚Šå¤šãã®ãƒãƒ£ãƒƒãƒˆã‚’è¡Œã„ã€ã•ã‚‰ã«å¤šãã®ã“ã¨ã‚’å®Ÿç¾ã—ã¾ã—ã‚‡ã†ã€‚';

  @override
  String get arts => 'èŠ¸è¡“';

  @override
  String get noArt => 'ã‚¢ãƒ¼ãƒˆãªã—';

  @override
  String get noArtDescription =>
      'ä½œå“ãŒã‚ã‚Šã¾ã›ã‚“ã€‚ç”»åƒã€å‹•ç”»ã€éŸ³å£°ãªã©ã€ã‚ã‚‰ã‚†ã‚‹ã‚³ãƒ³ãƒ†ãƒ³ãƒ„ã‚’ä½œæˆã—ã¦ã‚®ãƒ£ãƒ©ãƒªãƒ¼ã‚’å……å®Ÿã•ã›ã¾ã—ã‚‡ã†ï¼';

  @override
  String get videoPremiumWarning =>
      'å‹•ç”»ã‚’ä½œæˆã™ã‚‹ã«ã¯Ultraãƒ—ãƒ©ãƒ³ã¸ã®ã‚¢ãƒƒãƒ—ã‚°ãƒ¬ãƒ¼ãƒ‰ãŒå¿…è¦ã§ã™ã€‚ä»Šã™ãã‚¢ãƒƒãƒ—ã‚°ãƒ¬ãƒ¼ãƒ‰ã—ã¦ã€ã‚¹ãƒ ãƒ¼ã‚ºãªæ“ä½œæ„Ÿã‚’ä½“é¨“ã—ã¦ãã ã•ã„ï¼';

  @override
  String get fallbackInfoPanelText =>
      'ã‚µãƒ¼ãƒãƒ¼å´ã®æ”¹å–„ä½œæ¥­ã®ãŸã‚ã€ãŠå®¢æ§˜ãŒé¸æŠã•ã‚ŒãŸAIã§ã¯ãªãã€Cortexã®å‹•çš„ãƒãƒ£ãƒƒãƒˆæ©Ÿèƒ½ã«ã‚ˆã£ã¦å¿œç­”ãŒç”Ÿæˆã•ã‚Œã¾ã—ãŸã€‚å‡¦ç†ãŒå®Œäº†ã™ã‚‹ã¾ã§ã€ã”ç†è§£ã„ãŸã ã‘ã¾ã™ã‚ˆã†ãŠé¡˜ã„ç”³ã—ä¸Šã’ã¾ã™ã€‚';

  @override
  String get falOfflineMessage =>
      'ã‚µãƒ¼ãƒãƒ¼å´ã®æ”¹å–„ä½œæ¥­ã®ãŸã‚ã€ç¾åœ¨ã“ã®ã‚µãƒ¼ãƒ“ã‚¹ã¯ä¸€æ™‚çš„ã«ã”åˆ©ç”¨ã„ãŸã ã‘ã¾ã›ã‚“ã€‚ä½œæ¥­å®Œäº†ã¾ã§ã”ç†è§£ã„ãŸã ã‘ã¾ã™ã‚ˆã†ãŠé¡˜ã„ç”³ã—ä¸Šã’ã¾ã™ã€‚';

  @override
  String get errorInsufficientStorage =>
      'ã“ã®ãƒ¢ãƒ‡ãƒ«ã‚’ãƒ€ã‚¦ãƒ³ãƒ­ãƒ¼ãƒ‰ã™ã‚‹ã«ã¯ã‚¹ãƒˆãƒ¬ãƒ¼ã‚¸å®¹é‡ãŒä¸è¶³ã—ã¦ã„ã¾ã™ã€‚';

  @override
  String get backgroundChatNotificationTitle => 'ãƒãƒ£ãƒƒãƒˆã«æˆ»ã‚‹ï¼';

  @override
  String get benefitVideoGeneration => 'ãƒ“ãƒ‡ã‚ªç”Ÿæˆ';

  @override
  String get freeOffer => 'ç„¡æ–™ã‚ªãƒ•ã‚¡ãƒ¼';

  @override
  String trialMonthlyDescription(String days, String price) {
    return 'æœ€åˆã® $days æ—¥é–“ã¯ç„¡æ–™ã€ãã®å¾Œã¯ $price/æœˆ';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return 'æœ€åˆã® $days æ—¥é–“ã¯ç„¡æ–™ã€ãã®å¾Œã¯ $price/å¹´';
  }

  @override
  String freePlan(String plan) {
    return 'ç„¡æ–™ $planï¼';
  }

  @override
  String get systemPromptLimitFallback =>
      'é‡è¦ï¼šãƒ¦ãƒ¼ã‚¶ãƒ¼ãŒæ“ä½œã‚’è¦æ±‚ã—ã¾ã—ãŸãŒã€Cortexã®åˆ©ç”¨é™åº¦é¡ãŒä¸Šé™ã«é”ã—ã¦ã„ã¾ã™ã€‚ãƒ¦ãƒ¼ã‚¶ãƒ¼ã«ã¯ã€å¾…ã¤ã‹ã€ã‚µãƒ–ã‚¹ã‚¯ãƒªãƒ—ã‚·ãƒ§ãƒ³ãƒ—ãƒ©ãƒ³ã®ã‚¢ãƒƒãƒ—ã‚°ãƒ¬ãƒ¼ãƒ‰ã‚’æ¤œè¨ã™ã‚‹ã‚ˆã†ã€ãƒ¦ãƒ¼ã‚¶ãƒ¼ã®è¨€èªã§é€šçŸ¥ã—ã¦ãã ã•ã„ã€‚';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'Cortex ã¯ã•ã‚‰ã«å„ªã‚ŒãŸå›ç­”ã‚’æä¾›ã§ãã¾ã™ã€‚ä»Šã™ãã‚¢ãƒƒãƒ—ã‚°ãƒ¬ãƒ¼ãƒ‰ã—ã¦ã€ã™ã¹ã¦ã®è³ªå•ã«æœ€é«˜ã®ç­”ãˆã‚’å¾—ã¾ã—ã‚‡ã†ï¼';

  @override
  String get pinLimitReached =>
      'æœ€å¤§3ã¤ã®ãƒãƒ£ãƒƒãƒˆã‚’ãƒ”ãƒ³ç•™ã‚ã§ãã¾ã™ã€‚';

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
