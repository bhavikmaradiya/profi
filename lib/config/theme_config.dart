import 'package:flutter/material.dart';

import './dark_colors_config.dart';
import './light_colors_config.dart';

class ThemeConfig {
  static const appFonts = 'DMSans';
  static const notoSans = 'NotoSans';

  static ThemeData lightTheme = ThemeData(
    primaryColor: LightColorsConfig.themeColor,
    fontFamily: appFonts,
    scaffoldBackgroundColor: LightColorsConfig.whiteColor,
    brightness: Brightness.light,
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: DarkColorsConfig.themeColor,
    fontFamily: appFonts,
    scaffoldBackgroundColor: DarkColorsConfig.whiteColor,
    brightness: Brightness.dark,
    useMaterial3: true,
  );
}
