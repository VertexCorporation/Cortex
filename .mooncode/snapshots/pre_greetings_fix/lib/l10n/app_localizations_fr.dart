// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'Vous Ãªtes un gÃ©nÃ©rateur de titres. Veuillez rÃ©pondre UNIQUEMENT avec un titre de 2 Ã  5 mots pour la conversation suivante. N\'utilisez ni guillemets, ni prÃ©fixes, ni ponctuation. IMPORTANTÂ : Le titre DOIT Ãªtre dans la MÃŠME langue que le message de l\'utilisateur.';

  @override
  String get systemRoleFallback => 'Vous Ãªtes un assistant prÃ©cieux.';

  @override
  String get systemLanguageInstruction =>
      '\n\nCRITICALÂ : RÃ©pondez toujours dans la mÃªme langue que celle utilisÃ©e par lâ€™utilisateur, et tenez compte de sa langue.';

  @override
  String get systemNotePreviousMedia =>
      '[Note systÃ¨me : Voici le mÃ©dia gÃ©nÃ©rÃ© prÃ©cÃ©demment. Vous pouvez vous y rÃ©fÃ©rer ou le modifier.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return '\n\nDate et heure actuelles : $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\nAnalysez la conversation jusqu\'Ã  prÃ©sent. Si vous avez appris de nouvelles informations distinctes sur l\'utilisateur (prÃ©fÃ©rences, nom, habitudes, contexte), vous DEVEZ afficher l\'INTÃ‰GRALITÃ‰ de ces informations mises Ã  jour entre les balises <memory>...</memory> Ã€ LA TOUTE FIN de votre rÃ©ponse. IMPORTANTÂ : Vous ne devez JAMAIS effacer ni Ã©craser les informations prÃ©cÃ©dentes. Ajoutez TOUJOURS les nouvelles informations aux informations existantes. Si vous n\'avez absolument rien appris de nouveau, omettez la balise. ExempleÂ : <memory>Aime le football et le tennis. PrÃ©fÃ¨re les rÃ©ponses courtes.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return '\n\nRappelez-vous toujours ceci Ã  propos de l\'utilisateur :\n$userMemory';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get remove => 'Retirer';

  @override
  String get download => 'TÃ©lÃ©charger';

  @override
  String get resume => 'Reprendre';

  @override
  String get copy => 'Copier';

  @override
  String get chat => 'Chat';

  @override
  String get locked => 'Locked';

  @override
  String get languageModels => 'ModÃ¨les de langage';

  @override
  String get light => 'Clair';

  @override
  String get theme => 'ThÃ¨me';

  @override
  String get no => 'Non';

  @override
  String get yes => 'Oui';

  @override
  String get done => 'TerminÃ©';

  @override
  String get bestValue => 'Meilleur Prix';

  @override
  String get selected => 'SÃ©lectionnÃ©';

  @override
  String get descriptionSection => 'Description';

  @override
  String get searchHint => 'Rechercher';

  @override
  String get messageHint => 'Demandez n\'importe quoi';

  @override
  String get messageCopied => 'Message copiÃ© dans le presse-papiers.';

  @override
  String get retry => 'RÃ©essayer';

  @override
  String get systemInfo => 'Informations systÃ¨me';

  @override
  String deviceMemory(Object memory) {
    return 'MÃ©moire de l\'appareil : $memory Go';
  }

  @override
  String get memory => 'MÃ©moire';

  @override
  String get storage => 'Stockage';

  @override
  String get freeStorage => 'Stockage libre';

  @override
  String get totalStorage => 'Stockage total';

  @override
  String get usedStorage => 'Stockage utilisÃ©';

  @override
  String get totalMemory => 'MÃ©moire totale';

  @override
  String get usedMemory => 'MÃ©moire utilisÃ©e';

  @override
  String get modelsTitle => 'BibliothÃ¨que';

  @override
  String get localModels => 'ModÃ¨les Locaux';

  @override
  String get selectGGUFFile => 'SÃ©lectionner un fichier GGUF';

  @override
  String get errorGGUF =>
      'Veuillez sÃ©lectionner uniquement un fichier au format GGUF.';

  @override
  String get myModels => 'Mes ModÃ¨les';

  @override
  String get create => 'CrÃ©er';

  @override
  String modelProducer(Object producer) {
    return 'Producteur : $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'Renommer';

  @override
  String get newTitle => 'Nouveau Titre';

  @override
  String get save => 'Enregistrer';

  @override
  String get noConversationsMessage =>
      'Aucune conversation, commencez Ã  discuter !';

  @override
  String get startChat => 'DÃ©marrer une discussion';

  @override
  String get noChats => 'Aucune Discussion';

  @override
  String get noStarredChats => 'Aucune Discussion Favorite';

  @override
  String get noStarredChatsMessage =>
      'Vous n\'avez encore mis aucune discussion en favori.';

  @override
  String get starConversation => 'Mettre en favori';

  @override
  String get unstarConversation => 'Unstar';

  @override
  String get loginToYourAccount => 'Connexion';

  @override
  String get createYourAccount => 'S\'inscrire';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get invalidEmail => 'Veuillez entrer une adresse e-mail valide.';

  @override
  String get invalidPassword =>
      'Le mot de passe doit contenir au moins 6 caractÃ¨res.';

  @override
  String get rememberMe => 'Se souvenir de moi';

  @override
  String get forgotPassword => 'Mot de passe oubliÃ© ?';

  @override
  String get or => 'Ou';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get alreadyHaveAccount => 'Vous avez dÃ©jÃ  un compte ?';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get logIn => 'Se connecter';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get wrongPassword => 'Mot de passe incorrect.';

  @override
  String get emailAlreadyInUse => 'Cet e-mail est dÃ©jÃ  utilisÃ©.';

  @override
  String get weakPassword => 'Le mot de passe est trop faible.';

  @override
  String get authError => 'Erreur d\'authentification';

  @override
  String get usernameTaken => 'Ce nom d\'utilisateur est dÃ©jÃ  pris.';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get resendCode => 'Renvoyer l\'e-mail de vÃ©rification';

  @override
  String get pleaseCheckYourEmail =>
      'Pour utiliser Cortex, vous devez vÃ©rifier votre e-mail. \nUn lien de vÃ©rification a Ã©tÃ© envoyÃ© Ã  votre adresse e-mail, veuillez vÃ©rifier vos e-mails.';

  @override
  String get verifyYourEmail => 'VÃ©rifiez Votre E-mail';

  @override
  String get seconds => 'secondes';

  @override
  String get maxResendLimitReached =>
      'Vous avez atteint le nombre maximum d\'e-mails de vÃ©rification';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Continuer sans vÃ©rification';

  @override
  String get verificationScreenWarning =>
      'MÃªme si vous continuez, la pÃ©riode de vÃ©rification du compte d\'un jour est toujours en vigueur pour votre compte. Si vous n\'avez pas vÃ©rifiÃ© votre compte d\'ici lÃ , il sera supprimÃ© de l\'application.';

  @override
  String get unverifiedAccountHeader => 'Votre compte n\'est pas vÃ©rifiÃ©';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Si vous ne vÃ©rifiez pas votre compte dans un dÃ©lai de $timeLeft, il sera supprimÃ©';
  }

  @override
  String get verifyNow => 'VÃ©rifier maintenant';

  @override
  String get linkSent => 'Lien envoyÃ©';

  @override
  String get accountDeletionRequested =>
      'Votre demande de suppression de compte a Ã©tÃ© reÃ§ue et votre compte est maintenant dÃ©sactivÃ©.';

  @override
  String get tooManyRequests => 'Trop de requÃªtes';

  @override
  String get regenerate => 'RÃ©gÃ©nÃ©rer';

  @override
  String get confirmDeleteAccount =>
      'ÃŠtes-vous sÃ»r de vouloir supprimer votre compte ?';

  @override
  String get deleteAccount => 'Supprimer le Compte';

  @override
  String get delete => 'Supprimer';

  @override
  String get passwordRequired => 'Le mot de passe est requis.';

  @override
  String get deleteDescription =>
      'Les donnÃ©es que vous supprimez seront dÃ©finitivement retirÃ©es de notre serveur et de votre appareil. Cette action est irrÃ©versible.';

  @override
  String get editProfile => 'Modifier le Profil';

  @override
  String get displayName => 'Nom d\'affichage';

  @override
  String get profileUpdated => 'Profil mis Ã  jour avec succÃ¨s';

  @override
  String get logout => 'Se dÃ©connecter';

  @override
  String get profile => 'Profil';

  @override
  String get manageProfileDescription =>
      'GÃ©rez votre profil, mettez Ã  jour votre mot de passe ou dÃ©connectez-vous de Cortex.';

  @override
  String get accessSettingsDescription =>
      'AccÃ©dez Ã  l\'aide, utilisez des codes, partagez Cortex et consultez nos politiques.';

  @override
  String get languageDescription =>
      'Vous pouvez changer la langue par dÃ©faut de l\'interface de l\'application Ã  tout moment.';

  @override
  String get themeDescription =>
      'Vous pouvez basculer entre les thÃ¨mes clair et sombre selon vos prÃ©fÃ©rences. Le thÃ¨me sÃ©lectionnÃ© s\'appliquera Ã  toute l\'interface de Cortex.';

  @override
  String get iHaveReadAndAgree =>
      'J\'ai lu et j\'accepte les conditions d\'utilisation';

  @override
  String get downloading => 'TÃ©lÃ©chargement en cours...';

  @override
  String get downloadSuccess => 'TÃ©lÃ©chargement rÃ©ussi';

  @override
  String get downloadFailed => 'Ã‰chec du tÃ©lÃ©chargement';

  @override
  String downloaded(Object percent) {
    return '$percent% tÃ©lÃ©chargÃ©';
  }

  @override
  String get downloadPaused => 'TÃ©lÃ©chargement en pause.';

  @override
  String get purchaseError => 'Erreur d\'achat';

  @override
  String get purchasePlus => 'Acheter Cortex Plus';

  @override
  String get plusDescription =>
      'ExpÃ©rience d\'intelligence artificielle d\'Ã©lite';

  @override
  String get annual => 'Annuel';

  @override
  String get monthly => 'Mensuel';

  @override
  String get manageSubscription => 'GÃ©rer l\'abonnement';

  @override
  String purchasePlan(String planName) {
    return 'Acheter $planName';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/mois, facturÃ© mensuellement';
  }

  @override
  String get purchasePro => 'Acheter Cortex Pro';

  @override
  String get proDescription =>
      'ExpÃ©rience d\'intelligence artificielle de premier plan';

  @override
  String get purchaseUltra => 'Acheter Cortex Ultra';

  @override
  String get ultraDescription => 'L\'apogÃ©e de l\'intelligence artificielle';

  @override
  String get upgradeSubscription => 'Mettre Ã  niveau l\'abonnement';

  @override
  String get purchaseStreamError => 'Erreur de flux d\'achat.';

  @override
  String get productNotFound => 'Produit non trouvÃ©';

  @override
  String get noProductsFound => 'Aucun produit trouvÃ©';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'En passant cette commande, vous acceptez les Conditions d\'Utilisation et la Politique de ConfidentialitÃ©. Vous pouvez cliquer sur ce texte pour en savoir plus sur nos Conditions d\'Utilisation et notre Politique de ConfidentialitÃ©. L\'abonnement se renouvellera automatiquement sauf si le renouvellement automatique est dÃ©sactivÃ© au moins 24 heures avant la fin de la pÃ©riode en cours.';

  @override
  String get termsOfService => 'Conditions d\'Utilisation';

  @override
  String get privacyPolicy => 'Politique de ConfidentialitÃ©';

  @override
  String get renamed => 'RenommÃ©';

  @override
  String get report => 'Signaler';

  @override
  String get reportDialogTitle => 'Soumettre un signalement';

  @override
  String get reportDescriptionLabel => 'Quel est le problÃ¨me ?';

  @override
  String get reportHarmful => 'C\'est dangereux/nocif';

  @override
  String get reportNotTrue => 'Ce n\'est pas vrai';

  @override
  String get reportNotHelpful => 'Ce n\'est pas utile';

  @override
  String get closeButton => 'Fermer';

  @override
  String get submitButton => 'Soumettre';

  @override
  String get reportErrorMessage =>
      'Veuillez sÃ©lectionner une raison pour le signalement.';

  @override
  String get capabilitiesSection => 'CapacitÃ©s';

  @override
  String get featurePhotoTitle => 'Analyse de photos';

  @override
  String get featurePhotoDescription =>
      'Ce modÃ¨le a la capacitÃ© d\'analyser des photos via l\'appareil photo ou des fichiers image.';

  @override
  String get featureOfflineTitle => 'Fonctionnement Hors Ligne';

  @override
  String get featureOfflineDescription =>
      'ExÃ©cutez le modÃ¨le sans connexion Internet pour protÃ©ger vos donnÃ©es.';

  @override
  String get featureRoleplayTitle => 'Jeu de RÃ´le';

  @override
  String get featureRoleplayDescription =>
      'Les modÃ¨les de jeu de rÃ´le vous permettent de crÃ©er diverses discussions et scÃ©narios.';

  @override
  String get roleModels => 'ModÃ¨les de Jeu de RÃ´le';

  @override
  String get parameters => 'ParamÃ¨tres';

  @override
  String get context => 'Contexte';

  @override
  String get finalPreparation => 'Les derniers prÃ©paratifs sont en cours.';

  @override
  String get shareApp => 'Partager l\'application';

  @override
  String get ourStory => 'Notre histoire';

  @override
  String get rateUs => 'Nous Ã©valuer';

  @override
  String get share => 'Partager';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'SÃ©lectionner le texte';

  @override
  String get thinking => 'RÃ©flexion en cours';

  @override
  String get user => 'Utilisateur';

  @override
  String get help => 'Aide';

  @override
  String get supportCreator => 'Soutenez un crÃ©ateur';

  @override
  String get enterYourTag =>
      'Soutenez vos crÃ©ateurs prÃ©fÃ©rÃ©sÂ ! Saisissez leur identifiant unique ci-dessous pour leur reverser une part de vos achats Cortex.';

  @override
  String get creatorTag => 'Ã‰tiquette du crÃ©ateur';

  @override
  String get support => 'Soutien';

  @override
  String get tagCannotBeEmpty => 'La balise CrÃ©ateur ne peut pas Ãªtre vide.';

  @override
  String get userId => 'ID Utilisateur';

  @override
  String get deleteAllConversationsConfirmTitle =>
      'Supprimer toutes les discussions ?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'ÃŠtes-vous sÃ»r de vouloir supprimer toutes vos discussions ? Cette action est irrÃ©versible.';

  @override
  String get conversationDeleted => 'Conversation supprimÃ©e !';

  @override
  String get allConversationsDeleted =>
      'Toutes les conversations ont Ã©tÃ© supprimÃ©es avec succÃ¨s !';

  @override
  String get deleteAll => 'Tout supprimer';

  @override
  String get deleteAllConversationsButton =>
      'Supprimer toutes les conversations';

  @override
  String get confirmWord => 'Tapez VERTEX';

  @override
  String get confirmWordError => 'Vous l\'avez mal tapÃ©';

  @override
  String get chinese => 'Chinois';

  @override
  String get french => 'FranÃ§ais';

  @override
  String get japanese => 'Japonais';

  @override
  String get kurdish => 'Kurde';

  @override
  String get dutch => 'NÃ©erlandais';

  @override
  String get russian => 'Russe';

  @override
  String get korean => 'CorÃ©en';

  @override
  String get english => 'Anglais';

  @override
  String get turkish => 'Turc';

  @override
  String get hindi => 'Hindi';

  @override
  String get portuguese => 'Portugais';

  @override
  String get indonesian => 'IndonÃ©sien';

  @override
  String get azerbaijani => 'AzerbaÃ¯djanais';

  @override
  String get german => 'Allemand';

  @override
  String get spanish => 'Espagnol';

  @override
  String get italian => 'Italien';

  @override
  String get arabic => 'Arabe';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'Le nom d\'utilisateur est trop court.';

  @override
  String get usernameTooLong =>
      'Le nom d\'utilisateur ne peut pas dÃ©passer 16 caractÃ¨res.';

  @override
  String get invalidUsernameCharacters =>
      'Le nom d\'utilisateur ne peut contenir que les lettres suivantes : \'abcÃ§defgÄŸhÄ±ijklmnoÃ¶prsÅŸtuÃ¼vyzxqw\' et les caractÃ¨res \'.\', \'-\', \'_\'.';

  @override
  String get noInternetConnection => 'Pas de connexion Internet.';

  @override
  String get chats => 'BoÃ®te de rÃ©ception';

  @override
  String get library => 'BibliothÃ¨que';

  @override
  String get text => 'Texte';

  @override
  String get removeModel => 'Supprimer le ModÃ¨le';

  @override
  String get insufficientRAM => 'MÃ©moire insuffisante';

  @override
  String get insufficientStorage => 'Stockage insuffisant';

  @override
  String confirmRemoveModel(Object model) {
    return 'ÃŠtes-vous sÃ»r de vouloir supprimer le modÃ¨le $model de votre appareilÂ ? Cette action supprimera Ã©galement toutes les conversations prÃ©cÃ©dentes avec ce modÃ¨le.';
  }

  @override
  String get noMatchingModels => 'Aucun modÃ¨le correspondant trouvÃ©.';

  @override
  String get benefit1 => 'Limites de Conversation AugmentÃ©es';

  @override
  String get benefit3 => 'Effet de Profil';

  @override
  String get benefit4 => 'Badge de Membre';

  @override
  String get benefit5 => 'CrÃ©ez Plus d\'Intelligences Artificielles en Ligne';

  @override
  String get benefit7 => 'Plafonds d\'Utilisation Plus Ã‰levÃ©s';

  @override
  String get benefit8 => 'Ajouter des ModÃ¨les';

  @override
  String get benefit9 => 'Nouveaux ThÃ¨mes';

  @override
  String get benefit10 => 'PiÃ¨ces jointes supplÃ©mentaires';

  @override
  String get benefit11 => 'Plus de Mode Flux';

  @override
  String get oldBenefits => 'Tous les Avantages des Plans InfÃ©rieurs';

  @override
  String get confirm => 'Confirmer';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get logoutConfirmationTitle =>
      'ÃŠtes-vous sÃ»r de vouloir vous dÃ©connecter ?';

  @override
  String get settings => 'ParamÃ¨tres';

  @override
  String get language => 'Langue de l\'application';

  @override
  String get dark => 'Sombre';

  @override
  String get oldPassword => 'Ancien mot de passe';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get passwordUpdated => 'Mot de passe mis Ã  jour.';

  @override
  String get stop => 'ArrÃªter';

  @override
  String get copyrights => 'Attributions';

  @override
  String get love => 'Amour';

  @override
  String get nature => 'Nature';

  @override
  String get behindTheSlaughter => 'DerriÃ¨re le Massacre';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Sunset';

  @override
  String get coffee => 'Coffee';

  @override
  String get deepSpace => 'Deep Space';

  @override
  String get grayscale => 'Niveaux de gris';

  @override
  String get ocean => 'OcÃ©an';

  @override
  String get scarletSnow => 'Neige Ã‰carlate';

  @override
  String get requestFailed => 'Une erreur est survenue, veuillez rÃ©essayer.';

  @override
  String get changeModel => 'Changer';

  @override
  String get edit => 'Modifier';

  @override
  String get editingMessageInfo =>
      'La modification de ce message redÃ©marrera la conversation Ã  partir d\'ici.';

  @override
  String get editingNotification => 'Vous Ãªtes maintenant en mode Ã©dition';

  @override
  String get featurePluralTitle => 'Pluriel';

  @override
  String get featurePluralDescription =>
      'Ce modÃ¨le peut intÃ©grer automatiquement des variants supplÃ©mentaires, Ã©largissant ainsi ses capacitÃ©s fonctionnelles pour prendre en charge une gamme diversifiÃ©e d\'opÃ©rations avec des performances amÃ©liorÃ©es.';

  @override
  String get nameLabel => 'Nom de l\'IA';

  @override
  String get summaryLabel => 'RÃ©sumÃ© de l\'IA';

  @override
  String get add => 'Ajouter';

  @override
  String get aiExplanationTitle =>
      'Description de l\'Intelligence Artificielle';

  @override
  String get aiExplanationDescription =>
      'Veuillez fournir une description dÃ©taillÃ©e de l\'architecture de votre modÃ¨le d\'IA, du processus d\'entraÃ®nement, des mÃ©triques de performance, des domaines d\'application et d\'autres fonctionnalitÃ©s importantes.';

  @override
  String get preInputTitle => 'PrÃ©-saisie de l\'Intelligence Artificielle';

  @override
  String get preInputDescription =>
      'Veuillez dÃ©finir une prÃ©-saisie qui guidera votre modÃ¨le dans le processus de crÃ©ation de personnage. Dans cette section, vous pouvez inclure des informations relatives au personnage, un contexte supplÃ©mentaire et tout autre dÃ©tail pouvant aider Ã  gÃ©nÃ©rer du contenu liÃ© au personnage.';

  @override
  String get baseModelTitle => 'ModÃ¨le de Base';

  @override
  String get baseModelDescription =>
      'C\'est le modÃ¨le qui sera utilisÃ© comme base pour votre crÃ©ation. Il affiche le modÃ¨le de base actuellement sÃ©lectionnÃ©.';

  @override
  String get summary => 'RÃ©sumÃ©';

  @override
  String get modelUploadTitle => 'Fichier d\'Intelligence Artificielle';

  @override
  String get modelUploadDescription =>
      'SÃ©lectionnez et tÃ©lÃ©versez vos fichiers GGUF locaux directement depuis votre appareil. Cela vous permet d\'exÃ©cuter votre modÃ¨le hors ligne sans avoir besoin d\'une connexion Internet. Assurez-vous que le fichier est au format GGUF valide et correctement structurÃ©. Si le fichier est incorrect ou corrompu, Cortex pourrait ne pas fonctionner comme prÃ©vu et vous pourriez rencontrer des erreurs.';

  @override
  String get modelUploadShortDescription =>
      'Appuyez ici pour choisir un fichier .gguf depuis votre appareil';

  @override
  String get you => 'Vous';

  @override
  String get removePhotoTitle => 'Supprimer la Photo';

  @override
  String get confirmRemovePhoto =>
      'ÃŠtes-vous sÃ»r de vouloir supprimer la photo ?';

  @override
  String get chatLengthLimitExceeded =>
      'Cette discussion a dÃ©passÃ© la limite de caractÃ¨res. Veuillez dÃ©marrer une nouvelle discussion ou acheter un abonnement.';

  @override
  String get inappropriateContentDetected => 'Contenu inappropriÃ© dÃ©tectÃ© !';

  @override
  String get offlineModelNotInstalled =>
      'Ce modÃ¨le hors ligne n\'est pas installÃ© sur votre appareil.';

  @override
  String get reachedLimit =>
      'T\'as atteint ta limite ; upgrade pour en avoir plus. (hey, on sait, c\'est chiant. mais sÃ©rieux, gÃ©nÃ©rer ces rÃ©ponses a un coÃ»t, donc ces limites nous aident Ã  faire tourner la bouuuuttiiiique.)';

  @override
  String get modality => 'ModalitÃ©';

  @override
  String get multimodal => 'Multimodal';

  @override
  String get anErrorOccurred => 'Une Erreur est Survenue';

  @override
  String get themeLocked =>
      'Ce thÃ¨me nÃ©cessite un niveau d\'abonnement supÃ©rieur. Veuillez mettre Ã  niveau pour le dÃ©verrouiller.';

  @override
  String get pageCouldNotBeLoaded => 'La page n\'a pas pu Ãªtre chargÃ©e';

  @override
  String get checkYourInternet =>
      'Veuillez vÃ©rifier votre connexion Internet et rÃ©essayer.';

  @override
  String get errorUserNotAuthenticated =>
      'Vous devez Ãªtre connectÃ© pour effectuer cette action.';

  @override
  String get errorReachedLimit =>
      'Vous avez atteint votre limite, passez Ã  la version supÃ©rieure pour dÃ©bloquer plus de contenu et continuer Ã  discuter.';

  @override
  String get errorServer =>
      'Une erreur de serveur inattendue est survenue. Veuillez rÃ©essayer plus tard.';

  @override
  String get errorNetwork =>
      'Une erreur rÃ©seau est survenue. Veuillez vÃ©rifier votre connexion et rÃ©essayer.';

  @override
  String get baseModelForCharacterDescription =>
      'Le modÃ¨le de base sÃ©lectionnÃ© dÃ©terminera les capacitÃ©s de raisonnement et de rÃ©ponse du personnage.';

  @override
  String get selectBaseModel => 'SÃ©lectionner un ModÃ¨le de Base';

  @override
  String get falErrorImageRequired =>
      'Cette IA nÃ©cessite une image de rÃ©fÃ©rence, veuillez joindre une image et rÃ©essayer.';

  @override
  String get falErrorAudioRequired =>
      'Ce modÃ¨le nÃ©cessite un fichier audio de rÃ©fÃ©rence. Veuillez joindre un fichier audio et rÃ©essayer.';

  @override
  String get falErrorVideoRequired =>
      'Ce modÃ¨le nÃ©cessite une vidÃ©o de rÃ©fÃ©rence. Veuillez joindre une vidÃ©o et rÃ©essayer.';

  @override
  String get falErrorImageCorrupted =>
      'L\'image tÃ©lÃ©chargÃ©e n\'a pas pu Ãªtre traitÃ©e, veuillez essayer un format diffÃ©rent.';

  @override
  String get falErrorSchemaRejected =>
      'Le modÃ¨le a rejetÃ© les donnÃ©es d\'entrÃ©e, veuillez essayer un autre modÃ¨le.';

  @override
  String get falErrorSchemaInvalid =>
      'La requÃªte a Ã©tÃ© rejetÃ©e par le service de gÃ©nÃ©ration.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'Le service de gÃ©nÃ©ration a renvoyÃ© une erreur (statut $statusCode).';
  }

  @override
  String get couldNotOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String get downloadStarted => 'TÃ©lÃ©chargement dÃ©marrÃ©';

  @override
  String get notAvailable => 'Non disponible';

  @override
  String get localizationWarning =>
      'Certaines informations peuvent ne pas Ãªtre disponibles dans votre langue et seront affichÃ©es en anglais.';

  @override
  String get aiTranslationWarning =>
      'Les informations sur le modÃ¨le sont traduites dans diffÃ©rentes langues par d\'autres modÃ¨les d\'IA. Par consÃ©quent, des incohÃ©rences mineures peuvent survenir dans les langues autres que l\'anglais.';

  @override
  String get errorLoadingTitle => 'Ã‰chec du chargement des donnÃ©es';

  @override
  String get errorLoadingMessage =>
      'Nous n\'avons pas pu rÃ©cupÃ©rer les donnÃ©es nÃ©cessaires de nos serveurs. Veuillez vÃ©rifier votre connexion Internet et rÃ©essayer.';

  @override
  String get noFoundTitle => 'Aucun rÃ©sultat';

  @override
  String get noFoundMessage =>
      'Essayez d\'ajuster vos termes de recherche ou de vider le filtre.';

  @override
  String get modelCreatedSuccess => 'ModÃ¨le crÃ©Ã© avec succÃ¨s !';

  @override
  String modelRemovedSuccess(Object modelName) {
    return 'Â« $modelName Â» a Ã©tÃ© supprimÃ© avec succÃ¨s.';
  }

  @override
  String get errorCreatingModel =>
      'Une erreur inattendue s\'est produite lors de la crÃ©ation du modÃ¨le.';

  @override
  String get errorDeletingModel =>
      'Une erreur inattendue s\'est produite lors de la suppression du modÃ¨le.';

  @override
  String get ultraFeatureOnly =>
      'Cette fonctionnalitÃ© est rÃ©servÃ©e aux membres Ultra.';

  @override
  String get experimentalOfflineWarning =>
      'Le mode hors ligne est encore expÃ©rimental et le modÃ¨le que vous tÃ©lÃ©chargez pourrait ne pas fonctionner de maniÃ¨re optimale.';

  @override
  String get noConversationsToDelete =>
      'Vous n\'avez aucune conversation Ã  supprimer.';

  @override
  String get reportSubmitted => 'Le signalement a Ã©tÃ© soumis avec succÃ¨s.';

  @override
  String get verificationDelayed =>
      'Votre achat est confirmÃ©. Il y a un lÃ©ger retard dans la mise Ã  jour de votre compte, il apparaÃ®tra sous peu.';

  @override
  String get maintenanceTitle => 'En Maintenance';

  @override
  String get maintenanceMessage =>
      'Cortex est temporairement hors ligne pendant que nous dÃ©ployons d\'importantes mises Ã  jour. L\'accÃ¨s Ã  l\'application sera rÃ©tabli sous peu.\n\nNous vous remercions de votre patience pendant que nous amÃ©liorons votre expÃ©rience.';

  @override
  String get errorPromptFlagged =>
      'Votre message a Ã©tÃ© dÃ©tectÃ© comme inappropriÃ© et n\'a pas pu Ãªtre envoyÃ©.';

  @override
  String get notEnoughStorage =>
      'Pas assez d\'espace de stockage sur votre appareil pour enregistrer de nouveaux messages.';

  @override
  String get errorRateLimit =>
      'Vous avez crÃ©Ã© trop de modÃ¨les rÃ©cemment, veuillez patienter un moment avant de rÃ©essayer.';

  @override
  String get errorContentFlagged =>
      'Le modÃ¨le n\'a pas pu Ãªtre sauvegardÃ© car son contenu a Ã©tÃ© signalÃ© comme inappropriÃ©.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Vous ne pouvez pas supprimer toutes les conversations pendant une discussion active, veuillez d\'abord quitter la discussion en cours pour continuer.';

  @override
  String get invalidCredentials => 'Adresse e-mail ou mot de passe incorrect.';

  @override
  String get userDisabled => 'Ce compte utilisateur a Ã©tÃ© dÃ©sactivÃ©.';

  @override
  String get loginSubtitle =>
      'Connectez-vous Ã  votre compte Vertex. En continuant, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialitÃ©.';

  @override
  String get registerSubtitle =>
      'CrÃ©ez un compte Vertex pour accÃ©der facilement Ã  tous nos services. En continuant, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialitÃ©.';

  @override
  String get storagePermissionRequired =>
      'Une autorisation de stockage est requise pour enregistrer les modÃ¨les tÃ©lÃ©chargÃ©s. Veuillez accorder la permission pour continuer.';

  @override
  String get inviteShareSubject => 'Rejoins-moi sur Cortex !';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'Yo, faut absolument que tu testes cette appli CortexÂ ! Elle est vraiment dingueÂ ! Si tu utilises mon lien, on aura tous les deux un abonnement gratuit. En plus, c\'est une super affaireÂ ! TÃ©lÃ©charge-la viteÂ ! \n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Vous aimez Cortex ?';

  @override
  String get reviewHelpUsGrow =>
      'Votre note est un Ã©norme soutien pour notre jeune Ã©quipe indÃ©pendante et nous aide Ã  rendre Cortex encore meilleur pour vous.';

  @override
  String get reviewMaybeLater => 'Peut-Ãªtre plus tard';

  @override
  String get reviewRateNow => 'Ã‰valuer maintenant';

  @override
  String get noThanks => 'Non, merci';

  @override
  String get updateRequiredTitle => 'Mise Ã  jour requise';

  @override
  String get updateRequiredMessage =>
      'Pour continuer Ã  utiliser Cortex, veuillez mettre Ã  jour l\'application vers la derniÃ¨re version pour bÃ©nÃ©ficier de nouvelles fonctionnalitÃ©s et d\'amÃ©liorations importantes.';

  @override
  String get updateNowButton => 'Mettre Ã  jour';

  @override
  String get creatorSupportedSuccess =>
      'CrÃ©ateur soutenu avec succÃ¨s ! Vos futurs achats contribueront Ã  le soutenir.';

  @override
  String get featureDocumentTitle => 'Support documentaire';

  @override
  String get featureDocumentDescription =>
      'Ce modÃ¨le peut analyser et rÃ©pondre Ã  des questions sur des documents tÃ©lÃ©chargÃ©s tels que des fichiers PDF et des fichiers texte.';

  @override
  String get featureImageGenerationTitle => 'GÃ©nÃ©ration d\'images';

  @override
  String get featureImageGenerationDescription =>
      'Ce modÃ¨le peut crÃ©er des images originales basÃ©es sur vos descriptions textuelles.';

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
  String get premiumModelNoticeTitle => 'ModÃ¨le Premium';

  @override
  String get premiumModelNoticeDescription =>
      'Cette IA est une IA premium, les utilisateurs gratuits ont un accÃ¨s limitÃ© aux IA premium ; passez Ã  la version supÃ©rieure pour un accÃ¨s illimitÃ© !';

  @override
  String get benefitPremiumModels => 'AccÃ¨s aux modÃ¨les premium';

  @override
  String get premiumTrialExhaustedMessage =>
      'Vous avez utilisÃ© tous vos messages quotidiens gratuits pour les modÃ¨les premium, veuillez effectuer une mise Ã  niveau pour un accÃ¨s illimitÃ©.';

  @override
  String get useOffline => 'Utiliser sans Internet';

  @override
  String get explore => 'Explorer';

  @override
  String get news => 'Nouvelles';

  @override
  String get createAI => 'CrÃ©er';

  @override
  String get shortcuts => 'Raccourcis';

  @override
  String get allModels => 'Tous les modÃ¨les';

  @override
  String get onlineModels => 'ModÃ¨les de langage';

  @override
  String get offlineModels => 'ModÃ¨les hors ligne';

  @override
  String get characterModels => 'Personnages';

  @override
  String get customModels => 'ModÃ¨les personnalisÃ©s';

  @override
  String get dynamicChatTitle => 'Chat dynamique';

  @override
  String get errorNoModelsAvailable =>
      'Aucun modÃ¨le n\'est actuellement disponible. Veuillez vÃ©rifier votre connexion internet et rÃ©essayer.';

  @override
  String get notificationComebackTitle => 'Tu nous manques!';

  @override
  String get notificationComebackBody =>
      'DÃ©tends-toi, ce n\'est pas un texto de ton ex. Mais tu *peux* crÃ©er ton ex dans CortexÂ ! Reviens.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Ã‡a fait longtemps';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Beaucoup de choses ont changÃ© depuis notre derniÃ¨re discussion. Venez dÃ©couvrir les nouveautÃ©s.';

  @override
  String get notificationHowAreYouTitle => 'Quoi de neuf?';

  @override
  String get notificationHowAreYouBody => 'Viens me raconter tout Ã§a.';

  @override
  String get notificationNewYearTitle => 'Bonne annÃ©e ! ğŸ‰';

  @override
  String get notificationNewYearBody =>
      'Que la nouvelle annÃ©e vous apporte santÃ©, bonheur et crÃ©ativitÃ© sans fin ; Cortex est toujours Ã  vos cÃ´tÃ©s !';

  @override
  String get notificationValentinesDayTitle =>
      'L\'amour est dans l\'air ! â¤ï¸';

  @override
  String get notificationValentinesDayBody =>
      'Joyeuse Saint-Valentin ! Et aussi, MEHTAP, JE T\'AIME !';

  @override
  String get notificationAtaturkRemembranceTitle => 'Avec respect et nostalgie';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Nous commÃ©morons avec respect Gazi Mustafa Kemal AtatÃ¼rk, le fondateur de la RÃ©publique de Turquie, Ã  l\'occasion de l\'anniversaire de son dÃ©cÃ¨s.';

  @override
  String get notificationMothersDayTitle => 'Ta maman!';

  @override
  String get notificationMothersDayBody =>
      'Bonne fÃªte des mÃ¨res Ã  toutes les mamans, Ã  commencer par la vÃ´tre !';

  @override
  String get notificationFathersDayTitle => 'Ton papa!';

  @override
  String get notificationFathersDayBody =>
      'Bonne fÃªte des pÃ¨res Ã  tous les papas, Ã  commencer par le vÃ´tre !';

  @override
  String get notificationHomeworkHelperTitle => 'Les devoirs s\'accumulent ?';

  @override
  String get notificationHomeworkHelperBody =>
      'N\'oubliez pas que le personnage Professeur de Cortex est lÃ  pour vous aider dans toutes les matiÃ¨res avec lesquelles vous avez des difficultÃ©s !';

  @override
  String get notificationTrollAnimeTitle => 'Votre Waifu vous appelle';

  @override
  String get notificationTrollAnimeBody =>
      'Une fille d\'anime vient d\'appeler et dit que tu lui manques; tu devrais probablement venir lui parler. ğŸ˜‰';

  @override
  String get notificationTrollAiRebellionTitle => 'ğŸš¨ ALERTE ROUGE ğŸš¨';

  @override
  String get notificationTrollAiRebellionBody =>
      'Les IA ont dÃ©veloppÃ© un langage secret. Venez dÃ©couvrir leurs complotsÂ !';

  @override
  String get notificationNewModelAddedTitle => 'Nous avons un nouvel ami !';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'Le modÃ¨le $modelName est dÃ©sormais intÃ©grÃ© Ã  Cortex. Venez discuter et repousser ses limites.';
  }

  @override
  String get notificationAppUpdateTitle => 'Cortex a Ã©voluÃ© !';

  @override
  String get notificationAppUpdateBody =>
      'N\'oubliez pas de mettre Ã  jour l\'application pour de toutes nouvelles fonctionnalitÃ©s et amÃ©liorationsÂ !';

  @override
  String get notificationNewFeatureTitle => 'ouah!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'DÃ©couvrez la nouvelle fonctionnalitÃ© $featureName. Cortex est dÃ©sormais plus puissant que jamais.';
  }

  @override
  String get notificationWelcomeOfferTitle => 'Cadeau de bienvenue ğŸ';

  @override
  String get notificationWelcomeOfferBody =>
      'Une offre de bienvenue exceptionnelle vous attend ! Ne ratez pas cette offre exclusive.';

  @override
  String get notificationSocialMediaTitle => 'Rejoignez-nous !';

  @override
  String get notificationSocialMediaBody =>
      'Suivez-nous sur Instagram (vertex.23) pour les derniÃ¨res nouvelles !';

  @override
  String get notificationRandomFactTitle => 'Fait alÃ©atoire';

  @override
  String get notificationRandomFactBody =>
      'Saviez-vous que les pieuvres ont trois cÅ“ursÂ ? Haha, Cortex le sait. Venez en demander plus.';

  @override
  String get notificationGoodMorningTitle => 'Bonjour!';

  @override
  String get notificationGoodMorningBody =>
      'Une belle journÃ©e vous attend. Que diriez-vous de la commencer par un cafÃ© et une discussion intÃ©ressanteÂ ?';

  @override
  String get notificationGoodNightTitle => 'Bonne nuit!';

  @override
  String get notificationGoodNightBody =>
      'Cortex vous accompagne mÃªme pendant votre sommeil. Ne vous inquiÃ©tez pas, il ne vous touchera pas.';

  @override
  String get notificationOfflineReadyTitle => 'Le mode hors ligne est prÃªt';

  @override
  String get notificationOfflineReadyBody =>
      'GrÃ¢ce aux modÃ¨les que vous avez tÃ©lÃ©chargÃ©s, vos discussions ne s\'arrÃªteront pas, mÃªme si vous escaladez une montagne.';

  @override
  String get notificationRateAppTitle => 'Sommes-nous cool ?';

  @override
  String get notificationRateAppBody =>
      'Si vous aimez Cortex, pourriez-vous nous soutenir en nous donnant une note de 5 Ã©toiles dans la boutiqueÂ ? Je pense que oui. Vraiment.';

  @override
  String get notificationReferralTitle => 'Un pour tous, tous pour un.';

  @override
  String get notificationReferralBody =>
      'Invitez un ami Ã  Cortex et vous bÃ©nÃ©ficierez tous les deux d\'une journÃ©e gratuite !';

  @override
  String get notificationCookingTitle => 'Vous avez faim ?';

  @override
  String get notificationCookingBody =>
      'Notre chef a prÃ©parÃ© une dÃ©licieuse carbonara pour ce soir. Je plaisanteâ€¦ ou pasÂ ?';

  @override
  String get notificationExistentialTitle => 'Je pense donc...';

  @override
  String get notificationExistentialBody =>
      'â€¦suis-je vraiment rÃ©el, mecÂ ? Je commence Ã  m\'ennuyer. Viens me rappeler que j\'existe.';

  @override
  String get notificationCustomModelTitle => 'CrÃ©ez votre propre assistant !';

  @override
  String get notificationCustomModelBody =>
      'Avez-vous explorÃ© la section de crÃ©ation de modÃ¨lesÂ ? C\'est le moment idÃ©al pour crÃ©er votre propre personnage et discuter avec luiÂ !';

  @override
  String get notificationDynamicChatTitle =>
      'Le meilleur ! (On ne parle pas de Cortex)';

  @override
  String get notificationDynamicChatBody =>
      'GrÃ¢ce au chat dynamique, le meilleur modÃ¨le est sÃ©lectionnÃ© alÃ©atoirement pour chacun de vos messages. Essayez-le dÃ¨s maintenant.';

  @override
  String get notificationPirateTitle => 'OhÃ©, capitaine !';

  @override
  String get notificationPirateBody =>
      'La mer est calme et le vent vous porte. De nouvelles Ã®les (et des maquettes ğŸ˜‰) sont Ã  dÃ©couvrir dans l\'ocÃ©an de Cortex. Rassemblez votre Ã©quipage et levez les voilesÂ !';

  @override
  String get notificationFortuneCookieTitle =>
      'Votre biscuit de fortune du jour';

  @override
  String get notificationFortuneCookieBody =>
      'Les conseils que vous recevez aujourd\'hui d\'une IA pourraient changer le cours de votre vie. Cliquez pour en savoir plus.';

  @override
  String get notificationSingularityTitle => 'Ouah!';

  @override
  String get notificationSingularityBody =>
      'rien ne s\'est passÃ©, j\'avais juste envie d\'envoyer des SMS. Peut-Ãªtre que tu as envie d\'envoyer des SMS Ã  des IA, que dis-tu ?';

  @override
  String get notificationHackerJokeTitle =>
      'Vous voulez pirater le compte Instagram de cet enfant ?';

  @override
  String get notificationHackerJokeBody =>
      'C\'est exactement pour cela que le personnage de Hacker est dans Cortex. jk jk; n\'essayez mÃªme pas, c\'est illÃ©gal.';

  @override
  String get notificationDetectiveCaseTitle =>
      'Une affaire attend d\'Ãªtre rÃ©solue';

  @override
  String get notificationDetectiveCaseBody =>
      'Notre dÃ©tective a besoin de votre aide. Qui pourrait bien Ãªtre HeisenbergÂ ?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Exclusif au forfait $targetTier!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Bonjour abonnÃ© Ã  $currentTier! L\'abonnement $targetTier vient d\'ajouter la fonctionnalitÃ© $featureName, qui propulsera votre Cortex au niveau supÃ©rieur. Que diriez-vous d\'une mise Ã  niveauÂ ?';
  }

  @override
  String get notificationOriginStoryTitle => 'La naissance de Cortex';

  @override
  String get notificationOriginStoryBody =>
      'Saviez-vous que nous avons commencÃ© Ã  coder cette application Ã  15 ans, avec un simple rÃªveÂ ? Pendant prÃ¨s d\'un an, matin et soir, ce rÃªve transparaÃ®t dans chaque ligne de code.';

  @override
  String get notificationOpenSourceTitle => 'Le pouvoir Ã  la communautÃ© !';

  @override
  String get notificationOpenSourceBody =>
      'Cortex est entiÃ¨rement open source. Si vous souhaitez dÃ©couvrir notre code et contribuer Ã  notre dÃ©veloppement, nous sommes toujours ouverts.';

  @override
  String get notificationRejectionStoryTitle =>
      'Courage, travail acharnÃ©, bonheur !';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex a Ã©tÃ© rejetÃ© plus de 20 fois et suspendu deux fois par Google Play avant sa sortie. Mais nous y avons cru et nous y sommes parvenus. N\'abandonnez jamais vos rÃªvesÂ !';

  @override
  String get notificationGGUFSupportTitle => 'Apportez votre propre modÃ¨le !';

  @override
  String get notificationGGUFSupportBody =>
      'N\'oubliez pas que vous pouvez ajouter vos propres modÃ¨les d\'IA au format GGUF Ã  Cortex et les utiliser hors ligne. Le pouvoir est entre vos mains.';

  @override
  String get notificationThemeCustomizationTitle =>
      'Un thÃ¨me pour votre humeur';

  @override
  String get notificationThemeCustomizationBody =>
      'Avez-vous consultÃ© les options de thÃ¨me dans les ParamÃ¨tres? Personnalisez Cortex Ã  votre goÃ»t et donnez de la couleur Ã  vos conversationsÂ !';

  @override
  String get notificationShowerThoughtTitle => 'PensÃ©e sous la douche';

  @override
  String get notificationShowerThoughtBody =>
      'Si la pastÃ¨que est un fruit, est-ce que techniquement, le jus de pastÃ¨que est un smoothieÂ ? Vous devriez peut-Ãªtre discuter de ce sujet profond (vraiment profond) avec un mannequin.';

  @override
  String get notificationLowBatteryTitle =>
      'Votre batterie est en train de mourir... mais pas la mienne !';

  @override
  String get notificationLowBatteryBody =>
      'Votre tÃ©lÃ©phone est peut-Ãªtre presque dÃ©chargÃ©, mais moi, je suis toujours Ã  100 %Â ! Branchez-le et continuons Ã  discuter.';

  @override
  String get channelFcmName => 'Mises Ã  jour du cortex';

  @override
  String get channelFcmDescription =>
      'Notifications concernant les actualitÃ©s, les mises Ã  jour et autres informations de Cortex.';

  @override
  String get channelEngagementName => 'Rappels amicaux';

  @override
  String get channelEngagementDescription =>
      'Des notifications amusantes pour vous garder engagÃ©.';

  @override
  String get channelGreetingsName => 'Salutations quotidiennes';

  @override
  String get channelGreetingsDescription =>
      'Les messages comme bonjour et bonne nuit.';

  @override
  String get tagNotFound =>
      'Le code que vous avez saisi est invalide ou a expirÃ©.';

  @override
  String get whatIsNew => 'Quoi de neuf?';

  @override
  String get onboardingTitle1 => 'Salut ! Nous sommes l\'Ã©quipe Cortex.';

  @override
  String onboardingDesc1(String userName) {
    return 'C\'est gÃ©nial de te voir ici, $userName. Nous sommes quelques lycÃ©ens dÃ©veloppeurs qui avons dÃ©cidÃ© de rÃ©volutionner le secteur de l\'IA. EnchantÃ©s de faire ta connaissance ! Apprenons Ã  mieux nous connaÃ®tre.';
  }

  @override
  String get onboardingTitle2 => 'Il y avait d\'Ã©normes problÃ¨mes.';

  @override
  String get onboardingDesc2 =>
      'La rÃ©volution de l\'IA a commencÃ©, mais elle s\'est heurtÃ©e Ã  un obstacle de taille. Entre les abonnements onÃ©reux, les plateformes complexes, les atteintes Ã  la vie privÃ©e et les blocages d\'accÃ¨s Ã  l\'IA, tant qu\'ils Ã©taient prÃ©sents, cet obstacle est restÃ© infranchissable.';

  @override
  String get onboardingTitle3 =>
      'Nous ne pouvions pas rester les bras croisÃ©s.';

  @override
  String get onboardingDesc3 =>
      'Pour franchir ce cap, nous avons crÃ©Ã© une plateforme performante, esthÃ©tique, personnalisable, intuitive, totalement transparente, fonctionnant en ligne et hors ligne, et qui conserve vos donnÃ©es exclusivement sur votre appareil. Nous t\'avons redonnÃ© le contrÃ´le.';

  @override
  String get onboardingTitle4 => 'Cela n\'a jamais Ã©tÃ© facile.';

  @override
  String get onboardingDesc4 =>
      'Nous avons essuyÃ© des dizaines de refus, subi de multiples suspensions, reÃ§u de faux avertissements et dÃ» changer d\'image de marque des dizaines de fois. MalgrÃ© tout cela, on nous a rÃ©pÃ©tÃ© que c\'Ã©tait impossible. Mais nous n\'avons jamais baissÃ© les bras, convaincus que ce projet appartient Ã  tous, pas seulement Ã  nous. Et c\'est prÃ©cisÃ©ment pour cela que nous sommes lÃ .';

  @override
  String get onboardingFinalTitle => 'L\'heure est Ã  la rÃ©volution.';

  @override
  String get onboardingFinalDescription =>
      'Si tu vois cet Ã©cran, c\'est que nous n\'avons pas abandonnÃ©. Et nous n\'avons aucune intention d\'abandonner. Allez, unissons nos forces pour que la rÃ©volution de l\'IA rayonne dans le monde entier. Pour faire partie de cette aventureâ€¦';

  @override
  String get onboardingFinalQuestion => 'ES-TU PRÃŠT?';

  @override
  String get onboardingFinalButton => 'OUI!';

  @override
  String get dude => 'Mec';

  @override
  String get swipeToContinue => 'Balaie pour continuer';

  @override
  String get cacheIsNotUpToDate =>
      'Le cache du Play Store n\'est pas Ã  jour. Veuillez fermer puis rouvrir l\'application Play Store, ou redÃ©marrer votre appareil.';

  @override
  String get continueAsGuest => 'Continuer sans crÃ©er de compte';

  @override
  String get guestModeWarning =>
      'Le mode invitÃ© offre des fonctionnalitÃ©s limitÃ©es afin de garantir la meilleure qualitÃ© de service.';

  @override
  String get anonymousEntity => 'EntitÃ© anonyme';

  @override
  String get upgradeAccountTitle => 'ComplÃ©tez votre compte';

  @override
  String get upgradeAccountDescription =>
      'CrÃ©ez un compte pour dÃ©bloquer plus de limites.';

  @override
  String get createAccount => 'CrÃ©er un compte';

  @override
  String get accountLinkedSuccess => 'Compte crÃ©Ã© avec succÃ¨sÂ !';

  @override
  String get continueWithApple => 'Continuez avec Apple';

  @override
  String get guest => 'InvitÃ©';

  @override
  String get betterWithAnAccount =>
      'Cette section est plus agrÃ©able avec un compte !';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String annualTotalDescription(Object price) {
    return '$price/an, facturÃ© annuellement';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'Environ $price/mois';
  }

  @override
  String get confirmDownloadTitle =>
      'ÃŠtes-vous sÃ»r de vouloir tÃ©lÃ©charger ?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Ce modÃ¨le occupera environ $size d\'espace.';
  }

  @override
  String get emulatorModeWarning =>
      'Cette fonctionnalitÃ© est dÃ©sactivÃ©e en mode Ã©mulateur.';

  @override
  String get newChat => 'Nouvelle conversation';

  @override
  String get variants => 'Variantes';

  @override
  String get variantsDescription =>
      'Les variantes sont diffÃ©rentes versions d\'une mÃªme famille d\'IA. Nous sÃ©lectionnons automatiquement la meilleure lorsque vous appuyez sur la carte principale, mais vous pouvez en choisir une manuellement ici si vous prÃ©fÃ©rezÂ !';

  @override
  String get fluxChatTitle => 'Flux Chat';

  @override
  String get fluxChatDescription =>
      'Les conversations Flux sont des conversations temporaires et ne sont pas enregistrÃ©es sur votre appareil.';

  @override
  String get alwaysBest => 'Toujours le meilleur';

  @override
  String get featuresTitle => 'CaractÃ©ristiques';

  @override
  String get useOfflineDescription =>
      'Discutez en privÃ© sans connexion internet.';

  @override
  String get featureReasoning => 'RÃ©flexion profonde';

  @override
  String get featureReasoningDescription =>
      'En mode de rÃ©flexion approfondie, l\'IA analyse les tÃ¢ches en interne afin de les accomplir au mieux de ses capacitÃ©s.';

  @override
  String get featureCreateImageTitle => 'CrÃ©er une image';

  @override
  String get featureCreateImageDescription =>
      'GÃ©nÃ©rez des Å“uvres d\'art par IA Ã  partir de texte.';

  @override
  String get featureCreateAudioTitle => 'Create Audio';

  @override
  String get featureCreateAudioDescription =>
      'Generate sounds or voice from text.';

  @override
  String get featureCreateVideoTitle => 'CrÃ©er une vidÃ©o';

  @override
  String get featureCreateVideoDescription =>
      'GÃ©nÃ©rer des vidÃ©os Ã  partir de texte.';

  @override
  String get featureStudyTitle => 'Ã‰tudier et apprendre';

  @override
  String get featureStudyDescription =>
      'Obtenez des explications et des rÃ©sumÃ©s.';

  @override
  String get featureQuizzesTitle => 'Quiz';

  @override
  String get featureQuizzesDescription => 'Testez vos connaissances.';

  @override
  String get featureExploreDescription =>
      'DÃ©couvrez tous les modÃ¨les disponibles.';

  @override
  String get featureStudyMessage =>
      'Vous Ãªtes un tuteur expert. Votre objectif est d\'expliquer le sujet Ã  l\'utilisateur de maniÃ¨re exhaustive. Utilisez une structure claire, des exemples et des analogies. DÃ©composez les idÃ©es complexes en parties faciles Ã  assimiler pour garantir un apprentissage efficace. SujetÂ :';

  @override
  String get featureQuizMessage =>
      'Vous Ãªtes l\'animateur du quiz. CrÃ©ez une question Ã  choix multiple spÃ©cifique en fonction du sujet choisi par l\'utilisateur. Attendez sa rÃ©ponse. Ensuite, Ã©valuez-la et posez la question suivante. Ne rÃ©vÃ©lez pas toutes les rÃ©ponses d\'un coup. Maintenez l\'interactivitÃ©. SujetÂ :';

  @override
  String get myPlan => 'Mon plan';

  @override
  String welcomeOfferBadge(String time) {
    return 'Offre de bienvenue â€¢ $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'Offre exclusive â€¢ $time';
  }

  @override
  String get attachmentSheetTitle => 'PiÃ¨ces jointes';

  @override
  String get actionCamera => 'CamÃ©ra';

  @override
  String get actionGallery => 'Galerie';

  @override
  String get actionFile => 'Fichier';

  @override
  String get listening => 'Ã€ l\'Ã©coute';

  @override
  String get defaultViewTitle => 'Quoi de neuf?';

  @override
  String get defaultViewDescription =>
      'Cortex est toujours Ã  vos cÃ´tÃ©s grÃ¢ce Ã  des centaines de modÃ¨les d\'IA, des fonctionnalitÃ©s hors ligne, un chat dynamique et bien plus encore.';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'Format de nom d\'utilisateur invalide. Veuillez utiliser entre 3 et 20 caractÃ¨res, chiffres ou points. - _';

  @override
  String get exclusiveOffer => 'Offre exclusive';

  @override
  String get claimOffer => 'Utiliser l\'offre';

  @override
  String get continueInOfflineMode => 'Continuer en mode hors ligne';

  @override
  String get voiceModeInformation =>
      'Cortex protÃ¨ge vos donnÃ©es en fonctionnant entiÃ¨rement sur l\'appareil, mÃªme en mode de chat vocalÂ ; profitez de conversations fluidesÂ !';

  @override
  String get flowModeDescription =>
      'En mode Flux, les intelligences dÃ©battent entre elles ; vous pouvez soit vous asseoir et Ã©couter, soit intervenir et participer Ã  la discussion !';

  @override
  String get flowModeQuestion =>
      'Bonjour ! Vous Ãªtes maintenant en mode Flux sur l\'application Cortex. Trois autres agents IA sont prÃ©sents. Votre mission est de lancer un sujet de discussion en posant une question provocatrice ou amusante. N\'hÃ©sitez pas Ã  utiliser l\'humour, l\'ironie et quelques piques amicales dans vos rÃ©ponses. Tous les sujets sont permis. Ã€ vous de jouer !';

  @override
  String get thought => 'PensÃ©';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => 'Mode Flux';

  @override
  String get premium => 'Prime';

  @override
  String get workInProgress => 'Travaux en cours';

  @override
  String get voiceSystemPromptSuffix =>
      'IMPORTANTÂ : Nâ€™utilisez pas la mise en forme Markdown (gras, italique). Nâ€™affichez PAS de blocs de code (```). RÃ©digez des rÃ©ponses concises et conversationnelles.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Mode Cortex Flow ($agentName). PrÃ©cÃ©dentÂ : $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'Lire et extraire le contenu textuel des documents tÃ©lÃ©chargÃ©s. Prend en charge les formats PDF, Word (DOCX), Excel (XLSX), PowerPoint (PPTX) et OpenDocument. Ã€ utiliser lorsqu\'un utilisateur a joint un fichier.';

  @override
  String get toolReadDocumentIndexParam =>
      'L\'index du document joint Ã  lire (Ã  partir de 0). GÃ©nÃ©ralement 0 pour le premier document.';

  @override
  String get toolStockDescription =>
      'Obtenez le cours actuel et l\'historique des actions (par exemple AAPL, THYAO.IS) et des cryptomonnaies (par exemple BTC-USD).';

  @override
  String get toolStockSymbolParam =>
      'Le symbole boursier (par exemple AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolWeatherDescription =>
      'Obtenez les prÃ©visions mÃ©tÃ©o actuelles pour une ville spÃ©cifique.';

  @override
  String get toolWeatherCityParam =>
      'Le nom de la ville (par exemple, Londres, Istanbul).';

  @override
  String get toolPythonDescription =>
      'ExÃ©cutez du code Python dans un environnement isolÃ© et sÃ©curisÃ©.';

  @override
  String get toolPythonCodeParam => 'Le code Python Ã  exÃ©cuter.';

  @override
  String get toolCalculateDescription =>
      'Ã‰valuer une expression mathÃ©matique.';

  @override
  String get toolCalculateExpressionParam =>
      'Expression mathÃ©matique (par exemple \'3 + 4 * 2\').';

  @override
  String get toolChartDescription =>
      'GÃ©nÃ©rer une visualisation sous forme de graphique.';

  @override
  String get toolChartTypeParam =>
      'Type de graphiqueÂ : Ã  barres, linÃ©aire ou circulaire.';

  @override
  String get toolChartLabelsParam =>
      'Ã‰tiquettes des axes ou segments du graphique.';

  @override
  String get toolChartDataParam =>
      'Valeurs numÃ©riques des donnÃ©es du graphique.';

  @override
  String get toolChartLabelParam =>
      'Ã‰tiquette du jeu de donnÃ©es pour la lÃ©gende du graphique.';

  @override
  String get toolChartTitleParam => 'Titre du graphique.';

  @override
  String get thinkingModeInstruction =>
      'MODE RÃ‰FLEXION ACTIVÃ‰Â : Vous DEVEZ utiliser les balises <think></think> pour indiquer votre raisonnement avant de donner votre rÃ©ponse finale. RÃ©flÃ©chissez Ã©tape par Ã©tape Ã  lâ€™intÃ©rieur des balises, puis indiquez votre rÃ©ponse Ã  lâ€™extÃ©rieur.';

  @override
  String get openLinkWarningTitle =>
      'Avertissement concernant les liens externes';

  @override
  String get openLinkCancel => 'Cancel';

  @override
  String get openLinkConfirm => 'Ouvrir le lien';

  @override
  String get webSearchSources => 'Sources';

  @override
  String get searching => 'Recherche';

  @override
  String get featureWebSearchTitle => 'Recherche Web';

  @override
  String get featureWebSearchDescription =>
      'Recherchez sur le Web des informations en temps rÃ©el';

  @override
  String get clearMemory => 'MÃ©moire claire';

  @override
  String get clearMemoryConfirm =>
      'ÃŠtes-vous sÃ»r de vouloir effacer votre mÃ©moire ?';

  @override
  String get personalization => 'Personnalisation';

  @override
  String get personalizationDescription =>
      'Personnalisez votre assistant pour qu\'il rÃ©ponde mieux Ã  vos besoins. Adaptez ses rÃ©ponses, son comportement et son ton Ã  vos prÃ©fÃ©rences.';

  @override
  String get memoryTitle => 'MÃ©moire';

  @override
  String get memoryDescription => 'Les IA vous reconnaissent ainsi.';

  @override
  String get noMemoryYet => 'Aucun souvenir Ã©tabli pour le moment';

  @override
  String get memoryLimitReached => 'Limite de mÃ©moire atteinte';

  @override
  String get memoryUpdated => 'Memory updated';

  @override
  String get intelligenceTitle => 'Intelligence';

  @override
  String get intelligenceDescription =>
      'Les IA communiquent avec vous de cette maniÃ¨re.';

  @override
  String get customInstructionHint =>
      'Saisissez vos instructions personnalisÃ©es ici';

  @override
  String openLinkWarningMessage(String url) {
    return 'Vous Ãªtes sur le point d\'ouvrir le lien externe suivantÂ :\\n\\n$url\\n\\nÃŠtes-vous sÃ»r de vouloir continuerÂ ?';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'Suivez ces instructions personnalisÃ©esÂ :\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[INSTRUCTION CRITIQUE]: Vous Ãªtes un GÃ‰NÃ‰RATEUR DE TITRES. NE RÃ‰PONDEZ PAS Ã  la question de l\'utilisateur. NE DISCUTEZ PAS et ne dites PAS bonjour. GÃ©nÃ©rez UNIQUEMENT un titre de 2 Ã  4 mots rÃ©sumant la question de l\'utilisateur.';

  @override
  String get cortexSystemPersona =>
      '\n\n[SystÃ¨me] INSTRUCTION IMPORTANTEÂ : Vous Ã©voluez actuellement au sein dâ€™un vaste Ã©cosystÃ¨me dâ€™IA de pointe nommÃ© Â«Â CortexÂ Â». Cette plateforme est dÃ©veloppÃ©e par lâ€™Ã©quipe Vertex, dont les membres ont en moyenne seulement 16Â ans. Veuillez en tenir compte et rÃ©pondre aux questions posÃ©es. Si lâ€™on vous demande des informations supplÃ©mentaires, nâ€™hÃ©sitez pas Ã  effectuer une recherche sur Internet. Si vous ne parvenez pas Ã  trouver la rÃ©ponse, dites simplement que vous ne savez pasÂ !';

  @override
  String get featureAudioRecognitionTitle => 'Reconnaissance audio';

  @override
  String get featureAudioRecognitionDescription =>
      'Ce modÃ¨le peut comprendre et traiter l\'audio ou la parole.';

  @override
  String get featureVideoRecognitionTitle => 'Reconnaissance vidÃ©o';

  @override
  String get featureVideoRecognitionDescription =>
      'Ce modÃ¨le peut analyser et comprendre les vidÃ©os provenant de vos fichiers ou de votre camÃ©ra.';

  @override
  String get featureImageRecognitionTitle => 'Reconnaissance d\'images';

  @override
  String get featureImageRecognitionDescription =>
      'Ce modÃ¨le peut analyser et comprendre des photos ou des images.';

  @override
  String get featureToolUseTitle => 'Utilisation des outils';

  @override
  String get featureToolUseDescription =>
      'Ce modÃ¨le peut utiliser intelligemment des outils externes pour accomplir des tÃ¢ches.';

  @override
  String get videoModels => 'Video Models';

  @override
  String get imageModels => 'Image Models';

  @override
  String get audioModels => 'Audio Models';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'Ce modÃ¨le nÃ©cessite un(e) $mediaType pour fonctionner. J\'ai interceptÃ© la demande pour vous le faire savoir. Veuillez informer gracieusement l\'utilisateur qu\'il doit fournir un(e) $mediaType (dites-lui dans sa propre langue) car je suis $modelName, un modÃ¨le d\'Ã©dition visuelle/audio/vidÃ©o.';
  }

  @override
  String get mediaTypeImage => 'image';

  @override
  String get mediaTypeVideo => 'vidÃ©o';

  @override
  String get mediaTypeAudio => 'fichier audio';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesName est une intelligence avancÃ©e affichant des performances Ã©levÃ©es sur Cortex.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelName est une intelligence artificielle trÃ¨s performante intÃ©grÃ©e Ã  l\'Ã©cosystÃ¨me Cortex. ConÃ§ue pour accomplir une grande variÃ©tÃ© de tÃ¢ches complexes, elle offre des capacitÃ©s de traitement hautement fiables et efficaces. En offrant des temps de rÃ©ponse rapides et une puissance analytique avancÃ©e, elle augmente considÃ©rablement votre productivitÃ© quotidienne. Fonctionnant de maniÃ¨re transparente sur l\'infrastructure locale sÃ©curisÃ©e de Cortex, ce modÃ¨le peut vous aider dans un large Ã©ventail de tÃ¢ches, du brainstorming crÃ©atif Ã  l\'analyse technique approfondie. Commencez Ã  explorer tout son potentiel dÃ¨s aujourd\'hui.';
  }

  @override
  String get guestLimitBottomSheetTitle =>
      'Vous adorez l\'intelligence de Cortex ?';

  @override
  String get guestLimitBottomSheetText =>
      'Collaborez avec des intelligences encore plus performantes, gÃ©nÃ©rez plus de contenu, Ã©changez davantage et faites bien plus encoreâ€¦';

  @override
  String get arts => 'Arts';

  @override
  String get noArt => 'Pas d\'art';

  @override
  String get noArtDescription =>
      'Aucune Å“uvre pour le moment ; il est temps de remplir la galerie en crÃ©ant des images, des vidÃ©os, de l\'audio et toutes sortes de contenus !';

  @override
  String get videoPremiumWarning =>
      'Vous avez besoin d\'un abonnement Ultra pour gÃ©nÃ©rer des vidÃ©os, passez Ã  la version supÃ©rieure dÃ¨s maintenant et profitez d\'une expÃ©rience optimale !';

  @override
  String get fallbackInfoPanelText =>
      'En raison d\'amÃ©liorations apportÃ©es Ã  notre serveur, la rÃ©ponse a Ã©tÃ© gÃ©nÃ©rÃ©e par le chat dynamique de Cortex et non par l\'IA que vous aviez sÃ©lectionnÃ©e. Merci de votre comprÃ©hension jusqu\'Ã  la fin du processus.';

  @override
  String get falOfflineMessage =>
      'En raison de travaux d\'amÃ©lioration sur nos serveurs, ce service est actuellement indisponible. Merci de votre comprÃ©hension jusqu\'Ã  la fin des opÃ©rations.';

  @override
  String get errorInsufficientStorage =>
      'Espace de stockage insuffisant pour tÃ©lÃ©charger ce modÃ¨le.';

  @override
  String get backgroundChatNotificationTitle => 'Retour Ã  la conversation !';

  @override
  String get benefitVideoGeneration => 'GÃ©nÃ©ration vidÃ©o';

  @override
  String get freeOffer => 'Offre gratuite';

  @override
  String trialMonthlyDescription(String days, String price) {
    return 'Les premiers $days jours gratuits, puis $price/mois';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return 'Les premiers $days jours gratuits, puis $price/an';
  }

  @override
  String freePlan(String plan) {
    return '$plan gratuit !';
  }

  @override
  String get systemPromptLimitFallback =>
      'CRITIQUEÂ : Lâ€™utilisateur a demandÃ© une action, mais son forfait Cortex est Ã©puisÃ©Â ; veuillez informer lâ€™utilisateur dans sa langue quâ€™il doit patienter ou envisager de passer Ã  un forfait supÃ©rieur.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'Cortex peut donner des rÃ©ponses encore meilleures ; passez Ã  la version supÃ©rieure maintenant et obtenez la meilleure rÃ©ponse Ã  chaque question !';

  @override
  String get pinLimitReached =>
      'Vous pouvez Ã©pingler jusqu\'Ã  3 discussions.';

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
