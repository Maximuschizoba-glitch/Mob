import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../feed/domain/entities/happening.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/map_remote_data_source.dart';


class MapRepositoryImpl implements MapRepository {
  MapRepositoryImpl({required MapRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final MapRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<Happening>>> getMapHappenings({
    required double neLat,
    required double neLng,
    required double swLat,
    required double swLng,
    String? category,
  }) async {
    try {
      final result = await _remoteDataSource.getMapHappenings(
        neLat: neLat,
        neLng: neLng,
        swLat: swLat,
        swLng: swLng,
        category: category,
      );
      return Right(result);
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
