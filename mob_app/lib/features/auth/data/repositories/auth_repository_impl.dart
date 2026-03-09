import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';


class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;


  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    return _handleAuthRequest(() async {
      final result = await _remoteDataSource.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );


      await _localDataSource.saveToken(result.token);
      await _localDataSource.saveUser(result.user);

      return result.user;
    });
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    return _handleAuthRequest(() async {
      final result = await _remoteDataSource.login(
        email: email,
        password: password,
      );


      await _localDataSource.saveToken(result.token);
      await _localDataSource.saveUser(result.user);

      return result.user;
    });
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {

      await _remoteDataSource.logout();
    } on AuthException {

    } on NetworkException {

    } on ServerException {

    } finally {

      await _localDataSource.clearAll();
    }

    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> getUser() async {
    return _handleAuthRequest(() async {
      final user = await _remoteDataSource.getUser();


      await _localDataSource.saveUser(user);

      return user;
    });
  }

  @override
  Future<Either<Failure, void>> sendOtp({required String phone}) async {
    try {
      await _remoteDataSource.sendOtp(phone: phone);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    return _handleAuthRequest(() async {
      final user = await _remoteDataSource.verifyOtp(
        phone: phone,
        otp: otp,
      );


      await _localDataSource.saveUser(user);

      return user;
    });
  }

  @override
  Future<Either<Failure, User>> verifyEmail({required String token}) async {
    return _handleAuthRequest(() async {
      final user = await _remoteDataSource.verifyEmail(token: token);


      await _localDataSource.saveUser(user);

      return user;
    });
  }

  @override
  Future<Either<Failure, User>> guestLogin() async {
    return _handleAuthRequest(() async {
      final result = await _remoteDataSource.getGuestToken();


      await _localDataSource.saveToken(result.token);
      await _localDataSource.saveUser(result.user);

      return result.user;
    });
  }

  @override
  Future<Either<Failure, User>> checkAuthStatus() async {
    try {

      final hasToken = await _localDataSource.hasToken();
      if (!hasToken) {
        return const Left(AuthFailure('No auth token found'));
      }


      final cachedUser = await _localDataSource.getCachedUser();


      try {
        final freshUser = await _remoteDataSource.getUser();
        await _localDataSource.saveUser(freshUser);
        return Right(freshUser);
      } on AuthException {

        await _localDataSource.clearAll();
        return const Left(AuthFailure('Session expired'));
      } on NetworkException {

        if (cachedUser != null) {
          return Right(cachedUser);
        }
        return const Left(
          NetworkFailure('No internet connection and no cached data'),
        );
      } on ServerException catch (e) {

        if (cachedUser != null) {
          return Right(cachedUser);
        }
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> registerFcmToken({
    required String token,
    required String deviceType,
  }) async {
    try {
      await _remoteDataSource.registerFcmToken(
        token: token,
        deviceType: deviceType,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }


  Future<Either<Failure, User>> _handleAuthRequest(
    Future<UserModel> Function() request,
  ) async {
    try {
      final user = await request();
      return Right(user);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
