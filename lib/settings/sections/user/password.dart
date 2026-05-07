part of '../user.dart';

/// A self-contained, stateful widget for the "Change Password" dialog.
class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog>
    with TickerProviderStateMixin {
  late final AnimationController _oldPassShake,
      _newPassShake,
      _confirmPassShake;
  late final TextEditingController _oldPassController,
      _newPassController,
      _confirmPassController;

  String? _oldPassError;
  String? _newPassError;
  String? _confirmPassError;

  @override
  void initState() {
    super.initState();
    const shakeDuration = Duration(milliseconds: 500);
    _oldPassShake = AnimationController(vsync: this, duration: shakeDuration);
    _newPassShake = AnimationController(vsync: this, duration: shakeDuration);
    _confirmPassShake =
        AnimationController(vsync: this, duration: shakeDuration);
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

    setState(() {
      _oldPassError = null;
      _newPassError = null;
      _confirmPassError = null;
    });

    if (oldPass.isEmpty) {
      setState(() => _oldPassError = appLocalizations.passwordRequired);
      _oldPassShake.forward(from: 0);
      return;
    }
    if (newPass.length < 6) {
      setState(() => _newPassError = appLocalizations.weakPassword);
      _newPassShake.forward(from: 0);
      return;
    }
    if (newPass != confirmPass) {
      setState(() => _confirmPassError = appLocalizations.passwordsDoNotMatch);
      _confirmPassShake.forward(from: 0);
      return;
    }

    try {
      await actionProvider.changePassword(context,
          oldPassword: oldPass, newPassword: newPass);
      if (mounted) {
        navigator.pop(); // Pop the dialog
        navigator.pop(); // Pop the SettingsScreen
      }
    } catch (e) {
      if (mounted) {
        setState(() => _oldPassError = e.toString());
        _oldPassShake.forward(from: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ThemeProvider is watched by parent SettingsScreen — no need to re-watch here.
    final appLocalizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SingleChildScrollView(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: screenWidth * 0.8,
            decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(10)),
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
                            Text(appLocalizations.changePassword,
                                style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor.inverted),
                                textAlign: TextAlign.center),
                            SizedBox(height: screenWidth * 0.05),
                            // Old Password Field
                            ShakeWidget(
                                controller: _oldPassShake,
                                child: TextField(
                                    controller: _oldPassController,
                                    obscureText: true,
                                    style: TextStyle(
                                        color: AppColors.primaryColor.inverted),
                                    decoration: InputDecoration(
                                        labelText: appLocalizations.oldPassword,
                                        labelStyle: TextStyle(
                                            color: AppColors
                                                .primaryColor.inverted),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColors.quinaryColor),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColors
                                                    .primaryColor.inverted),
                                            borderRadius:
                                                BorderRadius.circular(10))))),
                            AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _oldPassError != null
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            top: screenWidth * 0.02),
                                        child: Text(_oldPassError!,
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: screenWidth * 0.03),
                                            key: ValueKey(_oldPassError)))
                                    : const SizedBox.shrink()),

                            SizedBox(height: screenWidth * 0.03),

                            // New Password Field
                            ShakeWidget(
                                controller: _newPassShake,
                                child: TextField(
                                    controller: _newPassController,
                                    obscureText: true,
                                    style: TextStyle(
                                        color: AppColors.primaryColor.inverted),
                                    decoration: InputDecoration(
                                        labelText: appLocalizations.newPassword,
                                        labelStyle: TextStyle(
                                            color: AppColors
                                                .primaryColor.inverted),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColors.quinaryColor),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColors
                                                    .primaryColor.inverted),
                                            borderRadius:
                                                BorderRadius.circular(10))))),
                            AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _newPassError != null
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            top: screenWidth * 0.02),
                                        child: Text(_newPassError!,
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: screenWidth * 0.03),
                                            key: ValueKey(_newPassError)))
                                    : const SizedBox.shrink()),

                            SizedBox(height: screenWidth * 0.03),

                            // Confirm Password Field
                            ShakeWidget(
                                controller: _confirmPassShake,
                                child: TextField(
                                    controller: _confirmPassController,
                                    obscureText: true,
                                    style: TextStyle(
                                        color: AppColors.primaryColor.inverted),
                                    decoration: InputDecoration(
                                        labelText:
                                            appLocalizations.confirmPassword,
                                        labelStyle: TextStyle(
                                            color: AppColors
                                                .primaryColor.inverted),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColors.quinaryColor),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColors
                                                    .primaryColor.inverted),
                                            borderRadius:
                                                BorderRadius.circular(10))))),
                            AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _confirmPassError != null
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            top: screenWidth * 0.02),
                                        child: Text(_confirmPassError!,
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: screenWidth * 0.03),
                                            key: ValueKey(_confirmPassError)))
                                    : const SizedBox.shrink()),
                          ],
                        ),
                      ),
                      Divider(
                          color: AppColors.quinaryColor,
                          thickness: 0.5,
                          height: 1),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                                child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                        onTap: isChanging
                                            ? null
                                            : () {
                                                HapticFeedback.lightImpact();
                                                Navigator.of(context).pop();
                                              },
                                        splashColor: AppColors.senaryColor
                                            .withValues(alpha: 0.1),
                                        highlightColor: AppColors.senaryColor
                                            .withValues(alpha: 0.1),
                                        child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(
                                                vertical: screenWidth * 0.04),
                                            child: Text(appLocalizations.cancel,
                                                style: TextStyle(
                                                    color:
                                                        AppColors.senaryColor,
                                                    fontSize: screenWidth *
                                                        0.04)))))),
                            VerticalDivider(
                                width: 1,
                                thickness: 0.5,
                                color: AppColors.quinaryColor),
                            Expanded(
                              child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    splashColor: AppColors.septenaryColor
                                        .withValues(alpha: 0.1),
                                    highlightColor: AppColors.septenaryColor
                                        .withValues(alpha: 0.1),
                                    onTap: isChanging
                                        ? null
                                        : () {
                                            HapticFeedback.lightImpact();
                                            _handleChangePassword();
                                          },
                                    child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(
                                            vertical: screenWidth * 0.04),
                                        child: isChanging
                                            ? SizedBox(
                                                width: screenWidth * 0.05,
                                                height: screenWidth * 0.05,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2.0,
                                                        color: AppColors
                                                            .septenaryColor))
                                            : Text(appLocalizations.save,
                                                style: TextStyle(
                                                    color: AppColors
                                                        .septenaryColor,
                                                    fontSize:
                                                        screenWidth * 0.04,
                                                    fontWeight:
                                                        FontWeight.bold))),
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
