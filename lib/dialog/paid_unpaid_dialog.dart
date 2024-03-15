import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import './bloc/dialog_bloc.dart';
import './model/transaction_enum.dart';
import '../add_project/model/milestone_info.dart';
import '../add_project/model/project_info.dart';
import '../app_widgets/app_outline_button.dart';
import '../app_widgets/app_text_field.dart';
import '../config/app_config.dart';
import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../enums/error_enum.dart';
import '../keyboard_action/keyboard_actions.dart';
import '../project_list/fetch_projects_bloc/firebase_fetch_projects_bloc.dart';
import '../project_list/utils/milestone_utils.dart';
import '../utils/app_utils.dart';
import '../utils/color_utils.dart';
import '../utils/decimal_text_input_formatter.dart';

class PaidUnPaidDialog extends StatefulWidget {
  final ProjectInfo projectInfo;
  final MilestoneInfo? milestoneInfo;
  final Function(String amount, String note, DateTime? dateTime)? onPaidClick;
  final Function(String amount, String note, DateTime? dateTime)? onUnPaidClick;
  final bool isPayOperationFromMilestoneDialog;
  final bool isUnPayOperationFromMilestoneDialog;
  final bool isOnlyPaidOperation;

  const PaidUnPaidDialog({
    Key? key,
    required this.projectInfo,
    required this.milestoneInfo,
    this.isPayOperationFromMilestoneDialog = false,
    this.isUnPayOperationFromMilestoneDialog = false,
    this.onPaidClick,
    this.onUnPaidClick,
    this.isOnlyPaidOperation = false,
  }) : super(key: key);

  @override
  State<PaidUnPaidDialog> createState() => _PaidUnPaidDialogState();
}

class _PaidUnPaidDialogState extends State<PaidUnPaidDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final amountFieldFocusNode = Platform.isIOS ? FocusNode() : null;
  late DateTime? _selectedDateTime;
  late bool isFullyPaidMilestone;
  DialogBloc? _dialogBlocProvider;
  late double totalMilestoneAmount;

  @override
  void initState() {
    final milestoneInfo = widget.milestoneInfo;
    if (milestoneInfo != null) {
      _selectedDateTime = milestoneInfo.dateTime;
      isFullyPaidMilestone = MilestoneUtils.isFullyPaidMilestone(
        milestoneInfo,
      );
      double amount = 0;
      if (isFullyPaidMilestone) {
        amount = milestoneInfo.receivedAmount ?? 0;
      } else {
        amount = (milestoneInfo.milestoneAmount ?? 0) -
            (milestoneInfo.receivedAmount ?? 0);
      }
      if (amount != 0) {
        _amountController.text = AppUtils.removeTrailingZero(amount);
      }
    } else {
      _selectedDateTime = DateTime.now();
      isFullyPaidMilestone = false;
    }
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    _dialogBlocProvider ??= BlocProvider.of<DialogBloc>(
      context,
      listen: false,
    );

    if (widget.isOnlyPaidOperation) {
      final amount =
          BlocProvider.of<FirebaseFetchProjectsBloc>(context, listen: false)
              .getTotalMilestoneAmount(
        widget.projectInfo,
      );
      totalMilestoneAmount = double.parse(amount);

      isFullyPaidMilestone =
          totalMilestoneAmount - (widget.projectInfo.receivedAmount ?? 0) == 0;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final milestoneInfo = widget.milestoneInfo;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  Dimens.dialogRadius.r,
                ),
              ),
              color: ColorUtils.getColor(
                context,
                ColorEnums.whiteColor,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _headerView(
                  context,
                  appLocalizations,
                  milestoneInfo,
                ),
                _contentView(
                  context,
                  appLocalizations,
                  milestoneInfo,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Material(
              color: ColorUtils.getColor(
                context,
                ColorEnums.transparentColor,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context, false);
                },
                borderRadius: BorderRadius.circular(
                  (Dimens.drawerCloseIconSize * 3).w,
                ),
                child: SizedBox(
                  width: (Dimens.drawerCloseIconSize * 3).w,
                  height: (Dimens.drawerCloseIconSize * 3).w,
                  child: Padding(
                    padding: EdgeInsets.all(
                      Dimens.drawerCloseIconSize.w,
                    ),
                    child: SvgPicture.asset(
                      Strings.close,
                      colorFilter: ColorFilter.mode(
                        ColorUtils.getColor(
                          context,
                          ColorEnums.gray99Color,
                        ),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!widget.isOnlyPaidOperation)
            Positioned(
              top: 0,
              left: 0,
              child: Material(
                color: ColorUtils.getColor(
                  context,
                  ColorEnums.transparentColor,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context, true);
                  },
                  borderRadius: BorderRadius.circular(
                    (Dimens.drawerCloseIconSize * 3).w,
                  ),
                  child: SizedBox(
                    width: (Dimens.drawerCloseIconSize * 3).w,
                    height: (Dimens.drawerCloseIconSize * 3).w,
                    child: Padding(
                      padding: EdgeInsets.all(
                        Dimens.drawerBackIconSize.w,
                      ),
                      child: SvgPicture.asset(
                        Strings.backButton,
                        colorFilter: ColorFilter.mode(
                          ColorUtils.getColor(
                            context,
                            ColorEnums.gray99Color,
                          ),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _headerView(
    BuildContext context,
    AppLocalizations appLocalizations,
    MilestoneInfo? milestoneInfo,
  ) {
    String projectName = widget.projectInfo.projectName ?? '';
    if (projectName.isNotEmpty) {
      final isPaidBtnAvailable = _isPaidOperation();
      final isUnPaidBtnAvailable = _isUnPaidOperations();
      if (isPaidBtnAvailable && isUnPaidBtnAvailable) {
        projectName = '$projectName - '
            '${appLocalizations.pay}/${appLocalizations.unPay}';
      } else if (isPaidBtnAvailable) {
        projectName =
            '${widget.projectInfo.projectName} - ${appLocalizations.pay}';
      } else if (isUnPaidBtnAvailable) {
        projectName =
            '${widget.projectInfo.projectName} - ${appLocalizations.unPay}';
      }
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            Dimens.dialogRadius.r,
          ),
          topRight: Radius.circular(
            Dimens.dialogRadius.r,
          ),
        ),
        color: ColorUtils.getColor(
          context,
          MilestoneUtils.getMilestoneBlockColor(
            milestoneInfo,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: (Dimens.dialogHorizontalPadding * 2).w,
        vertical: Dimens.dialogVerticalPadding.w,
      ),
      alignment: Alignment.center,
      child: Text(
        projectName,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: Dimens.dialogTitleTextSize.sp,
          fontWeight: FontWeight.w500,
          color: ColorUtils.getColor(
            context,
            ColorEnums.black33Color,
          ),
        ),
      ),
    );
  }

  Widget _contentView(
    BuildContext context,
    AppLocalizations appLocalizations,
    MilestoneInfo? milestoneInfo,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        left: Dimens.dialogHorizontalPadding.w,
        right: Dimens.dialogHorizontalPadding.w,
        bottom: Dimens.dialogHorizontalPadding.h,
      ),
      child: Column(
        children: [
          SizedBox(
            height: Dimens.dialogTitleAmountSpacing.h,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                child: SizedBox(),
              ),
              BlocBuilder<DialogBloc, DialogState>(
                buildWhen: (previous, current) =>
                    previous != current && current is FieldErrorState,
                builder: (context, state) {
                  return Container(
                    width: Dimens.dialogAmountFieldWidth.w,
                    height: Dimens.dialogAmountFieldHeight.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Dimens.fieldBorderRadius.r,
                      ),
                      border: Border.all(
                        color: ColorUtils.getColor(
                          context,
                          state is FieldErrorState
                              ? ColorEnums.redColor
                              : ColorEnums.black33Color,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: KeyboardActions(
                      tapOutsideBehavior: TapOutsideBehavior.none,
                      disableScroll: true,
                      enable: true,
                      config: KeyboardActionsConfig(
                        nextFocus: false,
                        keyboardBarElevation: 0,
                        keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
                        actions: [
                          KeyboardActionsItem(
                            focusNode: amountFieldFocusNode ?? FocusNode(),
                            displayArrows: false,
                            displayDoneButton: true,
                          ),
                        ],
                      ),
                      child: TextField(
                        textAlign: TextAlign.center,
                        enableInteractiveSelection: false,
                        focusNode: amountFieldFocusNode,
                        autofocus: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(
                            AppUtils.regexToDenyComma,
                          ),
                          DecimalTextInputFormatter(
                            decimalRange: AppConfig.decimalTextFieldInputLength,
                          ),
                          LengthLimitingTextInputFormatter(
                            AppConfig.amountInputLengthLimit,
                          ),
                        ],
                        style: TextStyle(
                          color: ColorUtils.getColor(
                            context,
                            ColorEnums.black33Color,
                          ),
                          fontSize: Dimens.dialogAmountFieldTextSize.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        cursorColor: ColorUtils.getColor(
                          context,
                          ColorEnums.black33Color,
                        ),
                        controller: _amountController,
                        cursorWidth: 1,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,
                        decoration: null,
                        onChanged: (value) {},
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: SizedBox(
                  height: Dimens.dialogAmountFieldHeight.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: SizedBox(),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (milestoneInfo?.isUpdated ?? false)
                            SizedBox(
                              width: Dimens.dialogUpdatedCirclePadding.w,
                            ),
                          if (milestoneInfo?.isUpdated ?? false)
                            CircleAvatar(
                              backgroundColor: ColorUtils.getColor(
                                context,
                                ColorEnums.black33Color,
                              ),
                              radius: Dimens.dialogUpdatedCircleSize.r,
                            ),
                        ],
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            _getOutOfMilestoneAmount(),
                            style: TextStyle(
                              color: ColorUtils.getColor(
                                context,
                                ColorEnums.gray6CColor,
                              ),
                              fontSize: Dimens.dialogMilestoneTextSize.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          BlocBuilder<DialogBloc, DialogState>(
            buildWhen: (previous, current) =>
                previous != current && current is FieldErrorState,
            builder: (context, state) {
              if (state is FieldErrorState) {
                String message = '';
                if (state.errorEnum == ErrorEnum.emptyAmount) {
                  message = appLocalizations.emptyAmountError;
                } else if (state.errorEnum == ErrorEnum.paidExceededAmount) {
                  if (widget.isOnlyPaidOperation) {
                    message = appLocalizations.amountExceededTo(
                      AppUtils.removeTrailingZero(
                        totalMilestoneAmount -
                            (widget.projectInfo.receivedAmount ?? 0),
                      ),
                    );
                  } else {
                    final totalAmount = (milestoneInfo?.milestoneAmount ?? 0) -
                        (milestoneInfo?.receivedAmount ?? 0);
                    message = appLocalizations.amountExceededTo(
                      AppUtils.removeTrailingZero(totalAmount),
                    );
                  }
                } else if (state.errorEnum == ErrorEnum.unPaidExceededAmount) {
                  if (widget.isOnlyPaidOperation) {
                    message = appLocalizations.amountExceededTo(
                      AppUtils.removeTrailingZero(
                        widget.projectInfo.receivedAmount ?? 0,
                      ),
                    );
                  } else {
                    message = appLocalizations.amountExceededTo(
                      AppUtils.removeTrailingZero(
                        milestoneInfo?.receivedAmount,
                      ),
                    );
                  }
                }
                return Padding(
                  padding: EdgeInsets.only(
                    top: Dimens.milestoneAmountErrorTextPadding.h,
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: Dimens.milestoneAmountErrorTextSize.sp,
                      color: ColorUtils.getColor(
                        context,
                        ColorEnums.redColor,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
          SizedBox(
            height: Dimens.dialogAmountDateSpacing.h,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat(AppConfig.milestoneInfoDateFormat).format(
                  _selectedDateTime ?? DateTime.now(),
                ),
                style: TextStyle(
                  fontSize: Dimens.dialogDateTextSize.sp,
                  color: ColorUtils.getColor(
                    context,
                    ColorEnums.gray6CColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: Dimens.dialogNoteFieldSpacing.h,
          ),
          AppTextField(
            title: null,
            keyboardAction: TextInputAction.next,
            isMultiLine: true,
            maxLine: 2,
            hint: appLocalizations.notes,
            textEditingController: _noteController,
            hintStyle: TextStyle(
              fontSize: Dimens.dialogNoteHintTextSize.sp,
              color: ColorUtils.getColor(
                context,
                ColorEnums.grayA8Color,
              ),
            ),
            fieldBgColor: ColorEnums.transparentColor,
            onTextChange: (notes) {},
          ),
          SizedBox(
            height: Dimens.dialogNoteFieldSpacing.h,
          ),
          _paidOperations(
            context,
            appLocalizations,
          ),
        ],
      ),
    );
  }

  Widget _paidOperations(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Row(
      children: [
        if (_isPaidOperation())
          Expanded(
            child: AppOutlineButton(
              title: appLocalizations.paid,
              bgColor: ColorUtils.getColor(
                context,
                ColorEnums.whiteColor,
              ),
              onButtonPressed: () {
                _onPaidButtonClick(context);
              },
            ),
          ),
        if (_isPaidOperation() && (_isUnPaidOperations()))
          SizedBox(
            width: Dimens.dialogButtonSpacing.w,
          ),
        if (_isUnPaidOperations())
          Expanded(
            child: AppOutlineButton(
              title: appLocalizations.unPaid,
              bgColor: ColorUtils.getColor(
                context,
                ColorEnums.whiteColor,
              ),
              onButtonPressed: () {
                _onUnPaidButtonClick(context);
              },
            ),
          ),
      ],
    );
  }

  bool _isPaidOperation() {
    if (widget.isOnlyPaidOperation) {
      return !isFullyPaidMilestone;
    } else {
      return widget.isPayOperationFromMilestoneDialog;
    }
  }

  bool _isUnPaidOperations() {
    if (widget.isOnlyPaidOperation) {
      return (widget.projectInfo.receivedAmount ?? 0) > 0;
    } else {
      return widget.isUnPayOperationFromMilestoneDialog;
    }
  }

  String _getOutOfMilestoneAmount() {
    if (widget.isOnlyPaidOperation) {
      return ' /${AppUtils.removeTrailingZero(totalMilestoneAmount)}';
    } else {
      return ' /${AppUtils.removeTrailingZero(
        widget.milestoneInfo?.milestoneAmount,
      )}';
    }
  }

  _onPaidButtonClick(BuildContext context) {
    if (widget.onPaidClick != null) {
      final amount = _amountController.text.toString().trim();
      bool? isValidField;
      if (widget.isOnlyPaidOperation) {
        isValidField = _dialogBlocProvider?.isValidPaidAmount(
          enteredAmount: amount,
          totalMilestoneAmount: totalMilestoneAmount,
          projectReceivedAmount: widget.projectInfo.receivedAmount ?? 0,
        );
      } else {
        isValidField = _dialogBlocProvider?.isValidAmount(
          enteredAmount: amount,
          milestoneInfo: widget.milestoneInfo,
          transactionEnum: TransactionEnum.paid,
        );
      }
      if (isValidField ?? false) {
        final note = _noteController.text.toString().trim();
        widget.onPaidClick!(
          amount,
          note,
          _selectedDateTime,
        );
        Navigator.pop(context, false);
      }
    }
  }

  _onUnPaidButtonClick(BuildContext context) {
    if (widget.onUnPaidClick != null) {
      final amount = _amountController.text.toString().trim();

      bool? isValidField;
      if (widget.isOnlyPaidOperation) {
        isValidField = _dialogBlocProvider?.isValidUnPaidAmount(
          enteredAmount: amount,
          projectReceivedAmount: widget.projectInfo.receivedAmount ?? 0,
        );
      } else {
        isValidField = _dialogBlocProvider?.isValidAmount(
          enteredAmount: amount,
          milestoneInfo: widget.milestoneInfo,
          transactionEnum: TransactionEnum.unPaid,
        );
      }

      if (isValidField ?? false) {
        final note = _noteController.text.toString().trim();
        widget.onUnPaidClick!(
          amount,
          note,
          _selectedDateTime,
        );
        Navigator.pop(context, false);
      }
    }
  }
}
