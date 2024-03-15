import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../config/app_config.dart';
import '../../enums/filter_criteria_enum.dart';
import '../../enums/filter_sort_by_enum.dart';
import '../../enums/project_status_enum.dart';
import '../../enums/project_type_enum.dart';
import '../model/applied_filter_info.dart';
import '../model/filter_model.dart';

part 'filter_event.dart';

part 'filter_state.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  late List<FilterModel> _sortByList;
  late List<FilterModel> _statusList;
  late List<FilterModel> _typeList;
  AppliedFilterInfo? _appliedFilterInfo;

  FilterBloc() : super(FilterInitialState()) {
    on<FilterCriteriaGenerationEvent>(_generateFilterCriteria);
    on<FilterCriteriaSelectionChangeEvent>(_onFilterCriteriaSelectionChanged);
    on<FilterApplyEvent>(_onApplyFilter);
    on<FilterClearEvent>(_onClearFilter);
  }

  _generateFilterCriteria(
    FilterCriteriaGenerationEvent event,
    Emitter<FilterState> emit,
  ) {
    _appliedFilterInfo = event.appliedFilterInfo;
    if (_appliedFilterInfo == null) {
      _generateSortByList(event.appLocalizations);
      _generateStatusList(event.appLocalizations);
      _generateTypeList(event.appLocalizations);
    } else {
      _generateFromAppliedList();
    }
    emit(
      FilterCriteriaGeneratedState(
        _sortByList,
        _statusList,
        _typeList,
      ),
    );
  }

  _generateSortByList(AppLocalizations appLocalizations) {
    _sortByList = [];
    _sortByList.add(
      FilterModel(
        filterEnum: FilterSortByEnum.sortByProjectCode,
        value: appLocalizations.projectNo,
        isSelected:
            AppConfig.defaultSortBy == FilterSortByEnum.sortByProjectCode,
      ),
    );
    _sortByList.add(
      FilterModel(
        filterEnum: FilterSortByEnum.sortByProjectName,
        value: appLocalizations.projectName,
        isSelected:
            AppConfig.defaultSortBy == FilterSortByEnum.sortByProjectName,
      ),
    );
  }

  _generateStatusList(AppLocalizations appLocalizations) {
    _statusList = [];
    _statusList.add(
      FilterModel(
        filterEnum: ProjectStatusEnum.active,
        value: appLocalizations.active,
        isSelected: true,
      ),
    );
    _statusList.add(
      FilterModel(
        filterEnum: ProjectStatusEnum.onHold,
        value: appLocalizations.onHold,
      ),
    );
    _statusList.add(
      FilterModel(
        filterEnum: ProjectStatusEnum.closed,
        value: appLocalizations.closed,
      ),
    );
    _statusList.add(
      FilterModel(
        filterEnum: ProjectStatusEnum.dropped,
        value: appLocalizations.dropped,
      ),
    );
  }

  _generateTypeList(AppLocalizations appLocalizations) {
    _typeList = [];
    _typeList.add(
      FilterModel(
        filterEnum: ProjectTypeEnum.fixed,
        value: appLocalizations.fixed,
        isSelected: true,
      ),
    );
    _typeList.add(
      FilterModel(
        filterEnum: ProjectTypeEnum.timeAndMaterial,
        value: appLocalizations.timeAndMaterial,
        isSelected: true,
      ),
    );
    _typeList.add(
      FilterModel(
        filterEnum: ProjectTypeEnum.retainer,
        value: appLocalizations.retainer,
        isSelected: true,
      ),
    );
    _typeList.add(
      FilterModel(
        filterEnum: ProjectTypeEnum.nonBillable,
        value: appLocalizations.nonBillable,
        isSelected: true,
      ),
    );
  }

  _generateFromAppliedList() {
    _sortByList = _appliedFilterInfo!.sortByList;
    _statusList = _appliedFilterInfo!.statusList;
    _typeList = _appliedFilterInfo!.typeList;
  }

  _onFilterCriteriaSelectionChanged(
    FilterCriteriaSelectionChangeEvent event,
    Emitter<FilterState> emit,
  ) {
    if (event.criteriaEnum == FilterCriteriaEnum.sortBy) {
      for (int i = 0; i < _sortByList.length; i++) {
        _sortByList[i].isSelected = false;
      }
      _sortByList[event.selectedIndex].isSelected = true;
      emit(FilterSortByChangedState(_sortByList));
    } else if (event.criteriaEnum == FilterCriteriaEnum.status) {
      _statusList[event.selectedIndex].isSelected =
          !_statusList[event.selectedIndex].isSelected;
      emit(FilterStatusChangedState(_statusList));
    } else if (event.criteriaEnum == FilterCriteriaEnum.type) {
      _typeList[event.selectedIndex].isSelected =
          !_typeList[event.selectedIndex].isSelected;
      emit(FilterTypeChangedState(_typeList));
    }
  }

  _onApplyFilter(
    FilterApplyEvent event,
    Emitter<FilterState> emit,
  ) {
    _appliedFilterInfo = AppliedFilterInfo(
      sortByList: _sortByList,
      statusList: _statusList,
      typeList: _typeList,
    );
    emit(FilterAppliedState(_appliedFilterInfo!));
  }

  _onClearFilter(
    FilterClearEvent event,
    Emitter<FilterState> emit,
  ) {
    for (int i = 0; i < _sortByList.length; i++) {
      _sortByList[i].isSelected =
          _sortByList[i].filterEnum == FilterSortByEnum.sortByProjectCode;
    }
    for (int i = 0; i < _statusList.length; i++) {
      _statusList[i].isSelected =
          _statusList[i].filterEnum == ProjectStatusEnum.active;
    }
    for (int i = 0; i < _typeList.length; i++) {
      _typeList[i].isSelected = true;
    }
    _appliedFilterInfo = null;
    emit(FilterClearedState());
  }
}
