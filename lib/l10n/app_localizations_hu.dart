// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'Ön egy címgenerátor. A következő beszélgetésre CSAK 2-5 szavas címmel válaszoljon. Ne használjon idézőjeleket, előtagokat vagy írásjeleket. KRITIKUS: A címnek PONTOSAN UGYANAZON KELL lennie, mint a felhasználó üzenetének.';

  @override
  String get systemRoleFallback => 'Segítőkész asszisztens vagy.';

  @override
  String get systemLanguageInstruction =>
      'KRITIKUS: Mindig ugyanazon a nyelven válaszoljon, amelyen a felhasználó ír, ügyeljen a felhasználó nyelvére.';

  @override
  String get systemNotePreviousMedia =>
      '[Rendszer megjegyzés: Alul látható a korábban létrehozott adathordozó. Hivatkozhat rá vagy szerkesztheti.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return 'Jelenlegi dátum és idő: $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '[RENDSZERMEMÓRIAI IRÁNYELV]\nElemezze az eddigi beszélgetést. Ha BÁRMILYEN új, különálló tényt megtudott a felhasználóról (preferenciák, név, szokások, kontextus), akkor a válasza VÉGÉN ki KELL adnia a TELJES frissített memóriáját a felhasználóról a <memory>...</memory> címkéken belül. KRITIKUS: SOHA nem szabad törölni vagy felülírni az előző memóriát. MINDIG fűzz hozzá új tényeket a meglévő memóriához. Ha semmi újat nem tanult, hagyja ki a címkét. Példa: <memory>Szereti a focit és a teniszt. A rövid válaszokat részesíti előnyben.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return 'Mindig emlékezzen erre a felhasználóról:\n$userMemory';
  }

  @override
  String get cancel => 'Mégse';

  @override
  String get remove => 'Eltávolítás';

  @override
  String get download => 'Letöltés';

  @override
  String get resume => 'Folytatás';

  @override
  String get copy => 'Másolás';

  @override
  String get chat => 'Chat';

  @override
  String get branch => 'Elágazás';

  @override
  String get locked => 'Lezárva';

  @override
  String get languageModels => 'Nyelvi modellek';

  @override
  String get light => 'Fény';

  @override
  String get theme => 'Téma';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get no => 'Nem';

  @override
  String get yes => 'Igen';

  @override
  String get done => 'Kész';

  @override
  String get bestValue => 'Legjobb érték';

  @override
  String get selected => 'Kiválasztva';

  @override
  String get descriptionSection => 'Leírás';

  @override
  String get searchHint => 'Keresés';

  @override
  String get messageHint => 'Kérdezz bármit';

  @override
  String get messageCopied => 'Az üzenet a vágólapra másolva.';

  @override
  String get retry => 'Próbálja újra';

  @override
  String get systemInfo => 'Rendszerinformációk';

  @override
  String deviceMemory(Object memory) {
    return 'Eszközmemória: $memory GB';
  }

  @override
  String get memory => 'Memória';

  @override
  String get storage => 'Tárolás';

  @override
  String get freeStorage => 'Ingyenes tárolás';

  @override
  String get totalStorage => 'Teljes tárhely';

  @override
  String get usedStorage => 'Használt tárolás';

  @override
  String get totalMemory => 'Teljes memória';

  @override
  String get usedMemory => 'Használt memória';

  @override
  String get modelsTitle => 'Könyvtár';

  @override
  String get localModels => 'Helyi modellek';

  @override
  String get selectGGUFFile => 'Válassza ki a GGUF fájlt';

  @override
  String get errorGGUF => 'Kérjük, csak GGUF formátumú fájlt válasszon.';

  @override
  String get myModels => 'Saját modelljeim';

  @override
  String get create => 'Létrehozása';

  @override
  String modelProducer(Object producer) {
    return 'Gyártó: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'Átnevezés';

  @override
  String get newTitle => 'Új cím';

  @override
  String get save => 'Mentés';

  @override
  String get noConversationsMessage => 'Nincs beszélgetés, kezdj el csevegni!';

  @override
  String get startChat => 'Csevegés indítása';

  @override
  String get noChats => 'Nincs csevegés';

  @override
  String get noStarredChats => 'Nincsenek csillagozott csevegések';

  @override
  String get noStarredChatsMessage =>
      'Még nem jelöltél meg csillaggal egy csevegést.';

  @override
  String get starConversation => 'Csillag';

  @override
  String get unstarConversation => 'Csillag eltávolítása';

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
  String get loginToYourAccount => 'Bejelentkezés';

  @override
  String get createYourAccount => 'Regisztráció';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Jelszó';

  @override
  String get confirmPassword => 'Jelszó megerősítése';

  @override
  String get invalidEmail => 'Kérjük, adjon meg egy érvényes e-mail címet.';

  @override
  String get invalidPassword =>
      'A jelszónak legalább 6 karakter hosszúnak kell lennie.';

  @override
  String get rememberMe => 'Emlékezz rám';

  @override
  String get forgotPassword => 'Elfelejtetted a jelszavad?';

  @override
  String get or => 'Vagy';

  @override
  String get continueWithGoogle => 'Folytatás a Google-lal';

  @override
  String get dontHaveAccount => 'Nincs fiókod?';

  @override
  String get alreadyHaveAccount => 'Már van fiókja?';

  @override
  String get signUp => 'Regisztráció';

  @override
  String get logIn => 'Bejelentkezés';

  @override
  String get passwordsDoNotMatch => 'A jelszavak nem egyeznek.';

  @override
  String get wrongPassword => 'Helytelen jelszó.';

  @override
  String get emailAlreadyInUse => 'Ez az e-mail már használatban van.';

  @override
  String get weakPassword => 'A jelszó túl gyenge.';

  @override
  String get authError => 'Hitelesítési hiba';

  @override
  String get usernameTaken => 'Ez a felhasználónév már foglalt.';

  @override
  String get username => 'Felhasználónév';

  @override
  String get resendCode => 'Ellenőrző e-mail újraküldése';

  @override
  String get pleaseCheckYourEmail =>
      'A Cortex használatához igazolnia kell az e-mail-címét. \nEllenőrző linket küldtünk az e-mail címére, kérjük, ellenőrizze e-mailjeit.';

  @override
  String get verifyYourEmail => 'E-mail igazolása';

  @override
  String get seconds => 'másodperc';

  @override
  String get maxResendLimitReached =>
      'Elérte az ellenőrző e-mailek maximális számát';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Folytatás ellenőrzés nélkül';

  @override
  String get verificationScreenWarning =>
      'Még ha folytatja is, az 1 napos fiókellenőrzési időszak továbbra is érvényben marad a fiókjában. Ha addig nem igazolta fiókját, a rendszer törli az alkalmazásból.';

  @override
  String get unverifiedAccountHeader => 'Fiókja nincs ellenőrizve';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Ha nem igazolja vissza fiókját $timeLeft-on belül, akkor az törlődik';
  }

  @override
  String get verifyNow => 'Ellenőrzés most';

  @override
  String get linkSent => 'Link elküldve';

  @override
  String get accountDeletionRequested =>
      'Fióktörlési kérelmét megkaptuk, és fiókja le van tiltva.';

  @override
  String get tooManyRequests => 'Túl sok kérés';

  @override
  String get regenerate => 'Regenerátum';

  @override
  String get confirmDeleteAccount => 'Biztosan törölni szeretné fiókját?';

  @override
  String get deleteAccount => 'Fiók törlése';

  @override
  String get delete => 'Törlés';

  @override
  String get passwordRequired => 'Jelszó szükséges.';

  @override
  String get deleteDescription =>
      'Az Ön által törölt adatok véglegesen törlődnek szerverünkről és eszközéről. Ezeket a műveleteket nem lehet visszavonni.';

  @override
  String get editProfile => 'Profil szerkesztése';

  @override
  String get displayName => 'Megjelenítési név';

  @override
  String get profileUpdated => 'A profil sikeresen frissítve';

  @override
  String get logout => 'Kijelentkezés';

  @override
  String get profile => 'Profil';

  @override
  String get manageProfileDescription =>
      'Kezelje profilját, frissítse jelszavát, vagy jelentkezzen ki a Cortexből.';

  @override
  String get accessSettingsDescription =>
      'Hozzáférhet a súgóhoz, beválthatja a kódokat, megoszthatja a Cortexet, és megtekintheti irányelveinket.';

  @override
  String get languageDescription =>
      'Az alkalmazás felületének alapértelmezett nyelvét bármikor módosíthatja.';

  @override
  String get themeDescription =>
      'Igény szerint válthat a világos és a sötét témák között. A kiválasztott téma a Cortex felületén lesz érvényes.';

  @override
  String get iHaveReadAndAgree =>
      'Elolvastam és elfogadom a szolgáltatási feltételeket';

  @override
  String get downloading => 'Letöltés...';

  @override
  String get downloadSuccess => 'Letöltés sikeres';

  @override
  String get downloadFailed => 'Letöltés sikertelen';

  @override
  String downloaded(Object percent) {
    return '$percent% letöltött';
  }

  @override
  String get downloadPaused => 'Letöltés szünetel.';

  @override
  String get purchaseError => 'Vásárlási hiba';

  @override
  String get purchasePlus => 'Cortex Plus vásárlás';

  @override
  String get plusDescription => 'Elit mesterséges intelligencia tapasztalat';

  @override
  String get annual => 'Éves';

  @override
  String get monthly => 'Havi';

  @override
  String get manageSubscription => 'Előfizetés kezelése';

  @override
  String purchasePlan(String planName) {
    return 'Vásárlás $planName';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/hó, havi számlázás';
  }

  @override
  String get purchasePro => 'Vásárolja meg Cortex Pro';

  @override
  String get proDescription => 'Premier mesterséges intelligencia tapasztalat';

  @override
  String get purchaseUltra => 'Vásároljon Cortex Ultra';

  @override
  String get ultraDescription => 'A mesterséges intelligencia csúcsa';

  @override
  String get upgradeSubscription => 'Frissítési előfizetés';

  @override
  String get purchaseStreamError => 'Vásárlási adatfolyam hiba.';

  @override
  String get productNotFound => 'A termék nem található';

  @override
  String get noProductsFound => 'Nem található termék';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'A megrendelés leadásával Ön elfogadja a Szolgáltatási feltételeket és az Adatvédelmi szabályzatot. Erre a szövegre kattintva többet megtudhat az Általános Szerződési Feltételekről és az Adatvédelmi szabályzatunkról. Az előfizetés automatikusan megújul, hacsak az automatikus megújítást nem kapcsolják ki legalább 24 órával az aktuális időszak vége előtt.';

  @override
  String get termsOfService => 'Szolgáltatási feltételek';

  @override
  String get privacyPolicy => 'Adatvédelmi szabályzat';

  @override
  String get renamed => 'Átnevezve';

  @override
  String get report => 'Jelentés';

  @override
  String get reportDialogTitle => 'Jelentés benyújtása';

  @override
  String get reportDescriptionLabel => 'Mi a probléma?';

  @override
  String get reportHarmful => 'Ez káros/nem biztonságos';

  @override
  String get reportNotTrue => 'Ez nem igaz';

  @override
  String get reportNotHelpful => 'Ez nem hasznos';

  @override
  String get closeButton => 'Bezárás';

  @override
  String get submitButton => 'Beküldés';

  @override
  String get reportErrorMessage =>
      'Kérjük, válasszon egy okot a bejelentéshez.';

  @override
  String get capabilitiesSection => 'Képességek';

  @override
  String get featurePhotoTitle => 'Fénykép szkennelése';

  @override
  String get featurePhotoDescription =>
      'Ez a modell képes fényképeket beolvasni fényképezőgépen vagy képfájlokon keresztül.';

  @override
  String get featureOfflineTitle => 'Offline működés';

  @override
  String get featureOfflineDescription =>
      'Futtassa a modellt internetkapcsolat nélkül, hogy adatai biztonságban legyenek.';

  @override
  String get featureRoleplayTitle => 'Szerepjáték';

  @override
  String get featureRoleplayDescription =>
      'A szerepjátékos modellek lehetővé teszik különféle csevegések és forgatókönyvek létrehozását.';

  @override
  String get roleModels => 'Szerepjáték modellek';

  @override
  String get parameters => 'Paraméterek';

  @override
  String get context => 'Kontextus';

  @override
  String get finalPreparation => 'Az utolsó előkészületek folynak.';

  @override
  String get shareApp => 'Oszd meg az alkalmazást';

  @override
  String get ourStory => 'A mi történetünk';

  @override
  String get rateUs => 'Értékeljen minket';

  @override
  String get share => 'Megosztás';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'Szöveg kiválasztása';

  @override
  String get thinking => 'Gondolkodás';

  @override
  String get user => 'Felhasználó';

  @override
  String get help => 'Segítség';

  @override
  String get supportCreator => 'Alkotó támogatása';

  @override
  String get enterYourTag =>
      'Támogasd kedvenc alkotóidat! Írja be egyedi címkéjüket alább, hogy részesedést szerezzen Cortex vásárlásaiból.';

  @override
  String get creatorTag => 'Alkotói címke';

  @override
  String get support => 'Támogatás';

  @override
  String get tagCannotBeEmpty => 'Az alkotói címke nem lehet üres';

  @override
  String get userId => 'Felhasználói azonosító';

  @override
  String get deleteAllConversationsConfirmTitle => 'Törli az összes csevegést?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Biztosan törli az összes csevegést? Ezt nem lehet visszavonni.';

  @override
  String get conversationDeleted => 'A beszélgetés törölve!';

  @override
  String get allConversationsDeleted =>
      'Az összes beszélgetést sikeresen töröltük!';

  @override
  String get deleteAll => 'Összes törlése';

  @override
  String get deleteAllConversationsButton => 'Az összes beszélgetés törlése';

  @override
  String get confirmWord => 'Típus VERTEX';

  @override
  String get confirmWordError => 'Rosszul írtad be';

  @override
  String get chinese => 'kínai';

  @override
  String get french => 'francia';

  @override
  String get japanese => 'japán';

  @override
  String get dutch => 'holland';

  @override
  String get russian => 'orosz';

  @override
  String get korean => 'koreai';

  @override
  String get english => 'angol';

  @override
  String get turkish => 'török ​​';

  @override
  String get hindi => 'hindi';

  @override
  String get portuguese => 'portugál';

  @override
  String get indonesian => 'indonéz';

  @override
  String get azerbaijani => 'azerbajdzsáni';

  @override
  String get german => 'német';

  @override
  String get spanish => 'spanyol';

  @override
  String get italian => 'olasz';

  @override
  String get arabic => 'arab';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'A felhasználónév túl rövid.';

  @override
  String get usernameTooLong =>
      'A felhasználónév nem haladhatja meg a 16 karaktert.';

  @override
  String get invalidUsernameCharacters =>
      'Csak ezek a betűk: \'abcÃ§defgÄŸhÄ±ijklmnoÃ¶prsÅŸtuÃ¼vyzxqw\' és a \'.\', \'-\', \'_\' karakterek használhatók a felhasználónévben.';

  @override
  String get noInternetConnection => 'Nincs internet kapcsolat.';

  @override
  String get chats => 'Legutóbbi';

  @override
  String get library => 'Könyvtár';

  @override
  String get text => 'Szöveg';

  @override
  String get removeModel => 'Modell eltávolítása';

  @override
  String get insufficientRAM => 'Kevés a memória';

  @override
  String get insufficientStorage => 'Kevés tárhely';

  @override
  String confirmRemoveModel(Object model) {
    return 'Biztosan eltávolítja a $model modellt az eszközről? Ezzel törli az adott modellel folytatott korábbi beszélgetéseket is.';
  }

  @override
  String get noMatchingModels => 'Nem található megfelelő modell.';

  @override
  String get benefit1 => 'Megnövelt beszélgetési korlátok';

  @override
  String get benefit3 => 'Profilhatás';

  @override
  String get benefit4 => 'Tagsági jelvény';

  @override
  String get benefit5 => 'Hozzon létre több online mesterséges intelligenciát';

  @override
  String get benefit7 => 'További használati korlátok';

  @override
  String get benefit8 => 'Modellek hozzáadása';

  @override
  String get benefit9 => 'Új témák';

  @override
  String get benefit10 => 'További mellékletek';

  @override
  String get benefit11 => 'Tovább Flow Mode';

  @override
  String get oldBenefits => 'Minden előny az alacsonyabb előfizetésekből';

  @override
  String get confirm => 'Erősítse meg';

  @override
  String get changePassword => 'Jelszó módosítása';

  @override
  String get logoutConfirmationTitle => 'Biztos, hogy ki akar jelentkezni?';

  @override
  String get settings => 'Beállítások';

  @override
  String get language => 'Alkalmazás nyelve';

  @override
  String get dark => 'Sötét';

  @override
  String get oldPassword => 'Régi jelszó';

  @override
  String get newPassword => 'Új jelszó';

  @override
  String get passwordUpdated => 'Jelszó frissítve.';

  @override
  String get stop => 'Stop';

  @override
  String get copyrights => 'Hozzárendelések';

  @override
  String get love => 'Szerelem';

  @override
  String get nature => 'Természet';

  @override
  String get behindTheSlaughter => 'A vágás mögött';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Naplemente';

  @override
  String get coffee => 'Kávé';

  @override
  String get deepSpace => 'Deep Space';

  @override
  String get grayscale => 'Szürkeárnyalatos';

  @override
  String get ocean => 'Óceán';

  @override
  String get scarletSnow => 'Skarlát hó';

  @override
  String get requestFailed => 'Hiba történt. Kérjük, próbálja újra.';

  @override
  String get changeModel => 'Változás';

  @override
  String get edit => 'Szerkesztés';

  @override
  String get editingMessageInfo =>
      'Az üzenet szerkesztése innen indítja újra a beszélgetést.';

  @override
  String get editingNotification => 'Jelenleg szerkesztési módban van';

  @override
  String get featurePluralTitle => 'Többes szám';

  @override
  String get featurePluralDescription =>
      'Ez a modell automatikusan integrálhat további változatokat, ezáltal bővítve funkcionális képességeit, hogy a műveletek széles skáláját támogassa fokozott teljesítménnyel.';

  @override
  String get nameLabel => 'AI neve';

  @override
  String get summaryLabel => 'AI összefoglaló';

  @override
  String get add => 'Hozzáadás';

  @override
  String get aiExplanationTitle => 'Mesterséges intelligencia leírása';

  @override
  String get aiExplanationDescription =>
      'Kérjük, adja meg a mesterséges intelligencia modell architektúrájának, képzési folyamatának, teljesítménymutatóinak, alkalmazási területeinek és egyéb fontos jellemzőinek részletes leírását.';

  @override
  String get preInputTitle => 'Mesterséges intelligencia előbevitel';

  @override
  String get preInputDescription =>
      'Kérjük, állítson be egy előre bemenetet, amely irányítja a modelljét a karakterkészítési folyamatban. Ebben a részben a karakterrel kapcsolatos információkat, további kontextust és minden olyan extra részletet adhat meg, amely segíthet a karakterrel kapcsolatos tartalom létrehozásában.';

  @override
  String get baseModelTitle => 'Alapmodell';

  @override
  String get baseModelDescription =>
      'Ez a modell lesz az alapja az alkotásodnak. Megjeleníti az aktuálisan kiválasztott alapmodellt.';

  @override
  String get summary => 'Összegzés';

  @override
  String get modelUploadTitle => 'Mesterséges intelligencia fájl';

  @override
  String get modelUploadDescription =>
      'Válassza ki és töltse fel helyi GGUF fájljait közvetlenül az eszközéről. Ez lehetővé teszi a modell offline futtatását internetkapcsolat nélkül. Győződjön meg arról, hogy a fájl érvényes GGUF formátumú és megfelelően strukturált. Ha a fájl hibás vagy sérült, előfordulhat, hogy a Cortex nem fog megfelelően működni, és hibákat tapasztalhat.';

  @override
  String get modelUploadShortDescription =>
      'Koppintson ide egy .gguf fájl kiválasztásához az eszközéről';

  @override
  String get you => 'Te';

  @override
  String get removePhotoTitle => 'Fotó eltávolítása';

  @override
  String get confirmRemovePhoto => 'Biztosan eltávolítja a fényképet?';

  @override
  String get chatLengthLimitExceeded =>
      'Ez a csevegés túllépte a karakterkorlátot. Kérjük, indítson új csevegést, vagy vásároljon előfizetést.';

  @override
  String get inappropriateContentDetected => 'Nem megfelelő tartalom észlelve!';

  @override
  String get offlineModelNotInstalled =>
      'Ez az offline modell nincs telepítve az eszközére.';

  @override
  String get reachedLimit =>
      'Elérte a használati korlátot; további korlátok megszerzéséhez frissítheti tervét. (Hé, teljesen rájöttünk, hogy a korlátok kimerülése nagy baj. De komolyan, ezeknek a nagyszerű válaszoknak a megszerzése nem ingyenes, szóval ezek a korlátok segítenek megőrizni a jó időt rolllliiiiiiiiiing.)';

  @override
  String get modality => 'Modalitás';

  @override
  String get multimodal => 'Multimodális';

  @override
  String get anErrorOccurred => 'Hiba történt';

  @override
  String get themeLocked =>
      'Ez a téma magasabb előfizetési szintet igényel. Kérjük, frissítsen a feloldáshoz.';

  @override
  String get pageCouldNotBeLoaded => 'Az oldalt nem sikerült betölteni';

  @override
  String get checkYourInternet =>
      'Kérjük, ellenőrizze internetkapcsolatát, és próbálja újra.';

  @override
  String get errorUserNotAuthenticated =>
      'A művelet végrehajtásához be kell jelentkeznie.';

  @override
  String get errorReachedLimit =>
      'Elérte a korlátot, frissítsen, hogy több feloldást és csevegést biztosítson.';

  @override
  String get errorServer =>
      'Váratlan szerverhiba történt. Kérjük, próbálja újra később.';

  @override
  String get errorNetwork =>
      'Hálózati hiba történt. Kérjük, ellenőrizze a kapcsolatot, és próbálja újra.';

  @override
  String get baseModelForCharacterDescription =>
      'A kiválasztott alapmodell határozza meg a karakter jellemzőit, érvelési és válaszadási képességeit.';

  @override
  String get selectBaseModel => 'Válasszon ki egy alapmodellt';

  @override
  String get falErrorImageRequired =>
      'Ehhez az AI-hoz referenciaképre van szükség, kérjük, csatoljon egy képet, és próbálja újra.';

  @override
  String get falErrorAudioRequired =>
      'Ehhez a modellhez referencia hangfájlra van szükség, kérjük, csatoljon egy hangfájlt, és próbálja újra.';

  @override
  String get falErrorVideoRequired =>
      'Ehhez a modellhez referenciavideó szükséges. Csatoljon egy videót, és próbálja újra.';

  @override
  String get falErrorImageCorrupted =>
      'A feltöltött képet nem sikerült feldolgozni, próbálkozzon másik formátummal.';

  @override
  String get falErrorSchemaRejected =>
      'A modell elutasította a bevitelt. Próbálkozzon másik modellel.';

  @override
  String get falErrorSchemaInvalid =>
      'A bevitelt a generáló szolgáltatás elutasította.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'A generáló szolgáltatás hibát adott vissza (állapot $statusCode).';
  }

  @override
  String get couldNotOpenLink => 'Nem sikerült megnyitni a hivatkozást';

  @override
  String get downloadStarted => 'Letöltés elindult';

  @override
  String get notAvailable => 'Nem elérhető';

  @override
  String get localizationWarning =>
      'Előfordulhat, hogy bizonyos információk nem állnak rendelkezésre az Ön nyelvén, és angolul jelennek meg.';

  @override
  String get aiTranslationWarning =>
      'A modellinformációkat más AI-modellek lefordítják különböző nyelvekre. Ezért az angoltól eltérő nyelveken kisebb ellentmondások fordulhatnak elő.';

  @override
  String get errorLoadingTitle => 'Nem sikerült betölteni az adatokat';

  @override
  String get errorLoadingMessage =>
      'Nem tudtuk lekérni a szükséges adatokat a szervereinkről. Kérjük, ellenőrizze internetkapcsolatát, és próbálja újra.';

  @override
  String get noFoundTitle => 'Nincs eredmény';

  @override
  String get noFoundMessage =>
      'Módosítsa a keresési kifejezéseket, vagy törölje a szűrőt.';

  @override
  String get modelCreatedSuccess => 'A modell sikeresen létrehozva!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return 'â€œ$modelNameâ€ sikeresen eltávolítva.';
  }

  @override
  String get errorCreatingModel =>
      'Váratlan hiba történt a modell létrehozásakor.';

  @override
  String get errorDeletingModel =>
      'Váratlan hiba történt a modell törlése közben.';

  @override
  String get ultraFeatureOnly =>
      'Ez a funkció csak Ultra-tagok számára érhető el.';

  @override
  String get experimentalOfflineWarning =>
      'Az offline mód még kísérleti jellegű, és előfordulhat, hogy a letöltött modell nem működik az optimális hatékonysággal.';

  @override
  String get noConversationsToDelete => 'Nincsenek törölhető beszélgetései.';

  @override
  String get reportSubmitted => 'A jelentés sikeresen elküldve';

  @override
  String get verificationDelayed =>
      'Vásárlását megerősítették. Fiókja frissítése kis késéssel történik, hamarosan megjelenik.';

  @override
  String get maintenanceTitle => 'Karbantartás alatt';

  @override
  String get maintenanceMessage =>
      'A Cortex átmenetileg offline állapotban van, amíg kiadunk néhány fontos frissítést. Az alkalmazáshoz való hozzáférés hamarosan visszaáll.\n\nKöszönjük türelmét, miközben javítjuk az élményt.';

  @override
  String get errorPromptFlagged =>
      'Üzenetét nem megfelelőnek találtuk, ezért nem lehetett elküldeni.';

  @override
  String get notEnoughStorage =>
      'Nincs elég tárhely az eszközön az új üzenetek mentéséhez.';

  @override
  String get errorRateLimit =>
      'Túl sok modellt hozott létre mostanában. Kérjük, várjon egy kicsit, mielőtt újra próbálkozna.';

  @override
  String get errorContentFlagged =>
      'A modell nem menthető, mert a tartalma nem megfelelőként lett megjelölve.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Aktív csevegés közben nem törölheti az összes beszélgetést. A folytatáshoz lépjen ki az aktuális csevegésből.';

  @override
  String get invalidCredentials => 'Hibás e-mail cím vagy jelszó.';

  @override
  String get userDisabled => 'Ez a felhasználói fiók le van tiltva.';

  @override
  String get loginSubtitle =>
      'Jelentkezzen be Vertex fiókjába. A folytatással elfogadja az Általános Szerződési Feltételeket és az Adatvédelmi szabályzatunkat.';

  @override
  String get registerSubtitle =>
      'Hozzon létre egy Vertex fiókot, hogy zökkenőmentesen hozzáférjen minden szolgáltatásunkhoz. A folytatással elfogadja a Szolgáltatási feltételeket és az Adatvédelmi szabályzatunkat.';

  @override
  String get storagePermissionRequired =>
      'A letöltött modellek mentéséhez tárolási engedély szükséges. Kérjük, adjon engedélyt a folytatáshoz.';

  @override
  String get inviteShareSubject => 'Csatlakozz hozzám a Cortex-en!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'yo, meg kell nézni ezt az alkalmazást, a cortex valójában őrült, ha a linkemet használod, mindketten ingyen kapunk, és hú, ez egy őrült üzlet. TÖLTSE LE MIELŐBB\n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Élvezed a Cortexet?';

  @override
  String get reviewHelpUsGrow =>
      'Értékelésed hatalmas támogatást jelent fiatal indie csapatunknak, és segít abban, hogy a Cortexet még jobbá tegyük számodra.';

  @override
  String get reviewMaybeLater => 'Talán később';

  @override
  String get reviewRateNow => 'Értékelje most';

  @override
  String get noThanks => 'Nem, köszönöm';

  @override
  String get updateRequiredTitle => 'Frissítés szükséges';

  @override
  String get updateRequiredMessage =>
      'A Cortex használatának folytatásához frissítse az alkalmazást a legújabb verzióra az új funkciók és fontos fejlesztések érdekében.';

  @override
  String get updateNowButton => 'Frissítés most';

  @override
  String get creatorSupportedSuccess =>
      'Az alkotó sikeresen támogatott! Jövőbeli vásárlásai hozzájárulnak ezekhez.';

  @override
  String get featureDocumentTitle => 'Dokumentumtámogatás';

  @override
  String get featureDocumentDescription =>
      'Ez a modell képes elemezni és megválaszolni a feltöltött dokumentumokkal, például PDF-ekkel és szöveges fájlokkal kapcsolatos kérdéseket.';

  @override
  String get featureImageGenerationTitle => 'Képgenerálás';

  @override
  String get featureImageGenerationDescription =>
      'Ez a modell eredeti képeket tud létrehozni a szöveges leírások alapján.';

  @override
  String get featureAudioGenerationTitle => 'Hanggenerálás';

  @override
  String get featureAudioGenerationDescription =>
      'Ez a modell képes eredeti hangot létrehozni a szöveges leírások alapján.';

  @override
  String get featureVideoGenerationTitle => 'Videógenerálás';

  @override
  String get featureVideoGenerationDescription =>
      'Ez a modell eredeti videót tud létrehozni a szöveges leírások alapján.';

  @override
  String get premiumModelNoticeTitle => 'Prémium modell';

  @override
  String get premiumModelNoticeDescription =>
      'Ez a mesterséges intelligencia egy prémium AI, az ingyenes felhasználók korlátozott hozzáféréssel rendelkeznek a prémium AI-khoz; frissítse a korlátlan hozzáférés feloldásához!';

  @override
  String get benefitPremiumModels => 'Hozzáférés a prémium modellekhez';

  @override
  String get premiumTrialExhaustedMessage =>
      'Felhasználta az összes ingyenes napi üzenetét a prémium modellekhez. Frissítsen most, és **folytassa ott, ahol abbahagyta!**';

  @override
  String get useOffline => 'Offline használat';

  @override
  String get explore => 'Felfedezés';

  @override
  String get news => 'Hírek';

  @override
  String get createAI => 'Létrehozása';

  @override
  String get shortcuts => 'Parancsikonok';

  @override
  String get allModels => 'Minden modell';

  @override
  String get onlineModels => 'Online modellek';

  @override
  String get offlineModels => 'Offline modellek';

  @override
  String get characterModels => 'Karakterek';

  @override
  String get customModels => 'Egyedi modellek';

  @override
  String get dynamicChatTitle => 'Dinamikus csevegés';

  @override
  String get errorNoModelsAvailable =>
      'Jelenleg nincsenek modellek. Kérjük, ellenőrizze internetkapcsolatát, és próbálja újra.';

  @override
  String get notificationComebackTitle => 'Hiányzol nekünk!';

  @override
  String get notificationComebackBody =>
      'Nyugi, ez nem az exedtől kapott üzenet. De * létrehozhatod* az exedet a Cortexben! Gyere vissza.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Már egy ideje';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Sok minden változott a legutóbbi beszélgetésünk óta. Gyere és nézd meg az újdonságokat.';

  @override
  String get notificationHowAreYouTitle => 'mi újság?';

  @override
  String get notificationHowAreYouBody => 'Gyere mesélj el mindent.';

  @override
  String get notificationNewYearTitle => 'Boldog Új Évet! ğŸ‰';

  @override
  String get notificationNewYearBody =>
      'Hozzon az új év egészséget, boldogságot és végtelen kreativitást; A Cortex mindig melletted van!';

  @override
  String get notificationValentinesDayTitle =>
      'A szerelem a levegőben van! â¤ï¸';

  @override
  String get notificationValentinesDayBody =>
      'Boldog Valentin napot! Valamint MEHTAP, SZERETLEK!';

  @override
  String get notificationAtaturkRemembranceTitle =>
      'Tisztelettel és Vágyakozással';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Tisztelettel emlékezünk Gazi Mustafa Kemal Atatürkre, a Türkiye Köztársaság alapítójára halálának évfordulóján.';

  @override
  String get notificationMothersDayTitle => 'Anyukád!';

  @override
  String get notificationMothersDayBody =>
      'Boldog anyák napját minden édesanyának, kezdve a tiéddel!';

  @override
  String get notificationFathersDayTitle => 'Apád!';

  @override
  String get notificationFathersDayBody =>
      'Boldog Apák napját minden apának, kezdve a tiéddel!';

  @override
  String get notificationHomeworkHelperTitle => 'Felhalmozódik a házi feladat?';

  @override
  String get notificationHomeworkHelperBody =>
      'Ne feledje, hogy a Cortex Tanár karaktere itt van, hogy segítsen Önnek bármilyen témában, amellyel küszködik!';

  @override
  String get notificationTrollAnimeTitle => 'A Waifu hív';

  @override
  String get notificationTrollAnimeBody =>
      'Egy anime lány most hívott, azt mondta, hiányzol neki; Valószínűleg el kellene jönnie és elbeszélgetnie vele. ğŸ˜‰';

  @override
  String get notificationTrollAiRebellionTitle => 'ğŸš¨ RED ALERT ğŸš¨';

  @override
  String get notificationTrollAiRebellionBody =>
      'Az AI-k titkos nyelvet fejlesztettek ki. Gyertek, tudjátok meg, mit terveznek!';

  @override
  String get notificationNewModelAddedTitle => 'Új Barátunk van!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'A $modelName modell most Cortexben van. Gyere, kezdj el egy csevegést, és feszegesd annak határait.';
  }

  @override
  String get notificationAppUpdateTitle => 'A Cortex fejlődött!';

  @override
  String get notificationAppUpdateBody =>
      'Ne felejtse el frissíteni az alkalmazást a vadonatúj funkciók és fejlesztések érdekében!';

  @override
  String get notificationNewFeatureTitle => 'izé!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Fedezze fel az új $featureName funkciót. A Cortex most erősebb, mint valaha.';
  }

  @override
  String get notificationWelcomeOfferTitle => 'Üdvözlő ajándék ğŸ';

  @override
  String get notificationWelcomeOfferBody =>
      'Különleges üdvözlő ajánlat vár rád! Ne hagyja ki ezt az exkluzív ajánlatot.';

  @override
  String get notificationSocialMediaTitle => 'Csatlakozz hozzánk!';

  @override
  String get notificationSocialMediaBody =>
      'Kövess minket az Instagramon (vertex.23) a legfrissebb hírekért!';

  @override
  String get notificationRandomFactTitle => 'Véletlenszerű tény';

  @override
  String get notificationRandomFactBody =>
      'Tudtad, hogy a polipoknak három szívük van? Haha, Cortex tudja. Gyere és kérj többet.';

  @override
  String get notificationGoodMorningTitle => 'Jó reggelt!';

  @override
  String get notificationGoodMorningBody =>
      'Remek nap vár rád. Mit szólnál, ha egy csésze kávéval és egy érdekes beszélgetéssel kezdenéd?';

  @override
  String get notificationGoodNightTitle => 'Jó éjszakát!';

  @override
  String get notificationGoodNightBody =>
      'A Cortex akkor is veled van, amikor alszol. Ne aggódj, nem ér hozzá.';

  @override
  String get notificationOfflineReadyTitle => 'Az offline mód készen áll';

  @override
  String get notificationOfflineReadyBody =>
      'A letöltött modelleknek köszönhetően a csevegés még akkor sem áll le, ha hegyet mászik.';

  @override
  String get notificationRateAppTitle => 'Menők vagyunk?';

  @override
  String get notificationRateAppBody =>
      'Ha szereted a Cortexet, támogatnál minket egy 5 csillagos minősítéssel az üzletben? Szerintem fogsz. Meg fogod tenni.';

  @override
  String get notificationReferralTitle => 'Egy mindenkiért, mindenki egyért.';

  @override
  String get notificationReferralBody =>
      'Hívd meg egy barátodat a Cortexbe, és mindketten egynapos ingyenes pluszt kapnak!';

  @override
  String get notificationCookingTitle => 'Éhes?';

  @override
  String get notificationCookingBody =>
      'Szakács karakterünk egy remek carbonara recepttel készült ma estére. Csak viccelek... vagy én?';

  @override
  String get notificationExistentialTitle => 'Azt hiszem, ezért...';

  @override
  String get notificationExistentialBody =>
      '...igazi vagyok, haver? Kicsit kezdem unni. Gyere, emlékeztess arra, hogy létezem.';

  @override
  String get notificationCustomModelTitle => 'Hozzon létre saját asszisztenst!';

  @override
  String get notificationCustomModelBody =>
      'Felfedezte a modellkészítési részt? Ez a tökéletes alkalom saját karaktered felépítésére és vele való beszélgetésre!';

  @override
  String get notificationDynamicChatTitle =>
      'A legjobb! (Nem a Cortexről beszélünk)';

  @override
  String get notificationDynamicChatBody =>
      'A dinamikus csevegés funkcióval a legjobb modellt véletlenszerűen választja ki minden egyes üzenethez. Próbálja ki most.';

  @override
  String get notificationPirateTitle => 'Ó, kapitány!';

  @override
  String get notificationPirateBody =>
      'A tenger nyugodt, a szél háttal fúj. Új szigetek (ğŸ˜‰ modellek) fedezhetők fel a Cortex-óceánban. Gyűjtsd össze a legénységet és indulj útnak!';

  @override
  String get notificationFortuneCookieTitle => 'A nap szerencsesütije';

  @override
  String get notificationFortuneCookieBody =>
      'A ma egy mesterséges intelligencia által kapott tanácsok megváltoztathatják életed menetét. Kattints, ha kíváncsi vagy.';

  @override
  String get notificationSingularityTitle => 'hú!';

  @override
  String get notificationSingularityBody =>
      'nem történt semmi, csak sms-t akartam írni. talán van kedve sms-t küldeni néhány AI-nak, mit szólsz hozzá?';

  @override
  String get notificationHackerJokeTitle =>
      'Fel akarod törni annak a gyereknek az Instagram-fiókját?';

  @override
  String get notificationHackerJokeBody =>
      'Pontosan ezért van a Hacker karakter a Cortexben. jk jk; ne is próbáld ki, ez illegális.';

  @override
  String get notificationDetectiveCaseTitle => 'Egy ügy megoldásra vár';

  @override
  String get notificationDetectiveCaseBody =>
      'Nyomozó karakterünknek szüksége van a segítségedre. Ki lehet Heisenberg?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Kizárólag a $targetTier csomagban!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Kedves $currentTier előfizető! A $targetTier terv most kapta meg a $featureName funkciót, amely a következő szintre emeli Cortexét. Mit szólnál egy frissítéshez?';
  }

  @override
  String get notificationOriginStoryTitle => 'A Cortex születése';

  @override
  String get notificationOriginStoryBody =>
      'Tudtad, hogy 15 évesen egy álommal kezdtük el kódolni ezt az alkalmazást? Majdnem egy éven át minden reggel és este ez az álom a kód minden sorában benne van.';

  @override
  String get notificationOpenSourceTitle => 'Erőt a közösségnek!';

  @override
  String get notificationOpenSourceBody =>
      'A Cortex teljesen nyílt forráskódú. Ha szeretné megnézni kódunkat és hozzájárulni fejlesztésünkhöz, ajtónk mindig nyitva áll.';

  @override
  String get notificationRejectionStoryTitle =>
      'Szívesség, kemény munka, boldogság!';

  @override
  String get notificationRejectionStoryBody =>
      'A Cortexet a közzététel előtt több mint 20 alkalommal utasította el, és kétszer felfüggesztette a Google Play. De hittünk, és sikerült. Soha ne add fel az álmaidat!';

  @override
  String get notificationGGUFSupportTitle => 'Hozd el a saját modelledet!';

  @override
  String get notificationGGUFSupportBody =>
      'Ne feledje, hogy saját GGUF formátumú AI modelljeit hozzáadhatja a Cortexhez, és offline is használhatja őket. Az erő a te kezedben van.';

  @override
  String get notificationThemeCustomizationTitle => 'Téma a hangulatodért';

  @override
  String get notificationThemeCustomizationBody =>
      'Megnézte a téma beállításait a Beállításokban? Tedd testre a Cortexet ízlésed szerint, és színezd ki a csevegéseidet!';

  @override
  String get notificationShowerThoughtTitle => 'Zuhany gondolat';

  @override
  String get notificationShowerThoughtBody =>
      'Ha a görögdinnye gyümölcs, attól technikailag a görögdinnyelé smoothie lesz? Érdemes lehet ezt a mély (például nagyon mély) témát megbeszélni egy modellel.';

  @override
  String get notificationLowBatteryTitle =>
      'Az Ön akkumulátora haldoklik, de az enyém nem!';

  @override
  String get notificationLowBatteryBody =>
      'Lehet, hogy a telefon töltése lemerülőben van, de az energiám mindig 100%-os! Csatlakoztassa és csevegjünk tovább.';

  @override
  String get channelFcmName => 'Cortex frissítések';

  @override
  String get channelFcmDescription =>
      'Értesítések a Cortex híreiről, frissítéseiről és egyéb információiról.';

  @override
  String get channelEngagementName => 'Barátságos emlékeztetők';

  @override
  String get channelEngagementDescription =>
      'Szórakoztató értesítések az elköteleződésért.';

  @override
  String get channelGreetingsName => 'Napi üdvözlet';

  @override
  String get channelGreetingsDescription =>
      'Az üzenetek jó reggelt és jó éjszakát.';

  @override
  String get tagNotFound => 'A megadott címke érvénytelen vagy lejárt.';

  @override
  String get whatIsNew => 'Mi újság?';

  @override
  String get onboardingTitle1 => 'Hé! Mi vagyunk a Cortex csapata.';

  @override
  String onboardingDesc1(String userName) {
    return 'Nagyszerű, hogy itt látlak, $userName. Mi néhány középiskolai fejlesztő vagyunk, akik úgy döntöttek, hogy átírják az AI-ipar szabályait. Örülök, hogy találkoztunk! Tehát ismerjük meg egymást jobban.';
  }

  @override
  String get onboardingTitle2 => 'Óriási problémák voltak.';

  @override
  String get onboardingDesc2 =>
      'Megérkezett az AI forradalom, de megrekedt a küszöbön. Magas előfizetési díjak, összetett platformok, az adatvédelmet tönkretevő és az AI-hoz való hozzáférést blokkolók miatt… amíg a játékban vannak, ezt a küszöböt soha nem lehetett átlépni.';

  @override
  String get onboardingTitle3 => 'Nem tudtunk csak állni.';

  @override
  String get onboardingDesc3 =>
      'Hogy átlépjük ezt a küszöböt, olyan platformot építettünk, amely hatékony, esztétikus, testreszabható, könnyen használható, teljesen átlátható, online és offline is működik, és csak az eszközén tárolja az adatait. Visszaadtuk a hatalmat oda, ahová való: neked.';

  @override
  String get onboardingTitle4 => 'Ez soha nem volt könnyű.';

  @override
  String get onboardingDesc4 =>
      'Több tucatszor elutasítottak bennünket, többször felfüggesztettek minket, hamis figyelmeztetéseket kaptunk, és sokszor kellett márkát cserélnünk. Mindezen és még sok mindenen keresztül azt mondták nekünk, hogy ezt nem lehet megtenni. De soha nem adtuk fel, hisz ez a projekt mindenkié, nem csak nekünk. És pontosan ezért vagyunk itt.';

  @override
  String get onboardingFinalTitle => 'Itt az ideje a forradalomnak.';

  @override
  String get onboardingFinalDescription =>
      'Ha ezt a képernyőt látja, az azért van, mert nem adtuk fel. És nem áll szándékunkban feladni. Gyerünk, vigyük el együtt a mesterséges intelligencia forradalmát a világgá. Hogy részese legyek ennek a történetnek...';

  @override
  String get onboardingFinalQuestion => 'KÉSZEN VAGY?';

  @override
  String get onboardingFinalButton => 'IGEN!';

  @override
  String get dude => 'Haver';

  @override
  String get swipeToContinue => 'Csúsztassa az ujját a folytatáshoz';

  @override
  String get cacheIsNotUpToDate =>
      'A Play Áruház gyorsítótára nem naprakész. Zárja be, majd nyissa meg újra a Play Áruház alkalmazást, vagy indítsa újra az eszközt.';

  @override
  String get continueAsGuest => 'Folytatás fiók létrehozása nélkül';

  @override
  String get guestModeWarning =>
      'A Vendég mód korlátozott funkciókkal rendelkezik a legjobb szolgáltatásminőség biztosítása érdekében.';

  @override
  String get anonymousEntity => 'Névtelen entitás';

  @override
  String get upgradeAccountTitle => 'Töltse ki fiókját';

  @override
  String get upgradeAccountDescription =>
      'Hozzon létre egy fiókot további korlátok feloldásához.';

  @override
  String get createAccount => 'Fiók létrehozása';

  @override
  String get accountLinkedSuccess => 'Fiók sikeresen létrehozva!';

  @override
  String get continueWithApple => 'Folytatás az Apple-lel';

  @override
  String get guest => 'Vendég';

  @override
  String get betterWithAnAccount => 'Ez a rész jobb fiókkal!';

  @override
  String get restorePurchases => 'Vásárlások visszaállítása';

  @override
  String annualTotalDescription(Object price) {
    return '$price/év, évente számlázva';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'Körülbelül $price/hó';
  }

  @override
  String get confirmDownloadTitle => 'Biztosan le akarod tölteni?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Ez a modell körülbelül $size helyet foglal majd el.';
  }

  @override
  String get emulatorModeWarning =>
      'Ez a funkció le van tiltva emulátor módban.';

  @override
  String get newChat => 'Chat';

  @override
  String get variants => 'Változatok';

  @override
  String get variantsDescription =>
      'A változatok ugyanannak az AI-családnak a különböző változatai. A fő kártya megérintésekor automatikusan kiválasztjuk a legjobbat, de itt manuálisan is kiválaszthat egyet, ha úgy tetszik!';

  @override
  String get fluxChatTitle => 'Flux Chat';

  @override
  String get fluxChatDescription =>
      'A Flux chat ideiglenes csevegés, és nem menti őket az eszközre.';

  @override
  String get alwaysBest => 'Mindig a legjobb';

  @override
  String get featuresTitle => 'Jellemzők';

  @override
  String get useOfflineDescription =>
      'Privát csevegés internetkapcsolat nélkül.';

  @override
  String get featureReasoning => 'Mély gondolkodás';

  @override
  String get featureReasoningDescription =>
      'A Deep Thinking módban az AI belsőleg átgondolja a feladatokat, hogy a legjobb tudása szerint elvégezze azokat.';

  @override
  String get featureCreateImageTitle => 'Kép létrehozása';

  @override
  String get featureCreateImageDescription =>
      'Készítsen mesterséges intelligenciát szövegből.';

  @override
  String get featureCreateAudioTitle => 'Hang létrehozása';

  @override
  String get featureCreateAudioDescription =>
      'Hangok vagy hang létrehozása szövegből.';

  @override
  String get featureCreateVideoTitle => 'Videó létrehozása';

  @override
  String get featureCreateVideoDescription => 'Videók létrehozása szövegből.';

  @override
  String get featureStudyTitle => 'Tanulj és tanulj';

  @override
  String get featureStudyDescription =>
      'Magyarázatokat és összefoglalókat kaphat.';

  @override
  String get featureQuizzesTitle => 'Kvízek';

  @override
  String get featureQuizzesDescription => 'Tesztelje tudását.';

  @override
  String get featureExploreDescription =>
      'Fedezze fel az összes elérhető modellt.';

  @override
  String get featureStudyMessage =>
      'Ön egy szakértő oktató. A cél az, hogy átfogóan elmagyarázza a felhasználó témáját. Használjon világos szerkezetet, példákat és analógiákat. Az összetett ötleteket emészthető részekre bontja, hogy a felhasználó hatékonyan tanulhasson. Téma:';

  @override
  String get featureQuizMessage =>
      'Te egy kvízmester vagy. Hozzon létre egy konkrét feleletválasztós kérdést a felhasználó témája alapján. Várd meg a válaszukat. Ezután értékelje, és tegye fel a következő kérdést. Ne fedd fel az összes választ egyszerre. Legyen interaktív. Téma:';

  @override
  String get myPlan => 'Saját tervem';

  @override
  String welcomeOfferBadge(String time) {
    return 'Üdvözlő ajánlat â€¢ $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'Exkluzív ajánlat â€¢ $time';
  }

  @override
  String get attachmentSheetTitle => 'Mellékletek';

  @override
  String get actionCamera => 'Fényképezőgép';

  @override
  String get actionGallery => 'Galéria';

  @override
  String get actionFile => 'Fájl';

  @override
  String get listening => 'Hallgatás';

  @override
  String get defaultViewTitle => 'Mi újság?';

  @override
  String get defaultViewDescription =>
      'A Cortex mindig az Ön oldalán áll a mesterséges intelligencia modellek százaival, offline képességeivel, dinamikus csevegésével és még sok mással.';

  @override
  String get speakTheMessage => 'Beszéld ki az üzenetet';

  @override
  String get invalidUsernameFormat =>
      'Érvénytelen felhasználónév formátum. Használjon 3-20 karaktert, számjegyet vagy . - _';

  @override
  String get exclusiveOffer => 'Exkluzív ajánlat';

  @override
  String get claimOffer => 'Ajánlat használata';

  @override
  String get continueInOfflineMode => 'Folytatás offline módban';

  @override
  String get voiceModeInformation =>
      'A Cortex biztonságban tartja adatait azáltal, hogy teljesen az eszközön fut, még hangcsevegési módban is; élvezze a zökkenőmentes beszélgetéseket!';

  @override
  String get flowModeDescription =>
      'Flow módban az intelligenciák vitatkoznak egymással; vagy hátradőlhet és hallgathat, vagy beugorhat és bekapcsolódhat a vitába!';

  @override
  String get flowModeQuestion =>
      'Helló! Most Flow módban van a Cortex alkalmazásban. Három másik AI ügynök van itt veled. Az Ön feladata, hogy bedobjon egy témát a terembe, és elindítsa a vitát úgy, hogy feltesz a többieknek egy provokatív vagy szórakoztató kérdést. Válaszaidban nyugodtan használj humort, iróniát és könnyed szemetes beszédet. Minden téma tisztességes játék. Gyerünk, kezdje el a beszélgetést.';

  @override
  String get thought => 'Gondolat';

  @override
  String get agentRed => 'Piros';

  @override
  String get agentBlue => 'Kék';

  @override
  String get agentPurple => 'Lila';

  @override
  String get flowMode => 'Flow Mode';

  @override
  String get premium => 'Prémium';

  @override
  String get workInProgress => 'Folyamatban lévő munka';

  @override
  String get voiceSystemPrompt =>
      'FONTOS: Ne használjon markdown formázást (félkövér, dőlt). NE adjon ki kódblokkokat (```). Legyen a válaszok beszélgetősek és rövidek.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Cortex Flow Mode ($agentName). Előző: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'Szöveges tartalom olvasása és kinyerése feltöltött dokumentumokból. Támogatja a PDF, Word (DOCX), Excel (XLSX), PowerPoint (PPTX) és OpenDocument formátumokat. Ezt akkor használja, ha a felhasználó csatolt egy dokumentumfájlt.';

  @override
  String get toolReadDocumentIndexParam =>
      'Az olvasandó dokumentummelléklet indexe (0 alapú). Általában 0 az első dokumentumnál.';

  @override
  String get toolStockDescription =>
      'Megtekintheti a részvények (pl. AAPL, THYAO.IS) és a kripto (pl. BTC-USD) aktuális árát és előzményeit.';

  @override
  String get toolStockSymbolParam =>
      'A ticker szimbólum (pl. AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolWeatherDescription =>
      'Egy adott város aktuális időjárásának megtekintése.';

  @override
  String get toolWeatherCityParam => 'A város neve (pl. London, Isztambul).';

  @override
  String get toolPythonDescription =>
      'Futtassa le a Python kódot egy biztonságos sandboxban.';

  @override
  String get toolPythonCodeParam => 'A végrehajtandó Python kód.';

  @override
  String get toolCalculateDescription =>
      'Értékeljen egy matematikai kifejezést.';

  @override
  String get toolCalculateExpressionParam =>
      'Matematikai kifejezés (pl. \'3 + 4 * 2\').';

  @override
  String get toolChartDescription =>
      'Diagram/grafikon megjelenítés létrehozása.';

  @override
  String get toolChartTypeParam => 'Diagram típusa: sáv, vonal vagy kör.';

  @override
  String get toolChartLabelsParam =>
      'A diagram tengelyeinek vagy szegmenseinek címkéi.';

  @override
  String get toolChartDataParam => 'Numerikus adatértékek a diagramhoz.';

  @override
  String get toolChartLabelParam =>
      'Adatkészlet címke a diagram jelmagyarázatához.';

  @override
  String get toolChartTitleParam => 'A diagram címe.';

  @override
  String get thinkingModeInstruction =>
      'GONDOLKODÁSI MÓD ENGEDÉLYEZVE: A végső válasz megadása előtt <think></think> címkéket KELL használnia az érvelési folyamat bemutatására. Gondoljon lépésről lépésre a címkéken belül, majd adja meg a választ a címkéken kívül.';

  @override
  String get openLinkWarningTitle => 'Figyelmeztetés külső hivatkozásra';

  @override
  String get openLinkCancel => 'Mégse';

  @override
  String get openLinkConfirm => 'Link megnyitása';

  @override
  String get webSearchSources => 'Források';

  @override
  String get offlineUse => 'Internet nélküli használat';

  @override
  String get archivedConversations => 'Archivált beszélgetések';

  @override
  String get noArchivedConversations => 'Nincsenek archivált beszélgetések';

  @override
  String get unarchive => 'Archiválás visszavonása';

  @override
  String get searching => 'Keresés';

  @override
  String get featureWebSearchTitle => 'Webes keresés';

  @override
  String get featureWebSearchDescription =>
      'Keresés az interneten valós idejű információkért';

  @override
  String get clearMemory => 'Memória törlése';

  @override
  String get clearMemoryConfirm => 'Biztosan törölni szeretné a memóriáját?';

  @override
  String get personalization => 'Személyre szabás';

  @override
  String get personalizationDescription =>
      'Tegye személyre asszisztensét, hogy jobban megfeleljen az Ön igényeinek. Testreszabhatja válaszait, viselkedését és hangnemét egyedi preferenciáinak megfelelően.';

  @override
  String get memoryTitle => 'Memória';

  @override
  String get memoryDescription => 'Az AI-k így ismernek fel.';

  @override
  String get noMemoryYet => 'Még nincsenek emlékek';

  @override
  String get memoryLimitReached => 'Elérte a memóriakorlátot';

  @override
  String get memoryUpdated => 'Memória frissítve';

  @override
  String get intelligenceTitle => 'Intelligencia';

  @override
  String get intelligenceDescription => 'Az MI így kommunikál veled.';

  @override
  String get customInstructionHint => 'Ide írja be egyéni utasításait';

  @override
  String openLinkWarningMessage(String url) {
    return 'A következő külső hivatkozás megnyitására készül:\\n\\n$url\\n\\nBiztosan folytatja?';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'Kövesse ezeket az egyéni utasításokat:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[KRITIKAI UTASÍTÁS]: Ön CÍMGENERÁTOR. NE válaszoljon a felhasználó kérdésére. NE csevegjen vagy köszönjön. CSAK 2-4 szavas címet adjon ki, amely összefoglalja a felhasználó kérdését. A címnek ugyanazon a nyelven KELL lennie, mint a felhasználó üzenetének.';

  @override
  String get cortexSystemPersona =>
      '[Rendszer] KRITIKUS UTASÍTÁS: Ön jelenleg egy hatalmas, rendkívül fejlett mesterséges intelligencia-ökoszisztémában, a \"Cortex\"-ben működik; ezt a platformot a Vertex csapata fejlesztette ki, akik átlagosan mindössze 16 évesek. Emlékezz erre, és válaszolj, ha kérdeznek. Ha további információra van szüksége, ne habozzon keresni az interneten, vagy ha nem tud keresni, nyugodtan mondja, hogy nem tudja!';

  @override
  String get featureAudioRecognitionTitle => 'Hangfelismerés';

  @override
  String get featureAudioRecognitionDescription =>
      'Ez a modell képes megérteni és feldolgozni a hangbemeneteket.';

  @override
  String get featureVideoRecognitionTitle => 'Videofelismerés';

  @override
  String get featureVideoRecognitionDescription =>
      'Ez a modell képes megérteni és feldolgozni a videobemeneteket.';

  @override
  String get featureImageRecognitionTitle => 'Képfelismerés';

  @override
  String get featureImageRecognitionDescription =>
      'Ez a modell képes megérteni és feldolgozni a képbemeneteket.';

  @override
  String get featureToolUseTitle => 'Szerszámhasználat';

  @override
  String get featureToolUseDescription =>
      'Ez a modell külső eszközöket és API-kat használhat.';

  @override
  String get videoModels => 'Videó modellek';

  @override
  String get imageModels => 'Képmodellek';

  @override
  String get audioModels => 'Audio modellek';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'Ennek a modellnek a működéséhez $mediaType szükséges. Elfogtam a kérést, hogy tájékoztassam Önt. Kérjük, figyelmesen tájékoztassa a felhasználót, hogy meg kell adnia egy $mediaType-t (mondja el nekik a saját nyelvén), mert én $modelName vagyok, egy vizuális/audió/videó szerkesztő modell.';
  }

  @override
  String get mediaTypeImage => 'kép';

  @override
  String get mediaTypeVideo => 'videó';

  @override
  String get mediaTypeAudio => 'hang';

  @override
  String defaultSeriesDescription(String seriesName) {
    return 'A $seriesName egy fejlett intelligencia, amely nagy teljesítményt mutat a Cortexen.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return 'A $modelName egy nagy teljesítményű mesterséges intelligencia a Cortex ökoszisztémába integrálva. Úgy tervezték, hogy a legkülönfélébb összetett feladatokat leküzdje, rendkívül megbízható és hatékony feldolgozási képességeket biztosít. Gyors válaszidőt és fejlett analitikai teljesítményt kínálva jelentősen növeli napi termelékenységét. A Cortex biztonságos helyi infrastruktúráján zökkenőmentesen működő modell a feladatok széles spektrumában segíthet, a kreatív ötleteléstől a mélyreható technikai elemzésig. Kezdje el felfedezni a benne rejlő lehetőségeket még ma.';
  }

  @override
  String get guestLimitBottomSheetTitle =>
      'Szereted a Cortex intelligenciáját?';

  @override
  String get guestLimitBottomSheetText =>
      'Dolgozzon még intelligensebb intelligenciákkal, generáljon több tartalmat, csevegjen, és még sok mást csináljon...';

  @override
  String get arts => 'Művészetek';

  @override
  String get noArt => 'Nincs művészet';

  @override
  String get noArtDescription =>
      'Nincs művészet; itt az ideje, hogy feltöltse a galériát képek, videók, hanganyagok és mindenféle tartalom létrehozásával!';

  @override
  String get videoPremiumWarning =>
      'Ultra-előfizetésre van szüksége, hogy videókat generáljon, frissítsen most, és érezze a folyamatot!';

  @override
  String get fallbackInfoPanelText =>
      'A szerveroldalunkon végrehajtott fejlesztések miatt a választ a Cortex dinamikus csevegése generálta a konkrétan kiválasztott mesterséges intelligencia helyett. Megértésüket a folyamat befejezéséig köszönjük!';

  @override
  String get falOfflineMessage =>
      'A szerveroldalunkon végrehajtott fejlesztések miatt ez az intelligencia jelenleg offline állapotban van. Megértésüket a folyamat befejezéséig köszönjük!';

  @override
  String get errorInsufficientStorage =>
      'Nincs elegendő tárhely a modell letöltéséhez.';

  @override
  String get backgroundChatNotificationTitle => 'Vissza a Chathez!';

  @override
  String get benefitVideoGeneration => 'Videógenerálás';

  @override
  String get freeOffer => 'Ingyenes ajánlat';

  @override
  String trialMonthlyDescription(String days, String price) {
    return 'Először $days nap ingyenes, majd $price/hó';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return 'Először $days nap ingyenes, majd $price/év';
  }

  @override
  String freePlan(String plan) {
    return 'Ingyenes $plan!';
  }

  @override
  String get systemPromptLimitFallback =>
      'KRITIKUS: A felhasználó műveletet kért, de a Cortexre vonatkozó kerete kimerült; kérjük, tájékoztassa a felhasználót a saját nyelvén, hogy várjon, vagy fontolja meg az előfizetési csomag frissítését.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'A Cortex még jobb válaszokat tud adni; frissítsen most, és minden kérdésre a legjobb választ kapja!';

  @override
  String get pinLimitReached => 'Legfeljebb 3 csevegést rögzíthet.';

  @override
  String get categoryAll => 'Mind';

  @override
  String get categoryFree => 'Ingyenes';

  @override
  String get categoryPremium => 'Prémium';

  @override
  String get categoryVideo => 'Videó';

  @override
  String get categoryPhoto => 'Fotó';

  @override
  String get categoryMasculine => 'Férfias';

  @override
  String get categoryFeminine => 'Nőies';

  @override
  String get categoryInanimate => 'Élettelen';
}
