import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/host_verification_model.dart';
import '../models/host_verification_request.dart';


abstract class HostVerificationRemoteDataSource {


  Future<HostVerificationModel> submitVerification(
    HostVerificationRequest request,
  );


  Future<HostVerificationModel> getVerificationStatus();
}


class HostVerificationRemoteDataSourceImpl
    implements HostVerificationRemoteDataSource {
  HostVerificationRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<HostVerificationModel> submitVerification(
    HostVerificationRequest request,
  ) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiEndpoints.hostVerify,
      data: request.toJson(),
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return HostVerificationModel.fromJson(response.data!);
  }

  @override
  Future<HostVerificationModel> getVerificationStatus() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiEndpoints.hostVerificationStatus,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return HostVerificationModel.fromJson(response.data!);
  }
}
