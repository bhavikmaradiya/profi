import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import '../../config/firestore_config.dart';
import '../../config/preference_config.dart';
import '../../enums/logs_enum.dart';
import '../../enums/transaction_type_enum.dart';
import '../../inward_transactions/model/transaction_info.dart';
import '../../logs/model/log_helper.dart';
import '../../logs/utils/log_utils.dart';
import '../../project_list/utils/milestone_utils.dart';
import '../model/milestone_info.dart';
import '../model/project_info.dart';

part 'firebase_add_project_event.dart';

part 'firebase_add_project_state.dart';

class FirebaseAddProjectBloc
    extends Bloc<FirebaseAddProjectEvent, FirebaseAddProjectState> {
  final _fireStoreInstance = FirebaseFirestore.instance;
  late String? _currentUserId;
  late String? _currentUserName;

  FirebaseAddProjectBloc() : super(FirebaseAddProjectInitialState()) {
    on<FirebaseAddProjectInitEvent>(_initFirebaseAddProject);
    on<FirebaseAddProjectSaveEvent>(_onFirebaseAddProjectSaveEvent);
    on<FirebaseEditProjectSaveEvent>(_onFirebaseEditProjectSaveEvent);
    add(FirebaseAddProjectInitEvent());
  }

  _initFirebaseAddProject(
    FirebaseAddProjectInitEvent event,
    Emitter<FirebaseAddProjectState> emit,
  ) async {
    await _getUserInfo();
  }

  _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString(PreferenceConfig.userIdPref);
    _currentUserName = prefs.getString(PreferenceConfig.userNamePref);
  }

  String _generateProjectId() {
    return _fireStoreInstance
        .collection(FireStoreConfig.projectCollection)
        .doc()
        .id;
  }

  String _generateMilestoneId() {
    return _fireStoreInstance
        .collection(FireStoreConfig.milestonesCollection)
        .doc()
        .id;
  }

  _onFirebaseAddProjectSaveEvent(
    FirebaseAddProjectSaveEvent event,
    Emitter<FirebaseAddProjectState> emit,
  ) async {
    final projectInfo = event.projectInfo;
    if (projectInfo != null) {
      final isProjectCodeAvailable = await _checkProjectCodeIsAvailable(
        projectInfo.projectCodeInt,
      );
      if (isProjectCodeAvailable) {
        emit(ProjectCodeAlreadyTakenState());
        return;
      }
      projectInfo.projectId = _generateProjectId();
      projectInfo.milestoneId = _generateMilestoneId();
      projectInfo.createdByName = _currentUserName;
      projectInfo.createdBy = _currentUserId;

      final List<String> availableForList = [];
      if (projectInfo.bdmUserId != null) {
        availableForList.add(projectInfo.bdmUserId!);
      }
      if (projectInfo.pmUserId != null) {
        availableForList.add(projectInfo.pmUserId!);
      }
      if (AppConfig.isProjectCreatedByUserAllowToSeeProject &&
          _currentUserId != null) {
        availableForList.add(_currentUserId!);
      }
      projectInfo.projectAvailableFor = availableForList;

      final milestones = event.milestoneInfo;
      await _uploadProjectWithMilestonesToFirebase(
        projectInfo: projectInfo,
        milestoneList: milestones,
      );
      emit(FirebaseAddEditProjectSuccessState(true));
    }
  }

  Future<bool> _checkProjectCodeIsAvailable(int? projectCodeInt) async {
    if (projectCodeInt == null) {
      return true;
    }
    final snapshot = await _fireStoreInstance
        .collection(FireStoreConfig.projectCollection)
        .where(
          FireStoreConfig.projectCodeIntField,
          isEqualTo: projectCodeInt,
        )
        .count()
        .get();
    return snapshot.count > 0;
  }

  _uploadProjectWithMilestonesToFirebase({
    required ProjectInfo projectInfo,
    required List<MilestoneInfo>? milestoneList,
  }) async {
    final batch = _fireStoreInstance.batch();

    final prefs = await SharedPreferences.getInstance();

    // project info:
    final projectDocRef = _fireStoreInstance
        .collection(FireStoreConfig.projectCollection)
        .doc(projectInfo.projectId);
    batch.set(projectDocRef, projectInfo.toMap());

    // creating new transaction on project create
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final transactionInfo = TransactionInfo(
      transactionId: _generateTransactionId(),
      projectId: projectInfo.projectId,
      projectName: projectInfo.projectName,
      projectCode: projectInfo.projectCode,
      projectType: projectInfo.projectType,
      transactionType: TransactionTypeEnum.projectCreated.name,
      transactionDate: timestamp,
      transactionByUserId: prefs.getString(
        PreferenceConfig.userIdPref,
      ),
      transactionByName: prefs.getString(
        PreferenceConfig.userNamePref,
      ),
      transactionAvailableFor: projectInfo.projectAvailableFor,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
    final transactionDocRef = _createTransactionDocReference(transactionInfo);
    batch.set(transactionDocRef, transactionInfo.toMap());

    // milestone info:
    if (milestoneList != null && milestoneList.isNotEmpty) {
      for (int i = 0; i < milestoneList.length; i++) {
        final milestone = milestoneList[i];
        if (MilestoneUtils.isValidMilestone(milestone)) {
          final docRef = _fireStoreInstance
              .collection(FireStoreConfig.milestonesCollection)
              .doc(projectInfo.milestoneId)
              .collection(FireStoreConfig.milestoneInfoCollection)
              .doc();
          final milestoneItemId = docRef.id;
          milestone.milestoneId = milestoneItemId;
          milestone.projectId = projectInfo.projectId;
          milestone.milestoneCollectionId = projectInfo.milestoneId;
          milestone.paymentStatus = MilestoneUtils.getMilestonePaymentStatus(
            projectInfo,
            milestone,
          ).name;
          milestone.updatedByUserId = _currentUserId;
          milestone.updatedByUserName = _currentUserName;
          batch.set(docRef, milestone.toMap());
          final currentTimestamp = DateTime.now().millisecondsSinceEpoch;

          final transactionInfo = TransactionInfo(
            transactionId: _generateTransactionId(),
            projectId: projectInfo.projectId,
            projectName: projectInfo.projectName,
            projectCode: projectInfo.projectCode,
            projectType: projectInfo.projectType,
            milestoneId: milestone.milestoneId,
            milestoneAmount: milestone.milestoneAmount,
            milestoneDate: milestone.dateTime?.millisecondsSinceEpoch,
            transactionType: TransactionTypeEnum.created.name,
            transactionDate: currentTimestamp,
            transactionByUserId: prefs.getString(
              PreferenceConfig.userIdPref,
            ),
            transactionByName: prefs.getString(
              PreferenceConfig.userNamePref,
            ),
            transactionAvailableFor: projectInfo.projectAvailableFor,
            createdAt: currentTimestamp,
            updatedAt: currentTimestamp,
          );

          final transactionDocRef =
              _createTransactionDocReference(transactionInfo);
          batch.set(transactionDocRef, transactionInfo.toMap());

          // create logs on milestone create
          final logId = LogUtils.generateLogId();
          final logDocRef = LogUtils.createLogDocReference(logId);
          final logsData = _generateMilestoneLogData(
            logId: logId,
            projectInfo: projectInfo,
            milestone: milestone,
          );
          batch.set(logDocRef, logsData);
        }
      }
    }
    await batch.commit();
  }

  Map<String, dynamic> _generateMilestoneLogData({
    required String logId,
    required ProjectInfo projectInfo,
    required MilestoneInfo milestone,
  }) {
    return LogUtils.generateLogInfoData(
      projectInfo: projectInfo,
      milestoneId: milestone.milestoneId,
      logId: logId,
      logsOn: LogsEnum.onCreate,
      oldAmount: null,
      newAmount: milestone.milestoneAmount,
      oldDate: null,
      newDate: milestone.dateTime?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
      notes: milestone.notes,
      transaction: null,
      currentUserId: _currentUserId,
      currentUserName: _currentUserName,
    );
  }

  Future<bool> _checkProjectCodeIsValidForEdit(
    String? projectId,
    int? projectCodeInt,
  ) async {
    if (projectCodeInt == null || projectId == null) {
      return true;
    }
    final snapshot = await _fireStoreInstance
        .collection(FireStoreConfig.projectCollection)
        .where(FireStoreConfig.projectCodeIntField, isEqualTo: projectCodeInt)
        .where(FireStoreConfig.projectIdField, isNotEqualTo: projectId.trim())
        .count()
        .get();
    return snapshot.count > 0;
  }

  _onFirebaseEditProjectSaveEvent(
    FirebaseEditProjectSaveEvent event,
    Emitter<FirebaseAddProjectState> emit,
  ) async {
    final projectInfo = event.projectInfo;

    final isProjectCodeAvailable = await _checkProjectCodeIsValidForEdit(
      projectInfo?.projectId,
      projectInfo?.projectCodeInt,
    );
    if (isProjectCodeAvailable) {
      emit(ProjectCodeAlreadyTakenState());
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    final updatedMilestoneList = event.updatedMilestones;
    final originalMilestoneList = event.originalMilestones;
    final removedMilestoneList = originalMilestoneList!
        .where((item1) => !updatedMilestoneList!.any((item2) =>
            (item1.milestoneId != null &&
                item2.milestoneId != null &&
                item1.milestoneId == item2.milestoneId)))
        .toList();

    WriteBatch batch = _fireStoreInstance.batch();

    // project info:
    final List<String> availableForList = [];
    if (projectInfo?.bdmUserId != null) {
      availableForList.add(projectInfo!.bdmUserId!);
    }
    if (projectInfo?.pmUserId != null) {
      availableForList.add(projectInfo!.pmUserId!);
    }
    if (AppConfig.isProjectCreatedByUserAllowToSeeProject &&
        _currentUserId != null) {
      availableForList.add(_currentUserId!);
    }
    projectInfo?.projectAvailableFor = availableForList;
    projectInfo?.updatedAt = currentTimestamp;

    final projectDocRef = _fireStoreInstance
        .collection(FireStoreConfig.projectCollection)
        .doc(projectInfo!.projectId!);
    batch.update(projectDocRef, projectInfo.toMap());

    // milestone info:
    if (updatedMilestoneList != null && updatedMilestoneList.isNotEmpty) {
      for (int i = 0; i < updatedMilestoneList.length; i++) {
        final milestone = updatedMilestoneList[i];
        if (MilestoneUtils.isValidMilestone(milestone)) {
          milestone.updatedAt = currentTimestamp;
          milestone.paymentStatus = MilestoneUtils.getMilestonePaymentStatus(
            projectInfo,
            milestone,
          ).name;
          DocumentReference docRef;
          if (milestone.milestoneId != null) {
            docRef = _fireStoreInstance
                .collection(FireStoreConfig.milestonesCollection)
                .doc(projectInfo.milestoneId)
                .collection(FireStoreConfig.milestoneInfoCollection)
                .doc(milestone.milestoneId);

            final oldMilestone = originalMilestoneList.firstWhereOrNull(
              (element) => element.milestoneId == milestone.milestoneId,
            );

            if (oldMilestone != null) {
              final logs = _generateMilestoneLog(
                projectInfo,
                milestone,
                oldMilestone,
              );
              if (logs.isNotEmpty) {
                final newAmount = milestone.milestoneAmount;
                final oldAmount = oldMilestone.milestoneAmount;
                final newDate = milestone.dateTime?.millisecondsSinceEpoch;
                final oldDate = oldMilestone.dateTime?.millisecondsSinceEpoch;
                final isUpdated =
                    (oldDate != newDate || oldAmount != newAmount);

                milestone.isUpdated = milestone.isUpdated != true
                    ? isUpdated
                    : milestone.isUpdated;
                milestone.updatedByUserId = _currentUserId;
                milestone.updatedByUserName = _currentUserName;
                milestone.lastMilestoneDate =
                    isUpdated ? oldDate : milestone.lastMilestoneDate;
                milestone.lastMilestoneAmount =
                    isUpdated ? oldAmount : milestone.lastMilestoneAmount;

                for (var element in logs) {
                  batch.set(
                    element.documentReference,
                    element.map,
                  );
                }

                if (oldDate != newDate || oldAmount != newAmount) {
                  final timestamp = DateTime.now().millisecondsSinceEpoch;
                  final transactionInfo = TransactionInfo(
                    transactionId: _generateTransactionId(),
                    projectId: projectInfo.projectId,
                    projectName: projectInfo.projectName,
                    projectCode: projectInfo.projectCode,
                    projectType: projectInfo.projectType,
                    milestoneId: milestone.milestoneId,
                    milestoneAmount: newAmount,
                    lastMilestoneAmount: oldAmount,
                    lastMilestoneDate: oldDate,
                    milestoneDate: newDate,
                    transactionType: TransactionTypeEnum.edited.name,
                    transactionDate: timestamp,
                    transactionByUserId: prefs.getString(
                      PreferenceConfig.userIdPref,
                    ),
                    transactionByName: prefs.getString(
                      PreferenceConfig.userNamePref,
                    ),
                    transactionAvailableFor: availableForList,
                    createdAt: timestamp,
                    updatedAt: timestamp,
                  );

                  final transactionDocRef =
                      _createTransactionDocReference(transactionInfo);
                  batch.set(transactionDocRef, transactionInfo.toMap());
                }
              }
            }
            batch.update(docRef, milestone.toMap());
          } else {
            docRef = _fireStoreInstance
                .collection(FireStoreConfig.milestonesCollection)
                .doc(projectInfo.milestoneId)
                .collection(FireStoreConfig.milestoneInfoCollection)
                .doc();
            final milestoneItemId = docRef.id;
            milestone.milestoneId = milestoneItemId;
            milestone.projectId = projectInfo.projectId;
            milestone.milestoneCollectionId = projectInfo.milestoneId;
            milestone.updatedByUserId = _currentUserId;
            milestone.updatedByUserName = _currentUserName;

            // create logs on milestone create
            final logId = LogUtils.generateLogId();
            final logDocRef = LogUtils.createLogDocReference(logId);
            final logsData = _generateMilestoneLogData(
              logId: logId,
              projectInfo: projectInfo,
              milestone: milestone,
            );
            batch.set(logDocRef, logsData);

            batch.set(docRef, milestone.toMap());

            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final transactionInfo = TransactionInfo(
              transactionId: _generateTransactionId(),
              projectId: projectInfo.projectId,
              projectName: projectInfo.projectName,
              projectCode: projectInfo.projectCode,
              projectType: projectInfo.projectType,
              milestoneId: milestone.milestoneId,
              milestoneAmount: milestone.milestoneAmount,
              milestoneDate: milestone.dateTime?.millisecondsSinceEpoch,
              transactionType: TransactionTypeEnum.created.name,
              transactionDate: timestamp,
              transactionByUserId: prefs.getString(
                PreferenceConfig.userIdPref,
              ),
              transactionByName: prefs.getString(
                PreferenceConfig.userNamePref,
              ),
              transactionAvailableFor: availableForList,
              createdAt: timestamp,
              updatedAt: timestamp,
            );
            final transactionDocRef =
                _createTransactionDocReference(transactionInfo);
            batch.set(transactionDocRef, transactionInfo.toMap());
          }
        }
      }
    }

    // removed milestones
    if (removedMilestoneList.isNotEmpty) {
      double toDeductAmount = 0;
      for (int i = 0; i < removedMilestoneList.length; i++) {
        final docRef = _fireStoreInstance
            .collection(FireStoreConfig.milestonesCollection)
            .doc(projectInfo.milestoneId)
            .collection(FireStoreConfig.milestoneInfoCollection)
            .doc(removedMilestoneList[i].milestoneId);
        batch.delete(docRef);

        final receivedAmount = removedMilestoneList[i].receivedAmount;
        if (receivedAmount != null) {
          toDeductAmount += receivedAmount;
        }
      }

      if (toDeductAmount > 0) {
        // update project received amount
        final projectData = <String, dynamic>{};
        projectData[FireStoreConfig.updatedAtField] =
            DateTime.now().millisecondsSinceEpoch;
        final updatedReceivedAmount =
            (projectInfo.receivedAmount ?? 0) - toDeductAmount;
        projectData[FireStoreConfig.receivedAmountField] =
            (updatedReceivedAmount > 0) ? updatedReceivedAmount : 0.0;
        batch.update(projectDocRef, projectData);
      }
    }

    await batch.commit();
    await _deleteTransactionOnMilestoneDelete(
      projectInfo,
      removedMilestoneList,
    );
    await _updateTransactionAvailableFor(
      projectInfo,
      currentTimestamp,
    );
    emit(FirebaseAddEditProjectSuccessState(false));
  }

  String _generateTransactionId() {
    return _fireStoreInstance
        .collection(FireStoreConfig.transactionsCollection)
        .doc()
        .id;
  }

  DocumentReference _createTransactionDocReference(
    TransactionInfo transactionInfo,
  ) {
    return _fireStoreInstance
        .collection(FireStoreConfig.transactionsCollection)
        .doc(transactionInfo.transactionId);
  }

  _updateTransactionAvailableFor(
    ProjectInfo? projectInfo,
    int timeStamp,
  ) async {
    if (projectInfo != null) {
      final querySnapshot = await _fireStoreInstance
          .collection(FireStoreConfig.transactionsCollection)
          .where(
            FireStoreConfig.transactionProjectIdField,
            isEqualTo: projectInfo.projectId,
          )
          .get();
      final documents = querySnapshot.docs;
      if (documents.isNotEmpty) {
        final batch = _fireStoreInstance.batch();
        for (int i = 0; i < documents.length; i++) {
          final document = documents[i];
          final docRef = _fireStoreInstance
              .collection(FireStoreConfig.transactionsCollection)
              .doc(document.id);
          final Map<String, dynamic> data = {};
          data[FireStoreConfig.transactionAvailableForField] =
              projectInfo.projectAvailableFor;
          data[FireStoreConfig.updatedAtField] = timeStamp;
          batch.update(docRef, data);
        }
        await batch.commit();
      }
    }
  }

  _deleteTransactionOnMilestoneDelete(
    ProjectInfo? projectInfo,
    List<MilestoneInfo> milestones,
  ) async {
    final batch = _fireStoreInstance.batch();
    final prefs = await SharedPreferences.getInstance();
    final List<String> transactionsToDelete = [];
    for (int k = 0; k < milestones.length; k++) {
      final milestone = milestones[k];
      if (milestone.milestoneId != null) {
        final querySnapshot = await _fireStoreInstance
            .collection(FireStoreConfig.transactionsCollection)
            .where(
              FireStoreConfig.transactionMilestoneIdField,
              isEqualTo: milestone.milestoneId,
            )
            .where(
          FireStoreConfig.transactionTypeField,
          whereNotIn: [
            TransactionTypeEnum.created.name,
            TransactionTypeEnum.edited.name,
            TransactionTypeEnum.deleted.name,
          ],
        ).get();
        final documents = querySnapshot.docs;
        if (documents.isNotEmpty) {
          for (int i = 0; i < documents.length; i++) {
            transactionsToDelete.add(documents[i].id);
          }
        }

        // creating new transaction with isDeleted: true
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final transactionInfo = TransactionInfo(
          transactionId: _generateTransactionId(),
          projectId: projectInfo?.projectId,
          projectName: projectInfo?.projectName,
          projectCode: projectInfo?.projectCode,
          projectType: projectInfo?.projectType,
          milestoneId: milestone.milestoneId,
          milestoneAmount: milestone.milestoneAmount,
          milestoneDate: milestone.dateTime?.millisecondsSinceEpoch,
          transactionType: TransactionTypeEnum.deleted.name,
          transactionDate: timestamp,
          transactionByUserId: prefs.getString(
            PreferenceConfig.userIdPref,
          ),
          transactionByName: prefs.getString(
            PreferenceConfig.userNamePref,
          ),
          transactionAvailableFor: projectInfo?.projectAvailableFor,
          createdAt: timestamp,
          updatedAt: timestamp,
        );
        final transactionDocRef =
            _createTransactionDocReference(transactionInfo);
        batch.set(transactionDocRef, transactionInfo.toMap());
      }
    }

    if (transactionsToDelete.isNotEmpty) {
      for (int j = 0; j < transactionsToDelete.length; j++) {
        final ref = _fireStoreInstance
            .collection(FireStoreConfig.transactionsCollection)
            .doc(transactionsToDelete[j]);
        batch.delete(ref);
      }
      await batch.commit();
    }
  }

  List<LogHelper> _generateMilestoneLog(
    ProjectInfo projectInfo,
    MilestoneInfo currentMilestone,
    MilestoneInfo oldMilestone,
  ) {
    final List<LogHelper> list = [];

    final newMilestoneAmount = currentMilestone.milestoneAmount;
    final oldMilestoneAmount = oldMilestone.milestoneAmount;
    final newMilestoneDate = currentMilestone.dateTime?.millisecondsSinceEpoch;
    final oldMilestoneDate = oldMilestone.dateTime?.millisecondsSinceEpoch;
    final notes = currentMilestone.notes;

    final isMinDataAvailableToSaveLogs = LogUtils.isMinDataAvailableToSaveLogs(
      oldAmount: oldMilestoneAmount,
      newAmount: newMilestoneAmount,
      oldDate: oldMilestoneDate,
      newDate: newMilestoneDate,
      notes: notes,
    );
    if (isMinDataAvailableToSaveLogs) {
      final logId = LogUtils.generateLogId();
      final logDocRef = LogUtils.createLogDocReference(logId);

      final logsData = LogUtils.generateLogInfoData(
        projectInfo: projectInfo,
        milestoneId: currentMilestone.milestoneId,
        logId: logId,
        logsOn: LogsEnum.onInfo,
        oldAmount: newMilestoneAmount != oldMilestoneAmount
            ? oldMilestoneAmount
            : null,
        newAmount: newMilestoneAmount != oldMilestoneAmount
            ? newMilestoneAmount
            : null,
        oldDate: newMilestoneDate != oldMilestoneDate ? oldMilestoneDate : null,
        newDate: newMilestoneDate != oldMilestoneDate ? newMilestoneDate : null,
        notes: notes,
        transaction: null,
        currentUserId: _currentUserId,
        currentUserName: _currentUserName,
      );

      list.add(LogHelper(logDocRef, logsData));
    }

    return list;
  }
}
