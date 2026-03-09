import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';


class ActivityLevelIndicator extends StatelessWidget {
  const ActivityLevelIndicator({
    super.key,
    required this.level,
    this.showLabel = false,
    this.dotSize = 8.0,
  });


  final String level;


  final bool showLabel;


  final double dotSize;

  Color get _color => AppColors.activityColor(level);

  String get _label {
    switch (level) {
      case 'high':
        return 'Hot';
      case 'medium':
        return 'Active';
      case 'low':
      default:
        return 'Chill';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: _color,
            shape: BoxShape.circle,
            boxShadow: level == 'high'
                ? [
                    BoxShadow(
                      color: _color.withValues(alpha: 0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),


        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(
            _label,
            style: AppTypography.caption.copyWith(color: _color),
          ),
        ],
      ],
    );
  }
}
