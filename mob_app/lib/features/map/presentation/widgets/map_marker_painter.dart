import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../shared/models/enums.dart';


class MapMarkerPainter {
  MapMarkerPainter._();


  static final Map<String, BitmapDescriptor> _cache = {};


  static Future<BitmapDescriptor> createImageMarker({
    required ui.Image image,
    required HappeningCategory category,
    required ActivityLevel activityLevel,
    required double devicePixelRatio,
    required String cacheKey,
  }) async {
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final ratio = devicePixelRatio.clamp(1.0, 3.0);


    final circleSize = (40 * ratio).toDouble();
    final borderWidth = (3 * ratio).toDouble();
    final triangleHeight = (8 * ratio).toDouble();
    final glowPadding =
        activityLevel == ActivityLevel.high ? (6 * ratio) : 0.0;
    final totalSize = circleSize + borderWidth * 2 + glowPadding * 2;
    final totalHeight = totalSize + triangleHeight;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final centerX = totalSize / 2;
    final centerY = (totalSize - glowPadding) / 2 + glowPadding / 2;
    final outerRadius = circleSize / 2 + borderWidth;
    final innerRadius = circleSize / 2;


    if (activityLevel == ActivityLevel.high) {
      final glowPaint = Paint()
        ..color = activityLevel.color.withAlpha(50)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * ratio);
      canvas.drawCircle(Offset(centerX, centerY), outerRadius + 3 * ratio,
          glowPaint);
    }


    final borderPaint = Paint()..color = category.color;
    canvas.drawCircle(Offset(centerX, centerY), outerRadius, borderPaint);


    canvas.save();
    final clipPath = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(centerX, centerY), radius: innerRadius));
    canvas.clipPath(clipPath);


    final srcRect = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final dstRect = Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: innerRadius,
    );
    canvas.drawImageRect(image, srcRect, dstRect, Paint());
    canvas.restore();


    final triangleTop = centerY + outerRadius;
    final trianglePath = Path()
      ..moveTo(centerX - 6 * ratio, triangleTop)
      ..lineTo(centerX, triangleTop + triangleHeight)
      ..lineTo(centerX + 6 * ratio, triangleTop)
      ..close();
    canvas.drawPath(trianglePath, borderPaint);

    final picture = recorder.endRecording();
    final rendered = await picture.toImage(
      totalSize.ceil(),
      totalHeight.ceil(),
    );
    final byteData =
        await rendered.toByteData(format: ui.ImageByteFormat.png);

    final descriptor = BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
    _cache[cacheKey] = descriptor;
    return descriptor;
  }


  static Future<BitmapDescriptor> createMarker({
    required HappeningCategory category,
    required ActivityLevel activityLevel,
    required double devicePixelRatio,
  }) async {
    final cacheKey =
        'emoji_${category.value}_${activityLevel.value}_$devicePixelRatio';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final ratio = devicePixelRatio.clamp(1.0, 3.0);
    final pinWidth = (28 * ratio).toDouble();
    final pinHeight = (36 * ratio).toDouble();
    final glowPadding =
        activityLevel == ActivityLevel.high ? (8 * ratio) : 0.0;
    final totalWidth = pinWidth + glowPadding * 2;
    final totalHeight = pinHeight + glowPadding;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final centerX = totalWidth / 2;
    final bodyLeft = (totalWidth - pinWidth) / 2;
    final bodyTop = glowPadding / 2;
    final bodyWidth = pinWidth;
    final bodyHeight = pinHeight - (8 * ratio);
    final cornerRadius = 6 * ratio;
    final triangleHeight = 8 * ratio;


    if (activityLevel == ActivityLevel.high) {
      final glowPaint = Paint()
        ..color = activityLevel.color.withAlpha(40)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * ratio);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            bodyLeft - 3 * ratio,
            bodyTop - 3 * ratio,
            bodyWidth + 6 * ratio,
            bodyHeight + 6 * ratio,
          ),
          Radius.circular(cornerRadius + 3 * ratio),
        ),
        glowPaint,
      );
    }


    final bodyPaint = Paint()..color = category.color;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth, bodyHeight),
      Radius.circular(cornerRadius),
    );
    canvas.drawRRect(bodyRect, bodyPaint);


    final trianglePath = Path()
      ..moveTo(centerX - 5 * ratio, bodyTop + bodyHeight)
      ..lineTo(centerX, bodyTop + bodyHeight + triangleHeight)
      ..lineTo(centerX + 5 * ratio, bodyTop + bodyHeight)
      ..close();
    canvas.drawPath(trianglePath, bodyPaint);


    final textPainter = TextPainter(
      text: TextSpan(
        text: category.emoji,
        style: TextStyle(fontSize: 14 * ratio),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        centerX - textPainter.width / 2,
        bodyTop + bodyHeight / 2 - textPainter.height / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      totalWidth.ceil(),
      totalHeight.ceil(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    final descriptor = BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
    _cache[cacheKey] = descriptor;
    return descriptor;
  }


  static void clearCache() => _cache.clear();
}
