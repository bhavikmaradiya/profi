part of 'add_project_field_bloc.dart';

abstract class AddProjectFieldState {}

class AddProjectFieldInitialState extends AddProjectFieldState {}

class BDMListGeneratedState extends AddProjectFieldState {
  final List<DropDownModel> bdmList;
  final DropDownModel? defaultSelected;

  BDMListGeneratedState(
    this.bdmList,
    this.defaultSelected,
  );
}

class PMListGeneratedState extends AddProjectFieldState {
  final List<DropDownModel> pmList;
  final DropDownModel? defaultSelected;

  PMListGeneratedState(
    this.pmList,
    this.defaultSelected,
  );
}

class CurrencySymbolGeneratedState extends AddProjectFieldState {
  final List<DropDownModel> currencySymbols;

  CurrencySymbolGeneratedState(this.currencySymbols);
}

class PaymentCycleGeneratedState extends AddProjectFieldState {
  final List<DropDownModel> paymentCycleList;

  PaymentCycleGeneratedState(this.paymentCycleList);
}

class ProjectTypeChangeState extends AddProjectFieldState {
  final ProjectTypeEnum projectTypeEnum;

  ProjectTypeChangeState(this.projectTypeEnum);
}

class ProjectStatusChangeState extends AddProjectFieldState {
  final ProjectStatusEnum projectStatusEnum;

  ProjectStatusChangeState(this.projectStatusEnum);
}

class TotalFixedAmountChangedState extends AddProjectFieldState {
  final double amount;

  TotalFixedAmountChangedState(this.amount);
}

class HourlyRateChangedState extends AddProjectFieldState {
  final double rate;

  HourlyRateChangedState(this.rate);
}

class WeeklyHoursChangedState extends AddProjectFieldState {
  final double weeklyHour;

  WeeklyHoursChangedState(this.weeklyHour);
}

class TotalHoursChangedState extends AddProjectFieldState {
  final double totalHours;

  TotalHoursChangedState(this.totalHours);
}

class MonthlyRetainerAmountChangedState extends AddProjectFieldState {
  final double amount;

  MonthlyRetainerAmountChangedState(this.amount);
}

class ProjectStartDateChangeState extends AddProjectFieldState {
  final DateTime selectedDate;

  ProjectStartDateChangeState(this.selectedDate);
}

class MilestoneSetupGeneratedState extends AddProjectFieldState {
  final List<MilestoneInfo> milestones;

  MilestoneSetupGeneratedState(this.milestones);
}

class MilestoneRemovedState extends AddProjectFieldState {
  final List<MilestoneInfo> milestones;

  MilestoneRemovedState(this.milestones);
}

class MilestoneChangedSuccessState extends AddProjectFieldState {
  final List<MilestoneInfo> milestones;

  MilestoneChangedSuccessState(this.milestones);
}

class NewMilestoneAddedState extends AddProjectFieldState {
  final List<MilestoneInfo> milestones;

  NewMilestoneAddedState(this.milestones);
}

class SaveProjectState extends AddProjectFieldState {
  final ProjectInfo projectInfo;
  final List<MilestoneInfo> milestoneInfo;
  final bool isEdited;

  SaveProjectState(
    this.projectInfo,
    this.milestoneInfo,
    this.isEdited,
  );
}

class LoadOtherFieldsState extends AddProjectFieldState {}

class FieldRequiredErrorState extends AddProjectFieldState {
  final ProjectFieldValidationEnum validationEnum;

  FieldRequiredErrorState(this.validationEnum);
}

class InvalidMilestoneDateErrorState extends AddProjectFieldState {}
