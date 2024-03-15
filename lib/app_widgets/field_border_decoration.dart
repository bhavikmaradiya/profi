import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../const/dimens.dart';
import '../enums/color_enums.dart';
import '../utils/color_utils.dart';

class FieldBorderDecoration {
  static InputDecoration fieldBorderDecoration(
    BuildContext context, {
    double contentPadding = 0,
    ColorEnums fillColor = ColorEnums.whiteColor,
    ColorEnums borderColor = ColorEnums.grayE0Color,
    bool isMultiLine = false,
    Widget? suffixIcon,
    String? hint,
    TextStyle? hintStyle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: hintStyle,
      fillColor: ColorUtils.getColor(
        context,
        fillColor,
      ),
      enabledBorder: _fieldBorder(
        context,
        borderColor: borderColor,
      ),
      disabledBorder: _fieldBorder(
        context,
        borderColor: borderColor,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorUtils.getColor(
            context,
            ColorEnums.black33Color,
          ),
          width: Dimens.fieldBorderSize.w,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: contentPadding.w,
        vertical: isMultiLine ? contentPadding.h : 0,
      ),
      suffixIcon: suffixIcon,
      filled: true,
    );
  }

  static OutlineInputBorder _fieldBorder(
    BuildContext context, {
    ColorEnums borderColor = ColorEnums.grayE0Color,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(
          Dimens.fieldBorderRadius.r,
        ),
      ),
      borderSide: BorderSide(
        color: ColorUtils.getColor(
          context,
          borderColor,
        ),
        width: Dimens.fieldBorderSize.w,
      ),
    );
  }
}
