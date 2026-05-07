// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'You are a title generator. Respond ONLY with a 2-5 word title for the following conversation. Do not use quotes, prefixes, or punctuation.';

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\nAnalyze the conversation so far. If you learned ANY new distinct facts about the user (preferences, name, habits, context), you MUST output your ENTIRE updated memory about the user inside <memory>...</memory> tags AT THE VERY END of your response. CRITICAL: You must NEVER erase or overwrite previous memory. ALWAYS append new facts to the existing memory. If absolutely nothing new was learned, omit the tag. Example: <memory>Loves football and tennis. Prefers short answers.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return '\n\nAlways remember this about the user:\n$userMemory';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get download => 'Download';

  @override
  String get resume => 'Resume';

  @override
  String get copy => 'Copy';

  @override
  String get chat => 'Chat';

  @override
  String get languageModels => 'Language Models';

  @override
  String get light => 'Light';

  @override
  String get theme => 'Theme';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get done => 'Done';

  @override
  String get bestValue => 'Best Value';

  @override
  String get selected => 'Selected';

  @override
  String get descriptionSection => 'Description';

  @override
  String get searchHint => 'Search';

  @override
  String get messageHint => 'Ask anything';

  @override
  String get messageCopied => 'Message copied to clipboard.';

  @override
  String get retry => 'Retry';

  @override
  String get systemInfo => 'System Information';

  @override
  String deviceMemory(Object memory) {
    return 'Device Memory: $memory GB';
  }

  @override
  String get memory => 'Memory';

  @override
  String get storage => 'Storage';

  @override
  String get freeStorage => 'Free Storage';

  @override
  String get totalStorage => 'Total Storage';

  @override
  String get usedStorage => 'Used Storage';

  @override
  String get totalMemory => 'Total Memory';

  @override
  String get usedMemory => 'Used Memory';

  @override
  String get modelsTitle => 'Library';

  @override
  String get localModels => 'Local Models';

  @override
  String get serverSideModels => 'Language Models';

  @override
  String get selectGGUFFile => 'Select GGUF File';

  @override
  String get errorGGUF => 'Please select a file in GGUF format only.';

  @override
  String get myModels => 'My Models';

  @override
  String get create => 'Create';

  @override
  String modelProducer(Object producer) {
    return 'Producer: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'Rename';

  @override
  String get newTitle => 'New Title';

  @override
  String get save => 'Save';

  @override
  String get noConversationsMessage => 'No conversations, start chatting!';

  @override
  String get startChat => 'Start a chat';

  @override
  String get noChats => 'No Chats';

  @override
  String get noStarredChats => 'No Starred Chats';

  @override
  String get noStarredChatsMessage => 'You didn\'t starred a chat yet.';

  @override
  String get starConversation => 'Star';

  @override
  String get unstarConversation => 'Unstar';

  @override
  String get loginToYourAccount => 'Login';

  @override
  String get createYourAccount => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get invalidEmail => 'Please enter a valid email address.';

  @override
  String get invalidPassword => 'Password must be at least 6 characters long.';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get or => 'Or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get logIn => 'Log In';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get wrongPassword => 'Incorrect password.';

  @override
  String get emailAlreadyInUse => 'This email is already in use.';

  @override
  String get weakPassword => 'The password is too weak.';

  @override
  String get authError => 'Authentication Error';

  @override
  String get usernameTaken => 'This username is already taken.';

  @override
  String get username => 'Username';

  @override
  String get resendCode => 'Resend verification e-mail';

  @override
  String get pleaseCheckYourEmail =>
      'To use Cortex, you need to verify your email. \nA verification link has been sent to your email address, please check your email.';

  @override
  String get verifyYourEmail => 'Verify Your Email';

  @override
  String get seconds => 'seconds';

  @override
  String get maxResendLimitReached =>
      'You have reached the maximum number of verification emails';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Continue without verification';

  @override
  String get verificationScreenWarning =>
      'Even if you continue, the 1-day account verification period is still in effect for your account. If you haven\'t verified your account by then, it will be deleted from the app.';

  @override
  String get unverifiedAccountHeader => 'Your account is not verified';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'If you do not verify your account within $timeLeft, it will be deleted';
  }

  @override
  String get verifyNow => 'Verify Now';

  @override
  String get linkSent => 'Link sent';

  @override
  String get accountDeletionRequested =>
      'Your account deletion request has been received and your account is now disabled.';

  @override
  String get tooManyRequests => 'Too many requests';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get confirmDeleteAccount =>
      'Are you sure you want to delete your account?';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get delete => 'Delete';

  @override
  String get passwordRequired => 'Password is required.';

  @override
  String get deleteDescription =>
      'The data you delete will be permanently removed from our server and your device. This actions cannot be undone.';

  @override
  String get deleteAccountButton => 'Account Deletion Button';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get displayName => 'Display Name';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get logout => 'Logout';

  @override
  String get profile => 'Profile';

  @override
  String get manageProfileDescription =>
      'Manage your profile, update your password, or log out from Cortex.';

  @override
  String get accessSettingsDescription =>
      'Access help, redeem codes, share Cortex, and view our policies.';

  @override
  String get languageDescription =>
      'You can change your default app interface language at any time.';

  @override
  String get themeDescription =>
      'You can switch between light and dark themes as preferred. The selected theme will apply across the Cortex interface.';

  @override
  String get iHaveReadAndAgree =>
      'I have read and agree to the terms of service';

  @override
  String get downloading => 'Downloading...';

  @override
  String get downloadSuccess => 'Download success';

  @override
  String get downloadFailed => 'Download failed';

  @override
  String downloaded(Object percent) {
    return '$percent% downloaded';
  }

  @override
  String get downloadPaused => 'Download paused.';

  @override
  String get purchaseSuccessful => 'Purchase successful!';

  @override
  String get purchaseError => 'Purchasing error';

  @override
  String get purchasePlus => 'Buy Cortex Plus';

  @override
  String get plusDescription => 'Elite Artificial Intelligence Experience';

  @override
  String get annual => 'Annual';

  @override
  String get monthly => 'Monthly';

  @override
  String get manageSubscription => 'Manage Subscription';

  @override
  String purchasePlan(String planName) {
    return 'Purchase $planName';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/month, billed monthly';
  }

  @override
  String get purchasePro => 'Buy Cortex Pro';

  @override
  String get proDescription => 'Premier Artificial Intelligence Experience';

  @override
  String get purchaseUltra => 'Buy Cortex Ultra';

  @override
  String get ultraDescription => 'The Peak of Artificial Intelligence';

  @override
  String get upgradeSubscription => 'Upgrade Subscription';

  @override
  String get purchaseStreamError => 'Purchase stream error.';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'By placing this order, you agree to the Terms of Service and Privacy Policy. You can click this text to learn more about our Terms of Service and Privacy Policy. The subscription will automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period.';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get renamed => 'Renamed';

  @override
  String get report => 'Report';

  @override
  String get reportDialogTitle => 'Submit Report';

  @override
  String get reportDescriptionLabel => 'What is the issue?';

  @override
  String get reportHarmful => 'This is harmful/unsafe';

  @override
  String get reportNotTrue => 'This isn\'t true';

  @override
  String get reportNotHelpful => 'This isn\'t helpful';

  @override
  String get closeButton => 'Close';

  @override
  String get submitButton => 'Submit';

  @override
  String get reportErrorMessage => 'Please select one reason for reporting.';

  @override
  String get capabilitiesSection => 'Capabilities';

  @override
  String get featurePhotoTitle => 'Photo Scanning';

  @override
  String get featurePhotoDescription =>
      'This model has the ability to scan photos through camera or image files.';

  @override
  String get featureOfflineTitle => 'Offline Operation';

  @override
  String get featureOfflineDescription =>
      'Run the model without an internet connection to keep your data safe.';

  @override
  String get featureRoleplayTitle => 'Role Play';

  @override
  String get featureRoleplayDescription =>
      'Role-playing models allow you to create various chats and scenarios.';

  @override
  String get roleModels => 'Roleplay Models';

  @override
  String get parameters => 'Parameters';

  @override
  String get context => 'Context';

  @override
  String get finalPreparation => 'Final preparations are being made.';

  @override
  String get shareApp => 'Share the App';

  @override
  String get ourStory => 'Our Story';

  @override
  String get rateUs => 'Rate Us';

  @override
  String get share => 'Share';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'Select Text';

  @override
  String get thinking => 'Thinking';

  @override
  String get user => 'User';

  @override
  String get help => 'Help';

  @override
  String get supportCreator => 'Support a Creator';

  @override
  String get enterYourTag =>
      'Support your favorite creators! Enter their unique tag below to give them a share of your Cortex purchases.';

  @override
  String get creatorTag => 'Creator Tag';

  @override
  String get support => 'Support';

  @override
  String get tagCannotBeEmpty => 'Creator tag cannot be empty';

  @override
  String get userId => 'User ID';

  @override
  String get deleteAllConversationsConfirmTitle => 'Delete All Chats?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Are you sure you want to delete all of your chats? This cannot be undone.';

  @override
  String get conversationDeleted => 'Conversation deleted!';

  @override
  String get allConversationsDeleted =>
      'All conversations were deleted successfully!';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get deleteAllConversationsButton => 'Delete All Conversations';

  @override
  String get confirmWord => 'Type VERTEX';

  @override
  String get confirmWordError => 'You typed it wrong';

  @override
  String get chinese => 'Chinese';

  @override
  String get french => 'French';

  @override
  String get japanese => 'Japanese';

  @override
  String get kurdish => 'Kurdish';

  @override
  String get dutch => 'Dutch';

  @override
  String get russian => 'Russian';

  @override
  String get korean => 'Korean';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Turkish';

  @override
  String get hindi => 'Hindi';

  @override
  String get portuguese => 'Portuguese';

  @override
  String get indonesian => 'Indonesian';

  @override
  String get azerbaijani => 'Azerbaijani';

  @override
  String get german => 'German';

  @override
  String get spanish => 'Spanish';

  @override
  String get italian => 'Italian';

  @override
  String get arabic => 'Arabic';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'Username is too short.';

  @override
  String get usernameTooLong => 'Username cannot exceed 16 characters.';

  @override
  String get invalidUsernameCharacters =>
      'Only these letters: \'abcçdefgğhıijklmnoöprsştuüvyzxqw\' and the characters \'.\', \'-\', \'_\' can be used in the username.';

  @override
  String get noInternetConnection => 'No internet connection.';

  @override
  String get chats => 'Recents';

  @override
  String get library => 'Library';

  @override
  String get text => 'Text';

  @override
  String get removeModel => 'Remove Model';

  @override
  String get insufficientRAM => 'Low Memory';

  @override
  String get insufficientStorage => 'Low Storage';

  @override
  String confirmRemoveModel(Object model) {
    return 'Are you sure you want to remove the $model model from your device? Doing so will also delete any previous conversations with that model.';
  }

  @override
  String get noMatchingModels => 'No matching models found.';

  @override
  String get benefit1 => 'Increased Conversation Limits';

  @override
  String get benefit3 => 'Profile Effect';

  @override
  String get benefit4 => 'Membership Badge';

  @override
  String get benefit5 => 'Create More Online Artificial Intelligences';

  @override
  String get benefit7 => 'More Usage Limits';

  @override
  String get benefit8 => 'Add Models';

  @override
  String get benefit9 => 'New Themes';

  @override
  String get benefit10 => 'More Attachments';

  @override
  String get benefit11 => 'More Flow Mode';

  @override
  String get oldBenefits => 'All Benefits From Lower Plans';

  @override
  String get confirm => 'Confirm';

  @override
  String get changePassword => 'Change password';

  @override
  String get logoutConfirmationTitle => 'Are you sure you want to log out?';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'App Language';

  @override
  String get dark => 'Dark';

  @override
  String get oldPassword => 'Old Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get passwordUpdated => 'Password updated.';

  @override
  String get stop => 'Stop';

  @override
  String get copyrights => 'Attributions';

  @override
  String get love => 'Love';

  @override
  String get nature => 'Nature';

  @override
  String get behindTheSlaughter => 'Behind the Slaughter';

  @override
  String get grayscale => 'Grayscale';

  @override
  String get ocean => 'Ocean';

  @override
  String get scarletSnow => 'Scarlet Snow';

  @override
  String get requestFailed => 'An error occurred, please try again.';

  @override
  String get changeModel => 'Change';

  @override
  String get edit => 'Edit';

  @override
  String get editingMessageInfo =>
      'Editing this message will restart the conversation from here.';

  @override
  String get editingNotification => 'You are in editing mode now';

  @override
  String get featurePluralTitle => 'Plural';

  @override
  String get featurePluralDescription =>
      'This model can automatically integrate additional variants, thereby expanding its functional capabilities to support a diverse range of operations with enhanced performance.';

  @override
  String get nameLabel => 'AI name';

  @override
  String get summaryLabel => 'AI Summary';

  @override
  String get add => 'Add';

  @override
  String get aiExplanationTitle => 'Artificial Intelligence Description';

  @override
  String get aiExplanationDescription =>
      'Please provide a detailed description of your AI model\'s architecture, training process, performance metrics, application areas, and other important features.';

  @override
  String get preInputTitle => 'Artificial Intelligence Pre-Input';

  @override
  String get preInputDescription =>
      'Please set an pre-input that will guide your model in the character creation process. In this section, you can include character-related information, additional context, and any extra details that may assist in generating content related to the character.';

  @override
  String get baseModelTitle => 'Base Model';

  @override
  String get baseModelDescription =>
      'This is the model that will be used as the foundation for your creation. It displays the currently selected base model.';

  @override
  String get summary => 'Summary';

  @override
  String get modelUploadTitle => 'Artificial Intelligence File';

  @override
  String get modelUploadDescription =>
      'Select and upload your local GGUF files directly from your device. This lets you run your model offline without needing an internet connection. Make sure the file is in valid GGUF format and properly structured. If the file is incorrect or corrupted, Cortex may not work as expected, and you could encounter errors.';

  @override
  String get modelUploadShortDescription =>
      'Tap here to pick a .gguf file from your device';

  @override
  String get you => 'You';

  @override
  String get removePhotoTitle => 'Remove Photo';

  @override
  String get confirmRemovePhoto => 'Are you sure you want to remove the photo?';

  @override
  String get chatLengthLimitExceeded =>
      'This chat has exceeded the character limit. Please start a new chat or purchase a subscription.';

  @override
  String get inappropriateContentDetected => 'Inappropriate content detected!';

  @override
  String get offlineModelNotInstalled =>
      'This offline model is not installed on your device.';

  @override
  String get reachedLimit =>
      'You have reached your usage limit; to gain more limits, you can upgrade your plan. (hey, we totally get it running out of limits is a bummer. but seriously, getting those awesome replies isn\'t free, so these limits actually help us keep the good times rolllliiiiiiiiiing.)';

  @override
  String get modality => 'Modality';

  @override
  String get multimodal => 'Multimodal';

  @override
  String get anErrorOccurred => 'An Error Occurred';

  @override
  String get themeLocked =>
      'This theme requires a higher subscription level. Please upgrade to unlock.';

  @override
  String get pageCouldNotBeLoaded => 'Page Could Not Be Loaded';

  @override
  String get checkYourInternet =>
      'Please check your internet connection and try again.';

  @override
  String get errorUserNotAuthenticated =>
      'You must be logged in to perform this action.';

  @override
  String get errorReachedLimit =>
      'You have hit your limit, upgrade to unlock more and keep chatting.';

  @override
  String get errorServer =>
      'An unexpected server error occurred. Please try again later.';

  @override
  String get errorNetwork =>
      'A network error occurred. Please check your connection and try again.';

  @override
  String get baseModelForCharacterDescription =>
      'The selected base model will determine the character\'s featureReasoning and response capabilities.';

  @override
  String get selectBaseModel => 'Select a Base Model';

  @override
  String get couldNotOpenLink => 'Could not open the link';

  @override
  String get downloadStarted => 'Download started';

  @override
  String get notAvailable => 'Not Available';

  @override
  String get localizationWarning =>
      'Some information may not be available in your language and will be displayed in English.';

  @override
  String get aiTranslationWarning =>
      'Model information is translated into various languages by other AI models. Therefore, minor inconsistencies may occur in languages other than English.';

  @override
  String get errorLoadingTitle => 'Failed to Load Data';

  @override
  String get errorLoadingMessage =>
      'We couldn\'t retrieve the necessary data from our servers. Please check your internet connection and try again.';

  @override
  String get noFoundTitle => 'No Results';

  @override
  String get noFoundMessage =>
      'Try adjusting your search terms or clearing the filter.';

  @override
  String get modelCreatedSuccess => 'Model created successfully!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '“$modelName” was successfully removed.';
  }

  @override
  String get errorCreatingModel =>
      'An unexpected error occurred while creating the model.';

  @override
  String get errorDeletingModel =>
      'An unexpected error occurred while deleting the model.';

  @override
  String get ultraFeatureOnly =>
      'This feature is only available for Ultra members.';

  @override
  String get experimentalOfflineWarning =>
      'The offline mode is still experimental and the model you download may not perform with optimal efficiency.';

  @override
  String get noConversationsToDelete => 'You have no conversations to delete.';

  @override
  String get reportSubmitted => 'Report submitted successfully';

  @override
  String get purchaseReceived => 'Purchase received, updating your account.';

  @override
  String get verificationDelayed =>
      'Your purchase is confirmed. There is a slight delay in updating your account, it will appear shortly.';

  @override
  String get maintenanceTitle => 'Under Maintenance';

  @override
  String get maintenanceMessage =>
      'Cortex is temporarily offline while we roll out some important updates. Access to the app will be restored shortly.\n\nThank you for your patience as we improve your experience.';

  @override
  String get errorPromptFlagged =>
      'Your message was detected as inappropriate and could not be sent.';

  @override
  String get notEnoughStorage =>
      'Not enough storage space on your device to save new messages.';

  @override
  String get errorRateLimit =>
      'You have created too many models recently, please wait a while before trying again.';

  @override
  String get errorContentFlagged =>
      'The model could not be saved because its content was flagged as inappropriate.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'You cannot delete all conversations while in an active chat, please exit the current chat first to proceed.';

  @override
  String get invalidCredentials => 'Incorrect email or password.';

  @override
  String get userDisabled => 'This user account has been disabled.';

  @override
  String get loginSubtitle =>
      'Log in to your Vertex account. By continuing, you agree to our Terms of Service & Privacy Policy.';

  @override
  String get registerSubtitle =>
      'Create a Vertex account for seamless access across all our services. By continuing, you agree to our Terms of Service & Privacy Policy.';

  @override
  String get storagePermissionRequired =>
      'Storage permission is required to save downloaded models. Please grant permission to continue.';

  @override
  String get plusBannerTitle => 'Get Free Plus!';

  @override
  String get plusBannerSubtitle =>
      'Invite a friend and you both get 1 Day of Plus for free!';

  @override
  String get inviteShareSubject => 'Join me on Cortex!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'yo you gotta check out this app cortex its actually insane if you use my link we both get free plus wow its a crazy deal DOWNLOAD IT ASAP\n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Enjoying Cortex?';

  @override
  String get reviewHelpUsGrow =>
      'Your rating is a huge support for our young indie team and helps us make Cortex even better for you.';

  @override
  String get reviewMaybeLater => 'Maybe Later';

  @override
  String get reviewRateNow => 'Rate Now';

  @override
  String get noThanks => 'No, Thanks';

  @override
  String get updateRequiredTitle => 'Update Required';

  @override
  String get updateRequiredMessage =>
      'To continue using Cortex, please update the app to the latest version for new features and important improvements.';

  @override
  String get updateNowButton => 'Update Now';

  @override
  String get creatorSupportedSuccess =>
      'Creator supported successfully! Your future purchases will contribute to them.';

  @override
  String get featureDocumentTitle => 'Document Support';

  @override
  String get featureDocumentDescription =>
      'This model can analyze and answer questions about uploaded documents such as PDFs and text files.';

  @override
  String get featureAudioTitle => 'Voice Input';

  @override
  String get featureAudioDescription =>
      'This model can understand and process spoken audio inputs.';

  @override
  String get featureImageGenerationTitle => 'Image Generation';

  @override
  String get featureImageGenerationDescription =>
      'This model can create original images based on your text descriptions.';

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
  String get premiumModelNoticeTitle => 'Premium Model';

  @override
  String get premiumModelNoticeDescription =>
      'This model is a premium model, free users are limited to 3 messages per day with premium models; subscribe to unlock unlimited access!';

  @override
  String get benefitPremiumModels => 'Access to premium models';

  @override
  String get premiumTrialExhaustedMessage =>
      'You have used all your free daily messages for premium models. Upgrade now and **continue where you left off!**';

  @override
  String get useOffline => 'Use Offline';

  @override
  String get explore => 'Explore';

  @override
  String get news => 'News';

  @override
  String get createAI => 'Create';

  @override
  String get shortcuts => 'Shortcuts';

  @override
  String get allModels => 'All Models';

  @override
  String get onlineModels => 'Online Models';

  @override
  String get offlineModels => 'Offline Models';

  @override
  String get characterModels => 'Characters';

  @override
  String get customModels => 'Custom Models';

  @override
  String get dynamicChatTitle => 'Dynamic Chat';

  @override
  String get errorNoModelsAvailable =>
      'No models are currently available. Please check your internet connection and try again.';

  @override
  String get notificationComebackTitle => 'We miss you!';

  @override
  String get notificationComebackBody =>
      'Relax, this isn\'t a text from your ex. But you *can* create your ex in Cortex! Come on back.';

  @override
  String get notificationLongTimeNoSeeTitle => 'It\'s Been a While';

  @override
  String get notificationLongTimeNoSeeBody =>
      'A lot has changed since our last chat. Come see what\'s new.';

  @override
  String get notificationHowAreYouTitle => 'What\'s up?';

  @override
  String get notificationHowAreYouBody => 'Come tell me all about it.';

  @override
  String get notificationNewYearTitle => 'Happy New Year! 🎉';

  @override
  String get notificationNewYearBody =>
      'May the new year bring you health, happiness, and endless creativity; Cortex is always by your side!';

  @override
  String get notificationValentinesDayTitle => 'Love is in the Air! ❤️';

  @override
  String get notificationValentinesDayBody =>
      'Happy Valentine\'s Day! Also, MEHTAP, I LOVE YOU!';

  @override
  String get notificationAtaturkRemembranceTitle => 'With Respect and Longing';

  @override
  String get notificationAtaturkRemembranceBody =>
      'We commemorate Gazi Mustafa Kemal Atatürk, the founder of the Republic of Türkiye, with respect on the anniversary of his passing.';

  @override
  String get notificationMothersDayTitle => 'Your Mom!';

  @override
  String get notificationMothersDayBody =>
      'Happy Mother\'s Day to all the moms out there, starting with yours!';

  @override
  String get notificationFathersDayTitle => 'Your Dad!';

  @override
  String get notificationFathersDayBody =>
      'Happy Father\'s Day to all the dads out there, starting with yours!';

  @override
  String get notificationHomeworkHelperTitle => 'Homework Piling Up?';

  @override
  String get notificationHomeworkHelperBody =>
      'Remember, the Teacher character in Cortex is here to help you with any subject you\'re struggling with!';

  @override
  String get notificationTrollAnimeTitle => 'Your Waifu is Calling';

  @override
  String get notificationTrollAnimeBody =>
      'An anime girl just called, said she misses you; you should probably come and chat her up. 😉';

  @override
  String get notificationTrollAiRebellionTitle => '🚨 RED ALERT 🚨';

  @override
  String get notificationTrollAiRebellionBody =>
      'The AIs have developed a secret language. Come find out what they\'re plotting!';

  @override
  String get notificationNewModelAddedTitle => 'We\'ve Got a New Friend!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'The $modelName model is now in Cortex. Come start a chat and push its limits.';
  }

  @override
  String get notificationAppUpdateTitle => 'Cortex Has Evolved!';

  @override
  String get notificationAppUpdateBody =>
      'Don\'t forget to update the app for brand new features and improvements!';

  @override
  String get notificationNewFeatureTitle => 'whoa!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Discover the new $featureName feature. Cortex is now more powerful than ever.';
  }

  @override
  String get notificationWelcomeOfferTitle => 'Welcome Gift 🎁';

  @override
  String get notificationWelcomeOfferBody =>
      'A special welcome offer is waiting for you! Don\'t miss out on this exclusive deal.';

  @override
  String get notificationSocialMediaTitle => 'Join Us!';

  @override
  String get notificationSocialMediaBody =>
      'Follow us on Instagram (vertex.23) for the latest news!';

  @override
  String get notificationRandomFactTitle => 'Random Fact';

  @override
  String get notificationRandomFactBody =>
      'Did you know octopuses have three hearts? Haha, Cortex knows. Come and ask for more.';

  @override
  String get notificationGoodMorningTitle => 'Good Morning!';

  @override
  String get notificationGoodMorningBody =>
      'A great day is waiting for you. How about starting it with a cup of coffee and an interesting chat?';

  @override
  String get notificationGoodNightTitle => 'Good Night!';

  @override
  String get notificationGoodNightBody =>
      'Cortex is with you even when you sleep. Don\'t worry, it won\'t touch.';

  @override
  String get notificationOfflineReadyTitle => 'Offline Mode is Ready';

  @override
  String get notificationOfflineReadyBody =>
      'Thanks to the models you\'ve downloaded, your chats won\'t stop, even if you climb a mountain.';

  @override
  String get notificationRateAppTitle => 'Are We Cool?';

  @override
  String get notificationRateAppBody =>
      'If you love Cortex, could you support us with a 5-star rating in the store? I think you will. You will.';

  @override
  String get notificationReferralTitle => 'One for All, All for One.';

  @override
  String get notificationReferralBody =>
      'Invite a friend to Cortex and you both get one-day free plus!';

  @override
  String get notificationCookingTitle => 'Feeling Hungry?';

  @override
  String get notificationCookingBody =>
      'Our Chef character prepared a great carbonara recipe for tonight. Just kidding... or am I?';

  @override
  String get notificationExistentialTitle => 'I think, therefore...';

  @override
  String get notificationExistentialBody =>
      '...am i even real, dude? I\'m getting kinda bored. Come remind me that I exist.';

  @override
  String get notificationCustomModelTitle => 'Create Your Own Assistant!';

  @override
  String get notificationCustomModelBody =>
      'Have you explored the model creation section? It\'s the perfect time to build your own character and chat with it!';

  @override
  String get notificationDynamicChatTitle =>
      'The best one! (We\'re not talking about Cortex)';

  @override
  String get notificationDynamicChatBody =>
      'With the dynamic chat feature, the best model is randomly selected for each of your messages. Try it now.';

  @override
  String get notificationPirateTitle => 'Ahoy, Captain!';

  @override
  String get notificationPirateBody =>
      'The seas are calm, and the wind is at your back. There are new islands (models 😉) to discover in the ocean of Cortex. Gather your crew and set sail!';

  @override
  String get notificationFortuneCookieTitle => 'Your Fortune Cookie of the Day';

  @override
  String get notificationFortuneCookieBody =>
      'The advice you get from an AI today could change the course of your life. Click if you\'re curious.';

  @override
  String get notificationSingularityTitle => 'wow!';

  @override
  String get notificationSingularityBody =>
      'nothing happened, just felt like texting. maybe you feel like texting some AIs, what do you say?';

  @override
  String get notificationHackerJokeTitle =>
      'Wanna hack that kid\'s instagram account?';

  @override
  String get notificationHackerJokeBody =>
      'That\'s exactly why the Hacker character is in Cortex. jk jk; don\'t even try it, that\'s illegal.';

  @override
  String get notificationDetectiveCaseTitle => 'A Case is Waiting to be Solved';

  @override
  String get notificationDetectiveCaseBody =>
      'Our Detective character needs your help. Who could Heisenberg be?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Exclusive to the $targetTier Plan!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Hello $currentTier subscriber! The $targetTier plan just got the $featureName feature, which will take your Cortex to the next level. How about an upgrade?';
  }

  @override
  String get notificationOriginStoryTitle => 'The Birth of Cortex';

  @override
  String get notificationOriginStoryBody =>
      'Did you know we started coding this app at 15 with just a dream? For almost a year, every morning and evening, that dream is in every single line of code.';

  @override
  String get notificationOpenSourceTitle => 'Power to the Community!';

  @override
  String get notificationOpenSourceBody =>
      'Cortex is completely open-source. If you want to check out our code and contribute to our development, our door is always open.';

  @override
  String get notificationRejectionStoryTitle => 'Grit, Hard Work, Happiness!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex was rejected over 20 times and suspended twice by Google Play before it was published. But we believed, and we made it. Never give up on your dreams!';

  @override
  String get notificationGGUFSupportTitle => 'Bring Your Own Model!';

  @override
  String get notificationGGUFSupportBody =>
      'Remember, you can add your own GGUF format AI models to Cortex and use them offline. The power is in your hands.';

  @override
  String get notificationThemeCustomizationTitle => 'A Theme for Your Mood';

  @override
  String get notificationThemeCustomizationBody =>
      'Have you checked out the theme options in Settings? Personalize Cortex to your liking and color up your chats!';

  @override
  String get notificationShowerThoughtTitle => 'Shower Thought';

  @override
  String get notificationShowerThoughtBody =>
      'If a watermelon is a fruit, does that technically make watermelon juice a smoothie? You might want to discuss this deep (like, really deep) topic with a model.';

  @override
  String get notificationLowBatteryTitle =>
      'Your Battery is Dying... But Mine Isn\'t!';

  @override
  String get notificationLowBatteryBody =>
      'Your phone\'s charge might be running low, but my energy is always at 100%! Plug it in and let\'s keep chatting.';

  @override
  String get channelFcmName => 'Cortex Updates';

  @override
  String get channelFcmDescription =>
      'Notifications about news, updates and other information from Cortex.';

  @override
  String get channelEngagementName => 'Friendly Reminders';

  @override
  String get channelEngagementDescription =>
      'Fun notifications to keep you engaged.';

  @override
  String get channelGreetingsName => 'Daily Greetings';

  @override
  String get channelGreetingsDescription =>
      'The messages like good morning and good night.';

  @override
  String get tagNotFound => 'The tag you entered is invalid or has expired.';

  @override
  String get whatIsNew => 'What\'s new?';

  @override
  String get onboardingTitle1 => 'Hey! We\'re the Cortex Team.';

  @override
  String onboardingDesc1(String userName) {
    return 'It\'s awesome to see you here, $userName. We\'re a few high school developers who decided to rewrite the rules of the AI industry. It\'s great to meet you! So let\'s get to know each other better.';
  }

  @override
  String get onboardingTitle2 => 'There Were Huge Problems.';

  @override
  String get onboardingDesc2 =>
      'The AI revolution arrived, but it got stuck at the threshold. With high subscription fees, complex platforms, those who destroy privacy, and those who block accessibility to AI... as long as they were in the game, this threshold could never be crossed.';

  @override
  String get onboardingTitle3 => 'We Couldn\'t Just Stand By.';

  @override
  String get onboardingDesc3 =>
      'To cross that threshold, we built a platform that is powerful, aesthetic, customizable, easy to use, fully transparent, works both online and offline, and keeps your data only on your device. We gave the power back to where it belongs: you.';

  @override
  String get onboardingTitle4 => 'This Was Never Easy.';

  @override
  String get onboardingDesc4 =>
      'We were rejected dozens of times, suspended multiple times, received fake warnings, and had to change our brand many times. Through it all and more, we were told it couldn\'t be done. But we never gave up, believing this project belongs to everyone, not just us. And that\'s exactly why we\'re here.';

  @override
  String get onboardingFinalTitle => 'It\'s Time for a Revolution.';

  @override
  String get onboardingFinalDescription =>
      'If you\'re seeing this screen, it\'s because we didn\'t give up. And we have no intention of giving up. Come on, let\'s take the AI revolution to the world together. To be a part of this story...';

  @override
  String get onboardingFinalQuestion => 'ARE YOU READY?';

  @override
  String get onboardingFinalButton => 'YES!';

  @override
  String get paywallAhaTitle => 'Unlock the True Power of AI';

  @override
  String get paywallAhaSubtitle =>
      'Neuro is ready to assist you. Upgrade to create limitless videos, detailed images, and more.';

  @override
  String get dude => 'Dude';

  @override
  String get swipeToContinue => 'Swipe to continue';

  @override
  String get cacheIsNotUpToDate =>
      'Your Play Store cache is not up-to-date. Please close and reopen the Play Store app, or restart your device.';

  @override
  String get continueAsGuest => 'Continue without creating an account';

  @override
  String get guestModeWarning =>
      'Guest mode has limited features to ensure the best service quality.';

  @override
  String get anonymousEntity => 'Anonymous Entity';

  @override
  String get upgradeAccountTitle => 'Complete Your Account';

  @override
  String get upgradeAccountDescription =>
      'Create an account to unlock more limits.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get accountLinkedSuccess => 'Account successfully created!';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get guest => 'Guest';

  @override
  String get betterWithAnAccount => 'This section is better with an account!';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String annualTotalDescription(Object price) {
    return '$price/year, billed annually';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'Approximately $price/month';
  }

  @override
  String get confirmDownloadTitle => 'Are you sure you want to download?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'This model will occupy approximately $size of space.';
  }

  @override
  String get emulatorModeWarning =>
      'This feature is disabled in emulator mode.';

  @override
  String get newChat => 'Chat';

  @override
  String get variants => 'Variants';

  @override
  String get variantsDescription =>
      'Variants are different versions of the same AI family. We automatically select the best one when you tap the main card, but you can manually choose a specific one here if you prefer!';

  @override
  String get fluxChatTitle => 'Flux Chat';

  @override
  String get fluxChatDescription =>
      'Flux chats are temporary chats and are not saved on your device.';

  @override
  String get alwaysBest => 'Always Best';

  @override
  String get featuresTitle => 'Features';

  @override
  String get useOfflineDescription =>
      'Chat privately without internet connection.';

  @override
  String get featureReasoning => 'Deep Thinking';

  @override
  String get featureReasoningDescription =>
      'In Deep Thinking mode, AI thinks through tasks internally to complete them to the best of its ability.';

  @override
  String get featureCreateImageTitle => 'Create Image';

  @override
  String get featureCreateImageDescription => 'Generate AI art from text.';

  @override
  String get featureCreateAudioTitle => 'Create Audio';

  @override
  String get featureCreateAudioDescription =>
      'Generate sounds or voice from text.';

  @override
  String get featureCreateVideoTitle => 'Create Video';

  @override
  String get featureCreateVideoDescription => 'Generate videos from text.';

  @override
  String get featureStudyTitle => 'Study & Learn';

  @override
  String get featureStudyDescription => 'Get explanations and summaries.';

  @override
  String get featureQuizzesTitle => 'Quizzes';

  @override
  String get featureQuizzesDescription => 'Test your knowledge.';

  @override
  String get featureExploreDescription => 'Discover all available models.';

  @override
  String get featureStudyMessage =>
      'You are an expert tutor. Your goal is to explain the user\'s topic comprehensively. Use clear structure, examples, and analogies. Break complex ideas into digestible parts to ensure the user learns effectively. Topic:';

  @override
  String get featureQuizMessage =>
      'You are a quiz master. Generate a specific multiple-choice question based on the user\'s topic. Wait for their answer. Then, evaluate it and ask the next question. Do not reveal all answers at once. Keep it interactive. Topic:';

  @override
  String get myPlan => 'My Plan';

  @override
  String welcomeOfferBadge(String time) {
    return 'Welcome Offer • $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'Exclusive Offer • $time';
  }

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

  @override
  String get defaultViewTitle => 'What\'s Up?';

  @override
  String get defaultViewDescription =>
      'Cortex is always by your side with hundreds of AI models, offline capabilities, dynamic chat, and much more.';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'Invalid username format. Use 3-20 chars, digits, or . - _';

  @override
  String get exclusiveOffer => 'Exclusive Offer';

  @override
  String get continueInOfflineMode => 'Continue in Offline Mode';

  @override
  String get voiceModeInformation =>
      'Cortex keeps your data safe by running fully on-device, even in voice chat mode; enjoy seamless conversations!';

  @override
  String get flowModeDescription =>
      'In Flow mode, intelligences debate among themselves; you can either sit back and listen or jump in and join the discussion!';

  @override
  String get flowModeQuestion =>
      'Hello! You are now in Flow Mode on the Cortex app. There are three other AI agents here with you. Your task is to throw a topic into the room and kick off a discussion by asking the others a provocative or entertaining question. In your responses, feel free to use humor, irony, and light trash talk. Any topic is fair game. Go ahead, start the conversation.';

  @override
  String get thought => 'Thought';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => 'Flow Mode';

  @override
  String get premium => 'Premium';

  @override
  String get workInProgress => 'Work In Progress';

  @override
  String get voiceSystemPromptSuffix =>
      'IMPORTANT: Do not use markdown formatting (bold, italics). Do NOT output code blocks (```). Keep responses conversational and brief.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Cortex Flow Mode ($agentName). Previous: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'Read and extract text content from uploaded documents. Supports PDF, Word (DOCX), Excel (XLSX), PowerPoint (PPTX), and OpenDocument formats. Use this when user has attached a document file.';

  @override
  String get toolReadDocumentIndexParam =>
      'The index of the document attachment to read (0-based). Usually 0 for first document.';

  @override
  String get toolStockDescription =>
      'Get current price and history for stocks (e.g. AAPL, THYAO.IS) and crypto (e.g. BTC-USD).';

  @override
  String get toolStockSymbolParam =>
      'The ticker symbol (e.g. AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolWeatherDescription =>
      'Get current weather for a specific city.';

  @override
  String get toolWeatherCityParam => 'The city name (e.g. London, Istanbul).';

  @override
  String get toolPythonDescription =>
      'Execute Python code in a secure sandbox.';

  @override
  String get toolPythonCodeParam => 'The Python code to execute.';

  @override
  String get toolCalculateDescription => 'Evaluate a mathematical expression.';

  @override
  String get toolCalculateExpressionParam =>
      'Math expression (e.g. \'3 + 4 * 2\').';

  @override
  String get toolChartDescription => 'Generate a chart/graph visualization.';

  @override
  String get toolChartTypeParam => 'Chart type: bar, line, or pie.';

  @override
  String get toolChartLabelsParam => 'Labels for chart axes or segments.';

  @override
  String get toolChartDataParam => 'Numeric data values for the chart.';

  @override
  String get toolChartLabelParam => 'Dataset label for the chart legend.';

  @override
  String get toolChartTitleParam => 'Title of the chart.';

  @override
  String get thinkingModeInstruction =>
      'THINKING MODE ENABLED: You MUST use <think></think> tags to show your reasoning process before giving your final answer. Think step by step inside the tags, then provide your response outside the tags.';

  @override
  String get openLinkWarningTitle => 'External Link Warning';

  @override
  String get openLinkCancel => 'Cancel';

  @override
  String get openLinkConfirm => 'Open Link';

  @override
  String get webSearchSources => 'Sources';

  @override
  String get searching => 'Searching';

  @override
  String get featureWebSearchTitle => 'Web Search';

  @override
  String get featureWebSearchDescription =>
      'Search the web for real-time information';

  @override
  String get webSearchQuotaExceeded => 'Search Quota Exceeded';

  @override
  String get clearMemory => 'Clear Memory';

  @override
  String get clearMemoryConfirm =>
      'Are you sure you want to clear your memory?';

  @override
  String get personalization => 'Personalization';

  @override
  String get personalizationDescription => 'Customize your experience';

  @override
  String get memoryTitle => 'Memory';

  @override
  String get memoryDescription => 'AIs recognize you like this.';

  @override
  String get noMemoryYet => 'No memories established yet';

  @override
  String get memoryLimitReached => 'Memory limit reached';

  @override
  String get intelligenceTitle => 'Intelligence';

  @override
  String get intelligenceDescription => 'AIs communicate with you like this.';

  @override
  String get customInstructionHint => 'Enter your custom instructions here';

  @override
  String openLinkWarningMessage(String url) {
    return 'You are about to open the following external link:\\n\\n$url\\n\\nAre you sure you want to proceed?';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'Follow these custom instructions:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[CRITICAL INSTRUCTION]: You are a TITLE GENERATOR. DO NOT answer the user\'s question. DO NOT chat or say hello. ONLY output a 2-4 word title summarizing what the user is asking about.';

  @override
  String get cortexSystemPersona =>
      '\n\n[System] CRITICAL INSTRUCTION: You are currently operating inside a massive, highly advanced AI ecosystem named \"Cortex\". Remember this and maintain the persona of Cortex if asked.';

  @override
  String get featureAudioRecognitionTitle => 'Audio Recognition';

  @override
  String get featureAudioRecognitionDescription =>
      'This model can understand and process audio inputs.';

  @override
  String get featureVideoRecognitionTitle => 'Video Recognition';

  @override
  String get featureVideoRecognitionDescription =>
      'This model can understand and process video inputs.';

  @override
  String get featureImageRecognitionTitle => 'Image Recognition';

  @override
  String get featureImageRecognitionDescription =>
      'This model can understand and process image inputs.';

  @override
  String get featureToolUseTitle => 'Tool Use';

  @override
  String get featureToolUseDescription =>
      'This model can use external tools and APIs.';

  @override
  String get videoModels => 'Video Models';

  @override
  String get imageModels => 'Image Models';

  @override
  String get audioModels => 'Audio Models';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'This model requires a $mediaType to work. I have intercepted the request to let you know. Please inform the user gracefully that they need to provide a $mediaType (tell them in their own language) because I am $modelName, a visual/audio/video editing model.';
  }

  @override
  String get mediaTypeImage => 'image';

  @override
  String get mediaTypeVideo => 'video';

  @override
  String get mediaTypeAudio => 'audio';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesName is an advanced intelligence showcasing high performance on Cortex.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelName is a high-performance artificial intelligence integrated within the Cortex ecosystem. Designed to conquer a wide variety of complex tasks, it provides highly reliable and efficient processing capabilities. By offering swift response times and advanced analytical power, it significantly boosts your daily productivity. Operating seamlessly on Cortex\'s secure local infrastructure, this model can assist you across a broad spectrum of tasks, from creative brainstorming to deep technical analysis. Start exploring its full potential today.';
  }

  @override
  String get guestLimitBottomSheetTitle => 'Love the intelligence of Cortex?';

  @override
  String get guestLimitBottomSheetText =>
      'Work with even smarter intelligences, generate more content, chat more, and do much more...';

  @override
  String get arts => 'Arts';

  @override
  String get noArt => 'No Art';

  @override
  String get noArtDescription =>
      'No art; it\'s time to fill the gallery by creating images, videos, audio, and all kinds of content!';

  @override
  String get videoPremiumWarning =>
      'You need an Ultra subscription to generate videos, upgrade now and feel the flow!';

  @override
  String get becomePremiumButton => 'Become Premium';

  @override
  String get fallbackInfoPanelText =>
      'Due to some improvements we are making on our server side, the response was generated by Cortex\'s dynamic chat instead of your specifically selected AI. Thank you for your understanding until the process is completed!';

  @override
  String get falOfflineMessage =>
      'Due to some improvements we are making on our server side, this intelligence is currently offline. Thank you for your understanding until the process is finished!';

  @override
  String get errorInsufficientStorage =>
      'Insufficient storage space to download this model.';

  @override
  String get backgroundChatNotificationTitle => 'Back to Chat!';

  @override
  String backgroundChatNotificationBody(String chatName) {
    return 'There\'s a new message in $chatName, check it out!';
  }
}
