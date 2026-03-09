import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';


class MobGradientButton extends StatelessWidget {
  const MobGradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isLarge = false,
    this.icon,
    this.gradient,
    this.width,
  });


  final String label;


  final VoidCallback? onPressed;


  final bool isLoading;


  final bool isLarge;


  final IconData? icon;


  final LinearGradient? gradient;


  final double? width;

  bool get _isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final height =
        isLarge ? AppSpacing.buttonHeightLg : AppSpacing.buttonHeight;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isDisabled ? 0.5 : 1.0,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: gradient ?? AppColors.primaryGradient,
          borderRadius: AppSpacing.buttonRadius,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isDisabled ? null : onPressed,
            borderRadius: AppSpacing.buttonRadius,
            splashColor: AppColors.textPrimary.withValues(alpha: 0.1),
            highlightColor: AppColors.textPrimary.withValues(alpha: 0.05),
            child: Center(
              child: isLoading ? _buildLoader() : _buildLabel(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return const SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        color: AppColors.textPrimary,
        strokeWidth: 2.5,
      ),
    );
  }

  Widget _buildLabel() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 20),
          AppSpacing.horizontalSm,
          Text(label, style: AppTypography.button),
        ],
      );
    }
    return Text(label, style: AppTypography.button);
  }
}
