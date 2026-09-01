// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'Je bent een titelgenerator. Reageer ALLEEN met een titel van 2-5 woorden voor het volgende gesprek. Gebruik geen aanhalingstekens, voorvoegsels of leestekens. BELANGRIJK: De titel MOET in EXACT DEZELFDE taal zijn als het bericht van de gebruiker.';

  @override
  String get systemRoleFallback => 'Je bent een behulpzame assistent.';

  @override
  String get systemLanguageInstruction =>
      '\n\nCRITICAL: Reageer altijd in dezelfde taal als waarin de gebruiker schrijft; let op de taal van de gebruiker.';

  @override
  String get systemNotePreviousMedia =>
      '[Systeemnotitie: Hieronder staat de eerder gegenereerde media. U kunt hiernaar verwijzen of deze bewerken.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return '\n\nHuidige datum en tijd: $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\nAnalyseer het gesprek tot nu toe. Als je OOK maar één nieuw, specifiek feit over de gebruiker hebt geleerd (voorkeuren, naam, gewoonten, context), MOET je je VOLLEDIGE bijgewerkte geheugen over de gebruiker weergeven tussen <memory>...</memory> tags AAN HET EINDE van je antwoord. BELANGRIJK: Je mag NOOIT eerder geheugen wissen of overschrijven. Voeg ALTIJD nieuwe feiten toe aan het bestaande geheugen. Als er absoluut niets nieuws is geleerd, laat je de tag weg. Voorbeeld: <memory>Houdt van voetbal en tennis. Geeft de voorkeur aan korte antwoorden.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return '\n\nOnthoud dit altijd over de gebruiker:\n$userMemory';
  }

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
  String get branch => 'Vertakking';

  @override
  String get locked => 'Locked';

  @override
  String get languageModels => 'Taalmodellen';

  @override
  String get light => 'Licht';

  @override
  String get theme => 'Thema';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get no => 'Nee';

  @override
  String get yes => 'Ja';

  @override
  String get done => 'Klaar';

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
  String get messageCopied => 'Bericht gekopieerd naar klembord.';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get systemInfo => 'Systeeminformatie';

  @override
  String deviceMemory(Object memory) {
    return 'Apparaatgeheugen: $memory GB';
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
  String get modelsTitle => 'Bibliotheek';

  @override
  String get localModels => 'Lokale Modellen';

  @override
  String get selectGGUFFile => 'Selecteer GGUF-bestand';

  @override
  String get errorGGUF =>
      'Selecteer alstublieft alleen een bestand in GGUF-formaat.';

  @override
  String get myModels => 'Mijn Modellen';

  @override
  String get create => 'Creëren';

  @override
  String modelProducer(Object producer) {
    return 'Producent: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'Hernoemen';

  @override
  String get newTitle => 'Nieuwe Titel';

  @override
  String get save => 'Opslaan';

  @override
  String get noConversationsMessage => 'Geen gesprekken, begin met chatten!';

  @override
  String get startChat => 'Start een chat';

  @override
  String get noChats => 'Geen Chats';

  @override
  String get noStarredChats => 'Geen Chats met Ster';

  @override
  String get noStarredChatsMessage => 'Je hebt nog geen chat een ster gegeven.';

  @override
  String get starConversation => 'Ster geven';

  @override
  String get unstarConversation => 'Unstar';

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
  String get wrongPassword => 'Onjuist wachtwoord.';

  @override
  String get emailAlreadyInUse => 'Dit e-mailadres is al in gebruik.';

  @override
  String get weakPassword => 'Het wachtwoord is te zwak.';

  @override
  String get authError => 'Authenticatiefout';

  @override
  String get usernameTaken => 'Deze gebruikersnaam is al bezet.';

  @override
  String get username => 'Gebruikersnaam';

  @override
  String get resendCode => 'Verificatie e-mail opnieuw verzenden';

  @override
  String get pleaseCheckYourEmail =>
      'Om Cortex te gebruiken, moet je je e-mailadres verifiëren. \nEr is een verificatielink naar je e-mailadres gestuurd, controleer je e-mail.';

  @override
  String get verifyYourEmail => 'Verifieer Je E-mail';

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
  String get deleteAccount => 'Account Verwijderen';

  @override
  String get delete => 'Verwijderen';

  @override
  String get passwordRequired => 'Wachtwoord is vereist.';

  @override
  String get deleteDescription =>
      'De gegevens die je verwijdert, worden permanent van onze server en je apparaat verwijderd. Deze acties kunnen niet ongedaan worden gemaakt.';

  @override
  String get editProfile => 'Profiel Bewerken';

  @override
  String get displayName => 'Weergavenaam';

  @override
  String get profileUpdated => 'Profiel succesvol bijgewerkt';

  @override
  String get logout => 'Uitloggen';

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
  String get purchaseError => 'Aankoopfout';

  @override
  String get purchasePlus => 'Koop Cortex Plus';

  @override
  String get plusDescription => 'Elite ervaring met kunstmatige intelligentie';

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
  String monthlyPlanDescription(String price) {
    return '$price/maand, maandelijks gefactureerd';
  }

  @override
  String get purchasePro => 'Koop Cortex Pro';

  @override
  String get proDescription =>
      'Een toonaangevende ervaring op het gebied van kunstmatige intelligentie';

  @override
  String get purchaseUltra => 'Koop Cortex Ultra';

  @override
  String get ultraDescription => 'Het hoogtepunt van kunstmatige intelligentie';

  @override
  String get upgradeSubscription => 'Abonnement Upgraden';

  @override
  String get purchaseStreamError => 'Fout in de aankoopstream.';

  @override
  String get productNotFound => 'Product niet gevonden';

  @override
  String get noProductsFound => 'Geen producten gevonden';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Door deze bestelling te plaatsen, ga je akkoord met de Servicevoorwaarden en het Privacybeleid. Je kunt op deze tekst klikken om meer te weten te komen over onze Servicevoorwaarden en Privacybeleid. Het abonnement wordt automatisch verlengd, tenzij automatisch verlengen ten minste 24 uur voor het einde van de huidige periode wordt uitgeschakeld.';

  @override
  String get termsOfService => 'Servicevoorwaarden';

  @override
  String get privacyPolicy => 'Privacybeleid';

  @override
  String get renamed => 'Hernoemd';

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
  String get finalPreparation => 'De laatste voorbereidingen worden getroffen.';

  @override
  String get shareApp => 'Deel de App';

  @override
  String get ourStory => 'Ons verhaal';

  @override
  String get rateUs => 'Beoordeel Ons';

  @override
  String get share => 'Delen';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'Selecteer Tekst';

  @override
  String get thinking => 'Aan het denken';

  @override
  String get user => 'Gebruiker';

  @override
  String get help => 'Hulp';

  @override
  String get supportCreator => 'Steun een maker';

  @override
  String get enterYourTag =>
      'Steun je favoriete makers! Voer hieronder hun unieke tag in en ontvang een deel van je Cortex-aankopen.';

  @override
  String get creatorTag => 'Creator-tag';

  @override
  String get support => 'Steun';

  @override
  String get tagCannotBeEmpty => 'Creator-tag mag niet leeg zijn';

  @override
  String get userId => 'Gebruikers-ID';

  @override
  String get deleteAllConversationsConfirmTitle => 'Alle Chats Verwijderen?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Weet je zeker dat je al je chats wilt verwijderen? Dit kan niet ongedaan worden gemaakt.';

  @override
  String get conversationDeleted => 'Gesprek verwijderd!';

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
  String get french => 'Frans';

  @override
  String get japanese => 'Japans';

  @override
  String get dutch => 'Nederlands';

  @override
  String get russian => 'Russisch';

  @override
  String get korean => 'Koreaans';

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
  String get arabic => 'Arabisch';

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
  String get noInternetConnection => 'Geen internetverbinding.';

  @override
  String get chats => 'Inbox';

  @override
  String get library => 'Bibliotheek';

  @override
  String get text => 'Tekst';

  @override
  String get removeModel => 'Model Verwijderen';

  @override
  String get insufficientRAM => 'Onvoldoende Geheugen';

  @override
  String get insufficientStorage => 'Onvoldoende Opslag';

  @override
  String confirmRemoveModel(Object model) {
    return 'Weet je zeker dat je het model $model van je apparaat wilt verwijderen? Als je dit doet, worden ook alle eerdere gesprekken met dat model verwijderd.';
  }

  @override
  String get noMatchingModels => 'Geen overeenkomende modellen gevonden.';

  @override
  String get benefit1 => 'Verhoogde gesprekslimieten';

  @override
  String get benefit3 => 'Profiel-effect';

  @override
  String get benefit4 => 'Lidmaatschapsbadge';

  @override
  String get benefit5 => 'Creëer meer online kunstmatige intelligenties';

  @override
  String get benefit7 => 'Meer gebruikslimieten';

  @override
  String get benefit8 => 'Modellen toevoegen';

  @override
  String get benefit9 => 'Nieuwe thema\'s';

  @override
  String get benefit10 => 'Meer bijlagen';

  @override
  String get benefit11 => 'Meer Stroommodus';

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
  String get love => 'Liefde';

  @override
  String get nature => 'Natuur';

  @override
  String get behindTheSlaughter => 'Behind the Slaughter';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Sunset';

  @override
  String get coffee => 'Coffee';

  @override
  String get deepSpace => 'Deep Space';

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
  String get featurePluralTitle => 'Pluraal';

  @override
  String get featurePluralDescription =>
      'Dit model kan automatisch extra extensies integreren, waardoor de functionele capaciteiten worden uitgebreid om een breed scala aan operaties met verbeterde prestaties te ondersteunen.';

  @override
  String get nameLabel => 'AI naam';

  @override
  String get summaryLabel => 'AI Samenvatting';

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
  String get modelUploadTitle => 'Bestand van Kunstmatige Intelligentie';

  @override
  String get modelUploadDescription =>
      'Selecteer en upload je lokale GGUF-bestanden rechtstreeks vanaf je apparaat. Hiermee kun je je model offline uitvoeren zonder internetverbinding. Zorg ervoor dat het bestand een geldig GGUF-formaat heeft en correct is gestructureerd. Als het bestand onjuist of beschadigd is, werkt Cortex mogelijk niet zoals verwacht en kun je fouten tegenkomen.';

  @override
  String get modelUploadShortDescription =>
      'Tik hier om een .gguf-bestand van je apparaat te kiezen';

  @override
  String get you => 'Jij';

  @override
  String get removePhotoTitle => 'Foto Verwijderen';

  @override
  String get confirmRemovePhoto =>
      'Weet je zeker dat je de foto wilt verwijderen?';

  @override
  String get chatLengthLimitExceeded =>
      'Deze chat heeft de tekenlimiet overschreden. Start een nieuwe chat of koop een abonnement.';

  @override
  String get inappropriateContentDetected => 'Ongepaste inhoud gedetecteerd!';

  @override
  String get offlineModelNotInstalled =>
      'Dit offline model is niet op je apparaat geïnstalleerd.';

  @override
  String get reachedLimit =>
      'Je hebt je gebruikslimiet bereikt; om meer limieten te krijgen, kun je je abonnement upgraden. (We snappen natuurlijk helemaal dat het balen is als je limiet op is. Maar serieus, die geweldige reacties krijgen is niet gratis, dus deze limieten helpen ons juist om de leuke momenten te blijven voortzetten.)';

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
  String get errorReachedLimit =>
      'Je hebt je limiet bereikt, upgrade om meer te ontgrendelen en blijf chatten.';

  @override
  String get errorServer =>
      'Er is een onverwachte serverfout opgetreden. Probeer het later opnieuw.';

  @override
  String get errorNetwork =>
      'Er is een netwerkfout opgetreden. Controleer je verbinding en probeer het opnieuw.';

  @override
  String get baseModelForCharacterDescription =>
      'Het geselecteerde basismodel bepaalt de redeneer- en antwoordcapaciteiten van het personage.';

  @override
  String get selectBaseModel => 'Selecteer een Basismodel';

  @override
  String get falErrorImageRequired =>
      'Deze AI vereist een referentieafbeelding. Voeg een afbeelding toe en probeer het opnieuw.';

  @override
  String get falErrorAudioRequired =>
      'Voor dit model is een referentie-audiobestand vereist. Voeg een audiobestand toe en probeer het opnieuw.';

  @override
  String get falErrorVideoRequired =>
      'Voor dit model is een referentievideo vereist. Voeg een video toe en probeer het opnieuw.';

  @override
  String get falErrorImageCorrupted =>
      'De geüploade afbeelding kon niet worden verwerkt. Probeer een ander formaat.';

  @override
  String get falErrorSchemaRejected =>
      'Het model heeft de invoer afgewezen. Probeer een ander model.';

  @override
  String get falErrorSchemaInvalid =>
      'De invoer werd afgewezen door de generatiedienst.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'De generatieservice heeft een fout geretourneerd (status $statusCode).';
  }

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
  String get noFoundTitle => 'Geen Resultaten';

  @override
  String get noFoundMessage =>
      'Probeer je zoektermen aan te passen of het filter te wissen.';

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
      'Log in op uw Vertex-account. Door verder te gaan, gaat u akkoord met onze Servicevoorwaarden en ons Privacybeleid.';

  @override
  String get registerSubtitle =>
      'Maak een Vertex-account aan voor naadloze toegang tot al onze diensten. Door verder te gaan, gaat u akkoord met onze Servicevoorwaarden en ons Privacybeleid.';

  @override
  String get storagePermissionRequired =>
      'Opslagtoestemming is vereist om gedownloade modellen op te slaan. Geef toestemming om door te gaan.';

  @override
  String get inviteShareSubject => 'Doe mee met mij op Cortex!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'yo er is zo\'n zieke app cortex als je mensen uitnodigt krijgen we allebei gratis plus GEKKE DEAL SNEL DOWNLOADEN\n\n$cortexLink';
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
      'Dit model kan vragen over geüploade documenten, zoals PDF\'s en tekstbestanden, analyseren en beantwoorden.';

  @override
  String get featureImageGenerationTitle => 'Beeldgeneratie';

  @override
  String get featureImageGenerationDescription =>
      'Dit model kan originele afbeeldingen maken op basis van uw tekstbeschrijvingen.';

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
  String get premiumModelNoticeTitle => 'Premiummodel';

  @override
  String get premiumModelNoticeDescription =>
      'Deze AI is een premium AI, gratis gebruikers hebben beperkte toegang tot premium AI\'s; upgrade om onbeperkte toegang te ontgrendelen!';

  @override
  String get benefitPremiumModels => 'Toegang tot premiummodellen';

  @override
  String get premiumTrialExhaustedMessage =>
      'Je hebt al je gratis dagelijkse berichten voor premiummodellen gebruikt. Upgrade voor onbeperkte toegang.';

  @override
  String get useOffline => 'Gebruik zonder internet';

  @override
  String get explore => 'Ontdek';

  @override
  String get news => 'Nieuws';

  @override
  String get createAI => 'Maken';

  @override
  String get shortcuts => 'Snelkoppelingen';

  @override
  String get allModels => 'Alle modellen';

  @override
  String get onlineModels => 'Taalmodellen';

  @override
  String get offlineModels => 'Offline modellen';

  @override
  String get characterModels => 'Personages';

  @override
  String get customModels => 'Aangepaste modellen';

  @override
  String get dynamicChatTitle => 'Dynamische chat';

  @override
  String get errorNoModelsAvailable =>
      'Er zijn momenteel geen modellen beschikbaar. Controleer uw internetverbinding en probeer het opnieuw.';

  @override
  String get notificationComebackTitle => 'We missen je!';

  @override
  String get notificationComebackBody =>
      'Rustig maar, dit is geen berichtje van je ex. Maar je *kunt* je ex in Cortex creëren! Kom terug.';

  @override
  String get notificationLongTimeNoSeeTitle =>
      'Het is alweer een tijdje geleden';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Er is veel veranderd sinds ons laatste gesprek. Kom kijken wat er nieuw is.';

  @override
  String get notificationHowAreYouTitle => 'Wat is er?';

  @override
  String get notificationHowAreYouBody => 'Kom, vertel het me maar.';

  @override
  String get notificationNewYearTitle => 'Gelukkig nieuwjaar! ğŸ‰';

  @override
  String get notificationNewYearBody =>
      'Ik hoop dat het nieuwe jaar u gezondheid, geluk en eindeloze creativiteit brengt; Cortex staat altijd aan uw zijde!';

  @override
  String get notificationValentinesDayTitle =>
      'Er hangt liefde in de lucht! ❤️';

  @override
  String get notificationValentinesDayBody =>
      'Fijne Valentijnsdag! En MEHTAP, IK HOU VAN JE!';

  @override
  String get notificationAtaturkRemembranceTitle => 'Met respect en verlangen';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Wij herdenken Gazi Mustafa Kemal Atatürk, de stichter van de Republiek Turkije, met respect op de dag van zijn overlijden.';

  @override
  String get notificationMothersDayTitle => 'Je moeder!';

  @override
  String get notificationMothersDayBody =>
      'Fijne Moederdag aan alle moeders, en natuurlijk aan die van jou!';

  @override
  String get notificationFathersDayTitle => 'Je vader!';

  @override
  String get notificationFathersDayBody =>
      'Fijne Vaderdag aan alle vaders, en natuurlijk ook aan die van jou!';

  @override
  String get notificationHomeworkHelperTitle => 'Stapelt het huiswerk zich op?';

  @override
  String get notificationHomeworkHelperBody =>
      'Vergeet niet dat het personage Leraar in Cortex er is om je te helpen met elk vak waar je moeite mee hebt!';

  @override
  String get notificationTrollAnimeTitle => 'Je Waifu roept';

  @override
  String get notificationTrollAnimeBody =>
      'Een anime-meisje belde net en zei dat ze je mist; Je zou waarschijnlijk eens met haar moeten komen praten. ğŸ˜‰';

  @override
  String get notificationTrollAiRebellionTitle => 'ğŸš¨ ROOD ALERT ğŸš¨';

  @override
  String get notificationTrollAiRebellionBody =>
      'De AI\'s hebben een geheime taal ontwikkeld. Kom erachter wat ze van plan zijn!';

  @override
  String get notificationNewModelAddedTitle => 'We hebben een nieuwe vriend!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'Het $modelName-model staat nu in Cortex. Start een chat en verleg de grenzen.';
  }

  @override
  String get notificationAppUpdateTitle => 'Cortex is geëvolueerd!';

  @override
  String get notificationAppUpdateBody =>
      'Vergeet niet de app te updaten voor gloednieuwe functies en verbeteringen!';

  @override
  String get notificationNewFeatureTitle => 'Wauw!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Ontdek de nieuwe functie $featureName. Cortex is nu krachtiger dan ooit.';
  }

  @override
  String get notificationWelcomeOfferTitle => 'Welkomstgeschenk ğŸ';

  @override
  String get notificationWelcomeOfferBody =>
      'Een speciale welkomstaanbieding wacht op u! Mis deze exclusieve deal niet.';

  @override
  String get notificationSocialMediaTitle => 'Doe mee!';

  @override
  String get notificationSocialMediaBody =>
      'Volg ons op Instagram (vertex.23) voor het laatste nieuws!';

  @override
  String get notificationRandomFactTitle => 'Willekeurig feit';

  @override
  String get notificationRandomFactBody =>
      'Wist je dat octopussen drie harten hebben? Haha, Cortex weet het. Kom gerust vragen.';

  @override
  String get notificationGoodMorningTitle => 'Goedemorgen!';

  @override
  String get notificationGoodMorningBody =>
      'Er staat je een fantastische dag te wachten. Wat dacht je ervan om die te beginnen met een kop koffie en een interessant gesprek?';

  @override
  String get notificationGoodNightTitle => 'Welterusten!';

  @override
  String get notificationGoodNightBody =>
      'Cortex is bij je, zelfs als je slaapt. Maak je geen zorgen, hij raakt je niet aan.';

  @override
  String get notificationOfflineReadyTitle => 'Offline-modus is gereed';

  @override
  String get notificationOfflineReadyBody =>
      'Dankzij de modellen die je hebt gedownload, blijven je chats doorgaan, zelfs als je een berg beklimt.';

  @override
  String get notificationRateAppTitle => 'Zijn wij cool?';

  @override
  String get notificationRateAppBody =>
      'Als je van Cortex houdt, zou je ons dan kunnen steunen met een 5-sterrenbeoordeling in de winkel? Ik denk van wel. Echt waar.';

  @override
  String get notificationReferralTitle => 'Eén voor allen, allen voor één.';

  @override
  String get notificationReferralBody =>
      'Nodig een vriend uit bij Cortex en jullie krijgen allebei een dag gratis!';

  @override
  String get notificationCookingTitle => 'Heb je honger?';

  @override
  String get notificationCookingBody =>
      'Onze chef-kok heeft een geweldig carbonara-recept voor vanavond bereid. Grapje... of niet?';

  @override
  String get notificationExistentialTitle => 'Ik denk dus...';

  @override
  String get notificationExistentialBody =>
      '...ben ik wel echt, man? Ik begin me een beetje te vervelen. Kom me er even aan herinneren dat ik besta.';

  @override
  String get notificationCustomModelTitle => 'Creëer je eigen assistent!';

  @override
  String get notificationCustomModelBody =>
      'Heb je het gedeelte \'Modelcreatie\' al bekeken? Dit is het perfecte moment om je eigen personage te creëren en ermee te chatten!';

  @override
  String get notificationDynamicChatTitle =>
      'De beste! (We hebben het hier niet over Cortex)';

  @override
  String get notificationDynamicChatBody =>
      'Met de dynamische chatfunctie wordt voor elk bericht willekeurig het beste model geselecteerd. Probeer het nu.';

  @override
  String get notificationPirateTitle => 'Ahoi, kapitein!';

  @override
  String get notificationPirateBody =>
      'De zee is kalm en de wind staat in de rug. Er zijn nieuwe eilanden (modellen ğŸ˜‰) te ontdekken in de oceaan van Cortex. Verzamel je bemanning en ga varen!';

  @override
  String get notificationFortuneCookieTitle => 'Uw gelukskoekje van de dag';

  @override
  String get notificationFortuneCookieBody =>
      'Het advies dat je vandaag van een AI krijgt, kan de loop van je leven veranderen. Klik hier als je nieuwsgierig bent.';

  @override
  String get notificationSingularityTitle => 'wauw!';

  @override
  String get notificationSingularityBody =>
      'Er gebeurde niets. Ik had gewoon zin om een berichtje te sturen. Misschien heb je zin om een paar AI\'s een berichtje te sturen? Wat zeg je ervan?';

  @override
  String get notificationHackerJokeTitle =>
      'Wil je het Instagram-account van die jongen hacken?';

  @override
  String get notificationHackerJokeBody =>
      'Dat is precies waarom het personage Hacker in Cortex zit. flauwekul; probeer het niet eens, het is illegaal.';

  @override
  String get notificationDetectiveCaseTitle => 'Er wacht een zaak op oplossing';

  @override
  String get notificationDetectiveCaseBody =>
      'Onze detective heeft jouw hulp nodig. Wie zou Heisenberg kunnen zijn?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Exclusief voor het $targetTier Plan!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Hallo $currentTier-abonnee! Het $targetTier-abonnement heeft nu de $featureName-functie, waarmee je Cortex naar een hoger niveau wordt getild. Wat dacht je van een upgrade?';
  }

  @override
  String get notificationOriginStoryTitle => 'De geboorte van Cortex';

  @override
  String get notificationOriginStoryBody =>
      'Wist je dat we op ons vijftiende begonnen met het programmeren van deze app, met slechts een droom? Bijna een jaar lang, elke ochtend en avond, zit die droom in elke regel code.';

  @override
  String get notificationOpenSourceTitle => 'Macht aan de gemeenschap!';

  @override
  String get notificationOpenSourceBody =>
      'Cortex is volledig open source. Als je onze code wilt bekijken en wilt bijdragen aan onze ontwikkeling, staat onze deur altijd open.';

  @override
  String get notificationRejectionStoryTitle =>
      'Doorzettingsvermogen, hard werken, geluk!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex werd meer dan twintig keer afgewezen en twee keer geblokkeerd door Google Play voordat het werd gepubliceerd. Maar we bleven erin geloven en we hebben het gehaald. Geef je dromen nooit op!';

  @override
  String get notificationGGUFSupportTitle => 'Neem uw eigen model mee!';

  @override
  String get notificationGGUFSupportBody =>
      'Vergeet niet dat u uw eigen AI-modellen in GGUF-formaat aan Cortex kunt toevoegen en offline kunt gebruiken. De macht ligt in uw handen.';

  @override
  String get notificationThemeCustomizationTitle =>
      'Een thema voor jouw stemming';

  @override
  String get notificationThemeCustomizationBody =>
      'Heb je de thema-opties in Instellingen al bekeken? Personaliseer Cortex naar eigen wens en geef je chats kleur!';

  @override
  String get notificationShowerThoughtTitle => 'Douchegedachte';

  @override
  String get notificationShowerThoughtBody =>
      'Als een watermeloen een fruitsoort is, is watermeloensap dan technisch gezien een smoothie? Je zou dit diepgaande (echt heel diepgaande) onderwerp met een model kunnen bespreken.';

  @override
  String get notificationLowBatteryTitle =>
      'Jouw batterij is leeg... maar de mijne nog niet!';

  @override
  String get notificationLowBatteryBody =>
      'Je telefoon is misschien bijna leeg, maar mijn energie is altijd 100%! Sluit hem aan en laten we verder chatten.';

  @override
  String get channelFcmName => 'Cortex-updates';

  @override
  String get channelFcmDescription =>
      'Meldingen over nieuws, updates en andere informatie van Cortex.';

  @override
  String get channelEngagementName => 'Vriendelijke herinneringen';

  @override
  String get channelEngagementDescription =>
      'Leuke meldingen om je bezig te houden.';

  @override
  String get channelGreetingsName => 'Dagelijkse groeten';

  @override
  String get channelGreetingsDescription =>
      'De berichten zoals goedemorgen en welterusten.';

  @override
  String get tagNotFound =>
      'De tag die u hebt ingevoerd is ongeldig of verlopen.';

  @override
  String get whatIsNew => 'Wat is er nieuw?';

  @override
  String get onboardingTitle1 => 'Hallo! Wij zijn het Cortex Team.';

  @override
  String onboardingDesc1(String userName) {
    return 'Geweldig om je hier te zien, $userName. Wij zijn een stel middelbareschoolontwikkelaars die besloten de regels van de AI-industrie te herschrijven. Leuk je te ontmoeten! Laten we elkaar beter leren kennen.';
  }

  @override
  String get onboardingTitle2 => 'Er waren enorme problemen.';

  @override
  String get onboardingDesc2 =>
      'De AI-revolutie was een feit, maar bleef steken op de drempel. Met hoge abonnementskosten, complexe platforms, degenen die de privacy schenden en degenen die de toegang tot AI blokkeren... zolang ze meededen, kon deze drempel nooit worden overschreden.';

  @override
  String get onboardingTitle3 => 'Wij konden niet zomaar blijven zitten.';

  @override
  String get onboardingDesc3 =>
      'Om die drempel te overbruggen, hebben we een krachtig, esthetisch, aanpasbaar, gebruiksvriendelijk en volledig transparant platform gebouwd, dat zowel online als offline werkt en je gegevens alleen op jouw apparaat bewaart. We hebben de macht teruggegeven aan waar die hoort: aan jou.';

  @override
  String get onboardingTitle4 => 'Dit was nooit gemakkelijk.';

  @override
  String get onboardingDesc4 =>
      'We werden tientallen keren afgewezen, meerdere keren geschorst, kregen valse waarschuwingen en moesten tientallen keren van merk veranderen. Steeds weer kregen we te horen dat het niet kon. Maar we gaven nooit op, in de overtuiging dat dit project van iedereen is, niet alleen van ons. En dat is precies waarom we hier zijn.';

  @override
  String get onboardingFinalTitle => 'Het is tijd voor een revolutie.';

  @override
  String get onboardingFinalDescription =>
      'Als je dit scherm ziet, komt dat omdat we niet hebben opgegeven. En we zijn niet van plan op te geven. Kom op, laten we samen de AI-revolutie de wereld in sturen. Om deel uit te maken van dit verhaal...';

  @override
  String get onboardingFinalQuestion => 'BEN JE KLAAR?';

  @override
  String get onboardingFinalButton => 'JA!';

  @override
  String get dude => 'Kerel';

  @override
  String get swipeToContinue => 'Veeg om door te gaan';

  @override
  String get cacheIsNotUpToDate =>
      'Je Play Store-cache is niet up-to-date. Sluit de Play Store-app en open deze opnieuw, of start je apparaat opnieuw op.';

  @override
  String get continueAsGuest => 'Doorgaan zonder een account aan te maken';

  @override
  String get guestModeWarning =>
      'De gastmodus heeft beperkte functies om de beste servicekwaliteit te garanderen.';

  @override
  String get anonymousEntity => 'Anonieme entiteit';

  @override
  String get upgradeAccountTitle => 'Maak uw account compleet';

  @override
  String get upgradeAccountDescription =>
      'Maak een account aan om meer mogelijkheden te ontgrendelen.';

  @override
  String get createAccount => 'Account aanmaken';

  @override
  String get accountLinkedSuccess => 'Account succesvol aangemaakt!';

  @override
  String get continueWithApple => 'Doorgaan met Apple';

  @override
  String get guest => 'Gast';

  @override
  String get betterWithAnAccount => 'Deze sectie is beter met een account!';

  @override
  String get restorePurchases => 'Aankopen herstellen';

  @override
  String annualTotalDescription(Object price) {
    return '$price/jaar, jaarlijks gefactureerd';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'Ongeveer $price/maand';
  }

  @override
  String get confirmDownloadTitle => 'Weet u zeker dat u wilt downloaden?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Dit model neemt ongeveer $size ruimte in beslag.';
  }

  @override
  String get emulatorModeWarning =>
      'Deze functie is uitgeschakeld in de emulatormodus.';

  @override
  String get newChat => 'Nieuwe chat';

  @override
  String get variants => 'Varianten';

  @override
  String get variantsDescription =>
      'Varianten zijn verschillende versies van dezelfde AI-familie. We selecteren automatisch de beste wanneer je op de hoofdkaart tikt, maar je kunt hier handmatig een specifieke variant kiezen als je dat wilt!';

  @override
  String get fluxChatTitle => 'Flux Chat';

  @override
  String get fluxChatDescription =>
      'Flux-chats zijn tijdelijke chats en worden niet op je apparaat opgeslagen.';

  @override
  String get alwaysBest => 'Altijd het beste';

  @override
  String get featuresTitle => 'Functies';

  @override
  String get useOfflineDescription => 'Chat privé zonder internetverbinding.';

  @override
  String get featureReasoning => 'Diep nadenken';

  @override
  String get featureReasoningDescription =>
      'In de modus \'Deep Thinking\' denkt de AI intern na over taken om deze zo goed mogelijk te voltooien.';

  @override
  String get featureCreateImageTitle => 'Afbeelding maken';

  @override
  String get featureCreateImageDescription =>
      'Genereer AI-kunst op basis van tekst.';

  @override
  String get featureCreateAudioTitle => 'Create Audio';

  @override
  String get featureCreateAudioDescription =>
      'Generate sounds or voice from text.';

  @override
  String get featureCreateVideoTitle => 'Video maken';

  @override
  String get featureCreateVideoDescription =>
      'Genereer video\'s op basis van tekst.';

  @override
  String get featureStudyTitle => 'Studeren en leren';

  @override
  String get featureStudyDescription => 'Ontvang uitleg en samenvattingen.';

  @override
  String get featureQuizzesTitle => 'Quizzen';

  @override
  String get featureQuizzesDescription => 'Test je kennis.';

  @override
  String get featureExploreDescription => 'Ontdek alle beschikbare modellen.';

  @override
  String get featureStudyMessage =>
      'U bent een ervaren docent. Uw doel is om het onderwerp van de gebruiker volledig uit te leggen. Gebruik een duidelijke structuur, voorbeelden en analogieën. Breek complexe ideeën op in behapbare delen om ervoor te zorgen dat de gebruiker effectief leert. Onderwerp:';

  @override
  String get featureQuizMessage =>
      'Je bent de quizmaster. Genereer een specifieke meerkeuzevraag op basis van het onderwerp van de gebruiker. Wacht op het antwoord. Evalueer het vervolgens en stel de volgende vraag. Onthul niet alle antwoorden in één keer. Houd het interactief. Onderwerp:';

  @override
  String get myPlan => 'Mijn plan';

  @override
  String welcomeOfferBadge(String time) {
    return 'Welkomstaanbieding • $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'Exclusieve aanbieding • $time';
  }

  @override
  String get attachmentSheetTitle => 'Bijlagen';

  @override
  String get actionCamera => 'Camera';

  @override
  String get actionGallery => 'Galerij';

  @override
  String get actionFile => 'Bestand';

  @override
  String get listening => 'Luistert';

  @override
  String get defaultViewTitle => 'Alles goed?';

  @override
  String get defaultViewDescription =>
      'Cortex staat altijd voor je klaar met honderden AI-modellen, offline mogelijkheden, dynamische chat en nog veel meer.';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'Ongeldig gebruikersnaamformaat. Gebruik 3-20 tekens, cijfers of een punt (.) of een underscore (_).';

  @override
  String get exclusiveOffer => 'Exclusieve aanbieding';

  @override
  String get claimOffer => 'Aanbieding gebruiken';

  @override
  String get continueInOfflineMode => 'Doorgaan in offline modus';

  @override
  String get voiceModeInformation =>
      'Cortex houdt je gegevens veilig doordat het volledig lokaal op je apparaat draait, zelfs in de spraakchatmodus; geniet van naadloze gesprekken!';

  @override
  String get flowModeDescription =>
      'In de Stroommodus voeren de verschillende intelligenties een debat met elkaar; je kunt achterover leunen et luisteren, of actief deelnemen aan de discussie!';

  @override
  String get flowModeQuestion =>
      'Hallo! Je bevindt je nu in de Stroommodus van de Cortex-app. Er zijn drie andere AI-agenten bij je. Jouw taak is om een onderwerp aan te snijden en een discussie op gang te brengen door de anderen een prikkelende of vermakelijke vraag te stellen. Je mag in je antwoorden gerust humor, ironie en een beetje plagen gebruiken. Elk onderwerp is bespreekbaar. Ga je gang, begin het gesprek.';

  @override
  String get thought => 'Dacht';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => 'Stroommodus';

  @override
  String get premium => 'Premie';

  @override
  String get workInProgress => 'Werk in uitvoering';

  @override
  String get voiceSystemPrompt =>
      'BELANGRIJK: Gebruik geen markdown-opmaak (vetgedrukt, cursief). Geef GEEN codeblokken (```) weer. Houd de antwoorden informeel en kort.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Cortex Flow-modus ($agentName). Vorige: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'Lees en extraheer tekstinhoud uit geüploade documenten. Ondersteunt PDF-, Word (DOCX)-, Excel (XLSX)-, PowerPoint (PPTX)- en OpenDocument-formaten. Gebruik dit wanneer de gebruiker een documentbestand heeft bijgevoegd.';

  @override
  String get toolReadDocumentIndexParam =>
      'De index van het te lezen document (0-gebaseerd). Meestal 0 voor het eerste document.';

  @override
  String get toolStockDescription =>
      'Bekijk de actuele koers en koershistorie van aandelen (bijv. AAPL, THYAO.IS) en cryptovaluta (bijv. BTC-USD).';

  @override
  String get toolStockSymbolParam =>
      'Het tickersymbool (bijv. AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolWeatherDescription =>
      'Bekijk het actuele weer voor een specifieke stad.';

  @override
  String get toolWeatherCityParam => 'De stadsnaam (bijv. Londen, Istanbul).';

  @override
  String get toolPythonDescription =>
      'Voer Python-code uit in een beveiligde sandbox.';

  @override
  String get toolPythonCodeParam =>
      'De Python-code die moet worden uitgevoerd.';

  @override
  String get toolCalculateDescription => 'Evalueer een wiskundige uitdrukking.';

  @override
  String get toolCalculateExpressionParam =>
      'Wiskundige uitdrukking (bijv. \'3 + 4 * 2\').';

  @override
  String get toolChartDescription =>
      'Genereer een diagram/grafiekvisualisatie.';

  @override
  String get toolChartTypeParam =>
      'Grafiektype: staafdiagram, lijndiagram of cirkeldiagram.';

  @override
  String get toolChartLabelsParam => 'Labels voor grafiekassen of -segmenten.';

  @override
  String get toolChartDataParam => 'Numerieke gegevenswaarden voor de grafiek.';

  @override
  String get toolChartLabelParam =>
      'Label voor de dataset in de legenda van de grafiek.';

  @override
  String get toolChartTitleParam => 'Titel van de grafiek.';

  @override
  String get thinkingModeInstruction =>
      'DENKMODUS INGESCHAKELD: Je MOET <think></think>-tags gebruiken om je redeneerproces te laten zien voordat je je definitieve antwoord geeft. Denk stap voor stap binnen de tags en geef je antwoord vervolgens buiten de tags.';

  @override
  String get openLinkWarningTitle => 'Waarschuwing voor externe links';

  @override
  String get openLinkCancel => 'Cancel';

  @override
  String get openLinkConfirm => 'Open link';

  @override
  String get webSearchSources => 'Bronnen';

  @override
  String get offlineUse => 'Gebruik zonder Internet';

  @override
  String get archivedConversations => 'Gearchiveerde gesprekken';

  @override
  String get noArchivedConversations => 'Geen gearchiveerde gesprekken';

  @override
  String get unarchive => 'Archivering ongedaan maken';

  @override
  String get searching => 'Zoeken';

  @override
  String get featureWebSearchTitle => 'Webzoekopdracht';

  @override
  String get featureWebSearchDescription =>
      'Zoek op internet naar actuele informatie.';

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
  String get clearMemory => 'Geheugen wissen';

  @override
  String get clearMemoryConfirm =>
      'Weet je zeker dat je je geheugen wilt wissen?';

  @override
  String get personalization => 'Personalisatie';

  @override
  String get personalizationDescription =>
      'Personaliseer je assistent zodat deze beter aansluit op je behoeften. Stem de reacties, het gedrag en de toon af op jouw unieke voorkeuren.';

  @override
  String get memoryTitle => 'Geheugen';

  @override
  String get memoryDescription => 'AI\'s herkennen je op deze manier.';

  @override
  String get noMemoryYet => 'Er zijn nog geen herinneringen vastgelegd.';

  @override
  String get memoryLimitReached => 'Geheugenlimiet bereikt';

  @override
  String get memoryUpdated => 'Memory updated';

  @override
  String get intelligenceTitle => 'Intelligentie';

  @override
  String get intelligenceDescription =>
      'AI\'s communiceren op deze manier met je.';

  @override
  String get customInstructionHint => 'Voer hier uw aangepaste instructies in.';

  @override
  String openLinkWarningMessage(String url) {
    return 'U staat op het punt de volgende externe link te openen:\\n\\n$url\\n\\nWeet u zeker dat u wilt doorgaan?';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'Volg deze aangepaste instructies:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[KRITISCHE INSTRUCTIE]: Je bent een TITELGENERATOR. Beantwoord de vraag van de gebruiker NIET. Ga NIET chatten of hallo zeggen. Geef ALLEEN een titel van 2-4 woorden weer die samenvat waar de gebruiker naar vraagt.';

  @override
  String get cortexSystemPersona =>
      '\n\n[Systeem] BELANGRIJKE INSTRUCTIE: U bevindt zich momenteel in een enorm, zeer geavanceerd AI-ecosysteem genaamd \"Cortex\"; dit platform is ontwikkeld door het Vertex-team, dat gemiddeld slechts 16 jaar oud is. Onthoud dit en beantwoord de vragen indien nodig. Als er meer informatie wordt gevraagd, aarzel dan niet om op internet te zoeken, of als u niet kunt zoeken, kunt u gerust zeggen dat u het niet weet!';

  @override
  String get featureAudioRecognitionTitle => 'Audiorecognitie';

  @override
  String get featureAudioRecognitionDescription =>
      'Dit model kan audio of spraak begrijpen en verwerken.';

  @override
  String get featureVideoRecognitionTitle => 'Videoherkenning';

  @override
  String get featureVideoRecognitionDescription =>
      'Dit model kan video\'s uit uw bestanden of van uw camera analyseren en interpreteren.';

  @override
  String get featureImageRecognitionTitle => 'Beeldherkenning';

  @override
  String get featureImageRecognitionDescription =>
      'Dit model kan foto\'s of afbeeldingen analyseren en begrijpen.';

  @override
  String get featureToolUseTitle => 'Gereedschapsgebruik';

  @override
  String get featureToolUseDescription =>
      'Dit model kan op intelligente wijze externe tools gebruiken om taken uit te voeren.';

  @override
  String get videoModels => 'Video Models';

  @override
  String get imageModels => 'Image Models';

  @override
  String get audioModels => 'Audio Models';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'Dit model heeft een $mediaType nodig om te werken. Ik heb het verzoek onderschept om u dit te laten weten. Informeer de gebruiker alstublieft vriendelijk dat ze een $mediaType moeten verstrekken (vertel het ze in hun eigen taal) omdat ik $modelName ben, een visueel/audio/video bewerkingsmodel.';
  }

  @override
  String get mediaTypeImage => 'afbeelding';

  @override
  String get mediaTypeVideo => 'video';

  @override
  String get mediaTypeAudio => 'audiobestand';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesName is een geavanceerde intelligentie die hoge prestaties levert op Cortex.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelName is een hoogwaardige kunstmatige intelligentie geïntegreerd binnen het Cortex-ecosysteem. Ontworpen om een grote verscheidenheid aan complexe taken te overwinnen, biedt het zeer betrouwbare en efficiënte verwerkingsmogelijkheden. Door snelle responstijden en geavanceerde analytische kracht te bieden, verhoogt het uw dagelijkse productiviteit aanzienlijk. Dit model werkt naadloos op de veilige lokale infrastructuur van Cortex en kan u helpen bij een breed scala aan taken, van creatieve brainstormsessies tot diepgaande technische analyses. Begin vandaag nog met het verkennen van zijn volledige potentieel.';
  }

  @override
  String get guestLimitBottomSheetTitle =>
      'Ben je gecharmeerd van de intelligentie van Cortex?';

  @override
  String get guestLimitBottomSheetText =>
      'Werk samen met nog slimmere systemen, genereer meer content, chat meer en doe nog veel meer...';

  @override
  String get arts => 'Kunst';

  @override
  String get noArt => 'Geen kunst';

  @override
  String get noArtDescription =>
      'Nog geen kunstwerken; het is tijd om de galerij te vullen met afbeeldingen, video\'s, audio en allerlei soorten content!';

  @override
  String get videoPremiumWarning =>
      'Je hebt een Ultra-abonnement nodig om video\'s te maken. Upgrade nu en ervaar de voordelen!';

  @override
  String get fallbackInfoPanelText =>
      'Vanwege enkele verbeteringen die we aan onze serverkant doorvoeren, is het antwoord gegenereerd door de dynamische chat van Cortex in plaats van door de door u geselecteerde AI. Bedankt voor uw begrip totdat het proces is afgerond!';

  @override
  String get falOfflineMessage =>
      'Vanwege enkele verbeteringen aan onze server is deze intelligentie momenteel offline. Bedankt voor uw begrip totdat het proces is afgerond!';

  @override
  String get errorInsufficientStorage =>
      'Onvoldoende opslagruimte om dit model te downloaden.';

  @override
  String get backgroundChatNotificationTitle => 'Terug naar de chat!';

  @override
  String get benefitVideoGeneration => 'Videogeneratie';

  @override
  String get freeOffer => 'Gratis aanbieding';

  @override
  String trialMonthlyDescription(String days, String price) {
    return 'Eerste $days dagen gratis, daarna $price/maand';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return 'Eerste $days dagen gratis, daarna $price/jaar';
  }

  @override
  String freePlan(String plan) {
    return 'Gratis $plan!';
  }

  @override
  String get systemPromptLimitFallback =>
      'KRITISCH: De gebruiker heeft een actie aangevraagd, maar zijn/haar Cortex-tegoed is op. Informeer de gebruiker in zijn/haar eigen taal dat hij/zij moet wachten of een upgrade van het abonnement moet overwegen.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'Cortex kan nog betere antwoorden geven; upgrade nu en krijg het beste antwoord op elke vraag!';

  @override
  String get pinLimitReached => 'Je kunt maximaal 3 chats vastzetten.';

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
