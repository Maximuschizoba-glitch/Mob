import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';


const int _defaultImageDuration = 5;


class SnapProgressBars extends StatelessWidget {
  const SnapProgressBars({
    super.key,
    required this.totalSnaps,
    required this.currentIndex,
    required this.controller,
    this.snapDurations,
  });


  final int totalSnaps;


  final int currentIndex;


  final AnimationController controller;


  final List<int?>? snapDurations;

  int _durationFor(int index) {
    if (snapDurations == null || index >= snapDurations!.length) {
      return _defaultImageDuration;
    }
    return snapDurations![index] ?? _defaultImageDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSnaps, (index) {
        final isCompleted = index < currentIndex;
        final isCurrent = index == currentIndex;

        return Flexible(
          flex: _durationFor(index),
          child: Padding(
            padding: EdgeInsets.only(
              right: index < totalSnaps - 1 ? 4.0 : 0.0,
            ),
            child: SizedBox(
              height: 2,
              child: isCurrent
                  ? AnimatedBuilder(
                      animation: controller,
                      builder: (context, _) {
                        return _ProgressBar(
                          fillFraction: controller.value,
                        );
                      },
                    )
                  : _ProgressBar(
                      fillFraction: isCompleted ? 1.0 : 0.0,
                    ),
            ),
          ),
        );
      }),
    );
  }
}


class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.fillFraction});

  final double fillFraction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(1),
      child: Stack(
        children: [

          Container(
            color: AppColors.textPrimary.withValues(alpha: 0.2),
          ),

          if (fillFraction > 0)
            FractionallySizedBox(
              widthFactor: fillFraction.clamp(0.0, 1.0),
              child: Container(color: AppColors.cyan),
            ),
        ],
      ),
    );
  }
}
