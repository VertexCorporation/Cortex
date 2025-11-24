// lib/settings/sections/user.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../darkener.dart';
import '../../l10n/app_localizations.dart';
import '../../shake.dart';
import '../../theme.dart';
import '../providers/general.dart';
import '../providers/actions.dart';
import '../services/auth.dart';

// --- DIALOG WIDGETS ---

/// A self-contained, stateful widget for the "Edit Profile" dialog.
/// It manages its own controllers to prevent lifecycle errors.
class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog();

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final TextEditingController _nameController;
  String? _errorText;

  final RegExp _usernameRegExp = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    // Initialize the controller here, using context.read for one-time access.
    final initialUsername = context.read<SettingsGeneralProvider>().userData?['username'] as String? ?? '';
    _nameController = TextEditingController(text: initialUsername);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    // Before any async gaps, get all necessary providers and localizations.
    final actionProvider = context.read<SettingsActionProvider>();
    final generalProvider = context.read<SettingsGeneralProvider>();
    final appLocalizations = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);

    final newName = _nameController.text.trim();
    final currentName = generalProvider.userData?['username'] as String? ?? '';

    if (!_usernameRegExp.hasMatch(newName)) {
      setState(() => _errorText = appLocalizations.invalidUsernameCharacters);
      _shakeController.forward(from: 0);
      return;
    }
    if (newName.toLowerCase() == currentName.toLowerCase()) {
      navigator.pop();
      return;
    }

    try {
      await actionProvider.updateUsername(context, newName);
      // Data is refreshed by the provider, but we pop the main screen
      // to ensure the UI fully reflects the changes upon re-entry.
      if(mounted) {
        navigator.pop(); // Pop the dialog
        navigator.pop(); // Pop the SettingsScreen
      }
    } catch (e) {
      if(mounted) setState(() => _errorText = e.toString());
      _shakeController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    final appLocalizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SingleChildScrollView(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: screenWidth * 0.8,
            decoration: BoxDecoration(color: AppColors.secondaryColor, borderRadius: BorderRadius.circular(10)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Consumer<SettingsActionProvider>(
                builder: (context, provider, child) {
                  final isUpdating = provider.isUpdatingUsername;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        child: Column(
                          children: [
                            Text(appLocalizations.editProfile, style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted), textAlign: TextAlign.center),
                            SizedBox(height: screenWidth * 0.05),
                            ShakeWidget(
                              controller: _shakeController,
                              child: TextField(
                                controller: _nameController,
                                maxLength: 20,
                                style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.04),
                                decoration: InputDecoration(labelText: appLocalizations.username, labelStyle: TextStyle(color: AppColors.primaryColor.inverted), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.quinaryColor), borderRadius: BorderRadius.circular(10.0)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor.inverted), borderRadius: BorderRadius.circular(10.0)), counterText: ''),
                              ),
                            ),
                            AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: _errorText != null ? Padding(padding: EdgeInsets.only(top: screenWidth * 0.02), child: Text(_errorText!, style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.03), key: ValueKey(_errorText))) : const SizedBox.shrink(key: ValueKey("emptyError"))),
                          ],
                        ),
                      ),
                      Divider(color: AppColors.quinaryColor, thickness: 0.5, height: 1),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(child: Material(color: Colors.transparent, child: InkWell(onTap: isUpdating ? null : () => Navigator.of(context).pop(), splashColor: AppColors.senaryColor.withValues(alpha: 0.1), highlightColor: AppColors.senaryColor.withValues(alpha: 0.1), child: Container(alignment: Alignment.center, padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04), child: Text(appLocalizations.cancel, style: TextStyle(color: AppColors.senaryColor, fontSize: screenWidth * 0.04)))))),
                            VerticalDivider(width: 1, thickness: 0.5, color: AppColors.quinaryColor),
                            Expanded(
                              child: Material(color: Colors.transparent, child: InkWell(
                                splashColor: AppColors.septenaryColor.withValues(alpha: 0.1), highlightColor: AppColors.septenaryColor.withValues(alpha: 0.1),
                                onTap: isUpdating ? null : _handleUpdate,
                                child: Container(alignment: Alignment.center, padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04), child: isUpdating ? SizedBox(width: screenWidth * 0.05, height: screenWidth * 0.05, child: CircularProgressIndicator(strokeWidth: 2.0, color: AppColors.septenaryColor)) : Text(appLocalizations.save, style: TextStyle(color: AppColors.septenaryColor, fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold))),
                              )),
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
      ),
    );
  }
}

/// A self-contained, stateful widget for the "Change Password" dialog.
class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> with TickerProviderStateMixin {
  late final AnimationController _oldPassShake, _newPassShake, _confirmPassShake;
  late final TextEditingController _oldPassController, _newPassController, _confirmPassController;

  // *** FIX: Use separate error variables for each field. ***
  String? _oldPassError;
  String? _newPassError;
  String? _confirmPassError;

  @override
  void initState() {
    super.initState();
    const shakeDuration = Duration(milliseconds: 500);
    _oldPassShake = AnimationController(vsync: this, duration: shakeDuration);
    _newPassShake = AnimationController(vsync: this, duration: shakeDuration);
    _confirmPassShake = AnimationController(vsync: this, duration: shakeDuration);
    _oldPassController = TextEditingController();
    _newPassController = TextEditingController();
    _confirmPassController = TextEditingController();
  }

  @override
  void dispose() {
    _oldPassShake.dispose();
    _newPassShake.dispose();
    _confirmPassShake.dispose();
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    final actionProvider = context.read<SettingsActionProvider>();
    final appLocalizations = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);

    final oldPass = _oldPassController.text;
    final newPass = _newPassController.text;
    final confirmPass = _confirmPassController.text;

    // Reset all errors at the beginning of the attempt.
    setState(() {
      _oldPassError = null;
      _newPassError = null;
      _confirmPassError = null;
    });

    // Client-side validation with specific error messages.
    if (oldPass.isEmpty) { setState(() => _oldPassError = appLocalizations.passwordRequired); _oldPassShake.forward(from: 0); return; }
    if (newPass.length < 6) { setState(() => _newPassError = appLocalizations.weakPassword); _newPassShake.forward(from: 0); return; }
    if (newPass != confirmPass) { setState(() => _confirmPassError = appLocalizations.passwordsDoNotMatch); _confirmPassShake.forward(from: 0); return; }

    try {
      await actionProvider.changePassword(context, oldPassword: oldPass, newPassword: newPass);
      if(mounted) {
        navigator.pop(); // Pop the dialog
        navigator.pop(); // Pop the SettingsScreen
      }
    } catch (e) {
      if(mounted) {
        // Show the error on the most likely problematic field (old password).
        setState(() => _oldPassError = e.toString());
        _oldPassShake.forward(from: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    final appLocalizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    // This is the build method for the dialog.
    return Center(
      child: SingleChildScrollView(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: screenWidth * 0.8,
            decoration: BoxDecoration(color: AppColors.secondaryColor, borderRadius: BorderRadius.circular(10)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Consumer<SettingsActionProvider>(
                builder: (context, provider, child) {
                  final isChanging = provider.isChangingPassword;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        child: Column(
                          children: [
                            Text(appLocalizations.changePassword, style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted), textAlign: TextAlign.center),
                            SizedBox(height: screenWidth * 0.05),
                            // Old Password Field
                            ShakeWidget(controller: _oldPassShake, child: TextField(controller: _oldPassController, obscureText: true, style: TextStyle(color: AppColors.primaryColor.inverted), decoration: InputDecoration(labelText: appLocalizations.oldPassword, labelStyle: TextStyle(color: AppColors.primaryColor.inverted), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.quinaryColor), borderRadius: BorderRadius.circular(10)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor.inverted), borderRadius: BorderRadius.circular(10))))),
                            AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: _oldPassError != null ? Padding(padding: EdgeInsets.only(top: screenWidth * 0.02), child: Text(_oldPassError!, style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.03), key: ValueKey(_oldPassError))) : const SizedBox.shrink()),

                            SizedBox(height: screenWidth * 0.03),

                            // New Password Field
                            ShakeWidget(controller: _newPassShake, child: TextField(controller: _newPassController, obscureText: true, style: TextStyle(color: AppColors.primaryColor.inverted), decoration: InputDecoration(labelText: appLocalizations.newPassword, labelStyle: TextStyle(color: AppColors.primaryColor.inverted), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.quinaryColor), borderRadius: BorderRadius.circular(10)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor.inverted), borderRadius: BorderRadius.circular(10))))),
                            AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: _newPassError != null ? Padding(padding: EdgeInsets.only(top: screenWidth * 0.02), child: Text(_newPassError!, style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.03), key: ValueKey(_newPassError))) : const SizedBox.shrink()),

                            SizedBox(height: screenWidth * 0.03),

                            // Confirm Password Field
                            ShakeWidget(controller: _confirmPassShake, child: TextField(controller: _confirmPassController, obscureText: true, style: TextStyle(color: AppColors.primaryColor.inverted), decoration: InputDecoration(labelText: appLocalizations.confirmPassword, labelStyle: TextStyle(color: AppColors.primaryColor.inverted), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.quinaryColor), borderRadius: BorderRadius.circular(10)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor.inverted), borderRadius: BorderRadius.circular(10))))),
                            AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: _confirmPassError != null ? Padding(padding: EdgeInsets.only(top: screenWidth * 0.02), child: Text(_confirmPassError!, style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.03), key: ValueKey(_confirmPassError))) : const SizedBox.shrink()),
                          ],
                        ),
                      ),
                      Divider(color: AppColors.quinaryColor, thickness: 0.5, height: 1),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(child: Material(color: Colors.transparent, child: InkWell(onTap: isChanging ? null : () => Navigator.of(context).pop(), splashColor: AppColors.senaryColor.withValues(alpha: 0.1), highlightColor: AppColors.senaryColor.withValues(alpha: 0.1), child: Container(alignment: Alignment.center, padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04), child: Text(appLocalizations.cancel, style: TextStyle(color: AppColors.senaryColor, fontSize: screenWidth * 0.04)))))),
                            VerticalDivider(width: 1, thickness: 0.5, color: AppColors.quinaryColor),
                            Expanded(
                              child: Material(color: Colors.transparent, child: InkWell(
                                splashColor: AppColors.septenaryColor.withValues(alpha: 0.1), highlightColor: AppColors.septenaryColor.withValues(alpha: 0.1),
                                onTap: isChanging ? null : _handleChangePassword,
                                child: Container(alignment: Alignment.center, padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04), child: isChanging ? SizedBox(width: screenWidth * 0.05, height: screenWidth * 0.05, child: CircularProgressIndicator(strokeWidth: 2.0, color: AppColors.septenaryColor)) : Text(appLocalizations.save, style: TextStyle(color: AppColors.septenaryColor, fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold))),
                              )),
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
      ),
    );
  }
}

/// A self-contained, stateless widget for the "Logout" confirmation dialog.
class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    final appLocalizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: screenWidth * 0.8,
          decoration: BoxDecoration(color: AppColors.secondaryColor, borderRadius: BorderRadius.circular(10)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Consumer<SettingsActionProvider>(
              builder: (context, provider, child) {
                final isLoggingOut = provider.isLoggingOut;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: Column(
                        children: [
                          Text(appLocalizations.logout, style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted), textAlign: TextAlign.center),
                          SizedBox(height: screenWidth * 0.03),
                          Text(appLocalizations.logoutConfirmationTitle, style: TextStyle(color: AppColors.quinaryColor, fontSize: screenWidth * 0.035), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    Divider(color: AppColors.quinaryColor, thickness: 0.5, height: 1),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(child: Material(color: Colors.transparent, child: InkWell(onTap: isLoggingOut ? null : () => Navigator.of(context).pop(), splashColor: AppColors.senaryColor.withValues(alpha: 0.1), highlightColor: AppColors.senaryColor.withValues(alpha: 0.1), child: Container(alignment: Alignment.center, padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04), child: Text(appLocalizations.no, style: TextStyle(color: AppColors.senaryColor, fontSize: screenWidth * 0.04)))))),
                          VerticalDivider(width: 1, thickness: 0.5, color: AppColors.quinaryColor),
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: AppColors.septenaryColor.withValues(alpha: 0.1),
                                highlightColor: AppColors.septenaryColor.withValues(alpha: 0.1),
                                onTap: isLoggingOut ? null : () => context.read<SettingsActionProvider>().performLogout(context),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                                  child: isLoggingOut
                                      ? SizedBox(width: screenWidth * 0.05, height: screenWidth * 0.05, child: CircularProgressIndicator(strokeWidth: 2.0, color: AppColors.septenaryColor))
                                      : Text(appLocalizations.yes, style: TextStyle(color: AppColors.septenaryColor, fontSize: screenWidth * 0.04)),
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
  }
}

/// A stateless widget that displays user management options and launches the corresponding dialogs.
class UserSection extends StatelessWidget {
  const UserSection({super.key});

  void _showDialog(BuildContext context, {required Widget child}) {
    final RestoreCallback restoreNavBar = Darkener.darken();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'UserActionDialog',
      pageBuilder: (ctx, _, __) {
        final keyboardPadding = MediaQuery.of(ctx).viewInsets.bottom;
        return AnimatedPadding(
          padding: EdgeInsets.only(bottom: keyboardPadding),
          duration: const Duration(milliseconds: 50),
          curve: Curves.easeInOut,
          child: child,
        );
      },
    ).whenComplete(restoreNavBar);
  }

  Widget _buildCenteredButton(BuildContext context, {required String text, required VoidCallback onPressed, bool enabled = true}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Material(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(10.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(10.0),
          splashColor: AppColors.quaternaryColor.withValues(alpha:0.3),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.045),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(text, style: GoogleFonts.roboto(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.041, fontWeight: FontWeight.w500)),
                Icon(Icons.arrow_forward_ios, color: AppColors.primaryColor.inverted, size: screenWidth * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    final appLocalizations = AppLocalizations.of(context)!;
    final hasInternet = context.watch<SettingsGeneralProvider>().hasInternet;
    final isPasswordUser = context.select((AuthService auth) => auth.hasPasswordProvider());

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(appLocalizations.user, style: GoogleFonts.roboto(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.05, fontWeight: FontWeight.w600)),
        SizedBox(height: screenHeight * 0.01),
        Text(appLocalizations.manageProfileDescription, style: GoogleFonts.roboto(color: AppColors.quinaryColor, fontSize: screenWidth * 0.035)),
        SizedBox(height: screenHeight * 0.02),
        _buildCenteredButton(
          context,
          text: appLocalizations.editProfile,
          enabled: hasInternet,
          onPressed: () => _showDialog(context, child: const _EditProfileDialog()),
        ),
        SizedBox(height: screenHeight * 0.015),
        _buildCenteredButton(
          context,
          text: appLocalizations.changePassword,
          enabled: hasInternet && isPasswordUser,
          onPressed: () => _showDialog(context, child: const _ChangePasswordDialog()),
        ),
        SizedBox(height: screenHeight * 0.015),
        _buildCenteredButton(
          context,
          text: appLocalizations.logout,
          enabled: hasInternet,
          onPressed: () => _showDialog(context, child: const _LogoutDialog()),
        ),
        SizedBox(height: screenWidth * 0.04),
      ],
    );
  }
}