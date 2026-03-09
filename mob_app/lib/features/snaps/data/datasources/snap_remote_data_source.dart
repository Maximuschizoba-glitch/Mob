import 'dart:io';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/video_processor.dart';
import '../models/snap_model.dart';


export '../../../../core/utils/video_processor.dart'
    show
        VideoTooLongException,
        VideoCompressionException,
        maxVideoDurationSeconds;


abstract class SnapRemoteDataSource {


  Future<List<SnapModel>> getHappeningSnaps(String happeningUuid);


  Future<SnapModel> createSnap({
    required String happeningUuid,
    required String mediaUrl,
    required String mediaType,
    String? thumbnailUrl,
    int? durationSeconds,
  });


  Future<File> compressVideo(File videoFile);


  Future<File> generateVideoThumbnail(File videoFile);
}


class SnapRemoteDataSourceImpl implements SnapRemoteDataSource {
  SnapRemoteDataSourceImpl({
    required DioClient dioClient,
    VideoProcessor? videoProcessor,
  })  : _dioClient = dioClient,
        _videoProcessor = videoProcessor ?? VideoProcessor();

  final DioClient _dioClient;
  final VideoProcessor _videoProcessor;

  @override
  Future<List<SnapModel>> getHappeningSnaps(String happeningUuid) async {
    final response = await _dioClient.get<List<dynamic>>(
      ApiEndpoints.happeningSnaps(happeningUuid),
      fromJson: (data) => data as List<dynamic>,
    );

    return (response.data ?? [])
        .map((e) => SnapModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SnapModel> createSnap({
    required String happeningUuid,
    required String mediaUrl,
    required String mediaType,
    String? thumbnailUrl,
    int? durationSeconds,
  }) async {
    final body = <String, dynamic>{
      'media_url': mediaUrl,
      'media_type': mediaType,
    };

    if (thumbnailUrl != null) {
      body['thumbnail_url'] = thumbnailUrl;
    }
    if (durationSeconds != null) {
      body['duration_seconds'] = durationSeconds;
    }

    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiEndpoints.happeningSnaps(happeningUuid),
      data: body,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    final data = response.data!;


    final snapJson = data.containsKey('snap')
        ? data['snap'] as Map<String, dynamic>
        : data;

    return SnapModel.fromJson(snapJson);
  }

  @override
  Future<File> compressVideo(File videoFile) async {
    final result = await _videoProcessor.processForUpload(videoFile);
    return result.compressedFile;
  }

  @override
  Future<File> generateVideoThumbnail(File videoFile) async {
    return _videoProcessor.generateThumbnail(videoFile);
  }
}
