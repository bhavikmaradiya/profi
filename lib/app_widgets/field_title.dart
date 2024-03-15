import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../const/dimens.dart';
import '../enums/color_enums.dart';
import '../utils/color_utils.dart';

class FieldTitle extends StatelessWidget {
  final String title;
  final ColorEnums textColorEnum;

  const FieldTitle({
    Key? key,
    required this.title,
    this.textColorEnum = ColorEnums.gray6CColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: ColorUtils.getColor(
          context,
          textColorEnum,
        ),
        fontSize: Dimens.fieldsTitleSize.sp,
      ),
    );
  }
}
