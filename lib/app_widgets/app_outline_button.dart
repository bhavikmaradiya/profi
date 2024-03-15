import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../const/dimens.dart';
import '../enums/color_enums.dart';
import '../utils/color_utils.dart';

class AppOutlineButton extends StatelessWidget {
  final String title;
  final Function onButtonPressed;
  final ColorEnums textColorEnum;
  final Color? bgColor;
  final ColorEnums borderColor;
  final bool isEnabled;
  final String? icon;
  final double? iconSize;

  const AppOutlineButton({
    Key? key,
    required this.title,
    required this.onButtonPressed,
    this.textColorEnum = ColorEnums.black33Color,
    this.borderColor = ColorEnums.grayE0Color,
    this.bgColor,
    this.isEnabled = true,
    this.icon,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isIconAvailable = icon != null && icon!.trim().isNotEmpty;
    return SizedBox(
      width: double.infinity,
      height: Dimens.fieldHeight.h,
      child: OutlinedButton(
        onPressed: isEnabled
            ? () {
                onButtonPressed();
              }
            : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: ColorUtils.getColor(
              context,
              borderColor,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                Dimens.buttonRadius.r,
              ),
            ),
          ),
          backgroundColor: bgColor ??
              ColorUtils.getColor(
                context,
                ColorEnums.whiteColor,
              ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isIconAvailable)
              SvgPicture.asset(
                icon!,
                width: iconSize ?? Dimens.buttonIconSize.w,
                height: iconSize ?? Dimens.buttonIconSize.w,
              ),
            if (isIconAvailable)
              SizedBox(
                width: Dimens.buttonIconTextSpacing.sp,
              ),
            Text(
              title,
              style: TextStyle(
                color: ColorUtils.getColor(
                  context,
                  textColorEnum,
                ),
                fontWeight: FontWeight.w700,
                fontSize: Dimens.buttonTextSize.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
