import 'package:cortex/funds/backend.dart';
import 'package:cortex/funds/funds.dart';
import 'package:cortex/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../darkener.dart';
import '../../l10n/app_localizations.dart';
import '../../shake.dart';
import '../../theme.dart';
import '../providers/general.dart';
import '../providers/actions.dart';
import '../services/auth.dart';

part 'user/edit.dart';

part 'user/password.dart';

part 'user/logout.dart';

part 'user/plan.dart';

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
        final keyboardPadding = MediaQuery
            .of(ctx)
            .viewInsets
            .bottom;
        return AnimatedPadding(
          padding: EdgeInsets.only(bottom: keyboardPadding),
          duration: const Duration(milliseconds: 50),
          curve: Curves.easeInOut,
          child: child,
        );
      },
    ).whenComplete(restoreNavBar);
  }

  Widget _buildCenteredButton(BuildContext context,
      {required String text, required VoidCallback onPressed, bool enabled = true}) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
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
                horizontal: screenWidth * 0.04, vertical: screenWidth * 0.045),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(text,
                    style: TextStyle(
                        color: AppColors.primaryColor.inverted,
                        fontSize: screenWidth * 0.041,
                        fontWeight: FontWeight.w500)),
                Icon(Icons.arrow_forward_ios,
                    color: AppColors.primaryColor.inverted,
                    size: screenWidth * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ThemeProvider is watched by parent SettingsScreen — no need to re-watch here.
    final appLocalizations = AppLocalizations.of(context)!;
    final hasInternet = context
        .watch<SettingsGeneralProvider>()
        .hasInternet;
    final isPasswordUser =
    context.select((AuthService auth) => auth.hasPasswordProvider());

    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(appLocalizations.user,
            style: TextStyle(
                color: AppColors.primaryColor.inverted,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600)),
        SizedBox(height: screenHeight * 0.01),
        Text(appLocalizations.manageProfileDescription,
            style: TextStyle(
                color: AppColors.quinaryColor, fontSize: screenWidth * 0.035)),
        SizedBox(height: screenHeight * 0.02),
        // Premium / My Plan Button
        const _MyPlanButton(),
        SizedBox(height: screenHeight * 0.015),
        _buildCenteredButton(
          context,
          text: appLocalizations.editProfile,
          enabled: hasInternet,
          onPressed: () =>
              _showDialog(context, child: const _EditProfileDialog()),
        ),
        SizedBox(height: screenHeight * 0.015),
        _buildCenteredButton(
          context,
          text: appLocalizations.changePassword,
          enabled: hasInternet && isPasswordUser,
          onPressed: () =>
              _showDialog(context, child: const _ChangePasswordDialog()),
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
