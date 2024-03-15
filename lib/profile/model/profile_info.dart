import 'package:cloud_firestore/cloud_firestore.dart';

import '../../config/firestore_config.dart';

class ProfileInfo {
  String? userId;
  String? name;
  String? email;
  String? role;
  List<String>? fcmTokens;
  int? createdAt;
  int? updatedAt;

  ProfileInfo({
    this.userId,
    this.name,
    this.email,
    this.role,
    this.fcmTokens,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileInfo.fromSnapshot(DocumentSnapshot document) {
    final data = document.data();
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception();
    }
    final List<String> fcmToken = [];
    final tokens = data[FireStoreConfig.userFcmTokenField];
    if (tokens is List<dynamic>) {
      for (int i = 0; i < tokens.length; i++) {
        final tokenId = tokens[i];
        if (tokenId is String && !fcmToken.contains(tokenId)) {
          fcmToken.add(tokens[i]);
        }
      }
    }

    return ProfileInfo(
      userId: data[FireStoreConfig.userIdField],
      name: data[FireStoreConfig.userNameField],
      email: data[FireStoreConfig.userEmailField],
      role: data[FireStoreConfig.userRoleField],
      fcmTokens: fcmToken,
      createdAt: data[FireStoreConfig.createdAtField],
      updatedAt: data[FireStoreConfig.updatedAtField],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FireStoreConfig.userIdField: userId,
      FireStoreConfig.userNameField: name,
      FireStoreConfig.userEmailField: email,
      FireStoreConfig.userRoleField: role,
      FireStoreConfig.userFcmTokenField: fcmTokens,
      FireStoreConfig.createdAtField: createdAt,
      FireStoreConfig.updatedAtField: updatedAt,
    };
  }
}
