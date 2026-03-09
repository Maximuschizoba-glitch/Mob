import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';


abstract class AuthRepository {


  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  });


  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });


  Future<Either<Failure, void>> logout();


  Future<Either<Failure, User>> getUser();


  Future<Either<Failure, void>> sendOtp({required String phone});


  Future<Either<Failure, User>> verifyOtp({
    required String phone,
    required String otp,
  });


  Future<Either<Failure, User>> verifyEmail({required String token});


  Future<Either<Failure, User>> guestLogin();


  Future<Either<Failure, User>> checkAuthStatus();


  Future<Either<Failure, void>> registerFcmToken({
    required String token,
    required String deviceType,
  });
}
