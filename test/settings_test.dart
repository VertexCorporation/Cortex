// test/settings_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/internet.dart';
import 'package:cortex/notifications/introvert.dart';
import 'package:cortex/server/user.dart';
import 'package:cortex/settings/providers/general.dart';
import 'package:cortex/settings/services/auth.dart';
import 'package:cortex/settings/services/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// --- FAKES ---

class FakeUser extends Fake implements User {
  @override
  String get uid => 'test_uid';
}

class FakeAuthService implements AuthService {
  bool verified = true;
  int reloadCalledCount = 0;
  int sendEmailCalledCount = 0;
  final FakeUser _fakeUser = FakeUser();

  @override
  bool isCurrentUserVerified() => verified;

  @override
  Future<void> reloadCurrentUser() async {
    reloadCalledCount++;
  }

  @override
  Future<void> sendVerificationEmail() async {
    sendEmailCalledCount++;
  }

  // CORRECTED OVERRIDE HERE
  @override
  Future<void> changePassword(
      {required String oldPassword, required String newPassword}) async {}

  @override
  User? get currentUser => _fakeUser; // Returns non-null user

  @override
  bool hasPasswordProvider() => true;

  @override
  bool get isLoggedIn => true;

  @override
  Future<void> signOutFromProviders() async {}
}

class FakeProfileService implements ProfileService {
  Map<String, dynamic> fakeData = {
    'accountType': 'standard',
    'hasCortexSubscription': 1,
    'verifyAttempts': 0,
  };
  int incrementAttemptsCalled = 0;

  @override
  Future<Map<String, dynamic>> fetchUserData() async {
    return fakeData;
  }

  @override
  Future<void> incrementVerificationAttempts() async {
    incrementAttemptsCalled++;
    if (fakeData.containsKey('verifyAttempts')) {
      fakeData['verifyAttempts'] = (fakeData['verifyAttempts'] as int) + 1;
    }
  }

  @override
  Future<void> redeemCreatorCode(String code) async {}

  @override
  Future<void> requestAccountDeletion() async {}

  @override
  Future<void> updateUsername(String newUsername) async {}
}

class FakeNotificationService implements IntrovertNotificationService {
  String? lastMessage;
  NotificationType? lastType;

  @override
  void showNotification({
    required String message,
    NotificationType type = NotificationType.neutral,
    double bottomOffset = 0.1,
    double fontSize = 0.038,
    bool oneLine = false,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    bool isAxonMode = false,
    double axonWidth = 0.0,
    bool isChatMode = false,
  }) {
    lastMessage = message;
    lastType = type;
  }

  @override
  void dismissAxonNotification() {}

  @override
  void dismissCurrentNotification() {}

  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();
}

class FakeInternetProvider extends InternetProvider {
  bool _connected = true;

  @override
  bool get isConnected => _connected;

  void setConnected(bool value) {
    _connected = value;
  }
}

class FakeUserProvider extends UserProvider {
  final FakeProfileService profileService;

  FakeUserProvider(this.profileService);

  @override
  Future<void> fetchInitialData(User user) async {
    final data = await profileService.fetchUserData();
    userData = data;
  }
}

void main() {
  group('SettingsGeneralProvider Tests', () {
    late SettingsGeneralProvider provider;
    late FakeAuthService auth;
    late FakeProfileService profile;
    late FakeNotificationService notifications;
    late FakeUserProvider userProvider;

    setUp(() {
      auth = FakeAuthService();
      profile = FakeProfileService();
      notifications = FakeNotificationService();
      userProvider = FakeUserProvider(profile);

      provider = SettingsGeneralProvider(
        authService: auth,
        profileService: profile,
        notificationService: notifications,
        userProvider: userProvider,
      );
    });

    test('Initial state getters', () {
      // isLoading becomes false almost immediately because cache check is synchronous
      // and it sets loading to false before fetching fresh data.
      expect(provider.isLoading, false);
      expect(provider.hasInternet, true);
      expect(provider.isResendingEmail, false);
      expect(provider.isVerified, true);
    });

    test('isAnonymous check', () async {
      await provider
          .refreshData(); // This loads data from profile into userProvider
      expect(provider.isAnonymous, false);

      profile.fakeData = {'accountType': 'anonymous'};
      await provider.refreshData();
      expect(provider.isAnonymous, true);
    });

    test('Subscription Level Logic', () async {
      await provider.refreshData();
      // Level 1 without expiry is 0
      expect(provider.activeSubscriptionLevel, 0);

      profile.fakeData = {
        'hasCortexSubscription': 1,
        'subscriptionExpiresAt':
            Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
      };
      await provider.refreshData();
      expect(provider.activeSubscriptionLevel, 1);

      profile.fakeData = {
        'hasCortexSubscription': 1,
        'subscriptionExpiresAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 1))),
      };
      await provider.refreshData();
      expect(provider.activeSubscriptionLevel, 0);

      profile.fakeData = {'hasCortexSubscription': 5};
      await provider.refreshData();
      expect(provider.activeSubscriptionLevel, 5);
    });

    test('Resend Verification Email Flow', () async {
      auth.verified = false;
      await provider.resendVerificationEmail();

      expect(provider.isResendingEmail, false);
      expect(auth.sendEmailCalledCount, 1);
      expect(profile.incrementAttemptsCalled, 1);
      expect(notifications.lastType, NotificationType.success);
    });

    test('Resend Verification Limit', () async {
      profile.fakeData = {'verifyAttempts': 2};
      await provider.refreshData();
      await provider.resendVerificationEmail();
      expect(auth.sendEmailCalledCount, 0);
    });
  });
}
