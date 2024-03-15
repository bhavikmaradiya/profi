part of 'milestone_operations_bloc.dart';

abstract class MilestoneOperationsState {}

class MilestoneOperationsInitialState extends MilestoneOperationsState {}

class MilestonePaidSuccessState extends MilestoneOperationsState {}

class MilestoneUpdatedState extends MilestoneOperationsState {
  final bool isNewMilestoneCreated;

  MilestoneUpdatedState(this.isNewMilestoneCreated);
}

class MilestoneDeletedState extends MilestoneOperationsState {}

class MilestoneUnPaidSuccessState extends MilestoneOperationsState {}

class MilestoneCurrencyChangedState extends MilestoneOperationsState {
  final CurrencyEnum currencyEnum;

  MilestoneCurrencyChangedState(this.currencyEnum);
}

class MilestoneInvoicedChangeState extends MilestoneOperationsState {
  final bool isInvoiced;

  MilestoneInvoicedChangeState(this.isInvoiced);
}
