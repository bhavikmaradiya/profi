import 'package:flutter_bloc/flutter_bloc.dart';

import '../../add_project/model/milestone_info.dart';
import '../../enums/error_enum.dart';
import '../../project_list/utils/milestone_utils.dart';
import '../model/transaction_enum.dart';

part 'dialog_event.dart';

part 'dialog_state.dart';

class DialogBloc extends Bloc<DialogEvent, DialogState> {
  DialogBloc() : super(DialogInitialState()) {
    on<FieldErrorEvent>(_onFieldError);
    on<InvalidMilestoneDateErrorEvent>(_onInvalidMilestoneDateError);
  }

  _onFieldError(
    FieldErrorEvent event,
    Emitter<DialogState> emit,
  ) {
    emit(FieldErrorState(event.errorEnum));
  }

  _onInvalidMilestoneDateError(
    InvalidMilestoneDateErrorEvent event,
    Emitter<DialogState> emit,
  ) {
    emit(InvalidMilestoneDateState());
  }

  bool isValidPaidAmount({
    required String enteredAmount,
    required double totalMilestoneAmount,
    required double projectReceivedAmount,
  }) {
    if (enteredAmount.isEmpty) {
      add(FieldErrorEvent(ErrorEnum.emptyAmount));
      return false;
    } else {
      final amount = double.tryParse(enteredAmount) ?? 0;
      final totalAmountPending = totalMilestoneAmount - projectReceivedAmount;
      if (amount > totalAmountPending) {
        add(FieldErrorEvent(ErrorEnum.paidExceededAmount));
        return false;
      }
    }
    return true;
  }

  bool isValidUnPaidAmount({
    required String enteredAmount,
    required double projectReceivedAmount,
  }) {
    if (enteredAmount.isEmpty) {
      add(FieldErrorEvent(ErrorEnum.emptyAmount));
      return false;
    } else {
      final amount = double.tryParse(enteredAmount) ?? 0;
      if (amount > projectReceivedAmount) {
        add(FieldErrorEvent(ErrorEnum.unPaidExceededAmount));
        return false;
      }
    }
    return true;
  }

  bool isValidAmount({
    required String enteredAmount,
    MilestoneInfo? milestoneInfo,
    TransactionEnum? transactionEnum,
  }) {
    if (enteredAmount.isEmpty) {
      add(FieldErrorEvent(ErrorEnum.emptyAmount));
      return false;
    } else if (transactionEnum != null) {
      if (transactionEnum == TransactionEnum.paid) {
        if (milestoneInfo != null && enteredAmount.isNotEmpty) {
          final amount = double.tryParse(enteredAmount);
          final totalAmount = (milestoneInfo.milestoneAmount ?? 0) -
              (milestoneInfo.receivedAmount ?? 0);
          if (amount == null || amount > totalAmount) {
            add(FieldErrorEvent(ErrorEnum.paidExceededAmount));
            return false;
          }
        }
      } else if (transactionEnum == TransactionEnum.unPaid) {
        if (milestoneInfo != null && enteredAmount.isNotEmpty) {
          final amount = double.tryParse(enteredAmount);
          if (amount == null || amount > (milestoneInfo.receivedAmount ?? 0)) {
            add(FieldErrorEvent(ErrorEnum.unPaidExceededAmount));
            return false;
          }
        }
      }
    }
    return true;
  }

  bool isValidDate({
    required DateTime? projectStartDate,
    required DateTime? milestoneDate,
  }) {
    final isValidDate = MilestoneUtils.isValidMilestoneDate(
      projectStartDate: projectStartDate,
      milestoneDate: milestoneDate,
    );
    if (!isValidDate) {
      add(InvalidMilestoneDateErrorEvent());
    }
    return isValidDate;
  }
}
