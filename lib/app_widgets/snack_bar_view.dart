import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/app_config.dart';
import '../const/dimens.dart';
import '../enums/color_enums.dart';
import '../main.dart';
import '../utils/color_utils.dart';

class SnackBarView {
  static showSnackBar(
    BuildContext context,
    String message, {
    String? action,
    Function()? onActionClicked,
    bool keepSnackBar = false,
    int? durationInSec,
    Color? textColor,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(navigatorKey.currentContext ?? context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: textColor ??
                ColorUtils.getColor(
                  context,
                  ColorEnums.whiteColor,
                ),
            fontWeight: FontWeight.w400,
            fontSize: Dimens.snackBarTextSize.sp,
          ),
        ),
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        action: action != null && onActionClicked != null
            ? SnackBarAction(
                label: action,
                onPressed: () {
                  ScaffoldMessenger.of(navigatorKey.currentContext ?? context)
                      .hideCurrentSnackBar();
                  onActionClicked();
                },
              )
            : null,
        duration: keepSnackBar
            ? const Duration(days: 365)
            : Duration(
                seconds: durationInSec ??= AppConfig.defaultSnackBarDuration,
              ),
      ),
    );
  }
}
