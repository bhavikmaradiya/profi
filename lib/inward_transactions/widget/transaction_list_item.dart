import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_widgets/min_width_container.dart';
import '../../config/app_config.dart';
import '../../config/preference_config.dart';
import '../../const/dimens.dart';
import '../../const/strings.dart';
import '../../enums/color_enums.dart';
import '../../enums/project_type_enum.dart';
import '../../utils/app_utils.dart';
import '../../utils/color_utils.dart';
import '../model/transaction_info.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionInfo transactionInfo;

  const TransactionListItem({
    Key? key,
    required this.transactionInfo,
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
    if (transactionInfo.paidAmount != null) {
      transactionFor = '${appLocalizations.paidOn} ';
    } else if (transactionInfo.unPaidAmount != null) {
      transactionFor = '${appLocalizations.unPaidOn} ';
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
        FutureBuilder(
          future: getReceiverName(appLocalizations),
          builder: (context, snapshot) {
            String receiverName = '-';
            if (snapshot.hasData) {
              receiverName = snapshot.data ?? receiverName;
            }
            return RichText(
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
                    text: transactionInfo.transactionDate != null
                        ? DateFormat(AppConfig.projectStartDateFormat).format(
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
                  TextSpan(text: ' ${appLocalizations.by} '),
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

  Widget _amountWidget(BuildContext context) {
    String value = '';
    if (transactionInfo.paidAmount != null) {
      final paidAmountValue = AppUtils.removeTrailingZero(
        transactionInfo.paidAmount,
      );

      value = (paidAmountValue.length > AppConfig.projectAmountMaxLength)
          ? '${paidAmountValue.substring(
              0,
              AppConfig.projectAmountMaxLength,
            )}...'
          : paidAmountValue;
    } else if (transactionInfo.unPaidAmount != null) {
      final unPaidAmountValue = AppUtils.removeTrailingZero(
        transactionInfo.unPaidAmount,
      );

      value = (unPaidAmountValue.length > AppConfig.projectAmountMaxLength)
          ? '${unPaidAmountValue.substring(
              0,
              AppConfig.projectAmountMaxLength,
            )}...'
          : unPaidAmountValue;
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
            transactionInfo.paidAmount != null
                ? ColorEnums.greenF2FCF3Color
                : ColorEnums.redFDF3F3Color,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.projectListMilestoneBlockHorizontalPadding.w,
          vertical: Dimens.projectListMilestoneBlockVerticalPadding.h,
        ),
        alignment: Alignment.center,
        child: Text(
          value,
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
