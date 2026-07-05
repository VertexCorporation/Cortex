part of '../user.dart';

/// A stateless widget for the "Logout" confirmation dialog.
class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final appLocalizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Center(
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
                final isLoggingOut = provider.isLoggingOut;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: Column(
                        children: [
                          Text(appLocalizations.logout,
                              style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor.inverted),
                              textAlign: TextAlign.center),
                          SizedBox(height: screenWidth * 0.03),
                          Text(appLocalizations.logoutConfirmationTitle,
                              style: TextStyle(
                                  color: AppColors.quinaryColor,
                                  fontSize: screenWidth * 0.035),
                              textAlign: TextAlign.center),
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
                                      onTap: isLoggingOut
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
                                          child: Text(appLocalizations.no,
                                              style: TextStyle(
                                                  color: AppColors.senaryColor,
                                                  fontSize:
                                                      screenWidth * 0.04)))))),
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
                                onTap: isLoggingOut
                                    ? null
                                    : () {
                                        HapticFeedback.lightImpact();
                                        context
                                            .read<SettingsActionProvider>()
                                            .performLogout(context);
                                      },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenWidth * 0.04),
                                  child: isLoggingOut
                                      ? SizedBox(
                                          width: screenWidth * 0.05,
                                          height: screenWidth * 0.05,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              color: AppColors.septenaryColor))
                                      : Text(appLocalizations.yes,
                                          style: TextStyle(
                                              color: AppColors.septenaryColor,
                                              fontSize: screenWidth * 0.04)),
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
