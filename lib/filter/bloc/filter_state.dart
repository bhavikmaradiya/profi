part of 'filter_bloc.dart';

abstract class FilterState {}

class FilterInitialState extends FilterState {}

class FilterCriteriaGeneratedState extends FilterState {
  final List<FilterModel> sortBy;
  final List<FilterModel> status;
  final List<FilterModel> type;

  FilterCriteriaGeneratedState(this.sortBy, this.status, this.type);
}

class FilterSortByChangedState extends FilterState {
  final List<FilterModel> sortBy;

  FilterSortByChangedState(this.sortBy);
}

class FilterStatusChangedState extends FilterState {
  final List<FilterModel> status;

  FilterStatusChangedState(this.status);
}

class FilterTypeChangedState extends FilterState {
  final List<FilterModel> type;

  FilterTypeChangedState(this.type);
}

class FilterAppliedState extends FilterState {
  final AppliedFilterInfo appliedFilterInfo;

  FilterAppliedState(this.appliedFilterInfo);
}

class FilterClearedState extends FilterState {}
