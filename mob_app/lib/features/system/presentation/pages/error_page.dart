import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/mob_gradient_button.dart';
import '../../../../shared/widgets/mob_text_button.dart';


class ErrorPage extends StatelessWidget {
  const ErrorPage({
    super.key,
    this.title = 'Something Went Wrong',
    this.message =
        'An unexpected error occurred. Please try again or return to the home screen.',
    this.onRetry,
    this.onGoHome,
  });


  final String title;


  final String message;


  final VoidCallback? onRetry;


  final VoidCallback? onGoHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                CustomPaint(
                  painter: _DashedCirclePainter(
                    color: AppColors.textTertiary,
                    strokeWidth: 2,
                    dashWidth: 6,
                    dashGap: 4,
                  ),
                  child: const SizedBox(
                    width: 120,
                    height: 120,
                    child: Center(
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 48,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ),

                AppSpacing.verticalXl,


                Text(
                  title,
                  style: AppTypography.h1,
                  textAlign: TextAlign.center,
                ),

                AppSpacing.verticalMd,


                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Text(
                    message,
                    style: AppTypography.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),

                AppSpacing.verticalXxl,


                if (onRetry != null)
                  SizedBox(
                    width: 220,
                    child: MobGradientButton(
                      label: 'Try Again',
                      icon: Icons.refresh_rounded,
                      onPressed: onRetry,
                    ),
                  ),

                if (onRetry != null && onGoHome != null) AppSpacing.verticalMd,


                if (onGoHome != null)
                  MobTextButton(
                    label: 'Go Home',
                    icon: Icons.home_rounded,
                    onPressed: onGoHome,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashWidth = 6,
    this.dashGap = 4,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final radius = (size.width / 2) - (strokeWidth / 2);
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * pi * radius;
    final dashCount = (circumference / (dashWidth + dashGap)).floor();

    for (int i = 0; i < dashCount; i++) {
      final startAngle =
          (i * (dashWidth + dashGap) / radius) - (pi / 2);
      final sweepAngle = dashWidth / radius;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth;
}
