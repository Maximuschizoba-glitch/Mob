import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../feed/domain/entities/happening.dart';
import '../../data/models/create_happening_request.dart';


abstract class HappeningRepository {

  Future<Either<Failure, Happening>> createHappening(
    CreateHappeningRequest request,
  );


  Future<Either<Failure, Happening>> updateHappening(
    String uuid, {
    String? title,
    String? description,
    String? category,
  });


  Future<Either<Failure, void>> endHappening(String uuid);


  Future<Either<Failure, void>> deleteHappening(String uuid);
}
