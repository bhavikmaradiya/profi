import '../enums/currency_enum.dart';
import '../enums/filter_sort_by_enum.dart';

class AppConfig {
  static const splashDuration = 2; // 2 sec
  static const defaultSnackBarDuration = 3; // 3 sec
  static const double figmaScreenWidth = 428;
  static const double figmaScreenHeight = 926;
  static const String projectStartDateFormat = 'dd MMM yy';
  static const String milestoneInfoDateFormat = 'dd MMM yy';
  static const String dateDifferenceFormat = 'dd MMM yy';
  static const int amountInputLengthLimit = 7;
  static const int hourlyRateInputLengthLimit = 5;
  static const bool autoRegisterWithLogin = false;
  static const int projectCodeMaxLength = 4;
  static const int projectAmountMaxLength = 10;
  static const int recentTransactionLength = 5;
  static const int monthlyAmountMaxLength = 4;

  // ---------------------------------------------------------------
  // If default currency is changed from rupees to other
  // you must need to change Currency enum default values
  static const int defaultCurrencyId = rupeeCurrencyId;
  static const CurrencyEnum defaultCurrencyEnum = CurrencyEnum.rupees;

  // ---------------------------------------------------------------

  static const int dollarCurrencyId = 1;
  static const int rupeeCurrencyId = 2;
  static const int euroCurrencyId = 3;
  static const String dollarCurrencySymbol = '\$';
  static const String rupeeCurrencySymbol = '₹';
  static const String euroCurrencySymbol = '€';
  static const double defaultDollarToInr = 82.90;
  static const double defaultEuroToInr = 88.84;
  static const int decimalTextFieldInputLength = 2;
  static const bool isTempTabEnabled = false;
  static const FilterSortByEnum defaultSortBy =
      FilterSortByEnum.sortByProjectCode;
  static const int datePickerFutureDays = 365 * 2;
  static const int projectStartDatePastDays = 365 * 10;
  static const bool isProjectCreatedByUserAllowToSeeProject = false;
}
