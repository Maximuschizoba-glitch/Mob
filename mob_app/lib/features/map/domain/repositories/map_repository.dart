import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../feed/domain/entities/happening.dart';


abstract class MapRepository {


  Future<Either<Failure, List<Happening>>> getMapHappenings({
    required double neLat,
    required double neLng,
    required double swLat,
    required double swLng,
    String? category,
  });
}
