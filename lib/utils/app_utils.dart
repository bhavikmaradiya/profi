import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../config/app_config.dart';
import '../enums/currency_enum.dart';
import '../enums/user_role_enums.dart';

class AppUtils {
  static bool isUserLoginAfterLogOut = false;

  static RegExp regexToRemoveTrailingZero = RegExp(r'([.]*0)(?!.*\d)');

  static RegExp regexToDenyComma = RegExp(r',');

  static RegExp regexToDenyNotADigit = RegExp(r'[^\d]');

  static bool hasMatch(String? value, String pattern) {
    return (value == null) ? false : RegExp(pattern).hasMatch(value);
  }

  static bool isValidEmail(String s) => hasMatch(s,
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  static bool isValidPasswordLength(String s) {
    return s.length >= 6;
  }

  /*
    Min 1 uppercase letter.
    Min 1 lowercase letter.
    Min 1 special character.
    Min 1 number.
    Min 8 characters.
    Max 30 characters
   */
  static bool isValidPasswordToRegister(String s) => hasMatch(s,
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[#$@!%&*?])[A-Za-z\d#$@!%&*?]{8,30}$');

  static DateTime getNextMonthRetainerDate(DateTime inputDate) {
    // Get the year and month from the input date
    int year = inputDate.year;
    int month = inputDate.month;
    int day = inputDate.day;

    // Calculate the next month
    if (month == 12) {
      year++;
      month = 1;
    } else {
      month++;
    }

    int lastDayOfNextMonth = DateTime(year, month + 1, 0).day;

    // Handle exceptional cases
    if (day >= 29 && day <= 31) {
      if (day > lastDayOfNextMonth) {
        day = lastDayOfNextMonth;
      }
    }

    // Create a new DateTime object for the next month
    return DateTime(year, month, day);
  }

  static DateTime getNextWeekDate(DateTime inputDate) {
    DateTime nextWeek = inputDate.add(const Duration(days: 7));
    return nextWeek;
  }

  static String getInitials(String value) => value.isNotEmpty
      ? value.trim().split(RegExp(' +')).map((s) => s[0]).take(2).join()
      : '';

  static String removeTrailingZero(double? value) {
    if (value != null) {
      return double.parse(value.toStringAsFixed(2))
          .toString()
          .replaceAll(regexToRemoveTrailingZero, '');
    }
    return '0';
  }

  static fieldCursorPositionAtLast(TextEditingController? controller) {
    controller?.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
  }

  static getUserRoleString(
    AppLocalizations appLocalizations,
    String roleEnum,
  ) {
    String role = '';
    if (roleEnum == UserRoleEnum.admin.name) {
      role = appLocalizations.userRoleAdmin;
    } else if (roleEnum == UserRoleEnum.bdm.name) {
      role = appLocalizations.userRoleBdm;
    } else if (roleEnum == UserRoleEnum.projectManager.name) {
      role = appLocalizations.userRoleProjectManager;
    }
    return role;
  }

  static String amountWithCurrencyFormatter({
    required double amount,
    required CurrencyEnum toCurrency,
  }) {
    final formattedValue = AppUtils.removeTrailingZero(amount);
    final parsedValue = double.parse(formattedValue);
    String finalFormattedValue = '';
    if (toCurrency == CurrencyEnum.dollars) {
      finalFormattedValue = NumberFormat.currency(
        locale: 'en_US',
        name: '${AppConfig.dollarCurrencySymbol} ',
        decimalDigits: parsedValue.truncateToDouble() == parsedValue ? 0 : 2,
      ).format(parsedValue);
    } else if (toCurrency == CurrencyEnum.rupees) {
      finalFormattedValue = NumberFormat.currency(
        locale: 'en_IN',
        name: '${AppConfig.rupeeCurrencySymbol} ',
        decimalDigits: parsedValue.truncateToDouble() == parsedValue ? 0 : 2,
      ).format(parsedValue);
    } else if (toCurrency == CurrencyEnum.euros) {
      finalFormattedValue = NumberFormat.currency(
        locale: 'en_EU',
        name: '${AppConfig.euroCurrencySymbol} ',
        decimalDigits: parsedValue.truncateToDouble() == parsedValue ? 0 : 2,
      ).format(double.parse(formattedValue));
    }
    return finalFormattedValue;
  }

  static int dateDifferenceInDays(int oldTimestamp, int newTimestamp) {
    DateTime dateTime1 = DateTime.fromMillisecondsSinceEpoch(oldTimestamp);
    DateTime dateTime2 = DateTime.fromMillisecondsSinceEpoch(newTimestamp);
    // Calculate the difference between the two dates
    Duration difference = dateTime2.difference(dateTime1);
    return difference.inDays;
  }
}
