import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';


class MobBadge extends StatelessWidget {
  const MobBadge({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.fontSize,
    this.icon,
  });


  final String label;


  final Color color;


  final Color? textColor;


  final double? fontSize;


  final IconData? icon;


  factory MobBadge.live() {
    return const MobBadge(
      label: 'LIVE',
      color: AppColors.success,
    );
  }


  factory MobBadge.upcoming() {
    return const MobBadge(
      label: 'UPCOMING',
      color: AppColors.cyan,
    );
  }


  factory MobBadge.ended() {
    return const MobBadge(
      label: 'ENDED',
      color: AppColors.warning,
    );
  }


  factory MobBadge.hidden() {
    return const MobBadge(
      label: 'HIDDEN',
      color: AppColors.error,
    );
  }


  factory MobBadge.refunded() {
    return const MobBadge(
      label: 'REFUNDED',
      color: AppColors.warning,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: effectiveTextColor, size: (fontSize ?? 10) + 2),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: AppTypography.micro.copyWith(
              color: effectiveTextColor,
              fontSize: fontSize ?? 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
