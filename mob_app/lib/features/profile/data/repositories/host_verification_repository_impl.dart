import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/host_verification_request.dart';
import '../../domain/entities/host_verification.dart';
import '../../domain/repositories/host_verification_repository.dart';
import '../datasources/host_verification_remote_data_source.dart';


class HostVerificationRepositoryImpl implements HostVerificationRepository {
  HostVerificationRepositoryImpl({
    required HostVerificationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final HostVerificationRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, HostVerification>> submitVerification(
    HostVerificationRequest request,
  ) async {
    try {
      final verification =
          await _remoteDataSource.submitVerification(request);
      return Right(verification);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    }
  }

  @override
  Future<Either<Failure, HostVerification>> getVerificationStatus() async {
    try {
      final verification = await _remoteDataSource.getVerificationStatus();
      return Right(verification);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {

      if (e.statusCode == 404) {
        return Left(NotFoundFailure(e.message));
      }
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    }
  }
}
