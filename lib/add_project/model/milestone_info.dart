import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../config/firestore_config.dart';
import '../../enums/payment_status_enum.dart';
import '../../utils/app_utils.dart';

class MilestoneInfo {
  final int id;
  String? milestoneCollectionId;
  String? milestoneId;
  DateTime? dateTime;
  double? milestoneAmount;
  int? sequence;
  String? paymentStatus;
  String? projectId;
  String? notes;
  double? receivedAmount;
  bool? isUpdated;
  int? createdAt;
  int? updatedAt;
  String? updatedByUserId;
  String? updatedByUserName;
  FocusNode? amountFieldFocusNode;
  TextEditingController? amountFieldController;
  bool? isInvoiced;
  int? invoicedUpdatedAt;

  MilestoneInfo({
    required this.id,
    required this.dateTime,
    required this.milestoneAmount,
    required this.createdAt,
    required this.updatedAt,
    this.milestoneCollectionId,
    this.milestoneId,
    this.sequence,
    this.paymentStatus,
    this.projectId,
    this.notes,
    this.isUpdated,
    this.receivedAmount,
    this.amountFieldFocusNode,
    this.amountFieldController,
    this.updatedByUserId,
    this.updatedByUserName,
    this.isInvoiced,
    this.invoicedUpdatedAt,
  });

  refreshAmountInController() {
    final amount = (milestoneAmount != null && milestoneAmount! > 0)
        ? AppUtils.removeTrailingZero(
            milestoneAmount,
          )
        : '';
    amountFieldController ??= TextEditingController(text: amount);
  }

  factory MilestoneInfo.fromSnapshot(DocumentSnapshot document) {
    final data = document.data();
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception();
    }
    return MilestoneInfo(
      id: DateTime.now().microsecondsSinceEpoch,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        data[FireStoreConfig.milestoneDateField] ?? 0,
      ),
      milestoneAmount: data[FireStoreConfig.milestoneAmountField],
      milestoneCollectionId: data[FireStoreConfig.milestoneCollectionIdField],
      milestoneId: data[FireStoreConfig.milestoneIdField],
      projectId: data[FireStoreConfig.projectIdField],
      sequence: data[FireStoreConfig.milestoneSequenceField],
      paymentStatus: data[FireStoreConfig.milestonePaymentStatusField],
      notes: data[FireStoreConfig.milestoneNotesField],
      isUpdated: data[FireStoreConfig.milestoneUpdatedField],
      receivedAmount: data[FireStoreConfig.milestoneReceivedAmountField],
      updatedByUserId: data[FireStoreConfig.milestoneUpdatedByUserIdField],
      updatedByUserName: data[FireStoreConfig.milestoneUpdatedByUserNameField],
      createdAt: data[FireStoreConfig.createdAtField],
      updatedAt: data[FireStoreConfig.updatedAtField],
      isInvoiced: data[FireStoreConfig.milestoneInvoicedField],
      invoicedUpdatedAt: data[FireStoreConfig.milestoneInvoicedUpdatedAtField],
    );
  }

  factory MilestoneInfo.copy(MilestoneInfo info) {
    return MilestoneInfo(
      id: info.id,
      milestoneCollectionId: info.milestoneCollectionId,
      milestoneId: info.milestoneId,
      dateTime: info.dateTime,
      milestoneAmount: info.milestoneAmount,
      sequence: info.sequence,
      paymentStatus: info.paymentStatus,
      projectId: info.projectId,
      notes: info.notes,
      receivedAmount: info.receivedAmount,
      isUpdated: info.isUpdated,
      updatedByUserId: info.updatedByUserId,
      updatedByUserName: info.updatedByUserName,
      isInvoiced: info.isInvoiced,
      invoicedUpdatedAt: info.invoicedUpdatedAt,
      createdAt: info.createdAt,
      updatedAt: info.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FireStoreConfig.milestoneCollectionIdField: milestoneCollectionId,
      FireStoreConfig.milestoneIdField: milestoneId,
      FireStoreConfig.milestoneDateField: dateTime?.millisecondsSinceEpoch,
      FireStoreConfig.milestoneAmountField: milestoneAmount,
      FireStoreConfig.milestonePaymentStatusField: paymentStatus ??=
          PaymentStatusEnum.upcoming.name,
      FireStoreConfig.milestoneSequenceField: sequence,
      FireStoreConfig.projectIdField: projectId,
      FireStoreConfig.milestoneNotesField: notes,
      FireStoreConfig.milestoneUpdatedField: isUpdated,
      FireStoreConfig.milestoneReceivedAmountField: receivedAmount,
      FireStoreConfig.milestoneUpdatedByUserIdField: updatedByUserId,
      FireStoreConfig.milestoneUpdatedByUserNameField: updatedByUserName,
      FireStoreConfig.createdAtField: createdAt,
      FireStoreConfig.updatedAtField: updatedAt,
      FireStoreConfig.milestoneInvoicedField: isInvoiced,
      FireStoreConfig.milestoneInvoicedUpdatedAtField: invoicedUpdatedAt,
    };
  }
}
