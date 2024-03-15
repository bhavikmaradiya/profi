import 'package:cloud_firestore/cloud_firestore.dart';

import '../../config/firestore_config.dart';

class WalletInfo {
  double? walletAAmount;
  double? walletBAmount;
  bool walletAIsStarted;
  bool walletBIsStarted;
  int? updatedAt;
  String? note;

  WalletInfo({
    this.walletAAmount,
    this.walletBAmount,
    this.walletAIsStarted = false,
    this.walletBIsStarted = false,
    this.note,
    this.updatedAt,
  });

  factory WalletInfo.fromSnapshot(DocumentSnapshot document) {
    final data = document.data();
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception();
    }
    final walletAAmount = data[FireStoreConfig.walletAAmountField];
    final walletBAmount = data[FireStoreConfig.walletBAmountField];
    return WalletInfo(
      walletAAmount: walletAAmount != null
          ? double.tryParse(walletAAmount.toString())
          : null,
      walletBAmount: walletBAmount != null
          ? double.tryParse(walletBAmount.toString())
          : null,
      walletAIsStarted: data[FireStoreConfig.walletAIsStartedField] ?? false,
      walletBIsStarted: data[FireStoreConfig.walletBIsStartedField] ?? false,
      note: data[FireStoreConfig.walletNoteField],
      updatedAt: data[FireStoreConfig.updatedAtField],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FireStoreConfig.walletAAmountField: walletAAmount,
      FireStoreConfig.walletBAmountField: walletBAmount,
      FireStoreConfig.walletAIsStartedField: walletAIsStarted,
      FireStoreConfig.walletBIsStartedField: walletBIsStarted,
      FireStoreConfig.walletNoteField: note,
      FireStoreConfig.updatedAtField: updatedAt,
    };
  }
}
