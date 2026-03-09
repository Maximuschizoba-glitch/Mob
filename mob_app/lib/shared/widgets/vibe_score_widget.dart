import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';


class VibeScoreWidget extends StatelessWidget {
  const VibeScoreWidget({
    super.key,
    required this.score,
    this.large = false,
  });


  final double score;


  final bool large;

  Color get _scoreColor {
    if (score >= 7.0) return AppColors.cyan;
    if (score >= 4.0) return AppColors.warning;
    return AppColors.textTertiary;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = large
        ? AppTypography.vibeScore
        : AppTypography.buttonSmall;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 10 : 8,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: _scoreColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\u{1F525}',
            style: TextStyle(fontSize: large ? 18 : 14),
          ),
          const SizedBox(width: 4),
          Text(
            score.toStringAsFixed(1),
            style: textStyle.copyWith(color: _scoreColor),
          ),
        ],
      ),
    );
  }
}
