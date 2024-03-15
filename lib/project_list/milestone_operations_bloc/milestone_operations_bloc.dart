import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../add_project/model/milestone_info.dart';
import '../../add_project/model/project_info.dart';
import '../../config/app_config.dart';
import '../../config/firestore_config.dart';
import '../../config/preference_config.dart';
import '../../dialog/model/multiple_milestone_info.dart';
import '../../enums/currency_enum.dart';
import '../../enums/logs_enum.dart';
import '../../enums/payment_status_enum.dart';
import '../../inward_transactions/model/transaction_info.dart';
import '../../logs/utils/log_utils.dart';
import '../utils/milestone_utils.dart';

part 'milestone_operations_event.dart';

part 'milestone_operations_state.dart';

class MilestoneOperationsBloc
    extends Bloc<MilestoneOperationsEvent, MilestoneOperationsState> {
  final _fireStoreInstance = FirebaseFirestore.instance;
  late String? _currentUserId;
  late String? _currentUserName;
  int _currencyId = AppConfig.defaultCurrencyId;
  CurrencyEnum _currencyEnum = AppConfig.defaultCurrencyEnum;

  MilestoneOperationsBloc() : super(MilestoneOperationsInitialState()) {
    on<MilestoneOperationsInitEvent>(_onMilestoneOperationsInit);
    on<MilestoneMarkAsPaidEvent>(_onPaidTransaction);
    on<MilestoneUpdateEvent>(_onUpdateTransaction);
    on<MilestoneDeleteEvent>(_onDeleteTransaction);
    on<MilestoneMarkAsUnPaidEvent>(_onUnPaidTransaction);
    on<MilestoneCurrencyChangeEvent>(_onMilestoneCurrencyChange);
    on<MultipleMilestonesMarkAsPaidEvent>(_onPaidMultipleTransaction);
    on<MultipleMilestonesMarkAsUnPaidEvent>(_onUnPaidMultipleTransaction);
    on<MilestoneInvoicedChangeEvent>(_onMilestoneInvoicedChange);
    add(MilestoneOperationsInitEvent());
  }

  _onMilestoneOperationsInit(
    MilestoneOperationsInitEvent event,
    Emitter<MilestoneOperationsState> state,
  ) async {
    await _getUserInfo();
  }

  _onMilestoneInvoicedChange(
    MilestoneInvoicedChangeEvent event,
    Emitter<MilestoneOperationsState> emit,
  ) async {
    final isInvoiced = !(event.milestoneInfo.isInvoiced ?? false);
    await _updateMilestoneInvoicedStatus(
      event.projectInfo,
      event.milestoneInfo,
      isInvoiced,
    );
    emit(MilestoneInvoicedChangeState(isInvoiced));
  }

  _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString(PreferenceConfig.userIdPref);
    _currentUserName = prefs.getString(PreferenceConfig.userNamePref);
  }

  _updateMilestoneInvoicedStatus(
    ProjectInfo projectInfo,
    MilestoneInfo milestoneInfo,
    bool isInvoiced,
  ) async {
    final batch = _fireStoreInstance.batch();
    final updatedAt = DateTime.now().millisecondsSinceEpoch;
    final milestoneDoc = _fireStoreInstance
        .collection(FireStoreConfig.milestonesCollection)
        .doc(milestoneInfo.milestoneCollectionId)
        .collection(FireStoreConfig.milestoneInfoCollection)
        .doc(milestoneInfo.milestoneId);
    final milestoneData = {
      FireStoreConfig.milestoneInvoicedField: isInvoiced,
      FireStoreConfig.milestoneInvoicedUpdatedAtField: updatedAt,
      FireStoreConfig.updatedAtField: updatedAt,
    };
    batch.update(milestoneDoc, milestoneData);
    // create logs on milestone invoiced / canceled invoice
    final logId = LogUtils.generateLogId();
    final logDocRef = LogUtils.createLogDocReference(logId);
    final logsData = _generateInvoiceLogData(
      logId: logId,
      projectInfo: projectInfo,
      milestoneInfo: milestoneInfo,
      isInvoiced: isInvoiced,
    );
    batch.set(logDocRef, logsData);
    await batch.commit();
  }

  Map<String, dynamic> _generateInvoiceLogData({
    required String logId,
    required ProjectInfo projectInfo,
    required MilestoneInfo milestoneInfo,
    required bool isInvoiced,
  }) {
    return LogUtils.generateLogInfoData(
      projectInfo: projectInfo,
      milestoneId: milestoneInfo.milestoneId,
      logId: logId,
      logsOn: LogsEnum.onInvoiced,
      oldAmount: null,
      newAmount: null,
      oldDate: null,
      newDate: null,
      notes: null,
      transaction: null,
      invoiced: isInvoiced,
      currentUserId: _currentUserId,
      currentUserName: _currentUserName,
    );
  }

  _onPaidTransaction(
    MilestoneMarkAsPaidEvent event,
    Emitter<MilestoneOperationsState> emit,
  ) async {
    final projectInfo = event.projectInfo;
    final transactionInfo = event.transactionInfo;
    transactionInfo.transactionId = _generateTransactionId();
    final prefs = await SharedPreferences.getInstance();
    transactionInfo.transactionByUserId = prefs.getString(
      PreferenceConfig.userIdPref,
    );
    transactionInfo.transactionByName = prefs.getString(
      PreferenceConfig.userNamePref,
    );

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
    transactionInfo.transactionAvailableFor = availableForList;

    await _uploadPaidTransactionToFirebase(
      transactionInfo,
      projectInfo,
      event.milestoneInfo,
    );
    emit(MilestonePaidSuccessState());
  }

  String _generateTransactionId() {
    return _fireStoreInstance
        .collection(FireStoreConfig.transactionsCollection)
        .doc()
        .id;
  }

  _uploadPaidTransactionToFirebase(
    TransactionInfo transactionInfo,
    ProjectInfo projectInfo,
    MilestoneInfo milestoneInfo,
  ) async {
    final batch = _fireStoreInstance.batch();

    final transactionDocRef = _createTransactionDocReference(transactionInfo);
    batch.set(transactionDocRef, transactionInfo.toMap());

    final projectDocRef = _createProjectDocReference(projectInfo);
    final projectData = _createProjectData(projectInfo, transactionInfo);
    batch.update(projectDocRef, projectData);

    final milestoneDocRef = _createMilestoneDocReference(
      projectInfo.milestoneId,
      milestoneInfo.milestoneId,
    );
    final milestoneData = _createMilestoneData(milestoneInfo, transactionInfo);
    batch.update(milestoneDocRef, milestoneData);

    final isMinDataAvailableToSaveLogs = LogUtils.isMinDataAvailableToSaveLogs(
      transaction: transactionInfo.paidAmount,
      notes: transactionInfo.notes,
    );

    if (isMinDataAvailableToSaveLogs) {
      final logId = LogUtils.generateLogId();
      final logDocRef = LogUtils.createLogDocReference(logId);
      final logsData = _generatePaidLogsData(
        projectInfo: projectInfo,
        milestoneId: milestoneInfo.milestoneId,
        logId: logId,
        transactionInfo: transactionInfo,
      );
      batch.set(logDocRef, logsData);
    }
    await batch.commit();
  }

  DocumentReference _createTransactionDocReference(
    TransactionInfo transactionInfo,
  ) {
    return _fireStoreInstance
        .collection(FireStoreConfig.transactionsCollection)
        .doc(transactionInfo.transactionId);
  }

  DocumentReference _createProjectDocReference(ProjectInfo projectInfo) {
    return _fireStoreInstance
        .collection(FireStoreConfig.projectCollection)
        .doc(projectInfo.projectId);
  }

  Map<String, dynamic> _createProjectData(
    ProjectInfo projectInfo,
    TransactionInfo transactionInfo,
  ) {
    final projectData = <String, dynamic>{};
    projectData[FireStoreConfig.updatedAtField] =
        DateTime.now().millisecondsSinceEpoch;
    final totalReceivedAmount =
        (projectInfo.receivedAmount ?? 0) + (transactionInfo.paidAmount ?? 0);
    projectData[FireStoreConfig.receivedAmountField] = totalReceivedAmount;
    return projectData;
  }

  DocumentReference _createMilestoneDocReference(
    String? projectMilestoneId,
    String? milestoneId,
  ) {
    return _fireStoreInstance
        .collection(FireStoreConfig.milestonesCollection)
        .doc(projectMilestoneId)
        .collection(FireStoreConfig.milestoneInfoCollection)
        .doc(milestoneId);
  }

  Map<String, dynamic> _createMilestoneData(
    MilestoneInfo milestoneInfo,
    TransactionInfo transactionInfo,
  ) {
    final milestoneData = <String, dynamic>{};
    milestoneData[FireStoreConfig.updatedAtField] =
        DateTime.now().millisecondsSinceEpoch;
    milestoneData[FireStoreConfig.milestoneUpdatedByUserIdField] =
        _currentUserId;
    milestoneData[FireStoreConfig.milestoneUpdatedByUserNameField] =
        _currentUserName;
    final totalReceivedAmount =
        (milestoneInfo.receivedAmount ?? 0) + (transactionInfo.paidAmount ?? 0);
    milestoneData[FireStoreConfig.milestoneReceivedAmountField] =
        totalReceivedAmount;
    if ((milestoneInfo.milestoneAmount ?? 0) <= totalReceivedAmount) {
      milestoneData[FireStoreConfig.milestonePaymentStatusField] =
          PaymentStatusEnum.fullyPaid.name;
    } else {
      milestoneData[FireStoreConfig.milestonePaymentStatusField] =
          PaymentStatusEnum.partiallyPaid.name;
    }
    return milestoneData;
  }

  Map<String, dynamic> _generatePaidLogsData({
    required ProjectInfo projectInfo,
    required String? milestoneId,
    required String logId,
    required TransactionInfo transactionInfo,
  }) {
    return LogUtils.generateLogInfoData(
      projectInfo: projectInfo,
      milestoneId: milestoneId,
      logId: logId,
      logsOn: LogsEnum.onPaid,
      oldDate: null,
      newDate: null,
      oldAmount: null,
      newAmount: null,
      notes: transactionInfo.notes,
      transaction: transactionInfo.paidAmount,
      currentUserId: _currentUserId,
      currentUserName: _currentUserName,
    );
  }

  _onUpdateTransaction(
    MilestoneUpdateEvent event,
    Emitter<MilestoneOperationsState> emit,
  ) async {
    final batch = _fireStoreInstance.batch();

    final updatedMilestoneAmount = event.milestoneAmount;
    final updatedMilestoneDate = event.milestoneDate;
    final updatedMilestoneNotes = event.notes;
    final projectInfo = event.projectInfo;
    final milestoneInfo = event.milestoneInfo;

    if (milestoneInfo != null) {
      // update milestone info
      // set logs first as milestone info is changing based on
      // updated amounts and dates
      final oldAmount = milestoneInfo.milestoneAmount;
      final newAmount = updatedMilestoneAmount;
      final oldDate = milestoneInfo.dateTime?.millisecondsSinceEpoch;
      final newDate = event.milestoneDate;

      final isMinDataAvailableToSaveLogs =
          LogUtils.isMinDataAvailableToSaveLogs(
        oldAmount: oldAmount,
        newAmount: newAmount,
        oldDate: oldDate,
        newDate: newDate,
        notes: event.notes,
      );

      if (isMinDataAvailableToSaveLogs) {
        final logId = LogUtils.generateLogId();
        final logDocRef = LogUtils.createLogDocReference(logId);
        final logsData = LogUtils.generateLogInfoData(
          projectInfo: projectInfo,
          milestoneId: milestoneInfo.milestoneId,
          logId: logId,
          logsOn: LogsEnum.onInfo,
          oldAmount: oldAmount != newAmount ? oldAmount : null,
          newAmount: oldAmount != newAmount ? newAmount : null,
          oldDate: oldDate != newDate ? oldDate : null,
          newDate: oldDate != newDate ? newDate : null,
          transaction: null,
          notes: event.notes,
          currentUserId: _currentUserId,
          currentUserName: _currentUserName,
        );
        batch.set(logDocRef, logsData);
      }

      final updateDocumentRef = _createMilestoneDocReferenceToUpdate(
        projectInfo: projectInfo,
        milestoneInfo: milestoneInfo,
      );
      final milestoneData = _createMilestoneDataToUpdate(
        updatedMilestoneAmount: updatedMilestoneAmount,
        updatedMilestoneDate: updatedMilestoneDate,
        notes: updatedMilestoneNotes,
        projectInfo: projectInfo,
        milestoneInfo: milestoneInfo
          ..isUpdated = milestoneInfo.isUpdated != true
              ? (oldDate != newDate || oldAmount != newAmount)
              : milestoneInfo.isUpdated
          ..dateTime =
              DateTime.fromMillisecondsSinceEpoch(updatedMilestoneDate ?? 0)
          ..milestoneAmount = updatedMilestoneAmount,
      );
      batch.update(updateDocumentRef, milestoneData);

      await batch.commit();
    } else {
      // add new milestone info
      _addNewMilestone(
        projectInfo,
        event.milestoneAmount,
        event.milestoneDate,
        event.notes,
      );
    }
    emit(MilestoneUpdatedState(event.isNewMilestone ?? false));
  }

  _addNewMilestone(
    ProjectInfo projectInfo,
    double? milestoneAmount,
    int? milestoneDate,
    String? notes,
  ) async {
    final batch = _fireStoreInstance.batch();
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    // milestone info:
    final milestoneInfo = MilestoneInfo(
      id: 1,
      dateTime: (milestoneDate != null)
          ? DateTime.fromMillisecondsSinceEpoch(milestoneDate)
          : DateTime.now(),
      projectId: projectInfo.projectId,
      milestoneCollectionId: projectInfo.milestoneId,
      milestoneAmount: milestoneAmount,
      notes: notes,
      sequence: 0,
      createdAt: currentTimestamp,
      updatedAt: currentTimestamp,
    );
    if (MilestoneUtils.isValidMilestone(milestoneInfo)) {
      final docRef = _fireStoreInstance
          .collection(FireStoreConfig.milestonesCollection)
          .doc(projectInfo.milestoneId)
          .collection(FireStoreConfig.milestoneInfoCollection)
          .doc();
      final milestoneItemId = docRef.id;
      milestoneInfo.milestoneId = milestoneItemId;
      milestoneInfo.paymentStatus = MilestoneUtils.getMilestonePaymentStatus(
        projectInfo,
        milestoneInfo,
      ).name;
      milestoneInfo.updatedByUserId = _currentUserId;
      milestoneInfo.updatedByUserName = _currentUserName;
      batch.set(docRef, milestoneInfo.toMap());

      // create logs on milestone create
      final logId = LogUtils.generateLogId();
      final logDocRef = LogUtils.createLogDocReference(logId);
      final logsData = _generateMilestoneLogData(
        logId: logId,
        projectInfo: projectInfo,
        milestoneInfo: milestoneInfo,
      );
      batch.set(logDocRef, logsData);
    }
    await batch.commit();
  }

  Map<String, dynamic> _generateMilestoneLogData({
    required String logId,
    required ProjectInfo projectInfo,
    required MilestoneInfo milestoneInfo,
  }) {
    return LogUtils.generateLogInfoData(
      projectInfo: projectInfo,
      milestoneId: milestoneInfo.milestoneId,
      logId: logId,
      logsOn: LogsEnum.onCreate,
      oldAmount: null,
      newAmount: milestoneInfo.milestoneAmount,
      oldDate: null,
      newDate: milestoneInfo.dateTime?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
      notes: milestoneInfo.notes,
      transaction: null,
      currentUserId: _currentUserId,
      currentUserName: _currentUserName,
    );
  }

  DocumentReference _createMilestoneDocReferenceToUpdate({
    required ProjectInfo projectInfo,
    required MilestoneInfo milestoneInfo,
  }) {
    return _fireStoreInstance
        .collection(FireStoreConfig.milestonesCollection)
        .doc(projectInfo.milestoneId)
        .collection(FireStoreConfig.milestoneInfoCollection)
        .doc(milestoneInfo.milestoneId);
  }

  Map<String, dynamic> _createMilestoneDataToUpdate({
    required double? updatedMilestoneAmount,
    required int? updatedMilestoneDate,
    required String? notes,
    required ProjectInfo projectInfo,
    required MilestoneInfo milestoneInfo,
  }) {
    final data = <String, dynamic>{};
    data[FireStoreConfig.updatedAtField] =
        DateTime.now().millisecondsSinceEpoch;
    data[FireStoreConfig.milestoneDateField] = updatedMilestoneDate;
    data[FireStoreConfig.milestoneNotesField] = notes;
    data[FireStoreConfig.milestoneAmountField] = updatedMilestoneAmount;
    data[FireStoreConfig.milestoneUpdatedField] = milestoneInfo.isUpdated;
    data[FireStoreConfig.milestoneUpdatedByUserIdField] = _currentUserId;
    data[FireStoreConfig.milestoneUpdatedByUserNameField] = _currentUserName;
    data[FireStoreConfig.milestonePaymentStatusField] =
        MilestoneUtils.getMilestonePaymentStatus(
      projectInfo,
      milestoneInfo,
    ).name;
    return data;
  }

  _onDeleteTransaction(
    MilestoneDeleteEvent event,
    Emitter<MilestoneOperationsState> emit,
  ) async {
    final projectInfo = event.projectInfo;
    final milestoneId = event.milestoneId;
    final batch = _fireStoreInstance.batch();
    final milestoneDocRef = _createMilestoneDocRefForDelete(
      projectInfo.milestoneId,
      milestoneId,
    );
    batch.delete(milestoneDocRef);

    final projectDocRef = _createProjectDocRefForDelete(
      projectInfo.projectId,
    );
    final projectData = _createProjectDataForDelete(
      projectInfo,
      event.receivedMilestoneAmount,
    );
    batch.update(projectDocRef, projectData);
    await batch.commit();
    await _deleteTransactionOnMilestoneDelete(milestoneId);
    emit(MilestoneDeletedState());
  }

  DocumentReference _createMilestoneDocRefForDelete(
    String? projectMilestoneId,
    String? milestoneId,
  ) {
    return _fireStoreInstance
        .collection(FireStoreConfig.milestonesCollection)
        .doc(projectMilestoneId)
        .collection(FireStoreConfig.milestoneInfoCollection)
        .doc(milestoneId);
  }

  _deleteTransactionOnMilestoneDelete(String? milestoneId) async {
    if (milestoneId != null) {
      final querySnapshot = await _fireStoreInstance
          .collection(FireStoreConfig.transactionsCollection)
          .where(
            FireStoreConfig.transactionMilestoneIdField,
            isEqualTo: milestoneId,
          )
          .get();
      final documents = querySnapshot.docs;
      if (documents.isNotEmpty) {
        final batch = _fireStoreInstance.batch();
        for (int i = 0; i < documents.length; i++) {
          final ref = _fireStoreInstance
              .collection(FireStoreConfig.transactionsCollection)
              .doc(documents[i].id);
          batch.delete(ref);
        }
        await batch.commit();
      }
    }
  }

  DocumentReference _createProjectDocRefForDelete(String? projectId) {
    return _fireStoreInstance
        .collection(FireStoreConfig.projectCollection)
        .doc(projectId);
  }

  Map<String, dynamic> _createProjectDataForDelete(
    ProjectInfo projectInfo,
    double? amount,
  ) {
    final projectData = <String, dynamic>{};
    projectData[FireStoreConfig.updatedAtField] =
        DateTime.now().millisecondsSinceEpoch;
    final updatedReceivedAmount =
        (projectInfo.receivedAmount ?? 0) - (amount ?? 0);
    projectData[FireStoreConfig.receivedAmountField] =
        (updatedReceivedAmount > 0) ? updatedReceivedAmount : 0.0;
    return projectData;
  }

  _onUnPaidTransaction(
    MilestoneMarkAsUnPaidEvent event,
    Emitter<MilestoneOperationsState> emit,
  ) async {
    final milestoneAmount = event.milestoneAmount;
    final ProjectInfo projectInfo = event.projectInfo;
    final MilestoneInfo milestoneInfo = event.milestoneInfo;

    final batch = _fireStoreInstance.batch();

    /*
    // Not deleting old paid transactions
    final transactionSnapshot = await _queryToRetrieveTransactionDocsToUnPaid(
      projectInfo,
      milestoneInfo,
      milestoneAmount,
    );
    final transactionDocument = transactionSnapshot.docs;
    if (transactionDocument.isNotEmpty) {
      for (var document in transactionDocument) {
        batch.delete(document.reference);
      }
    }*/

    final projectDocRef = _createProjectUnPaidDocReference(projectInfo);
    final projectData = _createProjectUnPaidData(projectInfo, milestoneAmount);
    batch.update(projectDocRef, projectData);

    final milestoneDocRef = _createMilestoneUnPaidDocReference(
      projectInfo.milestoneId,
      milestoneInfo.milestoneId,
    );
    final milestoneData = _createMilestoneUnPaidData(
      projectInfo,
      milestoneInfo,
      milestoneAmount,
    );
    batch.update(milestoneDocRef, milestoneData);

    final transactionInfo = event.transactionInfo;
    transactionInfo.transactionId = _generateTransactionId();
    final prefs = await SharedPreferences.getInstance();
    transactionInfo.transactionByUserId = prefs.getString(
      PreferenceConfig.userIdPref,
    );
    transactionInfo.transactionByName = prefs.getString(
      PreferenceConfig.userNamePref,
    );

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
    transactionInfo.transactionAvailableFor = availableForList;

    final transactionDocRef = _createTransactionDocReference(transactionInfo);
    batch.set(transactionDocRef, transactionInfo.toMap());

    final isMinDataAvailableToSaveLogs = LogUtils.isMinDataAvailableToSaveLogs(
      transaction: transactionInfo.unPaidAmount,
      notes: transactionInfo.notes,
    );
    if (isMinDataAvailableToSaveLogs) {
      final logId = LogUtils.generateLogId();
      final logDocRef = LogUtils.createLogDocReference(logId);
      final logsData = _generateUnPaidLogsData(
        projectInfo: projectInfo,
        milestoneId: milestoneInfo.milestoneId,
        logId: logId,
        transactionInfo: transactionInfo,
      );
      batch.set(logDocRef, logsData);
    }

    await batch.commit();
    emit(MilestoneUnPaidSuccessState());
  }

  Map<String, dynamic> _generateUnPaidLogsData({
    required ProjectInfo projectInfo,
    required String? milestoneId,
    required String logId,
    required TransactionInfo transactionInfo,
  }) {
    return LogUtils.generateLogInfoData(
      projectInfo: projectInfo,
      milestoneId: milestoneId,
      logId: logId,
      logsOn: LogsEnum.onUnPaid,
      oldDate: null,
      newDate: null,
      oldAmount: null,
      newAmount: null,
      notes: transactionInfo.notes,
      transaction: transactionInfo.unPaidAmount,
      currentUserId: _currentUserId,
      currentUserName: _currentUserName,
    );
  }

/*Future<QuerySnapshot> _queryToRetrieveTransactionDocsToUnPaid(
    ProjectInfo projectInfo,
    MilestoneInfo milestoneInfo,
    double? milestoneAmount,
  ) async {
    return await _fireStoreInstance
        .collection(FireStoreConfig.transactionsCollection)
        .where(
          FireStoreConfig.transactionProjectIdField,
          isEqualTo: projectInfo.projectId,
        )
        .where(
          FireStoreConfig.transactionMilestoneField,
          isEqualTo: milestoneInfo.milestoneId,
        )
        .where(
          FireStoreConfig.transactionPaidAmountField,
          isEqualTo: milestoneAmount,
        )
        .get();
  }*/

  DocumentReference _createProjectUnPaidDocReference(ProjectInfo projectInfo) {
    return _fireStoreInstance
        .collection(FireStoreConfig.projectCollection)
        .doc(projectInfo.projectId);
  }

  Map<String, dynamic> _createProjectUnPaidData(
    ProjectInfo projectInfo,
    double? amount,
  ) {
    final projectData = <String, dynamic>{};
    projectData[FireStoreConfig.updatedAtField] =
        DateTime.now().millisecondsSinceEpoch;
    final updatedReceivedAmount =
        (projectInfo.receivedAmount ?? 0) - (amount ?? 0);
    projectData[FireStoreConfig.receivedAmountField] =
        (updatedReceivedAmount > 0) ? updatedReceivedAmount : 0.0;
    return projectData;
  }

  DocumentReference _createMilestoneUnPaidDocReference(
    String? projectMilestoneId,
    String? milestoneId,
  ) {
    return _fireStoreInstance
        .collection(FireStoreConfig.milestonesCollection)
        .doc(projectMilestoneId)
        .collection(FireStoreConfig.milestoneInfoCollection)
        .doc(milestoneId);
  }

  Map<String, dynamic> _createMilestoneUnPaidData(
    ProjectInfo projectInfo,
    MilestoneInfo milestoneInfo,
    double? amount,
  ) {
    final milestoneData = <String, dynamic>{};
    milestoneData[FireStoreConfig.updatedAtField] =
        DateTime.now().millisecondsSinceEpoch;
    milestoneData[FireStoreConfig.milestoneUpdatedByUserIdField] =
        _currentUserId;
    milestoneData[FireStoreConfig.milestoneUpdatedByUserNameField] =
        _currentUserName;
    double updatedReceivedAmount =
        (milestoneInfo.receivedAmount ?? 0) - (amount ?? 0);
    milestoneData[FireStoreConfig.milestoneReceivedAmountField] =
        (updatedReceivedAmount > 0) ? updatedReceivedAmount : 0.0;
    milestoneData[FireStoreConfig.milestonePaymentStatusField] =
        MilestoneUtils.getMilestonePaymentStatus(
      projectInfo,
      milestoneInfo..receivedAmount = updatedReceivedAmount,
    ).name;
    return milestoneData;
  }

  _onMilestoneCurrencyChange(
    MilestoneCurrencyChangeEvent event,
    Emitter<MilestoneOperationsState> emit,
  ) {
    if (_currencyId == AppConfig.dollarCurrencyId) {
      _currencyId = AppConfig.rupeeCurrencyId;
      _currencyEnum = CurrencyEnum.rupees;
    }
    /*else if (_currencyId == AppConfig.rupeeCurrencyId) {
      _currencyId = AppConfig.euroCurrencyId;
      _currencyEnum = CurrencyEnum.euros;
    }*/
    else {
      _currencyId = AppConfig.dollarCurrencyId;
      _currencyEnum = CurrencyEnum.dollars;
    }
    emit(MilestoneCurrencyChangedState(_currencyEnum));
  }

  _onPaidMultipleTransaction(
    MultipleMilestonesMarkAsPaidEvent event,
    Emitter<MilestoneOperationsState> emit,
  ) async {
    final projectInfo = event.projectInfo;
    final multipleMilestones = event.multipleMilestoneInfo;

    final batch = _fireStoreInstance.batch();
    final prefs = await SharedPreferences.getInstance();

    double totalPaidAmount = 0;
    for (int i = 0; i < multipleMilestones.length; i++) {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final milestoneInfo = multipleMilestones[i];
      totalPaidAmount += (milestoneInfo.pendingPaidUnPaidAmount ?? 0);

      final transactionInfo = _createTransactionInfoForMultipleTransactions(
        projectInfo: projectInfo,
        milestoneInfo: milestoneInfo,
        prefs: prefs,
        currentTime: currentTime,
        isPaidTransaction: true,
      );
      final transactionDocRef = _createTransactionDocReference(transactionInfo);
      batch.set(transactionDocRef, transactionInfo.toMap());

      final milestoneDocRef = _createMilestoneDocReference(
        projectInfo.milestoneId,
        milestoneInfo.milestoneId,
      );

      final milestoneData = _createMilestoneDataForMultipleTransactions(
        milestoneInfo: milestoneInfo,
        currentTime: currentTime,
      );
      batch.update(milestoneDocRef, milestoneData);

      final isMinDataAvailableToSaveLogs =
          LogUtils.isMinDataAvailableToSaveLogs(
        transaction: transactionInfo.paidAmount,
        notes: transactionInfo.notes,
      );

      if (isMinDataAvailableToSaveLogs) {
        final logId = LogUtils.generateLogId();
        final logDocRef = LogUtils.createLogDocReference(logId);
        final logsData = _generatePaidLogsData(
          projectInfo: projectInfo,
          milestoneId: milestoneInfo.milestoneId,
          logId: logId,
          transactionInfo: transactionInfo,
        );
        batch.set(logDocRef, logsData);
      }
    }

    final projectDocRef = _createProjectDocReference(projectInfo);
    final projectData = <String, dynamic>{};
    projectData[FireStoreConfig.updatedAtField] =
        DateTime.now().millisecondsSinceEpoch;
    final totalReceivedAmount =
        (projectInfo.receivedAmount ?? 0) + (totalPaidAmount);
    projectData[FireStoreConfig.receivedAmountField] = totalReceivedAmount;
    batch.update(projectDocRef, projectData);

    await batch.commit();
    emit(MilestonePaidSuccessState());
  }

  TransactionInfo _createTransactionInfoForMultipleTransactions({
    required ProjectInfo projectInfo,
    required MultipleMilestoneInfo milestoneInfo,
    required SharedPreferences prefs,
    required int currentTime,
    required bool isPaidTransaction,
  }) {
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

    return TransactionInfo(
      transactionId: _generateTransactionId(),
      projectId: projectInfo.projectId,
      projectName: projectInfo.projectName,
      projectCode: projectInfo.projectCode,
      projectType: projectInfo.projectType,
      milestoneId: milestoneInfo.milestoneId,
      transactionDate: milestoneInfo.transactionDate,
      paidAmount:
          isPaidTransaction ? milestoneInfo.pendingPaidUnPaidAmount : null,
      unPaidAmount:
          isPaidTransaction ? null : milestoneInfo.pendingPaidUnPaidAmount,
      notes: milestoneInfo.notes,
      transactionByUserId: prefs.getString(
        PreferenceConfig.userIdPref,
      ),
      transactionByName: prefs.getString(
        PreferenceConfig.userNamePref,
      ),
      transactionAvailableFor: availableForList,
      createdAt: currentTime,
      updatedAt: currentTime,
    );
  }

  Map<String, dynamic> _createMilestoneDataForMultipleTransactions({
    required MultipleMilestoneInfo milestoneInfo,
    required int currentTime,
  }) {
    final milestoneData = <String, dynamic>{};
    milestoneData[FireStoreConfig.updatedAtField] = currentTime;
    milestoneData[FireStoreConfig.milestoneUpdatedByUserIdField] =
        _currentUserId;
    milestoneData[FireStoreConfig.milestoneUpdatedByUserNameField] =
        _currentUserName;
    final totalReceivedAmount = (milestoneInfo.receivedAmount ?? 0) +
        (milestoneInfo.pendingPaidUnPaidAmount ?? 0);
    milestoneData[FireStoreConfig.milestoneReceivedAmountField] =
        totalReceivedAmount;
    if ((milestoneInfo.milestoneAmount ?? 0) <= totalReceivedAmount) {
      milestoneData[FireStoreConfig.milestonePaymentStatusField] =
          PaymentStatusEnum.fullyPaid.name;
    } else {
      milestoneData[FireStoreConfig.milestonePaymentStatusField] =
          PaymentStatusEnum.partiallyPaid.name;
    }
    return milestoneData;
  }

  _onUnPaidMultipleTransaction(
    MultipleMilestonesMarkAsUnPaidEvent event,
    Emitter<MilestoneOperationsState> emit,
  ) async {
    final ProjectInfo projectInfo = event.projectInfo;
    final multipleMilestones = event.multipleMilestoneInfo;

    final batch = _fireStoreInstance.batch();
    final prefs = await SharedPreferences.getInstance();
    double totalUnPaidAmount = 0;

    for (int i = 0; i < multipleMilestones.length; i++) {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final milestoneInfo = multipleMilestones[i];
      totalUnPaidAmount += (milestoneInfo.pendingPaidUnPaidAmount ?? 0);

      final milestoneDocRef = _createMilestoneUnPaidDocReference(
        projectInfo.milestoneId,
        milestoneInfo.milestoneId,
      );

      final milestoneData = <String, dynamic>{};
      milestoneData[FireStoreConfig.updatedAtField] = currentTime;
      milestoneData[FireStoreConfig.milestoneUpdatedByUserIdField] =
          _currentUserId;
      milestoneData[FireStoreConfig.milestoneUpdatedByUserNameField] =
          _currentUserName;
      double updatedReceivedAmount = (milestoneInfo.receivedAmount ?? 0) -
          (milestoneInfo.pendingPaidUnPaidAmount ?? 0);
      milestoneData[FireStoreConfig.milestoneReceivedAmountField] =
          (updatedReceivedAmount > 0) ? updatedReceivedAmount : 0.0;

      milestoneData[FireStoreConfig.milestonePaymentStatusField] =
          MilestoneUtils.getPaymentStatusFromMilestoneInfo(
        projectInfo: projectInfo,
        milestoneAmount: milestoneInfo.milestoneAmount ?? 0,
        milestoneReceivedAmount: updatedReceivedAmount,
        milestoneDateTime: milestoneInfo.milestoneDate,
      ).name;

      batch.update(milestoneDocRef, milestoneData);

      final transactionInfo = _createTransactionInfoForMultipleTransactions(
        projectInfo: projectInfo,
        milestoneInfo: milestoneInfo,
        prefs: prefs,
        currentTime: currentTime,
        isPaidTransaction: false,
      );
      final transactionDocRef = _createTransactionDocReference(transactionInfo);
      batch.set(transactionDocRef, transactionInfo.toMap());

      final isMinDataAvailableToSaveLogs =
          LogUtils.isMinDataAvailableToSaveLogs(
        transaction: transactionInfo.unPaidAmount,
        notes: transactionInfo.notes,
      );
      if (isMinDataAvailableToSaveLogs) {
        final logId = LogUtils.generateLogId();
        final logDocRef = LogUtils.createLogDocReference(logId);
        final logsData = _generateUnPaidLogsData(
          projectInfo: projectInfo,
          milestoneId: milestoneInfo.milestoneId,
          logId: logId,
          transactionInfo: transactionInfo,
        );
        batch.set(logDocRef, logsData);
      }
    }

    final projectDocRef = _createProjectUnPaidDocReference(projectInfo);
    final projectData = _createProjectUnPaidData(
      projectInfo,
      totalUnPaidAmount,
    );
    batch.update(projectDocRef, projectData);

    await batch.commit();
    emit(MilestoneUnPaidSuccessState());
  }

  CurrencyEnum getSelectedCurrency() {
    return _currencyEnum;
  }
}
