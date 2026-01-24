// lib/settings/controller.dart

import 'dart:async';
import 'package:cortex/analytics/service.dart';
import 'package:cortex/settings/providers/general.dart';
import 'package:cortex/settings/sections/anonymous.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app.dart';
import '../appbar.dart';
import '../cache.dart';
import '../fog.dart';
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
class SettingsScreen extends StatefulWidget {
  final bool isFromActiveChat;

  const SettingsScreen({
    super.key,
    this.isFromActiveChat = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    AnalyticsService().logSettingsScreen();
    debugPrint("[SettingsScreen] Initialized and observing app lifecycle.");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    debugPrint(
        "[SettingsScreen] Disposed and stopped observing app lifecycle.");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      debugPrint(
          "[SettingsScreen] App resumed. Forcing a refresh of user data.");
      CacheService.invalidate(CacheKey.settingsUserData);
      context.read<SettingsGeneralProvider>().refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final bool isTablet = screenWidth >= 600;

    context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: CortexAppBar(
        titleText: appLocalizations.settings,
        scrollController: _scrollController,
        leadingMode: CortexLeadingMode.back,
      ),
      body: Consumer<SettingsGeneralProvider>(
        builder: (context, generalProvider, child) {
          final bool showSkeleton =
              generalProvider.isLoading && (generalProvider.userData == null);

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: showSkeleton
                ? const SkeletonLoader(key: ValueKey('skeleton'))
                : _buildContent(context, widget.isFromActiveChat, isTablet,
                appLocalizations),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isFromActiveChat,
      bool isTablet, AppLocalizations l10n) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final generalProvider = context.watch<SettingsGeneralProvider>();
    final bool isAnonymous = generalProvider.isAnonymous;

    final double topPadding = MediaQuery
        .of(context)
        .padding
        .top;

    final List<Widget> settingsItems = [
      if (generalProvider.userData != null) const ProfileHeaderSection(),
      SizedBox(height: isTablet ? 40.0 : screenWidth * 0.06),
      if (isAnonymous) const AnonymousUpgradePanel(),
      if (!isAnonymous &&
          !generalProvider.isVerified &&
          generalProvider.hasInternet)
        const _UnverifiedAccountPanel(),
      if (!isAnonymous && generalProvider.hasInternet) const UserSection(),
      if (!isAnonymous && generalProvider.hasInternet)
        SizedBox(height: isTablet ? 24.0 : screenWidth * 0.04),
      const AppLanguageSection(),
      SizedBox(height: isTablet ? 24.0 : screenWidth * 0.04),
      const AppThemeSection(),
      SizedBox(height: isTablet ? 24.0 : screenWidth * 0.04),
      const SettingsSection(),
      SizedBox(height: isTablet ? 24.0 : screenWidth * 0.04),
      DeleteSection(isFromActiveChat: isFromActiveChat),
      SizedBox(height: isTablet ? 60.0 : screenWidth * 0.08),
    ];

    return ScrollFog(
      scrollController: _scrollController,
      showTop: false,
      bottomFogHeight: 20,
      showBottom: true,
      child: Container(
        alignment: Alignment.topCenter,
        child: Container(
          constraints:
          BoxConstraints(maxWidth: isTablet ? 800 : double.infinity),
          child: ScrollConfiguration(
            behavior:
            ScrollConfiguration.of(context).copyWith(overscroll: false),
            child: ListView.builder(
              controller: _scrollController,
              key: const PageStorageKey('settingsContent'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: topPadding,
                bottom: 20,
                left: isTablet ? 32.0 : screenWidth * 0.04,
                right: isTablet ? 32.0 : screenWidth * 0.04,
              ),
              itemCount: settingsItems.length,
              itemBuilder: (context, index) {
                return settingsItems[index];
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _UnverifiedAccountPanel extends StatefulWidget {
  const _UnverifiedAccountPanel();

  @override
  State<_UnverifiedAccountPanel> createState() =>
      __UnverifiedAccountPanelState();
}

class __UnverifiedAccountPanelState extends State<_UnverifiedAccountPanel> {
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();

    final generalProvider = context.read<SettingsGeneralProvider>();
    final createdAt = generalProvider.createdAt;
    final verifyAttempts = generalProvider.verificationAttempts;

    if (createdAt != null) {
      final deadline =
      createdAt.toDate().add(Duration(hours: 24 * (verifyAttempts + 1)));
      final difference = deadline.difference(DateTime.now());

      setState(() {
        _remainingSeconds = difference.isNegative ? 0 : difference.inSeconds;
      });

      if (_remainingSeconds > 0) {
        _startTimer();
      }
    }
  }

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
        if (mounted) {
          context.read<SettingsGeneralProvider>().refreshData();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatRemainingTime(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(
        2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    final appLocalizations = AppLocalizations.of(context)!;
    final generalProvider = context.watch<SettingsGeneralProvider>();
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final bool isTablet = screenWidth >= 600;

    final timeStr = _formatRemainingTime(_remainingSeconds);

    final double headerSize = isTablet ? 24.0 : screenWidth * 0.045;
    final double bodySize = isTablet ? 16.0 : screenWidth * 0.035;
    final double buttonHeight = isTablet ? 60.0 : screenHeight * 0.06;
    final double padding = isTablet ? 24.0 : screenWidth * 0.04;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: AppColors.septenaryColor, width: 2),
          ),
          child: Column(
            children: [
              Text(
                appLocalizations.unverifiedAccountHeader,
                style: TextStyle(
                    fontSize: headerSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor.inverted),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                appLocalizations.unverifiedAccountWarning(timeStr),
                style: TextStyle(
                    fontSize: bodySize, color: AppColors.quinaryColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                timeStr,
                style: TextStyle(
                    fontSize: bodySize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.septenaryColor),
              ),
              SizedBox(height: screenHeight * 0.015),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(buttonHeight),
                      backgroundColor: AppColors.senaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<SettingsGeneralProvider>().refreshData();
                  },
                  child: Text(appLocalizations.verifyNow,
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: isTablet ? 18 : screenWidth * 0.04)),
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(buttonHeight),
                      backgroundColor: AppColors.senaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: (generalProvider.isResendingEmail ||
                      generalProvider.verificationAttempts >= 2)
                      ? null
                      : () {
                    HapticFeedback.lightImpact();
                    context
                        .read<SettingsGeneralProvider>()
                        .resendVerificationEmail();
                  },
                  child: generalProvider.isResendingEmail
                      ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: AppColors.primaryColor))
                      : Text(
                    appLocalizations.resendCode,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: (generalProvider.verificationAttempts >= 2)
                            ? AppColors.quinaryColor
                            : AppColors.primaryColor,
                        fontSize: isTablet ? 18 : screenWidth * 0.04),
                  ),
                ),
              ),
              if (generalProvider.verificationAttempts >= 2)
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.01),
                  child: Center(
                    child: Text(
                      appLocalizations.maxResendLimitReached,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.septenaryColor,
                          fontSize: bodySize,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 24.0 : screenWidth * 0.04),
      ],
    );
  }
}
