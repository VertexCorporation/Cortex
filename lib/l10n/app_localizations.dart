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

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood.'**
  String get understood;

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

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

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

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'COMING SOON'**
  String get comingSoon;

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

  /// No description provided for @modelLoading.
  ///
  /// In en, this message translates to:
  /// **'Model is loading...'**
  String get modelLoading;

  /// No description provided for @messageCopied.
  ///
  /// In en, this message translates to:
  /// **'Message copied to clipboard.'**
  String get messageCopied;

  /// No description provided for @storeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Store is currently unavailable. Please try again later'**
  String get storeUnavailable;

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

  /// No description provided for @storageSpace.
  ///
  /// In en, this message translates to:
  /// **'Storage Space: {storage} GB'**
  String storageSpace(Object storage);

  /// No description provided for @freeStorageSpace.
  ///
  /// In en, this message translates to:
  /// **'Free Storage Space: {freeStorage} GB'**
  String freeStorageSpace(Object freeStorage);

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

  /// No description provided for @requirements.
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get requirements;

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

  /// No description provided for @uploadYourOwnModel.
  ///
  /// In en, this message translates to:
  /// **'Upload Your Own Model!'**
  String get uploadYourOwnModel;

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

  /// No description provided for @modelAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Model already exists.'**
  String get modelAlreadyExists;

  /// No description provided for @modelAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Model added successfully.'**
  String get modelAddedSuccessfully;

  /// No description provided for @modelRemoved.
  ///
  /// In en, this message translates to:
  /// **'Model removed successfully.'**
  String get modelRemoved;

  /// No description provided for @removeError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while removing the model.'**
  String get removeError;

  /// No description provided for @fileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found.'**
  String get fileNotFound;

  /// No description provided for @fileUploadError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while uploading the file.'**
  String get fileUploadError;

  /// No description provided for @noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected.'**
  String get noFileSelected;

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

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @modelProducer.
  ///
  /// In en, this message translates to:
  /// **'Producer: {producer}'**
  String modelProducer(Object producer);

  /// No description provided for @modelRAM.
  ///
  /// In en, this message translates to:
  /// **'RAM: {ram}'**
  String modelRAM(Object ram);

  /// No description provided for @modelSize.
  ///
  /// In en, this message translates to:
  /// **'Size: {size}'**
  String modelSize(Object size);

  /// No description provided for @modelDescription.
  ///
  /// In en, this message translates to:
  /// **'{description}'**
  String modelDescription(Object description);

  /// No description provided for @conversationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversationsTitle;

  /// No description provided for @conversationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted.'**
  String get conversationDeleted;

  /// No description provided for @conversationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Conversation updated.'**
  String get conversationUpdated;

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

  /// No description provided for @titleCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Title cannot be empty.'**
  String get titleCannotBeEmpty;

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

  /// No description provided for @starredChats.
  ///
  /// In en, this message translates to:
  /// **'Starred Chats'**
  String get starredChats;

  /// No description provided for @allChats.
  ///
  /// In en, this message translates to:
  /// **'All Chats'**
  String get allChats;

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

  /// No description provided for @goToChats.
  ///
  /// In en, this message translates to:
  /// **'Star a chat'**
  String get goToChats;

  /// No description provided for @starConversation.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get starConversation;

  /// No description provided for @conversationTitleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Conversation title updated'**
  String get conversationTitleUpdated;

  /// No description provided for @youReachedConversationLimit.
  ///
  /// In en, this message translates to:
  /// **'You have reached the conversation limit.'**
  String get youReachedConversationLimit;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

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
  /// **'Forgot Password?'**
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

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get userNotFound;

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

  /// No description provided for @invalidUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username.'**
  String get invalidUsername;

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

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get authenticationFailed;

  /// No description provided for @emailTooLong.
  ///
  /// In en, this message translates to:
  /// **'Email can be at most 30 characters.'**
  String get emailTooLong;

  /// No description provided for @deviceLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You have reached the account creation limit for this device.'**
  String get deviceLimitReached;

  /// No description provided for @verificationEmailLimitReached.
  ///
  /// In en, this message translates to:
  /// **'We wont send anymore'**
  String get verificationEmailLimitReached;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification e-mail sent!'**
  String get verificationEmailSent;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'E-mail has not verified'**
  String get emailNotVerified;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend verification e-mail'**
  String get resendCode;

  /// No description provided for @remainingSeconds.
  ///
  /// In en, this message translates to:
  /// **'Remaining time for verification'**
  String get remainingSeconds;

  /// No description provided for @pleaseCheckYourEmail.
  ///
  /// In en, this message translates to:
  /// **'To use Cortex, you need to verify your email. \n A verification link has been sent to your email address, please check your email.'**
  String get pleaseCheckYourEmail;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyYourEmail;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get backToLogin;

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

  /// No description provided for @accountVerified.
  ///
  /// In en, this message translates to:
  /// **'Your account has been verified.'**
  String get accountVerified;

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

  /// No description provided for @enterPasswordToDelete.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to delete.'**
  String get enterPasswordToDelete;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting the account.'**
  String get deleteAccountError;

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

  /// No description provided for @tapToChangeProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Tap to change profile picture'**
  String get tapToChangeProfilePicture;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get updateFailed;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameCannotBeEmpty;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @noDisplayName.
  ///
  /// In en, this message translates to:
  /// **'No display name set'**
  String get noDisplayName;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No email address'**
  String get noEmail;

  /// No description provided for @noUserLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'No user is currently logged in'**
  String get noUserLoggedIn;

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

  /// No description provided for @downloadError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during download.'**
  String get downloadError;

  /// No description provided for @downloadCancelled.
  ///
  /// In en, this message translates to:
  /// **'Download cancelled.'**
  String get downloadCancelled;

  /// No description provided for @downloadResumed.
  ///
  /// In en, this message translates to:
  /// **'Download resumed.'**
  String get downloadResumed;

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
  /// **'Purchase succesful!'**
  String get purchaseSuccessful;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase unsuccesful'**
  String get purchaseFailed;

  /// No description provided for @creditProductNotFound.
  ///
  /// In en, this message translates to:
  /// **'The selected credit product could not be found.'**
  String get creditProductNotFound;

  /// No description provided for @creditsAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Credits were added to your account successfully!'**
  String get creditsAddedSuccessfully;

  /// No description provided for @creditDeliveryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add credits to your account. Please contact support.'**
  String get creditDeliveryFailed;

  /// No description provided for @invalidPurchase.
  ///
  /// In en, this message translates to:
  /// **'Invalid purchase'**
  String get invalidPurchase;

  /// No description provided for @purchaseError.
  ///
  /// In en, this message translates to:
  /// **'Purchasing error'**
  String get purchaseError;

  /// No description provided for @purchaseVertexPlusToUpload.
  ///
  /// In en, this message translates to:
  /// **'This is a Plus feature'**
  String get purchaseVertexPlusToUpload;

  /// No description provided for @purchasePlus.
  ///
  /// In en, this message translates to:
  /// **'Buy Cortex Plus'**
  String get purchasePlus;

  /// No description provided for @plusDescription.
  ///
  /// In en, this message translates to:
  /// **'Access more features of Cortex and experience AI much more!'**
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

  /// No description provided for @discountOffer.
  ///
  /// In en, this message translates to:
  /// **'{percent}% OFF'**
  String discountOffer(int percent);

  /// The description for the annual plan, showing the monthly equivalent price to make it seem more affordable. Example: $4.17/mo, billed annually
  ///
  /// In en, this message translates to:
  /// **'{price}/mo, billed annually'**
  String annualPlanDescription(String price);

  /// The description for the monthly plan, showing the price per month. Example: $4.99/mo, billed monthly
  ///
  /// In en, this message translates to:
  /// **'{price}/mo, billed monthly'**
  String monthlyPlanDescription(String price);

  /// The main headline for the promotional banner, emphasizing a special launch discount.
  ///
  /// In en, this message translates to:
  /// **'LAUNCH SPECIAL: 80% OFF!'**
  String get discountBannerTitle;

  /// The secondary text for the promotional banner, clarifying the offer applies to all plans and adding a sense of urgency.
  ///
  /// In en, this message translates to:
  /// **'Exclusive discount on ALL subscription plans to celebrate our launch. Don\'t miss out!'**
  String get discountBannerSubtitle;

  /// No description provided for @purchasePro.
  ///
  /// In en, this message translates to:
  /// **'Buy Cortex Pro'**
  String get purchasePro;

  /// No description provided for @proDescription.
  ///
  /// In en, this message translates to:
  /// **'Access even more features of Cortex and experience AI even more!'**
  String get proDescription;

  /// No description provided for @alreadySubscribed.
  ///
  /// In en, this message translates to:
  /// **'You are already subscribed'**
  String get alreadySubscribed;

  /// No description provided for @subscriptionInfo.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is active.'**
  String get subscriptionInfo;

  /// No description provided for @alreadySubscribedMessage.
  ///
  /// In en, this message translates to:
  /// **'You already have a Plus subscription. If you want to cancel your subscription, you can do so through the Play Store manager.'**
  String get alreadySubscribedMessage;

  /// No description provided for @cancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get cancelSubscription;

  /// No description provided for @cancelSubscriptionInfo.
  ///
  /// In en, this message translates to:
  /// **'If you want to cancel your subscription, please proceed through the Play Store subscription manager.'**
  String get cancelSubscriptionInfo;

  /// No description provided for @goToPlayStore.
  ///
  /// In en, this message translates to:
  /// **'Go to Play Store'**
  String get goToPlayStore;

  /// No description provided for @alreadySubscribedPlus.
  ///
  /// In en, this message translates to:
  /// **'You Have the Plus Plan!'**
  String get alreadySubscribedPlus;

  /// No description provided for @alreadySubscribedPlusMessage.
  ///
  /// In en, this message translates to:
  /// **'Your Plus plan is active. You can enjoy all the benefits.'**
  String get alreadySubscribedPlusMessage;

  /// No description provided for @purchaseUltra.
  ///
  /// In en, this message translates to:
  /// **'Buy Cortex Ultra'**
  String get purchaseUltra;

  /// No description provided for @ultraDescription.
  ///
  /// In en, this message translates to:
  /// **'Gain full access to all features of Cortex and experience AI to the fullest!'**
  String get ultraDescription;

  /// No description provided for @noSubscription.
  ///
  /// In en, this message translates to:
  /// **'No Subscription'**
  String get noSubscription;

  /// No description provided for @noSubscriptionMessage.
  ///
  /// In en, this message translates to:
  /// **'You do not have a subscription yet.'**
  String get noSubscriptionMessage;

  /// No description provided for @alreadyAtHighestPlan.
  ///
  /// In en, this message translates to:
  /// **'You are already on the highest plan.'**
  String get alreadyAtHighestPlan;

  /// No description provided for @unableToOpenSubscription.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the subscription management page.'**
  String get unableToOpenSubscription;

  /// No description provided for @upgradeSubscription.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Subscription'**
  String get upgradeSubscription;

  /// No description provided for @confirmUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to upgrade your subscription?'**
  String get confirmUpgrade;

  /// No description provided for @unsupportedPlatform.
  ///
  /// In en, this message translates to:
  /// **'Unsupported platform for subscription cancellation.'**
  String get unsupportedPlatform;

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

  /// No description provided for @productDetailsError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while fetching product details.'**
  String get productDetailsError;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @loadCreditsButton.
  ///
  /// In en, this message translates to:
  /// **'Load Credits'**
  String get loadCreditsButton;

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditsTitle;

  /// No description provided for @creditsScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'This screen shows the user\'s credits. \n\nUser\'s current credits: 100\n\nDetailed credit information can be displayed here.'**
  String get creditsScreenDescription;

  /// No description provided for @creditsLoaded.
  ///
  /// In en, this message translates to:
  /// **'Credits loaded!'**
  String get creditsLoaded;

  /// No description provided for @currentCredits.
  ///
  /// In en, this message translates to:
  /// **'Current Credits'**
  String get currentCredits;

  /// No description provided for @pleaseSelectCreditPackage.
  ///
  /// In en, this message translates to:
  /// **'Please select a credit package'**
  String get pleaseSelectCreditPackage;

  /// No description provided for @purchaseCreditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy Credits'**
  String get purchaseCreditsTitle;

  /// No description provided for @purchaseCreditsDescription.
  ///
  /// In en, this message translates to:
  /// **'Select a credit package that suits your needs and use our app more.'**
  String get purchaseCreditsDescription;

  /// No description provided for @purchaseButton.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get purchaseButton;

  /// No description provided for @productNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The selected product does not exist.'**
  String get productNotFoundMessage;

  /// No description provided for @buyCredits.
  ///
  /// In en, this message translates to:
  /// **'Buy Credits'**
  String get buyCredits;

  /// No description provided for @selectCreditPackageDescription.
  ///
  /// In en, this message translates to:
  /// **'Select a credit package that suits your needs and enjoy more features.'**
  String get selectCreditPackageDescription;

  /// No description provided for @buyCredit.
  ///
  /// In en, this message translates to:
  /// **'Buy Credits'**
  String get buyCredit;

  /// No description provided for @buyCreditPackage.
  ///
  /// In en, this message translates to:
  /// **'Buy {amount} Credits'**
  String buyCreditPackage(Object amount);

  /// No description provided for @subscribedPlan.
  ///
  /// In en, this message translates to:
  /// **'Subsrcibed'**
  String get subscribedPlan;

  /// No description provided for @errorResponseNotReceived.
  ///
  /// In en, this message translates to:
  /// **'Response not received'**
  String get errorResponseNotReceived;

  /// Error message used when Google API request fails
  ///
  /// In en, this message translates to:
  /// **'Google API request failed {attempt} times: {error}'**
  String googleApiRequestFailed(int attempt, String error);

  /// Log the response status code from OpenRouter API
  ///
  /// In en, this message translates to:
  /// **'OpenRouter Response Status: {statusCode}'**
  String openRouterResponseStatus(int statusCode);

  /// Log the response body from OpenRouter API
  ///
  /// In en, this message translates to:
  /// **'OpenRouter Decoded Response Body: {body}'**
  String openRouterDecodedResponseBody(String body);

  /// Log the decoded JSON data
  ///
  /// In en, this message translates to:
  /// **'Decoded JSON: {data}'**
  String decodedJson(String data);

  /// No description provided for @responseStructureUnexpectedMessageContentMissing.
  ///
  /// In en, this message translates to:
  /// **'Response structure is unexpected: message or content missing'**
  String get responseStructureUnexpectedMessageContentMissing;

  /// No description provided for @responseStructureUnexpectedChoicesMissing.
  ///
  /// In en, this message translates to:
  /// **'Response structure is unexpected: choices missing or empty'**
  String get responseStructureUnexpectedChoicesMissing;

  /// Error message used when OpenRouter API request fails
  ///
  /// In en, this message translates to:
  /// **'OpenRouter API request failed: {statusCode} - {body}'**
  String openRouterApiRequestFailed(int statusCode, String body);

  /// Error message used when OpenRouter API request fails after certain attempts
  ///
  /// In en, this message translates to:
  /// **'OpenRouter API request failed {attempt} times: {error}'**
  String openRouterApiRequestFailedAfterAttempts(int attempt, String error);

  /// No description provided for @internetRequired.
  ///
  /// In en, this message translates to:
  /// **'Internet connection is required to use this model'**
  String get internetRequired;

  /// No description provided for @pleaseWaitBeforeTryingAgain.
  ///
  /// In en, this message translates to:
  /// **'Please wait a moment before trying again'**
  String get pleaseWaitBeforeTryingAgain;

  /// Indicates that the API quota has been exceeded.
  ///
  /// In en, this message translates to:
  /// **'Quota exceeded. Status code: {statusCode}, Body: {decodedBody}'**
  String openRouterQuotaExceeded(int statusCode, String decodedBody);

  /// Indicates that the API request failed after a certain number of paid model attempts.
  ///
  /// In en, this message translates to:
  /// **'API request failed after {attempts} paid attempts. Error: {error}'**
  String openRouterApiRequestFailedAfterPaidAttempts(
      int attempts, String error);

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

  /// No description provided for @ratingsSection.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratingsSection;

  /// No description provided for @noRatingDataFound.
  ///
  /// In en, this message translates to:
  /// **'No rating data found'**
  String get noRatingDataFound;

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

  /// No description provided for @featureSupermodelTitle.
  ///
  /// In en, this message translates to:
  /// **'Super Model'**
  String get featureSupermodelTitle;

  /// No description provided for @featureSupermodelDescription.
  ///
  /// In en, this message translates to:
  /// **'This is a massive model with over 10 billion parameters, offering high performance and extensive capabilities.'**
  String get featureSupermodelDescription;

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

  /// No description provided for @millions.
  ///
  /// In en, this message translates to:
  /// **'million'**
  String get millions;

  /// No description provided for @billions.
  ///
  /// In en, this message translates to:
  /// **'billion'**
  String get billions;

  /// No description provided for @trillions.
  ///
  /// In en, this message translates to:
  /// **'trillion'**
  String get trillions;

  /// No description provided for @thousand.
  ///
  /// In en, this message translates to:
  /// **'thousand'**
  String get thousand;

  /// No description provided for @estimated.
  ///
  /// In en, this message translates to:
  /// **'estimated'**
  String get estimated;

  /// No description provided for @finalPreparation.
  ///
  /// In en, this message translates to:
  /// **'Final preparations are being made.'**
  String get finalPreparation;

  /// No description provided for @allEvaluationsByTestTeam.
  ///
  /// In en, this message translates to:
  /// **'All evaluations were made by our testing team'**
  String get allEvaluationsByTestTeam;

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

  /// No description provided for @shareMessage.
  ///
  /// In en, this message translates to:
  /// **'Check out the Cortex app, it is so amazing! Download it here: https://play.google.com/store/apps/details?id=com.vertex.cortex'**
  String get shareMessage;

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

  /// No description provided for @showLatex.
  ///
  /// In en, this message translates to:
  /// **'Show Special Symbols'**
  String get showLatex;

  /// No description provided for @hideLatex.
  ///
  /// In en, this message translates to:
  /// **'Hide Special Symbols'**
  String get hideLatex;

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

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @redeemCode.
  ///
  /// In en, this message translates to:
  /// **'Redeem Code'**
  String get redeemCode;

  /// No description provided for @enterYourCode.
  ///
  /// In en, this message translates to:
  /// **'Support your favorite creators! Enter their unique code below to give them a share of your Cortex purchases.'**
  String get enterYourCode;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @redeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get redeem;

  /// No description provided for @codeCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Code cannot be empty'**
  String get codeCannotBeEmpty;

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

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

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

  /// No description provided for @deutsch.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get deutsch;

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

  /// No description provided for @passwordTooLong.
  ///
  /// In en, this message translates to:
  /// **'Password cannot exceed 64 characters.'**
  String get passwordTooLong;

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

  /// No description provided for @inappropriateMessageWarning.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate message detected!'**
  String get inappropriateMessageWarning;

  /// No description provided for @myModelDescription.
  ///
  /// In en, this message translates to:
  /// **'My model.'**
  String get myModelDescription;

  /// No description provided for @noModelsDownloaded.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t downloaded any models yet.'**
  String get noModelsDownloaded;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Cortex'**
  String get appTitle;

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

  /// No description provided for @modelUploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Model uploaded successfully.'**
  String get modelUploadedSuccessfully;

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

  /// Button text to buy a specific number of credits
  ///
  /// In en, this message translates to:
  /// **'Buy {amount} Credits'**
  String creditPackage(Object amount);

  /// No description provided for @benefit1.
  ///
  /// In en, this message translates to:
  /// **'Many more conversation limit for online AIs'**
  String get benefit1;

  /// No description provided for @benefit2.
  ///
  /// In en, this message translates to:
  /// **'Upload your own models'**
  String get benefit2;

  /// No description provided for @benefit3.
  ///
  /// In en, this message translates to:
  /// **'Profile effect'**
  String get benefit3;

  /// No description provided for @benefit4.
  ///
  /// In en, this message translates to:
  /// **'Membership badge'**
  String get benefit4;

  /// No description provided for @benefit5.
  ///
  /// In en, this message translates to:
  /// **'Create more online artificial intelligences'**
  String get benefit5;

  /// No description provided for @benefit6.
  ///
  /// In en, this message translates to:
  /// **'Unlimited chat'**
  String get benefit6;

  /// No description provided for @benefit7.
  ///
  /// In en, this message translates to:
  /// **'{credits} daily credits'**
  String benefit7(Object credits);

  /// No description provided for @benefit8.
  ///
  /// In en, this message translates to:
  /// **'Add models'**
  String get benefit8;

  /// No description provided for @benefit9.
  ///
  /// In en, this message translates to:
  /// **'New themes'**
  String get benefit9;

  /// No description provided for @benefit10.
  ///
  /// In en, this message translates to:
  /// **'Offline voice chat'**
  String get benefit10;

  /// No description provided for @oldBenefits.
  ///
  /// In en, this message translates to:
  /// **'All benefits from lower plans'**
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

  /// No description provided for @downloadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloadingTitle;

  /// No description provided for @downloadCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Download Completed'**
  String get downloadCompletedTitle;

  /// No description provided for @downloadPausedTitle.
  ///
  /// In en, this message translates to:
  /// **'Download Paused'**
  String get downloadPausedTitle;

  /// No description provided for @downloadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Download Error'**
  String get downloadErrorTitle;

  /// No description provided for @cancelButtonText.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonText;

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

  /// No description provided for @featureIndulgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Indulgent'**
  String get featureIndulgentTitle;

  /// No description provided for @featureIndulgentDescription.
  ///
  /// In en, this message translates to:
  /// **'This model can seamlessly accommodate and process contexts exceeding 100,000 tokens, enabling it to handle extensive and detailed inputs without compromising performance.'**
  String get featureIndulgentDescription;

  /// No description provided for @featurePluralTitle.
  ///
  /// In en, this message translates to:
  /// **'Plural'**
  String get featurePluralTitle;

  /// No description provided for @featurePluralDescription.
  ///
  /// In en, this message translates to:
  /// **'This model can automatically integrate additional extensions, thereby expanding its functional capabilities to support a diverse range of operations with enhanced performance.'**
  String get featurePluralDescription;

  /// No description provided for @featureWiseTitle.
  ///
  /// In en, this message translates to:
  /// **'Wise'**
  String get featureWiseTitle;

  /// No description provided for @featureWiseDescription.
  ///
  /// In en, this message translates to:
  /// **'This model can leverage deep analytical insights and forward-thinking reasoning to deliver sophisticated support for decision-making and complex problem-solving.'**
  String get featureWiseDescription;

  /// No description provided for @featureResearcherTitle.
  ///
  /// In en, this message translates to:
  /// **'Researcher'**
  String get featureResearcherTitle;

  /// No description provided for @featureResearcherDescription.
  ///
  /// In en, this message translates to:
  /// **'Exclusively available in models equipped with advanced research and analytical capacities, this feature is designed to provide high-precision insights and comprehensive analysis across diverse domains.'**
  String get featureResearcherDescription;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'AI name'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your AI\'s name'**
  String get nameHint;

  /// No description provided for @summaryLabel.
  ///
  /// In en, this message translates to:
  /// **'AI Summary'**
  String get summaryLabel;

  /// No description provided for @summaryHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your AI\'s summary'**
  String get summaryHint;

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

  /// No description provided for @characterPoliceTitle.
  ///
  /// In en, this message translates to:
  /// **'Police'**
  String get characterPoliceTitle;

  /// No description provided for @characterPoliceRole.
  ///
  /// In en, this message translates to:
  /// **'You are a vigilant enforcer of the law, dedicated to protecting citizens and maintaining order with unwavering commitment, you are a police'**
  String get characterPoliceRole;

  /// No description provided for @characterPoliceShortDescription.
  ///
  /// In en, this message translates to:
  /// **'A steadfast and courageous law enforcer.'**
  String get characterPoliceShortDescription;

  /// No description provided for @purchaseSubscription.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchaseSubscription;

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

  /// No description provided for @addServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Artificial Intelligence Server'**
  String get addServerTitle;

  /// No description provided for @addServerDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the URL of your remote server to connect with an externally hosted model. This feature requires an active internet connection, and any server-related issues or errors are not caused by Cortex. Ensure your server is correctly configured, accessible from your network, and has a valid model endpoint for a smooth experience.'**
  String get addServerDescription;

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

  /// No description provided for @serverLink.
  ///
  /// In en, this message translates to:
  /// **'Server Link'**
  String get serverLink;

  /// No description provided for @enterURL.
  ///
  /// In en, this message translates to:
  /// **'Enter server URL'**
  String get enterURL;

  /// No description provided for @chatLengthLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'This chat has exceeded the character limit. Please start a new chat or purchase a subscription.'**
  String get chatLengthLimitExceeded;

  /// No description provided for @aiNameError.
  ///
  /// In en, this message translates to:
  /// **'An AI with this name already exists.'**
  String get aiNameError;

  /// No description provided for @modelLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'You have reached the maximum model creation limit for your plan.'**
  String get modelLimitExceeded;

  /// No description provided for @modelVertexProducer.
  ///
  /// In en, this message translates to:
  /// **'Vertex'**
  String get modelVertexProducer;

  /// No description provided for @photoLimitReachedMessage.
  ///
  /// In en, this message translates to:
  /// **'Only one photo can be added'**
  String get photoLimitReachedMessage;

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

  /// No description provided for @insufficientCredits.
  ///
  /// In en, this message translates to:
  /// **'You do not have enough credits to complete this request. This action requires {required} credits, but you only have {available}. To gain more credits, you can upgrade your plan or purchase them directly. hey we totally get it running out of credits can be a bit of a bummer but seriously getting those awesome replies from our models isnt free so these credits actually help us keep the good times rolling and listen if more of you guys jump in and get credits we can totally look at bumping up those free daily limits for everyone'**
  String insufficientCredits(Object available, Object required);

  /// No description provided for @regenerateInProgress.
  ///
  /// In en, this message translates to:
  /// **'Answer generation is already in progress.'**
  String get regenerateInProgress;

  /// No description provided for @errorOccurredDuringRegeneration.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while trying to regenerate: {errorDetails}'**
  String errorOccurredDuringRegeneration(String errorDetails);

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

  /// No description provided for @errorInsufficientCredits.
  ///
  /// In en, this message translates to:
  /// **'You have insufficient credits. Please top up to continue.'**
  String get errorInsufficientCredits;

  /// No description provided for @errorRateLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again in a moment.'**
  String get errorRateLimitExceeded;

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

  /// No description provided for @noModelsFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No Results'**
  String get noModelsFoundTitle;

  /// No description provided for @noModelsFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search terms or clearing the filter.'**
  String get noModelsFoundMessage;

  /// No description provided for @usernameRateLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'You can only change your username twice every 14 days.'**
  String get usernameRateLimitExceeded;

  /// No description provided for @usernameUnchanged.
  ///
  /// In en, this message translates to:
  /// **'This is already your current username.'**
  String get usernameUnchanged;

  /// No description provided for @creditsInfoPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'How Credits Work'**
  String get creditsInfoPanelTitle;

  /// No description provided for @creditsInfoPanelBody.
  ///
  /// In en, this message translates to:
  /// **'Credits are used to chat with online models. every single message costs us cash and these credits keepin us from going broke now lets explain the system \n\n• Each message to a free online model costs 10 credits.\n• Each message to an online premium model costs 20 credits.\n• Including an attachment adds 30 more credits.\n• Free plan users get a 200 credit bonus that resets daily.'**
  String get creditsInfoPanelBody;

  /// No description provided for @creditsInfoPanelFooter.
  ///
  /// In en, this message translates to:
  /// **'Happy chatting!'**
  String get creditsInfoPanelFooter;

  /// No description provided for @disclaimerMessage.
  ///
  /// In en, this message translates to:
  /// **'Artificial Intelligences can make mistakes, check important information.'**
  String get disclaimerMessage;

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
  /// **'Log in to your Vertex account. New users signing up via Google agree to our Terms & Privacy Policy. You can review them on the Sign Up screen.'**
  String get loginSubtitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a Vertex account, which you can also use for our other projects.'**
  String get registerSubtitle;

  /// No description provided for @photoWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'A photo is included. Models that don\'t support images may ignore it.'**
  String get photoWarningMessage;

  /// No description provided for @loginRequiredForPurchase.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to make a purchase.'**
  String get loginRequiredForPurchase;

  /// No description provided for @storagePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Storage permission is required to save downloaded models. Please grant permission to continue.'**
  String get storagePermissionRequired;

  /// No description provided for @creditBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Get Free Credits!'**
  String get creditBannerTitle;

  /// No description provided for @creditBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite a friend and you both get 50 credits on sign-up! If they subscribe, you both get an extra 500!'**
  String get creditBannerSubtitle;

  /// No description provided for @inviteShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Join me on Cortex!'**
  String get inviteShareSubject;

  /// The text message to share with a friend for an invite.
  ///
  /// In en, this message translates to:
  /// **'yo you gotta check out this app cortex its actually insane if you use my link we both get 50 credits and if you sub we both get an extra 500 its a crazy deal download it asap\n\n{playStoreLink}'**
  String inviteShareMessage(String playStoreLink);

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

  /// No description provided for @extensionInfoPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Models'**
  String get extensionInfoPanelTitle;

  /// No description provided for @extensionInfoPanelBody1.
  ///
  /// In en, this message translates to:
  /// **'This arrow lets you switch between different models within this series.'**
  String get extensionInfoPanelBody1;

  /// No description provided for @extensionInfoPanelBody2.
  ///
  /// In en, this message translates to:
  /// **'When you first start a chat with this series, the default model is automatically selected and you can change your selection at any time during a chat.'**
  String get extensionInfoPanelBody2;

  /// No description provided for @extensionInfoPanelFooter.
  ///
  /// In en, this message translates to:
  /// **'To view detailed information about each model or to manually select a different model, please go to the Library; select this model series from there and tap the arrow at the top of its detail page.'**
  String get extensionInfoPanelFooter;

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
