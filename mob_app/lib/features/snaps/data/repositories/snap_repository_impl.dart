import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/snap.dart';
import '../../domain/repositories/snap_repository.dart';
import '../datasources/snap_remote_data_source.dart';


class SnapRepositoryImpl implements SnapRepository {
  SnapRepositoryImpl({required SnapRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final SnapRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<Snap>>> getHappeningSnaps(
    String happeningUuid,
  ) async {
    try {
      final snaps = await _remoteDataSource.getHappeningSnaps(happeningUuid);
      return Right(snaps);
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
  Future<Either<Failure, Snap>> createSnap({
    required String happeningUuid,
    required String mediaUrl,
    required String mediaType,
    String? thumbnailUrl,
    int? durationSeconds,
  }) async {
    try {
      final snap = await _remoteDataSource.createSnap(
        happeningUuid: happeningUuid,
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        thumbnailUrl: thumbnailUrl,
        durationSeconds: durationSeconds,
      );
      return Right(snap);
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
