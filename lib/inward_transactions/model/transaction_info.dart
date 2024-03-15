import 'package:cloud_firestore/cloud_firestore.dart';

import '../../config/firestore_config.dart';

class TransactionInfo {
  String? transactionId;
  String? projectId;
  String? projectCode;
  String? projectName;
  String? projectType;
  String? milestoneId;
  String? transactionByUserId;
  String? transactionByName;
  List<String>? transactionAvailableFor;
  double? paidAmount;
  double? unPaidAmount;
  String? notes;
  int? transactionDate;
  int? createdAt;
  int? updatedAt;

  TransactionInfo({
    this.transactionId,
    this.projectId,
    this.projectCode,
    this.projectName,
    this.projectType,
    this.milestoneId,
    this.transactionByName,
    this.transactionByUserId,
    this.paidAmount,
    this.unPaidAmount,
    this.notes,
    this.transactionDate,
    this.transactionAvailableFor,
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionInfo.fromSnapshot(DocumentSnapshot document) {
    final data = document.data();
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception();
    }
    final paidAmount = data[FireStoreConfig.transactionPaidAmountField];
    final unPaidAmount = data[FireStoreConfig.transactionUnPaidAmountField];

    final List<String> availableFor = [];
    final transactionAvailableField =
        data[FireStoreConfig.transactionAvailableForField];
    if (transactionAvailableField is List<dynamic>) {
      for (int i = 0; i < transactionAvailableField.length; i++) {
        final transactionAvailableForId = transactionAvailableField[i];
        if (transactionAvailableForId is String &&
            !availableFor.contains(transactionAvailableForId)) {
          availableFor.add(transactionAvailableField[i]);
        }
      }
    }
    return TransactionInfo(
      transactionId: data[FireStoreConfig.transactionIdField],
      projectId: data[FireStoreConfig.transactionProjectIdField],
      projectCode: data[FireStoreConfig.transactionProjectCodeField],
      projectName: data[FireStoreConfig.transactionProjectNameField],
      projectType: data[FireStoreConfig.transactionProjectTypeField],
      milestoneId: data[FireStoreConfig.transactionMilestoneIdField],
      paidAmount:
          paidAmount != null ? double.parse(paidAmount.toString()) : null,
      unPaidAmount:
          unPaidAmount != null ? double.parse(unPaidAmount.toString()) : null,
      notes: data[FireStoreConfig.transactionNotesField],
      transactionByName: data[FireStoreConfig.transactionByNameField],
      transactionByUserId: data[FireStoreConfig.transactionByUserIdField],
      transactionAvailableFor: availableFor,
      transactionDate: data[FireStoreConfig.transactionDateField],
      createdAt: data[FireStoreConfig.createdAtField],
      updatedAt: data[FireStoreConfig.updatedAtField],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FireStoreConfig.transactionIdField: transactionId,
      FireStoreConfig.transactionProjectIdField: projectId,
      FireStoreConfig.transactionProjectCodeField: projectCode,
      FireStoreConfig.transactionProjectNameField: projectName,
      FireStoreConfig.transactionProjectTypeField: projectType,
      FireStoreConfig.transactionDateField: transactionDate,
      FireStoreConfig.transactionByNameField: transactionByName,
      FireStoreConfig.transactionByUserIdField: transactionByUserId,
      FireStoreConfig.transactionPaidAmountField: paidAmount,
      FireStoreConfig.transactionUnPaidAmountField: unPaidAmount,
      FireStoreConfig.transactionMilestoneIdField: milestoneId,
      FireStoreConfig.transactionAvailableForField: transactionAvailableFor,
      FireStoreConfig.transactionNotesField: notes,
      FireStoreConfig.createdAtField: createdAt,
      FireStoreConfig.updatedAtField: updatedAt,
    };
  }
}
