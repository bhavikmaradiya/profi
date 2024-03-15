import 'package:flutter/material.dart';

import '../enums/color_enums.dart';
import '../utils/color_utils.dart';

class AppDatePicker {
  static Future<DateTime?> selectDate({
    required BuildContext context,
    required DateTime selectedDate,
    required DateTime calendarFirstDate,
    required DateTime calendarLastDate,
  }) async {
    final DateTime? changedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: calendarFirstDate,
      lastDate: calendarLastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorUtils.getColor(
                context,
                ColorEnums.gray6CColor,
              ).withOpacity(0.5),
              // selected date round color with background color
              onPrimary: ColorUtils.getColor(
                context,
                ColorEnums.black33Color,
              ),
              // selected date font color
              surface: ColorUtils.getColor(
                context,
                ColorEnums.whiteColor,
              ),
              // background color
              onSurface: ColorUtils.getColor(
                context,
                ColorEnums.gray6CColor,
              ), // not selected text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: ColorUtils.getColor(
                  context,
                  ColorEnums.black33Color,
                ), // text button color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    return changedDate;
  }
}
