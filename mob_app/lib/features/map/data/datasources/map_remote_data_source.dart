import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/map_happening_model.dart';


abstract class MapRemoteDataSource {


  Future<List<MapHappeningModel>> getMapHappenings({
    required double neLat,
    required double neLng,
    required double swLat,
    required double swLng,
    String? category,
  });
}


class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  MapRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<List<MapHappeningModel>> getMapHappenings({
    required double neLat,
    required double neLng,
    required double swLat,
    required double swLng,
    String? category,
  }) async {
    final queryParams = <String, dynamic>{
      'ne_lat': neLat,
      'ne_lng': neLng,
      'sw_lat': swLat,
      'sw_lng': swLng,
    };

    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }

    final response = await _dioClient.get<List<dynamic>>(
      ApiEndpoints.happeningsMap,
      queryParams: queryParams,
      fromJson: (data) => data as List<dynamic>,
    );

    return (response.data ?? [])
        .map((e) => MapHappeningModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
