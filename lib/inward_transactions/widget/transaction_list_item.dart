import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../add_project/model/milestone_info.dart';
import '../../app_widgets/min_width_container.dart';
import '../../config/app_config.dart';
import '../../config/preference_config.dart';
import '../../const/dimens.dart';
import '../../const/strings.dart';
import '../../enums/color_enums.dart';
import '../../enums/project_type_enum.dart';
import '../../enums/transaction_type_enum.dart';
import '../../utils/app_utils.dart';
import '../../utils/color_utils.dart';
import '../model/transaction_info.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionInfo transactionInfo;
  final MilestoneInfo? milestoneInfo;

  const TransactionListItem({
    Key? key,
    required this.transactionInfo,
    required this.milestoneInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.screenHorizontalMargin.w,
            vertical: Dimens.projectListItemVerticalSpace.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _projectTypeAndCodeWidget(context),
              SizedBox(
                width: Dimens.projectListItemContentSpacing.w,
              ),
              Expanded(
                child: _projectNameAndStartDateWidget(
                  context,
                  appLocalizations,
                ),
              ),
              SizedBox(
                width: Dimens.projectListItemContentSpacing.w,
              ),
              _amountWidget(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _projectTypeAndCodeWidget(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: ColorUtils.getColor(
            context,
            ColorEnums.black33Color,
          ),
          radius: Dimens.projectListProjectTypeCircleRadius.r,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.projectListProjectTypeIconHorizontalSpace.w,
              vertical: Dimens.projectListProjectTypeIconVerticalSpace.h,
            ),
            child: SvgPicture.asset(
              getProjectTypeIcon(),
              width: double.infinity,
              height: double.infinity,
              colorFilter: ColorFilter.mode(
                ColorUtils.getColor(
                  context,
                  ColorEnums.whiteColor,
                ),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        if (transactionInfo.projectCode != null)
          SizedBox(
            height: Dimens.projectListProjectCodeTopSpacing.h,
          ),
        if (transactionInfo.projectCode != null)
          Text(
            '#${(transactionInfo.projectCode!.length > AppConfig.projectCodeMaxLength) ? transactionInfo.projectCode!.substring(0, AppConfig.projectCodeMaxLength) : transactionInfo.projectCode}',
            style: TextStyle(
              color: ColorUtils.getColor(
                context,
                ColorEnums.gray6CColor,
              ),
              fontWeight: FontWeight.w700,
              fontSize: Dimens.projectListProjectCodeTextSize.sp,
              overflow: TextOverflow.clip,
            ),
          ),
      ],
    );
  }

  Widget _projectNameAndStartDateWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    String transactionFor = '';

    String? transactionType = transactionInfo.transactionType;
    String? milestoneAmount = transactionInfo.milestoneAmount != null
        ? _getAmountToDisplay(transactionInfo.milestoneAmount)
        : milestoneInfo?.milestoneAmount != null
            ? _getAmountToDisplay(milestoneInfo?.milestoneAmount)
            : null;

    String? paidAmount;
    if (transactionInfo.paidAmount != null) {
      paidAmount = _getAmountToDisplay(transactionInfo.paidAmount);
      transactionType ??= TransactionTypeEnum.paid.name;
    }

    String? unPaidAmount;
    if (transactionInfo.unPaidAmount != null) {
      unPaidAmount = _getAmountToDisplay(transactionInfo.unPaidAmount);
      transactionType ??= TransactionTypeEnum.unpaid.name;
    }
    String? lastAmount;
    String? lastDate;
    String? milestoneDate = transactionInfo.milestoneDate != null
        ? DateFormat(AppConfig.projectStartDateFormat).format(
            DateTime.fromMillisecondsSinceEpoch(
              transactionInfo.milestoneDate!,
            ),
          )
        : milestoneInfo?.dateTime != null
            ? DateFormat(AppConfig.projectStartDateFormat).format(
                milestoneInfo!.dateTime!,
              )
            : null;
    String? transactionUpdatedValues;
    String? secondaryValues;
    if (milestoneDate != null && milestoneAmount != null) {
      secondaryValues = '(M $milestoneDate / $milestoneAmount)';
    }
    if (transactionType == TransactionTypeEnum.paid.name) {
      transactionFor = '${appLocalizations.paid} ';
      transactionUpdatedValues = paidAmount;
    } else if (transactionType == TransactionTypeEnum.unpaid.name) {
      transactionFor = '${appLocalizations.unPaid} ';
      transactionUpdatedValues = unPaidAmount;
    } else if (transactionType == TransactionTypeEnum.invoiced.name) {
      transactionFor = '${appLocalizations.invoiced} ';
      transactionUpdatedValues = milestoneAmount;
    } else if (transactionType == TransactionTypeEnum.unInvoiced.name) {
      transactionFor = '${appLocalizations.invoicedRemoved} ';
      transactionUpdatedValues = milestoneAmount;
    } else if (transactionType == TransactionTypeEnum.edited.name) {
      transactionFor = '${appLocalizations.editedMilestone} ';
      lastAmount = _getAmountToDisplay(transactionInfo.lastMilestoneAmount);
      lastDate = transactionInfo.lastMilestoneDate != null
          ? DateFormat(AppConfig.projectStartDateFormat).format(
              DateTime.fromMillisecondsSinceEpoch(
                transactionInfo.lastMilestoneDate!,
              ),
            )
          : null;
      if (lastAmount != null && lastDate != null) {
        secondaryValues = '(M $lastDate / $lastAmount)';
      }
      if (milestoneAmount != null) {
        transactionUpdatedValues = '$milestoneDate / $milestoneAmount';
      }
    } else if (transactionInfo.transactionType ==
        TransactionTypeEnum.created.name) {
      transactionFor = appLocalizations.createdMilestone;
    } else if (transactionInfo.transactionType ==
        TransactionTypeEnum.deleted.name) {
      transactionFor = appLocalizations.deletedMilestone;
    } else if (transactionInfo.transactionType ==
        TransactionTypeEnum.projectCreated.name) {
      transactionFor = appLocalizations.projectCreated;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          transactionInfo.projectName ?? '',
          style: TextStyle(
            fontSize: Dimens.projectListProjectNameTextSize.sp,
            color: ColorUtils.getColor(
              context,
              ColorEnums.black33Color,
            ),
            overflow: TextOverflow.clip,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
        ),
        SizedBox(
          height: Dimens.projectListProjectStartDateTopSpacing.h,
        ),
        RichText(
          text: TextSpan(
            text: transactionFor,
            style: TextStyle(
              color: ColorUtils.getColor(
                context,
                ColorEnums.gray6CColor,
              ),
              fontSize: Dimens.projectListProjectStartDateTextSize.sp,
            ),
            children: [
              TextSpan(
                text: '${transactionUpdatedValues ?? ''} ',
                style: TextStyle(
                  color: ColorUtils.getColor(
                    context,
                    ColorEnums.black33Color,
                  ),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (secondaryValues != null)
                TextSpan(
                  text: secondaryValues,
                  style: TextStyle(
                    color: ColorUtils.getColor(
                      context,
                      ColorEnums.black33Color,
                    ),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(
          height: Dimens.projectListProjectStartDateTopSpacing.h,
        ),
        FutureBuilder(
          future: getReceiverName(appLocalizations),
          builder: (context, snapshot) {
            String receiverName = '-';
            if (snapshot.hasData) {
              receiverName = snapshot.data ?? receiverName;
            }
            return RichText(
              text: TextSpan(
                text: '${appLocalizations.transactionOn} ',
                style: TextStyle(
                  color: ColorUtils.getColor(
                    context,
                    ColorEnums.gray6CColor,
                  ),
                  fontSize: Dimens.projectListProjectStartDateTextSize.sp,
                ),
                children: [
                  TextSpan(
                    text: transactionInfo.transactionDate != null
                        ? DateFormat(AppConfig.project24HrTimeDateFormat)
                            .format(
                            DateTime.fromMillisecondsSinceEpoch(
                              transactionInfo.transactionDate!,
                            ),
                          )
                        : '-',
                    style: TextStyle(
                      color: ColorUtils.getColor(
                        context,
                        ColorEnums.black33Color,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(text: ' ${appLocalizations.transactionBy} '),
                  TextSpan(
                    text: receiverName,
                    style: TextStyle(
                      color: ColorUtils.getColor(
                        context,
                        ColorEnums.black33Color,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
      ],
    );
  }

  _getAmountToDisplay(double? amount) {
    final amountValue = AppUtils.removeTrailingZero(amount);
    return (amountValue.length > AppConfig.projectAmountMaxLength)
        ? '${amountValue.substring(
            0,
            AppConfig.projectAmountMaxLength,
          )}...'
        : amountValue;
  }

  Widget _amountWidget(BuildContext context) {
    String? transactionType = transactionInfo.transactionType;
    String? milestoneAmount = transactionInfo.milestoneAmount != null
        ? _getAmountToDisplay(transactionInfo.milestoneAmount)
        : null;

    String? paidAmount;
    if (transactionInfo.paidAmount != null) {
      paidAmount = _getAmountToDisplay(transactionInfo.paidAmount);
      transactionType ??= TransactionTypeEnum.paid.name;
    }

    String? unPaidAmount;
    if (transactionInfo.unPaidAmount != null) {
      unPaidAmount = _getAmountToDisplay(transactionInfo.unPaidAmount);
      transactionType ??= TransactionTypeEnum.unpaid.name;
    }

    String? amountToDisplay = paidAmount ?? unPaidAmount ?? milestoneAmount;
    if (transactionType == TransactionTypeEnum.created.name ||
        transactionType == TransactionTypeEnum.edited.name ||
        transactionType == TransactionTypeEnum.deleted.name ||
        (amountToDisplay ?? '').trim().isEmpty) {
      return const SizedBox();
    }
    return MinWidthContainer(
      minWidth: Dimens.projectListMilestoneBlockMinWidth.h,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: ColorUtils.getColor(
              context,
              ColorEnums.grayE0Color,
            ),
            width: Dimens.projectListMilestoneBorderSize.w,
          ),
          borderRadius: BorderRadius.circular(
            Dimens.projectListMilestoneBorderRadius.r,
          ),
          color: ColorUtils.getColor(
            context,
            transactionType == TransactionTypeEnum.paid.name
                ? ColorEnums.greenF2FCF3Color
                : transactionType == TransactionTypeEnum.unpaid.name
                    ? ColorEnums.redFDF3F3Color
                    : (transactionType == TransactionTypeEnum.invoiced.name ||
                            transactionType ==
                                TransactionTypeEnum.unInvoiced.name)
                        ? ColorEnums.amberF59032Color
                        : ColorEnums.grayEAColor,
          ).withOpacity(
            (transactionType == TransactionTypeEnum.invoiced.name ||
                    transactionType == TransactionTypeEnum.unInvoiced.name)
                ? 0.05
                : 1,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.projectListMilestoneBlockHorizontalPadding.w,
          vertical: Dimens.projectListMilestoneBlockVerticalPadding.h,
        ),
        alignment: Alignment.center,
        child: Text(
          amountToDisplay!,
          style: TextStyle(
            color: ColorUtils.getColor(
              context,
              ColorEnums.black33Color,
            ),
            fontWeight: FontWeight.w700,
            fontSize: Dimens.projectListMilestoneDarkBlockTextSize.sp,
          ),
          maxLines: 1,
        ),
      ),
    );
  }

  String getProjectTypeIcon() {
    return (transactionInfo.projectType == ProjectTypeEnum.fixed.name)
        ? Strings.dollar
        : (transactionInfo.projectType == ProjectTypeEnum.timeAndMaterial.name)
            ? Strings.clock
            : (transactionInfo.projectType == ProjectTypeEnum.retainer.name)
                ? Strings.refresh
                : Strings.bulb;
  }

  Future<String> getReceiverName(AppLocalizations appLocalizations) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString(PreferenceConfig.userIdPref);
    if (currentUserId == transactionInfo.transactionByUserId) {
      return appLocalizations.you;
    } else if (transactionInfo.transactionByName?.trim().isNotEmpty ?? false) {
      return transactionInfo.transactionByName!;
    }
    return '-';
  }
}
