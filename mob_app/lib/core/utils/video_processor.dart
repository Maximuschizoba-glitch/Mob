import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:video_compress/video_compress.dart';


const int maxVideoDurationSeconds = 30;


class VideoProcessingResult {
  const VideoProcessingResult({
    required this.compressedFile,
    required this.thumbnail,
    required this.durationSeconds,
  });


  final File compressedFile;


  final File thumbnail;


  final int durationSeconds;
}


class VideoProcessor {

  Subscription? _progressSubscription;


  Future<VideoProcessingResult> processForUpload(
    File videoFile, {
    void Function(double progress)? onProgress,
  }) async {

    final durationSeconds = await getDurationSeconds(videoFile);

    if (durationSeconds > maxVideoDurationSeconds) {
      throw VideoTooLongException(
        durationSeconds: durationSeconds,
        maxSeconds: maxVideoDurationSeconds,
      );
    }


    _progressSubscription?.unsubscribe();
    _progressSubscription =
        VideoCompress.compressProgress$.subscribe((percent) {
      onProgress?.call((percent / 100.0).clamp(0.0, 1.0));
    });

    try {


      final result = await VideoCompress.compressVideo(
        videoFile.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
        frameRate: 30,
      );

      if (result == null || result.file == null) {
        throw const VideoCompressionException(
          'Video compression returned no output. Please try again.',
        );
      }

      final compressedFile = result.file!;


      final thumbnail = await generateThumbnail(videoFile);

      return VideoProcessingResult(
        compressedFile: compressedFile,
        thumbnail: thumbnail,
        durationSeconds: durationSeconds,
      );
    } finally {
      _progressSubscription?.unsubscribe();
      _progressSubscription = null;
    }
  }


  Future<int> getDurationSeconds(File videoFile) async {
    final info = await VideoCompress.getMediaInfo(videoFile.path);
    final durationMs = info.duration ?? 0.0;
    return (durationMs / 1000.0).ceil();
  }


  Future<File> generateThumbnail(File videoFile) async {
    try {
      return await VideoCompress.getFileThumbnail(
        videoFile.path,
        quality: 75,
      );
    } catch (e) {
      debugPrint('[VideoProcessor] Thumbnail generation failed: $e');
      throw VideoCompressionException(
        'Failed to generate video thumbnail: $e',
      );
    }
  }


  Future<void> cancelCompression() async {
    _progressSubscription?.unsubscribe();
    _progressSubscription = null;
    await VideoCompress.cancelCompression();
  }


  Future<void> dispose() async {
    await cancelCompression();
    await VideoCompress.deleteAllCache();
  }
}


class VideoTooLongException implements Exception {
  const VideoTooLongException({
    required this.durationSeconds,
    required this.maxSeconds,
  });

  final int durationSeconds;
  final int maxSeconds;

  String get message =>
      'Video is ${durationSeconds}s long. Maximum allowed is ${maxSeconds}s.';

  @override
  String toString() => 'VideoTooLongException: $message';
}


class VideoCompressionException implements Exception {
  const VideoCompressionException(this.message);

  final String message;

  @override
  String toString() => 'VideoCompressionException: $message';
}
