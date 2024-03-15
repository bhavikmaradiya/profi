import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../app_widgets/app_date_picker.dart';
import '../../config/app_config.dart';
import '../../const/dimens.dart';
import '../../const/strings.dart';
import '../../enums/color_enums.dart';
import '../../keyboard_action/keyboard_actions.dart';
import '../../project_list/utils/milestone_utils.dart';
import '../../utils/app_utils.dart';
import '../../utils/color_utils.dart';
import '../../utils/decimal_text_input_formatter.dart';
import '../add_project_field_bloc/add_project_field_bloc.dart';
import '../model/milestone_info.dart';

class MilestoneItem extends StatelessWidget {
  final MilestoneInfo mileStoneInfo;
  final AppLocalizations appLocalizations;
  final bool isTopLeftRounded;
  final bool isBottomLeftRounded;
  final bool isEdit;
  final bool isNeedToSetInitialValue;

  const MilestoneItem({
    Key? key,
    required this.mileStoneInfo,
    required this.appLocalizations,
    this.isTopLeftRounded = false,
    this.isBottomLeftRounded = false,
    this.isEdit = false,
    this.isNeedToSetInitialValue = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final blocProvider = BlocProvider.of<AddProjectFieldBloc>(
      context,
      listen: false,
    );
    final amount = (mileStoneInfo.milestoneAmount != null &&
            mileStoneInfo.milestoneAmount! > 0)
        ? AppUtils.removeTrailingZero(
            mileStoneInfo.milestoneAmount,
          )
        : '';
    return SizedBox(
      width: double.infinity,
      height: Dimens.fieldHeight.h,
      child: Row(
        children: [
          Container(
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  isTopLeftRounded
                      ? Dimens.addProjectMilestoneBorderRadius.r
                      : 0,
                ),
                bottomLeft: Radius.circular(
                  isBottomLeftRounded
                      ? Dimens.addProjectMilestoneBorderRadius.r
                      : 0,
                ),
              ),
              color: ColorUtils.getColor(
                context,
                MilestoneUtils.getMilestoneBlockColor(mileStoneInfo),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.addProjectMilestoneBorderSpacing.w,
                  ),
                  child: SvgPicture.asset(
                    Strings.milestone,
                    width: Dimens.addProjectMilestoneIconSize.w,
                    height: Dimens.addProjectMilestoneIconSize.w,
                    colorFilter: ColorFilter.mode(
                      ColorUtils.getColor(
                        context,
                        mileStoneInfo.dateTime != null
                            ? ColorEnums.black33Color
                            : ColorEnums.gray99Color,
                      ),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                if (mileStoneInfo.isUpdated ?? false)
                  Positioned(
                    top: (Dimens.addProjectMilestoneBorderSpacing / 2).w,
                    right: (Dimens.addProjectMilestoneBorderSpacing / 2).w,
                    child: CircleAvatar(
                      backgroundColor: ColorUtils.getColor(
                        context,
                        ColorEnums.black33Color,
                      ),
                      radius: Dimens.addProjectMilestoneUpdatedCircleSize.r,
                    ),
                  ),
              ],
            ),
          ),
          VerticalDivider(
            width: 0,
            color: ColorUtils.getColor(
              context,
              ColorEnums.grayD9Color,
            ),
          ),
          Flexible(
            flex: 3,
            child: InkWell(
              onTap: () async {
                FocusManager.instance.rootScope.unfocus();
                final dateTime = DateTime.now();
                final currentDate = DateTime(
                  dateTime.year,
                  dateTime.month,
                  dateTime.day,
                );
                final firstDate =
                    blocProvider.getProjectStartDate() ?? currentDate;
                final lastDate = currentDate.add(
                  const Duration(
                    days: AppConfig.datePickerFutureDays,
                  ),
                );
                DateTime selectedDate = mileStoneInfo.dateTime ?? firstDate;
                if (firstDate.isAfter(selectedDate)) {
                  selectedDate = firstDate;
                }
                final selectedDateTime = await AppDatePicker.selectDate(
                  context: context,
                  selectedDate: selectedDate,
                  calendarFirstDate: firstDate,
                  calendarLastDate: lastDate,
                );
                if (selectedDateTime != null) {
                  mileStoneInfo.dateTime = selectedDateTime;
                  blocProvider.add(
                    ChangeMilestoneInfoEvent(
                      mileStoneInfo,
                      false,
                      isEdit,
                    ),
                  );
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.addProjectMilestoneBorderSpacing.w,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        mileStoneInfo.dateTime != null
                            ? DateFormat(AppConfig.milestoneInfoDateFormat)
                                .format(mileStoneInfo.dateTime!)
                            : appLocalizations.date,
                        style: TextStyle(
                          color: ColorUtils.getColor(
                            context,
                            mileStoneInfo.dateTime != null
                                ? ColorEnums.black33Color
                                : ColorEnums.grayA8Color,
                          ),
                          fontSize: Dimens.addProjectMilestoneDateTextSize.sp,
                        ),
                      ),
                    ),
                    SvgPicture.asset(
                      Strings.date,
                      width: Dimens.addProjectMilestoneCalendarSize.w,
                      height: Dimens.addProjectMilestoneCalendarSize.w,
                      colorFilter: ColorFilter.mode(
                        ColorUtils.getColor(
                          context,
                          ColorEnums.grayE0Color,
                        ),
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          VerticalDivider(
            width: 0,
            thickness: Dimens.addProjectMilestoneBorderSize.w,
            color: ColorUtils.getColor(
              context,
              ColorEnums.grayD9Color,
            ),
          ),
          Flexible(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.addProjectMilestoneBorderSpacing.w,
              ),
              child: Row(
                children: [
                  Expanded(
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
                            focusNode: mileStoneInfo.amountFieldFocusNode ??
                                FocusNode(canRequestFocus: false),
                            displayArrows: false,
                            displayDoneButton: true,
                          ),
                        ],
                      ),
                      child: TextFormField(
                        initialValue: isNeedToSetInitialValue ? amount : null,
                        focusNode: mileStoneInfo.amountFieldFocusNode,
                        decoration: InputDecoration(
                          hintText: appLocalizations.amount,
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: ColorUtils.getColor(
                              context,
                              ColorEnums.grayA8Color,
                            ),
                            fontSize:
                                Dimens.addProjectMilestoneAmountTextSize.sp,
                          ),
                        ),
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
                          fontSize: Dimens.addProjectMilestoneAmountTextSize.sp,
                        ),
                        cursorColor: ColorUtils.getColor(
                          context,
                          ColorEnums.black33Color,
                        ),
                        cursorWidth: 1,
                        controller: isNeedToSetInitialValue
                            ? null
                            : mileStoneInfo.amountFieldController ??
                                TextEditingController(
                                  text: amount,
                                ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,
                        onChanged: (value) {
                          if (value.trim().isNotEmpty) {
                            mileStoneInfo.milestoneAmount =
                                double.parse(value.trim());
                          } else {
                            mileStoneInfo.milestoneAmount = 0;
                          }
                          mileStoneInfo.amountFieldController?.text =
                              (mileStoneInfo.milestoneAmount != null &&
                                      mileStoneInfo.milestoneAmount! > 0)
                                  ? AppUtils.removeTrailingZero(
                                      mileStoneInfo.milestoneAmount,
                                    )
                                  : '';
                          blocProvider.add(
                            ChangeMilestoneInfoEvent(
                              mileStoneInfo,
                              true,
                              isEdit,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      blocProvider.add(RemoveMilestoneEvent(mileStoneInfo.id));
                    },
                    child: SvgPicture.asset(
                      Strings.milestoneClose,
                      width: Dimens.addProjectMilestoneCloseSize.w,
                      height: Dimens.addProjectMilestoneCloseSize.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
