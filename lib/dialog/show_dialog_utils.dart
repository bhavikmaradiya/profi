import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import './bloc/dialog_bloc.dart';
import './delete_dialog.dart';
import './edit_dialog.dart';
import './history_dialog.dart';
import './milestone_operation_dialog.dart';
import './model/multiple_milestone_info.dart';
import './paid_unpaid_dialog.dart';
import '../add_project/model/milestone_info.dart';
import '../add_project/model/project_info.dart';
import '../const/dimens.dart';
import '../enums/color_enums.dart';
import '../inward_transactions/model/transaction_info.dart';
import '../logs/bloc/logs_bloc.dart';
import '../project_list/fetch_projects_bloc/firebase_fetch_projects_bloc.dart';
import '../project_list/milestone_operations_bloc/milestone_operations_bloc.dart';
import '../project_list/utils/milestone_utils.dart';
import '../utils/color_utils.dart';

class ShowDialogUtils {
  static showMilestoneDialog({
    required BuildContext context,
    required AppLocalizations appLocalizations,
    required ProjectInfo projectInfo,
    MilestoneInfo? milestoneInfo,
  }) async {
    GlobalKey dialogContentKey = GlobalKey();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => LogsBloc(),
            ),
            BlocProvider(
              create: (context) => DialogBloc(),
            ),
          ],
          child: Dialog(
            backgroundColor: ColorUtils.getColor(
              context,
              ColorEnums.transparentColor,
            ),
            elevation: 0,
            // Remove the shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            insetPadding: EdgeInsets.symmetric(
              horizontal: Dimens.screenHorizontalMargin.w,
              vertical: Dimens.screenHorizontalMargin.h,
            ),
            child: MilestoneOperationDialog(
              key: dialogContentKey,
              projectInfo: projectInfo,
              milestoneInfo: milestoneInfo,
              onPayClick: () {
                _onPayUnPayButtonClick(
                  context: context,
                  appLocalizations: appLocalizations,
                  projectInfo: projectInfo,
                  milestoneInfo: milestoneInfo,
                );
              },
              onUnPayClick: () {
                _onPayUnPayButtonClick(
                  context: context,
                  appLocalizations: appLocalizations,
                  projectInfo: projectInfo,
                  milestoneInfo: milestoneInfo,
                  isUnPayOperation: true,
                );
              },
              onEditClick: () {
                _onEditButtonClick(
                  context,
                  appLocalizations,
                  projectInfo,
                  milestoneInfo,
                );
              },
              onHistoryClick: (currentUserId) {
                final height = dialogContentKey.currentContext?.size?.height;
                _onHistoryButtonClick(
                  context: context,
                  appLocalizations: appLocalizations,
                  projectInfo: projectInfo,
                  milestoneInfo: milestoneInfo,
                  currentUserId: currentUserId,
                  height: height,
                );
              },
              onInvoicedCheckChange: () {
                if (milestoneInfo != null &&
                    MilestoneUtils.isMilestoneWithinPaymentCycle(
                        milestoneInfo)) {
                  BlocProvider.of<MilestoneOperationsBloc>(
                    context,
                    listen: false,
                  ).add(
                    MilestoneInvoicedChangeEvent(
                      projectInfo,
                      milestoneInfo,
                    ),
                  );
                }
                Navigator.pop(dialogContext);
              },
            ),
          ),
        );
      },
    );
  }

  static showPaidUnPaidDialog({
    required BuildContext context,
    required AppLocalizations appLocalizations,
    required ProjectInfo projectInfo,
    MilestoneInfo? milestoneInfo,
    bool isPayOperationFromMilestoneDialog = false,
    bool isUnPayOperationFromMilestoneDialog = false,
    bool isOnlyPaidOperation = false,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider(
          create: (context) => DialogBloc(),
          child: Dialog(
            backgroundColor: ColorUtils.getColor(
              context,
              ColorEnums.transparentColor,
            ),
            elevation: 0,
            // Remove the shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            insetPadding: EdgeInsets.symmetric(
              horizontal: Dimens.screenHorizontalMargin.w,
              vertical: Dimens.screenHorizontalMargin.h,
            ),
            child: PaidUnPaidDialog(
              projectInfo: projectInfo,
              milestoneInfo: milestoneInfo,
              isPayOperationFromMilestoneDialog:
                  isPayOperationFromMilestoneDialog,
              isUnPayOperationFromMilestoneDialog:
                  isUnPayOperationFromMilestoneDialog,
              isOnlyPaidOperation: isOnlyPaidOperation,
              onPaidClick: (
                String amount,
                String note,
                DateTime? dateTime,
              ) {
                _onPaidButtonClick(
                  context: context,
                  projectInfo: projectInfo,
                  milestoneInfo: milestoneInfo,
                  amount: amount,
                  note: note,
                  receivedDate: dateTime,
                  isOnlyPaidOperation: isOnlyPaidOperation,
                );
              },
              onUnPaidClick: (
                String amount,
                String note,
                DateTime? dateTime,
              ) {
                _onUnPaidButtonClick(
                  context: context,
                  projectInfo: projectInfo,
                  milestoneInfo: milestoneInfo,
                  amount: amount,
                  note: note,
                  receivedDate: dateTime,
                  isOnlyPaidOperation: isOnlyPaidOperation,
                );
              },
            ),
          ),
        );
      },
    ).then(
      (isNeedToOpenOperationDialog) {
        if (isNeedToOpenOperationDialog == null ||
            (isNeedToOpenOperationDialog is bool &&
                isNeedToOpenOperationDialog)) {
          if (milestoneInfo != null) {
            milestoneInfo.paymentStatus =
                MilestoneUtils.getMilestonePaymentStatus(
              projectInfo,
              milestoneInfo,
            ).name;
          }
          ShowDialogUtils.showMilestoneDialog(
            context: context,
            appLocalizations: appLocalizations,
            projectInfo: projectInfo,
            milestoneInfo: milestoneInfo,
          );
        }
      },
    );
  }

  static _onPaidButtonClick({
    required BuildContext context,
    required ProjectInfo projectInfo,
    required MilestoneInfo? milestoneInfo,
    required String amount,
    required String note,
    required DateTime? receivedDate,
    required bool isOnlyPaidOperation,
  }) {
    if (amount.isEmpty) {
      return;
    }
    if (!isOnlyPaidOperation) {
      _onSingleMilestonePaidOperation(
        context: context,
        projectInfo: projectInfo,
        milestoneInfo: milestoneInfo,
        amount: amount,
        note: note,
        receivedDate: receivedDate,
      );
    } else {
      _onMultipleMilestonePaidOperation(
        context: context,
        projectInfo: projectInfo,
        amount: amount,
        note: note,
        receivedDate: receivedDate,
      );
    }
  }

  static _onSingleMilestonePaidOperation({
    required BuildContext context,
    required ProjectInfo projectInfo,
    required MilestoneInfo? milestoneInfo,
    required String amount,
    required String note,
    required DateTime? receivedDate,
  }) {
    if (milestoneInfo == null) {
      return;
    }
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    BlocProvider.of<MilestoneOperationsBloc>(
      context,
      listen: false,
    ).add(
      MilestoneMarkAsPaidEvent(
        TransactionInfo(
          projectId: projectInfo.projectId,
          projectName: projectInfo.projectName,
          projectCode: projectInfo.projectCode,
          projectType: projectInfo.projectType,
          milestoneId: milestoneInfo.milestoneId,
          transactionDate: receivedDate?.millisecondsSinceEpoch ?? currentTime,
          paidAmount: double.parse(amount),
          notes: note,
          createdAt: currentTime,
          updatedAt: currentTime,
        ),
        projectInfo,
        milestoneInfo,
      ),
    );
  }

  static _onMultipleMilestonePaidOperation({
    required BuildContext context,
    required ProjectInfo projectInfo,
    required String amount,
    required String note,
    required DateTime? receivedDate,
  }) {
    List<MilestoneInfo> milestoneList =
        BlocProvider.of<FirebaseFetchProjectsBloc>(
      context,
      listen: false,
    ).getMilestoneInfoFromProjectId(
      projectInfo.projectId,
    );
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    List<MultipleMilestoneInfo> multipleMilestoneInfo = [];
    double pendingPaidAmount = double.parse(amount.trim());
    for (int i = 0; i < milestoneList.length; i++) {
      if (pendingPaidAmount > 0) {
        final milestone = milestoneList[i];
        final totalRequiredAmountForMilestone =
            (milestone.milestoneAmount ?? 0) - (milestone.receivedAmount ?? 0);
        if (totalRequiredAmountForMilestone != 0) {
          // if milestone is already completed or in green then ignore that milestone and move further
          if (pendingPaidAmount > totalRequiredAmountForMilestone) {
            multipleMilestoneInfo.add(
              MultipleMilestoneInfo(
                  milestoneId: milestone.milestoneId,
                  milestoneAmount: milestone.milestoneAmount,
                  receivedAmount: milestone.receivedAmount,
                  pendingPaidUnPaidAmount: totalRequiredAmountForMilestone,
                  notes: note,
                  transactionDate: currentTime,
                  milestoneDate: milestone.dateTime),
            );
            pendingPaidAmount -= totalRequiredAmountForMilestone;
          } else {
            multipleMilestoneInfo.add(
              MultipleMilestoneInfo(
                milestoneId: milestone.milestoneId,
                milestoneAmount: milestone.milestoneAmount,
                receivedAmount: milestone.receivedAmount,
                pendingPaidUnPaidAmount: pendingPaidAmount,
                notes: note,
                transactionDate: currentTime,
                milestoneDate: milestone.dateTime,
              ),
            );
            pendingPaidAmount = 0;
            break;
          }
        }
      } else {
        break;
      }
    }

    if (multipleMilestoneInfo.isNotEmpty) {
      BlocProvider.of<MilestoneOperationsBloc>(
        context,
        listen: false,
      ).add(
        MultipleMilestonesMarkAsPaidEvent(
          projectInfo,
          multipleMilestoneInfo,
        ),
      );
    }
  }

  static _onUnPaidButtonClick({
    required BuildContext context,
    required ProjectInfo projectInfo,
    required MilestoneInfo? milestoneInfo,
    required String amount,
    required String note,
    required DateTime? receivedDate,
    required bool isOnlyPaidOperation,
  }) {
    if (amount.isEmpty) {
      return;
    }
    if (!isOnlyPaidOperation) {
      _onSingleMilestoneUnPaidOperation(
        context: context,
        projectInfo: projectInfo,
        milestoneInfo: milestoneInfo,
        amount: amount,
        note: note,
        receivedDate: receivedDate,
      );
    } else {
      _onMultipleMilestoneUnPaidOperation(
        context: context,
        projectInfo: projectInfo,
        amount: amount,
        note: note,
        receivedDate: receivedDate,
      );
    }
  }

  static _onSingleMilestoneUnPaidOperation({
    required BuildContext context,
    required ProjectInfo projectInfo,
    required MilestoneInfo? milestoneInfo,
    required String amount,
    required String note,
    required DateTime? receivedDate,
  }) {
    if (milestoneInfo == null) {
      return;
    }
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    BlocProvider.of<MilestoneOperationsBloc>(
      context,
      listen: false,
    ).add(
      MilestoneMarkAsUnPaidEvent(
        milestoneDate: receivedDate?.millisecondsSinceEpoch ?? currentTime,
        milestoneAmount: double.parse(amount),
        notes: note,
        projectInfo: projectInfo,
        milestoneInfo: milestoneInfo,
        transactionInfo: TransactionInfo(
          projectId: projectInfo.projectId,
          projectName: projectInfo.projectName,
          projectCode: projectInfo.projectCode,
          projectType: projectInfo.projectType,
          milestoneId: milestoneInfo.milestoneId,
          transactionDate: receivedDate?.millisecondsSinceEpoch ?? currentTime,
          unPaidAmount: double.parse(amount),
          notes: note,
          createdAt: currentTime,
          updatedAt: currentTime,
        ),
      ),
    );
  }

  static _onMultipleMilestoneUnPaidOperation({
    required BuildContext context,
    required ProjectInfo projectInfo,
    required String amount,
    required String note,
    required DateTime? receivedDate,
  }) {
    List<MilestoneInfo> milestoneList =
        BlocProvider.of<FirebaseFetchProjectsBloc>(
      context,
      listen: false,
    ).getMilestoneInfoFromProjectId(
      projectInfo.projectId,
    );
    milestoneList.sort(
      (a, b) {
        if (a.dateTime == null && b.dateTime == null) {
          return 0; // Both dates are null, consider them equal
        } else if (a.dateTime == null) {
          return 1; // 'a' date is null, 'b' date is not null, 'b' comes first
        } else if (b.dateTime == null) {
          return -1; // 'b' date is null, 'a' date is not null, 'a' comes first
        } else {
          return b.dateTime!.compareTo(a.dateTime!); // Compare non-null dates
        }
      },
    );
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    List<MultipleMilestoneInfo> multipleMilestoneInfo = [];
    double pendingUnPaidAmount = double.parse(amount.trim());
    for (int i = 0; i < milestoneList.length; i++) {
      if (pendingUnPaidAmount > 0) {
        final milestone = milestoneList[i];
        final maxPossibleToUnPaidForMilestone = milestone.receivedAmount ?? 0;
        if (maxPossibleToUnPaidForMilestone != 0) {
          if (pendingUnPaidAmount > maxPossibleToUnPaidForMilestone) {
            multipleMilestoneInfo.add(
              MultipleMilestoneInfo(
                milestoneId: milestone.milestoneId,
                milestoneAmount: milestone.milestoneAmount,
                receivedAmount: milestone.receivedAmount,
                pendingPaidUnPaidAmount: maxPossibleToUnPaidForMilestone,
                notes: note,
                transactionDate: currentTime,
                milestoneDate: milestone.dateTime,
              ),
            );
            pendingUnPaidAmount -= maxPossibleToUnPaidForMilestone;
          } else {
            multipleMilestoneInfo.add(
              MultipleMilestoneInfo(
                milestoneId: milestone.milestoneId,
                milestoneAmount: milestone.milestoneAmount,
                receivedAmount: milestone.receivedAmount,
                pendingPaidUnPaidAmount: pendingUnPaidAmount,
                notes: note,
                transactionDate: currentTime,
                milestoneDate: milestone.dateTime,
              ),
            );
            pendingUnPaidAmount = 0;
            break;
          }
        }
      } else {
        break;
      }
    }

    if (multipleMilestoneInfo.isNotEmpty) {
      BlocProvider.of<MilestoneOperationsBloc>(
        context,
        listen: false,
      ).add(
        MultipleMilestonesMarkAsUnPaidEvent(
          projectInfo,
          multipleMilestoneInfo,
        ),
      );
    }
  }

  static _onPayUnPayButtonClick({
    required BuildContext context,
    required AppLocalizations appLocalizations,
    required ProjectInfo projectInfo,
    MilestoneInfo? milestoneInfo,
    bool isUnPayOperation = false,
    bool isOnlyPaidOperation = false,
  }) {
    ShowDialogUtils.showPaidUnPaidDialog(
      context: context,
      appLocalizations: appLocalizations,
      projectInfo: projectInfo,
      milestoneInfo: milestoneInfo,
      isOnlyPaidOperation: isOnlyPaidOperation,
      isPayOperationFromMilestoneDialog: !isUnPayOperation,
      isUnPayOperationFromMilestoneDialog: isUnPayOperation,
    );
  }

  static _onEditButtonClick(
    BuildContext context,
    AppLocalizations appLocalizations,
    ProjectInfo projectInfo,
    MilestoneInfo? milestoneInfo,
  ) {
    ShowDialogUtils.showUpdateMilestoneDialog(
      context: context,
      appLocalizations: appLocalizations,
      projectInfo: projectInfo,
      milestoneInfo: milestoneInfo,
    );
  }

  static showUpdateMilestoneDialog({
    required BuildContext context,
    required AppLocalizations appLocalizations,
    required ProjectInfo projectInfo,
    MilestoneInfo? milestoneInfo,
    bool isNewMilestoneToAdd = false,
    bool isOnlyPaidOperation = false,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider(
          create: (context) => DialogBloc(),
          child: Dialog(
            backgroundColor: ColorUtils.getColor(
              context,
              ColorEnums.transparentColor,
            ),
            elevation: 0,
            // Remove the shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            insetPadding: EdgeInsets.symmetric(
              horizontal: Dimens.screenHorizontalMargin.w,
              vertical: Dimens.screenHorizontalMargin.h,
            ),
            child: EditDialog(
              projectInfo: projectInfo,
              milestoneInfo: milestoneInfo,
              isNewMilestoneToAdd: isNewMilestoneToAdd,
              onSaveClick: (
                String amount,
                String note,
                DateTime? dateTime,
              ) {
                _onSaveButtonClick(
                  context,
                  projectInfo,
                  milestoneInfo,
                  amount,
                  note,
                  dateTime,
                );
              },
              onDeleteClick: () {
                _onDeleteButtonClick(
                  context: context,
                  appLocalizations: appLocalizations,
                  projectInfo: projectInfo,
                  milestoneInfo: milestoneInfo,
                  isOnlyPaidOperation: isOnlyPaidOperation,
                );
              },
            ),
          ),
        );
      },
    ).then(
      (isNeedToOpenOperationDialog) {
        if (isNeedToOpenOperationDialog == null ||
            (isNeedToOpenOperationDialog is bool &&
                isNeedToOpenOperationDialog)) {
          if (milestoneInfo != null) {
            milestoneInfo.paymentStatus =
                MilestoneUtils.getMilestonePaymentStatus(
              projectInfo,
              milestoneInfo,
            ).name;
          }
          ShowDialogUtils.showMilestoneDialog(
            context: context,
            appLocalizations: appLocalizations,
            projectInfo: projectInfo,
            milestoneInfo: milestoneInfo,
          );
        }
      },
    );
  }

  static _onSaveButtonClick(
    BuildContext context,
    ProjectInfo projectInfo,
    MilestoneInfo? milestoneInfo,
    String amount,
    String note,
    DateTime? receivedDate,
  ) {
    if (amount.isEmpty) {
      return;
    }
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    BlocProvider.of<MilestoneOperationsBloc>(
      context,
      listen: false,
    ).add(
      MilestoneUpdateEvent(
        projectInfo: projectInfo,
        milestoneInfo: milestoneInfo,
        notes: note,
        milestoneAmount: double.parse(amount),
        milestoneDate: receivedDate?.millisecondsSinceEpoch ?? currentTime,
        isNewMilestone: milestoneInfo == null,
      ),
    );
  }

  static _onDeleteButtonClick({
    required BuildContext context,
    required AppLocalizations appLocalizations,
    required ProjectInfo projectInfo,
    MilestoneInfo? milestoneInfo,
    bool isOnlyPaidOperation = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          child: DeleteDialog(
            message: appLocalizations.sureToDeleteMilestone,
            onDeleteClick: () {
              BlocProvider.of<MilestoneOperationsBloc>(
                context,
                listen: false,
              ).add(
                MilestoneDeleteEvent(
                  projectInfo,
                  milestoneInfo?.milestoneId,
                  milestoneInfo?.receivedAmount,
                ),
              );
              Navigator.pop(dialogContext);
            },
            onCancelClick: () {
              Navigator.pop(dialogContext);
              // open main dialog again!
              ShowDialogUtils.showMilestoneDialog(
                context: context,
                appLocalizations: appLocalizations,
                projectInfo: projectInfo,
                milestoneInfo: milestoneInfo,
              );
            },
          ),
        );
      },
    );
  }

  static showHistoryDialog({
    required BuildContext context,
    required AppLocalizations appLocalizations,
    required ProjectInfo projectInfo,
    required String? currentUserId,
    MilestoneInfo? milestoneInfo,
    double? height,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider(
          create: (context) => LogsBloc(),
          child: Dialog(
            backgroundColor: ColorUtils.getColor(
              context,
              ColorEnums.transparentColor,
            ),
            elevation: 0,
            // Remove the shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            insetPadding: EdgeInsets.symmetric(
              horizontal: Dimens.screenHorizontalMargin.w,
              vertical: Dimens.screenHorizontalMargin.h,
            ),
            child: HistoryDialog(
              projectInfo: projectInfo,
              milestoneInfo: milestoneInfo,
              currentUserId: currentUserId,
              height: height,
            ),
          ),
        );
      },
    ).then(
      (isNeedToOpenOperationDialog) {
        if (isNeedToOpenOperationDialog == null ||
            (isNeedToOpenOperationDialog is bool &&
                isNeedToOpenOperationDialog)) {
          ShowDialogUtils.showMilestoneDialog(
            context: context,
            appLocalizations: appLocalizations,
            projectInfo: projectInfo,
            milestoneInfo: milestoneInfo,
          );
        }
      },
    );
  }

  static _onHistoryButtonClick({
    required BuildContext context,
    required AppLocalizations appLocalizations,
    required ProjectInfo projectInfo,
    String? currentUserId,
    MilestoneInfo? milestoneInfo,
    double? height,
  }) async {
    ShowDialogUtils.showHistoryDialog(
      context: context,
      appLocalizations: appLocalizations,
      projectInfo: projectInfo,
      milestoneInfo: milestoneInfo,
      currentUserId: currentUserId,
      height: height,
    );
  }
}
