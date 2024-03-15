import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../const/dimens.dart';
import '../enums/color_enums.dart';
import '../utils/color_utils.dart';

class ListItemShimmer extends StatelessWidget {
  final int shimmerItemCount;
  final bool isTransactionShimmerView;

  const ListItemShimmer({
    Key? key,
    required this.shimmerItemCount,
    this.isTransactionShimmerView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: shimmerItemCount,
      itemBuilder: (ctx, index) {
        return _itemWidget(context);
      },
      separatorBuilder: (context, index) {
        return Divider(
          height: 0,
          color: ColorUtils.getColor(
            context,
            ColorEnums.grayD9Color,
          ),
        );
      },
    );
  }

  Widget _itemWidget(BuildContext context) {
    final baseColor = ColorUtils.getColor(
      context,
      ColorEnums.shimmerBaseColor,
    );
    final highlightedColor = ColorUtils.getColor(
      context,
      ColorEnums.shimmerHighlightedColor,
    );
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.screenHorizontalMargin.w,
        vertical: Dimens.projectListItemVerticalSpace.h,
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightedColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _projectTypeAndCodeWidget(baseColor),
            SizedBox(
              width: Dimens.projectListItemContentSpacing.w,
            ),
            Expanded(
              child: _projectNameAndStartDateWidget(baseColor),
            ),
            SizedBox(
              width: Dimens.projectListItemContentSpacing.w,
            ),
            if (isTransactionShimmerView) _transactionView(baseColor),
            if (!isTransactionShimmerView) _projectMilestoneOverview(baseColor),
          ],
        ),
      ),
    );
  }

  Widget _projectTypeAndCodeWidget(Color baseColor) {
    return Column(
      children: [
        CircleAvatar(
          radius: Dimens.projectListProjectTypeCircleRadius.r,
        ),
        SizedBox(
          height: Dimens.projectListProjectCodeTopSpacing.h,
        ),
        Container(
          width: Dimens.projectListProjectTypeCircleRadius.w,
          height: 10.h,
          color: baseColor,
        ),
      ],
    );
  }

  Widget _projectNameAndStartDateWidget(Color baseColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: (Dimens.projectListProjectStartDateTopSpacing * 2).h,
        ),
        Container(
          width: double.infinity,
          height: 25.h,
          color: baseColor,
        ),
        SizedBox(
          height: (Dimens.projectListProjectStartDateTopSpacing * 2).h,
        ),
        Container(
          width: 100.w,
          height: 20.h,
          color: baseColor,
        ),
      ],
    );
  }

  Widget _projectMilestoneOverview(Color baseColor) {
    return Row(
      children: [
        _milestoneItem(baseColor, true, false),
        _milestoneItem(baseColor, false, true),
      ],
    );
  }

  Widget _transactionView(Color baseColor) {
    return _milestoneItem(baseColor, true, true);
  }

  Widget _milestoneItem(
    Color baseColor,
    bool isLeftCornerRounded,
    bool isRightCornerRounded,
  ) {
    return Container(
      width: Dimens.projectListMilestoneBlockMinWidth.w,
      height: 70.h,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: baseColor,
            width: Dimens.projectListMilestoneBorderSize.w,
          ),
          left: BorderSide(
            color: baseColor,
            width: isLeftCornerRounded
                ? Dimens.projectListMilestoneBorderSize.w
                : (Dimens.projectListMilestoneBorderSize / 2).w,
          ),
          right: BorderSide(
            color: baseColor,
            width: isRightCornerRounded
                ? Dimens.projectListMilestoneBorderSize.w
                : (Dimens.projectListMilestoneBorderSize / 2).w,
          ),
          bottom: BorderSide(
            color: baseColor,
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
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50.w,
            height: 21.h,
            color: baseColor,
          ),
          if (!isTransactionShimmerView)
            SizedBox(
              height: (Dimens.projectListProjectStartDateTopSpacing * 2).h,
            ),
          if (!isTransactionShimmerView)
            Container(
              width: 30.w,
              height: 12.h,
              color: baseColor,
            ),
        ],
      ),
    );
  }
}
