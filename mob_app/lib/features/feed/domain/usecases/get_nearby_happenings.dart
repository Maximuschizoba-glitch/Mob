import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/happening.dart';
import '../repositories/feed_repository.dart';


class GetNearbyHappenings {
  GetNearbyHappenings(this._repository);

  final FeedRepository _repository;


  Future<Either<Failure, List<Happening>>> call({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? category,
    int page = 1,
  }) {
    return _repository.getNearbyHappenings(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      category: category,
      page: page,
    );
  }
}
