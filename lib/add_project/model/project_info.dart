import 'package:cloud_firestore/cloud_firestore.dart';

import '../../config/firestore_config.dart';

class ProjectInfo {
  String? projectId;
  String? projectCode;
  int? projectCodeInt;
  String? projectName;
  String? bdmUserId;
  String? pmUserId;
  String? projectStatus;
  String? projectType;
  String? currency;
  String? country;
  double? totalFixedAmount;
  double? receivedAmount;
  String? createdBy;
  String? createdByName;
  List<String>? projectAvailableFor;
  String? specialNotes;
  int? paymentCycle;
  int? projectStartDate;
  double? hourlyRate;
  double? weeklyHours;
  double? totalHours;
  double? monthlyAmount;
  String? milestoneId;
  int? createdAt;
  int? updatedAt;
  int? remainingDays;
  int? exceededDays;

  ProjectInfo({
    this.projectId,
    this.projectCode,
    this.projectCodeInt,
    this.projectName,
    this.bdmUserId,
    this.pmUserId,
    this.projectStatus,
    this.projectType,
    this.currency,
    this.country,
    this.totalFixedAmount,
    this.receivedAmount,
    this.createdBy,
    this.projectAvailableFor,
    this.createdByName,
    this.specialNotes,
    this.paymentCycle,
    this.projectStartDate,
    this.hourlyRate,
    this.weeklyHours,
    this.totalHours,
    this.monthlyAmount,
    this.milestoneId,
    this.createdAt,
    this.updatedAt,
  });

  factory ProjectInfo.fromSnapshot(DocumentSnapshot document) {
    final data = document.data();
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception();
    }
    final List<String> availableFor = [];
    final projectAvailableForField =
        data[FireStoreConfig.projectAvailableForField];
    if (projectAvailableForField is List<dynamic>) {
      for (int i = 0; i < projectAvailableForField.length; i++) {
        final projectAvailableForId = projectAvailableForField[i];
        if (projectAvailableForId is String &&
            !availableFor.contains(projectAvailableForId)) {
          availableFor.add(projectAvailableForField[i]);
        }
      }
    }
    return ProjectInfo(
      projectId: data[FireStoreConfig.projectIdField],
      projectCode: data[FireStoreConfig.projectCodeField],
      projectCodeInt: data[FireStoreConfig.projectCodeIntField],
      projectName: data[FireStoreConfig.projectNameField],
      bdmUserId: data[FireStoreConfig.bdmUserIdField],
      pmUserId: data[FireStoreConfig.pmUserIdField],
      projectStatus: data[FireStoreConfig.projectStatusField],
      projectType: data[FireStoreConfig.projectTypeField],
      currency: data[FireStoreConfig.currencyField],
      country: data[FireStoreConfig.countryField],
      totalFixedAmount: data[FireStoreConfig.totalFixedAmountField],
      receivedAmount: data[FireStoreConfig.receivedAmountField],
      createdBy: data[FireStoreConfig.createdByField],
      createdByName: data[FireStoreConfig.createdByNameField],
      specialNotes: data[FireStoreConfig.specialNotesField],
      paymentCycle: data[FireStoreConfig.paymentCycleField],
      projectStartDate: data[FireStoreConfig.projectStartDateField],
      hourlyRate: data[FireStoreConfig.hourlyRateField],
      weeklyHours: data[FireStoreConfig.weeklyHoursField],
      totalHours: data[FireStoreConfig.totalHoursField],
      monthlyAmount: data[FireStoreConfig.monthlyAmountField],
      milestoneId: data[FireStoreConfig.projectMilestoneIdField],
      projectAvailableFor: availableFor,
      createdAt: data[FireStoreConfig.createdAtField],
      updatedAt: data[FireStoreConfig.updatedAtField],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FireStoreConfig.projectIdField: projectId,
      FireStoreConfig.projectCodeField: projectCode,
      FireStoreConfig.projectCodeIntField: projectCodeInt,
      FireStoreConfig.projectNameField: projectName,
      FireStoreConfig.bdmUserIdField: bdmUserId,
      FireStoreConfig.pmUserIdField: pmUserId,
      FireStoreConfig.projectStatusField: projectStatus,
      FireStoreConfig.projectTypeField: projectType,
      FireStoreConfig.currencyField: currency,
      FireStoreConfig.countryField: country,
      FireStoreConfig.totalFixedAmountField: totalFixedAmount,
      FireStoreConfig.receivedAmountField: receivedAmount,
      FireStoreConfig.createdByField: createdBy,
      FireStoreConfig.createdByNameField: createdByName,
      FireStoreConfig.specialNotesField: specialNotes,
      FireStoreConfig.paymentCycleField: paymentCycle,
      FireStoreConfig.projectStartDateField: projectStartDate,
      FireStoreConfig.hourlyRateField: hourlyRate,
      FireStoreConfig.weeklyHoursField: weeklyHours,
      FireStoreConfig.totalHoursField: totalHours,
      FireStoreConfig.monthlyAmountField: monthlyAmount,
      FireStoreConfig.projectMilestoneIdField: milestoneId,
      FireStoreConfig.projectAvailableForField: projectAvailableFor,
      FireStoreConfig.createdAtField: createdAt,
      FireStoreConfig.updatedAtField: updatedAt,
    };
  }
}
