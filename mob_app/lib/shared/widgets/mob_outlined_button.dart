import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';


class MobOutlinedButton extends StatelessWidget {
  const MobOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.borderColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
  });


  final String label;


  final VoidCallback? onPressed;


  final Color? borderColor;


  final Color? textColor;


  final IconData? icon;


  final bool isLoading;

  bool get _isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.cyan;
    final effectiveTextColor = textColor ?? AppColors.cyan;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isDisabled ? 0.5 : 1.0,
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: AppSpacing.buttonRadius,
          border: Border.all(color: effectiveBorderColor, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isDisabled ? null : onPressed,
            borderRadius: AppSpacing.buttonRadius,
            splashColor: effectiveBorderColor.withValues(alpha: 0.1),
            highlightColor: effectiveBorderColor.withValues(alpha: 0.05),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: effectiveTextColor,
                        strokeWidth: 2,
                      ),
                    )
                  : _buildLabel(effectiveTextColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(Color color) {
    final style = AppTypography.buttonSmall.copyWith(color: color);
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          AppSpacing.horizontalSm,
          Text(label, style: style),
        ],
      );
    }
    return Text(label, style: style);
  }
}
