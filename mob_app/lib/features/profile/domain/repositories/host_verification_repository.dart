import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/host_verification_request.dart';
import '../entities/host_verification.dart';


abstract class HostVerificationRepository {


  Future<Either<Failure, HostVerification>> submitVerification(
    HostVerificationRequest request,
  );


  Future<Either<Failure, HostVerification>> getVerificationStatus();
}
