import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../const/dimens.dart';
import '../../enums/color_enums.dart';
import '../../utils/color_utils.dart';

class HistoryItemShimmer extends StatelessWidget {
  const HistoryItemShimmer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _listWidget();
  }

  Widget _listWidget() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.historyContentHorizontalPadding.w,
          ),
          child: Divider(
            height: 0,
            color: ColorUtils.getColor(
              context,
              ColorEnums.grayD9Color,
            ),
          ),
        );
      },
      itemBuilder: (context, index) {
        return _historyItem(context);
      },
      itemCount: 1,
    );
  }

  Widget _historyItem(BuildContext context) {
    final baseColor = ColorUtils.getColor(
      context,
      ColorEnums.shimmerBaseColor,
    );
    final highlightedColor = ColorUtils.getColor(
      context,
      ColorEnums.shimmerHighlightedColor,
    );
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightedColor,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.historyContentHorizontalPadding.w,
          vertical: Dimens.historyContentVerticalPadding.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 25.h,
              color: baseColor,
            ),
            SizedBox(
              height: Dimens.historyItemTitleDescPadding.h,
            ),
            Container(
              width: 100,
              height: 15.h,
              color: baseColor,
            ),
            SizedBox(
              height: Dimens.historyItemTitleDescPadding.h,
            ),
            Container(
              width: 150,
              height: 15.h,
              color: baseColor,
            ),
            SizedBox(
              height: Dimens.historyItemTitleDescPadding.h,
            ),
            Container(
              width: double.infinity,
              height: 15.h,
              color: baseColor,
            ),
          ],
        ),
      ),
    );
  }
}
