// settings.dart (FINAL, REFACTORED, AND PROFESSIONALLY POLISHED)

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cortex/main.dart';
import 'package:cortex/settings/sections/delete.dart';
import 'package:cortex/settings/sections/header.dart';
import 'package:cortex/settings/sections/language.dart';
import 'package:cortex/settings/sections/settings.dart';
import 'package:cortex/settings/sections/theme.dart';
import 'package:cortex/settings/sections/user.dart';
import 'package:cortex/settings/skeleton.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../cache.dart';
import '../internet.dart';
import '../language.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login/login.dart';
import '../models/backend/data.dart';
import '../notifications.dart';

class SettingsScreen extends StatefulWidget {
  final bool isFromActiveChat;

  const SettingsScreen({
    super.key,
    this.isFromActiveChat = false, // Default to false
  });

  @override
  SettingsScreenState createState() => SettingsScreenState();
}


class SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  static const String _className = "SettingsScreenState";

  // --- State Variables ---
  bool _isLoading = true;
  String _selectedLanguageCode = 'en';
  Map<String, dynamic>? _userData;
  int _hasCortexSubscription = 0;
  Timestamp? _subscriptionExpiresAt;
  bool _isAlphaUser = false;
  late final InternetService _internetService;
  bool _hasInternet = true;
  bool _isVerified = false;
  int _verifyAttempts = 0;
  bool _isDialogOpen = false;
  bool _isVerifyNowLoading = false;
  bool _isResendLoading = false;

  // --- Controllers & Notifiers ---
  late AnimationController _editProfileShakeController;
  late AnimationController _oldPasswordShakeController;
  late AnimationController _newPasswordShakeController;
  late AnimationController _confirmPasswordShakeController;
  late NotificationService _notificationService;
  late final ValueNotifier<int> _remainingSecondsNotifier;

  final RegExp _usernameRegExp = RegExp(r'^[a-z0-9çğışöü.\-_]{2,20}$', caseSensitive: false);

  @override
  void initState() {
    super.initState();
    debugPrint("$_className: initState called.");

    _internetService = InternetService();
    _hasInternet = _internetService.currentStatus;
    _internetService.onConnectivityChanged.listen((connected) {
      if (mounted) {
        final bool hadInternet = _hasInternet;
        setState(() => _hasInternet = connected);
        if (connected && !hadInternet) _fetchUserData();
      }
    });

    _notificationService = Provider.of<NotificationService>(context, listen: false);
    _selectedLanguageCode = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;
    _remainingSecondsNotifier = ValueNotifier<int>(0);
    _loadInitialData();

    const shakeDuration = Duration(milliseconds: 500);
    _editProfileShakeController = AnimationController(vsync: this, duration: shakeDuration);
    _oldPasswordShakeController = AnimationController(vsync: this, duration: shakeDuration);
    _newPasswordShakeController = AnimationController(vsync: this, duration: shakeDuration);
    _confirmPasswordShakeController = AnimationController(vsync: this, duration: shakeDuration);

    WidgetsBinding.instance.addObserver(this);
    debugPrint("$_className: WidgetsBindingObserver registered.");
    debugPrint("$_className: initState setup complete.");
  }

  @override
  void dispose() {
    debugPrint("$_className: dispose called.");
    if (_userData != null) {
      CacheService.startSettingsCacheTimer();
    }
    _editProfileShakeController.dispose();
    _oldPasswordShakeController.dispose();
    _newPasswordShakeController.dispose();
    _confirmPasswordShakeController.dispose();
    _internetService.dispose();
    _remainingSecondsNotifier.dispose();
    WidgetsBinding.instance.removeObserver(this);
    debugPrint("$_className: All controllers and services disposed.");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      debugPrint("$_className: App resumed. Forcing a refresh of user data by invalidating cache.");

      // --- THE FIX: Invalidate the in-memory cache and trigger a fresh data fetch. ---
      // This ensures that when the user returns to the app (e.g., after a purchase
      // or managing subscriptions), the data on this screen is up-to-date.
      CacheService.invalidateSettingsCache();

      // Now, when we fetch, it will be forced to go to the network
      // because the in-memory cache is now null.
      _fetchUserData();
    }
  }

  /// Loads initial user data. It first checks for a forced refresh or an empty
  /// cache. If neither is true, it loads instantly from the in-memory cache.
  void _loadInitialData() {
    final String methodName = "$_className: _loadInitialData";

    // If a refresh is forced OR the cache is empty, fetch new data from the network.
    if (AppDataState().needsRefresh || CacheService.cachedSettingsUserData == null) {
      debugPrint("$methodName: Forcing data fetch. Reason: Change flag set OR cache is empty.");
      _fetchUserData();
    } else {
      debugPrint("$methodName: Loading user data from valid in-memory cache.");

      // 1. Instantly check the locally known verification status from FirebaseAuth.
      final currentUser = FirebaseAuth.instance.currentUser;
      final bool isCurrentlyVerified = currentUser?.emailVerified ?? false;

      // 2. Get the cached data.
      final Map<String, dynamic> cachedData = CacheService.cachedSettingsUserData!;

      // 3. Populate the state with both cached data and the fresh verification status.
      _populateStateFromData(cachedData);

      setState(() {
        _isVerified = isCurrentlyVerified;
        _isLoading = false; // Immediately remove loading screen
      });

      // 4. This logic now correctly handles the countdown timer for unverified users.
      if (!isCurrentlyVerified && cachedData['createdAt'] != null) {
        // This logic mirrors the one in _fetchUserData to ensure consistency.
        final int verifyAttempts = cachedData['verifyAttempts'] as int? ?? 0;
        final Timestamp createdAt = cachedData['createdAt'] as Timestamp;
        final DateTime deadline = createdAt.toDate().add(Duration(hours: 24 * (verifyAttempts + 1)));
        final int calculatedRemainingSeconds = deadline.difference(DateTime.now()).inSeconds;

        _remainingSecondsNotifier.value = calculatedRemainingSeconds > 0 ? calculatedRemainingSeconds : 0;
        debugPrint("$methodName: Calculated remaining time from cache: ${_remainingSecondsNotifier.value} seconds.");
      } else {
        // If verified or if 'createdAt' is missing, the timer should be zero.
        _remainingSecondsNotifier.value = 0;
      }

      CacheService.touchSettingsCache(); // Reset the cache expiration timer
    }
  }

  /// Fetches user data from network sources (Auth and Firestore), updates the
  /// in-memory cache, and then populates the screen's state.
  Future<void> _fetchUserData() async {
    final String methodName = "$_className: _fetchUserData";
    debugPrint("$methodName: Attempting to fetch user data from network.");

    if (!mounted) return;

    // Show loading indicator only if it's the initial fetch (i.e., cache was empty)
    if (_userData == null) {
      setState(() => _isLoading = true);
    }

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (r) => false);
        return;
      }

      // Always get the latest auth state.
      await user.reload();
      final bool isEmailVerified = user.emailVerified;

      if (mounted) {
        setState(() => _isVerified = isEmailVerified);
      }
      if (isEmailVerified) {
        _remainingSecondsNotifier.value = 0;
      }

      // Fetch the corresponding Firestore document.
      debugPrint("$methodName: Fetching user document from Firestore for UID: ${user.uid}.");
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final DocumentSnapshot userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        await FirebaseAuth.instance.signOut();
        if (mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (r) => false);
        return;
      }

      final data = userDoc.data() as Map<String, dynamic>;

      // --- THE FIX: UPDATE THE CACHE AFTER A SUCCESSFUL FETCH ---
      // 1. Update the static in-memory cache with the fresh data.
      CacheService.updateSettingsCache(data);

      // 2. The `needsRefresh` getter in `AppDataState` automatically handles
      //    resetting the flag, so no explicit 'mark as refreshed' call is needed here.

      // Now, populate the screen's state with this new, fresh data.
      _populateStateFromData(data);

      // Calculate dynamic values on the fly (this doesn't affect the cache).
      if (!isEmailVerified && data['createdAt'] != null) {
        final int verifyAttempts = data['verifyAttempts'] as int? ?? 0;
        final Timestamp createdAt = data['createdAt'] as Timestamp;
        final DateTime deadline = createdAt.toDate().add(Duration(hours: 24 * (verifyAttempts + 1)));
        final int calculatedRemainingSeconds = deadline.difference(DateTime.now()).inSeconds;

        _remainingSecondsNotifier.value = calculatedRemainingSeconds > 0 ? calculatedRemainingSeconds : 0;
      }

      debugPrint("$methodName: User data fetched, cached, and state updated successfully.");

    } catch (e) {
      debugPrint("$methodName: Error fetching user data: $e");
      if(mounted){
        _notificationService.showNotification(
            message: AppLocalizations.of(context)!.anErrorOccurred,
            isSuccess: false
        );
      }
    } finally {
      // Ensure loading indicator is always turned off, regardless of success or failure.
      if (mounted && _isLoading) setState(() => _isLoading = false);
    }
  }

  /// Populates the widget's state from a given data map. This version is
  /// hardened to correctly handle `Timestamp` objects from a live fetch
  /// and `String` representations from the cache.
  void _populateStateFromData(Map<String, dynamic> data) {
    if (!mounted) return;

    // Handle the subscription date conversion safely.
    final dynamic expiresValue = data['subscriptionExpiresAt'];
    Timestamp? parsedTimestamp;

    if (expiresValue is Timestamp) {
      // Case 1: Data comes directly from Firestore (live fetch).
      parsedTimestamp = expiresValue;
    } else if (expiresValue is String) {
      // Case 2: Data comes from the JSON cache.
      // We need to parse the ISO 8601 string back into a Timestamp.
      final parsedDate = DateTime.tryParse(expiresValue);
      if (parsedDate != null) {
        parsedTimestamp = Timestamp.fromDate(parsedDate);
      }
    }
    // If expiresValue is null or invalid, parsedTimestamp remains null.

    setState(() {
      _userData = data;
      _hasCortexSubscription = data['hasCortexSubscription'] as int? ?? 0;
      _isAlphaUser = data['alphaUser'] as bool? ?? false;
      _verifyAttempts = data['verifyAttempts'] as int? ?? 0;

      // Use the safely parsed timestamp.
      _subscriptionExpiresAt = parsedTimestamp;
    });
  }

  /// Resends the verification email, now consistent with the logic in `verify.dart`.
  Future<void> _resendVerificationEmailFromAccount() async {
    final String methodName = "$_className: _resendVerificationEmailFromAccount";
    debugPrint("$methodName: Attempting to resend verification email.");

    if (_isResendLoading) return;
    setState(() => _isResendLoading = true);

    final appLocalizations = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isResendLoading = false);
      return;
    }

    if (!await _internetService.hasInternet()) {
      _notificationService.showNotification(message: appLocalizations.noInternetConnection, isSuccess: false, bottomOffset: 0.02);
      if (mounted) setState(() => _isResendLoading = false);
      return;
    }

    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      final doc = await userDocRef.get();
      final currentAttempts = doc.data()?['verifyAttempts'] as int? ?? 0;
      if (currentAttempts >= 2) {
        _notificationService.showNotification(message: appLocalizations.maxResendLimitReached, isSuccess: false, bottomOffset: 0.02);
        return;
      }

      await user.sendEmailVerification();
      await userDocRef.update({'verifyAttempts': FieldValue.increment(1)});

      _notificationService.showNotification(message: appLocalizations.linkSent, isSuccess: true, bottomOffset: 0.02);
    } on FirebaseAuthException catch (e) {
      final message = (e.code == 'too-many-requests')
          ? appLocalizations.tooManyRequests
          : (e.message ?? appLocalizations.anErrorOccurred);
      _notificationService.showNotification(message: message, isSuccess: false, bottomOffset: 0.02);
    } catch (e) {
      _notificationService.showNotification(message: appLocalizations.anErrorOccurred, isSuccess: false, bottomOffset: 0.02);
    } finally {
      // Refresh all data to reflect the new attempt count and remaining time.
      await _fetchUserData();
      if (mounted) setState(() => _isResendLoading = false);
    }
  }

  // --- OMITTED FOR BREVITY: Caching and helper methods remain unchanged ---
  // (_getLocalCacheFile, _convertTimestamps, saveUserDataCache, loadUserDataCache)
  // --- OMITTED FOR BREVITY: UI build methods remain unchanged ---
  // (build, _buildSkeletonLoader, _buildContent, _buildUnverifiedPanel)
  // --- OMITTED FOR BREVITY: Action methods remain unchanged ---
  // (_resendVerificationEmailFromAccount, _verifyNow, _changeLanguage)
  // --- OMITTED FOR BREVITY: Helper Widget and Function remain unchanged ---
  // (_formatRemainingTime, CountdownTimerWidget)

  // Full implementation of omitted methods for completeness
  Future<File> _getLocalCacheFile() async {
    final directory = Directory.systemTemp;
    return File('${directory.path}/userDataCache.json');
  }

  dynamic _convertTimestamps(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    } else if (value is Map) {
      return value.map((key, val) => MapEntry(key, _convertTimestamps(val)));
    } else if (value is List) {
      return value.map(_convertTimestamps).toList();
    }
    return value;
  }

  Future<void> saveUserDataCache(Map<String, dynamic> data) async {
    final String methodName = "$_className: saveUserDataCache";
    try {
      final file = await _getLocalCacheFile();
      final convertedData = _convertTimestamps(data);
      await file.writeAsString(jsonEncode(convertedData));
      debugPrint("$methodName: User data cached successfully to ${file.path}.");
    } catch (e) {
      debugPrint("$methodName: Error saving user data to cache: $e");
    }
  }

  Future<Map<String, dynamic>?> loadUserDataCache() async {
    final String methodName = "$_className: loadUserDataCache";
    try {
      final file = await _getLocalCacheFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = jsonDecode(contents) as Map<String, dynamic>;
        debugPrint(
            "$methodName: User data loaded successfully from cache: ${file.path}.");
        return data;
      } else {
        debugPrint("$methodName: Cache file not found at ${file.path}.");
      }
    } catch (e) {
      debugPrint("$methodName: Error loading user data from cache: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("$_className: build called. isLoading: $_isLoading.");
    final appLocalizations = AppLocalizations.of(context)!;

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
    child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
        child: _isLoading ? _buildSkeletonLoader() : _buildContent(appLocalizations),
      ),
    ),
    );
  }

  Widget _buildSkeletonLoader() => const SkeletonLoader(key: ValueKey('skeletonLoader'));


  Widget _buildContent(AppLocalizations appLocalizations) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final String displayName = _userData?['username'] as String? ?? FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? appLocalizations.user;
    final String email = FirebaseAuth.instance.currentUser?.email ?? appLocalizations.emailAlreadyInUse;

    return ListView(
      key: const ValueKey('settingsContent'),
      padding: EdgeInsets.all(screenWidth * 0.04),
      children: [
        if (_userData != null)
          ProfileHeaderSection(
            displayName: displayName,
            email: email,
            // Now passing both required pieces of data for a reliable check
            userSubscriptionLevel: _hasCortexSubscription,
            subscriptionExpiresAt: _subscriptionExpiresAt, // This parameter is new
            isAlphaUser: _isAlphaUser,
          ),
        if (_userData != null) SizedBox(height: screenHeight * 0.02),

        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: (_userData != null && !_isVerified && _hasInternet) ? 1.0 : 0.0,
          child: (_userData != null && !_isVerified && _hasInternet) ? _buildUnverifiedPanel(appLocalizations) : const SizedBox.shrink(),
        ),

        if (_userData != null && _hasInternet)
          UserSection(
            appLocalizations: appLocalizations,
            notificationService: _notificationService,
            userData: _userData!,
            fetchUserDataCallback: _fetchUserData,
            usernameRegExp: _usernameRegExp,
            editProfileShakeController: _editProfileShakeController,
            oldPasswordShakeController: _oldPasswordShakeController,
            newPasswordShakeController: _newPasswordShakeController,
            confirmPasswordShakeController: _confirmPasswordShakeController,
            isDialogOpen: _isDialogOpen,
            onDialogStateChanged: (isOpen) => setState(() => _isDialogOpen = isOpen),
            hasInternetConnectionCallback: () async => _internetService.hasInternet(),
          ),
        if (_userData != null && _hasInternet) SizedBox(height: screenHeight * 0.03),

        AppLanguageSection(appLocalizations: appLocalizations, selectedLanguageCode: _selectedLanguageCode, onLanguageChanged: _changeLanguage, isDialogOpen: _isDialogOpen, onDialogStateChanged: (isOpen) => setState(() => _isDialogOpen = isOpen)),
        SizedBox(height: screenHeight * 0.025),

        AppThemeSection(appLocalizations: appLocalizations, userSubscriptionLevel: _hasCortexSubscription, isDialogOpen: _isDialogOpen,   // This gives the widget the data it needs to check if the subscription is active.
            subscriptionExpiresAt: _subscriptionExpiresAt, onDialogStateChanged: (isOpen) => setState(() => _isDialogOpen = isOpen), notificationService: _notificationService),
        SizedBox(height: screenHeight * 0.025),

        SettingsSection(appLocalizations: appLocalizations),
        SizedBox(height: screenHeight * 0.025),

        DeleteSection(
          userData: _userData,
          hasInternet: _hasInternet,
          isFromActiveChat: widget.isFromActiveChat,
        ),
        SizedBox(height: screenHeight * 0.02),
      ],
    );
  }

  Widget _buildUnverifiedPanel(AppLocalizations appLocalizations) {
    debugPrint("$_className: Building unverified panel.");
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
          Text(appLocalizations.unverifiedAccountHeader, style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted), textAlign: TextAlign.center),
          SizedBox(height: screenHeight * 0.01),
          ValueListenableBuilder<int>(
            valueListenable: _remainingSecondsNotifier,
            builder: (context, currentSeconds, child) {
              final timeStr = _formatRemainingTime(currentSeconds);
              return Text(
                appLocalizations.unverifiedAccountWarning(timeStr),
                style: TextStyle(fontSize: screenWidth * 0.035, color: AppColors.quinaryColor),
                textAlign: TextAlign.center,
              );
            },
          ),
          SizedBox(height: screenHeight * 0.015),
          CountdownTimerWidget(
            initialSeconds: _remainingSecondsNotifier.value,
            style: GoogleFonts.anaheim(textStyle: TextStyle(fontSize: screenWidth * 0.05, color: AppColors.primaryColor.inverted, fontWeight: FontWeight.w900)),
            onFinished: () {
              if (mounted && !_isVerified) _fetchUserData();
            },
            remainingSecondsNotifier: _remainingSecondsNotifier,
          ),
          SizedBox(height: screenHeight * 0.015),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(screenHeight * 0.06), backgroundColor: AppColors.senaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: _isVerifyNowLoading ? null : _verifyNow,
              child: _isVerifyNowLoading ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryColor)) : Text(appLocalizations.verifyNow, style: TextStyle(color: AppColors.primaryColor, fontSize: screenWidth * 0.04)),
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(screenHeight * 0.06), backgroundColor: AppColors.senaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: (_verifyAttempts >= 2 || _isResendLoading) ? null : _resendVerificationEmailFromAccount,
              child: _isResendLoading ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryColor)) : Text(appLocalizations.resendCode, textAlign: TextAlign.center, style: TextStyle(color: _verifyAttempts >= 2 ? AppColors.quinaryColor : AppColors.primaryColor, fontSize: screenWidth * 0.04)),
            ),
          ),
          if (_verifyAttempts >= 2)
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.01),
              child: Center(
                child: Text(appLocalizations.maxResendLimitReached, textAlign: TextAlign.center, style: TextStyle(color: AppColors.septenaryColor, fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _verifyNow() async {
    final String methodName = "$_className: _verifyNow";
    debugPrint("$methodName: 'Verify Now' button pressed.");

    if (_isVerifyNowLoading) return;
    setState(() => _isVerifyNowLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isVerifyNowLoading = false);
      return;
    }

    if (!await _internetService.hasInternet()) {
      _notificationService.showNotification(message: AppLocalizations.of(context)!.noInternetConnection, isSuccess: false, bottomOffset: 0.02);
      setState(() => _isVerifyNowLoading = false);
      return;
    }

    try {
      await user.reload();
      if (user.emailVerified) {
        _notificationService.showNotification(message: AppLocalizations.of(context)!.accountVerified, bottomOffset: 0.02, isSuccess: true);
      } else {
        _notificationService.showNotification(message: AppLocalizations.of(context)!.authError, bottomOffset: 0.02, isSuccess: false);
      }
    } catch (e) {
      _notificationService.showNotification(message: AppLocalizations.of(context)!.anErrorOccurred, bottomOffset: 0.02, isSuccess: false);
    } finally {
      await _fetchUserData();
      if (mounted) setState(() => _isVerifyNowLoading = false);
    }
  }

  void _changeLanguage(String languageCode) {
    debugPrint("$_className: Changing language to '$languageCode'.");

    CacheService.invalidateModelsScreenCache();
    ModelData.clearCache();
    debugPrint("$_className: Caches invalidated due to language change.");

    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    if (mounted) {
      setState(() => _selectedLanguageCode = languageCode);
    }
    localeProvider.setLocale(Locale(languageCode));
  }
}

String _formatRemainingTime(int totalSeconds) {
  if (totalSeconds < 0) totalSeconds = 0;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
}

class CountdownTimerWidget extends StatefulWidget {
  final int initialSeconds;
  final TextStyle style;
  final VoidCallback onFinished;
  final ValueNotifier<int> remainingSecondsNotifier;

  const CountdownTimerWidget({
    Key? key,
    required this.initialSeconds,
    required this.style,
    required this.onFinished,
    required this.remainingSecondsNotifier,
  }) : super(key: key);

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.remainingSecondsNotifier.value = widget.initialSeconds;
    _startTimer();
  }

  @override
  void didUpdateWidget(CountdownTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSeconds != oldWidget.initialSeconds) {
      _timer?.cancel();
      widget.remainingSecondsNotifier.value = widget.initialSeconds;
      _startTimer();
    }
  }

  void _startTimer() {
    if (widget.remainingSecondsNotifier.value <= 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.remainingSecondsNotifier.value > 0) {
        widget.remainingSecondsNotifier.value--;
      } else {
        timer.cancel();
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.remainingSecondsNotifier,
      builder: (context, value, child) {
        return Text(
          _formatRemainingTime(value),
          style: widget.style,
        );
      },
    );
  }
}