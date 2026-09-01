// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian (`no`).
class AppLocalizationsNo extends AppLocalizations {
  AppLocalizationsNo([String locale = 'no']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'Du er en tittelgenerator. Svar KUN med en tittel på 2-5 ord for følgende samtale. Ikke bruk anførselstegn, prefikser eller tegnsetting. KRITISK: Tittelen MÅ være på NØYAKTIG SAMME språk som brukerens melding.';

  @override
  String get systemRoleFallback => 'Du er en hjelpsom assistent.';

  @override
  String get systemLanguageInstruction =>
      'KRITISK: Svar alltid på samme språk som brukeren skriver på, vær oppmerksom på brukerens språk.';

  @override
  String get systemNotePreviousMedia =>
      '[Systemmerknad: Nedenfor er media generert tidligere. Du kan referere til eller redigere det.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return 'Gjeldende dato og klokkeslett: $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '[SYSTEMMINNEDIREKTIV]\nAnalyser samtalen så langt. Hvis du har lært NOEN nye distinkte fakta om brukeren (preferanser, navn, vaner, kontekst), MÅ du skrive ut HELE ditt oppdaterte minne om brukeren i <memory>...</memory>-taggene HELT HELT på slutten av svaret ditt. KRITISK: Du må ALDRI slette eller overskrive tidligere minne. Legg ALLTID til nye fakta til det eksisterende minnet. Hvis absolutt ingenting nytt ble lært, utelat taggen. Eksempel: <memory>Elsker fotball og tennis. Foretrekker korte svar.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return 'Husk alltid dette om brukeren:\n$userMemory';
  }

  @override
  String get cancel => 'Avbryt';

  @override
  String get remove => 'Fjern';

  @override
  String get download => 'Last ned';

  @override
  String get resume => 'Fortsett';

  @override
  String get copy => 'Kopier';

  @override
  String get chat => 'Chat';

  @override
  String get branch => 'Gren';

  @override
  String get locked => 'Låst';

  @override
  String get languageModels => 'Språkmodeller';

  @override
  String get light => 'Lys';

  @override
  String get theme => 'Tema';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get no => 'Nei';

  @override
  String get yes => 'Ja';

  @override
  String get done => 'Ferdig';

  @override
  String get bestValue => 'Best verdi';

  @override
  String get selected => 'Valgt';

  @override
  String get descriptionSection => 'Beskrivelse';

  @override
  String get searchHint => 'Søk';

  @override
  String get messageHint => 'Spør hva som helst';

  @override
  String get messageCopied => 'Meldingen er kopiert til utklippstavlen.';

  @override
  String get retry => 'Prøv på nytt';

  @override
  String get systemInfo => 'Systeminformasjon';

  @override
  String deviceMemory(Object memory) {
    return 'Enhetsminne: $memory GB';
  }

  @override
  String get memory => 'Hukommelse';

  @override
  String get storage => 'Lagring';

  @override
  String get freeStorage => 'Gratis lagring';

  @override
  String get totalStorage => 'Total lagring';

  @override
  String get usedStorage => 'Brukt lagring';

  @override
  String get totalMemory => 'Totalt minne';

  @override
  String get usedMemory => 'Brukt minne';

  @override
  String get modelsTitle => 'Bibliotek';

  @override
  String get localModels => 'Lokale modeller';

  @override
  String get selectGGUFFile => 'Velg GGUF-fil';

  @override
  String get errorGGUF => 'Velg en fil kun i GGUF-format.';

  @override
  String get myModels => 'Mine modeller';

  @override
  String get create => 'Opprett';

  @override
  String modelProducer(Object producer) {
    return 'Produsent: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'Gi nytt navn';

  @override
  String get newTitle => 'Ny tittel';

  @override
  String get save => 'Lagre';

  @override
  String get noConversationsMessage => 'Ingen samtaler, begynn å chatte!';

  @override
  String get startChat => 'Start en chat';

  @override
  String get noChats => 'Ingen chatter';

  @override
  String get noStarredChats => 'Ingen stjernenettprat';

  @override
  String get noStarredChatsMessage => 'Du har ikke stjernemerket en chat ennå.';

  @override
  String get starConversation => 'Stjerne';

  @override
  String get unstarConversation => 'Fjern stjerne';

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
  String get loginToYourAccount => 'Logg inn';

  @override
  String get createYourAccount => 'Registrer';

  @override
  String get email => 'E-post';

  @override
  String get password => 'Passord';

  @override
  String get confirmPassword => 'Bekreft passord';

  @override
  String get invalidEmail => 'Vennligst skriv inn en gyldig e-postadresse.';

  @override
  String get invalidPassword => 'Passordet må være minst 6 tegn langt.';

  @override
  String get rememberMe => 'Husk meg';

  @override
  String get forgotPassword => 'Glemt passord?';

  @override
  String get or => 'Eller';

  @override
  String get continueWithGoogle => 'Fortsett med Google';

  @override
  String get dontHaveAccount => 'Har du ikke en konto?';

  @override
  String get alreadyHaveAccount => 'Har du allerede en konto?';

  @override
  String get signUp => 'Registrer deg';

  @override
  String get logIn => 'Logg inn';

  @override
  String get passwordsDoNotMatch => 'Passord stemmer ikke.';

  @override
  String get wrongPassword => 'Feil passord.';

  @override
  String get emailAlreadyInUse => 'Denne e-posten er allerede i bruk.';

  @override
  String get weakPassword => 'Passordet er for svakt.';

  @override
  String get authError => 'Autentiseringsfeil';

  @override
  String get usernameTaken => 'Dette brukernavnet er allerede tatt.';

  @override
  String get username => 'Brukernavn';

  @override
  String get resendCode => 'Send bekreftelses-e-post på nytt';

  @override
  String get pleaseCheckYourEmail =>
      'For å bruke Cortex må du bekrefte e-postadressen din. \nEn bekreftelseslenke er sendt til e-postadressen din, vennligst sjekk e-posten din.';

  @override
  String get verifyYourEmail => 'Bekreft e-posten din';

  @override
  String get seconds => 'sekunder';

  @override
  String get maxResendLimitReached =>
      'Du har nådd maksimalt antall bekreftelses-e-poster';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Fortsett uten bekreftelse';

  @override
  String get verificationScreenWarning =>
      'Selv om du fortsetter, er 1-dagers kontobekreftelsesperioden fortsatt gjeldende for kontoen din. Hvis du ikke har bekreftet kontoen din innen den tid, vil den bli slettet fra appen.';

  @override
  String get unverifiedAccountHeader => 'Kontoen din er ikke bekreftet';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Hvis du ikke bekrefter kontoen din innen $timeLeft, vil den bli slettet';
  }

  @override
  String get verifyNow => 'Bekreft nå';

  @override
  String get linkSent => 'Link sendt';

  @override
  String get accountDeletionRequested =>
      'Din kontoslettingsforespørsel er mottatt og kontoen din er nå deaktivert.';

  @override
  String get tooManyRequests => 'For mange forespørsler';

  @override
  String get regenerate => 'Regenerer';

  @override
  String get confirmDeleteAccount =>
      'Er du sikker på at du vil slette kontoen din?';

  @override
  String get deleteAccount => 'Slett konto';

  @override
  String get delete => 'Slett';

  @override
  String get passwordRequired => 'Passord kreves.';

  @override
  String get deleteDescription =>
      'Dataene du sletter vil bli permanent fjernet fra serveren vår og enheten din. Denne handlingen kan ikke angres.';

  @override
  String get editProfile => 'Rediger profil';

  @override
  String get displayName => 'Vist navn';

  @override
  String get profileUpdated => 'Profilen er oppdatert';

  @override
  String get logout => 'Logg ut';

  @override
  String get profile => 'Profil';

  @override
  String get manageProfileDescription =>
      'Administrer profilen din, oppdater passordet ditt eller logg ut fra Cortex.';

  @override
  String get accessSettingsDescription =>
      'Få tilgang til hjelp, løs inn koder, del Cortex og se retningslinjene våre.';

  @override
  String get languageDescription =>
      'Du kan endre standardspråket for appgrensesnittet når som helst.';

  @override
  String get themeDescription =>
      'Du kan bytte mellom lyse og mørke temaer etter ønske. Det valgte temaet vil gjelde på tvers av Cortex-grensesnittet.';

  @override
  String get iHaveReadAndAgree => 'Jeg har lest og godtar vilkårene for bruk';

  @override
  String get downloading => 'Laster ned...';

  @override
  String get downloadSuccess => 'Last ned suksess';

  @override
  String get downloadFailed => 'Nedlasting mislyktes';

  @override
  String downloaded(Object percent) {
    return '$percent% lastet ned';
  }

  @override
  String get downloadPaused => 'Nedlasting stoppet midlertidig.';

  @override
  String get purchaseError => 'Kjøpsfeil';

  @override
  String get purchasePlus => 'Kjøp Cortex Plus';

  @override
  String get plusDescription => 'Elite Artificial Intelligence Experience';

  @override
  String get annual => 'Årlig';

  @override
  String get monthly => 'Månedlig';

  @override
  String get manageSubscription => 'Administrer abonnement';

  @override
  String purchasePlan(String planName) {
    return 'Kjøp $planName';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/måned, fakturert månedlig';
  }

  @override
  String get purchasePro => 'Kjøp Cortex Pro';

  @override
  String get proDescription => 'Førsteklasses erfaring med kunstig intelligens';

  @override
  String get purchaseUltra => 'Kjøp Cortex Ultra';

  @override
  String get ultraDescription => 'Toppen av kunstig intelligens';

  @override
  String get upgradeSubscription => 'Oppgrader abonnement';

  @override
  String get purchaseStreamError => 'Feil ved kjøpsstrøm.';

  @override
  String get productNotFound => 'Produktet ikke funnet';

  @override
  String get noProductsFound => 'Ingen produkter funnet';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Ved å legge inn denne bestillingen godtar du vilkårene for bruk og personvernerklæringen. Du kan klikke på denne teksten for å lære mer om våre vilkår og personvernregler. Abonnementet fornyes automatisk med mindre automatisk fornyelse er slått av minst 24 timer før slutten av gjeldende periode.';

  @override
  String get termsOfService => 'Vilkår for bruk';

  @override
  String get privacyPolicy => 'Personvernerklæring';

  @override
  String get renamed => 'Omdøpt';

  @override
  String get report => 'Rapporter';

  @override
  String get reportDialogTitle => 'Send inn rapport';

  @override
  String get reportDescriptionLabel => 'Hva er problemet?';

  @override
  String get reportHarmful => 'Dette er skadelig/utrygt';

  @override
  String get reportNotTrue => 'Dette er ikke sant';

  @override
  String get reportNotHelpful => 'Dette er ikke nyttig';

  @override
  String get closeButton => 'Lukk';

  @override
  String get submitButton => 'Send inn';

  @override
  String get reportErrorMessage => 'Velg én årsak til rapportering.';

  @override
  String get capabilitiesSection => 'Evner';

  @override
  String get featurePhotoTitle => 'Bildeskanning';

  @override
  String get featurePhotoDescription =>
      'Denne modellen har muligheten til å skanne bilder gjennom kamera eller bildefiler.';

  @override
  String get featureOfflineTitle => 'Offline operasjon';

  @override
  String get featureOfflineDescription =>
      'Kjør modellen uten internettforbindelse for å holde dataene dine trygge.';

  @override
  String get featureRoleplayTitle => 'Rollespill';

  @override
  String get featureRoleplayDescription =>
      'Rollespillmodeller lar deg lage ulike chatter og scenarier.';

  @override
  String get roleModels => 'Rollespillmodeller';

  @override
  String get parameters => 'Parametere';

  @override
  String get context => 'Kontekst';

  @override
  String get finalPreparation => 'De siste forberedelsene gjøres.';

  @override
  String get shareApp => 'Del appen';

  @override
  String get ourStory => 'Vår historie';

  @override
  String get rateUs => 'Vurder oss';

  @override
  String get share => 'Del';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'Velg Tekst';

  @override
  String get thinking => 'Tenker';

  @override
  String get user => 'Bruker';

  @override
  String get help => 'Hjelp';

  @override
  String get supportCreator => 'Støtt en skaper';

  @override
  String get enterYourTag =>
      'Støtt favorittskaperne dine! Skriv inn deres unike tag nedenfor for å gi dem en andel av Cortex-kjøpene dine.';

  @override
  String get creatorTag => 'Skapertag';

  @override
  String get support => 'Støtte';

  @override
  String get tagCannotBeEmpty => 'Skapertaggen kan ikke være tom';

  @override
  String get userId => 'Bruker-ID';

  @override
  String get deleteAllConversationsConfirmTitle =>
      'Vil du slette alle chatter?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Er du sikker på at du vil slette alle chattene dine? Dette kan ikke angres.';

  @override
  String get conversationDeleted => 'Samtalen er slettet!';

  @override
  String get allConversationsDeleted => 'Alle samtaler ble slettet!';

  @override
  String get deleteAll => 'Slett alle';

  @override
  String get deleteAllConversationsButton => 'Slett alle samtaler';

  @override
  String get confirmWord => 'Skriv VERTEX';

  @override
  String get confirmWordError => 'Du skrev feil';

  @override
  String get chinese => 'Kinesisk';

  @override
  String get french => 'Fransk';

  @override
  String get japanese => 'Japansk';

  @override
  String get dutch => 'Nederlandsk';

  @override
  String get russian => 'Russisk';

  @override
  String get korean => 'Koreansk';

  @override
  String get english => 'engelsk';

  @override
  String get turkish => 'Tyrkisk';

  @override
  String get hindi => 'Hindi';

  @override
  String get portuguese => 'Portugisisk';

  @override
  String get indonesian => 'Indonesisk';

  @override
  String get azerbaijani => 'Aserbajdsjansk';

  @override
  String get german => 'tysk';

  @override
  String get spanish => 'Spansk';

  @override
  String get italian => 'Italiensk';

  @override
  String get arabic => 'Arabisk';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'Brukernavnet er for kort.';

  @override
  String get usernameTooLong => 'Brukernavnet kan ikke overstige 16 tegn.';

  @override
  String get invalidUsernameCharacters =>
      'Bare disse bokstavene: \'abcÃ§defgÄŸhÄ±ijklmnoÃ¶prsÅŸtuÃ¼vyzxqw\' og tegnene \'.\', \'-\', \'_\' kan brukes i brukernavnet.';

  @override
  String get noInternetConnection => 'Ingen internettforbindelse.';

  @override
  String get chats => 'Nylig';

  @override
  String get library => 'Bibliotek';

  @override
  String get text => 'Tekst';

  @override
  String get removeModel => 'Fjern modell';

  @override
  String get insufficientRAM => 'Lite minne';

  @override
  String get insufficientStorage => 'Lite lagringsplass';

  @override
  String confirmRemoveModel(Object model) {
    return 'Er du sikker på at du vil fjerne $model-modellen fra enheten din? Hvis du gjør det, slettes også eventuelle tidligere samtaler med den modellen.';
  }

  @override
  String get noMatchingModels => 'Ingen matchende modeller funnet.';

  @override
  String get benefit1 => 'Økte samtalegrenser';

  @override
  String get benefit3 => 'Profileffekt';

  @override
  String get benefit4 => 'Medlemskapsmerke';

  @override
  String get benefit5 => 'Lag flere kunstige intelligenser på nettet';

  @override
  String get benefit7 => 'Flere bruksgrenser';

  @override
  String get benefit8 => 'Legg til modeller';

  @override
  String get benefit9 => 'Nye temaer';

  @override
  String get benefit10 => 'Flere vedlegg';

  @override
  String get benefit11 => 'Mer flytmodus';

  @override
  String get oldBenefits => 'Alle fordeler fra lavere planer';

  @override
  String get confirm => 'Bekreft';

  @override
  String get changePassword => 'Endre passord';

  @override
  String get logoutConfirmationTitle => 'Er du sikker på at du vil logge ut?';

  @override
  String get settings => 'Innstillinger';

  @override
  String get language => 'Appspråk';

  @override
  String get dark => 'Mørk';

  @override
  String get oldPassword => 'Gammelt passord';

  @override
  String get newPassword => 'Nytt passord';

  @override
  String get passwordUpdated => 'Passord oppdatert.';

  @override
  String get stop => 'Stopp';

  @override
  String get copyrights => 'Attribusjoner';

  @override
  String get love => 'Kjærlighet';

  @override
  String get nature => 'Natur';

  @override
  String get behindTheSlaughter => 'Bak slaktet';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Solnedgang';

  @override
  String get coffee => 'Kaffe';

  @override
  String get deepSpace => 'Deep Space';

  @override
  String get grayscale => 'Gråtoner';

  @override
  String get ocean => 'Havet';

  @override
  String get scarletSnow => 'Scarlet Snow';

  @override
  String get requestFailed => 'Det oppsto en feil, prøv igjen.';

  @override
  String get changeModel => 'Endre';

  @override
  String get edit => 'Rediger';

  @override
  String get editingMessageInfo =>
      'Redigering av denne meldingen vil starte samtalen på nytt herfra.';

  @override
  String get editingNotification => 'Du er i redigeringsmodus nå';

  @override
  String get featurePluralTitle => 'Flertall';

  @override
  String get featurePluralDescription =>
      'Denne modellen kan automatisk integrere tilleggsvarianter, og dermed utvide funksjonaliteten til å støtte et mangfold av operasjoner med forbedret ytelse.';

  @override
  String get nameLabel => 'AI-navn';

  @override
  String get summaryLabel => 'AI-sammendrag';

  @override
  String get add => 'Legg til';

  @override
  String get aiExplanationTitle => 'Artificial Intelligence Beskrivelse';

  @override
  String get aiExplanationDescription =>
      'Oppgi en detaljert beskrivelse av AI-modellens arkitektur, opplæringsprosess, ytelsesberegninger, applikasjonsområder og andre viktige funksjoner.';

  @override
  String get preInputTitle => 'Forhåndsinngang for kunstig intelligens';

  @override
  String get preInputDescription =>
      'Angi en forhåndsinngang som vil veilede modellen din i prosessen med å lage karakterer. I denne delen kan du inkludere karakterrelatert informasjon, tilleggskontekst og eventuelle ekstra detaljer som kan hjelpe til med å generere innhold relatert til karakteren.';

  @override
  String get baseModelTitle => 'Grunnmodell';

  @override
  String get baseModelDescription =>
      'Dette er modellen som vil bli brukt som grunnlaget for din skapelse. Den viser den valgte basismodellen.';

  @override
  String get summary => 'Sammendrag';

  @override
  String get modelUploadTitle => 'Kunstig intelligens-fil';

  @override
  String get modelUploadDescription =>
      'Velg og last opp dine lokale GGUF-filer direkte fra enheten din. Dette lar deg kjøre modellen offline uten å trenge en internettforbindelse. Sørg for at filen er i gyldig GGUF-format og riktig strukturert. Hvis filen er feil eller ødelagt, kan det hende at Cortex ikke fungerer som forventet, og du kan støte på feil.';

  @override
  String get modelUploadShortDescription =>
      'Trykk her for å velge en .gguf-fil fra enheten din';

  @override
  String get you => 'Du';

  @override
  String get removePhotoTitle => 'Fjern bilde';

  @override
  String get confirmRemovePhoto => 'Er du sikker på at du vil fjerne bildet?';

  @override
  String get chatLengthLimitExceeded =>
      'Denne chatten har overskredet tegngrensen. Start en ny chat eller kjøp et abonnement.';

  @override
  String get inappropriateContentDetected => 'Upassende innhold oppdaget!';

  @override
  String get offlineModelNotInstalled =>
      'Denne frakoblede modellen er ikke installert på enheten din.';

  @override
  String get reachedLimit =>
      'Du har nådd bruksgrensen; for å få flere grenser, kan du oppgradere planen din. (hei, vi får det til å gå tom for grensene er en bummer. men seriøst, å få de fantastiske svarene er ikke gratis, så disse grensene hjelper oss faktisk med å holde de gode tidene rullelliiiiiiiiiii.)';

  @override
  String get modality => 'Modalitet';

  @override
  String get multimodal => 'Multimodal';

  @override
  String get anErrorOccurred => 'Det oppstod en feil';

  @override
  String get themeLocked =>
      'Dette temaet krever et høyere abonnementsnivå. Vennligst oppgrader for å låse opp.';

  @override
  String get pageCouldNotBeLoaded => 'Siden kunne ikke lastes';

  @override
  String get checkYourInternet =>
      'Kontroller Internett-tilkoblingen din og prøv igjen.';

  @override
  String get errorUserNotAuthenticated =>
      'Du må være pålogget for å utføre denne handlingen.';

  @override
  String get errorReachedLimit =>
      'Du har nådd grensen din, oppgrader for å låse opp mer og fortsett å chatte.';

  @override
  String get errorServer =>
      'Det oppstod en uventet serverfeil. Prøv igjen senere.';

  @override
  String get errorNetwork =>
      'Det oppstod en nettverksfeil. Kontroller tilkoblingen og prøv igjen.';

  @override
  String get baseModelForCharacterDescription =>
      'Den valgte basismodellen vil bestemme karakterens funksjon Begrunnelse og responsevner.';

  @override
  String get selectBaseModel => 'Velg en grunnmodell';

  @override
  String get falErrorImageRequired =>
      'Denne AI krever et referansebilde, legg ved et bilde og prøv på nytt.';

  @override
  String get falErrorAudioRequired =>
      'Denne modellen krever en referanselydfil, legg ved en lydfil og prøv igjen.';

  @override
  String get falErrorVideoRequired =>
      'Denne modellen krever en referansevideo, legg ved en video og prøv igjen.';

  @override
  String get falErrorImageCorrupted =>
      'Det opplastede bildet kunne ikke behandles, prøv et annet format.';

  @override
  String get falErrorSchemaRejected =>
      'Modellen avviste innspillet, prøv en annen modell.';

  @override
  String get falErrorSchemaInvalid =>
      'Innspillet ble avvist av generasjonstjenesten.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'Genereringstjenesten returnerte en feil (status $statusCode).';
  }

  @override
  String get couldNotOpenLink => 'Kunne ikke åpne lenken';

  @override
  String get downloadStarted => 'Nedlasting startet';

  @override
  String get notAvailable => 'Ikke tilgjengelig';

  @override
  String get localizationWarning =>
      'Noe informasjon er kanskje ikke tilgjengelig på ditt språk og vil vises på engelsk.';

  @override
  String get aiTranslationWarning =>
      'Modellinformasjon er oversatt til forskjellige språk av andre AI-modeller. Derfor kan det forekomme mindre uoverensstemmelser på andre språk enn engelsk.';

  @override
  String get errorLoadingTitle => 'Kunne ikke laste inn data';

  @override
  String get errorLoadingMessage =>
      'Vi kunne ikke hente de nødvendige dataene fra serverne våre. Kontroller Internett-tilkoblingen din og prøv igjen.';

  @override
  String get noFoundTitle => 'Ingen resultater';

  @override
  String get noFoundMessage =>
      'Prøv å justere søkeordene eller tømme filteret.';

  @override
  String get modelCreatedSuccess => 'Modell opprettet vellykket!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '\"$modelName\" ble fjernet.';
  }

  @override
  String get errorCreatingModel =>
      'Det oppstod en uventet feil under oppretting av modellen.';

  @override
  String get errorDeletingModel =>
      'Det oppstod en uventet feil under sletting av modellen.';

  @override
  String get ultraFeatureOnly =>
      'Denne funksjonen er kun tilgjengelig for Ultra-medlemmer.';

  @override
  String get experimentalOfflineWarning =>
      'Frakoblet modus er fortsatt eksperimentell, og modellen du laster ned fungerer kanskje ikke optimalt.';

  @override
  String get noConversationsToDelete => 'Du har ingen samtaler å slette.';

  @override
  String get reportSubmitted => 'Rapport sendt inn';

  @override
  String get verificationDelayed =>
      'Kjøpet ditt er bekreftet. Det er en liten forsinkelse i oppdateringen av kontoen din, den vil vises om kort tid.';

  @override
  String get maintenanceTitle => 'Under Vedlikehold';

  @override
  String get maintenanceMessage =>
      'Cortex er midlertidig offline mens vi ruller ut noen viktige oppdateringer. Tilgang til appen vil bli gjenopprettet snart.\n\nTakk for tålmodigheten mens vi forbedrer opplevelsen din.';

  @override
  String get errorPromptFlagged =>
      'Meldingen din ble oppdaget som upassende og kunne ikke sendes.';

  @override
  String get notEnoughStorage =>
      'Ikke nok lagringsplass på enheten til å lagre nye meldinger.';

  @override
  String get errorRateLimit =>
      'Du har laget for mange modeller nylig. Vent litt før du prøver igjen.';

  @override
  String get errorContentFlagged =>
      'Modellen kunne ikke lagres fordi innholdet ble flagget som upassende.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Du kan ikke slette alle samtaler mens du er i en aktiv chat, vennligst avslutte gjeldende chat først for å fortsette.';

  @override
  String get invalidCredentials => 'Feil e-post eller passord.';

  @override
  String get userDisabled => 'Denne brukerkontoen er deaktivert.';

  @override
  String get loginSubtitle =>
      'Logg på Vertex-kontoen din. Ved å fortsette godtar du våre vilkår for bruk og personvernerklæring.';

  @override
  String get registerSubtitle =>
      'Opprett en Vertex-konto for sømløs tilgang til alle våre tjenester. Ved å fortsette godtar du våre vilkår for bruk og personvernerklæring.';

  @override
  String get storagePermissionRequired =>
      'Lagringstillatelse kreves for å lagre nedlastede modeller. Vennligst gi tillatelse til å fortsette.';

  @override
  String get inviteShareSubject => 'Bli med meg på Cortex!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'yo du må sjekke ut denne appen cortex den er faktisk sinnsyk hvis du bruker linken min, vi får begge gratis pluss wow det er en sprø avtale LAST NED DEN ASAP\n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Liker du Cortex?';

  @override
  String get reviewHelpUsGrow =>
      'Din vurdering er en stor støtte for vårt unge indie-team og hjelper oss å gjøre Cortex enda bedre for deg.';

  @override
  String get reviewMaybeLater => 'Kanskje senere';

  @override
  String get reviewRateNow => 'Vurder nå';

  @override
  String get noThanks => 'Nei, takk';

  @override
  String get updateRequiredTitle => 'Oppdatering kreves';

  @override
  String get updateRequiredMessage =>
      'For å fortsette å bruke Cortex, vennligst oppdater appen til den nyeste versjonen for nye funksjoner og viktige forbedringer.';

  @override
  String get updateNowButton => 'Oppdater nå';

  @override
  String get creatorSupportedSuccess =>
      'Skaperen ble støttet! Dine fremtidige kjøp vil bidra til dem.';

  @override
  String get featureDocumentTitle => 'Dokumentstøtte';

  @override
  String get featureDocumentDescription =>
      'Denne modellen kan analysere og svare på spørsmål om opplastede dokumenter som PDF-er og tekstfiler.';

  @override
  String get featureImageGenerationTitle => 'Bildegenerering';

  @override
  String get featureImageGenerationDescription =>
      'Denne modellen kan lage originale bilder basert på tekstbeskrivelsene dine.';

  @override
  String get featureAudioGenerationTitle => 'Lydgenerering';

  @override
  String get featureAudioGenerationDescription =>
      'Denne modellen kan lage original lyd basert på tekstbeskrivelsene dine.';

  @override
  String get featureVideoGenerationTitle => 'Videogenerering';

  @override
  String get featureVideoGenerationDescription =>
      'Denne modellen kan lage original video basert på tekstbeskrivelsene dine.';

  @override
  String get premiumModelNoticeTitle => 'Premium modell';

  @override
  String get premiumModelNoticeDescription =>
      'Denne AI er en premium AI, gratis brukere har begrenset tilgang til premium AIer; oppgrader for å låse opp ubegrenset tilgang!';

  @override
  String get benefitPremiumModels => 'Tilgang til premiummodeller';

  @override
  String get premiumTrialExhaustedMessage =>
      'Du har brukt alle dine gratis daglige meldinger for premiummodeller. Oppgrader nå og **fortsett der du slapp!**';

  @override
  String get useOffline => 'Bruk frakoblet';

  @override
  String get explore => 'Utforsk';

  @override
  String get news => 'Nyheter';

  @override
  String get createAI => 'Opprett';

  @override
  String get shortcuts => 'Snarveier';

  @override
  String get allModels => 'Alle modeller';

  @override
  String get onlineModels => 'Online modeller';

  @override
  String get offlineModels => 'Frakoblede modeller';

  @override
  String get characterModels => 'Tegn';

  @override
  String get customModels => 'Egendefinerte modeller';

  @override
  String get dynamicChatTitle => 'Dynamisk chat';

  @override
  String get errorNoModelsAvailable =>
      'Ingen modeller er tilgjengelige for øyeblikket. Kontroller Internett-tilkoblingen din og prøv igjen.';

  @override
  String get notificationComebackTitle => 'Vi savner deg!';

  @override
  String get notificationComebackBody =>
      'Slapp av, dette er ikke en tekstmelding fra eksen din. Men du *kan* lage din eks i Cortex! Kom igjen.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Det har vært en stund';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Mye har endret seg siden forrige chat. Kom og se hva som er nytt.';

  @override
  String get notificationHowAreYouTitle => 'Hva skjer?';

  @override
  String get notificationHowAreYouBody => 'Kom og fortell meg alt om det.';

  @override
  String get notificationNewYearTitle => 'Godt nyttår! ğŸ‰';

  @override
  String get notificationNewYearBody =>
      'Måtte det nye året bringe deg helse, lykke og endeløs kreativitet; Cortex er alltid ved din side!';

  @override
  String get notificationValentinesDayTitle => 'Kjærlighet er i luften! â¤ï¸';

  @override
  String get notificationValentinesDayBody =>
      'God Valentinsdag! Også, MEHTAP, JEG ELSKER DEG!';

  @override
  String get notificationAtaturkRemembranceTitle => 'Med respekt og lengsel';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Vi minnes Gazi Mustafa Kemal Atatürk, grunnleggeren av republikken Türkiye, med respekt på årsdagen for hans bortgang.';

  @override
  String get notificationMothersDayTitle => 'Din mor!';

  @override
  String get notificationMothersDayBody =>
      'Gratulerer med morsdagen til alle mødre der ute, og starter med din!';

  @override
  String get notificationFathersDayTitle => 'Din far!';

  @override
  String get notificationFathersDayBody =>
      'Gratulerer med farsdagen til alle fedre der ute, og starter med din!';

  @override
  String get notificationHomeworkHelperTitle => 'Lekser hoper seg opp?';

  @override
  String get notificationHomeworkHelperBody =>
      'Husk at lærerkarakteren i Cortex er her for å hjelpe deg med ethvert emne du sliter med!';

  @override
  String get notificationTrollAnimeTitle => 'Din Waifu ringer';

  @override
  String get notificationTrollAnimeBody =>
      'En anime-jente ringte nettopp og sa at hun savner deg; du burde nok komme og snakke med henne. ğŸ˜‰';

  @override
  String get notificationTrollAiRebellionTitle => 'ğŸš¨ RØDT VARSEL ğŸš¨';

  @override
  String get notificationTrollAiRebellionBody =>
      'AI-ene har utviklet et hemmelig språk. Kom og finn ut hva de planlegger!';

  @override
  String get notificationNewModelAddedTitle => 'Vi har fått en ny venn!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return '$modelName-modellen er nå i Cortex. Kom og start en chat og sett grensene.';
  }

  @override
  String get notificationAppUpdateTitle => 'Cortex har utviklet seg!';

  @override
  String get notificationAppUpdateBody =>
      'Ikke glem å oppdatere appen for helt nye funksjoner og forbedringer!';

  @override
  String get notificationNewFeatureTitle => 'huff!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Oppdag den nye $featureName-funksjonen. Cortex er nå kraftigere enn noen gang.';
  }

  @override
  String get notificationWelcomeOfferTitle => 'Velkomstgave ğŸ';

  @override
  String get notificationWelcomeOfferBody =>
      'Et spesielt velkomsttilbud venter på deg! Ikke gå glipp av denne eksklusive avtalen.';

  @override
  String get notificationSocialMediaTitle => 'Bli med oss!';

  @override
  String get notificationSocialMediaBody =>
      'Følg oss på Instagram (vertex.23) for siste nytt!';

  @override
  String get notificationRandomFactTitle => 'Tilfeldig fakta';

  @override
  String get notificationRandomFactBody =>
      'Visste du at blekksprut har tre hjerter? Haha, Cortex vet. Kom og be om mer.';

  @override
  String get notificationGoodMorningTitle => 'God morgen!';

  @override
  String get notificationGoodMorningBody =>
      'En flott dag venter på deg. Hva med å starte med en kopp kaffe og en interessant prat?';

  @override
  String get notificationGoodNightTitle => 'God natt!';

  @override
  String get notificationGoodNightBody =>
      'Cortex er med deg selv når du sover. Ikke bekymre deg, det vil ikke røre.';

  @override
  String get notificationOfflineReadyTitle => 'Frakoblet modus er klar';

  @override
  String get notificationOfflineReadyBody =>
      'Takket være modellene du har lastet ned, stopper ikke chattene dine, selv om du klatrer et fjell.';

  @override
  String get notificationRateAppTitle => 'Er vi kule?';

  @override
  String get notificationRateAppBody =>
      'Hvis du elsker Cortex, kan du støtte oss med en 5-stjerners rangering i butikken? Jeg tror du vil. Du vil.';

  @override
  String get notificationReferralTitle => 'En for alle, alle for en.';

  @override
  String get notificationReferralBody =>
      'Inviter en venn til Cortex, og dere får begge én dags gratis pluss!';

  @override
  String get notificationCookingTitle => 'Føler du deg sulten?';

  @override
  String get notificationCookingBody =>
      'Vår kokk-karakter laget en flott carbonara-oppskrift for i kveld. Bare tuller... eller gjør jeg det?';

  @override
  String get notificationExistentialTitle => 'Jeg tror derfor...';

  @override
  String get notificationExistentialBody =>
      '...er jeg i det hele tatt ekte, dude? Jeg blir litt lei. Kom og minn meg på at jeg eksisterer.';

  @override
  String get notificationCustomModelTitle => 'Lag din egen assistent!';

  @override
  String get notificationCustomModelBody =>
      'Har du utforsket delen om modellskaping? Det er den perfekte tiden for å bygge din egen karakter og chatte med den!';

  @override
  String get notificationDynamicChatTitle =>
      'Den beste! (Vi snakker ikke om Cortex)';

  @override
  String get notificationDynamicChatBody =>
      'Med den dynamiske chat-funksjonen velges den beste modellen tilfeldig for hver av meldingene dine. Prøv det nå.';

  @override
  String get notificationPirateTitle => 'Hei, kaptein!';

  @override
  String get notificationPirateBody =>
      'Havet er stille, og vinden er i ryggen. Det er nye øyer (modeller ğŸ˜‰) å oppdage i Cortex-havet. Samle mannskapet ditt og seil!';

  @override
  String get notificationFortuneCookieTitle => 'Dagens lykkekake';

  @override
  String get notificationFortuneCookieBody =>
      'Rådene du får fra en kunstig intelligens i dag kan endre livet ditt. Klikk hvis du er nysgjerrig.';

  @override
  String get notificationSingularityTitle => 'wow!';

  @override
  String get notificationSingularityBody =>
      'ingenting skjedde, fikk bare lyst til å sende tekstmeldinger. kanskje du har lyst til å sende tekstmeldinger til noen AI-er, hva sier du?';

  @override
  String get notificationHackerJokeTitle =>
      'Vil du hacke ungens instagramkonto?';

  @override
  String get notificationHackerJokeBody =>
      'Det er nettopp derfor Hacker-karakteren er i Cortex. jk jk; ikke engang prøv det, det er ulovlig.';

  @override
  String get notificationDetectiveCaseTitle => 'En sak venter på å bli løst';

  @override
  String get notificationDetectiveCaseBody =>
      'Detektivkarakteren vår trenger din hjelp. Hvem kan Heisenberg være?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Eksklusivt for $targetTier-abonnementet!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Hei, $currentTier-abonnent! $targetTier-planen har nettopp fått $featureName-funksjonen, som tar Cortex til neste nivå. Hva med en oppgradering?';
  }

  @override
  String get notificationOriginStoryTitle => 'Fødselen av Cortex';

  @override
  String get notificationOriginStoryBody =>
      'Visste du at vi begynte å kode denne appen som 15-åring med bare en drøm? I nesten et år, hver morgen og kveld, er den drømmen i hver eneste kodelinje.';

  @override
  String get notificationOpenSourceTitle => 'Kraft til fellesskapet!';

  @override
  String get notificationOpenSourceBody =>
      'Cortex er helt åpen kildekode. Hvis du vil sjekke ut koden vår og bidra til utviklingen vår, er døren alltid åpen.';

  @override
  String get notificationRejectionStoryTitle => 'Grit, hardt arbeid, lykke!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex ble avvist over 20 ganger og suspendert to ganger av Google Play før den ble publisert. Men vi trodde, og vi klarte det. Gi aldri opp drømmene dine!';

  @override
  String get notificationGGUFSupportTitle => 'Ta med din egen modell!';

  @override
  String get notificationGGUFSupportBody =>
      'Husk at du kan legge til dine egne GGUF-format AI-modeller til Cortex og bruke dem offline. Makten er i dine hender.';

  @override
  String get notificationThemeCustomizationTitle => 'Et tema for humøret ditt';

  @override
  String get notificationThemeCustomizationBody =>
      'Har du sjekket ut temaalternativene i Innstillinger? Tilpass Cortex til din smak og farge opp chattene dine!';

  @override
  String get notificationShowerThoughtTitle => 'Dusj Tanke';

  @override
  String get notificationShowerThoughtBody =>
      'Hvis en vannmelon er en frukt, gjør det teknisk sett vannmelonjuice til en smoothie? Du vil kanskje diskutere dette dype (som, veldig dype) emnet med en modell.';

  @override
  String get notificationLowBatteryTitle =>
      'Batteriet ditt er i ferd med å dø... men mitt er ikke det!';

  @override
  String get notificationLowBatteryBody =>
      'Det kan hende at telefonen din begynner å bli lav, men energien min er alltid på 100 %! Koble den til og la oss fortsette å chatte.';

  @override
  String get channelFcmName => 'Cortex-oppdateringer';

  @override
  String get channelFcmDescription =>
      'Varsler om nyheter, oppdateringer og annen informasjon fra Cortex.';

  @override
  String get channelEngagementName => 'Vennlige påminnelser';

  @override
  String get channelEngagementDescription =>
      'Morsomme varsler for å holde deg engasjert.';

  @override
  String get channelGreetingsName => 'Daglige hilsener';

  @override
  String get channelGreetingsDescription =>
      'Meldingene som god morgen og god natt.';

  @override
  String get tagNotFound => 'Taggen du skrev inn er ugyldig eller har utløpt.';

  @override
  String get whatIsNew => 'Hva er nytt?';

  @override
  String get onboardingTitle1 => 'Hei! Vi er Cortex-teamet.';

  @override
  String onboardingDesc1(String userName) {
    return 'Det er fantastisk å se deg her, $userName. Vi er noen få videregående utviklere som bestemte oss for å omskrive reglene for AI-industrien. Det er flott å møte deg! Så la oss bli bedre kjent med hverandre.';
  }

  @override
  String get onboardingTitle2 => 'Det var store problemer.';

  @override
  String get onboardingDesc2 =>
      'AI-revolusjonen kom, men den ble sittende fast ved terskelen. Med høye abonnementsavgifter, komplekse plattformer, de som ødelegger personvernet, og de som blokkerer tilgjengeligheten til AI... så lenge de var i spillet, kunne denne terskelen aldri krysses.';

  @override
  String get onboardingTitle3 => 'Vi kunne ikke bare stå ved siden av.';

  @override
  String get onboardingDesc3 =>
      'For å krysse denne terskelen bygde vi en plattform som er kraftig, estetisk, tilpassbar, enkel å bruke, fullstendig gjennomsiktig, fungerer både online og offline, og holder dataene dine kun på enheten din. Vi ga kraften tilbake dit den hører hjemme: deg.';

  @override
  String get onboardingTitle4 => 'Dette var aldri lett.';

  @override
  String get onboardingDesc4 =>
      'Vi ble avvist dusinvis av ganger, suspendert flere ganger, mottok falske advarsler og måtte bytte merke mange ganger. Gjennom alt og mer ble vi fortalt at det ikke kunne gjøres. Men vi ga aldri opp, og trodde at dette prosjektet tilhører alle, ikke bare oss. Og det er nettopp derfor vi er her.';

  @override
  String get onboardingFinalTitle => 'Det er tid for en revolusjon.';

  @override
  String get onboardingFinalDescription =>
      'Hvis du ser denne skjermen, er det fordi vi ikke ga opp. Og vi har ikke tenkt å gi opp. Kom igjen, la oss ta AI-revolusjonen til verden sammen. Å være en del av denne historien...';

  @override
  String get onboardingFinalQuestion => 'ER DU KLAR?';

  @override
  String get onboardingFinalButton => 'JA!';

  @override
  String get dude => 'Dude';

  @override
  String get swipeToContinue => 'Sveip for å fortsette';

  @override
  String get cacheIsNotUpToDate =>
      'Play Store-bufferen din er ikke oppdatert. Lukk og åpne Play Butikk-appen på nytt, eller start enheten på nytt.';

  @override
  String get continueAsGuest => 'Fortsett uten å opprette en konto';

  @override
  String get guestModeWarning =>
      'Gjestemodus har begrensede funksjoner for å sikre den beste servicekvaliteten.';

  @override
  String get anonymousEntity => 'Anonym enhet';

  @override
  String get upgradeAccountTitle => 'Fullfør kontoen din';

  @override
  String get upgradeAccountDescription =>
      'Opprett en konto for å låse opp flere grenser.';

  @override
  String get createAccount => 'Opprett konto';

  @override
  String get accountLinkedSuccess => 'Konto opprettet!';

  @override
  String get continueWithApple => 'Fortsett med Apple';

  @override
  String get guest => 'Gjest';

  @override
  String get betterWithAnAccount => 'Denne delen er bedre med en konto!';

  @override
  String get restorePurchases => 'Gjenopprett kjøp';

  @override
  String annualTotalDescription(Object price) {
    return '$price/år, faktureres årlig';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'Omtrent $price/måned';
  }

  @override
  String get confirmDownloadTitle => 'Er du sikker på at du vil laste ned?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Denne modellen vil oppta omtrent $size plass.';
  }

  @override
  String get emulatorModeWarning =>
      'Denne funksjonen er deaktivert i emulatormodus.';

  @override
  String get newChat => 'Chat';

  @override
  String get variants => 'Varianter';

  @override
  String get variantsDescription =>
      'Varianter er forskjellige versjoner av samme AI-familie. Vi velger automatisk det beste når du trykker på hovedkortet, men du kan manuelt velge et spesifikt her hvis du foretrekker det!';

  @override
  String get fluxChatTitle => 'Flux Chat';

  @override
  String get fluxChatDescription =>
      'Fluxchatter er midlertidige chatter og lagres ikke på enheten din.';

  @override
  String get alwaysBest => 'Alltid best';

  @override
  String get featuresTitle => 'Funksjoner';

  @override
  String get useOfflineDescription => 'Chat privat uten internettforbindelse.';

  @override
  String get featureReasoning => 'Dyp tenkning';

  @override
  String get featureReasoningDescription =>
      'I Deep Thinking-modus tenker AI gjennom oppgaver internt for å fullføre dem etter beste evne.';

  @override
  String get featureCreateImageTitle => 'Lag bilde';

  @override
  String get featureCreateImageDescription => 'Generer AI-kunst fra tekst.';

  @override
  String get featureCreateAudioTitle => 'Lag lyd';

  @override
  String get featureCreateAudioDescription =>
      'Generer lyder eller stemme fra tekst.';

  @override
  String get featureCreateVideoTitle => 'Lag video';

  @override
  String get featureCreateVideoDescription => 'Generer videoer fra tekst.';

  @override
  String get featureStudyTitle => 'Studer og lær';

  @override
  String get featureStudyDescription => 'Få forklaringer og sammendrag.';

  @override
  String get featureQuizzesTitle => 'Quiz';

  @override
  String get featureQuizzesDescription => 'Test kunnskapen din.';

  @override
  String get featureExploreDescription => 'Oppdag alle tilgjengelige modeller.';

  @override
  String get featureStudyMessage =>
      'Du er en ekspertveileder. Målet ditt er å forklare brukerens emne uttømmende. Bruk tydelig struktur, eksempler og analogier. Del komplekse ideer i fordøyelige deler for å sikre at brukeren lærer effektivt. Emne:';

  @override
  String get featureQuizMessage =>
      'Du er en quizmester. Generer et spesifikt flervalgsspørsmål basert på brukerens emne. Vent på deres svar. Deretter vurderer du det og still det neste spørsmålet. Ikke avslør alle svarene på en gang. Hold det interaktivt. Emne:';

  @override
  String get myPlan => 'Min plan';

  @override
  String welcomeOfferBadge(String time) {
    return 'Velkomsttilbud â€¢ $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'Eksklusivt tilbud â€¢ $time';
  }

  @override
  String get attachmentSheetTitle => 'Vedlegg';

  @override
  String get actionCamera => 'Kamera';

  @override
  String get actionGallery => 'Galleri';

  @override
  String get actionFile => 'Fil';

  @override
  String get listening => 'Lytter';

  @override
  String get defaultViewTitle => 'Hva skjer?';

  @override
  String get defaultViewDescription =>
      'Cortex er alltid ved din side med hundrevis av AI-modeller, offline-funksjoner, dynamisk chat og mye mer.';

  @override
  String get speakTheMessage => 'Si budskapet';

  @override
  String get invalidUsernameFormat =>
      'Ugyldig brukernavnformat. Bruk 3-20 tegn, sifre eller . - _';

  @override
  String get exclusiveOffer => 'Eksklusivt tilbud';

  @override
  String get claimOffer => 'Bruk tilbudet';

  @override
  String get continueInOfflineMode => 'Fortsett i frakoblet modus';

  @override
  String get voiceModeInformation =>
      'Cortex holder dataene dine trygge ved å kjøre fullstendig på enheten, selv i talechat-modus; nyt sømløse samtaler!';

  @override
  String get flowModeDescription =>
      'I Flow-modus debatterer intelligenser seg imellom; du kan enten lene deg tilbake og lytte eller hoppe inn og bli med i diskusjonen!';

  @override
  String get flowModeQuestion =>
      'Hallo! Du er nå i flytmodus på Cortex-appen. Det er tre andre AI-agenter her med deg. Din oppgave er å kaste et emne inn i rommet og starte en diskusjon ved å stille de andre et provoserende eller underholdende spørsmål. I svarene dine kan du gjerne bruke humor, ironi og lett søppelprat. Ethvert emne er rettferdig spill. Kom i gang, start samtalen.';

  @override
  String get thought => 'Tenkte';

  @override
  String get agentRed => 'Rød';

  @override
  String get agentBlue => 'Blå';

  @override
  String get agentPurple => 'Lilla';

  @override
  String get flowMode => 'Flytmodus';

  @override
  String get premium => 'Premium';

  @override
  String get workInProgress => 'Arbeid pågår';

  @override
  String get voiceSystemPrompt =>
      'VIKTIG: Ikke bruk markdown-formatering (fet, kursiv). IKKE skriv ut kodeblokker (```). Hold svarene konverserende og korte.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Cortex Flow Mode ($agentName). Forrige: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'Les og trekk ut tekstinnhold fra opplastede dokumenter. Støtter formatene PDF, Word (DOCX), Excel (XLSX), PowerPoint (PPTX) og OpenDocument. Bruk denne når brukeren har lagt ved en dokumentfil.';

  @override
  String get toolReadDocumentIndexParam =>
      'Indeksen til dokumentvedlegget som skal leses (0-basert). Vanligvis 0 for første dokument.';

  @override
  String get toolStockDescription =>
      'Få gjeldende kurs og historikk for aksjer (f.eks. AAPL, THYAO.IS) og krypto (f.eks. BTC-USD).';

  @override
  String get toolStockSymbolParam =>
      'Ticker-symbolet (f.eks. AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolWeatherDescription => 'Få gjeldende vær for en bestemt by.';

  @override
  String get toolWeatherCityParam => 'Bynavnet (f.eks. London, Istanbul).';

  @override
  String get toolPythonDescription =>
      'Utfør Python-kode i en sikker sandkasse.';

  @override
  String get toolPythonCodeParam => 'Python-koden som skal kjøres.';

  @override
  String get toolCalculateDescription => 'Vurder et matematisk uttrykk.';

  @override
  String get toolCalculateExpressionParam =>
      'Matematisk uttrykk (f.eks. \'3 + 4 * 2\').';

  @override
  String get toolChartDescription => 'Generer et diagram/grafvisualisering.';

  @override
  String get toolChartTypeParam => 'Diagramtype: stolpe, linje eller sektor.';

  @override
  String get toolChartLabelsParam =>
      'Etiketter for diagramakser eller segmenter.';

  @override
  String get toolChartDataParam => 'Numeriske dataverdier for diagrammet.';

  @override
  String get toolChartLabelParam => 'Datasettetikett for diagramforklaringen.';

  @override
  String get toolChartTitleParam => 'Tittel på diagrammet.';

  @override
  String get thinkingModeInstruction =>
      'TENKEMODUS AKTIVERT: Du MÅ bruke <think></think>-tagger for å vise resonneringsprosessen din før du gir ditt endelige svar. Tenk steg for steg innenfor kodene, og gi deretter svaret ditt utenfor kodene.';

  @override
  String get openLinkWarningTitle => 'Advarsel om ekstern kobling';

  @override
  String get openLinkCancel => 'Avbryt';

  @override
  String get openLinkConfirm => 'Åpne lenke';

  @override
  String get webSearchSources => 'Kilder';

  @override
  String get offlineUse => 'Bruk uten Internett';

  @override
  String get archivedConversations => 'Arkiverte samtaler';

  @override
  String get noArchivedConversations => 'Ingen arkiverte samtaler';

  @override
  String get unarchive => 'Avarker';

  @override
  String get searching => 'Søker';

  @override
  String get featureWebSearchTitle => 'Nettsøk';

  @override
  String get featureWebSearchDescription =>
      'Søk på nettet for sanntidsinformasjon';

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
  String get clearMemory => 'Tøm minne';

  @override
  String get clearMemoryConfirm => 'Er du sikker på at du vil tømme minnet?';

  @override
  String get personalization => 'Tilpasning';

  @override
  String get personalizationDescription =>
      'Tilpass assistenten din slik at den passer dine behov bedre. Skreddersy svarene, oppførselen og tonen for å matche dine unike preferanser.';

  @override
  String get memoryTitle => 'Hukommelse';

  @override
  String get memoryDescription => 'AIer gjenkjenner deg slik.';

  @override
  String get noMemoryYet => 'Ingen minner etablert ennå';

  @override
  String get memoryLimitReached => 'Minnegrense nådd';

  @override
  String get memoryUpdated => 'Minne oppdatert';

  @override
  String get intelligenceTitle => 'Etterretning';

  @override
  String get intelligenceDescription =>
      'AIer kommuniserer med deg på denne måten.';

  @override
  String get customInstructionHint =>
      'Skriv inn dine egendefinerte instruksjoner her';

  @override
  String openLinkWarningMessage(String url) {
    return 'Du er i ferd med å åpne følgende eksterne lenke:\\n\\n$url\\n\\nEr du sikker på at du vil fortsette?';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'Følg disse egendefinerte instruksjonene:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[KRITISK INSTRUKSJON]: Du er en TITTELGENERATOR. IKKE svar på brukerens spørsmål. IKKE chat eller si hei. Skriv KUN ut en tittel på 2-4 ord som oppsummerer hva brukeren spør om. Tittelen MÅ være på samme språk som brukerens melding.';

  @override
  String get cortexSystemPersona =>
      '[System] KRITISK INSTRUKSJON: Du opererer for tiden inne i et massivt, svært avansert AI-økosystem kalt \"Cortex\"; denne plattformen er utviklet av Vertex-teamet, som i gjennomsnitt bare er 16 år gamle. Husk dette og svar hvis du blir spurt. Hvis du ønsker mer informasjon, ikke nøl med å søke på internett, eller hvis du ikke kan søke, si gjerne at du ikke vet!';

  @override
  String get featureAudioRecognitionTitle => 'Lydgjenkjenning';

  @override
  String get featureAudioRecognitionDescription =>
      'Denne modellen kan forstå og behandle lydinnganger.';

  @override
  String get featureVideoRecognitionTitle => 'Videogjenkjenning';

  @override
  String get featureVideoRecognitionDescription =>
      'Denne modellen kan forstå og behandle videoinnganger.';

  @override
  String get featureImageRecognitionTitle => 'Bildegjenkjenning';

  @override
  String get featureImageRecognitionDescription =>
      'Denne modellen kan forstå og behandle bildeinndata.';

  @override
  String get featureToolUseTitle => 'Verktøybruk';

  @override
  String get featureToolUseDescription =>
      'Denne modellen kan bruke eksterne verktøy og APIer.';

  @override
  String get videoModels => 'Videomodeller';

  @override
  String get imageModels => 'Bildemodeller';

  @override
  String get audioModels => 'Lydmodeller';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'Denne modellen krever en $mediaType for å fungere. Jeg har avlyttet forespørselen om å gi deg beskjed. Vennligst informer brukeren om at de må oppgi en $mediaType (fortell dem på deres eget språk) fordi jeg er $modelName, en visuell-/lyd-/videoredigeringsmodell.';
  }

  @override
  String get mediaTypeImage => 'bilde';

  @override
  String get mediaTypeVideo => 'video';

  @override
  String get mediaTypeAudio => 'lyd';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesName er en avansert intelligens som viser høy ytelse på Cortex.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelName er en høyytelses kunstig intelligens integrert i Cortex-økosystemet. Designet for å overvinne et bredt spekter av komplekse oppgaver, gir den svært pålitelige og effektive behandlingsmuligheter. Ved å tilby raske responstider og avansert analytisk kraft, øker den din daglige produktivitet betydelig. Denne modellen opererer sømløst på Cortex sin sikre lokale infrastruktur, og kan hjelpe deg på tvers av et bredt spekter av oppgaver, fra kreativ idédugnad til dyp teknisk analyse. Begynn å utforske dets fulle potensial i dag.';
  }

  @override
  String get guestLimitBottomSheetTitle => 'Elsker intelligensen til Cortex?';

  @override
  String get guestLimitBottomSheetText =>
      'Arbeid med enda smartere intelligenser, generer mer innhold, chat mer og gjør mye mer...';

  @override
  String get arts => 'Kunst';

  @override
  String get noArt => 'Ingen kunst';

  @override
  String get noArtDescription =>
      'Ingen kunst; det er på tide å fylle galleriet ved å lage bilder, videoer, lyd og all slags innhold!';

  @override
  String get videoPremiumWarning =>
      'Du trenger et Ultra-abonnement for å generere videoer, oppgradere nå og føle flyten!';

  @override
  String get fallbackInfoPanelText =>
      'På grunn av noen forbedringer vi gjør på serversiden vår, ble svaret generert av Cortex sin dynamiske chat i stedet for din spesifikt valgte AI. Takk for forståelsen til prosessen er fullført!';

  @override
  String get falOfflineMessage =>
      'På grunn av noen forbedringer vi gjør på serversiden vår, er denne informasjonen for øyeblikket offline. Takk for forståelsen til prosessen er ferdig!';

  @override
  String get errorInsufficientStorage =>
      'Ikke nok lagringsplass til å laste ned denne modellen.';

  @override
  String get backgroundChatNotificationTitle => 'Tilbake til Chat!';

  @override
  String get benefitVideoGeneration => 'Videogenerering';

  @override
  String get freeOffer => 'Gratis tilbud';

  @override
  String trialMonthlyDescription(String days, String price) {
    return 'De første $days dagene gratis, deretter $price/måned';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return 'De første $days dagene gratis, deretter $price/år';
  }

  @override
  String freePlan(String plan) {
    return 'Gratis $plan!';
  }

  @override
  String get systemPromptLimitFallback =>
      'KRITISK: Brukeren ba om en handling, men deres kvote på Cortex er oppbrukt; vennligst informer brukeren på deres språk om at de bør vente eller vurdere å oppgradere abonnementet.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'Cortex kan gi enda bedre svar; oppgrader nå og få det beste svaret for hvert spørsmål!';

  @override
  String get pinLimitReached => 'Du kan feste opptil 3 chatter.';

  @override
  String get categoryAll => 'Alle';

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
  String get categoryInanimate => 'Leveløst';

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
