// services/profile.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

// --- Custom Exceptions for Clear Error Handling ---

/// A base class for all user profile-related exceptions.
/// It now carries an error code instead of a user-facing message.
class ProfileException implements Exception {
  /// A machine-readable error code (e.g., 'already-exists', 'not-found').
  final String code;
  ProfileException(this.code);

  @override
  String toString() => 'ProfileException: $code';
}

/// Thrown when a user's document is not found in Firestore.
class ProfileNotFoundException extends ProfileException {
  ProfileNotFoundException() : super('not-found');
}

/// A generic exception for unknown or unexpected profile-related errors.
class ProfileUnknownException extends ProfileException {
  ProfileUnknownException() : super('unknown');
}


/// A service for managing user profile data stored in Firestore and
/// interacting with related Cloud Functions.
///
/// This class abstracts all data operations related to a user's account details.
/// It separates the application's business logic from the underlying Firebase implementation.
/// When errors occur, it throws `ProfileException` with a specific error code,
/// leaving localization to the ViewModel layer.
class ProfileService {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  ProfileService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1'),
        _auth = auth ?? FirebaseAuth.instance;

  String _getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ProfileException('no-user-signed-in');
    }
    return user.uid;
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    final uid = _getCurrentUserId();
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        throw ProfileNotFoundException();
      }
      return docSnapshot.data()!;
    } catch (e) {
      debugPrint("ProfileService: Error fetching user data: $e");
      if (e is ProfileNotFoundException) rethrow;
      throw ProfileUnknownException();
    }
  }

  /// Updates the current user's username by calling a secure Cloud Function.
  /// Throws a `ProfileException` with a specific code on failure.
  Future<void> updateUsername(String newUsername) async {
    try {
      final callable = _functions.httpsCallable('updateUsername');
      await callable.call({'newUsername': newUsername});
    } on FirebaseFunctionsException catch (e) {
      debugPrint("ProfileService: Cloud Function error updating username: ${e.code} - ${e.message}");
      // Propagate the specific error code for the ViewModel to handle localization.
      throw ProfileException(e.code);
    }
  }

  Future<void> incrementVerificationAttempts() async {
    final uid = _getCurrentUserId();
    try {
      await _firestore.collection('users').doc(uid).update({'verifyAttempts': FieldValue.increment(1)});
    } catch (e) {
      debugPrint("ProfileService: Error incrementing verification attempts: $e");
      // This is a non-critical error, so we don't throw to the UI.
    }
  }

  /// Redeems a creator or promotional code via a Cloud Function.
  /// Throws a `ProfileException` with a specific code on failure.
  Future<void> redeemCreatorCode(String code) async {
    try {
      final callable = _functions.httpsCallable('redeemCreatorCode');
      await callable.call({'code': code});
    } on FirebaseFunctionsException catch (e) {
      debugPrint("ProfileService: Cloud Function error redeeming code: ${e.code} - ${e.message}");
      // Propagate the specific error code for the ViewModel to handle localization.
      throw ProfileException(e.code);
    }
  }

  /// Requests the permanent deletion of the user's account via a Cloud Function.
  /// Throws a `ProfileException` with a generic code on failure.
  Future<void> requestAccountDeletion() async {
    try {
      final callable = _functions.httpsCallable('requestAccountDeletion');
      await callable.call();
    } on FirebaseFunctionsException catch (e) {
      debugPrint("ProfileService: Cloud Function error requesting account deletion: ${e.code} - ${e.message}");
      throw ProfileUnknownException();
    }
  }
}