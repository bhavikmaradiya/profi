import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import './bloc/dialog_bloc.dart';
import '../add_project/model/milestone_info.dart';
import '../add_project/model/project_info.dart';
import '../app_widgets/app_date_picker.dart';
import '../app_widgets/app_outline_button.dart';
import '../app_widgets/app_text_field.dart';
import '../config/app_config.dart';
import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../enums/error_enum.dart';
import '../keyboard_action/keyboard_actions.dart';
import '../project_list/utils/milestone_utils.dart';
import '../utils/app_utils.dart';
import '../utils/color_utils.dart';
import '../utils/decimal_text_input_formatter.dart';

class EditDialog extends StatefulWidget {
  final ProjectInfo projectInfo;
  final MilestoneInfo? milestoneInfo;
  final Function(String amount, String note, DateTime? dateTime)? onSaveClick;
  final VoidCallback? onDeleteClick;
  final bool isNewMilestoneToAdd;

  const EditDialog({
    Key? key,
    required this.projectInfo,
    required this.milestoneInfo,
    this.onSaveClick,
    this.onDeleteClick,
    this.isNewMilestoneToAdd = false,
  }) : super(key: key);

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final amountFieldFocusNode = Platform.isIOS ? FocusNode() : null;
  late DateTime? _selectedDateTime;
  late bool isFullyPaidMilestone;
  DialogBloc? _dialogBlocProvider;

  @override
  void initState() {
    final milestoneInfo = widget.milestoneInfo;
    if (milestoneInfo != null) {
      _selectedDateTime = milestoneInfo.dateTime;
      isFullyPaidMilestone = MilestoneUtils.isFullyPaidMilestone(
        milestoneInfo,
      );
      double amount = milestoneInfo.milestoneAmount ?? 0;
      if (amount != 0) {
        _amountController.text = AppUtils.removeTrailingZero(amount);
      }
    } else {
      final dateTime = DateTime.now();
      final currentDate = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
      );
      _selectedDateTime = currentDate;
      final projectStartDateTimestamp = widget.projectInfo.projectStartDate;
      if (projectStartDateTimestamp != null) {
        final projectStartDate = DateTime.fromMillisecondsSinceEpoch(
          projectStartDateTimestamp,
        );
        if (currentDate.isBefore(projectStartDate)) {
          _selectedDateTime = projectStartDate;
        }
      }
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
          if (!widget.isNewMilestoneToAdd)
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
                    Navigator.pop(context, _isNeedToReopenPaidDialog());
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
    if (projectName.isNotEmpty && !widget.isNewMilestoneToAdd) {
      projectName = '$projectName - ${appLocalizations.edit}';
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
        color: !widget.isNewMilestoneToAdd
            ? ColorUtils.getColor(
                context,
                MilestoneUtils.getMilestoneBlockColor(
                  milestoneInfo,
                ),
              )
            : ColorUtils.getColor(
                context,
                ColorEnums.blueE6F1F9Color,
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
              const Expanded(
                child: SizedBox(),
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
                }
                return Text(
                  message,
                  style: TextStyle(
                    fontSize: Dimens.milestoneAmountErrorTextSize.sp,
                    color: ColorUtils.getColor(
                      context,
                      ColorEnums.redColor,
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
          InkWell(
            onTap: () async {
              final dateTime = DateTime.now();
              final currentDate = DateTime(
                dateTime.year,
                dateTime.month,
                dateTime.day,
              );
              final firstDate = widget.projectInfo.projectStartDate != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                      widget.projectInfo.projectStartDate!,
                    )
                  : currentDate;
              final lastDate = currentDate.add(
                const Duration(
                  days: AppConfig.datePickerFutureDays,
                ),
              );
              DateTime selectedDate = _selectedDateTime ?? firstDate;
              if (firstDate.isAfter(selectedDate)) {
                selectedDate = firstDate;
              }
              final date = await AppDatePicker.selectDate(
                context: context,
                selectedDate: selectedDate,
                calendarFirstDate: firstDate,
                calendarLastDate: lastDate,
              );
              if (date != null) {
                setState(() {
                  _selectedDateTime = date;
                });
              }
            },
            child: Row(
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
                      ColorEnums.black33Color,
                    ),
                  ),
                ),
                SizedBox(
                  width: Dimens.dialogDateTextEditIconSpacing.w,
                ),
                SvgPicture.asset(
                  Strings.calendar,
                  width: Dimens.dialogEditIconSize.w,
                  height: Dimens.dialogEditIconSize.w,
                  colorFilter: ColorFilter.mode(
                    ColorUtils.getColor(
                      context,
                      ColorEnums.gray99Color,
                    ),
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<DialogBloc, DialogState>(
            buildWhen: (previous, current) =>
                previous != current && current is InvalidMilestoneDateState,
            builder: (context, state) {
              if (state is InvalidMilestoneDateState) {
                return Text(
                  appLocalizations.invalidMilestoneDate,
                  style: TextStyle(
                    fontSize: Dimens.milestoneAmountErrorTextSize.sp,
                    color: ColorUtils.getColor(
                      context,
                      ColorEnums.redColor,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
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
          _saveDeleteOperations(
            context,
            appLocalizations,
          ),
        ],
      ),
    );
  }

  Widget _saveDeleteOperations(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Row(
      children: [
        Expanded(
          child: AppOutlineButton(
            title: widget.isNewMilestoneToAdd
                ? appLocalizations.add
                : appLocalizations.save,
            textColorEnum: ColorEnums.black33Color,
            onButtonPressed: () {
              _onSaveButtonClick(context);
            },
            isEnabled: !isFullyPaidMilestone,
          ),
        ),
        if (!widget.isNewMilestoneToAdd)
          SizedBox(
            width: Dimens.dialogButtonSpacing.w,
          ),
        if (!widget.isNewMilestoneToAdd)
          Expanded(
            child: AppOutlineButton(
              title: appLocalizations.delete,
              textColorEnum: ColorEnums.redColor,
              onButtonPressed: () {
                // Here to display confirmation dialog
                // first we need to close this dialog and
                // then open confirmation dialog so don't change sequence of code
                Navigator.pop(context, false);
                _onDeleteButtonClick();
              },
              isEnabled: !isFullyPaidMilestone,
            ),
          ),
      ],
    );
  }

  _onSaveButtonClick(BuildContext context) {
    if (widget.onSaveClick != null) {
      final amount = _amountController.text.toString().trim();
      final isValidAmount = _dialogBlocProvider?.isValidAmount(
        milestoneInfo: widget.milestoneInfo,
        enteredAmount: amount,
      );
      final isValidDate = _dialogBlocProvider?.isValidDate(
        projectStartDate: DateTime.fromMillisecondsSinceEpoch(
          widget.projectInfo.projectStartDate ?? 0,
        ),
        milestoneDate: _selectedDateTime,
      );
      if ((isValidAmount ?? false) && (isValidDate ?? false)) {
        final note = _noteController.text.toString().trim();
        widget.onSaveClick!(
          amount,
          note,
          _selectedDateTime,
        );
        Navigator.pop(context, false);
      }
    }
  }

  _onDeleteButtonClick() {
    if (widget.onDeleteClick != null) {
      widget.onDeleteClick!();
    }
  }

  _isNeedToReopenPaidDialog() {
    return !widget.isNewMilestoneToAdd;
  }
}
