import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/firestore_config.dart';
import '../config/preference_config.dart';
import '../profile/model/profile_info.dart';

class NotificationTokenHelper {
  static String? _fcmToken = '';

  static uploadFcmToken() async {
    _fcmToken = await FirebaseMessaging.instance.getToken();
    if (_fcmToken != null) {
      _updateFcmTokenToFirebase();
    }
  }

  static observeNotificationChange() {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      _fcmToken = token;
      _updateFcmTokenToFirebase();
    });
  }

  static _updateFcmTokenToFirebase() async {
    final prefs = await SharedPreferences.getInstance();
    final firebaseUserId = prefs.getString(PreferenceConfig.userIdPref);
    if (firebaseUserId != null) {
      final profileInfo = await _fetchProfileInfoFromFirebase(firebaseUserId);
      if (profileInfo != null) {
        _updateFcmToken(profileInfo);
      }
    }
  }

  static Future<ProfileInfo?> _fetchProfileInfoFromFirebase(
    String firebaseUserId,
  ) async {
    final user = await FirebaseFirestore.instance
        .collection(FireStoreConfig.userCollection)
        .doc(firebaseUserId)
        .get();
    ProfileInfo? profileInfo;
    try {
      profileInfo = ProfileInfo.fromSnapshot(user);
    } on Exception catch (_) {}
    return profileInfo;
  }

  static removeTokenOnLogout(String? firebaseUserId) async {
    if (firebaseUserId != null && _fcmToken?.trim().isNotEmpty == true) {
      await FirebaseFirestore.instance
          .collection(FireStoreConfig.userCollection)
          .doc(firebaseUserId)
          .update({
        FireStoreConfig.userFcmTokenField: FieldValue.arrayRemove([_fcmToken])
      });
    }
  }

  static _updateFcmToken(ProfileInfo profileInfo) async {
    final Map<String, dynamic> data = {};
    List<String>? tokens = profileInfo.fcmTokens;
    tokens ??= [];
    if (!tokens.contains(_fcmToken)) {
      tokens.add(_fcmToken!);
      data[FireStoreConfig.userFcmTokenField] = tokens;
      data[FireStoreConfig.updatedAtField] =
          DateTime.now().millisecondsSinceEpoch;
      await FirebaseFirestore.instance
          .collection(FireStoreConfig.userCollection)
          .doc(profileInfo.userId)
          .update(data);
    }
  }
}
