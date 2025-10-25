// user.dart

import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:cortex/app.dart';
import 'package:cortex/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../cache.dart';
import '../../darkener.dart';
import '../../models/backend/data/data.dart';
import '../../models/backend/download.dart';
import '../../notifications.dart';
import '../../server/user.dart';
import '../../shake.dart';

class UserSection extends StatefulWidget {
  final AppLocalizations appLocalizations;
  final NotificationService notificationService;
  final Function(bool) onDialogStateChanged;
  final bool isDialogOpen;
  final Future<bool> Function() hasInternetConnectionCallback;

  const UserSection({
    super.key,
    required this.appLocalizations,
    required this.notificationService,
    required this.onDialogStateChanged,
    required this.isDialogOpen,
    required this.hasInternetConnectionCallback,
  });

  @override
  UserSectionState createState() => UserSectionState();
}

class UserSectionState extends State<UserSection> with TickerProviderStateMixin {
  // Animation controllers are now managed by the State.
  late final AnimationController editProfileShakeController;
  late final AnimationController oldPasswordShakeController;
  late final AnimationController newPasswordShakeController;
  late final AnimationController confirmPasswordShakeController;

  // The RegExp is now a constant within the State.
  final RegExp usernameRegExp = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isPasswordUser = false;

  @override
  void initState() {
    super.initState();

    // Initialize all animation controllers.
    const shakeDuration = Duration(milliseconds: 500);
    editProfileShakeController = AnimationController(vsync: this, duration: shakeDuration);
    oldPasswordShakeController = AnimationController(vsync: this, duration: shakeDuration);
    newPasswordShakeController = AnimationController(vsync: this, duration: shakeDuration);
    confirmPasswordShakeController = AnimationController(vsync: this, duration: shakeDuration);

    _checkUserProvider();
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is removed to prevent memory leaks.
    editProfileShakeController.dispose();
    oldPasswordShakeController.dispose();
    newPasswordShakeController.dispose();
    confirmPasswordShakeController.dispose();
    super.dispose();
  }

  void _checkUserProvider() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final hasPasswordProvider = user.providerData
          .any((provider) => provider.providerId == 'password');
      if (mounted) {
        setState(() {
          _isPasswordUser = hasPasswordProvider;
        });
      }
    }
  }

  Widget _buildCenteredButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    bool enabled = true,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Material(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(10.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(10.0),
          splashColor: AppColors.quaternaryColor.withValues(alpha: 0.3),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.02,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: GoogleFonts.roboto(
                    color: AppColors.primaryColor.inverted,
                    fontSize: screenWidth * 0.041111,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primaryColor.inverted,
                  size: screenWidth * 0.04,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(Map<String, dynamic> userData) {
    if (widget.isDialogOpen) return;
    widget.onDialogStateChanged(true);

    final appLocalizations = widget.appLocalizations;
    final nameController =
        TextEditingController(text: userData['username'] ?? '');
    String? editUsernameError;
    bool isLoading = false;

    String getLocalizedErrorMessage(String errorCode) {
      switch (errorCode) {
        case "already-exists":
          return appLocalizations.usernameTaken;
        case "invalid-argument":
          return appLocalizations.invalidUsernameCharacters;
        case "resource-exhausted":
          return appLocalizations.usernameRateLimitExceeded;
        case "not-found": // Should not happen, but good to handle
        default:
          return appLocalizations.anErrorOccurred;
      }
    }

    final RestoreCallback restoreNavBar = Darkener.darken();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'EditProfile',
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return Center(
            child: SingleChildScrollView(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(ctx).size.width * 0.8,
              decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(10)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: StatefulBuilder(
                  builder: (dialogContext, setStateDialog) {
                    Future<void> handleUpdateUsername() async {
                      final newName = nameController.text.trim();
                      final currentUsername = userData['username'] ?? "";

                      // Client-side validation is still useful for quick feedback.
                      if (newName.isEmpty) {
                        setStateDialog(() => editUsernameError =
                            appLocalizations.usernameTooShort);
                        editProfileShakeController.forward(from: 0);
                        return;
                      }
                      if (newName.toLowerCase() ==
                          currentUsername.toLowerCase()) {
                        Navigator.of(ctx).pop();
                        return;
                      }
                      if (!usernameRegExp.hasMatch(newName)) { // <<< CORRECTED
                        setStateDialog(() => editUsernameError = appLocalizations.invalidUsernameCharacters);
                        editProfileShakeController.forward(from: 0); // <<< CORRECTED
                        return;
                      }

                      setStateDialog(() {
                        isLoading = true;
                        editUsernameError = null;
                      });

                      try {
                        final HttpsCallable callable =
                            FirebaseFunctions.instanceFor(
                                    region: 'europe-west1')
                                .httpsCallable('updateUsername');
                        await callable.call({'newUsername': newName});

                        if (mounted) {
                          Navigator.of(ctx).pop();
                          widget.notificationService.showNotification(
                            message: appLocalizations.profileUpdated,
                            isSuccess: true,
                            bottomOffset: 0.02,
                          );
                        }
                      } on FirebaseFunctionsException catch (e) {
                        setStateDialog(() {
                          editUsernameError = getLocalizedErrorMessage(e.code);
                        });
                        editProfileShakeController.forward(from: 0);
                        debugPrint(
                            "FirebaseFunctionsException: ${e.code} - ${e.message}");
                      } catch (e) {
                        setStateDialog(() {
                          editUsernameError = appLocalizations.anErrorOccurred;
                        });
                        editProfileShakeController.forward(from: 0);
                        debugPrint("Generic error calling updateUsername: $e");
                      } finally {
                        if (mounted) {
                          setStateDialog(() => isLoading = false);
                        }
                      }
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(appLocalizations.editProfile,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryColor.inverted),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                              Text(appLocalizations.usernameRateLimitExceeded,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.quinaryColor,
                                      fontStyle: FontStyle.italic)),
                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShakeWidget(
                                      controller:
                                          editProfileShakeController,
                                      child: TextField(
                                          controller: nameController,
                                          maxLength: 20,
                                          style: TextStyle(
                                              color: AppColors
                                                  .primaryColor.inverted),
                                          decoration: InputDecoration(
                                              labelText:
                                                  appLocalizations.username,
                                              labelStyle: TextStyle(
                                                  color: AppColors
                                                      .primaryColor.inverted),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0,
                                                      vertical: 16.0),
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: AppColors.border),
                                                  borderRadius: BorderRadius.circular(
                                                      10.0)),
                                              focusedBorder:
                                                  OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor.inverted), borderRadius: BorderRadius.circular(10.0)),
                                              counterText: ''))),
                                  AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: editUsernameError != null
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0, left: 4.0),
                                              child: Text(editUsernameError!,
                                                  style: const TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12),
                                                  key: ValueKey(
                                                      editUsernameError)))
                                          : const SizedBox.shrink(
                                              key: ValueKey(
                                                  "emptyUsernameError"))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(
                            color: AppColors.border, thickness: 0.5, height: 1),
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                  child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                          splashColor: AppColors.senaryColor
                                              .withValues(alpha: 0.1),
                                          highlightColor: AppColors.senaryColor
                                              .withValues(alpha: 0.1),
                                          onTap: isLoading
                                              ? null
                                              : () => Navigator.of(ctx).pop(),
                                          child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              child: Text(
                                                  appLocalizations.cancel,
                                                  style: TextStyle(
                                                      color: AppColors.senaryColor,
                                                      fontSize: 16)))))),
                              VerticalDivider(
                                  width: 1,
                                  thickness: 0.5,
                                  color: AppColors.border),
                              Expanded(
                                  child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                          splashColor: AppColors.septenaryColor
                                              .withValues(alpha: 0.1),
                                          highlightColor: AppColors
                                              .septenaryColor
                                              .withValues(alpha: 0.1),
                                          onTap: isLoading
                                              ? null
                                              : handleUpdateUsername,
                                          child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              child: isLoading
                                                  ? SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                          strokeWidth: 2.0,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<Color>(
                                                                  AppColors.primaryColor.inverted)))
                                                  : Text(appLocalizations.save, style: TextStyle(color: AppColors.septenaryColor, fontSize: 16)))))),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ));
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    ).whenComplete(() {
      restoreNavBar();
      widget.onDialogStateChanged(false);
    });
  }

  // --- (Logout and Change Password dialogs have no major logical changes needed) ---
  Future<void> _showLogoutConfirmationDialog() async {
    if (widget.isDialogOpen) return;
    widget.onDialogStateChanged(true);

    final appLocalizations = widget.appLocalizations;
    final RestoreCallback restoreNavBar = Darkener.darken();
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Logout',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return Center(
            child: Material(
                color: Colors.transparent,
                child: Container(
                    width: MediaQuery.of(ctx).size.width * 0.8,
                    decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(children: [
                                Text(appLocalizations.logout,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryColor.inverted),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                Text(appLocalizations.logoutConfirmationTitle,
                                    style: TextStyle(
                                        color: AppColors.primaryColor.inverted
                                            .withValues(alpha: 0.4),
                                        fontSize: 14),
                                    textAlign: TextAlign.center)
                              ])),
                          Divider(
                              color: AppColors.border,
                              thickness: 0.5,
                              height: 1),
                          IntrinsicHeight(
                              child: Row(children: [
                            Expanded(
                                child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                        splashColor: AppColors.senaryColor
                                            .withValues(alpha: 0.1),
                                        highlightColor: AppColors.senaryColor
                                            .withValues(alpha: 0.1),
                                        onTap: () => Navigator.of(ctx).pop(),
                                        child: Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            child: Text(appLocalizations.no,
                                                style: TextStyle(
                                                    color: AppColors.senaryColor,
                                                    fontSize: 16)))))),
                            VerticalDivider(
                                width: 1,
                                thickness: 0.5,
                                color: AppColors.border),
                            Expanded(
                                child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                        splashColor: AppColors.septenaryColor
                                            .withValues(alpha: 0.1),
                                        highlightColor: AppColors.septenaryColor
                                            .withValues(alpha: 0.1),
                                        onTap: () => _performLogout(),
                                        child: Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            child: Text(appLocalizations.yes,
                                                style: TextStyle(
                                                    color: AppColors
                                                        .septenaryColor,
                                                    fontSize: 16))))))
                          ]))
                        ])))));
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ).whenComplete(() {
      restoreNavBar();
      widget.onDialogStateChanged(false);
    });
  }

  /// Handles the complete user logout process.
  Future<void> _performLogout() async {
    // IMPORTANT: Grab any provider that needs `context` *before* any async gaps,
    // especially before signOut(), which will cause this widget to be unmounted.
    final notificationService = Provider.of<NotificationService>(context, listen: false);

    // STEP 1: Sign out of Firebase immediately.
    // This is the most critical step for the UI. It triggers the listener that
    // rebuilds the app's widget tree and shows the login screen.
    await FirebaseAuth.instance.signOut();
    debugPrint("[UserSection] Firebase Sign-Out successful. UI transition has been initiated.");

    // STEP 2: Perform all other cleanup tasks.
    // From the user's perspective, these are now running in the background as they
    // are already being navigated away from this screen.

    // Sign out from other providers like Google.
    try {
      await _googleSignIn.signOut();
      debugPrint("[UserSection] Google Sign-Out successful.");
    } catch (e) {
      debugPrint("[UserSection] No active Google session to sign out from, or an error occurred: $e");
    }

    // Clear all stored credentials from the device's secure vault.
    final secureStorage = const FlutterSecureStorage();
    await secureStorage.deleteAll();
    debugPrint("[UserSection] All credentials cleared from secure storage.");

    // Clear the user's FCM token from the server to stop notifications.
    await notificationService.clearUserTokenOnSignOut();
    debugPrint("[UserSection] FCM token cleared from server.");

    // Clear all in-memory caches to prevent data leaks between sessions.
    ModelData.clearCache();
    CacheService.clearAll();
    debugPrint("[UserSection] All in-memory caches cleared.");

    // Cancel any ongoing file downloads.
    await FileDownloadHelper().cancelAllPendingDownloads();

    // Reset System UI for the login screen that is now being displayed.
    final overlay = AppColors.getSystemUIOverlayStyleForTheme(AppColors.currentTheme);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: overlay['navigationBarColor'] as Color,
        systemNavigationBarIconBrightness: overlay['navigationBarIconBrightness'] as Brightness
    ));
  }

  void _showChangePasswordDialog() {
    if (widget.isDialogOpen) return;
    widget.onDialogStateChanged(true);
    final appLocalizations = widget.appLocalizations;
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    String? oldPasswordError;
    String? newPasswordError;
    String? confirmPasswordError;
    bool isLoading = false;
    final RestoreCallback restoreNavBar = Darkener.darken();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ChangePassword',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return Center(
            child: SingleChildScrollView(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(ctx).size.width * 0.8,
              decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(10)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: StatefulBuilder(
                  builder: (dialogContext, setStateDialog) {
                    Future<void> attemptChangePassword() async {
                      final oldPassword = oldPasswordController.text.trim();
                      final newPassword = newPasswordController.text.trim();
                      final confirmPassword =
                          confirmPasswordController.text.trim();
                      setStateDialog(() {
                        oldPasswordError = null;
                        newPasswordError = null;
                        confirmPasswordError = null;
                      });
                      if (oldPassword.isEmpty) {
                        setStateDialog(() {
                          oldPasswordError = appLocalizations.passwordRequired;
                        });
                        oldPasswordShakeController.forward(from: 0);
                        return;
                      }
                      if (newPassword.isEmpty || newPassword.length < 6) {
                        setStateDialog(() {
                          newPasswordError = appLocalizations.weakPassword;
                        });
                        newPasswordShakeController.forward(from: 0);
                        return;
                      }
                      if (confirmPassword != newPassword) {
                        setStateDialog(() {
                          confirmPasswordError =
                              appLocalizations.passwordsDoNotMatch;
                        });
                        confirmPasswordShakeController.forward(from: 0);
                        return;
                      }
                      setStateDialog(() => isLoading = true);
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          if (!mounted) return;
                          Navigator.of(ctx).pop();
                          return;
                        }
                        final credential = EmailAuthProvider.credential(
                            email: user.email!, password: oldPassword);
                        await user.reauthenticateWithCredential(credential);
                        await user.updatePassword(newPassword);
                        setStateDialog(() => isLoading = false);
                        if (!mounted) return;
                        Navigator.of(ctx).pop();
                        widget.notificationService.showNotification(
                            message: appLocalizations.passwordUpdated,
                            isSuccess: true,
                            bottomOffset: 0.02);
                      } on FirebaseAuthException catch (e) {
                        setStateDialog(() => isLoading = false);
                        if (e.code == 'wrong-password' ||
                            e.code == 'INVALID_LOGIN_CREDENTIALS' ||
                            e.code == 'invalid-credential') {
                          setStateDialog(() {
                            oldPasswordError = appLocalizations.wrongPassword;
                          });
                          oldPasswordShakeController.forward(from: 0);
                        } else if (e.code == 'weak-password') {
                          setStateDialog(() {
                            newPasswordError = appLocalizations.weakPassword;
                          });
                          newPasswordShakeController.forward(from: 0);
                        } else {
                          debugPrint(
                              "Change Password FirebaseAuth Error: ${e.code} - ${e.message}");
                          setStateDialog(() {
                            oldPasswordError = appLocalizations.authError;
                          });
                          oldPasswordShakeController.forward(from: 0);
                        }
                      } catch (e) {
                        setStateDialog(() => isLoading = false);
                        debugPrint("Change Password Generic Error: $e");
                        setStateDialog(() {
                          oldPasswordError = appLocalizations.updateFailed;
                        });
                        oldPasswordShakeController.forward(from: 0);
                      }
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(children: [
                              Text(appLocalizations.changePassword,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryColor.inverted),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShakeWidget(
                                        controller:
                                            oldPasswordShakeController,
                                        child: TextField(
                                            controller: oldPasswordController,
                                            obscureText: true,
                                            style: TextStyle(
                                                color: AppColors
                                                    .primaryColor.inverted),
                                            decoration: InputDecoration(
                                                labelText: appLocalizations
                                                    .oldPassword,
                                                labelStyle: TextStyle(
                                                    color: AppColors
                                                        .primaryColor.inverted),
                                                enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: AppColors.border),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: AppColors.primaryColor.inverted),
                                                    borderRadius: BorderRadius.circular(10.0))))),
                                    AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: oldPasswordError != null
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(oldPasswordError!,
                                                    style: const TextStyle(
                                                        color: Colors.red),
                                                    key: ValueKey(
                                                        oldPasswordError)))
                                            : const SizedBox.shrink(
                                                key: ValueKey(
                                                    "emptyOldPassError")))
                                  ]),
                              const SizedBox(height: 20),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShakeWidget(
                                        controller:
                                            newPasswordShakeController,
                                        child: TextField(
                                            controller: newPasswordController,
                                            obscureText: true,
                                            style: TextStyle(
                                                color: AppColors
                                                    .primaryColor.inverted),
                                            decoration: InputDecoration(
                                                labelText: appLocalizations
                                                    .newPassword,
                                                labelStyle: TextStyle(
                                                    color: AppColors
                                                        .primaryColor.inverted),
                                                enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: AppColors.border),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: AppColors.primaryColor.inverted),
                                                    borderRadius: BorderRadius.circular(10.0))))),
                                    AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: newPasswordError != null
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(newPasswordError!,
                                                    style: const TextStyle(
                                                        color: Colors.red),
                                                    key: ValueKey(
                                                        newPasswordError)))
                                            : const SizedBox.shrink(
                                                key: ValueKey(
                                                    "emptyNewPassError")))
                                  ]),
                              const SizedBox(height: 20),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShakeWidget(
                                        controller: confirmPasswordShakeController,
                                        child: TextField(
                                            controller:
                                                confirmPasswordController,
                                            obscureText: true,
                                            style: TextStyle(
                                                color: AppColors
                                                    .primaryColor.inverted),
                                            decoration: InputDecoration(
                                                labelText: appLocalizations
                                                    .confirmPassword,
                                                labelStyle: TextStyle(
                                                    color: AppColors
                                                        .primaryColor.inverted),
                                                enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: AppColors.border),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: AppColors.primaryColor.inverted),
                                                    borderRadius: BorderRadius.circular(10.0))))),
                                    AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: confirmPasswordError != null
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                    confirmPasswordError!,
                                                    style: const TextStyle(
                                                        color: Colors.red),
                                                    key: ValueKey(
                                                        confirmPasswordError)))
                                            : const SizedBox.shrink(
                                                key: ValueKey(
                                                    "emptyConfirmPassError")))
                                  ])
                            ])),
                        Divider(
                            color: AppColors.border, thickness: 0.5, height: 1),
                        IntrinsicHeight(
                            child: Row(children: [
                          Expanded(
                              child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                      splashColor: AppColors.senaryColor
                                          .withValues(alpha: 0.1),
                                      highlightColor: AppColors.senaryColor
                                          .withValues(alpha: 0.1),
                                      onTap: isLoading
                                          ? null
                                          : () => Navigator.of(ctx).pop(),
                                      child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: Text(appLocalizations.cancel,
                                              style: TextStyle(
                                                  color: AppColors.senaryColor,
                                                  fontSize: 16)))))),
                          VerticalDivider(
                              width: 1,
                              thickness: 0.5,
                              color: AppColors.border),
                          Expanded(
                              child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                      splashColor: AppColors.septenaryColor
                                          .withValues(alpha: 0.1),
                                      highlightColor: AppColors.septenaryColor
                                          .withValues(alpha: 0.1),
                                      onTap: isLoading
                                          ? null
                                          : attemptChangePassword,
                                      child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: isLoading
                                              ? SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                      strokeWidth: 2.0,
                                                      valueColor: AlwaysStoppedAnimation<Color>(
                                                          AppColors.primaryColor
                                                              .inverted)))
                                              : Text(appLocalizations.save,
                                                  style: TextStyle(color: AppColors.septenaryColor, fontSize: 16))))))
                        ]))
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ));
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    ).whenComplete(() {
      restoreNavBar();
      widget.onDialogStateChanged(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the UI in a Consumer widget to listen to UserProvider.
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {

        // Add a guard clause: If the user is not logged in or data is not
        // yet available, render nothing to prevent errors during transitions.
        if (!userProvider.isLoggedIn) {
          return const SizedBox.shrink();
        }

        // THIS IS THE LINE THAT FIXES THE ERROR:
        // We define `userData` from the provider for use in this build scope.
        final userData = userProvider.userData!;

        // Now the rest of the build logic can safely use the `userData` variable.
        final appLocalizations = widget.appLocalizations;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalizations.user,
              style: GoogleFonts.roboto(
                  color: AppColors.primaryColor.inverted,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              appLocalizations.manageProfileDescription,
              style: GoogleFonts.roboto(
                  color: AppColors.quinaryColor, fontSize: screenWidth * 0.035),
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildCenteredButton(
              context: context,
              text: appLocalizations.editProfile,
              onPressed: () async {
                bool hasInternet = await widget.hasInternetConnectionCallback();
                if (hasInternet) {
                  // Now this call is valid because `userData` is defined.
                  _showEditProfileDialog(userData);
                } else {
                  widget.notificationService.showNotification(
                      bottomOffset: 0.02,
                      isSuccess: false,
                      message: appLocalizations.noInternetConnection);
                }
              },
            ),
            SizedBox(height: screenHeight * 0.015),
            _buildCenteredButton(
              context: context,
              text: appLocalizations.changePassword,
              enabled: _isPasswordUser,
              onPressed: () async {
                bool hasInternet = await widget.hasInternetConnectionCallback();
                if (hasInternet) {
                  _showChangePasswordDialog();
                } else {
                  widget.notificationService.showNotification(
                      bottomOffset: 0.02,
                      isSuccess: false,
                      message: appLocalizations.noInternetConnection);
                }
              },
            ),
            SizedBox(height: screenHeight * 0.015),
            _buildCenteredButton(
              context: context,
              text: appLocalizations.logout,
              onPressed: () async {
                bool hasInternet = await widget.hasInternetConnectionCallback();
                if (hasInternet) {
                  _showLogoutConfirmationDialog();
                } else {
                  widget.notificationService.showNotification(
                      bottomOffset: 0.02,
                      isSuccess: false,
                      message: appLocalizations.noInternetConnection);
                }
              },
            ),
          ],
        );
      },
    );
  }
}