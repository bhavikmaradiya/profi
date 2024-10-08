part of 'filter_bloc.dart';

abstract class FilterEvent {}

class FilterCriteriaGenerationEvent extends FilterEvent {
  final AppLocalizations appLocalizations;
  final AppliedFilterInfo? appliedFilterInfo;

  FilterCriteriaGenerationEvent(
    this.appLocalizations,
    this.appliedFilterInfo,
  );
}

class FilterCriteriaSelectionChangeEvent extends FilterEvent {
  final FilterCriteriaEnum criteriaEnum;
  final int selectedIndex;

  FilterCriteriaSelectionChangeEvent(this.criteriaEnum, this.selectedIndex);
}

class FilterApplyEvent extends FilterEvent {}

class FilterClearEvent extends FilterEvent {}
