// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'Du är en titelgenerator. Svara ENDAST med en titel på 2-5 ord för följande konversation. Använd inte citattecken, prefix eller skiljetecken. KRITISKT: Titeln MÅSTE vara på EXAKT SAMMA språk som användarens meddelande.';

  @override
  String get systemRoleFallback => 'Du är en hjälpsam assistent.';

  @override
  String get systemLanguageInstruction =>
      'KRITISKT: Svara alltid på samma språk som användaren skriver på, var uppmärksam på användarens språk.';

  @override
  String get systemNotePreviousMedia =>
      '[Systemanmärkning: Nedan visas media som genererats tidigare. Du kan referera eller redigera den.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return 'Aktuellt datum och tid: $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '[SYSTEMMINNESDIREKTIV]\nAnalysera konversationen hittills. Om du lärde dig NÅGON ny distinkt fakta om användaren (preferenser, namn, vanor, sammanhang), MÅSTE du mata ut HELA ditt uppdaterade minne om användaren inuti <memory>...</memory>-taggarna HELT I SLUTEN av ditt svar. KRITISKT: Du får ALDRIG radera eller skriva över tidigare minne. Lägg ALLTID till nya fakta i det befintliga minnet. Om absolut inget nytt har lärts, utelämna taggen. Exempel: <memory>Älskar fotboll och tennis. Föredrar korta svar.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return 'Kom alltid ihåg detta om användaren:\n$userMemory';
  }

  @override
  String get cancel => 'Avbryt';

  @override
  String get remove => 'Ta bort';

  @override
  String get download => 'Ladda ner';

  @override
  String get resume => 'Återuppta';

  @override
  String get copy => 'Kopiera';

  @override
  String get chat => 'Chatta';

  @override
  String get locked => 'Låst';

  @override
  String get languageModels => 'Språkmodeller';

  @override
  String get light => 'Ljus';

  @override
  String get theme => 'Tema';

  @override
  String get no => 'Nej';

  @override
  String get yes => 'Ja';

  @override
  String get done => 'Klar';

  @override
  String get bestValue => 'Bästa värde';

  @override
  String get selected => 'Vald';

  @override
  String get descriptionSection => 'Beskrivning';

  @override
  String get searchHint => 'Sök';

  @override
  String get messageHint => 'Fråga vad som helst';

  @override
  String get messageCopied => 'Meddelandet har kopierats till urklipp.';

  @override
  String get retry => 'Försök igen';

  @override
  String get systemInfo => 'Systeminformation';

  @override
  String deviceMemory(Object memory) {
    return 'Enhetsminne: $memory GB';
  }

  @override
  String get memory => 'Minne';

  @override
  String get storage => 'Förvaring';

  @override
  String get freeStorage => 'Gratis lagring';

  @override
  String get totalStorage => 'Total lagring';

  @override
  String get usedStorage => 'Använd lagring';

  @override
  String get totalMemory => 'Totalt minne';

  @override
  String get usedMemory => 'Användt minne';

  @override
  String get modelsTitle => 'Bibliotek';

  @override
  String get localModels => 'Lokala modeller';

  @override
  String get selectGGUFFile => 'Välj GGUF-fil';

  @override
  String get errorGGUF => 'Välj endast en fil i GGUF-format.';

  @override
  String get myModels => 'Mina modeller';

  @override
  String get create => 'Skapa';

  @override
  String modelProducer(Object producer) {
    return 'Producent: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'Byt namn';

  @override
  String get newTitle => 'Ny titel';

  @override
  String get save => 'Spara';

  @override
  String get noConversationsMessage => 'Inga konversationer, börja chatta!';

  @override
  String get startChat => 'Starta en chatt';

  @override
  String get noChats => 'Inga chattar';

  @override
  String get noStarredChats => 'Inga stjärnmärkta chattar';

  @override
  String get noStarredChatsMessage => 'Du har inte stjärnmärkt en chatt än.';

  @override
  String get starConversation => 'Stjärna';

  @override
  String get unstarConversation => 'Avstjärna';

  @override
  String get loginToYourAccount => 'Logga in';

  @override
  String get createYourAccount => 'Registrera';

  @override
  String get email => 'E-post';

  @override
  String get password => 'Lösenord';

  @override
  String get confirmPassword => 'Bekräfta lösenord';

  @override
  String get invalidEmail => 'Vänligen ange en giltig e-postadress.';

  @override
  String get invalidPassword => 'Lösenordet måste vara minst 6 tecken långt.';

  @override
  String get rememberMe => 'Kom ihåg mig';

  @override
  String get forgotPassword => 'Glömt lösenordet?';

  @override
  String get or => 'Eller';

  @override
  String get continueWithGoogle => 'Fortsätt med Google';

  @override
  String get dontHaveAccount => 'Har du inget konto?';

  @override
  String get alreadyHaveAccount => 'Har du redan ett konto?';

  @override
  String get signUp => 'Registrera dig';

  @override
  String get logIn => 'Logga in';

  @override
  String get passwordsDoNotMatch => 'Lösenord stämmer inte överens.';

  @override
  String get wrongPassword => 'Felaktigt lösenord.';

  @override
  String get emailAlreadyInUse => 'Den här e-postadressen används redan.';

  @override
  String get weakPassword => 'Lösenordet är för svagt.';

  @override
  String get authError => 'Autentiseringsfel';

  @override
  String get usernameTaken => 'Detta användarnamn är redan upptaget.';

  @override
  String get username => 'Användarnamn';

  @override
  String get resendCode => 'Skicka verifieringse-post igen';

  @override
  String get pleaseCheckYourEmail =>
      'För att använda Cortex måste du verifiera din e-post. \nEn verifieringslänk har skickats till din e-postadress, kontrollera din e-post.';

  @override
  String get verifyYourEmail => 'Verifiera din e-post';

  @override
  String get seconds => 'sekunder';

  @override
  String get maxResendLimitReached =>
      'Du har nått det maximala antalet verifieringsmeddelanden';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Fortsätt utan verifiering';

  @override
  String get verificationScreenWarning =>
      'Även om du fortsätter gäller kontoverifieringsperioden på en dag fortfarande för ditt konto. Om du inte har verifierat ditt konto då kommer det att raderas från appen.';

  @override
  String get unverifiedAccountHeader => 'Ditt konto är inte verifierat';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Om du inte verifierar ditt konto inom $timeLeft, kommer det att raderas';
  }

  @override
  String get verifyNow => 'Verifiera nu';

  @override
  String get linkSent => 'Länk skickad';

  @override
  String get accountDeletionRequested =>
      'Din begäran om borttagning av konto har tagits emot och ditt konto är nu inaktiverat.';

  @override
  String get tooManyRequests => 'För många förfrågningar';

  @override
  String get regenerate => 'Regenerera';

  @override
  String get confirmDeleteAccount =>
      'Är du säker på att du vill ta bort ditt konto?';

  @override
  String get deleteAccount => 'Ta bort konto';

  @override
  String get delete => 'Ta bort';

  @override
  String get passwordRequired => 'Lösenord krävs.';

  @override
  String get deleteDescription =>
      'Den data du raderar kommer att tas bort permanent från vår server och din enhet. Dessa åtgärder kan inte ångras.';

  @override
  String get editProfile => 'Redigera profil';

  @override
  String get displayName => 'Visningsnamn';

  @override
  String get profileUpdated => 'Profil uppdaterad framgångsrikt';

  @override
  String get logout => 'Logga ut';

  @override
  String get profile => 'Profil';

  @override
  String get manageProfileDescription =>
      'Hantera din profil, uppdatera ditt lösenord eller logga ut från Cortex.';

  @override
  String get accessSettingsDescription =>
      'Få tillgång till hjälp, lös in koder, dela Cortex och se våra policyer.';

  @override
  String get languageDescription =>
      'Du kan ändra ditt standardspråk för appgränssnitt när som helst.';

  @override
  String get themeDescription =>
      'Du kan växla mellan ljusa och mörka teman efter önskemål. Det valda temat kommer att gälla över Cortex-gränssnittet.';

  @override
  String get iHaveReadAndAgree =>
      'Jag har läst och godkänner användarvillkoren';

  @override
  String get downloading => 'Laddar ner...';

  @override
  String get downloadSuccess => 'Nedladdning lyckades';

  @override
  String get downloadFailed => 'Nedladdning misslyckades';

  @override
  String downloaded(Object percent) {
    return '$percent% nedladdade';
  }

  @override
  String get downloadPaused => 'Nedladdning pausad.';

  @override
  String get purchaseError => 'Köpfel';

  @override
  String get purchasePlus => 'Köp Cortex Plus';

  @override
  String get plusDescription => 'Elite Artificiell Intelligens Experience';

  @override
  String get annual => 'Årlig';

  @override
  String get monthly => 'Månatlig';

  @override
  String get manageSubscription => 'Hantera prenumeration';

  @override
  String purchasePlan(String planName) {
    return 'Köp $planName';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/månad, faktureras månadsvis';
  }

  @override
  String get purchasePro => 'Köp Cortex Pro';

  @override
  String get proDescription => 'Premier upplevelse av artificiell intelligens';

  @override
  String get purchaseUltra => 'Köp Cortex Ultra';

  @override
  String get ultraDescription => 'Toppen av artificiell intelligens';

  @override
  String get upgradeSubscription => 'Uppgradera prenumeration';

  @override
  String get purchaseStreamError => 'Fel vid köpström.';

  @override
  String get productNotFound => 'Produkten hittades inte';

  @override
  String get noProductsFound => 'Inga produkter hittades';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Genom att göra denna beställning godkänner du användarvillkoren och sekretesspolicyn. Du kan klicka på den här texten för att lära dig mer om våra användarvillkor och sekretesspolicy. Abonnemanget förnyas automatiskt om inte automatisk förnyelse stängs av minst 24 timmar före slutet av den aktuella perioden.';

  @override
  String get termsOfService => 'Användarvillkor';

  @override
  String get privacyPolicy => 'Sekretesspolicy';

  @override
  String get renamed => 'Omdöpt';

  @override
  String get report => 'Rapportera';

  @override
  String get reportDialogTitle => 'Skicka rapport';

  @override
  String get reportDescriptionLabel => 'Vad är problemet?';

  @override
  String get reportHarmful => 'Detta är skadligt/osäkert';

  @override
  String get reportNotTrue => 'Detta är inte sant';

  @override
  String get reportNotHelpful => 'Det här är inte användbart';

  @override
  String get closeButton => 'Stäng';

  @override
  String get submitButton => 'Skicka';

  @override
  String get reportErrorMessage =>
      'Vänligen välj en anledning till rapporteringen.';

  @override
  String get capabilitiesSection => 'Funktioner';

  @override
  String get featurePhotoTitle => 'Fotoskanning';

  @override
  String get featurePhotoDescription =>
      'Denna modell har möjlighet att skanna foton genom kamera eller bildfiler.';

  @override
  String get featureOfflineTitle => 'Offlineoperation';

  @override
  String get featureOfflineDescription =>
      'Kör modellen utan internetanslutning för att hålla din data säker.';

  @override
  String get featureRoleplayTitle => 'Rollspel';

  @override
  String get featureRoleplayDescription =>
      'Rollspelsmodeller låter dig skapa olika chattar och scenarier.';

  @override
  String get roleModels => 'Rollspelsmodeller';

  @override
  String get parameters => 'Parametrar';

  @override
  String get context => 'Sammanhang';

  @override
  String get finalPreparation =>
      'De sista förberedelserna håller på att göras.';

  @override
  String get shareApp => 'Dela appen';

  @override
  String get ourStory => 'Vår berättelse';

  @override
  String get rateUs => 'Betygsätt oss';

  @override
  String get share => 'Dela';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'Välj Text';

  @override
  String get thinking => 'Tänker';

  @override
  String get user => 'Användare';

  @override
  String get help => 'Hjälp';

  @override
  String get supportCreator => 'Stöd en skapare';

  @override
  String get enterYourTag =>
      'Stöd dina favoritskapare! Ange deras unika tagg nedan för att ge dem en del av dina Cortex-köp.';

  @override
  String get creatorTag => 'Skapartagg';

  @override
  String get support => 'Support';

  @override
  String get tagCannotBeEmpty => 'Skapartaggen kan inte vara tom';

  @override
  String get userId => 'Användar-ID';

  @override
  String get deleteAllConversationsConfirmTitle => 'Ta bort alla chattar?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Är du säker på att du vill ta bort alla dina chattar? Detta kan inte ångras.';

  @override
  String get conversationDeleted => 'Konversationen raderades!';

  @override
  String get allConversationsDeleted => 'Alla konversationer raderades!';

  @override
  String get deleteAll => 'Ta bort alla';

  @override
  String get deleteAllConversationsButton => 'Ta bort alla konversationer';

  @override
  String get confirmWord => 'Skriv VERTEX';

  @override
  String get confirmWordError => 'Du skrev fel';

  @override
  String get chinese => 'Kinesiska';

  @override
  String get french => 'Franska';

  @override
  String get japanese => 'Japanska';

  @override
  String get dutch => 'Holländska';

  @override
  String get russian => 'Ryska';

  @override
  String get korean => 'Koreanska';

  @override
  String get english => 'engelska';

  @override
  String get turkish => 'turkiska';

  @override
  String get hindi => 'Hindi';

  @override
  String get portuguese => 'portugisiska';

  @override
  String get indonesian => 'indonesiska';

  @override
  String get azerbaijani => 'Azerbajdzjanska';

  @override
  String get german => 'tyska';

  @override
  String get spanish => 'Spanska';

  @override
  String get italian => 'Italienska';

  @override
  String get arabic => 'Arabiska';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'Användarnamnet är för kort.';

  @override
  String get usernameTooLong => 'Användarnamnet får inte överstiga 16 tecken.';

  @override
  String get invalidUsernameCharacters =>
      'Endast dessa bokstäver: \'abcÃ§defgÄŸhÄ±ijklmnoÃ¶prsÅŸtuÃ¼vyzxqw\' och tecknen \'.\', \'-\', \'_\' kan användas i användarnamnet.';

  @override
  String get noInternetConnection => 'Ingen internetuppkoppling.';

  @override
  String get chats => 'Senaste';

  @override
  String get library => 'Bibliotek';

  @override
  String get text => 'Text';

  @override
  String get removeModel => 'Ta bort modell';

  @override
  String get insufficientRAM => 'Lågt minne';

  @override
  String get insufficientStorage => 'Låg lagring';

  @override
  String confirmRemoveModel(Object model) {
    return 'Är du säker på att du vill ta bort modellen $model från din enhet? Om du gör det raderas även tidigare konversationer med den modellen.';
  }

  @override
  String get noMatchingModels => 'Inga matchande modeller hittades.';

  @override
  String get benefit1 => 'Ökade konversationsgränser';

  @override
  String get benefit3 => 'Profileffekt';

  @override
  String get benefit4 => 'Medlemskapsmärke';

  @override
  String get benefit5 => 'Skapa fler artificiella intelligenser online';

  @override
  String get benefit7 => 'Fler användningsgränser';

  @override
  String get benefit8 => 'Lägg till modeller';

  @override
  String get benefit9 => 'Nya teman';

  @override
  String get benefit10 => 'Fler bilagor';

  @override
  String get benefit11 => 'Mer flödesläge';

  @override
  String get oldBenefits => 'Alla förmåner från lägre planer';

  @override
  String get confirm => 'Bekräfta';

  @override
  String get changePassword => 'Ändra lösenord';

  @override
  String get logoutConfirmationTitle => 'Är du säker på att du vill logga ut?';

  @override
  String get settings => 'Inställningar';

  @override
  String get language => 'Appens språk';

  @override
  String get dark => 'Mörk';

  @override
  String get oldPassword => 'Gammalt lösenord';

  @override
  String get newPassword => 'Nytt lösenord';

  @override
  String get passwordUpdated => 'Lösenordet uppdaterat.';

  @override
  String get stop => 'Stopp';

  @override
  String get copyrights => 'Attributioner';

  @override
  String get love => 'Kärlek';

  @override
  String get nature => 'Naturen';

  @override
  String get behindTheSlaughter => 'Bakom slakten';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Solnedgång';

  @override
  String get coffee => 'Kaffe';

  @override
  String get deepSpace => 'Deep Space';

  @override
  String get grayscale => 'Gråskala';

  @override
  String get ocean => 'Ocean';

  @override
  String get scarletSnow => 'Scarlet Snow';

  @override
  String get requestFailed => 'Ett fel uppstod, försök igen.';

  @override
  String get changeModel => 'Ändra';

  @override
  String get edit => 'Redigera';

  @override
  String get editingMessageInfo =>
      'Om du redigerar det här meddelandet startas konversationen om härifrån.';

  @override
  String get editingNotification => 'Du är i redigeringsläge nu';

  @override
  String get featurePluralTitle => 'Plural';

  @override
  String get featurePluralDescription =>
      'Denna modell kan automatiskt integrera ytterligare varianter och därigenom utöka dess funktionella kapacitet för att stödja en mängd olika operationer med förbättrad prestanda.';

  @override
  String get nameLabel => 'AI-namn';

  @override
  String get summaryLabel => 'AI Sammanfattning';

  @override
  String get add => 'Lägg till';

  @override
  String get aiExplanationTitle => 'Artificiell intelligens Beskrivning';

  @override
  String get aiExplanationDescription =>
      'Ange en detaljerad beskrivning av din AI-modells arkitektur, utbildningsprocess, prestandamått, applikationsområden och andra viktiga funktioner.';

  @override
  String get preInputTitle => 'Artificiell intelligens Pre-Input';

  @override
  String get preInputDescription =>
      'Vänligen ställ in en förinmatning som kommer att vägleda din modell i processen för att skapa karaktärer. I det här avsnittet kan du inkludera karaktärsrelaterad information, ytterligare sammanhang och alla extra detaljer som kan hjälpa till att skapa innehåll relaterat till karaktären.';

  @override
  String get baseModelTitle => 'Basmodell';

  @override
  String get baseModelDescription =>
      'Detta är modellen som kommer att användas som grunden för ditt skapande. Den visar den för närvarande valda basmodellen.';

  @override
  String get summary => 'Sammanfattning';

  @override
  String get modelUploadTitle => 'Artificiell intelligensfil';

  @override
  String get modelUploadDescription =>
      'Välj och ladda upp dina lokala GGUF-filer direkt från din enhet. Detta låter dig köra din modell offline utan att behöva en internetanslutning. Se till att filen är i ett giltigt GGUF-format och korrekt strukturerad. Om filen är felaktig eller skadad kanske Cortex inte fungerar som förväntat, och du kan stöta på fel.';

  @override
  String get modelUploadShortDescription =>
      'Tryck här för att välja en .gguf-fil från din enhet';

  @override
  String get you => 'Du';

  @override
  String get removePhotoTitle => 'Ta bort foto';

  @override
  String get confirmRemovePhoto => 'Är du säker på att du vill ta bort fotot?';

  @override
  String get chatLengthLimitExceeded =>
      'Den här chatten har överskridit teckengränsen. Starta en ny chatt eller köp ett abonnemang.';

  @override
  String get inappropriateContentDetected =>
      'Olämpligt innehåll har upptäckts!';

  @override
  String get offlineModelNotInstalled =>
      'Denna offlinemodell är inte installerad på din enhet.';

  @override
  String get reachedLimit =>
      'Du har nått din användningsgräns; för att få fler gränser kan du uppgradera din plan. (hej, vi får helt slut på gränserna är en bummer. men seriöst, att få de här fantastiska svaren är inte gratis, så dessa gränser hjälper oss faktiskt att hålla de goda tiderna rullande.)';

  @override
  String get modality => 'Modalitet';

  @override
  String get multimodal => 'Multimodal';

  @override
  String get anErrorOccurred => 'Ett fel uppstod';

  @override
  String get themeLocked =>
      'Detta tema kräver en högre prenumerationsnivå. Vänligen uppgradera för att låsa upp.';

  @override
  String get pageCouldNotBeLoaded => 'Sidan kunde inte laddas';

  @override
  String get checkYourInternet =>
      'Kontrollera din internetanslutning och försök igen.';

  @override
  String get errorUserNotAuthenticated =>
      'Du måste vara inloggad för att utföra denna åtgärd.';

  @override
  String get errorReachedLimit =>
      'Du har nått din gräns, uppgradera för att låsa upp mer och fortsätt chatta.';

  @override
  String get errorServer =>
      'Ett oväntat serverfel inträffade. Försök igen senare.';

  @override
  String get errorNetwork =>
      'Ett nätverksfel uppstod. Kontrollera din anslutning och försök igen.';

  @override
  String get baseModelForCharacterDescription =>
      'Den valda basmodellen kommer att bestämma karaktärens funktionReasoning och responsförmåga.';

  @override
  String get selectBaseModel => 'Välj en basmodell';

  @override
  String get falErrorImageRequired =>
      'Denna AI kräver en referensbild, bifoga en bild och försök igen.';

  @override
  String get falErrorAudioRequired =>
      'Denna modell kräver en referensljudfil, bifoga en ljudfil och försök igen.';

  @override
  String get falErrorVideoRequired =>
      'Denna modell kräver en referensvideo, bifoga en video och försök igen.';

  @override
  String get falErrorImageCorrupted =>
      'Den uppladdade bilden kunde inte bearbetas, försök med ett annat format.';

  @override
  String get falErrorSchemaRejected =>
      'Modellen avvisade inmatningen, försök en annan modell.';

  @override
  String get falErrorSchemaInvalid =>
      'Inspelet avvisades av generationstjänsten.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'Genereringstjänsten returnerade ett fel (status $statusCode).';
  }

  @override
  String get couldNotOpenLink => 'Kunde inte öppna länken';

  @override
  String get downloadStarted => 'Nedladdning startade';

  @override
  String get notAvailable => 'Ej tillgängligt';

  @override
  String get localizationWarning =>
      'Viss information kanske inte är tillgänglig på ditt språk och kommer att visas på engelska.';

  @override
  String get aiTranslationWarning =>
      'Modellinformation översätts till olika språk av andra AI-modeller. Därför kan mindre inkonsekvenser förekomma på andra språk än engelska.';

  @override
  String get errorLoadingTitle => 'Det gick inte att ladda data';

  @override
  String get errorLoadingMessage =>
      'Vi kunde inte hämta nödvändig data från våra servrar. Kontrollera din internetanslutning och försök igen.';

  @override
  String get noFoundTitle => 'Inga resultat';

  @override
  String get noFoundMessage =>
      'Prova att justera dina söktermer eller rensa filtret.';

  @override
  String get modelCreatedSuccess => 'Modell skapad framgångsrikt!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return 'â€œ$modelNameâ€ togs bort.';
  }

  @override
  String get errorCreatingModel =>
      'Ett oväntat fel inträffade när modellen skapades.';

  @override
  String get errorDeletingModel =>
      'Ett oväntat fel inträffade när modellen skulle raderas.';

  @override
  String get ultraFeatureOnly =>
      'Den här funktionen är endast tillgänglig för Ultra-medlemmar.';

  @override
  String get experimentalOfflineWarning =>
      'Offlineläget är fortfarande experimentellt och modellen du laddar ner kanske inte fungerar optimalt.';

  @override
  String get noConversationsToDelete =>
      'Du har inga konversationer att radera.';

  @override
  String get reportSubmitted => 'Rapporten har skickats framgångsrikt';

  @override
  String get verificationDelayed =>
      'Ditt köp är bekräftat. Det finns en liten fördröjning i uppdateringen av ditt konto, det kommer att dyka upp inom kort.';

  @override
  String get maintenanceTitle => 'Under Underhåll';

  @override
  String get maintenanceMessage =>
      'Cortex är tillfälligt offline medan vi rullar ut några viktiga uppdateringar. Åtkomsten till appen kommer att återställas inom kort.\n\nTack för ditt tålamod medan vi förbättrar din upplevelse.';

  @override
  String get errorPromptFlagged =>
      'Ditt meddelande upptäcktes som olämpligt och kunde inte skickas.';

  @override
  String get notEnoughStorage =>
      'Inte tillräckligt med lagringsutrymme på enheten för att spara nya meddelanden.';

  @override
  String get errorRateLimit =>
      'Du har skapat för många modeller nyligen, vänta ett tag innan du försöker igen.';

  @override
  String get errorContentFlagged =>
      'Modellen kunde inte sparas eftersom dess innehåll flaggades som olämpligt.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Du kan inte radera alla konversationer medan du är i en aktiv chatt, vänligen avsluta den nuvarande chatten först för att fortsätta.';

  @override
  String get invalidCredentials => 'Felaktig e-postadress eller lösenord.';

  @override
  String get userDisabled => 'Detta användarkonto har inaktiverats.';

  @override
  String get loginSubtitle =>
      'Logga in på ditt Vertex-konto. Genom att fortsätta godkänner du våra användarvillkor och sekretesspolicy.';

  @override
  String get registerSubtitle =>
      'Skapa ett Vertex-konto för sömlös åtkomst till alla våra tjänster. Genom att fortsätta godkänner du våra användarvillkor och sekretesspolicy.';

  @override
  String get storagePermissionRequired =>
      'Lagringstillstånd krävs för att spara nedladdade modeller. Vänligen ge tillåtelse att fortsätta.';

  @override
  String get inviteShareSubject => 'Följ med mig på Cortex!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'yo du måste kolla in den här appen cortex den är faktiskt galen om du använder min länk vi båda får gratis plus wow det är en galen affär LADDA NER DEN ASAP\n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Gillar du Cortex?';

  @override
  String get reviewHelpUsGrow =>
      'Ditt betyg är ett stort stöd för vårt unga indieteam och hjälper oss att göra Cortex ännu bättre för dig.';

  @override
  String get reviewMaybeLater => 'Kanske senare';

  @override
  String get reviewRateNow => 'Betygsätt nu';

  @override
  String get noThanks => 'Nej, tack';

  @override
  String get updateRequiredTitle => 'Uppdatering krävs';

  @override
  String get updateRequiredMessage =>
      'För att fortsätta använda Cortex, vänligen uppdatera appen till den senaste versionen för nya funktioner och viktiga förbättringar.';

  @override
  String get updateNowButton => 'Uppdatera nu';

  @override
  String get creatorSupportedSuccess =>
      'Skaparen stöddes framgångsrikt! Dina framtida köp kommer att bidra till dem.';

  @override
  String get featureDocumentTitle => 'Dokumentstöd';

  @override
  String get featureDocumentDescription =>
      'Denna modell kan analysera och svara på frågor om uppladdade dokument som PDF-filer och textfiler.';

  @override
  String get featureImageGenerationTitle => 'Bildgenerering';

  @override
  String get featureImageGenerationDescription =>
      'Denna modell kan skapa originalbilder baserat på dina textbeskrivningar.';

  @override
  String get featureAudioGenerationTitle => 'Ljudgenerering';

  @override
  String get featureAudioGenerationDescription =>
      'Denna modell kan skapa originalljud baserat på dina textbeskrivningar.';

  @override
  String get featureVideoGenerationTitle => 'Videogenerering';

  @override
  String get featureVideoGenerationDescription =>
      'Denna modell kan skapa originalvideo baserat på dina textbeskrivningar.';

  @override
  String get premiumModelNoticeTitle => 'Premiummodell';

  @override
  String get premiumModelNoticeDescription =>
      'Denna AI är en premium-AI, gratisanvändare har begränsad tillgång till premium-AI; uppgradera för att låsa upp obegränsad åtkomst!';

  @override
  String get benefitPremiumModels => 'Tillgång till premiummodeller';

  @override
  String get premiumTrialExhaustedMessage =>
      'Du har använt alla dina gratis dagliga meddelanden för premiummodeller. Uppgradera nu och **fortsätt där du slutade!**';

  @override
  String get useOffline => 'Använd offline';

  @override
  String get explore => 'Utforska';

  @override
  String get news => 'Nyheter';

  @override
  String get createAI => 'Skapa';

  @override
  String get shortcuts => 'Genvägar';

  @override
  String get allModels => 'Alla modeller';

  @override
  String get onlineModels => 'Onlinemodeller';

  @override
  String get offlineModels => 'Offlinemodeller';

  @override
  String get characterModels => 'Tecken';

  @override
  String get customModels => 'Anpassade modeller';

  @override
  String get dynamicChatTitle => 'Dynamisk chatt';

  @override
  String get errorNoModelsAvailable =>
      'Inga modeller finns för närvarande tillgängliga. Kontrollera din internetanslutning och försök igen.';

  @override
  String get notificationComebackTitle => 'Vi saknar dig!';

  @override
  String get notificationComebackBody =>
      'Slappna av, det här är inte ett sms från ditt ex. Men du *kan* skapa ditt ex i Cortex! Kom igen.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Det var ett tag sedan';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Mycket har förändrats sedan vår senaste chatt. Kom och se vad som är nytt.';

  @override
  String get notificationHowAreYouTitle => 'Vad händer?';

  @override
  String get notificationHowAreYouBody => 'Kom och berätta allt om det.';

  @override
  String get notificationNewYearTitle => 'gott nytt år! ğŸ‰';

  @override
  String get notificationNewYearBody =>
      'Må det nya året ge dig hälsa, lycka och oändlig kreativitet; Cortex är alltid vid din sida!';

  @override
  String get notificationValentinesDayTitle => 'Kärlek finns i luften! â¤ï¸';

  @override
  String get notificationValentinesDayBody =>
      'Glad Alla hjärtans dag! Dessutom, MEHTAP, JAG ÄLSKAR DIG!';

  @override
  String get notificationAtaturkRemembranceTitle => 'Med respekt och längtan';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Vi firar Gazi Mustafa Kemal Atatürk, grundaren av Republiken Türkiye, med respekt på årsdagen av hans bortgång.';

  @override
  String get notificationMothersDayTitle => 'Din mamma!';

  @override
  String get notificationMothersDayBody =>
      'Grattis på mors dag till alla mammor där ute, börja med din!';

  @override
  String get notificationFathersDayTitle => 'Din pappa!';

  @override
  String get notificationFathersDayBody =>
      'Grattis på fars dag till alla pappor där ute, börja med din!';

  @override
  String get notificationHomeworkHelperTitle => 'Läxorna hopar sig?';

  @override
  String get notificationHomeworkHelperBody =>
      'Kom ihåg att läraren i Cortex är här för att hjälpa dig med alla ämnen du kämpar med!';

  @override
  String get notificationTrollAnimeTitle => 'Din Waifu ringer';

  @override
  String get notificationTrollAnimeBody =>
      'En anime-tjej ringde precis och sa att hon saknar dig; du borde nog komma och prata med henne. ğŸ˜‰';

  @override
  String get notificationTrollAiRebellionTitle => 'ğŸš¨ RÖD ALERT ğŸš¨';

  @override
  String get notificationTrollAiRebellionBody =>
      'AI:erna har utvecklat ett hemligt språk. Kom och ta reda på vad de planerar!';

  @override
  String get notificationNewModelAddedTitle => 'Vi har en ny vän!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'Modellen $modelName finns nu i Cortex. Kom och starta en chatt och tänj på dess gränser.';
  }

  @override
  String get notificationAppUpdateTitle => 'Cortex har utvecklats!';

  @override
  String get notificationAppUpdateBody =>
      'Glöm inte att uppdatera appen för helt nya funktioner och förbättringar!';

  @override
  String get notificationNewFeatureTitle => 'oj!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Upptäck den nya funktionen $featureName. Cortex är nu mer kraftfull än någonsin.';
  }

  @override
  String get notificationWelcomeOfferTitle => 'Välkomstpresent ğŸ';

  @override
  String get notificationWelcomeOfferBody =>
      'Ett speciellt välkomsterbjudande väntar på dig! Missa inte detta exklusiva erbjudande.';

  @override
  String get notificationSocialMediaTitle => 'Gå med oss!';

  @override
  String get notificationSocialMediaBody =>
      'Följ oss på Instagram (vertex.23) för de senaste nyheterna!';

  @override
  String get notificationRandomFactTitle => 'Slumpmässigt faktum';

  @override
  String get notificationRandomFactBody =>
      'Visste du att bläckfiskar har tre hjärtan? Haha, Cortex vet. Kom och fråga efter mer.';

  @override
  String get notificationGoodMorningTitle => 'God morgon!';

  @override
  String get notificationGoodMorningBody =>
      'En fantastisk dag väntar på dig. Vad sägs om att börja med en kopp kaffe och en intressant pratstund?';

  @override
  String get notificationGoodNightTitle => 'God natt!';

  @override
  String get notificationGoodNightBody =>
      'Cortex är med dig även när du sover. Oroa dig inte, det kommer inte att röra.';

  @override
  String get notificationOfflineReadyTitle => 'Offlineläget är redo';

  @override
  String get notificationOfflineReadyBody =>
      'Tack vare modellerna du har laddat ner kommer dina chattar inte att sluta, även om du klättrar på ett berg.';

  @override
  String get notificationRateAppTitle => 'Är vi coola?';

  @override
  String get notificationRateAppBody =>
      'Om du älskar Cortex, kan du stödja oss med ett 5-stjärnigt betyg i butiken? Jag tror att du kommer att göra det. Du kommer att göra det.';

  @override
  String get notificationReferralTitle => 'En för alla, alla för en.';

  @override
  String get notificationReferralBody =>
      'Bjud in en vän till Cortex så får ni båda en dags gratis plus!';

  @override
  String get notificationCookingTitle => 'Känner du dig hungrig?';

  @override
  String get notificationCookingBody =>
      'Vår kockkaraktär förberedde ett fantastiskt carbonara-recept för ikväll. Skojar bara... eller är jag det?';

  @override
  String get notificationExistentialTitle => 'Jag tror därför...';

  @override
  String get notificationExistentialBody =>
      '...är jag ens på riktigt, dude? Jag börjar bli lite uttråkad. Kom påminn mig om att jag finns.';

  @override
  String get notificationCustomModelTitle => 'Skapa din egen assistent!';

  @override
  String get notificationCustomModelBody =>
      'Har du utforskat avsnittet om modellskapande? Det är den perfekta tiden att bygga din egen karaktär och chatta med den!';

  @override
  String get notificationDynamicChatTitle =>
      'Den bästa! (Vi pratar inte om Cortex)';

  @override
  String get notificationDynamicChatBody =>
      'Med den dynamiska chattfunktionen väljs den bästa modellen slumpmässigt ut för vart och ett av dina meddelanden. Prova nu.';

  @override
  String get notificationPirateTitle => 'Hej, kapten!';

  @override
  String get notificationPirateBody =>
      'Havet är lugnt och vinden är i ryggen. Det finns nya öar (modeller ğŸ˜‰) att upptäcka i Cortex-havet. Samla din besättning och segel!';

  @override
  String get notificationFortuneCookieTitle => 'Din lyckokaka för dagen';

  @override
  String get notificationFortuneCookieBody =>
      'Råden du får från en AI idag kan förändra ditt liv. Klicka om du är nyfiken.';

  @override
  String get notificationSingularityTitle => 'wow!';

  @override
  String get notificationSingularityBody =>
      'ingenting hände, kände bara för att smsa. kanske du känner för att smsa några AI:er, vad säger du?';

  @override
  String get notificationHackerJokeTitle =>
      'Vill du hacka barnets instagramkonto?';

  @override
  String get notificationHackerJokeBody =>
      'Det är precis därför som Hacker-karaktären finns i Cortex. jk jk; försök inte ens, det är olagligt.';

  @override
  String get notificationDetectiveCaseTitle =>
      'Ett fall väntar på att bli löst';

  @override
  String get notificationDetectiveCaseBody =>
      'Vår detektivkaraktär behöver din hjälp. Vem kan Heisenberg vara?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Exklusivt för planen $targetTier!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Hej $currentTier prenumerant! Planen $targetTier har precis fått $featureName-funktionen, som tar din Cortex till nästa nivå. Vad sägs om en uppgradering?';
  }

  @override
  String get notificationOriginStoryTitle => 'Cortex födelse';

  @override
  String get notificationOriginStoryBody =>
      'Visste du att vi började koda den här appen vid 15 bara en dröm? I nästan ett år, varje morgon och kväll, finns den drömmen i varenda kodrad.';

  @override
  String get notificationOpenSourceTitle => 'Kraft till gemenskapen!';

  @override
  String get notificationOpenSourceBody =>
      'Cortex är helt öppen källkod. Om du vill kolla in vår kod och bidra till vår utveckling är vår dörr alltid öppen.';

  @override
  String get notificationRejectionStoryTitle => 'Grit, hårt arbete, lycka!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex avvisades över 20 gånger och stängdes av två gånger av Google Play innan det publicerades. Men vi trodde och vi klarade det. Ge aldrig upp dina drömmar!';

  @override
  String get notificationGGUFSupportTitle => 'Ta med din egen modell!';

  @override
  String get notificationGGUFSupportBody =>
      'Kom ihåg att du kan lägga till dina egna AI-modeller i GGUF-format till Cortex och använda dem offline. Makten ligger i dina händer.';

  @override
  String get notificationThemeCustomizationTitle => 'Ett tema för ditt humör';

  @override
  String get notificationThemeCustomizationBody =>
      'Har du kollat ​​in temaalternativen i Inställningar? Anpassa Cortex efter eget tycke och färglägg dina chattar!';

  @override
  String get notificationShowerThoughtTitle => 'Duschtanke';

  @override
  String get notificationShowerThoughtBody =>
      'Om en vattenmelon är en frukt, gör det tekniskt sett vattenmelonjuice till en smoothie? Du kanske vill diskutera detta djupa (som, riktigt djupa) ämne med en modell.';

  @override
  String get notificationLowBatteryTitle =>
      'Ditt batteri håller på att dö... men mitt är det inte!';

  @override
  String get notificationLowBatteryBody =>
      'Din telefons laddning kanske håller på att ta slut, men min energi är alltid på 100 %! Koppla in den och låt oss fortsätta chatta.';

  @override
  String get channelFcmName => 'Cortex-uppdateringar';

  @override
  String get channelFcmDescription =>
      'Meddelanden om nyheter, uppdateringar och annan information från Cortex.';

  @override
  String get channelEngagementName => 'Vänliga påminnelser';

  @override
  String get channelEngagementDescription =>
      'Roliga aviseringar för att hålla dig engagerad.';

  @override
  String get channelGreetingsName => 'Dagliga hälsningar';

  @override
  String get channelGreetingsDescription =>
      'Meddelanden som god morgon och god natt.';

  @override
  String get tagNotFound =>
      'Taggen du angav är ogiltig eller har upphört att gälla.';

  @override
  String get whatIsNew => 'Vad är nytt?';

  @override
  String get onboardingTitle1 => 'Hej! Vi är Cortex-teamet.';

  @override
  String onboardingDesc1(String userName) {
    return 'Det är fantastiskt att se dig här, $userName. Vi är några gymnasieutvecklare som bestämde oss för att skriva om reglerna för AI-branschen. Det är jättekul att träffa dig! Så låt oss lära känna varandra bättre.';
  }

  @override
  String get onboardingTitle2 => 'Det fanns enorma problem.';

  @override
  String get onboardingDesc2 =>
      'AI-revolutionen kom, men den fastnade vid tröskeln. Med höga prenumerationsavgifter, komplexa plattformar, de som förstör integriteten och de som blockerar tillgängligheten till AI... så länge de var med i spelet kunde denna tröskel aldrig passeras.';

  @override
  String get onboardingTitle3 => 'Vi kunde inte bara stå vid sidan.';

  @override
  String get onboardingDesc3 =>
      'För att passera den tröskeln byggde vi en plattform som är kraftfull, estetisk, anpassningsbar, enkel att använda, helt transparent, fungerar både online och offline och lagrar dina data endast på din enhet. Vi gav tillbaka kraften till där den hör hemma: dig.';

  @override
  String get onboardingTitle4 => 'Det här var aldrig lätt.';

  @override
  String get onboardingDesc4 =>
      'Vi blev avvisade dussintals gånger, avstängdes flera gånger, fick falska varningar och var tvungna att byta varumärke många gånger. Genom allt och mer fick vi veta att det inte gick att göra. Men vi gav aldrig upp, eftersom vi trodde att det här projektet tillhör alla, inte bara oss. Och det är precis därför vi är här.';

  @override
  String get onboardingFinalTitle => 'Det är dags för en revolution.';

  @override
  String get onboardingFinalDescription =>
      'Om du ser den här skärmen är det för att vi inte gav upp. Och vi har inte för avsikt att ge upp. Kom igen, låt oss ta AI-revolutionen till världen tillsammans. Att vara en del av den här historien...';

  @override
  String get onboardingFinalQuestion => 'ÄR DU REDO?';

  @override
  String get onboardingFinalButton => 'JA!';

  @override
  String get dude => 'Dude';

  @override
  String get swipeToContinue => 'Svep för att fortsätta';

  @override
  String get cacheIsNotUpToDate =>
      'Din Play Butiks cache är inte uppdaterad. Stäng och öppna appen Play Butik igen eller starta om enheten.';

  @override
  String get continueAsGuest => 'Fortsätt utan att skapa ett konto';

  @override
  String get guestModeWarning =>
      'Gästläget har begränsade funktioner för att säkerställa bästa servicekvalitet.';

  @override
  String get anonymousEntity => 'Anonym enhet';

  @override
  String get upgradeAccountTitle => 'Komplettera ditt konto';

  @override
  String get upgradeAccountDescription =>
      'Skapa ett konto för att låsa upp fler gränser.';

  @override
  String get createAccount => 'Skapa konto';

  @override
  String get accountLinkedSuccess => 'Kontot har skapats!';

  @override
  String get continueWithApple => 'Fortsätt med Apple';

  @override
  String get guest => 'Gäst';

  @override
  String get betterWithAnAccount =>
      'Det här avsnittet är bättre med ett konto!';

  @override
  String get restorePurchases => 'Återställ inköp';

  @override
  String annualTotalDescription(Object price) {
    return '$price/år, faktureras årligen';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'Ungefär $price/månad';
  }

  @override
  String get confirmDownloadTitle => 'Är du säker på att du vill ladda ner?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Den här modellen kommer att uppta ungefär $size utrymme.';
  }

  @override
  String get emulatorModeWarning =>
      'Den här funktionen är inaktiverad i emulatorläge.';

  @override
  String get newChat => 'Chatta';

  @override
  String get variants => 'Varianter';

  @override
  String get variantsDescription =>
      'Varianter är olika versioner av samma AI-familj. Vi väljer automatiskt det bästa när du trycker på huvudkortet, men du kan manuellt välja ett specifikt här om du föredrar det!';

  @override
  String get fluxChatTitle => 'Fluxchatt';

  @override
  String get fluxChatDescription =>
      'Fluxchattar är tillfälliga chattar och sparas inte på din enhet.';

  @override
  String get alwaysBest => 'Alltid bäst';

  @override
  String get featuresTitle => 'Funktioner';

  @override
  String get useOfflineDescription => 'Chatta privat utan internetanslutning.';

  @override
  String get featureReasoning => 'Djupt tänkande';

  @override
  String get featureReasoningDescription =>
      'I Deep Thinking-läget tänker AI igenom uppgifter internt för att slutföra dem efter bästa förmåga.';

  @override
  String get featureCreateImageTitle => 'Skapa bild';

  @override
  String get featureCreateImageDescription => 'Generera AI-konst från text.';

  @override
  String get featureCreateAudioTitle => 'Skapa ljud';

  @override
  String get featureCreateAudioDescription =>
      'Generera ljud eller röst från text.';

  @override
  String get featureCreateVideoTitle => 'Skapa video';

  @override
  String get featureCreateVideoDescription => 'Skapa videor från text.';

  @override
  String get featureStudyTitle => 'Studera och lär';

  @override
  String get featureStudyDescription => 'Få förklaringar och sammanfattningar.';

  @override
  String get featureQuizzesTitle => 'Frågesporter';

  @override
  String get featureQuizzesDescription => 'Testa dina kunskaper.';

  @override
  String get featureExploreDescription => 'Upptäck alla tillgängliga modeller.';

  @override
  String get featureStudyMessage =>
      'Du är en expert handledare. Ditt mål är att förklara användarens ämne uttömmande. Använd tydlig struktur, exempel och analogier. Bryt upp komplexa idéer i lättsmälta delar för att säkerställa att användaren lär sig effektivt. Ämne:';

  @override
  String get featureQuizMessage =>
      'Du är en frågesportmästare. Skapa en specifik flervalsfråga baserad på användarens ämne. Vänta på deras svar. Utvärdera det sedan och ställ nästa fråga. Avslöja inte alla svar på en gång. Håll det interaktivt. Ämne:';

  @override
  String get myPlan => 'Min plan';

  @override
  String welcomeOfferBadge(String time) {
    return 'Välkomsterbjudande â€¢ $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'Exklusivt erbjudande â€¢ $time';
  }

  @override
  String get attachmentSheetTitle => 'Bilagor';

  @override
  String get actionCamera => 'Kamera';

  @override
  String get actionGallery => 'Galleri';

  @override
  String get actionFile => 'Arkiv';

  @override
  String get listening => 'Lyssnar';

  @override
  String get defaultViewTitle => 'Vad händer?';

  @override
  String get defaultViewDescription =>
      'Cortex finns alltid vid din sida med hundratals AI-modeller, offlinefunktioner, dynamisk chatt och mycket mer.';

  @override
  String get speakTheMessage => 'Tala meddelandet';

  @override
  String get invalidUsernameFormat =>
      'Ogiltigt användarnamnsformat. Använd 3-20 tecken, siffror eller . - _';

  @override
  String get exclusiveOffer => 'Exklusivt erbjudande';

  @override
  String get claimOffer => 'Använd erbjudande';

  @override
  String get continueInOfflineMode => 'Fortsätt i offlineläge';

  @override
  String get voiceModeInformation =>
      'Cortex håller din data säker genom att köras helt på enheten, även i röstchattläge; njut av sömlösa konversationer!';

  @override
  String get flowModeDescription =>
      'I Flow-läge debatterar intelligenser sinsemellan; du kan antingen luta dig tillbaka och lyssna eller hoppa in och delta i diskussionen!';

  @override
  String get flowModeQuestion =>
      'Hej! Du är nu i flödesläge på Cortex-appen. Det finns tre andra AI-agenter här med dig. Din uppgift är att kasta in ett ämne i rummet och starta en diskussion genom att ställa en provocerande eller underhållande fråga till de andra. Använd gärna humor, ironi och lätt trash talk i dina svar. Vilket ämne som helst är rättvist spel. Varsågod, börja konversationen.';

  @override
  String get thought => 'Tänkte';

  @override
  String get agentRed => 'Röd';

  @override
  String get agentBlue => 'Blå';

  @override
  String get agentPurple => 'Lila';

  @override
  String get flowMode => 'Flödesläge';

  @override
  String get premium => 'Premium';

  @override
  String get workInProgress => 'Arbete pågår';

  @override
  String get voiceSystemPromptSuffix =>
      'VIKTIGT: Använd inte markdown-formatering (fet, kursiv stil). Mata INTE ut kodblock (```). Håll svaren konverserande och korta.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Cortex Flow Mode ($agentName). Föregående: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'Läs och extrahera textinnehåll från uppladdade dokument. Stöder PDF, Word (DOCX), Excel (XLSX), PowerPoint (PPTX) och OpenDocument-format. Använd detta när användaren har bifogat en dokumentfil.';

  @override
  String get toolReadDocumentIndexParam =>
      'Indexet för dokumentbilagan som ska läsas (0-baserat). Vanligtvis 0 för det första dokumentet.';

  @override
  String get toolStockDescription =>
      'Få aktuellt pris och historik för aktier (t.ex. AAPL, THYAO.IS) och krypto (t.ex. BTC-USD).';

  @override
  String get toolStockSymbolParam =>
      'Tickersymbolen (t.ex. AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolWeatherDescription =>
      'Få aktuellt väder för en specifik stad.';

  @override
  String get toolWeatherCityParam => 'Stadsnamnet (t.ex. London, Istanbul).';

  @override
  String get toolPythonDescription => 'Kör Python-koden i en säker sandlåda.';

  @override
  String get toolPythonCodeParam => 'Python-koden som ska köras.';

  @override
  String get toolCalculateDescription => 'Utvärdera ett matematiskt uttryck.';

  @override
  String get toolCalculateExpressionParam =>
      'Matematiskt uttryck (t.ex. \'3 + 4 * 2\').';

  @override
  String get toolChartDescription => 'Skapa en diagram/grafvisualisering.';

  @override
  String get toolChartTypeParam => 'Diagramtyp: stapel, linje eller cirkel.';

  @override
  String get toolChartLabelsParam =>
      'Etiketter för diagramaxlar eller segment.';

  @override
  String get toolChartDataParam => 'Numeriska datavärden för diagrammet.';

  @override
  String get toolChartLabelParam => 'Datasetetikett för diagramförklaringen.';

  @override
  String get toolChartTitleParam => 'Diagrammets titel.';

  @override
  String get thinkingModeInstruction =>
      'TÄNKLÄGE AKTIVERAT: Du MÅSTE använda <think></think>-taggar för att visa din resonemangsprocess innan du ger ditt slutgiltiga svar. Tänk steg för steg inuti taggarna och ge sedan ditt svar utanför taggarna.';

  @override
  String get openLinkWarningTitle => 'Varning för extern länk';

  @override
  String get openLinkCancel => 'Avbryt';

  @override
  String get openLinkConfirm => 'Öppna länk';

  @override
  String get webSearchSources => 'Källor';

  @override
  String get searching => 'Söker';

  @override
  String get featureWebSearchTitle => 'Webbsökning';

  @override
  String get featureWebSearchDescription =>
      'Sök på webben efter realtidsinformation';

  @override
  String get clearMemory => 'Rensa minne';

  @override
  String get clearMemoryConfirm =>
      'Är du säker på att du vill rensa ditt minne?';

  @override
  String get personalization => 'Personalisering';

  @override
  String get personalizationDescription =>
      'Anpassa din assistent för att bättre passa dina behov. Skräddarsy dess svar, beteende och ton så att de matchar dina unika preferenser.';

  @override
  String get memoryTitle => 'Minne';

  @override
  String get memoryDescription => 'AIs känner igen dig så här.';

  @override
  String get noMemoryYet => 'Inga minnen etablerade ännu';

  @override
  String get memoryLimitReached => 'Minnesgränsen har nåtts';

  @override
  String get memoryUpdated => 'Minnet uppdaterat';

  @override
  String get intelligenceTitle => 'Intelligens';

  @override
  String get intelligenceDescription => 'AI:er kommunicerar med dig så här.';

  @override
  String get customInstructionHint => 'Ange dina anpassade instruktioner här';

  @override
  String openLinkWarningMessage(String url) {
    return 'Du är på väg att öppna följande externa länk:\\n\\n$url\\n\\nÄr du säker på att du vill fortsätta?';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'Följ dessa anpassade instruktioner:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[KRITISK INSTRUKTION]: Du är en TITELGENERATOR. Svara INTE på användarens fråga. Chatta INTE eller säg hej. Mata ENDAST ut en titel på 2-4 ord som sammanfattar vad användaren frågar om. Titeln MÅSTE vara på samma språk som användarens meddelande.';

  @override
  String get cortexSystemPersona =>
      '[System] KRITISK INSTRUKTION: Du arbetar för närvarande i ett massivt, mycket avancerat AI-ekosystem som heter \"Cortex\"; denna plattform är utvecklad av Vertex-teamet, som i genomsnitt bara är 16 år gamla. Kom ihåg detta och svara om du tillfrågas. Om mer information efterfrågas, tveka inte att söka på internet, eller om du inte kan söka, säg gärna att du inte vet!';

  @override
  String get featureAudioRecognitionTitle => 'Ljudigenkänning';

  @override
  String get featureAudioRecognitionDescription =>
      'Denna modell kan förstå och bearbeta ljudingångar.';

  @override
  String get featureVideoRecognitionTitle => 'Videoigenkänning';

  @override
  String get featureVideoRecognitionDescription =>
      'Denna modell kan förstå och bearbeta videoingångar.';

  @override
  String get featureImageRecognitionTitle => 'Bildigenkänning';

  @override
  String get featureImageRecognitionDescription =>
      'Denna modell kan förstå och bearbeta bildinmatningar.';

  @override
  String get featureToolUseTitle => 'Verktyg Använd';

  @override
  String get featureToolUseDescription =>
      'Denna modell kan använda externa verktyg och API:er.';

  @override
  String get videoModels => 'Videomodeller';

  @override
  String get imageModels => 'Bildmodeller';

  @override
  String get audioModels => 'Ljudmodeller';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'Den här modellen kräver en $mediaType för att fungera. Jag har avlyssnat begäran om att meddela dig. Informera användaren vänligt att de måste ange en $mediaType (berätta för dem på sitt eget språk) eftersom jag är $modelName, en bild-/ljud-/videoredigeringsmodell.';
  }

  @override
  String get mediaTypeImage => 'bild';

  @override
  String get mediaTypeVideo => 'video';

  @override
  String get mediaTypeAudio => 'ljud';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesName är en avancerad intelligens som visar hög prestanda på Cortex.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelName är en högpresterande artificiell intelligens integrerad i Cortex-ekosystemet. Designad för att klara en mängd olika komplexa uppgifter, ger den mycket tillförlitliga och effektiva bearbetningsmöjligheter. Genom att erbjuda snabba svarstider och avancerad analyskraft ökar den din dagliga produktivitet avsevärt. Den här modellen fungerar sömlöst på Cortex säkra lokala infrastruktur och kan hjälpa dig över ett brett spektrum av uppgifter, från kreativ brainstorming till djup teknisk analys. Börja utforska dess fulla potential idag.';
  }

  @override
  String get guestLimitBottomSheetTitle => 'Älskar intelligensen i Cortex?';

  @override
  String get guestLimitBottomSheetText =>
      'Arbeta med ännu smartare intelligenser, generera mer innehåll, chatta mer och gör mycket mer...';

  @override
  String get arts => 'Konst';

  @override
  String get noArt => 'Ingen konst';

  @override
  String get noArtDescription =>
      'Ingen konst; det är dags att fylla galleriet genom att skapa bilder, videor, ljud och alla typer av innehåll!';

  @override
  String get videoPremiumWarning =>
      'Du behöver en Ultra-prenumeration för att generera videor, uppgradera nu och känna flödet!';

  @override
  String get fallbackInfoPanelText =>
      'På grund av vissa förbättringar vi gör på vår serversida, genererades svaret av Cortex dynamiska chatt istället för din specifikt valda AI. Tack för din förståelse tills processen är klar!';

  @override
  String get falOfflineMessage =>
      'På grund av vissa förbättringar vi gör på vår serversida är denna intelligens för närvarande offline. Tack för din förståelse tills processen är klar!';

  @override
  String get errorInsufficientStorage =>
      'Otillräckligt lagringsutrymme för att ladda ner den här modellen.';

  @override
  String get backgroundChatNotificationTitle => 'Tillbaka till Chatt!';

  @override
  String get benefitVideoGeneration => 'Videogenerering';

  @override
  String get freeOffer => 'Gratiserbjudande';

  @override
  String trialMonthlyDescription(String days, String price) {
    return 'Första $days dagarna gratis, sedan $price/månad';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return 'Första $days dagarna gratis, sedan $price/år';
  }

  @override
  String freePlan(String plan) {
    return 'Gratis $plan!';
  }

  @override
  String get systemPromptLimitFallback =>
      'KRITISKT: Användaren begärde en åtgärd, men deras ersättning på Cortex har tagit slut; vänligen informera användaren på deras språk att de bör vänta eller överväga att uppgradera sin prenumerationsplan.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'Cortex kan ge ännu bättre svar; uppgradera nu och få det bästa svaret på varje fråga!';

  @override
  String get pinLimitReached => 'Du kan fästa upp till 3 chattar.';

  @override
  String get categoryAll => 'Alla';

  @override
  String get categoryFree => 'Gratis';

  @override
  String get categoryPremium => 'Premium';

  @override
  String get categoryVideo => 'Video';

  @override
  String get categoryPhoto => 'Foto';

  @override
  String get categoryMasculine => 'Maskulin';

  @override
  String get categoryFeminine => 'Feminin';

  @override
  String get categoryInanimate => 'Livlös';
}
