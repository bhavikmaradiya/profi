import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove any commas (,) if mistakenly entered
    final String withoutCommas = newValue.text.replaceAll(',', '');

    // Split the value by the dot (.)
    final List<String> parts = withoutCommas.split('.');

    // If there are more than two parts or the decimal part is longer than the allowed range, reject the input
    if (parts.length > 2 ||
        (parts.length == 2 && parts[1].length > decimalRange)) {
      return oldValue;
    }

    // Calculate the cursor offset by comparing the old and new values
    final int cursorOffset = newValue.selection.baseOffset +
        (withoutCommas.length - newValue.text.length);

    // Set the cursor offset in the updated TextEditingValue
    return TextEditingValue(
      text: withoutCommas,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}
