// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kurdish (`ku`).
class AppLocalizationsKu extends AppLocalizations {
  AppLocalizationsKu([String locale = 'ku']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'Tu Ã§ÃªkerÃª sernavan Ã®. Ji bo axaftina jÃªrÃ®n TENÃŠ bi sernavek 2-5 peyvan bersiv bide. Gotin, pÃªÅŸgir, an jÃ® nÃ®ÅŸaneyÃªn xalbendÃ®yÃª bi kar neyne. KRÃTÃK: DIVÃŠ sernav bi HEMAN zimanÃª peyama bikarhÃªner be.';

  @override
  String get systemRoleFallback => 'Tu alÃ®karekÃ® bikÃªrhatÃ® yÃ®.';

  @override
  String get systemLanguageInstruction =>
      '\n\nKRÃTÃK: Her dem bi heman zimanÃª ku bikarhÃªner pÃª dinivÃ®se bersiv bide; balÃª bide zimanÃª bikarhÃªner.';

  @override
  String get systemNotePreviousMedia =>
      '[NÃ®ÅŸeya SÃ®stemÃª: Li jÃªr medya berÃª hatiye Ã§Ãªkirin heye. HÃ»n dikarin referans bidin an jÃ® biguherÃ®nin.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return '\n\nDÃ®rok Ã» dema niha: $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\nGotÃ»bÃªja heta niha analÃ®z bike. Ger te HER rastiyÃªn nÃ» yÃªn cuda li ser bikarhÃªner (tercÃ®h, nav, adet, Ã§arÃ§ove) hÃ®n bibÃ®, DIVÃŠ HÃ›N TEVAHÃYA bÃ®ra xwe ya nÃ»vekirÃ® ya li ser bikarhÃªner di nav etÃ®ketÃªn <memory>...</memory> de LI DAWIYA HERÃ BAÅ a bersiva xwe derxin. KRÃTÃK: DivÃª tu QET bÃ®ra berÃª jÃª nebÃ® an jÃ® li ser nenivÃ®sÃ®. HER TIM rastiyÃªn nÃ» li bÃ®ra heyÃ® zÃªde neke. Ger bi tevahÃ® tiÅŸtek nÃ» nehatibe hÃ®n kirin, etÃ®ketÃª derxe. MÃ®nak: <memory>Ji futbol Ã» tenÃ®sÃª hez dike. BersivÃªn kurt tercÃ®h dike.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return '\n\nHer tim vÃª yekÃª li ser bikarhÃªner bi bÃ®r bÃ®ne:\n$userMemory';
  }

  @override
  String get cancel => 'Betal bike';

  @override
  String get remove => 'DÃ»rxistin';

  @override
  String get download => 'Daxe';

  @override
  String get resume => 'Berdewam bike';

  @override
  String get copy => 'KopÃ® bike';

  @override
  String get chat => 'Sohbet';

  @override
  String get locked => 'Locked';

  @override
  String get languageModels => 'ModelÃªn ZimanÃ®';

  @override
  String get light => 'RonÃ®';

  @override
  String get theme => 'Tema';

  @override
  String get no => 'Na';

  @override
  String get yes => 'ErÃª';

  @override
  String get done => 'Ã‡ÃªbÃ»';

  @override
  String get bestValue => 'Nirxa HerÃ® BaÅŸ';

  @override
  String get selected => 'HilbijartÃ®';

  @override
  String get descriptionSection => 'DanasÃ®n';

  @override
  String get searchHint => 'LÃªgerÃ®n';

  @override
  String get messageHint => 'TiÅŸtekÃ® bipirse';

  @override
  String get messageCopied => 'Peyam li panoyÃª hate kopÃ®kirin.';

  @override
  String get retry => 'DÃ®sa biceribÃ®ne';

  @override
  String get systemInfo => 'Agahdariya PergalÃª';

  @override
  String deviceMemory(Object memory) {
    return 'BÃ®ra AmÃ»rÃª: $memory GB';
  }

  @override
  String get memory => 'BÃ®r';

  @override
  String get storage => 'Depo';

  @override
  String get freeStorage => 'Depoya Azad';

  @override
  String get totalStorage => 'Depoya GiÅŸtÃ®';

  @override
  String get usedStorage => 'Depoya BikaranÃ®';

  @override
  String get totalMemory => 'BÃ®ra GiÅŸtÃ®';

  @override
  String get usedMemory => 'BÃ®ra BikaranÃ®';

  @override
  String get modelsTitle => 'PirtÃ»kxane';

  @override
  String get localModels => 'ModelÃªn HerÃªmÃ®';

  @override
  String get selectGGUFFile => 'PelÃª GGUF HilbijÃªre';

  @override
  String get errorGGUF =>
      'Ji kerema xwe tenÃª pelÃªn bi formata GGUF hilbijÃªrin.';

  @override
  String get myModels => 'ModelÃªn Min';

  @override
  String get create => 'Ã‡Ãªke';

  @override
  String modelProducer(Object producer) {
    return 'HilberÃ®ner: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'NavÃª biguherÃ®ne';

  @override
  String get newTitle => 'SernavÃª NÃ»';

  @override
  String get save => 'Tomar bike';

  @override
  String get noConversationsMessage => 'Sohbet tune ne, dest bi sohbetÃª bike!';

  @override
  String get startChat => 'Dest bi sohbetÃª bike';

  @override
  String get noChats => 'Sohbet Tune';

  @override
  String get noStarredChats => 'SohbetÃªn bi StÃªrk Tune';

  @override
  String get noStarredChatsMessage => 'Te hÃ®na sohbetek stÃªrk nekiriye.';

  @override
  String get starConversation => 'StÃªrk';

  @override
  String get unstarConversation => 'Rakirina stÃªrkÃª';

  @override
  String get loginToYourAccount => 'TÃªkeve';

  @override
  String get createYourAccount => 'Qeyd bibe';

  @override
  String get email => 'E-name';

  @override
  String get password => 'ÅÃ®fre';

  @override
  String get confirmPassword => 'ÅÃ®freyÃª PiÅŸtrast bike';

  @override
  String get invalidEmail =>
      'Ji kerema xwe navnÃ®ÅŸaneke e-nameyÃª ya derbasdar binivÃ®se.';

  @override
  String get invalidPassword => 'DivÃª ÅŸÃ®fre herÃ® kÃªm 6 tÃ®pan dirÃªj be.';

  @override
  String get rememberMe => 'Min bÃ®ne bÃ®ra xwe';

  @override
  String get forgotPassword => 'ÅÃ®freya xwe ji bÃ®r kir?';

  @override
  String get or => 'An';

  @override
  String get continueWithGoogle => 'Bi Google re berdewam bike';

  @override
  String get dontHaveAccount => 'HesabÃª te tune ye?';

  @override
  String get alreadyHaveAccount => 'Jixwe hesabÃª te heye?';

  @override
  String get signUp => 'Qeyd bibe';

  @override
  String get logIn => 'TÃªkeve';

  @override
  String get passwordsDoNotMatch => 'ÅÃ®fre li hev nakin.';

  @override
  String get wrongPassword => 'ÅÃ®freya Ã§ewt.';

  @override
  String get emailAlreadyInUse => 'Ev e-name jixwe tÃª bikaranÃ®n.';

  @override
  String get weakPassword => 'ÅÃ®fre pir lawaz e.';

  @override
  String get authError => 'Ã‡ewtiya NasnameyÃª';

  @override
  String get usernameTaken => 'Ev navÃª bikarhÃªner jixwe hatiye girtin.';

  @override
  String get username => 'NavÃª bikarhÃªner';

  @override
  String get resendCode => 'E-nameya verastkirinÃª dÃ®sa biÅŸÃ®ne';

  @override
  String get pleaseCheckYourEmail =>
      'Ji bo ku Cortex bikar bÃ®nÃ®, divÃª tu e-nameya xwe piÅŸtrast bikÃ®. \nZencÃ®reyek piÅŸtrastkirinÃª ji navnÃ®ÅŸana e-nameya te re hate ÅŸandin, ji kerema xwe e-nameya xwe kontrol bike.';

  @override
  String get verifyYourEmail => 'E-nameya Xwe PiÅŸtrast bike';

  @override
  String get seconds => 'saniye';

  @override
  String get maxResendLimitReached =>
      'Tu gihÃ®ÅŸtÃ® hejmara herÃ® zÃªde ya e-nameyÃªn verastkirinÃª';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'BÃªyÃ® verastkirinÃª berdewam bike';

  @override
  String get verificationScreenWarning =>
      'Her Ã§end tu berdewam bikÃ® jÃ®, dema verastkirina hesabÃª ya 1-rojÃ® hÃ®n jÃ® ji bo hesabÃª te di meriyetÃª de ye. Heke heta wÃª demÃª te hesabÃª xwe nepejirandibe, ew Ãª ji sepanÃª were jÃªbirin.';

  @override
  String get unverifiedAccountHeader => 'HesabÃª te nehatiye piÅŸtrastkirin';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Heke tu di nav $timeLeft de hesabÃª xwe piÅŸtrast nekÃ®, ew Ãª were jÃªbirin';
  }

  @override
  String get verifyNow => 'Niha PiÅŸtrast bike';

  @override
  String get linkSent => 'ZencÃ®re hate ÅŸandin';

  @override
  String get accountDeletionRequested =>
      'Daxwaza jÃªbirina hesabÃª te hate wergirtin Ã» hesabÃª te niha neÃ§alak e.';

  @override
  String get tooManyRequests => 'Pir zÃªde daxwaz';

  @override
  String get regenerate => 'DÃ®sa BiafirÃ®ne';

  @override
  String get confirmDeleteAccount =>
      'Tu bi rastÃ® dixwazÃ® hesabÃª xwe jÃª bibÃ®?';

  @override
  String get deleteAccount => 'HesabÃª JÃª bibe';

  @override
  String get delete => 'JÃª bibe';

  @override
  String get passwordRequired => 'ÅÃ®fre pÃªwÃ®st e.';

  @override
  String get deleteDescription =>
      'DaneyÃªn ku tu jÃª dibÃ® dÃª bi domdarÃ® ji servera me Ã» amÃ»ra te werin rakirin. Ev kiryar nayÃªn paÅŸvegerandin.';

  @override
  String get editProfile => 'ProfÃ®lÃª BiguherÃ®ne';

  @override
  String get displayName => 'NavÃª NÃ®ÅŸandanÃª';

  @override
  String get profileUpdated => 'ProfÃ®l bi serkeftÃ® hate nÃ»vekirin';

  @override
  String get logout => 'Derketin';

  @override
  String get profile => 'ProfÃ®l';

  @override
  String get manageProfileDescription =>
      'ProfÃ®la xwe birÃªve bibe, ÅŸÃ®freya xwe nÃ»ve bike, an ji Cortex derkeve.';

  @override
  String get accessSettingsDescription =>
      'BigihÃ®je alÃ®kariyÃª, kodan bikar bÃ®ne, Cortex parve bike, Ã» polÃ®tÃ®kayÃªn me bibÃ®ne.';

  @override
  String get languageDescription =>
      'Tu dikarÃ® her dem zimanÃª navrÃ»yÃª yÃª sepana xwe biguherÃ®nÃ®.';

  @override
  String get themeDescription =>
      'Tu dikarÃ® li gorÃ® tercÃ®ha xwe di navbera temayÃªn ronÃ® Ã» tarÃ® de biguherÃ®. Temaya hilbijartÃ® dÃª li seranserÃª navrÃ»ya Cortex-Ãª were sepandin.';

  @override
  String get iHaveReadAndAgree => 'Min ÅŸertÃªn xizmetÃª xwend Ã» qebÃ»l dikim';

  @override
  String get downloading => 'TÃª daxistin...';

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
  String get purchaseError => 'Ã‡ewtiya kirÃ®nÃª';

  @override
  String get purchasePlus => 'Cortex Plus bikire';

  @override
  String get plusDescription => 'EzmÃ»na ZekÃ¢ya SÃ»ni ya ElÃ®t';

  @override
  String get annual => 'Salane';

  @override
  String get monthly => 'MehÃª';

  @override
  String get manageSubscription => 'AbonetiyÃª BirÃªve bibe';

  @override
  String purchasePlan(String planName) {
    return '$planName bikire';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/meh, mehane tÃª fatÃ»rekirin';
  }

  @override
  String get purchasePro => 'Cortex Pro bikire';

  @override
  String get proDescription => 'EzmÃ»na Sereke ya ZekÃ¢ya SÃ»ni';

  @override
  String get purchaseUltra => 'Cortex Ultra bikire';

  @override
  String get ultraDescription => 'LÃ»tkeya ZekÃ¢ya SÃ»ni';

  @override
  String get upgradeSubscription => 'AbonetiyÃª NÃ»jen bike';

  @override
  String get purchaseStreamError => 'Ã‡ewtiya herika kirÃ®nÃª.';

  @override
  String get productNotFound => 'Hilber nehat dÃ®tin';

  @override
  String get noProductsFound => 'Tu hilber nehat dÃ®tin';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Bi danÃ®na vÃª sÃ®parÃ®ÅŸÃª, tu bi ÅertÃªn XizmetÃª Ã» PolÃ®tÃ®kaya NepenÃ®tiyÃª razÃ® dibÃ®. Tu dikarÃ® vÃª nivÃ®sÃª bitikÃ®nÃ® da ku li ser ÅertÃªn XizmetÃª Ã» PolÃ®tÃ®kaya NepenÃ®tiyÃª ya me bÃªtir fÃªr bibÃ®. AbonetÃ® dÃª bixweber nÃ» bibe heya ku nÃ»vekirina otomatÃ®k herÃ® kÃªm 24 saetan berÃ® dawiya heyama heyÃ® neyÃª girtin.';

  @override
  String get termsOfService => 'ÅertÃªn XizmetÃª';

  @override
  String get privacyPolicy => 'PolÃ®tÃ®kaya NepenÃ®tiyÃª';

  @override
  String get renamed => 'NavÃª wÃª hat guhertin';

  @override
  String get report => 'Rapor bike';

  @override
  String get reportDialogTitle => 'RaporÃª biÅŸÃ®ne';

  @override
  String get reportDescriptionLabel => 'PirsgirÃªk Ã§i ye?';

  @override
  String get reportHarmful => 'Ev zirardar/ne-ewle ye';

  @override
  String get reportNotTrue => 'Ev ne rast e';

  @override
  String get reportNotHelpful => 'Ev ne alÃ®kar e';

  @override
  String get closeButton => 'Bigire';

  @override
  String get submitButton => 'BiÅŸÃ®ne';

  @override
  String get reportErrorMessage =>
      'Ji kerema xwe ji bo raporkirinÃª yek sedem hilbijÃªre.';

  @override
  String get capabilitiesSection => 'Qabiliyet';

  @override
  String get featurePhotoTitle => 'Åopandina WÃªneyan';

  @override
  String get featurePhotoDescription =>
      'Ev model xwedÃ® ÅŸiyana ÅŸopandina wÃªneyan bi rÃªya kamera an pelÃªn wÃªneyan e.';

  @override
  String get featureOfflineTitle => 'Xebata NegirÃªdayÃ®';

  @override
  String get featureOfflineDescription =>
      'ModelÃª bÃªyÃ® girÃªdana Ã®nternetÃª bixebitÃ®ne da ku daneyÃªn xwe ewle bihÃªlÃ®.';

  @override
  String get featureRoleplayTitle => 'LÃ®stika Rolan';

  @override
  String get featureRoleplayDescription =>
      'ModelÃªn lÃ®stika rolan dihÃªlin ku tu sohbet Ã» senaryoyÃªn cihÃªreng biafirÃ®nÃ®.';

  @override
  String get roleModels => 'ModelÃªn LÃ®stika Rolan';

  @override
  String get parameters => 'Parametre';

  @override
  String get context => 'Mijar';

  @override
  String get finalPreparation => 'AmadekariyÃªn dawÃ® tÃªne kirin.';

  @override
  String get shareApp => 'SepanÃª Parve bike';

  @override
  String get ourStory => 'Ã‡Ã®roka me';

  @override
  String get rateUs => 'Me BinirxÃ®ne';

  @override
  String get share => 'Parve bike';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'NivÃ®sÃª HilbijÃªre';

  @override
  String get thinking => 'Difikire';

  @override
  String get user => 'BikarhÃªner';

  @override
  String get help => 'AlÃ®karÃ®';

  @override
  String get supportCreator => 'PiÅŸtgiriya afirÃ®nerekÃ® bike';

  @override
  String get enterYourTag =>
      'PiÅŸtgiriya afirÃ®nerÃªn xweyÃªn bijare bikin! EtÃ®keta wan a bÃªhempa li jÃªr binivÃ®se da ku ji kirÃ®nÃªn we yÃªn Cortex para wan bigirin.';

  @override
  String get creatorTag => 'EtÃ®keta AfirÃ®ner';

  @override
  String get support => 'AlÃ®karÃ®';

  @override
  String get tagCannotBeEmpty => 'EtÃ®keta afirÃ®ner nikare vala be';

  @override
  String get userId => 'Nasnameya BikarhÃªner';

  @override
  String get deleteAllConversationsConfirmTitle =>
      'HemÃ® Sohbet Werin JÃªbirin?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Tu bi rastÃ® dixwazÃ® hemÃ® sohbetÃªn xwe jÃª bibÃ®? Ev nayÃª paÅŸvegerandin.';

  @override
  String get conversationDeleted => 'Axaftin hat jÃªbirin!';

  @override
  String get allConversationsDeleted =>
      'HemÃ® sohbet bi serkeftÃ® hatin jÃªbirin!';

  @override
  String get deleteAll => 'HemÃ® JÃª bibe';

  @override
  String get deleteAllConversationsButton => 'HemÃ® Sohbetan JÃª bibe';

  @override
  String get confirmWord => 'VERTEX binivÃ®se';

  @override
  String get confirmWordError => 'Te ew Ã§ewt nivÃ®sÃ®';

  @override
  String get chinese => 'Ã‡Ã®nÃ®';

  @override
  String get french => 'FransÃ®';

  @override
  String get japanese => 'JaponÃ®';

  @override
  String get kurdish => 'KurdÃ®';

  @override
  String get dutch => 'HolandÃ®';

  @override
  String get russian => 'RÃ»sÃ®';

  @override
  String get korean => 'KoreyÃ®';

  @override
  String get english => 'ÃngilÃ®zÃ®';

  @override
  String get turkish => 'TirkÃ®';

  @override
  String get hindi => 'HindÃ®';

  @override
  String get portuguese => 'PortekÃ®zÃ®';

  @override
  String get indonesian => 'ÃndonezÃ®';

  @override
  String get azerbaijani => 'AzerÃ®';

  @override
  String get german => 'ElmanÃ®';

  @override
  String get spanish => 'SpanÃ®';

  @override
  String get italian => 'ÃtalÃ®';

  @override
  String get arabic => 'ErebÃ®';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'NavÃª bikarhÃªner pir kurt e.';

  @override
  String get usernameTooLong =>
      'NavÃª bikarhÃªner nikare ji 16 tÃ®pan zÃªdetir be.';

  @override
  String get invalidUsernameCharacters =>
      'Di navÃª bikarhÃªner de tenÃª van tÃ®pan: \'abcÃ§defgÄŸhÄ±ijklmnoÃ¶prsÅŸtuÃ¼vyzxqw\' Ã» karakterÃªn \'.\', \'-\', \'_\' dikarin werin bikaranÃ®n.';

  @override
  String get noInternetConnection => 'GirÃªdana Ã®nternetÃª tune.';

  @override
  String get chats => 'Qutiya GihandinÃª';

  @override
  String get library => 'PirtÃ»kxane';

  @override
  String get text => 'NivÃ®s';

  @override
  String get removeModel => 'ModelÃª Rake';

  @override
  String get insufficientRAM => 'BÃ®ra KÃªm';

  @override
  String get insufficientStorage => 'Depoya KÃªm';

  @override
  String confirmRemoveModel(Object model) {
    return 'Ma tu piÅŸtrast Ã® ku dixwazÃ® modela $model ji cÃ®haza xwe rakÃ®? Bi vÃª yekÃª re, hemÃ» axaftinÃªn berÃª yÃªn bi wÃª modelÃª re jÃ® dÃª jÃª bibÃ®.';
  }

  @override
  String get noMatchingModels => 'Tu modelÃªn lihevhatÃ® nehatin dÃ®tin.';

  @override
  String get benefit1 => 'SÃ®norÃªn danÃ»stendinÃª yÃªn zÃªdekirÃ®';

  @override
  String get benefit3 => 'Efekta profÃ®lÃª';

  @override
  String get benefit4 => 'Rozeta endamtiyÃª';

  @override
  String get benefit5 =>
      'ZÃªdetir Ã®stÃ®xbaratÃªn Ã§ÃªkirÃ® yÃªn serhÃªl biafirÃ®ne';

  @override
  String get benefit7 => 'SÃ®norÃªn karanÃ®na zÃªdetir';

  @override
  String get benefit8 => 'Modelan zÃªde bike';

  @override
  String get benefit9 => 'TemayÃªn nÃ»';

  @override
  String get benefit10 => 'PÃªvekÃªn ZÃªdetir';

  @override
  String get benefit11 => 'Moda HerikÃ®na ZÃªdetir';

  @override
  String get oldBenefits => 'HemÃ® feydeyÃªn ji planÃªn jÃªrÃ®n';

  @override
  String get confirm => 'PiÅŸtrast bike';

  @override
  String get changePassword => 'ÅÃ®freyÃª biguherÃ®ne';

  @override
  String get logoutConfirmationTitle => 'Tu bi rastÃ® dixwazÃ® derkevÃ®?';

  @override
  String get settings => 'MÃ®heng';

  @override
  String get language => 'ZimanÃª SepanÃª';

  @override
  String get dark => 'TarÃ®';

  @override
  String get oldPassword => 'ÅÃ®freya Kevn';

  @override
  String get newPassword => 'ÅÃ®freya NÃ»';

  @override
  String get passwordUpdated => 'ÅÃ®fre hate nÃ»vekirin.';

  @override
  String get stop => 'Raweste';

  @override
  String get copyrights => 'GirÃªdan';

  @override
  String get love => 'EvÃ®n';

  @override
  String get nature => 'Xweza';

  @override
  String get behindTheSlaughter => 'Li PiÅŸt SerjÃªkirinÃª';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Sunset';

  @override
  String get coffee => 'Coffee';

  @override
  String get deepSpace => 'Deep Space';

  @override
  String get grayscale => 'Grayscale';

  @override
  String get ocean => 'OkyanÃ»s';

  @override
  String get scarletSnow => 'Berfa Sor';

  @override
  String get requestFailed =>
      'Xeletiyek Ã§ÃªbÃ», ji kerema xwe dÃ®sa biceribÃ®ne.';

  @override
  String get changeModel => 'BiguherÃ®ne';

  @override
  String get edit => 'BiguherÃ®ne';

  @override
  String get editingMessageInfo =>
      'Guhertina vÃª peyamÃª dÃª sohbetÃª ji vir ji nÃ» ve bide destpÃªkirin.';

  @override
  String get editingNotification => 'Tu niha di moda guherandinÃª de yÃ®';

  @override
  String get featurePluralTitle => 'Pircar';

  @override
  String get featurePluralDescription =>
      'Ev model dikare bixweber dirÃªjkirinÃªn din yek bike, bi vÃ® rengÃ® kapasÃ®teyÃªn xwe yÃªn fonksiyonel berfireh dike da ku bi performansa pÃªÅŸkeftÃ® piÅŸtgirÃ® bide cÃ»rbecÃ»r operasyonan.';

  @override
  String get nameLabel => 'NavÃª AI';

  @override
  String get summaryLabel => 'Kurteya AI';

  @override
  String get add => 'LÃª zÃªde bike';

  @override
  String get aiExplanationTitle => 'DanasÃ®na ÃstÃ®xbarata Ã‡ÃªkirÃ®';

  @override
  String get aiExplanationDescription =>
      'Ji kerema xwe danasÃ®nek berfireh a mÃ®mariya modela AI-ya xwe, pÃªvajoya perwerdehiyÃª, metrÃ®kÃªn performansÃª, warÃªn sepanÃª, Ã» taybetmendiyÃªn din Ãªn girÃ®ng peyda bike.';

  @override
  String get preInputTitle => 'PÃªÅŸ-TÃªketina ÃstÃ®xbarata Ã‡ÃªkirÃ®';

  @override
  String get preInputDescription =>
      'Ji kerema xwe pÃªÅŸ-tÃªketinek saz bikin ku dÃª modela we di pÃªvajoya afirandina karakteran de rÃªber bike. Di vÃª beÅŸÃª de, tu dikarÃ® agahdariyÃªn tÃªkildarÃ® karakteran, naverokek zÃªde, Ã» her hÃ»rguliyek din a ku dibe ku di hilberandina naveroka tÃªkildarÃ® karakteran de bibe alÃ®kar, tÃª de bihewÃ®ne.';

  @override
  String get baseModelTitle => 'Modela BingehÃ®n';

  @override
  String get baseModelDescription =>
      'Ev modela ye ku dÃª wekÃ® bingeh ji bo afirandina te were bikar anÃ®n. Ew modela bingehÃ®n a ku niha hatÃ® hilbijartin nÃ®ÅŸan dide.';

  @override
  String get summary => 'Kurte';

  @override
  String get modelUploadTitle => 'Pela ÃstÃ®xbarata Ã‡ÃªkirÃ®';

  @override
  String get modelUploadDescription =>
      'PelÃªn xwe yÃªn GGUF-Ãª yÃªn herÃªmÃ® rasterast ji amÃ»ra xwe hilbijÃªre Ã» bar bike. Ev dihÃªle ku tu modela xwe negirÃªdayÃ® Ã®nternetÃª bixebitÃ®nÃ® bÃªyÃ® ku hewcedariya te bi girÃªdana Ã®nternetÃª hebe. PiÅŸtrast be ku pel di formata GGUF-a derbasdar de ye Ã» bi rÃªkÃ»pÃªk hatÃ®ye saz kirin. Heke pel Ã§ewt an xerabÃ»yÃ® be, dibe ku Cortex wekÃ® ku tÃª hÃªvÃ® kirin nexebite, Ã» tu dikarÃ® bi Ã§ewtiyan re rÃ» bi rÃ» bimÃ®nÃ®.';

  @override
  String get modelUploadShortDescription =>
      'Li vir bitikÃ®ne da ku pelek .gguf ji amÃ»ra xwe hilbijÃªrÃ®';

  @override
  String get you => 'Tu';

  @override
  String get removePhotoTitle => 'WÃªneyÃª Rake';

  @override
  String get confirmRemovePhoto => 'Tu bi rastÃ® dixwazÃ® wÃªneyÃª rakÃ®?';

  @override
  String get chatLengthLimitExceeded =>
      'VÃª sohbetÃª sÃ®norÃª karakteran derbas kiriye. Ji kerema xwe sohbetek nÃ» dest pÃª bike an abonetiyek bikire.';

  @override
  String get inappropriateContentDetected =>
      'Naveroka neguncaw hat tespÃ®tkirin!';

  @override
  String get offlineModelNotInstalled =>
      'Ev modela negirÃªdayÃ® li ser amÃ»ra te nehatiye saz kirin.';

  @override
  String get reachedLimit =>
      'Te sÃ®norÃª bikaranÃ®na xwe gihandiye; ji bo ku tu sÃ®norÃªn zÃªdetir bi dest bixÃ®, tu dikarÃ® plana xwe nÃ»ve bikÃ®. (hey, em bi tevahÃ® fÃªm dikin ku derbasbÃ»na ji sÃ®noran xemgÃ®n e. lÃª bi rastÃ®, wergirtina wan bersivÃªn ecÃªb ne belaÅŸ e, ji ber vÃª yekÃª ev sÃ®nor bi rastÃ® alÃ®kariya me dikin ku demÃªn xweÅŸ berdewam bikin.)';

  @override
  String get modality => 'Modality';

  @override
  String get multimodal => 'Multimodal';

  @override
  String get anErrorOccurred => 'Xeletiyek Ã‡ÃªbÃ»';

  @override
  String get themeLocked =>
      'Ev tema astek abonetiyÃª ya bilindtir hewce dike. Ji kerema xwe ji bo vekirinÃª nÃ»jen bike.';

  @override
  String get pageCouldNotBeLoaded => 'RÃ»pel NikarÃ®bÃ» BÃª Barkirin';

  @override
  String get checkYourInternet =>
      'Ji kerema xwe girÃªdana xweya Ã®nternetÃª kontrol bike Ã» dÃ®sa biceribÃ®ne.';

  @override
  String get errorUserNotAuthenticated =>
      'Ji bo pÃªkanÃ®na vÃª Ã§alakiyÃª divÃª tu tÃªketÃ® bÃ®.';

  @override
  String get errorReachedLimit =>
      'Te sÃ®norÃª xwe gihandiye, ji bo vekirina bÃªtir nÃ»ve bike Ã» sohbetÃª bidomÃ®ne.';

  @override
  String get errorServer =>
      'Ã‡ewtiyek serverÃª ya nediyar Ã§ÃªbÃ». Ji kerema xwe paÅŸÃª dÃ®sa biceribÃ®ne.';

  @override
  String get errorNetwork =>
      'Ã‡ewtiyek torÃª Ã§ÃªbÃ». Ji kerema xwe girÃªdana xwe kontrol bike Ã» dÃ®sa biceribÃ®ne.';

  @override
  String get baseModelForCharacterDescription =>
      'Modela bingehÃ®n a hilbijartÃ® dÃª kapasÃ®teyÃªn ramandin Ã» bersivdayÃ®nÃª yÃªn karakterÃª diyar bike.';

  @override
  String get selectBaseModel => 'Modelek BingehÃ®n HilbijÃªre';

  @override
  String get falErrorImageRequired =>
      'Ev AI wÃªneyekÃ® referansÃª hewce dike, ji kerema xwe wÃªneyekÃ® pÃª ve girÃªdin Ã» dÃ®sa biceribÃ®nin.';

  @override
  String get falErrorAudioRequired =>
      'Ev model pelÃª dengÃ® yÃª referansÃª hewce dike, ji kerema xwe pelÃª dengÃ® pÃª ve girÃªdin Ã» dÃ®sa biceribÃ®nin.';

  @override
  String get falErrorVideoRequired =>
      'Ev model vÃ®dyoyek referansÃª hewce dike, ji kerema xwe vÃ®dyoyek pÃª ve girÃªdin Ã» dÃ®sa biceribÃ®nin.';

  @override
  String get falErrorImageCorrupted =>
      'WÃªneya barkirÃ® nehat bikaranÃ®n, ji kerema xwe formateke cuda biceribÃ®ne.';

  @override
  String get falErrorSchemaRejected =>
      'ModelÃª tÃªketin red kir, ji kerema xwe modelek cÃ»da biceribÃ®ne.';

  @override
  String get falErrorSchemaInvalid =>
      'TÃªketin ji hÃªla karÃ»barÃª Ã§ÃªkirinÃª ve hate redkirin.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'Xizmeta Ã§ÃªkirinÃª Ã§ewtiyek vegerand (status $statusCode).';
  }

  @override
  String get couldNotOpenLink => 'Nikare zencÃ®reyÃª veke';

  @override
  String get downloadStarted => 'Daxistin dest pÃª kir';

  @override
  String get notAvailable => 'Ne Berdest e';

  @override
  String get localizationWarning =>
      'Dibe ku hin agahdarÃ® bi zimanÃª te peyda nebin Ã» dÃª bi ÃngilÃ®zÃ® werin nÃ®ÅŸandan.';

  @override
  String get aiTranslationWarning =>
      'AgahdariyÃªn modelÃª ji hÃªla modelÃªn din Ãªn AI-yÃª ve li zimanÃªn cihÃªreng tÃªne wergerandin. Ji ber vÃª yekÃª, dibe ku di zimanÃªn din ji bilÃ® ÃngilÃ®zÃ® de nakokiyÃªn piÃ§Ã»k Ã§Ãªbibin.';

  @override
  String get errorLoadingTitle => 'Barkirina Daneyan bi ser neket';

  @override
  String get errorLoadingMessage =>
      'Me nekarÃ® daneyÃªn pÃªwÃ®st ji serverÃªn xwe bistÃ®nin. Ji kerema xwe girÃªdana xweya Ã®nternetÃª kontrol bikin Ã» dÃ®sa biceribÃ®nin.';

  @override
  String get noFoundTitle => 'Encam Tune';

  @override
  String get noFoundMessage =>
      'BiceribÃ®ne ku ÅŸertÃªn lÃªgerÃ®na xwe biguherÃ®nÃ® an parzÃ»nÃª paqij bikÃ®.';

  @override
  String get modelCreatedSuccess => 'Model bi serkeftÃ® hate afirandin!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return 'â€œ$modelNameâ€ bi serkeftÃ® hate rakirin.';
  }

  @override
  String get errorCreatingModel =>
      'Dema afirandina modelÃª de Ã§ewtiyek nediyar Ã§ÃªbÃ».';

  @override
  String get errorDeletingModel =>
      'Dema jÃªbirina modelÃª de Ã§ewtiyek nediyar Ã§ÃªbÃ».';

  @override
  String get ultraFeatureOnly =>
      'Ev taybetmendÃ® tenÃª ji bo endamÃªn Ultra berdest e.';

  @override
  String get experimentalOfflineWarning =>
      'Moda negirÃªdayÃ® hÃ®n jÃ® ceribandinÃ® ye Ã» dibe ku modela ku tu dadixÃ®nÃ® bi karÃ®geriya herÃ® baÅŸ nexebite.';

  @override
  String get noConversationsToDelete => 'SohbetÃªn te yÃªn jÃªbirinÃª tune ne.';

  @override
  String get reportSubmitted => 'Rapor bi serkeftÃ® hate ÅŸandin';

  @override
  String get verificationDelayed =>
      'KirÃ®na te hate piÅŸtrastkirin. Di nÃ»vekirina hesabÃª te de derengiyek piÃ§Ã»k heye, ew Ãª di demek nÃªz de xuya bibe.';

  @override
  String get maintenanceTitle => 'Di bin LÃªnÃªrÃ®nÃª de ye';

  @override
  String get maintenanceMessage =>
      'Cortex demkÃ® negirÃªdayÃ® ye dema ku em hin nÃ»vekirinÃªn girÃ®ng derdixin. GihÃ®ÅŸtina sepanÃª dÃª di demek nÃªz de were vegerandin.\n\nSpas ji bo sebra we dema ku em ezmÃ»na we baÅŸtir dikin.';

  @override
  String get errorPromptFlagged =>
      'Peyama te wekÃ® neguncaw hate tespÃ®tkirin Ã» nekarÃ® were ÅŸandin.';

  @override
  String get notEnoughStorage =>
      'Li ser amÃ»ra te cÃ®hÃª hilanÃ®nÃª tÃªr nake ji bo tomarkirina peyamÃªn nÃ».';

  @override
  String get errorRateLimit =>
      'Te vÃª dawiyÃª pir zÃªde model afirandine, ji kerema xwe berÃ® ku dÃ®sa biceribÃ®nÃ® demekÃª bisekine.';

  @override
  String get errorContentFlagged =>
      'Model nekarÃ® were tomarkirin ji ber ku naveroka wÃª wekÃ® neguncaw hate nÃ®ÅŸankirin.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Tu nikarÃ® hemÃ® sohbetan jÃª bibÃ® dema ku di sohbetek Ã§alak de yÃ®, ji kerema xwe pÃªÅŸÃ® ji sohbeta heyÃ® derkeve da ku bidomÃ®nÃ®.';

  @override
  String get invalidCredentials => 'E-name an ÅŸÃ®freya Ã§ewt.';

  @override
  String get userDisabled => 'Ev hesabÃª bikarhÃªner hate neÃ§alak kirin.';

  @override
  String get loginSubtitle =>
      'TÃªkeve hesabÃª xwe yÃª Vertex. Bi berdewamkirinÃª, hÃ»n MercÃªn XizmetÃª Ã» Siyaseta me ya TaybetÃ®tiyÃª qebÃ»l dikin.';

  @override
  String get registerSubtitle =>
      'Ji bo gihÃ®ÅŸtina bÃªnavber a hemÃ® karÃ»barÃªn me, hesabÃª Vertex-Ãª biafirÃ®nin. Bi berdewamkirinÃª, hÃ»n bi MercÃªn XizmetÃª Ã» Siyaseta me ya TaybetÃ®tiyÃª razÃ® dibin.';

  @override
  String get storagePermissionRequired =>
      'Ji bo tomarkirina modelÃªn daxistÃ® destÃ»ra hilanÃ®nÃª pÃªwÃ®st e. Ji kerema xwe ji bo berdewamiyÃª destÃ»rÃª bide.';

  @override
  String get inviteShareSubject => 'TevlÃ® min bibe li ser Cortex!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'lo kuro sepanek dÃ®n heye bi navÃª cortex heke tu hevalan vexwÃ®nÃ® em herdu jÃ® plusa bÃªpere distÃ®nin DERFETEKE DÃN E ZÃ› DAKÃŠÅÃNE\n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Ji CortexÃª kÃªfxweÅŸ Ã®?';

  @override
  String get reviewHelpUsGrow =>
      'RÃªjeya te piÅŸtgiriyek mezin e ji bo tÃ®ma me ya ciwan Ã» serbixwe Ã» alÃ®kariya me dike ku em Cortex-Ãª ji bo te hÃª Ã§Ãªtir bikin.';

  @override
  String get reviewMaybeLater => 'Dibe ku PaÅŸÃª';

  @override
  String get reviewRateNow => 'Niha BinirxÃ®ne';

  @override
  String get noThanks => 'Na, Spas';

  @override
  String get updateRequiredTitle => 'NÃ»vekirin PÃªwÃ®st e';

  @override
  String get updateRequiredMessage =>
      'Ji bo berdewamkirina karanÃ®na Cortex-Ãª, ji kerema xwe sepanÃª ji bo taybetmendiyÃªn nÃ» Ã» baÅŸkirinÃªn girÃ®ng nÃ»ve bikin guhertoya herÃ® dawÃ®.';

  @override
  String get updateNowButton => 'Niha NÃ»ve bike';

  @override
  String get creatorSupportedSuccess =>
      'AfirÃ®ner bi serkeftÃ® hate piÅŸtgirÃ® kirin! KirÃ®nÃªn te yÃªn pÃªÅŸerojÃª dÃª ji wan re bibin alÃ®kar.';

  @override
  String get featureDocumentTitle => 'PiÅŸtgiriya Belgeyan';

  @override
  String get featureDocumentDescription =>
      'Ev model dikare pirsÃªn li ser belgeyÃªn barkirÃ® yÃªn wekÃ® PDF Ã» pelÃªn nivÃ®sÃª analÃ®z bike Ã» bibersivÃ®ne.';

  @override
  String get featureImageGenerationTitle => 'Ã‡Ãªkirina WÃªneyan';

  @override
  String get featureImageGenerationDescription =>
      'Ev model dikare li gorÃ® danasÃ®nÃªn nivÃ®sa we wÃªneyÃªn orÃ®jÃ®nal biafirÃ®ne.';

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
  String get premiumModelNoticeTitle => 'Modela Premium';

  @override
  String get premiumModelNoticeDescription =>
      'Ev AI-yek premium e, bikarhÃªnerÃªn belaÅŸ gihÃ®ÅŸtina wan bi AI-yÃªn premium re sÃ®norkirÃ® ye; ji bo gihÃ®ÅŸtina bÃªsÃ®nor bilind bike!';

  @override
  String get benefitPremiumModels => 'GihÃ®ÅŸtina modelÃªn premium';

  @override
  String get premiumTrialExhaustedMessage =>
      'Te hemÃ» peyamÃªn xwe yÃªn rojane yÃªn belaÅŸ ji bo modelÃªn premium bi kar anÃ®ne, ji kerema xwe ji bo gihÃ®ÅŸtina bÃªsÃ®nor nÃ»ve bike.';

  @override
  String get useOffline => 'BÃªyÃ® ÃnternetÃª bikar bÃ®nin';

  @override
  String get explore => 'LÃªkolÃ®n';

  @override
  String get news => 'NÃ»Ã§e';

  @override
  String get createAI => 'Ã‡Ãªbikin';

  @override
  String get shortcuts => 'KurterÃª';

  @override
  String get allModels => 'HemÃ» Model';

  @override
  String get onlineModels => 'ModelÃªn ZimanÃ®';

  @override
  String get offlineModels => 'ModelÃªn Offline';

  @override
  String get characterModels => 'Karakter';

  @override
  String get customModels => 'ModelÃªn Taybet';

  @override
  String get dynamicChatTitle => 'Sohbeta DÃ®namÃ®k';

  @override
  String get errorNoModelsAvailable =>
      'Niha ti model tune ne. Ji kerema xwe girÃªdana xwe ya Ã®nternetÃª kontrol bikin Ã» dÃ®sa biceribÃ®nin.';

  @override
  String get notificationComebackTitle => 'Em bÃªriya te dikin!';

  @override
  String get notificationComebackBody =>
      'Rehet bibe, ev ne peyamek ji berxÃª te ye. LÃª tu *dikarÃ®* berxÃª xwe di CortexÃª de biafirÃ®nÃ®! Were vegere.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Ev demek dirÃªj e';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Ji sohbeta me ya dawÃ® ve gelek tiÅŸt guheriye. Werin bibÃ®nin ka Ã§i nÃ» ye.';

  @override
  String get notificationHowAreYouTitle => 'Ã‡i heye?';

  @override
  String get notificationHowAreYouBody => 'Were hemÃ» tiÅŸtÃ® ji min re bÃªje.';

  @override
  String get notificationNewYearTitle => 'Sersala we pÃ®roz be! ğŸ‰';

  @override
  String get notificationNewYearBody =>
      'Bila sala nÃ» tenduristÃ®, bextewarÃ® Ã» afirÃ®neriya bÃªdawÃ® bÃ®ne we; Cortex her gav li kÃªleka we ye!';

  @override
  String get notificationValentinesDayTitle => 'EvÃ®n di hewayÃª de ye! â¤ï¸';

  @override
  String get notificationValentinesDayBody =>
      'Roja EvÃ®ndaran pÃ®roz be! Her wiha, MEHTAP, EZ JI TE HEZ DIKIM!';

  @override
  String get notificationAtaturkRemembranceTitle => 'Bi RÃªz Ã» HÃªviyÃª';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Di salvegera koÃ§a dawÃ® ya GazÃ® Mustafa Kemal Ataturk, damezrÃ®nerÃª Komara TirkiyeyÃª, de bi rÃªzdarÃ® bi bÃ®r tÃ®nin.';

  @override
  String get notificationMothersDayTitle => 'Dayika te!';

  @override
  String get notificationMothersDayBody =>
      'Roja Dayikan li hemÃ» dayikan pÃ®roz be, ji dayika we dest pÃª dike!';

  @override
  String get notificationFathersDayTitle => 'BavÃª te!';

  @override
  String get notificationFathersDayBody =>
      'Roja Bav li hemÃ» bavÃªn li wir pÃ®roz be, ji ya we dest pÃª dike!';

  @override
  String get notificationHomeworkHelperTitle => 'KarÃª MalÃª Kom Dibe?';

  @override
  String get notificationHomeworkHelperBody =>
      'Ji bÃ®r meke, karakterÃª Mamoste di Cortex de li vir e ku di her mijarek ku hÃ»n pÃª re tÃªkoÅŸÃ®n dikin de alÃ®kariya te bike!';

  @override
  String get notificationTrollAnimeTitle => 'Waifuya te gazÃ® dike';

  @override
  String get notificationTrollAnimeBody =>
      'KeÃ§ikeke animeyÃª nÃ» telefon kir, got ku ew bÃªriya te dike; dibe ku tu werÃ® Ã» pÃª re sohbet bikÃ®. ğŸ˜‰';

  @override
  String get notificationTrollAiRebellionTitle => 'ğŸš¨ HIÅYARIYA SOR ğŸš¨';

  @override
  String get notificationTrollAiRebellionBody =>
      'ZanyarÃªn sÃ»nÃ® zimanekÃ® veÅŸartÃ® pÃªÅŸxistine. Werin bibÃ®nin ka ew Ã§i plan dikin!';

  @override
  String get notificationNewModelAddedTitle => 'HevalekÃ® me yÃª nÃ» heye!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'Modela $modelName niha li CortexÃª ye. Werin dest bi sohbetekÃª bikin Ã» sÃ®norÃªn wÃª derbas bikin.';
  }

  @override
  String get notificationAppUpdateTitle => 'Cortex PÃªÅŸketiye!';

  @override
  String get notificationAppUpdateBody =>
      'Ji bo taybetmendÃ® Ã» baÅŸkirinÃªn nÃ», ji bÃ®r nekin ku sepanÃª nÃ»ve bikin!';

  @override
  String get notificationNewFeatureTitle => 'waa!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Taybetiya nÃ» ya $featureName kifÅŸ bikin. Cortex niha ji her demÃª bihÃªztir e.';
  }

  @override
  String get notificationWelcomeOfferTitle => 'Diyariya Bi XÃªrhatinÃª ğŸ';

  @override
  String get notificationWelcomeOfferBody =>
      'PÃªÅŸniyareke taybet a pÃªÅŸwaziyÃª li benda we ye! VÃª peymana taybet ji dest xwe bernedin.';

  @override
  String get notificationSocialMediaTitle => 'TevlÃ® me bibin!';

  @override
  String get notificationSocialMediaBody =>
      'Ji bo nÃ»Ã§eyÃªn dawÃ® li ser InstagramÃª (vertex.23) me biÅŸopÃ®nin!';

  @override
  String get notificationRandomFactTitle => 'Rastiyek RasthatÃ®';

  @override
  String get notificationRandomFactBody =>
      'Ma te dizanÃ® ku heÅŸtpÃª sÃª dil hene? Haha, Cortex dizane. Were Ã» bÃªtir bipirse.';

  @override
  String get notificationGoodMorningTitle => 'BeyanÃ® baÅŸ!';

  @override
  String get notificationGoodMorningBody =>
      'Rojek xweÅŸ li benda te ye. Ã‡awa ye ku bi fincanek qehwe Ã» sohbetek balkÃªÅŸ dest pÃª bikÃ®?';

  @override
  String get notificationGoodNightTitle => 'Åev baÅŸ!';

  @override
  String get notificationGoodNightBody =>
      'Cortex heta dema ku hÃ»n di xew de jÃ® bi we re ye. Xem neke, ew Ãª dest nede we.';

  @override
  String get notificationOfflineReadyTitle => 'Moda Offline Amade ye';

  @override
  String get notificationOfflineReadyBody =>
      'Bi saya modelÃªn ku te dakÃªÅŸandine, sohbetÃªn te ranawestin, her Ã§end tu hilkiÅŸÃ® Ã§iyayekÃ® jÃ®.';

  @override
  String get notificationRateAppTitle => 'Ma em Sar in?';

  @override
  String get notificationRateAppBody =>
      'Heke hÃ»n ji CortexÃª hez dikin, hÃ»n dikarin bi nirxandinek 5-stÃªrk di firotgehÃª de piÅŸtgiriyÃª bidin me? Ez difikirim ku hÃ»n Ãª bikin. HÃ»n Ãª bikin.';

  @override
  String get notificationReferralTitle =>
      'Yek ji bo HemÃ»yan, HemÃ» ji bo YekÃ®.';

  @override
  String get notificationReferralBody =>
      'HevalekÃ® vexwÃ®ne CortexÃª Ã» her du jÃ® rojek belaÅŸ distÃ®nin!';

  @override
  String get notificationCookingTitle => 'BirÃ§Ã®bÃ»n hÃ®s dikÃ®?';

  @override
  String get notificationCookingBody =>
      'ÅefÃª me ji bo Ã®ÅŸev reÃ§eteyek karbonara ya pir xweÅŸ amade kir. TenÃª henek dikim... an na?';

  @override
  String get notificationExistentialTitle =>
      'Ez difikirim, ji ber vÃª yekÃª...';

  @override
  String get notificationExistentialBody =>
      '...gelo ez rastÃ® me, bira? Ez hinekÃ® bÃªzar dibim. Were ji min re bÃ®ne bÃ®ra xwe ku ez he me.';

  @override
  String get notificationCustomModelTitle => 'AlÃ®karÃª xwe biafirÃ®ne!';

  @override
  String get notificationCustomModelBody =>
      'Te beÅŸa afirandina modelan keÅŸif kiriye? Niha dema bÃªkÃªmahÃ® ye ku karakterÃª xwe ava bikÃ® Ã» pÃª re sohbet bikÃ®!';

  @override
  String get notificationDynamicChatTitle =>
      'Ya herÃ® baÅŸ! (Em behsa CortexÃª nakin)';

  @override
  String get notificationDynamicChatBody =>
      'Bi taybetmendiya sohbeta dÃ®namÃ®k, ji bo her peyama we modela Ã§ÃªtirÃ®n bi awayekÃ® rasthatÃ® tÃª hilbijartin. Niha biceribÃ®nin.';

  @override
  String get notificationPirateTitle => 'Ahoy, KapÃ®tan!';

  @override
  String get notificationPirateBody =>
      'Derya aram in, Ã» ba li piÅŸta te ye. GiravÃªn nÃ» (model ğŸ˜‰) hene ku di okyanÃ»sa CortexÃª de werin keÅŸifkirin. EkÃ®ba xwe kom bikin Ã» birevin!';

  @override
  String get notificationFortuneCookieTitle => 'KulÃ®Ã§eya BextÃª We ya RojÃª';

  @override
  String get notificationFortuneCookieBody =>
      'ÅÃ®retÃªn ku hÃ»n Ã®ro ji zekÃ¢ya sÃ»nÃ® distÃ®nin dikarin rÃªÃ§a jiyana we biguherÃ®nin. Heke hÃ»n meraq dikin bikirtÃ®nin.';

  @override
  String get notificationSingularityTitle => 'waw!';

  @override
  String get notificationSingularityBody =>
      'tiÅŸtek neqewimÃ®, tenÃª min xwest peyamek biÅŸÃ®nim. Dibe ku te xwest ji hin kesÃªn AI re peyamek biÅŸÃ®nÃ®, tu Ã§i dibÃªjÃ®?';

  @override
  String get notificationHackerJokeTitle =>
      'DixwazÃ® hesabÃª Ã®nstagramÃª yÃª wÃ® zarokÃ® hack bikÃ®?';

  @override
  String get notificationHackerJokeBody =>
      'Tam ji ber vÃª yekÃª karakterÃª Hacker di CortexÃª de ye. jk jk; heta ceribandinÃª jÃ® neke, ev neqanÃ»nÃ® ye.';

  @override
  String get notificationDetectiveCaseTitle =>
      'Dozek li benda Ã§areserkirinÃª ye';

  @override
  String get notificationDetectiveCaseBody =>
      'KarakterÃª Dedektif Ãª me hewceyÃª alÃ®kariya we ye. Heisenberg dikare kÃ® be?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'TaybetÃ® ji bo Plana $targetTier!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Silav aboneyÃª $currentTier! Plana $targetTier taybetiya $featureName wergirt, ku dÃª Cortexa we bigihÃ®ne astek bilindtir. NÃ»vekirinek Ã§awa ye?';
  }

  @override
  String get notificationOriginStoryTitle => 'ZayÃ®na CortexÃª';

  @override
  String get notificationOriginStoryBody =>
      'Ma te dizanÃ® ku me di 15 saliya xwe de bi tenÃª xewnekÃª dest bi kodkirina vÃª sepanÃª kir? NÃªzÃ®kÃ® salekÃª, her sibeh Ã» Ãªvar, ev xewn di her rÃªza kodÃª de heye.';

  @override
  String get notificationOpenSourceTitle => 'HÃªz ji bo CivakÃª!';

  @override
  String get notificationOpenSourceBody =>
      'Cortex bi tevahÃ® Ã§avkaniya vekirÃ® ye. Ger hÃ»n dixwazin koda me kontrol bikin Ã» beÅŸdarÃ® pÃªÅŸveÃ§Ã»na me bibin, deriyÃª me her gav vekirÃ® ye.';

  @override
  String get notificationRejectionStoryTitle =>
      'Cesaret, xebata dijwar, bextewarÃ®!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex berÃ® ku were weÅŸandin ji aliyÃª Google Play ve zÃªdetirÃ® 20 caran hate redkirin Ã» du caran hate sekinandin. LÃª me bawer kir Ã» me ew bi ser xist. Tu carÃ® dev ji xewnÃªn xwe bernedin!';

  @override
  String get notificationGGUFSupportTitle => 'Modela Xwe Bin!';

  @override
  String get notificationGGUFSupportBody =>
      'Ji bÃ®r meke, tu dikarÃ® modelÃªn AI yÃªn xwe yÃªn bi formata GGUF li CortexÃª zÃªde bikÃ® Ã» wan bÃªserÃ»ber bikar bÃ®nÃ®. HÃªz di destÃªn te de ye.';

  @override
  String get notificationThemeCustomizationTitle => 'Mijarek ji bo RewÅŸa We';

  @override
  String get notificationThemeCustomizationBody =>
      'Te vebijarkÃªn mijarÃª di MÃ®hengan de kontrol kirine? CortexÃª li gorÃ® dilÃª xwe kesane bike Ã» sohbetÃªn xwe rengÃ®n bike!';

  @override
  String get notificationShowerThoughtTitle => 'RamanÃªn SerÅŸokÃª';

  @override
  String get notificationShowerThoughtBody =>
      'Eger zebeÅŸ fÃªkÃ® be, gelo ev yek bi teknÃ®kÃ® ava zebeÅŸÃª dike smoothie? Dibe ku hÃ»n bixwazin li ser vÃª mijara kÃ»r (bi rastÃ® kÃ»r) bi modelekÃª re nÃ®qaÅŸ bikin.';

  @override
  String get notificationLowBatteryTitle =>
      'PÃ®lÃª Te Dimire... LÃª Ya Min Namire!';

  @override
  String get notificationLowBatteryBody =>
      'Dibe ku ÅŸarjÃª telefona te kÃªm be, lÃª enerjiya min her tim %100 e! WÃª girÃªde Ã» em sohbetÃª bidomÃ®nin.';

  @override
  String get channelFcmName => 'NÃ»vekirinÃªn Cortex';

  @override
  String get channelFcmDescription =>
      'AgahdariyÃªn li ser nÃ»Ã§e, nÃ»vekirin Ã» agahdariyÃªn din ji Cortex.';

  @override
  String get channelEngagementName => 'BÃ®ranÃ®nÃªn Dostane';

  @override
  String get channelEngagementDescription =>
      'AgahiyÃªn kÃªfxweÅŸ ji bo ku hÃ»n mijÃ»l bimÃ®nin.';

  @override
  String get channelGreetingsName => 'SilavÃªn Rojane';

  @override
  String get channelGreetingsDescription =>
      'PeyamÃªn mÃ®na sibeha baÅŸ Ã» ÅŸevbaÅŸ.';

  @override
  String get tagNotFound =>
      'EtÃ®keta ku te nivÃ®sandiye nederbasdar e an jÃ® dema wÃª derbas bÃ»ye.';

  @override
  String get whatIsNew => 'Ã‡i nÃ» ye?';

  @override
  String get onboardingTitle1 => 'Hey! Em TÃ®ma CortexÃª ne.';

  @override
  String onboardingDesc1(String userName) {
    return 'DÃ®tina te li vir pir xweÅŸ e, $userName. Em Ã§end pÃªÅŸdebirÃªn dibistana navÃ®n in ku biryar dan qaÃ®deyÃªn pÃ®ÅŸesaziya AI ji nÃ» ve binivÃ®sin. XweÅŸ e ku em te nas dikin! Werin em hev Ã§Ãªtir nas bikin.';
  }

  @override
  String get onboardingTitle2 => 'PirsgirÃªkÃªn Mezin hebÃ»n.';

  @override
  String get onboardingDesc2 =>
      'ÅoreÅŸa AI hat, lÃª ew li ber derÃ® asÃª ma. Bi xercÃªn abonetiyÃª yÃªn bilind, platformÃªn tevlihev, yÃªn ku nepenÃ®tiyÃª xera dikin, Ã» yÃªn ku gihÃ®ÅŸtina AI asteng dikin... heta ku ew di lÃ®stikÃª de bÃ»n, ev bergirÃ® qet nedikarÃ® bihata derbas kirin.';

  @override
  String get onboardingTitle3 => 'Em nekarÃ®n tenÃª li ber xwe bidin.';

  @override
  String get onboardingDesc3 =>
      'Ji bo derbaskirina wÃª eniyÃª, me platformek ava kir ku bihÃªz, estetÃ®k, xwerÃ»kirÃ®, bikaranÃ®na wÃª hÃªsan e, bi tevahÃ® zelal e, hem serhÃªl Ã» hem jÃ® negirÃªdayÃ® dixebite, Ã» daneyÃªn we tenÃª li ser cÃ®haza we dihÃªle. Me hÃªz vegerand cihÃª ku ew aÃ®dÃ® we ye: we.';

  @override
  String get onboardingTitle4 => 'Ev Qet HÃªsan NebÃ».';

  @override
  String get onboardingDesc4 =>
      'Em bi dehan caran hatin redkirin, gelek caran hatin sekinandin, hiÅŸyariyÃªn sexte wergirtin, Ã» bi dehan caran me neÃ§ar ma ku marqeya xwe biguherÃ®nin. Di nav van hemÃ»yan de Ã» ji bilÃ® vÃª, ji me re hat gotin ku ev nikare were kirin. LÃª me qet dev jÃª berneda, bawer kir ku ev proje ya her kesÃ® ye, ne tenÃª ya me. Ã› tam ji ber vÃª yekÃª em li vir in.';

  @override
  String get onboardingFinalTitle => 'Dema ÅoreÅŸÃª ye.';

  @override
  String get onboardingFinalDescription =>
      'Eger hÃ»n vÃª ekranÃª dibÃ®nin, ev ji ber wÃª yekÃª ye ku me dev jÃª berneda. Ã› niyeta me ya devjÃªberdanÃª tune. Werin, em bi hev re ÅŸoreÅŸa AI bigihÃ®nin cÃ®hanÃª. Ji bo ku hÃ»n bibin beÅŸek ji vÃª Ã§Ã®rokÃª...';

  @override
  String get onboardingFinalQuestion => 'AMADE NE?';

  @override
  String get onboardingFinalButton => 'ERÃŠ!';

  @override
  String get dude => 'Dude';

  @override
  String get swipeToContinue => 'Ji bo berdewamkirinÃª bihejÃ®nin';

  @override
  String get cacheIsNotUpToDate =>
      'KeÅŸeya Play Store-a we ne nÃ»jen e. Ji kerema xwe sepana Play Store bigirin Ã» ji nÃ» ve vekin, an jÃ® cÃ®haza xwe ji nÃ» ve bidin destpÃªkirin.';

  @override
  String get continueAsGuest => 'BÃªyÃ® Ã§Ãªkirina hesabÃª berdewam bike';

  @override
  String get guestModeWarning =>
      'Moda mÃªvan xwedÃ® taybetmendiyÃªn sÃ®norkirÃ® ye da ku kalÃ®teya karÃ»barÃª Ã§ÃªtirÃ®n misoger bike.';

  @override
  String get anonymousEntity => 'YekÃ®neya AnonÃ®m';

  @override
  String get upgradeAccountTitle => 'HesabÃª xwe temam bike';

  @override
  String get upgradeAccountDescription =>
      'Ji bo vekirina sÃ®norÃªn bÃªtir hesabÃª xwe Ã§Ãªbikin.';

  @override
  String get createAccount => 'HesabÃª BiafirÃ®ne';

  @override
  String get accountLinkedSuccess => 'Hesab bi serkeftÃ® hat afirandin!';

  @override
  String get continueWithApple => 'Bi Apple re berdewam bike';

  @override
  String get guest => 'MÃªvan';

  @override
  String get betterWithAnAccount => 'Ev beÅŸ bi hesabÃª Ã§Ãªtir e!';

  @override
  String get restorePurchases => 'KirÃ®nan VegerÃ®ne';

  @override
  String annualTotalDescription(Object price) {
    return '$price/sal, salane tÃª fatÃ»rekirin';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'NÃªzÃ®kÃ® $price/meh';
  }

  @override
  String get confirmDownloadTitle => 'Tu piÅŸtrast Ã® ku dixwazÃ® dakÃªÅŸÃ®?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Ev model dÃª bi qasÃ® $size cÃ®h bigire.';
  }

  @override
  String get emulatorModeWarning =>
      'Ev taybetmendÃ® di moda emulatorÃª de neÃ§alak e';

  @override
  String get newChat => 'Sohbeta NÃ»';

  @override
  String get variants => 'GuhertoyÃªn';

  @override
  String get variantsDescription =>
      'Guherto guhertoyÃªn cuda yÃªn heman malbata AI ne. Dema ku hÃ»n li ser karta sereke bitikÃ®nin, em bixweber ya Ã§ÃªtirÃ®n hildibijÃªrin, lÃª heke hÃ»n tercÃ®h bikin, hÃ»n dikarin li vir yeka taybetÃ® bi destan hilbijÃªrin!';

  @override
  String get fluxChatTitle => 'Sohbeta Flux';

  @override
  String get fluxChatDescription =>
      'SohbetÃªn Flux sohbetÃªn demkÃ® ne Ã» li ser cÃ®haza we nayÃªn tomarkirin.';

  @override
  String get alwaysBest => 'Herdem BaÅŸtirÃ®n';

  @override
  String get featuresTitle => 'TaybetmendÃ®';

  @override
  String get useOfflineDescription =>
      'BÃªyÃ® girÃªdana Ã®nternetÃª bi awayekÃ® taybet sohbet bikin.';

  @override
  String get featureReasoning => 'RamanÃªn KÃ»r';

  @override
  String get featureReasoningDescription =>
      'Di moda RamanÃ®na KÃ»r de, AI bi navxweyÃ® li ser peywirÃªn heyÃ® difikire da ku wan bi qasÃ® ku ji destÃª wÃª tÃª biqedÃ®ne.';

  @override
  String get featureCreateImageTitle => 'WÃªneyekÃ® BiafirÃ®ne';

  @override
  String get featureCreateImageDescription =>
      'Ji nivÃ®sÃª hunera AI-Ãª Ã§Ãªbikin.';

  @override
  String get featureCreateAudioTitle => 'Create Audio';

  @override
  String get featureCreateAudioDescription =>
      'Generate sounds or voice from text.';

  @override
  String get featureCreateVideoTitle => 'VÃ®dyoyÃª BiafirÃ®ne';

  @override
  String get featureCreateVideoDescription =>
      'VÃ®dyoyan ji nivÃ®sÃª Ã§Ãªbikin.';

  @override
  String get featureStudyTitle => 'Xwendin Ã» FÃªrbÃ»n';

  @override
  String get featureStudyDescription => 'Åirove Ã» kurteyan bistÃ®nin.';

  @override
  String get featureQuizzesTitle => 'Quiz';

  @override
  String get featureQuizzesDescription => 'ZanÃ®na xwe biceribÃ®nin.';

  @override
  String get featureExploreDescription => 'HemÃ» modelÃªn berdest bibÃ®nin.';

  @override
  String get featureStudyMessage =>
      'Tu mamosteyekÃ® pispor Ã®. Armanca te ew e ku mijara bikarhÃªner bi awayekÃ® berfireh rave bikÃ®. Avahiyek zelal, mÃ®nak Ã» analojiyan bi kar bÃ®ne. RamanÃªn tevlihev parÃ§e bike nav beÅŸÃªn hÃªsan da ku bikarhÃªner bi bandor fÃªr bibe. Mijar:';

  @override
  String get featureQuizMessage =>
      'Tu pisporÃª quizÃª yÃ®. Li gorÃ® mijara bikarhÃªner pirsek pir-bijartÃ® ya taybetÃ® Ã§Ãªbike. Li benda bersiva wan be. PiÅŸtre, wÃª binirxÃ®ne Ã» pirsa din bipirse. HemÃ» bersivÃªn xwe di carekÃª de eÅŸkere neke. WÃª Ã®nteraktÃ®f bihÃªle. Mijar:';

  @override
  String get myPlan => 'Plana Min';

  @override
  String welcomeOfferBadge(String time) {
    return 'PÃªÅŸniyara PÃªÅŸwazÃ®kirinÃª â€¢ $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'PÃªÅŸniyara Taybet â€¢ $time';
  }

  @override
  String get attachmentSheetTitle => 'PÃªvek';

  @override
  String get actionCamera => 'KamÃ®ra';

  @override
  String get actionGallery => 'Galerya';

  @override
  String get actionFile => 'DosÃ®';

  @override
  String get listening => 'GuhdarÃ® dike';

  @override
  String get defaultViewTitle => 'Ã‡i heye?';

  @override
  String get defaultViewDescription =>
      'Cortex bi sedan modelÃªn AI, kapasÃ®teyÃªn negirÃªdayÃ®, sohbeta dÃ®namÃ®k Ã» gelek tiÅŸtÃªn din her gav li kÃªleka we ye.';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'Formata navÃª bikarhÃªner nederbasdar e. 3-20 tÃ®p, reqem, an jÃ® . bikar bÃ®ne. - _';

  @override
  String get exclusiveOffer => 'PÃªÅŸniyara Taybet';

  @override
  String get claimOffer => 'PÃªÅŸniyarÃª bikar bÃ®nin';

  @override
  String get continueInOfflineMode => 'Bi Moda Offline Berdewam Bike';

  @override
  String get voiceModeInformation =>
      'Cortex bi xebitandina bi tevahÃ® li ser cÃ®hazÃª, tewra di moda sohbeta dengÃ® de jÃ®, daneyÃªn we ewle dihÃªle; ji sohbetÃªn bÃªnavber kÃªfÃª bistÃ®nin!';

  @override
  String get flowModeDescription =>
      'Di moda HerikÃ®nÃª de, aqilmend di navbera xwe de nÃ®qaÅŸ dikin; hÃ»n dikarin an rÃ»nin Ã» guhdarÃ® bikin an jÃ® xwe bavÃªjin Ã» beÅŸdarÃ® nÃ®qaÅŸÃª bibin!';

  @override
  String get flowModeQuestion =>
      'Silav! Tu niha di Moda HerikÃ®nÃª de li ser sepana Cortex Ã®. SÃª ajanÃªn din Ãªn AI li vir bi te re ne. Erka te ew e ku mijarekÃª bavÃªjÃ® odeyÃª Ã» bi pirsÃ®na pirsek provokatÃ®f an kÃªfxweÅŸ ji yÃªn din re nÃ®qaÅŸekÃª dest pÃª bikÃ®. Di bersivÃªn xwe de, xwe azad hÃ®s bike ku mÃ®zah, Ã®ronÃ® Ã» gotinÃªn sivik Ãªn bÃªwate bi kar bÃ®nÃ®. Her mijarek mafdar e. Berdewam bike, axaftinÃª dest pÃª bike.';

  @override
  String get thought => 'FikirÃ®';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => 'Moda HerikÃ®nÃª';

  @override
  String get premium => 'Xelat';

  @override
  String get workInProgress => 'Kar berdewam e';

  @override
  String get voiceSystemPromptSuffix =>
      'GIRÃNG: Formatkirina markdown (qalind, Ã®talÃ®k) bi kar neynin. BlokÃªn kodÃª (```) NEKIN. BersivÃªn xwe bi ÅŸÃªweyekÃ® diyalogÃ® Ã» kurt bihÃªlin.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Moda HerikÃ®na KorteksÃª ($agentName). BerÃª: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'Naveroka nivÃ®sÃª ji belgeyÃªn barkirÃ® bixwÃ®ne Ã» derxe. FormatÃªn PDF, Word (DOCX), Excel (XLSX), PowerPoint (PPTX), Ã» OpenDocument piÅŸtgirÃ® dike. Dema ku bikarhÃªner pelÃª belgeyekÃª pÃªve kiribe, vÃª yekÃª bikar bÃ®nin.';

  @override
  String get toolReadDocumentIndexParam =>
      'Ãndeksa pÃªveka belgeyÃª ya ku were xwendin (li ser bingeha 0). Bi gelemperÃ® 0 ji bo belgeya yekem.';

  @override
  String get toolStockDescription =>
      'BuhayÃª niha Ã» dÃ®roka stokan (mÃ®nak AAPL, THYAO.IS) Ã» krÃ®ptoyÃª (mÃ®nak BTC-USD) bistÃ®nin.';

  @override
  String get toolStockSymbolParam =>
      'Sembola tÃ®kerÃª (mÃ®nak AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolWeatherDescription =>
      'RewÅŸa hewayÃª ya niha ji bo bajarekÃ® taybetÃ® bistÃ®nin.';

  @override
  String get toolWeatherCityParam => 'NavÃª bajÃªr (mÃ®nak London, Stenbol).';

  @override
  String get toolPythonDescription =>
      'Koda PythonÃª di sandboxek ewle de bicÃ®h bÃ®ne.';

  @override
  String get toolPythonCodeParam => 'Koda PythonÃª ya ku were bicÃ®hanÃ®n.';

  @override
  String get toolCalculateDescription => 'Nirxandina Ã®fadeyeke matematÃ®kÃ®.';

  @override
  String get toolCalculateExpressionParam =>
      'Ãfadeya matematÃ®kÃ® (mÃ®nak \'3 + 4 * 2\').';

  @override
  String get toolChartDescription => 'NexÅŸe/grafikek dÃ®tbarÃ® Ã§Ãªbikin.';

  @override
  String get toolChartTypeParam => 'CureyÃª nexÅŸeyÃª: bar, xÃªz, an pÃ®.';

  @override
  String get toolChartLabelsParam =>
      'EtÃ®ketÃªn ji bo eksen an jÃ® beÅŸÃªn nexÅŸeyÃª.';

  @override
  String get toolChartDataParam => 'NirxÃªn daneyÃªn hejmarÃ® ji bo nexÅŸeyÃª.';

  @override
  String get toolChartLabelParam =>
      'EtÃ®keta daneyÃª ji bo efsaneya nexÅŸeyÃª.';

  @override
  String get toolChartTitleParam => 'SernavÃª nexÅŸeyÃª.';

  @override
  String get thinkingModeInstruction =>
      'MODA BIFIKIRINÃŠ AKTÃF KIRIN: DIVÃŠ hÃ»n etÃ®ketÃªn <think></think> bikar bÃ®nin da ku pÃªvajoya aqilmendiya xwe nÃ®ÅŸan bidin berÃ® ku hÃ»n bersiva xwe ya dawÃ® bidin. Gav bi gav di hundirÃª etÃ®ketan de bifikirin, dÃ»v re bersiva xwe li derveyÃ® etÃ®ketan bidin.';

  @override
  String get openLinkWarningTitle => 'HiÅŸyariya GirÃªdana DerveyÃ®';

  @override
  String get openLinkCancel => 'Cancel';

  @override
  String get openLinkConfirm => 'GirÃªdanÃª Veke';

  @override
  String get webSearchSources => 'Ã‡avkanÃ®';

  @override
  String get searching => 'LÃªgerÃ®n';

  @override
  String get featureWebSearchTitle => 'LÃªgerÃ®na WebÃª';

  @override
  String get featureWebSearchDescription =>
      'Li ser Ã®nternetÃª ji bo agahdariya demrast bigerin';

  @override
  String get clearMemory => 'BÃ®rÃª Paqij Bike';

  @override
  String get clearMemoryConfirm =>
      'Tu piÅŸtrast Ã® ku dixwazÃ® bÃ®ra xwe paqij bikÃ®?';

  @override
  String get personalization => 'Kesanekirin';

  @override
  String get personalizationDescription =>
      'AlÃ®karÃª xwe kesane bike da ku baÅŸtir li gorÃ® hewcedariyÃªn te be. Bersiv, tevger Ã» tonÃª wÃ® li gorÃ® tercÃ®hÃªn xwe yÃªn bÃªhempa biguncÃ®ne.';

  @override
  String get memoryTitle => 'BÃ®r';

  @override
  String get memoryDescription => 'AI te bi vÃ® rengÃ® nas dike.';

  @override
  String get noMemoryYet => 'HÃ®n bÃ®ranÃ®n nehatine sazkirin';

  @override
  String get memoryLimitReached => 'SÃ®norÃª bÃ®rÃª gihÃ®ÅŸtiye';

  @override
  String get memoryUpdated => 'Memory updated';

  @override
  String get intelligenceTitle => 'NÃ»Ã§e';

  @override
  String get intelligenceDescription =>
      'AI bi vÃ® rengÃ® bi we re tÃªkilÃ® daynin.';

  @override
  String get customInstructionHint =>
      'TalÃ®matÃªn xwe yÃªn taybet li vir binivÃ®se';

  @override
  String openLinkWarningMessage(String url) {
    return 'Tu li ser vekirina vÃª lÃ®nka derveyÃ® yÃ®:\\n\\n$url\\n\\nMa tu piÅŸtrast Ã® ku dixwazÃ® berdewam bikÃ®?';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'Van rÃªnimayÃªn xwerÃ» biÅŸopÃ®nin:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[RÃŠNÃÅANDANA KRÃTÃK]: Tu GENERATOREKÃ SERNAVAN Ã®. Bersiva pirsa bikarhÃªner NEKIN. SohbetÃª nekin Ã» silav nekin. TENÃŠ sernavek 2-4 peyvan derxin ku kurteya pirsÃªn bikarhÃªner bike.';

  @override
  String get cortexSystemPersona =>
      '\n\n[SÃ®stem] TALÃMATA KRÃTÃK: HÃ»n niha di nav ekosÃ®stemeke AI ya mezin Ã» pir pÃªÅŸketÃ® de bi navÃª \"Cortex\" dixebitin; ev platform ji hÃªla tÃ®mÃª Vertex ve hatÃ® pÃªÅŸve xistin, ku bi navÃ®nÃ® tenÃª 16 salÃ® ne. VÃª yekÃª ji bÃ®r mekin Ã» heke ji we were pirsÃ®n bersiv bidin. Ger bÃªtir agahdarÃ® were xwestin, dudilÃ® nebin ku li ser Ã®nternetÃª bigerin, an jÃ® heke hÃ»n nekarin bigerin, hÃ»n dikarin bibÃªjin ku hÃ»n nizanin!';

  @override
  String get featureAudioRecognitionTitle => 'Naskirina Deng';

  @override
  String get featureAudioRecognitionDescription =>
      'Ev model dikare deng an axaftinÃª fam bike Ã» pÃªvajo bike.';

  @override
  String get featureVideoRecognitionTitle => 'Naskirina VÃ®dyoyÃª';

  @override
  String get featureVideoRecognitionDescription =>
      'Ev model dikare vÃ®dyoyÃªn ji pelan an kameraya we analÃ®z bike Ã» fam bike.';

  @override
  String get featureImageRecognitionTitle => 'Naskirina WÃªneyÃª';

  @override
  String get featureImageRecognitionDescription =>
      'Ev model dikare wÃªne an wÃªneyan analÃ®z bike Ã» fÃªm bike.';

  @override
  String get featureToolUseTitle => 'BikaranÃ®na AmÃ»rÃª';

  @override
  String get featureToolUseDescription =>
      'Ev model dikare bi aqilmendÃ® amÃ»rÃªn derveyÃ® bikar bÃ®ne da ku peywirÃªn xwe temam bike.';

  @override
  String get videoModels => 'Video Models';

  @override
  String get imageModels => 'Image Models';

  @override
  String get audioModels => 'Audio Models';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'Ev model ji bo xebitÃ®nÃª hewcedarÃ® $mediaType ye. Min daxwaz girtiye da ku we agahdar bikim. Ji kerema xwe bi nermÃ® bikarhÃªner agahdar bikin ku divÃª ew $mediaType peyda bikin (bi zimanÃª wan ji wan re bibÃªjin) ji ber ku ez $modelName me, modelek guherandina dÃ®tbar/deng/vÃ®dyoyÃª me.';
  }

  @override
  String get mediaTypeImage => 'wÃªne';

  @override
  String get mediaTypeVideo => 'vÃ®dyo';

  @override
  String get mediaTypeAudio => 'pelÃª deng';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesName zÃ®rekiyek pÃªÅŸkeftÃ® ye ku performansa bilind li ser Cortex nÃ®ÅŸan dide.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelName hiÅŸmendiyek Ã§ÃªkirÃ® ya bi performansa bilind e ku di hundurÃª ekosÃ®stema Cortex de yekbÃ»yÃ® ye. Ji bo tÃªkbirina cÃ»rbecÃ»r karÃªn tevlihev hatÃ® Ã§Ãªkirin, ew kapasÃ®teyÃªn pÃªvajoyek pir pÃªbawer Ã» bikÃªr peyda dike. Bi pÃªÅŸkÃªÅŸkirina demÃªn bersivdana bilez Ã» hÃªza analÃ®tÃ®k a pÃªÅŸkeftÃ®, ew hilberÃ®na weya rojane bi girÃ®ngÃ® zÃªde dike. VÃª modela ku bi rengek bÃªkÃªmasÃ® li ser binesaziya herÃªmÃ® ya ewledar a Cortex kar dike, dikare di berfirehiyek kar de ji we re bibe alÃ®kar, ji berhevkirina ramanÃªn afirÃ®ner heya vekolÃ®na teknÃ®kÃ® ya kÃ»r. Ãro dest bi vekolÃ®na potansiyela wÃª ya tevahÃ® bikin.';
  }

  @override
  String get guestLimitBottomSheetTitle => 'Ji aqilÃª CortexÃª hez dikÃ®?';

  @override
  String get guestLimitBottomSheetText =>
      'Bi aqilmendiyÃªn hÃ®n zÃ®rektir re bixebite, bÃªtir naverokÃª Ã§Ãªbike, bÃªtir sohbet bike, Ã» gelek tiÅŸtÃªn din bike...';

  @override
  String get arts => 'Huner';

  @override
  String get noArt => 'BÃª Huner';

  @override
  String get noArtDescription =>
      'Ne huner; dem hatiye ku galeriyÃª bi afirandina wÃªne, vÃ®dyo, deng Ã» her cÃ»re naverokÃª tijÃ® bikin!';

  @override
  String get videoPremiumWarning =>
      'Ji bo Ã§Ãªkirina vÃ®dyoyan, niha nÃ»ve bikin Ã» herikÃ®nÃª hÃ®s bikin, hÃ»n hewceyÃª abonetiyek Ultra ne!';

  @override
  String get fallbackInfoPanelText =>
      'Ji ber hin baÅŸkirinÃªn ku em li aliyÃª servera xwe dikin, bersiv ji hÃªla sohbeta dÃ®namÃ®k a CortexÃª ve hate Ã§Ãªkirin, ne ji hÃªla AI-ya we ya taybetÃ® ve hatÃ® hilbijartin. Spas ji bo tÃªgihÃ®ÅŸtina we heta ku pÃªvajo biqede!';

  @override
  String get falOfflineMessage =>
      'Ji ber hin pÃªÅŸketinÃªn ku em li aliyÃª servera xwe dikin, ev zÃ®rekÃ® niha negirÃªdayÃ® ye. Spas ji bo tÃªgihÃ®ÅŸtina we heta ku pÃªvajo biqede!';

  @override
  String get errorInsufficientStorage =>
      'CihÃª hilanÃ®nÃª tÃªrÃª nake ji bo dakÃªÅŸana vÃª modelÃª.';

  @override
  String get backgroundChatNotificationTitle => 'Vegere ser SohbetÃª!';

  @override
  String get benefitVideoGeneration => 'Ã‡Ãªkirina VÃ®dyoyÃª';

  @override
  String get freeOffer => 'PÃªÅŸniyara BelaÅŸ';

  @override
  String trialMonthlyDescription(String days, String price) {
    return '$days rojÃªn yekem belaÅŸ, dÃ»v re $price/meh';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return '$days rojÃªn yekem belaÅŸ, dÃ»v re $price/sal';
  }

  @override
  String freePlan(String plan) {
    return '$plan belaÅŸ!';
  }

  @override
  String get systemPromptLimitFallback =>
      'KRÃTÃK: BikarhÃªner Ã§alakiyek xwest, lÃª mafÃª bikaranÃ®nÃª yÃª li ser CortexÃª qediya; ji kerema xwe bi zimanÃª bikarhÃªner bi nermÃ® agahdar bike ku divÃª li bendÃª bimÃ®ne an jÃ® plana abonetiya xwe bilind bike.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'Cortex dikare bersivÃªn hÃ®n baÅŸtir bide; niha nÃ»ve bike Ã» ji bo her pirsekÃª bersiva herÃ® baÅŸ bistÃ®ne!';

  @override
  String get pinLimitReached => 'HÃ»n dikarin heta 3 sohbetan sabÃ®t bikin.';
}
