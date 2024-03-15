import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';

import './model/auto_update_info.dart';
import '../../add_project/model/milestone_info.dart';
import '../../add_project/model/project_info.dart';
import '../../config/firestore_config.dart';
import '../../enums/payment_status_enum.dart';
import '../../firebase_options.dart';
import '../../utils/app_utils.dart';
import '../utils/milestone_utils.dart';

class AutoUpdateProjectStatus {
  _fetchDateExceedMilestones(AutoUpdateInfo autoUpdateInfo) async {
    final dateTime =
        DateTime.fromMillisecondsSinceEpoch(autoUpdateInfo.timestamp);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final exceededMilestones = autoUpdateInfo.milestones.where(
      (element) =>
          (element.paymentStatus == PaymentStatusEnum.upcoming.name ||
              element.paymentStatus == PaymentStatusEnum.aboutToExceed.name) &&
          element.dateTime != null &&
          AppUtils.dateDifferenceInDays(
                DateTime(
                  element.dateTime!.year,
                  element.dateTime!.month,
                  element.dateTime!.day,
                ).millisecondsSinceEpoch,
                dateOnly.millisecondsSinceEpoch,
              ) >
              0,
    );
    if (exceededMilestones.isNotEmpty) {
      final firestoreInstance = FirebaseFirestore.instance;
      final batch = firestoreInstance.batch();
      bool shouldUpdate = false;
      for (var milestone in exceededMilestones) {
        final projectInfo = autoUpdateInfo.projects.firstWhereOrNull(
          (element) => element.projectId == milestone.projectId,
        );
        if (projectInfo != null) {
          final docRef = firestoreInstance
              .collection(FireStoreConfig.milestonesCollection)
              .doc(milestone.milestoneCollectionId)
              .collection(FireStoreConfig.milestoneInfoCollection)
              .doc(milestone.milestoneId);
          final updatedPaymentStatus = MilestoneUtils.getMilestonePaymentStatus(
            projectInfo,
            milestone,
          ).name;
          if (milestone.paymentStatus != updatedPaymentStatus) {
            final Map<String, dynamic> milestoneData = {};
            milestoneData[FireStoreConfig.updatedAtField] =
                DateTime.now().millisecondsSinceEpoch;
            milestoneData[FireStoreConfig.lastMilestoneAmount] =
                milestone.milestoneAmount;
            milestoneData[FireStoreConfig.lastMilestoneDate] =
                milestone.dateTime?.millisecondsSinceEpoch;
            milestoneData[FireStoreConfig.milestonePaymentStatusField] =
                updatedPaymentStatus;
            batch.update(docRef, milestoneData);
            if (!shouldUpdate) {
              shouldUpdate = true;
            }
          }
        }
      }
      if (shouldUpdate) {
        await batch.commit();
      }
    }
  }

  doProcessForAutoUpdateProjectStatus(
    int currentDateTimestamp,
    List<MilestoneInfo> milestones,
    List<ProjectInfo> projects,
  ) {
    final rootToken = RootIsolateToken.instance!;
    final autoUpdateInfo = AutoUpdateInfo(
      token: rootToken,
      firebaseOptions: DefaultFirebaseOptions.currentPlatform,
      timestamp: currentDateTimestamp,
      milestones: milestones,
      projects: projects,
    );
    _fetchDateExceedMilestones(autoUpdateInfo);
  }
}
