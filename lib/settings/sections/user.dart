// user.dart

import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:cortex/main.dart';
import 'package:cortex/server/fetch.dart';
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
import '../../login/login.dart';
import '../../models/backend/data.dart';
import '../../models/backend/download.dart';
import '../../notifications.dart';

// Helper Widget for Shake Animation (No changes needed)
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final AnimationController controller;
  const ShakeWidget({Key? key, required this.child, required this.controller})
      : super(key: key);
  @override
  ShakeWidgetState createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget> {
  late Animation<double> _animation;
  VoidCallback? _animationListener;
  void Function(AnimationStatus)? _statusListener;
  @override
  void initState() {
    super.initState();
    _animation = Tween<double>(begin: -5, end: 5).animate(
        CurvedAnimation(parent: widget.controller, curve: Curves.elasticIn));
    _animationListener = () {
      if (mounted) {
        setState(() {});
      }
    };
    _statusListener = (status) {
      if (status == AnimationStatus.completed) {
        widget.controller.reset();
      }
    };
    _animation.addListener(_animationListener!);
    widget.controller.addStatusListener(_statusListener!);
  }

  @override
  void dispose() {
    if (_animationListener != null) {
      _animation.removeListener(_animationListener!);
    }
    if (_statusListener != null) {
      widget.controller.removeStatusListener(_statusListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
        offset: Offset(_animation.value, 0), child: widget.child);
  }
}

class UserSection extends StatefulWidget {
  final AppLocalizations appLocalizations;
  final NotificationService notificationService;
  final Map<String, dynamic>? userData;
  final VoidCallback fetchUserDataCallback;
  final RegExp usernameRegExp;
  final AnimationController editProfileShakeController;
  final AnimationController oldPasswordShakeController;
  final AnimationController newPasswordShakeController;
  final AnimationController confirmPasswordShakeController;
  final bool isDialogOpen;
  final Function(bool) onDialogStateChanged;
  final Future<bool> Function() hasInternetConnectionCallback;

  const UserSection({
    Key? key,
    required this.appLocalizations,
    required this.notificationService,
    required this.userData,
    required this.fetchUserDataCallback,
    required this.usernameRegExp,
    required this.editProfileShakeController,
    required this.oldPasswordShakeController,
    required this.newPasswordShakeController,
    required this.confirmPasswordShakeController,
    required this.isDialogOpen,
    required this.onDialogStateChanged,
    required this.hasInternetConnectionCallback,
  }) : super(key: key);

  @override
  UserSectionState createState() => UserSectionState();
}

class UserSectionState extends State<UserSection> {

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isPasswordUser = false;

  @override
  void initState() {
    super.initState();
    _checkUserProvider();
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
          splashColor: AppColors.quaternaryColor.withOpacity(0.3),
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

  void _showEditProfileDialog() {
    if (widget.isDialogOpen) return;
    widget.onDialogStateChanged(true);

    final appLocalizations = widget.appLocalizations;
    final nameController =
        TextEditingController(text: widget.userData?['username'] ?? '');
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
                      final currentUsername =
                          widget.userData?['username'] ?? "";

                      // Client-side validation is still useful for quick feedback.
                      if (newName.isEmpty) {
                        setStateDialog(() => editUsernameError =
                            appLocalizations.usernameTooShort);
                        widget.editProfileShakeController.forward(from: 0);
                        return;
                      }
                      if (newName.toLowerCase() ==
                          currentUsername.toLowerCase()) {
                        Navigator.of(ctx).pop();
                        return;
                      }
                      if (!widget.usernameRegExp.hasMatch(newName)) {
                        setStateDialog(() => editUsernameError =
                            appLocalizations.invalidUsernameCharacters);
                        widget.editProfileShakeController.forward(from: 0);
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
                          widget.fetchUserDataCallback();
                          await FetchService.updateProfileInitial(newName);
                        }
                      } on FirebaseFunctionsException catch (e) {
                        setStateDialog(() {
                          editUsernameError = getLocalizedErrorMessage(e.code);
                        });
                        widget.editProfileShakeController.forward(from: 0);
                        debugPrint(
                            "FirebaseFunctionsException: ${e.code} - ${e.message}");
                      } catch (e) {
                        setStateDialog(() {
                          editUsernameError = appLocalizations.anErrorOccurred;
                        });
                        widget.editProfileShakeController.forward(from: 0);
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
                                          widget.editProfileShakeController,
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
                                              .withOpacity(0.1),
                                          highlightColor: AppColors.senaryColor
                                              .withOpacity(0.1),
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
                                                      color:
                                                          AppColors.senaryColor,
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
                                              .withOpacity(0.1),
                                          highlightColor: AppColors
                                              .septenaryColor
                                              .withOpacity(0.1),
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
                                            .withOpacity(0.4),
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
                                            .withOpacity(0.1),
                                        highlightColor: AppColors.senaryColor
                                            .withOpacity(0.1),
                                        onTap: () => Navigator.of(ctx).pop(),
                                        child: Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            child: Text(appLocalizations.no,
                                                style: TextStyle(
                                                    color:
                                                        AppColors.senaryColor,
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
                                            .withOpacity(0.1),
                                        highlightColor: AppColors.septenaryColor
                                            .withOpacity(0.1),
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

  /// This now includes clearing all credentials from `flutter_secure_storage`
  /// to ensure the 'Remember Me' feature is completely reset on logout.
  Future<void> _performLogout() async {
    // Instantiate secure storage to clear it.
    final secureStorage = const FlutterSecureStorage();

    // Clear all in-memory caches first to prevent data leaks between sessions.
    ModelData.clearCache();
    debugPrint("[UserSection] In-memory model cache cleared.");
    await FileDownloadHelper().cancelAllPendingDownloads();
    await FetchService.clearProfileInitial();
    CacheService.clearAll();
    debugPrint("[UserSection] All other in-memory caches and services cleared.");

    // Reset System UI for the login screen.
    final overlay = AppColors.getSystemUIOverlayStyleForTheme(AppColors.currentTheme);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: overlay['navigationBarColor'] as Color,
        systemNavigationBarIconBrightness: overlay['navigationBarIconBrightness'] as Brightness
    ));

    // CRITICAL NEW STEP: Clear all stored credentials from the device's secure vault.
    // This is the most important part of the new logout process.
    await secureStorage.deleteAll();
    debugPrint("[UserSection] All credentials cleared from secure storage.");

    final notificationService = Provider.of<NotificationService>(context, listen: false);

    await notificationService.clearUserTokenOnSignOut();

    debugPrint("[UserSection] FCM token cleared.");

    // Sign out from all authentication providers.
    try {
      await _googleSignIn.signOut();
      debugPrint("[UserSection] Google Sign-Out successful.");
    } catch (e) {
      debugPrint("[UserSection] No active Google session to sign out from, or an error occurred: $e");
    }

    await FirebaseAuth.instance.signOut();
    debugPrint("[UserSection] Firebase Sign-Out successful.");

    if (!mounted) return;

    // Navigate back to the login screen, removing all previous routes.
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false
    );
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
          // Klavye açıldığında taşmayı önler
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
                        widget.oldPasswordShakeController.forward(from: 0);
                        return;
                      }
                      if (newPassword.isEmpty || newPassword.length < 6) {
                        setStateDialog(() {
                          newPasswordError = appLocalizations.weakPassword;
                        });
                        widget.newPasswordShakeController.forward(from: 0);
                        return;
                      }
                      if (confirmPassword != newPassword) {
                        setStateDialog(() {
                          confirmPasswordError =
                              appLocalizations.passwordsDoNotMatch;
                        });
                        widget.confirmPasswordShakeController.forward(from: 0);
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
                          widget.oldPasswordShakeController.forward(from: 0);
                        } else if (e.code == 'weak-password') {
                          setStateDialog(() {
                            newPasswordError = appLocalizations.weakPassword;
                          });
                          widget.newPasswordShakeController.forward(from: 0);
                        } else {
                          debugPrint(
                              "Change Password FirebaseAuth Error: ${e.code} - ${e.message}");
                          setStateDialog(() {
                            oldPasswordError = appLocalizations.authError;
                          });
                          widget.oldPasswordShakeController.forward(from: 0);
                        }
                      } catch (e) {
                        setStateDialog(() => isLoading = false);
                        debugPrint("Change Password Generic Error: $e");
                        setStateDialog(() {
                          oldPasswordError = appLocalizations.updateFailed;
                        });
                        widget.oldPasswordShakeController.forward(from: 0);
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
                                            widget.oldPasswordShakeController,
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
                                                        color:
                                                            AppColors.border),
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
                                            widget.newPasswordShakeController,
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
                                                        color:
                                                            AppColors.border),
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
                                        controller: widget
                                            .confirmPasswordShakeController,
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
                                                        color:
                                                            AppColors.border),
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
                                          .withOpacity(0.1),
                                      highlightColor: AppColors.senaryColor
                                          .withOpacity(0.1),
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
                                          .withOpacity(0.1),
                                      highlightColor: AppColors.septenaryColor
                                          .withOpacity(0.1),
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
              _showEditProfileDialog();
            } else {
              widget.notificationService.showNotification(
                  bottomOffset: 0.02,
                  isSuccess: false,
                  message: appLocalizations.noInternetConnection);
            }
          },
        ),
        SizedBox(height: screenHeight * 0.015),
        // DEĞİŞİKLİK: Şifre değiştirme butonu artık sadece şifreyle giriş yapan kullanıcılara gösteriliyor.
        _buildCenteredButton(
          context: context,
          text: appLocalizations.changePassword,
          enabled: _isPasswordUser, // Butonu etkinleştirir/devre dışı bırakır.
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
  }
}
