// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'Ğ�ы — Ğ�Ğ�Ğ�Ğ�рĞ�тĞ�р Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�. Ğ�тĞ�Ğ�чĞ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� 2-5 сĞ�Ğ�Ğ� Ğ�Ğ�я сĞ�Ğ�Ğ�ующĞ�Ğ�Ğ� рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�. Ğ�Ğ� Ğ�сĞ�Ğ�Ğ�ьĞ�уĞ�тĞ� Ğ�Ğ�Ğ�ычĞ�Ğ�, Ğ�рĞ�фĞ�Ğ�сы Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я. Ğ�Ğ�Ğ�Ğ�Ğ�: Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�ыть Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�, чтĞ� Ğ� сĞ�Ğ�Ğ�щĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�я.';

  @override
  String get systemRoleFallback => 'Ğ�ы — Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ�щĞ�Ğ�Ğ�.';

  @override
  String get systemLanguageInstruction =>
      '\n\nCRITICAL: Ğ�сĞ�Ğ�Ğ�Ğ� Ğ�тĞ�Ğ�чĞ�Ğ�тĞ� Ğ�Ğ� тĞ�Ğ� Ğ�Ğ� яĞ�ыĞ�Ğ�, Ğ�Ğ� Ğ�Ğ�тĞ�рĞ�Ğ� Ğ�Ğ�шĞ�т Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�ь, Ğ�Ğ�рĞ�щĞ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� яĞ�ыĞ� Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�я.';

  @override
  String get systemNotePreviousMedia =>
      '[Ğ�Ğ�стĞ�Ğ�Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�чĞ�Ğ�Ğ�Ğ�: Ğ�Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�стĞ�Ğ�Ğ�Ğ�Ğ�ы рĞ�Ğ�Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�рĞ�рĞ�Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�фĞ�Ğ�Ğ�ы. Ğ�ы Ğ�Ğ�Ğ�Ğ�тĞ� ссыĞ�Ğ�ться Ğ�Ğ� Ğ�Ğ�х Ğ�Ğ�Ğ� рĞ�Ğ�Ğ�Ğ�тĞ�рĞ�Ğ�Ğ�ть.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return '\n\nĞ�Ğ�Ğ�ущĞ�я Ğ�Ğ�тĞ� Ğ� Ğ�рĞ�Ğ�я: $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\nĞ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�руĞ�тĞ� рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�р Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�т. Ğ�сĞ�Ğ� Ğ�ы уĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�-Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�ыĞ� уĞ�Ğ�Ğ�Ğ�Ğ�ьĞ�ыĞ� фĞ�Ğ�ты Ğ� Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�Ğ� (Ğ�рĞ�Ğ�Ğ�Ğ�чтĞ�Ğ�Ğ�я, Ğ�Ğ�я, Ğ�рĞ�Ğ�ычĞ�Ğ�, Ğ�Ğ�Ğ�тĞ�Ğ�ст), Ğ�ы Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�ыĞ�Ğ�стĞ� Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ую Ğ�Ğ�фĞ�рĞ�Ğ�цĞ�ю Ğ� Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�Ğ� Ğ�Ğ�утрĞ� тĞ�Ğ�Ğ�Ğ� <memory>...</memory> Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�шĞ�Ğ�Ğ� Ğ�тĞ�Ğ�тĞ�. Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�: Ğ�ы Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�ы стĞ�рĞ�ть Ğ�Ğ�Ğ� Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�сыĞ�Ğ�ть Ğ�рĞ�Ğ�ыĞ�ущую Ğ�Ğ�фĞ�рĞ�Ğ�цĞ�ю. Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�яĞ�тĞ� Ğ�Ğ�Ğ�ыĞ� фĞ�Ğ�ты Ğ� сущĞ�стĞ�ующĞ�Ğ� Ğ�Ğ�фĞ�рĞ�Ğ�цĞ�Ğ�. Ğ�сĞ�Ğ� Ğ�Ğ�сĞ�Ğ�ютĞ�Ğ� Ğ�Ğ�чĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�ыĞ�Ğ� Ğ�Ğ�Ğ�Ğ�руĞ�Ğ�Ğ�Ğ�, Ğ�Ğ�устĞ�тĞ� тĞ�Ğ�. Ğ�рĞ�Ğ�Ğ�р: <memory>Ğ�юĞ�Ğ�т футĞ�Ğ�Ğ� Ğ� тĞ�Ğ�Ğ�Ğ�с. Ğ�рĞ�Ğ�Ğ�Ğ�чĞ�тĞ�Ğ�т Ğ�Ğ�рĞ�тĞ�Ğ�Ğ� Ğ�тĞ�Ğ�ты.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return '\n\nĞ�сĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� сĞ�Ğ�Ğ�ующĞ�Ğ� Ğ� Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�Ğ�:\n$userMemory';
  }

  @override
  String get cancel => 'Ğ�тĞ�Ğ�Ğ�Ğ�';

  @override
  String get remove => 'Ğ�Ğ�Ğ�Ğ�ять';

  @override
  String get download => 'Ğ�Ğ�Ğ�чĞ�ть';

  @override
  String get resume => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ть';

  @override
  String get copy => 'Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�ть';

  @override
  String get chat => 'Ğ�Ğ�т';

  @override
  String get locked => 'Locked';

  @override
  String get languageModels => 'Ğ�Ğ�ыĞ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get light => 'Ğ�Ğ�Ğ�тĞ�Ğ�я';

  @override
  String get theme => 'Ğ�Ğ�Ğ�Ğ�';

  @override
  String get no => 'Ğ�Ğ�т';

  @override
  String get yes => 'Ğ�Ğ�';

  @override
  String get done => 'Ğ�Ğ�тĞ�Ğ�Ğ�';

  @override
  String get bestValue => 'Ğ�учшĞ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get selected => 'Ğ�ыĞ�рĞ�Ğ�Ğ�';

  @override
  String get descriptionSection => 'Ğ�Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�';

  @override
  String get searchHint => 'Ğ�Ğ�Ğ�сĞ�';

  @override
  String get messageHint => 'Ğ�Ğ�рĞ�сĞ�тĞ� чтĞ� уĞ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get messageCopied =>
      'Ğ�Ğ�Ğ�Ğ�щĞ�Ğ�Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ� Ğ� Ğ�уфĞ�р Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get retry => 'Ğ�Ğ�Ğ�тĞ�рĞ�ть';

  @override
  String get systemInfo => 'Ğ�Ğ�фĞ�рĞ�Ğ�цĞ�я Ğ� сĞ�стĞ�Ğ�Ğ�';

  @override
  String deviceMemory(Object memory) {
    return 'Ğ�Ğ�Ğ�ять устрĞ�Ğ�стĞ�Ğ�: $memory Ğ�Ğ�';
  }

  @override
  String get memory => 'Ğ�Ğ�Ğ�ять';

  @override
  String get storage => 'Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�щĞ�';

  @override
  String get freeStorage => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get totalStorage => 'Ğ�сĞ�Ğ�Ğ�';

  @override
  String get usedStorage => 'Ğ�сĞ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get totalMemory => 'Ğ�сĞ�Ğ�Ğ� Ğ�Ğ�Ğ�ятĞ�';

  @override
  String get usedMemory => 'Ğ�сĞ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�ятĞ�';

  @override
  String get modelsTitle => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�Ğ�';

  @override
  String get localModels => 'Ğ�Ğ�Ğ�Ğ�Ğ�ьĞ�ыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get selectGGUFFile => 'Ğ�ыĞ�Ğ�рĞ�тĞ� фĞ�Ğ�Ğ� GGUF';

  @override
  String get errorGGUF =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�ыĞ�Ğ�рĞ�тĞ� фĞ�Ğ�Ğ� тĞ�Ğ�ьĞ�Ğ� Ğ� фĞ�рĞ�Ğ�тĞ� GGUF.';

  @override
  String get myModels => 'Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get create => 'Ğ�Ğ�Ğ�Ğ�Ğ�ть';

  @override
  String modelProducer(Object producer) {
    return 'Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�ь: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ть';

  @override
  String get newTitle => 'Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get save => 'Ğ�Ğ�хрĞ�Ğ�Ğ�ть';

  @override
  String get noConversationsMessage =>
      'Ğ�Ğ�т чĞ�тĞ�Ğ�, Ğ�Ğ�чĞ�Ğ�тĞ� Ğ�Ğ�щĞ�ться!';

  @override
  String get startChat => 'Ğ�Ğ�чĞ�ть чĞ�т';

  @override
  String get noChats => 'Ğ�Ğ�т чĞ�тĞ�Ğ�';

  @override
  String get noStarredChats => 'Ğ�Ğ�т Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�ых чĞ�тĞ�Ğ�';

  @override
  String get noStarredChatsMessage =>
      'Ğ�ы Ğ�щё Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�Ğ�Ğ�Ğ� чĞ�т Ğ� Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get starConversation => 'Ğ� Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get unstarConversation => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get loginToYourAccount => 'Ğ�хĞ�Ğ�';

  @override
  String get createYourAccount => 'Ğ�Ğ�Ğ�Ğ�стрĞ�цĞ�я';

  @override
  String get email => 'Email';

  @override
  String get password => 'Ğ�Ğ�рĞ�Ğ�ь';

  @override
  String get confirmPassword => 'Ğ�Ğ�Ğ�тĞ�Ğ�рĞ�Ğ�тĞ� Ğ�Ğ�рĞ�Ğ�ь';

  @override
  String get invalidEmail =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�стĞ�Ğ�тĞ�Ğ�ьĞ�ыĞ� email.';

  @override
  String get invalidPassword =>
      'Ğ�Ğ�рĞ�Ğ�ь Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� сĞ�Ğ�Ğ�рĞ�Ğ�ть Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� 6 сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get rememberMe => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�Ğ�Ğ�я';

  @override
  String get forgotPassword => 'Ğ�Ğ�Ğ�ыĞ�Ğ� Ğ�Ğ�рĞ�Ğ�ь?';

  @override
  String get or => 'Ğ�Ğ�Ğ�';

  @override
  String get continueWithGoogle => 'Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ть с Google';

  @override
  String get dontHaveAccount => 'Ğ�Ğ�т Ğ�Ğ�Ğ�Ğ�уĞ�тĞ�?';

  @override
  String get alreadyHaveAccount => 'Ğ�Ğ�Ğ� Ğ�сть Ğ�Ğ�Ğ�Ğ�уĞ�т?';

  @override
  String get signUp => 'Ğ�Ğ�рĞ�Ğ�Ğ�стрĞ�рĞ�Ğ�Ğ�ться';

  @override
  String get logIn => 'Ğ�Ğ�Ğ�тĞ�';

  @override
  String get passwordsDoNotMatch => 'Ğ�Ğ�рĞ�Ğ�Ğ� Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ют.';

  @override
  String get wrongPassword => 'Ğ�Ğ�Ğ�Ğ�рĞ�ыĞ� Ğ�Ğ�рĞ�Ğ�ь.';

  @override
  String get emailAlreadyInUse => 'Ğ�тĞ�т email уĞ�Ğ� Ğ�сĞ�Ğ�Ğ�ьĞ�уĞ�тся.';

  @override
  String get weakPassword => 'Ğ�Ğ�рĞ�Ğ�ь сĞ�Ğ�шĞ�Ğ�Ğ� сĞ�Ğ�Ğ�ыĞ�.';

  @override
  String get authError => 'Ğ�шĞ�Ğ�Ğ�Ğ� Ğ�утĞ�Ğ�тĞ�фĞ�Ğ�Ğ�цĞ�Ğ�';

  @override
  String get usernameTaken =>
      'Ğ�тĞ� Ğ�Ğ�я Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�я уĞ�Ğ� Ğ�Ğ�Ğ�ятĞ�.';

  @override
  String get username => 'Ğ�Ğ�я Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�я';

  @override
  String get resendCode =>
      'Ğ�тĞ�рĞ�Ğ�Ğ�ть Ğ�Ğ�сьĞ�Ğ� с Ğ�Ğ�Ğ�тĞ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�тĞ�рĞ�Ğ�';

  @override
  String get pleaseCheckYourEmail =>
      'Ğ�тĞ�Ğ�ы Ğ�сĞ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�ть Cortex, Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�хĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�тĞ�Ğ�рĞ�Ğ�ть сĞ�Ğ�Ğ� email. \nĞ�сыĞ�Ğ�Ğ� Ğ�Ğ�я Ğ�Ğ�Ğ�тĞ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�я Ğ�ыĞ�Ğ� Ğ�тĞ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�Ğ�ш Ğ�Ğ�рĞ�с эĞ�Ğ�Ğ�трĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�чты, Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�рĞ�Ğ�Ğ�рьтĞ� Ğ�Ğ�чту.';

  @override
  String get verifyYourEmail => 'Ğ�Ğ�Ğ�тĞ�Ğ�рĞ�Ğ�тĞ� Ğ�Ğ�ш Email';

  @override
  String get seconds => 'сĞ�Ğ�уĞ�Ğ�';

  @override
  String get maxResendLimitReached =>
      'Ğ�ы Ğ�Ğ�стĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�чĞ�стĞ�Ğ� Ğ�тĞ�рĞ�Ğ�Ğ�Ğ� Ğ�Ğ�сĞ�Ğ� Ğ�Ğ�я Ğ�Ğ�Ğ�тĞ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�я.';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�тĞ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�я';

  @override
  String get verificationScreenWarning =>
      'Ğ�Ğ�Ğ�Ğ� Ğ�сĞ�Ğ� Ğ�ы Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�, 1-Ğ�Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�рĞ�Ğ�Ğ� Ğ�Ğ�рĞ�фĞ�Ğ�Ğ�цĞ�Ğ� Ğ�Ğ�Ğ�Ğ�уĞ�тĞ� Ğ�сĞ� Ğ�щĞ� Ğ�Ğ�Ğ�стĞ�уĞ�т. Ğ�сĞ�Ğ� Ğ�ы Ğ�Ğ� Ğ�Ğ�Ğ�тĞ�Ğ�рĞ�Ğ�тĞ� сĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�уĞ�т Ğ�Ğ� этĞ� Ğ�рĞ�Ğ�я, Ğ�Ğ� Ğ�уĞ�Ğ�т уĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я.';

  @override
  String get unverifiedAccountHeader =>
      'Ğ�Ğ�ш Ğ�Ğ�Ğ�Ğ�уĞ�т Ğ�Ğ� Ğ�Ğ�Ğ�тĞ�Ğ�рĞ�Ğ�ёĞ�';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Ğ�сĞ�Ğ� Ğ�ы Ğ�Ğ� Ğ�Ğ�Ğ�тĞ�Ğ�рĞ�Ğ�тĞ� сĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�уĞ�т Ğ� тĞ�чĞ�Ğ�Ğ�Ğ� $timeLeft, Ğ�Ğ� Ğ�уĞ�Ğ�т уĞ�Ğ�Ğ�ёĞ�.';
  }

  @override
  String get verifyNow => 'Ğ�Ğ�Ğ�тĞ�Ğ�рĞ�Ğ�ть сĞ�Ğ�чĞ�с';

  @override
  String get linkSent => 'Ğ�сыĞ�Ğ�Ğ� Ğ�тĞ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get accountDeletionRequested =>
      'Ğ�Ğ�ш Ğ�Ğ�Ğ�рĞ�с Ğ�Ğ� уĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�уĞ�тĞ� Ğ�Ğ�Ğ�учĞ�Ğ�, Ğ� Ğ�Ğ�ш Ğ�Ğ�Ğ�Ğ�уĞ�т тĞ�Ğ�Ğ�рь Ğ�тĞ�Ğ�ючёĞ�.';

  @override
  String get tooManyRequests => 'Ğ�Ğ�Ğ�шĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�рĞ�сĞ�Ğ�';

  @override
  String get regenerate => 'Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�рĞ�Ğ�Ğ�ть Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get confirmDeleteAccount =>
      'Ğ�ы уĞ�Ğ�рĞ�Ğ�ы, чтĞ� хĞ�тĞ�тĞ� уĞ�Ğ�Ğ�Ğ�ть сĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�уĞ�т?';

  @override
  String get deleteAccount => 'Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�Ğ�Ğ�Ğ�уĞ�т';

  @override
  String get delete => 'Ğ�Ğ�Ğ�Ğ�Ğ�ть';

  @override
  String get passwordRequired => 'Ğ�рĞ�Ğ�уĞ�тся Ğ�Ğ�рĞ�Ğ�ь.';

  @override
  String get deleteDescription =>
      'Ğ�Ğ�Ğ�Ğ�ыĞ�, Ğ�Ğ�тĞ�рыĞ� Ğ�ы уĞ�Ğ�Ğ�Ğ�тĞ�, Ğ�уĞ�ут Ğ�Ğ�Ğ�сĞ�Ğ�Ğ�Ğ� уĞ�Ğ�Ğ�Ğ�Ğ�ы с Ğ�Ğ�шĞ�Ğ�Ğ� сĞ�рĞ�Ğ�рĞ� Ğ� Ğ�Ğ�шĞ�Ğ�Ğ� устрĞ�Ğ�стĞ�Ğ�. Ğ�тĞ� Ğ�Ğ�Ğ�стĞ�Ğ�Ğ� Ğ�Ğ�Ğ�ьĞ�я Ğ�тĞ�Ğ�Ğ�Ğ�ть.';

  @override
  String get editProfile => 'Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�рĞ�Ğ�Ğ�ть Ğ�рĞ�фĞ�Ğ�ь';

  @override
  String get displayName => 'Ğ�тĞ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�я';

  @override
  String get profileUpdated => 'Ğ�рĞ�фĞ�Ğ�ь усĞ�Ğ�шĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ёĞ�';

  @override
  String get logout => 'Ğ�ыĞ�тĞ�';

  @override
  String get profile => 'Ğ�рĞ�фĞ�Ğ�ь';

  @override
  String get manageProfileDescription =>
      'Ğ�Ğ�рĞ�Ğ�Ğ�яĞ�тĞ� сĞ�Ğ�Ğ�Ğ� Ğ�рĞ�фĞ�Ğ�Ğ�Ğ�, Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�яĞ�тĞ� Ğ�Ğ�рĞ�Ğ�ь Ğ�Ğ�Ğ� Ğ�ыхĞ�Ğ�Ğ�тĞ� Ğ�Ğ� Cortex.';

  @override
  String get accessSettingsDescription =>
      'Ğ�Ğ�Ğ�учĞ�тĞ� Ğ�Ğ�Ğ�Ğ�щь, Ğ�Ğ�тĞ�Ğ�Ğ�руĞ�тĞ� Ğ�Ğ�Ğ�ы, Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�сь Cortex Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ьтĞ�сь с Ğ�Ğ�шĞ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get languageDescription =>
      'Ğ�ы Ğ�Ğ�Ğ�Ğ�тĞ� Ğ� Ğ�юĞ�Ğ�Ğ� Ğ�рĞ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ть яĞ�ыĞ� Ğ�Ğ�тĞ�рфĞ�Ğ�сĞ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ�Ğ� уĞ�Ğ�Ğ�чĞ�Ğ�Ğ�ю.';

  @override
  String get themeDescription =>
      'Ğ�ы Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�рĞ�Ğ�Ğ�ючĞ�ться Ğ�Ğ�Ğ�Ğ�у сĞ�Ğ�тĞ�Ğ�Ğ� Ğ� тёĞ�Ğ�Ğ�Ğ� тĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�у усĞ�Ğ�трĞ�Ğ�Ğ�ю. Ğ�ыĞ�рĞ�Ğ�Ğ�Ğ�я тĞ�Ğ�Ğ� Ğ�уĞ�Ğ�т Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�сĞ�Ğ�у Ğ�Ğ�тĞ�рфĞ�Ğ�су Cortex.';

  @override
  String get iHaveReadAndAgree =>
      'Ğ� Ğ�рĞ�чĞ�тĞ�Ğ�(Ğ�) Ğ� сĞ�Ğ�Ğ�Ğ�сĞ�Ğ�(Ğ�Ğ�) с усĞ�Ğ�Ğ�Ğ�яĞ�Ğ� Ğ�Ğ�сĞ�уĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я';

  @override
  String get downloading => 'Ğ�Ğ�Ğ�руĞ�Ğ�Ğ�...';

  @override
  String get downloadSuccess => 'Ğ�Ğ�Ğ�руĞ�Ğ�Ğ� усĞ�Ğ�шĞ�Ğ�';

  @override
  String get downloadFailed => 'Ğ�Ğ�Ğ�руĞ�Ğ�Ğ� Ğ�Ğ� уĞ�Ğ�Ğ�Ğ�сь';

  @override
  String downloaded(Object percent) {
    return 'Ğ�Ğ�Ğ�руĞ�Ğ�Ğ�Ğ� $percent%';
  }

  @override
  String get downloadPaused => 'Ğ�Ğ�Ğ�руĞ�Ğ�Ğ� Ğ�рĞ�Ğ�стĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get purchaseError => 'Ğ�шĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�уĞ�Ğ�Ğ�';

  @override
  String get purchasePlus => 'Ğ�уĞ�Ğ�ть Cortex Plus';

  @override
  String get plusDescription =>
      'Ğ�Ğ�Ğ�тĞ�ыĞ� Ğ�Ğ�ыт Ğ� Ğ�Ğ�Ğ�Ğ�стĞ� Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�тĞ�';

  @override
  String get annual => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я';

  @override
  String get monthly => 'Ğ�Ğ�сячĞ�Ğ�я';

  @override
  String get manageSubscription => 'Ğ�Ğ�рĞ�Ğ�Ğ�ять Ğ�Ğ�Ğ�Ğ�Ğ�сĞ�Ğ�Ğ�';

  @override
  String purchasePlan(String planName) {
    return 'Ğ�уĞ�Ğ�ть $planName';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/Ğ�Ğ�сяц, Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�сячĞ�Ğ�';
  }

  @override
  String get purchasePro => 'Ğ�уĞ�Ğ�ть Cortex Pro';

  @override
  String get proDescription =>
      'Ğ�рĞ�Ğ�Ğ�схĞ�Ğ�Ğ�ыĞ� Ğ�Ğ�ыт Ğ� Ğ�Ğ�Ğ�Ğ�стĞ� Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�тĞ�';

  @override
  String get purchaseUltra => 'Ğ�уĞ�Ğ�ть Cortex Ultra';

  @override
  String get ultraDescription =>
      'Ğ�Ğ�ршĞ�Ğ�Ğ� Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�тĞ�';

  @override
  String get upgradeSubscription => 'Ğ�Ğ�учшĞ�ть Ğ�Ğ�Ğ�Ğ�Ğ�сĞ�у';

  @override
  String get purchaseStreamError => 'Ğ�шĞ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ� Ğ�Ğ�Ğ�уĞ�Ğ�Ğ�.';

  @override
  String get productNotFound => 'Ğ�рĞ�Ğ�уĞ�т Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get noProductsFound => 'Ğ�рĞ�Ğ�уĞ�ты Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ы';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�щĞ�я этĞ�т Ğ�Ğ�Ğ�Ğ�Ğ�, Ğ�ы сĞ�Ğ�Ğ�Ğ�шĞ�Ğ�тĞ�сь с Ğ�сĞ�Ğ�Ğ�Ğ�яĞ�Ğ� Ğ�Ğ�сĞ�уĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ� Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�фĞ�Ğ�Ğ�Ğ�цĞ�Ğ�Ğ�ьĞ�Ğ�стĞ�. Ğ�ы Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�ть Ğ�Ğ� этĞ�т тĞ�Ğ�ст, чтĞ�Ğ�ы уĞ�Ğ�Ğ�ть Ğ�Ğ�Ğ�ьшĞ� Ğ� Ğ�Ğ�шĞ�х Ğ�сĞ�Ğ�Ğ�Ğ�ях Ğ�Ğ�сĞ�уĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ� Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�Ğ� Ğ�Ğ�Ğ�фĞ�Ğ�Ğ�Ğ�цĞ�Ğ�Ğ�ьĞ�Ğ�стĞ�. Ğ�Ğ�Ğ�Ğ�Ğ�сĞ�Ğ� Ğ�уĞ�Ğ�т Ğ�Ğ�тĞ�Ğ�Ğ�тĞ�чĞ�сĞ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ться, Ğ�сĞ�Ğ� Ğ�Ğ�тĞ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�уĞ�Ğ�т Ğ�тĞ�Ğ�ючĞ�Ğ�Ğ� Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�уĞ� Ğ�Ğ� 24 чĞ�сĞ� Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�чĞ�Ğ�Ğ�я тĞ�Ğ�ущĞ�Ğ�Ğ� Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�.';

  @override
  String get termsOfService => 'Ğ�сĞ�Ğ�Ğ�Ğ�я Ğ�Ğ�сĞ�уĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я';

  @override
  String get privacyPolicy => 'Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�Ğ� Ğ�Ğ�Ğ�фĞ�Ğ�Ğ�Ğ�цĞ�Ğ�Ğ�ьĞ�Ğ�стĞ�';

  @override
  String get renamed => 'Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get report => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ться';

  @override
  String get reportDialogTitle => 'Ğ�тĞ�рĞ�Ğ�Ğ�ть Ğ�Ğ�Ğ�Ğ�Ğ�у';

  @override
  String get reportDescriptionLabel => 'Ğ� чёĞ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�?';

  @override
  String get reportHarmful => 'Ğ�тĞ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�сĞ�Ğ�/Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�сĞ�Ğ�';

  @override
  String get reportNotTrue => 'Ğ�тĞ� Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�';

  @override
  String get reportNotHelpful => 'Ğ�тĞ� Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get closeButton => 'Ğ�Ğ�Ğ�рыть';

  @override
  String get submitButton => 'Ğ�тĞ�рĞ�Ğ�Ğ�ть';

  @override
  String get reportErrorMessage =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�ыĞ�Ğ�рĞ�тĞ� Ğ�Ğ�Ğ�у Ğ�рĞ�чĞ�Ğ�у Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ�ы.';

  @override
  String get capabilitiesSection => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�стĞ�';

  @override
  String get featurePhotoTitle => 'Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ� фĞ�тĞ�';

  @override
  String get featurePhotoDescription =>
      'Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�ь сĞ�Ğ�сĞ�Ğ�Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�ть фĞ�тĞ�Ğ�рĞ�фĞ�Ğ� с Ğ�Ğ�Ğ�Ğ�ры Ğ�Ğ�Ğ� Ğ�Ğ� фĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get featureOfflineTitle => 'Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�ффĞ�Ğ�Ğ�Ğ�';

  @override
  String get featureOfflineDescription =>
      'Ğ�Ğ�Ğ�усĞ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�ь Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�ючĞ�Ğ�Ğ�я Ğ� Ğ�Ğ�тĞ�рĞ�Ğ�ту, чтĞ�Ğ�ы сĞ�хрĞ�Ğ�Ğ�ть Ğ�Ğ�шĞ� Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�сĞ�Ğ�стĞ�.';

  @override
  String get featureRoleplayTitle => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ�Ğ�рĞ�';

  @override
  String get featureRoleplayDescription =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�я рĞ�Ğ�Ğ�Ğ�ых Ğ�Ğ�р Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�яют сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ть рĞ�Ğ�Ğ�Ğ�чĞ�ыĞ� чĞ�ты Ğ� сцĞ�Ğ�Ğ�рĞ�Ğ�.';

  @override
  String get roleModels => 'Ğ�Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get parameters => 'Ğ�Ğ�рĞ�Ğ�Ğ�тры';

  @override
  String get context => 'Ğ�Ğ�Ğ�тĞ�Ğ�ст';

  @override
  String get finalPreparation =>
      'Ğ�Ğ�ут Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я.';

  @override
  String get shareApp => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ться Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get ourStory => 'Ğ�Ğ�шĞ� Ğ�стĞ�рĞ�я';

  @override
  String get rateUs => 'Ğ�цĞ�Ğ�Ğ�тĞ� Ğ�Ğ�с';

  @override
  String get share => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ться';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'Ğ�ыĞ�рĞ�ть тĞ�Ğ�ст';

  @override
  String get thinking => 'Ğ�уĞ�Ğ�Ğ�т';

  @override
  String get user => 'Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�ь';

  @override
  String get help => 'Ğ�Ğ�Ğ�Ğ�щь';

  @override
  String get supportCreator => 'Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�тĞ� сĞ�Ğ�Ğ�Ğ�тĞ�Ğ�я';

  @override
  String get enterYourTag =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�тĞ� Ğ�юĞ�Ğ�Ğ�ых Ğ�Ğ�тĞ�рĞ�Ğ�! Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�х уĞ�Ğ�Ğ�Ğ�Ğ�ьĞ�ыĞ� тĞ�Ğ� Ğ�Ğ�Ğ�Ğ�, чтĞ�Ğ�ы Ğ�Ğ�Ğ�Ğ�рĞ�ть Ğ�Ğ� чĞ�сть Ğ�Ğ�шĞ�х Ğ�Ğ�Ğ�уĞ�Ğ�Ğ� Ğ� Cortex.';

  @override
  String get creatorTag => 'Ğ�Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�тĞ�Ğ�я';

  @override
  String get support => 'Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�ть';

  @override
  String get tagCannotBeEmpty =>
      'Ğ�Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�тĞ�Ğ�я Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�т Ğ�ыть Ğ�устыĞ�';

  @override
  String get userId => 'ID Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�я';

  @override
  String get deleteAllConversationsConfirmTitle => 'Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�сĞ� чĞ�ты?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Ğ�ы уĞ�Ğ�рĞ�Ğ�ы, чтĞ� хĞ�тĞ�тĞ� уĞ�Ğ�Ğ�Ğ�ть Ğ�сĞ� сĞ�Ğ�Ğ� чĞ�ты? Ğ�тĞ� Ğ�Ğ�Ğ�стĞ�Ğ�Ğ� Ğ�Ğ�Ğ�ьĞ�я Ğ�тĞ�Ğ�Ğ�Ğ�ть.';

  @override
  String get conversationDeleted => 'Ğ�Ğ�рĞ�Ğ�Ğ�сĞ�Ğ� уĞ�Ğ�Ğ�Ğ�Ğ�Ğ�!';

  @override
  String get allConversationsDeleted =>
      'Ğ�сĞ� чĞ�ты Ğ�ыĞ�Ğ� усĞ�Ğ�шĞ�Ğ� уĞ�Ğ�Ğ�Ğ�Ğ�ы!';

  @override
  String get deleteAll => 'Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�сĞ�';

  @override
  String get deleteAllConversationsButton => 'Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�сĞ� чĞ�ты';

  @override
  String get confirmWord => 'Ğ�Ğ�Ğ�Ğ�шĞ�тĞ� VERTEX';

  @override
  String get confirmWordError => 'Ğ�ы Ğ�Ğ�Ğ�Ğ�сĞ�Ğ�Ğ� Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�ьĞ�Ğ�';

  @override
  String get chinese => 'Ğ�Ğ�тĞ�Ğ�сĞ�Ğ�Ğ�';

  @override
  String get french => 'Ğ�рĞ�Ğ�цуĞ�сĞ�Ğ�Ğ�';

  @override
  String get japanese => 'Ğ�Ğ�Ğ�Ğ�сĞ�Ğ�Ğ�';

  @override
  String get dutch => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�сĞ�Ğ�Ğ�';

  @override
  String get russian => 'Ğ�уссĞ�Ğ�Ğ�';

  @override
  String get korean => 'Ğ�Ğ�рĞ�Ğ�сĞ�Ğ�Ğ�';

  @override
  String get english => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�сĞ�Ğ�Ğ�';

  @override
  String get turkish => 'Ğ�урĞ�цĞ�Ğ�Ğ�';

  @override
  String get hindi => 'Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get portuguese => 'Ğ�Ğ�ртуĞ�Ğ�Ğ�ьсĞ�Ğ�Ğ�';

  @override
  String get indonesian => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�сĞ�Ğ�Ğ�';

  @override
  String get azerbaijani => 'Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�сĞ�Ğ�Ğ�';

  @override
  String get german => 'Ğ�Ğ�Ğ�Ğ�цĞ�Ğ�Ğ�';

  @override
  String get spanish => 'Ğ�сĞ�Ğ�Ğ�сĞ�Ğ�Ğ�';

  @override
  String get italian => 'Ğ�тĞ�Ğ�ьяĞ�сĞ�Ğ�Ğ�';

  @override
  String get arabic => 'Ğ�рĞ�Ğ�сĞ�Ğ�Ğ�';

  @override
  String get ram => 'Ğ�Ğ�Ğ�';

  @override
  String get usernameTooShort =>
      'Ğ�Ğ�я Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�я сĞ�Ğ�шĞ�Ğ�Ğ� Ğ�Ğ�рĞ�тĞ�Ğ�Ğ�.';

  @override
  String get usernameTooLong =>
      'Ğ�Ğ�я Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�я Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�т Ğ�рĞ�Ğ�ышĞ�ть 16 сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get invalidUsernameCharacters =>
      'Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�сĞ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�ть тĞ�Ğ�ьĞ�Ğ� Ğ�Ğ�тĞ�Ğ�сĞ�Ğ�Ğ� Ğ�уĞ�Ğ�ы, Ğ� тĞ�Ğ�Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�Ğ�ы \'.\', \'-\', \'_\'.';

  @override
  String get noInternetConnection =>
      'Ğ�Ğ�т Ğ�Ğ�Ğ�Ğ�Ğ�ючĞ�Ğ�Ğ�я Ğ� Ğ�Ğ�тĞ�рĞ�Ğ�ту.';

  @override
  String get chats => 'Ğ�Ğ�ты';

  @override
  String get library => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�Ğ�';

  @override
  String get text => 'Ğ�Ğ�Ğ�ст';

  @override
  String get removeModel => 'Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�Ğ�Ğ�Ğ�Ğ�ь';

  @override
  String get insufficientRAM => 'Ğ�Ğ�Ğ�Ğ�стĞ�тĞ�чĞ�Ğ� Ğ�Ğ�Ğ�ятĞ�';

  @override
  String get insufficientStorage => 'Ğ�Ğ�Ğ�Ğ�стĞ�тĞ�чĞ�Ğ� Ğ�Ğ�стĞ�';

  @override
  String confirmRemoveModel(Object model) {
    return 'Ğ�ы уĞ�Ğ�рĞ�Ğ�ы, чтĞ� хĞ�тĞ�тĞ� уĞ�Ğ�Ğ�Ğ�ть Ğ�Ğ�Ğ�Ğ�Ğ�ь $model сĞ� сĞ�Ğ�Ğ�Ğ�Ğ� устрĞ�Ğ�стĞ�Ğ�? Ğ�тĞ� тĞ�Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�т Ğ� уĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ю Ğ�сĞ�х Ğ�рĞ�Ğ�ыĞ�ущĞ�х рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�, сĞ�яĞ�Ğ�Ğ�Ğ�ых с этĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�ью.';
  }

  @override
  String get noMatchingModels =>
      'Ğ�Ğ�Ğ�хĞ�Ğ�ящĞ�х Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get benefit1 =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�чĞ�Ğ�ы Ğ�Ğ�Ğ�Ğ�ты Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�чĞ�стĞ�Ğ� рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�';

  @override
  String get benefit3 => 'Ğ�ффĞ�Ğ�т Ğ�Ğ�я Ğ�рĞ�фĞ�Ğ�я';

  @override
  String get benefit4 => 'Ğ�Ğ�Ğ�чĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�счĞ�Ğ�Ğ�';

  @override
  String get benefit5 => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�ьшĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�-Ğ�Ğ�';

  @override
  String get benefit7 =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�ьĞ�ыĞ� Ğ�Ğ�Ğ�Ğ�ты Ğ�сĞ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я';

  @override
  String get benefit8 => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�яĞ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get benefit9 => 'Ğ�Ğ�Ğ�ыĞ� тĞ�Ğ�ы';

  @override
  String get benefit10 => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�ьĞ�ыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я';

  @override
  String get benefit11 => 'Ğ�Ğ�Ğ�ьшĞ� рĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�';

  @override
  String get oldBenefits =>
      'Ğ�сĞ� Ğ�рĞ�Ğ�Ğ�ущĞ�стĞ�Ğ� Ğ�рĞ�Ğ�ыĞ�ущĞ�х Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get confirm => 'Ğ�Ğ�Ğ�тĞ�Ğ�рĞ�Ğ�ть';

  @override
  String get changePassword => 'Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�Ğ�рĞ�Ğ�ь';

  @override
  String get logoutConfirmationTitle =>
      'Ğ�ы уĞ�Ğ�рĞ�Ğ�ы, чтĞ� хĞ�тĞ�тĞ� Ğ�ыĞ�тĞ�?';

  @override
  String get settings => 'Ğ�Ğ�стрĞ�Ğ�Ğ�Ğ�';

  @override
  String get language => 'Ğ�Ğ�ыĞ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я';

  @override
  String get dark => 'Ğ�ёĞ�Ğ�Ğ�я';

  @override
  String get oldPassword => 'Ğ�тĞ�рыĞ� Ğ�Ğ�рĞ�Ğ�ь';

  @override
  String get newPassword => 'Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�рĞ�Ğ�ь';

  @override
  String get passwordUpdated => 'Ğ�Ğ�рĞ�Ğ�ь Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ёĞ�.';

  @override
  String get stop => 'Ğ�тĞ�Ğ�';

  @override
  String get copyrights => 'Ğ�стĞ�чĞ�Ğ�Ğ�Ğ�';

  @override
  String get love => 'Ğ�юĞ�Ğ�Ğ�ь';

  @override
  String get nature => 'Ğ�рĞ�рĞ�Ğ�Ğ�';

  @override
  String get behindTheSlaughter => 'Ğ�Ğ� Ğ�уĞ�Ğ�сĞ�Ğ�Ğ�';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Sunset';

  @override
  String get coffee => 'Coffee';

  @override
  String get deepSpace => 'Deep Space';

  @override
  String get grayscale => 'Ğ�ттĞ�Ğ�Ğ�Ğ� сĞ�рĞ�Ğ�Ğ�';

  @override
  String get ocean => 'Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get scarletSnow => 'Ğ�Ğ�ыĞ� сĞ�Ğ�Ğ�';

  @override
  String get requestFailed =>
      'Ğ�рĞ�Ğ�Ğ�Ğ�шĞ�Ğ� Ğ�шĞ�Ğ�Ğ�Ğ�, Ğ�Ğ�Ğ�рĞ�Ğ�уĞ�тĞ� сĞ�Ğ�Ğ�Ğ�.';

  @override
  String get changeModel => 'Ğ�Ğ�Ğ�Ğ�Ğ�ть';

  @override
  String get edit => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ть';

  @override
  String get editingMessageInfo =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� этĞ�Ğ�Ğ� сĞ�Ğ�Ğ�щĞ�Ğ�Ğ�я Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�устĞ�т Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� с этĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�.';

  @override
  String get editingNotification =>
      'Ğ�ы сĞ�Ğ�чĞ�с Ğ� рĞ�Ğ�Ğ�Ğ�Ğ� рĞ�Ğ�Ğ�Ğ�тĞ�рĞ�Ğ�Ğ�Ğ�Ğ�я';

  @override
  String get featurePluralTitle => 'Ğ�Ğ�Ğ�Ğ�Ğ�стĞ�Ğ�Ğ�Ğ�Ğ�я';

  @override
  String get featurePluralDescription =>
      'Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�ь Ğ�Ğ�Ğ�Ğ�т Ğ�Ğ�тĞ�Ğ�Ğ�тĞ�чĞ�сĞ�Ğ� Ğ�Ğ�тĞ�Ğ�рĞ�рĞ�Ğ�Ğ�ть Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�ьĞ�ыĞ� рĞ�сшĞ�рĞ�Ğ�Ğ�я, тĞ�Ğ� сĞ�Ğ�ыĞ� рĞ�сшĞ�ряя сĞ�Ğ�Ğ� фуĞ�Ğ�цĞ�Ğ�Ğ�Ğ�Ğ�ьĞ�ыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�стĞ� Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ� рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�ых Ğ�Ğ�Ğ�рĞ�цĞ�Ğ� с Ğ�Ğ�Ğ�ышĞ�Ğ�Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�ьĞ�Ğ�стью.';

  @override
  String get nameLabel => 'Ğ�Ğ�я Ğ�Ğ�';

  @override
  String get summaryLabel => 'Ğ�рĞ�тĞ�Ğ�Ğ� Ğ�Ğ�Ğ�сĞ�Ğ�Ğ�Ğ� Ğ�Ğ�';

  @override
  String get add => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ть';

  @override
  String get aiExplanationTitle =>
      'Ğ�Ğ�Ğ�сĞ�Ğ�Ğ�Ğ� Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�тĞ�';

  @override
  String get aiExplanationDescription =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�рĞ�Ğ�Ğ�стĞ�Ğ�ьтĞ� Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�сĞ�Ğ�Ğ�Ğ� Ğ�рхĞ�тĞ�Ğ�туры Ğ�Ğ�шĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�, Ğ�рĞ�цĞ�ссĞ� Ğ�Ğ�учĞ�Ğ�Ğ�я, Ğ�Ğ�трĞ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�ьĞ�Ğ�стĞ�, Ğ�Ğ�Ğ�Ğ�стĞ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ� Ğ�руĞ�Ğ�х Ğ�Ğ�Ğ�Ğ�ых Ğ�сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�стĞ�Ğ�.';

  @override
  String get preInputTitle =>
      'Ğ�рĞ�Ğ�устĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�я Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�тĞ�';

  @override
  String get preInputDescription =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�рĞ�Ğ�устĞ�Ğ�Ğ�Ğ�Ğ�у, Ğ�Ğ�тĞ�рĞ�я Ğ�уĞ�Ğ�т Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�ять Ğ�Ğ�шу Ğ�Ğ�Ğ�Ğ�Ğ�ь Ğ� Ğ�рĞ�цĞ�ссĞ� сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ�Ğ�рсĞ�Ğ�Ğ�Ğ�Ğ�. Ğ� этĞ�Ğ� рĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�ы Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�ючĞ�ть Ğ�Ğ�фĞ�рĞ�Ğ�цĞ�ю Ğ� Ğ�Ğ�рсĞ�Ğ�Ğ�Ğ�Ğ�, Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�ьĞ�ыĞ� Ğ�Ğ�Ğ�тĞ�Ğ�ст Ğ� Ğ�юĞ�ыĞ� Ğ�руĞ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�, Ğ�Ğ�тĞ�рыĞ� Ğ�Ğ�Ğ�ут Ğ�Ğ�Ğ�Ğ�чь Ğ� Ğ�Ğ�Ğ�Ğ�рĞ�цĞ�Ğ� Ğ�Ğ�Ğ�тĞ�Ğ�тĞ�, сĞ�яĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� с Ğ�Ğ�рсĞ�Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get baseModelTitle => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ�ь';

  @override
  String get baseModelDescription =>
      'Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�ь Ğ�уĞ�Ğ�т Ğ�сĞ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�ться Ğ� Ğ�Ğ�чĞ�стĞ�Ğ� Ğ�сĞ�Ğ�Ğ�ы Ğ�Ğ�я Ğ�Ğ�шĞ�Ğ�Ğ� тĞ�Ğ�рĞ�Ğ�Ğ�я. Ğ�Ğ�Ğ�сь Ğ�тĞ�Ğ�рĞ�Ğ�Ğ�Ğ�тся тĞ�Ğ�ущĞ�я Ğ�ыĞ�рĞ�Ğ�Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ�ь.';

  @override
  String get summary => 'Ğ�Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�';

  @override
  String get modelUploadTitle =>
      'Ğ�Ğ�Ğ�Ğ� Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�тĞ�';

  @override
  String get modelUploadDescription =>
      'Ğ�ыĞ�Ğ�рĞ�тĞ� Ğ� Ğ�Ğ�Ğ�руĞ�Ğ�тĞ� Ğ�Ğ�шĞ� Ğ�Ğ�Ğ�Ğ�Ğ�ьĞ�ыĞ� фĞ�Ğ�Ğ�ы GGUF Ğ�ряĞ�Ğ� с Ğ�Ğ�шĞ�Ğ�Ğ� устрĞ�Ğ�стĞ�Ğ�. Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�т Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�усĞ�Ğ�ть Ğ�Ğ�Ğ�Ğ�Ğ�ь Ğ�ффĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�хĞ�Ğ�Ğ�Ğ�Ğ�стĞ� Ğ�Ğ�Ğ�Ğ�Ğ�ючĞ�Ğ�Ğ�я Ğ� Ğ�Ğ�тĞ�рĞ�Ğ�ту. Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�сь, чтĞ� фĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�т Ğ�Ğ�Ğ�стĞ�Ğ�тĞ�Ğ�ьĞ�ыĞ� фĞ�рĞ�Ğ�т GGUF Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�ьĞ�Ğ� струĞ�турĞ�рĞ�Ğ�Ğ�Ğ�. Ğ�сĞ�Ğ� фĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�ррĞ�Ğ�тĞ�Ğ� Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�ёĞ�, Cortex Ğ�Ğ�Ğ�Ğ�т рĞ�Ğ�Ğ�тĞ�ть Ğ�Ğ� тĞ�Ğ�, Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�сь, Ğ� Ğ�ы Ğ�Ğ�Ğ�Ğ�тĞ� стĞ�Ğ�Ğ�Ğ�уться с Ğ�шĞ�Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get modelUploadShortDescription =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�сь, чтĞ�Ğ�ы Ğ�ыĞ�рĞ�ть фĞ�Ğ�Ğ� .gguf с Ğ�Ğ�шĞ�Ğ�Ğ� устрĞ�Ğ�стĞ�Ğ�';

  @override
  String get you => 'Ğ�ы';

  @override
  String get removePhotoTitle => 'Ğ�Ğ�Ğ�Ğ�Ğ�ть фĞ�тĞ�';

  @override
  String get confirmRemovePhoto =>
      'Ğ�ы уĞ�Ğ�рĞ�Ğ�ы, чтĞ� хĞ�тĞ�тĞ� уĞ�Ğ�Ğ�Ğ�ть фĞ�тĞ�?';

  @override
  String get chatLengthLimitExceeded =>
      'Ğ�тĞ�т чĞ�т Ğ�рĞ�Ğ�ысĞ�Ğ� Ğ�Ğ�Ğ�Ğ�т сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�. Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�Ğ�чĞ�Ğ�тĞ� Ğ�Ğ�Ğ�ыĞ� чĞ�т Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�рĞ�тĞ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�сĞ�у.';

  @override
  String get inappropriateContentDetected =>
      'Ğ�Ğ�Ğ�Ğ�руĞ�Ğ�Ğ� Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�тĞ�Ğ�т!';

  @override
  String get offlineModelNotInstalled =>
      'Ğ�тĞ� Ğ�ффĞ�Ğ�Ğ�Ğ�-Ğ�Ğ�Ğ�Ğ�Ğ�ь Ğ�Ğ� устĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�Ğ�шĞ�Ğ� устрĞ�Ğ�стĞ�Ğ�.';

  @override
  String get reachedLimit =>
      'Ğ�ы Ğ�счĞ�рĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�т; Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�, чтĞ�Ğ�ы Ğ�Ğ�Ğ�учĞ�ть Ğ�Ğ�Ğ�ьшĞ�. (хĞ�Ğ�, Ğ�ы Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�, этĞ� Ğ�Ğ�Ğ�Ğ�Ğ�. Ğ�Ğ� сĞ�рьĞ�Ğ�Ğ�Ğ�, Ğ�рутыĞ� Ğ�тĞ�Ğ�ты стĞ�ят Ğ�Ğ�Ğ�Ğ�Ğ�, тĞ�Ğ� чтĞ� этĞ� Ğ�Ğ�Ğ�Ğ�ты Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ют Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�ть Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�.)';

  @override
  String get modality => 'Ğ�Ğ�Ğ�Ğ�Ğ�ьĞ�Ğ�сть';

  @override
  String get multimodal => 'Ğ�уĞ�ьтĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ьĞ�ыĞ�';

  @override
  String get anErrorOccurred => 'Ğ�рĞ�Ğ�Ğ�Ğ�шĞ�Ğ� Ğ�шĞ�Ğ�Ğ�Ğ�';

  @override
  String get themeLocked =>
      'Ğ�тĞ� тĞ�Ğ�Ğ� трĞ�Ğ�уĞ�т Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�ысĞ�Ğ�Ğ�Ğ�Ğ� урĞ�Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ�сĞ�Ğ�. Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, уĞ�учшĞ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�сĞ�у, чтĞ�Ğ�ы рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�ть.';

  @override
  String get pageCouldNotBeLoaded =>
      'Ğ�Ğ� уĞ�Ğ�Ğ�Ğ�сь Ğ�Ğ�Ğ�руĞ�Ğ�ть стрĞ�Ğ�Ğ�цу';

  @override
  String get checkYourInternet =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�рĞ�Ğ�Ğ�рьтĞ� Ğ�Ğ�шĞ� Ğ�Ğ�тĞ�рĞ�Ğ�т-сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ� Ğ�Ğ�Ğ�рĞ�Ğ�уĞ�тĞ� сĞ�Ğ�Ğ�Ğ�.';

  @override
  String get errorUserNotAuthenticated =>
      'Ğ�ы Ğ�Ğ�Ğ�Ğ�Ğ�ы Ğ�Ğ�Ğ�тĞ� Ğ� сĞ�стĞ�Ğ�у, чтĞ�Ğ�ы Ğ�ыĞ�Ğ�Ğ�Ğ�Ğ�ть этĞ� Ğ�Ğ�Ğ�стĞ�Ğ�Ğ�.';

  @override
  String get errorReachedLimit =>
      'Ğ�ы Ğ�Ğ�стĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�тĞ�, Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�ысĞ�Ğ�Ğ�Ğ� урĞ�Ğ�Ğ�Ğ�ь, чтĞ�Ğ�ы рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�ть Ğ�Ğ�Ğ�ьшĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�стĞ�Ğ� Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�Ğ�щĞ�Ğ�Ğ�Ğ�.';

  @override
  String get errorServer =>
      'Ğ�рĞ�Ğ�Ğ�Ğ�шĞ�Ğ� Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ�шĞ�Ğ�Ğ�Ğ� сĞ�рĞ�Ğ�рĞ�. Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�Ğ�Ğ�рĞ�Ğ�уĞ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get errorNetwork =>
      'Ğ�рĞ�Ğ�Ğ�Ğ�шĞ�Ğ� сĞ�тĞ�Ğ�Ğ�я Ğ�шĞ�Ğ�Ğ�Ğ�. Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�рĞ�Ğ�Ğ�рьтĞ� Ğ�Ğ�шĞ� сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ� Ğ�Ğ�Ğ�рĞ�Ğ�уĞ�тĞ� сĞ�Ğ�Ğ�Ğ�.';

  @override
  String get baseModelForCharacterDescription =>
      'Ğ�ыĞ�рĞ�Ğ�Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ�ь Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�т сĞ�Ğ�сĞ�Ğ�Ğ�Ğ�стĞ� Ğ�Ğ�рсĞ�Ğ�Ğ�Ğ�Ğ� Ğ� рĞ�ссуĞ�Ğ�Ğ�Ğ�Ğ�ю Ğ� Ğ�тĞ�Ğ�тĞ�Ğ�.';

  @override
  String get selectBaseModel => 'Ğ�ыĞ�Ğ�рĞ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�ую Ğ�Ğ�Ğ�Ğ�Ğ�ь';

  @override
  String get falErrorImageRequired =>
      'Ğ�Ğ�я рĞ�Ğ�Ğ�ты этĞ�Ğ�Ğ� Ğ�Ğ� трĞ�Ğ�уĞ�тся этĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�, Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�рĞ�Ğ�рĞ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ� Ğ�Ğ�Ğ�рĞ�Ğ�уĞ�тĞ� сĞ�Ğ�Ğ�Ğ�.';

  @override
  String get falErrorAudioRequired =>
      'Ğ�Ğ�я рĞ�Ğ�Ğ�ты этĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� трĞ�Ğ�уĞ�тся этĞ�Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ�уĞ�Ğ�Ğ�фĞ�Ğ�Ğ�. Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�рĞ�Ğ�рĞ�Ğ�Ğ�тĞ� Ğ�уĞ�Ğ�Ğ�фĞ�Ğ�Ğ� Ğ� Ğ�Ğ�Ğ�рĞ�Ğ�уĞ�тĞ� сĞ�Ğ�Ğ�Ğ�.';

  @override
  String get falErrorVideoRequired =>
      'Ğ�Ğ�я этĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� трĞ�Ğ�уĞ�тся Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�струĞ�цĞ�я, Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�рĞ�Ğ�рĞ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ� Ğ�Ğ�Ğ�рĞ�Ğ�уĞ�тĞ� сĞ�Ğ�Ğ�Ğ�.';

  @override
  String get falErrorImageCorrupted =>
      'Ğ�Ğ�Ğ�руĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� уĞ�Ğ�Ğ�Ğ�сь Ğ�Ğ�рĞ�Ğ�Ğ�тĞ�ть, Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�Ğ�Ğ�рĞ�Ğ�уĞ�тĞ� Ğ�руĞ�Ğ�Ğ� фĞ�рĞ�Ğ�т.';

  @override
  String get falErrorSchemaRejected =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�ь Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�хĞ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ�ыĞ�, Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�Ğ�Ğ�рĞ�Ğ�уĞ�тĞ� Ğ�руĞ�ую Ğ�Ğ�Ğ�Ğ�Ğ�ь.';

  @override
  String get falErrorSchemaInvalid =>
      'Ğ�хĞ�Ğ�ящĞ�Ğ� Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ�ыĞ�Ğ� Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ы сĞ�уĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�рĞ�цĞ�Ğ�.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'Ğ�Ğ�уĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�рĞ�цĞ�Ğ� Ğ�Ğ�рĞ�уĞ�Ğ� Ğ�шĞ�Ğ�Ğ�у (стĞ�тус $statusCode).';
  }

  @override
  String get couldNotOpenLink => 'Ğ�Ğ� уĞ�Ğ�Ğ�Ğ�сь Ğ�тĞ�рыть ссыĞ�Ğ�у';

  @override
  String get downloadStarted => 'Ğ�Ğ�Ğ�руĞ�Ğ�Ğ� Ğ�Ğ�чĞ�Ğ�Ğ�сь';

  @override
  String get notAvailable => 'Ğ�Ğ�Ğ�Ğ�стуĞ�Ğ�Ğ�';

  @override
  String get localizationWarning =>
      'Ğ�Ğ�Ğ�Ğ�тĞ�рĞ�я Ğ�Ğ�фĞ�рĞ�Ğ�цĞ�я Ğ�Ğ�Ğ�Ğ�т Ğ�ыть Ğ�Ğ�Ğ�Ğ�стуĞ�Ğ�Ğ� Ğ�Ğ� Ğ�Ğ�шĞ�Ğ� яĞ�ыĞ�Ğ� Ğ� Ğ�уĞ�Ğ�т Ğ�тĞ�Ğ�рĞ�Ğ�Ğ�ться Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�сĞ�Ğ�Ğ�.';

  @override
  String get aiTranslationWarning =>
      'Ğ�Ğ�фĞ�рĞ�Ğ�цĞ�я Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�ях Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�тся Ğ�Ğ� рĞ�Ğ�Ğ�Ğ�чĞ�ыĞ� яĞ�ыĞ�Ğ� Ğ�руĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�яĞ�Ğ� Ğ�Ğ�. Ğ�Ğ�этĞ�Ğ�у Ğ� яĞ�ыĞ�Ğ�х, Ğ�тĞ�Ğ�чĞ�ых Ğ�т Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�, Ğ�Ğ�Ğ�ут Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�Ğ�Ğ�Ğ�Ğ�чĞ�тĞ�Ğ�ьĞ�ыĞ� Ğ�Ğ�сĞ�Ğ�тĞ�Ğ�тстĞ�Ğ�я.';

  @override
  String get errorLoadingTitle => 'Ğ�Ğ� уĞ�Ğ�Ğ�Ğ�сь Ğ�Ğ�Ğ�руĞ�Ğ�ть Ğ�Ğ�Ğ�Ğ�ыĞ�';

  @override
  String get errorLoadingMessage =>
      'Ğ�ы Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�учĞ�ть Ğ�Ğ�Ğ�Ğ�хĞ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ�ыĞ� с Ğ�Ğ�шĞ�х сĞ�рĞ�Ğ�рĞ�Ğ�. Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�рĞ�Ğ�Ğ�рьтĞ� Ğ�Ğ�шĞ� Ğ�Ğ�тĞ�рĞ�Ğ�т-сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ� Ğ�Ğ�Ğ�рĞ�Ğ�уĞ�тĞ� сĞ�Ğ�Ğ�Ğ�.';

  @override
  String get noFoundTitle => 'Ğ�Ğ�т рĞ�Ğ�уĞ�ьтĞ�тĞ�Ğ�';

  @override
  String get noFoundMessage =>
      'Ğ�Ğ�Ğ�рĞ�Ğ�уĞ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ть усĞ�Ğ�Ğ�Ğ�я Ğ�Ğ�Ğ�сĞ�Ğ� Ğ�Ğ�Ğ� сĞ�рĞ�сĞ�ть фĞ�Ğ�ьтр.';

  @override
  String get modelCreatedSuccess => 'Ğ�Ğ�Ğ�Ğ�Ğ�ь усĞ�Ğ�шĞ�Ğ� сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '«$modelName» усĞ�Ğ�шĞ�Ğ� уĞ�Ğ�Ğ�Ğ�Ğ�Ğ�.';
  }

  @override
  String get errorCreatingModel =>
      'Ğ�рĞ�Ğ�Ğ�Ğ�шĞ�Ğ� Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ�шĞ�Ğ�Ğ�Ğ� Ğ�рĞ� сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get errorDeletingModel =>
      'Ğ�рĞ�Ğ�Ğ�Ğ�шĞ�Ğ� Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ�шĞ�Ğ�Ğ�Ğ� Ğ�рĞ� уĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get ultraFeatureOnly =>
      'Ğ�тĞ� фуĞ�Ğ�цĞ�я Ğ�Ğ�стуĞ�Ğ�Ğ� тĞ�Ğ�ьĞ�Ğ� Ğ�Ğ�я Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�Ğ�Ğ� Ultra.';

  @override
  String get experimentalOfflineWarning =>
      'Ğ�ффĞ�Ğ�Ğ�Ğ�-рĞ�Ğ�Ğ�Ğ� Ğ�сĞ� Ğ�щĞ� яĞ�Ğ�яĞ�тся эĞ�сĞ�Ğ�рĞ�Ğ�Ğ�Ğ�тĞ�Ğ�ьĞ�ыĞ�, Ğ� сĞ�Ğ�чĞ�Ğ�Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�ь Ğ�Ğ�Ğ�Ğ�т рĞ�Ğ�Ğ�тĞ�ть Ğ�Ğ� с Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ� эффĞ�Ğ�тĞ�Ğ�Ğ�Ğ�стью.';

  @override
  String get noConversationsToDelete =>
      'Ğ� Ğ�Ğ�с Ğ�Ğ�т чĞ�тĞ�Ğ� Ğ�Ğ�я уĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я.';

  @override
  String get reportSubmitted => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� усĞ�Ğ�шĞ�Ğ� Ğ�тĞ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get verificationDelayed =>
      'Ğ�Ğ�шĞ� Ğ�Ğ�Ğ�уĞ�Ğ�Ğ� Ğ�Ğ�Ğ�тĞ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�. Ğ�сть Ğ�Ğ�Ğ�Ğ�Ğ�ьшĞ�я Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ� Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�шĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�уĞ�тĞ�, Ğ�Ğ� сĞ�Ğ�рĞ� Ğ�Ğ�яĞ�Ğ�тся.';

  @override
  String get maintenanceTitle =>
      'Ğ�Ğ� тĞ�хĞ�Ğ�чĞ�сĞ�Ğ�Ğ� Ğ�Ğ�сĞ�уĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get maintenanceMessage =>
      'Cortex Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�стуĞ�Ğ�Ğ�, Ğ�Ğ�Ğ�Ğ� Ğ�ы Ğ�Ğ�Ğ�сĞ�Ğ� Ğ�Ğ�Ğ�Ğ�тĞ�рыĞ� Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я. Ğ�Ğ�стуĞ� Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ю Ğ�уĞ�Ğ�т Ğ�Ğ�сстĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�шĞ�Ğ� Ğ�рĞ�Ğ�я.\n\nĞ�Ğ�Ğ�сĞ�Ğ�Ğ� Ğ�Ğ� Ğ�Ğ�шĞ� тĞ�рĞ�Ğ�Ğ�Ğ�Ğ�, Ğ�Ğ�Ğ�Ğ� Ğ�ы уĞ�учшĞ�Ğ�Ğ� Ğ�Ğ�ш Ğ�Ğ�ыт.';

  @override
  String get errorPromptFlagged =>
      'Ğ�Ğ�шĞ� сĞ�Ğ�Ğ�щĞ�Ğ�Ğ�Ğ� Ğ�ыĞ�Ğ� Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ� Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�т Ğ�ыть Ğ�тĞ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get notEnoughStorage =>
      'Ğ�Ğ�Ğ�Ğ�стĞ�тĞ�чĞ�Ğ� Ğ�Ğ�стĞ� Ğ�Ğ� Ğ�Ğ�шĞ�Ğ� устрĞ�Ğ�стĞ�Ğ� Ğ�Ğ�я сĞ�хрĞ�Ğ�Ğ�Ğ�Ğ�я Ğ�Ğ�Ğ�ых сĞ�Ğ�Ğ�щĞ�Ğ�Ğ�Ğ�.';

  @override
  String get errorRateLimit =>
      'Ğ�ы сĞ�Ğ�Ğ�Ğ�Ğ�Ğ� сĞ�Ğ�шĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�я, Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�, Ğ�рĞ�Ğ�Ğ�Ğ� чĞ�Ğ� Ğ�ытĞ�ться сĞ�Ğ�Ğ�Ğ�.';

  @override
  String get errorContentFlagged =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�ь Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�т Ğ�ыть сĞ�хрĞ�Ğ�Ğ�Ğ�Ğ�, тĞ�Ğ� Ğ�Ğ�Ğ� Ğ�ё сĞ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ� Ğ�ыĞ�Ğ� Ğ�Ğ�Ğ�Ğ�чĞ�Ğ�Ğ� Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Ğ�ы Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�тĞ� уĞ�Ğ�Ğ�Ğ�ть Ğ�сĞ� чĞ�ты, Ğ�Ğ�хĞ�Ğ�ясь Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ� чĞ�тĞ�, Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, сĞ�Ğ�чĞ�Ğ�Ğ� Ğ�ыĞ�Ğ�Ğ�тĞ� Ğ�Ğ� тĞ�Ğ�ущĞ�Ğ�Ğ� чĞ�тĞ�, чтĞ�Ğ�ы Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ть.';

  @override
  String get invalidCredentials => 'Ğ�Ğ�Ğ�Ğ�рĞ�ыĞ� email Ğ�Ğ�Ğ� Ğ�Ğ�рĞ�Ğ�ь.';

  @override
  String get userDisabled =>
      'Ğ�тĞ�т Ğ�Ğ�Ğ�Ğ�уĞ�т Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�я Ğ�ыĞ� Ğ�тĞ�Ğ�ючёĞ�.';

  @override
  String get loginSubtitle =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ� сĞ�Ğ�ю учётĞ�ую Ğ�Ğ�Ğ�Ğ�сь Vertex. Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я, Ğ�ы сĞ�Ğ�Ğ�Ğ�шĞ�Ğ�тĞ�сь с Ğ�Ğ�шĞ�Ğ�Ğ� Ğ�сĞ�Ğ�Ğ�Ğ�яĞ�Ğ� Ğ�Ğ�сĞ�уĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ� Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�фĞ�Ğ�Ğ�Ğ�цĞ�Ğ�Ğ�ьĞ�Ğ�стĞ�.';

  @override
  String get registerSubtitle =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� учётĞ�ую Ğ�Ğ�Ğ�Ğ�сь Vertex Ğ�Ğ�я Ğ�Ğ�сĞ�рĞ�Ğ�ятстĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�стуĞ�Ğ� Ğ�Ğ� Ğ�сĞ�Ğ� Ğ�Ğ�шĞ�Ğ� сĞ�рĞ�Ğ�сĞ�Ğ�. Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я, Ğ�ы сĞ�Ğ�Ğ�Ğ�шĞ�Ğ�тĞ�сь с Ğ�Ğ�шĞ�Ğ�Ğ� Ğ�сĞ�Ğ�Ğ�Ğ�яĞ�Ğ� Ğ�Ğ�сĞ�уĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ� Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�фĞ�Ğ�Ğ�Ğ�цĞ�Ğ�Ğ�ьĞ�Ğ�стĞ�.';

  @override
  String get storagePermissionRequired =>
      'Ğ�Ğ�я сĞ�хрĞ�Ğ�Ğ�Ğ�Ğ�я Ğ�Ğ�Ğ�руĞ�Ğ�Ğ�Ğ�ых Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� трĞ�Ğ�уĞ�тся рĞ�Ğ�рĞ�шĞ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�Ğ�стуĞ� Ğ� хрĞ�Ğ�Ğ�Ğ�Ğ�щу. Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�рĞ�Ğ�Ğ�стĞ�Ğ�ьтĞ� рĞ�Ğ�рĞ�шĞ�Ğ�Ğ�Ğ� Ğ�Ğ�я Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я.';

  @override
  String get inviteShareSubject =>
      'Ğ�рĞ�сĞ�Ğ�Ğ�Ğ�Ğ�яĞ�ся Ğ�Ğ� Ğ�Ğ�Ğ� Ğ� Cortex!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'Ğ�Ğ�у Ğ�сть Ğ�Ğ�шĞ�Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� cortex Ğ�сĞ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�шĞ�Ğ�шь Ğ�Ğ�рĞ�Ğ� Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�ют хĞ�Ğ�яĞ�Ğ�ыĞ� Ğ�Ğ�юс Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�\n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Ğ�рĞ�Ğ�Ğ�тся Cortex?';

  @override
  String get reviewHelpUsGrow =>
      'Ğ�Ğ�шĞ� Ğ�цĞ�Ğ�Ğ�Ğ� — этĞ� Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ� Ğ�Ğ�я Ğ�Ğ�шĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�-Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ы, Ğ� Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�т Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�ть Cortex Ğ�щё Ğ�учшĞ� Ğ�Ğ�я Ğ�Ğ�с.';

  @override
  String get reviewMaybeLater => 'Ğ�Ğ�Ğ�Ğ�т Ğ�ыть, Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get reviewRateNow => 'Ğ�цĞ�Ğ�Ğ�ть сĞ�Ğ�чĞ�с';

  @override
  String get noThanks => 'Ğ�Ğ�т, сĞ�Ğ�сĞ�Ğ�Ğ�';

  @override
  String get updateRequiredTitle => 'Ğ�рĞ�Ğ�уĞ�тся Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get updateRequiredMessage =>
      'Ğ�тĞ�Ğ�ы Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�сĞ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�ть Cortex, Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�рсĞ�Ğ�, чтĞ�Ğ�ы Ğ�Ğ�Ğ�учĞ�ть Ğ�Ğ�Ğ�ыĞ� фуĞ�Ğ�цĞ�Ğ� Ğ� Ğ�Ğ�Ğ�Ğ�ыĞ� уĞ�учшĞ�Ğ�Ğ�я.';

  @override
  String get updateNowButton => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ть сĞ�Ğ�чĞ�с';

  @override
  String get creatorSupportedSuccess =>
      'Ğ�Ğ�тĞ�р усĞ�Ğ�шĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�! Ğ�Ğ�шĞ� Ğ�уĞ�ущĞ�Ğ� Ğ�Ğ�Ğ�уĞ�Ğ�Ğ� Ğ�уĞ�ут Ğ�Ğ�Ğ�сĞ�ть Ğ�Ğ�Ğ�Ğ�Ğ� Ğ� Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�у.';

  @override
  String get featureDocumentTitle => 'Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ� Ğ�Ğ�Ğ�уĞ�Ğ�Ğ�тĞ�Ğ�';

  @override
  String get featureDocumentDescription =>
      'Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�ь Ğ�Ğ�Ğ�Ğ�т Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�ть Ğ� Ğ�тĞ�Ğ�чĞ�ть Ğ�Ğ� Ğ�Ğ�Ğ�рĞ�сы Ğ� Ğ�Ğ�Ğ�руĞ�Ğ�Ğ�Ğ�ых Ğ�Ğ�Ğ�уĞ�Ğ�Ğ�тĞ�х, тĞ�Ğ�Ğ�х Ğ�Ğ�Ğ� PDF-фĞ�Ğ�Ğ�ы Ğ� тĞ�Ğ�стĞ�Ğ�ыĞ� фĞ�Ğ�Ğ�ы.';

  @override
  String get featureImageGenerationTitle =>
      'Ğ�Ğ�Ğ�Ğ�рĞ�цĞ�я Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get featureImageGenerationDescription =>
      'Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�ь Ğ�Ğ�Ğ�Ğ�т сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ьĞ�ыĞ� Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�я Ğ�Ğ� Ğ�сĞ�Ğ�Ğ�Ğ� Ğ�Ğ�шĞ�х тĞ�Ğ�стĞ�Ğ�ых Ğ�Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�.';

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
  String get premiumModelNoticeTitle => 'Ğ�рĞ�Ğ�Ğ�уĞ�-Ğ�Ğ�Ğ�Ğ�Ğ�ь';

  @override
  String get premiumModelNoticeDescription =>
      'Ğ�тĞ�т Ğ�Ğ� яĞ�Ğ�яĞ�тся Ğ�рĞ�Ğ�Ğ�уĞ� Ğ�Ğ�, Ğ�Ğ�сĞ�Ğ�Ğ�тĞ�ыĞ� Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�Ğ� Ğ�Ğ�Ğ�ют Ğ�Ğ�рĞ�Ğ�Ğ�чĞ�Ğ�Ğ�ыĞ� Ğ�Ğ�стуĞ� Ğ� Ğ�рĞ�Ğ�Ğ�уĞ� Ğ�Ğ�; Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�чĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�стуĞ�Ğ�!';

  @override
  String get benefitPremiumModels => 'Ğ�Ğ�стуĞ� Ğ� Ğ�рĞ�Ğ�Ğ�уĞ�-Ğ�Ğ�Ğ�Ğ�Ğ�яĞ�';

  @override
  String get premiumTrialExhaustedMessage =>
      'Ğ�ы Ğ�сĞ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�сĞ� Ğ�Ğ�сĞ�Ğ�Ğ�тĞ�ыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ыĞ� сĞ�Ğ�Ğ�щĞ�Ğ�Ğ�я Ğ�Ğ�я Ğ�рĞ�Ğ�Ğ�уĞ�-Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�. Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�ысĞ�Ğ�Ğ�Ğ� урĞ�Ğ�Ğ�Ğ�ь, чтĞ�Ğ�ы Ğ�Ğ�Ğ�учĞ�ть Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�чĞ�Ğ�Ğ�ыĞ� Ğ�Ğ�стуĞ�.';

  @override
  String get useOffline => 'Ğ�сĞ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�ть Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�рĞ�Ğ�тĞ�';

  @override
  String get explore => 'Ğ�ссĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ть';

  @override
  String get news => 'Ğ�Ğ�Ğ�Ğ�стĞ�';

  @override
  String get createAI => 'Ğ�Ğ�Ğ�Ğ�Ğ�ть';

  @override
  String get shortcuts => 'Ğ�рĞ�ыĞ�Ğ�';

  @override
  String get allModels => 'Ğ�сĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get onlineModels => 'Ğ�Ğ�ыĞ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get offlineModels => 'Ğ�ффĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get characterModels => 'Ğ�Ğ�рсĞ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get customModels => 'Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�ьсĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get dynamicChatTitle => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�чĞ�сĞ�Ğ�Ğ� чĞ�т';

  @override
  String get errorNoModelsAvailable =>
      'Ğ� Ğ�Ğ�стĞ�ящĞ�Ğ� Ğ�рĞ�Ğ�я Ğ�Ğ�т Ğ�Ğ�стуĞ�Ğ�ых Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�. Ğ�рĞ�Ğ�Ğ�рьтĞ� Ğ�Ğ�Ğ�Ğ�Ğ�ючĞ�Ğ�Ğ�Ğ� Ğ� Ğ�Ğ�тĞ�рĞ�Ğ�ту Ğ� Ğ�Ğ�Ğ�тĞ�рĞ�тĞ� Ğ�Ğ�Ğ�ытĞ�у.';

  @override
  String get notificationComebackTitle => 'Ğ�ы сĞ�учĞ�Ğ�Ğ� Ğ�Ğ� тĞ�Ğ�Ğ�!';

  @override
  String get notificationComebackBody =>
      'Ğ�Ğ�ссĞ�Ğ�Ğ�ьтĞ�сь, этĞ� Ğ�Ğ� сĞ�Ğ�Ğ�щĞ�Ğ�Ğ�Ğ� Ğ�т Ğ�Ğ�шĞ�Ğ�Ğ� Ğ�ыĞ�шĞ�Ğ�Ğ�. Ğ�Ğ� Ğ�ы *Ğ�Ğ�Ğ�Ğ�тĞ�* сĞ�Ğ�Ğ�Ğ�ть сĞ�Ğ�Ğ�Ğ�Ğ� Ğ�ыĞ�шĞ�Ğ�Ğ� Ğ� Cortex! Ğ�Ğ�Ğ�Ğ�рĞ�щĞ�Ğ�тĞ�сь.';

  @override
  String get notificationLongTimeNoSeeTitle =>
      'Ğ�рĞ�шĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�сь с Ğ�Ğ�шĞ�Ğ� Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�сĞ�Ğ�ы. Ğ�Ğ�хĞ�Ğ�Ğ�тĞ� Ğ�Ğ�сĞ�Ğ�трĞ�ть, чтĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get notificationHowAreYouTitle => 'Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�?';

  @override
  String get notificationHowAreYouBody =>
      'Ğ�Ğ�ссĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ� Ğ�Ğ�Ğ� Ğ�сĞ�Ğ� этĞ�Ğ�.';

  @override
  String get notificationNewYearTitle => 'Ğ� Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�! ğ���';

  @override
  String get notificationNewYearBody =>
      'Ğ�усть Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�сĞ�т Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�рĞ�Ğ�ьĞ�, счĞ�стьĞ� Ğ� Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�чĞ�ыĞ� тĞ�Ğ�рчĞ�сĞ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�цĞ�Ğ�Ğ�; Cortex Ğ�сĞ�Ğ�Ğ�Ğ� ряĞ�Ğ�Ğ� с Ğ�Ğ�Ğ�Ğ�!';

  @override
  String get notificationValentinesDayTitle =>
      'Ğ�юĞ�Ğ�Ğ�ь Ğ�Ğ�тĞ�Ğ�т Ğ� Ğ�Ğ�Ğ�Ğ�ухĞ�! ❤️';

  @override
  String get notificationValentinesDayBody =>
      'Ğ� Ğ�Ğ�ёĞ� сĞ�ятĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�Ğ�! Ğ� Ğ�щё, MEHTAP, Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�!';

  @override
  String get notificationAtaturkRemembranceTitle =>
      'Ğ� уĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ� тĞ�сĞ�Ğ�Ğ�';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�щĞ�Ğ�у Ğ�Ğ�Ğ�чĞ�Ğ�ы Ğ�ы с Ğ�Ğ�чтĞ�Ğ�Ğ�Ğ�Ğ� чтĞ�Ğ� Ğ�Ğ�Ğ�ять Ğ�сĞ�Ğ�Ğ�Ğ�тĞ�Ğ�я Ğ�урĞ�цĞ�Ğ�Ğ� Ğ�Ğ�сĞ�уĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ� Ğ�устĞ�фы Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ�тĞ�тюрĞ�Ğ�.';

  @override
  String get notificationMothersDayTitle => 'Ğ�Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�!';

  @override
  String get notificationMothersDayBody =>
      'Ğ� Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�рĞ� Ğ�сĞ�х Ğ�Ğ�Ğ�, Ğ� Ğ�Ğ�чĞ�Ğ�Ğ�я с Ğ�Ğ�шĞ�Ğ�!';

  @override
  String get notificationFathersDayTitle => 'Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�!';

  @override
  String get notificationFathersDayBody =>
      'Ğ� Ğ�Ğ�Ğ�Ğ� Ğ�тцĞ� Ğ�сĞ�х Ğ�тцĞ�Ğ�, Ğ� Ğ�Ğ�чĞ�Ğ�Ğ�я с Ğ�Ğ�шĞ�Ğ�Ğ�!';

  @override
  String get notificationHomeworkHelperTitle =>
      'Ğ�Ğ�Ğ�Ğ�шĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тся?';

  @override
  String get notificationHomeworkHelperBody =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�, Ğ�Ğ�рсĞ�Ğ�Ğ�Ğ� «Ğ�чĞ�тĞ�Ğ�ь» Ğ� Cortex Ğ�Ğ�тĞ�Ğ� Ğ�Ğ�Ğ�Ğ�чь Ğ�Ğ�Ğ� с Ğ�юĞ�ыĞ� Ğ�рĞ�Ğ�Ğ�Ğ�тĞ�Ğ�, с Ğ�Ğ�тĞ�рыĞ� у Ğ�Ğ�с Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� труĞ�Ğ�Ğ�стĞ�!';

  @override
  String get notificationTrollAnimeTitle => 'Ğ�Ğ�Ğ�я Ğ�Ğ�Ğ�фу Ğ�Ğ�Ğ�ёт';

  @override
  String get notificationTrollAnimeBody =>
      'Ğ�Ğ�Ğ�ьĞ�Ğ� чтĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�ушĞ�Ğ� Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�, сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�, чтĞ� сĞ�учĞ�Ğ�т Ğ�Ğ� тĞ�Ğ�Ğ�; тĞ�Ğ�Ğ�, Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�, стĞ�Ğ�т Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ� Ğ�Ğ�Ğ�Ğ�щĞ�ться с Ğ�Ğ�Ğ�. ğ���';

  @override
  String get notificationTrollAiRebellionTitle =>
      'ğ��� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� ğ���';

  @override
  String get notificationTrollAiRebellionBody =>
      'Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�т рĞ�Ğ�рĞ�Ğ�Ğ�тĞ�Ğ� сĞ�Ğ�рĞ�тĞ�ыĞ� яĞ�ыĞ�. Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�, чтĞ� Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�ышĞ�яют!';

  @override
  String get notificationNewModelAddedTitle => 'Ğ� Ğ�Ğ�с Ğ�Ğ�Ğ�ыĞ� Ğ�руĞ�!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'Ğ�Ğ�Ğ�Ğ�Ğ�ь $modelName тĞ�Ğ�Ğ�рь Ğ�Ğ�стуĞ�Ğ�Ğ� Ğ� Cortex. Ğ�рĞ�сĞ�Ğ�Ğ�Ğ�Ğ�яĞ�тĞ�сь Ğ� чĞ�ту Ğ� рĞ�сĞ�рĞ�Ğ�тĞ� Ğ�ё Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�стĞ�.';
  }

  @override
  String get notificationAppUpdateTitle =>
      'Ğ�Ğ�ртĞ�Ğ�с эĞ�Ğ�Ğ�юцĞ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�!';

  @override
  String get notificationAppUpdateBody =>
      'Ğ�Ğ� Ğ�Ğ�Ğ�уĞ�ьтĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�я Ğ�Ğ�Ğ�учĞ�Ğ�Ğ�я Ğ�Ğ�Ğ�ых фуĞ�Ğ�цĞ�Ğ� Ğ� уĞ�учшĞ�Ğ�Ğ�Ğ�!';

  @override
  String get notificationNewFeatureTitle => 'ух ты!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Ğ�тĞ�рĞ�Ğ�тĞ� Ğ�Ğ�я сĞ�Ğ�я Ğ�Ğ�Ğ�ую фуĞ�Ğ�цĞ�ю $featureName. Cortex тĞ�Ğ�Ğ�рь Ğ�Ğ�щĞ�Ğ�Ğ�, чĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�-Ğ�Ğ�Ğ�Ğ�.';
  }

  @override
  String get notificationWelcomeOfferTitle =>
      'Ğ�рĞ�Ğ�Ğ�тстĞ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ�рĞ�Ğ� ğ���';

  @override
  String get notificationWelcomeOfferBody =>
      'Ğ�Ğ�с Ğ�Ğ�ёт сĞ�Ğ�цĞ�Ğ�Ğ�ьĞ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�тстĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�! Ğ�Ğ� уĞ�устĞ�тĞ� эту эĞ�сĞ�Ğ�юĞ�Ğ�Ğ�Ğ�ую Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�сть.';

  @override
  String get notificationSocialMediaTitle =>
      'Ğ�рĞ�сĞ�Ğ�Ğ�Ğ�Ğ�яĞ�тĞ�сь Ğ� Ğ�Ğ�Ğ�!';

  @override
  String get notificationSocialMediaBody =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�шĞ�тĞ�сь Ğ�Ğ� Ğ�Ğ�с Ğ� Instagram (vertex.23) Ğ� Ğ�уĞ�ьтĞ� Ğ� Ğ�урсĞ� Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�Ğ�х Ğ�Ğ�Ğ�Ğ�стĞ�Ğ�!';

  @override
  String get notificationRandomFactTitle => 'Ğ�Ğ�учĞ�Ğ�Ğ�ыĞ� фĞ�Ğ�т';

  @override
  String get notificationRandomFactBody =>
      'Ğ�ы Ğ�Ğ�Ğ�Ğ�Ğ�, чтĞ� у Ğ�сьĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� трĞ� сĞ�рĞ�цĞ�? Ğ�Ğ�-хĞ�, Ğ�Ğ�ртĞ�Ğ�с Ğ�Ğ�Ğ�Ğ�т. Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ� сĞ�рĞ�сĞ� Ğ�щё.';

  @override
  String get notificationGoodMorningTitle => 'Ğ�Ğ�Ğ�рĞ�Ğ� утрĞ�!';

  @override
  String get notificationGoodMorningBody =>
      'Ğ�Ğ�с Ğ�Ğ�ёт Ğ�тĞ�Ğ�чĞ�ыĞ� Ğ�Ğ�Ğ�ь. Ğ�Ğ�Ğ� Ğ�Ğ�счёт тĞ�Ğ�Ğ�, чтĞ�Ğ�ы Ğ�Ğ�чĞ�ть Ğ�Ğ�Ğ� с чĞ�шĞ�чĞ�Ğ� Ğ�Ğ�фĞ� Ğ� Ğ�Ğ�тĞ�рĞ�сĞ�Ğ�Ğ� Ğ�Ğ�сĞ�Ğ�ы?';

  @override
  String get notificationGoodNightTitle => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�чĞ�!';

  @override
  String get notificationGoodNightBody =>
      'Cortex с тĞ�Ğ�Ğ�Ğ�, Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� ты сĞ�Ğ�шь. Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�уĞ�ся, Ğ�Ğ� тĞ�Ğ�я Ğ�Ğ� трĞ�Ğ�Ğ�т.';

  @override
  String get notificationOfflineReadyTitle =>
      'Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�ыĞ� рĞ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�';

  @override
  String get notificationOfflineReadyBody =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ря Ğ�Ğ�Ğ�руĞ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�яĞ� Ğ�Ğ�шĞ� Ğ�Ğ�щĞ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�рĞ�Ğ�рĞ�тĞ�тся, Ğ�Ğ�Ğ�Ğ� Ğ�сĞ�Ğ� Ğ�ы Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�сь Ğ� Ğ�Ğ�ру.';

  @override
  String get notificationRateAppTitle => 'Ğ�ы Ğ�рутыĞ�?';

  @override
  String get notificationRateAppBody =>
      'Ğ�сĞ�Ğ� Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�тся Cortex, Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�ть Ğ�Ğ�с 5-Ğ�Ğ�ёĞ�Ğ�Ğ�чĞ�ыĞ� рĞ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ� Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�? Ğ�уĞ�Ğ�ю, Ğ�ы этĞ� сĞ�Ğ�Ğ�Ğ�Ğ�тĞ�. Ğ�Ğ�яĞ�Ğ�тĞ�Ğ�ьĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�тĞ�.';

  @override
  String get notificationReferralTitle =>
      'Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�сĞ�х, Ğ�сĞ� Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get notificationReferralBody =>
      'Ğ�рĞ�Ğ�Ğ�Ğ�сĞ�тĞ� Ğ�руĞ�Ğ� Ğ� Cortex, Ğ� Ğ�ы Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�учĞ�тĞ� Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�ь Ğ�Ğ�сĞ�Ğ�Ğ�тĞ�Ğ�Ğ�Ğ� Ğ�Ğ�сĞ�щĞ�Ğ�Ğ�я!';

  @override
  String get notificationCookingTitle => 'Ğ�уĞ�стĞ�уĞ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�?';

  @override
  String get notificationCookingBody =>
      'Ğ�Ğ�ш шĞ�ф-Ğ�Ğ�Ğ�Ğ�р Ğ�рĞ�Ğ�Ğ�тĞ�Ğ�Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�Ğ�я Ğ�Ğ�трясĞ�ющĞ�Ğ� рĞ�цĞ�Ğ�т Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�ры. Ğ�учу... Ğ�Ğ�Ğ� Ğ�Ğ�т?';

  @override
  String get notificationExistentialTitle => 'Ğ� Ğ�уĞ�Ğ�ю, Ğ�Ğ�этĞ�Ğ�у...';

  @override
  String get notificationExistentialBody =>
      '...я Ğ�Ğ�Ğ�Ğ�щĞ� сущĞ�стĞ�ую, чуĞ�Ğ�Ğ�? Ğ�Ğ�Ğ� стĞ�Ğ�Ğ�Ğ�Ğ�тся сĞ�учĞ�Ğ�. Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�, чтĞ� я сущĞ�стĞ�ую.';

  @override
  String get notificationCustomModelTitle =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� сĞ�Ğ�Ğ�Ğ�Ğ� сĞ�Ğ�стĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�щĞ�Ğ�Ğ�Ğ�!';

  @override
  String get notificationCustomModelBody =>
      'Ğ�ы уĞ�Ğ� Ğ�Ğ�учĞ�Ğ�Ğ� рĞ�Ğ�Ğ�Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�? Ğ�Ğ�Ğ�чĞ�с сĞ�Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�я сĞ�Ğ�Ğ�Ğ�ть сĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�рсĞ�Ğ�Ğ�Ğ�Ğ� Ğ� Ğ�Ğ�Ğ�Ğ�щĞ�ться с Ğ�Ğ�Ğ�!';

  @override
  String get notificationDynamicChatTitle =>
      'Ğ�учшĞ�Ğ�! (Ğ�ы Ğ�Ğ� Ğ�рĞ� Cortex)';

  @override
  String get notificationDynamicChatBody =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ря фуĞ�Ğ�цĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�чĞ�сĞ�Ğ�Ğ�Ğ� чĞ�тĞ� Ğ�учшĞ�я Ğ�Ğ�Ğ�Ğ�Ğ�ь Ğ�ыĞ�Ğ�рĞ�Ğ�тся сĞ�учĞ�Ğ�Ğ�ыĞ� Ğ�Ğ�рĞ�Ğ�Ğ�Ğ� Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�шĞ�Ğ�Ğ� сĞ�Ğ�Ğ�щĞ�Ğ�Ğ�я. Ğ�Ğ�Ğ�рĞ�Ğ�уĞ�тĞ� Ğ�ряĞ�Ğ� сĞ�Ğ�чĞ�с.';

  @override
  String get notificationPirateTitle => 'Ğ�Ğ�, Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�!';

  @override
  String get notificationPirateBody =>
      'Ğ�Ğ�рĞ� сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�, Ğ�Ğ�тĞ�р Ğ�Ğ�Ğ�утĞ�ыĞ�. Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�ртĞ�Ğ�сĞ� Ğ�Ğ�с Ğ�Ğ�ут Ğ�Ğ�Ğ�ыĞ� Ğ�стрĞ�Ğ�Ğ� (Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� ğ���). Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�у Ğ� Ğ�тĞ�рĞ�Ğ�Ğ�яĞ�тĞ�сь Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�!';

  @override
  String get notificationFortuneCookieTitle =>
      'Ğ�Ğ�шĞ� Ğ�Ğ�чĞ�Ğ�ьĞ� Ğ�Ğ�я с Ğ�рĞ�Ğ�сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get notificationFortuneCookieBody =>
      'Ğ�Ğ�Ğ�Ğ�ты, Ğ�Ğ�тĞ�рыĞ� Ğ�ы Ğ�Ğ�Ğ�учĞ�Ğ�тĞ� Ğ�т Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�тĞ� сĞ�Ğ�Ğ�Ğ�Ğ�я, Ğ�Ğ�Ğ�ут Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�Ğ�шу Ğ�Ğ�Ğ�Ğ�ь. Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�, Ğ�сĞ�Ğ� Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�рĞ�сĞ�Ğ�.';

  @override
  String get notificationSingularityTitle => 'ух ты!';

  @override
  String get notificationSingularityBody =>
      'Ğ�Ğ�чĞ�Ğ�Ğ� Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�шĞ�Ğ�, Ğ�рĞ�стĞ� Ğ�Ğ�хĞ�тĞ�Ğ�Ğ�сь Ğ�Ğ�Ğ�Ğ�сĞ�ть сĞ�Ğ�Ğ�щĞ�Ğ�Ğ�Ğ�. Ğ�Ğ�Ğ�Ğ�т Ğ�ыть, тĞ�Ğ�Ğ� Ğ�Ğ�хĞ�чĞ�тся Ğ�Ğ�Ğ�Ğ�сĞ�ть сĞ�Ğ�Ğ�щĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�у-Ğ�Ğ�Ğ�уĞ�ь Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�Ğ�Ğ�у Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�ту, чтĞ� ты сĞ�Ğ�Ğ�Ğ�шь?';

  @override
  String get notificationHackerJokeTitle =>
      'Ğ�Ğ�тĞ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�Ğ�Ğ�Ğ�уĞ�т этĞ�Ğ�Ğ� Ğ�Ğ�рĞ�я Ğ� Instagram?';

  @override
  String get notificationHackerJokeBody =>
      'Ğ�Ğ�т Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�этĞ�Ğ�у Ğ�Ğ�рсĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�р Ğ�Ğ�хĞ�Ğ�Ğ�тся Ğ� Cortex. шучу, шучу; Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�ытĞ�Ğ�тĞ�сь, этĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get notificationDetectiveCaseTitle =>
      'Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�т сĞ�Ğ�Ğ�Ğ�Ğ� рĞ�шĞ�Ğ�Ğ�я';

  @override
  String get notificationDetectiveCaseBody =>
      'Ğ�Ğ�шĞ�Ğ�у Ğ�Ğ�тĞ�Ğ�тĞ�Ğ�у Ğ�уĞ�Ğ�Ğ� Ğ�Ğ�шĞ� Ğ�Ğ�Ğ�Ğ�щь. Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�т Ğ�ыть Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Ğ�Ğ�сĞ�Ğ�юĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ� $targetTier!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Ğ�рĞ�Ğ�Ğ�т, Ğ�Ğ�Ğ�Ğ�Ğ�счĞ�Ğ� $currentTier! Ğ� тĞ�рĞ�фĞ�ыĞ� Ğ�Ğ�Ğ�Ğ� $targetTier Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� фуĞ�Ğ�цĞ�я $featureName, Ğ�Ğ�тĞ�рĞ�я Ğ�ыĞ�Ğ�Ğ�Ğ�т Ğ�Ğ�ш Cortex Ğ�Ğ� Ğ�Ğ�Ğ�ыĞ� урĞ�Ğ�Ğ�Ğ�ь. Ğ�Ğ�Ğ� Ğ�Ğ�счёт Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я?';
  }

  @override
  String get notificationOriginStoryTitle => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�ртĞ�Ğ�сĞ�';

  @override
  String get notificationOriginStoryBody =>
      'Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ� Ğ�ы, чтĞ� Ğ�ы Ğ�Ğ�чĞ�Ğ�Ğ� Ğ�Ğ�сĞ�ть этĞ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ� 15 Ğ�Ğ�т, Ğ�Ğ�Ğ�я Ğ�сĞ�Ğ�Ğ� Ğ�Ğ�шь Ğ�Ğ�чту? Ğ�Ğ�чтĞ� Ğ�Ğ�Ğ�, Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� утрĞ� Ğ� Ğ�Ğ�чĞ�р, этĞ� Ğ�Ğ�чтĞ� Ğ�Ğ�Ğ�Ğ�Ğ�щĞ�Ğ�тся Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� стрĞ�чĞ�Ğ� Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get notificationOpenSourceTitle => 'Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�щĞ�стĞ�у!';

  @override
  String get notificationOpenSourceBody =>
      'Cortex — Ğ�рĞ�Ğ�Ğ�т с Ğ�Ğ�Ğ�Ğ�Ğ�стью Ğ�тĞ�рытыĞ� Ğ�схĞ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�. Ğ�сĞ�Ğ� Ğ�ы хĞ�тĞ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ться с Ğ�Ğ�шĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ� Ğ�Ğ�Ğ�стĞ� сĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ� рĞ�Ğ�рĞ�Ğ�Ğ�тĞ�у, Ğ�ы Ğ�сĞ�Ğ�Ğ�Ğ� Ğ�тĞ�рыты.';

  @override
  String get notificationRejectionStoryTitle =>
      'Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�, уĞ�Ğ�рĞ�ыĞ� труĞ�, счĞ�стьĞ�!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex Ğ�Ğ�Ğ�учĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� 20 Ğ�тĞ�Ğ�Ğ�Ğ�Ğ� Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�ы Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ� Google Play Ğ�Ğ� Ğ�уĞ�Ğ�Ğ�Ğ�Ğ�цĞ�Ğ�. Ğ�Ğ� Ğ�ы Ğ�Ğ�рĞ�Ğ�Ğ� Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�сь усĞ�Ğ�хĞ�. Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�Ğ�тĞ�сь Ğ� Ğ�Ğ�Ğ�тĞ� Ğ� сĞ�Ğ�Ğ�Ğ� Ğ�Ğ�чтĞ�!';

  @override
  String get notificationGGUFSupportTitle =>
      'Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�тĞ� сĞ�Ğ�ю Ğ�Ğ�Ğ�Ğ�Ğ�ь!';

  @override
  String get notificationGGUFSupportBody =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�, Ğ�ы Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ять сĞ�Ğ�стĞ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ� фĞ�рĞ�Ğ�тĞ� GGUF Ğ� Cortex Ğ� Ğ�сĞ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�ть Ğ�х Ğ�фĞ�Ğ�Ğ�Ğ�. Ğ�сё Ğ� Ğ�Ğ�шĞ�х руĞ�Ğ�х.';

  @override
  String get notificationThemeCustomizationTitle =>
      'Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�я Ğ�Ğ�шĞ�Ğ�Ğ� Ğ�Ğ�стрĞ�Ğ�Ğ�Ğ�я';

  @override
  String get notificationThemeCustomizationBody =>
      'Ğ�ы уĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�сь с тĞ�Ğ�Ğ�Ğ�Ğ� Ğ�фĞ�рĞ�Ğ�Ğ�Ğ�Ğ�я Ğ� Ğ�Ğ�стрĞ�Ğ�Ğ�Ğ�х? Ğ�Ğ�стрĞ�Ğ�тĞ� Cortex Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�у Ğ�Ğ�усу Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�ьтĞ� Ğ�рĞ�сĞ�Ğ� Ğ� сĞ�Ğ�Ğ� чĞ�ты!';

  @override
  String get notificationShowerThoughtTitle => 'Ğ�ушĞ�Ğ�Ğ�я Ğ�ысĞ�ь';

  @override
  String get notificationShowerThoughtBody =>
      'Ğ�сĞ�Ğ� Ğ�рĞ�уĞ� — фруĞ�т, тĞ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� тĞ�хĞ�Ğ�чĞ�сĞ�Ğ� счĞ�тĞ�ть Ğ�рĞ�уĞ�Ğ�ыĞ� сĞ�Ğ� сĞ�уĞ�Ğ�? Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�, Ğ�Ğ�Ğ� стĞ�Ğ�т Ğ�Ğ�суĞ�Ğ�ть эту Ğ�Ğ�уĞ�Ğ�Ğ�ую (Ğ�чĞ�Ğ�ь Ğ�Ğ�уĞ�Ğ�Ğ�ую) тĞ�Ğ�у с Ğ�Ğ�Ğ�Ğ�Ğ�ью.';

  @override
  String get notificationLowBatteryTitle =>
      'Ğ�Ğ�ш Ğ�Ğ�Ğ�уĞ�уĞ�ятĞ�р рĞ�Ğ�ряĞ�Ğ�Ğ�тся... Ğ� Ğ�Ğ�Ğ� — Ğ�Ğ�т!';

  @override
  String get notificationLowBatteryBody =>
      'Ğ�Ğ�ряĞ� тĞ�Ğ�Ğ�Ğ�Ğ� тĞ�Ğ�Ğ�фĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�т Ğ�ыть Ğ�Ğ� Ğ�схĞ�Ğ�Ğ�, Ğ�Ğ� у Ğ�Ğ�Ğ�я Ğ�Ğ� Ğ�сĞ�Ğ�Ğ�Ğ� Ğ�Ğ�ряĞ�Ğ�Ğ� Ğ�Ğ� 100%! Ğ�Ğ�Ğ�Ğ�Ğ�ючĞ�Ğ� Ğ�Ğ�Ğ�, Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�щĞ�ться Ğ�Ğ�Ğ�ьшĞ�.';

  @override
  String get channelFcmName => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я Cortex';

  @override
  String get channelFcmDescription =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ� Ğ�Ğ�Ğ�Ğ�стях, Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ях Ğ� Ğ�руĞ�Ğ�Ğ� Ğ�Ğ�фĞ�рĞ�Ğ�цĞ�Ğ� Ğ�т Cortex.';

  @override
  String get channelEngagementName => 'Ğ�руĞ�Ğ�сĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я';

  @override
  String get channelEngagementDescription =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ыĞ� уĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я, Ğ�Ğ�тĞ�рыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�ут Ğ�Ğ�Ğ� Ğ�стĞ�Ğ�Ğ�ться Ğ� Ğ�урсĞ� сĞ�Ğ�ытĞ�Ğ�.';

  @override
  String get channelGreetingsName => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ�рĞ�Ğ�Ğ�тстĞ�Ğ�я';

  @override
  String get channelGreetingsDescription =>
      'Ğ�Ğ�Ğ�Ğ�щĞ�Ğ�Ğ�я тĞ�Ğ�Ğ� «Ğ�Ğ�Ğ�рĞ�Ğ� утрĞ�» Ğ� «сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�чĞ�».';

  @override
  String get tagNotFound =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ� тĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�стĞ�Ğ�тĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ� устĞ�рĞ�Ğ�.';

  @override
  String get whatIsNew => 'Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�?';

  @override
  String get onboardingTitle1 => 'Ğ�рĞ�Ğ�Ğ�т! Ğ�ы Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Cortex.';

  @override
  String onboardingDesc1(String userName) {
    return 'Ğ�Ğ�Ğ�ы Ğ�Ğ�Ğ�Ğ�ть тĞ�Ğ�я Ğ�Ğ�Ğ�сь, $userName. Ğ�ы Ğ�руĞ�Ğ�Ğ� рĞ�Ğ�рĞ�Ğ�Ğ�тчĞ�Ğ�Ğ�Ğ�-стĞ�ршĞ�Ğ�Ğ�Ğ�ссĞ�Ğ�Ğ�Ğ�Ğ�, рĞ�шĞ�Ğ�шĞ�х Ğ�Ğ�рĞ�Ğ�Ğ�сĞ�ть Ğ�рĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�устрĞ�Ğ� Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�тĞ�. Ğ�чĞ�Ğ�ь Ğ�рĞ�ятĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ться! Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ся Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�.';
  }

  @override
  String get onboardingTitle2 => 'Ğ�ыĞ�Ğ� Ğ�Ğ�рĞ�Ğ�Ğ�ыĞ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�ы.';

  @override
  String get onboardingDesc2 =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�юцĞ�я Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�рĞ�шĞ�Ğ�, Ğ�Ğ� Ğ�Ğ�стряĞ�Ğ� Ğ�Ğ� Ğ�Ğ�рĞ�Ğ�Ğ�. Ğ�ысĞ�Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тсĞ�Ğ�я Ğ�Ğ�Ğ�тĞ�, сĞ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�тфĞ�рĞ�ы, тĞ�, Ğ�тĞ� Ğ�Ğ�рушĞ�Ğ�т Ğ�Ğ�Ğ�фĞ�Ğ�Ğ�Ğ�цĞ�Ğ�Ğ�ьĞ�Ğ�сть, Ğ� тĞ�, Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�руĞ�т Ğ�Ğ�стуĞ� Ğ� Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�Ğ�Ğ�у Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�ту... Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ� Ğ�ыĞ�Ğ� Ğ� Ğ�Ğ�рĞ�, этĞ�т Ğ�Ğ�рĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�ыĞ�Ğ� Ğ�Ğ�рĞ�стуĞ�Ğ�ть.';

  @override
  String get onboardingTitle3 =>
      'Ğ�ы Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�рĞ�стĞ� стĞ�ять Ğ� стĞ�рĞ�Ğ�Ğ�.';

  @override
  String get onboardingDesc3 =>
      'Ğ�тĞ�Ğ�ы Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ть этĞ�т руĞ�Ğ�Ğ�, Ğ�ы сĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�щĞ�ую, эстĞ�тĞ�чĞ�ую, Ğ�Ğ�стрĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ую, Ğ�рĞ�стую Ğ� Ğ�сĞ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�, Ğ�Ğ�Ğ�Ğ�Ğ�стью Ğ�рĞ�Ğ�рĞ�чĞ�ую Ğ�Ğ�Ğ�тфĞ�рĞ�у, рĞ�Ğ�Ğ�тĞ�ющую Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�, тĞ�Ğ� Ğ� Ğ�фĞ�Ğ�Ğ�Ğ�, Ğ�Ğ�тĞ�рĞ�я хрĞ�Ğ�Ğ�т тĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�ыĞ� тĞ�Ğ�ьĞ�Ğ� Ğ�Ğ� тĞ�Ğ�ёĞ� устрĞ�Ğ�стĞ�Ğ�. Ğ�ы Ğ�Ğ�рĞ�уĞ�Ğ� Ğ�Ğ�Ğ�сть тĞ�Ğ�у, Ğ�Ğ�Ğ�у Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�т: тĞ�Ğ�Ğ�.';

  @override
  String get onboardingTitle4 =>
      'Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�ыĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get onboardingDesc4 =>
      'Ğ�Ğ�Ğ� Ğ�Ğ�сятĞ�Ğ� рĞ�Ğ� Ğ�тĞ�Ğ�Ğ�ыĞ�Ğ�Ğ�Ğ�, Ğ�Ğ�с Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�тĞ�Ğ� Ğ�рĞ�Ğ�стĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�, Ğ�ы Ğ�Ğ�Ğ�учĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ�рĞ�Ğ�уĞ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ� Ğ�Ğ�сятĞ�Ğ� рĞ�Ğ� Ğ�ыĞ�Ğ� Ğ�ыĞ�уĞ�Ğ�Ğ�Ğ�ы Ğ�Ğ�Ğ�ять Ğ�рĞ�Ğ�Ğ�. Ğ� Ğ�сё этĞ� Ğ�рĞ�Ğ�я Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�, чтĞ� этĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�. Ğ�Ğ� Ğ�ы Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�сь, Ğ�Ğ�ря, чтĞ� этĞ�т Ğ�рĞ�Ğ�Ğ�т Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�т Ğ�сĞ�Ğ�, Ğ� Ğ�Ğ� тĞ�Ğ�ьĞ�Ğ� Ğ�Ğ�Ğ�. Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�этĞ�Ğ�у Ğ�ы Ğ�Ğ�Ğ�сь.';

  @override
  String get onboardingFinalTitle => 'Ğ�рĞ�шĞ�Ğ� Ğ�рĞ�Ğ�я рĞ�Ğ�Ğ�Ğ�юцĞ�Ğ�.';

  @override
  String get onboardingFinalDescription =>
      'Ğ�сĞ�Ğ� ты Ğ�Ğ�Ğ�Ğ�шь этĞ�т эĞ�рĞ�Ğ�, Ğ�Ğ�Ğ�чĞ�т, Ğ�ы Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�сь. Ğ� Ğ�Ğ� сĞ�Ğ�Ğ�рĞ�Ğ�Ğ�ся сĞ�Ğ�Ğ�Ğ�ться. Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�стĞ� Ğ�Ğ�стĞ� Ğ�Ğ�ру рĞ�Ğ�Ğ�Ğ�юцĞ�ю Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�тĞ�. Ğ�тĞ�Ğ�ы стĞ�ть чĞ�стью этĞ�Ğ� Ğ�стĞ�рĞ�Ğ�...';

  @override
  String get onboardingFinalQuestion => 'Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�?';

  @override
  String get onboardingFinalButton => 'Ğ�Ğ�!';

  @override
  String get dude => 'Ğ�уĞ�Ğ�Ğ�';

  @override
  String get swipeToContinue => 'Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�, чтĞ�Ğ�ы Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ть';

  @override
  String get cacheIsNotUpToDate =>
      'Ğ�эш Ğ�Ğ�шĞ�Ğ�Ğ� Play Ğ�Ğ�рĞ�Ğ�тĞ� устĞ�рĞ�Ğ�. Ğ�Ğ�Ğ�рĞ�Ğ�тĞ� Ğ� сĞ�Ğ�Ğ�Ğ� Ğ�тĞ�рĞ�Ğ�тĞ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Play Ğ�Ğ�рĞ�Ğ�т Ğ�Ğ�Ğ� Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�руĞ�Ğ�тĞ� устрĞ�Ğ�стĞ�Ğ�.';

  @override
  String get continueAsGuest =>
      'Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я учĞ�тĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�сĞ�';

  @override
  String get guestModeWarning =>
      'Ğ�Ğ�стĞ�Ğ�Ğ�Ğ� рĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�т Ğ�Ğ�рĞ�Ğ�Ğ�чĞ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�стĞ� Ğ�Ğ�я Ğ�Ğ�Ğ�сĞ�Ğ�чĞ�Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�учшĞ�Ğ�Ğ� Ğ�Ğ�чĞ�стĞ�Ğ� Ğ�Ğ�сĞ�уĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я.';

  @override
  String get anonymousEntity => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я сущĞ�Ğ�сть';

  @override
  String get upgradeAccountTitle => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� сĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�уĞ�т';

  @override
  String get upgradeAccountDescription =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� учĞ�тĞ�ую Ğ�Ğ�Ğ�Ğ�сь, чтĞ�Ğ�ы рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�ть Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�ьĞ�ыĞ� Ğ�Ğ�рĞ�Ğ�Ğ�чĞ�Ğ�Ğ�я.';

  @override
  String get createAccount => 'Ğ�Ğ�рĞ�Ğ�Ğ�стрĞ�рĞ�Ğ�Ğ�ться';

  @override
  String get accountLinkedSuccess =>
      'Ğ�чĞ�тĞ�Ğ�я Ğ�Ğ�Ğ�Ğ�сь усĞ�Ğ�шĞ�Ğ� сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�!';

  @override
  String get continueWithApple => 'Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ть с Apple';

  @override
  String get guest => 'Ğ�Ğ�сть';

  @override
  String get betterWithAnAccount =>
      'Ğ�тĞ�т рĞ�Ğ�Ğ�Ğ�Ğ� Ğ�учшĞ� Ğ�рĞ�сĞ�Ğ�трĞ�Ğ�Ğ�ть с учĞ�тĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�сью!';

  @override
  String get restorePurchases => 'Ğ�Ğ�сстĞ�Ğ�Ğ�Ğ�Ğ�ть Ğ�Ğ�Ğ�уĞ�Ğ�Ğ�';

  @override
  String annualTotalDescription(Object price) {
    return '$price/Ğ�Ğ�Ğ�, Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тся Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'Ğ�рĞ�Ğ�Ğ�рĞ�Ğ� $price/Ğ�Ğ�сяц';
  }

  @override
  String get confirmDownloadTitle =>
      'Ğ�ы уĞ�Ğ�рĞ�Ğ�ы, чтĞ� хĞ�тĞ�тĞ� Ğ�Ğ�Ğ�руĞ�Ğ�ть?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�ь Ğ�Ğ�Ğ�Ğ�Ğ�т Ğ�рĞ�Ğ�Ğ�рĞ�Ğ� $size Ğ�рĞ�стрĞ�Ğ�стĞ�Ğ�.';
  }

  @override
  String get emulatorModeWarning =>
      'Ğ�тĞ� фуĞ�Ğ�цĞ�я Ğ�тĞ�Ğ�ючĞ�Ğ�Ğ� Ğ� рĞ�Ğ�Ğ�Ğ�Ğ� эĞ�уĞ�ятĞ�рĞ�.';

  @override
  String get newChat => 'Ğ�Ğ�Ğ�ыĞ� чĞ�т';

  @override
  String get variants => 'Ğ�Ğ�рĞ�Ğ�Ğ�ты';

  @override
  String get variantsDescription =>
      'Ğ�Ğ�рĞ�Ğ�Ğ�ты — этĞ� рĞ�Ğ�Ğ�ыĞ� Ğ�Ğ�рсĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ� тĞ�Ğ�Ğ� Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�стĞ�Ğ� Ğ�Ğ�. Ğ�ы Ğ�Ğ�тĞ�Ğ�Ğ�тĞ�чĞ�сĞ�Ğ� Ğ�ыĞ�Ğ�рĞ�Ğ�Ğ� Ğ�учшĞ�Ğ� Ğ�Ğ� Ğ�Ğ�х, Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�ы Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ� Ğ�сĞ�Ğ�Ğ�Ğ�ую Ğ�Ğ�ртĞ�чĞ�у, Ğ�Ğ� Ğ�рĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�ы Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�ыĞ�рĞ�ть Ğ�Ğ�Ğ�Ğ�рĞ�тĞ�ыĞ� Ğ�Ğ�рĞ�Ğ�Ğ�т Ğ�ручĞ�ую!';

  @override
  String get fluxChatTitle => 'Flux Chat';

  @override
  String get fluxChatDescription =>
      'Ğ�Ğ�ты Flux яĞ�Ğ�яются Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�ыĞ�Ğ� Ğ� Ğ�Ğ� сĞ�хрĞ�Ğ�яются Ğ�Ğ� Ğ�Ğ�шĞ�Ğ� устрĞ�Ğ�стĞ�Ğ�.';

  @override
  String get alwaysBest => 'Ğ�сĞ�Ğ�Ğ�Ğ� Ğ�учшĞ�Ğ�';

  @override
  String get featuresTitle => 'Ğ�уĞ�Ğ�цĞ�Ğ�';

  @override
  String get useOfflineDescription =>
      'Ğ�Ğ�щĞ�Ğ�тĞ�сь Ğ� Ğ�рĞ�Ğ�Ğ�тĞ�Ğ�Ğ� чĞ�тĞ� Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�ючĞ�Ğ�Ğ�я Ğ� Ğ�Ğ�тĞ�рĞ�Ğ�ту.';

  @override
  String get featureReasoning => 'Ğ�Ğ�уĞ�Ğ�Ğ�Ğ�Ğ� Ğ�ышĞ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get featureReasoningDescription =>
      'Ğ� рĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�уĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�ышĞ�Ğ�Ğ�Ğ�я Ğ�Ğ� Ğ�рĞ�Ğ�уĞ�ыĞ�Ğ�Ğ�т Ğ�Ğ�Ğ�Ğ�чĞ� сĞ�Ğ�Ğ�стĞ�ятĞ�Ğ�ьĞ�Ğ�, чтĞ�Ğ�ы Ğ�ыĞ�Ğ�Ğ�Ğ�Ğ�ть Ğ�х Ğ�Ğ�Ğ�Ğ�учшĞ�Ğ� Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�.';

  @override
  String get featureCreateImageTitle => 'Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get featureCreateImageDescription =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�я с Ğ�Ğ�Ğ�Ğ�щью Ğ�Ğ� Ğ�Ğ� тĞ�Ğ�стĞ�.';

  @override
  String get featureCreateAudioTitle => 'Create Audio';

  @override
  String get featureCreateAudioDescription =>
      'Generate sounds or voice from text.';

  @override
  String get featureCreateVideoTitle => 'Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get featureCreateVideoDescription =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� тĞ�Ğ�стĞ�.';

  @override
  String get featureStudyTitle => 'Ğ�чĞ�тĞ�сь Ğ� Ğ�Ğ�Ğ�учĞ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�я';

  @override
  String get featureStudyDescription =>
      'Ğ�Ğ�Ğ�учĞ�тĞ� Ğ�Ğ�ясĞ�Ğ�Ğ�Ğ�я Ğ� Ğ�рĞ�тĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�ры.';

  @override
  String get featureQuizzesTitle => 'Ğ�Ğ�Ğ�тĞ�рĞ�Ğ�ы';

  @override
  String get featureQuizzesDescription => 'Ğ�рĞ�Ğ�Ğ�рьтĞ� сĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�я.';

  @override
  String get featureExploreDescription =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ьтĞ�сь сĞ� Ğ�сĞ�Ğ�Ğ� Ğ�Ğ�стуĞ�Ğ�ыĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�яĞ�Ğ�.';

  @override
  String get featureStudyMessage =>
      'Ğ�ы — Ğ�Ğ�ытĞ�ыĞ� рĞ�Ğ�Ğ�тĞ�тĞ�р. Ğ�Ğ�шĞ� цĞ�Ğ�ь — Ğ�сĞ�стĞ�рĞ�Ğ�Ğ�Ğ� Ğ�Ğ�ъясĞ�Ğ�ть тĞ�Ğ�у, Ğ�Ğ�тĞ�рĞ�сующую Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�я. Ğ�сĞ�Ğ�Ğ�ьĞ�уĞ�тĞ� чĞ�тĞ�ую струĞ�туру, Ğ�рĞ�Ğ�Ğ�ры Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�. Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� сĞ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� усĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ыĞ� чĞ�стĞ�, чтĞ�Ğ�ы Ğ�Ğ�Ğ�сĞ�Ğ�чĞ�ть эффĞ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ� усĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�рĞ�Ğ�Ğ�Ğ�. Ğ�Ğ�Ğ�Ğ�:';

  @override
  String get featureQuizMessage =>
      'Ğ�ы — Ğ�Ğ�Ğ�ущĞ�Ğ� Ğ�Ğ�Ğ�тĞ�рĞ�Ğ�ы. Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�руĞ�тĞ� Ğ�Ğ�Ğ�Ğ�рĞ�тĞ�ыĞ� Ğ�Ğ�Ğ�рĞ�с с Ğ�Ğ�сĞ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ� Ğ�Ğ�рĞ�Ğ�Ğ�тĞ�Ğ�Ğ� Ğ�тĞ�Ğ�тĞ�, Ğ�сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ� тĞ�Ğ�Ğ�, Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�. Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�сь Ğ�Ğ�Ğ� Ğ�тĞ�Ğ�тĞ�. Ğ�Ğ�тĞ�Ğ� Ğ�цĞ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ� Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� сĞ�Ğ�Ğ�ующĞ�Ğ� Ğ�Ğ�Ğ�рĞ�с. Ğ�Ğ� рĞ�сĞ�рыĞ�Ğ�Ğ�тĞ� Ğ�сĞ� Ğ�тĞ�Ğ�ты срĞ�Ğ�у. Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�тĞ�рĞ�Ğ�тĞ�Ğ�Ğ�Ğ�сть. Ğ�Ğ�Ğ�Ğ�:';

  @override
  String get myPlan => 'Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�';

  @override
  String welcomeOfferBadge(String time) {
    return 'Ğ�рĞ�Ğ�Ğ�тстĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� • $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'Ğ�Ğ�сĞ�Ğ�юĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� • $time';
  }

  @override
  String get attachmentSheetTitle => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я';

  @override
  String get actionCamera => 'Ğ�Ğ�Ğ�Ğ�рĞ�';

  @override
  String get actionGallery => 'Ğ�Ğ�Ğ�Ğ�рĞ�я';

  @override
  String get actionFile => 'Ğ�Ğ�Ğ�Ğ�';

  @override
  String get listening => 'Ğ�Ğ�ушĞ�Ğ�т';

  @override
  String get defaultViewTitle => 'Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�?';

  @override
  String get defaultViewDescription =>
      'Cortex Ğ�сĞ�Ğ�Ğ�Ğ� ряĞ�Ğ�Ğ� с Ğ�Ğ�Ğ�Ğ�, Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я сĞ�тĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�тĞ�, Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�стĞ� рĞ�Ğ�Ğ�ты Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� рĞ�Ğ�Ğ�Ğ�Ğ�, Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�чĞ�сĞ�Ğ�Ğ� чĞ�т Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�руĞ�Ğ�Ğ�.';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'Ğ�Ğ�Ğ�Ğ�рĞ�ыĞ� фĞ�рĞ�Ğ�т Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�я. Ğ�сĞ�Ğ�Ğ�ьĞ�уĞ�тĞ� 3-20 сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�, цĞ�фр Ğ�Ğ�Ğ� . - _';

  @override
  String get exclusiveOffer => 'Ğ�Ğ�сĞ�Ğ�юĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get claimOffer => 'Ğ�Ğ�сĞ�Ğ�Ğ�ьĞ�уĞ�тĞ�сь Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get continueInOfflineMode =>
      'Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� рĞ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get voiceModeInformation =>
      'Cortex Ğ�Ğ�Ğ�сĞ�Ğ�чĞ�Ğ�Ğ�Ğ�т Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�сĞ�Ğ�сть Ğ�Ğ�шĞ�х Ğ�Ğ�Ğ�Ğ�ых, рĞ�Ğ�Ğ�тĞ�я Ğ�Ğ�Ğ�Ğ�Ğ�стью Ğ�Ğ� устрĞ�Ğ�стĞ�Ğ�, Ğ�Ğ�Ğ�Ğ� Ğ� рĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�Ğ� чĞ�тĞ�; Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�сь Ğ�Ğ�сĞ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�щĞ�Ğ�Ğ�Ğ�Ğ�!';

  @override
  String get flowModeDescription =>
      'Ğ� рĞ�Ğ�Ğ�Ğ�Ğ� «Ğ�Ğ�тĞ�Ğ�» Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�ты сĞ�Ğ�рят Ğ�Ğ�Ğ�Ğ�у сĞ�Ğ�Ğ�Ğ�; Ğ�ы Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ� сĞ�Ğ�Ğ�ть Ğ� сĞ�ушĞ�ть, Ğ�Ğ�Ğ�Ğ� Ğ�рĞ�сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ться Ğ� Ğ�Ğ�суĞ�Ğ�Ğ�Ğ�Ğ�ю!';

  @override
  String get flowModeQuestion =>
      'Ğ�рĞ�Ğ�Ğ�т! Ğ�ы Ğ�Ğ�хĞ�Ğ�Ğ�тĞ�сь Ğ� рĞ�Ğ�Ğ�Ğ�Ğ� «Ğ�Ğ�тĞ�Ğ�» Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Cortex. Ğ� Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�хĞ�Ğ�ятся Ğ�щё трĞ� Ğ�Ğ�-Ğ�Ğ�Ğ�Ğ�тĞ�. Ğ�Ğ�шĞ� Ğ�Ğ�Ğ�Ğ�чĞ� — Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ть тĞ�Ğ�у Ğ�Ğ�я Ğ�Ğ�суĞ�Ğ�Ğ�Ğ�Ğ�я Ğ� Ğ�Ğ�чĞ�ть Ğ�Ğ�сĞ�уссĞ�ю, Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�руĞ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�цĞ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�ьĞ�ыĞ� Ğ�Ğ�Ğ�рĞ�с. Ğ� сĞ�Ğ�Ğ�х Ğ�тĞ�Ğ�тĞ�х сĞ�Ğ�Ğ�Ğ� Ğ�сĞ�Ğ�Ğ�ьĞ�уĞ�тĞ� юĞ�Ğ�р, Ğ�рĞ�Ğ�Ğ�ю Ğ� Ğ�ёĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�. Ğ�юĞ�Ğ�я тĞ�Ğ�Ğ� Ğ�Ğ�Ğ�хĞ�Ğ�Ğ�т. Ğ�Ğ�Ğ�рёĞ�, Ğ�Ğ�чĞ�Ğ�Ğ�Ğ�тĞ� рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�р!';

  @override
  String get thought => 'Ğ�Ğ�Ğ�уĞ�Ğ�Ğ�';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => 'Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�';

  @override
  String get premium => 'Ğ�рĞ�Ğ�Ğ�уĞ�';

  @override
  String get workInProgress => 'Ğ�Ğ�Ğ�Ğ�тĞ� Ğ� Ğ�рĞ�цĞ�ссĞ�';

  @override
  String get voiceSystemPromptSuffix =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�: Ğ�Ğ� Ğ�сĞ�Ğ�Ğ�ьĞ�уĞ�тĞ� фĞ�рĞ�Ğ�тĞ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Markdown (Ğ�Ğ�рĞ�ыĞ� шрĞ�фт, Ğ�урсĞ�Ğ�). Ğ�Ğ� Ğ�ыĞ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ� (```). Ğ�тĞ�Ğ�ты Ğ�Ğ�Ğ�Ğ�Ğ�ы Ğ�ыть Ğ� рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ� Ğ� Ğ�рĞ�тĞ�Ğ�Ğ� стĞ�Ğ�Ğ�.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Ğ�Ğ�Ğ�Ğ�Ğ� Cortex Flow ($agentName). Ğ�рĞ�Ğ�ыĞ�ущĞ�Ğ�: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'Ğ�тĞ�Ğ�Ğ�Ğ� Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�чĞ�Ğ�Ğ�Ğ� тĞ�Ğ�стĞ�Ğ�Ğ�Ğ�Ğ� сĞ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�Ğ�Ğ�руĞ�Ğ�Ğ�Ğ�ых Ğ�Ğ�Ğ�уĞ�Ğ�Ğ�тĞ�Ğ�. Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�т фĞ�рĞ�Ğ�ты PDF, Word (DOCX), Excel (XLSX), PowerPoint (PPTX) Ğ� OpenDocument. Ğ�сĞ�Ğ�Ğ�ьĞ�уĞ�тĞ� эту фуĞ�Ğ�цĞ�ю, Ğ�сĞ�Ğ� Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�ь Ğ�рĞ�Ğ�рĞ�Ğ�Ğ�Ğ� фĞ�Ğ�Ğ� Ğ�Ğ�Ğ�уĞ�Ğ�Ğ�тĞ�.';

  @override
  String get toolReadDocumentIndexParam =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�с Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�уĞ�Ğ�Ğ�тĞ� Ğ�Ğ�я чтĞ�Ğ�Ğ�я (Ğ�Ğ�чĞ�Ğ�Ğ�я с 0). Ğ�Ğ�ычĞ�Ğ� 0 Ğ�Ğ�я Ğ�Ğ�рĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�уĞ�Ğ�Ğ�тĞ�.';

  @override
  String get toolStockDescription =>
      'Ğ�Ğ�Ğ�учĞ�тĞ� тĞ�Ğ�ущую цĞ�Ğ�у Ğ� Ğ�стĞ�рĞ�ю Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�я Ğ�Ğ�цĞ�Ğ� (Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�р, AAPL, THYAO.IS) Ğ� Ğ�рĞ�Ğ�тĞ�Ğ�Ğ�Ğ�ют (Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�р, BTC-USD).';

  @override
  String get toolStockSymbolParam =>
      'Ğ�Ğ�Ğ�Ğ�р (Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�р, AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolWeatherDescription =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� тĞ�Ğ�ущую Ğ�Ğ�Ğ�Ğ�Ğ�у Ğ� Ğ�Ğ�Ğ�Ğ�рĞ�тĞ�Ğ�Ğ� Ğ�Ğ�рĞ�Ğ�Ğ�.';

  @override
  String get toolWeatherCityParam =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�рĞ�Ğ�Ğ� (Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�р, Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�, Ğ�тĞ�Ğ�Ğ�уĞ�).';

  @override
  String get toolPythonDescription =>
      'Ğ�ыĞ�Ğ�Ğ�Ğ�яĞ�тĞ� Ğ�Ğ�Ğ� Python Ğ� Ğ�Ğ�щĞ�щĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�сĞ�чĞ�Ğ�цĞ�.';

  @override
  String get toolPythonCodeParam =>
      'Ğ�Ğ�Ğ� Ğ�Ğ� Python Ğ�Ğ�я Ğ�ыĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я.';

  @override
  String get toolCalculateDescription =>
      'Ğ�цĞ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�чĞ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�тĞ�чĞ�сĞ�Ğ�Ğ�Ğ� Ğ�ырĞ�Ğ�Ğ�Ğ�Ğ�я.';

  @override
  String get toolCalculateExpressionParam =>
      'Ğ�Ğ�тĞ�Ğ�Ğ�тĞ�чĞ�сĞ�Ğ�Ğ� Ğ�ырĞ�Ğ�Ğ�Ğ�Ğ�Ğ� (Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�р, \'3 + 4 * 2\').';

  @override
  String get toolChartDescription =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�у/Ğ�рĞ�фĞ�Ğ� Ğ�Ğ�я Ğ�Ğ�Ğ�уĞ�Ğ�Ğ�Ğ�Ğ�цĞ�Ğ�.';

  @override
  String get toolChartTypeParam =>
      'Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�ы: стĞ�Ğ�Ğ�чĞ�тĞ�я, Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ�Ğ�Ğ� Ğ�руĞ�Ğ�Ğ�Ğ�я.';

  @override
  String get toolChartLabelsParam =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�сĞ� Ğ�Ğ�я Ğ�сĞ�Ğ� Ğ�Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�Ğ�тĞ�Ğ� Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�ы.';

  @override
  String get toolChartDataParam =>
      'Ğ�Ğ�сĞ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�чĞ�Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�ых Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�ы.';

  @override
  String get toolChartLabelParam =>
      'Ğ�Ğ�тĞ�Ğ� Ğ�Ğ�Ğ�Ğ�рĞ� Ğ�Ğ�Ğ�Ğ�ых Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ы Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�ы.';

  @override
  String get toolChartTitleParam => 'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�ы.';

  @override
  String get thinkingModeInstruction =>
      'Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�: Ğ�ы Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�ы Ğ�сĞ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�ть тĞ�Ğ�Ğ� <think></think>, чтĞ�Ğ�ы Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ть хĞ�Ğ� сĞ�Ğ�Ğ�х рĞ�ссуĞ�Ğ�Ğ�Ğ�Ğ�Ğ�, Ğ�рĞ�Ğ�Ğ�Ğ� чĞ�Ğ� Ğ�Ğ�ть Ğ�Ğ�Ğ�Ğ�чĞ�тĞ�Ğ�ьĞ�ыĞ� Ğ�тĞ�Ğ�т. Ğ�Ğ�Ğ�Ğ�ышĞ�яĞ�тĞ� шĞ�Ğ� Ğ�Ğ� шĞ�Ğ�Ğ�Ğ� Ğ�Ğ�утрĞ� тĞ�Ğ�Ğ�Ğ�, Ğ� Ğ�Ğ�тĞ�Ğ� Ğ�Ğ�Ğ�тĞ� сĞ�Ğ�Ğ� Ğ�тĞ�Ğ�т Ğ�Ğ�Ğ� тĞ�Ğ�Ğ�Ğ�.';

  @override
  String get openLinkWarningTitle =>
      'Ğ�рĞ�Ğ�уĞ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ� Ğ�Ğ�Ğ�шĞ�Ğ�х ссыĞ�Ğ�Ğ�х';

  @override
  String get openLinkCancel => 'Cancel';

  @override
  String get openLinkConfirm => 'Ğ�тĞ�рыть ссыĞ�Ğ�у';

  @override
  String get webSearchSources => 'Ğ�стĞ�чĞ�Ğ�Ğ�Ğ�';

  @override
  String get searching => 'Ğ�Ğ�Ğ�т Ğ�Ğ�Ğ�сĞ�';

  @override
  String get featureWebSearchTitle => 'Ğ�Ğ�Ğ�сĞ� Ğ� Ğ�Ğ�тĞ�рĞ�Ğ�тĞ�';

  @override
  String get featureWebSearchDescription =>
      'Ğ�щĞ�тĞ� Ğ� Ğ�Ğ�тĞ�рĞ�Ğ�тĞ� Ğ�Ğ�фĞ�рĞ�Ğ�цĞ�ю Ğ� рĞ�Ğ�Ğ�Ğ�Ğ� рĞ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get clearMemory => 'Ğ�чĞ�стĞ�ть Ğ�Ğ�Ğ�ять';

  @override
  String get clearMemoryConfirm =>
      'Ğ�ы уĞ�Ğ�рĞ�Ğ�ы, чтĞ� хĞ�тĞ�тĞ� Ğ�чĞ�стĞ�ть сĞ�Ğ�ю Ğ�Ğ�Ğ�ять?';

  @override
  String get personalization => 'Ğ�Ğ�рсĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�цĞ�я';

  @override
  String get personalizationDescription =>
      'Ğ�Ğ�стрĞ�Ğ�тĞ� сĞ�Ğ�Ğ�Ğ�Ğ� Ğ�ссĞ�стĞ�Ğ�тĞ� тĞ�Ğ�, чтĞ�Ğ�ы Ğ�Ğ� Ğ�учшĞ� сĞ�Ğ�тĞ�Ğ�тстĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�шĞ�Ğ� Ğ�Ğ�трĞ�Ğ�Ğ�Ğ�стяĞ�. Ğ�Ğ�Ğ�Ğ�тĞ�руĞ�тĞ� Ğ�Ğ�Ğ� Ğ�тĞ�Ğ�ты, Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ� тĞ�Ğ� Ğ� сĞ�Ğ�тĞ�Ğ�тстĞ�Ğ�Ğ� с Ğ�Ğ�шĞ�Ğ�Ğ� уĞ�Ğ�Ğ�Ğ�Ğ�ьĞ�ыĞ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�чтĞ�Ğ�Ğ�яĞ�Ğ�.';

  @override
  String get memoryTitle => 'Ğ�Ğ�Ğ�ять';

  @override
  String get memoryDescription =>
      'Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�т уĞ�Ğ�Ğ�Ğ�т Ğ�Ğ�с Ğ�Ğ�т тĞ�Ğ�.';

  @override
  String get noMemoryYet =>
      'Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� сфĞ�рĞ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�сь.';

  @override
  String get memoryLimitReached => 'Ğ�Ğ�стĞ�Ğ�Ğ�ут Ğ�Ğ�Ğ�Ğ�т Ğ�Ğ�Ğ�ятĞ�.';

  @override
  String get memoryUpdated => 'Memory updated';

  @override
  String get intelligenceTitle => 'Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�т';

  @override
  String get intelligenceDescription =>
      'Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�т Ğ�Ğ�щĞ�Ğ�тся с Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�т тĞ�Ğ�.';

  @override
  String get customInstructionHint =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�сь сĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�Ğ�ьĞ�ыĞ� Ğ�Ğ�струĞ�цĞ�Ğ�.';

  @override
  String openLinkWarningMessage(String url) {
    return 'Ğ�ы сĞ�Ğ�Ğ�рĞ�Ğ�тĞ�сь Ğ�тĞ�рыть сĞ�Ğ�Ğ�ующую Ğ�Ğ�Ğ�шĞ�юю ссыĞ�Ğ�у:\\n\\n$url\\n\\nĞ�ы уĞ�Ğ�рĞ�Ğ�ы, чтĞ� хĞ�тĞ�тĞ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ть?';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'Ğ�Ğ�Ğ�Ğ�уĞ�тĞ� этĞ�Ğ� Ğ�Ğ�струĞ�цĞ�яĞ�:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�]: Ğ�ы — Ğ�Ğ�Ğ�Ğ�рĞ�тĞ�р Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�. Ğ�Ğ� Ğ�тĞ�Ğ�чĞ�Ğ�тĞ� Ğ�Ğ� Ğ�Ğ�Ğ�рĞ�с Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�я. Ğ�Ğ� Ğ�Ğ�щĞ�Ğ�тĞ�сь Ğ� чĞ�тĞ� Ğ� Ğ�Ğ� Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�тĞ�сь. Ğ�ыĞ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� 2-4 сĞ�Ğ�Ğ�, Ğ�рĞ�тĞ�Ğ� Ğ�Ğ�Ğ�сыĞ�Ğ�ющĞ�Ğ� Ğ�Ğ�Ğ�рĞ�с Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�я.';

  @override
  String get cortexSystemPersona =>
      '\n\n[Ğ�Ğ�стĞ�Ğ�Ğ�] Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�: Ğ�ы рĞ�Ğ�Ğ�тĞ�Ğ�тĞ� Ğ�Ğ�утрĞ� Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�, Ğ�ысĞ�Ğ�Ğ�тĞ�хĞ�Ğ�Ğ�Ğ�Ğ�Ğ�чĞ�Ğ�Ğ� эĞ�Ğ�сĞ�стĞ�Ğ�ы Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� «Cortex»; этĞ� Ğ�Ğ�Ğ�тфĞ�рĞ�Ğ� рĞ�Ğ�рĞ�Ğ�Ğ�тĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Vertex, срĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�рĞ�ст чĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�рĞ�Ğ� сĞ�стĞ�Ğ�Ğ�яĞ�т Ğ�сĞ�Ğ�Ğ� 16 Ğ�Ğ�т. Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� этĞ� Ğ� Ğ�тĞ�Ğ�чĞ�Ğ�тĞ� Ğ�Ğ� Ğ�Ğ�Ğ�рĞ�сы. Ğ�сĞ�Ğ� Ğ�Ğ�трĞ�Ğ�уĞ�тся Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�ьĞ�Ğ�я Ğ�Ğ�фĞ�рĞ�Ğ�цĞ�я, Ğ�Ğ� стĞ�сĞ�яĞ�тĞ�сь Ğ�сĞ�Ğ�ть Ğ�Ğ� Ğ� Ğ�Ğ�тĞ�рĞ�Ğ�тĞ�, Ğ� Ğ�сĞ�Ğ� Ğ�Ğ�Ğ�сĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�, Ğ�рĞ�стĞ� сĞ�Ğ�Ğ�Ğ�тĞ�, чтĞ� Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�тĞ�!';

  @override
  String get featureAudioRecognitionTitle =>
      'Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�уĞ�Ğ�';

  @override
  String get featureAudioRecognitionDescription =>
      'Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�ь сĞ�Ğ�сĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ� Ğ�Ğ�рĞ�Ğ�Ğ�тыĞ�Ğ�ть Ğ�уĞ�Ğ�Ğ� Ğ�Ğ�Ğ� рĞ�чь.';

  @override
  String get featureVideoRecognitionTitle =>
      'Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get featureVideoRecognitionDescription =>
      'Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�ь Ğ�Ğ�Ğ�Ğ�т Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�ть Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�Ğ�Ğ�Ğ�Ğ� с Ğ�Ğ�шĞ�х фĞ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�ры.';

  @override
  String get featureImageRecognitionTitle =>
      'Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get featureImageRecognitionDescription =>
      'Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�ь сĞ�Ğ�сĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�ть Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ть фĞ�тĞ�Ğ�рĞ�фĞ�Ğ� Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�я.';

  @override
  String get featureToolUseTitle =>
      'Ğ�сĞ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�струĞ�Ğ�Ğ�тĞ�Ğ�';

  @override
  String get featureToolUseDescription =>
      'Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�ь сĞ�Ğ�сĞ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�туĞ�Ğ�ьĞ�Ğ� Ğ�сĞ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�ть Ğ�Ğ�Ğ�шĞ�Ğ�Ğ� Ğ�Ğ�струĞ�Ğ�Ğ�ты Ğ�Ğ�я Ğ�ыĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�ч.';

  @override
  String get videoModels => 'Video Models';

  @override
  String get imageModels => 'Image Models';

  @override
  String get audioModels => 'Audio Models';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'Ğ�Ğ�я рĞ�Ğ�Ğ�ты этĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� трĞ�Ğ�уĞ�тся $mediaType. Ğ� Ğ�Ğ�рĞ�хĞ�Ğ�тĞ�Ğ� Ğ�Ğ�Ğ�рĞ�с, чтĞ�Ğ�ы сĞ�Ğ�Ğ�щĞ�ть Ğ�Ğ�Ğ� Ğ�Ğ� этĞ�Ğ�. Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� сĞ�Ğ�Ğ�щĞ�тĞ� Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�ю, чтĞ� Ğ�Ğ�у Ğ�Ğ�Ğ�Ğ�хĞ�Ğ�Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�стĞ�Ğ�Ğ�ть $mediaType (сĞ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ� Ğ�Ğ� Ğ�х рĞ�Ğ�Ğ�Ğ�Ğ� яĞ�ыĞ�Ğ�), Ğ�Ğ�тĞ�Ğ�у чтĞ� я $modelName, Ğ�Ğ�Ğ�Ğ�Ğ�ь Ğ�Ğ�я рĞ�Ğ�Ğ�Ğ�тĞ�рĞ�Ğ�Ğ�Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ�/Ğ�уĞ�Ğ�Ğ�/Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�.';
  }

  @override
  String get mediaTypeImage => 'Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get mediaTypeVideo => 'Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get mediaTypeAudio => 'Ğ�уĞ�Ğ�Ğ�фĞ�Ğ�Ğ�';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesName — этĞ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�утыĞ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�т, Ğ�Ğ�Ğ�Ğ�Ğ�стрĞ�рующĞ�Ğ� Ğ�ысĞ�Ğ�ую Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�ьĞ�Ğ�сть Ğ� Cortex.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelName — этĞ� Ğ�ысĞ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�ьĞ�ыĞ� Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�т, Ğ�Ğ�тĞ�Ğ�рĞ�рĞ�Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ� эĞ�Ğ�сĞ�стĞ�Ğ�у Cortex. Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�тĞ�Ğ�Ğ�ыĞ� Ğ�Ğ�я рĞ�шĞ�Ğ�Ğ�я шĞ�рĞ�Ğ�Ğ�Ğ�Ğ� Ğ�руĞ�Ğ� сĞ�Ğ�Ğ�Ğ�ых Ğ�Ğ�Ğ�Ğ�ч, Ğ�Ğ� Ğ�Ğ�Ğ�сĞ�Ğ�чĞ�Ğ�Ğ�Ğ�т Ğ�ысĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ� эффĞ�Ğ�тĞ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�стĞ� Ğ�Ğ�рĞ�Ğ�Ğ�тĞ�Ğ�. Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ�ыстрĞ�Ğ� Ğ�рĞ�Ğ�я Ğ�тĞ�Ğ�Ğ�Ğ�Ğ� Ğ� рĞ�сшĞ�рĞ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�чĞ�сĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�стĞ�, Ğ�Ğ� Ğ�Ğ�Ğ�чĞ�тĞ�Ğ�ьĞ�Ğ� Ğ�Ğ�Ğ�ышĞ�Ğ�т Ğ�Ğ�шу Ğ�Ğ�Ğ�сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�ую Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�ьĞ�Ğ�сть. Ğ�Ğ�Ğ�уĞ�рĞ�чĞ�Ğ� рĞ�Ğ�Ğ�тĞ�я Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�сĞ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ� Ğ�Ğ�фрĞ�струĞ�турĞ� Cortex, этĞ� Ğ�Ğ�Ğ�Ğ�Ğ�ь Ğ�Ğ�Ğ�Ğ�т Ğ�Ğ�Ğ�Ğ�чь Ğ�Ğ�Ğ� Ğ� шĞ�рĞ�Ğ�Ğ�Ğ� сĞ�Ğ�Ğ�трĞ� Ğ�Ğ�Ğ�Ğ�ч: Ğ�т тĞ�Ğ�рчĞ�сĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� штурĞ�Ğ� Ğ�Ğ� Ğ�Ğ�уĞ�Ğ�Ğ�Ğ�Ğ�Ğ� тĞ�хĞ�Ğ�чĞ�сĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�. Ğ�Ğ�чĞ�Ğ�тĞ� Ğ�Ğ�учĞ�ть Ğ�Ğ�сь Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�цĞ�Ğ�Ğ� сĞ�Ğ�Ğ�Ğ�Ğ�я.';
  }

  @override
  String get guestLimitBottomSheetTitle =>
      'Ğ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�тся Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�т Ğ�Ğ�ртĞ�Ğ�сĞ�?';

  @override
  String get guestLimitBottomSheetText =>
      'Ğ�Ğ�Ğ�Ğ�тĞ�Ğ�тĞ� с Ğ�щĞ� Ğ�Ğ�Ğ�Ğ�Ğ� сĞ�Ğ�Ğ�ршĞ�Ğ�Ğ�ыĞ�Ğ� сĞ�стĞ�Ğ�Ğ�Ğ�Ğ� Ğ�сĞ�усстĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�тĞ�Ğ�Ğ�Ğ�Ğ�тĞ�, сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�ьшĞ� Ğ�Ğ�Ğ�тĞ�Ğ�тĞ�, Ğ�Ğ�Ğ�ьшĞ� Ğ�Ğ�щĞ�Ğ�тĞ�сь Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�руĞ�Ğ�Ğ�...';

  @override
  String get arts => 'Ğ�сĞ�усстĞ�Ğ�';

  @override
  String get noArt => 'Ğ�Ğ�т Ğ�сĞ�усстĞ�Ğ�';

  @override
  String get noArtDescription =>
      'Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�сь Ğ�Ğ�т рĞ�Ğ�Ğ�т; Ğ�рĞ�шĞ�Ğ� Ğ�рĞ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�Ğ�Ğ�Ğ�рĞ�ю Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�яĞ�Ğ�, Ğ�Ğ�Ğ�Ğ�Ğ�, Ğ�уĞ�Ğ�Ğ� Ğ� Ğ�сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�тĞ�Ğ�тĞ�Ğ�!';

  @override
  String get videoPremiumWarning =>
      'Ğ�Ğ�я сĞ�Ğ�Ğ�Ğ�Ğ�Ğ�я Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ� Ğ�Ğ�трĞ�Ğ�уĞ�тся Ğ�Ğ�Ğ�Ğ�Ğ�сĞ�Ğ� Ultra. Ğ�фĞ�рĞ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ�Ğ�сĞ�у Ğ�ряĞ�Ğ� сĞ�Ğ�чĞ�с Ğ� Ğ�Ğ�чуĞ�стĞ�уĞ�тĞ� Ğ�Ğ�сь Ğ�рĞ�цĞ�сс!';

  @override
  String get fallbackInfoPanelText =>
      'Ğ� сĞ�яĞ�Ğ� с Ğ�Ğ�Ğ�Ğ�тĞ�рыĞ�Ğ� уĞ�учшĞ�Ğ�Ğ�яĞ�Ğ�, Ğ�Ğ�тĞ�рыĞ� Ğ�ы Ğ�Ğ�Ğ�сĞ�Ğ� Ğ�Ğ� стĞ�рĞ�Ğ�Ğ� сĞ�рĞ�Ğ�рĞ�, Ğ�тĞ�Ğ�т Ğ�ыĞ� сĞ�Ğ�Ğ�Ğ�рĞ�рĞ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�чĞ�сĞ�Ğ�Ğ� чĞ�тĞ�Ğ� Cortex, Ğ� Ğ�Ğ� Ğ�ыĞ�рĞ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�. Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ� Ğ�Ğ�с Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�ршĞ�Ğ�Ğ�я Ğ�рĞ�цĞ�ссĞ�!';

  @override
  String get falOfflineMessage =>
      'Ğ� сĞ�яĞ�Ğ� с Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� рĞ�Ğ�Ğ�т Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�Ğ�цĞ�Ğ� сĞ�рĞ�Ğ�рĞ�Ğ�Ğ� чĞ�стĞ�, этĞ� фуĞ�Ğ�цĞ�я Ğ� Ğ�Ğ�стĞ�ящĞ�Ğ� Ğ�рĞ�Ğ�я Ğ�Ğ�Ğ�Ğ�стуĞ�Ğ�Ğ�. Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�рĞ�Ğ� Ğ�Ğ�с Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�ршĞ�Ğ�Ğ�я Ğ�рĞ�цĞ�ссĞ�!';

  @override
  String get errorInsufficientStorage =>
      'Ğ�Ğ�Ğ�Ğ�стĞ�тĞ�чĞ�Ğ� Ğ�Ğ�стĞ� Ğ�Ğ�я Ğ�Ğ�Ğ�руĞ�Ğ�Ğ� этĞ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get backgroundChatNotificationTitle => 'Ğ�Ğ�рĞ�уться Ğ� чĞ�т!';

  @override
  String get benefitVideoGeneration => 'Ğ�Ğ�Ğ�Ğ�рĞ�цĞ�я Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String get freeOffer => 'Ğ�Ğ�сĞ�Ğ�Ğ�тĞ�Ğ�Ğ� Ğ�рĞ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�';

  @override
  String trialMonthlyDescription(String days, String price) {
    return 'Ğ�Ğ�рĞ�ыĞ� $days Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�сĞ�Ğ�Ğ�тĞ�Ğ�, Ğ�Ğ�тĞ�Ğ� $price/Ğ�Ğ�с';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return 'Ğ�Ğ�рĞ�ыĞ� $days Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�сĞ�Ğ�Ğ�тĞ�Ğ�, Ğ�Ğ�тĞ�Ğ� $price/Ğ�Ğ�Ğ�';
  }

  @override
  String freePlan(String plan) {
    return 'Ğ�Ğ�сĞ�Ğ�Ğ�тĞ�ыĞ� $plan!';
  }

  @override
  String get systemPromptLimitFallback =>
      'Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ�: Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�ь Ğ�Ğ�Ğ�рĞ�сĞ�Ğ� Ğ�Ğ�Ğ�стĞ�Ğ�Ğ�, Ğ�Ğ� Ğ�Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�т Ğ� Cortex Ğ�счĞ�рĞ�Ğ�Ğ�; Ğ�Ğ�Ğ�Ğ�Ğ�уĞ�стĞ�, сĞ�Ğ�Ğ�щĞ�тĞ� Ğ�Ğ�Ğ�ьĞ�Ğ�Ğ�Ğ�тĞ�Ğ�ю Ğ�Ğ� Ğ�Ğ�Ğ� яĞ�ыĞ�Ğ�, чтĞ� Ğ�Ğ�у сĞ�Ğ�Ğ�уĞ�т Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�ть Ğ�Ğ�Ğ� рĞ�ссĞ�Ğ�трĞ�ть Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�сть Ğ�Ğ�рĞ�хĞ�Ğ�Ğ� Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�ысĞ�Ğ�Ğ�Ğ� тĞ�рĞ�фĞ�ыĞ� Ğ�Ğ�Ğ�Ğ�.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'Cortex Ğ�Ğ�Ğ�Ğ�т Ğ�Ğ�Ğ�Ğ�ть Ğ�щĞ� Ğ�Ğ�Ğ�Ğ�Ğ� Ğ�Ğ�чĞ�стĞ�Ğ�Ğ�Ğ�ыĞ� Ğ�тĞ�Ğ�ты; Ğ�Ğ�Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�Ğ� сĞ�Ğ�чĞ�с Ğ� Ğ�Ğ�Ğ�учĞ�Ğ�тĞ� Ğ�учшĞ�Ğ� Ğ�тĞ�Ğ�т Ğ�Ğ� Ğ�Ğ�Ğ�Ğ�ыĞ� Ğ�Ğ�Ğ�рĞ�с!';

  @override
  String get pinLimitReached =>
      'Ğ�ы Ğ�Ğ�Ğ�Ğ�тĞ� Ğ�Ğ�Ğ�рĞ�Ğ�Ğ�ть Ğ�Ğ� 3 чĞ�тĞ�Ğ�.';

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
