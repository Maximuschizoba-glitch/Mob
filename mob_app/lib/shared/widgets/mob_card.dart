import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';


class MobCard extends StatelessWidget {
  const MobCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.radius,
    this.onTap,
    this.margin,
  });


  final Widget child;


  final EdgeInsets? padding;


  final Color? backgroundColor;


  final Color? borderColor;


  final double? radius;


  final VoidCallback? onTap;


  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = radius ?? AppSpacing.radiusLg;
    final borderRadiusValue = BorderRadius.circular(effectiveRadius);

    final container = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.card,
        borderRadius: borderRadiusValue,
        border: Border.all(
          color: borderColor ?? AppColors.border,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: padding ?? AppSpacing.cardPadding,
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadiusValue,
          splashColor: AppColors.cyan.withValues(alpha: 0.08),
          highlightColor: AppColors.cyan.withValues(alpha: 0.04),
          child: container,
        ),
      );
    }

    return container;
  }
}
