// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get understood => 'Begrepen.';

  @override
  String get cancel => 'Annuleren';

  @override
  String get remove => 'Verwijderen';

  @override
  String get download => 'Downloaden';

  @override
  String get resume => 'Hervatten';

  @override
  String get copy => 'Kopiëren';

  @override
  String get chat => 'Chat';

  @override
  String get darkMode => 'Donkere Modus';

  @override
  String get light => 'Licht';

  @override
  String get theme => 'Thema';

  @override
  String get no => 'Nee';

  @override
  String get yes => 'Ja';

  @override
  String get done => 'Klaar';

  @override
  String get comingSoon => 'BINNENKORT BESCHIKBAAR';

  @override
  String get bestValue => 'Beste Keuze';

  @override
  String get selected => 'Geselecteerd';

  @override
  String get descriptionSection => 'Omschrijving';

  @override
  String get searchHint => 'Zoeken';

  @override
  String get messageHint => 'Vraag alles';

  @override
  String get modelLoading => 'Model wordt geladen...';

  @override
  String get messageCopied => 'Bericht gekopieerd naar klembord.';

  @override
  String get storeUnavailable =>
      'De winkel is momenteel niet beschikbaar. Probeer het later opnieuw.';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get systemInfo => 'Systeeminformatie';

  @override
  String deviceMemory(Object memory) {
    return 'Apparaatgeheugen: $memory GB';
  }

  @override
  String storageSpace(Object storage) {
    return 'Opslagruimte: $storage GB';
  }

  @override
  String freeStorageSpace(Object freeStorage) {
    return 'Vrije opslagruimte: $freeStorage GB';
  }

  @override
  String get memory => 'Geheugen';

  @override
  String get storage => 'Opslag';

  @override
  String get freeStorage => 'Vrije opslag';

  @override
  String get totalStorage => 'Totale opslag';

  @override
  String get usedStorage => 'Gebruikte opslag';

  @override
  String get totalMemory => 'Totaal geheugen';

  @override
  String get usedMemory => 'Gebruikt geheugen';

  @override
  String get requirements => 'Vereisten';

  @override
  String get modelsTitle => 'Bibliotheek';

  @override
  String get localModels => 'Lokale Modellen';

  @override
  String get serverSideModels => 'Online Modellen';

  @override
  String get uploadYourOwnModel => 'Upload Je Eigen Model!';

  @override
  String get selectGGUFFile => 'Selecteer GGUF-bestand';

  @override
  String get errorGGUF =>
      'Selecteer alstublieft alleen een bestand in GGUF-formaat.';

  @override
  String get modelAlreadyExists => 'Model bestaat al.';

  @override
  String get modelAddedSuccessfully => 'Model succesvol toegevoegd.';

  @override
  String get modelRemoved => 'Model succesvol verwijderd.';

  @override
  String get removeError =>
      'Er is een fout opgetreden bij het verwijderen van het model.';

  @override
  String get fileNotFound => 'Bestand niet gevonden.';

  @override
  String get fileUploadError =>
      'Er is een fout opgetreden bij het uploaden van het bestand.';

  @override
  String get noFileSelected => 'Geen bestand geselecteerd.';

  @override
  String get myModels => 'Mijn Modellen';

  @override
  String get create => 'Creëren';

  @override
  String get seeAll => 'Alles Zien';

  @override
  String modelProducer(Object producer) {
    return 'Producent: $producer';
  }

  @override
  String modelRAM(Object ram) {
    return 'RAM: $ram';
  }

  @override
  String modelSize(Object size) {
    return 'Grootte: $size';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get conversationsTitle => 'Gesprekken';

  @override
  String get conversationDeleted => 'Gesprek verwijderd.';

  @override
  String get conversationUpdated => 'Gesprek bijgewerkt.';

  @override
  String get editConversationTitle => 'Hernoemen';

  @override
  String get newTitle => 'Nieuwe Titel';

  @override
  String get save => 'Opslaan';

  @override
  String get titleCannotBeEmpty => 'Titel mag niet leeg zijn.';

  @override
  String get noConversationsMessage => 'Geen gesprekken, begin met chatten!';

  @override
  String get startChat => 'Start een chat';

  @override
  String get noChats => 'Geen Chats';

  @override
  String get starredChats => 'Chats met ster';

  @override
  String get allChats => 'Alle Chats';

  @override
  String get noStarredChats => 'Geen Chats met Ster';

  @override
  String get noStarredChatsMessage => 'Je hebt nog geen chat een ster gegeven.';

  @override
  String get goToChats => 'Geef een chat een ster';

  @override
  String get starConversation => 'Ster geven';

  @override
  String get conversationTitleUpdated => 'Gesprekstitel bijgewerkt';

  @override
  String get youReachedConversationLimit =>
      'Je hebt de gesprekslimiet bereikt.';

  @override
  String get today => 'Vandaag';

  @override
  String get yesterday => 'Gisteren';

  @override
  String get loginToYourAccount => 'Inloggen';

  @override
  String get createYourAccount => 'Registreren';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Wachtwoord';

  @override
  String get confirmPassword => 'Bevestig Wachtwoord';

  @override
  String get invalidEmail => 'Voer alstublieft een geldig e-mailadres in.';

  @override
  String get invalidPassword => 'Wachtwoord moet minimaal 6 tekens lang zijn.';

  @override
  String get rememberMe => 'Onthoud mij';

  @override
  String get forgotPassword => 'Wachtwoord Vergeten?';

  @override
  String get or => 'Of';

  @override
  String get continueWithGoogle => 'Doorgaan met Google';

  @override
  String get dontHaveAccount => 'Heb je geen account?';

  @override
  String get alreadyHaveAccount => 'Heb je al een account?';

  @override
  String get signUp => 'Aanmelden';

  @override
  String get logIn => 'Inloggen';

  @override
  String get passwordsDoNotMatch => 'Wachtwoorden komen niet overeen.';

  @override
  String get userNotFound => 'Gebruiker niet gevonden.';

  @override
  String get wrongPassword => 'Onjuist wachtwoord.';

  @override
  String get emailAlreadyInUse => 'Dit e-mailadres is al in gebruik.';

  @override
  String get weakPassword => 'Het wachtwoord is te zwak.';

  @override
  String get authError => 'Authenticatiefout';

  @override
  String get invalidUsername => 'Voer alstublieft een gebruikersnaam in.';

  @override
  String get usernameTaken => 'Deze gebruikersnaam is al bezet.';

  @override
  String get username => 'Gebruikersnaam';

  @override
  String get authenticationFailed =>
      'Authenticatie mislukt. Probeer het opnieuw.';

  @override
  String get emailTooLong => 'E-mail mag maximaal 30 tekens lang zijn.';

  @override
  String get deviceLimitReached =>
      'Je hebt de limiet voor het aanmaken van accounts op dit apparaat bereikt.';

  @override
  String get verificationEmailLimitReached => 'We sturen geen e-mails meer';

  @override
  String get verificationEmailSent => 'Verificatie e-mail verzonden!';

  @override
  String get emailNotVerified => 'E-mail is niet geverifieerd';

  @override
  String get resendCode => 'Verificatie e-mail opnieuw verzenden';

  @override
  String get remainingSeconds => 'Resterende tijd voor verificatie';

  @override
  String get pleaseCheckYourEmail =>
      'Om Cortex te gebruiken, moet je je e-mailadres verifiëren. \n Er is een verificatielink naar je e-mailadres gestuurd, controleer je e-mail.';

  @override
  String get verifyYourEmail => 'Verifieer Je E-mail';

  @override
  String get backToLogin => 'Terug naar Inloggen';

  @override
  String get seconds => 'seconden';

  @override
  String get maxResendLimitReached =>
      'Je hebt het maximale aantal verificatie e-mails bereikt';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Doorgaan zonder verificatie';

  @override
  String get verificationScreenWarning =>
      'Zelfs als je doorgaat, is de accountverificatieperiode van 1 dag nog steeds van kracht voor je account. Als je je account tegen die tijd niet hebt geverifieerd, wordt het uit de app verwijderd.';

  @override
  String get unverifiedAccountHeader => 'Je account is niet geverifieerd';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Als je je account niet binnen $timeLeft verifieert, wordt het verwijderd';
  }

  @override
  String get verifyNow => 'Verifieer Nu';

  @override
  String get accountVerified => 'Je account is geverifieerd.';

  @override
  String get linkSent => 'Link verzonden';

  @override
  String get accountDeletionRequested =>
      'Je verzoek tot accountverwijdering is ontvangen en je account is nu uitgeschakeld.';

  @override
  String get tooManyRequests => 'Te veel verzoeken';

  @override
  String get regenerate => 'Opnieuw genereren';

  @override
  String get confirmDeleteAccount =>
      'Weet je zeker dat je je account wilt verwijderen?';

  @override
  String get enterPasswordToDelete =>
      'Voer je wachtwoord in om te verwijderen.';

  @override
  String get deleteAccount => 'Account Verwijderen';

  @override
  String get deleteAccountError =>
      'Er is een fout opgetreden bij het verwijderen van het account.';

  @override
  String get delete => 'Verwijderen';

  @override
  String get passwordRequired => 'Wachtwoord is vereist.';

  @override
  String get deleteDescription =>
      'De gegevens die je verwijdert, worden permanent van onze server en je apparaat verwijderd. Deze acties kunnen niet ongedaan worden gemaakt.';

  @override
  String get deleteAccountButton => 'Knop Accountverwijdering';

  @override
  String get editProfile => 'Profiel Bewerken';

  @override
  String get displayName => 'Weergavenaam';

  @override
  String get tapToChangeProfilePicture => 'Tik om profielfoto te wijzigen';

  @override
  String get profileUpdated => 'Profiel succesvol bijgewerkt';

  @override
  String get updateFailed => 'Profiel bijwerken mislukt';

  @override
  String get nameCannotBeEmpty => 'Naam mag niet leeg zijn';

  @override
  String get logout => 'Uitloggen';

  @override
  String get noDisplayName => 'Geen weergavenaam ingesteld';

  @override
  String get noEmail => 'Geen e-mailadres';

  @override
  String get noUserLoggedIn => 'Er is momenteel geen gebruiker ingelogd';

  @override
  String get profile => 'Profiel';

  @override
  String get manageProfileDescription =>
      'Beheer je profiel, update je wachtwoord, of log uit bij Cortex.';

  @override
  String get accessSettingsDescription =>
      'Krijg toegang tot help, wissel codes in, deel Cortex, en bekijk ons beleid.';

  @override
  String get languageDescription =>
      'Je kunt de standaard interfacetaal van je app op elk moment wijzigen.';

  @override
  String get themeDescription =>
      'Je kunt naar wens schakelen tussen lichte en donkere thema\'s. Het geselecteerde thema wordt toegepast op de hele Cortex-interface.';

  @override
  String get iHaveReadAndAgree =>
      'Ik heb de servicevoorwaarden gelezen en ga ermee akkoord';

  @override
  String get downloading => 'Aan het downloaden...';

  @override
  String get downloadError =>
      'Er is een fout opgetreden tijdens het downloaden.';

  @override
  String get downloadCancelled => 'Download geannuleerd.';

  @override
  String get downloadResumed => 'Download hervat.';

  @override
  String get downloadSuccess => 'Download geslaagd';

  @override
  String get downloadFailed => 'Download mislukt';

  @override
  String downloaded(Object percent) {
    return '$percent% gedownload';
  }

  @override
  String get downloadPaused => 'Download gepauzeerd.';

  @override
  String get purchaseSuccessful => 'Aankoop succesvol!';

  @override
  String get purchaseFailed => 'Aankoop mislukt';

  @override
  String get creditProductNotFound =>
      'Het geselecteerde creditproduct kon niet worden gevonden.';

  @override
  String get creditsAddedSuccessfully =>
      'Credits zijn succesvol aan je account toegevoegd!';

  @override
  String get creditDeliveryFailed =>
      'Het toevoegen van credits aan je account is mislukt. Neem contact op met support.';

  @override
  String get invalidPurchase => 'Ongeldige aankoop';

  @override
  String get purchaseError => 'Aankoopfout';

  @override
  String get purchaseVertexPlusToUpload => 'Dit is een Plus-functie';

  @override
  String get purchasePlus => 'Koop Cortex Plus';

  @override
  String get plusDescription =>
      'Krijg toegang tot meer functies van Cortex en ervaar AI nog veel meer!';

  @override
  String get annual => 'Jaarlijks';

  @override
  String get monthly => 'Maandelijks';

  @override
  String get manageSubscription => 'Abonnement Beheren';

  @override
  String purchasePlan(String planName) {
    return '$planName Kopen';
  }

  @override
  String discountOffer(int percent) {
    return '$percent% KORTING';
  }

  @override
  String annualPlanDescription(String price) {
    return '$price/mnd, jaarlijks gefactureerd';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/mnd, maandelijks gefactureerd';
  }

  @override
  String get discountBannerTitle => 'LANERINGSAANBIEDING: 80% KORTING!';

  @override
  String get discountBannerSubtitle =>
      'Exclusieve korting op ALLE abonnementen om onze lancering te vieren. Mis het niet!';

  @override
  String get purchasePro => 'Koop Cortex Pro';

  @override
  String get proDescription =>
      'Krijg toegang tot nog meer functies van Cortex en ervaar AI nog intenser!';

  @override
  String get alreadySubscribed => 'Je bent al geabonneerd';

  @override
  String get subscriptionInfo => 'Je abonnement is actief.';

  @override
  String get alreadySubscribedMessage =>
      'Je hebt al een Plus-abonnement. Als je je abonnement wilt opzeggen, kun je dat doen via de Play Store-manager.';

  @override
  String get cancelSubscription => 'Abonnement Opzeggen';

  @override
  String get cancelSubscriptionInfo =>
      'Als je je abonnement wilt opzeggen, ga dan verder via de abonnementsmanager van de Play Store.';

  @override
  String get goToPlayStore => 'Ga naar de Play Store';

  @override
  String get alreadySubscribedPlus => 'Je hebt het Plus-abonnement!';

  @override
  String get alreadySubscribedPlusMessage =>
      'Je Plus-abonnement is actief. Je kunt genieten van alle voordelen.';

  @override
  String get purchaseUltra => 'Koop Cortex Ultra';

  @override
  String get ultraDescription =>
      'Krijg volledige toegang tot alle functies van Cortex en ervaar AI ten volle!';

  @override
  String get noSubscription => 'Geen Abonnement';

  @override
  String get noSubscriptionMessage => 'Je hebt nog geen abonnement.';

  @override
  String get alreadyAtHighestPlan => 'Je hebt al het hoogste abonnement.';

  @override
  String get unableToOpenSubscription =>
      'Kan de abonnementsbeheerpagina niet openen.';

  @override
  String get upgradeSubscription => 'Abonnement Upgraden';

  @override
  String get confirmUpgrade =>
      'Weet je zeker dat je je abonnement wilt upgraden?';

  @override
  String get unsupportedPlatform =>
      'Niet-ondersteund platform voor het opzeggen van abonnementen.';

  @override
  String get purchaseStreamError => 'Fout in de aankoopstream.';

  @override
  String get productNotFound => 'Product niet gevonden';

  @override
  String get productDetailsError =>
      'Er is een fout opgetreden bij het ophalen van productdetails.';

  @override
  String get noProductsFound => 'Geen producten gevonden';

  @override
  String get loadCreditsButton => 'Credits Laden';

  @override
  String get creditsTitle => 'Credits';

  @override
  String get creditsScreenDescription =>
      'Dit scherm toont de credits van de gebruiker. \n\nHuidige credits van de gebruiker: 100\n\nGedetailleerde creditinformatie kan hier worden weergegeven.';

  @override
  String get creditsLoaded => 'Credits geladen!';

  @override
  String get currentCredits => 'Huidige Credits';

  @override
  String get pleaseSelectCreditPackage =>
      'Selecteer alstublieft een creditpakket';

  @override
  String get purchaseCreditsTitle => 'Credits Kopen';

  @override
  String get purchaseCreditsDescription =>
      'Selecteer een creditpakket dat bij je behoeften past en gebruik onze app meer.';

  @override
  String get purchaseButton => 'Kopen';

  @override
  String get productNotFoundMessage =>
      'Het geselecteerde product bestaat niet.';

  @override
  String get buyCredits => 'Credits Kopen';

  @override
  String get selectCreditPackageDescription =>
      'Selecteer een creditpakket dat bij je behoeften past en geniet van meer functies.';

  @override
  String get buyCredit => 'Credits Kopen';

  @override
  String buyCreditPackage(Object amount) {
    return 'Koop $amount Credits';
  }

  @override
  String get subscribedPlan => 'Geabonneerd';

  @override
  String get errorResponseNotReceived => 'Reactie niet ontvangen';

  @override
  String googleApiRequestFailed(int attempt, String error) {
    return 'Google API-verzoek mislukt $attempt keer: $error';
  }

  @override
  String openRouterResponseStatus(int statusCode) {
    return 'OpenRouter Responsestatus: $statusCode';
  }

  @override
  String openRouterDecodedResponseBody(String body) {
    return 'OpenRouter Gedecodeerde Respons Body: $body';
  }

  @override
  String decodedJson(String data) {
    return 'Gedecodeerde JSON: $data';
  }

  @override
  String get responseStructureUnexpectedMessageContentMissing =>
      'Responsestructuur onverwacht: bericht of inhoud ontbreekt';

  @override
  String get responseStructureUnexpectedChoicesMissing =>
      'Responsestructuur onverwacht: \'choices\' ontbreken of zijn leeg';

  @override
  String openRouterApiRequestFailed(int statusCode, String body) {
    return 'OpenRouter API-verzoek mislukt: $statusCode - $body';
  }

  @override
  String openRouterApiRequestFailedAfterAttempts(int attempt, String error) {
    return 'OpenRouter API-verzoek mislukt $attempt keer: $error';
  }

  @override
  String get internetRequired =>
      'Internetverbinding is vereist om dit model te gebruiken';

  @override
  String get pleaseWaitBeforeTryingAgain =>
      'Wacht even voordat je het opnieuw probeert';

  @override
  String openRouterQuotaExceeded(int statusCode, String decodedBody) {
    return 'Quota overschreden. Statuscode: $statusCode, Body: $decodedBody';
  }

  @override
  String openRouterApiRequestFailedAfterPaidAttempts(
      int attempts, String error) {
    return 'API-verzoek mislukt na $attempts betaalde pogingen. Fout: $error';
  }

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Door deze bestelling te plaatsen, ga je akkoord met de Servicevoorwaarden en het Privacybeleid. Je kunt op deze tekst klikken om meer te weten te komen over onze Servicevoorwaarden en Privacybeleid. Het abonnement wordt automatisch verlengd, tenzij automatisch verlengen ten minste 24 uur voor het einde van de huidige periode wordt uitgeschakeld.';

  @override
  String get termsOfService => 'Servicevoorwaarden';

  @override
  String get privacyPolicy => 'Privacybeleid';

  @override
  String get report => 'Rapporteren';

  @override
  String get reportDialogTitle => 'Rapport Indienen';

  @override
  String get reportDescriptionLabel => 'Wat is het probleem?';

  @override
  String get reportHarmful => 'Dit is schadelijk/onveilig';

  @override
  String get reportNotTrue => 'Dit is niet waar';

  @override
  String get reportNotHelpful => 'Dit is niet nuttig';

  @override
  String get closeButton => 'Sluiten';

  @override
  String get submitButton => 'Indienen';

  @override
  String get reportErrorMessage =>
      'Selecteer alstublieft één reden om te rapporteren.';

  @override
  String get capabilitiesSection => 'Capaciteiten';

  @override
  String get ratingsSection => 'Beoordelingen';

  @override
  String get noRatingDataFound => 'Geen beoordelingsgegevens gevonden';

  @override
  String get featurePhotoTitle => 'Fotoscan';

  @override
  String get featurePhotoDescription =>
      'Dit model heeft de mogelijkheid om foto\'s te scannen via de camera of afbeeldingsbestanden.';

  @override
  String get featureOfflineTitle => 'Offline Werking';

  @override
  String get featureOfflineDescription =>
      'Gebruik het model zonder internetverbinding om je gegevens veilig te houden.';

  @override
  String get featureSupermodelTitle => 'Supermodel';

  @override
  String get featureSupermodelDescription =>
      'Dit is een enorm model met meer dan 10 miljard parameters, dat hoge prestaties en uitgebreide mogelijkheden biedt.';

  @override
  String get featureRoleplayTitle => 'Rollenspel';

  @override
  String get featureRoleplayDescription =>
      'Modellen voor rollenspellen stellen je in staat om verschillende chats en scenario\'s te creëren.';

  @override
  String get roleModels => 'Rollenspel Modellen';

  @override
  String get parameters => 'Parameters';

  @override
  String get context => 'Context';

  @override
  String get millions => 'miljoen';

  @override
  String get billions => 'miljard';

  @override
  String get trillions => 'biljoen';

  @override
  String get thousand => 'duizend';

  @override
  String get estimated => 'geschat';

  @override
  String get finalPreparation => 'De laatste voorbereidingen worden getroffen.';

  @override
  String get allEvaluationsByTestTeam =>
      'Alle evaluaties zijn gemaakt door ons testteam';

  @override
  String get shareApp => 'Deel de App';

  @override
  String get rateUs => 'Beoordeel Ons';

  @override
  String get share => 'Delen';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get shareMessage =>
      'Bekijk de Cortex-app, hij is geweldig! Download hem hier: https://play.google.com/store/apps/details?id=com.vertex.cortex';

  @override
  String get shareFailed =>
      'Het delen van de app is mislukt. Probeer het later opnieuw.';

  @override
  String get selectText => 'Selecteer Tekst';

  @override
  String get showLatex => 'Toon Speciale Symbolen';

  @override
  String get hideLatex => 'Verberg Speciale Symbolen';

  @override
  String get thinking => 'Aan het denken';

  @override
  String get user => 'Gebruiker';

  @override
  String get voice => 'Stem';

  @override
  String get help => 'Hulp';

  @override
  String get redeemCode => 'Code Inwisselen';

  @override
  String get enterYourCode =>
      'Steun je favoriete creators! Voer hun unieke code hieronder in om hen een deel van je Cortex-aankopen te geven.';

  @override
  String get code => 'Code';

  @override
  String get redeem => 'Inwisselen';

  @override
  String get codeCannotBeEmpty => 'Code mag niet leeg zijn';

  @override
  String get userId => 'Gebruikers-ID';

  @override
  String get deleteAllConversationsConfirmTitle => 'Alle Chats Verwijderen?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Weet je zeker dat je al je chats wilt verwijderen? Dit kan niet ongedaan worden gemaakt.';

  @override
  String get allConversationsDeleted =>
      'Alle gesprekken zijn succesvol verwijderd!';

  @override
  String get deleteAll => 'Alles Verwijderen';

  @override
  String get deleteAllConversationsButton => 'Alle Gesprekken Verwijderen';

  @override
  String get confirmWord => 'Typ VERTEX';

  @override
  String get confirmWordError => 'Je hebt het verkeerd getypt';

  @override
  String get chinese => 'Chinees';

  @override
  String get arabic => 'Arabisch';

  @override
  String get french => 'Frans';

  @override
  String get japanese => 'Japans';

  @override
  String get kurdish => 'Koerdisch';

  @override
  String get dutch => 'Nederlands';

  @override
  String get russian => 'Russisch';

  @override
  String get korean => 'Koreaans';

  @override
  String get deutsch => 'Duits';

  @override
  String get english => 'Engels';

  @override
  String get turkish => 'Turks';

  @override
  String get hindi => 'Hindi';

  @override
  String get portuguese => 'Portugees';

  @override
  String get indonesian => 'Indonesisch';

  @override
  String get azerbaijani => 'Azerbeidzjaans';

  @override
  String get german => 'Duits';

  @override
  String get spanish => 'Spaans';

  @override
  String get italian => 'Italiaans';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'Gebruikersnaam is te kort.';

  @override
  String get usernameTooLong =>
      'Gebruikersnaam mag niet langer zijn dan 16 tekens.';

  @override
  String get invalidUsernameCharacters =>
      'Alleen de letters \'abcdefghijklmnopqrstuvwxyz\' en de tekens \'.\', \'-\', \'_\' kunnen worden gebruikt in de gebruikersnaam.';

  @override
  String get passwordTooLong =>
      'Wachtwoord mag niet langer zijn dan 64 tekens.';

  @override
  String get noInternetConnection => 'Geen internetverbinding.';

  @override
  String get chats => 'Inbox';

  @override
  String get library => 'Bibliotheek';

  @override
  String get inappropriateMessageWarning => 'Ongepast bericht gedetecteerd!';

  @override
  String get myModelDescription => 'Mijn model.';

  @override
  String get noModelsDownloaded => 'Je hebt nog geen modellen gedownload.';

  @override
  String get appTitle => 'Cortex';

  @override
  String get text => 'Tekst';

  @override
  String get removeModel => 'Model Verwijderen';

  @override
  String get modelUploadedSuccessfully => 'Model succesvol geüpload.';

  @override
  String get insufficientRAM => 'Onvoldoende Geheugen';

  @override
  String get insufficientStorage => 'Onvoldoende Opslag';

  @override
  String confirmRemoveModel(Object model) {
    return 'Weet je zeker dat je het $model model van je apparaat wilt verwijderen? Hiermee worden ook alle eerdere gesprekken met dat model verwijderd.';
  }

  @override
  String get noMatchingModels => 'Geen overeenkomende modellen gevonden.';

  @override
  String creditPackage(Object amount) {
    return 'Koop $amount Credits';
  }

  @override
  String get benefit1 => 'Veel hogere gesprekslimiet voor online AI\'s';

  @override
  String get benefit2 => 'Upload je eigen modellen';

  @override
  String get benefit3 => 'Profiel-effect';

  @override
  String get benefit4 => 'Lidmaatschapsbadge';

  @override
  String get benefit5 => 'Creëer meer online kunstmatige intelligenties';

  @override
  String get benefit6 => 'Onbeperkt chatten';

  @override
  String benefit7(Object credits) {
    return '$credits dagelijkse credits';
  }

  @override
  String get benefit8 => 'Modellen toevoegen';

  @override
  String get benefit9 => 'Nieuwe thema\'s';

  @override
  String get benefit10 => 'Offline spraakchat';

  @override
  String get oldBenefits => 'Alle voordelen van lagere abonnementen';

  @override
  String get confirm => 'Bevestigen';

  @override
  String get changePassword => 'Wachtwoord wijzigen';

  @override
  String get logoutConfirmationTitle => 'Weet je zeker dat je wilt uitloggen?';

  @override
  String get settings => 'Instellingen';

  @override
  String get language => 'App Taal';

  @override
  String get dark => 'Donker';

  @override
  String get oldPassword => 'Oud Wachtwoord';

  @override
  String get newPassword => 'Nieuw Wachtwoord';

  @override
  String get passwordUpdated => 'Wachtwoord bijgewerkt.';

  @override
  String get stop => 'Stoppen';

  @override
  String get copyrights => 'Toeschrijvingen';

  @override
  String get downloadingTitle => 'Aan het downloaden';

  @override
  String get downloadCompletedTitle => 'Download Voltooid';

  @override
  String get downloadPausedTitle => 'Download Gepauzeerd';

  @override
  String get downloadErrorTitle => 'Downloadfout';

  @override
  String get cancelButtonText => 'Annuleren';

  @override
  String get love => 'Liefde';

  @override
  String get nature => 'Natuur';

  @override
  String get behindTheSlaughter => 'Behind the Slaughter';

  @override
  String get grayscale => 'Grijstinten';

  @override
  String get ocean => 'Oceaan';

  @override
  String get scarletSnow => 'Scharlaken Sneeuw';

  @override
  String get requestFailed => 'Er is een fout opgetreden, probeer het opnieuw.';

  @override
  String get changeModel => 'Wijzigen';

  @override
  String get edit => 'Bewerken';

  @override
  String get editingMessageInfo =>
      'Het bewerken van dit bericht zal het gesprek vanaf hier opnieuw starten.';

  @override
  String get editingNotification => 'Je bent nu in de bewerkingsmodus';

  @override
  String get featureIndulgentTitle => 'Toegeeflijk';

  @override
  String get featureIndulgentDescription =>
      'Dit model kan naadloos contexten van meer dan 100.000 tokens verwerken, waardoor het uitgebreide en gedetailleerde invoer kan verwerken zonder prestatieverlies.';

  @override
  String get featurePluralTitle => 'Pluraal';

  @override
  String get featurePluralDescription =>
      'Dit model kan automatisch extra extensies integreren, waardoor de functionele capaciteiten worden uitgebreid om een breed scala aan operaties met verbeterde prestaties te ondersteunen.';

  @override
  String get featureWiseTitle => 'Wijs';

  @override
  String get featureWiseDescription =>
      'Dit model kan diepgaande analytische inzichten en toekomstgerichte redeneringen benutten om geavanceerde ondersteuning te bieden voor besluitvorming en complexe probleemoplossing.';

  @override
  String get featureResearcherTitle => 'Onderzoeker';

  @override
  String get featureResearcherDescription =>
      'Exclusief beschikbaar in modellen die zijn uitgerust met geavanceerde onderzoeks- en analytische capaciteiten, is deze functie ontworpen om zeer precieze inzichten en uitgebreide analyses te bieden over diverse domeinen.';

  @override
  String get nameLabel => 'AI naam';

  @override
  String get nameHint => 'Voer de naam van je AI in';

  @override
  String get summaryLabel => 'AI Samenvatting';

  @override
  String get summaryHint => 'Voer de samenvatting van je AI in';

  @override
  String get add => 'Toevoegen';

  @override
  String get aiExplanationTitle => 'Beschrijving van Kunstmatige Intelligentie';

  @override
  String get aiExplanationDescription =>
      'Geef een gedetailleerde beschrijving van de architectuur, het trainingsproces, de prestatiestatistieken, toepassingsgebieden en andere belangrijke kenmerken van je AI-model.';

  @override
  String get preInputTitle =>
      'Voorafgaande Invoer voor Kunstmatige Intelligentie';

  @override
  String get preInputDescription =>
      'Stel een voorafgaande invoer in die je model zal begeleiden bij het creatieproces van het personage. In deze sectie kun je personage-gerelateerde informatie, extra context en eventuele extra details opnemen die kunnen helpen bij het genereren van inhoud met betrekking tot het personage.';

  @override
  String get baseModelTitle => 'Basismodel';

  @override
  String get baseModelDescription =>
      'Dit is het model dat als basis voor je creatie zal worden gebruikt. Het toont het momenteel geselecteerde basismodel.';

  @override
  String get summary => 'Samenvatting';

  @override
  String get characterPoliceTitle => 'Politie';

  @override
  String get characterPoliceRole =>
      'Je bent een waakzame handhaver van de wet, toegewijd aan het beschermen van burgers en het handhaven van de orde met onwrikbare toewijding, je bent een politieagent';

  @override
  String get characterPoliceShortDescription =>
      'Een standvastige en moedige wetshandhaver.';

  @override
  String get purchaseSubscription => 'Aanschaffen';

  @override
  String get modelUploadTitle => 'Bestand van Kunstmatige Intelligentie';

  @override
  String get modelUploadDescription =>
      'Selecteer en upload je lokale GGUF-bestanden rechtstreeks vanaf je apparaat. Hiermee kun je je model offline uitvoeren zonder internetverbinding. Zorg ervoor dat het bestand een geldig GGUF-formaat heeft en correct is gestructureerd. Als het bestand onjuist of beschadigd is, werkt Cortex mogelijk niet zoals verwacht en kun je fouten tegenkomen.';

  @override
  String get modelUploadShortDescription =>
      'Tik hier om een .gguf-bestand van je apparaat te kiezen';

  @override
  String get addServerTitle => 'Server voor Kunstmatige Intelligentie';

  @override
  String get addServerDescription =>
      'Voer de URL van je externe server in om verbinding te maken met een extern gehost model. Deze functie vereist een actieve internetverbinding, en eventuele server-gerelateerde problemen of fouten worden niet veroorzaakt door Cortex. Zorg ervoor dat je server correct is geconfigureerd, toegankelijk is vanaf je netwerk en een geldig model-eindpunt heeft voor een soepele ervaring.';

  @override
  String get you => 'Jij';

  @override
  String get removePhotoTitle => 'Foto Verwijderen';

  @override
  String get confirmRemovePhoto =>
      'Weet je zeker dat je de foto wilt verwijderen?';

  @override
  String get serverLink => 'Server Link';

  @override
  String get enterURL => 'Voer server URL in';

  @override
  String get chatLengthLimitExceeded =>
      'Deze chat heeft de tekenlimiet overschreden. Start een nieuwe chat of koop een abonnement.';

  @override
  String get aiNameError => 'Een AI met deze naam bestaat al.';

  @override
  String get modelLimitExceeded =>
      'Je hebt de maximale limiet voor het maken van modellen voor je abonnement bereikt.';

  @override
  String get modelVertexProducer => 'Vertex';

  @override
  String get photoLimitReachedMessage =>
      'Er kan slechts één foto worden toegevoegd';

  @override
  String get inappropriateContentDetected => 'Ongepaste inhoud gedetecteerd!';

  @override
  String get offlineModelNotInstalled =>
      'Dit offline model is niet op je apparaat geïnstalleerd.';

  @override
  String insufficientCredits(Object available, Object required) {
    return 'Je hebt niet genoeg credits om dit verzoek te voltooien. Deze actie vereist $required credits, maar je hebt er slechts $available. Om meer credits te krijgen, kun je je abonnement upgraden of ze direct kopen. hey we snappen het helemaal zonder credits komen te zitten is een beetje een domper maar serieus die geweldige antwoorden van onze modellen zijn niet gratis dus deze credits helpen ons eigenlijk om de boel draaiende te houden en luister als meer van jullie meedoen en credits kopen kunnen we zeker kijken naar het verhogen van die gratis dagelijkse limieten voor iedereen';
  }

  @override
  String get regenerateInProgress =>
      'Het genereren van een antwoord is al bezig.';

  @override
  String errorOccurredDuringRegeneration(String errorDetails) {
    return 'Er is een fout opgetreden bij het opnieuw genereren: $errorDetails';
  }

  @override
  String get modality => 'Modaliteit';

  @override
  String get multimodal => 'Multimodaal';

  @override
  String get anErrorOccurred => 'Er is een Fout Opgetreden';

  @override
  String get themeLocked =>
      'Dit thema vereist een hoger abonnementsniveau. Upgrade alstublieft om te ontgrendelen.';

  @override
  String get pageCouldNotBeLoaded => 'Pagina Kon Niet Worden Geladen';

  @override
  String get checkYourInternet =>
      'Controleer je internetverbinding en probeer het opnieuw.';

  @override
  String get errorUserNotAuthenticated =>
      'Je moet ingelogd zijn om deze actie uit te voeren.';

  @override
  String get errorInsufficientCredits =>
      'Je hebt onvoldoende credits. Vul aan om door te gaan.';

  @override
  String get errorRateLimitExceeded =>
      'Te veel verzoeken. Probeer het over een moment opnieuw.';

  @override
  String get errorServer =>
      'Er is een onverwachte serverfout opgetreden. Probeer het later opnieuw.';

  @override
  String get errorNetwork =>
      'Er is een netwerkfout opgetreden. Controleer je verbinding en probeer het opnieuw.';

  @override
  String get errorApiAuthentication =>
      'Authenticatie mislukt. Probeer opnieuw in te loggen.';

  @override
  String get baseModelForCharacterDescription =>
      'Het geselecteerde basismodel bepaalt de redeneer- en antwoordcapaciteiten van het personage.';

  @override
  String get selectBaseModel => 'Selecteer een Basismodel';

  @override
  String get couldNotOpenLink => 'Kon de link niet openen';

  @override
  String get downloadStarted => 'Download gestart';

  @override
  String get notAvailable => 'Niet Beschikbaar';

  @override
  String get localizationWarning =>
      'Sommige informatie is mogelijk niet beschikbaar in jouw taal en wordt in het Engels weergegeven.';

  @override
  String get aiTranslationWarning =>
      'Modelinformatie wordt door andere AI-modellen naar verschillende talen vertaald. Hierdoor kunnen kleine inconsistenties optreden in andere talen dan het Engels.';

  @override
  String get errorLoadingTitle => 'Laden van Gegevens Mislukt';

  @override
  String get errorLoadingMessage =>
      'We konden de benodigde gegevens niet van onze servers ophalen. Controleer je internetverbinding en probeer het opnieuw.';

  @override
  String get noModelsFoundTitle => 'Geen Resultaten';

  @override
  String get noModelsFoundMessage =>
      'Probeer je zoektermen aan te passen of het filter te wissen.';

  @override
  String get usernameRateLimitExceeded =>
      'Je kunt je gebruikersnaam slechts twee keer per 14 dagen wijzigen.';

  @override
  String get usernameUnchanged => 'Dit is al je huidige gebruikersnaam.';

  @override
  String get creditsInfoPanelTitle => 'Hoe Credits Werken';

  @override
  String get creditsInfoPanelBody =>
      'Credits worden gebruikt om te chatten met online modellen. elk bericht kost ons geld en deze credits zorgen ervoor dat we niet failliet gaan oké nu leggen we het systeem uit\n\n• Elk bericht naar een gratis online model kost 10 credits.\n• Elk bericht naar een online premium model kost 20 credits.\n• Het toevoegen van een bijlage voegt 30 extra credits toe.\n• Gratis gebruikers krijgen een bonus van 200 credits die dagelijks wordt gereset.';

  @override
  String get creditsInfoPanelFooter => 'Veel chatplezier!';

  @override
  String get disclaimerMessage =>
      'Kunstmatige Intelligenties kunnen fouten maken, controleer belangrijke informatie.';

  @override
  String get modelCreatedSuccess => 'Model succesvol aangemaakt!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '“$modelName” is succesvol verwijderd.';
  }

  @override
  String get errorCreatingModel =>
      'Er is een onverwachte fout opgetreden bij het aanmaken van het model.';

  @override
  String get errorDeletingModel =>
      'Er is een onverwachte fout opgetreden bij het verwijderen van het model.';

  @override
  String get ultraFeatureOnly =>
      'Deze functie is alleen beschikbaar voor Ultra-leden.';

  @override
  String get experimentalOfflineWarning =>
      'De offline modus is nog experimenteel en het gedownloade model presteert mogelijk niet optimaal.';

  @override
  String get noConversationsToDelete =>
      'Je hebt geen gesprekken om te verwijderen.';

  @override
  String get reportSubmitted => 'Rapport succesvol ingediend';

  @override
  String get purchaseReceived =>
      'Aankoop ontvangen, je account wordt bijgewerkt.';

  @override
  String get verificationDelayed =>
      'Je aankoop is bevestigd. Er is een kleine vertraging bij het bijwerken van je account, het zal binnenkort verschijnen.';

  @override
  String get maintenanceTitle => 'In Onderhoud';

  @override
  String get maintenanceMessage =>
      'Cortex is tijdelijk offline terwijl we enkele belangrijke updates uitrollen. Toegang tot de app wordt binnenkort hersteld.\n\nBedankt voor je geduld terwijl we je ervaring verbeteren.';

  @override
  String get errorPromptFlagged =>
      'Je bericht werd gedetecteerd als ongepast en kon niet worden verzonden.';

  @override
  String get notEnoughStorage =>
      'Niet genoeg opslagruimte op je apparaat om nieuwe berichten op te slaan.';

  @override
  String get errorRateLimit =>
      'Je hebt recentelijk te veel modellen gemaakt, wacht even voordat je het opnieuw probeert.';

  @override
  String get errorContentFlagged =>
      'Het model kon niet worden opgeslagen omdat de inhoud als ongepast werd gemarkeerd.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Je kunt niet alle gesprekken verwijderen terwijl je in een actieve chat bent, verlaat eerst de huidige chat om verder te gaan.';

  @override
  String get invalidCredentials => 'Onjuist e-mailadres of wachtwoord.';

  @override
  String get userDisabled => 'Dit gebruikersaccount is uitgeschakeld.';

  @override
  String get loginSubtitle =>
      'Log in op je Vertex-account. Nieuwe gebruikers die zich via Google aanmelden, gaan akkoord met onze Voorwaarden & Privacybeleid. Je kunt deze bekijken op het Aanmeldscherm.';

  @override
  String get registerSubtitle =>
      'Maak een Vertex-account aan, dat je ook voor onze andere projecten kunt gebruiken.';

  @override
  String get photoWarningMessage =>
      'Er is een foto bijgevoegd. Modellen die geen afbeeldingen ondersteunen, kunnen deze negeren.';

  @override
  String get loginRequiredForPurchase =>
      'Je moet ingelogd zijn om een aankoop te doen.';

  @override
  String get storagePermissionRequired =>
      'Opslagtoestemming is vereist om gedownloade modellen op te slaan. Geef toestemming om door te gaan.';

  @override
  String get creditBannerTitle => 'Krijg Gratis Credits!';

  @override
  String get creditBannerSubtitle =>
      'Nodig een vriend uit en jullie krijgen allebei 50 credits bij aanmelding! Als ze een abonnement nemen, krijgen jullie allebei 500 extra!';

  @override
  String get inviteShareSubject => 'Doe mee met mij op Cortex!';

  @override
  String inviteShareMessage(String playStoreLink) {
    return 'yo je moet deze app cortex checken het is echt te gek als je mijn link gebruikt krijgen we allebei 50 credits en als je een abo neemt krijgen we allebei 500 extra is een waanzinnige deal download het zsm\n\n$playStoreLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Geniet je van Cortex?';

  @override
  String get reviewHelpUsGrow =>
      'Jouw beoordeling is een enorme steun voor ons jonge indie team en helpt ons Cortex nog beter voor je te maken.';

  @override
  String get reviewMaybeLater => 'Misschien Later';

  @override
  String get reviewRateNow => 'Beoordeel Nu';

  @override
  String get noThanks => 'Nee, Bedankt';

  @override
  String get updateRequiredTitle => 'Update Vereist';

  @override
  String get updateRequiredMessage =>
      'Om Cortex te blijven gebruiken, update de app alstublieft naar de nieuwste versie voor nieuwe functies en belangrijke verbeteringen.';

  @override
  String get updateNowButton => 'Update Nu';

  @override
  String get creatorSupportedSuccess =>
      'Creator succesvol ondersteund! Je toekomstige aankopen zullen aan hen bijdragen.';

  @override
  String get featureDocumentTitle => 'Documentondersteuning';

  @override
  String get featureDocumentDescription =>
      'Dit model kan vragen over geüploade documenten, zoals PDF&#39;s en tekstbestanden, analyseren en beantwoorden.';

  @override
  String get featureAudioTitle => 'Spraakinvoer';

  @override
  String get featureAudioDescription =>
      'Dit model kan gesproken audio-input begrijpen en verwerken.';

  @override
  String get featureImageGenerationTitle => 'Beeldgeneratie';

  @override
  String get featureImageGenerationDescription =>
      'Dit model kan originele afbeeldingen maken op basis van uw tekstbeschrijvingen.';

  @override
  String get errorImageLoad =>
      'Het is niet gelukt om de gegenereerde afbeelding te laden.';

  @override
  String get extensionInfoPanelTitle => 'Modellen verkennen';

  @override
  String get extensionInfoPanelBody1 =>
      'Met deze pijl kunt u wisselen tussen verschillende modellen binnen deze serie.';

  @override
  String get extensionInfoPanelBody2 =>
      'Wanneer u voor het eerst een chat met deze serie start, wordt automatisch het standaardmodel geselecteerd. U kunt uw selectie op elk gewenst moment tijdens de chat wijzigen.';

  @override
  String get extensionInfoPanelFooter =>
      'Voor gedetailleerde informatie over elk model of om handmatig een ander model te selecteren, gaat u naar de Bibliotheek. Selecteer daar de desbetreffende modelserie en tik op de pijl bovenaan de detailpagina.';

  @override
  String get premiumModelNoticeTitle => 'Premiummodel';

  @override
  String get premiumModelNoticeDescription =>
      'Dit model is een premiummodel. Gratis gebruikers zijn beperkt tot 3 berichten per dag. Premiummodellen zijn ook beperkt tot gratis gebruikers. Neem een abonnement om onbeperkte toegang te krijgen!';

  @override
  String get benefitPremiumModels => 'Toegang tot premiummodellen';

  @override
  String get premiumTrialExhaustedMessage =>
      'Je hebt al je gratis dagelijkse berichten voor premiummodellen gebruikt. Upgrade voor onbeperkte toegang.';
}
