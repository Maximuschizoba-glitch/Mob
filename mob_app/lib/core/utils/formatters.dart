import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class ThousandSeparatorFormatter extends TextInputFormatter {
  ThousandSeparatorFormatter();

  static final _formatter = NumberFormat('#,###', 'en_US');


  static String rawValue(String formatted) => formatted.replaceAll(',', '');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    final number = int.tryParse(digitsOnly);
    if (number == null) return oldValue;

    final formatted = _formatter.format(number);


    final newCursorOffset = newValue.selection.extentOffset;
    int digitsBefore = 0;
    for (int i = 0; i < newCursorOffset && i < newValue.text.length; i++) {
      if (RegExp(r'\d').hasMatch(newValue.text[i])) {
        digitsBefore++;
      }
    }


    int formattedCursor = 0;
    int count = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (count == digitsBefore) break;
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        count++;
      }
      formattedCursor = i + 1;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formattedCursor.clamp(0, formatted.length),
      ),
    );
  }
}
