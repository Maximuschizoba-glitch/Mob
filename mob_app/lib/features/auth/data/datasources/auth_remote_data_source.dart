import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';


abstract class AuthRemoteDataSource {


  Future<({UserModel user, String token})> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  });


  Future<({UserModel user, String token})> login({
    required String email,
    required String password,
  });


  Future<void> logout();


  Future<UserModel> getUser();


  Future<void> sendOtp({required String phone});


  Future<UserModel> verifyOtp({
    required String phone,
    required String otp,
  });


  Future<UserModel> verifyEmail({required String token});


  Future<({UserModel user, String token})> getGuestToken();


  Future<void> registerFcmToken({
    required String token,
    required String deviceType,
  });
}


class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<({UserModel user, String token})> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return _parseAuthResponse(response.data!);
  }

  @override
  Future<({UserModel user, String token})> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return _parseAuthResponse(response.data!);
  }

  @override
  Future<void> logout() async {
    await _dioClient.post(ApiEndpoints.logout);
  }

  @override
  Future<UserModel> getUser() async {
    final response = await _dioClient.get<UserModel>(
      ApiEndpoints.user,
      fromJson: (json) =>
          UserModel.fromJson(json as Map<String, dynamic>),
    );

    return response.data!;
  }

  @override
  Future<void> sendOtp({required String phone}) async {
    await _dioClient.post(
      ApiEndpoints.sendPhoneOtp,
      data: {'phone': phone},
    );
  }

  @override
  Future<UserModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await _dioClient.post<UserModel>(
      ApiEndpoints.verifyPhone,
      data: {
        'phone': phone,
        'otp': otp,
      },
      fromJson: (json) =>
          UserModel.fromJson(json as Map<String, dynamic>),
    );

    return response.data!;
  }

  @override
  Future<UserModel> verifyEmail({required String token}) async {
    final response = await _dioClient.post<UserModel>(
      ApiEndpoints.verifyEmail,
      data: {'token': token},
      fromJson: (json) =>
          UserModel.fromJson(json as Map<String, dynamic>),
    );

    return response.data!;
  }

  @override
  Future<({UserModel user, String token})> getGuestToken() async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiEndpoints.guestToken,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return _parseAuthResponse(response.data!);
  }

  @override
  Future<void> registerFcmToken({
    required String token,
    required String deviceType,
  }) async {
    await _dioClient.post(
      ApiEndpoints.registerFcmToken,
      data: {
        'token': token,
        'device_type': deviceType,
      },
    );
  }


  ({UserModel user, String token}) _parseAuthResponse(
    Map<String, dynamic> data,
  ) {
    final userJson = data['user'] as Map<String, dynamic>;
    final token = data['token'] as String;

    return (
      user: UserModel.fromJson(userJson),
      token: token,
    );
  }
}
