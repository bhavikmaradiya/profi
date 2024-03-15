part of 'add_project_field_bloc.dart';

abstract class AddProjectFieldEvent {}

class AddProjectInitialEvent extends AddProjectFieldEvent {}

class FetchUserInfoEvent extends AddProjectFieldEvent {}

class GenerateCurrencySymbolEvent extends AddProjectFieldEvent {}

class GeneratePaymentCycleEvent extends AddProjectFieldEvent {}

class ProjectCodeTextChangeEvent extends AddProjectFieldEvent {
  final String projectCode;

  ProjectCodeTextChangeEvent(this.projectCode);
}

class ProjectNameTextChangeEvent extends AddProjectFieldEvent {
  final String projectName;

  ProjectNameTextChangeEvent(this.projectName);
}

class BdmInfoSelectionChangeEvent extends AddProjectFieldEvent {
  final String? bdmId;

  BdmInfoSelectionChangeEvent(this.bdmId);
}

class ProjectManagerInfoSelectionChangeEvent extends AddProjectFieldEvent {
  final String? pmId;

  ProjectManagerInfoSelectionChangeEvent(this.pmId);
}

class ProjectTypeChangeEvent extends AddProjectFieldEvent {
  final ProjectTypeEnum projectTypeEnum;

  ProjectTypeChangeEvent(this.projectTypeEnum);
}

class ProjectStatusChangeEvent extends AddProjectFieldEvent {
  final ProjectStatusEnum projectStatusEnum;

  ProjectStatusChangeEvent(this.projectStatusEnum);
}

class TotalFixedAmountChangeEvent extends AddProjectFieldEvent {
  final String amount;

  TotalFixedAmountChangeEvent(this.amount);
}

class CurrencyChangeEvent extends AddProjectFieldEvent {
  final int selectedCurrencyId;

  CurrencyChangeEvent(this.selectedCurrencyId);
}

class HourlyRateChangeEvent extends AddProjectFieldEvent {
  final String rate;

  HourlyRateChangeEvent(this.rate);
}

class WeeklyHoursChangeEvent extends AddProjectFieldEvent {
  final String weeklyHour;

  WeeklyHoursChangeEvent(this.weeklyHour);
}

class TotalHoursChangeEvent extends AddProjectFieldEvent {
  final String totalHours;

  TotalHoursChangeEvent(this.totalHours);
}

class MonthlyRetainerAmountChangeEvent extends AddProjectFieldEvent {
  final String amount;

  MonthlyRetainerAmountChangeEvent(this.amount);
}

class ProjectStartDateChangeEvent extends AddProjectFieldEvent {
  final DateTime? changedDate;

  ProjectStartDateChangeEvent(this.changedDate);
}

class PaymentCycleDaysChangeEvent extends AddProjectFieldEvent {
  final DropDownModel paymentCycle;

  PaymentCycleDaysChangeEvent(this.paymentCycle);
}

class SpecialNotesTextChangeEvent extends AddProjectFieldEvent {
  final String notes;

  SpecialNotesTextChangeEvent(this.notes);
}

class MilestoneSetupEvent extends AddProjectFieldEvent {}

class RemoveMilestoneEvent extends AddProjectFieldEvent {
  final int milestoneId;

  RemoveMilestoneEvent(this.milestoneId);
}

class ChangeMilestoneInfoEvent extends AddProjectFieldEvent {
  final MilestoneInfo milestoneInfo;
  final bool isAmountChanged;
  final bool isEdit;

  ChangeMilestoneInfoEvent(
    this.milestoneInfo,
    this.isAmountChanged,
    this.isEdit,
  );
}

class AddNewMilestoneEvent extends AddProjectFieldEvent {}

class AddProjectEvent extends AddProjectFieldEvent {}

class EditProjectEvent extends AddProjectFieldEvent {}

class EditProjectInitEvent extends AddProjectFieldEvent {
  final ProjectInfo projectInfo;
  final List<MilestoneInfo> milestones;

  EditProjectInitEvent(this.projectInfo, this.milestones);
}

class LoadOtherFieldsEvent extends AddProjectFieldEvent {}

class TimeMaterialMilestoneUpdatedEvent extends AddProjectFieldEvent {}
