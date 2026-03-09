import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';


class MobTextButton extends StatelessWidget {
  const MobTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.icon,
  });


  final String label;


  final VoidCallback? onPressed;


  final Color? color;


  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.cyan;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: onPressed == null ? 0.5 : 1.0,
        child: icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: effectiveColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppTypography.buttonSmall
                        .copyWith(color: effectiveColor),
                  ),
                ],
              )
            : Text(
                label,
                style:
                    AppTypography.buttonSmall.copyWith(color: effectiveColor),
              ),
      ),
    );
  }
}
