import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/happening.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_data_source.dart';


class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl({required FeedRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final FeedRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<Happening>>> getNearbyHappenings({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? category,
    int page = 1,
  }) async {
    try {
      final result = await _remoteDataSource.getNearbyHappenings(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        category: category,
        page: page,
      );
      return Right(result.happenings);
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
  Future<Either<Failure, Happening>> getHappeningDetail(String uuid) async {
    try {
      final happening = await _remoteDataSource.getHappeningDetail(uuid);
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
}
