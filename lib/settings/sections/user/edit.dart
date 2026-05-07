part of '../user.dart';

/// A self-contained, stateful widget for the "Edit Profile" dialog.
/// It manages its own controllers to prevent lifecycle errors.
class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog();

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final TextEditingController _nameController;
  String? _errorText;

  final RegExp _usernameRegExp = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    // Initialize the controller here, using context.read for one-time access.
    final initialUsername = context
            .read<SettingsGeneralProvider>()
            .userData?['username'] as String? ??
        '';
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
      if (mounted) {
        navigator.pop(); // Pop the dialog
        navigator.pop(); // Pop the SettingsScreen
      }
    } catch (e) {
      if (mounted) setState(() => _errorText = e.toString());
      _shakeController.forward(from: 0);
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
                  final isUpdating = provider.isUpdatingUsername;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        child: Column(
                          children: [
                            Text(appLocalizations.editProfile,
                                style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor.inverted),
                                textAlign: TextAlign.center),
                            SizedBox(height: screenWidth * 0.05),
                            ShakeWidget(
                              controller: _shakeController,
                              child: TextField(
                                controller: _nameController,
                                maxLength: 20,
                                style: TextStyle(
                                    color: AppColors.primaryColor.inverted,
                                    fontSize: screenWidth * 0.04),
                                decoration: InputDecoration(
                                    labelText: appLocalizations.username,
                                    labelStyle: TextStyle(
                                        color: AppColors.primaryColor.inverted),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.quinaryColor),
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors
                                                .primaryColor.inverted),
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    counterText: ''),
                              ),
                            ),
                            AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _errorText != null
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            top: screenWidth * 0.02),
                                        child: Text(_errorText!,
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: screenWidth * 0.03),
                                            key: ValueKey(_errorText)))
                                    : const SizedBox.shrink(
                                        key: ValueKey("emptyError"))),
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
                                        onTap: isUpdating
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
                                    onTap: isUpdating
                                        ? null
                                        : () {
                                            HapticFeedback.lightImpact();
                                            _handleUpdate();
                                          },
                                    child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(
                                            vertical: screenWidth * 0.04),
                                        child: isUpdating
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
