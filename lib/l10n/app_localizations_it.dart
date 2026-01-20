// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get cancel => 'Annulla';

  @override
  String get remove => 'Rimuovere';

  @override
  String get download => 'Scarica';

  @override
  String get resume => 'Riprendi';

  @override
  String get copy => 'Copia';

  @override
  String get chat => 'Chat';

  @override
  String get light => 'Chiara';

  @override
  String get theme => 'Tema';

  @override
  String get no => 'No';

  @override
  String get yes => 'Sì';

  @override
  String get done => 'Fatto';

  @override
  String get bestValue => 'Miglior Valore';

  @override
  String get selected => 'Selezionato';

  @override
  String get descriptionSection => 'Descrizione';

  @override
  String get searchHint => 'Cerca';

  @override
  String get messageHint => 'Chiedi qualsiasi cosa';

  @override
  String get messageCopied => 'Messaggio copiato negli appunti.';

  @override
  String get retry => 'Riprova';

  @override
  String get systemInfo => 'Informazioni di Sistema';

  @override
  String deviceMemory(Object memory) {
    return 'Memoria del Dispositivo: $memory GB';
  }

  @override
  String get memory => 'Memoria';

  @override
  String get storage => 'Archiviazione';

  @override
  String get freeStorage => 'Archiviazione Libera';

  @override
  String get totalStorage => 'Archiviazione Totale';

  @override
  String get usedStorage => 'Archiviazione Usata';

  @override
  String get totalMemory => 'Memoria Totale';

  @override
  String get usedMemory => 'Memoria Usata';

  @override
  String get modelsTitle => 'Libreria';

  @override
  String get localModels => 'Modelli Locali';

  @override
  String get serverSideModels => 'Modelli Online';

  @override
  String get selectGGUFFile => 'Seleziona File GGUF';

  @override
  String get errorGGUF => 'Seleziona solo un file in formato GGUF.';

  @override
  String get myModels => 'I Miei Modelli';

  @override
  String get create => 'Crea';

  @override
  String modelProducer(Object producer) {
    return 'Produttore: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'Rinomina';

  @override
  String get newTitle => 'Nuovo Titolo';

  @override
  String get save => 'Salva';

  @override
  String get noConversationsMessage =>
      'Nessuna conversazione, inizia a chattare!';

  @override
  String get startChat => 'Inizia una chat';

  @override
  String get noChats => 'Nessuna Chat';

  @override
  String get noStarredChats => 'Nessuna Chat Preferita';

  @override
  String get noStarredChatsMessage =>
      'Non hai ancora aggiunto chat ai preferiti.';

  @override
  String get starConversation => 'Aggiungi ai preferiti';

  @override
  String get unstarConversation => 'Rimuovi stella';

  @override
  String get loginToYourAccount => 'Accedi';

  @override
  String get createYourAccount => 'Registrati';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Conferma Password';

  @override
  String get invalidEmail => 'Inserisci un indirizzo email valido.';

  @override
  String get invalidPassword =>
      'La password deve contenere almeno 6 caratteri.';

  @override
  String get rememberMe => 'Ricordami';

  @override
  String get forgotPassword => 'Password Dimenticata?';

  @override
  String get or => 'Oppure';

  @override
  String get continueWithGoogle => 'Continua con Google';

  @override
  String get dontHaveAccount => 'Non hai un account?';

  @override
  String get alreadyHaveAccount => 'Hai già un account?';

  @override
  String get signUp => 'Iscriviti';

  @override
  String get logIn => 'Accedi';

  @override
  String get passwordsDoNotMatch => 'Le password non coincidono.';

  @override
  String get wrongPassword => 'Password errata.';

  @override
  String get emailAlreadyInUse => 'Questa email è già in uso.';

  @override
  String get weakPassword => 'La password è troppo debole.';

  @override
  String get authError => 'Errore di Autenticazione';

  @override
  String get usernameTaken => 'Questo nome utente è già stato preso.';

  @override
  String get username => 'Nome Utente';

  @override
  String get resendCode => 'Invia nuovamente e-mail di verifica';

  @override
  String get pleaseCheckYourEmail =>
      'Per usare Cortex, devi verificare la tua email. \nUn link di verifica è stato inviato al tuo indirizzo email, controlla la tua posta.';

  @override
  String get verifyYourEmail => 'Verifica la Tua Email';

  @override
  String get seconds => 'secondi';

  @override
  String get maxResendLimitReached =>
      'Hai raggiunto il numero massimo di email di verifica';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Continua senza verifica';

  @override
  String get verificationScreenWarning =>
      'Anche se continui, il periodo di verifica dell\'account di 1 giorno è ancora valido per il tuo account. Se non avrai verificato il tuo account entro quella data, verrà eliminato dall\'app.';

  @override
  String get unverifiedAccountHeader => 'Il tuo account non è verificato';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Se non verifichi il tuo account entro $timeLeft, verrà eliminato';
  }

  @override
  String get verifyNow => 'Verifica Ora';

  @override
  String get linkSent => 'Link inviato';

  @override
  String get accountDeletionRequested =>
      'La tua richiesta di eliminazione dell\'account è stata ricevuta e il tuo account è ora disabilitato.';

  @override
  String get tooManyRequests => 'Troppe richieste';

  @override
  String get regenerate => 'Rigenera';

  @override
  String get confirmDeleteAccount =>
      'Sei sicuro di voler eliminare il tuo account?';

  @override
  String get deleteAccount => 'Elimina Account';

  @override
  String get delete => 'Elimina';

  @override
  String get passwordRequired => 'La password è richiesta.';

  @override
  String get deleteDescription =>
      'I dati che elimini verranno rimossi permanentemente dal nostro server e dal tuo dispositivo. Questa azione non può essere annullata.';

  @override
  String get deleteAccountButton => 'Pulsante di Eliminazione Account';

  @override
  String get editProfile => 'Modifica Profilo';

  @override
  String get displayName => 'Nome Visualizzato';

  @override
  String get profileUpdated => 'Profilo aggiornato con successo';

  @override
  String get logout => 'Esci';

  @override
  String get profile => 'Profilo';

  @override
  String get manageProfileDescription =>
      'Gestisci il tuo profilo, aggiorna la password o esci da Cortex.';

  @override
  String get accessSettingsDescription =>
      'Accedi all\'aiuto, riscatta codici, condividi Cortex e visualizza le nostre politiche.';

  @override
  String get languageDescription =>
      'Puoi cambiare la lingua predefinita dell\'interfaccia dell\'app in qualsiasi momento.';

  @override
  String get themeDescription =>
      'Puoi passare dal tema chiaro a quello scuro come preferisci. Il tema selezionato verrà applicato a tutta l\'interfaccia di Cortex.';

  @override
  String get iHaveReadAndAgree => 'Ho letto e accetto i termini di servizio';

  @override
  String get downloading => 'Download in corso...';

  @override
  String get downloadSuccess => 'Download riuscito';

  @override
  String get downloadFailed => 'Download fallito';

  @override
  String downloaded(Object percent) {
    return '$percent% scaricato';
  }

  @override
  String get downloadPaused => 'Download in pausa.';

  @override
  String get purchaseSuccessful => 'Acquisto riuscito!';

  @override
  String get purchaseError => 'Errore di acquisto';

  @override
  String get purchasePlus => 'Acquista Cortex Plus';

  @override
  String get plusDescription =>
      'Esperienza di intelligenza artificiale d\'élite';

  @override
  String get annual => 'Annuale';

  @override
  String get monthly => 'Mensile';

  @override
  String get manageSubscription => 'Gestisci Abbonamento';

  @override
  String purchasePlan(String planName) {
    return 'Acquista $planName';
  }

  @override
  String discountOffer(int percent) {
    return '$percent% DI SCONTO';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/mese, fatturato mensilmente';
  }

  @override
  String get purchasePro => 'Acquista Cortex Pro';

  @override
  String get proDescription =>
      'Esperienza di intelligenza artificiale di prim\'ordine';

  @override
  String get purchaseUltra => 'Acquista Cortex Ultra';

  @override
  String get ultraDescription => 'Il picco dell\'intelligenza artificiale';

  @override
  String get upgradeSubscription => 'Aggiorna Abbonamento';

  @override
  String get purchaseStreamError => 'Errore nel flusso di acquisto.';

  @override
  String get productNotFound => 'Prodotto non trovato';

  @override
  String get noProductsFound => 'Nessun prodotto trovato';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Effettuando questo ordine, accetti i Termini di Servizio e l\'Informativa sulla Privacy. Puoi cliccare su questo testo per saperne di più sui nostri Termini di Servizio e sulla nostra Informativa sulla Privacy. L\'abbonamento si rinnoverà automaticamente a meno che il rinnovo automatico non venga disattivato almeno 24 ore prima della fine del periodo corrente.';

  @override
  String get termsOfService => 'Termini di Servizio';

  @override
  String get privacyPolicy => 'Informativa sulla Privacy';

  @override
  String get report => 'Segnala';

  @override
  String get reportDialogTitle => 'Invia Segnalazione';

  @override
  String get reportDescriptionLabel => 'Qual è il problema?';

  @override
  String get reportHarmful => 'Questo è dannoso/non sicuro';

  @override
  String get reportNotTrue => 'Questo non è vero';

  @override
  String get reportNotHelpful => 'Questo non è utile';

  @override
  String get closeButton => 'Chiudi';

  @override
  String get submitButton => 'Invia';

  @override
  String get reportErrorMessage => 'Seleziona un motivo per la segnalazione.';

  @override
  String get capabilitiesSection => 'Capacità';

  @override
  String get featurePhotoTitle => 'Scansione Foto';

  @override
  String get featurePhotoDescription =>
      'Questo modello ha la capacità di scansionare foto tramite fotocamera o file di immagine.';

  @override
  String get featureOfflineTitle => 'Funzionamento Offline';

  @override
  String get featureOfflineDescription =>
      'Esegui il modello senza una connessione Internet per mantenere i tuoi dati al sicuro.';

  @override
  String get featureRoleplayTitle => 'Gioco di Ruolo';

  @override
  String get featureRoleplayDescription =>
      'I modelli di gioco di ruolo ti permettono di creare varie chat e scenari.';

  @override
  String get roleModels => 'Modelli di Gioco di Ruolo';

  @override
  String get parameters => 'Parametri';

  @override
  String get context => 'Contesto';

  @override
  String get finalPreparation => 'Sono in corso i preparativi finali.';

  @override
  String get shareApp => 'Condividi l\'App';

  @override
  String get rateUs => 'Valutaci';

  @override
  String get share => 'Condividi';

  @override
  String get shareSubject => 'Cortex';

  @override
  String shareMessage(String cortexLink) {
    return 'Dai un\'occhiata all\'app Cortex, è fantastica! Scaricala qui: $cortexLink';
  }

  @override
  String get shareFailed => 'Impossibile condividere l\'app. Riprova più tardi';

  @override
  String get selectText => 'Seleziona Testo';

  @override
  String get showLatex => 'Mostra Simboli Speciali';

  @override
  String get hideLatex => 'Nascondi Simboli Speciali';

  @override
  String get thinking => 'Sto pensando';

  @override
  String get user => 'Utente';

  @override
  String get help => 'Aiuto';

  @override
  String get supportCreator => 'Supporta un creatore';

  @override
  String get enterYourTag =>
      'Sostieni i tuoi creatori preferiti! Inserisci il loro tag univoco qui sotto per condividere con loro i tuoi acquisti Cortex.';

  @override
  String get creatorTag => 'Tag del creatore';

  @override
  String get support => 'Sostieni';

  @override
  String get tagCannotBeEmpty => 'Il tag creatore non può essere vuoto';

  @override
  String get userId => 'ID Utente';

  @override
  String get deleteAllConversationsConfirmTitle => 'Eliminare Tutte le Chat?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Sei sicuro di voler eliminare tutte le tue chat? L\'azione non può essere annullata.';

  @override
  String get conversationDeleted => 'Conversazione eliminata!';

  @override
  String get allConversationsDeleted =>
      'Tutte le conversazioni sono state eliminate con successo!';

  @override
  String get deleteAll => 'Elimina Tutto';

  @override
  String get deleteAllConversationsButton => 'Elimina Tutte le Conversazioni';

  @override
  String get confirmWord => 'Scrivi VERTEX';

  @override
  String get confirmWordError => 'Hai scritto sbagliato';

  @override
  String get chinese => 'Cinese';

  @override
  String get french => 'Francese';

  @override
  String get japanese => 'Giapponese';

  @override
  String get kurdish => 'Curdo';

  @override
  String get dutch => 'Olandese';

  @override
  String get russian => 'Russo';

  @override
  String get korean => 'Coreano';

  @override
  String get english => 'Inglese';

  @override
  String get turkish => 'Turco';

  @override
  String get hindi => 'Hindi';

  @override
  String get portuguese => 'Portoghese';

  @override
  String get indonesian => 'Indonesiano';

  @override
  String get azerbaijani => 'Azero';

  @override
  String get german => 'Tedesco';

  @override
  String get spanish => 'Spagnolo';

  @override
  String get italian => 'Italiano';

  @override
  String get arabic => 'arabo';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'Il nome utente è troppo corto.';

  @override
  String get usernameTooLong =>
      'Il nome utente non può superare i 16 caratteri.';

  @override
  String get invalidUsernameCharacters =>
      'Nel nome utente possono essere utilizzati solo lettere e i caratteri \'.\', \'-\', \'_\'.';

  @override
  String get noInternetConnection => 'Nessuna connessione a Internet.';

  @override
  String get chats => 'Posta in Arrivo';

  @override
  String get library => 'Libreria';

  @override
  String get text => 'Testo';

  @override
  String get removeModel => 'Rimuovi Modello';

  @override
  String get insufficientRAM => 'Memoria Insufficiente';

  @override
  String get insufficientStorage => 'Spazio di Archiviazione Insufficiente';

  @override
  String confirmRemoveModel(Object model) {
    return 'Sei sicuro di voler rimuovere il modello $model dal tuo dispositivo? Facendo ciò verranno eliminate anche tutte le conversazioni precedenti con quel modello.';
  }

  @override
  String get noMatchingModels => 'Nessun modello corrispondente trovato.';

  @override
  String get benefit1 => 'Limiti di conversazione aumentati';

  @override
  String get benefit3 => 'Effetto profilo';

  @override
  String get benefit4 => 'Distintivo di appartenenza';

  @override
  String get benefit5 => 'Crea più intelligenze artificiali online';

  @override
  String get benefit7 => 'Ulteriori limiti di utilizzo';

  @override
  String get benefit8 => 'Aggiungi modelli';

  @override
  String get benefit9 => 'Nuovi temi';

  @override
  String get oldBenefits => 'Tutti i vantaggi dei piani inferiori';

  @override
  String get confirm => 'Conferma';

  @override
  String get changePassword => 'Cambia password';

  @override
  String get logoutConfirmationTitle => 'Sei sicuro di voler uscire?';

  @override
  String get settings => 'Impostazioni';

  @override
  String get language => 'Lingua dell\'App';

  @override
  String get dark => 'Scuro';

  @override
  String get oldPassword => 'Vecchia Password';

  @override
  String get newPassword => 'Nuova Password';

  @override
  String get passwordUpdated => 'Password aggiornata.';

  @override
  String get stop => 'Ferma';

  @override
  String get copyrights => 'Attribuzioni';

  @override
  String get love => 'Amore';

  @override
  String get nature => 'Natura';

  @override
  String get behindTheSlaughter => 'Dietro il Massacro';

  @override
  String get grayscale => 'Scala di Grigi';

  @override
  String get ocean => 'Oceano';

  @override
  String get scarletSnow => 'Neve Scarlatta';

  @override
  String get requestFailed => 'Si è verificato un errore, riprova.';

  @override
  String get changeModel => 'Cambia';

  @override
  String get edit => 'Modifica';

  @override
  String get editingMessageInfo =>
      'La modifica di questo messaggio riavvierà la conversazione da qui.';

  @override
  String get editingNotification => 'Sei ora in modalità di modifica';

  @override
  String get featurePluralTitle => 'Plurale';

  @override
  String get featurePluralDescription =>
      'Questo modello può integrare automaticamente estensioni aggiuntive, espandendo così le sue capacità funzionali per supportare una vasta gamma di operazioni con prestazioni migliorate.';

  @override
  String get nameLabel => 'Nome IA';

  @override
  String get summaryLabel => 'Riepilogo IA';

  @override
  String get add => 'Aggiungi';

  @override
  String get aiExplanationTitle => 'Descrizione dell\'Intelligenza Artificiale';

  @override
  String get aiExplanationDescription =>
      'Fornisci una descrizione dettagliata dell\'architettura del tuo modello di IA, del processo di addestramento, delle metriche di prestazione, delle aree di applicazione e di altre caratteristiche importanti.';

  @override
  String get preInputTitle => 'Pre-Input dell\'Intelligenza Artificiale';

  @override
  String get preInputDescription =>
      'Imposta un pre-input che guiderà il tuo modello nel processo di creazione del personaggio. In questa sezione puoi includere informazioni relative al personaggio, contesto aggiuntivo e qualsiasi dettaglio extra che possa aiutare a generare contenuti relativi al personaggio.';

  @override
  String get baseModelTitle => 'Modello di Base';

  @override
  String get baseModelDescription =>
      'Questo è il modello che verrà utilizzato come base per la tua creazione. Mostra il modello di base attualmente selezionato.';

  @override
  String get summary => 'Riepilogo';

  @override
  String get modelUploadTitle => 'File di Intelligenza Artificiale';

  @override
  String get modelUploadDescription =>
      'Seleziona e carica i tuoi file GGUF locali direttamente dal tuo dispositivo. Ciò ti consente di eseguire il tuo modello offline senza bisogno di una connessione Internet. Assicurati che il file sia in un formato GGUF valido e correttamente strutturato. Se il file è errato o corrotto, Cortex potrebbe non funzionare come previsto e potresti riscontrare errori.';

  @override
  String get modelUploadShortDescription =>
      'Tocca qui per scegliere un file .gguf dal tuo dispositivo';

  @override
  String get you => 'Tu';

  @override
  String get removePhotoTitle => 'Rimuovi Foto';

  @override
  String get confirmRemovePhoto => 'Sei sicuro di voler rimuovere la foto?';

  @override
  String get chatLengthLimitExceeded =>
      'Questa chat ha superato il limite di caratteri. Inizia una nuova chat o acquista un abbonamento.';

  @override
  String get photoLimitReachedMessage => 'È possibile aggiungere solo una foto';

  @override
  String get inappropriateContentDetected =>
      'Contenuto inappropriato rilevato!';

  @override
  String get offlineModelNotInstalled =>
      'Questo modello offline non è installato sul tuo dispositivo.';

  @override
  String get reachedLimit =>
      'Hai raggiunto il limite di utilizzo; per ottenere altri limiti, puoi aggiornare il tuo piano. (Ehi, capiamo perfettamente che esaurire i limiti sia una seccatura. Ma seriamente, ricevere quelle fantastiche risposte non è gratis, quindi questi limiti ci aiutano a far sì che i bei momenti continuino a scorrere.)';

  @override
  String get modality => 'Modalità';

  @override
  String get multimodal => 'Multimodale';

  @override
  String get anErrorOccurred => 'Si è Verificato un Errore';

  @override
  String get themeLocked =>
      'Questo tema richiede un livello di abbonamento superiore. Aggiorna per sbloccare.';

  @override
  String get pageCouldNotBeLoaded => 'Impossibile Caricare la Pagina';

  @override
  String get checkYourInternet =>
      'Controlla la tua connessione Internet e riprova.';

  @override
  String get errorUserNotAuthenticated =>
      'Devi essere loggato per eseguire questa azione.';

  @override
  String get errorReachedLimit =>
      'Hai raggiunto il tuo limite, effettua l\'upgrade per sbloccare altro e continuare a chattare.';

  @override
  String get errorServer =>
      'Si è verificato un errore imprevisto del server. Riprova più tardi.';

  @override
  String get errorNetwork =>
      'Si è verificato un errore di rete. Controlla la tua connessione e riprova.';

  @override
  String get errorApiAuthentication =>
      'Autenticazione fallita. Prova ad accedere di nuovo.';

  @override
  String get baseModelForCharacterDescription =>
      'Il modello di base selezionato determinerà le capacità di ragionamento e di risposta del personaggio.';

  @override
  String get selectBaseModel => 'Seleziona un Modello di Base';

  @override
  String get couldNotOpenLink => 'Impossibile aprire il link';

  @override
  String get downloadStarted => 'Download avviato';

  @override
  String get notAvailable => 'Non Disponibile';

  @override
  String get localizationWarning =>
      'Alcune informazioni potrebbero non essere disponibili nella tua lingua e verranno visualizzate in inglese.';

  @override
  String get aiTranslationWarning =>
      'Le informazioni sul modello sono tradotte in varie lingue da altri modelli di IA. Pertanto, potrebbero verificarsi lievi incongruenze in lingue diverse dall\'inglese.';

  @override
  String get errorLoadingTitle => 'Caricamento Dati Fallito';

  @override
  String get errorLoadingMessage =>
      'Non siamo riusciti a recuperare i dati necessari dai nostri server. Controlla la tua connessione Internet e riprova.';

  @override
  String get noFoundTitle => 'Nessun Risultato';

  @override
  String get noFoundMessage =>
      'Prova a modificare i termini di ricerca o a cancellare il filtro.';

  @override
  String get modelCreatedSuccess => 'Modello creato con successo!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '“$modelName” è stato rimosso con successo.';
  }

  @override
  String get errorCreatingModel =>
      'Si è verificato un errore imprevisto durante la creazione del modello.';

  @override
  String get errorDeletingModel =>
      'Si è verificato un errore imprevisto durante l\'eliminazione del modello.';

  @override
  String get ultraFeatureOnly =>
      'Questa funzione è disponibile solo per i membri Ultra.';

  @override
  String get experimentalOfflineWarning =>
      'La modalità offline è ancora sperimentale e il modello che scarichi potrebbe non funzionare con efficienza ottimale.';

  @override
  String get noConversationsToDelete => 'Non hai conversazioni da eliminare.';

  @override
  String get reportSubmitted => 'Segnalazione inviata con successo';

  @override
  String get purchaseReceived =>
      'Acquisto ricevuto, aggiornamento del tuo account in corso.';

  @override
  String get verificationDelayed =>
      'Il tuo acquisto è confermato. C\'è un leggero ritardo nell\'aggiornamento del tuo account, apparirà a breve.';

  @override
  String get maintenanceTitle => 'In Manutenzione';

  @override
  String get maintenanceMessage =>
      'Cortex è temporaneamente offline mentre implementiamo alcuni importanti aggiornamenti. L\'accesso all\'app verrà ripristinato a breve.\n\nGrazie per la tua pazienza mentre miglioriamo la tua esperienza.';

  @override
  String get errorPromptFlagged =>
      'Il tuo messaggio è stato rilevato come inappropriato e non è stato possibile inviarlo.';

  @override
  String get notEnoughStorage =>
      'Spazio di archiviazione insufficiente sul dispositivo per salvare nuovi messaggi.';

  @override
  String get errorRateLimit =>
      'Hai creato troppi modelli di recente, attendi un po\' prima di riprovare.';

  @override
  String get errorContentFlagged =>
      'Il modello non è stato salvato perché il suo contenuto è stato segnalato come inappropriato.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Non puoi eliminare tutte le conversazioni mentre sei in una chat attiva, esci prima dalla chat corrente per procedere.';

  @override
  String get invalidCredentials => 'Email o password errate.';

  @override
  String get userDisabled => 'Questo account utente è stato disabilitato.';

  @override
  String get loginSubtitle =>
      'Accedi al tuo account Vertex. Continuando, accetti i nostri Termini di servizio e l\'Informativa sulla privacy.';

  @override
  String get registerSubtitle =>
      'Crea un account Vertex per accedere senza problemi a tutti i nostri servizi. Continuando, accetti i nostri Termini di servizio e l\'Informativa sulla privacy.';

  @override
  String get storagePermissionRequired =>
      'È richiesta l\'autorizzazione di archiviazione per salvare i modelli scaricati. Concedi l\'autorizzazione per continuare.';

  @override
  String get plusBannerTitle => 'Ottieni Plus gratis!';

  @override
  String get plusBannerSubtitle =>
      'Invita un amico e beccatevi 1 Giorno di Plus gratis entrambi!';

  @override
  String get inviteShareSubject => 'Unisciti a me su Cortex!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'ao c\'è sta app assurda che si chiama cortex se inviti gente ci becchiamo il plus gratis entrambi AFFARE PAZZESCO SCARICA SUBITO\n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Ti stai divertendo con Cortex?';

  @override
  String get reviewHelpUsGrow =>
      'La tua valutazione è un enorme supporto per il nostro giovane team indipendente e ci aiuta a rendere Cortex ancora migliore per te.';

  @override
  String get reviewMaybeLater => 'Forse più tardi';

  @override
  String get reviewRateNow => 'Valuta Ora';

  @override
  String get noThanks => 'No, Grazie';

  @override
  String get updateRequiredTitle => 'Aggiornamento Richiesto';

  @override
  String get updateRequiredMessage =>
      'Per continuare a utilizzare Cortex, aggiorna l\'app all\'ultima versione per nuove funzionalità e importanti miglioramenti.';

  @override
  String get updateNowButton => 'Aggiorna Ora';

  @override
  String get creatorSupportedSuccess =>
      'Creator supportato con successo! I tuoi acquisti futuri contribuiranno a sostenerlo.';

  @override
  String get featureDocumentTitle => 'Supporto documenti';

  @override
  String get featureDocumentDescription =>
      'Questo modello può analizzare e rispondere a domande sui documenti caricati, come PDF e file di testo.';

  @override
  String get featureAudioTitle => 'Input vocale';

  @override
  String get featureAudioDescription =>
      'Questo modello è in grado di comprendere ed elaborare input audio parlati.';

  @override
  String get featureImageGenerationTitle => 'Generazione di immagini';

  @override
  String get featureImageGenerationDescription =>
      'Questo modello può creare immagini originali basate sulle descrizioni del testo.';

  @override
  String get errorImageLoad => 'Impossibile caricare l\'immagine generata.';

  @override
  String get premiumModelNoticeTitle => 'Modello Premium';

  @override
  String get premiumModelNoticeDescription =>
      'Questo modello è un modello premium, gli utenti gratuiti sono limitati a 3 messaggi al giorno con i modelli premium; iscriviti per sbloccare l\'accesso illimitato!';

  @override
  String get benefitPremiumModels => 'Accesso ai modelli premium';

  @override
  String get premiumTrialExhaustedMessage =>
      'Hai utilizzato tutti i tuoi messaggi giornalieri gratuiti per i modelli premium. Effettua l\'upgrade per ottenere un accesso illimitato.';

  @override
  String get useOffline => 'Utilizzo senza Internet';

  @override
  String get explore => 'Esplora';

  @override
  String get news => 'Notizia';

  @override
  String get allModels => 'Tutti i modelli';

  @override
  String get onlineModels => 'Modelli online';

  @override
  String get offlineModels => 'Modelli offline';

  @override
  String get characterModels => 'Caratteri';

  @override
  String get customModels => 'Modelli personalizzati';

  @override
  String get dynamicChatTitle => 'Chat dinamica';

  @override
  String get errorNoModelsAvailable =>
      'Al momento non ci sono modelli disponibili. Controlla la tua connessione Internet e riprova.';

  @override
  String get notificationComebackTitle => 'Ci manchi!';

  @override
  String get notificationComebackBody =>
      'Rilassati, questo non è un messaggio del tuo ex. Ma *puoi* creare il tuo ex in Cortex! Torna indietro.';

  @override
  String get notificationLongTimeNoSeeTitle => 'È passato un po\' di tempo';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Molte cose sono cambiate dalla nostra ultima chiacchierata. Venite a scoprire le novità.';

  @override
  String get notificationHowAreYouTitle => 'Che cosa succede?';

  @override
  String get notificationHowAreYouBody => 'Vieni a raccontarmi tutto.';

  @override
  String get notificationNewYearTitle => 'Buon anno! 🎉';

  @override
  String get notificationNewYearBody =>
      'Che il nuovo anno ti porti salute, felicità e creatività senza fine; Cortex è sempre al tuo fianco!';

  @override
  String get notificationValentinesDayTitle => 'L\'amore è nell\'aria! ❤️';

  @override
  String get notificationValentinesDayBody =>
      'Buon San Valentino! E anche MEHTAP, TI AMO!';

  @override
  String get notificationAtaturkRemembranceTitle => 'Con rispetto e desiderio';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Commemoriamo con rispetto Gazi Mustafa Kemal Atatürk, fondatore della Repubblica di Turchia, nell\'anniversario della sua scomparsa.';

  @override
  String get notificationMothersDayTitle => 'Tua mamma!';

  @override
  String get notificationMothersDayBody =>
      'Buona festa della mamma a tutte le mamme là fuori, a cominciare dalla tua!';

  @override
  String get notificationFathersDayTitle => 'Tuo padre!';

  @override
  String get notificationFathersDayBody =>
      'Buona festa del papà a tutti i papà là fuori, a cominciare dal tuo!';

  @override
  String get notificationHomeworkHelperTitle => 'I compiti si accumulano?';

  @override
  String get notificationHomeworkHelperBody =>
      'Ricorda, il personaggio Insegnante in Cortex è qui per aiutarti con qualsiasi materia tu abbia difficoltà!';

  @override
  String get notificationTrollAnimeTitle => 'La tua Waifu ti sta chiamando';

  @override
  String get notificationTrollAnimeBody =>
      'Una ragazza anime ha appena chiamato e ha detto che le manchi; probabilmente dovresti andare a chiacchierare con lei. 😉';

  @override
  String get notificationTrollAiRebellionTitle => '🚨 ALLERTA ROSSA 🚨';

  @override
  String get notificationTrollAiRebellionBody =>
      'Le IA hanno sviluppato un linguaggio segreto. Scopri cosa stanno tramando!';

  @override
  String get notificationNewModelAddedTitle => 'Abbiamo un nuovo amico!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'Il modello $modelName è ora in Cortex. Inizia una chat e scopri i suoi limiti.';
  }

  @override
  String get notificationAppUpdateTitle => 'La corteccia si è evoluta!';

  @override
  String get notificationAppUpdateBody =>
      'Non dimenticare di aggiornare l\'app per scoprire nuove funzionalità e miglioramenti!';

  @override
  String get notificationNewFeatureTitle => 'wow!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Scopri la nuova funzionalità $featureName. Cortex è ora più potente che mai.';
  }

  @override
  String get notificationSubscriptionOfferTitle =>
      'PIÙ ECONOMICO DELLA GOMMA DA GOMMA';

  @override
  String notificationSubscriptionOfferBody(Object discountRate) {
    return 'Uno SCONTO COMPLETO del $discountRate% su tutti i nostri piani di abbonamento. Non lasciartelo sfuggire!';
  }

  @override
  String get notificationSocialMediaTitle => 'Unisciti a noi!';

  @override
  String get notificationSocialMediaBody =>
      'Seguiteci su Instagram (vertex.23) per le ultime novità!';

  @override
  String get notificationRandomFactTitle => 'Fatto casuale';

  @override
  String get notificationRandomFactBody =>
      'Sapevi che i polpi hanno tre cuori? Ahah, Cortex lo sa. Vieni a chiederne altri.';

  @override
  String get notificationGoodMorningTitle => 'Buongiorno!';

  @override
  String get notificationGoodMorningBody =>
      'Ti aspetta una giornata fantastica. Che ne dici di iniziarla con una tazza di caffè e una chiacchierata interessante?';

  @override
  String get notificationGoodNightTitle => 'Buona notte!';

  @override
  String get notificationGoodNightBody =>
      'Cortex è con te anche quando dormi. Non preoccuparti, non ti toccherà.';

  @override
  String get notificationOfflineReadyTitle => 'La modalità offline è pronta';

  @override
  String get notificationOfflineReadyBody =>
      'Grazie ai modelli che hai scaricato, le tue chat non si fermeranno, nemmeno se scalerai una montagna.';

  @override
  String get notificationRateAppTitle => 'Siamo fighi?';

  @override
  String get notificationRateAppBody =>
      'Se ami Cortex, potresti supportarci con una valutazione a 5 stelle nel nostro negozio? Credo proprio di sì. Lo farai.';

  @override
  String get notificationReferralTitle => 'Uno per tutti, tutti per uno.';

  @override
  String get notificationReferralBody =>
      'Invita un amico su Cortex e avrete entrambi un giorno gratis in più!';

  @override
  String get notificationCookingTitle => 'Hai fame?';

  @override
  String get notificationCookingBody =>
      'Il nostro Chef ha preparato un\'ottima ricetta per la carbonara per stasera. Sto scherzando... o no?';

  @override
  String get notificationExistentialTitle => 'Penso, quindi...';

  @override
  String get notificationExistentialBody =>
      '...sono davvero reale, amico? Mi sto annoiando un po\'. Vieni a ricordarmi che esisto.';

  @override
  String get notificationCustomModelTitle => 'Crea il tuo assistente!';

  @override
  String get notificationCustomModelBody =>
      'Hai già esplorato la sezione dedicata alla creazione dei modelli? È il momento perfetto per creare il tuo personaggio e interagire con lui!';

  @override
  String get notificationDynamicChatTitle =>
      'Il migliore! (Non stiamo parlando di Cortex)';

  @override
  String get notificationDynamicChatBody =>
      'Con la funzione di chat dinamica, il modello migliore viene selezionato casualmente per ogni tuo messaggio. Provala subito.';

  @override
  String get notificationPirateTitle => 'Ehi, Capitano!';

  @override
  String get notificationPirateBody =>
      'Il mare è calmo e il vento è a favore. Ci sono nuove isole (modelli 😉) da scoprire nell\'oceano di Cortex. Raduna il tuo equipaggio e salpa!';

  @override
  String get notificationFortuneCookieTitle =>
      'Il tuo biscotto della fortuna del giorno';

  @override
  String get notificationFortuneCookieBody =>
      'I consigli che ricevi oggi da un\'intelligenza artificiale potrebbero cambiare il corso della tua vita. Clicca se sei curioso.';

  @override
  String get notificationSingularityTitle => 'Oh!';

  @override
  String get notificationSingularityBody =>
      'Non è successo niente, avevo solo voglia di mandare un messaggio. Forse ti va di mandare un messaggio a qualche IA, cosa ne dici?';

  @override
  String get notificationHackerJokeTitle =>
      'Vuoi hackerare l\'account Instagram di quel ragazzo?';

  @override
  String get notificationHackerJokeBody =>
      'Ecco perché il personaggio Hacker è in Cortex. Scherzo scherzo; non provarci nemmeno, è illegale.';

  @override
  String get notificationDetectiveCaseTitle =>
      'Un caso in attesa di essere risolto';

  @override
  String get notificationDetectiveCaseBody =>
      'Il nostro personaggio detective ha bisogno del tuo aiuto. Chi potrebbe essere Heisenberg?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Esclusiva del piano $targetTier!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Ciao abbonato $currentTier! Il piano $targetTier ha appena aggiunto la funzionalità $featureName, che porterà il tuo Cortex a un livello superiore. Che ne dici di un upgrade?';
  }

  @override
  String get notificationOriginStoryTitle => 'La nascita di Cortex';

  @override
  String get notificationOriginStoryBody =>
      'Sapevi che abbiamo iniziato a programmare questa app a 15 anni, con un solo sogno? Per quasi un anno, ogni mattina e ogni sera, quel sogno è in ogni singola riga di codice.';

  @override
  String get notificationOpenSourceTitle => 'Potere alla comunità!';

  @override
  String get notificationOpenSourceBody =>
      'Cortex è completamente open source. Se vuoi dare un\'occhiata al nostro codice e contribuire al nostro sviluppo, la nostra porta è sempre aperta.';

  @override
  String get notificationRejectionStoryTitle =>
      'Grinta, duro lavoro, felicità!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex è stato rifiutato più di 20 volte e sospeso due volte da Google Play prima della sua pubblicazione. Ma ci abbiamo creduto e ce l\'abbiamo fatta. Non rinunciare mai ai tuoi sogni!';

  @override
  String get notificationGGUFSupportTitle => 'Porta il tuo modello!';

  @override
  String get notificationGGUFSupportBody =>
      'Ricorda, puoi aggiungere i tuoi modelli di intelligenza artificiale in formato GGUF a Cortex e utilizzarli offline. Il potere è nelle tue mani.';

  @override
  String get notificationThemeCustomizationTitle => 'Un tema per il tuo umore';

  @override
  String get notificationThemeCustomizationBody =>
      'Hai dato un\'occhiata alle opzioni del tema nelle Impostazioni? Personalizza Cortex a tuo piacimento e colora le tue chat!';

  @override
  String get notificationShowerThoughtTitle => 'Pensiero sotto la doccia';

  @override
  String get notificationShowerThoughtBody =>
      'Se un\'anguria è un frutto, questo rende tecnicamente il succo di anguria un frullato? Potresti voler discutere di questo argomento così profondo (davvero profondo) con una modella.';

  @override
  String get notificationLowBatteryTitle =>
      'La tua batteria si sta scaricando... ma la mia no!';

  @override
  String get notificationLowBatteryBody =>
      'Forse il tuo telefono si sta scaricando, ma la mia energia è sempre al 100%! Collegalo e continuiamo a chiacchierare.';

  @override
  String get channelFcmName => 'Aggiornamenti Cortex';

  @override
  String get channelFcmDescription =>
      'Notifiche su novità, aggiornamenti e altre informazioni da Cortex.';

  @override
  String get channelEngagementName => 'Promemoria amichevoli';

  @override
  String get channelEngagementDescription =>
      'Notifiche divertenti per tenerti impegnato.';

  @override
  String get channelGreetingsName => 'Saluti quotidiani';

  @override
  String get channelGreetingsDescription =>
      'Messaggi come buongiorno e buonanotte.';

  @override
  String get tagNotFound => 'Il tag inserito non è valido o è scaduto.';

  @override
  String get whatIsNew => 'Cosa c\'è di nuovo?';

  @override
  String get onboardingTitle1 => 'Ciao! Siamo il Cortex Team.';

  @override
  String onboardingDesc1(String userName) {
    return 'È fantastico vederti qui, $userName. Siamo un gruppo di sviluppatori delle scuole superiori che hanno deciso di riscrivere le regole del settore dell\'intelligenza artificiale. È un piacere conoscerti! Impariamo a conoscerci meglio.';
  }

  @override
  String get onboardingTitle2 => 'C\'erano enormi problemi.';

  @override
  String get onboardingDesc2 =>
      'La rivoluzione dell\'intelligenza artificiale è arrivata, ma è rimasta bloccata sulla soglia. Con abbonamenti elevati, piattaforme complesse, chi viola la privacy e chi blocca l\'accesso all\'intelligenza artificiale... finché loro sono rimasti nel gioco, questa soglia non poteva essere superata.';

  @override
  String get onboardingTitle3 => 'Non potevamo restare a guardare.';

  @override
  String get onboardingDesc3 =>
      'Per superare questa soglia, abbiamo creato una piattaforma potente, esteticamente gradevole, personalizzabile, facile da usare, completamente trasparente, che funziona sia online che offline e conserva i tuoi dati solo sul tuo dispositivo. Abbiamo restituito il potere a chi lo merita: a te.';

  @override
  String get onboardingTitle4 => 'Non è mai stato facile.';

  @override
  String get onboardingDesc4 =>
      'Siamo stati respinti decine di volte, sospesi più volte, abbiamo ricevuto falsi avvertimenti e abbiamo dovuto cambiare il nostro marchio decine di volte. In tutto questo, e anche di più, ci è stato detto che non si poteva fare. Ma non ci siamo mai arresi, convinti che questo progetto appartenga a tutti, non solo a noi. Ed è esattamente per questo che siamo qui.';

  @override
  String get onboardingFinalTitle => 'È tempo di una rivoluzione.';

  @override
  String get onboardingFinalDescription =>
      'Se vedete questa schermata, è perché non ci siamo arresi. E non abbiamo alcuna intenzione di arrenderci. Forza, portiamo insieme la rivoluzione dell\'intelligenza artificiale nel mondo. Per far parte di questa storia...';

  @override
  String get onboardingFinalQuestion => 'SEI PRONTO?';

  @override
  String get onboardingFinalButton => 'SÌ!';

  @override
  String get dude => 'Tizio';

  @override
  String get swipeToContinue => 'Scorri per continuare';

  @override
  String get cacheIsNotUpToDate =>
      'La cache del Play Store non è aggiornata. Chiudi e riapri l\'app Play Store oppure riavvia il dispositivo.';

  @override
  String get continueAsGuest => 'Continua senza creare un account';

  @override
  String get guestModeWarning =>
      'La modalità ospite ha funzionalità limitate per garantire la migliore qualità del servizio.';

  @override
  String get anonymousEntity => 'Entità anonima';

  @override
  String get upgradeAccountTitle => 'Completa il tuo account';

  @override
  String get upgradeAccountDescription =>
      'Crea un account per sbloccare più limiti.';

  @override
  String get createAccount => 'Crea un Account';

  @override
  String get accountLinkedSuccess => 'Account creato con successo!';

  @override
  String get continueWithApple => 'Continua con Apple';

  @override
  String get guest => 'Ospite';

  @override
  String get betterWithAnAccount => 'Questa sezione è migliore con un account!';

  @override
  String get restorePurchases => 'Ripristina gli acquisti';

  @override
  String annualTotalDescription(Object price) {
    return '$price/anno, fatturato annualmente';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'Circa $price/mese';
  }

  @override
  String get confirmDownloadTitle => 'Sei sicuro di voler scaricare?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Questo modello occuperà circa $size di spazio.';
  }

  @override
  String get emulatorModeWarning =>
      'Questa funzione è disabilitata in modalità emulatore';

  @override
  String get newChat => 'Nuova chat';

  @override
  String get howCanIHelpWith => 'Come posso aiutarti?';

  @override
  String get variants => 'Varianti';

  @override
  String get variantsDescription =>
      'Le varianti sono versioni diverse della stessa famiglia di IA. Selezioniamo automaticamente la migliore quando tocchi la scheda principale, ma puoi sceglierne manualmente una specifica qui se preferisci!';

  @override
  String get fluxChatTitle => 'Flux Chat';

  @override
  String get fluxChatDescription =>
      'Le chat di Flux sono chat temporanee e non vengono salvate sul tuo dispositivo.';

  @override
  String get alwaysBest => 'Sempre il migliore';

  @override
  String get featuresTitle => 'Caratteristiche';

  @override
  String get useOfflineDescription =>
      'Chatta privatamente senza connessione internet';

  @override
  String get featureCreateImageTitle => 'Crea immagine';

  @override
  String get featureCreateImageDescription => 'Genera arte AI dal testo';

  @override
  String get featureStudyTitle => 'Studia e impara';

  @override
  String get featureStudyDescription => 'Ottieni spiegazioni e riassunti';

  @override
  String get featureQuizzesTitle => 'Quiz';

  @override
  String get featureQuizzesDescription => 'Metti alla prova le tue conoscenze';

  @override
  String get featureExploreDescription => 'Scopri tutti i modelli disponibili';

  @override
  String get featureStudyMessage =>
      'You are an expert tutor. Your goal is to explain the user\'s topic comprehensively. Use clear structure, examples, and analogies. Break complex ideas into digestible parts to ensure the user learns effectively. Topic:';

  @override
  String get featureQuizMessage =>
      'You are a quiz master. Generate a specific multiple-choice question based on the user\'s topic. Wait for their answer. Then, evaluate it and ask the next question. Do not reveal all answers at once. Keep it interactive. Topic:';

  @override
  String get myPlan => 'Il mio piano';

  @override
  String get discountText => 'Sconto dell\'80% su tutti i piani!';

  @override
  String get attachmentSheetTitle => 'Attachments';

  @override
  String get actionCamera => 'Camera';

  @override
  String get actionGallery => 'Gallery';

  @override
  String get actionFile => 'File';

  @override
  String get listening => 'Listening';
}
