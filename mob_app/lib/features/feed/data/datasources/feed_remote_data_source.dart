import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/happening_model.dart';


abstract class FeedRemoteDataSource {


  Future<PaginatedHappenings> getNearbyHappenings({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? category,
    int page = 1,
    int perPage = 20,
  });


  Future<HappeningModel> getHappeningDetail(String uuid);
}


class PaginatedHappenings {
  final List<HappeningModel> happenings;
  final PaginationMeta? meta;

  const PaginatedHappenings({
    required this.happenings,
    this.meta,
  });
}


class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  FeedRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<PaginatedHappenings> getNearbyHappenings({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? category,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'radius_km': radiusKm,
      'page': page,
      'per_page': perPage,
    };


    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }

    final response = await _dioClient.get<List<dynamic>>(
      ApiEndpoints.happenings,
      queryParams: queryParams,
      fromJson: (data) => data as List<dynamic>,
    );

    final happenings = (response.data ?? [])
        .map((e) => HappeningModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedHappenings(
      happenings: happenings,
      meta: response.meta,
    );
  }

  @override
  Future<HappeningModel> getHappeningDetail(String uuid) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiEndpoints.happeningDetail(uuid),
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return HappeningModel.fromJson(response.data!);
  }
}
