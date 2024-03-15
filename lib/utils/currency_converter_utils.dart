import '../config/app_config.dart';
import '../enums/currency_enum.dart';

class CurrencyConverterUtils {
  // Define conversion rates (relative to INR)
  static Map<String, double> exchangeRates = {
    CurrencyEnum.dollars.name: AppConfig.defaultDollarToInr,
    CurrencyEnum.euros.name: AppConfig.defaultEuroToInr,
    CurrencyEnum.rupees.name: 1,
  };

  // Function to convert currency
  // Currency : From and Two must be from CurrencyEnum
  static double convert(double amount, String fromCurrency, String toCurrency) {
    if (exchangeRates.containsKey(fromCurrency) &&
        exchangeRates.containsKey(toCurrency)) {
      final double rateFrom = exchangeRates[fromCurrency]!;
      final double rateTo = exchangeRates[toCurrency]!;
      return (amount / rateTo) * rateFrom;
    } else {
      throw Exception('Invalid currency codes');
    }
  }
}
