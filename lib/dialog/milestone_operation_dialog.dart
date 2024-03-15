import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './bloc/dialog_bloc.dart';
import '../add_project/model/milestone_info.dart';
import '../add_project/model/project_info.dart';
import '../app_widgets/app_outline_button.dart';
import '../app_widgets/app_text_field.dart';
import '../config/app_config.dart';
import '../config/preference_config.dart';
import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../keyboard_action/keyboard_actions.dart';
import '../logs/bloc/logs_bloc.dart';
import '../project_list/milestone_operations_bloc/milestone_operations_bloc.dart';
import '../project_list/utils/milestone_utils.dart';
import '../utils/app_utils.dart';
import '../utils/color_utils.dart';
import '../utils/decimal_text_input_formatter.dart';

class MilestoneOperationDialog extends StatefulWidget {
  final ProjectInfo projectInfo;
  final MilestoneInfo? milestoneInfo;
  final Function? onPayClick;
  final Function? onUnPayClick;
  final Function? onEditClick;
  final Function(String?)? onHistoryClick;
  final Function? onInvoicedCheckChange;

  const MilestoneOperationDialog({
    Key? key,
    required this.projectInfo,
    required this.milestoneInfo,
    this.onPayClick,
    this.onUnPayClick,
    this.onEditClick,
    this.onHistoryClick,
    this.onInvoicedCheckChange,
  }) : super(key: key);

  @override
  State<MilestoneOperationDialog> createState() =>
      _MilestoneOperationDialogState();
}

class _MilestoneOperationDialogState extends State<MilestoneOperationDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final amountFieldFocusNode = Platform.isIOS ? FocusNode() : null;
  late DateTime? _selectedDateTime;
  late bool isFullyPaidMilestone;
  late bool isMilestoneWithinPaymentCycle;
  late String? _currentUserId;
  DialogBloc? _dialogBlocProvider;
  LogsBloc? _logsBlocProvider;
  late double totalMilestoneAmount;
  bool _isInvoiced = false;

  @override
  void initState() {
    final milestoneInfo = widget.milestoneInfo;
    if (milestoneInfo != null) {
      _isInvoiced = milestoneInfo.isInvoiced ?? false;
      _selectedDateTime = milestoneInfo.dateTime;
      isFullyPaidMilestone = MilestoneUtils.isFullyPaidMilestone(
        milestoneInfo,
      );
      isMilestoneWithinPaymentCycle =
          MilestoneUtils.isMilestoneWithinPaymentCycle(
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
    final milestoneId = widget.milestoneInfo?.milestoneId;
    _dialogBlocProvider ??= BlocProvider.of<DialogBloc>(
      context,
      listen: false,
    );
    if (milestoneId != null) {
      BlocProvider.of<LogsBloc>(context, listen: false).add(
        CheckForLogHistoryEvent(milestoneId),
      );
    }
    _logsBlocProvider ??= BlocProvider.of<LogsBloc>(context, listen: false);
    _getCurrentUserId();
    super.didChangeDependencies();
  }

  _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString(PreferenceConfig.userIdPref);
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
                  Navigator.pop(context);
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
        ],
      ),
    );
  }

  Widget _headerView(
    BuildContext context,
    AppLocalizations appLocalizations,
    MilestoneInfo? milestoneInfo,
  ) {
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
        widget.projectInfo.projectName ?? '',
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
              Container(
                width: Dimens.dialogAmountFieldWidth.w,
                height: Dimens.dialogAmountFieldHeight.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    Dimens.fieldBorderRadius.r,
                  ),
                  border: Border.all(
                    color: ColorUtils.getColor(
                      context,
                      ColorEnums.grayE0Color,
                    ),
                  ),
                  color: ColorUtils.getColor(
                    context,
                    ColorEnums.grayF5Color,
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
                    enabled: false,
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
                        ColorEnums.gray99Color,
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
          AbsorbPointer(
            child: AppTextField(
              title: null,
              keyboardAction: TextInputAction.next,
              isMultiLine: true,
              maxLine: 2,
              isReadOnly: true,
              hint: appLocalizations.notes,
              textEditingController: _noteController,
              hintStyle: TextStyle(
                fontSize: Dimens.dialogNoteHintTextSize.sp,
                color: ColorUtils.getColor(
                  context,
                  ColorEnums.gray99Color,
                ),
              ),
              fieldBgColor: ColorEnums.grayF5Color,
              onTextChange: (notes) {},
            ),
          ),
          SizedBox(
            height: Dimens.dialogNoteFieldSpacing.h,
          ),
          _paidOperations(
            context,
            appLocalizations,
          ),
          if (isMilestoneWithinPaymentCycle)
            SizedBox(
              height: Dimens.dialogNoteFieldSpacing.h,
            ),
          if (isMilestoneWithinPaymentCycle)
            GestureDetector(
              onTap: () {
                if (widget.onInvoicedCheckChange != null) {
                  widget.onInvoicedCheckChange!();
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    _isInvoiced
                        ? Strings.checkBoxChecked
                        : Strings.checkBoxUnChecked,
                    width: Dimens.invoicedCheckBoxIconSize.w,
                    height: Dimens.invoicedCheckBoxIconSize.w,
                  ),
                  SizedBox(
                    width: Dimens.invoicedCheckBoxIconTextSpacing.w,
                  ),
                  Expanded(
                    child: Text(
                      appLocalizations.invoiced,
                      style: TextStyle(
                        fontSize: Dimens.filterItemTextSize.sp,
                        color: ColorUtils.getColor(
                          context,
                          ColorEnums.black00Color,
                        ),
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
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
              title: appLocalizations.pay,
              bgColor: ColorUtils.getColor(
                context,
                ColorEnums.whiteColor,
              ),
              onButtonPressed: () {
                _onPayButtonClick(context);
              },
            ),
          ),
        if (_isPaidOperation() && (_isUnPaidOperations() || _isEditOperation()))
          SizedBox(
            width: Dimens.dialogButtonSpacing.w,
          ),
        if (_isUnPaidOperations())
          Expanded(
            child: AppOutlineButton(
              title: appLocalizations.unPay,
              bgColor: ColorUtils.getColor(
                context,
                ColorEnums.whiteColor,
              ),
              onButtonPressed: () {
                _onUnPayButtonClick(context);
              },
            ),
          ),
        if (_isUnPaidOperations())
          SizedBox(
            width: Dimens.dialogButtonSpacing.w,
          ),
        if (_isEditOperation())
          Expanded(
            child: AppOutlineButton(
              title: appLocalizations.edit,
              textColorEnum: ColorEnums.black33Color,
              onButtonPressed: () {
                _onEditButtonClick(context);
              },
            ),
          ),
        if (_isEditOperation())
          SizedBox(
            width: Dimens.dialogButtonSpacing.w,
          ),
        Expanded(
          child: BlocBuilder<LogsBloc, LogsState>(
            buildWhen: (previous, current) =>
                previous != current && current is LogsHistoryCountState,
            builder: (context, state) {
              int historyLogCount = 0;
              if (state is LogsHistoryCountState) {
                historyLogCount = state.historyCount;
              }
              return AppOutlineButton(
                title: appLocalizations.history,
                textColorEnum: historyLogCount == 0
                    ? ColorEnums.gray99Color
                    : ColorEnums.black33Color,
                onButtonPressed: () {
                  _onHistoryButtonClick(context);
                },
                isEnabled: historyLogCount > 0,
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isPaidOperation() {
    return !isFullyPaidMilestone;
  }

  bool _isUnPaidOperations() {
    return isFullyPaidMilestone ||
        (widget.milestoneInfo?.receivedAmount ?? 0) > 0;
  }

  bool _isEditOperation() {
    return !isFullyPaidMilestone;
  }

  String _getOutOfMilestoneAmount() {
    return ' /${AppUtils.removeTrailingZero(
      widget.milestoneInfo?.milestoneAmount,
    )}';
  }

  _onPayButtonClick(BuildContext context) {
    if (widget.onPayClick != null) {
      Navigator.pop(context);
      widget.onPayClick!();
    }
  }

  _onUnPayButtonClick(BuildContext context) {
    if (widget.onUnPayClick != null) {
      Navigator.pop(context);
      widget.onUnPayClick!();
    }
  }

  _onEditButtonClick(BuildContext context) {
    if (widget.onEditClick != null) {
      Navigator.pop(context);
      widget.onEditClick!();
    }
  }

  _onHistoryButtonClick(BuildContext context) {
    if (widget.onHistoryClick != null) {
      Navigator.pop(context);
      widget.onHistoryClick!(_currentUserId);
    }
  }
}
