// lib/settings/delete.dart

import 'dart:async';
import 'package:cortex/main.dart'; // Assuming ShakeWidget is defined here or in a common utility.
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:cloud_functions/cloud_functions.dart';

// Local imports
import '../../darkener.dart';
import '../../theme.dart';
import '../../login/login.dart';
import '../../notifications.dart';
import '../../cache.dart';
import '../../chat/services/storage.dart';

/// A widget that provides UI elements for deleting user conversations and account.
///
/// This section includes options to:
/// 1. Delete all user conversations (local operation, always available).
/// 2. Delete the user's account permanently (server operation, only available online).
class DeleteSection extends StatefulWidget {
  /// User data, potentially containing username or other relevant information.
  final Map<String, dynamic>? userData;

  /// The current internet connection status, passed from the parent widget.
  final bool hasInternet;

  final bool isFromActiveChat;

  const DeleteSection({
    Key? key,
    required this.userData,
    required this.hasInternet,
    this.isFromActiveChat = false,
  }) : super(key: key);

  @override
  DeleteSectionState createState() => DeleteSectionState();
}

class DeleteSectionState extends State<DeleteSection> with TickerProviderStateMixin {
  late AnimationController _deleteAccountPasswordShakeController;
  late AnimationController _deleteAllConversationsConfirmShakeController;
  bool _isDialogCurrentlyOpen = false;
  late NotificationService _notificationService;

  static const String _className = "DeleteSectionState";

  @override
  void initState() {
    super.initState();
    debugPrint("$_className: initState called.");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _notificationService = Provider.of<NotificationService>(context, listen: false);
        debugPrint("$_className: NotificationService initialized.");
      }
    });

    const shakeDuration = Duration(milliseconds: 500);
    _deleteAccountPasswordShakeController = AnimationController(vsync: this, duration: shakeDuration);
    _deleteAllConversationsConfirmShakeController = AnimationController(vsync: this, duration: shakeDuration);
    debugPrint("$_className: AnimationControllers initialized.");
  }

  @override
  void dispose() {
    debugPrint("$_className: dispose called.");
    _deleteAccountPasswordShakeController.dispose();
    _deleteAllConversationsConfirmShakeController.dispose();
    super.dispose();
  }

  void _setDialogState(bool isOpen) {
    if (mounted) {
      setState(() {
        _isDialogCurrentlyOpen = isOpen;
      });
    }
  }

  Future<bool> _checkInternet() async {
    bool hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet && mounted) {
      Provider.of<NotificationService>(context, listen: false).showNotification(
        bottomOffset: 0.02,
        message: AppLocalizations.of(context)!.noInternetConnection,
      );
    }
    return hasInternet;
  }

  /// Displays a confirmation dialog for deleting all user conversations.
  /// This is a local operation and does not require an internet connection.
  Future<void> _showDeleteAllConversationsDialog(AppLocalizations appLocalizations) async {
    final String methodName = "$_className: _showDeleteAllConversationsDialog";
    debugPrint("$methodName: Called for local conversation deletion.");

    if (_isDialogCurrentlyOpen) {
      debugPrint("$methodName: Aborted because a dialog is already open.");
      return;
    }
    _setDialogState(true);

    final TextEditingController confirmController = TextEditingController();
    String? confirmError;
    final RestoreCallback restoreNavBar = Darkener.darken();

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'DeleteAllConversationsDialogBarrier',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (dialogPageContext, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(dialogPageContext).size.width * 0.8,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: StatefulBuilder(
                  builder: (dialogContext, setDialogInnerState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                appLocalizations.deleteAllConversationsConfirmTitle,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor.inverted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                appLocalizations.deleteAllConversationsConfirmMessage,
                                style: TextStyle(
                                  color: AppColors.quinaryColor,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShakeWidget(
                                    controller: _deleteAllConversationsConfirmShakeController,
                                    child: TextField(
                                      controller: confirmController,
                                      style: TextStyle(color: AppColors.primaryColor.inverted),
                                      decoration: InputDecoration(
                                        labelText: appLocalizations.confirmWord,
                                        labelStyle: TextStyle(color: AppColors.primaryColor.inverted),
                                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.quinaryColor), borderRadius: BorderRadius.circular(10.0),),
                                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor.inverted), borderRadius: BorderRadius.circular(10.0),),
                                      ),
                                    ),
                                  ),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: confirmError != null
                                        ? Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(confirmError!, style: const TextStyle(color: Colors.red), key: ValueKey(confirmError),),
                                    )
                                        : const SizedBox.shrink(key: ValueKey("emptyConfirmError")),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(color: AppColors.quinaryColor, thickness: 0.5, height: 1),
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => Navigator.of(dialogPageContext).pop(),
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: Text(appLocalizations.cancel, style: TextStyle(color: AppColors.senaryColor, fontSize: 16),),
                                    ),
                                  ),
                                ),
                              ),
                              VerticalDivider(width: 1, thickness: 0.5, color: AppColors.quinaryColor),
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    splashColor: Colors.red.withOpacity(0.3),
                                    highlightColor: Colors.red.withOpacity(0.1),
                                    onTap: () async {
                                      // --- NEW LOGIC ---
                                      if (confirmController.text.trim() != "VERTEX") {
                                        setDialogInnerState(() => confirmError = appLocalizations.confirmWordError);
                                        _deleteAllConversationsConfirmShakeController.forward(from: 0);
                                        return;
                                      }

                                      // 1. Check if there's anything to delete.
                                      final bool hasConversations = await ChatStorageService.hasAnyConversations();

                                      if (!hasConversations) {
                                        debugPrint("$methodName: No conversations found to delete.");
                                        if (!mounted) return;
                                        Navigator.of(dialogPageContext).pop(); // Close the dialog
                                        _notificationService.showNotification(
                                          // Assuming you add this string to your .arb files
                                          message: appLocalizations.noConversationsToDelete,
                                          isSuccess: false, // Use 'fail' style for info
                                          bottomOffset: 0.02,
                                        );
                                        return;
                                      }

                                      // 2. If conversations exist, proceed with deletion.
                                      debugPrint("$methodName: Conversations found. Proceeding with deletion.");
                                      await ChatStorageService.deleteAllConversations();
                                      CacheService.invalidateConversationCache();

                                      if (!mounted) return;
                                      Navigator.of(dialogPageContext).pop();
                                      _notificationService.showNotification(
                                        message: appLocalizations.allConversationsDeleted,
                                        isSuccess: true,
                                        bottomOffset: 0.02,
                                      );
                                      // --- END OF NEW LOGIC ---
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: Text(appLocalizations.deleteAll, style: const TextStyle(color: Colors.red, fontSize: 16),),
                                    ),
                                  ),
                                ),
                              ),
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
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    ).whenComplete(() {
      restoreNavBar();
      _setDialogState(false);
    });
  }

  /// Displays a confirmation dialog for deleting the user's account.
  /// This is a server-dependent operation that calls a secure Cloud Function.
  Future<void> _showDeleteAccountDialog(AppLocalizations appLocalizations) async {
    final String methodName = "$_className: _showDeleteAccountDialog";
    debugPrint("$methodName: Called for server-side account deletion.");

    if (!await _checkInternet()) {
      debugPrint("$methodName: Aborted due to no internet connection.");
      return;
    }
    if (_isDialogCurrentlyOpen) {
      debugPrint("$methodName: Aborted because a dialog is already open.");
      return;
    }
    _setDialogState(true);

    final TextEditingController passwordController = TextEditingController();
    String? passwordError;
    final RestoreCallback restoreNavBar = Darkener.darken();

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'DeleteAccountDialogBarrier',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (dialogPageContext, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(dialogPageContext).size.width * 0.8,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: StatefulBuilder(
                  builder: (dialogContext, setDialogInnerState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(appLocalizations.confirmDeleteAccount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted,), textAlign: TextAlign.center,),
                              const SizedBox(height: 12),
                              Text(appLocalizations.enterPasswordToDelete, style: TextStyle(color: AppColors.quinaryColor, fontSize: 14,), textAlign: TextAlign.center,),
                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShakeWidget(
                                    controller: _deleteAccountPasswordShakeController,
                                    child: TextField(
                                      controller: passwordController,
                                      obscureText: true,
                                      style: TextStyle(color: AppColors.primaryColor.inverted),
                                      decoration: InputDecoration(
                                        labelText: appLocalizations.password,
                                        labelStyle: TextStyle(color: AppColors.primaryColor.inverted),
                                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.quinaryColor), borderRadius: BorderRadius.circular(10.0),),
                                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor.inverted), borderRadius: BorderRadius.circular(10.0),),
                                      ),
                                    ),
                                  ),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: passwordError != null
                                        ? Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(passwordError!, style: const TextStyle(color: Colors.red), key: ValueKey(passwordError),),
                                    )
                                        : const SizedBox.shrink(key: ValueKey("emptyPasswordError")),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(color: AppColors.quinaryColor, thickness: 0.5, height: 1),
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => Navigator.of(dialogPageContext).pop(),
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: Text(appLocalizations.cancel, style: TextStyle(color: AppColors.senaryColor, fontSize: 16),),
                                    ),
                                  ),
                                ),
                              ),
                              VerticalDivider(width: 1, thickness: 0.5, color: AppColors.quinaryColor),
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    splashColor: Colors.red.withOpacity(0.3),
                                    highlightColor: Colors.red.withOpacity(0.1),
                                    onTap: () async {
                                      final password = passwordController.text.trim();
                                      if (password.isEmpty) {
                                        setDialogInnerState(() => passwordError = appLocalizations.passwordRequired);
                                        _deleteAccountPasswordShakeController.forward(from: 0);
                                        return;
                                      }

                                      final user = FirebaseAuth.instance.currentUser;
                                      if (user == null) {
                                        if (mounted) Navigator.of(dialogPageContext).pop();
                                        return;
                                      }

                                      try {
                                        final credential = EmailAuthProvider.credential(
                                          email: user.email!,
                                          password: password,
                                        );
                                        await user.reauthenticateWithCredential(credential);

                                        debugPrint("$methodName: Re-authentication successful. Calling 'requestAccountDeletion' function...");
                                        final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
                                        await functions.httpsCallable('requestAccountDeletion').call();
                                        debugPrint("$methodName: 'requestAccountDeletion' function call completed successfully.");

                                        restoreNavBar();
                                        await FirebaseAuth.instance.signOut();

                                        if (!context.mounted) return;

                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                                              (Route<dynamic> route) => false,
                                        );

                                        _notificationService.showNotification(
                                            message: appLocalizations.accountDeletionRequested,
                                            isSuccess: true,
                                            bottomOffset: 0.02
                                        );

                                      } on FirebaseAuthException catch (e) {
                                        if (!dialogPageContext.mounted) return;
                                        debugPrint("$methodName: FirebaseAuthException: ${e.code}");
                                        if (e.code == 'wrong-password' || e.code == 'invalid-credential' || e.code == 'invalid-password') {
                                          setDialogInnerState(() => passwordError = appLocalizations.wrongPassword);
                                        } else {
                                          setDialogInnerState(() => passwordError = appLocalizations.anErrorOccurred);
                                        }
                                        _deleteAccountPasswordShakeController.forward(from: 0);
                                      } on FirebaseFunctionsException catch (e) {
                                        if (!dialogPageContext.mounted) return;
                                        debugPrint("$methodName: FirebaseFunctionsException: ${e.code} - ${e.message}");
                                        setDialogInnerState(() => passwordError = appLocalizations.anErrorOccurred);
                                        _deleteAccountPasswordShakeController.forward(from: 0);
                                      }
                                      catch (e) {
                                        if (!dialogPageContext.mounted) return;
                                        debugPrint("$methodName: An unexpected error occurred: $e");
                                        setDialogInnerState(() => passwordError = appLocalizations.anErrorOccurred);
                                        _deleteAccountPasswordShakeController.forward(from: 0);
                                      }
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: Text(appLocalizations.delete, style: const TextStyle(color: Colors.red, fontSize: 16),),
                                    ),
                                  ),
                                ),
                              ),
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
        );
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    ).whenComplete(() {
      restoreNavBar();
      _setDialogState(false);
    });
  }

  Widget _buildDeleteAllConversationsButton(AppLocalizations appLocalizations) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Material(
      color: AppColors.septenaryColor,
      borderRadius: BorderRadius.circular(10.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDeleteAllConversationsDialog(appLocalizations),
        borderRadius: BorderRadius.circular(10.0),
        splashColor: AppColors.quaternaryColor.withOpacity(0.3),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appLocalizations.deleteAllConversationsButton,
                style: GoogleFonts.roboto(color: Colors.white, fontSize: screenWidth * 0.04, fontWeight: FontWeight.w500,),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: screenWidth * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(AppLocalizations appLocalizations) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Material(
      color: AppColors.septenaryColor,
      borderRadius: BorderRadius.circular(10.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDeleteAccountDialog(appLocalizations),
        borderRadius: BorderRadius.circular(10.0),
        splashColor: AppColors.quaternaryColor.withOpacity(0.3),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appLocalizations.deleteAccountButton,
                style: GoogleFonts.roboto(color: Colors.white, fontSize: screenWidth * 0.04, fontWeight: FontWeight.w500,),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: screenWidth * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisabledInfoText(AppLocalizations appLocalizations) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.septenaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: AppColors.septenaryColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/warning.svg',
            colorFilter: ColorFilter.mode(
              AppColors.quinaryColor,
              BlendMode.srcIn,
            ),
            width: screenWidth * 0.05,
            height: screenWidth * 0.05,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              appLocalizations.deleteAllConversationsDisabledInfo,
              style: GoogleFonts.roboto(
                color: AppColors.quinaryColor,
                fontSize: screenWidth * 0.035,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("$_className: build method called. Has Internet: ${widget.hasInternet}");
    final appLocalizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.delete,
          style: GoogleFonts.roboto(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.05, fontWeight: FontWeight.w600,),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          appLocalizations.deleteDescription,
          style: GoogleFonts.roboto(color: AppColors.quinaryColor, fontSize: screenWidth * 0.035),
        ),
        SizedBox(height: screenHeight * 0.02),

        // --- THE FIX: Conditionally render the button or the info text ---
        // This widget is for local deletion.
        if (widget.isFromActiveChat)
          _buildDisabledInfoText(appLocalizations)
        else
          _buildDeleteAllConversationsButton(appLocalizations),
        SizedBox(height: screenHeight * 0.015),

        // This widget for server-side account deletion is only visible when online.
        if (widget.hasInternet)
          _buildDeleteAccountButton(appLocalizations),
      ],
    );
  }
}

/// A simple widget that shakes its child when its controller is triggered.
/// This version is robust and will not cause lifecycle errors.
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  const ShakeWidget({
    Key? key,
    required this.child,
    required this.controller,
  }) : super(key: key);

  @override
  ShakeWidgetState createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget> {
  // A listener callback function. We keep a reference to it
  // so we can remove it in dispose().
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();

    // Define the listener. It no longer needs to call setState because
    // AnimatedBuilder handles rebuilding automatically.
    _listener = () {
      // This is now empty, but we still need the listener reference.
    };

    // Add the listener to the controller.
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    // CRITICAL: Remove the listener from the controller when the widget is destroyed.
    // This prevents the controller from trying to notify a disposed widget,
    // which is the root cause of the "setState() called after dispose()" error.
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using AnimatedBuilder is the most efficient way to handle this.
    // It rebuilds only the Transform widget when the animation value changes,
    // not the entire widget subtree.
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        // Calculate the animation value based on the controller.
        final animationValue = Tween<double>(begin: 0, end: 1)
            .chain(CurveTween(curve: Curves.elasticIn))
            .evaluate(widget.controller);

        // Apply the horizontal translation.
        return Transform.translate(
          offset: Offset(animationValue * 10, 0),
          child: child,
        );
      },
      // The child is passed here so it's built only once, not on every animation frame.
      child: widget.child,
    );
  }
}