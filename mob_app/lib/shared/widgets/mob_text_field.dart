import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';


class MobTextField extends StatelessWidget {
  const MobTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.errorText,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.prefixText,
  });


  final String? label;


  final String? hint;


  final TextEditingController? controller;


  final String? Function(String?)? validator;


  final bool obscureText;


  final TextInputType? keyboardType;


  final Widget? prefixIcon;


  final Widget? suffixIcon;


  final int maxLines;


  final int? maxLength;


  final bool enabled;


  final String? errorText;


  final FocusNode? focusNode;


  final ValueChanged<String>? onChanged;


  final ValueChanged<String>? onSubmitted;


  final TextInputAction? textInputAction;


  final List<TextInputFormatter>? inputFormatters;


  final Iterable<String>? autofillHints;


  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [

        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: AppTypography.overline.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
          ),
          AppSpacing.verticalSm,
        ],


        TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          enabled: enabled,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          style: AppTypography.body.copyWith(
            color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
          ),
          cursorColor: AppColors.cyan,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon,
            prefixText: prefixText,
            prefixStyle: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
            suffixIcon: suffixIcon,

            counterText: '',
          ),
        ),


        if (maxLength != null) ...[
          AppSpacing.verticalXs,
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${controller?.text.length ?? 0}/$maxLength',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
