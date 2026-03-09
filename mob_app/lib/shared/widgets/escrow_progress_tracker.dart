import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';


class EscrowProgressTracker extends StatelessWidget {
  const EscrowProgressTracker({
    super.key,
    required this.currentStatus,
    this.compact = false,
    this.eventHasStarted = false,
  });


  final String currentStatus;


  final bool compact;


  final bool eventHasStarted;


  static const _steps = ['paid', 'held', 'confirmed', 'released'];
  static const _labels = ['Paid', 'Held', 'Confirmed', 'Released'];


  int get _currentStepIndex {
    switch (currentStatus) {
      case 'collecting':

        return eventHasStarted ? 1 : 0;
      case 'held':
        return 1;
      case 'awaiting_completion':
        return 2;
      case 'released':
        return 3;
      case 'refunding':
      case 'refunded':
        return -1;
      case 'disputed':
        return -2;
      default:
        return 0;
    }
  }

  bool get _isRefunded =>
      currentStatus == 'refunding' || currentStatus == 'refunded';

  @override
  Widget build(BuildContext context) {
    if (_isRefunded) {
      return _buildRefundedTracker();
    }
    return _buildNormalTracker();
  }


  Widget _buildNormalTracker() {
    final stepIndex = _currentStepIndex;

    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {

        if (i.isEven) {
          final dotIndex = i ~/ 2;
          return _buildStep(
            index: dotIndex,
            isCompleted: dotIndex < stepIndex,
            isCurrent: dotIndex == stepIndex,
            label: _labels[dotIndex],
          );
        } else {
          final lineIndex = i ~/ 2;
          return _buildLine(isCompleted: lineIndex < stepIndex);
        }
      }),
    );
  }

  Widget _buildStep({
    required int index,
    required bool isCompleted,
    required bool isCurrent,
    required String label,
  }) {
    final Color dotColor;
    final double dotSize;

    if (isCompleted) {
      dotColor = AppColors.cyan;
      dotSize = compact ? 10 : 12;
    } else if (isCurrent) {
      dotColor = AppColors.cyan;
      dotSize = compact ? 12 : 14;
    } else {
      dotColor = AppColors.surface;
      dotSize = compact ? 8 : 10;
    }

    final dot = Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: (isCompleted || isCurrent) ? dotColor : Colors.transparent,
        shape: BoxShape.circle,
        border: (isCompleted || isCurrent)
            ? null
            : Border.all(color: AppColors.surface, width: 1.5),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.cyan.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: isCompleted
          ? Icon(Icons.check, size: dotSize * 0.6, color: AppColors.background)
          : null,
    );

    if (compact) return dot;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.micro.copyWith(
            color: (isCompleted || isCurrent)
                ? AppColors.textPrimary
                : AppColors.textTertiary,
            fontWeight:
                isCurrent ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLine({required bool isCompleted}) {
    return Expanded(
      child: compact
          ? Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: isCompleted ? AppColors.cyan : AppColors.surface,
            )
          : Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: isCompleted ? AppColors.cyan : AppColors.surface,
              ),
            ),
    );
  }


  Widget _buildRefundedTracker() {
    final isComplete = currentStatus == 'refunded';

    return Row(
      children: [

        _buildStep(
          index: 0,
          isCompleted: true,
          isCurrent: false,
          label: 'Paid',
        ),
        _buildLine(isCompleted: true),


        _buildStep(
          index: 1,
          isCompleted: true,
          isCurrent: false,
          label: 'Held',
        ),
        _buildLine(isCompleted: false),


        _buildRefundStep(isComplete: isComplete),
      ],
    );
  }

  Widget _buildRefundStep({required bool isComplete}) {
    final color = isComplete ? AppColors.warning : AppColors.warning;
    final dotSize = compact ? 12.0 : 14.0;

    final dot = Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.undo_rounded,
        size: dotSize * 0.6,
        color: AppColors.background,
      ),
    );

    if (compact) return dot;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(height: AppSpacing.xs),
        Text(
          isComplete ? 'Refunded' : 'Refunding',
          style: AppTypography.micro.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
