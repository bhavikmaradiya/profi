import 'package:cloud_firestore/cloud_firestore.dart';

import '../../config/firestore_config.dart';

class LogInfo {
  String? logId;
  String? projectId;
  String? projectMilestoneId;
  String? milestoneInfoId;
  String? on;
  double? oldAmount;
  double? newAmount;
  int? oldDate;
  int? newDate;
  String? notes;
  double? transaction;
  bool? invoiced;
  String? generatedByUserId;
  String? generatedByUserName;
  int? createdAt;

  LogInfo({
    this.logId,
    this.projectId,
    this.projectMilestoneId,
    this.milestoneInfoId,
    this.on,
    this.oldAmount,
    this.newAmount,
    this.oldDate,
    this.newDate,
    this.notes,
    this.transaction,
    this.invoiced,
    this.generatedByUserId,
    this.generatedByUserName,
    this.createdAt,
  });

  factory LogInfo.fromSnapshot(DocumentSnapshot document) {
    final data = document.data();
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception();
    }
    return LogInfo(
      logId: data[FireStoreConfig.logIdField],
      projectId: data[FireStoreConfig.logProjectIdField],
      projectMilestoneId: data[FireStoreConfig.logProjectMilestoneIdField],
      milestoneInfoId: data[FireStoreConfig.logMilestoneInfoIdField],
      on: data[FireStoreConfig.logOnField],
      oldAmount: data[FireStoreConfig.logOldAmountField],
      newAmount: data[FireStoreConfig.logNewAmountField],
      oldDate: data[FireStoreConfig.logOldDateField],
      newDate: data[FireStoreConfig.logNewDateField],
      notes: data[FireStoreConfig.logNotesField],
      transaction: data[FireStoreConfig.logTransactionField],
      invoiced: data[FireStoreConfig.logInvoicedField],
      generatedByUserId: data[FireStoreConfig.logGeneratedByUserIdField],
      generatedByUserName: data[FireStoreConfig.logGeneratedByUserNameField],
      createdAt: data[FireStoreConfig.createdAtField],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FireStoreConfig.logIdField: logId,
      FireStoreConfig.logProjectIdField: projectId,
      FireStoreConfig.logProjectMilestoneIdField: projectMilestoneId,
      FireStoreConfig.logMilestoneInfoIdField: milestoneInfoId,
      FireStoreConfig.logOnField: on,
      FireStoreConfig.logOldDateField: oldDate,
      FireStoreConfig.logNewDateField: newDate,
      FireStoreConfig.logOldAmountField: oldAmount,
      FireStoreConfig.logNewAmountField: newAmount,
      FireStoreConfig.logTransactionField: transaction,
      FireStoreConfig.logInvoicedField: invoiced,
      FireStoreConfig.logNotesField: notes,
      FireStoreConfig.logGeneratedByUserIdField: generatedByUserId,
      FireStoreConfig.logGeneratedByUserNameField: generatedByUserName,
      FireStoreConfig.createdAtField: createdAt,
    };
  }
}
