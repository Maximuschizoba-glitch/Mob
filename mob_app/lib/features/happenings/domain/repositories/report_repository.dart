import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';


abstract class ReportRepository {


  Future<Either<Failure, void>> submitReport({
    required String happeningUuid,
    required String reason,
    String? details,
  });
}
