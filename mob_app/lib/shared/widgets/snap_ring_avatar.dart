import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';


class SnapRingAvatar extends StatelessWidget {
  const SnapRingAvatar({
    super.key,
    this.imageUrl,
    required this.fallbackInitial,
    this.size = 56,
    this.snapCount = 0,
    this.hasUnviewedSnaps = true,
    this.isVerifiedHost = false,
    this.onTap,
  });


  final String? imageUrl;


  final String fallbackInitial;


  final double size;


  final int snapCount;


  final bool hasUnviewedSnaps;


  final bool isVerifiedHost;


  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasSnaps = snapCount > 0;
    const ringWidth = 3.0;
    const gapWidth = 2.5;
    final avatarSize = size - (ringWidth * 2) - (gapWidth * 2);
    final badgeSize = size * 0.3;

    return GestureDetector(
      onTap: hasSnaps ? onTap : null,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [

            if (hasSnaps)
              CustomPaint(
                size: Size(size, size),
                painter: _SnapRingPainter(
                  segmentCount: snapCount.clamp(1, 12),
                  strokeWidth: ringWidth,
                  isActive: hasUnviewedSnaps,
                ),
              ),


            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.elevated,
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildImage(avatarSize),
            ),


            if (isVerifiedHost)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.background,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    size: badgeSize * 0.55,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(double avatarSize) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      final cacheSize = (avatarSize * 2).toInt();
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        width: avatarSize,
        height: avatarSize,
        memCacheWidth: cacheSize,
        memCacheHeight: cacheSize,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildFallback(avatarSize),
        errorWidget: (_, __, ___) => _buildFallback(avatarSize),
      );
    }
    return _buildFallback(avatarSize);
  }

  Widget _buildFallback(double avatarSize) {
    return Container(
      width: avatarSize,
      height: avatarSize,
      color: AppColors.elevated,
      alignment: Alignment.center,
      child: Text(
        fallbackInitial,
        style: AppTypography.buttonSmall.copyWith(
          color: AppColors.textPrimary,
          fontSize: avatarSize * 0.4,
        ),
      ),
    );
  }
}


class _SnapRingPainter extends CustomPainter {
  _SnapRingPainter({
    required this.segmentCount,
    required this.strokeWidth,
    required this.isActive,
  });

  final int segmentCount;
  final double strokeWidth;
  final bool isActive;

  static const _cyan = AppColors.cyan;
  static const _purple = AppColors.purple;
  static const _gray = AppColors.textTertiary;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (segmentCount <= 1) {

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      if (isActive) {
        paint.shader = const SweepGradient(
          colors: [_cyan, _purple, AppColors.magenta, _cyan],
        ).createShader(rect);
      } else {
        paint.color = _gray;
      }

      canvas.drawCircle(center, radius, paint);
      return;
    }


    const gapAngle = 0.08;
    final totalGap = gapAngle * segmentCount;
    final segmentAngle = (2 * pi - totalGap) / segmentCount;
    const startOffset = -pi / 2;

    for (var i = 0; i < segmentCount; i++) {
      final start = startOffset + (i * (segmentAngle + gapAngle));
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      if (isActive) {
        final t = i / segmentCount;
        paint.color = Color.lerp(_cyan, _purple, t)!;
      } else {
        paint.color = _gray;
      }

      canvas.drawArc(rect, start, segmentAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnapRingPainter oldDelegate) {
    return oldDelegate.segmentCount != segmentCount ||
        oldDelegate.isActive != isActive ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
