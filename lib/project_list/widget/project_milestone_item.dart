import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app_widgets/min_width_container.dart';
import '../../config/app_config.dart';
import '../../const/dimens.dart';
import '../../const/strings.dart';
import '../../enums/color_enums.dart';
import '../../utils/color_utils.dart';

class ProjectMilestoneItem extends StatelessWidget {
  final bool isLeftCornerRounded;
  final bool isRightCornerRounded;
  final ColorEnums blockBgColor;
  final String darkText;
  final String lightText;
  final bool isNeedToAddMilestone;
  final bool isLeftSpacingRequired;
  final bool isRightSpacingRequired;
  final Function? onMilestoneClick;
  final bool isMilestoneUpdated;
  final double? customWidth;
  final bool isMilestoneInvoiced;

  const ProjectMilestoneItem({
    Key? key,
    required this.darkText,
    required this.lightText,
    this.isLeftCornerRounded = false,
    this.isRightCornerRounded = false,
    this.blockBgColor = ColorEnums.whiteColor,
    this.isNeedToAddMilestone = false,
    this.isLeftSpacingRequired = false,
    this.isRightSpacingRequired = false,
    this.onMilestoneClick,
    this.isMilestoneUpdated = false,
    this.customWidth,
    this.isMilestoneInvoiced = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MinWidthContainer(
      minWidth: customWidth ?? Dimens.projectListMilestoneBlockMinWidth.h,
      child: InkWell(
        onTap: () {
          if (onMilestoneClick != null) {
            onMilestoneClick!();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: ColorUtils.getColor(
                  context,
                  ColorEnums.grayE0Color,
                ),
                width: Dimens.projectListMilestoneBorderSize.w,
              ),
              left: BorderSide(
                color: ColorUtils.getColor(
                  context,
                  ColorEnums.grayE0Color,
                ),
                width: isLeftCornerRounded
                    ? Dimens.projectListMilestoneBorderSize.w
                    : (Dimens.projectListMilestoneBorderSize / 2).w,
              ),
              right: BorderSide(
                color: ColorUtils.getColor(
                  context,
                  ColorEnums.grayE0Color,
                ),
                width: isRightCornerRounded
                    ? Dimens.projectListMilestoneBorderSize.w
                    : (Dimens.projectListMilestoneBorderSize / 2).w,
              ),
              bottom: BorderSide(
                color: ColorUtils.getColor(
                  context,
                  ColorEnums.grayE0Color,
                ),
                width: Dimens.projectListMilestoneBorderSize.w,
              ),
            ),
            borderRadius: (isLeftCornerRounded && isRightCornerRounded)
                ? BorderRadius.circular(
                    Dimens.projectListMilestoneBorderRadius.r,
                  )
                : isLeftCornerRounded
                    ? BorderRadius.only(
                        topLeft: Radius.circular(
                          Dimens.projectListMilestoneBorderRadius.r,
                        ),
                        bottomLeft: Radius.circular(
                          Dimens.projectListMilestoneBorderRadius.r,
                        ),
                      )
                    : isRightCornerRounded
                        ? BorderRadius.only(
                            topRight: Radius.circular(
                              Dimens.projectListMilestoneBorderRadius.r,
                            ),
                            bottomRight: Radius.circular(
                              Dimens.projectListMilestoneBorderRadius.r,
                            ),
                          )
                        : BorderRadius.zero,
            color: isNeedToAddMilestone
                ? ColorUtils.getColor(
                    context,
                    ColorEnums.blueColor,
                  ).withOpacity(0.1)
                : ColorUtils.getColor(
                    context,
                    blockBgColor,
                  ),
          ),
          margin: EdgeInsets.only(
            left: isLeftSpacingRequired ? Dimens.screenHorizontalMargin.w : 0,
            right: isRightSpacingRequired ? Dimens.screenHorizontalMargin.w : 0,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      Dimens.projectListMilestoneBlockHorizontalPadding.w,
                  vertical: Dimens.projectListMilestoneBlockVerticalPadding.h,
                ),
                child: _contentWidget(context),
              ),
              if (isMilestoneUpdated)
                Positioned(
                  top: (Dimens.projectListMilestoneBlockVerticalPadding / 2).w,
                  right:
                      (Dimens.projectListMilestoneBlockVerticalPadding / 2).w,
                  child: CircleAvatar(
                    backgroundColor: ColorUtils.getColor(
                      context,
                      ColorEnums.black33Color,
                    ),
                    radius: Dimens.projectListMilestoneUpdatedCircleSize.r,
                  ),
                ),
              if (isMilestoneInvoiced)
                Positioned(
                  top: (Dimens.projectListMilestoneBlockVerticalPadding / 2).w,
                  left: (Dimens.projectListMilestoneBlockVerticalPadding / 2).w,
                  child: Container(
                    height: Dimens.projectListMilestoneInvoicedCheckIconSize.w,
                    width: Dimens.projectListMilestoneInvoicedCheckIconSize.w,
                    decoration: BoxDecoration(
                      color: ColorUtils.getColor(
                        context,
                        ColorEnums.black00Color,
                      ),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(
                      Dimens
                          .projectListMilestoneInvoicedCheckIconInnerPadding.w,
                    ),
                    child: SvgPicture.asset(
                      Strings.checked,
                      height:
                          Dimens.projectListMilestoneInvoicedCheckIconSize.w,
                      width: Dimens.projectListMilestoneInvoicedCheckIconSize.w,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _contentWidget(BuildContext context) {
    if (isNeedToAddMilestone) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            Strings.add,
            width: Dimens.projectListMilestoneBlockAddIconSize.w,
            height: Dimens.projectListMilestoneBlockAddIconSize.w,
            colorFilter: ColorFilter.mode(
              ColorUtils.getColor(
                context,
                ColorEnums.blueColor,
              ),
              BlendMode.srcIn,
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Text(
          (darkText.length > AppConfig.projectAmountMaxLength)
              ? '${darkText.substring(
                  0,
                  AppConfig.projectAmountMaxLength,
                )}...'
              : darkText,
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
        SizedBox(
          height: Dimens.projectListMilestoneLightBlockTopSpacing.h,
        ),
        Text(
          lightText,
          style: TextStyle(
            color: ColorUtils.getColor(
              context,
              ColorEnums.black33Color,
            ),
            fontSize: Dimens.projectListMilestoneLightBlockTextSize.sp,
          ),
        ),
      ],
    );
  }
}
