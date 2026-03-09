import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';


class MobSectionLabel extends StatelessWidget {
  const MobSectionLabel({
    super.key,
    required this.label,
    this.color,
    this.trailing,
  });


  final String label;


  final Color? color;


  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      label.toUpperCase(),
      style: AppTypography.overline.copyWith(
        color: color ?? AppColors.textTertiary,
      ),
    );

    if (trailing != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          textWidget,
          trailing!,
        ],
      );
    }

    return textWidget;
  }
}
