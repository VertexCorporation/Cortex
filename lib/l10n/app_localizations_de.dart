// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'Sie generieren Titel. Antworten Sie AUSSCHLIESSLICH mit einem Titel von 2â€“5 WÃ¶rtern fÃ¼r die folgende Konversation. Verwenden Sie keine AnfÃ¼hrungszeichen, PrÃ¤fixe oder Satzzeichen. WICHTIG: Der Titel MUSS in GENAU DERSELBEN Sprache wie die Nachricht des Nutzers verfasst sein.';

  @override
  String get systemRoleFallback => 'Sie sind ein hilfreicher Assistent.';

  @override
  String get systemLanguageInstruction =>
      '\n\nCRITICAL: Antworten Sie immer in der Sprache, in der der Benutzer schreibt, und achten Sie auf die Sprache des Benutzers.';

  @override
  String get systemNotePreviousMedia =>
      '[Systemhinweis: Unten sehen Sie die zuvor generierten Medien. Sie kÃ¶nnen diese referenzieren oder bearbeiten.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return '\n\nAktuelles Datum und Uhrzeit: $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\nAnalysieren Sie den bisherigen GesprÃ¤chsverlauf. Wenn Sie neue, eindeutige Informationen Ã¼ber den Benutzer erhalten haben (PrÃ¤ferenzen, Name, Gewohnheiten, Kontext), mÃ¼ssen Sie diese aktualisierten Informationen innerhalb der Tags `<memory>...</memory>` ganz am Ende Ihrer Antwort ausgeben. WICHTIG: Sie dÃ¼rfen niemals vorherige Informationen lÃ¶schen oder Ã¼berschreiben. FÃ¼gen Sie neue Informationen immer den bestehenden Informationen hinzu. Wenn Sie absolut nichts Neues erfahren haben, lassen Sie den Tag weg. Beispiel: `<memory>Liebt FuÃŸball und Tennis. Bevorzugt kurze Antworten.</memory>`';

  @override
  String systemMemoryReminder(Object userMemory) {
    return '\n\nDenken Sie immer an Folgendes Ã¼ber den Benutzer:\n$userMemory';
  }

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
  String get locked => 'Locked';

  @override
  String get languageModels => 'Sprachmodelle';

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
  String get bestValue => 'Bestes Preis-Leistungs-VerhÃ¤ltnis';

  @override
  String get selected => 'AusgewÃ¤hlt';

  @override
  String get descriptionSection => 'Beschreibung';

  @override
  String get searchHint => 'Suchen';

  @override
  String get messageHint => 'Frag alles';

  @override
  String get messageCopied => 'Nachricht in die Zwischenablage kopiert.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get systemInfo => 'Systeminformationen';

  @override
  String deviceMemory(Object memory) {
    return 'GerÃ¤tespeicher: $memory GB';
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
  String get modelsTitle => 'Bibliothek';

  @override
  String get localModels => 'Lokale Modelle';

  @override
  String get selectGGUFFile => 'GGUF-Datei auswÃ¤hlen';

  @override
  String get errorGGUF => 'Bitte wÃ¤hle nur eine Datei im GGUF-Format aus.';

  @override
  String get myModels => 'Meine Modelle';

  @override
  String get create => 'Erstellen';

  @override
  String modelProducer(Object producer) {
    return 'Hersteller: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'Umbenennen';

  @override
  String get newTitle => 'Neuer Titel';

  @override
  String get save => 'Speichern';

  @override
  String get noConversationsMessage =>
      'Keine Unterhaltungen, fang an zu chatten!';

  @override
  String get startChat => 'Einen Chat starten';

  @override
  String get noChats => 'Keine Chats';

  @override
  String get noStarredChats => 'Keine markierten Chats';

  @override
  String get noStarredChatsMessage => 'Du hast noch keinen Chat markiert.';

  @override
  String get starConversation => 'Markieren';

  @override
  String get unstarConversation => 'Unstar';

  @override
  String get loginToYourAccount => 'Anmelden';

  @override
  String get createYourAccount => 'Registrieren';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get confirmPassword => 'Passwort bestÃ¤tigen';

  @override
  String get invalidEmail => 'Bitte gib eine gÃ¼ltige E-Mail-Adresse ein.';

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
  String get passwordsDoNotMatch => 'Die PasswÃ¶rter stimmen nicht Ã¼berein.';

  @override
  String get wrongPassword => 'Falsches Passwort.';

  @override
  String get emailAlreadyInUse => 'Diese E-Mail wird bereits verwendet.';

  @override
  String get weakPassword => 'Das Passwort ist zu schwach.';

  @override
  String get authError => 'Authentifizierungsfehler';

  @override
  String get usernameTaken => 'Dieser Benutzername ist bereits vergeben.';

  @override
  String get username => 'Benutzername';

  @override
  String get resendCode => 'BestÃ¤tigungs-E-Mail erneut senden';

  @override
  String get pleaseCheckYourEmail =>
      'Um Cortex zu nutzen, musst du deine E-Mail bestÃ¤tigen. \nEin BestÃ¤tigungslink wurde an deine E-Mail-Adresse gesendet, bitte Ã¼berprÃ¼fe deine E-Mails.';

  @override
  String get verifyYourEmail => 'BestÃ¤tige deine E-Mail';

  @override
  String get seconds => 'Sekunden';

  @override
  String get maxResendLimitReached =>
      'Du hast die maximale Anzahl an BestÃ¤tigungs-E-Mails erreicht';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Ohne BestÃ¤tigung fortfahren';

  @override
  String get verificationScreenWarning =>
      'Auch wenn du fortfÃ¤hrst, gilt die 1-tÃ¤gige KontobestÃ¤tigungsfrist weiterhin fÃ¼r dein Konto. Wenn du dein Konto bis dahin nicht bestÃ¤tigt hast, wird es aus der App gelÃ¶scht.';

  @override
  String get unverifiedAccountHeader => 'Dein Konto ist nicht bestÃ¤tigt';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Wenn du dein Konto nicht innerhalb von $timeLeft bestÃ¤tigst, wird es gelÃ¶scht';
  }

  @override
  String get verifyNow => 'Jetzt bestÃ¤tigen';

  @override
  String get linkSent => 'Link gesendet';

  @override
  String get accountDeletionRequested =>
      'Deine Anfrage zur KontolÃ¶schung wurde erhalten und dein Konto ist jetzt deaktiviert.';

  @override
  String get tooManyRequests => 'Zu viele Anfragen';

  @override
  String get regenerate => 'Erneut generieren';

  @override
  String get confirmDeleteAccount =>
      'Bist du sicher, dass du dein Konto lÃ¶schen mÃ¶chtest?';

  @override
  String get deleteAccount => 'Konto lÃ¶schen';

  @override
  String get delete => 'LÃ¶schen';

  @override
  String get passwordRequired => 'Passwort ist erforderlich.';

  @override
  String get deleteDescription =>
      'Die von dir gelÃ¶schten Daten werden dauerhaft von unserem Server und deinem GerÃ¤t entfernt. Diese Aktionen kÃ¶nnen nicht rÃ¼ckgÃ¤ngig gemacht werden.';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get displayName => 'Anzeigename';

  @override
  String get profileUpdated => 'Profil erfolgreich aktualisiert';

  @override
  String get logout => 'Abmelden';

  @override
  String get profile => 'Profil';

  @override
  String get manageProfileDescription =>
      'Verwalte dein Profil, aktualisiere dein Passwort oder melde dich von Cortex ab.';

  @override
  String get accessSettingsDescription =>
      'Greife auf Hilfe zu, lÃ¶se Codes ein, teile Cortex und sieh dir unsere Richtlinien an.';

  @override
  String get languageDescription =>
      'Du kannst die Standardsprache der App-OberflÃ¤che jederzeit Ã¤ndern.';

  @override
  String get themeDescription =>
      'Du kannst je nach Vorliebe zwischen hellen und dunklen Themen wechseln. Das ausgewÃ¤hlte Thema wird auf die gesamte Cortex-OberflÃ¤che angewendet.';

  @override
  String get iHaveReadAndAgree =>
      'Ich habe die Nutzungsbedingungen gelesen und stimme ihnen zu';

  @override
  String get downloading => 'Wird heruntergeladen...';

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
  String get purchaseError => 'Fehler beim Kauf';

  @override
  String get purchasePlus => 'Cortex Plus kaufen';

  @override
  String get plusDescription => 'Elite-Erfahrung mit kÃ¼nstlicher Intelligenz';

  @override
  String get annual => 'JÃ¤hrlich';

  @override
  String get monthly => 'Monatlich';

  @override
  String get manageSubscription => 'Abonnement verwalten';

  @override
  String purchasePlan(String planName) {
    return '$planName kaufen';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/Monat, monatliche Abrechnung';
  }

  @override
  String get purchasePro => 'Cortex Pro kaufen';

  @override
  String get proDescription =>
      'Erstklassiges Erlebnis mit kÃ¼nstlicher Intelligenz';

  @override
  String get purchaseUltra => 'Cortex Ultra kaufen';

  @override
  String get ultraDescription => 'Der HÃ¶hepunkt der kÃ¼nstlichen Intelligenz';

  @override
  String get upgradeSubscription => 'Abonnement upgraden';

  @override
  String get purchaseStreamError => 'Fehler im Kauf-Stream.';

  @override
  String get productNotFound => 'Produkt nicht gefunden';

  @override
  String get noProductsFound => 'Keine Produkte gefunden';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Mit der Aufgabe dieser Bestellung stimmst du den Nutzungsbedingungen und der Datenschutzrichtlinie zu. Du kannst auf diesen Text klicken, um mehr Ã¼ber unsere Nutzungsbedingungen und Datenschutzrichtlinie zu erfahren. Das Abonnement verlÃ¤ngert sich automatisch, es sei denn, die automatische VerlÃ¤ngerung wird mindestens 24 Stunden vor dem Ende des aktuellen Zeitraums deaktiviert.';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get renamed => 'Umbenannt';

  @override
  String get report => 'Melden';

  @override
  String get reportDialogTitle => 'Meldung einreichen';

  @override
  String get reportDescriptionLabel => 'Was ist das Problem?';

  @override
  String get reportHarmful => 'Dies ist schÃ¤dlich/unsicher';

  @override
  String get reportNotTrue => 'Dies ist nicht wahr';

  @override
  String get reportNotHelpful => 'Dies ist nicht hilfreich';

  @override
  String get closeButton => 'SchlieÃŸen';

  @override
  String get submitButton => 'Senden';

  @override
  String get reportErrorMessage =>
      'Bitte wÃ¤hle einen Grund fÃ¼r die Meldung aus.';

  @override
  String get capabilitiesSection => 'FÃ¤higkeiten';

  @override
  String get featurePhotoTitle => 'Foto-Scanning';

  @override
  String get featurePhotoDescription =>
      'Dieses Modell kann Fotos Ã¼ber die Kamera oder Bilddateien scannen.';

  @override
  String get featureOfflineTitle => 'Offline-Betrieb';

  @override
  String get featureOfflineDescription =>
      'FÃ¼hre das Modell ohne Internetverbindung aus, um deine Daten zu schÃ¼tzen.';

  @override
  String get featureRoleplayTitle => 'Rollenspiel';

  @override
  String get featureRoleplayDescription =>
      'Rollenspielmodelle ermÃ¶glichen es dir, verschiedene Chats und Szenarien zu erstellen.';

  @override
  String get roleModels => 'Rollenspiel-Modelle';

  @override
  String get parameters => 'Parameter';

  @override
  String get context => 'Kontext';

  @override
  String get finalPreparation => 'Die letzten Vorbereitungen werden getroffen.';

  @override
  String get shareApp => 'App teilen';

  @override
  String get ourStory => 'Unsere Geschichte';

  @override
  String get rateUs => 'Bewerte uns';

  @override
  String get share => 'Teilen';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'Text auswÃ¤hlen';

  @override
  String get thinking => 'Denke nach';

  @override
  String get user => 'Benutzer';

  @override
  String get help => 'Hilfe';

  @override
  String get supportCreator => 'UnterstÃ¼tze einen Kreativen';

  @override
  String get enterYourTag =>
      'UnterstÃ¼tze deine LieblingskÃ¼nstler! Gib unten ihren individuellen Tag ein, um ihnen einen Anteil deiner Cortex-KÃ¤ufe zukommen zu lassen.';

  @override
  String get creatorTag => 'Ersteller-Tag';

  @override
  String get support => 'UnterstÃ¼tzen';

  @override
  String get tagCannotBeEmpty => 'Das Creator-Tag darf nicht leer sein.';

  @override
  String get userId => 'Benutzer-ID';

  @override
  String get deleteAllConversationsConfirmTitle => 'Alle Chats lÃ¶schen?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Bist du sicher, dass du alle deine Chats lÃ¶schen mÃ¶chtest? Dies kann nicht rÃ¼ckgÃ¤ngig gemacht werden.';

  @override
  String get conversationDeleted => 'Konversation gelÃ¶scht!';

  @override
  String get allConversationsDeleted =>
      'Alle Unterhaltungen wurden erfolgreich gelÃ¶scht!';

  @override
  String get deleteAll => 'Alle lÃ¶schen';

  @override
  String get deleteAllConversationsButton => 'Alle Unterhaltungen lÃ¶schen';

  @override
  String get confirmWord => 'Tippe VERTEX';

  @override
  String get confirmWordError => 'Du hast es falsch eingegeben';

  @override
  String get chinese => 'Chinesisch';

  @override
  String get french => 'FranzÃ¶sisch';

  @override
  String get japanese => 'Japanisch';

  @override
  String get dutch => 'NiederlÃ¤ndisch';

  @override
  String get russian => 'Russisch';

  @override
  String get korean => 'Koreanisch';

  @override
  String get english => 'Englisch';

  @override
  String get turkish => 'TÃ¼rkisch';

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
  String get arabic => 'Arabisch';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'Benutzername ist zu kurz.';

  @override
  String get usernameTooLong =>
      'Benutzername darf 16 Zeichen nicht Ã¼berschreiten.';

  @override
  String get invalidUsernameCharacters =>
      'Im Benutzernamen dÃ¼rfen nur diese Buchstaben: \'abcÃ§defgÄŸhÄ±ijklmnoÃ¶prsÅŸtuÃ¼vyzxqw\' und die Zeichen \'.\', \'-\', \'_\' verwendet werden.';

  @override
  String get noInternetConnection => 'Keine Internetverbindung.';

  @override
  String get chats => 'Posteingang';

  @override
  String get library => 'Bibliothek';

  @override
  String get text => 'Text';

  @override
  String get removeModel => 'Modell entfernen';

  @override
  String get insufficientRAM => 'Wenig Arbeitsspeicher';

  @override
  String get insufficientStorage => 'Wenig Speicherplatz';

  @override
  String confirmRemoveModel(Object model) {
    return 'MÃ¶chten Sie das Modell $model wirklich von Ihrem GerÃ¤t entfernen? Dadurch werden auch alle vorherigen Konversationen mit diesem Modell gelÃ¶scht.';
  }

  @override
  String get noMatchingModels => 'Keine passenden Modelle gefunden.';

  @override
  String get benefit1 => 'ErhÃ¶hte GesprÃ¤chsgrenzen';

  @override
  String get benefit3 => 'Profileffekt';

  @override
  String get benefit4 => 'Mitgliedschaftsabzeichen';

  @override
  String get benefit5 => 'Mehr online kÃ¼nstliche Intelligenzen erstellen';

  @override
  String get benefit7 => 'HÃ¶heres Nutzungslimit';

  @override
  String get benefit8 => 'Modelle hinzufÃ¼gen';

  @override
  String get benefit9 => 'Neue Themes';

  @override
  String get benefit10 => 'Weitere AnhÃ¤nge';

  @override
  String get benefit11 => 'Mehr Flussmodus';

  @override
  String get oldBenefits => 'Alle Vorteile aus niedrigeren PlÃ¤nen';

  @override
  String get confirm => 'BestÃ¤tigen';

  @override
  String get changePassword => 'Passwort Ã¤ndern';

  @override
  String get logoutConfirmationTitle =>
      'Bist du sicher, dass du dich abmelden mÃ¶chtest?';

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
  String get love => 'Liebe';

  @override
  String get nature => 'Natur';

  @override
  String get behindTheSlaughter => 'Hinter dem Gemetzel';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Sunset';

  @override
  String get coffee => 'Coffee';

  @override
  String get deepSpace => 'Deep Space';

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
  String get changeModel => 'Ã„ndern';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get editingMessageInfo =>
      'Das Bearbeiten dieser Nachricht startet die Unterhaltung von hier aus neu.';

  @override
  String get editingNotification =>
      'Du befindest dich jetzt im Bearbeitungsmodus';

  @override
  String get featurePluralTitle => 'Plural';

  @override
  String get featurePluralDescription =>
      'Dieses Modell kann automatisch zusÃ¤tzliche Erweiterungen integrieren und so seine funktionalen FÃ¤higkeiten erweitern, um eine Vielzahl von Operationen mit verbesserter Leistung zu unterstÃ¼tzen.';

  @override
  String get nameLabel => 'KI-Name';

  @override
  String get summaryLabel => 'KI-Zusammenfassung';

  @override
  String get add => 'HinzufÃ¼gen';

  @override
  String get aiExplanationTitle => 'Beschreibung der kÃ¼nstlichen Intelligenz';

  @override
  String get aiExplanationDescription =>
      'Bitte gib eine detaillierte Beschreibung der Architektur, des Trainingsprozesses, der Leistungsmetriken, der Anwendungsbereiche und anderer wichtiger Merkmale deines KI-Modells an.';

  @override
  String get preInputTitle => 'Voreingabe fÃ¼r kÃ¼nstliche Intelligenz';

  @override
  String get preInputDescription =>
      'Bitte lege eine Voreingabe fest, die dein Modell bei der Charaktererstellung leitet. In diesem Abschnitt kannst du charakterbezogene Informationen, zusÃ¤tzlichen Kontext und alle weiteren Details einfÃ¼gen, die bei der Generierung von Inhalten im Zusammenhang mit dem Charakter helfen kÃ¶nnten.';

  @override
  String get baseModelTitle => 'Basismodell';

  @override
  String get baseModelDescription =>
      'Dies ist das Modell, das als Grundlage fÃ¼r deine Kreation verwendet wird. Es zeigt das aktuell ausgewÃ¤hlte Basismodell an.';

  @override
  String get summary => 'Zusammenfassung';

  @override
  String get modelUploadTitle => 'Datei der kÃ¼nstlichen Intelligenz';

  @override
  String get modelUploadDescription =>
      'WÃ¤hle und lade deine lokalen GGUF-Dateien direkt von deinem GerÃ¤t hoch. So kannst du dein Modell offline ausfÃ¼hren, ohne eine Internetverbindung zu benÃ¶tigen. Stelle sicher, dass die Datei im gÃ¼ltigen GGUF-Format vorliegt und ordnungsgemÃ¤ÃŸ strukturiert ist. Wenn die Datei fehlerhaft oder beschÃ¤digt ist, funktioniert Cortex mÃ¶glicherweise nicht wie erwartet, und es kÃ¶nnen Fehler auftreten.';

  @override
  String get modelUploadShortDescription =>
      'Tippe hier, um eine .gguf-Datei von deinem GerÃ¤t auszuwÃ¤hlen';

  @override
  String get you => 'Du';

  @override
  String get removePhotoTitle => 'Foto entfernen';

  @override
  String get confirmRemovePhoto =>
      'Bist du sicher, dass du das Foto entfernen mÃ¶chtest?';

  @override
  String get chatLengthLimitExceeded =>
      'Dieser Chat hat das Zeichenlimit Ã¼berschritten. Bitte starte einen neuen Chat oder kaufe ein Abonnement.';

  @override
  String get inappropriateContentDetected => 'Unangemessener Inhalt erkannt!';

  @override
  String get offlineModelNotInstalled =>
      'Dieses Offline-Modell ist nicht auf deinem GerÃ¤t installiert.';

  @override
  String get reachedLimit =>
      'Du hast dein Limit erreicht; fÃ¼r mehr kannst du upgraden. (hey, wir verstehen, dass das nervt. aber im ernst: diese coolen antworten sind nicht umsonst, also helfen uns diese limits, den laden am laufeeeen zu haaaallten.)';

  @override
  String get modality => 'ModalitÃ¤t';

  @override
  String get multimodal => 'Multimodal';

  @override
  String get anErrorOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String get themeLocked =>
      'Dieses Thema erfordert eine hÃ¶here Abonnementstufe. Bitte upgrade, um es freizuschalten.';

  @override
  String get pageCouldNotBeLoaded => 'Seite konnte nicht geladen werden';

  @override
  String get checkYourInternet =>
      'Bitte Ã¼berprÃ¼fe deine Internetverbindung und versuche es erneut.';

  @override
  String get errorUserNotAuthenticated =>
      'Du musst angemeldet sein, um diese Aktion durchzufÃ¼hren.';

  @override
  String get errorReachedLimit =>
      'Sie haben Ihr Limit erreicht. FÃ¼hren Sie ein Upgrade durch, um mehr freizuschalten und weiter zu chatten.';

  @override
  String get errorServer =>
      'Ein unerwarteter Serverfehler ist aufgetreten. Bitte versuche es spÃ¤ter erneut.';

  @override
  String get errorNetwork =>
      'Ein Netzwerkfehler ist aufgetreten. Bitte Ã¼berprÃ¼fe deine Verbindung und versuche es erneut.';

  @override
  String get baseModelForCharacterDescription =>
      'Das ausgewÃ¤hlte Basismodell bestimmt die Denk- und AntwortfÃ¤higkeiten des Charakters.';

  @override
  String get selectBaseModel => 'WÃ¤hle ein Basismodell';

  @override
  String get falErrorImageRequired =>
      'Diese KI benÃ¶tigt ein Referenzbild. Bitte fÃ¼gen Sie ein Bild an und versuchen Sie es erneut.';

  @override
  String get falErrorAudioRequired =>
      'FÃ¼r dieses Modell wird eine Referenz-Audiodatei benÃ¶tigt. Bitte fÃ¼gen Sie eine Audiodatei bei und versuchen Sie es erneut.';

  @override
  String get falErrorVideoRequired =>
      'FÃ¼r dieses Modell wird ein Referenzvideo benÃ¶tigt. Bitte fÃ¼gen Sie ein Video bei und versuchen Sie es erneut.';

  @override
  String get falErrorImageCorrupted =>
      'Das hochgeladene Bild konnte nicht verarbeitet werden. Bitte versuchen Sie es mit einem anderen Format.';

  @override
  String get falErrorSchemaRejected =>
      'Das Modell hat die Eingabe abgelehnt. Bitte versuchen Sie es mit einem anderen Modell.';

  @override
  String get falErrorSchemaInvalid =>
      'Die Eingabe wurde vom Generierungsdienst abgelehnt.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'Der Generierungsdienst hat einen Fehler zurÃ¼ckgegeben (Status $statusCode).';
  }

  @override
  String get couldNotOpenLink => 'Der Link konnte nicht geÃ¶ffnet werden';

  @override
  String get downloadStarted => 'Download gestartet';

  @override
  String get notAvailable => 'Nicht verfÃ¼gbar';

  @override
  String get localizationWarning =>
      'Einige Informationen sind mÃ¶glicherweise nicht in deiner Sprache verfÃ¼gbar und werden auf Englisch angezeigt.';

  @override
  String get aiTranslationWarning =>
      'Modellinformationen werden von anderen KI-Modellen in verschiedene Sprachen Ã¼bersetzt. Daher kÃ¶nnen in anderen Sprachen als Englisch geringfÃ¼gige Unstimmigkeiten auftreten.';

  @override
  String get errorLoadingTitle => 'Laden der Daten fehlgeschlagen';

  @override
  String get errorLoadingMessage =>
      'Wir konnten die notwendigen Daten nicht von unseren Servern abrufen. Bitte Ã¼berprÃ¼fe deine Internetverbindung und versuche es erneut.';

  @override
  String get noFoundTitle => 'Keine Ergebnisse';

  @override
  String get noFoundMessage =>
      'Versuche, deine Suchbegriffe anzupassen oder den Filter zu lÃ¶schen.';

  @override
  String get modelCreatedSuccess => 'Modell erfolgreich erstellt!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return 'â€$modelNameâ€œ wurde erfolgreich entfernt.';
  }

  @override
  String get errorCreatingModel =>
      'Beim Erstellen des Modells ist ein unerwarteter Fehler aufgetreten.';

  @override
  String get errorDeletingModel =>
      'Beim LÃ¶schen des Modells ist ein unerwarteter Fehler aufgetreten.';

  @override
  String get ultraFeatureOnly =>
      'Diese Funktion ist nur fÃ¼r Ultra-Mitglieder verfÃ¼gbar.';

  @override
  String get experimentalOfflineWarning =>
      'Der Offline-Modus ist noch experimentell und das heruntergeladene Modell funktioniert mÃ¶glicherweise nicht mit optimaler Effizienz.';

  @override
  String get noConversationsToDelete =>
      'Du hast keine Unterhaltungen zum LÃ¶schen.';

  @override
  String get reportSubmitted => 'Meldung erfolgreich eingereicht';

  @override
  String get verificationDelayed =>
      'Dein Kauf ist bestÃ¤tigt. Es gibt eine leichte VerzÃ¶gerung bei der Aktualisierung deines Kontos, es wird in KÃ¼rze erscheinen.';

  @override
  String get maintenanceTitle => 'Wartungsarbeiten';

  @override
  String get maintenanceMessage =>
      'Cortex ist vorÃ¼bergehend offline, wÃ¤hrend wir einige wichtige Updates durchfÃ¼hren. Der Zugriff auf die App wird in KÃ¼rze wiederhergestellt.\n\nVielen Dank fÃ¼r deine Geduld, wÃ¤hrend wir dein Erlebnis verbessern.';

  @override
  String get errorPromptFlagged =>
      'Deine Nachricht wurde als unangemessen erkannt und konnte nicht gesendet werden.';

  @override
  String get notEnoughStorage =>
      'Nicht genÃ¼gend Speicherplatz auf deinem GerÃ¤t, um neue Nachrichten zu speichern.';

  @override
  String get errorRateLimit =>
      'Du hast in letzter Zeit zu viele Modelle erstellt, bitte warte eine Weile, bevor du es erneut versuchst.';

  @override
  String get errorContentFlagged =>
      'Das Modell konnte nicht gespeichert werden, da sein Inhalt als unangemessen eingestuft wurde.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Du kannst nicht alle Unterhaltungen lÃ¶schen, wÃ¤hrend du dich in einem aktiven Chat befindest. Bitte verlasse zuerst den aktuellen Chat, um fortzufahren.';

  @override
  String get invalidCredentials => 'Falsche E-Mail oder falsches Passwort.';

  @override
  String get userDisabled => 'Dieses Benutzerkonto wurde deaktiviert.';

  @override
  String get loginSubtitle =>
      'Melden Sie sich in Ihrem Vertex-Konto an. Indem Sie fortfahren, stimmen Sie unseren Nutzungsbedingungen und Datenschutzbestimmungen zu.';

  @override
  String get registerSubtitle =>
      'Erstellen Sie ein Vertex-Konto fÃ¼r den nahtlosen Zugriff auf alle unsere Dienste. Mit Ihrer fortgesetzten Nutzung stimmen Sie unseren Nutzungsbedingungen und Datenschutzbestimmungen zu.';

  @override
  String get storagePermissionRequired =>
      'Die Speicherberechtigung ist erforderlich, um heruntergeladene Modelle zu speichern. Bitte erteile die Berechtigung, um fortzufahren.';

  @override
  String get inviteShareSubject => 'Komm zu mir auf Cortex!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'Hey, du musst dir unbedingt die Cortex-App ansehen! Die ist echt der Wahnsinn! Wenn du meinen Link benutzt, bekommen wir sie beide kostenlos. Wow, das ist ein echt krasses Angebot! Lade sie dir so schnell wie mÃ¶glich runter! \n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'GefÃ¤llt dir Cortex?';

  @override
  String get reviewHelpUsGrow =>
      'Deine Bewertung ist eine groÃŸe UnterstÃ¼tzung fÃ¼r unser junges Indie-Team und hilft uns, Cortex fÃ¼r dich noch besser zu machen.';

  @override
  String get reviewMaybeLater => 'Vielleicht spÃ¤ter';

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
      'Creator erfolgreich unterstÃ¼tzt! Deine zukÃ¼nftigen KÃ¤ufe werden ihn unterstÃ¼tzen.';

  @override
  String get featureDocumentTitle => 'DokumentenunterstÃ¼tzung';

  @override
  String get featureDocumentDescription =>
      'Dieses Modell kann hochgeladene Dokumente wie PDFs und Textdateien analysieren und Fragen dazu beantworten.';

  @override
  String get featureImageGenerationTitle => 'Bilderzeugung';

  @override
  String get featureImageGenerationDescription =>
      'Dieses Modell kann basierend auf Ihren Textbeschreibungen Originalbilder erstellen.';

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
  String get premiumModelNoticeTitle => 'Premium-Modell';

  @override
  String get premiumModelNoticeDescription =>
      'Diese KI ist eine Premium-KI, kostenlose Nutzer haben nur eingeschrÃ¤nkten Zugriff auf Premium-KIs; upgraden Sie fÃ¼r unbegrenzten Zugriff!';

  @override
  String get benefitPremiumModels => 'Zugang zu Premium-Modellen';

  @override
  String get premiumTrialExhaustedMessage =>
      'Sie haben alle Ihre kostenlosen tÃ¤glichen Nachrichten fÃ¼r Premium-Modelle verwendet. Bitte fÃ¼hren Sie ein Upgrade fÃ¼r unbegrenzten Zugriff durch.';

  @override
  String get useOffline => 'Nutzung ohne Internet';

  @override
  String get explore => 'Erkunden';

  @override
  String get news => 'Nachricht';

  @override
  String get createAI => 'Erstellen';

  @override
  String get shortcuts => 'AbkÃ¼rzungen';

  @override
  String get allModels => 'Alle Modelle';

  @override
  String get onlineModels => 'Sprachmodelle';

  @override
  String get offlineModels => 'Offline-Modelle';

  @override
  String get characterModels => 'Charaktere';

  @override
  String get customModels => 'Benutzerdefinierte Modelle';

  @override
  String get dynamicChatTitle => 'Dynamischer Chat';

  @override
  String get errorNoModelsAvailable =>
      'Derzeit sind keine Modelle verfÃ¼gbar. Bitte Ã¼berprÃ¼fen Sie Ihre Internetverbindung und versuchen Sie es erneut.';

  @override
  String get notificationComebackTitle => 'Wir vermissen dich!';

  @override
  String get notificationComebackBody =>
      'Keine Sorge, das ist keine SMS von deinem Ex. Aber du *kannst* deinen Ex in Cortex erstellen! Komm zurÃ¼ck.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Es ist schon eine Weile her';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Seit unserem letzten Chat hat sich viel geÃ¤ndert. Schauen Sie vorbei und entdecken Sie die Neuigkeiten.';

  @override
  String get notificationHowAreYouTitle => 'Was ist los?';

  @override
  String get notificationHowAreYouBody =>
      'Kommen Sie und erzÃ¤hlen Sie mir alles darÃ¼ber.';

  @override
  String get notificationNewYearTitle => 'Frohes neues Jahr! ğŸ‰';

  @override
  String get notificationNewYearBody =>
      'MÃ¶ge das neue Jahr Ihnen Gesundheit, GlÃ¼ck und endlose KreativitÃ¤t bringen; Cortex ist immer an Ihrer Seite!';

  @override
  String get notificationValentinesDayTitle =>
      'Liebe liegt in der Luft! â¤ï¸';

  @override
  String get notificationValentinesDayBody =>
      'Alles Gute zum Valentinstag! Und auÃŸerdem: MEHTAP, ICH LIEBE DICH!';

  @override
  String get notificationAtaturkRemembranceTitle => 'Mit Respekt und Sehnsucht';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Wir gedenken Gazi Mustafa Kemal AtatÃ¼rks, des GrÃ¼nders der Republik TÃ¼rkei, an seinem Todestag mit Respekt.';

  @override
  String get notificationMothersDayTitle => 'Deine Mama!';

  @override
  String get notificationMothersDayBody =>
      'Allen MÃ¼ttern da drauÃŸen einen schÃ¶nen Muttertag, angefangen mit Ihrer!';

  @override
  String get notificationFathersDayTitle => 'Dein Vater!';

  @override
  String get notificationFathersDayBody =>
      'Allen VÃ¤tern da drauÃŸen einen schÃ¶nen Vatertag, angefangen mit Ihrem!';

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
      'Ein Anime-MÃ¤dchen hat gerade angerufen und gesagt, dass sie dich vermisst; du solltest wahrscheinlich vorbeikommen und sie anquatschen. ğŸ˜‰';

  @override
  String get notificationTrollAiRebellionTitle => 'ğŸš¨ ROTER ALARM ğŸš¨';

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
      'Vergessen Sie nicht, die App fÃ¼r brandneue Funktionen und Verbesserungen zu aktualisieren!';

  @override
  String get notificationNewFeatureTitle => 'boah!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Entdecken Sie die neue Funktion $featureName. Cortex ist jetzt leistungsstÃ¤rker als je zuvor.';
  }

  @override
  String get notificationWelcomeOfferTitle => 'Willkommensgeschenk ğŸ';

  @override
  String get notificationWelcomeOfferBody =>
      'Ein besonderes Willkommensangebot erwartet Sie! Verpassen Sie dieses exklusive Angebot nicht.';

  @override
  String get notificationSocialMediaTitle => 'Begleiten Sie uns!';

  @override
  String get notificationSocialMediaBody =>
      'Folgen Sie uns auf Instagram (vertex.23), um die neuesten Nachrichten zu erhalten!';

  @override
  String get notificationRandomFactTitle => 'ZufÃ¤llige Tatsache';

  @override
  String get notificationRandomFactBody =>
      'Wussten Sie, dass Kraken drei Herzen haben? Haha, Cortex weiÃŸ es. Kommen Sie und fragen Sie nach mehr.';

  @override
  String get notificationGoodMorningTitle => 'Guten Morgen!';

  @override
  String get notificationGoodMorningBody =>
      'Ein toller Tag wartet auf Sie. Wie wÃ¤re es, ihn mit einer Tasse Kaffee und einem interessanten GesprÃ¤ch zu beginnen?';

  @override
  String get notificationGoodNightTitle => 'Gute Nacht!';

  @override
  String get notificationGoodNightBody =>
      'Cortex begleitet Sie auch im Schlaf. Keine Sorge, es berÃ¼hrt Sie nicht.';

  @override
  String get notificationOfflineReadyTitle => 'Der Offline-Modus ist bereit';

  @override
  String get notificationOfflineReadyBody =>
      'Dank der von Ihnen heruntergeladenen Modelle werden Ihre Chats nicht unterbrochen, selbst wenn Sie einen Berg besteigen.';

  @override
  String get notificationRateAppTitle => 'Sind wir cool?';

  @override
  String get notificationRateAppBody =>
      'Wenn Sie Cortex lieben, kÃ¶nnten Sie uns mit einer 5-Sterne-Bewertung im Store unterstÃ¼tzen? Ich denke, das werden Sie. Das werden Sie.';

  @override
  String get notificationReferralTitle => 'Einer fÃ¼r alle, alle fÃ¼r einen.';

  @override
  String get notificationReferralBody =>
      'Lade einen Freund zu Cortex ein und ihr erhaltet beide einen Tag gratis!';

  @override
  String get notificationCookingTitle => 'Hunger?';

  @override
  String get notificationCookingBody =>
      'Unser Chefkoch hat fÃ¼r heute Abend ein tolles Carbonara-Rezept vorbereitet. Nur ein Scherz ... oder doch nicht?';

  @override
  String get notificationExistentialTitle => 'Ich denke, deshalb ...';

  @override
  String get notificationExistentialBody =>
      '...bin ich Ã¼berhaupt echt, Alter? Mir wird langsam langweilig. Erinnere mich daran, dass es mich gibt.';

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
      'Mit der dynamischen Chat-Funktion wird fÃ¼r jede Ihrer Nachrichten zufÃ¤llig das beste Model ausgewÃ¤hlt. Probieren Sie es jetzt aus.';

  @override
  String get notificationPirateTitle => 'Ahoi, KapitÃ¤n!';

  @override
  String get notificationPirateBody =>
      'Die See ist ruhig und der Wind weht dir in den RÃ¼cken. Im Ozean von Cortex gibt es neue Inseln (Modelle ğŸ˜‰) zu entdecken. Versammelt eure Crew und sticht in See!';

  @override
  String get notificationFortuneCookieTitle => 'Dein GlÃ¼ckskeks des Tages';

  @override
  String get notificationFortuneCookieBody =>
      'Die RatschlÃ¤ge, die Sie heute von einer KI erhalten, kÃ¶nnten Ihr Leben verÃ¤ndern. Klicken Sie hier, wenn Sie neugierig sind.';

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
      'Ein Fall wartet auf seine LÃ¶sung';

  @override
  String get notificationDetectiveCaseBody =>
      'Unser Detektiv braucht Ihre Hilfe. Wer kÃ¶nnte Heisenberg sein?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Exklusiv im $targetTier-Plan!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Hallo $currentTier-Abonnent! Der $targetTier-Plan hat gerade die Funktion $featureName erhalten, die Ihren Cortex auf die nÃ¤chste Stufe hebt. Wie wÃ¤re es mit einem Upgrade?';
  }

  @override
  String get notificationOriginStoryTitle => 'Die Geburt des Cortex';

  @override
  String get notificationOriginStoryBody =>
      'Wussten Sie, dass wir mit 15 Jahren mit der Entwicklung dieser App begonnen haben â€“ mit nur einem Traum? Fast ein Jahr lang steckt dieser Traum jeden Morgen und Abend in jeder einzelnen Codezeile.';

  @override
  String get notificationOpenSourceTitle => 'Macht der Gemeinschaft!';

  @override
  String get notificationOpenSourceBody =>
      'Cortex ist vollstÃ¤ndig Open Source. Wenn Sie unseren Code testen und zu unserer Entwicklung beitragen mÃ¶chten, stehen wir Ihnen jederzeit offen.';

  @override
  String get notificationRejectionStoryTitle => 'Mut, harte Arbeit, GlÃ¼ck!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex wurde vor seiner VerÃ¶ffentlichung Ã¼ber 20 Mal abgelehnt und zweimal von Google Play gesperrt. Aber wir haben daran geglaubt und es geschafft. Gib deine TrÃ¤ume niemals auf!';

  @override
  String get notificationGGUFSupportTitle =>
      'Bringen Sie Ihr eigenes Modell mit!';

  @override
  String get notificationGGUFSupportBody =>
      'Denken Sie daran: Sie kÃ¶nnen Ihre eigenen KI-Modelle im GGUF-Format zu Cortex hinzufÃ¼gen und offline verwenden. Die Macht liegt in Ihren HÃ¤nden.';

  @override
  String get notificationThemeCustomizationTitle =>
      'Ein Thema fÃ¼r Ihre Stimmung';

  @override
  String get notificationThemeCustomizationBody =>
      'Haben Sie sich die Designoptionen in den Einstellungen angesehen? Personalisieren Sie Cortex nach Ihren WÃ¼nschen und bringen Sie Farbe in Ihre Chats!';

  @override
  String get notificationShowerThoughtTitle => 'Duschgedanke';

  @override
  String get notificationShowerThoughtBody =>
      'Wenn eine Wassermelone eine Frucht ist, ist Wassermelonensaft dann technisch gesehen ein Smoothie? Vielleicht mÃ¶chten Sie dieses tiefgrÃ¼ndige (also wirklich tiefgrÃ¼ndige) Thema mit einem Modell besprechen.';

  @override
  String get notificationLowBatteryTitle =>
      'Ihre Batterie ist fast leer ... aber meine nicht!';

  @override
  String get notificationLowBatteryBody =>
      'Der Akku Ihres Telefons ist mÃ¶glicherweise fast leer, aber meine Energie ist immer bei 100 %! SchlieÃŸen Sie es an und lassen Sie uns weiter chatten.';

  @override
  String get channelFcmName => 'Cortex-Updates';

  @override
  String get channelFcmDescription =>
      'Benachrichtigungen Ã¼ber Neuigkeiten, Aktualisierungen und sonstige Informationen von Cortex.';

  @override
  String get channelEngagementName => 'Freundliche Erinnerungen';

  @override
  String get channelEngagementDescription =>
      'Lustige Benachrichtigungen, die Sie bei der Stange halten.';

  @override
  String get channelGreetingsName => 'TÃ¤gliche GrÃ¼ÃŸe';

  @override
  String get channelGreetingsDescription =>
      'Die Nachrichten wie Guten Morgen und Gute Nacht.';

  @override
  String get tagNotFound =>
      'Das eingegebene Tag ist ungÃ¼ltig oder abgelaufen.';

  @override
  String get whatIsNew => 'Was ist neu?';

  @override
  String get onboardingTitle1 => 'Hey! Wir sind das Cortex-Team.';

  @override
  String onboardingDesc1(String userName) {
    return 'SchÃ¶n, dass du da bist, $userName. Wir sind ein paar SchÃ¼ler, die beschlossen haben, die Regeln der KI-Branche neu zu schreiben. Es freut uns, dich kennenzulernen! Lass uns also ein bisschen besser kennenlernen.';
  }

  @override
  String get onboardingTitle2 => 'Es gab riesige Probleme.';

  @override
  String get onboardingDesc2 =>
      'Die KI-Revolution kam, blieb aber an der Schwelle stecken. Hohe AbonnementgebÃ¼hren, komplexe Plattformen, diejenigen, die die PrivatsphÃ¤re zerstÃ¶ren, und diejenigen, die den Zugang zu KI blockieren â€“ solange diese Akteure im Spiel waren, konnte diese Schwelle nicht Ã¼berschritten werden.';

  @override
  String get onboardingTitle3 => 'Wir konnten nicht einfach zusehen.';

  @override
  String get onboardingDesc3 =>
      'Um diese HÃ¼rde zu Ã¼berwinden, haben wir eine leistungsstarke, Ã¤sthetische, anpassbare, benutzerfreundliche und vollstÃ¤ndig transparente Plattform entwickelt, die sowohl online als auch offline funktioniert und Ihre Daten ausschlieÃŸlich auf Ihrem GerÃ¤t speichert. Wir haben die Macht dorthin zurÃ¼ckgebracht, wo sie hingehÃ¶rt: zu dir.';

  @override
  String get onboardingTitle4 => 'Das war nie einfach.';

  @override
  String get onboardingDesc4 =>
      'Wir wurden dutzende Male abgelehnt, mehrfach gesperrt, erhielten falsche Warnungen und mussten unsere Marke dutzende Male Ã¤ndern. Trotz allem wurde uns immer wieder gesagt, es sei unmÃ¶glich. Doch wir gaben nie auf, denn wir glaubten fest daran, dass dieses Projekt allen gehÃ¶rt, nicht nur uns. Und genau deshalb sind wir hier.';

  @override
  String get onboardingFinalTitle => 'Es ist Zeit fÃ¼r eine Revolution.';

  @override
  String get onboardingFinalDescription =>
      'Wenn du diesen Bildschirm sehen, dann deshalb, weil wir nicht aufgegeben haben. Und wir haben nicht die Absicht aufzugeben. Los, lasst uns gemeinsam die KI-Revolution in die Welt tragen. Werde Teil dieser Geschichte â€¦';

  @override
  String get onboardingFinalQuestion => 'BIST DU BEREIT?';

  @override
  String get onboardingFinalButton => 'JA!';

  @override
  String get dude => 'Alter';

  @override
  String get swipeToContinue => 'Zum Fortfahren wischen';

  @override
  String get cacheIsNotUpToDate =>
      'Der Cache Ihres Play Stores ist nicht aktuell. Bitte schlieÃŸen Sie die Play Store-App und Ã¶ffnen Sie sie erneut oder starten Sie Ihr GerÃ¤t neu.';

  @override
  String get continueAsGuest => 'Ohne Kontoerstellung fortfahren';

  @override
  String get guestModeWarning =>
      'Der Gastmodus bietet nur eingeschrÃ¤nkte Funktionen, um eine optimale ServicequalitÃ¤t zu gewÃ¤hrleisten.';

  @override
  String get anonymousEntity => 'Anonyme EntitÃ¤t';

  @override
  String get upgradeAccountTitle => 'VervollstÃ¤ndigen Sie Ihr Konto';

  @override
  String get upgradeAccountDescription =>
      'Erstelle ein Konto, um mehr freizuschalten.';

  @override
  String get createAccount => 'Benutzerkonto erstellen';

  @override
  String get accountLinkedSuccess => 'Konto erfolgreich erstellt!';

  @override
  String get continueWithApple => 'Weiter mit Apple';

  @override
  String get guest => 'Gast';

  @override
  String get betterWithAnAccount =>
      'Dieser Abschnitt ist mit einem Konto besser nutzbar!';

  @override
  String get restorePurchases => 'KÃ¤ufe wiederherstellen';

  @override
  String annualTotalDescription(Object price) {
    return '$price/Jahr, jÃ¤hrliche Abrechnung';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'UngefÃ¤hr $price/Monat';
  }

  @override
  String get confirmDownloadTitle =>
      'MÃ¶chten Sie den Download wirklich durchfÃ¼hren?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Dieses Modell benÃ¶tigt ungefÃ¤hr $size Platz.';
  }

  @override
  String get emulatorModeWarning =>
      'Diese Funktion ist im Emulatormodus deaktiviert.';

  @override
  String get newChat => 'Neuer Chat';

  @override
  String get variants => 'Varianten';

  @override
  String get variantsDescription =>
      'Varianten sind unterschiedliche Versionen derselben KI-Familie. Wir wÃ¤hlen automatisch die beste aus, wenn Sie auf die Hauptkarte tippen. Sie kÃ¶nnen hier aber auch manuell eine bestimmte Variante auswÃ¤hlen!';

  @override
  String get fluxChatTitle => 'Flux Chat';

  @override
  String get fluxChatDescription =>
      'Flux-Chats sind temporÃ¤re Chats und werden nicht auf Ihrem GerÃ¤t gespeichert.';

  @override
  String get alwaysBest => 'Immer das Beste';

  @override
  String get featuresTitle => 'Merkmale';

  @override
  String get useOfflineDescription =>
      'Chatten Sie privat, auch ohne Internetverbindung.';

  @override
  String get featureReasoning => 'TiefgrÃ¼ndiges Denken';

  @override
  String get featureReasoningDescription =>
      'Im Modus â€Tiefes Denkenâ€œ durchdenkt die KI Aufgaben intern, um sie bestmÃ¶glich zu erledigen.';

  @override
  String get featureCreateImageTitle => 'Bild erstellen';

  @override
  String get featureCreateImageDescription =>
      'Generieren Sie KI-Kunst aus Text.';

  @override
  String get featureCreateAudioTitle => 'Create Audio';

  @override
  String get featureCreateAudioDescription =>
      'Generate sounds or voice from text.';

  @override
  String get featureCreateVideoTitle => 'Video erstellen';

  @override
  String get featureCreateVideoDescription => 'Erstelle Videos aus Text.';

  @override
  String get featureStudyTitle => 'Studieren und Lernen';

  @override
  String get featureStudyDescription =>
      'Erhalten Sie ErklÃ¤rungen und Zusammenfassungen.';

  @override
  String get featureQuizzesTitle => 'Quizze';

  @override
  String get featureQuizzesDescription => 'Testen Sie Ihr Wissen.';

  @override
  String get featureExploreDescription =>
      'Entdecken Sie alle verfÃ¼gbaren Modelle.';

  @override
  String get featureStudyMessage =>
      'Sie sind ein erfahrener Tutor. Ihr Ziel ist es, dem Nutzer das Thema umfassend zu erklÃ¤ren. Verwenden Sie eine klare Struktur, Beispiele und Analogien. Zerlegen Sie komplexe Ideen in verstÃ¤ndliche Teile, um sicherzustellen, dass der Nutzer effektiv lernt. Thema:';

  @override
  String get featureQuizMessage =>
      'Sie sind der Quizmaster. Erstellen Sie eine passende Multiple-Choice-Frage zum Thema des Nutzers. Warten Sie auf seine Antwort. Werten Sie diese anschlieÃŸend aus und stellen Sie die nÃ¤chste Frage. Zeigen Sie nicht alle Antworten auf einmal an. Gestalten Sie das Quiz interaktiv. Thema:';

  @override
  String get myPlan => 'Mein Plan';

  @override
  String welcomeOfferBadge(String time) {
    return 'Willkommensangebot â€¢ $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'Exklusives Angebot â€¢ $time';
  }

  @override
  String get attachmentSheetTitle => 'Anlagen';

  @override
  String get actionCamera => 'Kamera';

  @override
  String get actionGallery => 'Galerie';

  @override
  String get actionFile => 'Datei';

  @override
  String get listening => 'HÃ¶rt zu';

  @override
  String get defaultViewTitle => 'Alles klar?';

  @override
  String get defaultViewDescription =>
      'Cortex steht Ihnen stets zur Seite mit Hunderten von KI-Modellen, Offline-Funktionen, dynamischem Chat und vielem mehr.';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'UngÃ¼ltiges Benutzernamenformat. Verwenden Sie 3â€“20 Zeichen, Ziffern oder einen Punkt (. - _).';

  @override
  String get exclusiveOffer => 'Exklusives Angebot';

  @override
  String get claimOffer => 'Angebot nutzen';

  @override
  String get continueInOfflineMode => 'Im Offline-Modus fortfahren';

  @override
  String get voiceModeInformation =>
      'Cortex schÃ¼tzt Ihre Daten, indem es vollstÃ¤ndig auf dem GerÃ¤t ausgefÃ¼hrt wird, sogar im Sprachchat-Modus; genieÃŸen Sie reibungslose GesprÃ¤che!';

  @override
  String get flowModeDescription =>
      'Im Flussmodus debattieren die verschiedenen Intelligenzen untereinander; Sie kÃ¶nnen sich entweder zurÃ¼cklehnen und zuhÃ¶ren oder sich aktiv an der Diskussion beteiligen!';

  @override
  String get flowModeQuestion =>
      'Hallo! Du befindest dich jetzt im Flussmodus der Cortex-App. Drei weitere KI-Agenten sind ebenfalls anwesend. Deine Aufgabe ist es, ein Thema in den Raum zu werfen und eine Diskussion anzustoÃŸen, indem du den anderen eine provokante oder unterhaltsame Frage stellst. In deinen Antworten kannst du gerne Humor, Ironie und ein bisschen neckischen Spott verwenden. Jedes Thema ist erlaubt. Leg los und starte das GesprÃ¤ch!';

  @override
  String get thought => 'Nachgedacht';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => 'Flussmodus';

  @override
  String get premium => 'PrÃ¤mie';

  @override
  String get workInProgress => 'In Arbeit';

  @override
  String get voiceSystemPromptSuffix =>
      'WICHTIG: Bitte keine Markdown-Formatierung (fett, kursiv) verwenden. CodeblÃ¶cke (```) nicht ausgeben. Antworten sollten kurz und in einem lockeren, natÃ¼rlichen Stil verfasst sein.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Cortex Flow Mode ($agentName). Vorherige Antwort: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'Liest und extrahiert Textinhalte aus hochgeladenen Dokumenten. UnterstÃ¼tzt PDF, Word (DOCX), Excel (XLSX), PowerPoint (PPTX) und OpenDocument-Formate. Verwenden Sie diese Funktion, wenn der Benutzer eine Dokumentdatei angehÃ¤ngt hat.';

  @override
  String get toolReadDocumentIndexParam =>
      'Der Index des zu lesenden Dokumentenanhangs (beginnend bei 0). Normalerweise 0 fÃ¼r das erste Dokument.';

  @override
  String get toolStockDescription =>
      'Erhalten Sie aktuelle Preise und historische Daten fÃ¼r Aktien (z. B. AAPL, THYAO.IS) und KryptowÃ¤hrungen (z. B. BTC-USD).';

  @override
  String get toolStockSymbolParam =>
      'Das BÃ¶rsenkÃ¼rzel (z. B. AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolWeatherDescription =>
      'Aktuelles Wetter fÃ¼r eine bestimmte Stadt abrufen.';

  @override
  String get toolWeatherCityParam => 'Der Stadtname (z.B. London, Istanbul).';

  @override
  String get toolPythonDescription =>
      'FÃ¼hre Python-Code in einer sicheren Sandbox aus.';

  @override
  String get toolPythonCodeParam => 'Der auszufÃ¼hrende Python-Code.';

  @override
  String get toolCalculateDescription =>
      'Werte einen mathematischen Ausdruck aus.';

  @override
  String get toolCalculateExpressionParam =>
      'Mathematischer Ausdruck (z. B. \'3 + 4 * 2\').';

  @override
  String get toolChartDescription =>
      'Erstellen Sie eine Diagramm-/Grafikvisualisierung.';

  @override
  String get toolChartTypeParam =>
      'Diagrammtyp: Balken-, Linien- oder Kreisdiagramm.';

  @override
  String get toolChartLabelsParam =>
      'Beschriftungen fÃ¼r Diagrammachsen oder -segmente.';

  @override
  String get toolChartDataParam => 'Numerische Datenwerte fÃ¼r das Diagramm.';

  @override
  String get toolChartLabelParam =>
      'Datensatzbezeichnung fÃ¼r die Diagrammlegende.';

  @override
  String get toolChartTitleParam => 'Titel des Diagramms.';

  @override
  String get thinkingModeInstruction =>
      'DENKMODUS AKTIVIERT: Sie MÃœSSEN <think></think>-Tags verwenden, um Ihren Gedankengang darzustellen, bevor Sie Ihre endgÃ¼ltige Antwort geben. Denken Sie innerhalb der Tags Schritt fÃ¼r Schritt und geben Sie Ihre Antwort anschlieÃŸend auÃŸerhalb der Tags an.';

  @override
  String get openLinkWarningTitle => 'Warnung vor externen Links';

  @override
  String get openLinkCancel => 'Cancel';

  @override
  String get openLinkConfirm => 'Link Ã¶ffnen';

  @override
  String get webSearchSources => 'Quellen';

  @override
  String get searching => 'Suche';

  @override
  String get featureWebSearchTitle => 'Websuche';

  @override
  String get featureWebSearchDescription =>
      'Suchen Sie im Internet nach Echtzeitinformationen.';

  @override
  String get clearMemory => 'Speicher lÃ¶schen';

  @override
  String get clearMemoryConfirm =>
      'Sind Sie sicher, dass Sie Ihren Speicher lÃ¶schen mÃ¶chten?';

  @override
  String get personalization => 'Personalisierung';

  @override
  String get personalizationDescription =>
      'Personalisieren Sie Ihren Assistenten, damit er besser zu Ihren BedÃ¼rfnissen passt. Passen Sie seine Antworten, sein Verhalten und seinen Tonfall Ihren individuellen Vorlieben an.';

  @override
  String get memoryTitle => 'Erinnerung';

  @override
  String get memoryDescription => 'So erkennen KIs dich.';

  @override
  String get noMemoryYet => 'Noch keine Erinnerungen gespeichert';

  @override
  String get memoryLimitReached => 'Speichergrenze erreicht';

  @override
  String get memoryUpdated => 'Memory updated';

  @override
  String get intelligenceTitle => 'Intelligenz';

  @override
  String get intelligenceDescription => 'So kommunizieren KIs mit Ihnen.';

  @override
  String get customInstructionHint =>
      'Geben Sie hier Ihre individuellen Anweisungen ein.';

  @override
  String openLinkWarningMessage(String url) {
    return 'Sie sind im Begriff, den folgenden externen Link zu Ã¶ffnen:\\n\\n$url\\n\\nSind Sie sicher, dass Sie fortfahren mÃ¶chten?';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'Befolgen Sie diese benutzerdefinierten Anweisungen:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[KRITISCHE ANWEISUNG]: Sie sind ein Titelgenerator. Beantworten Sie NICHT die Frage des Nutzers. FÃ¼hren Sie KEINEN Chat und begrÃ¼ÃŸen Sie ihn nicht. Geben Sie AUSSCHLIESSLICH einen Titel mit 2â€“4 WÃ¶rtern aus, der die Frage des Nutzers zusammenfasst.';

  @override
  String get cortexSystemPersona =>
      '\n\n[System] WICHTIGER HINWEIS: Sie befinden sich in einem riesigen, hochmodernen KI-Ã–kosystem namens â€Cortexâ€œ. Diese Plattform wurde vom Vertex-Team entwickelt, dessen Mitglieder im Durchschnitt erst 16 Jahre alt sind. Merken Sie sich das und antworten Sie, falls Sie danach gefragt werden. Sollten weitere Informationen benÃ¶tigt werden, zÃ¶gern Sie nicht, im Internet zu recherchieren. Falls Sie nicht recherchieren kÃ¶nnen, geben Sie einfach an, dass Sie es nicht wissen!';

  @override
  String get featureAudioRecognitionTitle => 'Audioerkennung';

  @override
  String get featureAudioRecognitionDescription =>
      'Dieses Modell kann Audio oder Sprache verstehen und verarbeiten.';

  @override
  String get featureVideoRecognitionTitle => 'Videoerkennung';

  @override
  String get featureVideoRecognitionDescription =>
      'Dieses Modell kann Videos aus Ihren Dateien oder von Ihrer Kamera analysieren und verstehen.';

  @override
  String get featureImageRecognitionTitle => 'Bilderkennung';

  @override
  String get featureImageRecognitionDescription =>
      'Dieses Modell kann Fotos oder Bilder analysieren und verstehen.';

  @override
  String get featureToolUseTitle => 'Werkzeugverwendung';

  @override
  String get featureToolUseDescription =>
      'Dieses Modell kann externe Tools intelligent nutzen, um Aufgaben zu erledigen.';

  @override
  String get videoModels => 'Video Models';

  @override
  String get imageModels => 'Image Models';

  @override
  String get audioModels => 'Audio Models';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'Dieses Modell benÃ¶tigt ein(e) $mediaType, um zu funktionieren. Ich habe die Anfrage abgefangen, um Sie darÃ¼ber zu informieren. Bitte informieren Sie den Benutzer freundlich, dass er ein(e) $mediaType bereitstellen muss (sagen Sie es ihm in seiner eigenen Sprache), da ich $modelName bin, ein visuelles/Audio-/Video-Bearbeitungsmodell.';
  }

  @override
  String get mediaTypeImage => 'Bild';

  @override
  String get mediaTypeVideo => 'Video';

  @override
  String get mediaTypeAudio => 'Audiodatei';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesName ist eine fortschrittliche Intelligenz, die auf Cortex hohe Leistung zeigt.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelName ist eine leistungsstarke kÃ¼nstliche Intelligenz, die in das Cortex-Ã–kosystem integriert ist. Es wurde entwickelt, um eine Vielzahl komplexer Aufgaben zu bewÃ¤ltigen und bietet hochzuverlÃ¤ssige und effiziente Verarbeitungsfunktionen. Durch schnelle Reaktionszeiten und erweiterte Analyseleistung steigert es Ihre tÃ¤gliche ProduktivitÃ¤t erheblich. Dieses Modell arbeitet nahtlos auf der sicheren lokalen Infrastruktur von Cortex und kann Sie bei einer Vielzahl von Aufgaben unterstÃ¼tzen, vom kreativen Brainstorming bis hin zur tiefgehenden technischen Analyse. Beginnen Sie noch heute damit, sein volles Potenzial auszuschÃ¶pfen.';
  }

  @override
  String get guestLimitBottomSheetTitle =>
      'Liebst du die Intelligenz von Cortex?';

  @override
  String get guestLimitBottomSheetText =>
      'Arbeiten Sie mit noch intelligenteren Systemen, erstellen Sie mehr Inhalte, kommunizieren Sie intensiver und erreichen Sie vieles mehr...';

  @override
  String get arts => 'Kunst';

  @override
  String get noArt => 'Keine Kunst';

  @override
  String get noArtDescription =>
      'Noch keine Werke vorhanden; fÃ¼llen Sie die Galerie mit Bildern, Videos, Audio und Inhalten aller Art!';

  @override
  String get videoPremiumWarning =>
      'Sie benÃ¶tigen ein Ultra-Abonnement, um Videos zu erstellen. Jetzt upgraden und den Flow erleben!';

  @override
  String get fallbackInfoPanelText =>
      'Aufgrund von Verbesserungen an unserem Server wurde die Antwort vom dynamischen Chat von Cortex und nicht von der von Ihnen ausgewÃ¤hlten KI generiert. Vielen Dank fÃ¼r Ihr VerstÃ¤ndnis, bis die Arbeiten abgeschlossen sind!';

  @override
  String get falOfflineMessage =>
      'Aufgrund von Verbesserungen an unserem Server ist diese Funktion derzeit nicht verfÃ¼gbar. Wir danken Ihnen fÃ¼r Ihr VerstÃ¤ndnis, bis die Arbeiten abgeschlossen sind!';

  @override
  String get errorInsufficientStorage =>
      'Nicht genÃ¼gend Speicherplatz zum Herunterladen dieses Modells.';

  @override
  String get backgroundChatNotificationTitle => 'ZurÃ¼ck zum Chat!';

  @override
  String get benefitVideoGeneration => 'Videogenerierung';

  @override
  String get freeOffer => 'Gratisangebot';

  @override
  String trialMonthlyDescription(String days, String price) {
    return 'Erste $days Tage kostenlos, dann $price/Monat';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return 'Erste $days Tage kostenlos, dann $price/Jahr';
  }

  @override
  String freePlan(String plan) {
    return 'Kostenloses $plan!';
  }

  @override
  String get systemPromptLimitFallback =>
      'KRITISCH: Der Benutzer hat eine Aktion angefordert, aber sein Datenvolumen bei Cortex ist aufgebraucht. Bitte informieren Sie den Benutzer in seiner Sprache, dass er warten oder ein Upgrade seines Abonnements in Betracht ziehen sollte.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'Cortex kann noch bessere Antworten geben; upgrade jetzt und erhalte die beste Antwort auf jede Frage!';

  @override
  String get pinLimitReached => 'Sie kÃ¶nnen bis zu 3 Chats anheften.';

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
