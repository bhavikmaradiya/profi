import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../utils/color_utils.dart';

class FloatingActionBtn extends StatelessWidget {
  final String? icon;
  final Function onPressed;

  const FloatingActionBtn({
    Key? key,
    this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: Dimens.floatingActionBtnMarginRight.w,
        bottom: Dimens.floatingActionBtnMarginBottom.h,
      ),
      child: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            Dimens.addProjectFloatingBtnRadius.r,
          ),
        ),
        backgroundColor: ColorUtils.getColor(
          context,
          ColorEnums.whiteColor,
        ),
        onPressed: () => onPressed(),
        child: SvgPicture.asset(
          icon ?? Strings.add,
          width: Dimens.addProjectIconSize.w,
          height: Dimens.addProjectIconSize.h,
        ),
      ),
    );
  }
}
