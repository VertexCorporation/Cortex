// lib/settings/controller.dart

import 'dart:async';
import 'package:cortex/settings/providers/general.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app.dart';
import '../cache.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'sections/delete.dart';
import 'sections/header.dart';
import 'sections/language.dart';
import 'sections/settings.dart';
import 'sections/theme.dart';
import 'sections/user.dart';
import 'skeleton.dart';

/// The main screen for displaying user settings.
///
/// This widget acts as the root view for the settings interface. It is a
/// state-consumer that listens to `SettingsGeneralProvider` to determine what to display:
/// either a loading skeleton or the main content. It also listens to `ThemeProvider`
/// to rebuild the entire screen when the app's theme is changed.
class SettingsScreen extends StatefulWidget {
  final bool isFromActiveChat;

  const SettingsScreen({
    super.key,
    this.isFromActiveChat = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint("[SettingsScreen] Initialized and observing app lifecycle.");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debugPrint("[SettingsScreen] Disposed and stopped observing app lifecycle.");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      debugPrint("[SettingsScreen] App resumed. Forcing a refresh of user data.");
      // Invalidate the cache to ensure fresh data is fetched from the server.
      CacheService.invalidate(CacheKey.settingsUserData);
      // Trigger the data refresh through the provider.
      context.read<SettingsGeneralProvider>().refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    // Listen to ThemeProvider changes to rebuild the entire screen with new colors.
    context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(appLocalizations.settings, style: GoogleFonts.roboto(color: AppColors.primaryColor.inverted)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryColor.inverted),
      ),
      body: SafeArea(
        child: Consumer<SettingsGeneralProvider>(
          builder: (context, generalProvider, child) {
            final bool showSkeleton = generalProvider.isLoading ||
                (generalProvider.hasInternet && generalProvider.userData == null);

            // Use AnimatedSwitcher for a smooth transition between loading and content states.
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
              child: showSkeleton
                  ? const SkeletonLoader(key: ValueKey('skeleton'))
                  : _buildContent(context, widget.isFromActiveChat),
            );
          },
        ),
      ),
    );
  }

  /// Builds the main content of the settings screen once data is loaded.
  Widget _buildContent(BuildContext context, bool isFromActiveChat) {
    final screenWidth = MediaQuery.of(context).size.width;
    final generalProvider = context.watch<SettingsGeneralProvider>();

    final List<Widget> settingsItems = [
      if (generalProvider.userData != null)
        const ProfileHeaderSection(),

      SizedBox(height: screenWidth * 0.04),

      // The unverified panel is only shown if the user is not verified and has internet.
      if (!generalProvider.isVerified && generalProvider.hasInternet)
        const _UnverifiedAccountPanel(),

      if (generalProvider.hasInternet)
        const UserSection(),

      if (generalProvider.hasInternet)
        SizedBox(height: screenWidth * 0.04),

      const AppLanguageSection(),
      SizedBox(height: screenWidth * 0.04),

      const AppThemeSection(),
      SizedBox(height: screenWidth * 0.04),

      const SettingsSection(),
      SizedBox(height: screenWidth * 0.04),

      DeleteSection(isFromActiveChat: isFromActiveChat),
      SizedBox(height: screenWidth * 0.04),
    ];

    return ListView.builder(
      key: const ValueKey('settingsContent'),
      padding: EdgeInsets.all(screenWidth * 0.04),
      itemCount: settingsItems.length,
      itemBuilder: (context, index) {
        return settingsItems[index];
      },
    );
  }
}


/// A private stateful widget to display the "Unverified Account" panel.
/// It manages its own timer for the live countdown, ensuring encapsulation.
class _UnverifiedAccountPanel extends StatefulWidget {
  const _UnverifiedAccountPanel();

  @override
  State<_UnverifiedAccountPanel> createState() => __UnverifiedAccountPanelState();
}

class __UnverifiedAccountPanelState extends State<_UnverifiedAccountPanel> {
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    // The timer is initialized in didChangeDependencies to ensure provider data is available.
  }

  /// This method is called when the widget is first built and whenever its
  /// dependencies (like Providers) change. It's the ideal place to react to
  /// data updates and reset the timer.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resetTimer();
  }

  /// Calculates the remaining time and starts or resets the countdown timer.
  void _resetTimer() {
    _timer?.cancel(); // Cancel any existing timer to prevent multiple timers running.

    final generalProvider = context.read<SettingsGeneralProvider>();
    final createdAt = generalProvider.createdAt;
    final verifyAttempts = generalProvider.verificationAttempts;

    if (createdAt != null) {
      // Replicates the logic from the original system: each resend adds 24 hours.
      final deadline = createdAt.toDate().add(Duration(hours: 24 * (verifyAttempts + 1)));
      final difference = deadline.difference(DateTime.now());

      setState(() {
        _remainingSeconds = difference.isNegative ? 0 : difference.inSeconds;
      });

      if (_remainingSeconds > 0) {
        _startTimer();
      }
    }
  }

  /// Starts a periodic timer that decrements the remaining seconds every second.
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      } else {
        timer.cancel();
        // Optionally trigger a data refresh when the timer hits zero.
        if (mounted) {
          context.read<SettingsGeneralProvider>().refreshData();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Crucial: always cancel the timer to avoid memory leaks.
    super.dispose();
  }

  /// Formats the total seconds into a HH:MM:SS string.
  String _formatRemainingTime(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    final appLocalizations = AppLocalizations.of(context)!;
    // Use `watch` here to rebuild when `isResendingEmail` or `verificationAttempts` change.
    final generalProvider = context.watch<SettingsGeneralProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final timeStr = _formatRemainingTime(_remainingSeconds);

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.septenaryColor, width: 2),
      ),
      child: Column(
        children: [
          Text(
            appLocalizations.unverifiedAccountHeader,
            style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            appLocalizations.unverifiedAccountWarning(timeStr),
            style: TextStyle(fontSize: screenWidth * 0.035, color: AppColors.quinaryColor),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.015),
          // Live Countdown Timer Display
          Text(
            timeStr,
            style: GoogleFonts.anaheim(textStyle: TextStyle(fontSize: screenWidth * 0.05, color: AppColors.primaryColor.inverted, fontWeight: FontWeight.w900)),
          ),
          SizedBox(height: screenHeight * 0.015),
          // Verify Now Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(screenHeight * 0.06), backgroundColor: AppColors.senaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => context.read<SettingsGeneralProvider>().refreshData(),
              child: Text(appLocalizations.verifyNow, style: TextStyle(color: AppColors.primaryColor, fontSize: screenWidth * 0.04)),
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          // Resend Code Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(screenHeight * 0.06), backgroundColor: AppColors.senaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: (generalProvider.isResendingEmail || generalProvider.verificationAttempts >= 2) ? null : () {
                context.read<SettingsGeneralProvider>().resendVerificationEmail();
              },
              child: generalProvider.isResendingEmail
                  ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryColor))
                  : Text(
                appLocalizations.resendCode,
                textAlign: TextAlign.center,
                style: TextStyle(color: (generalProvider.verificationAttempts >= 2) ? AppColors.quinaryColor : AppColors.primaryColor, fontSize: screenWidth * 0.04),
              ),
            ),
          ),
          // Max Resend Limit Notice
          if (generalProvider.verificationAttempts >= 2)
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.01),
              child: Center(
                child: Text(
                  appLocalizations.maxResendLimitReached,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.septenaryColor, fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}