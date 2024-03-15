import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../const/dimens.dart';
import '../enums/color_enums.dart';
import '../utils/color_utils.dart';

class AppFilledButton extends StatelessWidget {
  final String title;
  final Function onButtonPressed;

  const AppFilledButton({
    Key? key,
    required this.title,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Dimens.fieldHeight.h,
      child: FilledButton(
        onPressed: () {
          onButtonPressed();
        },
        style: FilledButton.styleFrom(
          backgroundColor: ColorUtils.getColor(
            context,
            ColorEnums.black33Color,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                Dimens.buttonRadius.r,
              ),
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: ColorUtils.getColor(
              context,
              ColorEnums.whiteColor,
            ),
            fontWeight: FontWeight.w700,
            fontSize: Dimens.buttonTextSize.sp,
          ),
        ),
      ),
    );
  }
}
