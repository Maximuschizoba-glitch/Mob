import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../shared/widgets/mob_gradient_button.dart';
import '../../../../shared/widgets/mob_outlined_button.dart';
import '../bloc/feed_cubit.dart';


class FeedEmptyState extends StatelessWidget {
  const FeedEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [

            const SizedBox(height: 64),


            const _RadarVisual(),

            const SizedBox(height: AppSpacing.xl),


            const Text(
              'Nothing happening nearby\u2026 yet',
              style: AppTypography.h4,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.sm),


            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: const Text(
                'Try expanding your search area or check back later. Lagos never sleeps for long.',
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),


            MobGradientButton(
              label: 'Expand Search Radius',
              icon: Icons.radar_rounded,
              onPressed: () {
                context.read<FeedCubit>().updateRadius(25.0);
              },
            ),

            const SizedBox(height: AppSpacing.md),


            MobOutlinedButton(
              label: 'Post a Happening',
              icon: Icons.add_circle_outline,
              onPressed: () => _handlePostTap(context),
            ),

            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }

  void _handlePostTap(BuildContext context) {
    if (!requireAuth(context, action: 'post happenings and share snaps')) {
      return;
    }
    context.push(RoutePaths.post);
  }
}


class _RadarVisual extends StatelessWidget {
  const _RadarVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: CustomPaint(
        painter: _RadarPainter(),
        child: Center(
          child: _buildPin(),
        ),
      ),
    );
  }

  Widget _buildPin() {
    return Container(
      width: 40,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: const Text(
        '?',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
          height: 1,
        ),
      ),
    );
  }
}


class _RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);


    _drawDashedCircle(
      canvas,
      center,
      80,
      AppColors.textTertiary.withValues(alpha: 0.2),
    );
    _drawDashedCircle(
      canvas,
      center,
      55,
      AppColors.textTertiary.withValues(alpha: 0.3),
    );
    _drawDashedCircle(
      canvas,
      center,
      30,
      AppColors.textTertiary.withValues(alpha: 0.4),
    );
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const double dashLength = 6;
    const double gapLength = 4;
    final double circumference = 2 * math.pi * radius;
    const double totalSegment = dashLength + gapLength;
    final int dashCount = (circumference / totalSegment).floor();

    for (int i = 0; i < dashCount; i++) {
      final double startAngle =
          (i * totalSegment / circumference) * 2 * math.pi;
      final double sweepAngle =
          (dashLength / circumference) * 2 * math.pi;

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
