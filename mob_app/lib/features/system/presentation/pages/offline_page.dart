import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/connectivity/connectivity_cubit.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/mob_gradient_button.dart';
import '../../../../shared/widgets/mob_text_button.dart';


class OfflinePage extends StatefulWidget {
  const OfflinePage({
    super.key,
    this.onRetry,
  });


  final VoidCallback? onRetry;

  @override
  State<OfflinePage> createState() => _OfflinePageState();
}

class _OfflinePageState extends State<OfflinePage> {
  bool _isChecking = false;

  Future<void> _handleRetry() async {
    setState(() => _isChecking = true);

    final connected =
        await context.read<ConnectivityCubit>().checkNow();

    if (mounted) {
      setState(() => _isChecking = false);

      if (connected) {
        widget.onRetry?.call();
      }
    }
  }

  Future<void> _openSettings() async {

    final uri = Uri.parse('app-settings:');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

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
                        Icons.wifi_off_rounded,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),

                AppSpacing.verticalXl,


                const Text(
                  'You\u2019re Offline',
                  style: AppTypography.h1,
                  textAlign: TextAlign.center,
                ),

                AppSpacing.verticalMd,


                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: const Text(
                    'It looks like you\u2019ve lost your internet connection. '
                    'Check your WiFi or mobile data and try again.',
                    style: AppTypography.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),

                AppSpacing.verticalXxl,


                SizedBox(
                  width: 220,
                  child: MobGradientButton(
                    label: 'Try Again',
                    icon: Icons.refresh_rounded,
                    isLoading: _isChecking,
                    onPressed: _isChecking ? null : _handleRetry,
                  ),
                ),

                AppSpacing.verticalMd,


                MobTextButton(
                  label: 'Go to Settings',
                  icon: Icons.settings_rounded,
                  onPressed: _openSettings,
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
