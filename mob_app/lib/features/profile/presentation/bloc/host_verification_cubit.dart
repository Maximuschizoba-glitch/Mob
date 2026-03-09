import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/host_verification_request.dart';
import '../../domain/repositories/host_verification_repository.dart';
import 'host_verification_state.dart';


class HostVerificationCubit extends Cubit<HostVerificationState> {
  HostVerificationCubit({
    required HostVerificationRepository hostVerificationRepository,
  })  : _hostVerificationRepository = hostVerificationRepository,
        super(const HostVerificationInitial());

  final HostVerificationRepository _hostVerificationRepository;


  Future<void> loadVerificationStatus() async {
    emit(const HostVerificationLoading());

    final result =
        await _hostVerificationRepository.getVerificationStatus();

    result.fold(
      (failure) {

        if (failure is NotFoundFailure) {
          emit(const HostVerificationEmpty());
        } else {
          emit(HostVerificationError(failure.message));
        }
      },
      (verification) => emit(HostVerificationLoaded(verification)),
    );
  }


  Future<void> submitVerification(HostVerificationRequest request) async {

    final currentVerification = state is HostVerificationLoaded
        ? (state as HostVerificationLoaded).verification
        : null;

    emit(HostVerificationSubmitting(
      previousVerification: currentVerification,
    ));

    final result =
        await _hostVerificationRepository.submitVerification(request);

    result.fold(
      (failure) => emit(HostVerificationError(
        failure.message,
        previousVerification: currentVerification,
      )),
      (verification) => emit(HostVerificationSubmitted(
        verification,
        message:
            'Verification request submitted. You will be notified once reviewed.',
      )),
    );
  }
}
