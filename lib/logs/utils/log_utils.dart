import 'package:cloud_firestore/cloud_firestore.dart';

import '../../add_project/model/project_info.dart';
import '../../config/firestore_config.dart';
import '../../enums/logs_enum.dart';
import '../model/log_info.dart';

class LogUtils {
  static String generateLogId() {
    return FirebaseFirestore.instance
        .collection(FireStoreConfig.logsCollections)
        .doc()
        .id;
  }

  static DocumentReference createLogDocReference(String logId) {
    return FirebaseFirestore.instance
        .collection(FireStoreConfig.logsCollections)
        .doc(logId);
  }

  static bool isMinDataAvailableToSaveLogs({
    double? oldAmount,
    double? newAmount,
    int? oldDate,
    int? newDate,
    double? transaction,
    String? notes,
  }) {
    return oldAmount != newAmount ||
        oldDate != newDate ||
        transaction != null ||
        (notes != null && notes.isNotEmpty);
  }

  static Map<String, dynamic> generateLogInfoData({
    required ProjectInfo projectInfo,
    required String? milestoneId,
    required String logId,
    required LogsEnum logsOn,
    required double? oldAmount,
    required double? newAmount,
    required int? oldDate,
    required int? newDate,
    required double? transaction,
    required String? notes,
    required String? currentUserId,
    required String? currentUserName,
    bool? invoiced,
  }) {
    return LogInfo(
      logId: logId,
      projectId: projectInfo.projectId,
      projectMilestoneId: projectInfo.milestoneId,
      milestoneInfoId: milestoneId,
      on: logsOn.name,
      oldAmount: oldAmount,
      newAmount: newAmount,
      oldDate: oldDate,
      newDate: newDate,
      transaction: transaction,
      invoiced: invoiced,
      notes: notes,
      generatedByUserId: currentUserId,
      generatedByUserName: currentUserName,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ).toMap();
  }
}
