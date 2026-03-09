import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../feed/domain/entities/happening.dart';
import '../../domain/repositories/happening_repository.dart';
import '../datasources/happening_remote_data_source.dart';
import '../models/create_happening_request.dart';


class HappeningRepositoryImpl implements HappeningRepository {
  HappeningRepositoryImpl({
    required HappeningRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final HappeningRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Happening>> createHappening(
    CreateHappeningRequest request,
  ) async {
    try {
      final happening = await _remoteDataSource.createHappening(request);
      return Right(happening);
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
  Future<Either<Failure, Happening>> updateHappening(
    String uuid, {
    String? title,
    String? description,
    String? category,
  }) async {
    try {
      final happening = await _remoteDataSource.updateHappening(
        uuid,
        title: title,
        description: description,
        category: category,
      );
      return Right(happening);
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
  Future<Either<Failure, void>> endHappening(String uuid) async {
    try {
      await _remoteDataSource.endHappening(uuid);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHappening(String uuid) async {
    try {
      await _remoteDataSource.deleteHappening(uuid);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
