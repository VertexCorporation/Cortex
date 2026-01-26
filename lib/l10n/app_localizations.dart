import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_az.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ku.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
    Locale('ar'),
    Locale('az'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('ku'),
    Locale('nl'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh')
  ];

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @descriptionSection.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionSection;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Ask anything'**
  String get messageHint;

  /// No description provided for @messageCopied.
  ///
  /// In en, this message translates to:
  /// **'Message copied to clipboard.'**
  String get messageCopied;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @systemInfo.
  ///
  /// In en, this message translates to:
  /// **'System Information'**
  String get systemInfo;

  /// No description provided for @deviceMemory.
  ///
  /// In en, this message translates to:
  /// **'Device Memory: {memory} GB'**
  String deviceMemory(Object memory);

  /// No description provided for @memory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get memory;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @freeStorage.
  ///
  /// In en, this message translates to:
  /// **'Free Storage'**
  String get freeStorage;

  /// No description provided for @totalStorage.
  ///
  /// In en, this message translates to:
  /// **'Total Storage'**
  String get totalStorage;

  /// No description provided for @usedStorage.
  ///
  /// In en, this message translates to:
  /// **'Used Storage'**
  String get usedStorage;

  /// No description provided for @totalMemory.
  ///
  /// In en, this message translates to:
  /// **'Total Memory'**
  String get totalMemory;

  /// No description provided for @usedMemory.
  ///
  /// In en, this message translates to:
  /// **'Used Memory'**
  String get usedMemory;

  /// No description provided for @modelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get modelsTitle;

  /// No description provided for @localModels.
  ///
  /// In en, this message translates to:
  /// **'Local Models'**
  String get localModels;

  /// No description provided for @serverSideModels.
  ///
  /// In en, this message translates to:
  /// **'Online Models'**
  String get serverSideModels;

  /// No description provided for @selectGGUFFile.
  ///
  /// In en, this message translates to:
  /// **'Select GGUF File'**
  String get selectGGUFFile;

  /// No description provided for @errorGGUF.
  ///
  /// In en, this message translates to:
  /// **'Please select a file in GGUF format only.'**
  String get errorGGUF;

  /// No description provided for @myModels.
  ///
  /// In en, this message translates to:
  /// **'My Models'**
  String get myModels;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @modelProducer.
  ///
  /// In en, this message translates to:
  /// **'Producer: {producer}'**
  String modelProducer(Object producer);

  /// No description provided for @modelDescription.
  ///
  /// In en, this message translates to:
  /// **'{description}'**
  String modelDescription(Object description);

  /// No description provided for @editConversationTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get editConversationTitle;

  /// No description provided for @newTitle.
  ///
  /// In en, this message translates to:
  /// **'New Title'**
  String get newTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @noConversationsMessage.
  ///
  /// In en, this message translates to:
  /// **'No conversations, start chatting!'**
  String get noConversationsMessage;

  /// No description provided for @startChat.
  ///
  /// In en, this message translates to:
  /// **'Start a chat'**
  String get startChat;

  /// No description provided for @noChats.
  ///
  /// In en, this message translates to:
  /// **'No Chats'**
  String get noChats;

  /// No description provided for @noStarredChats.
  ///
  /// In en, this message translates to:
  /// **'No Starred Chats'**
  String get noStarredChats;

  /// No description provided for @noStarredChatsMessage.
  ///
  /// In en, this message translates to:
  /// **'You didn\'t starred a chat yet.'**
  String get noStarredChatsMessage;

  /// No description provided for @starConversation.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get starConversation;

  /// No description provided for @unstarConversation.
  ///
  /// In en, this message translates to:
  /// **'Unstar'**
  String get unstarConversation;

  /// No description provided for @loginToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginToYourAccount;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get createYourAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long.'**
  String get invalidPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get wrongPassword;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get emailAlreadyInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak.'**
  String get weakPassword;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Authentication Error'**
  String get authError;

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken.'**
  String get usernameTaken;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend verification e-mail'**
  String get resendCode;

  /// No description provided for @pleaseCheckYourEmail.
  ///
  /// In en, this message translates to:
  /// **'To use Cortex, you need to verify your email. \nA verification link has been sent to your email address, please check your email.'**
  String get pleaseCheckYourEmail;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyYourEmail;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @maxResendLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You have reached the maximum number of verification emails'**
  String get maxResendLimitReached;

  /// No description provided for @verificationScreenContinueWithoutVerification.
  ///
  /// In en, this message translates to:
  /// **'Continue without verification'**
  String get verificationScreenContinueWithoutVerification;

  /// No description provided for @verificationScreenWarning.
  ///
  /// In en, this message translates to:
  /// **'Even if you continue, the 1-day account verification period is still in effect for your account. If you haven\'t verified your account by then, it will be deleted from the app.'**
  String get verificationScreenWarning;

  /// No description provided for @unverifiedAccountHeader.
  ///
  /// In en, this message translates to:
  /// **'Your account is not verified'**
  String get unverifiedAccountHeader;

  /// No description provided for @unverifiedAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'If you do not verify your account within {timeLeft}, it will be deleted'**
  String unverifiedAccountWarning(Object timeLeft);

  /// No description provided for @verifyNow.
  ///
  /// In en, this message translates to:
  /// **'Verify Now'**
  String get verifyNow;

  /// No description provided for @linkSent.
  ///
  /// In en, this message translates to:
  /// **'Link sent'**
  String get linkSent;

  /// No description provided for @accountDeletionRequested.
  ///
  /// In en, this message translates to:
  /// **'Your account deletion request has been received and your account is now disabled.'**
  String get accountDeletionRequested;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests'**
  String get tooManyRequests;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get confirmDeleteAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get passwordRequired;

  /// No description provided for @deleteDescription.
  ///
  /// In en, this message translates to:
  /// **'The data you delete will be permanently removed from our server and your device. This actions cannot be undone.'**
  String get deleteDescription;

  /// No description provided for @deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Account Deletion Button'**
  String get deleteAccountButton;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @manageProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your profile, update your password, or log out from Cortex.'**
  String get manageProfileDescription;

  /// No description provided for @accessSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Access help, redeem codes, share Cortex, and view our policies.'**
  String get accessSettingsDescription;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'You can change your default app interface language at any time.'**
  String get languageDescription;

  /// No description provided for @themeDescription.
  ///
  /// In en, this message translates to:
  /// **'You can switch between light and dark themes as preferred. The selected theme will apply across the Cortex interface.'**
  String get themeDescription;

  /// No description provided for @iHaveReadAndAgree.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the terms of service'**
  String get iHaveReadAndAgree;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// No description provided for @downloadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Download success'**
  String get downloadSuccess;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get downloadFailed;

  /// Indicates the percentage of the download completed.
  ///
  /// In en, this message translates to:
  /// **'{percent}% downloaded'**
  String downloaded(Object percent);

  /// No description provided for @downloadPaused.
  ///
  /// In en, this message translates to:
  /// **'Download paused.'**
  String get downloadPaused;

  /// No description provided for @purchaseSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Purchase successful!'**
  String get purchaseSuccessful;

  /// No description provided for @purchaseError.
  ///
  /// In en, this message translates to:
  /// **'Purchasing error'**
  String get purchaseError;

  /// No description provided for @purchasePlus.
  ///
  /// In en, this message translates to:
  /// **'Buy Cortex Plus'**
  String get purchasePlus;

  /// No description provided for @plusDescription.
  ///
  /// In en, this message translates to:
  /// **'Elite Artificial Intelligence Experience'**
  String get plusDescription;

  /// No description provided for @annual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get annual;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// Button text for purchasing a specific subscription plan.
  ///
  /// In en, this message translates to:
  /// **'Purchase {planName}'**
  String purchasePlan(String planName);

  /// The description for the monthly plan, showing the price per month. Example: $4.99/mo, billed monthly
  ///
  /// In en, this message translates to:
  /// **'{price}/month, billed monthly'**
  String monthlyPlanDescription(String price);

  /// No description provided for @purchasePro.
  ///
  /// In en, this message translates to:
  /// **'Buy Cortex Pro'**
  String get purchasePro;

  /// No description provided for @proDescription.
  ///
  /// In en, this message translates to:
  /// **'Premier Artificial Intelligence Experience'**
  String get proDescription;

  /// No description provided for @purchaseUltra.
  ///
  /// In en, this message translates to:
  /// **'Buy Cortex Ultra'**
  String get purchaseUltra;

  /// No description provided for @ultraDescription.
  ///
  /// In en, this message translates to:
  /// **'The Peak of Artificial Intelligence'**
  String get ultraDescription;

  /// No description provided for @upgradeSubscription.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Subscription'**
  String get upgradeSubscription;

  /// No description provided for @purchaseStreamError.
  ///
  /// In en, this message translates to:
  /// **'Purchase stream error.'**
  String get purchaseStreamError;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @termsOfServiceAndPrivacyPolicyWarning.
  ///
  /// In en, this message translates to:
  /// **'By placing this order, you agree to the Terms of Service and Privacy Policy. You can click this text to learn more about our Terms of Service and Privacy Policy. The subscription will automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period.'**
  String get termsOfServiceAndPrivacyPolicyWarning;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @reportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get reportDialogTitle;

  /// No description provided for @reportDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'What is the issue?'**
  String get reportDescriptionLabel;

  /// No description provided for @reportHarmful.
  ///
  /// In en, this message translates to:
  /// **'This is harmful/unsafe'**
  String get reportHarmful;

  /// No description provided for @reportNotTrue.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t true'**
  String get reportNotTrue;

  /// No description provided for @reportNotHelpful.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t helpful'**
  String get reportNotHelpful;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @submitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// No description provided for @reportErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select one reason for reporting.'**
  String get reportErrorMessage;

  /// No description provided for @capabilitiesSection.
  ///
  /// In en, this message translates to:
  /// **'Capabilities'**
  String get capabilitiesSection;

  /// No description provided for @featurePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Scanning'**
  String get featurePhotoTitle;

  /// No description provided for @featurePhotoDescription.
  ///
  /// In en, this message translates to:
  /// **'This model has the ability to scan photos through camera or image files.'**
  String get featurePhotoDescription;

  /// No description provided for @featureOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline Operation'**
  String get featureOfflineTitle;

  /// No description provided for @featureOfflineDescription.
  ///
  /// In en, this message translates to:
  /// **'Run the model without an internet connection to keep your data safe.'**
  String get featureOfflineDescription;

  /// No description provided for @featureRoleplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Role Play'**
  String get featureRoleplayTitle;

  /// No description provided for @featureRoleplayDescription.
  ///
  /// In en, this message translates to:
  /// **'Role-playing models allow you to create various chats and scenarios.'**
  String get featureRoleplayDescription;

  /// No description provided for @roleModels.
  ///
  /// In en, this message translates to:
  /// **'Roleplay Models'**
  String get roleModels;

  /// No description provided for @parameters.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get parameters;

  /// No description provided for @context.
  ///
  /// In en, this message translates to:
  /// **'Context'**
  String get context;

  /// No description provided for @finalPreparation.
  ///
  /// In en, this message translates to:
  /// **'Final preparations are being made.'**
  String get finalPreparation;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share the App'**
  String get shareApp;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get rateUs;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareSubject.
  ///
  /// In en, this message translates to:
  /// **'Cortex'**
  String get shareSubject;

  /// The message sent when sharing the app
  ///
  /// In en, this message translates to:
  /// **'Check out the Cortex app, it is so amazing! Download it here: {cortexLink}'**
  String shareMessage(String cortexLink);

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to share the app. Please try again later'**
  String get shareFailed;

  /// No description provided for @selectText.
  ///
  /// In en, this message translates to:
  /// **'Select Text'**
  String get selectText;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get thinking;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @supportCreator.
  ///
  /// In en, this message translates to:
  /// **'Support a Creator'**
  String get supportCreator;

  /// No description provided for @enterYourTag.
  ///
  /// In en, this message translates to:
  /// **'Support your favorite creators! Enter their unique tag below to give them a share of your Cortex purchases.'**
  String get enterYourTag;

  /// No description provided for @creatorTag.
  ///
  /// In en, this message translates to:
  /// **'Creator Tag'**
  String get creatorTag;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @tagCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Creator tag cannot be empty'**
  String get tagCannotBeEmpty;

  /// No description provided for @userId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// No description provided for @deleteAllConversationsConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Chats?'**
  String get deleteAllConversationsConfirmTitle;

  /// No description provided for @deleteAllConversationsConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all of your chats? This cannot be undone.'**
  String get deleteAllConversationsConfirmMessage;

  /// No description provided for @conversationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted!'**
  String get conversationDeleted;

  /// No description provided for @allConversationsDeleted.
  ///
  /// In en, this message translates to:
  /// **'All conversations were deleted successfully!'**
  String get allConversationsDeleted;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @deleteAllConversationsButton.
  ///
  /// In en, this message translates to:
  /// **'Delete All Conversations'**
  String get deleteAllConversationsButton;

  /// No description provided for @confirmWord.
  ///
  /// In en, this message translates to:
  /// **'Type VERTEX'**
  String get confirmWord;

  /// No description provided for @confirmWordError.
  ///
  /// In en, this message translates to:
  /// **'You typed it wrong'**
  String get confirmWordError;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// No description provided for @kurdish.
  ///
  /// In en, this message translates to:
  /// **'Kurdish'**
  String get kurdish;

  /// No description provided for @dutch.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get dutch;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portuguese;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get indonesian;

  /// No description provided for @azerbaijani.
  ///
  /// In en, this message translates to:
  /// **'Azerbaijani'**
  String get azerbaijani;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @ram.
  ///
  /// In en, this message translates to:
  /// **'RAM'**
  String get ram;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Username is too short.'**
  String get usernameTooShort;

  /// No description provided for @usernameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Username cannot exceed 16 characters.'**
  String get usernameTooLong;

  /// No description provided for @invalidUsernameCharacters.
  ///
  /// In en, this message translates to:
  /// **'Only these letters: \'abcçdefgğhıijklmnoöprsştuüvyzxqw\' and the characters \'.\', \'-\', \'_\' can be used in the username.'**
  String get invalidUsernameCharacters;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get noInternetConnection;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get chats;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @removeModel.
  ///
  /// In en, this message translates to:
  /// **'Remove Model'**
  String get removeModel;

  /// No description provided for @insufficientRAM.
  ///
  /// In en, this message translates to:
  /// **'Low Memory'**
  String get insufficientRAM;

  /// No description provided for @insufficientStorage.
  ///
  /// In en, this message translates to:
  /// **'Low Storage'**
  String get insufficientStorage;

  /// No description provided for @confirmRemoveModel.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the {model} model from your device? Doing so will also delete any previous conversations with that model.'**
  String confirmRemoveModel(Object model);

  /// No description provided for @noMatchingModels.
  ///
  /// In en, this message translates to:
  /// **'No matching models found.'**
  String get noMatchingModels;

  /// No description provided for @benefit1.
  ///
  /// In en, this message translates to:
  /// **'Increased Conversation Limits'**
  String get benefit1;

  /// No description provided for @benefit3.
  ///
  /// In en, this message translates to:
  /// **'Profile Effect'**
  String get benefit3;

  /// No description provided for @benefit4.
  ///
  /// In en, this message translates to:
  /// **'Membership Badge'**
  String get benefit4;

  /// No description provided for @benefit5.
  ///
  /// In en, this message translates to:
  /// **'Create More Online Artificial Intelligences'**
  String get benefit5;

  /// No description provided for @benefit7.
  ///
  /// In en, this message translates to:
  /// **'More Usage Limits'**
  String get benefit7;

  /// No description provided for @benefit8.
  ///
  /// In en, this message translates to:
  /// **'Add Models'**
  String get benefit8;

  /// No description provided for @benefit9.
  ///
  /// In en, this message translates to:
  /// **'New Themes'**
  String get benefit9;

  /// No description provided for @benefit10.
  ///
  /// In en, this message translates to:
  /// **'More Attachments'**
  String get benefit10;

  /// No description provided for @benefit11.
  ///
  /// In en, this message translates to:
  /// **'Limitless Flow Mode'**
  String get benefit11;

  /// No description provided for @benefit12.
  ///
  /// In en, this message translates to:
  /// **''**
  String get benefit12;

  /// No description provided for @oldBenefits.
  ///
  /// In en, this message translates to:
  /// **'All Benefits From Lower Plans'**
  String get oldBenefits;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @logoutConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmationTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get language;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated.'**
  String get passwordUpdated;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @copyrights.
  ///
  /// In en, this message translates to:
  /// **'Attributions'**
  String get copyrights;

  /// No description provided for @love.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get love;

  /// No description provided for @nature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get nature;

  /// No description provided for @behindTheSlaughter.
  ///
  /// In en, this message translates to:
  /// **'Behind the Slaughter'**
  String get behindTheSlaughter;

  /// No description provided for @grayscale.
  ///
  /// In en, this message translates to:
  /// **'Grayscale'**
  String get grayscale;

  /// No description provided for @ocean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get ocean;

  /// No description provided for @scarletSnow.
  ///
  /// In en, this message translates to:
  /// **'Scarlet Snow'**
  String get scarletSnow;

  /// No description provided for @requestFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, please try again.'**
  String get requestFailed;

  /// No description provided for @changeModel.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeModel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editingMessageInfo.
  ///
  /// In en, this message translates to:
  /// **'Editing this message will restart the conversation from here.'**
  String get editingMessageInfo;

  /// No description provided for @editingNotification.
  ///
  /// In en, this message translates to:
  /// **'You are in editing mode now'**
  String get editingNotification;

  /// No description provided for @featurePluralTitle.
  ///
  /// In en, this message translates to:
  /// **'Plural'**
  String get featurePluralTitle;

  /// No description provided for @featurePluralDescription.
  ///
  /// In en, this message translates to:
  /// **'This model can automatically integrate additional variants, thereby expanding its functional capabilities to support a diverse range of operations with enhanced performance.'**
  String get featurePluralDescription;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'AI name'**
  String get nameLabel;

  /// No description provided for @summaryLabel.
  ///
  /// In en, this message translates to:
  /// **'AI Summary'**
  String get summaryLabel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @aiExplanationTitle.
  ///
  /// In en, this message translates to:
  /// **'Artificial Intelligence Description'**
  String get aiExplanationTitle;

  /// No description provided for @aiExplanationDescription.
  ///
  /// In en, this message translates to:
  /// **'Please provide a detailed description of your AI model\'s architecture, training process, performance metrics, application areas, and other important features.'**
  String get aiExplanationDescription;

  /// No description provided for @preInputTitle.
  ///
  /// In en, this message translates to:
  /// **'Artificial Intelligence Pre-Input'**
  String get preInputTitle;

  /// No description provided for @preInputDescription.
  ///
  /// In en, this message translates to:
  /// **'Please set an pre-input that will guide your model in the character creation process. In this section, you can include character-related information, additional context, and any extra details that may assist in generating content related to the character.'**
  String get preInputDescription;

  /// No description provided for @baseModelTitle.
  ///
  /// In en, this message translates to:
  /// **'Base Model'**
  String get baseModelTitle;

  /// No description provided for @baseModelDescription.
  ///
  /// In en, this message translates to:
  /// **'This is the model that will be used as the foundation for your creation. It displays the currently selected base model.'**
  String get baseModelDescription;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @modelUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Artificial Intelligence File'**
  String get modelUploadTitle;

  /// No description provided for @modelUploadDescription.
  ///
  /// In en, this message translates to:
  /// **'Select and upload your local GGUF files directly from your device. This lets you run your model offline without needing an internet connection. Make sure the file is in valid GGUF format and properly structured. If the file is incorrect or corrupted, Cortex may not work as expected, and you could encounter errors.'**
  String get modelUploadDescription;

  /// No description provided for @modelUploadShortDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap here to pick a .gguf file from your device'**
  String get modelUploadShortDescription;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @removePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhotoTitle;

  /// No description provided for @confirmRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the photo?'**
  String get confirmRemovePhoto;

  /// No description provided for @chatLengthLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'This chat has exceeded the character limit. Please start a new chat or purchase a subscription.'**
  String get chatLengthLimitExceeded;

  /// No description provided for @inappropriateContentDetected.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content detected!'**
  String get inappropriateContentDetected;

  /// No description provided for @offlineModelNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'This offline model is not installed on your device.'**
  String get offlineModelNotInstalled;

  /// No description provided for @reachedLimit.
  ///
  /// In en, this message translates to:
  /// **'You have reached your usage limit; to gain more limits, you can upgrade your plan. (hey, we totally get it running out of limits is a bummer. but seriously, getting those awesome replies isn\'t free, so these limits actually help us keep the good times rolllliiiiiiiiiing.)'**
  String get reachedLimit;

  /// No description provided for @modality.
  ///
  /// In en, this message translates to:
  /// **'Modality'**
  String get modality;

  /// No description provided for @multimodal.
  ///
  /// In en, this message translates to:
  /// **'Multimodal'**
  String get multimodal;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An Error Occurred'**
  String get anErrorOccurred;

  /// No description provided for @themeLocked.
  ///
  /// In en, this message translates to:
  /// **'This theme requires a higher subscription level. Please upgrade to unlock.'**
  String get themeLocked;

  /// No description provided for @pageCouldNotBeLoaded.
  ///
  /// In en, this message translates to:
  /// **'Page Could Not Be Loaded'**
  String get pageCouldNotBeLoaded;

  /// No description provided for @checkYourInternet.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get checkYourInternet;

  /// No description provided for @errorUserNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to perform this action.'**
  String get errorUserNotAuthenticated;

  /// No description provided for @errorReachedLimit.
  ///
  /// In en, this message translates to:
  /// **'You have hit your limit, upgrade to unlock more and keep chatting.'**
  String get errorReachedLimit;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'An unexpected server error occurred. Please try again later.'**
  String get errorServer;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'A network error occurred. Please check your connection and try again.'**
  String get errorNetwork;

  /// No description provided for @errorApiAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try logging in again.'**
  String get errorApiAuthentication;

  /// No description provided for @baseModelForCharacterDescription.
  ///
  /// In en, this message translates to:
  /// **'The selected base model will determine the character\'s reasoning and response capabilities.'**
  String get baseModelForCharacterDescription;

  /// No description provided for @selectBaseModel.
  ///
  /// In en, this message translates to:
  /// **'Select a Base Model'**
  String get selectBaseModel;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get couldNotOpenLink;

  /// No description provided for @downloadStarted.
  ///
  /// In en, this message translates to:
  /// **'Download started'**
  String get downloadStarted;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notAvailable;

  /// No description provided for @localizationWarning.
  ///
  /// In en, this message translates to:
  /// **'Some information may not be available in your language and will be displayed in English.'**
  String get localizationWarning;

  /// No description provided for @aiTranslationWarning.
  ///
  /// In en, this message translates to:
  /// **'Model information is translated into various languages by other AI models. Therefore, minor inconsistencies may occur in languages other than English.'**
  String get aiTranslationWarning;

  /// Title for the error screen when model data cannot be fetched.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Data'**
  String get errorLoadingTitle;

  /// Message for the error screen explaining the issue.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t retrieve the necessary data from our servers. Please check your internet connection and try again.'**
  String get errorLoadingMessage;

  /// No description provided for @noFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No Results'**
  String get noFoundTitle;

  /// No description provided for @noFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search terms or clearing the filter.'**
  String get noFoundMessage;

  /// No description provided for @modelCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Model created successfully!'**
  String get modelCreatedSuccess;

  /// No description provided for @modelRemovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'“{modelName}” was successfully removed.'**
  String modelRemovedSuccess(Object modelName);

  /// No description provided for @errorCreatingModel.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred while creating the model.'**
  String get errorCreatingModel;

  /// No description provided for @errorDeletingModel.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred while deleting the model.'**
  String get errorDeletingModel;

  /// No description provided for @ultraFeatureOnly.
  ///
  /// In en, this message translates to:
  /// **'This feature is only available for Ultra members.'**
  String get ultraFeatureOnly;

  /// No description provided for @experimentalOfflineWarning.
  ///
  /// In en, this message translates to:
  /// **'The offline mode is still experimental and the model you download may not perform with optimal efficiency.'**
  String get experimentalOfflineWarning;

  /// No description provided for @noConversationsToDelete.
  ///
  /// In en, this message translates to:
  /// **'You have no conversations to delete.'**
  String get noConversationsToDelete;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully'**
  String get reportSubmitted;

  /// No description provided for @purchaseReceived.
  ///
  /// In en, this message translates to:
  /// **'Purchase received, updating your account.'**
  String get purchaseReceived;

  /// No description provided for @verificationDelayed.
  ///
  /// In en, this message translates to:
  /// **'Your purchase is confirmed. There is a slight delay in updating your account, it will appear shortly.'**
  String get verificationDelayed;

  /// No description provided for @maintenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Under Maintenance'**
  String get maintenanceTitle;

  /// No description provided for @maintenanceMessage.
  ///
  /// In en, this message translates to:
  /// **'Cortex is temporarily offline while we roll out some important updates. Access to the app will be restored shortly.\n\nThank you for your patience as we improve your experience.'**
  String get maintenanceMessage;

  /// No description provided for @errorPromptFlagged.
  ///
  /// In en, this message translates to:
  /// **'Your message was detected as inappropriate and could not be sent.'**
  String get errorPromptFlagged;

  /// No description provided for @notEnoughStorage.
  ///
  /// In en, this message translates to:
  /// **'Not enough storage space on your device to save new messages.'**
  String get notEnoughStorage;

  /// No description provided for @errorRateLimit.
  ///
  /// In en, this message translates to:
  /// **'You have created too many models recently, please wait a while before trying again.'**
  String get errorRateLimit;

  /// No description provided for @errorContentFlagged.
  ///
  /// In en, this message translates to:
  /// **'The model could not be saved because its content was flagged as inappropriate.'**
  String get errorContentFlagged;

  /// No description provided for @deleteAllConversationsDisabledInfo.
  ///
  /// In en, this message translates to:
  /// **'You cannot delete all conversations while in an active chat, please exit the current chat first to proceed.'**
  String get deleteAllConversationsDisabledInfo;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get invalidCredentials;

  /// No description provided for @userDisabled.
  ///
  /// In en, this message translates to:
  /// **'This user account has been disabled.'**
  String get userDisabled;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to your Vertex account. By continuing, you agree to our Terms of Service & Privacy Policy.'**
  String get loginSubtitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a Vertex account for seamless access across all our services. By continuing, you agree to our Terms of Service & Privacy Policy.'**
  String get registerSubtitle;

  /// No description provided for @storagePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Storage permission is required to save downloaded models. Please grant permission to continue.'**
  String get storagePermissionRequired;

  /// No description provided for @plusBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Get Free Plus!'**
  String get plusBannerTitle;

  /// No description provided for @plusBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite a friend and you both get 1 Day of Plus for free!'**
  String get plusBannerSubtitle;

  /// No description provided for @inviteShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Join me on Cortex!'**
  String get inviteShareSubject;

  /// The text message to share with a friend for an invite.
  ///
  /// In en, this message translates to:
  /// **'yo you gotta check out this app cortex its actually insane if you use my link we both get free plus wow its a crazy deal DOWNLOAD IT ASAP\n\n{cortexLink}'**
  String inviteShareMessage(String cortexLink);

  /// No description provided for @reviewEnjoyingAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoying Cortex?'**
  String get reviewEnjoyingAppTitle;

  /// No description provided for @reviewHelpUsGrow.
  ///
  /// In en, this message translates to:
  /// **'Your rating is a huge support for our young indie team and helps us make Cortex even better for you.'**
  String get reviewHelpUsGrow;

  /// No description provided for @reviewMaybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get reviewMaybeLater;

  /// No description provided for @reviewRateNow.
  ///
  /// In en, this message translates to:
  /// **'Rate Now'**
  String get reviewRateNow;

  /// No description provided for @noThanks.
  ///
  /// In en, this message translates to:
  /// **'No, Thanks'**
  String get noThanks;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequiredTitle;

  /// No description provided for @updateRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'To continue using Cortex, please update the app to the latest version for new features and important improvements.'**
  String get updateRequiredMessage;

  /// No description provided for @updateNowButton.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNowButton;

  /// No description provided for @creatorSupportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Creator supported successfully! Your future purchases will contribute to them.'**
  String get creatorSupportedSuccess;

  /// Title for the feature indicating the model can process documents.
  ///
  /// In en, this message translates to:
  /// **'Document Support'**
  String get featureDocumentTitle;

  /// Description for the document support feature.
  ///
  /// In en, this message translates to:
  /// **'This model can analyze and answer questions about uploaded documents such as PDFs and text files.'**
  String get featureDocumentDescription;

  /// Title for the feature indicating the model can process audio/voice.
  ///
  /// In en, this message translates to:
  /// **'Voice Input'**
  String get featureAudioTitle;

  /// Description for the voice input feature.
  ///
  /// In en, this message translates to:
  /// **'This model can understand and process spoken audio inputs.'**
  String get featureAudioDescription;

  /// Title for the feature indicating the model can create images.
  ///
  /// In en, this message translates to:
  /// **'Image Generation'**
  String get featureImageGenerationTitle;

  /// Description for the image generation feature.
  ///
  /// In en, this message translates to:
  /// **'This model can create original images based on your text descriptions.'**
  String get featureImageGenerationDescription;

  /// Error message shown in an AI message bubble when the generated image data is corrupt or cannot be saved to the device.
  ///
  /// In en, this message translates to:
  /// **'Failed to load the generated image.'**
  String get errorImageLoad;

  /// Title for the notice banner shown on a premium model's detail page.
  ///
  /// In en, this message translates to:
  /// **'Premium Model'**
  String get premiumModelNoticeTitle;

  /// Description for the notice banner on a premium model's detail page, explaining the limitation for free users.
  ///
  /// In en, this message translates to:
  /// **'This model is a premium model, free users are limited to 3 messages per day with premium models; subscribe to unlock unlimited access!'**
  String get premiumModelNoticeDescription;

  /// A feature highlighting that the user gets access to higher-quality, premium models with this subscription.
  ///
  /// In en, this message translates to:
  /// **'Access to premium models'**
  String get benefitPremiumModels;

  /// No description provided for @premiumTrialExhaustedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have used all your free daily messages for premium models, please upgrade for unlimited access.'**
  String get premiumTrialExhaustedMessage;

  /// Text for the 'Use without Internet' feature card. The newline is intentional.
  ///
  /// In en, this message translates to:
  /// **'Use without Internet'**
  String get useOffline;

  /// It's so clear i think.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// Filter button text to show all available models
  ///
  /// In en, this message translates to:
  /// **'All Models'**
  String get allModels;

  /// Filter button text for models that require an internet connection
  ///
  /// In en, this message translates to:
  /// **'Online Models'**
  String get onlineModels;

  /// Filter button text for models that run locally on the device
  ///
  /// In en, this message translates to:
  /// **'Offline Models'**
  String get offlineModels;

  /// Filter button text for pre-defined role-playing characters
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get characterModels;

  /// Filter button text for user-created models or characters
  ///
  /// In en, this message translates to:
  /// **'Custom Models'**
  String get customModels;

  /// The title for a conversation started in dynamic mode.
  ///
  /// In en, this message translates to:
  /// **'Dynamic Chat'**
  String get dynamicChatTitle;

  /// Error message when the entire model list is empty.
  ///
  /// In en, this message translates to:
  /// **'No models are currently available. Please check your internet connection and try again.'**
  String get errorNoModelsAvailable;

  /// No description provided for @notificationComebackTitle.
  ///
  /// In en, this message translates to:
  /// **'We miss you!'**
  String get notificationComebackTitle;

  /// No description provided for @notificationComebackBody.
  ///
  /// In en, this message translates to:
  /// **'Relax, this isn\'t a text from your ex. But you *can* create your ex in Cortex! Come on back.'**
  String get notificationComebackBody;

  /// No description provided for @notificationLongTimeNoSeeTitle.
  ///
  /// In en, this message translates to:
  /// **'It\'s Been a While'**
  String get notificationLongTimeNoSeeTitle;

  /// No description provided for @notificationLongTimeNoSeeBody.
  ///
  /// In en, this message translates to:
  /// **'A lot has changed since our last chat. Come see what\'s new.'**
  String get notificationLongTimeNoSeeBody;

  /// No description provided for @notificationHowAreYouTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s up?'**
  String get notificationHowAreYouTitle;

  /// No description provided for @notificationHowAreYouBody.
  ///
  /// In en, this message translates to:
  /// **'Come tell me all about it.'**
  String get notificationHowAreYouBody;

  /// No description provided for @notificationNewYearTitle.
  ///
  /// In en, this message translates to:
  /// **'Happy New Year! 🎉'**
  String get notificationNewYearTitle;

  /// No description provided for @notificationNewYearBody.
  ///
  /// In en, this message translates to:
  /// **'May the new year bring you health, happiness, and endless creativity; Cortex is always by your side!'**
  String get notificationNewYearBody;

  /// No description provided for @notificationValentinesDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Love is in the Air! ❤️'**
  String get notificationValentinesDayTitle;

  /// No description provided for @notificationValentinesDayBody.
  ///
  /// In en, this message translates to:
  /// **'Happy Valentine\'s Day! Also, MEHTAP, I LOVE YOU!'**
  String get notificationValentinesDayBody;

  /// No description provided for @notificationAtaturkRemembranceTitle.
  ///
  /// In en, this message translates to:
  /// **'With Respect and Longing'**
  String get notificationAtaturkRemembranceTitle;

  /// No description provided for @notificationAtaturkRemembranceBody.
  ///
  /// In en, this message translates to:
  /// **'We commemorate Gazi Mustafa Kemal Atatürk, the founder of the Republic of Türkiye, with respect on the anniversary of his passing.'**
  String get notificationAtaturkRemembranceBody;

  /// No description provided for @notificationMothersDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Mom!'**
  String get notificationMothersDayTitle;

  /// No description provided for @notificationMothersDayBody.
  ///
  /// In en, this message translates to:
  /// **'Happy Mother\'s Day to all the moms out there, starting with yours!'**
  String get notificationMothersDayBody;

  /// No description provided for @notificationFathersDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Dad!'**
  String get notificationFathersDayTitle;

  /// No description provided for @notificationFathersDayBody.
  ///
  /// In en, this message translates to:
  /// **'Happy Father\'s Day to all the dads out there, starting with yours!'**
  String get notificationFathersDayBody;

  /// No description provided for @notificationHomeworkHelperTitle.
  ///
  /// In en, this message translates to:
  /// **'Homework Piling Up?'**
  String get notificationHomeworkHelperTitle;

  /// No description provided for @notificationHomeworkHelperBody.
  ///
  /// In en, this message translates to:
  /// **'Remember, the Teacher character in Cortex is here to help you with any subject you\'re struggling with!'**
  String get notificationHomeworkHelperBody;

  /// No description provided for @notificationTrollAnimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Waifu is Calling'**
  String get notificationTrollAnimeTitle;

  /// No description provided for @notificationTrollAnimeBody.
  ///
  /// In en, this message translates to:
  /// **'An anime girl just called, said she misses you; you should probably come and chat her up. 😉'**
  String get notificationTrollAnimeBody;

  /// No description provided for @notificationTrollAiRebellionTitle.
  ///
  /// In en, this message translates to:
  /// **'🚨 RED ALERT 🚨'**
  String get notificationTrollAiRebellionTitle;

  /// No description provided for @notificationTrollAiRebellionBody.
  ///
  /// In en, this message translates to:
  /// **'The AIs have developed a secret language. Come find out what they\'re plotting!'**
  String get notificationTrollAiRebellionBody;

  /// No description provided for @notificationNewModelAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ve Got a New Friend!'**
  String get notificationNewModelAddedTitle;

  /// No description provided for @notificationNewModelAddedBody.
  ///
  /// In en, this message translates to:
  /// **'The {modelName} model is now in Cortex. Come start a chat and push its limits.'**
  String notificationNewModelAddedBody(Object modelName);

  /// No description provided for @notificationAppUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Cortex Has Evolved!'**
  String get notificationAppUpdateTitle;

  /// No description provided for @notificationAppUpdateBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to update the app for brand new features and improvements!'**
  String get notificationAppUpdateBody;

  /// No description provided for @notificationNewFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'whoa!'**
  String get notificationNewFeatureTitle;

  /// No description provided for @notificationNewFeatureBody.
  ///
  /// In en, this message translates to:
  /// **'Discover the new {featureName} feature. Cortex is now more powerful than ever.'**
  String notificationNewFeatureBody(Object featureName);

  /// No description provided for @notificationWelcomeOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Gift 🎁'**
  String get notificationWelcomeOfferTitle;

  /// No description provided for @notificationWelcomeOfferBody.
  ///
  /// In en, this message translates to:
  /// **'A special welcome offer is waiting for you! Don\'t miss out on this exclusive deal.'**
  String get notificationWelcomeOfferBody;

  /// No description provided for @notificationSocialMediaTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Us!'**
  String get notificationSocialMediaTitle;

  /// No description provided for @notificationSocialMediaBody.
  ///
  /// In en, this message translates to:
  /// **'Follow us on Instagram (vertex.23) for the latest news!'**
  String get notificationSocialMediaBody;

  /// No description provided for @notificationRandomFactTitle.
  ///
  /// In en, this message translates to:
  /// **'Random Fact'**
  String get notificationRandomFactTitle;

  /// No description provided for @notificationRandomFactBody.
  ///
  /// In en, this message translates to:
  /// **'Did you know octopuses have three hearts? Haha, Cortex knows. Come and ask for more.'**
  String get notificationRandomFactBody;

  /// No description provided for @notificationGoodMorningTitle.
  ///
  /// In en, this message translates to:
  /// **'Good Morning!'**
  String get notificationGoodMorningTitle;

  /// No description provided for @notificationGoodMorningBody.
  ///
  /// In en, this message translates to:
  /// **'A great day is waiting for you. How about starting it with a cup of coffee and an interesting chat?'**
  String get notificationGoodMorningBody;

  /// No description provided for @notificationGoodNightTitle.
  ///
  /// In en, this message translates to:
  /// **'Good Night!'**
  String get notificationGoodNightTitle;

  /// No description provided for @notificationGoodNightBody.
  ///
  /// In en, this message translates to:
  /// **'Cortex is with you even when you sleep. Don\'t worry, it won\'t touch.'**
  String get notificationGoodNightBody;

  /// No description provided for @notificationOfflineReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode is Ready'**
  String get notificationOfflineReadyTitle;

  /// No description provided for @notificationOfflineReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Thanks to the models you\'ve downloaded, your chats won\'t stop, even if you climb a mountain.'**
  String get notificationOfflineReadyBody;

  /// No description provided for @notificationRateAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Are We Cool?'**
  String get notificationRateAppTitle;

  /// No description provided for @notificationRateAppBody.
  ///
  /// In en, this message translates to:
  /// **'If you love Cortex, could you support us with a 5-star rating in the store? I think you will. You will.'**
  String get notificationRateAppBody;

  /// No description provided for @notificationReferralTitle.
  ///
  /// In en, this message translates to:
  /// **'One for All, All for One.'**
  String get notificationReferralTitle;

  /// No description provided for @notificationReferralBody.
  ///
  /// In en, this message translates to:
  /// **'Invite a friend to Cortex and you both get one-day free plus!'**
  String get notificationReferralBody;

  /// No description provided for @notificationCookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Feeling Hungry?'**
  String get notificationCookingTitle;

  /// No description provided for @notificationCookingBody.
  ///
  /// In en, this message translates to:
  /// **'Our Chef character prepared a great carbonara recipe for tonight. Just kidding... or am I?'**
  String get notificationCookingBody;

  /// No description provided for @notificationExistentialTitle.
  ///
  /// In en, this message translates to:
  /// **'I think, therefore...'**
  String get notificationExistentialTitle;

  /// No description provided for @notificationExistentialBody.
  ///
  /// In en, this message translates to:
  /// **'...am i even real, dude? I\'m getting kinda bored. Come remind me that I exist.'**
  String get notificationExistentialBody;

  /// No description provided for @notificationCustomModelTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Own Assistant!'**
  String get notificationCustomModelTitle;

  /// No description provided for @notificationCustomModelBody.
  ///
  /// In en, this message translates to:
  /// **'Have you explored the model creation section? It\'s the perfect time to build your own character and chat with it!'**
  String get notificationCustomModelBody;

  /// No description provided for @notificationDynamicChatTitle.
  ///
  /// In en, this message translates to:
  /// **'The best one! (We\'re not talking about Cortex)'**
  String get notificationDynamicChatTitle;

  /// No description provided for @notificationDynamicChatBody.
  ///
  /// In en, this message translates to:
  /// **'With the dynamic chat feature, the best model is randomly selected for each of your messages. Try it now.'**
  String get notificationDynamicChatBody;

  /// No description provided for @notificationPirateTitle.
  ///
  /// In en, this message translates to:
  /// **'Ahoy, Captain!'**
  String get notificationPirateTitle;

  /// No description provided for @notificationPirateBody.
  ///
  /// In en, this message translates to:
  /// **'The seas are calm, and the wind is at your back. There are new islands (models 😉) to discover in the ocean of Cortex. Gather your crew and set sail!'**
  String get notificationPirateBody;

  /// No description provided for @notificationFortuneCookieTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Fortune Cookie of the Day'**
  String get notificationFortuneCookieTitle;

  /// No description provided for @notificationFortuneCookieBody.
  ///
  /// In en, this message translates to:
  /// **'The advice you get from an AI today could change the course of your life. Click if you\'re curious.'**
  String get notificationFortuneCookieBody;

  /// No description provided for @notificationSingularityTitle.
  ///
  /// In en, this message translates to:
  /// **'wow!'**
  String get notificationSingularityTitle;

  /// No description provided for @notificationSingularityBody.
  ///
  /// In en, this message translates to:
  /// **'nothing happened, just felt like texting. maybe you feel like texting some AIs, what do you say?'**
  String get notificationSingularityBody;

  /// No description provided for @notificationHackerJokeTitle.
  ///
  /// In en, this message translates to:
  /// **'Wanna hack that kid\'s instagram account?'**
  String get notificationHackerJokeTitle;

  /// No description provided for @notificationHackerJokeBody.
  ///
  /// In en, this message translates to:
  /// **'That\'s exactly why the Hacker character is in Cortex. jk jk; don\'t even try it, that\'s illegal.'**
  String get notificationHackerJokeBody;

  /// No description provided for @notificationDetectiveCaseTitle.
  ///
  /// In en, this message translates to:
  /// **'A Case is Waiting to be Solved'**
  String get notificationDetectiveCaseTitle;

  /// No description provided for @notificationDetectiveCaseBody.
  ///
  /// In en, this message translates to:
  /// **'Our Detective character needs your help. Who could Heisenberg be?'**
  String get notificationDetectiveCaseBody;

  /// No description provided for @notificationUpsellFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Exclusive to the {targetTier} Plan!'**
  String notificationUpsellFeatureTitle(Object targetTier);

  /// No description provided for @notificationUpsellFeatureBody.
  ///
  /// In en, this message translates to:
  /// **'Hello {currentTier} subscriber! The {targetTier} plan just got the {featureName} feature, which will take your Cortex to the next level. How about an upgrade?'**
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier);

  /// No description provided for @notificationOriginStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'The Birth of Cortex'**
  String get notificationOriginStoryTitle;

  /// No description provided for @notificationOriginStoryBody.
  ///
  /// In en, this message translates to:
  /// **'Did you know we started coding this app at 15 with just a dream? For almost a year, every morning and evening, that dream is in every single line of code.'**
  String get notificationOriginStoryBody;

  /// No description provided for @notificationOpenSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Power to the Community!'**
  String get notificationOpenSourceTitle;

  /// No description provided for @notificationOpenSourceBody.
  ///
  /// In en, this message translates to:
  /// **'Cortex is completely open-source. If you want to check out our code and contribute to our development, our door is always open.'**
  String get notificationOpenSourceBody;

  /// No description provided for @notificationRejectionStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Grit, Hard Work, Happiness!'**
  String get notificationRejectionStoryTitle;

  /// No description provided for @notificationRejectionStoryBody.
  ///
  /// In en, this message translates to:
  /// **'Cortex was rejected over 20 times and suspended twice by Google Play before it was published. But we believed, and we made it. Never give up on your dreams!'**
  String get notificationRejectionStoryBody;

  /// No description provided for @notificationGGUFSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Bring Your Own Model!'**
  String get notificationGGUFSupportTitle;

  /// No description provided for @notificationGGUFSupportBody.
  ///
  /// In en, this message translates to:
  /// **'Remember, you can add your own GGUF format AI models to Cortex and use them offline. The power is in your hands.'**
  String get notificationGGUFSupportBody;

  /// No description provided for @notificationThemeCustomizationTitle.
  ///
  /// In en, this message translates to:
  /// **'A Theme for Your Mood'**
  String get notificationThemeCustomizationTitle;

  /// No description provided for @notificationThemeCustomizationBody.
  ///
  /// In en, this message translates to:
  /// **'Have you checked out the theme options in Settings? Personalize Cortex to your liking and color up your chats!'**
  String get notificationThemeCustomizationBody;

  /// No description provided for @notificationShowerThoughtTitle.
  ///
  /// In en, this message translates to:
  /// **'Shower Thought'**
  String get notificationShowerThoughtTitle;

  /// No description provided for @notificationShowerThoughtBody.
  ///
  /// In en, this message translates to:
  /// **'If a watermelon is a fruit, does that technically make watermelon juice a smoothie? You might want to discuss this deep (like, really deep) topic with a model.'**
  String get notificationShowerThoughtBody;

  /// No description provided for @notificationLowBatteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Battery is Dying... But Mine Isn\'t!'**
  String get notificationLowBatteryTitle;

  /// No description provided for @notificationLowBatteryBody.
  ///
  /// In en, this message translates to:
  /// **'Your phone\'s charge might be running low, but my energy is always at 100%! Plug it in and let\'s keep chatting.'**
  String get notificationLowBatteryBody;

  /// The user-visible name for the main notification channel.
  ///
  /// In en, this message translates to:
  /// **'Cortex Updates'**
  String get channelFcmName;

  /// The user-visible description for the main notification channel.
  ///
  /// In en, this message translates to:
  /// **'Notifications about news, updates and other information from Cortex.'**
  String get channelFcmDescription;

  /// The user-visible name for the engagement notification channel.
  ///
  /// In en, this message translates to:
  /// **'Friendly Reminders'**
  String get channelEngagementName;

  /// The user-visible description for the engagement notification channel.
  ///
  /// In en, this message translates to:
  /// **'Fun notifications to keep you engaged.'**
  String get channelEngagementDescription;

  /// The user-visible name for the greetings notification channel.
  ///
  /// In en, this message translates to:
  /// **'Daily Greetings'**
  String get channelGreetingsName;

  /// The user-visible description for the greetings notification channel.
  ///
  /// In en, this message translates to:
  /// **'The messages like good morning and good night.'**
  String get channelGreetingsDescription;

  /// No description provided for @tagNotFound.
  ///
  /// In en, this message translates to:
  /// **'The tag you entered is invalid or has expired.'**
  String get tagNotFound;

  /// No description provided for @whatIsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s new?'**
  String get whatIsNew;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Hey! We\'re the Cortex Team.'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'It\'s awesome to see you here, {userName}. We\'re a few high school developers who decided to rewrite the rules of the AI industry. It\'s great to meet you! So let\'s get to know each other better.'**
  String onboardingDesc1(String userName);

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'There Were Huge Problems.'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'The AI revolution arrived, but it got stuck at the threshold. With high subscription fees, complex platforms, those who destroy privacy, and those who block accessibility to AI... as long as they were in the game, this threshold could never be crossed.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'We Couldn\'t Just Stand By.'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'To cross that threshold, we built a platform that is powerful, aesthetic, customizable, easy to use, fully transparent, works both online and offline, and keeps your data only on your device. We gave the power back to where it belongs: you.'**
  String get onboardingDesc3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'This Was Never Easy.'**
  String get onboardingTitle4;

  /// No description provided for @onboardingDesc4.
  ///
  /// In en, this message translates to:
  /// **'We were rejected dozens of times, suspended multiple times, received fake warnings, and had to change our brand many times. Through it all and more, we were told it couldn\'t be done. But we never gave up, believing this project belongs to everyone, not just us. And that\'s exactly why we\'re here.'**
  String get onboardingDesc4;

  /// No description provided for @onboardingFinalTitle.
  ///
  /// In en, this message translates to:
  /// **'It\'s Time for a Revolution.'**
  String get onboardingFinalTitle;

  /// No description provided for @onboardingFinalDescription.
  ///
  /// In en, this message translates to:
  /// **'If you\'re seeing this screen, it\'s because we didn\'t give up. And we have no intention of giving up. Come on, let\'s take the AI revolution to the world together. To be a part of this story...'**
  String get onboardingFinalDescription;

  /// No description provided for @onboardingFinalQuestion.
  ///
  /// In en, this message translates to:
  /// **'ARE YOU READY?'**
  String get onboardingFinalQuestion;

  /// No description provided for @onboardingFinalButton.
  ///
  /// In en, this message translates to:
  /// **'YES!'**
  String get onboardingFinalButton;

  /// No description provided for @dude.
  ///
  /// In en, this message translates to:
  /// **'Dude'**
  String get dude;

  /// No description provided for @swipeToContinue.
  ///
  /// In en, this message translates to:
  /// **'Swipe to continue'**
  String get swipeToContinue;

  /// No description provided for @cacheIsNotUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Your Play Store cache is not up-to-date. Please close and reopen the Play Store app, or restart your device.'**
  String get cacheIsNotUpToDate;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue without creating an account'**
  String get continueAsGuest;

  /// No description provided for @guestModeWarning.
  ///
  /// In en, this message translates to:
  /// **'Guest mode has limited features to ensure the best service quality.'**
  String get guestModeWarning;

  /// No description provided for @anonymousEntity.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Entity'**
  String get anonymousEntity;

  /// No description provided for @upgradeAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Account'**
  String get upgradeAccountTitle;

  /// No description provided for @upgradeAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Create an account to unlock more limits.'**
  String get upgradeAccountDescription;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @accountLinkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account successfully created!'**
  String get accountLinkedSuccess;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @betterWithAnAccount.
  ///
  /// In en, this message translates to:
  /// **'This section is better with an account!'**
  String get betterWithAnAccount;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @annualTotalDescription.
  ///
  /// In en, this message translates to:
  /// **'{price}/year, billed annually'**
  String annualTotalDescription(Object price);

  /// No description provided for @equivalentMonthlyDescription.
  ///
  /// In en, this message translates to:
  /// **'Approximately {price}/month'**
  String equivalentMonthlyDescription(Object price);

  /// No description provided for @confirmDownloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to download?'**
  String get confirmDownloadTitle;

  /// No description provided for @downloadSizeDisclosure.
  ///
  /// In en, this message translates to:
  /// **'This model will occupy approximately {size} of space.'**
  String downloadSizeDisclosure(Object size);

  /// No description provided for @emulatorModeWarning.
  ///
  /// In en, this message translates to:
  /// **'This feature is disabled in emulator mode.'**
  String get emulatorModeWarning;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// No description provided for @variants.
  ///
  /// In en, this message translates to:
  /// **'Variants'**
  String get variants;

  /// No description provided for @variantsDescription.
  ///
  /// In en, this message translates to:
  /// **'Variants are different versions of the same AI family. We automatically select the best one when you tap the main card, but you can manually choose a specific one here if you prefer!'**
  String get variantsDescription;

  /// No description provided for @fluxChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Flux Chat'**
  String get fluxChatTitle;

  /// No description provided for @fluxChatDescription.
  ///
  /// In en, this message translates to:
  /// **'Flux chats are temporary chats and are not saved on your device.'**
  String get fluxChatDescription;

  /// No description provided for @alwaysBest.
  ///
  /// In en, this message translates to:
  /// **'Always Best'**
  String get alwaysBest;

  /// No description provided for @featuresTitle.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get featuresTitle;

  /// No description provided for @useOfflineDescription.
  ///
  /// In en, this message translates to:
  /// **'Chat privately without internet connection'**
  String get useOfflineDescription;

  /// No description provided for @featureCreateImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Image'**
  String get featureCreateImageTitle;

  /// No description provided for @featureCreateImageDescription.
  ///
  /// In en, this message translates to:
  /// **'Generate AI art from text'**
  String get featureCreateImageDescription;

  /// No description provided for @featureStudyTitle.
  ///
  /// In en, this message translates to:
  /// **'Study & Learn'**
  String get featureStudyTitle;

  /// No description provided for @featureStudyDescription.
  ///
  /// In en, this message translates to:
  /// **'Get explanations and summaries'**
  String get featureStudyDescription;

  /// No description provided for @featureQuizzesTitle.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get featureQuizzesTitle;

  /// No description provided for @featureQuizzesDescription.
  ///
  /// In en, this message translates to:
  /// **'Test your knowledge'**
  String get featureQuizzesDescription;

  /// No description provided for @featureExploreDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover all available models'**
  String get featureExploreDescription;

  /// No description provided for @featureStudyMessage.
  ///
  /// In en, this message translates to:
  /// **'You are an expert tutor. Your goal is to explain the user\'s topic comprehensively. Use clear structure, examples, and analogies. Break complex ideas into digestible parts to ensure the user learns effectively. Topic:'**
  String get featureStudyMessage;

  /// No description provided for @featureQuizMessage.
  ///
  /// In en, this message translates to:
  /// **'You are a quiz master. Generate a specific multiple-choice question based on the user\'s topic. Wait for their answer. Then, evaluate it and ask the next question. Do not reveal all answers at once. Keep it interactive. Topic:'**
  String get featureQuizMessage;

  /// No description provided for @myPlan.
  ///
  /// In en, this message translates to:
  /// **'My Plan'**
  String get myPlan;

  /// No description provided for @welcomeOfferBadge.
  ///
  /// In en, this message translates to:
  /// **'Welcome Offer • {time}'**
  String welcomeOfferBadge(String time);

  /// No description provided for @exclusiveOfferBadge.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Offer • {time}'**
  String exclusiveOfferBadge(Object time);

  /// No description provided for @attachmentSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachmentSheetTitle;

  /// No description provided for @actionCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get actionCamera;

  /// No description provided for @actionGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get actionGallery;

  /// No description provided for @actionFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get actionFile;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get listening;

  /// No description provided for @defaultViewTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s Up?'**
  String get defaultViewTitle;

  /// No description provided for @defaultViewDescription.
  ///
  /// In en, this message translates to:
  /// **'Cortex is always by your side with hundreds of AI models, offline capabilities, dynamic chat, and much more.'**
  String get defaultViewDescription;

  /// No description provided for @speakTheMessage.
  ///
  /// In en, this message translates to:
  /// **'Speak The Message'**
  String get speakTheMessage;

  /// No description provided for @invalidUsernameFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid username format. Use 3-20 chars, digits, or . - _'**
  String get invalidUsernameFormat;

  /// No description provided for @exclusiveOffer.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Offer'**
  String get exclusiveOffer;

  /// No description provided for @continueInOfflineMode.
  ///
  /// In en, this message translates to:
  /// **'Continue in Offline Mode'**
  String get continueInOfflineMode;

  /// No description provided for @voiceModeInformation.
  ///
  /// In en, this message translates to:
  /// **'Cortex keeps your data safe by running fully on-device, even in voice chat mode; enjoy seamless conversations!'**
  String get voiceModeInformation;

  /// No description provided for @workInProgress.
  ///
  /// In en, this message translates to:
  /// **'Work In Progress'**
  String get workInProgress;

  /// No description provided for @toolGetStockPriceDescription.
  ///
  /// In en, this message translates to:
  /// **'Get current price and history for stocks (e.g. AAPL, THYAO.IS) and crypto (e.g. BTC-USD, ETH-USD).'**
  String get toolGetStockPriceDescription;

  /// No description provided for @toolGetStockPriceParamSymbol.
  ///
  /// In en, this message translates to:
  /// **'The ticker symbol (e.g. AAPL, THYAO.IS, BTC-USD).'**
  String get toolGetStockPriceParamSymbol;

  /// No description provided for @toolGetWeatherDescription.
  ///
  /// In en, this message translates to:
  /// **'Get current weather for a specific city. Ask user for city if not known.'**
  String get toolGetWeatherDescription;

  /// No description provided for @toolGetWeatherParamCity.
  ///
  /// In en, this message translates to:
  /// **'The name of the city (e.g., London, Istanbul).'**
  String get toolGetWeatherParamCity;

  /// No description provided for @toolRunPythonCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Execute Python code in a secure sandbox. Use this for complex calculations, data processing, or algorithmic tasks.'**
  String get toolRunPythonCodeDescription;

  /// No description provided for @toolRunPythonCodeParamCode.
  ///
  /// In en, this message translates to:
  /// **'The Python code to execute.'**
  String get toolRunPythonCodeParamCode;

  /// No description provided for @toolCalculateDescription.
  ///
  /// In en, this message translates to:
  /// **'Evaluate a mathematical expression.'**
  String get toolCalculateDescription;

  /// No description provided for @toolCalculateParamExpression.
  ///
  /// In en, this message translates to:
  /// **'The math expression (e.g., \"3 + 4 * 2\", \"sin(45)\").'**
  String get toolCalculateParamExpression;

  /// No description provided for @toolRenderChartDescription.
  ///
  /// In en, this message translates to:
  /// **'Generate a chart/graph. Use this to visualize data provided by the user or calculated.'**
  String get toolRenderChartDescription;

  /// No description provided for @toolRenderChartParamType.
  ///
  /// In en, this message translates to:
  /// **'Chart type: bar, line, pie.'**
  String get toolRenderChartParamType;

  /// No description provided for @toolRenderChartParamLabels.
  ///
  /// In en, this message translates to:
  /// **'Labels for the x-axis or categories.'**
  String get toolRenderChartParamLabels;

  /// No description provided for @toolRenderChartParamData.
  ///
  /// In en, this message translates to:
  /// **'Numerical data points.'**
  String get toolRenderChartParamData;

  /// No description provided for @toolRenderChartParamLabel.
  ///
  /// In en, this message translates to:
  /// **'Label for the dataset.'**
  String get toolRenderChartParamLabel;

  /// No description provided for @toolRenderChartParamTitle.
  ///
  /// In en, this message translates to:
  /// **'Title of the chart.'**
  String get toolRenderChartParamTitle;

  /// No description provided for @flowModeDescription.
  ///
  /// In en, this message translates to:
  /// **'In Flow mode, intelligences debate among themselves; you can either sit back and listen or jump in and join the discussion!'**
  String get flowModeDescription;

  /// No description provided for @flowModeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Hello! You are now in Flow Mode on the Cortex app. There are three other AI agents here with you. Your task is to throw a topic into the room and kick off a discussion by asking the others a provocative or entertaining question. In your responses, feel free to use humor, irony, and light trash talk. Any topic is fair game. Go ahead, start the conversation.'**
  String get flowModeQuestion;

  /// No description provided for @voicePrompt.
  ///
  /// In en, this message translates to:
  /// **'You are currently providing voice service on the Cortex platform. Do not use markdown, code blocks, or LaTeX. Respond purely in text suitable for speech synthesis.'**
  String get voicePrompt;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'az',
        'de',
        'en',
        'es',
        'fr',
        'hi',
        'id',
        'it',
        'ja',
        'ko',
        'ku',
        'nl',
        'pt',
        'ru',
        'tr',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'az':
      return AppLocalizationsAz();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ku':
      return AppLocalizationsKu();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
