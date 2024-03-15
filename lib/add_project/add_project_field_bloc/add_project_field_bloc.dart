import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_models/drop_down_model.dart';
import '../../config/app_config.dart';
import '../../config/firestore_config.dart';
import '../../config/preference_config.dart';
import '../../enums/currency_enum.dart';
import '../../enums/project_field_validation_enum.dart';
import '../../enums/project_status_enum.dart';
import '../../enums/project_type_enum.dart';
import '../../enums/user_role_enums.dart';
import '../../main.dart';
import '../../profile/model/profile_info.dart';
import '../../project_list/utils/milestone_utils.dart';
import '../../utils/app_utils.dart';
import '../generate_weekly_milestones.dart';
import '../model/milestone_info.dart';
import '../model/project_info.dart';
import '../model/weekly_milestone_input.dart';

part 'add_project_field_event.dart';

part 'add_project_field_state.dart';

class AddProjectFieldBloc
    extends Bloc<AddProjectFieldEvent, AddProjectFieldState> {
  final int maxPaymentCycleDays = 90;
  final int minPaymentCycleDays = -30;
  final List<DropDownModel> _currencySymbols = [];
  List<MilestoneInfo> _milestones = [];
  final List<DropDownModel> _paymentCycleList = [];

  late ProjectInfo _editProject;
  String? _projectCode;
  String? _projectName;
  String? _selectedBdmUserId;
  String? _selectedPmUserId;
  double? _totalFixedAmount;
  double? _monthlyRetainerAmount;
  double? _hourlyRate;
  double? _weeklyHours;
  double? _totalHours;
  int? _paymentCycle;
  String? _specialNotes;
  String? _projectStatus = ProjectStatusEnum.active.name;
  DateTime? _projectStartDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  ProjectTypeEnum _projectTypeEnum = ProjectTypeEnum.nonBillable;
  bool _isMilestoneChangedByUser = false;
  bool isEdit = false;
  Timer? _weeklyCalcDebounce;
  ProfileInfo? _profileInfo;

  ProjectTypeEnum get selectedProjectType => _projectTypeEnum;

  AddProjectFieldBloc() : super(AddProjectFieldInitialState()) {
    on<FetchUserInfoEvent>(_fetchUserInfo);
    on<GenerateCurrencySymbolEvent>(_generateCurrencySymbols);
    on<GeneratePaymentCycleEvent>(_generatePaymentCycles);
    on<ProjectCodeTextChangeEvent>(_onProjectCodeTextChanged);
    on<ProjectNameTextChangeEvent>(_onProjectNameTextChanged);
    on<BdmInfoSelectionChangeEvent>(_onBdmSelectionChanged);
    on<ProjectManagerInfoSelectionChangeEvent>(_onProjectManagerInfoChanged);
    on<ProjectTypeChangeEvent>(_onProjectTypeChanged);
    on<ProjectStatusChangeEvent>(_onProjectStatusChanged);
    on<TotalFixedAmountChangeEvent>(_onTotalFixedAmountChanged);
    on<CurrencyChangeEvent>(_onCurrencyChanged);
    on<HourlyRateChangeEvent>(_onHourlyRateChanged);
    on<WeeklyHoursChangeEvent>(_onWeeklyHoursChanged);
    on<TotalHoursChangeEvent>(_onTotalHoursChanged);
    on<MonthlyRetainerAmountChangeEvent>(_onMonthlyRetainerAmountChanged);
    on<ProjectStartDateChangeEvent>(_onStartDateChanged);
    on<PaymentCycleDaysChangeEvent>(_onPaymentCycleDaysChanged);
    on<SpecialNotesTextChangeEvent>(_onSpecialNotesChanged);
    on<MilestoneSetupEvent>(_generateMilestones);
    on<ChangeMilestoneInfoEvent>(_onMilestoneInfoChanged);
    on<RemoveMilestoneEvent>(_onRemoveMilestone);
    on<AddNewMilestoneEvent>(_onNewMilestoneAdded);
    on<AddProjectEvent>(_onAddProject);
    on<EditProjectEvent>(_onEditProject);
    on<EditProjectInitEvent>(_initEditProject);
    on<LoadOtherFieldsEvent>(_loadOtherFields);
    on<TimeMaterialMilestoneUpdatedEvent>(_onTimeMaterialMilestoneUpdated);
    add(FetchUserInfoEvent());
    add(GenerateCurrencySymbolEvent());
    add(
      ProjectStartDateChangeEvent(
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ),
      ),
    );
    add(GeneratePaymentCycleEvent());
  }

  _fetchUserInfo(
    FetchUserInfoEvent event,
    Emitter<AddProjectFieldState> _,
  ) async {
    final preference = await SharedPreferences.getInstance();
    final role = preference.getString(PreferenceConfig.userRolePref);
    final userId = preference.getString(PreferenceConfig.userIdPref);
    _profileInfo = ProfileInfo(
      userId: userId,
      role: role,
    );
  }

  _generateCurrencySymbols(
    GenerateCurrencySymbolEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    _currencySymbols
          ..add(
            DropDownModel(
              id: AppConfig.rupeeCurrencyId,
              value: AppConfig.rupeeCurrencySymbol,
            ),
          )
          ..add(
            DropDownModel(
              id: AppConfig.dollarCurrencyId,
              value: AppConfig.dollarCurrencySymbol,
              isSelected: true,
            ),
          )
        /*..add(
        DropDownModel(
          id: AppConfig.euroCurrencyId,
          value: AppConfig.euroCurrencySymbol,
        ),
      )
      ..add(
        DropDownModel(
          id: AppConfig.cadCurrencyId,
          value: AppConfig.cadCurrencySymbol,
        ),
      )*/
        ;
  }

  _generatePaymentCycles(
    GeneratePaymentCycleEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    for (int i = minPaymentCycleDays; i <= maxPaymentCycleDays; i++) {
      _paymentCycleList.add(DropDownModel(id: i, value: '$i'));
    }
    emit(PaymentCycleGeneratedState(_paymentCycleList));
  }

  _onProjectCodeTextChanged(
    ProjectCodeTextChangeEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    _projectCode = event.projectCode;
  }

  _onProjectNameTextChanged(
    ProjectNameTextChangeEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    _projectName = event.projectName;
  }

  _onBdmSelectionChanged(
    BdmInfoSelectionChangeEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    _selectedBdmUserId = event.bdmId;
  }

  _onProjectManagerInfoChanged(
    ProjectManagerInfoSelectionChangeEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    _selectedPmUserId = event.pmId;
  }

  _onProjectTypeChanged(
    ProjectTypeChangeEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    _projectTypeEnum = event.projectTypeEnum;
    emit(ProjectTypeChangeState(_projectTypeEnum));
    add(MilestoneSetupEvent());
  }

  _onProjectStatusChanged(
    ProjectStatusChangeEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    _projectStatus = event.projectStatusEnum.name;
    emit(ProjectStatusChangeState(event.projectStatusEnum));
  }

  _onTotalFixedAmountChanged(
    TotalFixedAmountChangeEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    _totalFixedAmount =
        event.amount.trim().isNotEmpty ? double.parse(event.amount.trim()) : 0;
    emit(TotalFixedAmountChangedState(_totalFixedAmount!));
  }

  _onCurrencyChanged(
    CurrencyChangeEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    _updateCurrencySymbol(event.selectedCurrencyId);
  }

  _updateCurrencySymbol(int currencyId) {
    for (int i = 0; i < _currencySymbols.length; i++) {
      _currencySymbols[i].isSelected = false;
    }
    final index = _currencySymbols.indexWhere(
      (element) => element.id == currencyId,
    );
    if (index != -1) {
      _currencySymbols[index].isSelected = true;
    } else {
      _currencySymbols[0].isSelected = true;
    }
  }

  _onHourlyRateChanged(
    HourlyRateChangeEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    _hourlyRate =
        event.rate.trim().isNotEmpty ? double.parse(event.rate.trim()) : 0;
    emit(HourlyRateChangedState(_hourlyRate!));
    _autoGenerateMilestones();
    emit(MilestoneChangedSuccessState(_milestones));
  }

  _onWeeklyHoursChanged(
    WeeklyHoursChangeEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    _weeklyHours = event.weeklyHour.trim().isNotEmpty
        ? double.parse(event.weeklyHour.trim())
        : 0;
    emit(WeeklyHoursChangedState(_weeklyHours!));
    _autoGenerateMilestones();
    emit(MilestoneChangedSuccessState(_milestones));
  }

  _onTotalHoursChanged(
    TotalHoursChangeEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    _totalHours = event.totalHours.trim().isNotEmpty
        ? double.parse(event.totalHours.trim())
        : 0;
    emit(TotalHoursChangedState(_totalHours!));
    _autoGenerateMilestones();
    emit(MilestoneChangedSuccessState(_milestones));
  }

  _onMonthlyRetainerAmountChanged(
    MonthlyRetainerAmountChangeEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    _monthlyRetainerAmount =
        event.amount.trim().isNotEmpty ? double.parse(event.amount.trim()) : 0;
    emit(MonthlyRetainerAmountChangedState(_monthlyRetainerAmount!));
    _autoGenerateMilestones();
    emit(MilestoneChangedSuccessState(_milestones));
  }

  _onStartDateChanged(
    ProjectStartDateChangeEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    final currentDate = DateTime.now();
    _projectStartDate = event.changedDate ??
        DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );
    emit(ProjectStartDateChangeState(_projectStartDate!));
    _autoGenerateMilestones();
    emit(MilestoneChangedSuccessState(_milestones));
  }

  _onPaymentCycleDaysChanged(
    PaymentCycleDaysChangeEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    for (int i = 0; i < _paymentCycleList.length; i++) {
      _paymentCycleList[i].isSelected = false;
    }
    final index = _paymentCycleList.indexWhere(
      (element) => element.id == event.paymentCycle.id,
    );
    if (index != -1) {
      _paymentCycleList[index].isSelected = true;
    }
    final days = event.paymentCycle.value;
    if (days.trim().isNotEmpty) {
      _paymentCycle = int.parse(days.trim());
    }
  }

  _onSpecialNotesChanged(
    SpecialNotesTextChangeEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    _specialNotes = event.notes;
  }

  _onMilestoneInfoChanged(
    ChangeMilestoneInfoEvent event,
    Emitter<AddProjectFieldState> emit,
  ) async {
    if (!event.isAmountChanged) {
      FocusManager.instance.rootScope.unfocus();
    }
    _isMilestoneChangedByUser = true;
    final index = _milestones.indexWhere(
      (milestone) => milestone.id == event.milestoneInfo.id,
    );
    if (index != -1) {
      _milestones[index] = event.milestoneInfo;
      if (!event.isAmountChanged) {
        FocusManager.instance.primaryFocus?.unfocus();
        _sortMilestones();
        emit(MilestoneChangedSuccessState(_milestones));
        final sortedIndex = _milestones.indexWhere(
          (milestone) => milestone.id == event.milestoneInfo.id,
        );
        await Future.delayed(
          const Duration(milliseconds: 500),
          () {
            FocusScope.of(navigatorKey.currentContext!)
                .requestFocus(_milestones[sortedIndex].amountFieldFocusNode);
          },
        );
      }
      AppUtils.fieldCursorPositionAtLast(
        _milestones[index].amountFieldController,
      );
    }
  }

  _sortMilestones() {
    _milestones.sort(
      (a, b) {
        if (a.dateTime != null && b.dateTime != null) {
          return a.dateTime!.compareTo(b.dateTime!);
        }
        return -1;
      },
    );
    // Updating sequence of milestone.
    // This will be used when drag and drop feature with milestone list
    for (int i = 0; i < _milestones.length; i++) {
      _milestones[i].sequence = i;
    }
  }

  _onRemoveMilestone(
    RemoveMilestoneEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    _isMilestoneChangedByUser = true;
    if (_milestones.isNotEmpty) {
      final indexToDelete =
          _milestones.indexWhere((element) => element.id == event.milestoneId);
      if (indexToDelete != -1) {
        if (_milestones[indexToDelete].amountFieldController != null) {
          _milestones[indexToDelete].amountFieldController?.dispose();
        }
        if (_milestones[indexToDelete].amountFieldFocusNode != null) {
          _milestones[indexToDelete].amountFieldFocusNode?.dispose();
          _milestones[indexToDelete].amountFieldFocusNode = null;
        }
        _milestones.removeAt(indexToDelete);
      }
    }
    if (_milestones.isEmpty) {
      _isMilestoneChangedByUser = false;
      // If all milestone removed manually then add new empty milestone
      _addNewMilestone();
    }
    emit(MilestoneRemovedState(_milestones));
  }

  _onNewMilestoneAdded(
    AddNewMilestoneEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    _isMilestoneChangedByUser = true;
    _autoGenerateMilestones(
      fromAddNewMilestoneButton: true,
    );
    emit(NewMilestoneAddedState(_milestones));
  }

  _addNewMilestone({
    DateTime? dateTime,
    double? amount,
  }) {
    final timeStamp = DateTime.now().millisecondsSinceEpoch;
    int id = _milestones.length;
    _milestones.add(
      MilestoneInfo(
        id: id,
        dateTime: dateTime,
        milestoneAmount: amount,
        createdAt: timeStamp,
        updatedAt: timeStamp,
        amountFieldFocusNode: FocusNode(),
      )..refreshAmountInController(),
    );
    _sortMilestones();
  }

  _generateMilestones(
    MilestoneSetupEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    _autoGenerateMilestones(isProjectTypeChanged: true);
    emit(MilestoneSetupGeneratedState(_milestones));
  }

  _autoGenerateMilestones({
    bool fromAddNewMilestoneButton = false,
    bool isProjectTypeChanged = false,
  }) {
// Milestone will autoGenerate only if:
// 1. no milestone available
// 2. milestone is not changed by user and any field changed
// 3. milestone with empty details available and changes on fields
// 4. milestone is adding by user by clicking on add button
    bool isNeedToAutoGenerate = fromAddNewMilestoneButton ||
        _milestones.isEmpty ||
        !_isMilestoneChangedByUser;
    if (!isNeedToAutoGenerate) {
      isNeedToAutoGenerate = _milestones.length == 1 &&
          _milestones[0].dateTime == null &&
          _milestones[0].milestoneAmount == null;
    }
    if (isNeedToAutoGenerate) {
      if (!fromAddNewMilestoneButton) {
        if (!isProjectTypeChanged) {
          _disposeMilestoneOnClear();
          _milestones.clear();
        }
      }
      if (!fromAddNewMilestoneButton &&
          _milestones.isNotEmpty &&
          _milestones.every((element) =>
              element.dateTime == null && element.milestoneAmount == null)) {
        _disposeMilestoneOnClear();
        _milestones.clear();
      }

      if (_projectTypeEnum == ProjectTypeEnum.fixed) {
        _generateFixedTypeMilestone();
      } else if (_projectTypeEnum == ProjectTypeEnum.timeAndMaterial) {
        if (_weeklyHours != null && _weeklyHours! > 0) {
          _generateTimeAndMaterialMilestoneWithWeek(fromAddNewMilestoneButton);
        } else {
          _generateTimeAndMaterialMilestone();
        }
      } else if (_projectTypeEnum == ProjectTypeEnum.retainer) {
        _generateRetainerMilestone();
      } else if (_projectTypeEnum == ProjectTypeEnum.nonBillable) {
        _addNewMilestone();
      }
    }
  }

  _disposeMilestoneOnClear() {
    if (_milestones.isNotEmpty) {
      for (var element in _milestones) {
        if (element.amountFieldFocusNode != null) {
          element.amountFieldFocusNode!.dispose();
          element.amountFieldFocusNode = null;
        }
        if (element.amountFieldController != null) {
          element.amountFieldController!.dispose();
        }
      }
    }
  }

  _generateFixedTypeMilestone() {
    _addNewMilestone();
  }

  _generateTimeAndMaterialMilestone() {
    if (_hourlyRate != null &&
        _totalHours != null &&
        _projectStartDate != null) {
      DateTime dateTime = _projectStartDate!;
      if (_milestones.isNotEmpty && _milestones.last.dateTime != null) {
        dateTime = _milestones.last.dateTime!;
      }
      final amount = _hourlyRate! * _totalHours!;
      _addNewMilestone(
        dateTime: AppUtils.getNextWeekDate(dateTime),
        amount: amount,
      );
    } else {
      _addNewMilestone();
    }
  }

  _generateTimeAndMaterialMilestoneWithWeek(
    bool fromAddNewMilestoneButton,
  ) async {
    if (_hourlyRate != null &&
        _totalHours != null &&
        _weeklyHours != null &&
        _projectStartDate != null) {
      if (fromAddNewMilestoneButton) {
        DateTime dateTime = _projectStartDate!;
        if (_milestones.isNotEmpty && _milestones.last.dateTime != null) {
          dateTime = _milestones.last.dateTime!;
        }
        final amount = _hourlyRate! * _weeklyHours!;
        _addNewMilestone(
          dateTime: AppUtils.getNextWeekDate(dateTime),
          amount: amount,
        );
      } else {
        if (_weeklyCalcDebounce?.isActive ?? false) {
          _weeklyCalcDebounce?.cancel();
        }
        _weeklyCalcDebounce = Timer(
          const Duration(seconds: 1),
          () {
            final totalWeek = (_totalHours! / _weeklyHours!).ceil();
            double totalAmount = _totalHours! * _hourlyRate!;
            final subscription =
                GenerateWeeklyMilestones.callIsolateToGenerateWeeklyMilestones(
              WeeklyMilestoneInput(
                weeklyHours: _weeklyHours!,
                hourlyRates: _hourlyRate!,
                totalWeek: totalWeek,
                totalAmount: totalAmount,
                projectStartDate: _projectStartDate!,
                milestones: _milestones,
              ),
            );
            subscription.listen(
              (generatedMilestones) async {
                _milestones.clear();
                await Future.forEach(
                  generatedMilestones,
                  (element) {
                    element.amountFieldFocusNode = FocusNode();
                    element.refreshAmountInController();
                    _milestones.add(element);
                  },
                );
                add(TimeMaterialMilestoneUpdatedEvent());
              },
            );
          },
        );
      }
    } else {
      _addNewMilestone();
    }
  }

  _onTimeMaterialMilestoneUpdated(
    TimeMaterialMilestoneUpdatedEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    emit(MilestoneChangedSuccessState(_milestones));
  }

  _generateRetainerMilestone() {
    if (_monthlyRetainerAmount != null && _projectStartDate != null) {
      DateTime dateTime = _projectStartDate!;
      if (_milestones.isNotEmpty && _milestones.last.dateTime != null) {
        dateTime = _milestones.last.dateTime!;
      }
      _addNewMilestone(
        dateTime: AppUtils.getNextMonthRetainerDate(dateTime),
        amount: _monthlyRetainerAmount,
      );
    } else {
      _addNewMilestone();
    }
  }

  _onAddProject(AddProjectEvent event, Emitter<AddProjectFieldState> emit) {
    if (_projectCode == null || _projectCode.toString().trim().isEmpty) {
      emit(FieldRequiredErrorState(ProjectFieldValidationEnum.projectNo));
    } else if (_projectName == null || _projectName.toString().trim().isEmpty) {
      emit(FieldRequiredErrorState(ProjectFieldValidationEnum.projectName));
    } else {
      final milestoneInfo =
          getMilestones().map((e) => MilestoneInfo.copy(e)).toList();
      final isAnyMilestoneInvalid = _isValidMilestoneDates(milestoneInfo);
      if (!isAnyMilestoneInvalid) {
        emit(InvalidMilestoneDateErrorState());
        return;
      }
      final projectInfo = _createProject();
      emit(
        SaveProjectState(
          projectInfo,
          milestoneInfo,
          false,
        ),
      );
    }
  }

  bool _isValidMilestoneDates(List<MilestoneInfo> milestoneInfo) {
    bool isAnyMilestoneInvalid = true;
    if (milestoneInfo.isNotEmpty) {
      for (int i = 0; i < milestoneInfo.length; i++) {
        final info = milestoneInfo[i];
        if (info.dateTime != null && info.milestoneAmount != null) {
          isAnyMilestoneInvalid = MilestoneUtils.isValidMilestoneDate(
            projectStartDate: _projectStartDate,
            milestoneDate: info.dateTime,
          );
          if (!isAnyMilestoneInvalid) {
            break;
          }
        }
      }
    }
    return isAnyMilestoneInvalid;
  }

  String? getSelectedBDM() {
    return _selectedBdmUserId;
  }

  String? getSelectedPM() {
    return _selectedPmUserId;
  }

  ProjectInfo _createProject() {
    final timeStamp = DateTime.now().millisecondsSinceEpoch;
    return ProjectInfo(
      projectCode: _projectCode?.trim(),
      projectCodeInt: int.tryParse(_projectCode?.trim() ?? ''),
      projectName: _projectName?.trim(),
      projectStatus: _projectStatus ?? ProjectStatusEnum.active.name,
      bdmUserId: _selectedBdmUserId,
      pmUserId: _selectedPmUserId,
      country: null,
      currency: _getSelectedCurrency(),
      projectType: _projectTypeEnum.name,
      totalFixedAmount: _projectTypeEnum == ProjectTypeEnum.fixed
          ? _totalFixedAmount?.toDouble()
          : null,
      hourlyRate: _projectTypeEnum == ProjectTypeEnum.timeAndMaterial
          ? _hourlyRate
          : null,
      weeklyHours: _projectTypeEnum == ProjectTypeEnum.timeAndMaterial
          ? _weeklyHours
          : null,
      totalHours: _projectTypeEnum == ProjectTypeEnum.timeAndMaterial
          ? _totalHours
          : null,
      monthlyAmount: _projectTypeEnum == ProjectTypeEnum.retainer
          ? _monthlyRetainerAmount?.toDouble()
          : null,
      projectStartDate: _projectStartDate?.millisecondsSinceEpoch,
      receivedAmount: 0,
      specialNotes: _specialNotes,
      paymentCycle: _paymentCycle,
      createdAt: timeStamp,
      updatedAt: timeStamp,
    );
  }

  String _getSelectedCurrency() {
    final symbol = _currencySymbols.firstWhere((element) => element.isSelected);
    if (symbol.id == AppConfig.dollarCurrencyId) {
      return CurrencyEnum.dollars.name;
    } else if (symbol.id == AppConfig.rupeeCurrencyId) {
      return CurrencyEnum.rupees.name;
    } else if (symbol.id == AppConfig.euroCurrencyId) {
      return CurrencyEnum.euros.name;
    } else if (symbol.id == AppConfig.cadCurrencyId) {
      return CurrencyEnum.CAD.name;
    }
    return AppConfig.defaultCurrencyEnum.name;
  }

  List<MilestoneInfo> getMilestones() {
    return _milestones;
  }

  _initEditProject(
    EditProjectInitEvent event,
    Emitter<AddProjectFieldState> emit,
  ) {
    _editProject = event.projectInfo;
    _projectCode = _editProject.projectCode;
    _projectName = _editProject.projectName;
    _selectedBdmUserId = _editProject.bdmUserId;
    _selectedPmUserId = _editProject.pmUserId;
    _isMilestoneChangedByUser = true;

    _projectTypeEnum = _getProjectTypeEnum(_editProject.projectType);
    emit(ProjectTypeChangeState(_projectTypeEnum));

    _totalFixedAmount = _editProject.totalFixedAmount;
    _monthlyRetainerAmount = _editProject.monthlyAmount;
    _hourlyRate = _editProject.hourlyRate;
    _weeklyHours = _editProject.weeklyHours;
    _totalHours = _editProject.totalHours;
    _projectStatus = _editProject.projectStatus;

    _updateCurrencySymbolOnEdit(_editProject.currency);

    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    _projectStartDate = DateTime.fromMillisecondsSinceEpoch(
      _editProject.projectStartDate ?? currentTimestamp,
    );
    emit(ProjectStartDateChangeState(_projectStartDate!));

    _paymentCycle = _editProject.paymentCycle;
    if (_paymentCycle != null) {
      for (int i = 0; i < _paymentCycleList.length; i++) {
        _paymentCycleList[i].isSelected = false;
      }
      final index = _paymentCycleList.indexWhere(
        (element) => element.value == _paymentCycle.toString(),
      );
      if (index != -1) {
        _paymentCycleList[index].isSelected = true;
      }
    }
    _specialNotes = _editProject.specialNotes;

    _milestones.clear();
    if (event.milestones.isNotEmpty) {
      // copy of list : copy will be created either spread operator or List.from()
      _milestones = event.milestones
          .map(
            (e) => MilestoneInfo.copy(e)
              ..amountFieldFocusNode = FocusNode()
              ..refreshAmountInController(),
          )
          .toList();
      // currently we don't have notes field in edit project screen
      // so removing notes from milestone
      // as at time of edit previous notes are set to new milestone
      final isAnyMilestoneWithNotes = _milestones.any(
        (element) => element.notes != null,
      );
      if (isAnyMilestoneWithNotes) {
        for (int i = 0; i < _milestones.length; i++) {
          _milestones[i].notes = null;
        }
      }
    } else {
      // if no milestones then show one default milestone
      _addNewMilestone();
    }
    emit(MilestoneSetupGeneratedState(_milestones));
  }

  _updateCurrencySymbolOnEdit(String? currency) {
    for (int i = 0; i < _currencySymbols.length; i++) {
      _currencySymbols[i].isSelected = false;
    }
    int selectedId = AppConfig.defaultCurrencyId;
    if (currency == CurrencyEnum.dollars.name) {
      selectedId = AppConfig.dollarCurrencyId;
    } else if (currency == CurrencyEnum.rupees.name) {
      selectedId = AppConfig.rupeeCurrencyId;
    } else if (currency == CurrencyEnum.euros.name) {
      selectedId = AppConfig.euroCurrencyId;
    }
    final index = _currencySymbols.indexWhere(
      (element) => element.id == selectedId,
    );
    if (index != -1) {
      _currencySymbols[index].isSelected = true;
    } else {
      _currencySymbols[0].isSelected = true;
    }
  }

  _onEditProject(EditProjectEvent event, Emitter<AddProjectFieldState> emit) {
    final milestoneInfo =
        getMilestones().map((e) => MilestoneInfo.copy(e)).toList();
    final isAnyMilestoneInvalid = _isValidMilestoneDates(milestoneInfo);
    if (!isAnyMilestoneInvalid) {
      emit(InvalidMilestoneDateErrorState());
      return;
    }
    final projectInfo = _editProjectInfo();
    emit(
      SaveProjectState(
        projectInfo,
        milestoneInfo,
        true,
      ),
    );
  }

  ProjectInfo _editProjectInfo() {
    final timeStamp = DateTime.now().millisecondsSinceEpoch;
    return ProjectInfo(
      projectId: _editProject.projectId,
      projectCode: _projectCode?.trim(),
      projectCodeInt: int.tryParse(_projectCode?.trim() ?? ''),
      projectName: _projectName?.trim(),
      projectStatus: _projectStatus,
      bdmUserId: _selectedBdmUserId,
      pmUserId: _selectedPmUserId,
      country: null,
      currency: _getSelectedCurrency(),
      projectType: _projectTypeEnum.name,
      totalFixedAmount: _projectTypeEnum == ProjectTypeEnum.fixed
          ? _totalFixedAmount?.toDouble()
          : null,
      hourlyRate: _projectTypeEnum == ProjectTypeEnum.timeAndMaterial
          ? _hourlyRate
          : null,
      weeklyHours: _projectTypeEnum == ProjectTypeEnum.timeAndMaterial
          ? _weeklyHours
          : null,
      totalHours: _projectTypeEnum == ProjectTypeEnum.timeAndMaterial
          ? _totalHours
          : null,
      monthlyAmount: _projectTypeEnum == ProjectTypeEnum.retainer
          ? _monthlyRetainerAmount?.toDouble()
          : null,
      projectStartDate: _projectStartDate?.millisecondsSinceEpoch,
      receivedAmount: _editProject.receivedAmount,
      specialNotes: _specialNotes,
      paymentCycle: _paymentCycle,
      milestoneId: _editProject.milestoneId,
      createdBy: _editProject.createdBy,
      createdByName: _editProject.createdByName,
      projectAvailableFor: _editProject.projectAvailableFor,
      createdAt: _editProject.createdAt,
      updatedAt: timeStamp,
    );
  }

  ProjectTypeEnum _getProjectTypeEnum(String? name) {
    if (name == ProjectTypeEnum.fixed.name) {
      return ProjectTypeEnum.fixed;
    } else if (name == ProjectTypeEnum.timeAndMaterial.name) {
      return ProjectTypeEnum.timeAndMaterial;
    } else if (name == ProjectTypeEnum.retainer.name) {
      return ProjectTypeEnum.retainer;
    }
    return ProjectTypeEnum.nonBillable;
  }

  _loadOtherFields(
    LoadOtherFieldsEvent event,
    Emitter<AddProjectFieldState> emit,
  ) async {
    emit(LoadOtherFieldsState());
    emit(ProjectTypeChangeState(_projectTypeEnum));
  }

  DateTime? getProjectStartDate() {
    return _projectStartDate;
  }

  String? getProjectStatus() {
    return _projectStatus;
  }

  List<DropDownModel> getPaymentCycle() {
    return _paymentCycleList;
  }

  List<DropDownModel> getCurrencySymbols() {
    return _currencySymbols;
  }

  ProfileInfo? getCurrentUserRole() {
    return _profileInfo;
  }

  @override
  Future<void> close() {
    if (_weeklyCalcDebounce?.isActive ?? false) {
      _weeklyCalcDebounce?.cancel();
    }
    _disposeMilestoneOnClear();
    return super.close();
  }
}
