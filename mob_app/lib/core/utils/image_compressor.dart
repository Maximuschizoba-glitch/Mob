import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';


class ImageCompressor {
  ImageCompressor._();


  static const int maxDimension = 1920;


  static const int quality = 80;


  static const int skipThresholdBytes = 200 * 1024;


  static Future<File> compress(File file) async {
    try {

      final fileSize = await file.length();
      if (fileSize < skipThresholdBytes) {
        debugPrint(
          '[Mob] Image already small (${fileSize ~/ 1024}KB), '
          'skipping compression',
        );
        return file;
      }


      final ext = file.path.toLowerCase();
      if (!_isSupportedImage(ext)) {
        debugPrint(
          '[Mob] Not a supported image format, skipping compression',
        );
        return file;
      }


      final tempDir = Directory.systemTemp;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final targetPath = '${tempDir.path}/mob_compressed_$timestamp.jpg';

      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxDimension,
        minHeight: maxDimension,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        debugPrint('[Mob] Compression returned null, using original');
        return file;
      }

      final compressedFile = File(result.path);
      final compressedSize = await compressedFile.length();

      debugPrint(
        '[Mob] Image compressed: '
        '${fileSize ~/ 1024}KB → ${compressedSize ~/ 1024}KB '
        '(${((1 - compressedSize / fileSize) * 100).toStringAsFixed(0)}%'
        ' reduction)',
      );


      if (compressedSize >= fileSize) {
        debugPrint('[Mob] Compressed file not smaller, using original');
        try {
          await compressedFile.delete();
        } catch (_) {

        }
        return file;
      }

      return compressedFile;
    } catch (e) {
      debugPrint('[Mob] Image compression failed: $e');
      return file;
    }
  }


  static Future<Uint8List> compressBytes(Uint8List bytes) async {
    try {
      if (bytes.length < skipThresholdBytes) return bytes;

      final result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: quality,
        minWidth: maxDimension,
        minHeight: maxDimension,
        format: CompressFormat.jpeg,
      );

      if (result.length >= bytes.length) return bytes;
      return result;
    } catch (e) {
      debugPrint('[Mob] Byte compression failed: $e');
      return bytes;
    }
  }


  static Future<List<File>> compressAll(List<File> files) async {
    return Future.wait(files.map(compress));
  }


  static bool _isSupportedImage(String path) {
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp') ||
        path.endsWith('.heic') ||
        path.endsWith('.heif');
  }
}
