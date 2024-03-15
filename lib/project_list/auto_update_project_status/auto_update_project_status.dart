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
          element.paymentStatus == PaymentStatusEnum.upcoming.name &&
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
          final Map<String, dynamic> milestoneData = {};
          milestoneData[FireStoreConfig.updatedAtField] =
              DateTime.now().millisecondsSinceEpoch;
          milestoneData[FireStoreConfig.milestonePaymentStatusField] =
              MilestoneUtils.getMilestonePaymentStatus(
            projectInfo,
            milestone,
          ).name;
          batch.update(docRef, milestoneData);
        }
      }
      await batch.commit();
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
