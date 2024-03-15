import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../add_project/model/milestone_info.dart';
import '../../add_project/model/project_info.dart';
import '../../api/fetch_date_time/date_time_repository.dart';
import '../../config/app_config.dart';
import '../../config/firestore_config.dart';
import '../../config/preference_config.dart';
import '../../enums/currency_enum.dart';
import '../../enums/filter_sort_by_enum.dart';
import '../../enums/payment_status_enum.dart';
import '../../enums/project_status_enum.dart';
import '../../enums/project_type_enum.dart';
import '../../enums/user_role_enums.dart';
import '../../filter/model/applied_filter_info.dart';
import '../../profile/model/profile_info.dart';
import '../../utils/app_utils.dart';
import '../../utils/currency_converter_utils.dart';
import '../auto_update_project_status/auto_update_project_status.dart';
import '../utils/milestone_utils.dart';

part 'firebase_fetch_projects_event.dart';
part 'firebase_fetch_projects_state.dart';

class FirebaseFetchProjectsBloc
    extends Bloc<FirebaseFetchProjectsEvent, FirebaseFetchProjectsState> {
  final _fireStoreInstance = FirebaseFirestore.instance;
  final List<ProjectInfo> _allProjects = [];
  final List<String> _milestoneIds = [];
  final List<MilestoneInfo> _milestoneInfo = [];
  StreamSubscription? _projectListSubscription;
  StreamSubscription? _bdmListSubscription;
  StreamSubscription? _pmListSubscription;
  final List<ProfileInfo> _bdmList = [];
  final List<ProfileInfo> _pmList = [];
  final List<StreamSubscription> _milestoneListSubscription = [];
  AppliedFilterInfo? _appliedFilterInfo;
  int? _currentDateTimestamp;
  bool _isPendingToCheckAutoUpdate = true;
  bool _isSearchEnabled = false;
  String _searchText = '';
  Timer? _debounceTimer;
  String? _userRole;

  List<ProfileInfo> get bdmList => _bdmList;

  List<ProfileInfo> get pmList => _pmList;

  FirebaseFetchProjectsBloc() : super(FirebaseFetchProjectsInitialState()) {
    on<FirebaseFetchProjectsDetailsEvent>(_startProjectListCallback);
    on<FirebaseMilestoneInfoChangedEvent>(_onMilestoneInfoChanged);
    on<FirebaseFetchBdmDetailsEvent>(_fetchBDList);
    on<FirebaseFetchPMDetailsEvent>(_fetchPMList);
    on<FilterChangedEvent>(_onFilterChanged);
    on<ProjectSearchInitializeEvent>(_onSearchInitialized);
    on<ProjectSearchTextChangedEvent>(_onSearchTextChange);
    on<ProjectSearchClosedEvent>(_onSearchClosed);
    add(FirebaseFetchProjectsDetailsEvent());
    add(FirebaseFetchBdmDetailsEvent());
    add(FirebaseFetchPMDetailsEvent());
    _fetchDateTimeToUpdateMilestonePaymentStatus();
  }

  getMilestoneInfo(String? milestoneId) {
    if (milestoneId == null || milestoneId.trim().isEmpty) {
      return null;
    }
    return _milestoneInfo
        .firstWhereOrNull((element) => element.milestoneId == milestoneId);
  }

  _onSearchClosed(
    ProjectSearchClosedEvent event,
    Emitter<FirebaseFetchProjectsState> emit,
  ) {
    _isSearchEnabled = false;
    _searchText = '';
    emit(ProjectSearchClosedState());
    emit(ProjectSearchTextChangeState(_searchText));
    emit(FirebaseMilestoneInfoChangedState(_milestoneInfo));
  }

  _onSearchTextChange(
    ProjectSearchTextChangedEvent event,
    Emitter<FirebaseFetchProjectsState> emit,
  ) {
    if (_isSearchEnabled) {
      _searchText = event.searchBy;
      emit(ProjectSearchTextChangeState(_searchText));
      emit(FirebaseMilestoneInfoChangedState(_milestoneInfo));
    }
  }

  _onSearchInitialized(
    ProjectSearchInitializeEvent event,
    Emitter<FirebaseFetchProjectsState> emit,
  ) {
    _isSearchEnabled = true;
    _searchText = '';
    emit(ProjectSearchInitializedState());
    emit(FirebaseMilestoneInfoChangedState(_milestoneInfo));
  }

  List<ProjectInfo> _applySearchFilter(List<ProjectInfo> projects) {
    List<ProjectInfo> filteredProjects = [];
    if (_isSearchEnabled &&
        _searchText.trim().isNotEmpty &&
        projects.isNotEmpty) {
      final searchBy = _searchText.trim().toLowerCase();
      filteredProjects.addAll(projects
          .where((element) =>
              element.projectName!.trim().toLowerCase().contains(searchBy))
          .toList());
      return filteredProjects;
    } else {
      return projects;
    }
  }

  _fetchBDList(
    FirebaseFetchBdmDetailsEvent event,
    Emitter<FirebaseFetchProjectsState> emit,
  ) async {
    Stream<QuerySnapshot<Map<String, dynamic>>> snapshotStream =
        _createBDMStreamQuery();
    _bdmListSubscription = snapshotStream.listen(
      (snapshot) {
        _bdmList.clear();
        final docs = snapshot.docs;
        for (int i = 0; i < docs.length; i++) {
          try {
            final profileInfo = ProfileInfo.fromSnapshot(docs[i]);
            _bdmList.add(profileInfo);
          } on Exception catch (_) {}
        }
        emit(FirebaseBDMInfoChangedState(_bdmList));
      },
    );
    await _bdmListSubscription?.asFuture();
  }

  _fetchPMList(
    FirebaseFetchPMDetailsEvent event,
    Emitter<FirebaseFetchProjectsState> emit,
  ) async {
    Stream<QuerySnapshot<Map<String, dynamic>>> snapshotStream =
        _createPMStreamQuery();
    _pmListSubscription = snapshotStream.listen(
      (snapshot) {
        _pmList.clear();
        final docs = snapshot.docs;
        for (int i = 0; i < docs.length; i++) {
          try {
            final profileInfo = ProfileInfo.fromSnapshot(docs[i]);
            _pmList.add(profileInfo);
          } on Exception catch (_) {}
        }
        emit(FirebasePMInfoChangedState(_pmList));
      },
    );
    await _pmListSubscription?.asFuture();
  }

  getBdmInfoById(String? bdmId) {
    if (bdmId == null) {
      return null;
    }
    return _bdmList.firstWhereOrNull(
      (bdmInfo) => bdmInfo.userId == bdmId,
    );
  }

  _createBDMStreamQuery() {
    return _fireStoreInstance
        .collection(FireStoreConfig.userCollection)
        .where(
          FireStoreConfig.userRoleField,
          isEqualTo: UserRoleEnum.bdm.name,
        )
        .snapshots();
  }

  _createPMStreamQuery() {
    return _fireStoreInstance
        .collection(FireStoreConfig.userCollection)
        .where(
          FireStoreConfig.userRoleField,
          isEqualTo: UserRoleEnum.projectManager.name,
        )
        .snapshots();
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
    _userRole = preference.getString(PreferenceConfig.userRolePref);
    return _userRole;
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
    PaymentStatusEnum? paymentStatusEnum, {
    bool? includeOnlyInvoiced,
  }) {
    if (paymentStatusEnum == PaymentStatusEnum.exceeded) {
      return getRedProjects();
    } else if (paymentStatusEnum == PaymentStatusEnum.aboutToExceed) {
      return getOrangeProjects(
        shouldExcludeUnInvoiced: includeOnlyInvoiced == true,
        shouldExcludeInvoiced: includeOnlyInvoiced == false,
      );
    }
    return getAllProjects();
  }

  List<ProjectInfo> getAllProjects() {
    final searchFiltered = _applySearchFilter(_allProjects);
    return _applyFilter(searchFiltered);
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
        final _redProjects = _allProjects
            .where(
              (project) => filter.any(
                (milestone) => milestone.projectId == project.projectId,
              ),
            )
            .toList();

        for (int i = 0; i < _redProjects.length; i++) {
          final projectInfo = _redProjects[i];
          final projectMilestones = _milestoneInfo
              .where((element) => element.projectId == projectInfo.projectId)
              .toList();
          if (projectMilestones.isNotEmpty) {
            MilestoneInfo milestoneInfo = projectMilestones.first;
            final nearestIndex = MilestoneUtils.getFocusedMilestoneIndex(
              projectMilestones,
            );
            if (nearestIndex != (-1)) {
              milestoneInfo = projectMilestones[nearestIndex];
            }
            bool isExceed =
                MilestoneUtils.isMilestonePaymentCycleExceed(milestoneInfo);
            if (isExceed) {
              var currentDate = DateTime.now();
              currentDate = DateTime(
                currentDate.year,
                currentDate.month,
                currentDate.day,
              );
              var milestoneDate = milestoneInfo.dateTime!;
              milestoneDate = DateTime(
                milestoneDate.year,
                milestoneDate.month,
                milestoneDate.day,
              );
              final paymentCycle = projectInfo.paymentCycle ?? 0;
              int dateDiffWithCurrentDate =
                  milestoneDate.difference(currentDate).inDays;
              if (paymentCycle <= 0) {
                dateDiffWithCurrentDate =
                    currentDate.difference(milestoneDate).inDays;
              } else if (paymentCycle > 0) {
                final maxMilestoneDate = milestoneDate.add(
                  Duration(
                    days: paymentCycle,
                  ),
                );
                dateDiffWithCurrentDate =
                    currentDate.difference(maxMilestoneDate).inDays;
              }
              _redProjects[i].exceededDays = dateDiffWithCurrentDate;
            }
          }
        }
        redProjects.addAll(_redProjects);
      }
    }
    final searchFiltered = _applySearchFilter(redProjects);
    if (isProjectFilterRequired) {
      return _applyFilter(
        searchFiltered,
        defaultSortBy: FilterSortByEnum.sortByExceededDays,
      );
    } else {
      return _projectSortByFilter(
        FilterSortByEnum.sortByExceededDays,
        searchFiltered,
      );
    }
  }

  getOrangeProjects({
    bool isProjectFilterRequired = true,
    bool shouldExcludeInvoiced = false,
    bool shouldExcludeUnInvoiced = false,
  }) {
    final List<ProjectInfo> orangeProjects = [];
    final filter = _milestoneInfo.where(
      (element) =>
          element.paymentStatus == PaymentStatusEnum.aboutToExceed.name &&
          ((!shouldExcludeInvoiced && !shouldExcludeUnInvoiced) ||
              (shouldExcludeInvoiced &&
                  (element.isInvoiced ?? false) == false) ||
              (shouldExcludeUnInvoiced &&
                  (element.isInvoiced ?? false) == true)),
    );
    if (filter.isNotEmpty) {
      final _orangeProjects = _allProjects
          .where(
            (project) => filter.any(
              (milestone) => milestone.projectId == project.projectId,
            ),
          )
          .toList();

      for (int i = 0; i < _orangeProjects.length; i++) {
        final projectInfo = _orangeProjects[i];
        final projectMilestones = _milestoneInfo
            .where((element) => element.projectId == projectInfo.projectId)
            .toList();
        if (projectMilestones.isNotEmpty) {
          MilestoneInfo milestoneInfo = projectMilestones.first;
          final nearestIndex = MilestoneUtils.getFocusedMilestoneIndex(
            projectMilestones,
          );
          if (nearestIndex != (-1)) {
            milestoneInfo = projectMilestones[nearestIndex];
          }
          bool isAboutToExceed =
              MilestoneUtils.isMilestoneWithinPaymentCycle(milestoneInfo);
          if (isAboutToExceed) {
            var currentDate = DateTime.now();
            currentDate = DateTime(
              currentDate.year,
              currentDate.month,
              currentDate.day,
            );
            var milestoneDate = milestoneInfo.dateTime!;
            milestoneDate = DateTime(
              milestoneDate.year,
              milestoneDate.month,
              milestoneDate.day,
            );
            final paymentCycle = projectInfo.paymentCycle ?? 0;
            int dateDiffWithCurrentDate =
                milestoneDate.difference(currentDate).inDays;
            if (paymentCycle > 0) {
              final maxMilestoneDate = milestoneDate.add(
                Duration(
                  days: paymentCycle,
                ),
              );
              dateDiffWithCurrentDate =
                  maxMilestoneDate.difference(currentDate).inDays;
            } else if (paymentCycle < 0) {
              dateDiffWithCurrentDate =
                  milestoneDate.difference(currentDate).inDays;
            }
            _orangeProjects[i].remainingDays = dateDiffWithCurrentDate;
          }
        }
      }

      orangeProjects.addAll(_orangeProjects);
    }
    final searchFiltered = _applySearchFilter(orangeProjects);
    if (isProjectFilterRequired) {
      return _applyFilter(
        searchFiltered,
        defaultSortBy: FilterSortByEnum.sortByRemainingDays,
      );
    } else {
      return _projectSortByFilter(
        FilterSortByEnum.sortByRemainingDays,
        searchFiltered,
      );
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

  List<ProjectInfo> _applyFilter(
    List<ProjectInfo> originalList, {
    FilterSortByEnum? defaultSortBy,
  }) {
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
        defaultSortBy ?? AppConfig.defaultSortBy,
        filteredList,
      );
      return filteredList;
    }
    bool isAdmin = _userRole == UserRoleEnum.admin.name;
    bool isPM = _userRole == UserRoleEnum.projectManager.name;
    bool isBDM = _userRole == UserRoleEnum.bdm.name;
    final selectedBDMList = _appliedFilterInfo!.selectedBDMList;
    final selectedPMList = _appliedFilterInfo!.selectedPMList;
    final shouldApplyPMFilter = (isAdmin || isBDM) && selectedPMList.isNotEmpty;
    final shouldApplyBDMFilter =
        (isAdmin || isPM) && selectedBDMList.isNotEmpty;
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
            ) &&
            (!shouldApplyPMFilter ||
                (project.pmUserId != null &&
                    selectedPMList.firstWhereOrNull(
                            (element) => element.userId == project.pmUserId) !=
                        null)) &&
            (!shouldApplyBDMFilter ||
                (project.bdmUserId != null &&
                    selectedBDMList.firstWhereOrNull(
                            (element) => element.userId == project.bdmUserId) !=
                        null)),
      ),
    );

    final sortBy = _appliedFilterInfo!.sortByList.firstWhere(
      (element) => element.isSelected,
    );
    filteredList = _projectSortByFilter(
      (defaultSortBy != null && (shouldApplyPMFilter || shouldApplyBDMFilter))
          ? defaultSortBy
          : sortBy.filterEnum,
      filteredList,
    );
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
    } else if (sortByEnum == FilterSortByEnum.sortByRemainingDays) {
      filteredList.sort(
        (a, b) {
          if (a.remainingDays == null) {
            return 0;
          }
          if (b.remainingDays == null) {
            return 0;
          }
          return a.remainingDays!.compareTo(
            b.remainingDays!,
          );
        },
      );
    } else if (sortByEnum == FilterSortByEnum.sortByExceededDays) {
      filteredList.sort(
        (a, b) {
          if (a.exceededDays == null) {
            return 0;
          }
          if (b.exceededDays == null) {
            return 0;
          }
          return b.exceededDays!.compareTo(
            a.exceededDays!,
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

  dynamic getPendingAmount({
    required List<ProjectInfo> projects,
    required PaymentStatusEnum? paymentStatusEnum,
    required CurrencyEnum toCurrency,
    bool separateWithinDays = false,
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
    double in5Days = 0;
    double in10Days = 0;
    double in15Days = 0;
    double inThisMonth = 0;
    double inNextMonth = 0;

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
      if (separateWithinDays) {
        final project = projects.firstWhereOrNull(
          (element) => element.projectId == milestone.projectId,
        );
        if (project != null) {
          final paymentCycle = project.paymentCycle ?? 0;
          var currentDate = DateTime.now();
          currentDate = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
          );
          var milestoneDate = milestone.dateTime!;
          milestoneDate = DateTime(
            milestoneDate.year,
            milestoneDate.month,
            milestoneDate.day,
          );
          int dateDiffWithCurrentDate =
              milestoneDate.difference(currentDate).inDays;
          if (paymentCycle > 0) {
            final maxMilestoneDate = milestoneDate.add(
              Duration(
                days: paymentCycle,
              ),
            );
            dateDiffWithCurrentDate =
                maxMilestoneDate.difference(currentDate).inDays;
          } else if (paymentCycle < 0) {
            dateDiffWithCurrentDate =
                milestoneDate.difference(currentDate).inDays;
          }
          if (dateDiffWithCurrentDate <= 5) {
            in5Days += CurrencyConverterUtils.convert(
              milestone.milestoneAmount!,
              projectCurrency ?? AppConfig.defaultCurrencyEnum.name,
              toCurrency.name,
            );
          }
          if (dateDiffWithCurrentDate <= 10) {
            in10Days += CurrencyConverterUtils.convert(
              milestone.milestoneAmount!,
              projectCurrency ?? AppConfig.defaultCurrencyEnum.name,
              toCurrency.name,
            );
          }
          if (dateDiffWithCurrentDate <= 15) {
            in15Days += CurrencyConverterUtils.convert(
              milestone.milestoneAmount!,
              projectCurrency ?? AppConfig.defaultCurrencyEnum.name,
              toCurrency.name,
            );
          }

          final lastDayOfMonth = (currentDate.month < 12)
              ? DateTime(currentDate.year, currentDate.month + 1, 0)
              : DateTime(currentDate.year + 1, 1, 0);
          final firstDayOfMonth =
              DateTime(currentDate.year, currentDate.month, 1);
          final lastDayOfNextMonth = (currentDate.month < 12)
              ? DateTime(currentDate.year, currentDate.month + 2, 0)
              : DateTime(currentDate.year + 1, 2, 0);
          final firstDayOfNextMonth = (currentDate.month < 12)
              ? DateTime(currentDate.year, currentDate.month + 1, 1)
              : DateTime(currentDate.year + 1, 1, 1);
          var maxMilestoneDate = milestoneDate;
          if (paymentCycle > 0) {
            maxMilestoneDate = milestoneDate.add(
              Duration(
                days: paymentCycle,
              ),
            );
          }
          if ((maxMilestoneDate.isBefore(lastDayOfMonth) &&
                  maxMilestoneDate.isAfter(firstDayOfMonth)) ||
              maxMilestoneDate.compareTo(firstDayOfMonth) == 0 ||
              maxMilestoneDate.compareTo(lastDayOfMonth) == 0) {
            inThisMonth += CurrencyConverterUtils.convert(
              milestone.milestoneAmount!,
              projectCurrency ?? AppConfig.defaultCurrencyEnum.name,
              toCurrency.name,
            );
          }
          if ((maxMilestoneDate.isBefore(lastDayOfNextMonth) &&
                  maxMilestoneDate.isAfter(firstDayOfNextMonth)) ||
              maxMilestoneDate.compareTo(firstDayOfNextMonth) == 0 ||
              maxMilestoneDate.compareTo(lastDayOfNextMonth) == 0) {
            inNextMonth += CurrencyConverterUtils.convert(
              milestone.milestoneAmount!,
              projectCurrency ?? AppConfig.defaultCurrencyEnum.name,
              toCurrency.name,
            );
          }
        }
      }
    }
    if (separateWithinDays) {
      return {
        MilestoneUtils.keyPendingTotalAmount:
            AppUtils.amountWithCurrencyFormatter(
          amount: amount,
          toCurrency: toCurrency,
        ),
        MilestoneUtils.keyPendingAmountWithinThisMonth:
            AppUtils.amountWithCurrencyFormatter(
          amount: inThisMonth,
          toCurrency: toCurrency,
        ),
        MilestoneUtils.keyPendingAmountWithinNextMonth:
            AppUtils.amountWithCurrencyFormatter(
          amount: inNextMonth,
          toCurrency: toCurrency,
        ),
        MilestoneUtils.keyPendingAmountWithin5Days:
            AppUtils.amountWithCurrencyFormatter(
          amount: in5Days,
          toCurrency: toCurrency,
        ),
        MilestoneUtils.keyPendingAmountWithin10Days:
            AppUtils.amountWithCurrencyFormatter(
          amount: in10Days,
          toCurrency: toCurrency,
        ),
        MilestoneUtils.keyPendingAmountWithin15Days:
            AppUtils.amountWithCurrencyFormatter(
          amount: in15Days,
          toCurrency: toCurrency,
        ),
      };
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
    await _bdmListSubscription?.cancel();
    await _pmListSubscription?.cancel();
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
