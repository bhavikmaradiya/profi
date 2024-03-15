part of 'milestone_operations_bloc.dart';

abstract class MilestoneOperationsEvent {}

class MilestoneOperationsInitEvent extends MilestoneOperationsEvent {}

class MilestoneMarkAsPaidEvent extends MilestoneOperationsEvent {
  final TransactionInfo transactionInfo;
  final ProjectInfo projectInfo;
  final MilestoneInfo milestoneInfo;

  MilestoneMarkAsPaidEvent(
    this.transactionInfo,
    this.projectInfo,
    this.milestoneInfo,
  );
}

class MultipleMilestonesMarkAsPaidEvent extends MilestoneOperationsEvent {
  final ProjectInfo projectInfo;
  final List<MultipleMilestoneInfo> multipleMilestoneInfo;

  MultipleMilestonesMarkAsPaidEvent(
    this.projectInfo,
    this.multipleMilestoneInfo,
  );
}

class MilestoneUpdateEvent extends MilestoneOperationsEvent {
  final ProjectInfo projectInfo;
  final MilestoneInfo? milestoneInfo;
  final double? milestoneAmount;
  final int? milestoneDate;
  final String? notes;
  final bool? isNewMilestone;

  MilestoneUpdateEvent({
    required this.projectInfo,
    required this.milestoneInfo,
    this.milestoneAmount,
    this.milestoneDate,
    this.notes,
    this.isNewMilestone,
  });
}

class MilestoneDeleteEvent extends MilestoneOperationsEvent {
  final ProjectInfo projectInfo;
  final String? milestoneId;
  final double? receivedMilestoneAmount;

  MilestoneDeleteEvent(
    this.projectInfo,
    this.milestoneId,
    this.receivedMilestoneAmount,
  );
}

class MilestoneMarkAsUnPaidEvent extends MilestoneOperationsEvent {
  final TransactionInfo transactionInfo;
  final double? milestoneAmount;
  final int? milestoneDate;
  final String? notes;
  final ProjectInfo projectInfo;
  final MilestoneInfo milestoneInfo;

  MilestoneMarkAsUnPaidEvent({
    required this.projectInfo,
    required this.milestoneInfo,
    required this.transactionInfo,
    this.milestoneAmount,
    this.milestoneDate,
    this.notes,
  });
}

class MultipleMilestonesMarkAsUnPaidEvent extends MilestoneOperationsEvent {
  final ProjectInfo projectInfo;
  final List<MultipleMilestoneInfo> multipleMilestoneInfo;

  MultipleMilestonesMarkAsUnPaidEvent(
    this.projectInfo,
    this.multipleMilestoneInfo,
  );
}

class MilestoneCurrencyChangeEvent extends MilestoneOperationsEvent {}

class MilestoneInvoicedChangeEvent extends MilestoneOperationsEvent {
  final ProjectInfo projectInfo;
  final MilestoneInfo milestoneInfo;

  MilestoneInvoicedChangeEvent(this.projectInfo, this.milestoneInfo);
}
