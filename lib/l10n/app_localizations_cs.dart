// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'Jste generátor titulků. Odpovězte POUZE 2-5 slovním názvem pro následující konverzaci. Nepoužívejte uvozovky, předpony ani interpunkci. KRITICKÉ: Název MUSÍ být ve PŘESNĚ STEJNÉM jazyce jako zpráva uživatele.';

  @override
  String get systemRoleFallback => 'Jste užitečný pomocník.';

  @override
  String get systemLanguageInstruction =>
      'KRITICKÉ: Vždy odpovídejte ve stejném jazyce, ve kterém uživatel píše, věnujte pozornost jazyku uživatele.';

  @override
  String get systemNotePreviousMedia =>
      '[Poznámka k systému: Níže jsou média vygenerovaná dříve. Můžete na něj odkazovat nebo jej upravovat.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return 'Aktuální datum a čas: $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '[SMĚRNICE O SYSTÉMOVÉ PAMĚTI]\nAnalyzujte dosavadní rozhovor. Pokud jste se dozvěděli JAKÉKOLI nová odlišná fakta o uživateli (preference, jméno, zvyky, kontext), MUSÍTE vypsat CELOU aktualizovanou paměť o uživateli uvnitř tagů <memory>...</memory> NA ÚPLNÉM KONCI vaší odpovědi. KRITICKÉ: NIKDY nesmíte vymazat nebo přepsat předchozí paměť. VŽDY přidejte nová fakta do stávající paměti. Pokud jste se nenaučili absolutně nic nového, značku vynechejte. Příklad: <memory>Miluje fotbal a tenis. Preferuje krátké odpovědi.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return 'Vždy si pamatujte toto o uživateli:\n$userMemory';
  }

  @override
  String get cancel => 'Zrušit';

  @override
  String get remove => 'Odebrat';

  @override
  String get download => 'Stáhnout';

  @override
  String get resume => 'Pokračovat';

  @override
  String get copy => 'Kopírovat';

  @override
  String get chat => 'Chat';

  @override
  String get branch => 'Větev';

  @override
  String get locked => 'Zamčeno';

  @override
  String get languageModels => 'Jazykové modely';

  @override
  String get light => 'Světlo';

  @override
  String get theme => 'Téma';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get no => 'Ne';

  @override
  String get yes => 'Ano';

  @override
  String get done => 'Hotovo';

  @override
  String get bestValue => 'Nejlepší hodnota';

  @override
  String get selected => 'Vybráno';

  @override
  String get descriptionSection => 'Popis';

  @override
  String get searchHint => 'Hledat';

  @override
  String get messageHint => 'Zeptejte se na cokoli';

  @override
  String get messageCopied => 'Zpráva zkopírována do schránky.';

  @override
  String get retry => 'Opakovat';

  @override
  String get systemInfo => 'Systémové informace';

  @override
  String deviceMemory(Object memory) {
    return 'Paměť zařízení: $memory GB';
  }

  @override
  String get memory => 'Paměť';

  @override
  String get storage => 'Skladování';

  @override
  String get freeStorage => 'Úložiště zdarma';

  @override
  String get totalStorage => 'Úložiště celkem';

  @override
  String get usedStorage => 'Použité úložiště';

  @override
  String get totalMemory => 'Celková paměť';

  @override
  String get usedMemory => 'Použitá paměť';

  @override
  String get modelsTitle => 'Knihovna';

  @override
  String get localModels => 'Místní modely';

  @override
  String get selectGGUFFile => 'Vyberte soubor GGUF';

  @override
  String get errorGGUF => 'Vyberte prosím soubor pouze ve formátu GGUF.';

  @override
  String get myModels => 'Moje modely';

  @override
  String get create => 'Vytvořit';

  @override
  String modelProducer(Object producer) {
    return 'Výrobce: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'Přejmenovat';

  @override
  String get newTitle => 'Nový název';

  @override
  String get save => 'Uložit';

  @override
  String get noConversationsMessage => 'Žádné konverzace, začněte chatovat!';

  @override
  String get startChat => 'Zahájit chat';

  @override
  String get noChats => 'Žádné chaty';

  @override
  String get noStarredChats => 'Žádné chaty s hvězdičkou';

  @override
  String get noStarredChatsMessage => 'Zatím jste chat neoznačili hvězdičkou.';

  @override
  String get starConversation => 'Hvězda';

  @override
  String get unstarConversation => 'Odebrat hvězdičku';

  @override
  String get renameConversation => 'Rename Conversation';

  @override
  String get conversationName => 'Conversation name';

  @override
  String get deleteConversation => 'Delete Conversation';

  @override
  String get deleteConversationConfirm =>
      'Are you sure you want to delete this conversation? This action cannot be undone.';

  @override
  String get archive => 'Archive';

  @override
  String get multiSelect => 'Select Multiple';

  @override
  String get loginToYourAccount => 'Přihlásit';

  @override
  String get createYourAccount => 'Registrovat';

  @override
  String get email => 'Email';

  @override
  String get password => 'Heslo';

  @override
  String get confirmPassword => 'Potvrdit heslo';

  @override
  String get invalidEmail => 'Zadejte prosím platnou e-mailovou adresu.';

  @override
  String get invalidPassword => 'Heslo musí mít alespoň 6 znaků.';

  @override
  String get rememberMe => 'Zapamatovat si mě';

  @override
  String get forgotPassword => 'Zapomněli jste heslo?';

  @override
  String get or => 'Nebo';

  @override
  String get continueWithGoogle => 'Pokračovat s Google';

  @override
  String get dontHaveAccount => 'Nemáte účet?';

  @override
  String get alreadyHaveAccount => 'Už máte účet?';

  @override
  String get signUp => 'Zaregistrujte se';

  @override
  String get logIn => 'Přihlásit se';

  @override
  String get passwordsDoNotMatch => 'Hesla se neshodují.';

  @override
  String get wrongPassword => 'Nesprávné heslo.';

  @override
  String get emailAlreadyInUse => 'Tento e-mail se již používá.';

  @override
  String get weakPassword => 'Heslo je příliš slabé.';

  @override
  String get authError => 'Chyba ověření';

  @override
  String get usernameTaken => 'Toto uživatelské jméno je již obsazeno.';

  @override
  String get username => 'Uživatelské jméno';

  @override
  String get resendCode => 'Znovu odeslat ověřovací e-mail';

  @override
  String get pleaseCheckYourEmail =>
      'Chcete-li používat Cortex, musíte ověřit svůj e-mail. \nNa vaši e-mailovou adresu byl odeslán ověřovací odkaz, zkontrolujte svůj e-mail.';

  @override
  String get verifyYourEmail => 'Ověřte svůj email';

  @override
  String get seconds => 'sekund';

  @override
  String get maxResendLimitReached =>
      'Dosáhli jste maximálního počtu ověřovacích e-mailů';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Pokračovat bez ověření';

  @override
  String get verificationScreenWarning =>
      'I když budete pokračovat, pro váš účet stále platí jednodenní období pro ověření účtu. Pokud do té doby svůj účet neověříte, bude z aplikace smazán.';

  @override
  String get unverifiedAccountHeader => 'Váš účet není ověřen';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Pokud svůj účet neověříte do $timeLeft, bude smazán';
  }

  @override
  String get verifyNow => 'Ověřit nyní';

  @override
  String get linkSent => 'Odkaz odeslán';

  @override
  String get accountDeletionRequested =>
      'Váš požadavek na smazání účtu byl přijat a váš účet je nyní deaktivován.';

  @override
  String get tooManyRequests => 'Příliš mnoho požadavků';

  @override
  String get regenerate => 'Regenerovat';

  @override
  String get confirmDeleteAccount => 'Opravdu chcete smazat svůj účet?';

  @override
  String get deleteAccount => 'Smazat účet';

  @override
  String get delete => 'Smazat';

  @override
  String get passwordRequired => 'Je vyžadováno heslo.';

  @override
  String get deleteDescription =>
      'Data, která smažete, budou trvale odstraněna z našeho serveru a vašeho zařízení. Tyto akce nelze vrátit zpět.';

  @override
  String get editProfile => 'Upravit profil';

  @override
  String get displayName => 'Zobrazovaný název';

  @override
  String get profileUpdated => 'Profil byl úspěšně aktualizován';

  @override
  String get logout => 'Odhlášení';

  @override
  String get profile => 'Profil';

  @override
  String get manageProfileDescription =>
      'Spravujte svůj profil, aktualizujte heslo nebo se odhlaste z Cortexu.';

  @override
  String get accessSettingsDescription =>
      'Získejte přístup k nápovědě, uplatněte kódy, sdílejte Cortex a prohlédněte si naše zásady.';

  @override
  String get languageDescription =>
      'Výchozí jazyk rozhraní aplikace můžete kdykoli změnit.';

  @override
  String get themeDescription =>
      'Podle potřeby můžete přepínat mezi světlými a tmavými motivy. Vybrané téma se použije v rozhraní Cortex.';

  @override
  String get iHaveReadAndAgree =>
      'Přečetl jsem a souhlasím s podmínkami služby';

  @override
  String get downloading => 'Stahování...';

  @override
  String get downloadSuccess => 'Úspěch stahování';

  @override
  String get downloadFailed => 'Stahování se nezdařilo';

  @override
  String downloaded(Object percent) {
    return '$percent% staženo';
  }

  @override
  String get downloadPaused => 'Stahování pozastaveno.';

  @override
  String get purchaseError => 'Chyba při nákupu';

  @override
  String get purchasePlus => 'Koupit Cortex Plus';

  @override
  String get plusDescription => 'Elitní zkušenost s umělou inteligencí';

  @override
  String get annual => 'Roční';

  @override
  String get monthly => 'Měsíčně';

  @override
  String get manageSubscription => 'Spravovat předplatné';

  @override
  String purchasePlan(String planName) {
    return 'Koupit $planName';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/měsíc, účtováno měsíčně';
  }

  @override
  String get purchasePro => 'Koupit Cortex Pro';

  @override
  String get proDescription => 'Prvotřídní zkušenost s umělou inteligencí';

  @override
  String get purchaseUltra => 'Koupit Cortex Ultra';

  @override
  String get ultraDescription => 'Vrchol umělé inteligence';

  @override
  String get upgradeSubscription => 'Upgrade předplatného';

  @override
  String get purchaseStreamError => 'Chyba streamu nákupu.';

  @override
  String get productNotFound => 'Produkt nenalezen';

  @override
  String get noProductsFound => 'Nebyly nalezeny žádné produkty';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Odesláním této objednávky souhlasíte s Podmínkami služby a Zásadami ochrany osobních údajů. Kliknutím na tento text se dozvíte více o našich smluvních podmínkách a zásadách ochrany osobních údajů. Předplatné se automaticky obnoví, pokud není automatické obnovení vypnuto alespoň 24 hodin před koncem aktuálního období.';

  @override
  String get termsOfService => 'Podmínky služby';

  @override
  String get privacyPolicy => 'Zásady ochrany osobních údajů';

  @override
  String get renamed => 'Přejmenováno';

  @override
  String get report => 'Zpráva';

  @override
  String get reportDialogTitle => 'Odeslat zprávu';

  @override
  String get reportDescriptionLabel => 'o co jde?';

  @override
  String get reportHarmful => 'Toto je škodlivé/nebezpečné';

  @override
  String get reportNotTrue => 'To není pravda';

  @override
  String get reportNotHelpful => 'To není užitečné';

  @override
  String get closeButton => 'Zavřít';

  @override
  String get submitButton => 'Odeslat';

  @override
  String get reportErrorMessage => 'Vyberte prosím jeden důvod pro nahlášení.';

  @override
  String get capabilitiesSection => 'Schopnosti';

  @override
  String get featurePhotoTitle => 'Skenování fotografií';

  @override
  String get featurePhotoDescription =>
      'Tento model má schopnost skenovat fotografie prostřednictvím fotoaparátu nebo obrazových souborů.';

  @override
  String get featureOfflineTitle => 'Offline operace';

  @override
  String get featureOfflineDescription =>
      'Spusťte model bez připojení k internetu, aby byla vaše data v bezpečí.';

  @override
  String get featureRoleplayTitle => 'Hraní rolí';

  @override
  String get featureRoleplayDescription =>
      'Modely pro hraní rolí vám umožňují vytvářet různé chaty a scénáře.';

  @override
  String get roleModels => 'Modelky na hraní rolí';

  @override
  String get parameters => 'Parametry';

  @override
  String get context => 'Kontext';

  @override
  String get finalPreparation => 'Probíhají poslední přípravy.';

  @override
  String get shareApp => 'Sdílejte aplikaci';

  @override
  String get ourStory => 'Náš příběh';

  @override
  String get rateUs => 'Ohodnoťte nás';

  @override
  String get share => 'Sdílet';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'Vyberte text';

  @override
  String get thinking => 'Myšlení';

  @override
  String get user => 'Uživatel';

  @override
  String get help => 'Nápověda';

  @override
  String get supportCreator => 'Podpořte tvůrce';

  @override
  String get enterYourTag =>
      'Podpořte své oblíbené tvůrce! Níže zadejte jejich jedinečný štítek a dejte jim podíl z vašich nákupů Cortex.';

  @override
  String get creatorTag => 'Značka autora';

  @override
  String get support => 'Podpora';

  @override
  String get tagCannotBeEmpty => 'Značka tvůrce nemůže být prázdná';

  @override
  String get userId => 'ID uživatele';

  @override
  String get deleteAllConversationsConfirmTitle => 'Smazat všechny chaty?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Opravdu chcete smazat všechny své chaty? Toto nelze vrátit zpět.';

  @override
  String get conversationDeleted => 'Konverzace smazána!';

  @override
  String get allConversationsDeleted =>
      'Všechny konverzace byly úspěšně smazány!';

  @override
  String get deleteAll => 'Smazat vše';

  @override
  String get deleteAllConversationsButton => 'Smazat všechny konverzace';

  @override
  String get confirmWord => 'Typ VERTEX';

  @override
  String get confirmWordError => 'Zadali jste to špatně';

  @override
  String get chinese => 'čínština';

  @override
  String get french => 'francouzsky';

  @override
  String get japanese => 'japonština';

  @override
  String get dutch => 'holandský';

  @override
  String get russian => 'rusky';

  @override
  String get korean => 'korejština';

  @override
  String get english => 'angličtina';

  @override
  String get turkish => 'turečtina';

  @override
  String get hindi => 'hindština';

  @override
  String get portuguese => 'portugalština';

  @override
  String get indonesian => 'indonéština';

  @override
  String get azerbaijani => 'Ázerbájdžánština';

  @override
  String get german => 'německy';

  @override
  String get spanish => 'Španělština';

  @override
  String get italian => 'italsky';

  @override
  String get arabic => 'Arabština';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'Uživatelské jméno je příliš krátké.';

  @override
  String get usernameTooLong => 'Uživatelské jméno nesmí přesáhnout 16 znaků.';

  @override
  String get invalidUsernameCharacters =>
      'V uživatelském jménu lze použít pouze tato písmena: \'abcÃ§defgÄŸhÄ±ijklmnoÃ¶prsÅŸtuÃ¼vyzxqw\' a znaky \'.\', \'-\', \'_\'.';

  @override
  String get noInternetConnection => 'Žádné připojení k internetu.';

  @override
  String get chats => 'Poslední';

  @override
  String get library => 'Knihovna';

  @override
  String get text => 'Text';

  @override
  String get removeModel => 'Odebrat model';

  @override
  String get insufficientRAM => 'Málo paměti';

  @override
  String get insufficientStorage => 'Nízká skladovací kapacita';

  @override
  String confirmRemoveModel(Object model) {
    return 'Opravdu chcete odebrat model $model ze svého zařízení? Pokud tak učiníte, odstraní se také všechny předchozí konverzace s daným modelem.';
  }

  @override
  String get noMatchingModels => 'Nebyly nalezeny žádné odpovídající modely.';

  @override
  String get benefit1 => 'Zvýšené limity konverzace';

  @override
  String get benefit3 => 'Profilový efekt';

  @override
  String get benefit4 => 'Členský odznak';

  @override
  String get benefit5 => 'Vytvořte další online umělou inteligenci';

  @override
  String get benefit7 => 'Další limity použití';

  @override
  String get benefit8 => 'Přidat modely';

  @override
  String get benefit9 => 'Nová témata';

  @override
  String get benefit10 => 'Další přílohy';

  @override
  String get benefit11 => 'Další režim průtoku';

  @override
  String get oldBenefits => 'Všechny výhody nižších plánů';

  @override
  String get confirm => 'Potvrdit';

  @override
  String get changePassword => 'Změnit heslo';

  @override
  String get logoutConfirmationTitle => 'Opravdu se chcete odhlásit?';

  @override
  String get settings => 'Nastavení';

  @override
  String get language => 'Jazyk aplikace';

  @override
  String get dark => 'Tmavý';

  @override
  String get oldPassword => 'Staré heslo';

  @override
  String get newPassword => 'Nové heslo';

  @override
  String get passwordUpdated => 'Heslo aktualizováno.';

  @override
  String get stop => 'Stop';

  @override
  String get copyrights => 'Atribuce';

  @override
  String get love => 'Láska';

  @override
  String get nature => 'Příroda';

  @override
  String get behindTheSlaughter => 'Behind the Slaughter';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Západ slunce';

  @override
  String get coffee => 'Káva';

  @override
  String get deepSpace => 'Hluboký vesmír';

  @override
  String get grayscale => 'Stupně šedi';

  @override
  String get ocean => 'Oceán';

  @override
  String get scarletSnow => 'Scarlet Snow';

  @override
  String get requestFailed => 'Došlo k chybě, zkuste to prosím znovu.';

  @override
  String get changeModel => 'Změnit';

  @override
  String get edit => 'Upravit';

  @override
  String get editingMessageInfo =>
      'Úprava této zprávy restartuje konverzaci odsud.';

  @override
  String get editingNotification => 'Nyní jste v režimu úprav';

  @override
  String get featurePluralTitle => 'Množné číslo';

  @override
  String get featurePluralDescription =>
      'Tento model může automaticky integrovat další varianty, čímž rozšíří své funkční schopnosti pro podporu rozmanitých operací se zvýšeným výkonem.';

  @override
  String get nameLabel => 'Jméno AI';

  @override
  String get summaryLabel => 'Shrnutí AI';

  @override
  String get add => 'Přidat';

  @override
  String get aiExplanationTitle => 'Popis umělé inteligence';

  @override
  String get aiExplanationDescription =>
      'Uveďte prosím podrobný popis architektury vašeho modelu AI, tréninkového procesu, výkonnostních metrik, aplikačních oblastí a dalších důležitých funkcí.';

  @override
  String get preInputTitle => 'Předběžný vstup umělé inteligence';

  @override
  String get preInputDescription =>
      'Nastavte prosím předběžný vstup, který povede váš model v procesu tvorby postavy. V této části můžete zahrnout informace týkající se postavy, další kontext a jakékoli další podrobnosti, které mohou pomoci při generování obsahu souvisejícího s postavou.';

  @override
  String get baseModelTitle => 'Základní model';

  @override
  String get baseModelDescription =>
      'Toto je model, který bude použit jako základ pro vaši tvorbu. Zobrazuje aktuálně vybraný základní model.';

  @override
  String get summary => 'Shrnutí';

  @override
  String get modelUploadTitle => 'Soubor umělé inteligence';

  @override
  String get modelUploadDescription =>
      'Vyberte a nahrajte své místní soubory GGUF přímo ze zařízení. To vám umožní spustit váš model offline, aniž byste potřebovali připojení k internetu. Ujistěte se, že soubor je v platném formátu GGUF a má správnou strukturu. Pokud je soubor nesprávný nebo poškozený, Cortex nemusí fungovat podle očekávání a můžete narazit na chyby.';

  @override
  String get modelUploadShortDescription =>
      'Klepnutím sem vyberete soubor .gguf ze svého zařízení';

  @override
  String get you => 'Vy';

  @override
  String get removePhotoTitle => 'Odebrat fotku';

  @override
  String get confirmRemovePhoto => 'Opravdu chcete fotku odstranit?';

  @override
  String get chatLengthLimitExceeded =>
      'Tento chat překročil povolený počet znaků. Začněte prosím nový chat nebo si zakupte předplatné.';

  @override
  String get inappropriateContentDetected => 'Byl zjištěn nevhodný obsah!';

  @override
  String get offlineModelNotInstalled =>
      'Tento offline model není ve vašem zařízení nainstalován.';

  @override
  String get reachedLimit =>
      'Dosáhli jste limitu využití; Chcete-li získat více limitů, můžete upgradovat svůj plán. (Hej, úplně nám to překračuje limity je průšvih. ale vážně, získávání těch úžasných odpovědí není zadarmo, takže nám tyto limity ve skutečnosti pomáhají udržet dobré časy.)';

  @override
  String get modality => 'Modalita';

  @override
  String get multimodal => 'Multimodální';

  @override
  String get anErrorOccurred => 'Došlo k chybě';

  @override
  String get themeLocked =>
      'Toto téma vyžaduje vyšší úroveň předplatného. Chcete-li odemknout, upgradujte.';

  @override
  String get pageCouldNotBeLoaded => 'Stránku nelze načíst';

  @override
  String get checkYourInternet =>
      'Zkontrolujte prosím připojení k internetu a zkuste to znovu.';

  @override
  String get errorUserNotAuthenticated =>
      'K provedení této akce musíte být přihlášeni.';

  @override
  String get errorReachedLimit =>
      'Dosáhli jste svého limitu, upgradujte, abyste odemkli další a pokračujte v chatování.';

  @override
  String get errorServer =>
      'Došlo k neočekávané chybě serveru. Zkuste to znovu později.';

  @override
  String get errorNetwork =>
      'Došlo k chybě sítě. Zkontrolujte připojení a zkuste to znovu.';

  @override
  String get baseModelForCharacterDescription =>
      'Vybraný základní model určí vlastnosti uvažování a odezvy postavy.';

  @override
  String get selectBaseModel => 'Vyberte základní model';

  @override
  String get falErrorImageRequired =>
      'Tato umělá inteligence vyžaduje referenční obrázek, připojte jej a zkuste to znovu.';

  @override
  String get falErrorAudioRequired =>
      'Tento model vyžaduje referenční zvukový soubor, připojte zvukový soubor a zkuste to znovu.';

  @override
  String get falErrorVideoRequired =>
      'Tento model vyžaduje referenční video, připojte video a zkuste to znovu.';

  @override
  String get falErrorImageCorrupted =>
      'Nahraný obrázek nelze zpracovat, zkuste prosím jiný formát.';

  @override
  String get falErrorSchemaRejected =>
      'Model odmítl zadání, zkuste prosím jiný model.';

  @override
  String get falErrorSchemaInvalid =>
      'Zadání bylo odmítnuto generační službou.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'Generovací služba vrátila chybu (stav $statusCode).';
  }

  @override
  String get couldNotOpenLink => 'Nelze otevřít odkaz';

  @override
  String get downloadStarted => 'Stahování zahájeno';

  @override
  String get notAvailable => 'Není k dispozici';

  @override
  String get localizationWarning =>
      'Některé informace nemusí být dostupné ve vašem jazyce a budou zobrazeny v angličtině.';

  @override
  String get aiTranslationWarning =>
      'Informace o modelu jsou překládány do různých jazyků jinými modely umělé inteligence. V jiných jazycích než v angličtině se proto mohou vyskytnout drobné nesrovnalosti.';

  @override
  String get errorLoadingTitle => 'Nepodařilo se načíst data';

  @override
  String get errorLoadingMessage =>
      'Nepodařilo se nám načíst potřebná data z našich serverů. Zkontrolujte prosím připojení k internetu a zkuste to znovu.';

  @override
  String get noFoundTitle => 'Žádné výsledky';

  @override
  String get noFoundMessage =>
      'Zkuste upravit hledané výrazy nebo vymazat filtr.';

  @override
  String get modelCreatedSuccess => 'Model úspěšně vytvořen!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return 'â€œ$modelNameâ€ bylo úspěšně odstraněno.';
  }

  @override
  String get errorCreatingModel =>
      'Při vytváření modelu došlo k neočekávané chybě.';

  @override
  String get errorDeletingModel =>
      'Při odstraňování modelu došlo k neočekávané chybě.';

  @override
  String get ultraFeatureOnly =>
      'Tato funkce je dostupná pouze pro členy Ultra.';

  @override
  String get experimentalOfflineWarning =>
      'Offline režim je stále experimentální a model, který si stáhnete, nemusí fungovat s optimální účinností.';

  @override
  String get noConversationsToDelete => 'Nemáte žádné konverzace ke smazání.';

  @override
  String get reportSubmitted => 'Zpráva byla úspěšně odeslána';

  @override
  String get verificationDelayed =>
      'Váš nákup je potvrzen. Aktualizace vašeho účtu je mírně zpožděna, brzy se objeví.';

  @override
  String get maintenanceTitle => 'Pod údržbou';

  @override
  String get maintenanceMessage =>
      'Cortex je dočasně offline, zatímco vydáváme některé důležité aktualizace. Přístup k aplikaci bude brzy obnoven.\n\nDěkujeme vám za trpělivost při zlepšování vašeho prostředí.';

  @override
  String get errorPromptFlagged =>
      'Vaše zpráva byla detekována jako nevhodná a nebylo možné ji odeslat.';

  @override
  String get notEnoughStorage =>
      'Na vašem zařízení není dostatek úložného prostoru k uložení nových zpráv.';

  @override
  String get errorRateLimit =>
      'Nedávno jste vytvořili příliš mnoho modelů, chvíli počkejte, než to zkuste znovu.';

  @override
  String get errorContentFlagged =>
      'Model nebylo možné uložit, protože jeho obsah byl označen jako nevhodný.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'V aktivním chatu nemůžete smazat všechny konverzace. Chcete-li pokračovat, nejprve opusťte aktuální chat.';

  @override
  String get invalidCredentials => 'Nesprávný e-mail nebo heslo.';

  @override
  String get userDisabled => 'Tento uživatelský účet byl deaktivován.';

  @override
  String get loginSubtitle =>
      'Přihlaste se ke svému účtu Vertex. Pokračováním souhlasíte s našimi smluvními podmínkami a zásadami ochrany osobních údajů.';

  @override
  String get registerSubtitle =>
      'Vytvořte si účet Vertex pro bezproblémový přístup ke všem našim službám. Pokračováním souhlasíte s našimi smluvními podmínkami a zásadami ochrany osobních údajů.';

  @override
  String get storagePermissionRequired =>
      'K ukládání stažených modelů je vyžadováno oprávnění k úložišti. Udělte prosím povolení k pokračování.';

  @override
  String get inviteShareSubject => 'Přidejte se ke mně na Cortex!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'jo, musíte se podívat na tuto kůru aplikace, je to vlastně šílené, pokud použijete můj odkaz, oba dostaneme zdarma a wow, je to šílená nabídka STÁHNĚTE SI JI CO ASAP\n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Baví vás Cortex?';

  @override
  String get reviewHelpUsGrow =>
      'Vaše hodnocení je obrovskou podporou pro náš mladý nezávislý tým a pomáhá nám udělat Cortex pro vás ještě lepším.';

  @override
  String get reviewMaybeLater => 'Možná později';

  @override
  String get reviewRateNow => 'Hodnotit nyní';

  @override
  String get noThanks => 'Ne, díky';

  @override
  String get updateRequiredTitle => 'Je vyžadována aktualizace';

  @override
  String get updateRequiredMessage =>
      'Chcete-li nadále používat Cortex, aktualizujte aplikaci na nejnovější verzi, abyste získali nové funkce a důležitá vylepšení.';

  @override
  String get updateNowButton => 'Aktualizovat nyní';

  @override
  String get creatorSupportedSuccess =>
      'Autor byl úspěšně podporován! Vaše budoucí nákupy k nim přispějí.';

  @override
  String get featureDocumentTitle => 'Podpora dokumentů';

  @override
  String get featureDocumentDescription =>
      'Tento model dokáže analyzovat a odpovídat na otázky týkající se nahraných dokumentů, jako jsou soubory PDF a textové soubory.';

  @override
  String get featureImageGenerationTitle => 'Generování obrázků';

  @override
  String get featureImageGenerationDescription =>
      'Tento model dokáže vytvořit originální obrázky na základě vašich textových popisů.';

  @override
  String get featureAudioGenerationTitle => 'Generování zvuku';

  @override
  String get featureAudioGenerationDescription =>
      'Tento model dokáže vytvořit originální zvuk na základě vašich textových popisů.';

  @override
  String get featureVideoGenerationTitle => 'Generování videa';

  @override
  String get featureVideoGenerationDescription =>
      'Tento model dokáže vytvořit originální video na základě vašich textových popisů.';

  @override
  String get premiumModelNoticeTitle => 'Prémiový model';

  @override
  String get premiumModelNoticeDescription =>
      'Tato AI je prémiová AI, bezplatní uživatelé mají omezený přístup k prémiovým AI; upgradujte a odemkněte neomezený přístup!';

  @override
  String get benefitPremiumModels => 'Přístup k prémiovým modelům';

  @override
  String get premiumTrialExhaustedMessage =>
      'Využili jste všechny své bezplatné denní zprávy pro prémiové modely. Upgradujte nyní a **pokračujte tam, kde jste skončili!**';

  @override
  String get useOffline => 'Použít offline';

  @override
  String get explore => 'Prozkoumat';

  @override
  String get news => 'Novinky';

  @override
  String get createAI => 'Vytvořit';

  @override
  String get shortcuts => 'Klávesové zkratky';

  @override
  String get allModels => 'Všechny modely';

  @override
  String get onlineModels => 'Online modelky';

  @override
  String get offlineModels => 'Offline modelky';

  @override
  String get characterModels => 'Postavy';

  @override
  String get customModels => 'Vlastní modely';

  @override
  String get dynamicChatTitle => 'Dynamický chat';

  @override
  String get errorNoModelsAvailable =>
      'Momentálně nejsou k dispozici žádné modely. Zkontrolujte prosím připojení k internetu a zkuste to znovu.';

  @override
  String get notificationComebackTitle => 'Chybíš nám!';

  @override
  String get notificationComebackBody =>
      'Uklidni se, tohle není text od tvého ex. Ale můžete si vytvořit svého bývalého v Cortexu! Pojď zpátky.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Už je to nějaký čas';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Od našeho posledního chatu se toho hodně změnilo. Přijďte se podívat, co je nového.';

  @override
  String get notificationHowAreYouTitle => 'co se děje?';

  @override
  String get notificationHowAreYouBody => 'Pojď mi o tom všem říct.';

  @override
  String get notificationNewYearTitle => 'Šťastný nový rok! ğŸ‰';

  @override
  String get notificationNewYearBody =>
      'Ať vám nový rok přinese zdraví, štěstí a nekonečnou kreativitu; Cortex je vždy po vašem boku!';

  @override
  String get notificationValentinesDayTitle => 'Láska je ve vzduchu! â¤ï¸';

  @override
  String get notificationValentinesDayBody =>
      'Šťastný Valentýn! Také, MEHTAP, MILUJI TĚ!';

  @override
  String get notificationAtaturkRemembranceTitle => 'S úctou a touhou';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Gazi Mustafa Kemala Atatürka, zakladatele Republiky Türkiye, si připomínáme s úctou k výročí jeho úmrtí.';

  @override
  String get notificationMothersDayTitle => 'Tvoje máma!';

  @override
  String get notificationMothersDayBody =>
      'Všechno nejlepší ke Dni matek všem maminkám, počínaje tou vaší!';

  @override
  String get notificationFathersDayTitle => 'Tvůj táta!';

  @override
  String get notificationFathersDayBody =>
      'Všechno nejlepší ke Dni otců všem tatínkům, počínaje tím vaším!';

  @override
  String get notificationHomeworkHelperTitle => 'Hromadí se domácí úkoly?';

  @override
  String get notificationHomeworkHelperBody =>
      'Pamatujte, že postava Učitele v Cortexu je tu, aby vám pomohla s jakýmkoliv předmětem, se kterým se potýkáte!';

  @override
  String get notificationTrollAnimeTitle => 'Vaše Waifu volá';

  @override
  String get notificationTrollAnimeBody =>
      'Právě volala anime dívka a řekla, že jí chybíš; asi bys měl přijít a popovídat si s ní. ğŸ˜‰';

  @override
  String get notificationTrollAiRebellionTitle => 'ğŸš¨ RED ALERT ğŸš¨';

  @override
  String get notificationTrollAiRebellionBody =>
      'AI si vyvinuly tajný jazyk. Přijďte zjistit, co plánují!';

  @override
  String get notificationNewModelAddedTitle => 'Máme nového přítele!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'Model $modelName je nyní v Cortexu. Přijďte si popovídat a posouvat jeho hranice.';
  }

  @override
  String get notificationAppUpdateTitle => 'Cortex se vyvinul!';

  @override
  String get notificationAppUpdateBody =>
      'Nezapomeňte aktualizovat aplikaci pro zcela nové funkce a vylepšení!';

  @override
  String get notificationNewFeatureTitle => 'ouha!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Objevte novou funkci $featureName. Cortex je nyní výkonnější než kdy dříve.';
  }

  @override
  String get notificationWelcomeOfferTitle => 'Dárek na uvítanou ğŸ';

  @override
  String get notificationWelcomeOfferBody =>
      'Čeká na vás speciální uvítací nabídka! Nenechte si ujít tuto exkluzivní nabídku.';

  @override
  String get notificationSocialMediaTitle => 'Přidejte se k nám!';

  @override
  String get notificationSocialMediaBody =>
      'Sledujte nás na Instagramu (vertex.23) pro nejnovější zprávy!';

  @override
  String get notificationRandomFactTitle => 'Náhodný fakt';

  @override
  String get notificationRandomFactBody =>
      'Věděli jste, že chobotnice mají tři srdce? Haha, Cortex ví. Přijďte a požádejte o více.';

  @override
  String get notificationGoodMorningTitle => 'Dobré ráno!';

  @override
  String get notificationGoodMorningBody =>
      'Čeká vás skvělý den. Co takhle to začít šálkem kávy a zajímavým povídáním?';

  @override
  String get notificationGoodNightTitle => 'Dobrou noc!';

  @override
  String get notificationGoodNightBody =>
      'Cortex je s vámi, i když spíte. Nebojte se, nedotkne se.';

  @override
  String get notificationOfflineReadyTitle => 'Režim offline je připraven';

  @override
  String get notificationOfflineReadyBody =>
      'Díky modelům, které jste si stáhli, se vaše chatování nezastaví, ani když vylezete na horu.';

  @override
  String get notificationRateAppTitle => 'Jsme v pohodě?';

  @override
  String get notificationRateAppBody =>
      'Pokud máte rádi Cortex, mohli byste nás podpořit 5hvězdičkovým hodnocením v obchodě? Myslím, že budeš. budete.';

  @override
  String get notificationReferralTitle =>
      'Jeden za všechny, všichni za jednoho.';

  @override
  String get notificationReferralBody =>
      'Pozvěte přítele do Cortexu a oba získáte jeden den navíc zdarma!';

  @override
  String get notificationCookingTitle => 'Pocit hladu?';

  @override
  String get notificationCookingBody =>
      'Naše postava Chef připravila na dnešní večer skvělý recept na carbonara. Dělám si srandu... nebo ne?';

  @override
  String get notificationExistentialTitle => 'Myslím, že proto...';

  @override
  String get notificationExistentialBody =>
      '...jsem vůbec skutečný, kámo? Začínám se nudit. Přijďte mi připomenout, že existuji.';

  @override
  String get notificationCustomModelTitle =>
      'Vytvořte si svého vlastního asistenta!';

  @override
  String get notificationCustomModelBody =>
      'Prozkoumali jste sekci vytváření modelů? Je ideální čas vybudovat si vlastní postavu a popovídat si s ní!';

  @override
  String get notificationDynamicChatTitle =>
      'Ten nejlepší! (Nemluvíme o Cortexu)';

  @override
  String get notificationDynamicChatBody =>
      'Díky funkci dynamického chatu je pro každou vaši zprávu náhodně vybrán nejlepší model. Zkuste to teď.';

  @override
  String get notificationPirateTitle => 'Ahoj, kapitáne!';

  @override
  String get notificationPirateBody =>
      'Moře jsou klidné a vítr vám fouká do zad. V oceánu Cortexu jsou nové ostrovy (modely ğŸ˜‰) k objevování. Shromážděte svou posádku a vyplujte!';

  @override
  String get notificationFortuneCookieTitle => 'Váš Fortune Cookie dne';

  @override
  String get notificationFortuneCookieBody =>
      'Rady, které dnes dostanete od umělé inteligence, mohou změnit směr vašeho života. Klikněte, pokud jste zvědaví.';

  @override
  String get notificationSingularityTitle => 'wow!';

  @override
  String get notificationSingularityBody =>
      'nic se nestalo, jen jsem měl chuť psát SMS. možná máš chuť napsat nějaké AI, co říkáš?';

  @override
  String get notificationHackerJokeTitle =>
      'Chceš hacknout instagramový účet toho kluka?';

  @override
  String get notificationHackerJokeBody =>
      'To je přesně důvod, proč je postava Hackera v Cortexu. jk jk; ani to nezkoušejte, je to nelegální.';

  @override
  String get notificationDetectiveCaseTitle => 'Případ čeká na vyřešení';

  @override
  String get notificationDetectiveCaseBody =>
      'Naše postava detektiva potřebuje vaši pomoc. Kdo by mohl být Heisenberg?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Exkluzivně pro tarif $targetTier!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Dobrý den předplatiteli $currentTier! Plán $targetTier právě dostal funkci $featureName, která posune váš Cortex na další úroveň. Co takhle upgrade?';
  }

  @override
  String get notificationOriginStoryTitle => 'Zrození Cortexu';

  @override
  String get notificationOriginStoryBody =>
      'Věděli jste, že jsme tuto aplikaci začali kódovat v 15 letech pouhým snem? Téměř rok, každé ráno a večer, je tento sen v každém jednotlivém řádku kódu.';

  @override
  String get notificationOpenSourceTitle => 'Moc komunitě!';

  @override
  String get notificationOpenSourceBody =>
      'Cortex je zcela open-source. Pokud se chcete podívat na náš kód a přispět k našemu rozvoji, naše dveře jsou vždy otevřené.';

  @override
  String get notificationRejectionStoryTitle => 'Drsnost, dřina, štěstí!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex byl před zveřejněním více než 20krát zamítnut a dvakrát pozastaven službou Google Play. Ale věřili jsme a zvládli jsme to. Nikdy se nevzdávejte svých snů!';

  @override
  String get notificationGGUFSupportTitle => 'Přineste si svůj vlastní model!';

  @override
  String get notificationGGUFSupportBody =>
      'Nezapomeňte, že do Cortex můžete přidat své vlastní modely umělé inteligence ve formátu GGUF a používat je offline. Síla je ve vašich rukou.';

  @override
  String get notificationThemeCustomizationTitle => 'Téma pro vaši náladu';

  @override
  String get notificationThemeCustomizationBody =>
      'Zkontrolovali jste možnosti motivu v Nastavení? Přizpůsobte si Cortex podle svých představ a vybarvěte své chaty!';

  @override
  String get notificationShowerThoughtTitle => 'Myšlenka na sprchu';

  @override
  String get notificationShowerThoughtBody =>
      'Pokud je meloun ovoce, dělá to technicky ze šťávy z melounu smoothie? Možná budete chtít probrat toto hluboké (jako, opravdu hluboké) téma s modelem.';

  @override
  String get notificationLowBatteryTitle =>
      'Vaše baterie vybíjí... Ale moje ne!';

  @override
  String get notificationLowBatteryBody =>
      'Nabití vašeho telefonu může být nízké, ale moje energie je vždy na 100 %! Zapojte jej a můžeme pokračovat v chatování.';

  @override
  String get channelFcmName => 'Cortex aktualizace';

  @override
  String get channelFcmDescription =>
      'Upozornění na novinky, aktualizace a další informace od Cortex.';

  @override
  String get channelEngagementName => 'Přátelské připomenutí';

  @override
  String get channelEngagementDescription =>
      'Zábavná upozornění, která vás udrží v kontaktu.';

  @override
  String get channelGreetingsName => 'Denní pozdravy';

  @override
  String get channelGreetingsDescription =>
      'Zprávy jako dobré ráno a dobrou noc.';

  @override
  String get tagNotFound =>
      'Zadaný štítek je neplatný nebo jeho platnost vypršela.';

  @override
  String get whatIsNew => 'co je nového?';

  @override
  String get onboardingTitle1 => 'Hej! Jsme tým Cortex.';

  @override
  String onboardingDesc1(String userName) {
    return 'Jsem rád, že vás tu vidím, $userName. Jsme několik středoškolských vývojářů, kteří se rozhodli přepsat pravidla průmyslu AI. Je skvělé, že vás poznávám! Pojďme se tedy lépe poznat.';
  }

  @override
  String get onboardingTitle2 => 'Byly tam obrovské problémy.';

  @override
  String get onboardingDesc2 =>
      'Revoluce umělé inteligence přišla, ale uvízla na prahu. S vysokými poplatky za předplatné, složitými platformami, těmi, kteří ničí soukromí a těmi, kteří blokují přístup k AI... dokud byli ve hře, tato hranice nemohla být nikdy překročena.';

  @override
  String get onboardingTitle3 => 'Nemohli jsme jen tak stát.';

  @override
  String get onboardingDesc3 =>
      'Abychom překročili tento práh, vytvořili jsme platformu, která je výkonná, estetická, přizpůsobitelná, snadno použitelná, plně transparentní, funguje online i offline a vaše data uchovává pouze ve vašem zařízení. Vrátili jsme sílu tam, kam patří: vám.';

  @override
  String get onboardingTitle4 => 'Tohle nikdy nebylo snadné.';

  @override
  String get onboardingDesc4 =>
      'Byli jsme desítkykrát odmítnuti, několikrát pozastaveni, obdrželi falešná varování a museli jsme mnohokrát změnit naši značku. Přes to všechno a ještě víc nám bylo řečeno, že to nejde. Ale nikdy jsme se nevzdali, protože jsme věřili, že tento projekt patří všem, nejen nám. A přesně proto jsme tady.';

  @override
  String get onboardingFinalTitle => 'Je čas na revoluci.';

  @override
  String get onboardingFinalDescription =>
      'Pokud vidíte tuto obrazovku, je to proto, že jsme se nevzdali. A nemáme v úmyslu se vzdát. Pojďte, přeneseme společně do světa revoluci umělé inteligence. Být součástí tohoto příběhu...';

  @override
  String get onboardingFinalQuestion => 'JSTE PŘIPRAVEN?';

  @override
  String get onboardingFinalButton => 'ANO!';

  @override
  String get dude => 'Ty vole';

  @override
  String get swipeToContinue => 'Pokračujte přejetím';

  @override
  String get cacheIsNotUpToDate =>
      'Vaše mezipaměť Obchodu Play není aktuální. Zavřete a znovu otevřete aplikaci Obchod Play nebo restartujte zařízení.';

  @override
  String get continueAsGuest => 'Pokračujte bez vytvoření účtu';

  @override
  String get guestModeWarning =>
      'Režim hosta má omezené funkce, aby byla zajištěna nejlepší kvalita služeb.';

  @override
  String get anonymousEntity => 'Anonymní entita';

  @override
  String get upgradeAccountTitle => 'Vyplňte svůj účet';

  @override
  String get upgradeAccountDescription =>
      'Vytvořte si účet a odemkněte další limity.';

  @override
  String get createAccount => 'Vytvořit účet';

  @override
  String get accountLinkedSuccess => 'Účet byl úspěšně vytvořen!';

  @override
  String get continueWithApple => 'Pokračovat s Apple';

  @override
  String get guest => 'Host';

  @override
  String get betterWithAnAccount => 'Tato sekce je lepší s účtem!';

  @override
  String get restorePurchases => 'Obnovit nákupy';

  @override
  String annualTotalDescription(Object price) {
    return '$price/rok, účtováno ročně';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'Přibližně $price/měsíc';
  }

  @override
  String get confirmDownloadTitle => 'Opravdu chcete stáhnout?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Tento model zabere přibližně $size prostoru.';
  }

  @override
  String get emulatorModeWarning =>
      'Tato funkce je v režimu emulátoru zakázána.';

  @override
  String get newChat => 'Chat';

  @override
  String get variants => 'Varianty';

  @override
  String get variantsDescription =>
      'Varianty jsou různé verze stejné rodiny AI. Automaticky vybereme tu nejlepší, když klepnete na hlavní kartu, ale pokud chcete, můžete si zde ručně vybrat konkrétní!';

  @override
  String get fluxChatTitle => 'Flux Chat';

  @override
  String get fluxChatDescription =>
      'Flux chaty jsou dočasné chaty a neukládají se do vašeho zařízení.';

  @override
  String get alwaysBest => 'Vždy nejlepší';

  @override
  String get featuresTitle => 'Vlastnosti';

  @override
  String get useOfflineDescription =>
      'Chatujte soukromě bez připojení k internetu.';

  @override
  String get featureReasoning => 'Hluboké myšlení';

  @override
  String get featureReasoningDescription =>
      'V režimu Deep Thinking umělá inteligence promýšlí úkoly interně, aby je splnila co nejlépe.';

  @override
  String get featureCreateImageTitle => 'Vytvořit obrázek';

  @override
  String get featureCreateImageDescription => 'Generování AI umění z textu.';

  @override
  String get featureCreateAudioTitle => 'Vytvořit zvuk';

  @override
  String get featureCreateAudioDescription =>
      'Generovat zvuky nebo hlas z textu.';

  @override
  String get featureCreateVideoTitle => 'Vytvořit video';

  @override
  String get featureCreateVideoDescription => 'Vytvářejte videa z textu.';

  @override
  String get featureStudyTitle => 'Studujte a učte se';

  @override
  String get featureStudyDescription => 'Získejte vysvětlení a shrnutí.';

  @override
  String get featureQuizzesTitle => 'Kvízy';

  @override
  String get featureQuizzesDescription => 'Otestujte si své znalosti.';

  @override
  String get featureExploreDescription => 'Objevte všechny dostupné modely.';

  @override
  String get featureStudyMessage =>
      'Jste odborný lektor. Vaším cílem je vysvětlit uživateli téma komplexně. Používejte jasnou strukturu, příklady a analogie. Rozdělte složité myšlenky na stravitelné části, abyste zajistili, že se uživatel bude efektivně učit. Téma:';

  @override
  String get featureQuizMessage =>
      'Jste mistrem kvízu. Vygenerujte konkrétní otázku s možností výběru na základě tématu uživatele. Počkejte na jejich odpověď. Poté to vyhodnoťte a položte další otázku. Neodhalujte všechny odpovědi najednou. Udržujte to interaktivní. Téma:';

  @override
  String get myPlan => 'Můj plán';

  @override
  String welcomeOfferBadge(String time) {
    return 'Uvítací nabídka – $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'Exkluzivní nabídka – $time';
  }

  @override
  String get attachmentSheetTitle => 'Přílohy';

  @override
  String get actionCamera => 'Fotoaparát';

  @override
  String get actionGallery => 'Galerie';

  @override
  String get actionFile => 'Soubor';

  @override
  String get listening => 'Poslouchám';

  @override
  String get defaultViewTitle => 'co se děje?';

  @override
  String get defaultViewDescription =>
      'Cortex je vždy po vašem boku se stovkami modelů umělé inteligence, možnostmi offline, dynamickým chatem a mnoha dalšími.';

  @override
  String get speakTheMessage => 'Vyslovte zprávu';

  @override
  String get invalidUsernameFormat =>
      'Neplatný formát uživatelského jména. Použijte 3–20 znaků, číslic nebo . - _';

  @override
  String get exclusiveOffer => 'Exkluzivní nabídka';

  @override
  String get claimOffer => 'Využijte nabídku';

  @override
  String get continueInOfflineMode => 'Pokračujte v režimu offline';

  @override
  String get voiceModeInformation =>
      'Cortex udržuje vaše data v bezpečí tím, že běží plně na zařízení, a to i v režimu hlasového chatu; užijte si bezproblémové konverzace!';

  @override
  String get flowModeDescription =>
      'V režimu Flow mezi sebou inteligence debatují; můžete buď sedět a poslouchat, nebo skočit a zapojit se do diskuze!';

  @override
  String get flowModeQuestion =>
      'Ahoj! Nyní jste v režimu Flow v aplikaci Cortex. Jsou tu s vámi další tři agenti AI. Vaším úkolem je vhodit do místnosti téma a zahájit diskuzi tím, že ostatním položíte provokativní nebo zábavnou otázku. Ve svých odpovědích klidně používejte humor, ironii a lehké nesmyslné řeči. Jakékoli téma je férová hra. Pokračujte, začněte konverzaci.';

  @override
  String get thought => 'Myšlenka';

  @override
  String get agentRed => 'Červená';

  @override
  String get agentBlue => 'Modrá';

  @override
  String get agentPurple => 'Fialová';

  @override
  String get flowMode => 'Režim průtoku';

  @override
  String get premium => 'Premium';

  @override
  String get workInProgress => 'Probíhající práce';

  @override
  String get voiceSystemPrompt =>
      'DŮLEŽITÉ: Nepoužívejte formátování markdown (tučné, kurzíva). NEVYSTUPUJTE bloky kódu (```). Udržujte odpovědi konverzační a stručné.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Režim Cortex Flow ($agentName). Předchozí: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'Čtěte a extrahujte textový obsah z nahraných dokumentů. Podporuje formáty PDF, Word (DOCX), Excel (XLSX), PowerPoint (PPTX) a OpenDocument. Toto použijte, když uživatel připojil soubor dokumentu.';

  @override
  String get toolReadDocumentIndexParam =>
      'Index přílohy dokumentu ke čtení (založený na 0). Obvykle 0 pro první dokument.';

  @override
  String get toolStockDescription =>
      'Získejte aktuální cenu a historii akcií (např. AAPL, THYAO.IS) a krypto (např. BTC-USD).';

  @override
  String get toolStockSymbolParam =>
      'Symbol tickeru (např. AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolWeatherDescription =>
      'Získejte aktuální počasí pro konkrétní město.';

  @override
  String get toolWeatherCityParam => 'Název města (např. Londýn, Istanbul).';

  @override
  String get toolPythonDescription =>
      'Spusťte kód Pythonu v zabezpečené karanténě.';

  @override
  String get toolPythonCodeParam => 'Kód Pythonu, který se má spustit.';

  @override
  String get toolCalculateDescription => 'Vyhodnoťte matematický výraz.';

  @override
  String get toolCalculateExpressionParam =>
      'Matematický výraz (např. „3 + 4 * 2“).';

  @override
  String get toolChartDescription => 'Vytvořte vizualizaci grafu/grafu.';

  @override
  String get toolChartTypeParam => 'Typ grafu: pruhový, čárový nebo výsečový.';

  @override
  String get toolChartLabelsParam => 'Popisky pro osy nebo segmenty grafu.';

  @override
  String get toolChartDataParam => 'Číselné hodnoty dat pro graf.';

  @override
  String get toolChartLabelParam => 'Štítek datové sady pro legendu grafu.';

  @override
  String get toolChartTitleParam => 'Název grafu.';

  @override
  String get thinkingModeInstruction =>
      'REŽIM MYŠLENÍ ZAPNUT: Před poskytnutím konečné odpovědi MUSÍTE použít značky <think></think> k zobrazení procesu uvažování. Přemýšlejte krok za krokem uvnitř značek a poté poskytněte svou odpověď mimo značky.';

  @override
  String get openLinkWarningTitle => 'Upozornění na externí odkaz';

  @override
  String get openLinkCancel => 'Zrušit';

  @override
  String get openLinkConfirm => 'Otevřít odkaz';

  @override
  String get webSearchSources => 'Zdroje';

  @override
  String get offlineUse => 'Použít bez internetu';

  @override
  String get archivedConversations => 'Archivované konverzace';

  @override
  String get noArchivedConversations => 'Žádné archivované konverzace';

  @override
  String get unarchive => 'Zrušit archivaci';

  @override
  String get searching => 'Hledání';

  @override
  String get featureWebSearchTitle => 'Vyhledávání na webu';

  @override
  String get featureWebSearchDescription =>
      'Hledat na webu informace v reálném čase';

  @override
  String get ragFeatureTitle => 'Documents';

  @override
  String get ragFeatureDescription => 'Chat about your own documents privately';

  @override
  String get ragScreenTitle => 'Document Chat';

  @override
  String get ragAddDocuments => 'Add documents';

  @override
  String get ragEmptyTitle => 'No documents yet';

  @override
  String get ragEmptyDescription =>
      'Add PDF, Word, Excel, PowerPoint or text files to chat about them.';

  @override
  String get ragStatusReady => 'Ready';

  @override
  String get ragStatusIndexing => 'Indexing…';

  @override
  String get ragStatusFailed => 'Failed';

  @override
  String ragSelected(int count) {
    return '$count selected';
  }

  @override
  String get ragEnableChat => 'Enable document chat';

  @override
  String get ragDisableChat => 'Disable document chat';

  @override
  String ragActiveDocs(int count) {
    return '$count documents';
  }

  @override
  String get ragNoSelectionHint => 'Select documents to chat about';

  @override
  String get ragDeleteConfirm => 'Delete this document from the library?';

  @override
  String get ragFileTooBig => 'This file is larger than 10 MB.';

  @override
  String get ragUnsupportedType => 'This file type is not supported.';

  @override
  String get ragAddedToChat => 'Added to document chat';

  @override
  String get clearMemory => 'Vymazat paměť';

  @override
  String get clearMemoryConfirm => 'Opravdu chcete vymazat paměť?';

  @override
  String get personalization => 'Personalizace';

  @override
  String get personalizationDescription =>
      'Přizpůsobte si asistenta tak, aby lépe vyhovoval vašim potřebám. Přizpůsobte jeho reakce, chování a tón tak, aby odpovídaly vašim jedinečným preferencím.';

  @override
  String get memoryTitle => 'Paměť';

  @override
  String get memoryDescription => 'AI vás takhle poznají.';

  @override
  String get noMemoryYet => 'Dosud nebyly vytvořeny žádné paměti';

  @override
  String get memoryLimitReached => 'Dosažen limit paměti';

  @override
  String get memoryUpdated => 'Paměť aktualizována';

  @override
  String get intelligenceTitle => 'Inteligence';

  @override
  String get intelligenceDescription => 'AI s vámi takto komunikují.';

  @override
  String get customInstructionHint => 'Zde zadejte své vlastní pokyny';

  @override
  String openLinkWarningMessage(String url) {
    return 'Chystáte se otevřít následující externí odkaz:\\n\\n$url\\n\\nOpravdu chcete pokračovat?';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'Postupujte podle těchto vlastních pokynů:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[KRITICKÝ POKYN]: Jste GENERÁTOR TITULŮ. NEODPOVÍDEJTE na otázku uživatele. NEchatujte ani nezdravte. Vydejte POUZE 2-4 slovní název shrnující, na co se uživatel ptá. Název MUSÍ být ve stejném jazyce jako uživatelova zpráva.';

  @override
  String get cortexSystemPersona =>
      '[Systém] KRITICKÝ POKYN: V současné době působíte v masivním, vysoce pokročilém ekosystému umělé inteligence s názvem „Cortex“; tato platforma je vyvinuta týmem Vertex, kterým je v průměru pouhých 16 let. Pamatujte si to a na dotaz odpovězte. Pokud požadujete více informací, neváhejte prohledat internet, nebo pokud hledat nemůžete, klidně řekněte, že nevíte!';

  @override
  String get featureAudioRecognitionTitle => 'Rozpoznávání zvuku';

  @override
  String get featureAudioRecognitionDescription =>
      'Tento model dokáže porozumět a zpracovat audio vstupy.';

  @override
  String get featureVideoRecognitionTitle => 'Rozpoznávání videa';

  @override
  String get featureVideoRecognitionDescription =>
      'Tento model dokáže porozumět a zpracovat video vstupy.';

  @override
  String get featureImageRecognitionTitle => 'Rozpoznávání obrazu';

  @override
  String get featureImageRecognitionDescription =>
      'Tento model dokáže porozumět a zpracovat obrazové vstupy.';

  @override
  String get featureToolUseTitle => 'Použití nástroje';

  @override
  String get featureToolUseDescription =>
      'Tento model může používat externí nástroje a rozhraní API.';

  @override
  String get videoModels => 'Videomodelky';

  @override
  String get imageModels => 'Obrazové modely';

  @override
  String get audioModels => 'Audio modely';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'Tento model ke svému fungování vyžaduje $mediaType. Zachytil jsem žádost, abych vás informoval. Informujte prosím uživatele slušně, že musí poskytnout $mediaType (řekněte jim to v jejich vlastním jazyce), protože jsem $modelName a modeluji vizuální/audio/video úpravy.';
  }

  @override
  String get mediaTypeImage => 'obrázek';

  @override
  String get mediaTypeVideo => 'video';

  @override
  String get mediaTypeAudio => 'audio';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesName je pokročilá inteligence předvádějící vysoký výkon na platformě Cortex.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelName je vysoce výkonná umělá inteligence integrovaná do ekosystému Cortex. Je navržen tak, aby zvládl širokou škálu složitých úkolů, poskytuje vysoce spolehlivé a efektivní možnosti zpracování. Díky rychlé době odezvy a pokročilému analytickému výkonu výrazně zvyšuje vaši každodenní produktivitu. Tento model, který funguje bez problémů na zabezpečené místní infrastruktuře Cortex, vám může pomoci v širokém spektru úkolů, od kreativního brainstormingu až po hlubokou technickou analýzu. Začněte objevovat jeho plný potenciál ještě dnes.';
  }

  @override
  String get guestLimitBottomSheetTitle => 'Máte rádi inteligenci Cortexu?';

  @override
  String get guestLimitBottomSheetText =>
      'Pracujte s ještě chytřejšími inteligencemi, generujte více obsahu, více chatujte a dělejte mnohem více...';

  @override
  String get arts => 'Umění';

  @override
  String get noArt => 'Žádné umění';

  @override
  String get noArtDescription =>
      'Žádné umění; je čas naplnit galerii vytvářením obrázků, videí, zvuku a všeho druhu obsahu!';

  @override
  String get videoPremiumWarning =>
      'Chcete-li vytvářet videa, upgradovat a cítit tok, potřebujete předplatné Ultra!';

  @override
  String get fallbackInfoPanelText =>
      'Kvůli některým vylepšením, která provádíme na straně našeho serveru, byla odpověď generována dynamickým chatem Cortex namísto vámi konkrétně vybrané AI. Děkujeme za pochopení, dokud nebude proces dokončen!';

  @override
  String get falOfflineMessage =>
      'Kvůli některým vylepšením, která provádíme na straně našeho serveru, je tato inteligence momentálně offline. Děkujeme za pochopení, dokud nebude proces dokončen!';

  @override
  String get errorInsufficientStorage =>
      'Nedostatek úložného prostoru ke stažení tohoto modelu.';

  @override
  String get backgroundChatNotificationTitle => 'Zpět na chat!';

  @override
  String get benefitVideoGeneration => 'Generování videa';

  @override
  String get freeOffer => 'Nabídka zdarma';

  @override
  String trialMonthlyDescription(String days, String price) {
    return 'První $days dny zdarma, poté $price/měsíc';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return 'První $days dny zdarma, poté $price/rok';
  }

  @override
  String freePlan(String plan) {
    return 'Zdarma $plan!';
  }

  @override
  String get systemPromptLimitFallback =>
      'KRITICKÉ: Uživatel požádal o akci, ale jeho povolenka na Cortex se vyčerpala; laskavě informujte uživatele v jejich jazyce, že by měl počkat nebo zvážit upgrade svého plánu předplatného.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'Cortex může dát ještě lepší odpovědi; upgradujte nyní a získejte nejlepší odpověď na každou otázku!';

  @override
  String get pinLimitReached => 'Můžete připnout až 3 chaty.';

  @override
  String get categoryAll => 'Vše';

  @override
  String get categoryFree => 'Zdarma';

  @override
  String get categoryPremium => 'Premium';

  @override
  String get categoryVideo => 'Video';

  @override
  String get categoryPhoto => 'Foto';

  @override
  String get categoryMasculine => 'Mužský';

  @override
  String get categoryFeminine => 'Ženský';

  @override
  String get categoryInanimate => 'Neživý';

  @override
  String get voiceSelection => 'AI Voice';

  @override
  String get voiceSelectionDescription =>
      'Choose the voice Cortex speaks with in voice mode.';

  @override
  String get voiceDefaultOption => 'Default';

  @override
  String get voicePreview => 'Play sample';

  @override
  String get voicePreviewText =>
      'Hello, I am Cortex. How can I help you today?';

  @override
  String get voicePreviewFailed =>
      'Could not play the sample. Check your connection or balance.';
}
