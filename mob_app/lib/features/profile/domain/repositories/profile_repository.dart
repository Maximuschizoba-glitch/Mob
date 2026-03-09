import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../feed/domain/entities/happening.dart';
import '../../data/models/update_profile_request.dart';


abstract class ProfileRepository {


  Future<Either<Failure, User>> getProfile();


  Future<Either<Failure, User>> updateProfile(UpdateProfileRequest request);


  Future<Either<Failure, User>> updateAvatar(String filePath);


  Future<Either<Failure, List<Happening>>> getMyHappenings();


  Future<Either<Failure, void>> deleteHappening(String uuid);


  Future<Either<Failure, void>> deleteAccount();
}
