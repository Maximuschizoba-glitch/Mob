import 'dart:io';

import '../../../auth/data/models/user_model.dart';
import '../../../feed/data/models/happening_model.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/image_compressor.dart';
import '../models/update_profile_request.dart';


abstract class ProfileRemoteDataSource {


  Future<UserModel> getProfile();


  Future<UserModel> updateProfile(UpdateProfileRequest request);


  Future<UserModel> updateAvatar(String filePath);


  Future<List<HappeningModel>> getMyHappenings();


  Future<void> deleteHappening(String uuid);


  Future<void> deleteAccount();
}


class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<UserModel> getProfile() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiEndpoints.user,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return UserModel.fromJson(response.data!);
  }

  @override
  Future<UserModel> updateProfile(UpdateProfileRequest request) async {
    final response = await _dioClient.put<Map<String, dynamic>>(
      ApiEndpoints.updateProfile,
      data: request.toJson(),
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return UserModel.fromJson(response.data!);
  }

  @override
  Future<UserModel> updateAvatar(String filePath) async {

    final compressed = await ImageCompressor.compress(File(filePath));

    final response = await _dioClient.uploadFile<Map<String, dynamic>>(
      '${ApiEndpoints.profile}/avatar',
      filePath: compressed.path,
      fileField: 'avatar',
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return UserModel.fromJson(response.data!);
  }

  @override
  Future<List<HappeningModel>> getMyHappenings() async {
    final response = await _dioClient.get<List<dynamic>>(
      ApiEndpoints.myHappenings,
      fromJson: (data) => data as List<dynamic>,
    );

    return (response.data ?? [])
        .map((e) => HappeningModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> deleteHappening(String uuid) async {
    await _dioClient.delete<void>(ApiEndpoints.happeningDetail(uuid));
  }

  @override
  Future<void> deleteAccount() async {
    await _dioClient.delete<void>(ApiEndpoints.profile);
  }
}
