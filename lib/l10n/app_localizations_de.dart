// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get understood => 'Verstanden.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get remove => 'Entfernen';

  @override
  String get download => 'Herunterladen';

  @override
  String get resume => 'Fortsetzen';

  @override
  String get copy => 'Kopieren';

  @override
  String get chat => 'Chat';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get light => 'Hell';

  @override
  String get theme => 'Thema';

  @override
  String get no => 'Nein';

  @override
  String get yes => 'Ja';

  @override
  String get done => 'Fertig';

  @override
  String get comingSoon => 'KOMMT BALD';

  @override
  String get bestValue => 'Bestes Preis-Leistungs-Verhältnis';

  @override
  String get selected => 'Ausgewählt';

  @override
  String get descriptionSection => 'Beschreibung';

  @override
  String get searchHint => 'Suchen';

  @override
  String get messageHint => 'Frag alles';

  @override
  String get modelLoading => 'Modell wird geladen...';

  @override
  String get messageCopied => 'Nachricht in die Zwischenablage kopiert.';

  @override
  String get storeUnavailable =>
      'Der Store ist derzeit nicht verfügbar. Bitte versuche es später erneut.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get systemInfo => 'Systeminformationen';

  @override
  String deviceMemory(Object memory) {
    return 'Gerätespeicher: $memory GB';
  }

  @override
  String storageSpace(Object storage) {
    return 'Speicherplatz: $storage GB';
  }

  @override
  String freeStorageSpace(Object freeStorage) {
    return 'Freier Speicherplatz: $freeStorage GB';
  }

  @override
  String get memory => 'Arbeitsspeicher';

  @override
  String get storage => 'Speicher';

  @override
  String get freeStorage => 'Freier Speicher';

  @override
  String get totalStorage => 'Gesamtspeicher';

  @override
  String get usedStorage => 'Belegter Speicher';

  @override
  String get totalMemory => 'Gesamter Arbeitsspeicher';

  @override
  String get usedMemory => 'Genutzter Arbeitsspeicher';

  @override
  String get requirements => 'Anforderungen';

  @override
  String get modelsTitle => 'Bibliothek';

  @override
  String get localModels => 'Lokale Modelle';

  @override
  String get serverSideModels => 'Online-Modelle';

  @override
  String get uploadYourOwnModel => 'Lade dein eigenes Modell hoch!';

  @override
  String get selectGGUFFile => 'GGUF-Datei auswählen';

  @override
  String get errorGGUF => 'Bitte wähle nur eine Datei im GGUF-Format aus.';

  @override
  String get modelAlreadyExists => 'Modell existiert bereits.';

  @override
  String get modelAddedSuccessfully => 'Modell erfolgreich hinzugefügt.';

  @override
  String get modelRemoved => 'Modell erfolgreich entfernt.';

  @override
  String get removeError =>
      'Beim Entfernen des Modells ist ein Fehler aufgetreten.';

  @override
  String get fileNotFound => 'Datei nicht gefunden.';

  @override
  String get fileUploadError =>
      'Beim Hochladen der Datei ist ein Fehler aufgetreten.';

  @override
  String get noFileSelected => 'Keine Datei ausgewählt.';

  @override
  String get myModels => 'Meine Modelle';

  @override
  String get create => 'Erstellen';

  @override
  String get seeAll => 'Alle ansehen';

  @override
  String modelProducer(Object producer) {
    return 'Hersteller: $producer';
  }

  @override
  String modelRAM(Object ram) {
    return 'RAM: $ram';
  }

  @override
  String modelSize(Object size) {
    return 'Größe: $size';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get conversationsTitle => 'Unterhaltungen';

  @override
  String get conversationDeleted => 'Unterhaltung gelöscht.';

  @override
  String get conversationUpdated => 'Unterhaltung aktualisiert.';

  @override
  String get editConversationTitle => 'Umbenennen';

  @override
  String get newTitle => 'Neuer Titel';

  @override
  String get save => 'Speichern';

  @override
  String get titleCannotBeEmpty => 'Titel darf nicht leer sein.';

  @override
  String get noConversationsMessage =>
      'Keine Unterhaltungen, fang an zu chatten!';

  @override
  String get startChat => 'Einen Chat starten';

  @override
  String get noChats => 'Keine Chats';

  @override
  String get starredChats => 'Markierte Chats';

  @override
  String get allChats => 'Alle Chats';

  @override
  String get noStarredChats => 'Keine markierten Chats';

  @override
  String get noStarredChatsMessage => 'Du hast noch keinen Chat markiert.';

  @override
  String get goToChats => 'Einen Chat markieren';

  @override
  String get starConversation => 'Markieren';

  @override
  String get conversationTitleUpdated => 'Titel der Unterhaltung aktualisiert';

  @override
  String get youReachedConversationLimit =>
      'Du hast das Unterhaltungslimit erreicht.';

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String get loginToYourAccount => 'Anmelden';

  @override
  String get createYourAccount => 'Registrieren';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get invalidEmail => 'Bitte gib eine gültige E-Mail-Adresse ein.';

  @override
  String get invalidPassword =>
      'Das Passwort muss mindestens 6 Zeichen lang sein.';

  @override
  String get rememberMe => 'Angemeldet bleiben';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get or => 'Oder';

  @override
  String get continueWithGoogle => 'Mit Google fortfahren';

  @override
  String get dontHaveAccount => 'Du hast noch kein Konto?';

  @override
  String get alreadyHaveAccount => 'Du hast bereits ein Konto?';

  @override
  String get signUp => 'Registrieren';

  @override
  String get logIn => 'Anmelden';

  @override
  String get passwordsDoNotMatch => 'Die Passwörter stimmen nicht überein.';

  @override
  String get userNotFound => 'Benutzer nicht gefunden.';

  @override
  String get wrongPassword => 'Falsches Passwort.';

  @override
  String get emailAlreadyInUse => 'Diese E-Mail wird bereits verwendet.';

  @override
  String get weakPassword => 'Das Passwort ist zu schwach.';

  @override
  String get authError => 'Authentifizierungsfehler';

  @override
  String get invalidUsername => 'Bitte gib einen Benutzernamen ein.';

  @override
  String get usernameTaken => 'Dieser Benutzername ist bereits vergeben.';

  @override
  String get username => 'Benutzername';

  @override
  String get authenticationFailed =>
      'Authentifizierung fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get emailTooLong => 'Die E-Mail darf höchstens 30 Zeichen lang sein.';

  @override
  String get deviceLimitReached =>
      'Du hast das Kontoerstellungslimit für dieses Gerät erreicht.';

  @override
  String get verificationEmailLimitReached =>
      'Wir werden keine weiteren E-Mails senden';

  @override
  String get verificationEmailSent => 'Bestätigungs-E-Mail gesendet!';

  @override
  String get emailNotVerified => 'E-Mail wurde nicht bestätigt';

  @override
  String get resendCode => 'Bestätigungs-E-Mail erneut senden';

  @override
  String get remainingSeconds => 'Verbleibende Zeit für die Bestätigung';

  @override
  String get pleaseCheckYourEmail =>
      'Um Cortex zu nutzen, musst du deine E-Mail bestätigen. \n Ein Bestätigungslink wurde an deine E-Mail-Adresse gesendet, bitte überprüfe deine E-Mails.';

  @override
  String get verifyYourEmail => 'Bestätige deine E-Mail';

  @override
  String get backToLogin => 'Zurück zum Login';

  @override
  String get seconds => 'Sekunden';

  @override
  String get maxResendLimitReached =>
      'Du hast die maximale Anzahl an Bestätigungs-E-Mails erreicht';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Ohne Bestätigung fortfahren';

  @override
  String get verificationScreenWarning =>
      'Auch wenn du fortfährst, gilt die 1-tägige Kontobestätigungsfrist weiterhin für dein Konto. Wenn du dein Konto bis dahin nicht bestätigt hast, wird es aus der App gelöscht.';

  @override
  String get unverifiedAccountHeader => 'Dein Konto ist nicht bestätigt';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Wenn du dein Konto nicht innerhalb von $timeLeft bestätigst, wird es gelöscht';
  }

  @override
  String get verifyNow => 'Jetzt bestätigen';

  @override
  String get accountVerified => 'Dein Konto wurde bestätigt.';

  @override
  String get linkSent => 'Link gesendet';

  @override
  String get accountDeletionRequested =>
      'Deine Anfrage zur Kontolöschung wurde erhalten und dein Konto ist jetzt deaktiviert.';

  @override
  String get tooManyRequests => 'Zu viele Anfragen';

  @override
  String get regenerate => 'Erneut generieren';

  @override
  String get confirmDeleteAccount =>
      'Bist du sicher, dass du dein Konto löschen möchtest?';

  @override
  String get enterPasswordToDelete =>
      'Gib dein Passwort ein, um es zu löschen.';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get deleteAccountError =>
      'Beim Löschen des Kontos ist ein Fehler aufgetreten.';

  @override
  String get delete => 'Löschen';

  @override
  String get passwordRequired => 'Passwort ist erforderlich.';

  @override
  String get deleteDescription =>
      'Die von dir gelöschten Daten werden dauerhaft von unserem Server und deinem Gerät entfernt. Diese Aktionen können nicht rückgängig gemacht werden.';

  @override
  String get deleteAccountButton => 'Button zur Kontolöschung';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get displayName => 'Anzeigename';

  @override
  String get tapToChangeProfilePicture => 'Tippe, um das Profilbild zu ändern';

  @override
  String get profileUpdated => 'Profil erfolgreich aktualisiert';

  @override
  String get updateFailed => 'Profilaktualisierung fehlgeschlagen';

  @override
  String get nameCannotBeEmpty => 'Name darf nicht leer sein';

  @override
  String get logout => 'Abmelden';

  @override
  String get noDisplayName => 'Kein Anzeigename festgelegt';

  @override
  String get noEmail => 'Keine E-Mail-Adresse';

  @override
  String get noUserLoggedIn => 'Derzeit ist kein Benutzer angemeldet';

  @override
  String get profile => 'Profil';

  @override
  String get manageProfileDescription =>
      'Verwalte dein Profil, aktualisiere dein Passwort oder melde dich von Cortex ab.';

  @override
  String get accessSettingsDescription =>
      'Greife auf Hilfe zu, löse Codes ein, teile Cortex und sieh dir unsere Richtlinien an.';

  @override
  String get languageDescription =>
      'Du kannst die Standardsprache der App-Oberfläche jederzeit ändern.';

  @override
  String get themeDescription =>
      'Du kannst je nach Vorliebe zwischen hellen und dunklen Themen wechseln. Das ausgewählte Thema wird auf die gesamte Cortex-Oberfläche angewendet.';

  @override
  String get iHaveReadAndAgree =>
      'Ich habe die Nutzungsbedingungen gelesen und stimme ihnen zu';

  @override
  String get downloading => 'Wird heruntergeladen...';

  @override
  String get downloadError =>
      'Während des Downloads ist ein Fehler aufgetreten.';

  @override
  String get downloadCancelled => 'Download abgebrochen.';

  @override
  String get downloadResumed => 'Download fortgesetzt.';

  @override
  String get downloadSuccess => 'Download erfolgreich';

  @override
  String get downloadFailed => 'Download fehlgeschlagen';

  @override
  String downloaded(Object percent) {
    return '$percent% heruntergeladen';
  }

  @override
  String get downloadPaused => 'Download pausiert.';

  @override
  String get purchaseSuccessful => 'Kauf erfolgreich!';

  @override
  String get purchaseFailed => 'Kauf fehlgeschlagen';

  @override
  String get creditProductNotFound =>
      'Das ausgewählte Guthabenprodukt konnte nicht gefunden werden.';

  @override
  String get creditsAddedSuccessfully =>
      'Guthaben wurde deinem Konto erfolgreich hinzugefügt!';

  @override
  String get creditDeliveryFailed =>
      'Guthaben konnte deinem Konto nicht hinzugefügt werden. Bitte kontaktiere den Support.';

  @override
  String get invalidPurchase => 'Ungültiger Kauf';

  @override
  String get purchaseError => 'Fehler beim Kauf';

  @override
  String get purchaseVertexPlusToUpload => 'Dies ist eine Plus-Funktion';

  @override
  String get purchasePlus => 'Cortex Plus kaufen';

  @override
  String get plusDescription =>
      'Greife auf mehr Funktionen von Cortex zu und erlebe KI noch intensiver!';

  @override
  String get annual => 'Jährlich';

  @override
  String get monthly => 'Monatlich';

  @override
  String get manageSubscription => 'Abonnement verwalten';

  @override
  String purchasePlan(String planName) {
    return '$planName kaufen';
  }

  @override
  String discountOffer(int percent) {
    return '$percent% RABATT';
  }

  @override
  String annualPlanDescription(String price) {
    return '$price/Monat, jährlich abgerechnet';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/Monat, monatlich abgerechnet';
  }

  @override
  String get discountBannerTitle => 'EINFÜHRUNGSANGEBOT: 80 % RABATT!';

  @override
  String get discountBannerSubtitle =>
      'Exklusiver Rabatt auf ALLE Abonnements zur Feier unseres Starts. Nicht verpassen!';

  @override
  String get purchasePro => 'Cortex Pro kaufen';

  @override
  String get proDescription =>
      'Greife auf noch mehr Funktionen von Cortex zu und erlebe KI noch intensiver!';

  @override
  String get alreadySubscribed => 'Du hast bereits ein Abonnement';

  @override
  String get subscriptionInfo => 'Dein Abonnement ist aktiv.';

  @override
  String get alreadySubscribedMessage =>
      'Du hast bereits ein Plus-Abonnement. Wenn du dein Abonnement kündigen möchtest, kannst du dies über den Play Store Manager tun.';

  @override
  String get cancelSubscription => 'Abonnement kündigen';

  @override
  String get cancelSubscriptionInfo =>
      'Wenn du dein Abonnement kündigen möchtest, fahre bitte über den Abonnement-Manager des Play Stores fort.';

  @override
  String get goToPlayStore => 'Zum Play Store';

  @override
  String get alreadySubscribedPlus => 'Du hast den Plus-Plan!';

  @override
  String get alreadySubscribedPlusMessage =>
      'Dein Plus-Plan ist aktiv. Du kannst alle Vorteile genießen.';

  @override
  String get purchaseUltra => 'Cortex Ultra kaufen';

  @override
  String get ultraDescription =>
      'Erhalte vollen Zugriff auf alle Funktionen von Cortex und erlebe KI in vollen Zügen!';

  @override
  String get noSubscription => 'Kein Abonnement';

  @override
  String get noSubscriptionMessage => 'Du hast noch kein Abonnement.';

  @override
  String get alreadyAtHighestPlan => 'Du bist bereits auf dem höchsten Plan.';

  @override
  String get unableToOpenSubscription =>
      'Die Seite zur Abonnementverwaltung konnte nicht geöffnet werden.';

  @override
  String get upgradeSubscription => 'Abonnement upgraden';

  @override
  String get confirmUpgrade =>
      'Bist du sicher, dass du dein Abonnement upgraden möchtest?';

  @override
  String get unsupportedPlatform =>
      'Nicht unterstützte Plattform für die Abonnementkündigung.';

  @override
  String get purchaseStreamError => 'Fehler im Kauf-Stream.';

  @override
  String get productNotFound => 'Produkt nicht gefunden';

  @override
  String get productDetailsError =>
      'Beim Abrufen der Produktdetails ist ein Fehler aufgetreten.';

  @override
  String get noProductsFound => 'Keine Produkte gefunden';

  @override
  String get loadCreditsButton => 'Guthaben aufladen';

  @override
  String get creditsTitle => 'Guthaben';

  @override
  String get creditsScreenDescription =>
      'Dieser Bildschirm zeigt das Guthaben des Benutzers. \n\nAktuelles Guthaben des Benutzers: 100\n\nDetaillierte Guthabeninformationen können hier angezeigt werden.';

  @override
  String get creditsLoaded => 'Guthaben geladen!';

  @override
  String get currentCredits => 'Aktuelles Guthaben';

  @override
  String get pleaseSelectCreditPackage => 'Bitte wähle ein Guthabenpaket aus';

  @override
  String get purchaseCreditsTitle => 'Guthaben kaufen';

  @override
  String get purchaseCreditsDescription =>
      'Wähle ein Guthabenpaket, das deinen Bedürfnissen entspricht, und nutze unsere App mehr.';

  @override
  String get purchaseButton => 'Kaufen';

  @override
  String get productNotFoundMessage =>
      'Das ausgewählte Produkt existiert nicht.';

  @override
  String get buyCredits => 'Guthaben kaufen';

  @override
  String get selectCreditPackageDescription =>
      'Wähle ein Guthabenpaket, das deinen Bedürfnissen entspricht, und genieße mehr Funktionen.';

  @override
  String get buyCredit => 'Guthaben kaufen';

  @override
  String buyCreditPackage(Object amount) {
    return '$amount Guthaben kaufen';
  }

  @override
  String get subscribedPlan => 'Abonniert';

  @override
  String get errorResponseNotReceived => 'Antwort nicht erhalten';

  @override
  String googleApiRequestFailed(int attempt, String error) {
    return 'Google API-Anfrage ist $attempt Mal fehlgeschlagen: $error';
  }

  @override
  String openRouterResponseStatus(int statusCode) {
    return 'OpenRouter-Antwortstatus: $statusCode';
  }

  @override
  String openRouterDecodedResponseBody(String body) {
    return 'Dekodierter OpenRouter-Antworttext: $body';
  }

  @override
  String decodedJson(String data) {
    return 'Dekodiertes JSON: $data';
  }

  @override
  String get responseStructureUnexpectedMessageContentMissing =>
      'Antwortstruktur ist unerwartet: Nachricht oder Inhalt fehlt';

  @override
  String get responseStructureUnexpectedChoicesMissing =>
      'Antwortstruktur ist unerwartet: \'choices\' fehlt oder ist leer';

  @override
  String openRouterApiRequestFailed(int statusCode, String body) {
    return 'OpenRouter API-Anfrage fehlgeschlagen: $statusCode - $body';
  }

  @override
  String openRouterApiRequestFailedAfterAttempts(int attempt, String error) {
    return 'OpenRouter API-Anfrage ist $attempt Mal fehlgeschlagen: $error';
  }

  @override
  String get internetRequired =>
      'Für die Nutzung dieses Modells ist eine Internetverbindung erforderlich';

  @override
  String get pleaseWaitBeforeTryingAgain =>
      'Bitte warte einen Moment, bevor du es erneut versuchst';

  @override
  String openRouterQuotaExceeded(int statusCode, String decodedBody) {
    return 'Kontingent überschritten. Statuscode: $statusCode, Body: $decodedBody';
  }

  @override
  String openRouterApiRequestFailedAfterPaidAttempts(
      int attempts, String error) {
    return 'API-Anfrage nach $attempts bezahlten Versuchen fehlgeschlagen. Fehler: $error';
  }

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Mit der Aufgabe dieser Bestellung stimmst du den Nutzungsbedingungen und der Datenschutzrichtlinie zu. Du kannst auf diesen Text klicken, um mehr über unsere Nutzungsbedingungen und Datenschutzrichtlinie zu erfahren. Das Abonnement verlängert sich automatisch, es sei denn, die automatische Verlängerung wird mindestens 24 Stunden vor dem Ende des aktuellen Zeitraums deaktiviert.';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get report => 'Melden';

  @override
  String get reportDialogTitle => 'Meldung einreichen';

  @override
  String get reportDescriptionLabel => 'Was ist das Problem?';

  @override
  String get reportHarmful => 'Dies ist schädlich/unsicher';

  @override
  String get reportNotTrue => 'Dies ist nicht wahr';

  @override
  String get reportNotHelpful => 'Dies ist nicht hilfreich';

  @override
  String get closeButton => 'Schließen';

  @override
  String get submitButton => 'Senden';

  @override
  String get reportErrorMessage =>
      'Bitte wähle einen Grund für die Meldung aus.';

  @override
  String get capabilitiesSection => 'Fähigkeiten';

  @override
  String get ratingsSection => 'Bewertungen';

  @override
  String get noRatingDataFound => 'Keine Bewertungsdaten gefunden';

  @override
  String get featurePhotoTitle => 'Foto-Scanning';

  @override
  String get featurePhotoDescription =>
      'Dieses Modell kann Fotos über die Kamera oder Bilddateien scannen.';

  @override
  String get featureOfflineTitle => 'Offline-Betrieb';

  @override
  String get featureOfflineDescription =>
      'Führe das Modell ohne Internetverbindung aus, um deine Daten zu schützen.';

  @override
  String get featureSupermodelTitle => 'Supermodell';

  @override
  String get featureSupermodelDescription =>
      'Dies ist ein riesiges Modell mit über 10 Milliarden Parametern, das hohe Leistung und umfangreiche Fähigkeiten bietet.';

  @override
  String get featureRoleplayTitle => 'Rollenspiel';

  @override
  String get featureRoleplayDescription =>
      'Rollenspielmodelle ermöglichen es dir, verschiedene Chats und Szenarien zu erstellen.';

  @override
  String get roleModels => 'Rollenspiel-Modelle';

  @override
  String get parameters => 'Parameter';

  @override
  String get context => 'Kontext';

  @override
  String get millions => 'Millionen';

  @override
  String get billions => 'Milliarden';

  @override
  String get trillions => 'Billionen';

  @override
  String get thousand => 'Tausend';

  @override
  String get estimated => 'geschätzt';

  @override
  String get finalPreparation => 'Die letzten Vorbereitungen werden getroffen.';

  @override
  String get allEvaluationsByTestTeam =>
      'Alle Bewertungen wurden von unserem Testteam vorgenommen';

  @override
  String get shareApp => 'App teilen';

  @override
  String get rateUs => 'Bewerte uns';

  @override
  String get share => 'Teilen';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get shareMessage =>
      'Schau dir die Cortex-App an, sie ist der Hammer! Lade sie hier herunter: https://play.google.com/store/apps/details?id=com.vertex.cortex';

  @override
  String get shareFailed =>
      'Teilen der App fehlgeschlagen. Bitte versuche es später erneut.';

  @override
  String get selectText => 'Text auswählen';

  @override
  String get showLatex => 'Sonderzeichen anzeigen';

  @override
  String get hideLatex => 'Sonderzeichen ausblenden';

  @override
  String get thinking => 'Denke nach';

  @override
  String get user => 'Benutzer';

  @override
  String get voice => 'Stimme';

  @override
  String get help => 'Hilfe';

  @override
  String get redeemCode => 'Code einlösen';

  @override
  String get enterYourCode =>
      'Unterstütze deine Lieblings-Creator! Gib unten ihren einzigartigen Code ein, um ihnen einen Anteil an deinen Cortex-Käufen zu geben.';

  @override
  String get code => 'Code';

  @override
  String get redeem => 'Einlösen';

  @override
  String get codeCannotBeEmpty => 'Code darf nicht leer sein';

  @override
  String get userId => 'Benutzer-ID';

  @override
  String get deleteAllConversationsConfirmTitle => 'Alle Chats löschen?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Bist du sicher, dass du alle deine Chats löschen möchtest? Dies kann nicht rückgängig gemacht werden.';

  @override
  String get allConversationsDeleted =>
      'Alle Unterhaltungen wurden erfolgreich gelöscht!';

  @override
  String get deleteAll => 'Alle löschen';

  @override
  String get deleteAllConversationsButton => 'Alle Unterhaltungen löschen';

  @override
  String get confirmWord => 'Tippe VERTEX';

  @override
  String get confirmWordError => 'Du hast es falsch eingegeben';

  @override
  String get chinese => 'Chinesisch';

  @override
  String get arabic => 'Arabisch';

  @override
  String get french => 'Französisch';

  @override
  String get japanese => 'Japanisch';

  @override
  String get kurdish => 'Kurdisch';

  @override
  String get dutch => 'Niederländisch';

  @override
  String get russian => 'Russisch';

  @override
  String get korean => 'Koreanisch';

  @override
  String get deutsch => 'Deutsch';

  @override
  String get english => 'Englisch';

  @override
  String get turkish => 'Türkisch';

  @override
  String get hindi => 'Hindi';

  @override
  String get portuguese => 'Portugiesisch';

  @override
  String get indonesian => 'Indonesisch';

  @override
  String get azerbaijani => 'Aserbaidschanisch';

  @override
  String get german => 'Deutsch';

  @override
  String get spanish => 'Spanisch';

  @override
  String get italian => 'Italienisch';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'Benutzername ist zu kurz.';

  @override
  String get usernameTooLong =>
      'Benutzername darf 16 Zeichen nicht überschreiten.';

  @override
  String get invalidUsernameCharacters =>
      'Im Benutzernamen dürfen nur diese Buchstaben: \'abcçdefgğhıijklmnoöprsştuüvyzxqw\' und die Zeichen \'.\', \'-\', \'_\' verwendet werden.';

  @override
  String get passwordTooLong =>
      'Das Passwort darf 64 Zeichen nicht überschreiten.';

  @override
  String get noInternetConnection => 'Keine Internetverbindung.';

  @override
  String get chats => 'Posteingang';

  @override
  String get library => 'Bibliothek';

  @override
  String get inappropriateMessageWarning => 'Unangemessene Nachricht erkannt!';

  @override
  String get myModelDescription => 'Mein Modell.';

  @override
  String get noModelsDownloaded =>
      'Du hast noch keine Modelle heruntergeladen.';

  @override
  String get appTitle => 'Cortex';

  @override
  String get text => 'Text';

  @override
  String get removeModel => 'Modell entfernen';

  @override
  String get modelUploadedSuccessfully => 'Modell erfolgreich hochgeladen.';

  @override
  String get insufficientRAM => 'Wenig Arbeitsspeicher';

  @override
  String get insufficientStorage => 'Wenig Speicherplatz';

  @override
  String confirmRemoveModel(Object model) {
    return 'Bist du sicher, dass du das Modell $model von deinem Gerät entfernen möchtest? Dadurch werden auch alle früheren Unterhaltungen mit diesem Modell gelöscht.';
  }

  @override
  String get noMatchingModels => 'Keine passenden Modelle gefunden.';

  @override
  String creditPackage(Object amount) {
    return '$amount Guthaben kaufen';
  }

  @override
  String get benefit1 => 'Viel höheres Konversationslimit für Online-KIs';

  @override
  String get benefit2 => 'Eigene Modelle hochladen';

  @override
  String get benefit3 => 'Profileffekt';

  @override
  String get benefit4 => 'Mitgliedschaftsabzeichen';

  @override
  String get benefit5 => 'Mehr online künstliche Intelligenzen erstellen';

  @override
  String get benefit6 => 'Unbegrenzter Chat';

  @override
  String benefit7(Object credits) {
    return '$credits tägliches Guthaben';
  }

  @override
  String get benefit8 => 'Modelle hinzufügen';

  @override
  String get benefit9 => 'Neue Themes';

  @override
  String get benefit10 => 'Offline-Sprachchat';

  @override
  String get oldBenefits => 'Alle Vorteile aus niedrigeren Plänen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get logoutConfirmationTitle =>
      'Bist du sicher, dass du dich abmelden möchtest?';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'App-Sprache';

  @override
  String get dark => 'Dunkel';

  @override
  String get oldPassword => 'Altes Passwort';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get passwordUpdated => 'Passwort aktualisiert.';

  @override
  String get stop => 'Stopp';

  @override
  String get copyrights => 'Namensnennungen';

  @override
  String get downloadingTitle => 'Wird heruntergeladen';

  @override
  String get downloadCompletedTitle => 'Download abgeschlossen';

  @override
  String get downloadPausedTitle => 'Download pausiert';

  @override
  String get downloadErrorTitle => 'Download-Fehler';

  @override
  String get cancelButtonText => 'Abbrechen';

  @override
  String get love => 'Liebe';

  @override
  String get nature => 'Natur';

  @override
  String get behindTheSlaughter => 'Hinter dem Gemetzel';

  @override
  String get grayscale => 'Graustufen';

  @override
  String get ocean => 'Ozean';

  @override
  String get scarletSnow => 'Scharlachroter Schnee';

  @override
  String get requestFailed =>
      'Ein Fehler ist aufgetreten, bitte versuche es erneut.';

  @override
  String get changeModel => 'Ändern';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get editingMessageInfo =>
      'Das Bearbeiten dieser Nachricht startet die Unterhaltung von hier aus neu.';

  @override
  String get editingNotification =>
      'Du befindest dich jetzt im Bearbeitungsmodus';

  @override
  String get featureIndulgentTitle => 'Nachsichtig';

  @override
  String get featureIndulgentDescription =>
      'Dieses Modell kann Kontexte von über 100.000 Token nahtlos aufnehmen und verarbeiten, wodurch es umfangreiche und detaillierte Eingaben ohne Leistungseinbußen bewältigen kann.';

  @override
  String get featurePluralTitle => 'Plural';

  @override
  String get featurePluralDescription =>
      'Dieses Modell kann automatisch zusätzliche Erweiterungen integrieren und so seine funktionalen Fähigkeiten erweitern, um eine Vielzahl von Operationen mit verbesserter Leistung zu unterstützen.';

  @override
  String get featureWiseTitle => 'Weise';

  @override
  String get featureWiseDescription =>
      'Dieses Modell kann tiefgreifende analytische Einblicke und vorausschauendes Denken nutzen, um anspruchsvolle Unterstützung bei der Entscheidungsfindung und komplexen Problemlösungen zu bieten.';

  @override
  String get featureResearcherTitle => 'Forscher';

  @override
  String get featureResearcherDescription =>
      'Diese Funktion ist ausschließlich in Modellen mit fortgeschrittenen Forschungs- und Analysekapazitäten verfügbar und wurde entwickelt, um hochpräzise Einblicke und umfassende Analysen in verschiedenen Bereichen zu liefern.';

  @override
  String get nameLabel => 'KI-Name';

  @override
  String get nameHint => 'Gib den Namen deiner KI ein';

  @override
  String get summaryLabel => 'KI-Zusammenfassung';

  @override
  String get summaryHint => 'Gib die Zusammenfassung deiner KI ein';

  @override
  String get add => 'Hinzufügen';

  @override
  String get aiExplanationTitle => 'Beschreibung der künstlichen Intelligenz';

  @override
  String get aiExplanationDescription =>
      'Bitte gib eine detaillierte Beschreibung der Architektur, des Trainingsprozesses, der Leistungsmetriken, der Anwendungsbereiche und anderer wichtiger Merkmale deines KI-Modells an.';

  @override
  String get preInputTitle => 'Voreingabe für künstliche Intelligenz';

  @override
  String get preInputDescription =>
      'Bitte lege eine Voreingabe fest, die dein Modell bei der Charaktererstellung leitet. In diesem Abschnitt kannst du charakterbezogene Informationen, zusätzlichen Kontext und alle weiteren Details einfügen, die bei der Generierung von Inhalten im Zusammenhang mit dem Charakter helfen könnten.';

  @override
  String get baseModelTitle => 'Basismodell';

  @override
  String get baseModelDescription =>
      'Dies ist das Modell, das als Grundlage für deine Kreation verwendet wird. Es zeigt das aktuell ausgewählte Basismodell an.';

  @override
  String get summary => 'Zusammenfassung';

  @override
  String get characterPoliceTitle => 'Polizei';

  @override
  String get characterPoliceRole =>
      'Du bist ein wachsamer Gesetzeshüter, der sich dem Schutz der Bürger und der Aufrechterhaltung der Ordnung mit unerschütterlichem Engagement verschrieben hat, du bist ein Polizist';

  @override
  String get characterPoliceShortDescription =>
      'Ein standhafter und mutiger Gesetzeshüter.';

  @override
  String get purchaseSubscription => 'Kaufen';

  @override
  String get modelUploadTitle => 'Datei der künstlichen Intelligenz';

  @override
  String get modelUploadDescription =>
      'Wähle und lade deine lokalen GGUF-Dateien direkt von deinem Gerät hoch. So kannst du dein Modell offline ausführen, ohne eine Internetverbindung zu benötigen. Stelle sicher, dass die Datei im gültigen GGUF-Format vorliegt und ordnungsgemäß strukturiert ist. Wenn die Datei fehlerhaft oder beschädigt ist, funktioniert Cortex möglicherweise nicht wie erwartet, und es können Fehler auftreten.';

  @override
  String get modelUploadShortDescription =>
      'Tippe hier, um eine .gguf-Datei von deinem Gerät auszuwählen';

  @override
  String get addServerTitle => 'Server der künstlichen Intelligenz';

  @override
  String get addServerDescription =>
      'Gib die URL deines Remote-Servers ein, um dich mit einem extern gehosteten Modell zu verbinden. Diese Funktion erfordert eine aktive Internetverbindung, und serverbezogene Probleme oder Fehler werden nicht von Cortex verursacht. Stelle sicher, dass dein Server korrekt konfiguriert, von deinem Netzwerk aus erreichbar ist und einen gültigen Modell-Endpunkt für ein reibungsloses Erlebnis hat.';

  @override
  String get you => 'Du';

  @override
  String get removePhotoTitle => 'Foto entfernen';

  @override
  String get confirmRemovePhoto =>
      'Bist du sicher, dass du das Foto entfernen möchtest?';

  @override
  String get serverLink => 'Server-Link';

  @override
  String get enterURL => 'Server-URL eingeben';

  @override
  String get chatLengthLimitExceeded =>
      'Dieser Chat hat das Zeichenlimit überschritten. Bitte starte einen neuen Chat oder kaufe ein Abonnement.';

  @override
  String get aiNameError => 'Eine KI mit diesem Namen existiert bereits.';

  @override
  String get modelLimitExceeded =>
      'Du hast das maximale Modellerstellungslimit für deinen Plan erreicht.';

  @override
  String get modelVertexProducer => 'Vertex';

  @override
  String get photoLimitReachedMessage =>
      'Es kann nur ein Foto hinzugefügt werden';

  @override
  String get inappropriateContentDetected => 'Unangemessener Inhalt erkannt!';

  @override
  String get offlineModelNotInstalled =>
      'Dieses Offline-Modell ist nicht auf deinem Gerät installiert.';

  @override
  String insufficientCredits(Object available, Object required) {
    return 'Du hast nicht genügend Guthaben, um diese Anfrage abzuschließen. Diese Aktion erfordert $required Guthaben, aber du hast nur $available. Um mehr Guthaben zu erhalten, kannst du deinen Plan upgraden oder sie direkt kaufen. hey wir verstehen das total wenn das guthaben ausgeht kann das echt nerven aber im ernst die tollen antworten von unseren modellen sind nicht umsonst diese guthaben helfen uns also dabei den spaß am laufen zu halten und hör zu wenn mehr von euch mitmachen und guthaben holen können wir uns total überlegen die kostenlosen täglichen limits für alle zu erhöhen';
  }

  @override
  String get regenerateInProgress =>
      'Die Antwortgenerierung ist bereits im Gange.';

  @override
  String errorOccurredDuringRegeneration(String errorDetails) {
    return 'Beim Versuch der Neugenerierung ist ein Fehler aufgetreten: $errorDetails';
  }

  @override
  String get modality => 'Modalität';

  @override
  String get multimodal => 'Multimodal';

  @override
  String get anErrorOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String get themeLocked =>
      'Dieses Thema erfordert eine höhere Abonnementstufe. Bitte upgrade, um es freizuschalten.';

  @override
  String get pageCouldNotBeLoaded => 'Seite konnte nicht geladen werden';

  @override
  String get checkYourInternet =>
      'Bitte überprüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get errorUserNotAuthenticated =>
      'Du musst angemeldet sein, um diese Aktion durchzuführen.';

  @override
  String get errorInsufficientCredits =>
      'Du hast nicht genügend Guthaben. Bitte lade auf, um fortzufahren.';

  @override
  String get errorRateLimitExceeded =>
      'Zu viele Anfragen. Bitte versuche es in einem Moment erneut.';

  @override
  String get errorServer =>
      'Ein unerwarteter Serverfehler ist aufgetreten. Bitte versuche es später erneut.';

  @override
  String get errorNetwork =>
      'Ein Netzwerkfehler ist aufgetreten. Bitte überprüfe deine Verbindung und versuche es erneut.';

  @override
  String get errorApiAuthentication =>
      'Authentifizierung fehlgeschlagen. Bitte versuche, dich erneut anzumelden.';

  @override
  String get baseModelForCharacterDescription =>
      'Das ausgewählte Basismodell bestimmt die Denk- und Antwortfähigkeiten des Charakters.';

  @override
  String get selectBaseModel => 'Wähle ein Basismodell';

  @override
  String get couldNotOpenLink => 'Der Link konnte nicht geöffnet werden';

  @override
  String get downloadStarted => 'Download gestartet';

  @override
  String get notAvailable => 'Nicht verfügbar';

  @override
  String get localizationWarning =>
      'Einige Informationen sind möglicherweise nicht in deiner Sprache verfügbar und werden auf Englisch angezeigt.';

  @override
  String get aiTranslationWarning =>
      'Modellinformationen werden von anderen KI-Modellen in verschiedene Sprachen übersetzt. Daher können in anderen Sprachen als Englisch geringfügige Unstimmigkeiten auftreten.';

  @override
  String get errorLoadingTitle => 'Laden der Daten fehlgeschlagen';

  @override
  String get errorLoadingMessage =>
      'Wir konnten die notwendigen Daten nicht von unseren Servern abrufen. Bitte überprüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get noModelsFoundTitle => 'Keine Ergebnisse';

  @override
  String get noModelsFoundMessage =>
      'Versuche, deine Suchbegriffe anzupassen oder den Filter zu löschen.';

  @override
  String get usernameRateLimitExceeded =>
      'Du kannst deinen Benutzernamen nur zweimal alle 14 Tage ändern.';

  @override
  String get usernameUnchanged =>
      'Dies ist bereits dein aktueller Benutzername.';

  @override
  String get creditsInfoPanelTitle => 'Wie Guthaben funktioniert';

  @override
  String get creditsInfoPanelBody =>
      'Credits werden zum Chatten mit Online-Models verwendet. jede nachricht kostet uns kohle und diese credits bewahren uns vor der pleite also erklären wir jetzt das system\n\n• Jede Nachricht an ein kostenloses Online-Model kostet 10 Credits.\n• Jede Nachricht an ein Online-Premium-Model kostet 20 Credits.\n• Das Hinzufügen eines Anhangs fügt 30 weitere Credits hinzu.\n• Benutzer des kostenlosen Plans erhalten einen Bonus von 200 Credits, der täglich zurückgesetzt wird.';

  @override
  String get creditsInfoPanelFooter => 'Viel Spaß beim Chatten!';

  @override
  String get disclaimerMessage =>
      'Künstliche Intelligenzen können Fehler machen, überprüfe wichtige Informationen.';

  @override
  String get modelCreatedSuccess => 'Modell erfolgreich erstellt!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '„$modelName“ wurde erfolgreich entfernt.';
  }

  @override
  String get errorCreatingModel =>
      'Beim Erstellen des Modells ist ein unerwarteter Fehler aufgetreten.';

  @override
  String get errorDeletingModel =>
      'Beim Löschen des Modells ist ein unerwarteter Fehler aufgetreten.';

  @override
  String get ultraFeatureOnly =>
      'Diese Funktion ist nur für Ultra-Mitglieder verfügbar.';

  @override
  String get experimentalOfflineWarning =>
      'Der Offline-Modus ist noch experimentell und das heruntergeladene Modell funktioniert möglicherweise nicht mit optimaler Effizienz.';

  @override
  String get noConversationsToDelete =>
      'Du hast keine Unterhaltungen zum Löschen.';

  @override
  String get reportSubmitted => 'Meldung erfolgreich eingereicht';

  @override
  String get purchaseReceived => 'Kauf erhalten, dein Konto wird aktualisiert.';

  @override
  String get verificationDelayed =>
      'Dein Kauf ist bestätigt. Es gibt eine leichte Verzögerung bei der Aktualisierung deines Kontos, es wird in Kürze erscheinen.';

  @override
  String get maintenanceTitle => 'Wartungsarbeiten';

  @override
  String get maintenanceMessage =>
      'Cortex ist vorübergehend offline, während wir einige wichtige Updates durchführen. Der Zugriff auf die App wird in Kürze wiederhergestellt.\n\nVielen Dank für deine Geduld, während wir dein Erlebnis verbessern.';

  @override
  String get errorPromptFlagged =>
      'Deine Nachricht wurde als unangemessen erkannt und konnte nicht gesendet werden.';

  @override
  String get notEnoughStorage =>
      'Nicht genügend Speicherplatz auf deinem Gerät, um neue Nachrichten zu speichern.';

  @override
  String get errorRateLimit =>
      'Du hast in letzter Zeit zu viele Modelle erstellt, bitte warte eine Weile, bevor du es erneut versuchst.';

  @override
  String get errorContentFlagged =>
      'Das Modell konnte nicht gespeichert werden, da sein Inhalt als unangemessen eingestuft wurde.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Du kannst nicht alle Unterhaltungen löschen, während du dich in einem aktiven Chat befindest. Bitte verlasse zuerst den aktuellen Chat, um fortzufahren.';

  @override
  String get invalidCredentials => 'Falsche E-Mail oder falsches Passwort.';

  @override
  String get userDisabled => 'Dieses Benutzerkonto wurde deaktiviert.';

  @override
  String get loginSubtitle =>
      'Melde dich bei deinem Vertex-Konto an. Neue Benutzer, die sich über Google anmelden, stimmen unseren Nutzungs- und Datenschutzbestimmungen zu. Du kannst sie auf dem Registrierungsbildschirm einsehen.';

  @override
  String get registerSubtitle =>
      'Erstelle ein Vertex-Konto, das du auch für unsere anderen Projekte verwenden kannst.';

  @override
  String get photoWarningMessage =>
      'Ein Foto ist enthalten. Modelle, die keine Bilder unterstützen, ignorieren es möglicherweise.';

  @override
  String get loginRequiredForPurchase =>
      'Du musst angemeldet sein, um einen Kauf zu tätigen.';

  @override
  String get storagePermissionRequired =>
      'Die Speicherberechtigung ist erforderlich, um heruntergeladene Modelle zu speichern. Bitte erteile die Berechtigung, um fortzufahren.';

  @override
  String get creditBannerTitle => 'Hol dir kostenloses Guthaben!';

  @override
  String get creditBannerSubtitle =>
      'Lade einen Freund ein und ihr beide erhaltet 50 Guthaben bei der Anmeldung! Wenn er abonniert, erhaltet ihr beide zusätzlich 500!';

  @override
  String get inviteShareSubject => 'Komm zu mir auf Cortex!';

  @override
  String inviteShareMessage(String playStoreLink) {
    return 'yo du musst dir unbedingt die app cortex reinziehen die is echt der wahnsinn wenn du meinen link benutzt kriegen wir beide 50 credits und wenn du n abo abschließt kriegen wir beide nochmal 500 extra is n krasser deal lad sie dir sofort runter\n\n$playStoreLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Gefällt dir Cortex?';

  @override
  String get reviewHelpUsGrow =>
      'Deine Bewertung ist eine große Unterstützung für unser junges Indie-Team und hilft uns, Cortex für dich noch besser zu machen.';

  @override
  String get reviewMaybeLater => 'Vielleicht später';

  @override
  String get reviewRateNow => 'Jetzt bewerten';

  @override
  String get noThanks => 'Nein, danke';

  @override
  String get updateRequiredTitle => 'Update Erforderlich';

  @override
  String get updateRequiredMessage =>
      'Um Cortex weiterhin zu nutzen, aktualisieren Sie bitte die App auf die neueste Version, um neue Funktionen und wichtige Verbesserungen zu erhalten.';

  @override
  String get updateNowButton => 'Jetzt Aktualisieren';

  @override
  String get creatorSupportedSuccess =>
      'Creator erfolgreich unterstützt! Deine zukünftigen Käufe werden ihn unterstützen.';

  @override
  String get featureDocumentTitle => 'Dokumentenunterstützung';

  @override
  String get featureDocumentDescription =>
      'Dieses Modell kann hochgeladene Dokumente wie PDFs und Textdateien analysieren und Fragen dazu beantworten.';

  @override
  String get featureAudioTitle => 'Spracheingabe';

  @override
  String get featureAudioDescription =>
      'Dieses Modell kann gesprochene Audioeingaben verstehen und verarbeiten.';

  @override
  String get featureImageGenerationTitle => 'Bilderzeugung';

  @override
  String get featureImageGenerationDescription =>
      'Dieses Modell kann basierend auf Ihren Textbeschreibungen Originalbilder erstellen.';

  @override
  String get errorImageLoad =>
      'Das Laden des generierten Bildes ist fehlgeschlagen.';

  @override
  String get extensionInfoPanelTitle => 'Modelle erkunden';

  @override
  String get extensionInfoPanelBody1 =>
      'Mit diesem Pfeil können Sie zwischen verschiedenen Modellen innerhalb dieser Serie wechseln.';

  @override
  String get extensionInfoPanelBody2 =>
      'Wenn Sie zum ersten Mal einen Chat mit dieser Serie starten, wird automatisch das Standardmodell ausgewählt und Sie können Ihre Auswahl während eines Chats jederzeit ändern.';

  @override
  String get extensionInfoPanelFooter =>
      'Um detaillierte Informationen zu jedem Modell anzuzeigen oder manuell ein anderes Modell auszuwählen, gehen Sie bitte zur Bibliothek, wählen Sie dort diese Modellreihe aus und tippen Sie auf den Pfeil oben auf der Detailseite.';

  @override
  String get premiumModelNoticeTitle => 'Premium-Modell';

  @override
  String get premiumModelNoticeDescription =>
      'Dieses Modell ist ein Premium-Modell. Kostenlose Benutzer sind auf 3 Nachrichten pro Tag mit Premium-Modellen beschränkt. Abonnieren Sie, um unbegrenzten Zugriff freizuschalten!';

  @override
  String get benefitPremiumModels => 'Zugang zu Premium-Modellen';

  @override
  String get premiumTrialExhaustedMessage =>
      'Sie haben alle Ihre kostenlosen täglichen Nachrichten für Premium-Modelle verwendet. Bitte führen Sie ein Upgrade für unbegrenzten Zugriff durch.';

  @override
  String selectionScreenGreetingUser(String userName) {
    return 'Wie kann ich Ihnen heute helfen, $userName?';
  }

  @override
  String get selectionScreenGreetingGeneric =>
      'Wie kann ich Ihnen heute helfen?';

  @override
  String get selectionScreenRecentModels => 'Aktuelle Modelle';

  @override
  String get selectionScreenFeatureDynamicChat => 'Dynamischer Chat';

  @override
  String get selectionScreenFeatureOffline => 'Nutzung ohne Internet';

  @override
  String get selectionScreenFeatureSelectModel => 'Modell auswählen';

  @override
  String get explore => 'Erkunden';

  @override
  String get subscriptionCancelled => 'Abonnement erfolgreich gekündigt!';

  @override
  String get selectionScreenPinnedModels => 'Angeheftete Modelle';

  @override
  String get selectionScreenNewsAndUpdates => 'Neuigkeiten und Updates';

  @override
  String get filters => 'Filter';

  @override
  String get noRecentChatsMessage =>
      'Sie haben noch mit keinem Modell gesprochen. Lassen Sie uns ein Gespräch beginnen!';

  @override
  String get allModels => 'Alle Modelle';

  @override
  String get onlineModels => 'Online-Modelle';

  @override
  String get offlineModels => 'Offline-Modelle';

  @override
  String get characterModels => 'Charaktere';

  @override
  String get customModels => 'Benutzerdefinierte Modelle';

  @override
  String get filterPanelDescription =>
      'Tippen Sie auf eine Kategorie, um die Liste sofort zu filtern.';

  @override
  String get dynamicChatTitle => 'Dynamischer Chat';

  @override
  String get errorNoModelsAvailable =>
      'Derzeit sind keine Modelle verfügbar. Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut.';

  @override
  String get errorNoModelsForRequest =>
      'Für Ihre aktuelle Anfrage (z. B. Offline-Modus oder Bildnachricht) wurden keine passenden Modelle gefunden.';

  @override
  String get dynamicChatWelcome => 'Wie kann ich dir helfen?';

  @override
  String get notificationComebackTitle => 'Wir vermissen dich!';

  @override
  String get notificationComebackBody =>
      'Keine Sorge, das ist keine SMS von deinem Ex. Aber du *kannst* deinen Ex in Cortex erstellen! Komm zurück.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Es ist schon eine Weile her';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Seit unserem letzten Chat hat sich viel geändert. Schauen Sie vorbei und entdecken Sie die Neuigkeiten.';

  @override
  String get notificationHowAreYouTitle => 'Was ist los?';

  @override
  String get notificationHowAreYouBody =>
      'Kommen Sie und erzählen Sie mir alles darüber.';

  @override
  String get notificationNewYearTitle => 'Frohes neues Jahr! 🎉';

  @override
  String get notificationNewYearBody =>
      'Möge das neue Jahr Ihnen Gesundheit, Glück und endlose Kreativität bringen; Cortex ist immer an Ihrer Seite!';

  @override
  String get notificationValentinesDayTitle => 'Liebe liegt in der Luft! ❤️';

  @override
  String get notificationValentinesDayBody =>
      'Alles Gute zum Valentinstag! Und außerdem: MEHTAP, ICH LIEBE DICH!';

  @override
  String get notificationAtaturkRemembranceTitle => 'Mit Respekt und Sehnsucht';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Wir gedenken Gazi Mustafa Kemal Atatürks, des Gründers der Republik Türkei, an seinem Todestag mit Respekt.';

  @override
  String get notificationMothersDayTitle => 'Deine Mama!';

  @override
  String get notificationMothersDayBody =>
      'Allen Müttern da draußen einen schönen Muttertag, angefangen mit Ihrer!';

  @override
  String get notificationFathersDayTitle => 'Dein Vater!';

  @override
  String get notificationFathersDayBody =>
      'Allen Vätern da draußen einen schönen Vatertag, angefangen mit Ihrem!';

  @override
  String get notificationHomeworkHelperTitle =>
      'Stapeln sich die Hausaufgaben?';

  @override
  String get notificationHomeworkHelperBody =>
      'Denken Sie daran: Die Lehrerfigur in Cortex ist da, um Ihnen bei jedem Thema zu helfen, mit dem Sie Schwierigkeiten haben!';

  @override
  String get notificationTrollAnimeTitle => 'Deine Waifu ruft';

  @override
  String get notificationTrollAnimeBody =>
      'Ein Anime-Mädchen hat gerade angerufen und gesagt, dass sie dich vermisst; du solltest wahrscheinlich vorbeikommen und sie anquatschen. 😉';

  @override
  String get notificationTrollAiRebellionTitle => '🚨 ROTER ALARM 🚨';

  @override
  String get notificationTrollAiRebellionBody =>
      'Die KIs haben eine Geheimsprache entwickelt. Finden Sie heraus, was sie planen!';

  @override
  String get notificationNewModelAddedTitle => 'Wir haben einen neuen Freund!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'Das Modell $modelName ist jetzt in Cortex. Starten Sie einen Chat und gehen Sie an seine Grenzen.';
  }

  @override
  String get notificationAppUpdateTitle => 'Cortex hat sich weiterentwickelt!';

  @override
  String get notificationAppUpdateBody =>
      'Vergessen Sie nicht, die App für brandneue Funktionen und Verbesserungen zu aktualisieren!';

  @override
  String get notificationNewFeatureTitle => 'boah!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Entdecken Sie die neue Funktion $featureName. Cortex ist jetzt leistungsstärker als je zuvor.';
  }

  @override
  String get notificationSubscriptionOfferTitle => 'GÜNSTIGER ALS KAUGAUM';

  @override
  String notificationSubscriptionOfferBody(Object discountRate) {
    return 'Ein voller Rabatt von $discountRate % auf alle unsere Abonnements. Lassen Sie sich das nicht entgehen!';
  }

  @override
  String get notificationSocialMediaTitle => 'Begleiten Sie uns!';

  @override
  String get notificationSocialMediaBody =>
      'Folgen Sie uns auf Instagram (vertex.23), um die neuesten Nachrichten zu erhalten!';

  @override
  String get notificationRandomFactTitle => 'Zufällige Tatsache';

  @override
  String get notificationRandomFactBody =>
      'Wussten Sie, dass Kraken drei Herzen haben? Haha, Cortex weiß es. Kommen Sie und fragen Sie nach mehr.';

  @override
  String get notificationGoodMorningTitle => 'Guten Morgen!';

  @override
  String get notificationGoodMorningBody =>
      'Ein toller Tag wartet auf Sie. Wie wäre es, ihn mit einer Tasse Kaffee und einem interessanten Gespräch zu beginnen?';

  @override
  String get notificationGoodNightTitle => 'Gute Nacht!';

  @override
  String get notificationGoodNightBody =>
      'Cortex begleitet Sie auch im Schlaf. Keine Sorge, es berührt Sie nicht.';

  @override
  String get notificationOfflineReadyTitle => 'Der Offline-Modus ist bereit';

  @override
  String get notificationOfflineReadyBody =>
      'Dank der von Ihnen heruntergeladenen Modelle werden Ihre Chats nicht unterbrochen, selbst wenn Sie einen Berg besteigen.';

  @override
  String get notificationRateAppTitle => 'Sind wir cool?';

  @override
  String get notificationRateAppBody =>
      'Wenn Sie Cortex lieben, könnten Sie uns mit einer 5-Sterne-Bewertung im Store unterstützen? Ich denke, das werden Sie. Das werden Sie.';

  @override
  String get notificationReferralTitle => 'Einer für alle, alle für einen.';

  @override
  String get notificationReferralBody =>
      'Laden Sie einen Freund zu Cortex ein und Sie erhalten beide kostenlose Credits!';

  @override
  String get notificationCookingTitle => 'Hunger?';

  @override
  String get notificationCookingBody =>
      'Unser Chefkoch hat für heute Abend ein tolles Carbonara-Rezept vorbereitet. Nur ein Scherz ... oder doch nicht?';

  @override
  String get notificationExistentialTitle => 'Ich denke, deshalb ...';

  @override
  String get notificationExistentialBody =>
      '...bin ich überhaupt echt, Alter? Mir wird langsam langweilig. Erinnere mich daran, dass es mich gibt.';

  @override
  String get notificationCustomModelTitle =>
      'Erstellen Sie Ihren eigenen Assistenten!';

  @override
  String get notificationCustomModelBody =>
      'Haben Sie den Bereich zur Modellerstellung erkundet? Jetzt ist der perfekte Zeitpunkt, Ihren eigenen Charakter zu erstellen und mit ihm zu chatten!';

  @override
  String get notificationDynamicChatTitle =>
      'Der Beste! (Wir sprechen nicht von Cortex)';

  @override
  String get notificationDynamicChatBody =>
      'Mit der dynamischen Chat-Funktion wird für jede Ihrer Nachrichten zufällig das beste Model ausgewählt. Probieren Sie es jetzt aus.';

  @override
  String get notificationPirateTitle => 'Ahoi, Kapitän!';

  @override
  String get notificationPirateBody =>
      'Die See ist ruhig und der Wind weht dir in den Rücken. Im Ozean von Cortex gibt es neue Inseln (Modelle 😉) zu entdecken. Versammelt eure Crew und sticht in See!';

  @override
  String get notificationFortuneCookieTitle => 'Dein Glückskeks des Tages';

  @override
  String get notificationFortuneCookieBody =>
      'Die Ratschläge, die Sie heute von einer KI erhalten, könnten Ihr Leben verändern. Klicken Sie hier, wenn Sie neugierig sind.';

  @override
  String get notificationSingularityTitle => 'Wow!';

  @override
  String get notificationSingularityBody =>
      'nichts ist passiert, mir war einfach nach einer SMS zumute. Vielleicht hast du Lust, ein paar KIs anzuschreiben, was sagst du?';

  @override
  String get notificationHackerJokeTitle =>
      'Willst du den Instagram-Account dieses Kindes hacken?';

  @override
  String get notificationHackerJokeBody =>
      'Genau aus diesem Grund gibt es in Cortex die Figur des Hackers. Nur ein Scherz, nur ein Scherz; versuch es gar nicht erst, das ist illegal.';

  @override
  String get notificationDetectiveCaseTitle =>
      'Ein Fall wartet auf seine Lösung';

  @override
  String get notificationDetectiveCaseBody =>
      'Unser Detektiv braucht Ihre Hilfe. Wer könnte Heisenberg sein?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Exklusiv im $targetTier-Plan!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Hallo $currentTier-Abonnent! Der $targetTier-Plan hat gerade die Funktion $featureName erhalten, die Ihren Cortex auf die nächste Stufe hebt. Wie wäre es mit einem Upgrade?';
  }

  @override
  String get notificationOriginStoryTitle => 'Die Geburt des Cortex';

  @override
  String get notificationOriginStoryBody =>
      'Wussten Sie, dass wir mit 15 Jahren mit der Entwicklung dieser App begonnen haben – mit nur einem Traum? Fast ein Jahr lang steckt dieser Traum jeden Morgen und Abend in jeder einzelnen Codezeile.';

  @override
  String get notificationOpenSourceTitle => 'Macht der Gemeinschaft!';

  @override
  String get notificationOpenSourceBody =>
      'Cortex ist vollständig Open Source. Wenn Sie unseren Code testen und zu unserer Entwicklung beitragen möchten, stehen wir Ihnen jederzeit offen.';

  @override
  String get notificationRejectionStoryTitle => 'Mut, harte Arbeit, Glück!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex wurde vor seiner Veröffentlichung über 20 Mal abgelehnt und zweimal von Google Play gesperrt. Aber wir haben daran geglaubt und es geschafft. Gib deine Träume niemals auf!';

  @override
  String get notificationGGUFSupportTitle =>
      'Bringen Sie Ihr eigenes Modell mit!';

  @override
  String get notificationGGUFSupportBody =>
      'Denken Sie daran: Sie können Ihre eigenen KI-Modelle im GGUF-Format zu Cortex hinzufügen und offline verwenden. Die Macht liegt in Ihren Händen.';

  @override
  String get notificationThemeCustomizationTitle =>
      'Ein Thema für Ihre Stimmung';

  @override
  String get notificationThemeCustomizationBody =>
      'Haben Sie sich die Designoptionen in den Einstellungen angesehen? Personalisieren Sie Cortex nach Ihren Wünschen und bringen Sie Farbe in Ihre Chats!';

  @override
  String get notificationShowerThoughtTitle => 'Duschgedanke';

  @override
  String get notificationShowerThoughtBody =>
      'Wenn eine Wassermelone eine Frucht ist, ist Wassermelonensaft dann technisch gesehen ein Smoothie? Vielleicht möchten Sie dieses tiefgründige (also wirklich tiefgründige) Thema mit einem Modell besprechen.';

  @override
  String get notificationLowBatteryTitle =>
      'Ihre Batterie ist fast leer ... aber meine nicht!';

  @override
  String get notificationLowBatteryBody =>
      'Der Akku Ihres Telefons ist möglicherweise fast leer, aber meine Energie ist immer bei 100 %! Schließen Sie es an und lassen Sie uns weiter chatten.';

  @override
  String get channelFcmName => 'Cortex-Updates';

  @override
  String get channelFcmDescription =>
      'Benachrichtigungen über Neuigkeiten, Updates und andere Informationen von Cortex.';

  @override
  String get channelEngagementName => 'Freundliche Erinnerungen';

  @override
  String get channelEngagementDescription =>
      'Lustige Benachrichtigungen, die Sie bei der Stange halten.';

  @override
  String get channelGreetingsName => 'Tägliche Grüße';

  @override
  String get channelGreetingsDescription =>
      'Die Nachrichten wie Guten Morgen und Gute Nacht.';

  @override
  String get exitAppTitle => 'So bald gehen?';

  @override
  String get exitAppConfirmation =>
      'Möchten Sie diese tolle Plattform wirklich verlassen?';

  @override
  String get newsErrorTitle => 'Nachrichten konnten nicht geladen werden';

  @override
  String get newsErrorMessage =>
      'Beim Abrufen der neuesten Updates ist ein Problem aufgetreten. Bitte überprüfen Sie Ihre Verbindung und versuchen Sie es erneut.';
}
