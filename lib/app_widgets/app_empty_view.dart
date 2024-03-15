import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../const/dimens.dart';
import '../enums/color_enums.dart';
import '../utils/color_utils.dart';

class AppEmptyView extends StatelessWidget {
  final String message;

  const AppEmptyView({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: ColorUtils.getColor(
            context,
            ColorEnums.black33Color,
          ),
          fontWeight: FontWeight.w500,
          fontSize: Dimens.emptyViewMessageTextSize.sp,
        ),
      ),
    );
  }
}
