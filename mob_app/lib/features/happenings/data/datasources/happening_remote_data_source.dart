import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../feed/data/models/happening_model.dart';
import '../../../feed/domain/entities/happening.dart';
import '../models/create_happening_request.dart';


abstract class HappeningRemoteDataSource {


  Future<Happening> createHappening(CreateHappeningRequest request);


  Future<Happening> updateHappening(
    String uuid, {
    String? title,
    String? description,
    String? category,
  });


  Future<void> endHappening(String uuid);


  Future<void> deleteHappening(String uuid);
}


class HappeningRemoteDataSourceImpl implements HappeningRemoteDataSource {
  HappeningRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<Happening> createHappening(CreateHappeningRequest request) async {
    final body = request.toJson();

    debugPrint(
      '[Mob] POST ${ApiEndpoints.happenings} FULL REQUEST BODY: ${jsonEncode(body)}',
    );

    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        ApiEndpoints.happenings,
        data: body,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      return HappeningModel.fromJson(response.data!);
    } on ValidationException catch (e) {
      debugPrint(
        '[Mob] API VALIDATION ERROR: message=${e.message} errors=${e.errors}',
      );
      rethrow;
    } on ServerException catch (e) {
      debugPrint(
        '[Mob] API SERVER ERROR: statusCode=${e.statusCode} message=${e.message}',
      );
      rethrow;
    }
  }

  @override
  Future<Happening> updateHappening(
    String uuid, {
    String? title,
    String? description,
    String? category,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (category != null) body['category'] = category;

    final response = await _dioClient.put<Map<String, dynamic>>(
      ApiEndpoints.happeningUpdate(uuid),
      data: body,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return HappeningModel.fromJson(response.data!);
  }

  @override
  Future<void> endHappening(String uuid) async {
    await _dioClient.post<Map<String, dynamic>>(
      ApiEndpoints.happeningEnd(uuid),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteHappening(String uuid) async {
    await _dioClient.delete<Map<String, dynamic>>(
      ApiEndpoints.happeningDelete(uuid),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}
