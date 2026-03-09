import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/mob_text_field.dart';


class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    this.validator,
    this.errorText,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });


  final TextEditingController controller;


  final String? Function(String?)? validator;


  final String? errorText;


  final FocusNode? focusNode;


  final TextInputAction? textInputAction;


  final ValueChanged<String>? onSubmitted;


  String get fullPhoneNumber {
    final digits = controller.text.replaceAll(RegExp(r'\s+'), '');
    if (digits.isEmpty) return '';


    final normalized = digits.startsWith('0') ? digits.substring(1) : digits;
    return '+234$normalized';
  }

  @override
  Widget build(BuildContext context) {
    return MobTextField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      errorText: errorText,
      label: 'Phone',
      hint: '801 234 5678',
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      autofillHints: const [AutofillHints.telephoneNumberLocal],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _NigerianPhoneFormatter(),
      ],
      prefixIcon: Container(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Text(
              '🇳🇬',
              style: TextStyle(fontSize: 16),
            ),
            AppSpacing.horizontalXs,

            Text(
              '+234',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.horizontalSm,

            Container(
              width: 1,
              height: 20,
              color: AppColors.surface,
            ),
          ],
        ),
      ),
    );
  }
}


class _NigerianPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\s+'), '');


    final trimmed = digits.length > 11 ? digits.substring(0, 11) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < trimmed.length; i++) {
      buffer.write(trimmed[i]);

      if ((i == 2 || i == 5) && i != trimmed.length - 1) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
