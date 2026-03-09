import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/snap.dart';


abstract class SnapRepository {


  Future<Either<Failure, List<Snap>>> getHappeningSnaps(String happeningUuid);


  Future<Either<Failure, Snap>> createSnap({
    required String happeningUuid,
    required String mediaUrl,
    required String mediaType,
    String? thumbnailUrl,
    int? durationSeconds,
  });
}
