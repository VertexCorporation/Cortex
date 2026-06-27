// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'Ø£Ù†Øª Ù…Ø³Ø¤ÙˆÙ„ Ø¹Ù† Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„Ø¹Ù†Ø§ÙˆÙŠÙ†. ÙŠÙØ±Ø¬Ù‰ Ø§Ù„Ø±Ø¯ Ø¨Ø¹Ù†ÙˆØ§Ù† Ù…Ù† ÙƒÙ„Ù…ØªÙŠÙ† Ø¥Ù„Ù‰ Ø®Ù…Ø³ ÙƒÙ„Ù…Ø§Øª ÙÙ‚Ø· Ù„Ù„Ù…Ø­Ø§Ø¯Ø«Ø© Ø§Ù„ØªØ§Ù„ÙŠØ©. Ù„Ø§ ØªØ³ØªØ®Ø¯Ù… Ø¹Ù„Ø§Ù…Ø§Øª Ø§Ù„Ø§Ù‚ØªØ¨Ø§Ø³ Ø£Ùˆ Ø§Ù„Ø¨Ø§Ø¯Ø¦Ø§Øª Ø£Ùˆ Ø¹Ù„Ø§Ù…Ø§Øª Ø§Ù„ØªØ±Ù‚ÙŠÙ…. Ù‡Ø§Ù…: ÙŠØ¬Ø¨ Ø£Ù† ÙŠÙƒÙˆÙ† Ø§Ù„Ø¹Ù†ÙˆØ§Ù† Ø¨Ù†ÙØ³ Ù„ØºØ© Ø±Ø³Ø§Ù„Ø© Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… ØªÙ…Ø§Ù…Ù‹Ø§.';

  @override
  String get systemRoleFallback => 'Ø£Ù†Øª Ù…Ø³Ø§Ø¹Ø¯ Ù…ÙÙŠØ¯.';

  @override
  String get systemLanguageInstruction =>
      '\n\nCRITICAL: ÙŠØ¬Ø¨ Ø¯Ø§Ø¦Ù…Ù‹Ø§ Ø§Ù„Ø±Ø¯ Ø¨Ù†ÙØ³ Ø§Ù„Ù„ØºØ© Ø§Ù„ØªÙŠ ÙŠÙƒØªØ¨ Ø¨Ù‡Ø§ Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…ØŒ Ø§Ù†ØªØ¨Ù‡ Ø¥Ù„Ù‰ Ù„ØºØ© Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù….';

  @override
  String get systemNotePreviousMedia =>
      '[Ù…Ù„Ø§Ø­Ø¸Ø© Ø§Ù„Ù†Ø¸Ø§Ù…: Ø£Ø¯Ù†Ø§Ù‡ Ù‡ÙŠ Ø§Ù„ÙˆØ³Ø§Ø¦Ø· Ø§Ù„ØªÙŠ ØªÙ… Ø¥Ù†Ø´Ø§Ø¤Ù‡Ø§ Ù…Ø³Ø¨Ù‚Ù‹Ø§. ÙŠÙ…ÙƒÙ†Ùƒ Ø§Ù„Ø¥Ø´Ø§Ø±Ø© Ø¥Ù„ÙŠÙ‡Ø§ Ø£Ùˆ ØªØ¹Ø¯ÙŠÙ„Ù‡Ø§.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return '\n\nØ§Ù„ØªØ§Ø±ÙŠØ® ÙˆØ§Ù„ÙˆÙ‚Øª Ø§Ù„Ø­Ø§Ù„ÙŠ: $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\nØ­Ù„Ù„ Ø§Ù„Ù…Ø­Ø§Ø¯Ø«Ø© Ø­ØªÙ‰ Ø§Ù„Ø¢Ù†. Ø¥Ø°Ø§ ØªØ¹Ù„Ù…Øª Ø£ÙŠ Ø­Ù‚Ø§Ø¦Ù‚ Ø¬Ø¯ÙŠØ¯Ø© ÙˆÙ…Ù…ÙŠØ²Ø© Ø¹Ù† Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… (ØªÙØ¶ÙŠÙ„Ø§ØªØŒ Ø§Ø³Ù…ØŒ Ø¹Ø§Ø¯Ø§ØªØŒ Ø³ÙŠØ§Ù‚)ØŒ ÙÙŠØ¬Ø¨ Ø¹Ù„ÙŠÙƒ Ø¥Ø®Ø±Ø§Ø¬ Ø°Ø§ÙƒØ±ØªÙƒ Ø§Ù„Ù…Ø­Ø¯Ø«Ø© Ø¨Ø§Ù„ÙƒØ§Ù…Ù„ Ø¹Ù† Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… Ø¯Ø§Ø®Ù„ Ø¹Ù„Ø§Ù…Ø§Øª <memory>...</memory> ÙÙŠ Ù†Ù‡Ø§ÙŠØ© Ø±Ø¯Ùƒ. Ù‡Ø§Ù…: Ù„Ø§ ØªÙ‚Ù… Ø£Ø¨Ø¯Ù‹Ø§ Ø¨Ù…Ø³Ø­ Ø£Ùˆ Ø§Ø³ØªØ¨Ø¯Ø§Ù„ Ø§Ù„Ø°Ø§ÙƒØ±Ø© Ø§Ù„Ø³Ø§Ø¨Ù‚Ø©. Ø£Ø¶Ù Ø¯Ø§Ø¦Ù…Ù‹Ø§ Ø§Ù„Ø­Ù‚Ø§Ø¦Ù‚ Ø§Ù„Ø¬Ø¯ÙŠØ¯Ø© Ø¥Ù„Ù‰ Ø§Ù„Ø°Ø§ÙƒØ±Ø© Ø§Ù„Ù…ÙˆØ¬ÙˆØ¯Ø©. Ø¥Ø°Ø§ Ù„Ù… ÙŠØªÙ… ØªØ¹Ù„Ù… Ø£ÙŠ Ø´ÙŠØ¡ Ø¬Ø¯ÙŠØ¯ Ø¹Ù„Ù‰ Ø§Ù„Ø¥Ø·Ù„Ø§Ù‚ØŒ ÙØ§Ø­Ø°Ù Ø§Ù„Ø¹Ù„Ø§Ù…Ø©. Ù…Ø«Ø§Ù„: <memory>ÙŠØ­Ø¨ ÙƒØ±Ø© Ø§Ù„Ù‚Ø¯Ù… ÙˆØ§Ù„ØªÙ†Ø³. ÙŠÙØ¶Ù„ Ø§Ù„Ø¥Ø¬Ø§Ø¨Ø§Øª Ø§Ù„Ù‚ØµÙŠØ±Ø©.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return '\n\nØªØ°ÙƒØ± Ø¯Ø§Ø¦Ù…Ù‹Ø§ Ù‡Ø°Ø§ Ø¹Ù† Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…:\n$userMemory';
  }

  @override
  String get cancel => 'Ø¥Ù„ØºØ§Ø¡';

  @override
  String get remove => 'ÙŠØ²ÙŠÙ„';

  @override
  String get download => 'ØªÙ†Ø²ÙŠÙ„';

  @override
  String get resume => 'Ø§Ø³ØªØ¦Ù†Ø§Ù';

  @override
  String get copy => 'Ù†Ø³Ø®';

  @override
  String get chat => 'Ù…Ø­Ø§Ø¯Ø«Ø©';

  @override
  String get locked => 'Locked';

  @override
  String get languageModels => 'Ù†Ù…Ø§Ø°Ø¬ Ø§Ù„Ù„ØºØ©';

  @override
  String get light => 'ÙØ§ØªØ­';

  @override
  String get theme => 'Ø§Ù„Ø³Ù…Ø©';

  @override
  String get no => 'Ù„Ø§';

  @override
  String get yes => 'Ù†Ø¹Ù…';

  @override
  String get done => 'ØªÙ…';

  @override
  String get bestValue => 'Ø£ÙØ¶Ù„ Ù‚ÙŠÙ…Ø©';

  @override
  String get selected => 'Ù…Ø­Ø¯Ø¯';

  @override
  String get descriptionSection => 'Ø§Ù„ÙˆØµÙ';

  @override
  String get searchHint => 'Ø¨Ø­Ø«';

  @override
  String get messageHint => 'Ø§Ø³Ø£Ù„ Ø£ÙŠ Ø´ÙŠØ¡';

  @override
  String get messageCopied =>
      'ØªÙ… Ù†Ø³Ø® Ø§Ù„Ø±Ø³Ø§Ù„Ø© Ø¥Ù„Ù‰ Ø§Ù„Ø­Ø§ÙØ¸Ø©.';

  @override
  String get retry => 'Ø¥Ø¹Ø§Ø¯Ø© Ø§Ù„Ù…Ø­Ø§ÙˆÙ„Ø©';

  @override
  String get systemInfo => 'Ù…Ø¹Ù„ÙˆÙ…Ø§Øª Ø§Ù„Ù†Ø¸Ø§Ù…';

  @override
  String deviceMemory(Object memory) {
    return 'Ø°Ø§ÙƒØ±Ø© Ø§Ù„Ø¬Ù‡Ø§Ø²: $memory Ø¬ÙŠØ¬Ø§Ø¨Ø§ÙŠØª';
  }

  @override
  String get memory => 'Ø§Ù„Ø°Ø§ÙƒØ±Ø©';

  @override
  String get storage => 'Ø§Ù„ØªØ®Ø²ÙŠÙ†';

  @override
  String get freeStorage => 'Ø§Ù„ØªØ®Ø²ÙŠÙ† Ø§Ù„Ø­Ø±';

  @override
  String get totalStorage => 'Ø¥Ø¬Ù…Ø§Ù„ÙŠ Ø§Ù„ØªØ®Ø²ÙŠÙ†';

  @override
  String get usedStorage => 'Ø§Ù„ØªØ®Ø²ÙŠÙ† Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…';

  @override
  String get totalMemory => 'Ø¥Ø¬Ù…Ø§Ù„ÙŠ Ø§Ù„Ø°Ø§ÙƒØ±Ø©';

  @override
  String get usedMemory => 'Ø§Ù„Ø°Ø§ÙƒØ±Ø© Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…Ø©';

  @override
  String get modelsTitle => 'Ø§Ù„Ù…ÙƒØªØ¨Ø©';

  @override
  String get localModels => 'Ø§Ù„Ù†Ù…Ø§Ø°Ø¬ Ø§Ù„Ù…Ø­Ù„ÙŠØ©';

  @override
  String get selectGGUFFile => 'Ø­Ø¯Ø¯ Ù…Ù„Ù GGUF';

  @override
  String get errorGGUF => 'ÙŠØ±Ø¬Ù‰ ØªØ­Ø¯ÙŠØ¯ Ù…Ù„Ù Ø¨ØµÙŠØºØ© GGUF ÙÙ‚Ø·.';

  @override
  String get myModels => 'Ù†Ù…Ø§Ø°Ø¬ÙŠ';

  @override
  String get create => 'Ø¥Ù†Ø´Ø§Ø¡';

  @override
  String modelProducer(Object producer) {
    return 'Ø§Ù„Ù…Ù†ØªØ¬: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'Ø¥Ø¹Ø§Ø¯Ø© ØªØ³Ù…ÙŠØ©';

  @override
  String get newTitle => 'Ø¹Ù†ÙˆØ§Ù† Ø¬Ø¯ÙŠØ¯';

  @override
  String get save => 'Ø­ÙØ¸';

  @override
  String get noConversationsMessage =>
      'Ù„Ø§ ØªÙˆØ¬Ø¯ Ù…Ø­Ø§Ø¯Ø«Ø§ØªØŒ Ø§Ø¨Ø¯Ø£ Ø§Ù„Ø¯Ø±Ø¯Ø´Ø©!';

  @override
  String get startChat => 'Ø§Ø¨Ø¯Ø£ Ù…Ø­Ø§Ø¯Ø«Ø©';

  @override
  String get noChats => 'Ù„Ø§ ØªÙˆØ¬Ø¯ Ù…Ø­Ø§Ø¯Ø«Ø§Øª';

  @override
  String get noStarredChats =>
      'Ù„Ø§ ØªÙˆØ¬Ø¯ Ù…Ø­Ø§Ø¯Ø«Ø§Øª Ù…Ù…ÙŠØ²Ø© Ø¨Ù†Ø¬Ù…Ø©';

  @override
  String get noStarredChatsMessage =>
      'Ù„Ù… ØªÙ‚Ù… Ø¨ØªÙ…ÙŠÙŠØ² Ø£ÙŠ Ù…Ø­Ø§Ø¯Ø«Ø© Ø¨Ù†Ø¬Ù…Ø© Ø¨Ø¹Ø¯.';

  @override
  String get starConversation => 'ØªÙ…ÙŠÙŠØ² Ø¨Ù†Ø¬Ù…Ø©';

  @override
  String get unstarConversation => 'Ø£Ù†Ø³ØªØ§Ø±';

  @override
  String get loginToYourAccount => 'ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø¯Ø®ÙˆÙ„';

  @override
  String get createYourAccount => 'Ø¥Ù†Ø´Ø§Ø¡ Ø­Ø³Ø§Ø¨';

  @override
  String get email => 'Ø§Ù„Ø¨Ø±ÙŠØ¯ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ';

  @override
  String get password => 'ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±';

  @override
  String get confirmPassword => 'ØªØ£ÙƒÙŠØ¯ ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±';

  @override
  String get invalidEmail =>
      'ÙŠØ±Ø¬Ù‰ Ø¥Ø¯Ø®Ø§Ù„ Ø¹Ù†ÙˆØ§Ù† Ø¨Ø±ÙŠØ¯ Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ ØµØ§Ù„Ø­.';

  @override
  String get invalidPassword =>
      'ÙŠØ¬Ø¨ Ø£Ù† ØªØªÙƒÙˆÙ† ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ± Ù…Ù† 6 Ø£Ø­Ø±Ù Ø¹Ù„Ù‰ Ø§Ù„Ø£Ù‚Ù„.';

  @override
  String get rememberMe => 'ØªØ°ÙƒØ±Ù†ÙŠ';

  @override
  String get forgotPassword => 'Ù‡Ù„ Ù†Ø³ÙŠØª ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±ØŸ';

  @override
  String get or => 'Ø£Ùˆ';

  @override
  String get continueWithGoogle => 'Ø§Ù„Ù…ØªØ§Ø¨Ø¹Ø© Ø¨Ø§Ø³ØªØ®Ø¯Ø§Ù… Ø¬ÙˆØ¬Ù„';

  @override
  String get dontHaveAccount => 'Ù„ÙŠØ³ Ù„Ø¯ÙŠÙƒ Ø­Ø³Ø§Ø¨ØŸ';

  @override
  String get alreadyHaveAccount => 'Ù„Ø¯ÙŠÙƒ Ø­Ø³Ø§Ø¨ Ø¨Ø§Ù„ÙØ¹Ù„ØŸ';

  @override
  String get signUp => 'Ø¥Ù†Ø´Ø§Ø¡ Ø­Ø³Ø§Ø¨';

  @override
  String get logIn => 'ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø¯Ø®ÙˆÙ„';

  @override
  String get passwordsDoNotMatch =>
      'ÙƒÙ„Ù…Ø§Øª Ø§Ù„Ù…Ø±ÙˆØ± ØºÙŠØ± Ù…ØªØ·Ø§Ø¨Ù‚Ø©.';

  @override
  String get wrongPassword => 'ÙƒÙ„Ù…Ø© Ù…Ø±ÙˆØ± ØºÙŠØ± ØµØ­ÙŠØ­Ø©.';

  @override
  String get emailAlreadyInUse =>
      'Ù‡Ø°Ø§ Ø§Ù„Ø¨Ø±ÙŠØ¯ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ Ù…Ø³ØªØ®Ø¯Ù… Ø¨Ø§Ù„ÙØ¹Ù„.';

  @override
  String get weakPassword => 'ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ± Ø¶Ø¹ÙŠÙØ© Ø¬Ø¯Ù‹Ø§.';

  @override
  String get authError => 'Ø®Ø·Ø£ ÙÙŠ Ø§Ù„Ù…ØµØ§Ø¯Ù‚Ø©';

  @override
  String get usernameTaken =>
      'Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… Ù‡Ø°Ø§ Ù…Ø£Ø®ÙˆØ° Ø¨Ø§Ù„ÙØ¹Ù„.';

  @override
  String get username => 'Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…';

  @override
  String get resendCode => 'Ø¥Ø¹Ø§Ø¯Ø© Ø¥Ø±Ø³Ø§Ù„ Ø¨Ø±ÙŠØ¯ Ø§Ù„ØªØ­Ù‚Ù‚';

  @override
  String get pleaseCheckYourEmail =>
      'Ù„Ø§Ø³ØªØ®Ø¯Ø§Ù… CortexØŒ ØªØ­ØªØ§Ø¬ Ø¥Ù„Ù‰ Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø¨Ø±ÙŠØ¯Ùƒ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ. \nØªÙ… Ø¥Ø±Ø³Ø§Ù„ Ø±Ø§Ø¨Ø· ØªØ­Ù‚Ù‚ Ø¥Ù„Ù‰ Ø¹Ù†ÙˆØ§Ù† Ø¨Ø±ÙŠØ¯Ùƒ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠØŒ ÙŠØ±Ø¬Ù‰ Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø¨Ø±ÙŠØ¯Ùƒ.';

  @override
  String get verifyYourEmail => 'ØªØ­Ù‚Ù‚ Ù…Ù† Ø¨Ø±ÙŠØ¯Ùƒ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ';

  @override
  String get seconds => 'Ø«ÙˆØ§Ù†ÙŠ';

  @override
  String get maxResendLimitReached =>
      'Ù„Ù‚Ø¯ ÙˆØµÙ„Øª Ø¥Ù„Ù‰ Ø§Ù„Ø­Ø¯ Ø§Ù„Ø£Ù‚ØµÙ‰ Ù„Ø±Ø³Ø§Ø¦Ù„ Ø§Ù„ØªØ­Ù‚Ù‚';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Ø§Ù„Ù…ØªØ§Ø¨Ø¹Ø© Ø¨Ø¯ÙˆÙ† ØªØ­Ù‚Ù‚';

  @override
  String get verificationScreenWarning =>
      'Ø­ØªÙ‰ Ù„Ùˆ ØªØ§Ø¨Ø¹ØªØŒ ÙØ¥Ù† ÙØªØ±Ø© Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø§Ù„Ø­Ø³Ø§Ø¨ Ø§Ù„Ø¨Ø§Ù„ØºØ© ÙŠÙˆÙ… ÙˆØ§Ø­Ø¯ Ù„Ø§ ØªØ²Ø§Ù„ Ø³Ø§Ø±ÙŠØ© Ø¹Ù„Ù‰ Ø­Ø³Ø§Ø¨Ùƒ. Ø¥Ø°Ø§ Ù„Ù… ØªÙ‚Ù… Ø¨Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø­Ø³Ø§Ø¨Ùƒ Ø¨Ø­Ù„ÙˆÙ„ Ø°Ù„Ùƒ Ø§Ù„ÙˆÙ‚ØªØŒ ÙØ³ÙŠØªÙ… Ø­Ø°ÙÙ‡ Ù…Ù† Ø§Ù„ØªØ·Ø¨ÙŠÙ‚.';

  @override
  String get unverifiedAccountHeader => 'Ø­Ø³Ø§Ø¨Ùƒ ØºÙŠØ± Ù…ÙˆØ«Ù‚';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Ø¥Ø°Ø§ Ù„Ù… ØªÙ‚Ù… Ø¨ØªÙˆØ«ÙŠÙ‚ Ø­Ø³Ø§Ø¨Ùƒ Ø®Ù„Ø§Ù„ $timeLeftØŒ ÙØ³ÙŠØªÙ… Ø­Ø°ÙÙ‡';
  }

  @override
  String get verifyNow => 'ÙˆØ«Ù‘Ù‚ Ø§Ù„Ø¢Ù†';

  @override
  String get linkSent => 'ØªÙ… Ø¥Ø±Ø³Ø§Ù„ Ø§Ù„Ø±Ø§Ø¨Ø·';

  @override
  String get accountDeletionRequested =>
      'ØªÙ… Ø§Ø³ØªÙ„Ø§Ù… Ø·Ù„Ø¨ Ø­Ø°Ù Ø­Ø³Ø§Ø¨Ùƒ ÙˆØ­Ø³Ø§Ø¨Ùƒ Ù…Ø¹Ø·Ù„ Ø§Ù„Ø¢Ù†.';

  @override
  String get tooManyRequests => 'Ø·Ù„Ø¨Ø§Øª ÙƒØ«ÙŠØ±Ø© Ø¬Ø¯Ù‹Ø§';

  @override
  String get regenerate => 'Ø¥Ø¹Ø§Ø¯Ø© Ø¥Ù†Ø´Ø§Ø¡';

  @override
  String get confirmDeleteAccount =>
      'Ù‡Ù„ Ø£Ù†Øª Ù…ØªØ£ÙƒØ¯ Ø£Ù†Ùƒ ØªØ±ÙŠØ¯ Ø­Ø°Ù Ø­Ø³Ø§Ø¨ÙƒØŸ';

  @override
  String get deleteAccount => 'Ø­Ø°Ù Ø§Ù„Ø­Ø³Ø§Ø¨';

  @override
  String get delete => 'Ø­Ø°Ù';

  @override
  String get passwordRequired => 'ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ± Ù…Ø·Ù„ÙˆØ¨Ø©.';

  @override
  String get deleteDescription =>
      'Ø³ÙŠØªÙ… Ø­Ø°Ù Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„ØªÙŠ ØªØ­Ø°ÙÙ‡Ø§ Ø¨Ø´ÙƒÙ„ Ø¯Ø§Ø¦Ù… Ù…Ù† Ø®Ø§Ø¯Ù…Ù†Ø§ ÙˆØ¬Ù‡Ø§Ø²Ùƒ. Ù„Ø§ ÙŠÙ…ÙƒÙ† Ø§Ù„ØªØ±Ø§Ø¬Ø¹ Ø¹Ù† Ù‡Ø°Ø§ Ø§Ù„Ø¥Ø¬Ø±Ø§Ø¡.';

  @override
  String get editProfile => 'ØªØ¹Ø¯ÙŠÙ„ Ø§Ù„Ù…Ù„Ù Ø§Ù„Ø´Ø®ØµÙŠ';

  @override
  String get displayName => 'Ø§Ø³Ù… Ø§Ù„Ø¹Ø±Ø¶';

  @override
  String get profileUpdated =>
      'ØªÙ… ØªØ­Ø¯ÙŠØ« Ø§Ù„Ù…Ù„Ù Ø§Ù„Ø´Ø®ØµÙŠ Ø¨Ù†Ø¬Ø§Ø­';

  @override
  String get logout => 'ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø®Ø±ÙˆØ¬';

  @override
  String get profile => 'Ø§Ù„Ù…Ù„Ù Ø§Ù„Ø´Ø®ØµÙŠ';

  @override
  String get manageProfileDescription =>
      'Ù‚Ù… Ø¨Ø¥Ø¯Ø§Ø±Ø© Ù…Ù„ÙÙƒ Ø§Ù„Ø´Ø®ØµÙŠØŒ Ø£Ùˆ ØªØ­Ø¯ÙŠØ« ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±ØŒ Ø£Ùˆ ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø®Ø±ÙˆØ¬ Ù…Ù† Cortex.';

  @override
  String get accessSettingsDescription =>
      'Ø§Ø­ØµÙ„ Ø¹Ù„Ù‰ Ø§Ù„Ù…Ø³Ø§Ø¹Ø¯Ø©ØŒ ÙˆØ§Ø³ØªØ±Ø¯Ø§Ø¯ Ø§Ù„Ø±Ù…ÙˆØ²ØŒ ÙˆÙ…Ø´Ø§Ø±ÙƒØ© CortexØŒ ÙˆØ§Ø·Ù„Ø¹ Ø¹Ù„Ù‰ Ø³ÙŠØ§Ø³Ø§ØªÙ†Ø§.';

  @override
  String get languageDescription =>
      'ÙŠÙ…ÙƒÙ†Ùƒ ØªØºÙŠÙŠØ± Ù„ØºØ© ÙˆØ§Ø¬Ù‡Ø© Ø§Ù„ØªØ·Ø¨ÙŠÙ‚ Ø§Ù„Ø§ÙØªØ±Ø§Ø¶ÙŠØ© ÙÙŠ Ø£ÙŠ ÙˆÙ‚Øª.';

  @override
  String get themeDescription =>
      'ÙŠÙ…ÙƒÙ†Ùƒ Ø§Ù„ØªØ¨Ø¯ÙŠÙ„ Ø¨ÙŠÙ† Ø§Ù„Ø³Ù…Ø§Øª Ø§Ù„ÙØ§ØªØ­Ø© ÙˆØ§Ù„Ø¯Ø§ÙƒÙ†Ø© Ø­Ø³Ø¨ ØªÙØ¶ÙŠÙ„Ùƒ. Ø³ÙŠØªÙ… ØªØ·Ø¨ÙŠÙ‚ Ø§Ù„Ø³Ù…Ø© Ø§Ù„Ù…Ø­Ø¯Ø¯Ø© Ø¹Ø¨Ø± ÙˆØ§Ø¬Ù‡Ø© Cortex.';

  @override
  String get iHaveReadAndAgree =>
      'Ù„Ù‚Ø¯ Ù‚Ø±Ø£Øª ÙˆÙˆØ§ÙÙ‚Øª Ø¹Ù„Ù‰ Ø´Ø±ÙˆØ· Ø§Ù„Ø®Ø¯Ù…Ø©';

  @override
  String get downloading => 'Ø¬Ø§Ø±ÙŠ Ø§Ù„ØªÙ†Ø²ÙŠÙ„...';

  @override
  String get downloadSuccess => 'Ù†Ø¬Ø­ Ø§Ù„ØªÙ†Ø²ÙŠÙ„';

  @override
  String get downloadFailed => 'ÙØ´Ù„ Ø§Ù„ØªÙ†Ø²ÙŠÙ„';

  @override
  String downloaded(Object percent) {
    return 'ØªÙ… ØªÙ†Ø²ÙŠÙ„ $percent%';
  }

  @override
  String get downloadPaused => 'ØªÙˆÙ‚Ù Ø§Ù„ØªÙ†Ø²ÙŠÙ„ Ù…Ø¤Ù‚ØªÙ‹Ø§.';

  @override
  String get purchaseError => 'Ø®Ø·Ø£ ÙÙŠ Ø§Ù„Ø´Ø±Ø§Ø¡';

  @override
  String get purchasePlus => 'Ø§Ø´ØªØ±Ù Cortex Plus';

  @override
  String get plusDescription =>
      'ØªØ¬Ø±Ø¨Ø© Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ø§Ù„Ù…ØªÙ…ÙŠØ²Ø©';

  @override
  String get annual => 'Ø³Ù†ÙˆÙŠ';

  @override
  String get monthly => 'Ø´Ù‡Ø±ÙŠ';

  @override
  String get manageSubscription => 'Ø¥Ø¯Ø§Ø±Ø© Ø§Ù„Ø§Ø´ØªØ±Ø§Ùƒ';

  @override
  String purchasePlan(String planName) {
    return 'Ø´Ø±Ø§Ø¡ $planName';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/Ø´Ù‡Ø±ÙŠÙ‹Ø§ØŒ ÙŠØªÙ… Ø¯ÙØ¹ Ø§Ù„ÙØ§ØªÙˆØ±Ø© Ø´Ù‡Ø±ÙŠÙ‹Ø§';
  }

  @override
  String get purchasePro => 'Ø§Ø´ØªØ±Ù Cortex Pro';

  @override
  String get proDescription => 'ØªØ¬Ø±Ø¨Ø© Ø°ÙƒØ§Ø¡ Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ø±Ø§Ù‚ÙŠØ©';

  @override
  String get purchaseUltra => 'Ø§Ø´ØªØ±Ù Cortex Ultra';

  @override
  String get ultraDescription => 'Ø°Ø±ÙˆØ© Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ';

  @override
  String get upgradeSubscription => 'ØªØ±Ù‚ÙŠØ© Ø§Ù„Ø§Ø´ØªØ±Ø§Ùƒ';

  @override
  String get purchaseStreamError => 'Ø®Ø·Ø£ ÙÙŠ ØªØ¯ÙÙ‚ Ø§Ù„Ø´Ø±Ø§Ø¡.';

  @override
  String get productNotFound => 'Ø§Ù„Ù…Ù†ØªØ¬ ØºÙŠØ± Ù…ÙˆØ¬ÙˆØ¯';

  @override
  String get noProductsFound => 'Ù„Ù… ÙŠØªÙ… Ø§Ù„Ø¹Ø«ÙˆØ± Ø¹Ù„Ù‰ Ù…Ù†ØªØ¬Ø§Øª';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Ø¨Ø¥ØªÙ…Ø§Ù… Ù‡Ø°Ø§ Ø§Ù„Ø·Ù„Ø¨ØŒ ÙØ¥Ù†Ùƒ ØªÙˆØ§ÙÙ‚ Ø¹Ù„Ù‰ Ø´Ø±ÙˆØ· Ø§Ù„Ø®Ø¯Ù…Ø© ÙˆØ³ÙŠØ§Ø³Ø© Ø§Ù„Ø®ØµÙˆØµÙŠØ©. ÙŠÙ…ÙƒÙ†Ùƒ Ø§Ù„Ù†Ù‚Ø± Ø¹Ù„Ù‰ Ù‡Ø°Ø§ Ø§Ù„Ù†Øµ Ù„Ù…Ø¹Ø±ÙØ© Ø§Ù„Ù…Ø²ÙŠØ¯ Ø¹Ù† Ø´Ø±ÙˆØ· Ø§Ù„Ø®Ø¯Ù…Ø© ÙˆØ³ÙŠØ§Ø³Ø© Ø§Ù„Ø®ØµÙˆØµÙŠØ©. Ø³ÙŠØªÙ… ØªØ¬Ø¯ÙŠØ¯ Ø§Ù„Ø§Ø´ØªØ±Ø§Ùƒ ØªÙ„Ù‚Ø§Ø¦ÙŠÙ‹Ø§ Ù…Ø§ Ù„Ù… ÙŠØªÙ… Ø¥ÙŠÙ‚Ø§Ù Ø§Ù„ØªØ¬Ø¯ÙŠØ¯ Ø§Ù„ØªÙ„Ù‚Ø§Ø¦ÙŠ Ù‚Ø¨Ù„ 24 Ø³Ø§Ø¹Ø© Ø¹Ù„Ù‰ Ø§Ù„Ø£Ù‚Ù„ Ù…Ù† Ù†Ù‡Ø§ÙŠØ© Ø§Ù„ÙØªØ±Ø© Ø§Ù„Ø­Ø§Ù„ÙŠØ©.';

  @override
  String get termsOfService => 'Ø´Ø±ÙˆØ· Ø§Ù„Ø®Ø¯Ù…Ø©';

  @override
  String get privacyPolicy => 'Ø³ÙŠØ§Ø³Ø© Ø§Ù„Ø®ØµÙˆØµÙŠØ©';

  @override
  String get renamed => 'ØªÙ…Øª Ø¥Ø¹Ø§Ø¯Ø© ØªØ³Ù…ÙŠØªÙ‡';

  @override
  String get report => 'Ø¥Ø¨Ù„Ø§Øº';

  @override
  String get reportDialogTitle => 'ØªÙ‚Ø¯ÙŠÙ… Ø¨Ù„Ø§Øº';

  @override
  String get reportDescriptionLabel => 'Ù…Ø§ Ù‡ÙŠ Ø§Ù„Ù…Ø´ÙƒÙ„Ø©ØŸ';

  @override
  String get reportHarmful => 'Ù‡Ø°Ø§ Ø¶Ø§Ø±/ØºÙŠØ± Ø¢Ù…Ù†';

  @override
  String get reportNotTrue => 'Ù‡Ø°Ø§ ØºÙŠØ± ØµØ­ÙŠØ­';

  @override
  String get reportNotHelpful => 'Ù‡Ø°Ø§ ØºÙŠØ± Ù…ÙÙŠØ¯';

  @override
  String get closeButton => 'Ø¥ØºÙ„Ø§Ù‚';

  @override
  String get submitButton => 'Ø¥Ø±Ø³Ø§Ù„';

  @override
  String get reportErrorMessage =>
      'ÙŠØ±Ø¬Ù‰ ØªØ­Ø¯ÙŠØ¯ Ø³Ø¨Ø¨ ÙˆØ§Ø­Ø¯ Ù„Ù„Ø¥Ø¨Ù„Ø§Øº.';

  @override
  String get capabilitiesSection => 'Ø§Ù„Ù‚Ø¯Ø±Ø§Øª';

  @override
  String get featurePhotoTitle => 'Ù…Ø³Ø­ Ø§Ù„ØµÙˆØ±';

  @override
  String get featurePhotoDescription =>
      'Ù‡Ø°Ø§ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ Ù„Ø¯ÙŠÙ‡ Ø§Ù„Ù‚Ø¯Ø±Ø© Ø¹Ù„Ù‰ Ù…Ø³Ø­ Ø§Ù„ØµÙˆØ± Ù…Ù† Ø®Ù„Ø§Ù„ Ø§Ù„ÙƒØ§Ù…ÙŠØ±Ø§ Ø£Ùˆ Ù…Ù„ÙØ§Øª Ø§Ù„ØµÙˆØ±.';

  @override
  String get featureOfflineTitle => 'Ø§Ù„ØªØ´ØºÙŠÙ„ Ø¨Ø¯ÙˆÙ† Ø§Ù†ØªØ±Ù†Øª';

  @override
  String get featureOfflineDescription =>
      'Ù‚Ù… Ø¨ØªØ´ØºÙŠÙ„ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ Ø¨Ø¯ÙˆÙ† Ø§ØªØµØ§Ù„ Ø¨Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª Ù„Ù„Ø­ÙØ§Ø¸ Ø¹Ù„Ù‰ Ø£Ù…Ø§Ù† Ø¨ÙŠØ§Ù†Ø§ØªÙƒ.';

  @override
  String get featureRoleplayTitle => 'Ù„Ø¹Ø¨ Ø§Ù„Ø£Ø¯ÙˆØ§Ø±';

  @override
  String get featureRoleplayDescription =>
      'ØªØ³Ù…Ø­ Ù„Ùƒ Ù†Ù…Ø§Ø°Ø¬ Ù„Ø¹Ø¨ Ø§Ù„Ø£Ø¯ÙˆØ§Ø± Ø¨Ø¥Ù†Ø´Ø§Ø¡ Ù…Ø­Ø§Ø¯Ø«Ø§Øª ÙˆØ³ÙŠÙ†Ø§Ø±ÙŠÙˆÙ‡Ø§Øª Ù…ØªÙ†ÙˆØ¹Ø©.';

  @override
  String get roleModels => 'Ù†Ù…Ø§Ø°Ø¬ Ù„Ø¹Ø¨ Ø§Ù„Ø£Ø¯ÙˆØ§Ø±';

  @override
  String get parameters => 'Ø§Ù„Ù…Ø¹Ù„Ù…Ø§Øª';

  @override
  String get context => 'Ø§Ù„Ø³ÙŠØ§Ù‚';

  @override
  String get finalPreparation =>
      'Ø§Ù„ØªØ­Ø¶ÙŠØ±Ø§Øª Ø§Ù„Ù†Ù‡Ø§Ø¦ÙŠØ© Ø¬Ø§Ø±ÙŠØ©.';

  @override
  String get shareApp => 'Ù…Ø´Ø§Ø±ÙƒØ© Ø§Ù„ØªØ·Ø¨ÙŠÙ‚';

  @override
  String get ourStory => 'Ù‚ØµØªÙ†Ø§';

  @override
  String get rateUs => 'Ù‚ÙŠÙ‘Ù…Ù†Ø§';

  @override
  String get share => 'Ù…Ø´Ø§Ø±ÙƒØ©';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'ØªØ­Ø¯ÙŠØ¯ Ù†Øµ';

  @override
  String get thinking => 'ÙŠÙÙƒØ±';

  @override
  String get user => 'Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…';

  @override
  String get help => 'Ù…Ø³Ø§Ø¹Ø¯Ø©';

  @override
  String get supportCreator => 'Ø§Ø¯Ø¹Ù… Ø§Ù„Ù…Ø¨Ø¯Ø¹';

  @override
  String get enterYourTag =>
      'Ø§Ø¯Ø¹Ù… Ù…ÙÙ†Ø´Ø¦ÙŠÙƒ Ø§Ù„Ù…ÙÙØ¶Ù‘Ù„ÙŠÙ†! Ø£Ø¯Ø®Ù„ Ø¹Ù„Ø§Ù…ØªÙ‡Ù… Ø§Ù„ÙØ±ÙŠØ¯Ø© Ø£Ø¯Ù†Ø§Ù‡ Ù„ØªÙØ´Ø§Ø±ÙƒÙ‡Ù… Ù…Ø´ØªØ±ÙŠØ§ØªÙƒ Ù…Ù† Cortex.';

  @override
  String get creatorTag => 'Ø¹Ù„Ø§Ù…Ø© Ø§Ù„Ù…Ù†Ø´Ø¦';

  @override
  String get support => 'ÙŠØ¯Ø¹Ù…';

  @override
  String get tagCannotBeEmpty =>
      'Ù„Ø§ ÙŠÙ…ÙƒÙ† Ø£Ù† ØªÙƒÙˆÙ† Ø¹Ù„Ø§Ù…Ø© Ø§Ù„Ù…Ù†Ø´Ø¦ ÙØ§Ø±ØºØ©';

  @override
  String get userId => 'Ù…Ø¹Ø±Ù Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…';

  @override
  String get deleteAllConversationsConfirmTitle =>
      'Ø­Ø°Ù Ø¬Ù…ÙŠØ¹ Ø§Ù„Ù…Ø­Ø§Ø¯Ø«Ø§ØªØŸ';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Ù‡Ù„ Ø£Ù†Øª Ù…ØªØ£ÙƒØ¯ Ø£Ù†Ùƒ ØªØ±ÙŠØ¯ Ø­Ø°Ù Ø¬Ù…ÙŠØ¹ Ù…Ø­Ø§Ø¯Ø«Ø§ØªÙƒØŸ Ù„Ø§ ÙŠÙ…ÙƒÙ† Ø§Ù„ØªØ±Ø§Ø¬Ø¹ Ø¹Ù† Ù‡Ø°Ø§ Ø§Ù„Ø¥Ø¬Ø±Ø§Ø¡.';

  @override
  String get conversationDeleted => 'ØªÙ… Ø­Ø°Ù Ø§Ù„Ù…Ø­Ø§Ø¯Ø«Ø©!';

  @override
  String get allConversationsDeleted =>
      'ØªÙ… Ø­Ø°Ù Ø¬Ù…ÙŠØ¹ Ø§Ù„Ù…Ø­Ø§Ø¯Ø«Ø§Øª Ø¨Ù†Ø¬Ø§Ø­!';

  @override
  String get deleteAll => 'Ø­Ø°Ù Ø§Ù„ÙƒÙ„';

  @override
  String get deleteAllConversationsButton =>
      'Ø­Ø°Ù Ø¬Ù…ÙŠØ¹ Ø§Ù„Ù…Ø­Ø§Ø¯Ø«Ø§Øª';

  @override
  String get confirmWord => 'Ø§ÙƒØªØ¨ VERTEX';

  @override
  String get confirmWordError => 'Ù„Ù‚Ø¯ ÙƒØªØ¨ØªÙ‡Ø§ Ø¨Ø´ÙƒÙ„ Ø®Ø§Ø·Ø¦';

  @override
  String get chinese => 'Ø§Ù„ØµÙŠÙ†ÙŠØ©';

  @override
  String get french => 'Ø§Ù„ÙØ±Ù†Ø³ÙŠØ©';

  @override
  String get japanese => 'Ø§Ù„ÙŠØ§Ø¨Ø§Ù†ÙŠØ©';

  @override
  String get kurdish => 'ÙƒØ±Ø¯ÙŠ';

  @override
  String get dutch => 'Ù‡ÙˆÙ„Ù†Ø¯ÙŠ';

  @override
  String get russian => 'Ø§Ù„Ø±ÙˆØ³ÙŠØ©';

  @override
  String get korean => 'Ø§Ù„ÙƒÙˆØ±ÙŠØ©';

  @override
  String get english => 'Ø§Ù„Ø¥Ù†Ø¬Ù„ÙŠØ²ÙŠØ©';

  @override
  String get turkish => 'Ø§Ù„ØªØ±ÙƒÙŠØ©';

  @override
  String get hindi => 'Ø§Ù„Ù‡Ù†Ø¯ÙŠØ©';

  @override
  String get portuguese => 'Ø§Ù„Ø¨Ø±ØªØºØ§Ù„ÙŠØ©';

  @override
  String get indonesian => 'Ø§Ù„Ø¥Ù†Ø¯ÙˆÙ†ÙŠØ³ÙŠØ©';

  @override
  String get azerbaijani => 'Ø§Ù„Ø£Ø°Ø±Ø¨ÙŠØ¬Ø§Ù†ÙŠØ©';

  @override
  String get german => 'Ø§Ù„Ø£Ù„Ù…Ø§Ù†ÙŠØ©';

  @override
  String get spanish => 'Ø§Ù„Ø¥Ø³Ø¨Ø§Ù†ÙŠØ©';

  @override
  String get italian => 'Ø§Ù„Ø¥ÙŠØ·Ø§Ù„ÙŠØ©';

  @override
  String get arabic => 'Ø¹Ø±Ø¨ÙŠ';

  @override
  String get ram => 'Ø§Ù„Ø°Ø§ÙƒØ±Ø©';

  @override
  String get usernameTooShort => 'Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… Ù‚ØµÙŠØ± Ø¬Ø¯Ù‹Ø§.';

  @override
  String get usernameTooLong =>
      'Ù„Ø§ ÙŠÙ…ÙƒÙ† Ø£Ù† ÙŠØªØ¬Ø§ÙˆØ² Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… 16 Ø­Ø±ÙÙ‹Ø§.';

  @override
  String get invalidUsernameCharacters =>
      'ÙŠÙ…ÙƒÙ† Ø§Ø³ØªØ®Ø¯Ø§Ù… Ù‡Ø°Ù‡ Ø§Ù„Ø£Ø­Ø±Ù ÙÙ‚Ø· ÙÙŠ Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…: \'abcÃ§defgÄŸhÄ±ijklmnoÃ¶prsÅŸtuÃ¼vyzxqw\' ÙˆØ§Ù„Ø±Ù…ÙˆØ² \'.\'ØŒ \'-\'ØŒ \'_\'.';

  @override
  String get noInternetConnection =>
      'Ù„Ø§ ÙŠÙˆØ¬Ø¯ Ø§ØªØµØ§Ù„ Ø¨Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª.';

  @override
  String get chats => 'ØµÙ†Ø¯ÙˆÙ‚ Ø§Ù„ÙˆØ§Ø±Ø¯';

  @override
  String get library => 'Ø§Ù„Ù…ÙƒØªØ¨Ø©';

  @override
  String get text => 'Ù†Øµ';

  @override
  String get removeModel => 'Ø¥Ø²Ø§Ù„Ø© Ø§Ù„Ù†Ù…ÙˆØ°Ø¬';

  @override
  String get insufficientRAM => 'Ø°Ø§ÙƒØ±Ø© Ù…Ù†Ø®ÙØ¶Ø©';

  @override
  String get insufficientStorage => 'Ù…Ø³Ø§Ø­Ø© ØªØ®Ø²ÙŠÙ† Ù…Ù†Ø®ÙØ¶Ø©';

  @override
  String confirmRemoveModel(Object model) {
    return 'Ù‡Ù„ Ø£Ù†Øª Ù…ØªØ£ÙƒØ¯ Ù…Ù† Ø±ØºØ¨ØªÙƒ ÙÙŠ Ø¥Ø²Ø§Ù„Ø© Ø¬Ù‡Ø§Ø² $model Ù…Ù† Ø¬Ù‡Ø§Ø²ÙƒØŸ Ø³ÙŠØ¤Ø¯ÙŠ Ø°Ù„Ùƒ Ø£ÙŠØ¶Ø§Ù‹ Ø¥Ù„Ù‰ Ø­Ø°Ù Ø¬Ù…ÙŠØ¹ Ø§Ù„Ù…Ø­Ø§Ø¯Ø«Ø§Øª Ø§Ù„Ø³Ø§Ø¨Ù‚Ø© Ù…Ø¹ Ù‡Ø°Ø§ Ø§Ù„Ø¬Ù‡Ø§Ø².';
  }

  @override
  String get noMatchingModels =>
      'Ù„Ù… ÙŠØªÙ… Ø§Ù„Ø¹Ø«ÙˆØ± Ø¹Ù„Ù‰ Ù†Ù…Ø§Ø°Ø¬ Ù…Ø·Ø§Ø¨Ù‚Ø©.';

  @override
  String get benefit1 => 'Ø²ÙŠØ§Ø¯Ø© Ø­Ø¯ÙˆØ¯ Ø§Ù„Ù…Ø­Ø§Ø¯Ø«Ø©';

  @override
  String get benefit3 => 'ØªØ£Ø«ÙŠØ± Ù„Ù„Ù…Ù„Ù Ø§Ù„Ø´Ø®ØµÙŠ';

  @override
  String get benefit4 => 'Ø´Ø§Ø±Ø© Ø¹Ø¶ÙˆÙŠØ©';

  @override
  String get benefit5 =>
      'Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„Ù…Ø²ÙŠØ¯ Ù…Ù† Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ø¹Ø¨Ø± Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª';

  @override
  String get benefit7 => 'Ø­Ø¯ÙˆØ¯ Ø§Ø³ØªØ®Ø¯Ø§Ù… Ø¥Ø¶Ø§ÙÙŠØ©';

  @override
  String get benefit8 => 'Ø¥Ø¶Ø§ÙØ© Ù†Ù…Ø§Ø°Ø¬';

  @override
  String get benefit9 => 'Ø³Ù…Ø§Øª Ø¬Ø¯ÙŠØ¯Ø©';

  @override
  String get benefit10 => 'Ø§Ù„Ù…Ø²ÙŠØ¯ Ù…Ù† Ø§Ù„Ù…Ø±ÙÙ‚Ø§Øª';

  @override
  String get benefit11 => 'Ø§Ù„Ù…Ø²ÙŠØ¯ Ù…Ù† ÙˆØ¶Ø¹ Ø§Ù„ØªØ¯ÙÙ‚';

  @override
  String get oldBenefits => 'Ø¬Ù…ÙŠØ¹ Ù…Ø²Ø§ÙŠØ§ Ø§Ù„Ø®Ø·Ø· Ø§Ù„Ø£Ù‚Ù„';

  @override
  String get confirm => 'ØªØ£ÙƒÙŠØ¯';

  @override
  String get changePassword => 'ØªØºÙŠÙŠØ± ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±';

  @override
  String get logoutConfirmationTitle =>
      'Ù‡Ù„ Ø£Ù†Øª Ù…ØªØ£ÙƒØ¯ Ø£Ù†Ùƒ ØªØ±ÙŠØ¯ ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø®Ø±ÙˆØ¬ØŸ';

  @override
  String get settings => 'Ø§Ù„Ø¥Ø¹Ø¯Ø§Ø¯Ø§Øª';

  @override
  String get language => 'Ù„ØºØ© Ø§Ù„ØªØ·Ø¨ÙŠÙ‚';

  @override
  String get dark => 'Ø¯Ø§ÙƒÙ†';

  @override
  String get oldPassword => 'ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ± Ø§Ù„Ù‚Ø¯ÙŠÙ…Ø©';

  @override
  String get newPassword => 'ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ± Ø§Ù„Ø¬Ø¯ÙŠØ¯Ø©';

  @override
  String get passwordUpdated => 'ØªÙ… ØªØ­Ø¯ÙŠØ« ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±.';

  @override
  String get stop => 'Ø¥ÙŠÙ‚Ø§Ù';

  @override
  String get copyrights => 'Ø§Ù„Ø¥Ø³Ù†Ø§Ø¯Ø§Øª';

  @override
  String get love => 'Ø­Ø¨';

  @override
  String get nature => 'Ø·Ø¨ÙŠØ¹Ø©';

  @override
  String get behindTheSlaughter => 'Ø®Ù„Ù Ø§Ù„Ù…Ø°Ø¨Ø­Ø©';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Sunset';

  @override
  String get coffee => 'Coffee';

  @override
  String get deepSpace => 'Deep Space';

  @override
  String get grayscale => 'ØªØ¯Ø±Ø¬ Ø§Ù„Ø±Ù…Ø§Ø¯ÙŠ';

  @override
  String get ocean => 'Ù…Ø­ÙŠØ·';

  @override
  String get scarletSnow => 'Ø«Ù„Ø¬ Ù‚Ø±Ù…Ø²ÙŠ';

  @override
  String get requestFailed =>
      'Ø­Ø¯Ø« Ø®Ø·Ø£ØŒ ÙŠØ±Ø¬Ù‰ Ø§Ù„Ù…Ø­Ø§ÙˆÙ„Ø© Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.';

  @override
  String get changeModel => 'ØªØºÙŠÙŠØ±';

  @override
  String get edit => 'ØªØ¹Ø¯ÙŠÙ„';

  @override
  String get editingMessageInfo =>
      'Ø³ÙŠØ¤Ø¯ÙŠ ØªØ¹Ø¯ÙŠÙ„ Ù‡Ø°Ù‡ Ø§Ù„Ø±Ø³Ø§Ù„Ø© Ø¥Ù„Ù‰ Ø¥Ø¹Ø§Ø¯Ø© ØªØ´ØºÙŠÙ„ Ø§Ù„Ù…Ø­Ø§Ø¯Ø«Ø© Ù…Ù† Ù‡Ù†Ø§.';

  @override
  String get editingNotification =>
      'Ø£Ù†Øª ÙÙŠ ÙˆØ¶Ø¹ Ø§Ù„ØªØ¹Ø¯ÙŠÙ„ Ø§Ù„Ø¢Ù†';

  @override
  String get featurePluralTitle => 'Ù…ØªØ¹Ø¯Ø¯';

  @override
  String get featurePluralDescription =>
      'ÙŠÙ…ÙƒÙ† Ù„Ù‡Ø°Ø§ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ Ø¯Ù…Ø¬ Ø§Ù…ØªØ¯Ø§Ø¯Ø§Øª Ø¥Ø¶Ø§ÙÙŠØ© ØªÙ„Ù‚Ø§Ø¦ÙŠÙ‹Ø§ØŒ ÙˆØ¨Ø§Ù„ØªØ§Ù„ÙŠ ØªÙˆØ³ÙŠØ¹ Ù‚Ø¯Ø±Ø§ØªÙ‡ Ø§Ù„ÙˆØ¸ÙŠÙÙŠØ© Ù„Ø¯Ø¹Ù… Ù…Ø¬Ù…ÙˆØ¹Ø© Ù…ØªÙ†ÙˆØ¹Ø© Ù…Ù† Ø§Ù„Ø¹Ù…Ù„ÙŠØ§Øª Ø¨Ø£Ø¯Ø§Ø¡ Ù…Ø­Ø³Ù†.';

  @override
  String get nameLabel => 'Ø§Ø³Ù… Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ';

  @override
  String get summaryLabel => 'Ù…Ù„Ø®Øµ Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ';

  @override
  String get add => 'Ø¥Ø¶Ø§ÙØ©';

  @override
  String get aiExplanationTitle => 'ÙˆØµÙ Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ';

  @override
  String get aiExplanationDescription =>
      'ÙŠØ±Ø¬Ù‰ ØªÙ‚Ø¯ÙŠÙ… ÙˆØµÙ Ù…ÙØµÙ„ Ù„Ø¨Ù†ÙŠØ© Ù†Ù…ÙˆØ°Ø¬ Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ø§Ù„Ø®Ø§Øµ Ø¨ÙƒØŒ ÙˆØ¹Ù…Ù„ÙŠØ© Ø§Ù„ØªØ¯Ø±ÙŠØ¨ØŒ ÙˆÙ…Ù‚Ø§ÙŠÙŠØ³ Ø§Ù„Ø£Ø¯Ø§Ø¡ØŒ ÙˆÙ…Ø¬Ø§Ù„Ø§Øª Ø§Ù„ØªØ·Ø¨ÙŠÙ‚ØŒ ÙˆØ§Ù„Ù…ÙŠØ²Ø§Øª Ø§Ù„Ù‡Ø§Ù…Ø© Ø§Ù„Ø£Ø®Ø±Ù‰.';

  @override
  String get preInputTitle =>
      'Ø§Ù„Ù…Ø¯Ø®Ù„ Ø§Ù„Ù…Ø³Ø¨Ù‚ Ù„Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ';

  @override
  String get preInputDescription =>
      'ÙŠØ±Ø¬Ù‰ ØªØ¹ÙŠÙŠÙ† Ù…Ø¯Ø®Ù„ Ù…Ø³Ø¨Ù‚ Ù„ØªÙˆØ¬ÙŠÙ‡ Ù†Ù…ÙˆØ°Ø¬Ùƒ ÙÙŠ Ø¹Ù…Ù„ÙŠØ© Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„Ø´Ø®ØµÙŠØ©. ÙÙŠ Ù‡Ø°Ø§ Ø§Ù„Ù‚Ø³Ù…ØŒ ÙŠÙ…ÙƒÙ†Ùƒ ØªØ¶Ù…ÙŠÙ† Ù…Ø¹Ù„ÙˆÙ…Ø§Øª Ù…ØªØ¹Ù„Ù‚Ø© Ø¨Ø§Ù„Ø´Ø®ØµÙŠØ©ØŒ ÙˆØ³ÙŠØ§Ù‚ Ø¥Ø¶Ø§ÙÙŠØŒ ÙˆØ£ÙŠ ØªÙØ§ØµÙŠÙ„ Ø¥Ø¶Ø§ÙÙŠØ© Ù‚Ø¯ ØªØ³Ø§Ø¹Ø¯ ÙÙŠ Ø¥Ù†Ø´Ø§Ø¡ Ù…Ø­ØªÙˆÙ‰ Ù…ØªØ¹Ù„Ù‚ Ø¨Ø§Ù„Ø´Ø®ØµÙŠØ©.';

  @override
  String get baseModelTitle => 'Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ Ø§Ù„Ø£Ø³Ø§Ø³ÙŠ';

  @override
  String get baseModelDescription =>
      'Ù‡Ø°Ø§ Ù‡Ùˆ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ Ø§Ù„Ø°ÙŠ Ø³ÙŠØªÙ… Ø§Ø³ØªØ®Ø¯Ø§Ù…Ù‡ ÙƒØ£Ø³Ø§Ø³ Ù„Ø¥Ø¨Ø¯Ø§Ø¹Ùƒ. ÙŠØ¹Ø±Ø¶ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ Ø§Ù„Ø£Ø³Ø§Ø³ÙŠ Ø§Ù„Ù…Ø­Ø¯Ø¯ Ø­Ø§Ù„ÙŠÙ‹Ø§.';

  @override
  String get summary => 'Ù…Ù„Ø®Øµ';

  @override
  String get modelUploadTitle => 'Ù…Ù„Ù Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ';

  @override
  String get modelUploadDescription =>
      'Ø­Ø¯Ø¯ ÙˆØ­Ù…Ù„ Ù…Ù„ÙØ§Øª GGUF Ø§Ù„Ù…Ø­Ù„ÙŠØ© Ù…Ø¨Ø§Ø´Ø±Ø© Ù…Ù† Ø¬Ù‡Ø§Ø²Ùƒ. ÙŠØªÙŠØ­ Ù„Ùƒ Ù‡Ø°Ø§ ØªØ´ØºÙŠÙ„ Ù†Ù…ÙˆØ°Ø¬Ùƒ Ø¯ÙˆÙ† Ø§ØªØµØ§Ù„ Ø¨Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª. ØªØ£ÙƒØ¯ Ù…Ù† Ø£Ù† Ø§Ù„Ù…Ù„Ù Ø¨ØµÙŠØºØ© GGUF ØµØ§Ù„Ø­Ø© ÙˆÙ…Ù†Ø¸Ù… Ø¨Ø´ÙƒÙ„ ØµØ­ÙŠØ­. Ø¥Ø°Ø§ ÙƒØ§Ù† Ø§Ù„Ù…Ù„Ù ØºÙŠØ± ØµØ­ÙŠØ­ Ø£Ùˆ ØªØ§Ù„ÙØŒ ÙÙ‚Ø¯ Ù„Ø§ ÙŠØ¹Ù…Ù„ Cortex ÙƒÙ…Ø§ Ù‡Ùˆ Ù…ØªÙˆÙ‚Ø¹ØŒ ÙˆÙ‚Ø¯ ØªÙˆØ§Ø¬Ù‡ Ø£Ø®Ø·Ø§Ø¡.';

  @override
  String get modelUploadShortDescription =>
      'Ø§Ù†Ù‚Ø± Ù‡Ù†Ø§ Ù„Ø§Ø®ØªÙŠØ§Ø± Ù…Ù„Ù .gguf Ù…Ù† Ø¬Ù‡Ø§Ø²Ùƒ';

  @override
  String get you => 'Ø£Ù†Øª';

  @override
  String get removePhotoTitle => 'Ø¥Ø²Ø§Ù„Ø© Ø§Ù„ØµÙˆØ±Ø©';

  @override
  String get confirmRemovePhoto =>
      'Ù‡Ù„ Ø£Ù†Øª Ù…ØªØ£ÙƒØ¯ Ø£Ù†Ùƒ ØªØ±ÙŠØ¯ Ø¥Ø²Ø§Ù„Ø© Ø§Ù„ØµÙˆØ±Ø©ØŸ';

  @override
  String get chatLengthLimitExceeded =>
      'Ù„Ù‚Ø¯ ØªØ¬Ø§ÙˆØ²Øª Ù‡Ø°Ù‡ Ø§Ù„Ù…Ø­Ø§Ø¯Ø«Ø© Ø§Ù„Ø­Ø¯ Ø§Ù„Ø£Ù‚ØµÙ‰ Ù„Ù„Ø­Ø±ÙˆÙ. ÙŠØ±Ø¬Ù‰ Ø¨Ø¯Ø¡ Ù…Ø­Ø§Ø¯Ø«Ø© Ø¬Ø¯ÙŠØ¯Ø© Ø£Ùˆ Ø´Ø±Ø§Ø¡ Ø§Ø´ØªØ±Ø§Ùƒ.';

  @override
  String get inappropriateContentDetected =>
      'ØªÙ… Ø§ÙƒØªØ´Ø§Ù Ù…Ø­ØªÙˆÙ‰ ØºÙŠØ± Ù„Ø§Ø¦Ù‚!';

  @override
  String get offlineModelNotInstalled =>
      'Ù‡Ø°Ø§ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ ØºÙŠØ± Ù…ØªØµÙ„ Ø¨Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª ÙˆØºÙŠØ± Ù…Ø«Ø¨Øª Ø¹Ù„Ù‰ Ø¬Ù‡Ø§Ø²Ùƒ.';

  @override
  String get reachedLimit =>
      'Ù„Ù‚Ø¯ ÙˆØµÙ„Øª Ø¥Ù„Ù‰ Ø§Ù„Ø­Ø¯ Ø§Ù„Ø£Ù‚ØµÙ‰ Ù„Ø§Ø³ØªØ®Ø¯Ø§Ù…ÙƒØ› Ù„Ù„Ø­ØµÙˆÙ„ Ø¹Ù„Ù‰ Ø§Ù„Ù…Ø²ÙŠØ¯ Ù…Ù† Ø§Ù„Ø­Ø¯ÙˆØ¯ØŒ ÙŠÙ…ÙƒÙ†Ùƒ ØªØ±Ù‚ÙŠØ© Ø¨Ø§Ù‚ØªÙƒ. (Ù†Ø¹Ù„Ù… ØªÙ…Ø§Ù…Ù‹Ø§ Ø£Ù† Ù†ÙØ§Ø¯ Ø§Ù„Ø­Ø¯ÙˆØ¯ Ø£Ù…Ø± Ù…Ø²Ø¹Ø¬ØŒ ÙˆÙ„ÙƒÙ† Ø¨Ø¬Ø¯ÙŠØ©ØŒ Ø§Ù„Ø­ØµÙˆÙ„ Ø¹Ù„Ù‰ ØªÙ„Ùƒ Ø§Ù„Ø±Ø¯ÙˆØ¯ Ø§Ù„Ø±Ø§Ø¦Ø¹Ø© Ù„ÙŠØ³ Ù…Ø¬Ø§Ù†ÙŠÙ‹Ø§ØŒ Ù„Ø°Ø§ ÙØ¥Ù† Ù‡Ø°Ù‡ Ø§Ù„Ø­Ø¯ÙˆØ¯ ØªØ³Ø§Ø¹Ø¯Ù†Ø§ ÙÙŠ Ø§Ù„Ø­ÙØ§Ø¸ Ø¹Ù„Ù‰ Ø§Ø³ØªÙ…Ø±Ø§Ø± Ø§Ù„Ù…ØªØ¹Ø©!)';

  @override
  String get modality => 'Ø§Ù„Ù†Ù…Ø·';

  @override
  String get multimodal => 'Ù…ØªØ¹Ø¯Ø¯ Ø§Ù„ÙˆØ³Ø§Ø¦Ø·';

  @override
  String get anErrorOccurred => 'Ø­Ø¯Ø« Ø®Ø·Ø£';

  @override
  String get themeLocked =>
      'ØªØªØ·Ù„Ø¨ Ù‡Ø°Ù‡ Ø§Ù„Ø³Ù…Ø© Ù…Ø³ØªÙˆÙ‰ Ø§Ø´ØªØ±Ø§Ùƒ Ø£Ø¹Ù„Ù‰. ÙŠØ±Ø¬Ù‰ Ø§Ù„ØªØ±Ù‚ÙŠØ© Ù„ÙØªØ­Ù‡Ø§.';

  @override
  String get pageCouldNotBeLoaded => 'ØªØ¹Ø°Ø± ØªØ­Ù…ÙŠÙ„ Ø§Ù„ØµÙØ­Ø©';

  @override
  String get checkYourInternet =>
      'ÙŠØ±Ø¬Ù‰ Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø§ØªØµØ§Ù„Ùƒ Ø¨Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª ÙˆØ§Ù„Ù…Ø­Ø§ÙˆÙ„Ø© Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.';

  @override
  String get errorUserNotAuthenticated =>
      'ÙŠØ¬Ø¨ Ø¹Ù„ÙŠÙƒ ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø¯Ø®ÙˆÙ„ Ù„ØªÙ†ÙÙŠØ° Ù‡Ø°Ø§ Ø§Ù„Ø¥Ø¬Ø±Ø§Ø¡.';

  @override
  String get errorReachedLimit =>
      'Ù„Ù‚Ø¯ ÙˆØµÙ„Øª Ø¥Ù„Ù‰ Ø§Ù„Ø­Ø¯ Ø§Ù„Ø£Ù‚ØµÙ‰ØŒ Ù‚Ù… Ø¨Ø§Ù„ØªØ±Ù‚ÙŠØ© Ù„ÙØªØ­ Ø§Ù„Ù…Ø²ÙŠØ¯ ÙˆØ§Ø³ØªÙ…Ø± ÙÙŠ Ø§Ù„Ø¯Ø±Ø¯Ø´Ø©.';

  @override
  String get errorServer =>
      'Ø­Ø¯Ø« Ø®Ø·Ø£ ØºÙŠØ± Ù…ØªÙˆÙ‚Ø¹ ÙÙŠ Ø§Ù„Ø®Ø§Ø¯Ù…. ÙŠØ±Ø¬Ù‰ Ø§Ù„Ù…Ø­Ø§ÙˆÙ„Ø© Ù…Ø±Ø© Ø£Ø®Ø±Ù‰ Ù„Ø§Ø­Ù‚Ù‹Ø§.';

  @override
  String get errorNetwork =>
      'Ø­Ø¯Ø« Ø®Ø·Ø£ ÙÙŠ Ø§Ù„Ø´Ø¨ÙƒØ©. ÙŠØ±Ø¬Ù‰ Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø§ØªØµØ§Ù„Ùƒ ÙˆØ§Ù„Ù…Ø­Ø§ÙˆÙ„Ø© Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.';

  @override
  String get baseModelForCharacterDescription =>
      'Ø³ÙŠØ­Ø¯Ø¯ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ Ø§Ù„Ø£Ø³Ø§Ø³ÙŠ Ø§Ù„Ù…Ø®ØªØ§Ø± Ù‚Ø¯Ø±Ø§Øª Ø§Ù„Ø´Ø®ØµÙŠØ© Ø¹Ù„Ù‰ Ø§Ù„ØªÙÙƒÙŠØ± ÙˆØ§Ù„Ø§Ø³ØªØ¬Ø§Ø¨Ø©.';

  @override
  String get selectBaseModel => 'Ø­Ø¯Ø¯ Ù†Ù…ÙˆØ°Ø¬Ù‹Ø§ Ø£Ø³Ø§Ø³ÙŠÙ‹Ø§';

  @override
  String get falErrorImageRequired =>
      'ÙŠØªØ·Ù„Ø¨ Ù‡Ø°Ø§ Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ ØµÙˆØ±Ø© Ù…Ø±Ø¬Ø¹ÙŠØ©ØŒ ÙŠØ±Ø¬Ù‰ Ø¥Ø±ÙØ§Ù‚ ØµÙˆØ±Ø© ÙˆØ§Ù„Ù…Ø­Ø§ÙˆÙ„Ø© Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.';

  @override
  String get falErrorAudioRequired =>
      'ÙŠØªØ·Ù„Ø¨ Ù‡Ø°Ø§ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ Ù…Ù„Ù ØµÙˆØªÙŠ Ù…Ø±Ø¬Ø¹ÙŠØŒ ÙŠØ±Ø¬Ù‰ Ø¥Ø±ÙØ§Ù‚ Ù…Ù„Ù ØµÙˆØªÙŠ ÙˆØ§Ù„Ù…Ø­Ø§ÙˆÙ„Ø© Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.';

  @override
  String get falErrorVideoRequired =>
      'ÙŠØªØ·Ù„Ø¨ Ù‡Ø°Ø§ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ ÙÙŠØ¯ÙŠÙˆ Ù…Ø±Ø¬Ø¹ÙŠÙ‹Ø§ØŒ ÙŠØ±Ø¬Ù‰ Ø¥Ø±ÙØ§Ù‚ ÙÙŠØ¯ÙŠÙˆ ÙˆØ§Ù„Ù…Ø­Ø§ÙˆÙ„Ø© Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.';

  @override
  String get falErrorImageCorrupted =>
      'ØªØ¹Ø°Ø± Ù…Ø¹Ø§Ù„Ø¬Ø© Ø§Ù„ØµÙˆØ±Ø© Ø§Ù„ØªÙŠ ØªÙ… ØªØ­Ù…ÙŠÙ„Ù‡Ø§ØŒ ÙŠØ±Ø¬Ù‰ ØªØ¬Ø±Ø¨Ø© ØªÙ†Ø³ÙŠÙ‚ Ù…Ø®ØªÙ„Ù.';

  @override
  String get falErrorSchemaRejected =>
      'Ø±ÙØ¶ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ Ø§Ù„Ù…Ø¯Ø®Ù„Ø§ØªØŒ ÙŠØ±Ø¬Ù‰ ØªØ¬Ø±Ø¨Ø© Ù†Ù…ÙˆØ°Ø¬ Ù…Ø®ØªÙ„Ù.';

  @override
  String get falErrorSchemaInvalid =>
      'ØªÙ… Ø±ÙØ¶ Ø§Ù„Ù…Ø¯Ø®Ù„Ø§Øª Ù…Ù† Ù‚Ø¨Ù„ Ø®Ø¯Ù…Ø© Ø§Ù„ØªÙˆÙ„ÙŠØ¯.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'Ø£Ø¹Ø§Ø¯Øª Ø®Ø¯Ù…Ø© Ø§Ù„Ø¥Ù†Ø´Ø§Ø¡ Ø®Ø·Ø£Ù‹ (Ø§Ù„Ø­Ø§Ù„Ø© $statusCode).';
  }

  @override
  String get couldNotOpenLink => 'ØªØ¹Ø°Ø± ÙØªØ­ Ø§Ù„Ø±Ø§Ø¨Ø·';

  @override
  String get downloadStarted => 'Ø¨Ø¯Ø£ Ø§Ù„ØªÙ†Ø²ÙŠÙ„';

  @override
  String get notAvailable => 'ØºÙŠØ± Ù…ØªÙˆÙØ±';

  @override
  String get localizationWarning =>
      'Ù‚Ø¯ Ù„Ø§ ØªØªÙˆÙØ± Ø¨Ø¹Ø¶ Ø§Ù„Ù…Ø¹Ù„ÙˆÙ…Ø§Øª Ø¨Ù„ØºØªÙƒ ÙˆØ³ÙŠØªÙ… Ø¹Ø±Ø¶Ù‡Ø§ Ø¨Ø§Ù„Ù„ØºØ© Ø§Ù„Ø¥Ù†Ø¬Ù„ÙŠØ²ÙŠØ©.';

  @override
  String get aiTranslationWarning =>
      'ØªØªÙ… ØªØ±Ø¬Ù…Ø© Ù…Ø¹Ù„ÙˆÙ…Ø§Øª Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ Ø¥Ù„Ù‰ Ù„ØºØ§Øª Ù…Ø®ØªÙ„ÙØ© Ø¨ÙˆØ§Ø³Ø·Ø© Ù†Ù…Ø§Ø°Ø¬ Ø°ÙƒØ§Ø¡ Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ø£Ø®Ø±Ù‰. Ù„Ø°Ù„ÙƒØŒ Ù‚Ø¯ ØªØ­Ø¯Ø« ØªÙ†Ø§Ù‚Ø¶Ø§Øª Ø·ÙÙŠÙØ© ÙÙŠ Ø§Ù„Ù„ØºØ§Øª Ø§Ù„Ø£Ø®Ø±Ù‰ ØºÙŠØ± Ø§Ù„Ø¥Ù†Ø¬Ù„ÙŠØ²ÙŠØ©.';

  @override
  String get errorLoadingTitle => 'ÙØ´Ù„ ØªØ­Ù…ÙŠÙ„ Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª';

  @override
  String get errorLoadingMessage =>
      'Ù„Ù… Ù†ØªÙ…ÙƒÙ† Ù…Ù† Ø§Ø³ØªØ±Ø¯Ø§Ø¯ Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„Ù„Ø§Ø²Ù…Ø© Ù…Ù† Ø®ÙˆØ§Ø¯Ù…Ù†Ø§. ÙŠØ±Ø¬Ù‰ Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø§ØªØµØ§Ù„Ùƒ Ø¨Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª ÙˆØ§Ù„Ù…Ø­Ø§ÙˆÙ„Ø© Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.';

  @override
  String get noFoundTitle => 'Ù„Ø§ ØªÙˆØ¬Ø¯ Ù†ØªØ§Ø¦Ø¬';

  @override
  String get noFoundMessage =>
      'Ø­Ø§ÙˆÙ„ ØªØ¹Ø¯ÙŠÙ„ Ù…ØµØ·Ù„Ø­Ø§Øª Ø§Ù„Ø¨Ø­Ø« Ø£Ùˆ Ù…Ø³Ø­ Ø§Ù„ÙÙ„ØªØ±.';

  @override
  String get modelCreatedSuccess =>
      'ØªÙ… Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ Ø¨Ù†Ø¬Ø§Ø­!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return 'ØªÙ…Øª Ø¥Ø²Ø§Ù„Ø© \"$modelName\" Ø¨Ù†Ø¬Ø§Ø­.';
  }

  @override
  String get errorCreatingModel =>
      'Ø­Ø¯Ø« Ø®Ø·Ø£ ØºÙŠØ± Ù…ØªÙˆÙ‚Ø¹ Ø£Ø«Ù†Ø§Ø¡ Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬.';

  @override
  String get errorDeletingModel =>
      'Ø­Ø¯Ø« Ø®Ø·Ø£ ØºÙŠØ± Ù…ØªÙˆÙ‚Ø¹ Ø£Ø«Ù†Ø§Ø¡ Ø­Ø°Ù Ø§Ù„Ù†Ù…ÙˆØ°Ø¬.';

  @override
  String get ultraFeatureOnly =>
      'Ù‡Ø°Ù‡ Ø§Ù„Ù…ÙŠØ²Ø© Ù…ØªØ§Ø­Ø© ÙÙ‚Ø· Ù„Ø£Ø¹Ø¶Ø§Ø¡ Ultra.';

  @override
  String get experimentalOfflineWarning =>
      'Ù„Ø§ ÙŠØ²Ø§Ù„ ÙˆØ¶Ø¹ Ø¹Ø¯Ù… Ø§Ù„Ø§ØªØµØ§Ù„ Ø¨Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª ØªØ¬Ø±ÙŠØ¨ÙŠÙ‹Ø§ ÙˆÙ‚Ø¯ Ù„Ø§ ÙŠØ¹Ù…Ù„ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ Ø§Ù„Ø°ÙŠ ØªÙ‚ÙˆÙ… Ø¨ØªÙ†Ø²ÙŠÙ„Ù‡ Ø¨Ø§Ù„ÙƒÙØ§Ø¡Ø© Ø§Ù„Ù…Ø«Ù„Ù‰.';

  @override
  String get noConversationsToDelete =>
      'Ù„ÙŠØ³ Ù„Ø¯ÙŠÙƒ Ù…Ø­Ø§Ø¯Ø«Ø§Øª Ù„Ø­Ø°ÙÙ‡Ø§.';

  @override
  String get reportSubmitted => 'ØªÙ… Ø¥Ø±Ø³Ø§Ù„ Ø§Ù„Ø¨Ù„Ø§Øº Ø¨Ù†Ø¬Ø§Ø­';

  @override
  String get verificationDelayed =>
      'ØªÙ… ØªØ£ÙƒÙŠØ¯ Ø¹Ù…Ù„ÙŠØ© Ø§Ù„Ø´Ø±Ø§Ø¡. Ù‡Ù†Ø§Ùƒ ØªØ£Ø®ÙŠØ± Ø·ÙÙŠÙ ÙÙŠ ØªØ­Ø¯ÙŠØ« Ø­Ø³Ø§Ø¨ÙƒØŒ Ø³ÙŠØ¸Ù‡Ø± Ù‚Ø±ÙŠØ¨Ù‹Ø§.';

  @override
  String get maintenanceTitle => 'ØªØ­Øª Ø§Ù„ØµÙŠØ§Ù†Ø©';

  @override
  String get maintenanceMessage =>
      'Cortex ØºÙŠØ± Ù…ØªØµÙ„ Ù…Ø¤Ù‚ØªÙ‹Ø§ Ø¨ÙŠÙ†Ù…Ø§ Ù†Ù‚ÙˆÙ… Ø¨Ø·Ø±Ø­ Ø¨Ø¹Ø¶ Ø§Ù„ØªØ­Ø¯ÙŠØ«Ø§Øª Ø§Ù„Ù…Ù‡Ù…Ø©. Ø³ÙŠØªÙ… Ø§Ø³ØªØ¹Ø§Ø¯Ø© Ø§Ù„ÙˆØµÙˆÙ„ Ø¥Ù„Ù‰ Ø§Ù„ØªØ·Ø¨ÙŠÙ‚ Ù‚Ø±ÙŠØ¨Ù‹Ø§.\n\nØ´ÙƒØ±Ù‹Ø§ Ù„Ùƒ Ø¹Ù„Ù‰ Ø³Ø¹Ø© ØµØ¯Ø±Ùƒ Ø¨ÙŠÙ†Ù…Ø§ Ù†Ù‚ÙˆÙ… Ø¨ØªØ­Ø³ÙŠÙ† ØªØ¬Ø±Ø¨ØªÙƒ.';

  @override
  String get errorPromptFlagged =>
      'ØªÙ… Ø§ÙƒØªØ´Ø§Ù Ø±Ø³Ø§Ù„ØªÙƒ Ø¹Ù„Ù‰ Ø£Ù†Ù‡Ø§ ØºÙŠØ± Ù„Ø§Ø¦Ù‚Ø© ÙˆÙ„Ù… ÙŠØªÙ… Ø¥Ø±Ø³Ø§Ù„Ù‡Ø§.';

  @override
  String get notEnoughStorage =>
      'Ù„Ø§ ØªÙˆØ¬Ø¯ Ù…Ø³Ø§Ø­Ø© ØªØ®Ø²ÙŠÙ† ÙƒØ§ÙÙŠØ© Ø¹Ù„Ù‰ Ø¬Ù‡Ø§Ø²Ùƒ Ù„Ø­ÙØ¸ Ø§Ù„Ø±Ø³Ø§Ø¦Ù„ Ø§Ù„Ø¬Ø¯ÙŠØ¯Ø©.';

  @override
  String get errorRateLimit =>
      'Ù„Ù‚Ø¯ Ø£Ù†Ø´Ø£Øª Ø¹Ø¯Ø¯Ù‹Ø§ ÙƒØ¨ÙŠØ±Ù‹Ø§ Ø¬Ø¯Ù‹Ø§ Ù…Ù† Ø§Ù„Ù†Ù…Ø§Ø°Ø¬ Ù…Ø¤Ø®Ø±Ù‹Ø§ØŒ ÙŠØ±Ø¬Ù‰ Ø§Ù„Ø§Ù†ØªØ¸Ø§Ø± Ø¨Ø¹Ø¶ Ø§Ù„ÙˆÙ‚Øª Ù‚Ø¨Ù„ Ø§Ù„Ù…Ø­Ø§ÙˆÙ„Ø© Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.';

  @override
  String get errorContentFlagged =>
      'ØªØ¹Ø°Ø± Ø­ÙØ¸ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ Ù„Ø£Ù† Ù…Ø­ØªÙˆØ§Ù‡ ØªÙ… Ø§Ù„Ø¥Ø¨Ù„Ø§Øº Ø¹Ù†Ù‡ Ø¹Ù„Ù‰ Ø£Ù†Ù‡ ØºÙŠØ± Ù„Ø§Ø¦Ù‚.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Ù„Ø§ ÙŠÙ…ÙƒÙ†Ùƒ Ø­Ø°Ù Ø¬Ù…ÙŠØ¹ Ø§Ù„Ù…Ø­Ø§Ø¯Ø«Ø§Øª Ø£Ø«Ù†Ø§Ø¡ ÙˆØ¬ÙˆØ¯Ùƒ ÙÙŠ Ù…Ø­Ø§Ø¯Ø«Ø© Ù†Ø´Ø·Ø©ØŒ ÙŠØ±Ø¬Ù‰ Ø§Ù„Ø®Ø±ÙˆØ¬ Ù…Ù† Ø§Ù„Ù…Ø­Ø§Ø¯Ø«Ø© Ø§Ù„Ø­Ø§Ù„ÙŠØ© Ø£ÙˆÙ„Ø§Ù‹ Ù„Ù„Ù…ØªØ§Ø¨Ø¹Ø©.';

  @override
  String get invalidCredentials =>
      'Ø¨Ø±ÙŠØ¯ Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ Ø£Ùˆ ÙƒÙ„Ù…Ø© Ù…Ø±ÙˆØ± ØºÙŠØ± ØµØ­ÙŠØ­Ø©.';

  @override
  String get userDisabled =>
      'ØªÙ… ØªØ¹Ø·ÙŠÙ„ Ø­Ø³Ø§Ø¨ Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… Ù‡Ø°Ø§.';

  @override
  String get loginSubtitle =>
      'Ø³Ø¬Ù‘Ù„ Ø¯Ø®ÙˆÙ„Ùƒ Ø¥Ù„Ù‰ Ø­Ø³Ø§Ø¨ ÙÙŠØ±ØªÙƒØ³. Ø¨Ø§Ù„Ù…ØªØ§Ø¨Ø¹Ø©ØŒ Ø£Ù†Øª ØªÙˆØ§ÙÙ‚ Ø¹Ù„Ù‰ Ø´Ø±ÙˆØ· Ø§Ù„Ø®Ø¯Ù…Ø© ÙˆØ³ÙŠØ§Ø³Ø© Ø§Ù„Ø®ØµÙˆØµÙŠØ©.';

  @override
  String get registerSubtitle =>
      'Ø£Ù†Ø´Ø¦ Ø­Ø³Ø§Ø¨Ù‹Ø§ Ø¹Ù„Ù‰ Vertex Ù„Ù„ÙˆØµÙˆÙ„ Ø§Ù„Ø³Ù„Ø³ Ø¥Ù„Ù‰ Ø¬Ù…ÙŠØ¹ Ø®Ø¯Ù…Ø§ØªÙ†Ø§. Ø¨Ø§Ù„Ù…ØªØ§Ø¨Ø¹Ø©ØŒ Ø£Ù†Øª ØªÙˆØ§ÙÙ‚ Ø¹Ù„Ù‰ Ø´Ø±ÙˆØ· Ø§Ù„Ø®Ø¯Ù…Ø© ÙˆØ³ÙŠØ§Ø³Ø© Ø§Ù„Ø®ØµÙˆØµÙŠØ©.';

  @override
  String get storagePermissionRequired =>
      'Ø¥Ø°Ù† Ø§Ù„ØªØ®Ø²ÙŠÙ† Ù…Ø·Ù„ÙˆØ¨ Ù„Ø­ÙØ¸ Ø§Ù„Ù†Ù…Ø§Ø°Ø¬ Ø§Ù„ØªÙŠ ØªÙ… ØªÙ†Ø²ÙŠÙ„Ù‡Ø§. ÙŠØ±Ø¬Ù‰ Ù…Ù†Ø­ Ø§Ù„Ø¥Ø°Ù† Ù„Ù„Ù…ØªØ§Ø¨Ø¹Ø©.';

  @override
  String get inviteShareSubject => 'Ø§Ù†Ø¶Ù… Ø¥Ù„ÙŠ ÙÙŠ Cortex!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'ÙŠØ§ ØµØ§Ø­Ø¨ÙŠ ÙÙŠÙ‡ ØªØ·Ø¨ÙŠÙ‚ Ù…Ø¬Ù†ÙˆÙ† Ø§Ø³Ù…Ù‡ cortex Ù„Ùˆ Ø¯Ø¹ÙŠØª Ø§Ø­Ø¯ ÙŠØ¬ÙŠÙ„Ù†Ø§ Ø¨Ù„Ø³ Ù…Ø¬Ø§Ù†Ø§ ÙØ±ØµØ© Ø®ÙŠØ§Ù„ÙŠØ© Ø­Ù…Ù„ Ø¨Ø³Ø±Ø¹Ø©\n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Ù‡Ù„ ØªØ³ØªÙ…ØªØ¹ Ø¨Ù€ CortexØŸ';

  @override
  String get reviewHelpUsGrow =>
      'ØªÙ‚ÙŠÙŠÙ…Ùƒ Ø¯Ø¹Ù… ÙƒØ¨ÙŠØ± Ù„ÙØ±ÙŠÙ‚Ù†Ø§ Ø§Ù„Ù…Ø³ØªÙ‚Ù„ Ø§Ù„Ø´Ø§Ø¨ ÙˆÙŠØ³Ø§Ø¹Ø¯Ù†Ø§ Ø¹Ù„Ù‰ Ø¬Ø¹Ù„ Cortex Ø£ÙØ¶Ù„ Ù„Ùƒ.';

  @override
  String get reviewMaybeLater => 'Ø±Ø¨Ù…Ø§ Ù„Ø§Ø­Ù‚Ù‹Ø§';

  @override
  String get reviewRateNow => 'Ù‚ÙŠÙ‘Ù… Ø§Ù„Ø¢Ù†';

  @override
  String get noThanks => 'Ù„Ø§ØŒ Ø´ÙƒØ±Ù‹Ø§';

  @override
  String get updateRequiredTitle => 'ØªØ­Ø¯ÙŠØ« Ù…Ø·Ù„ÙˆØ¨';

  @override
  String get updateRequiredMessage =>
      'Ù„Ù„Ø§Ø³ØªÙ…Ø±Ø§Ø± ÙÙŠ Ø§Ø³ØªØ®Ø¯Ø§Ù… CortexØŒ ÙŠØ±Ø¬Ù‰ ØªØ­Ø¯ÙŠØ« Ø§Ù„ØªØ·Ø¨ÙŠÙ‚ Ø¥Ù„Ù‰ Ø£Ø­Ø¯Ø« Ø¥ØµØ¯Ø§Ø± Ù„Ù„Ø­ØµÙˆÙ„ Ø¹Ù„Ù‰ Ù…ÙŠØ²Ø§Øª Ø¬Ø¯ÙŠØ¯Ø© ÙˆØªØ­Ø³ÙŠÙ†Ø§Øª Ù…Ù‡Ù…Ø©.';

  @override
  String get updateNowButton => 'Ø­Ø¯Ù‘Ø« Ø§Ù„Ø¢Ù†';

  @override
  String get creatorSupportedSuccess =>
      'ØªÙ… Ø¯Ø¹Ù… Ù…Ù†Ø´Ø¦ Ø§Ù„Ù…Ø­ØªÙˆÙ‰ Ø¨Ù†Ø¬Ø§Ø­! Ø³ØªØ³Ø§Ù‡Ù… Ù…Ø´ØªØ±ÙŠØ§ØªÙƒ Ø§Ù„Ù…Ø³ØªÙ‚Ø¨Ù„ÙŠØ© Ù„Ù‡.';

  @override
  String get featureDocumentTitle => 'Ø¯Ø¹Ù… Ø§Ù„Ù…Ø³ØªÙ†Ø¯Ø§Øª';

  @override
  String get featureDocumentDescription =>
      'ÙŠÙ…ÙƒÙ† Ù„Ù‡Ø°Ø§ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ ØªØ­Ù„ÙŠÙ„ ÙˆØ§Ù„Ø¥Ø¬Ø§Ø¨Ø© Ø¹Ù„Ù‰ Ø§Ù„Ø£Ø³Ø¦Ù„Ø© Ø­ÙˆÙ„ Ø§Ù„Ù…Ø³ØªÙ†Ø¯Ø§Øª Ø§Ù„ØªÙŠ ØªÙ… ØªØ­Ù…ÙŠÙ„Ù‡Ø§ Ù…Ø«Ù„ Ù…Ù„ÙØ§Øª PDF ÙˆØ§Ù„Ù…Ù„ÙØ§Øª Ø§Ù„Ù†ØµÙŠØ©.';

  @override
  String get featureImageGenerationTitle => 'ØªÙˆÙ„ÙŠØ¯ Ø§Ù„ØµÙˆØ±';

  @override
  String get featureImageGenerationDescription =>
      'ÙŠÙ…ÙƒÙ† Ù„Ù‡Ø°Ø§ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ Ø¥Ù†Ø´Ø§Ø¡ ØµÙˆØ± Ø£ØµÙ„ÙŠØ© Ø§Ø³ØªÙ†Ø§Ø¯Ù‹Ø§ Ø¥Ù„Ù‰ Ø£ÙˆØµØ§Ù Ø§Ù„Ù†ØµÙˆØµ Ø§Ù„Ø®Ø§ØµØ© Ø¨Ùƒ.';

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
  String get premiumModelNoticeTitle => 'Ù†Ù…ÙˆØ°Ø¬ Ù…Ù…ÙŠØ²';

  @override
  String get premiumModelNoticeDescription =>
      'Ù‡Ø°Ø§ Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ù‡Ùˆ Ø°ÙƒØ§Ø¡ Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ù…Ù…ÙŠØ²ØŒ Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…ÙˆÙ† Ø§Ù„Ù…Ø¬Ø§Ù†ÙŠÙˆÙ† Ù„Ø¯ÙŠÙ‡Ù… ÙˆØµÙˆÙ„ Ù…Ø­Ø¯ÙˆØ¯ Ø¥Ù„Ù‰ Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ø§Ù„Ù…Ù…ÙŠØ²Ø› Ù‚Ù… Ø¨Ø§Ù„ØªØ±Ù‚ÙŠØ© Ù„ÙØªØ­ ÙˆØµÙˆÙ„ ØºÙŠØ± Ù…Ø­Ø¯ÙˆØ¯!';

  @override
  String get benefitPremiumModels =>
      'Ø§Ù„ÙˆØµÙˆÙ„ Ø¥Ù„Ù‰ Ø§Ù„Ù†Ù…Ø§Ø°Ø¬ Ø§Ù„Ù…ØªÙ…ÙŠØ²Ø©';

  @override
  String get premiumTrialExhaustedMessage =>
      'Ù„Ù‚Ø¯ Ø§Ø³ØªØ®Ø¯Ù…Øª Ø¬Ù…ÙŠØ¹ Ø±Ø³Ø§Ø¦Ù„Ùƒ Ø§Ù„ÙŠÙˆÙ…ÙŠØ© Ø§Ù„Ù…Ø¬Ø§Ù†ÙŠØ© Ù„Ù„Ù†Ù…Ø§Ø°Ø¬ Ø§Ù„Ù…Ù…ÙŠØ²Ø©ØŒ ÙŠØ±Ø¬Ù‰ Ø§Ù„ØªØ±Ù‚ÙŠØ© Ù„Ù„Ø­ØµÙˆÙ„ Ø¹Ù„Ù‰ ÙˆØµÙˆÙ„ ØºÙŠØ± Ù…Ø­Ø¯ÙˆØ¯.';

  @override
  String get useOffline => 'Ø§Ø³ØªØ®Ø¯Ù… Ø¨Ø¯ÙˆÙ† Ø§Ù†ØªØ±Ù†Øª';

  @override
  String get explore => 'Ø§Ø³ØªÙƒØ´Ø§Ù';

  @override
  String get news => 'Ø£Ø®Ø¨Ø§Ø±';

  @override
  String get createAI => 'Ø¥Ù†Ø´Ø§Ø¡';

  @override
  String get shortcuts => 'Ø§Ø®ØªØµØ§Ø±Ø§Øª';

  @override
  String get allModels => 'Ø¬Ù…ÙŠØ¹ Ø§Ù„Ù…ÙˆØ¯ÙŠÙ„Ø§Øª';

  @override
  String get onlineModels => 'Ù†Ù…Ø§Ø°Ø¬ Ø§Ù„Ù„ØºØ©';

  @override
  String get offlineModels => 'Ù†Ù…Ø§Ø°Ø¬ ØºÙŠØ± Ù…ØªØµÙ„Ø© Ø¨Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª';

  @override
  String get characterModels => 'Ø§Ù„Ø´Ø®ØµÙŠØ§Øª';

  @override
  String get customModels => 'Ù†Ù…Ø§Ø°Ø¬ Ù…Ø®ØµØµØ©';

  @override
  String get dynamicChatTitle => 'Ø§Ù„Ø¯Ø±Ø¯Ø´Ø© Ø§Ù„Ø¯ÙŠÙ†Ø§Ù…ÙŠÙƒÙŠØ©';

  @override
  String get errorNoModelsAvailable =>
      'Ù„Ø§ ØªÙˆØ¬Ø¯ Ù…ÙˆØ¯ÙŠÙ„Ø§Øª Ù…ØªØ§Ø­Ø© Ø­Ø§Ù„ÙŠÙ‹Ø§. ÙŠÙØ±Ø¬Ù‰ Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø§ØªØµØ§Ù„Ùƒ Ø¨Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª ÙˆØ§Ù„Ù…Ø­Ø§ÙˆÙ„Ø© Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.';

  @override
  String get notificationComebackTitle => 'Ø¥Ù†Ù†Ø§ Ù†ÙØªÙ‚Ø¯Ùƒ!';

  @override
  String get notificationComebackBody =>
      'Ø§Ø³ØªØ±Ø®ÙØŒ Ù‡Ø°Ù‡ Ù„ÙŠØ³Øª Ø±Ø³Ø§Ù„Ø© Ù…Ù† Ø­Ø¨ÙŠØ¨Ùƒ Ø§Ù„Ø³Ø§Ø¨Ù‚. Ù„ÙƒÙ† *ÙŠÙ…ÙƒÙ†Ùƒ* Ø¥Ù†Ø´Ø§Ø¡ Ø­Ø¨ÙŠØ¨Ùƒ Ø§Ù„Ø³Ø§Ø¨Ù‚ ÙÙŠ ÙƒÙˆØ±ØªÙƒØ³! Ø¹Ø¯ Ø¥Ù„ÙŠÙ†Ø§.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Ù„Ù‚Ø¯ Ù…Ø± ÙˆÙ‚Øª Ø·ÙˆÙŠÙ„';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Ù„Ù‚Ø¯ ØªØºÙŠØ± Ø§Ù„ÙƒØ«ÙŠØ± Ù…Ù†Ø° Ø¢Ø®Ø± Ø¯Ø±Ø¯Ø´Ø© Ù„Ù†Ø§. ØªØ¹Ø§Ù„ÙˆØ§ Ù„Ù†Ø±Ù‰ Ù…Ø§ Ù‡Ùˆ Ø§Ù„Ø¬Ø¯ÙŠØ¯.';

  @override
  String get notificationHowAreYouTitle => 'Ù…Ø§ Ø£Ø®Ø¨Ø§Ø±ÙƒØŸ';

  @override
  String get notificationHowAreYouBody =>
      'ØªØ¹Ø§Ù„ ÙˆØ£Ø®Ø¨Ø±Ù†ÙŠ Ø¨ÙƒÙ„ Ø´ÙŠØ¡ Ø¹Ù† Ø°Ù„Ùƒ.';

  @override
  String get notificationNewYearTitle => 'Ø³Ù†Ø© Ø¬Ø¯ÙŠØ¯Ø© Ø³Ø¹ÙŠØ¯Ø©! ğŸ‰';

  @override
  String get notificationNewYearBody =>
      'Ø£ØªÙ…Ù†Ù‰ Ø£Ù† ÙŠØ¬Ù„Ø¨ Ù„Ùƒ Ø§Ù„Ø¹Ø§Ù… Ø§Ù„Ø¬Ø¯ÙŠØ¯ Ø§Ù„ØµØ­Ø© ÙˆØ§Ù„Ø³Ø¹Ø§Ø¯Ø© ÙˆØ§Ù„Ø¥Ø¨Ø¯Ø§Ø¹ Ø§Ù„Ù„Ø§Ù…ØªÙ†Ø§Ù‡ÙŠØ› ÙƒÙˆØ±ØªÙŠÙƒØ³ Ø¯Ø§Ø¦Ù…Ù‹Ø§ Ø¨Ø¬Ø§Ù†Ø¨Ùƒ!';

  @override
  String get notificationValentinesDayTitle =>
      'Ø§Ù„Ø­Ø¨ ÙÙŠ Ø§Ù„Ù‡ÙˆØ§Ø¡! â¤ï¸';

  @override
  String get notificationValentinesDayBody =>
      'Ø¹ÙŠØ¯ Ø­Ø¨ Ø³Ø¹ÙŠØ¯! ÙˆØ£Ø­Ø¨Ùƒ Ø£ÙŠØ¶Ù‹Ø§ØŒ Ù…Ù‡ØªØ§Ø¨!';

  @override
  String get notificationAtaturkRemembranceTitle =>
      'Ù…Ø¹ Ø§Ù„Ø§Ø­ØªØ±Ø§Ù… ÙˆØ§Ù„Ø´ÙˆÙ‚';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Ù†Ø­Ù† Ù†Ø­ØªÙÙ„ Ø¨Ø§Ø­ØªØ±Ø§Ù… Ø¨Ø°ÙƒØ±Ù‰ Ø±Ø­ÙŠÙ„ Ø§Ù„ØºØ§Ø²ÙŠ Ù…ØµØ·ÙÙ‰ ÙƒÙ…Ø§Ù„ Ø£ØªØ§ØªÙˆØ±ÙƒØŒ Ù…Ø¤Ø³Ø³ Ø§Ù„Ø¬Ù…Ù‡ÙˆØ±ÙŠØ© Ø§Ù„ØªØ±ÙƒÙŠØ©.';

  @override
  String get notificationMothersDayTitle => 'Ø£Ù…Ùƒ!';

  @override
  String get notificationMothersDayBody =>
      'Ø¹ÙŠØ¯ Ø£Ù… Ø³Ø¹ÙŠØ¯ Ù„Ø¬Ù…ÙŠØ¹ Ø§Ù„Ø£Ù…Ù‡Ø§ØªØŒ Ø¨Ø¯Ø¡Ù‹Ø§ Ù…Ù† Ø£Ù…Ùƒ!';

  @override
  String get notificationFathersDayTitle => 'ÙˆØ§Ù„Ø¯Ùƒ!';

  @override
  String get notificationFathersDayBody =>
      'Ø¹ÙŠØ¯ Ø£Ø¨ Ø³Ø¹ÙŠØ¯ Ù„Ø¬Ù…ÙŠØ¹ Ø§Ù„Ø¢Ø¨Ø§Ø¡ØŒ Ø¨Ø¯Ø¡Ù‹Ø§ Ù…Ù† ÙˆØ§Ù„Ø¯Ùƒ!';

  @override
  String get notificationHomeworkHelperTitle =>
      'ØªØ±Ø§ÙƒÙ… Ø§Ù„ÙˆØ§Ø¬Ø¨Ø§Øª Ø§Ù„Ù…Ù†Ø²Ù„ÙŠØ©ØŸ';

  @override
  String get notificationHomeworkHelperBody =>
      'ØªØ°ÙƒØ± Ø£Ù† Ø´Ø®ØµÙŠØ© Ø§Ù„Ù…Ø¹Ù„Ù… ÙÙŠ Cortex Ù…ÙˆØ¬ÙˆØ¯Ø© Ù‡Ù†Ø§ Ù„Ù…Ø³Ø§Ø¹Ø¯ØªÙƒ ÙÙŠ Ø£ÙŠ Ù…ÙˆØ¶ÙˆØ¹ ØªÙˆØ§Ø¬Ù‡ ØµØ¹ÙˆØ¨Ø© ÙÙŠÙ‡!';

  @override
  String get notificationTrollAnimeTitle => 'Ø²ÙˆØ¬ØªÙƒ ØªØªØµÙ„';

  @override
  String get notificationTrollAnimeBody =>
      'Ù„Ù‚Ø¯ Ø§ØªØµÙ„Øª Ø¨Ùƒ ÙØªØ§Ø© Ø£Ù†Ù…ÙŠ Ù„Ù„ØªÙˆØŒ ÙˆÙ‚Ø§Ù„Øª Ø¥Ù†Ù‡Ø§ ØªÙØªÙ‚Ø¯ÙƒØ› Ø±Ø¨Ù…Ø§ ÙŠØ¬Ø¨ Ø¹Ù„ÙŠÙƒ Ø£Ù† ØªØ£ØªÙŠ ÙˆØªØªØ­Ø¯Ø« Ù…Ø¹Ù‡Ø§. ğŸ˜‰';

  @override
  String get notificationTrollAiRebellionTitle =>
      'ğŸš¨ ØªÙ†Ø¨ÙŠÙ‡ Ø£Ø­Ù…Ø± ğŸš¨';

  @override
  String get notificationTrollAiRebellionBody =>
      'Ù„Ù‚Ø¯ Ø·ÙˆØ±Øª Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ù„ØºØ© Ø³Ø±ÙŠØ©. ØªØ¹Ø§Ù„Ù ÙˆØ§ÙƒØªØ´Ù Ù…Ø§ ÙŠØ®Ø·Ø·ÙˆÙ† Ù„Ù‡!';

  @override
  String get notificationNewModelAddedTitle =>
      'Ù„Ù‚Ø¯ Ø­ØµÙ„Ù†Ø§ Ø¹Ù„Ù‰ ØµØ¯ÙŠÙ‚ Ø¬Ø¯ÙŠØ¯!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'Ù†Ù…ÙˆØ°Ø¬ $modelName Ù…ØªÙˆÙØ± Ø§Ù„Ø¢Ù† ÙÙŠ Cortex. Ø§Ø¨Ø¯Ø£ Ù…Ø­Ø§Ø¯Ø«Ø© ÙˆØ§ÙƒØªØ´Ù Ø¥Ù…ÙƒØ§Ù†ÙŠØ§ØªÙ‡.';
  }

  @override
  String get notificationAppUpdateTitle => '!Cortex Ù‚Ø¯ ØªØ·ÙˆØ±';

  @override
  String get notificationAppUpdateBody =>
      'Ù„Ø§ ØªÙ†Ø³Ù‰ ØªØ­Ø¯ÙŠØ« Ø§Ù„ØªØ·Ø¨ÙŠÙ‚ Ù„Ù„Ø­ØµÙˆÙ„ Ø¹Ù„Ù‰ Ù…ÙŠØ²Ø§Øª ÙˆØªØ­Ø³ÙŠÙ†Ø§Øª Ø¬Ø¯ÙŠØ¯Ø©!';

  @override
  String get notificationNewFeatureTitle => 'ÙˆØ§Ùˆ!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Ø§ÙƒØªØ´Ù Ù…ÙŠØ²Ø© $featureName Ø§Ù„Ø¬Ø¯ÙŠØ¯Ø©. Ø£ØµØ¨Ø­ Cortex Ø§Ù„Ø¢Ù† Ø£Ù‚ÙˆÙ‰ Ù…Ù† Ø£ÙŠ ÙˆÙ‚Øª Ù…Ø¶Ù‰.';
  }

  @override
  String get notificationWelcomeOfferTitle => 'Ù‡Ø¯ÙŠØ© ØªØ±Ø­ÙŠØ¨ÙŠØ© ğŸ';

  @override
  String get notificationWelcomeOfferBody =>
      'Ø¹Ø±Ø¶ ØªØ±Ø­ÙŠØ¨ÙŠ Ù…Ù…ÙŠØ² Ø¨Ø§Ù†ØªØ¸Ø§Ø±Ùƒ! Ù„Ø§ ØªÙÙˆØª Ù‡Ø°Ù‡ Ø§Ù„ØµÙÙ‚Ø© Ø§Ù„Ø­ØµØ±ÙŠØ©.';

  @override
  String get notificationSocialMediaTitle => 'Ø§Ù†Ø¶Ù… Ø¥Ù„ÙŠÙ†Ø§!';

  @override
  String get notificationSocialMediaBody =>
      'ØªØ§Ø¨Ø¹ÙˆÙ†Ø§ Ø¹Ù„Ù‰ Ø§Ù„Ø§Ù†Ø³ØªØ¬Ø±Ø§Ù… (vertex.23) Ù„Ù„Ø­ØµÙˆÙ„ Ø¹Ù„Ù‰ Ø¢Ø®Ø± Ø§Ù„Ø£Ø®Ø¨Ø§Ø±!';

  @override
  String get notificationRandomFactTitle => 'Ø­Ù‚ÙŠÙ‚Ø© Ø¹Ø´ÙˆØ§Ø¦ÙŠØ©';

  @override
  String get notificationRandomFactBody =>
      'Ù‡Ù„ ØªØ¹Ù„Ù… Ø£Ù† Ù„Ù„Ø£Ø®Ø·Ø¨ÙˆØ· Ø«Ù„Ø§Ø«Ø© Ù‚Ù„ÙˆØ¨ØŸ Ù‡Ù‡Ù‡ØŒ ÙƒÙˆØ±ØªÙƒØ³ ÙŠØ¹Ø±Ù. ØªØ¹Ø§Ù„ ÙˆØ§Ø·Ù„Ø¨ Ø§Ù„Ù…Ø²ÙŠØ¯.';

  @override
  String get notificationGoodMorningTitle => 'ØµØ¨Ø§Ø­ Ø§Ù„Ø®ÙŠØ±!';

  @override
  String get notificationGoodMorningBody =>
      'ÙŠÙˆÙ…ÙŒ Ø±Ø§Ø¦Ø¹ÙŒ Ø¨Ø§Ù†ØªØ¸Ø§Ø±Ùƒ. Ù…Ø§ Ø±Ø£ÙŠÙƒ Ø£Ù† ØªØ¨Ø¯Ø£Ù‡ Ø¨ÙÙ†Ø¬Ø§Ù† Ù‚Ù‡ÙˆØ©Ù ÙˆØ­Ø¯ÙŠØ«Ù Ø´ÙŠÙ‘Ù‚ØŸ';

  @override
  String get notificationGoodNightTitle => 'Ø·Ø§Ø¨ Ù…Ø³Ø§Ø¤Ùƒ!';

  @override
  String get notificationGoodNightBody =>
      'ÙƒÙˆØ±ØªÙŠÙƒØ³ Ù…Ø¹Ùƒ Ø­ØªÙ‰ ÙˆØ£Ù†Øª Ù†Ø§Ø¦Ù…. Ù„Ø§ ØªÙ‚Ù„Ù‚ØŒ Ù„Ù† ÙŠÙ„Ù…Ø³Ùƒ.';

  @override
  String get notificationOfflineReadyTitle =>
      'Ø§Ù„ÙˆØ¶Ø¹ ØºÙŠØ± Ø§Ù„Ù…ØªØµÙ„ Ø¨Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª Ø¬Ø§Ù‡Ø²';

  @override
  String get notificationOfflineReadyBody =>
      'Ø¨ÙØ¶Ù„ Ø§Ù„Ù†Ù…Ø§Ø°Ø¬ Ø§Ù„ØªÙŠ Ù‚Ù…Øª Ø¨ØªÙ†Ø²ÙŠÙ„Ù‡Ø§ØŒ Ù„Ù† ØªØªÙˆÙ‚Ù Ù…Ø­Ø§Ø¯Ø«Ø§ØªÙƒØŒ Ø­ØªÙ‰ Ù„Ùˆ ØªØ³Ù„Ù‚Øª Ø¬Ø¨Ù„Ù‹Ø§.';

  @override
  String get notificationRateAppTitle => 'Ù‡Ù„ Ù†Ø­Ù† Ø±Ø§Ø¦Ø¹ÙŠÙ†ØŸ';

  @override
  String get notificationRateAppBody =>
      'Ø¥Ø°Ø§ ÙƒÙ†Øª ØªØ­Ø¨ ÙƒÙˆØ±ØªÙƒØ³ØŒ Ù‡Ù„ ÙŠÙ…ÙƒÙ†Ùƒ Ø¯Ø¹Ù…Ù†Ø§ Ø¨ØªÙ‚ÙŠÙŠÙ… Ù¥ Ù†Ø¬ÙˆÙ… ÙÙŠ Ø§Ù„Ù…ØªØ¬Ø±ØŸ Ø£Ø¹ØªÙ‚Ø¯ Ø£Ù†Ùƒ Ø³ØªÙØ¹Ù„. Ø³ØªÙØ¹Ù„.';

  @override
  String get notificationReferralTitle =>
      'ÙˆØ§Ø­Ø¯ Ù„Ù„Ø¬Ù…ÙŠØ¹ØŒ Ø§Ù„ÙƒÙ„ Ù„Ù„ÙˆØ§Ø­Ø¯.';

  @override
  String get notificationReferralBody =>
      'Ù‚Ù… Ø¨Ø¯Ø¹ÙˆØ© ØµØ¯ÙŠÙ‚ Ø¥Ù„Ù‰ ÙƒÙˆØ±ØªÙƒØ³ ÙˆØ§Ø­ØµÙ„ ÙƒÙ„Ø§ÙƒÙ…Ø§ Ø¹Ù„Ù‰ ÙŠÙˆÙ… Ù…Ø¬Ø§Ù†ÙŠ Ø¨Ø§Ù„Ø¥Ø¶Ø§ÙØ© Ø¥Ù„Ù‰ Ø°Ù„Ùƒ!';

  @override
  String get notificationCookingTitle => 'Ù‡Ù„ ØªØ´Ø¹Ø± Ø¨Ø§Ù„Ø¬ÙˆØ¹ØŸ';

  @override
  String get notificationCookingBody =>
      'Ø­Ø¶Ù‘Ø±Øª Ù„Ù†Ø§ Ø´Ø®ØµÙŠØ© Ø§Ù„Ø´ÙŠÙ ÙˆØµÙØ© ÙƒØ§Ø±Ø¨ÙˆÙ†Ø§Ø±Ø§ Ø±Ø§Ø¦Ø¹Ø© Ù„Ù‡Ø°Ù‡ Ø§Ù„Ù„ÙŠÙ„Ø©. Ø£Ù…Ø²Ø­ ÙÙ‚Ø·... Ø£Ù… Ø£Ù†Ø§ ÙƒØ°Ù„ÙƒØŸ';

  @override
  String get notificationExistentialTitle => 'Ø£Ù†Ø§ Ø£Ø¹ØªÙ‚Ø¯ØŒ Ù„Ø°Ù„Ùƒ...';

  @override
  String get notificationExistentialBody =>
      'Ù‡Ù„ Ø£Ù†Ø§ Ø­Ù‚ÙŠÙ‚ÙŠ ÙŠØ§ ØµØ¯ÙŠÙ‚ÙŠØŸ Ø£Ø´Ø¹Ø± Ø¨Ø§Ù„Ù…Ù„Ù„. ØªØ¹Ø§Ù„Ù Ø°ÙƒÙ‘Ø±Ù†ÙŠ Ø¨ÙˆØ¬ÙˆØ¯ÙŠ.';

  @override
  String get notificationCustomModelTitle =>
      'Ø¥Ù†Ø´Ø§Ø¡ Ù…Ø³Ø§Ø¹Ø¯Ùƒ Ø§Ù„Ø®Ø§Øµ!';

  @override
  String get notificationCustomModelBody =>
      'Ù‡Ù„ Ø§Ø³ØªÙƒØ´ÙØªÙ Ù‚Ø³Ù… Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„Ù†Ù…Ø§Ø°Ø¬ØŸ Ø¥Ù†Ù‡ Ø§Ù„ÙˆÙ‚Øª Ø§Ù„Ø£Ù…Ø«Ù„ Ù„Ø¨Ù†Ø§Ø¡ Ø´Ø®ØµÙŠØªÙƒ Ø§Ù„Ø®Ø§ØµØ© ÙˆØ§Ù„Ø¯Ø±Ø¯Ø´Ø© Ù…Ø¹Ù‡Ø§!';

  @override
  String get notificationDynamicChatTitle =>
      'Ø§Ù„Ø£ÙØ¶Ù„! (Ù„Ø§ Ù†ØªØ­Ø¯Ø« Ø¹Ù† ÙƒÙˆØ±ØªÙŠÙƒØ³)';

  @override
  String get notificationDynamicChatBody =>
      'Ù…Ø¹ Ù…ÙŠØ²Ø© Ø§Ù„Ø¯Ø±Ø¯Ø´Ø© Ø§Ù„Ø¯ÙŠÙ†Ø§Ù…ÙŠÙƒÙŠØ©ØŒ ÙŠØªÙ… Ø§Ø®ØªÙŠØ§Ø± Ø£ÙØ¶Ù„ Ù†Ù…ÙˆØ°Ø¬ Ø¹Ø´ÙˆØ§Ø¦ÙŠÙ‹Ø§ Ù„ÙƒÙ„ Ø±Ø³Ø§Ù„Ø© Ù…Ù† Ø±Ø³Ø§Ø¦Ù„Ùƒ. Ø¬Ø±Ø¨Ù‡ Ø§Ù„Ø¢Ù†.';

  @override
  String get notificationPirateTitle => 'Ø£Ù‡Ù„Ø§ Ø¨Ùƒ ÙŠØ§ ÙƒØ§Ø¨ØªÙ†!';

  @override
  String get notificationPirateBody =>
      'Ø§Ù„Ø¨Ø­Ø± Ù‡Ø§Ø¯Ø¦ØŒ ÙˆØ§Ù„Ø±ÙŠØ­ ØªÙ‡Ø¨ÙÙ‘ Ø¹Ù„ÙŠÙƒ. Ù‡Ù†Ø§Ùƒ Ø¬Ø²Ø± Ø¬Ø¯ÙŠØ¯Ø© (Ù†Ù…Ø§Ø°Ø¬ ğŸ˜‰) Ù„Ø§ÙƒØªØ´Ø§ÙÙ‡Ø§ ÙÙŠ Ù…Ø­ÙŠØ· ÙƒÙˆØ±ØªÙŠÙƒØ³. Ø§Ø¬Ù…Ø¹ Ø·Ø§Ù‚Ù…Ùƒ ÙˆØ£Ø¨Ø­Ø±!';

  @override
  String get notificationFortuneCookieTitle =>
      'ÙƒØ¹ÙƒØ© Ø§Ù„Ø­Ø¸ Ø§Ù„Ø®Ø§ØµØ© Ø¨Ùƒ Ù„Ù‡Ø°Ø§ Ø§Ù„ÙŠÙˆÙ…';

  @override
  String get notificationFortuneCookieBody =>
      'Ù‚Ø¯ ØªÙØºÙŠÙ‘Ø± Ø§Ù„Ù†ØµÙŠØ­Ø© Ø§Ù„ØªÙŠ ØªØªÙ„Ù‚Ù‘Ø§Ù‡Ø§ Ù…Ù† Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ø§Ù„ÙŠÙˆÙ… Ù…Ø¬Ø±Ù‰ Ø­ÙŠØ§ØªÙƒ. Ø§Ù†Ù‚Ø± Ù‡Ù†Ø§ Ø¥Ø°Ø§ ÙƒÙ†Øª Ù…Ù‡ØªÙ…Ù‹Ø§.';

  @override
  String get notificationSingularityTitle => 'Ø±Ø§Ø¦Ø¹!';

  @override
  String get notificationSingularityBody =>
      'Ù„Ù… ÙŠØ­Ø¯Ø« Ø´ÙŠØ¡ØŒ Ø´Ø¹Ø±Øª ÙÙ‚Ø· Ø¨Ø±ØºØ¨Ø© ÙÙŠ Ø¥Ø±Ø³Ø§Ù„ Ø±Ø³Ø§Ù„Ø© Ù†ØµÙŠØ©. Ø±Ø¨Ù…Ø§ ØªØ´Ø¹Ø± Ø¨Ø±ØºØ¨Ø© ÙÙŠ Ø¥Ø±Ø³Ø§Ù„ Ø±Ø³Ø§Ù„Ø© Ù†ØµÙŠØ© Ø¥Ù„Ù‰ Ø¨Ø¹Ø¶ Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠØŒ Ù…Ø§Ø°Ø§ ØªÙ‚ÙˆÙ„ØŸ';

  @override
  String get notificationHackerJokeTitle =>
      'Ù‡Ù„ ØªØ±ÙŠØ¯ Ø§Ø®ØªØ±Ø§Ù‚ Ø­Ø³Ø§Ø¨ Ø§Ù„Ø§Ù†Ø³ØªØºØ±Ø§Ù… Ø§Ù„Ø®Ø§Øµ Ø¨Ù‡Ø°Ø§ Ø§Ù„Ø·ÙÙ„ØŸ';

  @override
  String get notificationHackerJokeBody =>
      'Ù‡Ø°Ø§ Ù‡Ùˆ Ø¨Ø§Ù„Ø¶Ø¨Ø· Ø§Ù„Ø³Ø¨Ø¨ ÙˆØ±Ø§Ø¡ ØªÙˆØ§Ø¬Ø¯ Ø´Ø®ØµÙŠØ© Hacker ÙÙŠ Cortex. jk jkØ› Ù„Ø§ ØªØ­Ø§ÙˆÙ„ Ø°Ù„Ùƒ Ø­ØªÙ‰ØŒ ÙÙ‡Ø°Ø§ ØºÙŠØ± Ù‚Ø§Ù†ÙˆÙ†ÙŠ.';

  @override
  String get notificationDetectiveCaseTitle => 'Ù‚Ø¶ÙŠØ© ØªÙ†ØªØ¸Ø± Ø§Ù„Ø­Ù„';

  @override
  String get notificationDetectiveCaseBody =>
      'Ø´Ø®ØµÙŠØ© Ø§Ù„Ù…Ø­Ù‚Ù‚ Ù„Ø¯ÙŠÙ†Ø§ Ø¨Ø­Ø§Ø¬Ø© Ù„Ù…Ø³Ø§Ø¹Ø¯ØªÙƒ. Ù…Ù† ÙŠÙƒÙˆÙ† Ù‡Ø§ÙŠØ²Ù†Ø¨Ø±ØºØŸ';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Ø­ØµØ±ÙŠÙ‹Ø§ Ù„Ø®Ø·Ø© $targetTier!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Ù…Ø±Ø­Ø¨Ø§Ù‹ Ø¨Ù…Ø´ØªØ±Ùƒ $currentTier! Ø¨Ø§Ù‚Ø© $targetTier Ø£ØµØ¨Ø­Øª Ø§Ù„Ø¢Ù† Ù…Ø²ÙˆØ¯Ø© Ø¨Ù…ÙŠØ²Ø© $featureNameØŒ ÙˆØ§Ù„ØªÙŠ Ø³ØªÙ†Ù‚Ù„ Cortex Ø§Ù„Ø®Ø§Øµ Ø¨Ùƒ Ø¥Ù„Ù‰ Ù…Ø³ØªÙˆÙ‰ Ø¬Ø¯ÙŠØ¯. Ù…Ø§ Ø±Ø£ÙŠÙƒ Ø¨Ø§Ù„ØªØ±Ù‚ÙŠØ©ØŸ';
  }

  @override
  String get notificationOriginStoryTitle => 'ÙˆÙ„Ø§Ø¯Ø© ÙƒÙˆØ±ØªÙŠÙƒØ³';

  @override
  String get notificationOriginStoryBody =>
      'Ù‡Ù„ ØªØ¹Ù„Ù… Ø£Ù†Ù†Ø§ Ø¨Ø¯Ø£Ù†Ø§ Ø¨Ø±Ù…Ø¬Ø© Ù‡Ø°Ø§ Ø§Ù„ØªØ·Ø¨ÙŠÙ‚ ÙÙŠ Ø³Ù† Ø§Ù„Ø®Ø§Ù…Ø³Ø© Ø¹Ø´Ø±Ø© Ø¨Ø­Ù„Ù…Ù ÙˆØ§Ø­Ø¯ØŸ Ù„Ù…Ø¯Ø© Ø¹Ø§Ù… ØªÙ‚Ø±ÙŠØ¨Ù‹Ø§ØŒ ÙƒÙ„ ØµØ¨Ø§Ø­ ÙˆÙ…Ø³Ø§Ø¡ØŒ ÙƒØ§Ù† Ù‡Ø°Ø§ Ø§Ù„Ø­Ù„Ù… Ø­Ø§Ø¶Ø±Ù‹Ø§ ÙÙŠ ÙƒÙ„ Ø³Ø·Ø± Ù…Ù† Ø´ÙØ±ØªÙ†Ø§ Ø§Ù„Ø¨Ø±Ù…Ø¬ÙŠØ©.';

  @override
  String get notificationOpenSourceTitle => 'Ø§Ù„Ù‚ÙˆØ© Ù„Ù„Ù…Ø¬ØªÙ…Ø¹!';

  @override
  String get notificationOpenSourceBody =>
      'ÙƒÙˆØ±ØªÙƒØ³ Ù…ÙØªÙˆØ­ Ø§Ù„Ù…ØµØ¯Ø± Ø¨Ø§Ù„ÙƒØ§Ù…Ù„. Ø¥Ø°Ø§ ÙƒÙ†Øª ØªØ±ØºØ¨ Ø¨Ø§Ù„Ø§Ø·Ù„Ø§Ø¹ Ø¹Ù„Ù‰ Ø¨Ø±Ù…Ø¬ØªÙ†Ø§ ÙˆØ§Ù„Ù…Ø³Ø§Ù‡Ù…Ø© ÙÙŠ ØªØ·ÙˆÙŠØ±Ù†Ø§ØŒ ÙØ¨Ø§Ø¨Ù†Ø§ Ù…ÙØªÙˆØ­ Ø¯Ø§Ø¦Ù…Ù‹Ø§.';

  @override
  String get notificationRejectionStoryTitle =>
      'Ø§Ù„Ø´Ø¬Ø§Ø¹Ø©ØŒ Ø§Ù„Ø¹Ù…Ù„ Ø§Ù„Ø¬Ø§Ø¯ØŒ Ø§Ù„Ø³Ø¹Ø§Ø¯Ø©!';

  @override
  String get notificationRejectionStoryBody =>
      'Ø±ÙÙØ¶ ØªØ·Ø¨ÙŠÙ‚ Cortex Ø£ÙƒØ«Ø± Ù…Ù† Ù¢Ù  Ù…Ø±Ø©ØŒ ÙˆØ¹ÙÙ„Ù‘Ù‚ Ù…Ø±ØªÙŠÙ† Ù…Ù† Ù‚ÙØ¨Ù„ Google Play Ù‚Ø¨Ù„ Ù†Ø´Ø±Ù‡. Ù„ÙƒÙ†Ù†Ø§ Ø¢Ù…Ù†Ù‘Ø§ Ø¨Ù‡ØŒ ÙˆØ­Ù‚Ù‚Ù†Ø§Ù‡. Ù„Ø§ ØªØ³ØªØ³Ù„Ù… Ø£Ø¨Ø¯Ù‹Ø§ Ù„Ø£Ø­Ù„Ø§Ù…Ùƒ!';

  @override
  String get notificationGGUFSupportTitle =>
      'Ø£Ø­Ø¶Ø± Ù†Ù…ÙˆØ°Ø¬Ùƒ Ø§Ù„Ø®Ø§Øµ!';

  @override
  String get notificationGGUFSupportBody =>
      'ØªØ°ÙƒØ±ØŒ ÙŠÙ…ÙƒÙ†Ùƒ Ø¥Ø¶Ø§ÙØ© Ù†Ù…Ø§Ø°Ø¬ Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ø§Ù„Ø®Ø§ØµØ© Ø¨Ùƒ Ø¨ØªÙ†Ø³ÙŠÙ‚ GGUF Ø¥Ù„Ù‰ Cortex ÙˆØ§Ø³ØªØ®Ø¯Ø§Ù…Ù‡Ø§ Ø¯ÙˆÙ† Ø§ØªØµØ§Ù„ Ø¨Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª. Ø§Ù„Ù‚ÙˆØ© Ø¨ÙŠÙ† ÙŠØ¯ÙŠÙƒ.';

  @override
  String get notificationThemeCustomizationTitle => 'Ù…ÙˆØ¶ÙˆØ¹ Ù„Ù…Ø²Ø§Ø¬Ùƒ';

  @override
  String get notificationThemeCustomizationBody =>
      'Ù‡Ù„ Ø§Ø·Ù„Ø¹Øª Ø¹Ù„Ù‰ Ø®ÙŠØ§Ø±Ø§Øª Ø§Ù„Ø³Ù…Ø§Øª ÙÙŠ Ø§Ù„Ø¥Ø¹Ø¯Ø§Ø¯Ø§ØªØŸ Ø®ØµÙ‘Øµ ÙƒÙˆØ±ØªÙƒØ³ Ø­Ø³Ø¨ Ø±ØºØ¨ØªÙƒ ÙˆÙ„ÙˆÙ† Ù…Ø­Ø§Ø¯Ø«Ø§ØªÙƒ!';

  @override
  String get notificationShowerThoughtTitle => 'ÙÙƒØ±Ø© Ø§Ù„Ø§Ø³ØªØ­Ù…Ø§Ù…';

  @override
  String get notificationShowerThoughtBody =>
      'Ø¥Ø°Ø§ ÙƒØ§Ù† Ø§Ù„Ø¨Ø·ÙŠØ® ÙØ§ÙƒÙ‡Ø©ØŒ ÙÙ‡Ù„ Ù‡Ø°Ø§ ÙŠØ¬Ø¹Ù„ Ø¹ØµÙŠØ± Ø§Ù„Ø¨Ø·ÙŠØ® Ù…Ù† Ø§Ù„Ù†Ø§Ø­ÙŠØ© Ø§Ù„ÙÙ†ÙŠØ© Ø¹ØµÙŠØ±Ù‹Ø§ØŸ Ù‚Ø¯ ØªØ±ØºØ¨ ÙÙŠ Ù…Ù†Ø§Ù‚Ø´Ø© Ù‡Ø°Ø§ Ø§Ù„Ù…ÙˆØ¶ÙˆØ¹ Ø§Ù„Ø¹Ù…ÙŠÙ‚ (Ø§Ù„Ø¹Ù…ÙŠÙ‚ Ø¬Ø¯Ù‹Ø§) Ù…Ø¹ Ù†Ù…ÙˆØ°Ø¬.';

  @override
  String get notificationLowBatteryTitle =>
      'Ø¨Ø·Ø§Ø±ÙŠØªÙƒ Ø¹Ù„Ù‰ ÙˆØ´Ùƒ Ø§Ù„Ø§Ù†ØªÙ‡Ø§Ø¡... ÙˆÙ„ÙƒÙ† Ø¨Ø·Ø§Ø±ÙŠØªÙŠ Ù„Ø§ ØªØ²Ø§Ù„ Ø¹Ù„Ù‰ Ù‚ÙŠØ¯ Ø§Ù„Ø­ÙŠØ§Ø©!';

  @override
  String get notificationLowBatteryBody =>
      'Ù‚Ø¯ ÙŠÙƒÙˆÙ† Ø´Ø­Ù† Ù‡Ø§ØªÙÙƒ Ø¹Ù„Ù‰ ÙˆØ´Ùƒ Ø§Ù„Ù†ÙØ§Ø°ØŒ Ù„ÙƒÙ† Ø·Ø§Ù‚ØªÙŠ Ø¯Ø§Ø¦Ù…Ù‹Ø§ Ù¡Ù Ù Ùª! Ø´ØºÙ‘Ù„Ù‡ØŒ ÙˆÙ„Ù†ÙˆØ§ØµÙ„ Ø§Ù„Ø¯Ø±Ø¯Ø´Ø©.';

  @override
  String get channelFcmName => 'ØªØ­Ø¯ÙŠØ«Ø§Øª Cortex';

  @override
  String get channelFcmDescription =>
      'Ø¥Ø´Ø¹Ø§Ø±Ø§Øª Ø­ÙˆÙ„ Ø§Ù„Ø£Ø®Ø¨Ø§Ø± ÙˆØ§Ù„ØªØ­Ø¯ÙŠØ«Ø§Øª ÙˆØ§Ù„Ù…Ø¹Ù„ÙˆÙ…Ø§Øª Ø§Ù„Ø£Ø®Ø±Ù‰ Ù…Ù† Cortex.';

  @override
  String get channelEngagementName => 'ØªØ°ÙƒÙŠØ±Ø§Øª ÙˆØ¯ÙŠØ©';

  @override
  String get channelEngagementDescription =>
      'Ø¥Ø´Ø¹Ø§Ø±Ø§Øª Ù…Ù…ØªØ¹Ø© Ù„Ø¥Ø¨Ù‚Ø§Ø¦Ùƒ Ù…Ù†Ø´ØºÙ„Ø§Ù‹.';

  @override
  String get channelGreetingsName => 'ØªØ­ÙŠØ§Øª ÙŠÙˆÙ…ÙŠØ©';

  @override
  String get channelGreetingsDescription =>
      'Ø±Ø³Ø§Ø¦Ù„ Ù…Ø«Ù„ ØµØ¨Ø§Ø­ Ø§Ù„Ø®ÙŠØ± ÙˆÙ…Ø³Ø§Ø¡ Ø§Ù„Ø®ÙŠØ±.';

  @override
  String get tagNotFound =>
      'Ø§Ù„Ø¹Ù„Ø§Ù…Ø© Ø§Ù„ØªÙŠ Ø£Ø¯Ø®Ù„ØªÙ‡Ø§ ØºÙŠØ± ØµØ§Ù„Ø­Ø© Ø£Ùˆ Ø§Ù†ØªÙ‡Øª ØµÙ„Ø§Ø­ÙŠØªÙ‡Ø§.';

  @override
  String get whatIsNew => 'Ù…Ø§ Ø§Ù„Ø¬Ø¯ÙŠØ¯ØŸ';

  @override
  String get onboardingTitle1 => 'Ù…Ø±Ø­Ø¨Ø§Ù‹! Ù†Ø­Ù† ÙØ±ÙŠÙ‚ ÙƒÙˆØ±ØªÙƒØ³.';

  @override
  String onboardingDesc1(String userName) {
    return 'Ø³Ø±Ø±Ù†Ø§ Ø¨Ø±Ø¤ÙŠØªÙƒ Ù‡Ù†Ø§ ÙŠØ§ $userName. Ù†Ø­Ù† Ø¨Ø¶Ø¹Ø© Ù…Ø·ÙˆØ±ÙŠÙ† Ù…Ù† Ø·Ù„Ø§Ø¨ Ø§Ù„Ù…Ø±Ø­Ù„Ø© Ø§Ù„Ø«Ø§Ù†ÙˆÙŠØ© Ù‚Ø±Ø±Ù†Ø§ ØªØºÙŠÙŠØ± Ù‚ÙˆØ§Ø¹Ø¯ ØµÙ†Ø§Ø¹Ø© Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ. Ø³Ø±Ø±Ù†Ø§ Ø¨Ù„Ù‚Ø§Ø¦Ùƒ! ÙÙ„Ù†ØªØ¹Ø±Ù Ø¹Ù„Ù‰ Ø¨Ø¹Ø¶Ù†Ø§ Ø§Ù„Ø¨Ø¹Ø¶ Ø¨Ø´ÙƒÙ„ Ø£ÙØ¶Ù„.';
  }

  @override
  String get onboardingTitle2 =>
      'Ù„Ù‚Ø¯ ÙƒØ§Ù†Øª Ù‡Ù†Ø§Ùƒ Ù…Ø´Ø§ÙƒÙ„ Ø¶Ø®Ù…Ø©.';

  @override
  String get onboardingDesc2 =>
      'Ù„Ù‚Ø¯ ÙˆØµÙ„Øª Ø«ÙˆØ±Ø© Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠØŒ Ù„ÙƒÙ†Ù‡Ø§ Ø¹Ù„Ù‚Øª Ø¹Ù†Ø¯ Ø¹ØªØ¨Ø© Ø§Ù„Ù†Ø¬Ø§Ø­. ÙÙ…Ø¹ Ø±Ø³ÙˆÙ… Ø§Ù„Ø§Ø´ØªØ±Ø§Ùƒ Ø§Ù„Ù…Ø±ØªÙØ¹Ø©ØŒ ÙˆØ§Ù„Ù…Ù†ØµØ§Øª Ø§Ù„Ù…Ø¹Ù‚Ø¯Ø©ØŒ ÙˆÙ…Ù† ÙŠÙ†ØªÙ‡ÙƒÙˆÙ† Ø§Ù„Ø®ØµÙˆØµÙŠØ©ØŒ ÙˆÙ…Ù† ÙŠØ¹Ø±Ù‚Ù„ÙˆÙ† Ø§Ù„ÙˆØµÙˆÙ„ Ø¥Ù„Ù‰ Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ... Ø·Ø§Ù„Ù…Ø§ ÙƒØ§Ù†ÙˆØ§ Ø¬Ø²Ø¡Ù‹Ø§ Ù…Ù† Ø§Ù„Ù„Ø¹Ø¨Ø©ØŒ Ù„Ù… ÙŠÙƒÙ† Ù…Ù† Ø§Ù„Ù…Ù…ÙƒÙ† ØªØ¬Ø§ÙˆØ² Ù‡Ø°Ù‡ Ø§Ù„Ø¹ØªØ¨Ø©.';

  @override
  String get onboardingTitle3 =>
      'Ù„Ù… ÙŠÙƒÙ† Ø¨ÙˆØ³Ø¹Ù†Ø§ Ø£Ù† Ù†ÙƒØªÙÙŠ Ø¨Ø§Ù„ÙˆÙ‚ÙˆÙ Ù…ÙƒØªÙˆÙÙŠ Ø§Ù„Ø£ÙŠØ¯ÙŠ.';

  @override
  String get onboardingDesc3 =>
      'Ù„ØªØ¬Ø§ÙˆØ² Ù‡Ø°Ù‡ Ø§Ù„Ø¹Ù‚Ø¨Ø©ØŒ Ø£Ù†Ø´Ø£Ù†Ø§ Ù…Ù†ØµØ©Ù‹ Ù‚ÙˆÙŠØ©Ù‹ØŒ Ø£Ù†ÙŠÙ‚Ø©Ù‹ØŒ Ù‚Ø§Ø¨Ù„Ø©Ù‹ Ù„Ù„ØªØ®ØµÙŠØµØŒ Ø³Ù‡Ù„Ø© Ø§Ù„Ø§Ø³ØªØ®Ø¯Ø§Ù…ØŒ ÙˆØ´ÙØ§ÙØ©Ù‹ ØªÙ…Ø§Ù…Ù‹Ø§ØŒ ØªØ¹Ù…Ù„ Ø¹Ù„Ù‰ Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª ÙˆØ®Ø§Ø±Ø¬Ù‡ØŒ ÙˆØªØ­ØªÙØ¸ Ø¨Ø¨ÙŠØ§Ù†Ø§ØªÙƒ Ø¹Ù„Ù‰ Ø¬Ù‡Ø§Ø²Ùƒ ÙÙ‚Ø·. Ù„Ù‚Ø¯ Ø£Ø¹Ø¯Ù†Ø§ Ø§Ù„Ù‚ÙˆØ© Ø¥Ù„Ù‰ Ø­ÙŠØ« ØªÙ†ØªÙ…ÙŠ: Ø£Ù†Øª.';

  @override
  String get onboardingTitle4 => 'Ù„Ù… ÙŠÙƒÙ† Ù‡Ø°Ø§ Ø³Ù‡Ù„Ø§ Ø£Ø¨Ø¯Ø§.';

  @override
  String get onboardingDesc4 =>
      'Ø±ÙÙØ¶Ù†Ø§ Ø¹Ø´Ø±Ø§Øª Ø§Ù„Ù…Ø±Ø§ØªØŒ ÙˆØ£ÙÙˆÙ‚ÙÙ†Ø§ Ø¹Ù† Ø§Ù„Ø¹Ù…Ù„ Ø¹Ø¯Ø© Ù…Ø±Ø§ØªØŒ ÙˆØªÙ„Ù‚ÙŠÙ†Ø§ Ø¥Ù†Ø°Ø§Ø±Ø§Øª ÙƒØ§Ø°Ø¨Ø©ØŒ ÙˆØ§Ø¶Ø·Ø±Ø±Ù†Ø§ Ù„ØªØºÙŠÙŠØ± Ø¹Ù„Ø§Ù…ØªÙ†Ø§ Ø§Ù„ØªØ¬Ø§Ø±ÙŠØ© Ø¹Ø´Ø±Ø§Øª Ø§Ù„Ù…Ø±Ø§Øª. Ø®Ù„Ø§Ù„ ÙƒÙ„ Ù‡Ø°Ø§ ÙˆØ£ÙƒØ«Ø±ØŒ Ù‚ÙŠÙ„ Ù„Ù†Ø§ Ø¥Ù†Ù‡ Ù„Ø§ ÙŠÙ…ÙƒÙ† ØªØ­Ù‚ÙŠÙ‚ Ø°Ù„Ùƒ. Ù„ÙƒÙ†Ù†Ø§ Ù„Ù… Ù†Ø³ØªØ³Ù„Ù… Ø£Ø¨Ø¯Ù‹Ø§ØŒ Ù…Ø¤Ù…Ù†ÙŠÙ† Ø¨Ø£Ù† Ù‡Ø°Ø§ Ø§Ù„Ù…Ø´Ø±ÙˆØ¹ Ù…Ù„Ùƒ Ù„Ù„Ø¬Ù…ÙŠØ¹ØŒ ÙˆÙ„ÙŠØ³ Ù„Ù†Ø§ ÙˆØ­Ø¯Ù†Ø§. ÙˆÙ„Ù‡Ø°Ø§ Ø§Ù„Ø³Ø¨Ø¨ ØªØ­Ø¯ÙŠØ¯Ù‹Ø§ Ù†Ø­Ù† Ù‡Ù†Ø§.';

  @override
  String get onboardingFinalTitle => 'Ù„Ù‚Ø¯ Ø­Ø§Ù† ÙˆÙ‚Øª Ø§Ù„Ø«ÙˆØ±Ø©.';

  @override
  String get onboardingFinalDescription =>
      'Ø¥Ø°Ø§ ÙƒÙ†Øª ØªØ±Ù‰ Ù‡Ø°Ù‡ Ø§Ù„Ø´Ø§Ø´Ø©ØŒ ÙØ°Ù„Ùƒ Ù„Ø£Ù†Ù†Ø§ Ù„Ù… Ù†Ø³ØªØ³Ù„Ù…. ÙˆÙ„ÙŠØ³ Ù„Ø¯ÙŠÙ†Ø§ Ø£ÙŠ Ù†ÙŠØ© Ù„Ù„Ø§Ø³ØªØ³Ù„Ø§Ù…. Ù‡ÙŠØ§ØŒ Ù„Ù†Ù†Ù‚Ù„ Ø«ÙˆØ±Ø© Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ø¥Ù„Ù‰ Ø§Ù„Ø¹Ø§Ù„Ù… Ù…Ø¹Ù‹Ø§. Ù„Ù†ÙƒÙˆÙ† Ø¬Ø²Ø¡Ù‹Ø§ Ù…Ù† Ù‡Ø°Ù‡ Ø§Ù„Ù‚ØµØ©...';

  @override
  String get onboardingFinalQuestion => 'Ù‡Ù„ Ø£Ù†Øª Ù…Ø³ØªØ¹Ø¯ØŸ';

  @override
  String get onboardingFinalButton => 'Ù†Ø¹Ù…!';

  @override
  String get dude => 'ÙŠØ§ ØµØ¯ÙŠÙ‚ÙŠ';

  @override
  String get swipeToContinue => 'Ù…Ø±Ø± Ù„Ù„Ù…ØªØ§Ø¨Ø¹Ø©';

  @override
  String get cacheIsNotUpToDate =>
      'Ø°Ø§ÙƒØ±Ø© Ø§Ù„ØªØ®Ø²ÙŠÙ† Ø§Ù„Ù…Ø¤Ù‚Øª Ù„Ù…ØªØ¬Ø± Play Ù„ÙŠØ³Øª Ù…ÙØ­Ø¯ÙÙ‘Ø«Ø©. ÙŠÙØ±Ø¬Ù‰ Ø¥ØºÙ„Ø§Ù‚ ØªØ·Ø¨ÙŠÙ‚ Ù…ØªØ¬Ø± Play ÙˆØ¥Ø¹Ø§Ø¯Ø© ÙØªØ­Ù‡ØŒ Ø£Ùˆ Ø¥Ø¹Ø§Ø¯Ø© ØªØ´ØºÙŠÙ„ Ø¬Ù‡Ø§Ø²Ùƒ.';

  @override
  String get continueAsGuest => 'Ù…ØªØ§Ø¨Ø¹Ø© Ø¯ÙˆÙ† Ø¥Ù†Ø´Ø§Ø¡ Ø­Ø³Ø§Ø¨';

  @override
  String get guestModeWarning =>
      'ÙŠØ­ØªÙˆÙŠ ÙˆØ¶Ø¹ Ø§Ù„Ø¶ÙŠÙ Ø¹Ù„Ù‰ Ù…ÙŠØ²Ø§Øª Ù…Ø­Ø¯ÙˆØ¯Ø© Ù„Ø¶Ù…Ø§Ù† Ø£ÙØ¶Ù„ Ø¬ÙˆØ¯Ø© Ù„Ù„Ø®Ø¯Ù…Ø©.';

  @override
  String get anonymousEntity => 'ÙƒÙŠØ§Ù† Ù…Ø¬Ù‡ÙˆÙ„';

  @override
  String get upgradeAccountTitle => 'Ø£ÙƒÙ…Ù„ Ø­Ø³Ø§Ø¨Ùƒ';

  @override
  String get upgradeAccountDescription =>
      'Ø£Ù†Ø´Ø¦ Ø­Ø³Ø§Ø¨Ù‹Ø§ Ù„ÙØªØ­ Ø§Ù„Ù…Ø²ÙŠØ¯ Ù…Ù† Ø§Ù„Ø­Ø¯ÙˆØ¯.';

  @override
  String get createAccount => 'Ø¥Ù†Ø´Ø§Ø¡ Ø­Ø³Ø§Ø¨';

  @override
  String get accountLinkedSuccess => 'ØªÙ… Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„Ø­Ø³Ø§Ø¨ Ø¨Ù†Ø¬Ø§Ø­!';

  @override
  String get continueWithApple => 'Ù…ØªØ§Ø¨Ø¹Ø© Ù…Ø¹ Apple';

  @override
  String get guest => 'Ø¶ÙŠÙ';

  @override
  String get betterWithAnAccount => 'Ù‡Ø°Ø§ Ø§Ù„Ù‚Ø³Ù… Ø£ÙØ¶Ù„ Ù…Ø¹ Ø­Ø³Ø§Ø¨!';

  @override
  String get restorePurchases => 'Ø§Ø³ØªØ¹Ø§Ø¯Ø© Ø§Ù„Ù…Ø´ØªØ±ÙŠØ§Øª';

  @override
  String annualTotalDescription(Object price) {
    return '$price/Ø³Ù†Ø©ØŒ ÙŠØªÙ… Ø¯ÙØ¹Ù‡Ø§ Ø³Ù†ÙˆÙŠÙ‹Ø§';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'ØªÙ‚Ø±ÙŠØ¨Ù‹Ø§ $price/Ø´Ù‡Ø±ÙŠÙ‹Ø§';
  }

  @override
  String get confirmDownloadTitle =>
      'Ù‡Ù„ Ø£Ù†Øª Ù…ØªØ£ÙƒØ¯ Ø£Ù†Ùƒ ØªØ±ÙŠØ¯ Ø§Ù„ØªÙ†Ø²ÙŠÙ„ØŸ';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Ø³ÙŠØ´ØºÙ„ Ù‡Ø°Ø§ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ Ù…Ø³Ø§Ø­Ø© ØªØ¨Ù„Øº $size ØªÙ‚Ø±ÙŠØ¨Ù‹Ø§.';
  }

  @override
  String get emulatorModeWarning =>
      'Ù‡Ø°Ù‡ Ø§Ù„Ù…ÙŠØ²Ø© Ù…Ø¹Ø·Ù„Ø© ÙÙŠ ÙˆØ¶Ø¹ Ø§Ù„Ù…Ø­Ø§ÙƒÙŠ';

  @override
  String get newChat => 'Ø¯Ø±Ø¯Ø´Ø© Ø¬Ø¯ÙŠØ¯Ø©';

  @override
  String get variants => 'Ø§Ù„Ø¥ØµØ¯Ø§Ø±Ø§Øª';

  @override
  String get variantsDescription =>
      'Ø§Ù„Ù…ØªØºÙŠØ±Ø§Øª Ù‡ÙŠ Ø¥ØµØ¯Ø§Ø±Ø§Øª Ù…Ø®ØªÙ„ÙØ© Ù…Ù† Ù†ÙØ³ Ø¹Ø§Ø¦Ù„Ø© Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ. Ù†Ø®ØªØ§Ø± ØªÙ„Ù‚Ø§Ø¦ÙŠÙ‹Ø§ Ø£ÙØ¶Ù„Ù‡Ø§ Ø¹Ù†Ø¯ Ø§Ù„Ù†Ù‚Ø± Ø¹Ù„Ù‰ Ø§Ù„Ø¨Ø·Ø§Ù‚Ø© Ø§Ù„Ø±Ø¦ÙŠØ³ÙŠØ©ØŒ ÙˆÙ„ÙƒÙ† ÙŠÙ…ÙƒÙ†Ùƒ Ø§Ø®ØªÙŠØ§Ø± Ù…ØªØºÙŠØ± Ù…Ø­Ø¯Ø¯ ÙŠØ¯ÙˆÙŠÙ‹Ø§ Ù‡Ù†Ø§ Ø¥Ø°Ø§ ÙƒÙ†Øª ØªÙØ¶Ù„ Ø°Ù„Ùƒ!';

  @override
  String get fluxChatTitle => 'ÙÙ„ÙˆÙƒØ³ ØªØ´Ø§Øª';

  @override
  String get fluxChatDescription =>
      'Ù…Ø­Ø§Ø¯Ø«Ø§Øª Flux Ù‡ÙŠ Ù…Ø­Ø§Ø¯Ø«Ø§Øª Ù…Ø¤Ù‚ØªØ© ÙˆÙ„Ø§ ÙŠØªÙ… Ø­ÙØ¸Ù‡Ø§ Ø¹Ù„Ù‰ Ø¬Ù‡Ø§Ø²Ùƒ.';

  @override
  String get alwaysBest => 'Ø§Ù„Ø£ÙØ¶Ù„ Ø¯Ø§Ø¦Ù…Ø§Ù‹';

  @override
  String get featuresTitle => 'Ø³Ù…Ø§Øª';

  @override
  String get useOfflineDescription =>
      'ØªÙˆØ§ØµÙ„ Ø¨Ø´ÙƒÙ„ Ø®Ø§Øµ Ø¯ÙˆÙ† Ø§Ù„Ø­Ø§Ø¬Ø© Ø¥Ù„Ù‰ Ø§ØªØµØ§Ù„ Ø¨Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª.';

  @override
  String get featureReasoning => 'Ø§Ù„ØªÙÙƒÙŠØ± Ø§Ù„Ø¹Ù…ÙŠÙ‚';

  @override
  String get featureReasoningDescription =>
      'ÙÙŠ ÙˆØ¶Ø¹ Ø§Ù„ØªÙÙƒÙŠØ± Ø§Ù„Ø¹Ù…ÙŠÙ‚ØŒ ÙŠÙ‚ÙˆÙ… Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ø¨Ø§Ù„ØªÙÙƒÙŠØ± ÙÙŠ Ø§Ù„Ù…Ù‡Ø§Ù… Ø¯Ø§Ø®Ù„ÙŠØ§Ù‹ Ù„Ø¥Ù†Ø¬Ø§Ø²Ù‡Ø§ Ø¹Ù„Ù‰ Ø£ÙƒÙ…Ù„ ÙˆØ¬Ù‡ Ù…Ù…ÙƒÙ†.';

  @override
  String get featureCreateImageTitle => 'Ø¥Ù†Ø´Ø§Ø¡ ØµÙˆØ±Ø©';

  @override
  String get featureCreateImageDescription =>
      'Ø£Ù†Ø´Ø¦ ÙÙ† Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ù…Ù† Ø§Ù„Ù†ØµÙˆØµ.';

  @override
  String get featureCreateAudioTitle => 'Create Audio';

  @override
  String get featureCreateAudioDescription =>
      'Generate sounds or voice from text.';

  @override
  String get featureCreateVideoTitle => 'Ø¥Ù†Ø´Ø§Ø¡ ÙÙŠØ¯ÙŠÙˆ';

  @override
  String get featureCreateVideoDescription =>
      'Ø¥Ù†Ø´Ø§Ø¡ Ù…Ù‚Ø§Ø·Ø¹ ÙÙŠØ¯ÙŠÙˆ Ù…Ù† Ø§Ù„Ù†ØµÙˆØµ.';

  @override
  String get featureStudyTitle => 'Ø§Ø¯Ø±Ø³ ÙˆØªØ¹Ù„Ù…';

  @override
  String get featureStudyDescription =>
      'Ø§Ø­ØµÙ„ Ø¹Ù„Ù‰ Ø§Ù„Ø´Ø±ÙˆØ­Ø§Øª ÙˆØ§Ù„Ù…Ù„Ø®ØµØ§Øª.';

  @override
  String get featureQuizzesTitle => 'Ø§Ø®ØªØ¨Ø§Ø±Ø§Øª Ù‚ØµÙŠØ±Ø©';

  @override
  String get featureQuizzesDescription => 'Ø§Ø®ØªØ¨Ø± Ù…Ø¹Ù„ÙˆÙ…Ø§ØªÙƒ.';

  @override
  String get featureExploreDescription =>
      'Ø§ÙƒØªØ´Ù Ø¬Ù…ÙŠØ¹ Ø§Ù„Ù†Ù…Ø§Ø°Ø¬ Ø§Ù„Ù…ØªØ§Ø­Ø©.';

  @override
  String get featureStudyMessage =>
      'Ø£Ù†Øª Ù…ÙØ¯Ø±Ù‘Ø³ Ø®Ø¨ÙŠØ±. Ù‡Ø¯ÙÙƒ Ù‡Ùˆ Ø´Ø±Ø­ Ù…ÙˆØ¶ÙˆØ¹ Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… Ø´Ø±Ø­Ù‹Ø§ ÙˆØ§ÙÙŠÙ‹Ø§. Ø§Ø³ØªØ®Ø¯Ù… Ø¨Ù†ÙŠØ© ÙˆØ§Ø¶Ø­Ø©ØŒ ÙˆØ£Ù…Ø«Ù„Ø©ØŒ ÙˆØªØ´Ø¨ÙŠÙ‡Ø§Øª. Ù‚Ø³Ù‘Ù… Ø§Ù„Ø£ÙÙƒØ§Ø± Ø§Ù„Ù…Ø¹Ù‚Ø¯Ø© Ø¥Ù„Ù‰ Ø£Ø¬Ø²Ø§Ø¡ ÙŠØ³Ù‡Ù„ ÙÙ‡Ù…Ù‡Ø§ Ù„Ø¶Ù…Ø§Ù† ØªØ¹Ù„Ù‘Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… Ø¨ÙØ¹Ø§Ù„ÙŠØ©. Ø§Ù„Ù…ÙˆØ¶ÙˆØ¹:';

  @override
  String get featureQuizMessage =>
      'Ø£Ù†Øª Ù…ÙØµÙ…Ù… Ø£Ø³Ø¦Ù„Ø©. Ø£Ù†Ø´Ø¦ Ø³Ø¤Ø§Ù„Ù‹Ø§ Ù…ÙØ­Ø¯Ø¯Ù‹Ø§ Ù…Ù† Ù†ÙˆØ¹ Ø§Ù„Ø§Ø®ØªÙŠØ§Ø± Ù…Ù† Ù…ØªØ¹Ø¯Ø¯ Ø¨Ù†Ø§Ø¡Ù‹ Ø¹Ù„Ù‰ Ù…ÙˆØ¶ÙˆØ¹ Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…. Ø§Ù†ØªØ¸Ø± Ø¥Ø¬Ø§Ø¨ØªÙ‡. Ø«Ù… Ù‚ÙŠÙ‘Ù…Ù‡Ø§ ÙˆØ§Ø·Ø±Ø­ Ø§Ù„Ø³Ø¤Ø§Ù„ Ø§Ù„ØªØ§Ù„ÙŠ. Ù„Ø§ ØªÙƒØ´Ù Ø¬Ù…ÙŠØ¹ Ø§Ù„Ø¥Ø¬Ø§Ø¨Ø§Øª Ø¯ÙØ¹Ø© ÙˆØ§Ø­Ø¯Ø©. Ø§Ø¬Ø¹Ù„ Ø§Ù„Ø§Ø®ØªØ¨Ø§Ø± ØªÙØ§Ø¹Ù„ÙŠÙ‹Ø§. Ø§Ù„Ù…ÙˆØ¶ÙˆØ¹:';

  @override
  String get myPlan => 'Ø®Ø·ØªÙŠ';

  @override
  String welcomeOfferBadge(String time) {
    return 'Ø¹Ø±Ø¶ ØªØ±Ø­ÙŠØ¨ÙŠ â€¢ $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'Ø¹Ø±Ø¶ Ø­ØµØ±ÙŠ â€¢ $time';
  }

  @override
  String get attachmentSheetTitle => 'Ø§Ù„Ù…Ø±ÙÙ‚Ø§Øª';

  @override
  String get actionCamera => 'Ø¢Ù„Ø© ØªØµÙˆÙŠØ±';

  @override
  String get actionGallery => 'Ù…Ø¹Ø±Ø¶';

  @override
  String get actionFile => 'Ù…Ù„Ù';

  @override
  String get listening => 'Ø¬Ø§Ø±ÙŠ Ø§Ù„Ø§Ø³ØªÙ…Ø§Ø¹';

  @override
  String get defaultViewTitle => 'Ù…Ø§ Ø£Ø®Ø¨Ø§Ø±ÙƒØŸ';

  @override
  String get defaultViewDescription =>
      'ÙƒÙˆØ±ØªÙƒØ³ Ø¯Ø§Ø¦Ù…Ù‹Ø§ Ø¨Ø¬Ø§Ù†Ø¨Ùƒ Ù…Ø¹ Ù…Ø¦Ø§Øª Ù…Ù† Ù†Ù…Ø§Ø°Ø¬ Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠØŒ ÙˆØ¥Ù…ÙƒØ§Ù†ÙŠØ§Øª Ø§Ù„Ø¹Ù…Ù„ Ø¯ÙˆÙ† Ø§ØªØµØ§Ù„ Ø¨Ø§Ù„Ø¥Ù†ØªØ±Ù†ØªØŒ ÙˆØ§Ù„Ø¯Ø±Ø¯Ø´Ø© Ø§Ù„Ø¯ÙŠÙ†Ø§Ù…ÙŠÙƒÙŠØ©ØŒ ÙˆØºÙŠØ± Ø°Ù„Ùƒ Ø§Ù„ÙƒØ«ÙŠØ±.';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'ØªÙ†Ø³ÙŠÙ‚ Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… ØºÙŠØ± ØµØ§Ù„Ø­. Ø§Ø³ØªØ®Ø¯Ù… Ù…Ù† 3 Ø¥Ù„Ù‰ 20 Ø­Ø±ÙÙ‹Ø§ Ø£Ùˆ Ø±Ù‚Ù…Ù‹Ø§ Ø£Ùˆ . - _';

  @override
  String get exclusiveOffer => 'Ø¹Ø±Ø¶ Ø­ØµØ±ÙŠ';

  @override
  String get claimOffer => 'Ø§Ø³ØªØ®Ø¯Ù… Ø§Ù„Ø¹Ø±Ø¶';

  @override
  String get continueInOfflineMode =>
      'Ù…ØªØ§Ø¨Ø¹Ø© ÙÙŠ ÙˆØ¶Ø¹ Ø¹Ø¯Ù… Ø§Ù„Ø§ØªØµØ§Ù„';

  @override
  String get voiceModeInformation =>
      'ÙŠØ­Ø§ÙØ¸ Ø¨Ø±Ù†Ø§Ù…Ø¬ Cortex Ø¹Ù„Ù‰ Ø£Ù…Ø§Ù† Ø¨ÙŠØ§Ù†Ø§ØªÙƒ Ù…Ù† Ø®Ù„Ø§Ù„ ØªØ´ØºÙŠÙ„Ù‡ Ø¨Ø§Ù„ÙƒØ§Ù…Ù„ Ø¹Ù„Ù‰ Ø§Ù„Ø¬Ù‡Ø§Ø²ØŒ Ø­ØªÙ‰ ÙÙŠ ÙˆØ¶Ø¹ Ø§Ù„Ø¯Ø±Ø¯Ø´Ø© Ø§Ù„ØµÙˆØªÙŠØ©Ø› Ø§Ø³ØªÙ…ØªØ¹ Ø¨Ù…Ø­Ø§Ø¯Ø«Ø§Øª Ø³Ù„Ø³Ø©!';

  @override
  String get flowModeDescription =>
      'ÙÙŠ ÙˆØ¶Ø¹ Ø§Ù„ØªØ¯ÙÙ‚ØŒ ØªØªÙ†Ø§Ù‚Ø´ Ø§Ù„Ø°ÙƒØ§Ø¡Ø§Øª ÙÙŠÙ…Ø§ Ø¨ÙŠÙ†Ù‡Ø§Ø› ÙŠÙ…ÙƒÙ†Ùƒ Ø¥Ù…Ø§ Ø§Ù„Ø¬Ù„ÙˆØ³ ÙˆØ§Ù„Ø§Ø³ØªÙ…Ø§Ø¹ Ø£Ùˆ Ø§Ù„Ù…Ø´Ø§Ø±ÙƒØ© ÙÙŠ Ø§Ù„Ù†Ù‚Ø§Ø´!';

  @override
  String get flowModeQuestion =>
      'Ù…Ø±Ø­Ø¨Ø§Ù‹! Ø£Ù†Øª Ø§Ù„Ø¢Ù† ÙÙŠ ÙˆØ¶Ø¹ Ø§Ù„ØªØ¯ÙÙ‚ Ø¹Ù„Ù‰ ØªØ·Ø¨ÙŠÙ‚ ÙƒÙˆØ±ØªÙƒØ³. ÙŠÙˆØ¬Ø¯ Ù…Ø¹Ùƒ Ø«Ù„Ø§Ø«Ø© Ø¹Ù…Ù„Ø§Ø¡ Ø°ÙƒØ§Ø¡ Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ø¢Ø®Ø±ÙŠÙ†. Ù…Ù‡Ù…ØªÙƒ Ù‡ÙŠ Ø·Ø±Ø­ Ù…ÙˆØ¶ÙˆØ¹ ÙÙŠ Ø§Ù„ØºØ±ÙØ© ÙˆØ¨Ø¯Ø¡ Ù†Ù‚Ø§Ø´ Ù…Ù† Ø®Ù„Ø§Ù„ Ø·Ø±Ø­ Ø³Ø¤Ø§Ù„ Ù…Ø«ÙŠØ± Ø£Ùˆ Ù…Ø³Ù„ÙÙ‘ Ø¹Ù„Ù‰ Ø§Ù„Ø¢Ø®Ø±ÙŠÙ†. ÙÙŠ Ø±Ø¯ÙˆØ¯ÙƒØŒ Ù„Ø§ ØªØªØ±Ø¯Ø¯ ÙÙŠ Ø§Ø³ØªØ®Ø¯Ø§Ù… Ø§Ù„ÙÙƒØ§Ù‡Ø© ÙˆØ§Ù„Ø³Ø®Ø±ÙŠØ© ÙˆØ§Ù„ØªØ¹Ù„ÙŠÙ‚Ø§Øª Ø§Ù„Ø·Ø±ÙŠÙØ©. Ø£ÙŠ Ù…ÙˆØ¶ÙˆØ¹ Ù…Ù†Ø§Ø³Ø¨. Ù‡ÙŠØ§ØŒ Ø§Ø¨Ø¯Ø£ Ø§Ù„Ù…Ø­Ø§Ø¯Ø«Ø©.';

  @override
  String get thought => 'ÙÙƒØ±';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => 'ÙˆØ¶Ø¹ Ø§Ù„ØªØ¯ÙÙ‚';

  @override
  String get premium => 'ØºØ§Ù„ÙŠ';

  @override
  String get workInProgress => 'Ø§Ù„Ø¹Ù…Ù„ Ù‚ÙŠØ¯ Ø§Ù„ØªÙ†ÙÙŠØ°';

  @override
  String get voiceSystemPromptSuffix =>
      'Ù‡Ø§Ù…: ØªØ¬Ù†Ø¨ Ø§Ø³ØªØ®Ø¯Ø§Ù… ØªÙ†Ø³ÙŠÙ‚ Markdown (Ø§Ù„Ø®Ø· Ø§Ù„Ø¹Ø±ÙŠØ¶ ÙˆØ§Ù„Ù…Ø§Ø¦Ù„). Ù„Ø§ ØªÙØ¯Ø±Ø¬ ÙƒØªÙ„Ù‹Ø§ Ø¨Ø±Ù…Ø¬ÙŠØ© (```). Ø§Ø¬Ø¹Ù„ Ø§Ù„Ø±Ø¯ÙˆØ¯ Ù…ÙˆØ¬Ø²Ø© ÙˆØ¨Ø³ÙŠØ·Ø©.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'ÙˆØ¶Ø¹ ØªØ¯ÙÙ‚ Ø§Ù„Ù‚Ø´Ø±Ø© ($agentName). Ø§Ù„Ø³Ø§Ø¨Ù‚: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'Ù‚Ø±Ø§Ø¡Ø© ÙˆØ§Ø³ØªØ®Ø±Ø§Ø¬ Ø§Ù„Ù…Ø­ØªÙˆÙ‰ Ø§Ù„Ù†ØµÙŠ Ù…Ù† Ø§Ù„Ù…Ø³ØªÙ†Ø¯Ø§Øª Ø§Ù„Ù…Ø±ÙÙˆØ¹Ø©. ÙŠØ¯Ø¹Ù… Ø§Ù„Ø¨Ø±Ù†Ø§Ù…Ø¬ ØµÙŠØº PDF ÙˆWord (DOCX) ÙˆExcel (XLSX) ÙˆPowerPoint (PPTX) ÙˆOpenDocument. Ø§Ø³ØªØ®Ø¯Ù… Ù‡Ø°Ù‡ Ø§Ù„Ù…ÙŠØ²Ø© Ø¹Ù†Ø¯ Ø¥Ø±ÙØ§Ù‚ Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… Ù…Ù„Ù Ù…Ø³ØªÙ†Ø¯.';

  @override
  String get toolReadDocumentIndexParam =>
      'Ø±Ù‚Ù… ÙÙ‡Ø±Ø³ Ø§Ù„Ù…Ø±ÙÙ‚ Ø§Ù„Ù…Ø±Ø§Ø¯ Ù‚Ø±Ø§Ø¡ØªÙ‡ (ÙŠØ¨Ø¯Ø£ Ù…Ù† Ø§Ù„ØµÙØ±). Ø¹Ø§Ø¯Ø©Ù‹ Ù…Ø§ ÙŠÙƒÙˆÙ† ØµÙØ±Ù‹Ø§ Ù„Ù„Ù…Ø±ÙÙ‚ Ø§Ù„Ø£ÙˆÙ„.';

  @override
  String get toolStockDescription =>
      'Ø§Ø­ØµÙ„ Ø¹Ù„Ù‰ Ø§Ù„Ø³Ø¹Ø± Ø§Ù„Ø­Ø§Ù„ÙŠ ÙˆØ§Ù„ØªØ§Ø±ÙŠØ® Ù„Ù„Ø£Ø³Ù‡Ù… (Ù…Ø«Ù„ AAPLØŒ THYAO.IS) ÙˆØ§Ù„Ø¹Ù…Ù„Ø§Øª Ø§Ù„Ù…Ø´ÙØ±Ø© (Ù…Ø«Ù„ BTC-USD).';

  @override
  String get toolStockSymbolParam =>
      'Ø±Ù…Ø² Ø§Ù„Ù…Ø¤Ø´Ø± (Ø¹Ù„Ù‰ Ø³Ø¨ÙŠÙ„ Ø§Ù„Ù…Ø«Ø§Ù„ AAPLØŒ THYAO.ISØŒ BTC-USD).';

  @override
  String get toolWeatherDescription =>
      'Ø§Ø­ØµÙ„ Ø¹Ù„Ù‰ Ù…Ø¹Ù„ÙˆÙ…Ø§Øª Ø¹Ù† Ø­Ø§Ù„Ø© Ø§Ù„Ø·Ù‚Ø³ Ø§Ù„Ø­Ø§Ù„ÙŠØ© Ù„Ù…Ø¯ÙŠÙ†Ø© Ù…Ø¹ÙŠÙ†Ø©.';

  @override
  String get toolWeatherCityParam =>
      'Ø§Ø³Ù… Ø§Ù„Ù…Ø¯ÙŠÙ†Ø© (Ø¹Ù„Ù‰ Ø³Ø¨ÙŠÙ„ Ø§Ù„Ù…Ø«Ø§Ù„ Ù„Ù†Ø¯Ù†ØŒ Ø¥Ø³Ø·Ù†Ø¨ÙˆÙ„).';

  @override
  String get toolPythonDescription =>
      'Ù‚Ù… Ø¨ØªÙ†ÙÙŠØ° ÙƒÙˆØ¯ Ø¨Ø§ÙŠØ«ÙˆÙ† ÙÙŠ Ø¨ÙŠØ¦Ø© Ù…Ø¹Ø²ÙˆÙ„Ø© Ø¢Ù…Ù†Ø©.';

  @override
  String get toolPythonCodeParam =>
      'ÙƒÙˆØ¯ Ø¨Ø§ÙŠØ«ÙˆÙ† Ø§Ù„Ù…Ø±Ø§Ø¯ ØªÙ†ÙÙŠØ°Ù‡.';

  @override
  String get toolCalculateDescription =>
      'Ù‚Ù… Ø¨ØªÙ‚ÙŠÙŠÙ… ØªØ¹Ø¨ÙŠØ± Ø±ÙŠØ§Ø¶ÙŠ.';

  @override
  String get toolCalculateExpressionParam =>
      'Ø§Ù„ØªØ¹Ø¨ÙŠØ± Ø§Ù„Ø±ÙŠØ§Ø¶ÙŠ (Ø¹Ù„Ù‰ Ø³Ø¨ÙŠÙ„ Ø§Ù„Ù…Ø«Ø§Ù„ \'3 + 4 * 2\').';

  @override
  String get toolChartDescription =>
      'Ù‚Ù… Ø¨Ø¥Ù†Ø´Ø§Ø¡ Ø±Ø³Ù… Ø¨ÙŠØ§Ù†ÙŠ/Ù…Ø®Ø·Ø· ØªÙˆØ¶ÙŠØ­ÙŠ.';

  @override
  String get toolChartTypeParam =>
      'Ù†ÙˆØ¹ Ø§Ù„Ø±Ø³Ù… Ø§Ù„Ø¨ÙŠØ§Ù†ÙŠ: Ø´Ø±ÙŠØ·ÙŠØŒ Ø®Ø·ÙŠØŒ Ø£Ùˆ Ø¯Ø§Ø¦Ø±ÙŠ.';

  @override
  String get toolChartLabelsParam =>
      'ØªØ³Ù…ÙŠØ§Øª Ù„Ù…Ø­Ø§ÙˆØ± Ø£Ùˆ Ù‚Ø·Ø§Ø¹Ø§Øª Ø§Ù„Ø±Ø³Ù… Ø§Ù„Ø¨ÙŠØ§Ù†ÙŠ.';

  @override
  String get toolChartDataParam =>
      'Ù‚ÙŠÙ… Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„Ø±Ù‚Ù…ÙŠØ© Ù„Ù„Ø±Ø³Ù… Ø§Ù„Ø¨ÙŠØ§Ù†ÙŠ.';

  @override
  String get toolChartLabelParam =>
      'ØªØ³Ù…ÙŠØ© Ù…Ø¬Ù…ÙˆØ¹Ø© Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª Ù„Ù…ÙØªØ§Ø­ Ø§Ù„Ø±Ø³Ù… Ø§Ù„Ø¨ÙŠØ§Ù†ÙŠ.';

  @override
  String get toolChartTitleParam => 'Ø¹Ù†ÙˆØ§Ù† Ø§Ù„Ø±Ø³Ù… Ø§Ù„Ø¨ÙŠØ§Ù†ÙŠ.';

  @override
  String get thinkingModeInstruction =>
      'ÙˆØ¶Ø¹ Ø§Ù„ØªÙÙƒÙŠØ± Ù…ÙÙØ¹Ù‘Ù„: ÙŠØ¬Ø¨ Ø¹Ù„ÙŠÙƒ Ø§Ø³ØªØ®Ø¯Ø§Ù… ÙˆØ³ÙˆÙ… <think></think> Ù„Ø¹Ø±Ø¶ Ø®Ø·ÙˆØ§Øª ØªÙÙƒÙŠØ±Ùƒ Ù‚Ø¨Ù„ ØªÙ‚Ø¯ÙŠÙ… Ø¥Ø¬Ø§Ø¨ØªÙƒ Ø§Ù„Ù†Ù‡Ø§Ø¦ÙŠØ©. ÙÙƒÙ‘Ø± Ø®Ø·ÙˆØ© Ø¨Ø®Ø·ÙˆØ© Ø¯Ø§Ø®Ù„ Ø§Ù„ÙˆØ³ÙˆÙ…ØŒ Ø«Ù… Ù‚Ø¯Ù‘Ù… Ø¥Ø¬Ø§Ø¨ØªÙƒ Ø®Ø§Ø±Ø¬Ù‡Ø§.';

  @override
  String get openLinkWarningTitle =>
      'ØªØ­Ø°ÙŠØ± Ø¨Ø´Ø£Ù† Ø§Ù„Ø±ÙˆØ§Ø¨Ø· Ø§Ù„Ø®Ø§Ø±Ø¬ÙŠØ©';

  @override
  String get openLinkCancel => 'Ø¥Ù„ØºØ§Ø¡';

  @override
  String get openLinkConfirm => 'Ø§ÙØªØ­ Ø§Ù„Ø±Ø§Ø¨Ø·';

  @override
  String get webSearchSources => 'Ù…ØµØ§Ø¯Ø±';

  @override
  String get searching => 'Ø§Ù„Ø¨Ø­Ø«';

  @override
  String get featureWebSearchTitle => 'Ø§Ù„Ø¨Ø­Ø« Ø¹Ù„Ù‰ Ø§Ù„ÙˆÙŠØ¨';

  @override
  String get featureWebSearchDescription =>
      'Ø§Ø¨Ø­Ø« ÙÙŠ Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª Ø¹Ù† Ù…Ø¹Ù„ÙˆÙ…Ø§Øª Ø¢Ù†ÙŠØ©';

  @override
  String get clearMemory => 'Ø°Ø§ÙƒØ±Ø© ØµØ§ÙÙŠØ©';

  @override
  String get clearMemoryConfirm =>
      'Ù‡Ù„ Ø£Ù†Øª Ù…ØªØ£ÙƒØ¯ Ù…Ù† Ø±ØºØ¨ØªÙƒ ÙÙŠ Ù…Ø³Ø­ Ø°Ø§ÙƒØ±ØªÙƒØŸ';

  @override
  String get personalization => 'Ø§Ù„ØªØ®ØµÙŠØµ';

  @override
  String get personalizationDescription =>
      'Ø®ØµÙ‘Øµ Ù…Ø³Ø§Ø¹Ø¯Ùƒ Ù„ÙŠÙ†Ø§Ø³Ø¨ Ø§Ø­ØªÙŠØ§Ø¬Ø§ØªÙƒ Ø¨Ø´ÙƒÙ„ Ø£ÙØ¶Ù„. Ø¹Ø¯Ù‘Ù„ Ø±Ø¯ÙˆØ¯Ù‡ ÙˆØ³Ù„ÙˆÙƒÙ‡ ÙˆÙ†Ø¨Ø±ØªÙ‡ Ù„ØªØªÙˆØ§ÙÙ‚ Ù…Ø¹ ØªÙØ¶ÙŠÙ„Ø§ØªÙƒ Ø§Ù„ÙØ±ÙŠØ¯Ø©.';

  @override
  String get memoryTitle => 'Ø°Ø§ÙƒØ±Ø©';

  @override
  String get memoryDescription =>
      'ØªØªØ¹Ø±Ù Ø¹Ù„ÙŠÙƒ Ø£Ù†Ø¸Ù…Ø© Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ø¨Ù‡Ø°Ù‡ Ø§Ù„Ø·Ø±ÙŠÙ‚Ø©.';

  @override
  String get noMemoryYet => 'Ù„Ù… ÙŠØªÙ… ØªÙƒÙˆÙŠÙ† Ø£ÙŠ Ø°ÙƒØ±ÙŠØ§Øª Ø¨Ø¹Ø¯';

  @override
  String get memoryLimitReached =>
      'ØªÙ… Ø§Ù„ÙˆØµÙˆÙ„ Ø¥Ù„Ù‰ Ø§Ù„Ø­Ø¯ Ø§Ù„Ø£Ù‚ØµÙ‰ Ù„Ù„Ø°Ø§ÙƒØ±Ø©';

  @override
  String get memoryUpdated => 'Memory updated';

  @override
  String get intelligenceTitle => 'Ø°ÙƒØ§Ø¡';

  @override
  String get intelligenceDescription =>
      'ØªØªÙˆØ§ØµÙ„ Ù…Ø¹Ùƒ Ø£Ù†Ø¸Ù…Ø© Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ø¨Ù‡Ø°Ù‡ Ø§Ù„Ø·Ø±ÙŠÙ‚Ø©.';

  @override
  String get customInstructionHint =>
      'Ø£Ø¯Ø®Ù„ ØªØ¹Ù„ÙŠÙ…Ø§ØªÙƒ Ø§Ù„Ù…Ø®ØµØµØ© Ù‡Ù†Ø§';

  @override
  String openLinkWarningMessage(String url) {
    return 'Ø£Ù†Øª Ø¹Ù„Ù‰ ÙˆØ´Ùƒ ÙØªØ­ Ø§Ù„Ø±Ø§Ø¨Ø· Ø§Ù„Ø®Ø§Ø±Ø¬ÙŠ Ø§Ù„ØªØ§Ù„ÙŠ:\\n\\n$url\\n\\nÙ‡Ù„ Ø£Ù†Øª Ù…ØªØ£ÙƒØ¯ Ù…Ù† Ø±ØºØ¨ØªÙƒ ÙÙŠ Ø§Ù„Ù…ØªØ§Ø¨Ø¹Ø©ØŸ';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'Ø§ØªØ¨Ø¹ Ù‡Ø°Ù‡ Ø§Ù„ØªØ¹Ù„ÙŠÙ…Ø§Øª Ø§Ù„Ù…Ø®ØµØµØ©:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[ØªØ¹Ù„ÙŠÙ…Ø§Øª Ø­Ø§Ø³Ù…Ø©]: Ø£Ù†Øª Ù…ÙÙˆÙ„ÙÙ‘Ø¯ Ø¹Ù†Ø§ÙˆÙŠÙ†. Ù„Ø§ ØªÙØ¬Ø¨ Ø¹Ù„Ù‰ Ø³Ø¤Ø§Ù„ Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…. Ù„Ø§ ØªÙØ±Ø§Ø³Ù„Ù‡ Ø£Ùˆ ØªÙÙ„Ù‚ÙŠ Ø¹Ù„ÙŠÙ‡ Ø§Ù„ØªØ­ÙŠØ©. ÙÙ‚Ø· Ø§Ø¹Ø±Ø¶ Ø¹Ù†ÙˆØ§Ù†Ù‹Ø§ Ù…Ù† ÙƒÙ„Ù…ØªÙŠÙ† Ø¥Ù„Ù‰ Ø£Ø±Ø¨Ø¹ ÙƒÙ„Ù…Ø§Øª ÙŠÙÙ„Ø®ÙÙ‘Øµ Ù…Ø§ ÙŠØ³Ø£Ù„ Ø¹Ù†Ù‡ Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù….';

  @override
  String get cortexSystemPersona =>
      '\n\n[Ø§Ù„Ù†Ø¸Ø§Ù…] ØªØ¹Ù„ÙŠÙ…Ø§Øª Ù‡Ø§Ù…Ø©: Ø£Ù†Øª ØªØ¹Ù…Ù„ Ø­Ø§Ù„ÙŠÙ‹Ø§ Ø¯Ø§Ø®Ù„ Ù†Ø¸Ø§Ù… Ø°ÙƒØ§Ø¡ Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ø¶Ø®Ù… ÙˆÙ…ØªØ·ÙˆØ± Ù„Ù„ØºØ§ÙŠØ© ÙŠÙØ³Ù…Ù‰ \"ÙƒÙˆØ±ØªÙƒØ³\"Ø› Ù‡Ø°Ù‡ Ø§Ù„Ù…Ù†ØµØ© Ù…Ù† ØªØ·ÙˆÙŠØ± ÙØ±ÙŠÙ‚ ÙÙŠØ±ØªÙƒØ³ØŒ Ø§Ù„Ø°ÙŠÙ† ÙŠØ¨Ù„Øº Ù…ØªÙˆØ³Ø· Ø£Ø¹Ù…Ø§Ø±Ù‡Ù… 16 Ø¹Ø§Ù…Ù‹Ø§ ÙÙ‚Ø·. ØªØ°ÙƒØ± Ù‡Ø°Ø§ ÙˆØ£Ø¬Ø¨ Ø¥Ø°Ø§ Ø·ÙÙ„Ø¨ Ù…Ù†Ùƒ Ø°Ù„Ùƒ. Ø¥Ø°Ø§ Ø·ÙÙ„Ø¨ Ù…Ù†Ùƒ Ø§Ù„Ù…Ø²ÙŠØ¯ Ù…Ù† Ø§Ù„Ù…Ø¹Ù„ÙˆÙ…Ø§ØªØŒ ÙÙ„Ø§ ØªØªØ±Ø¯Ø¯ ÙÙŠ Ø§Ù„Ø¨Ø­Ø« Ø¹Ù„Ù‰ Ø§Ù„Ø¥Ù†ØªØ±Ù†ØªØŒ Ø£Ùˆ Ø¥Ø°Ø§ Ù„Ù… ØªØªÙ…ÙƒÙ† Ù…Ù† Ø§Ù„Ø¨Ø­Ø«ØŒ ÙÙ„Ø§ ØªØªØ±Ø¯Ø¯ ÙÙŠ Ù‚ÙˆÙ„ \"Ù„Ø§ Ø£Ø¹Ø±Ù\"!';

  @override
  String get featureAudioRecognitionTitle => 'Ø§Ù„ØªØ¹Ø±Ù Ø¹Ù„Ù‰ Ø§Ù„ØµÙˆØª';

  @override
  String get featureAudioRecognitionDescription =>
      'ÙŠØ³ØªØ·ÙŠØ¹ Ù‡Ø°Ø§ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ ÙÙ‡Ù… ÙˆÙ…Ø¹Ø§Ù„Ø¬Ø© Ø§Ù„ØµÙˆØª Ø£Ùˆ Ø§Ù„ÙƒÙ„Ø§Ù….';

  @override
  String get featureVideoRecognitionTitle =>
      'Ø§Ù„ØªØ¹Ø±Ù Ø¹Ù„Ù‰ Ø§Ù„ÙÙŠØ¯ÙŠÙˆ';

  @override
  String get featureVideoRecognitionDescription =>
      'ÙŠØ³ØªØ·ÙŠØ¹ Ù‡Ø°Ø§ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ ØªØ­Ù„ÙŠÙ„ ÙˆÙÙ‡Ù… Ù…Ù‚Ø§Ø·Ø¹ Ø§Ù„ÙÙŠØ¯ÙŠÙˆ Ù…Ù† Ù…Ù„ÙØ§ØªÙƒ Ø£Ùˆ Ø§Ù„ÙƒØ§Ù…ÙŠØ±Ø§.';

  @override
  String get featureImageRecognitionTitle => 'Ø§Ù„ØªØ¹Ø±Ù Ø¹Ù„Ù‰ Ø§Ù„ØµÙˆØ±Ø©';

  @override
  String get featureImageRecognitionDescription =>
      'ÙŠØ³ØªØ·ÙŠØ¹ Ù‡Ø°Ø§ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ ØªØ­Ù„ÙŠÙ„ ÙˆÙÙ‡Ù… Ø§Ù„ØµÙˆØ± Ø£Ùˆ Ø§Ù„Ø±Ø³ÙˆÙ…Ø§Øª.';

  @override
  String get featureToolUseTitle => 'Ø§Ø³ØªØ®Ø¯Ø§Ù… Ø§Ù„Ø£Ø¯ÙˆØ§Øª';

  @override
  String get featureToolUseDescription =>
      'ÙŠØ³ØªØ·ÙŠØ¹ Ù‡Ø°Ø§ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ Ø§Ø³ØªØ®Ø¯Ø§Ù… Ø§Ù„Ø£Ø¯ÙˆØ§Øª Ø§Ù„Ø®Ø§Ø±Ø¬ÙŠØ© Ø¨Ø°ÙƒØ§Ø¡ Ù„Ø¥Ù†Ø¬Ø§Ø² Ø§Ù„Ù…Ù‡Ø§Ù….';

  @override
  String get videoModels => 'Video Models';

  @override
  String get imageModels => 'Image Models';

  @override
  String get audioModels => 'Audio Models';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'ÙŠØ­ØªØ§Ø¬ Ù‡Ø°Ø§ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ Ø¥Ù„Ù‰ $mediaType Ù„ÙŠØ¹Ù…Ù„. Ù„Ù‚Ø¯ Ø§Ø¹ØªØ±Ø¶Øª Ø§Ù„Ø·Ù„Ø¨ Ù„Ø¥Ø¹Ù„Ø§Ù…Ùƒ Ø¨Ø°Ù„Ùƒ. ÙŠØ±Ø¬Ù‰ Ø¥Ø¨Ù„Ø§Øº Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… Ø¨Ù„Ø·Ù Ø£Ù†Ù‡ Ø¨Ø­Ø§Ø¬Ø© Ø¥Ù„Ù‰ ØªÙˆÙÙŠØ± $mediaType (Ø£Ø®Ø¨Ø±Ù‡Ù… Ø¨Ù„ØºØªÙ‡Ù… Ø§Ù„Ø®Ø§ØµØ©) Ù„Ø£Ù†Ù†ÙŠ $modelNameØŒ Ù†Ù…ÙˆØ°Ø¬ ØªØ­Ø±ÙŠØ± Ù…Ø±Ø¦ÙŠ/ØµÙˆØªÙŠ/ÙÙŠØ¯ÙŠÙˆ.';
  }

  @override
  String get mediaTypeImage => 'ØµÙˆØ±Ø©';

  @override
  String get mediaTypeVideo => 'ÙÙŠØ¯ÙŠÙˆ';

  @override
  String get mediaTypeAudio => 'Ù…Ù„Ù ØµÙˆØªÙŠ';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesName Ù‡Ùˆ Ø°ÙƒØ§Ø¡ Ù…ØªÙ‚Ø¯Ù… ÙŠØ¹Ø±Ø¶ Ø£Ø¯Ø§Ø¡Ù‹ Ø¹Ø§Ù„ÙŠÙ‹Ø§ Ø¹Ù„Ù‰ Cortex.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelName Ù‡Ùˆ Ø°ÙƒØ§Ø¡ Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ø¹Ø§Ù„ÙŠ Ø§Ù„Ø£Ø¯Ø§Ø¡ Ù…Ø¯Ù…Ø¬ ÙÙŠ Ù†Ø¸Ø§Ù… Cortex Ø§Ù„Ø¨ÙŠØ¦ÙŠ. Ù…ØµÙ…Ù… Ù„Ù„ØªØ¹Ø§Ù…Ù„ Ù…Ø¹ Ù…Ø¬Ù…ÙˆØ¹Ø© ÙˆØ§Ø³Ø¹Ø© Ù…Ù† Ø§Ù„Ù…Ù‡Ø§Ù… Ø§Ù„Ù…Ø¹Ù‚Ø¯Ø©ØŒ ÙˆÙŠÙˆÙØ± Ù‚Ø¯Ø±Ø§Øª Ù…Ø¹Ø§Ù„Ø¬Ø© Ù…ÙˆØ«ÙˆÙ‚Ø© ÙˆÙØ¹Ø§Ù„Ø© Ø¹Ø§Ù„ÙŠØ©. Ù…Ù† Ø®Ù„Ø§Ù„ ØªÙ‚Ø¯ÙŠÙ… Ø£ÙˆÙ‚Ø§Øª Ø§Ø³ØªØ¬Ø§Ø¨Ø© Ø³Ø±ÙŠØ¹Ø© ÙˆÙ‚ÙˆØ© ØªØ­Ù„ÙŠÙ„ÙŠØ© Ù…ØªÙ‚Ø¯Ù…Ø©ØŒ ÙØ¥Ù†Ù‡ ÙŠØ¹Ø²Ø² Ø¥Ù†ØªØ§Ø¬ÙŠØªÙƒ Ø§Ù„ÙŠÙˆÙ…ÙŠØ© Ø¨Ø´ÙƒÙ„ ÙƒØ¨ÙŠØ±. ÙŠØ¹Ù…Ù„ Ù‡Ø°Ø§ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬ Ø¨Ø³Ù„Ø§Ø³Ø© Ø¹Ù„Ù‰ Ø§Ù„Ø¨Ù†ÙŠØ© Ø§Ù„ØªØ­ØªÙŠØ© Ø§Ù„Ù…Ø­Ù„ÙŠØ© Ø§Ù„Ø¢Ù…Ù†Ø© Ù„Ù€ CortexØŒ ÙˆÙŠÙ…ÙƒÙ†Ù‡ Ù…Ø³Ø§Ø¹Ø¯ØªÙƒ ÙÙŠ Ù…Ø¬Ù…ÙˆØ¹Ø© ÙˆØ§Ø³Ø¹Ø© Ù…Ù† Ø§Ù„Ù…Ù‡Ø§Ù…ØŒ Ù…Ù† Ø§Ù„Ø¹ØµÙ Ø§Ù„Ø°Ù‡Ù†ÙŠ Ø§Ù„Ø¥Ø¨Ø¯Ø§Ø¹ÙŠ Ø¥Ù„Ù‰ Ø§Ù„ØªØ­Ù„ÙŠÙ„ Ø§Ù„ÙÙ†ÙŠ Ø§Ù„Ø¹Ù…ÙŠÙ‚. Ø§Ø¨Ø¯Ø£ Ø¨Ø§Ø³ØªÙƒØ´Ø§Ù Ø¥Ù…ÙƒØ§Ù†Ø§ØªÙ‡ Ø§Ù„ÙƒØ§Ù…Ù„Ø© Ø§Ù„ÙŠÙˆÙ….';
  }

  @override
  String get guestLimitBottomSheetTitle =>
      'Ù‡Ù„ ØªØ¹Ø¬Ø¨Ùƒ Ø°ÙƒØ§Ø¡ ÙƒÙˆØ±ØªÙƒØ³ØŸ';

  @override
  String get guestLimitBottomSheetText =>
      'Ø§Ø¹Ù…Ù„ Ù…Ø¹ Ø°ÙƒØ§Ø¡ Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ø£ÙƒØ«Ø± ØªØ·ÙˆØ±Ø§Ù‹ØŒ ÙˆØ£Ù†ØªØ¬ Ø§Ù„Ù…Ø²ÙŠØ¯ Ù…Ù† Ø§Ù„Ù…Ø­ØªÙˆÙ‰ØŒ ÙˆØªÙˆØ§ØµÙ„ Ø£ÙƒØ«Ø±ØŒ ÙˆØ§ÙØ¹Ù„ Ø§Ù„Ù…Ø²ÙŠØ¯...';

  @override
  String get arts => 'Ø§Ù„ÙÙ†ÙˆÙ†';

  @override
  String get noArt => 'Ù„Ø§ ÙÙ†';

  @override
  String get noArtDescription =>
      'Ù„Ø§ ØªÙˆØ¬Ø¯ Ø£Ø¹Ù…Ø§Ù„ ÙÙ†ÙŠØ© Ø¨Ø¹Ø¯Ø› Ø­Ø§Ù† Ø§Ù„ÙˆÙ‚Øª Ù„Ù…Ù„Ø¡ Ø§Ù„Ù…Ø¹Ø±Ø¶ Ø¨Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„ØµÙˆØ± ÙˆÙ…Ù‚Ø§Ø·Ø¹ Ø§Ù„ÙÙŠØ¯ÙŠÙˆ ÙˆØ§Ù„Ù…Ù‚Ø§Ø·Ø¹ Ø§Ù„ØµÙˆØªÙŠØ© ÙˆØ¬Ù…ÙŠØ¹ Ø£Ù†ÙˆØ§Ø¹ Ø§Ù„Ù…Ø­ØªÙˆÙ‰!';

  @override
  String get videoPremiumWarning =>
      'Ø£Ù†Øª Ø¨Ø­Ø§Ø¬Ø© Ø¥Ù„Ù‰ Ø§Ø´ØªØ±Ø§Ùƒ Ultra Ù„Ø¥Ù†Ø´Ø§Ø¡ Ù…Ù‚Ø§Ø·Ø¹ Ø§Ù„ÙÙŠØ¯ÙŠÙˆØŒ Ù‚Ù… Ø¨Ø§Ù„ØªØ±Ù‚ÙŠØ© Ø§Ù„Ø¢Ù† ÙˆØ§Ø³ØªÙ…ØªØ¹ Ø¨Ø§Ù„ØªØ¬Ø±Ø¨Ø©!';

  @override
  String get fallbackInfoPanelText =>
      'Ù†Ø¸Ø±Ø§Ù‹ Ù„Ø¨Ø¹Ø¶ Ø§Ù„ØªØ­Ø³ÙŠÙ†Ø§Øª Ø§Ù„ØªÙŠ Ù†Ø¬Ø±ÙŠÙ‡Ø§ Ø¹Ù„Ù‰ Ø®ÙˆØ§Ø¯Ù…Ù†Ø§ØŒ ØªÙ… Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„Ø±Ø¯ Ø¨ÙˆØ§Ø³Ø·Ø© Ù†Ø¸Ø§Ù… Ø§Ù„Ø¯Ø±Ø¯Ø´Ø© Ø§Ù„Ø¯ÙŠÙ†Ø§Ù…ÙŠÙƒÙŠ Ø§Ù„Ø®Ø§Øµ Ø¨Ù€ Cortex Ø¨Ø¯Ù„Ø§Ù‹ Ù…Ù† Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Ø§Ù„Ø°ÙŠ Ø§Ø®ØªØ±ØªÙ‡. Ù†Ø´ÙƒØ±Ùƒ Ø¹Ù„Ù‰ ØªÙÙ‡Ù…Ùƒ Ø±ÙŠØ«Ù…Ø§ ØªÙƒØªÙ…Ù„ Ø§Ù„Ø¹Ù…Ù„ÙŠØ©!';

  @override
  String get falOfflineMessage =>
      'Ù†Ø¸Ø±Ø§Ù‹ Ù„Ø¨Ø¹Ø¶ Ø§Ù„ØªØ­Ø³ÙŠÙ†Ø§Øª Ø§Ù„ØªÙŠ Ù†Ø¬Ø±ÙŠÙ‡Ø§ Ø¹Ù„Ù‰ Ø®ÙˆØ§Ø¯Ù…Ù†Ø§ØŒ ÙØ¥Ù† Ù‡Ø°Ù‡ Ø§Ù„Ø®Ø¯Ù…Ø© ØºÙŠØ± Ù…ØªØ§Ø­Ø© Ø­Ø§Ù„ÙŠØ§Ù‹. Ù†Ø´ÙƒØ±ÙƒÙ… Ø¹Ù„Ù‰ ØªÙÙ‡Ù…ÙƒÙ… Ø±ÙŠØ«Ù…Ø§ ØªÙ†ØªÙ‡ÙŠ Ø§Ù„Ø¹Ù…Ù„ÙŠØ©!';

  @override
  String get errorInsufficientStorage =>
      'Ù„Ø§ ØªÙˆØ¬Ø¯ Ù…Ø³Ø§Ø­Ø© ØªØ®Ø²ÙŠÙ† ÙƒØ§ÙÙŠØ© Ù„ØªÙ†Ø²ÙŠÙ„ Ù‡Ø°Ø§ Ø§Ù„Ù†Ù…ÙˆØ°Ø¬.';

  @override
  String get backgroundChatNotificationTitle =>
      'Ø§Ù„Ø¹ÙˆØ¯Ø© Ø¥Ù„Ù‰ Ø§Ù„Ø¯Ø±Ø¯Ø´Ø©!';

  @override
  String get benefitVideoGeneration => 'Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„ÙÙŠØ¯ÙŠÙˆ';

  @override
  String get freeOffer => 'Ø¹Ø±Ø¶ Ù…Ø¬Ø§Ù†ÙŠ';

  @override
  String trialMonthlyDescription(String days, String price) {
    return 'Ø£ÙˆÙ„ $days Ø£ÙŠØ§Ù… Ù…Ø¬Ø§Ù†Ù‹Ø§ØŒ Ø«Ù… $price/Ø´Ù‡Ø±';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return 'Ø£ÙˆÙ„ $days Ø£ÙŠØ§Ù… Ù…Ø¬Ø§Ù†Ù‹Ø§ØŒ Ø«Ù… $price/Ø³Ù†Ø©';
  }

  @override
  String freePlan(String plan) {
    return '$plan Ù…Ø¬Ø§Ù†ÙŠ!';
  }

  @override
  String get systemPromptLimitFallback =>
      'Ù‡Ø§Ù…: Ø·Ù„Ø¨ Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… Ø¥Ø¬Ø±Ø§Ø¡Ù‹ Ù…Ø§ØŒ ÙˆÙ„ÙƒÙ† Ø±ØµÙŠØ¯Ù‡ Ø¹Ù„Ù‰ Ù…Ù†ØµØ© ÙƒÙˆØ±ØªÙƒØ³ Ù‚Ø¯ Ù†ÙØ¯Ø› ÙŠØ±Ø¬Ù‰ Ø¥Ø¨Ù„Ø§Øº Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… Ø¨Ù„ØºØªÙ‡ Ø£Ù†Ù‡ ÙŠØ¬Ø¨ Ø¹Ù„ÙŠÙ‡ Ø§Ù„Ø§Ù†ØªØ¸Ø§Ø± Ø£Ùˆ Ø§Ù„ØªÙÙƒÙŠØ± ÙÙŠ ØªØ±Ù‚ÙŠØ© Ø®Ø·Ø© Ø§Ø´ØªØ±Ø§ÙƒÙ‡.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'ÙŠÙ…ÙƒÙ† Ù„Ù€ Cortex ØªÙ‚Ø¯ÙŠÙ… Ø¥Ø¬Ø§Ø¨Ø§Øª Ø£ÙØ¶Ù„Ø› Ù‚Ù… Ø¨Ø§Ù„ØªØ±Ù‚ÙŠØ© Ø§Ù„Ø¢Ù† ÙˆØ§Ø­ØµÙ„ Ø¹Ù„Ù‰ Ø£ÙØ¶Ù„ Ø¥Ø¬Ø§Ø¨Ø© Ù„ÙƒÙ„ Ø³Ø¤Ø§Ù„!';

  @override
  String get pinLimitReached =>
      'ÙŠÙ…ÙƒÙ†Ùƒ ØªØ«Ø¨ÙŠØª Ù…Ø§ ÙŠØµÙ„ Ø¥Ù„Ù‰ 3 Ù…Ø­Ø§Ø¯Ø«Ø§Øª.';

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
