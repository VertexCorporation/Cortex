// fetch.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FetchService {
  static Future<Map<String, dynamic>?> fetchUserData() async {
    bool isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      return await loadCachedUserData();
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        Map<String, dynamic> userData = userDoc.data() ?? {};

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'cached_user_data',
          jsonEncode(
            userData,
            toEncodable: (object) {
              if (object is Timestamp) {
                return object.toDate().toIso8601String();
              }
              return object;
            },
          ),
        );

        // Eğer kullanıcı adı mevcutsa, ilk harf cache’leniyor.
        if (userData['username'] != null &&
            (userData['username'] as String).trim().isNotEmpty) {
          final initial =
          (userData['username'] as String).trim()[0].toUpperCase();
          await prefs.setString('profile_initial', initial);
        }
        return userData;
      } catch (e) {
        print("Error fetching user data: $e");
        return await loadCachedUserData();
      }
    }
    return null;
  }

  static Future<Map<String, dynamic>?> loadCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_user_data');
    if (cachedData != null) {
      try {
        return jsonDecode(cachedData);
      } catch (e) {
        print("Cache parse error: $e");
      }
    }
    return null;
  }

  static Future<String> getProfileInitial() async {
    final prefs = await SharedPreferences.getInstance();
    String? initial = prefs.getString('profile_initial');
    if (initial != null && initial.isNotEmpty) {
      return initial;
    }
    final userData = await fetchUserData();
    if (userData != null &&
        userData['username'] != null &&
        (userData['username'] as String).trim().isNotEmpty) {
      initial = (userData['username'] as String).trim()[0].toUpperCase();
      await prefs.setString('profile_initial', initial);
      return initial;
    }
    return '?';
  }

  static Future<void> updateProfileInitial(String newUsername) async {
    final prefs = await SharedPreferences.getInstance();
    final newInitial =
    newUsername.trim().isNotEmpty ? newUsername.trim()[0].toUpperCase() : '?';
    await prefs.setString('profile_initial', newInitial);
  }

  static Future<void> clearProfileInitial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_initial');
  }
}