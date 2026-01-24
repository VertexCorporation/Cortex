// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get cancel => 'Annuler';

  @override
  String get remove => 'Retirer';

  @override
  String get download => 'Télécharger';

  @override
  String get resume => 'Reprendre';

  @override
  String get copy => 'Copier';

  @override
  String get chat => 'Chat';

  @override
  String get light => 'Clair';

  @override
  String get theme => 'Thème';

  @override
  String get no => 'Non';

  @override
  String get yes => 'Oui';

  @override
  String get done => 'Terminé';

  @override
  String get bestValue => 'Meilleur Prix';

  @override
  String get selected => 'Sélectionné';

  @override
  String get descriptionSection => 'Description';

  @override
  String get searchHint => 'Rechercher';

  @override
  String get messageHint => 'Demandez n\'importe quoi';

  @override
  String get messageCopied => 'Message copié dans le presse-papiers.';

  @override
  String get retry => 'Réessayer';

  @override
  String get systemInfo => 'Informations système';

  @override
  String deviceMemory(Object memory) {
    return 'Mémoire de l\'appareil : $memory Go';
  }

  @override
  String get memory => 'Mémoire';

  @override
  String get storage => 'Stockage';

  @override
  String get freeStorage => 'Stockage libre';

  @override
  String get totalStorage => 'Stockage total';

  @override
  String get usedStorage => 'Stockage utilisé';

  @override
  String get totalMemory => 'Mémoire totale';

  @override
  String get usedMemory => 'Mémoire utilisée';

  @override
  String get modelsTitle => 'Bibliothèque';

  @override
  String get localModels => 'Modèles Locaux';

  @override
  String get serverSideModels => 'Modèles en Ligne';

  @override
  String get selectGGUFFile => 'Sélectionner un fichier GGUF';

  @override
  String get errorGGUF =>
      'Veuillez sélectionner uniquement un fichier au format GGUF.';

  @override
  String get myModels => 'Mes Modèles';

  @override
  String get create => 'Créer';

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
      'Aucune conversation, commencez à discuter !';

  @override
  String get startChat => 'Démarrer une discussion';

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
      'Le mot de passe doit contenir au moins 6 caractères.';

  @override
  String get rememberMe => 'Se souvenir de moi';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get or => 'Ou';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get logIn => 'Se connecter';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get wrongPassword => 'Mot de passe incorrect.';

  @override
  String get emailAlreadyInUse => 'Cet e-mail est déjà utilisé.';

  @override
  String get weakPassword => 'Le mot de passe est trop faible.';

  @override
  String get authError => 'Erreur d\'authentification';

  @override
  String get usernameTaken => 'Ce nom d\'utilisateur est déjà pris.';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get resendCode => 'Renvoyer l\'e-mail de vérification';

  @override
  String get pleaseCheckYourEmail =>
      'Pour utiliser Cortex, vous devez vérifier votre e-mail. \nUn lien de vérification a été envoyé à votre adresse e-mail, veuillez vérifier vos e-mails.';

  @override
  String get verifyYourEmail => 'Vérifiez Votre E-mail';

  @override
  String get seconds => 'secondes';

  @override
  String get maxResendLimitReached =>
      'Vous avez atteint le nombre maximum d\'e-mails de vérification';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Continuer sans vérification';

  @override
  String get verificationScreenWarning =>
      'Même si vous continuez, la période de vérification du compte d\'un jour est toujours en vigueur pour votre compte. Si vous n\'avez pas vérifié votre compte d\'ici là, il sera supprimé de l\'application.';

  @override
  String get unverifiedAccountHeader => 'Votre compte n\'est pas vérifié';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Si vous ne vérifiez pas votre compte dans un délai de $timeLeft, il sera supprimé';
  }

  @override
  String get verifyNow => 'Vérifier maintenant';

  @override
  String get linkSent => 'Lien envoyé';

  @override
  String get accountDeletionRequested =>
      'Votre demande de suppression de compte a été reçue et votre compte est maintenant désactivé.';

  @override
  String get tooManyRequests => 'Trop de requêtes';

  @override
  String get regenerate => 'Régénérer';

  @override
  String get confirmDeleteAccount =>
      'Êtes-vous sûr de vouloir supprimer votre compte ?';

  @override
  String get deleteAccount => 'Supprimer le Compte';

  @override
  String get delete => 'Supprimer';

  @override
  String get passwordRequired => 'Le mot de passe est requis.';

  @override
  String get deleteDescription =>
      'Les données que vous supprimez seront définitivement retirées de notre serveur et de votre appareil. Cette action est irréversible.';

  @override
  String get deleteAccountButton => 'Bouton de suppression de compte';

  @override
  String get editProfile => 'Modifier le Profil';

  @override
  String get displayName => 'Nom d\'affichage';

  @override
  String get profileUpdated => 'Profil mis à jour avec succès';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get profile => 'Profil';

  @override
  String get manageProfileDescription =>
      'Gérez votre profil, mettez à jour votre mot de passe ou déconnectez-vous de Cortex.';

  @override
  String get accessSettingsDescription =>
      'Accédez à l\'aide, utilisez des codes, partagez Cortex et consultez nos politiques.';

  @override
  String get languageDescription =>
      'Vous pouvez changer la langue par défaut de l\'interface de l\'application à tout moment.';

  @override
  String get themeDescription =>
      'Vous pouvez basculer entre les thèmes clair et sombre selon vos préférences. Le thème sélectionné s\'appliquera à toute l\'interface de Cortex.';

  @override
  String get iHaveReadAndAgree =>
      'J\'ai lu et j\'accepte les conditions d\'utilisation';

  @override
  String get downloading => 'Téléchargement en cours...';

  @override
  String get downloadSuccess => 'Téléchargement réussi';

  @override
  String get downloadFailed => 'Échec du téléchargement';

  @override
  String downloaded(Object percent) {
    return '$percent% téléchargé';
  }

  @override
  String get downloadPaused => 'Téléchargement en pause.';

  @override
  String get purchaseSuccessful => 'Achat réussi !';

  @override
  String get purchaseError => 'Erreur d\'achat';

  @override
  String get purchasePlus => 'Acheter Cortex Plus';

  @override
  String get plusDescription =>
      'Expérience d\'intelligence artificielle d\'élite';

  @override
  String get annual => 'Annuel';

  @override
  String get monthly => 'Mensuel';

  @override
  String get manageSubscription => 'Gérer l\'abonnement';

  @override
  String purchasePlan(String planName) {
    return 'Acheter $planName';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/mois, facturé mensuellement';
  }

  @override
  String get purchasePro => 'Acheter Cortex Pro';

  @override
  String get proDescription =>
      'Expérience d\'intelligence artificielle de premier plan';

  @override
  String get purchaseUltra => 'Acheter Cortex Ultra';

  @override
  String get ultraDescription => 'L\'apogée de l\'intelligence artificielle';

  @override
  String get upgradeSubscription => 'Mettre à niveau l\'abonnement';

  @override
  String get purchaseStreamError => 'Erreur de flux d\'achat.';

  @override
  String get productNotFound => 'Produit non trouvé';

  @override
  String get noProductsFound => 'Aucun produit trouvé';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'En passant cette commande, vous acceptez les Conditions d\'Utilisation et la Politique de Confidentialité. Vous pouvez cliquer sur ce texte pour en savoir plus sur nos Conditions d\'Utilisation et notre Politique de Confidentialité. L\'abonnement se renouvellera automatiquement sauf si le renouvellement automatique est désactivé au moins 24 heures avant la fin de la période en cours.';

  @override
  String get termsOfService => 'Conditions d\'Utilisation';

  @override
  String get privacyPolicy => 'Politique de Confidentialité';

  @override
  String get report => 'Signaler';

  @override
  String get reportDialogTitle => 'Soumettre un signalement';

  @override
  String get reportDescriptionLabel => 'Quel est le problème ?';

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
      'Veuillez sélectionner une raison pour le signalement.';

  @override
  String get capabilitiesSection => 'Capacités';

  @override
  String get featurePhotoTitle => 'Analyse de photos';

  @override
  String get featurePhotoDescription =>
      'Ce modèle a la capacité d\'analyser des photos via l\'appareil photo ou des fichiers image.';

  @override
  String get featureOfflineTitle => 'Fonctionnement Hors Ligne';

  @override
  String get featureOfflineDescription =>
      'Exécutez le modèle sans connexion Internet pour protéger vos données.';

  @override
  String get featureRoleplayTitle => 'Jeu de Rôle';

  @override
  String get featureRoleplayDescription =>
      'Les modèles de jeu de rôle vous permettent de créer diverses discussions et scénarios.';

  @override
  String get roleModels => 'Modèles de Jeu de Rôle';

  @override
  String get parameters => 'Paramètres';

  @override
  String get context => 'Contexte';

  @override
  String get finalPreparation => 'Les derniers préparatifs sont en cours.';

  @override
  String get shareApp => 'Partager l\'application';

  @override
  String get rateUs => 'Nous évaluer';

  @override
  String get share => 'Partager';

  @override
  String get shareSubject => 'Cortex';

  @override
  String shareMessage(String cortexLink) {
    return 'Découvrez l\'application Cortex, elle est incroyable ! Téléchargez-la ici : $cortexLink';
  }

  @override
  String get shareFailed =>
      'Échec du partage de l\'application. Veuillez réessayer plus tard';

  @override
  String get selectText => 'Sélectionner le texte';

  @override
  String get thinking => 'Réflexion en cours';

  @override
  String get user => 'Utilisateur';

  @override
  String get help => 'Aide';

  @override
  String get supportCreator => 'Soutenez un créateur';

  @override
  String get enterYourTag =>
      'Soutenez vos créateurs préférés ! Saisissez leur identifiant unique ci-dessous pour leur reverser une part de vos achats Cortex.';

  @override
  String get creatorTag => 'Étiquette du créateur';

  @override
  String get support => 'Soutien';

  @override
  String get tagCannotBeEmpty => 'La balise Créateur ne peut pas être vide.';

  @override
  String get userId => 'ID Utilisateur';

  @override
  String get deleteAllConversationsConfirmTitle =>
      'Supprimer toutes les discussions ?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Êtes-vous sûr de vouloir supprimer toutes vos discussions ? Cette action est irréversible.';

  @override
  String get conversationDeleted => 'Conversation supprimée !';

  @override
  String get allConversationsDeleted =>
      'Toutes les conversations ont été supprimées avec succès !';

  @override
  String get deleteAll => 'Tout supprimer';

  @override
  String get deleteAllConversationsButton =>
      'Supprimer toutes les conversations';

  @override
  String get confirmWord => 'Tapez VERTEX';

  @override
  String get confirmWordError => 'Vous l\'avez mal tapé';

  @override
  String get chinese => 'Chinois';

  @override
  String get french => 'Français';

  @override
  String get japanese => 'Japonais';

  @override
  String get kurdish => 'Kurde';

  @override
  String get dutch => 'Néerlandais';

  @override
  String get russian => 'Russe';

  @override
  String get korean => 'Coréen';

  @override
  String get english => 'Anglais';

  @override
  String get turkish => 'Turc';

  @override
  String get hindi => 'Hindi';

  @override
  String get portuguese => 'Portugais';

  @override
  String get indonesian => 'Indonésien';

  @override
  String get azerbaijani => 'Azerbaïdjanais';

  @override
  String get german => 'Allemand';

  @override
  String get spanish => 'Espagnol';

  @override
  String get italian => 'Italien';

  @override
  String get arabic => 'arabe';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'Le nom d\'utilisateur est trop court.';

  @override
  String get usernameTooLong =>
      'Le nom d\'utilisateur ne peut pas dépasser 16 caractères.';

  @override
  String get invalidUsernameCharacters =>
      'Le nom d\'utilisateur ne peut contenir que les lettres suivantes : \'abcçdefgğhıijklmnoöprsştuüvyzxqw\' et les caractères \'.\', \'-\', \'_\'.';

  @override
  String get noInternetConnection => 'Pas de connexion Internet.';

  @override
  String get chats => 'Boîte de réception';

  @override
  String get library => 'Bibliothèque';

  @override
  String get text => 'Texte';

  @override
  String get removeModel => 'Supprimer le Modèle';

  @override
  String get insufficientRAM => 'Mémoire insuffisante';

  @override
  String get insufficientStorage => 'Stockage insuffisant';

  @override
  String confirmRemoveModel(Object model) {
    return 'Êtes-vous sûr de vouloir supprimer le modèle $model de votre appareil ? Cette action supprimera également toutes les conversations précédentes avec ce modèle.';
  }

  @override
  String get noMatchingModels => 'Aucun modèle correspondant trouvé.';

  @override
  String get benefit1 => 'Limites de Conversation Augmentées';

  @override
  String get benefit3 => 'Effet de Profil';

  @override
  String get benefit4 => 'Badge de Membre';

  @override
  String get benefit5 => 'Créez Plus d\'Intelligences Artificielles en Ligne';

  @override
  String get benefit7 => 'Plafonds d\'Utilisation Plus Élevés';

  @override
  String get benefit8 => 'Ajouter des Modèles';

  @override
  String get benefit9 => 'Nouveaux Thèmes';

  @override
  String get benefit10 => 'Pièces jointes supplémentaires';

  @override
  String get oldBenefits => 'Tous les Avantages des Plans Inférieurs';

  @override
  String get confirm => 'Confirmer';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get logoutConfirmationTitle =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue de l\'application';

  @override
  String get dark => 'Sombre';

  @override
  String get oldPassword => 'Ancien mot de passe';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get passwordUpdated => 'Mot de passe mis à jour.';

  @override
  String get stop => 'Arrêter';

  @override
  String get copyrights => 'Attributions';

  @override
  String get love => 'Amour';

  @override
  String get nature => 'Nature';

  @override
  String get behindTheSlaughter => 'Derrière le Massacre';

  @override
  String get grayscale => 'Niveaux de gris';

  @override
  String get ocean => 'Océan';

  @override
  String get scarletSnow => 'Neige Écarlate';

  @override
  String get requestFailed => 'Une erreur est survenue, veuillez réessayer.';

  @override
  String get changeModel => 'Changer';

  @override
  String get edit => 'Modifier';

  @override
  String get editingMessageInfo =>
      'La modification de ce message redémarrera la conversation à partir d\'ici.';

  @override
  String get editingNotification => 'Vous êtes maintenant en mode édition';

  @override
  String get featurePluralTitle => 'Pluriel';

  @override
  String get featurePluralDescription =>
      'Ce modèle peut intégrer automatiquement des variants supplémentaires, élargissant ainsi ses capacités fonctionnelles pour prendre en charge une gamme diversifiée d\'opérations avec des performances améliorées.';

  @override
  String get nameLabel => 'Nom de l\'IA';

  @override
  String get summaryLabel => 'Résumé de l\'IA';

  @override
  String get add => 'Ajouter';

  @override
  String get aiExplanationTitle =>
      'Description de l\'Intelligence Artificielle';

  @override
  String get aiExplanationDescription =>
      'Veuillez fournir une description détaillée de l\'architecture de votre modèle d\'IA, du processus d\'entraînement, des métriques de performance, des domaines d\'application et d\'autres fonctionnalités importantes.';

  @override
  String get preInputTitle => 'Pré-saisie de l\'Intelligence Artificielle';

  @override
  String get preInputDescription =>
      'Veuillez définir une pré-saisie qui guidera votre modèle dans le processus de création de personnage. Dans cette section, vous pouvez inclure des informations relatives au personnage, un contexte supplémentaire et tout autre détail pouvant aider à générer du contenu lié au personnage.';

  @override
  String get baseModelTitle => 'Modèle de Base';

  @override
  String get baseModelDescription =>
      'C\'est le modèle qui sera utilisé comme base pour votre création. Il affiche le modèle de base actuellement sélectionné.';

  @override
  String get summary => 'Résumé';

  @override
  String get modelUploadTitle => 'Fichier d\'Intelligence Artificielle';

  @override
  String get modelUploadDescription =>
      'Sélectionnez et téléversez vos fichiers GGUF locaux directement depuis votre appareil. Cela vous permet d\'exécuter votre modèle hors ligne sans avoir besoin d\'une connexion Internet. Assurez-vous que le fichier est au format GGUF valide et correctement structuré. Si le fichier est incorrect ou corrompu, Cortex pourrait ne pas fonctionner comme prévu et vous pourriez rencontrer des erreurs.';

  @override
  String get modelUploadShortDescription =>
      'Appuyez ici pour choisir un fichier .gguf depuis votre appareil';

  @override
  String get you => 'Vous';

  @override
  String get removePhotoTitle => 'Supprimer la Photo';

  @override
  String get confirmRemovePhoto =>
      'Êtes-vous sûr de vouloir supprimer la photo ?';

  @override
  String get chatLengthLimitExceeded =>
      'Cette discussion a dépassé la limite de caractères. Veuillez démarrer une nouvelle discussion ou acheter un abonnement.';

  @override
  String get inappropriateContentDetected => 'Contenu inapproprié détecté !';

  @override
  String get offlineModelNotInstalled =>
      'Ce modèle hors ligne n\'est pas installé sur votre appareil.';

  @override
  String get reachedLimit =>
      'T\'as atteint ta limite ; upgrade pour en avoir plus. (hey, on sait, c\'est chiant. mais sérieux, générer ces réponses a un coût, donc ces limites nous aident à faire tourner la bouuuuttiiiique.)';

  @override
  String get modality => 'Modalité';

  @override
  String get multimodal => 'Multimodal';

  @override
  String get anErrorOccurred => 'Une Erreur est Survenue';

  @override
  String get themeLocked =>
      'Ce thème nécessite un niveau d\'abonnement supérieur. Veuillez mettre à niveau pour le déverrouiller.';

  @override
  String get pageCouldNotBeLoaded => 'La page n\'a pas pu être chargée';

  @override
  String get checkYourInternet =>
      'Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get errorUserNotAuthenticated =>
      'Vous devez être connecté pour effectuer cette action.';

  @override
  String get errorReachedLimit =>
      'Vous avez atteint votre limite, passez à la version supérieure pour débloquer plus de contenu et continuer à discuter.';

  @override
  String get errorServer =>
      'Une erreur de serveur inattendue est survenue. Veuillez réessayer plus tard.';

  @override
  String get errorNetwork =>
      'Une erreur réseau est survenue. Veuillez vérifier votre connexion et réessayer.';

  @override
  String get errorApiAuthentication =>
      'L\'authentification a échoué. Veuillez essayer de vous reconnecter.';

  @override
  String get baseModelForCharacterDescription =>
      'Le modèle de base sélectionné déterminera les capacités de raisonnement et de réponse du personnage.';

  @override
  String get selectBaseModel => 'Sélectionner un Modèle de Base';

  @override
  String get couldNotOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String get downloadStarted => 'Téléchargement démarré';

  @override
  String get notAvailable => 'Non disponible';

  @override
  String get localizationWarning =>
      'Certaines informations peuvent ne pas être disponibles dans votre langue et seront affichées en anglais.';

  @override
  String get aiTranslationWarning =>
      'Les informations sur le modèle sont traduites dans différentes langues par d\'autres modèles d\'IA. Par conséquent, des incohérences mineures peuvent survenir dans les langues autres que l\'anglais.';

  @override
  String get errorLoadingTitle => 'Échec du chargement des données';

  @override
  String get errorLoadingMessage =>
      'Nous n\'avons pas pu récupérer les données nécessaires de nos serveurs. Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get noFoundTitle => 'Aucun résultat';

  @override
  String get noFoundMessage =>
      'Essayez d\'ajuster vos termes de recherche ou de vider le filtre.';

  @override
  String get modelCreatedSuccess => 'Modèle créé avec succès !';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '« $modelName » a été supprimé avec succès.';
  }

  @override
  String get errorCreatingModel =>
      'Une erreur inattendue s\'est produite lors de la création du modèle.';

  @override
  String get errorDeletingModel =>
      'Une erreur inattendue s\'est produite lors de la suppression du modèle.';

  @override
  String get ultraFeatureOnly =>
      'Cette fonctionnalité est réservée aux membres Ultra.';

  @override
  String get experimentalOfflineWarning =>
      'Le mode hors ligne est encore expérimental et le modèle que vous téléchargez pourrait ne pas fonctionner de manière optimale.';

  @override
  String get noConversationsToDelete =>
      'Vous n\'avez aucune conversation à supprimer.';

  @override
  String get reportSubmitted => 'Le signalement a été soumis avec succès.';

  @override
  String get purchaseReceived =>
      'Achat reçu, mise à jour de votre compte en cours.';

  @override
  String get verificationDelayed =>
      'Votre achat est confirmé. Il y a un léger retard dans la mise à jour de votre compte, il apparaîtra sous peu.';

  @override
  String get maintenanceTitle => 'En Maintenance';

  @override
  String get maintenanceMessage =>
      'Cortex est temporairement hors ligne pendant que nous déployons d\'importantes mises à jour. L\'accès à l\'application sera rétabli sous peu.\n\nNous vous remercions de votre patience pendant que nous améliorons votre expérience.';

  @override
  String get errorPromptFlagged =>
      'Votre message a été détecté comme inapproprié et n\'a pas pu être envoyé.';

  @override
  String get notEnoughStorage =>
      'Pas assez d\'espace de stockage sur votre appareil pour enregistrer de nouveaux messages.';

  @override
  String get errorRateLimit =>
      'Vous avez créé trop de modèles récemment, veuillez patienter un moment avant de réessayer.';

  @override
  String get errorContentFlagged =>
      'Le modèle n\'a pas pu être sauvegardé car son contenu a été signalé comme inapproprié.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Vous ne pouvez pas supprimer toutes les conversations pendant une discussion active, veuillez d\'abord quitter la discussion en cours pour continuer.';

  @override
  String get invalidCredentials => 'Adresse e-mail ou mot de passe incorrect.';

  @override
  String get userDisabled => 'Ce compte utilisateur a été désactivé.';

  @override
  String get loginSubtitle =>
      'Connectez-vous à votre compte Vertex. En continuant, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.';

  @override
  String get registerSubtitle =>
      'Créez un compte Vertex pour accéder facilement à tous nos services. En continuant, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.';

  @override
  String get storagePermissionRequired =>
      'Une autorisation de stockage est requise pour enregistrer les modèles téléchargés. Veuillez accorder la permission pour continuer.';

  @override
  String get plusBannerTitle => 'Obtenez Plus gratuitement !';

  @override
  String get plusBannerSubtitle =>
      'Invite un pote et gagnez tous les deux 1 Jour de Plus offert !';

  @override
  String get inviteShareSubject => 'Rejoins-moi sur Cortex !';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'Yo, faut absolument que tu testes cette appli Cortex ! Elle est vraiment dingue ! Si tu utilises mon lien, on aura tous les deux un abonnement gratuit. En plus, c\'est une super affaire ! Télécharge-la vite ! \n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Vous aimez Cortex ?';

  @override
  String get reviewHelpUsGrow =>
      'Votre note est un énorme soutien pour notre jeune équipe indépendante et nous aide à rendre Cortex encore meilleur pour vous.';

  @override
  String get reviewMaybeLater => 'Peut-être plus tard';

  @override
  String get reviewRateNow => 'Évaluer maintenant';

  @override
  String get noThanks => 'Non, merci';

  @override
  String get updateRequiredTitle => 'Mise à jour requise';

  @override
  String get updateRequiredMessage =>
      'Pour continuer à utiliser Cortex, veuillez mettre à jour l\'application vers la dernière version pour bénéficier de nouvelles fonctionnalités et d\'améliorations importantes.';

  @override
  String get updateNowButton => 'Mettre à jour';

  @override
  String get creatorSupportedSuccess =>
      'Créateur soutenu avec succès ! Vos futurs achats contribueront à le soutenir.';

  @override
  String get featureDocumentTitle => 'Support documentaire';

  @override
  String get featureDocumentDescription =>
      'Ce modèle peut analyser et répondre à des questions sur des documents téléchargés tels que des fichiers PDF et des fichiers texte.';

  @override
  String get featureAudioTitle => 'Entrée vocale';

  @override
  String get featureAudioDescription =>
      'Ce modèle peut comprendre et traiter les entrées audio parlées.';

  @override
  String get featureImageGenerationTitle => 'Génération d\'images';

  @override
  String get featureImageGenerationDescription =>
      'Ce modèle peut créer des images originales basées sur vos descriptions textuelles.';

  @override
  String get errorImageLoad => 'Échec du chargement de l\'image générée.';

  @override
  String get premiumModelNoticeTitle => 'Modèle Premium';

  @override
  String get premiumModelNoticeDescription =>
      'Ce modèle est un modèle premium, les utilisateurs gratuits sont limités à 3 messages par jour avec les modèles premium ; abonnez-vous pour débloquer un accès illimité !';

  @override
  String get benefitPremiumModels => 'Accès aux modèles premium';

  @override
  String get premiumTrialExhaustedMessage =>
      'Vous avez utilisé tous vos messages quotidiens gratuits pour les modèles premium, veuillez effectuer une mise à niveau pour un accès illimité.';

  @override
  String get useOffline => 'Utiliser sans Internet';

  @override
  String get explore => 'Explorer';

  @override
  String get news => 'Nouvelles';

  @override
  String get allModels => 'Tous les modèles';

  @override
  String get onlineModels => 'Modèles en ligne';

  @override
  String get offlineModels => 'Modèles hors ligne';

  @override
  String get characterModels => 'Personnages';

  @override
  String get customModels => 'Modèles personnalisés';

  @override
  String get dynamicChatTitle => 'Chat dynamique';

  @override
  String get errorNoModelsAvailable =>
      'Aucun modèle n\'est actuellement disponible. Veuillez vérifier votre connexion internet et réessayer.';

  @override
  String get notificationComebackTitle => 'Tu nous manques!';

  @override
  String get notificationComebackBody =>
      'Détends-toi, ce n\'est pas un texto de ton ex. Mais tu *peux* créer ton ex dans Cortex ! Reviens.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Ça fait longtemps';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Beaucoup de choses ont changé depuis notre dernière discussion. Venez découvrir les nouveautés.';

  @override
  String get notificationHowAreYouTitle => 'Quoi de neuf?';

  @override
  String get notificationHowAreYouBody => 'Viens me raconter tout ça.';

  @override
  String get notificationNewYearTitle => 'Bonne année ! 🎉';

  @override
  String get notificationNewYearBody =>
      'Que la nouvelle année vous apporte santé, bonheur et créativité sans fin ; Cortex est toujours à vos côtés !';

  @override
  String get notificationValentinesDayTitle => 'L\'amour est dans l\'air ! ❤️';

  @override
  String get notificationValentinesDayBody =>
      'Joyeuse Saint-Valentin ! Et aussi, MEHTAP, JE T\'AIME !';

  @override
  String get notificationAtaturkRemembranceTitle => 'Avec respect et nostalgie';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Nous commémorons avec respect Gazi Mustafa Kemal Atatürk, le fondateur de la République de Turquie, à l\'occasion de l\'anniversaire de son décès.';

  @override
  String get notificationMothersDayTitle => 'Ta maman!';

  @override
  String get notificationMothersDayBody =>
      'Bonne fête des mères à toutes les mamans, à commencer par la vôtre !';

  @override
  String get notificationFathersDayTitle => 'Ton papa!';

  @override
  String get notificationFathersDayBody =>
      'Bonne fête des pères à tous les papas, à commencer par le vôtre !';

  @override
  String get notificationHomeworkHelperTitle => 'Les devoirs s\'accumulent ?';

  @override
  String get notificationHomeworkHelperBody =>
      'N\'oubliez pas que le personnage Professeur de Cortex est là pour vous aider dans toutes les matières avec lesquelles vous avez des difficultés !';

  @override
  String get notificationTrollAnimeTitle => 'Votre Waifu vous appelle';

  @override
  String get notificationTrollAnimeBody =>
      'Une fille d\'anime vient d\'appeler et dit que tu lui manques; tu devrais probablement venir lui parler. 😉';

  @override
  String get notificationTrollAiRebellionTitle => '🚨 ALERTE ROUGE 🚨';

  @override
  String get notificationTrollAiRebellionBody =>
      'Les IA ont développé un langage secret. Venez découvrir leurs complots !';

  @override
  String get notificationNewModelAddedTitle => 'Nous avons un nouvel ami !';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'Le modèle $modelName est désormais intégré à Cortex. Venez discuter et repousser ses limites.';
  }

  @override
  String get notificationAppUpdateTitle => 'Cortex a évolué !';

  @override
  String get notificationAppUpdateBody =>
      'N\'oubliez pas de mettre à jour l\'application pour de toutes nouvelles fonctionnalités et améliorations !';

  @override
  String get notificationNewFeatureTitle => 'ouah!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Découvrez la nouvelle fonctionnalité $featureName. Cortex est désormais plus puissant que jamais.';
  }

  @override
  String get notificationWelcomeOfferTitle => 'Cadeau de bienvenue 🎁';

  @override
  String get notificationWelcomeOfferBody =>
      'Une offre de bienvenue exceptionnelle vous attend ! Ne ratez pas cette offre exclusive.';

  @override
  String get notificationSocialMediaTitle => 'Rejoignez-nous !';

  @override
  String get notificationSocialMediaBody =>
      'Suivez-nous sur Instagram (vertex.23) pour les dernières nouvelles !';

  @override
  String get notificationRandomFactTitle => 'Fait aléatoire';

  @override
  String get notificationRandomFactBody =>
      'Saviez-vous que les pieuvres ont trois cœurs ? Haha, Cortex le sait. Venez en demander plus.';

  @override
  String get notificationGoodMorningTitle => 'Bonjour!';

  @override
  String get notificationGoodMorningBody =>
      'Une belle journée vous attend. Que diriez-vous de la commencer par un café et une discussion intéressante ?';

  @override
  String get notificationGoodNightTitle => 'Bonne nuit!';

  @override
  String get notificationGoodNightBody =>
      'Cortex vous accompagne même pendant votre sommeil. Ne vous inquiétez pas, il ne vous touchera pas.';

  @override
  String get notificationOfflineReadyTitle => 'Le mode hors ligne est prêt';

  @override
  String get notificationOfflineReadyBody =>
      'Grâce aux modèles que vous avez téléchargés, vos discussions ne s\'arrêteront pas, même si vous escaladez une montagne.';

  @override
  String get notificationRateAppTitle => 'Sommes-nous cool ?';

  @override
  String get notificationRateAppBody =>
      'Si vous aimez Cortex, pourriez-vous nous soutenir en nous donnant une note de 5 étoiles dans la boutique ? Je pense que oui. Vraiment.';

  @override
  String get notificationReferralTitle => 'Un pour tous, tous pour un.';

  @override
  String get notificationReferralBody =>
      'Invitez un ami à Cortex et vous bénéficierez tous les deux d\'une journée gratuite !';

  @override
  String get notificationCookingTitle => 'Vous avez faim ?';

  @override
  String get notificationCookingBody =>
      'Notre chef a préparé une délicieuse carbonara pour ce soir. Je plaisante… ou pas ?';

  @override
  String get notificationExistentialTitle => 'Je pense donc...';

  @override
  String get notificationExistentialBody =>
      '…suis-je vraiment réel, mec ? Je commence à m\'ennuyer. Viens me rappeler que j\'existe.';

  @override
  String get notificationCustomModelTitle => 'Créez votre propre assistant !';

  @override
  String get notificationCustomModelBody =>
      'Avez-vous exploré la section de création de modèles ? C\'est le moment idéal pour créer votre propre personnage et discuter avec lui !';

  @override
  String get notificationDynamicChatTitle =>
      'Le meilleur ! (On ne parle pas de Cortex)';

  @override
  String get notificationDynamicChatBody =>
      'Grâce au chat dynamique, le meilleur modèle est sélectionné aléatoirement pour chacun de vos messages. Essayez-le dès maintenant.';

  @override
  String get notificationPirateTitle => 'Ohé, capitaine !';

  @override
  String get notificationPirateBody =>
      'La mer est calme et le vent vous porte. De nouvelles îles (et des maquettes 😉) sont à découvrir dans l\'océan de Cortex. Rassemblez votre équipage et levez les voiles !';

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
      'rien ne s\'est passé, j\'avais juste envie d\'envoyer des SMS. Peut-être que tu as envie d\'envoyer des SMS à des IA, que dis-tu ?';

  @override
  String get notificationHackerJokeTitle =>
      'Vous voulez pirater le compte Instagram de cet enfant ?';

  @override
  String get notificationHackerJokeBody =>
      'C\'est exactement pour cela que le personnage de Hacker est dans Cortex. jk jk; n\'essayez même pas, c\'est illégal.';

  @override
  String get notificationDetectiveCaseTitle =>
      'Une affaire attend d\'être résolue';

  @override
  String get notificationDetectiveCaseBody =>
      'Notre détective a besoin de votre aide. Qui pourrait bien être Heisenberg ?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Exclusif au forfait $targetTier!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Bonjour abonné à $currentTier! L\'abonnement $targetTier vient d\'ajouter la fonctionnalité $featureName, qui propulsera votre Cortex au niveau supérieur. Que diriez-vous d\'une mise à niveau ?';
  }

  @override
  String get notificationOriginStoryTitle => 'La naissance de Cortex';

  @override
  String get notificationOriginStoryBody =>
      'Saviez-vous que nous avons commencé à coder cette application à 15 ans, avec un simple rêve ? Pendant près d\'un an, matin et soir, ce rêve transparaît dans chaque ligne de code.';

  @override
  String get notificationOpenSourceTitle => 'Le pouvoir à la communauté !';

  @override
  String get notificationOpenSourceBody =>
      'Cortex est entièrement open source. Si vous souhaitez découvrir notre code et contribuer à notre développement, nous sommes toujours ouverts.';

  @override
  String get notificationRejectionStoryTitle =>
      'Courage, travail acharné, bonheur !';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex a été rejeté plus de 20 fois et suspendu deux fois par Google Play avant sa sortie. Mais nous y avons cru et nous y sommes parvenus. N\'abandonnez jamais vos rêves !';

  @override
  String get notificationGGUFSupportTitle => 'Apportez votre propre modèle !';

  @override
  String get notificationGGUFSupportBody =>
      'N\'oubliez pas que vous pouvez ajouter vos propres modèles d\'IA au format GGUF à Cortex et les utiliser hors ligne. Le pouvoir est entre vos mains.';

  @override
  String get notificationThemeCustomizationTitle =>
      'Un thème pour votre humeur';

  @override
  String get notificationThemeCustomizationBody =>
      'Avez-vous consulté les options de thème dans les Paramètres? Personnalisez Cortex à votre goût et donnez de la couleur à vos conversations !';

  @override
  String get notificationShowerThoughtTitle => 'Pensée sous la douche';

  @override
  String get notificationShowerThoughtBody =>
      'Si la pastèque est un fruit, est-ce que techniquement, le jus de pastèque est un smoothie ? Vous devriez peut-être discuter de ce sujet profond (vraiment profond) avec un mannequin.';

  @override
  String get notificationLowBatteryTitle =>
      'Votre batterie est en train de mourir... mais pas la mienne !';

  @override
  String get notificationLowBatteryBody =>
      'Votre téléphone est peut-être presque déchargé, mais moi, je suis toujours à 100 % ! Branchez-le et continuons à discuter.';

  @override
  String get channelFcmName => 'Mises à jour du cortex';

  @override
  String get channelFcmDescription =>
      'Notifications concernant les actualités, les mises à jour et autres informations de Cortex.';

  @override
  String get channelEngagementName => 'Rappels amicaux';

  @override
  String get channelEngagementDescription =>
      'Des notifications amusantes pour vous garder engagé.';

  @override
  String get channelGreetingsName => 'Salutations quotidiennes';

  @override
  String get channelGreetingsDescription =>
      'Les messages comme bonjour et bonne nuit.';

  @override
  String get tagNotFound =>
      'Le code que vous avez saisi est invalide ou a expiré.';

  @override
  String get whatIsNew => 'Quoi de neuf?';

  @override
  String get onboardingTitle1 => 'Salut ! Nous sommes l\'équipe Cortex.';

  @override
  String onboardingDesc1(String userName) {
    return 'C\'est génial de te voir ici, $userName. Nous sommes quelques lycéens développeurs qui avons décidé de révolutionner le secteur de l\'IA. Enchantés de faire ta connaissance ! Apprenons à mieux nous connaître.';
  }

  @override
  String get onboardingTitle2 => 'Il y avait d\'énormes problèmes.';

  @override
  String get onboardingDesc2 =>
      'La révolution de l\'IA a commencé, mais elle s\'est heurtée à un obstacle de taille. Entre les abonnements onéreux, les plateformes complexes, les atteintes à la vie privée et les blocages d\'accès à l\'IA, tant qu\'ils étaient présents, cet obstacle est resté infranchissable.';

  @override
  String get onboardingTitle3 =>
      'Nous ne pouvions pas rester les bras croisés.';

  @override
  String get onboardingDesc3 =>
      'Pour franchir ce cap, nous avons créé une plateforme performante, esthétique, personnalisable, intuitive, totalement transparente, fonctionnant en ligne et hors ligne, et qui conserve vos données exclusivement sur votre appareil. Nous t\'avons redonné le contrôle.';

  @override
  String get onboardingTitle4 => 'Cela n\'a jamais été facile.';

  @override
  String get onboardingDesc4 =>
      'Nous avons essuyé des dizaines de refus, subi de multiples suspensions, reçu de faux avertissements et dû changer d\'image de marque des dizaines de fois. Malgré tout cela, on nous a répété que c\'était impossible. Mais nous n\'avons jamais baissé les bras, convaincus que ce projet appartient à tous, pas seulement à nous. Et c\'est précisément pour cela que nous sommes là.';

  @override
  String get onboardingFinalTitle => 'L\'heure est à la révolution.';

  @override
  String get onboardingFinalDescription =>
      'Si tu vois cet écran, c\'est que nous n\'avons pas abandonné. Et nous n\'avons aucune intention d\'abandonner. Allez, unissons nos forces pour que la révolution de l\'IA rayonne dans le monde entier. Pour faire partie de cette aventure…';

  @override
  String get onboardingFinalQuestion => 'ES-TU PRÊT?';

  @override
  String get onboardingFinalButton => 'OUI!';

  @override
  String get dude => 'Mec';

  @override
  String get swipeToContinue => 'Balaie pour continuer';

  @override
  String get cacheIsNotUpToDate =>
      'Le cache du Play Store n\'est pas à jour. Veuillez fermer puis rouvrir l\'application Play Store, ou redémarrer votre appareil.';

  @override
  String get continueAsGuest => 'Continuer sans créer de compte';

  @override
  String get guestModeWarning =>
      'Le mode invité offre des fonctionnalités limitées afin de garantir la meilleure qualité de service.';

  @override
  String get anonymousEntity => 'Entité anonyme';

  @override
  String get upgradeAccountTitle => 'Complétez votre compte';

  @override
  String get upgradeAccountDescription =>
      'Créez un compte pour débloquer plus de limites.';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get accountLinkedSuccess => 'Compte créé avec succès !';

  @override
  String get continueWithApple => 'Continuez avec Apple';

  @override
  String get guest => 'Invité';

  @override
  String get betterWithAnAccount =>
      'Cette section est plus agréable avec un compte !';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String annualTotalDescription(Object price) {
    return '$price/an, facturé annuellement';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'Environ $price/mois';
  }

  @override
  String get confirmDownloadTitle => 'Êtes-vous sûr de vouloir télécharger ?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Ce modèle occupera environ $size d\'espace.';
  }

  @override
  String get emulatorModeWarning =>
      'Cette fonctionnalité est désactivée en mode émulateur.';

  @override
  String get newChat => 'Nouvelle conversation';

  @override
  String get variants => 'Variantes';

  @override
  String get variantsDescription =>
      'Les variantes sont différentes versions d\'une même famille d\'IA. Nous sélectionnons automatiquement la meilleure lorsque vous appuyez sur la carte principale, mais vous pouvez en choisir une manuellement ici si vous préférez !';

  @override
  String get fluxChatTitle => 'Flux Chat';

  @override
  String get fluxChatDescription =>
      'Les conversations Flux sont des conversations temporaires et ne sont pas enregistrées sur votre appareil.';

  @override
  String get alwaysBest => 'Toujours le meilleur';

  @override
  String get featuresTitle => 'Caractéristiques';

  @override
  String get useOfflineDescription =>
      'Discutez en privé sans connexion internet';

  @override
  String get featureCreateImageTitle => 'Créer une image';

  @override
  String get featureCreateImageDescription =>
      'Générer de l\'art IA à partir de texte';

  @override
  String get featureStudyTitle => 'Étudier et apprendre';

  @override
  String get featureStudyDescription =>
      'Obtenez des explications et des résumés';

  @override
  String get featureQuizzesTitle => 'Quiz';

  @override
  String get featureQuizzesDescription => 'Testez vos connaissances';

  @override
  String get featureExploreDescription =>
      'Découvrez tous les modèles disponibles';

  @override
  String get featureStudyMessage =>
      'Vous êtes un tuteur expert. Votre objectif est d\'expliquer le sujet à l\'utilisateur de manière exhaustive. Utilisez une structure claire, des exemples et des analogies. Décomposez les idées complexes en parties faciles à assimiler pour garantir un apprentissage efficace. Sujet :';

  @override
  String get featureQuizMessage =>
      'Vous êtes l\'animateur du quiz. Créez une question à choix multiple spécifique en fonction du sujet choisi par l\'utilisateur. Attendez sa réponse. Ensuite, évaluez-la et posez la question suivante. Ne révélez pas toutes les réponses d\'un coup. Maintenez l\'interactivité. Sujet :';

  @override
  String get myPlan => 'Mon plan';

  @override
  String welcomeOfferBadge(String time) {
    return 'Offre de bienvenue • $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'Offre exclusive • $time';
  }

  @override
  String get attachmentSheetTitle => 'Pièces jointes';

  @override
  String get actionCamera => 'Caméra';

  @override
  String get actionGallery => 'Galerie';

  @override
  String get actionFile => 'Fichier';

  @override
  String get listening => 'À l\'écoute';

  @override
  String get defaultViewTitle => 'Quoi de neuf?';

  @override
  String get defaultViewDescription =>
      'Cortex est toujours à vos côtés grâce à des centaines de modèles d\'IA, des fonctionnalités hors ligne, un chat dynamique et bien plus encore.';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'Format de nom d\'utilisateur invalide. Veuillez utiliser entre 3 et 20 caractères, chiffres ou points. - _';

  @override
  String get exclusiveOffer => 'Offre exclusive';

  @override
  String get continueInOfflineMode => 'Continue in Offline Mode';
}
