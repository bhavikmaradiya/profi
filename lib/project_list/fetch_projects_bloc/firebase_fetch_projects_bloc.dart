import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profi/enums/payment_status_enum.dart';
import 'package:profi/enums/project_type_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../add_project/model/milestone_info.dart';
import '../../add_project/model/project_info.dart';
import '../../api/fetch_date_time/date_time_repository.dart';
import '../../config/app_config.dart';
import '../../config/firestore_config.dart';
import '../../config/preference_config.dart';
import '../../enums/currency_enum.dart';
import '../../enums/filter_sort_by_enum.dart';
import '../../enums/project_status_enum.dart';
import '../../enums/user_role_enums.dart';
import '../../filter/model/applied_filter_info.dart';
import '../../utils/app_utils.dart';
import '../../utils/currency_converter_utils.dart';
import '../auto_update_project_status/auto_update_project_status.dart';

part 'firebase_fetch_projects_event.dart';
part 'firebase_fetch_projects_state.dart';

class FirebaseFetchProjectsBloc
    extends Bloc<FirebaseFetchProjectsEvent, FirebaseFetchProjectsState> {
  final _fireStoreInstance = FirebaseFirestore.instance;
  final List<ProjectInfo> _allProjects = [];
  final List<String> _milestoneIds = [];
  final List<MilestoneInfo> _milestoneInfo = [];
  StreamSubscription? _projectListSubscription;
  final List<StreamSubscription> _milestoneListSubscription = [];
  AppliedFilterInfo? _appliedFilterInfo;
  int? _currentDateTimestamp;
  bool _isPendingToCheckAutoUpdate = true;
  Timer? _debounceTimer;

  FirebaseFetchProjectsBloc() : super(FirebaseFetchProjectsInitialState()) {
    on<FirebaseFetchProjectsDetailsEvent>(_startProjectListCallback);
    on<FirebaseMilestoneInfoChangedEvent>(_onMilestoneInfoChanged);
    on<FilterChangedEvent>(_onFilterChanged);
    add(FirebaseFetchProjectsDetailsEvent());
    _fetchDateTimeToUpdateMilestonePaymentStatus();
  }

  _fetchDateTimeToUpdateMilestonePaymentStatus() async {
    final repository = DateTimeRepository();
    final response = await repository.fetchDateTime();
    final unixTime = response?.unixtime;
    if (unixTime != null) {
      // unix time coming in sec to converting in millisecond
      final dateTime = DateTime.fromMillisecondsSinceEpoch(unixTime * 1000);
      _currentDateTimestamp = dateTime.millisecondsSinceEpoch;
      if (_isPendingToCheckAutoUpdate) {
        _autoUpdateMilestonePaymentStatus();
      }
    }
  }

  _startProjectListCallback(
    FirebaseFetchProjectsDetailsEvent event,
    Emitter<FirebaseFetchProjectsState> emit,
  ) async {
    emit(FirebaseFetchProjectsLoadingState());
    final userRole = await _getCurrentUserRole();
    Stream<QuerySnapshot<Map<String, dynamic>>> snapshotStream;
    if (userRole == UserRoleEnum.admin.name) {
      snapshotStream = _createProjectsQueryForAdminRole();
    } else {
      snapshotStream = await _createProjectsQueryBasedOnUser();
    }
    _projectListSubscription = snapshotStream.listen(
      (snapshot) async {
        await _updateProjectInfo(snapshot);
        if (_allProjects.isEmpty) {
          _clearMilestonesOnEmptyProject();
          emit(FirebaseFetchProjectsEmptyState());
        } else {
          emit(FirebaseFetchProjectsDataState(_allProjects));
          final isNewMilestoneGenerated = await _generateMilestones();
          if (!isNewMilestoneGenerated) {
            // if new milestone is not generated then emit old milestones
            // to manage state and maintain list item.
            // this is required otherwise expandable list will empty
            emit(FirebaseMilestoneInfoChangedState(_milestoneInfo));
          }
        }
      },
    );
    // Await the subscription to ensure proper cleanup
    await _projectListSubscription?.asFuture();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      _createProjectsQueryForAdminRole() {
    // get all entries for admin role
    return _fireStoreInstance
        .collection(FireStoreConfig.projectCollection)
        .orderBy(
          FireStoreConfig.updatedAtField,
          descending: true,
        )
        .snapshots();
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>>
      _createProjectsQueryBasedOnUser() async {
    // get only entries which available for current user
    final userId = await _getCurrentUserId();
    return _fireStoreInstance
        .collection(FireStoreConfig.projectCollection)
        .where(
          FireStoreConfig.projectAvailableForField,
          arrayContains: userId,
        )
        .orderBy(
          FireStoreConfig.updatedAtField,
          descending: true,
        )
        .snapshots();
  }

  Future<String?> _getCurrentUserRole() async {
    final preference = await SharedPreferences.getInstance();
    return preference.getString(PreferenceConfig.userRolePref);
  }

  Future<String?> _getCurrentUserId() async {
    final preference = await SharedPreferences.getInstance();
    return preference.getString(PreferenceConfig.userIdPref);
  }

  _updateProjectInfo(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.docChanges.isNotEmpty) {
      for (var element in snapshot.docChanges) {
        final document = element.doc;
        if (element.type == DocumentChangeType.added) {
          _addProject(document);
        } else if (element.type == DocumentChangeType.modified) {
          _modifyProjectDetails(document);
        } else if (element.type == DocumentChangeType.removed) {
          _removeProject(document);
        }
      }
    }
  }

  _addProject(DocumentSnapshot document) {
    try {
      final projectInfo = ProjectInfo.fromSnapshot(document);
      _allProjects.add(projectInfo);
      _applyFilter(_allProjects);
    } on Exception catch (_) {}
  }

  _modifyProjectDetails(DocumentSnapshot document) {
    final index = _allProjects.indexWhere(
      (projectInfo) => projectInfo.projectId == document.id,
    );
    if (index != (-1)) {
      try {
        final projectInfo = ProjectInfo.fromSnapshot(document);
        _allProjects[index] = projectInfo;
      } on Exception catch (_) {}
    }
  }

  _removeProject(DocumentSnapshot document) {
    _allProjects.removeWhere(
      (projectInfo) => projectInfo.projectId == document.id,
    );
  }

  Future<bool> _generateMilestones() async {
    // this list is required to set observer as
    // _milestoneIds will contain all list
    // milestoneIdsToPutObserver only contains new list...
    // to set observer to minimize duplication of observer
    final List<String> milestoneIdsToPutObserver = [];
    for (int i = 0; i < _allProjects.length; i++) {
      final milestoneId = _allProjects[i].milestoneId;
      if (milestoneId != null) {
        if (!_milestoneIds.contains(milestoneId)) {
          milestoneIdsToPutObserver.add(milestoneId.toString().trim());
          _milestoneIds.add(milestoneId.toString().trim());
        }
      }
    }
    if (milestoneIdsToPutObserver.isNotEmpty) {
      for (final parentDocId in milestoneIdsToPutObserver) {
        final snapshot = _fireStoreInstance
            .collection(FireStoreConfig.milestonesCollection)
            .doc(parentDocId)
            .collection(FireStoreConfig.milestoneInfoCollection)
            .orderBy(FireStoreConfig.milestoneDateField)
            .snapshots();
        final subscription = snapshot.listen(
          (snapshot) {
            _updateMilestones(snapshot);
            _sortMilestones();
            add(FirebaseMilestoneInfoChangedEvent());
          },
        );
        _milestoneListSubscription.add(subscription);
      }
      return true;
    }
    return false;
  }

  _updateMilestones(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.docChanges.isNotEmpty) {
      for (var element in snapshot.docChanges) {
        final document = element.doc;
        if (element.type == DocumentChangeType.added) {
          _addNewMilestone(document);
        } else if (element.type == DocumentChangeType.modified) {
          _modifyMilestoneDetails(document);
        } else if (element.type == DocumentChangeType.removed) {
          _removeMilestone(document);
        }
      }
    }
  }

  _addNewMilestone(DocumentSnapshot document) {
    try {
      final milestoneInfo = MilestoneInfo.fromSnapshot(document);
      _milestoneInfo.add(milestoneInfo);
    } on Exception catch (_) {}
  }

  _modifyMilestoneDetails(DocumentSnapshot document) {
    final index = _milestoneInfo.indexWhere(
      (milestoneInfo) => milestoneInfo.milestoneId == document.id,
    );
    if (index != (-1)) {
      try {
        final milestoneInfo = MilestoneInfo.fromSnapshot(document);
        _milestoneInfo[index] = milestoneInfo;
      } on Exception catch (_) {}
    }
  }

  _removeMilestone(DocumentSnapshot document) {
    _milestoneInfo.removeWhere(
      (milestoneInfo) => milestoneInfo.milestoneId == document.id,
    );
  }

  _sortMilestones() {
    _milestoneInfo.sort(
      (a, b) {
        if (a.dateTime != null && b.dateTime != null) {
          return a.dateTime!.compareTo(b.dateTime!);
        }
        return -1;
      },
    );
  }

  _onMilestoneInfoChanged(
    FirebaseMilestoneInfoChangedEvent event,
    Emitter<FirebaseFetchProjectsState> emit,
  ) {
    emit(FirebaseMilestoneInfoChangedState(_milestoneInfo));
    _autoUpdateMilestonePaymentStatus();
  }

  _clearMilestonesOnEmptyProject() {
    // clearing observer if any:
    if (_milestoneListSubscription.isNotEmpty) {
      for (final subscription in _milestoneListSubscription) {
        subscription.cancel();
      }
    }
    // clearing milestone info
    _milestoneIds.clear();
    _milestoneInfo.clear();
  }

  ProjectInfo? getProjectInfoFromProjectId(String? projectId) {
    if (projectId == null) {
      return null;
    }
    final projectInfo = _allProjects.firstWhereOrNull(
      (element) => element.projectId == projectId,
    );
    return projectInfo;
  }

  List<MilestoneInfo> getMilestoneInfoFromProjectId(String? projectId) {
    if (projectId != null) {
      final list = _milestoneInfo
          .where(
            (element) => element.projectId == projectId,
          )
          .toList();
      // returning copy of list so actual list will not change
      return list.map((e) => MilestoneInfo.copy(e)).toList();
    }
    return [];
  }

  List<ProjectInfo> getProjectsByPaymentStatus(
    PaymentStatusEnum? paymentStatusEnum,
  ) {
    if (paymentStatusEnum == PaymentStatusEnum.exceeded) {
      return getRedProjects();
    } else if (paymentStatusEnum == PaymentStatusEnum.aboutToExceed) {
      return getOrangeProjects();
    }
    return getAllProjects();
  }

  List<ProjectInfo> getAllProjects() {
    return _applyFilter(_allProjects);
  }

  List<ProjectInfo> getRedProjects({
    bool isProjectFilterRequired = true,
  }) {
    final List<ProjectInfo> redProjects = [];
    if (_milestoneInfo.isNotEmpty) {
      final filter = _milestoneInfo.where(
        (element) => element.paymentStatus == PaymentStatusEnum.exceeded.name,
      );
      if (filter.isNotEmpty) {
        redProjects.addAll(
          _allProjects
              .where(
                (project) => filter.any(
                  (milestone) => milestone.projectId == project.projectId,
                ),
              )
              .toList(),
        );
      }
    }
    if (isProjectFilterRequired) {
      return _applyFilter(redProjects);
    } else {
      return redProjects;
    }
  }

  getOrangeProjects({
    bool isProjectFilterRequired = true,
    bool shouldExcludeInvoiced = false,
  }) {
    final List<ProjectInfo> orangeProjects = [];
    final filter = _milestoneInfo.where(
      (element) =>
          element.paymentStatus == PaymentStatusEnum.aboutToExceed.name &&
          (!shouldExcludeInvoiced || (element.isInvoiced ?? false) == false),
    );
    if (filter.isNotEmpty) {
      orangeProjects.addAll(
        _allProjects
            .where(
              (project) => filter.any(
                (milestone) => milestone.projectId == project.projectId,
              ),
            )
            .toList(),
      );
    }
    if (isProjectFilterRequired) {
      return _applyFilter(orangeProjects);
    } else {
      return orangeProjects;
    }
  }

  _onFilterChanged(
    FilterChangedEvent event,
    Emitter<FirebaseFetchProjectsState> emit,
  ) {
    _appliedFilterInfo = event.appliedFilterInfo;
    emit(FilterChangedState());
    emit(FirebaseMilestoneInfoChangedState(_milestoneInfo));
  }

  List<ProjectInfo> _applyFilter(List<ProjectInfo> originalList) {
    if (originalList.isEmpty) {
      return originalList;
    }
    List<ProjectInfo> filteredList = [];
    if (_appliedFilterInfo == null) {
      filteredList.addAll(
        originalList.where(
          (project) => project.projectStatus == ProjectStatusEnum.active.name,
        ),
      );
      filteredList = _projectSortByFilter(
        AppConfig.defaultSortBy,
        filteredList,
      );
      return filteredList;
    }
    filteredList.addAll(
      originalList.where(
        (project) =>
            _appliedFilterInfo!.statusList.any(
              (status) =>
                  status.isSelected &&
                  project.projectStatus?.toLowerCase() ==
                      (status.filterEnum as ProjectStatusEnum)
                          .name
                          .toLowerCase(),
            ) &&
            _appliedFilterInfo!.typeList.any(
              (type) =>
                  type.isSelected &&
                  project.projectType?.toLowerCase() ==
                      (type.filterEnum as ProjectTypeEnum).name.toLowerCase(),
            ),
      ),
    );

    final sortBy = _appliedFilterInfo!.sortByList.firstWhere(
      (element) => element.isSelected,
    );
    filteredList = _projectSortByFilter(sortBy.filterEnum, filteredList);
    return filteredList;
  }

  List<ProjectInfo> _projectSortByFilter(
    FilterSortByEnum sortByEnum,
    List<ProjectInfo> filteredList,
  ) {
    if (sortByEnum == FilterSortByEnum.sortByProjectName) {
      filteredList.sort(
        (a, b) => a.projectName!.toLowerCase().compareTo(
              b.projectName!.toLowerCase(),
            ),
      );
    } else if (sortByEnum == FilterSortByEnum.sortByProjectCode) {
      filteredList.sort(
        (a, b) {
          if (b.projectCodeInt == null) {
            return 0;
          }
          if (a.projectCodeInt == null) {
            return 0;
          }
          return b.projectCodeInt!.compareTo(
            a.projectCodeInt!,
          );
        },
      );
    } else {
      filteredList.sort(
        (a, b) => b.updatedAt!.compareTo(
          a.updatedAt!,
        ),
      );
    }
    return filteredList;
  }

  AppliedFilterInfo? getAppliedFilter() {
    return _appliedFilterInfo;
  }

  String getPendingAmount({
    required List<ProjectInfo> projects,
    required PaymentStatusEnum? paymentStatusEnum,
    required CurrencyEnum toCurrency,
  }) {
    if (paymentStatusEnum == null || projects.isEmpty) {
      return AppUtils.amountWithCurrencyFormatter(
        amount: 0,
        toCurrency: toCurrency,
      );
    }
    final filteredMilestones = _milestoneInfo
        .where(
          (milestone) =>
              milestone.milestoneAmount != null &&
              milestone.paymentStatus == paymentStatusEnum.name &&
              projects.any(
                (element) => element.projectId == milestone.projectId,
              ),
        )
        .toList();
    double amount = 0;
    for (var milestone in filteredMilestones) {
      final projectCurrency = _allProjects
          .firstWhereOrNull(
            (project) => project.projectId == milestone.projectId,
          )
          ?.currency;
      amount += CurrencyConverterUtils.convert(
        milestone.milestoneAmount!,
        projectCurrency ?? AppConfig.defaultCurrencyEnum.name,
        toCurrency.name,
      );
    }
    return AppUtils.amountWithCurrencyFormatter(
      amount: amount,
      toCurrency: toCurrency,
    );
  }

  String getInwardAmount({
    required CurrencyEnum toCurrency,
  }) {
    if (_allProjects.isEmpty) {
      return AppUtils.amountWithCurrencyFormatter(
        amount: 0,
        toCurrency: toCurrency,
      );
    }
    final projects =
        _allProjects.where((element) => element.receivedAmount != null);
    double amount = 0;
    for (var project in projects) {
      amount += CurrencyConverterUtils.convert(
        project.receivedAmount!,
        project.currency ?? CurrencyEnum.dollars.name,
        toCurrency.name,
      );
    }
    return AppUtils.amountWithCurrencyFormatter(
      amount: amount,
      toCurrency: toCurrency,
    );
  }

  _autoUpdateMilestonePaymentStatus() {
    // When date is changed - check for milestones
    // update it's payment status to red or orange based on logics
    if (_currentDateTimestamp != null && _isPendingToCheckAutoUpdate) {
      _isPendingToCheckAutoUpdate = false;
      if (_debounceTimer?.isActive ?? false) {
        _debounceTimer?.cancel();
      }
      _debounceTimer = Timer(
        const Duration(seconds: 3),
        () {
          final autoUpdateProjectStatus = AutoUpdateProjectStatus();
          autoUpdateProjectStatus.doProcessForAutoUpdateProjectStatus(
            _currentDateTimestamp!,
            _milestoneInfo,
            _allProjects,
          );
        },
      );
    }
  }

  String getTotalMilestoneAmount(ProjectInfo projectInfo) {
    final milestones = getMilestoneInfoFromProjectId(
      projectInfo.projectId,
    );
    double totalProjectAmount = 0;
    if (milestones.isNotEmpty) {
      for (var element in milestones) {
        totalProjectAmount += element.milestoneAmount ?? 0;
      }
    }
    return AppUtils.removeTrailingZero(totalProjectAmount);
  }

  StreamSubscription? getProjectListSubscription() {
    return _projectListSubscription;
  }

  onLogout() async {
    _dispose();
    _allProjects.clear();
    _milestoneIds.clear();
    _milestoneInfo.clear();
    _appliedFilterInfo = null;
    _isPendingToCheckAutoUpdate = true;
  }

  _dispose() async {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }
    await _projectListSubscription?.cancel();
    if (_milestoneListSubscription.isNotEmpty) {
      for (final subscription in _milestoneListSubscription) {
        await subscription.cancel();
      }
    }
  }

  @override
  Future<void> close() {
    _dispose();
    return super.close();
  }
}
