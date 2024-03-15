import 'package:flutter/material.dart';

import '../config/dark_colors_config.dart';
import '../config/light_colors_config.dart';
import '../enums/color_enums.dart';

class ColorUtils {
  static bool isAppDarkMode(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }

  static Color getColor(BuildContext context, ColorEnums colorEnum) {
    final isDarkMode = isAppDarkMode(context);
    Color color;
    switch (colorEnum) {
      case ColorEnums.themeColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.themeColor
              : LightColorsConfig.themeColor;
          break;
        }
      case ColorEnums.black00Color:
        {
          color = isDarkMode
              ? DarkColorsConfig.black00Color
              : LightColorsConfig.black00Color;
          break;
        }
      case ColorEnums.black33Color:
        {
          color = isDarkMode
              ? DarkColorsConfig.black33Color
              : LightColorsConfig.black33Color;
          break;
        }
      case ColorEnums.whiteColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.whiteColor
              : LightColorsConfig.whiteColor;
          break;
        }
      case ColorEnums.gray6CColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.gray6CColor
              : LightColorsConfig.gray6CColor;
          break;
        }
      case ColorEnums.gray99Color:
        {
          color = isDarkMode
              ? DarkColorsConfig.gray99Color
              : LightColorsConfig.gray99Color;
          break;
        }
      case ColorEnums.statusBarColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.statusBarColor
              : LightColorsConfig.statusBarColor;
          break;
        }
      case ColorEnums.grayF5Color:
        {
          color = isDarkMode
              ? DarkColorsConfig.grayF5Color
              : LightColorsConfig.grayF5Color;
          break;
        }
      case ColorEnums.grayE0Color:
        {
          color = isDarkMode
              ? DarkColorsConfig.grayE0Color
              : LightColorsConfig.grayE0Color;
          break;
        }
      case ColorEnums.black1AColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.black1AColor
              : LightColorsConfig.black1AColor;
          break;
        }
      case ColorEnums.redColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.redColor
              : LightColorsConfig.redColor;
          break;
        }
      case ColorEnums.greenColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.greenColor
              : LightColorsConfig.greenColor;
          break;
        }
      case ColorEnums.blueColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.blueColor
              : LightColorsConfig.blueColor;
          break;
        }
      case ColorEnums.milestonePartiallyPaidColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.milestonePartiallyPaidColor
              : LightColorsConfig.milestonePartiallyPaidColor;
          break;
        }
      case ColorEnums.milestoneFullyPaidColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.milestoneFullyPaidColor
              : LightColorsConfig.milestoneFullyPaidColor;
          break;
        }
      case ColorEnums.projectFullyPaidColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.projectFullyPaidColor
              : LightColorsConfig.projectFullyPaidColor;
          break;
        }
      case ColorEnums.blueE6F1F9Color:
        {
          color = isDarkMode
              ? DarkColorsConfig.blueE6F1F9Color
              : LightColorsConfig.blueE6F1F9Color;
          break;
        }
      case ColorEnums.redFFE3E3Color:
        {
          color = isDarkMode
              ? DarkColorsConfig.redFFE3E3Color
              : LightColorsConfig.redFFE3E3Color;
          break;
        }
      case ColorEnums.multipleMilestoneExceededColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.multipleMilestoneExceededColor
              : LightColorsConfig.multipleMilestoneExceededColor;
          break;
        }
      case ColorEnums.amberF59032Color:
        {
          color = isDarkMode
              ? DarkColorsConfig.amberF59032Color
              : LightColorsConfig.amberF59032Color;
          break;
        }
      case ColorEnums.milestoneAboutToExceedColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.milestoneAboutToExceedColor
              : LightColorsConfig.milestoneAboutToExceedColor;
          break;
        }
      case ColorEnums.milestoneExceededColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.milestoneExceededColor
              : LightColorsConfig.milestoneExceededColor;
          break;
        }
      case ColorEnums.upcomingMilestoneColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.upcomingMilestoneColor
              : LightColorsConfig.upcomingMilestoneColor;
          break;
        }
      case ColorEnums.greenF2FCF3Color:
        {
          color = isDarkMode
              ? DarkColorsConfig.greenF2FCF3Color
              : LightColorsConfig.greenF2FCF3Color;
          break;
        }
      case ColorEnums.redFDF3F3Color:
        {
          color = isDarkMode
              ? DarkColorsConfig.redFDF3F3Color
              : LightColorsConfig.redFDF3F3Color;
          break;
        }
      case ColorEnums.grayEAColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.grayEAColor
              : LightColorsConfig.grayEAColor;
          break;
        }
      case ColorEnums.transparentColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.transparentColor
              : LightColorsConfig.transparentColor;
          break;
        }
      case ColorEnums.shimmerBaseColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.shimmerBaseColor
              : LightColorsConfig.shimmerBaseColor;
          break;
        }
      case ColorEnums.shimmerHighlightedColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.shimmerHighlightedColor
              : LightColorsConfig.shimmerHighlightedColor;
          break;
        }
      case ColorEnums.grayD9Color:
        {
          color = isDarkMode
              ? DarkColorsConfig.grayD9Color
              : LightColorsConfig.grayD9Color;
          break;
        }
      case ColorEnums.grayA8Color:
        {
          color = isDarkMode
              ? DarkColorsConfig.grayA8Color
              : LightColorsConfig.grayA8Color;
          break;
        }

      case ColorEnums.blackColor5Opacity:
        {
          color = isDarkMode
              ? DarkColorsConfig.blackColor5Opacity
              : LightColorsConfig.blackColor5Opacity;
          break;
        }
      case ColorEnums.projectOnHoldColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.projectOnHoldColor
              : LightColorsConfig.projectOnHoldColor;
          break;
        }
      case ColorEnums.projectClosedColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.projectClosedColor
              : LightColorsConfig.projectClosedColor;
          break;
        }
      case ColorEnums.projectDroppedColor:
        {
          color = isDarkMode
              ? DarkColorsConfig.projectDroppedColor
              : LightColorsConfig.projectDroppedColor;
          break;
        }
      default:
        {
          color = isDarkMode
              ? DarkColorsConfig.themeColor
              : LightColorsConfig.themeColor;
          break;
        }
    }
    return color;
  }
}
