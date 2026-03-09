import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';


class FirebaseStorageService {
  FirebaseStorageService({FirebaseStorage? storage}) : _storage = storage;

  final FirebaseStorage? _storage;


  FirebaseStorage get _storageInstance =>
      _storage ?? FirebaseStorage.instance;


  Future<String> uploadSnapMedia({
    required File file,
    required String userId,
    required String mediaType,
    void Function(double progress)? onProgress,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = file.path;
    final dotIndex = filePath.lastIndexOf('.');
    final extension =
        dotIndex != -1 ? filePath.substring(dotIndex).toLowerCase() : '';
    final fileName = '${timestamp}_snap$extension';
    final ref = _storageInstance.ref().child('snaps/$userId/$fileName');

    final contentType = mediaType == 'video' ? 'video/mp4' : 'image/jpeg';
    final metadata = SettableMetadata(contentType: contentType);

    final uploadTask = ref.putFile(file, metadata);


    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((event) {
        if (event.totalBytes > 0) {
          final progress = event.bytesTransferred / event.totalBytes;
          onProgress(progress);
        }
      });
    }

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    debugPrint('[Mob] Uploaded snap media: $downloadUrl');
    return downloadUrl;
  }


  Future<String> uploadSnapThumbnail({
    required File file,
    required String userId,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref =
        _storageInstance.ref().child('snaps/$userId/thumb_$timestamp.jpg');

    final metadata = SettableMetadata(contentType: 'image/jpeg');
    final snapshot = await ref.putFile(file, metadata);
    final downloadUrl = await snapshot.ref.getDownloadURL();

    debugPrint('[Mob] Uploaded thumbnail: $downloadUrl');
    return downloadUrl;
  }


  Future<String> uploadVerificationDocument({
    required File file,
    required String userId,
    void Function(double progress)? onProgress,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = file.path;
    final dotIndex = filePath.lastIndexOf('.');
    final extension =
        dotIndex != -1 ? filePath.substring(dotIndex).toLowerCase() : '.pdf';
    final fileName = '${timestamp}_cac$extension';
    final ref =
        _storageInstance.ref().child('verification/$userId/$fileName');


    final contentType = switch (extension) {
      '.pdf' => 'application/pdf',
      '.png' => 'image/png',
      '.jpg' || '.jpeg' => 'image/jpeg',
      _ => 'application/octet-stream',
    };
    final metadata = SettableMetadata(contentType: contentType);

    final uploadTask = ref.putFile(file, metadata);

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((event) {
        if (event.totalBytes > 0) {
          final progress = event.bytesTransferred / event.totalBytes;
          onProgress(progress);
        }
      });
    }

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    debugPrint('[Mob] Uploaded verification doc: $downloadUrl');
    return downloadUrl;
  }
}
