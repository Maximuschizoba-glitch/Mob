import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';


abstract class ReportRemoteDataSource {


  Future<void> submitReport({
    required String happeningUuid,
    required String reason,
    String? details,
  });
}


class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  ReportRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<void> submitReport({
    required String happeningUuid,
    required String reason,
    String? details,
  }) async {
    final body = <String, dynamic>{
      'reason': reason,
    };

    if (details != null && details.trim().isNotEmpty) {
      body['details'] = details.trim();
    }

    await _dioClient.post<void>(
      ApiEndpoints.happeningReport(happeningUuid),
      data: body,
    );
  }
}
