import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/happening.dart';


abstract class FeedRepository {


  Future<Either<Failure, List<Happening>>> getNearbyHappenings({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? category,
    int page = 1,
  });


  Future<Either<Failure, Happening>> getHappeningDetail(String uuid);
}
