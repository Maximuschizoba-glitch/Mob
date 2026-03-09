import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_data_source.dart';


class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl({required ReportRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ReportRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, void>> submitReport({
    required String happeningUuid,
    required String reason,
    String? details,
  }) async {
    try {
      await _remoteDataSource.submitReport(
        happeningUuid: happeningUuid,
        reason: reason,
        details: details,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
