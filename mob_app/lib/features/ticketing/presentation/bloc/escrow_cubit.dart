import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/ticket_repository.dart';
import 'escrow_state.dart';


class EscrowCubit extends Cubit<EscrowState> {
  EscrowCubit({
    required TicketRepository ticketRepository,
  })  : _ticketRepository = ticketRepository,
        super(const EscrowInitial());

  final TicketRepository _ticketRepository;


  Future<void> loadEscrowDashboard(String uuid) async {
    emit(const EscrowLoading());

    final result = await _ticketRepository.getEscrowDashboard(uuid);

    result.fold(
      (failure) => emit(EscrowError(failure.message)),
      (escrow) => emit(EscrowLoaded(escrow)),
    );
  }


  Future<void> loadEscrowByHappening(String happeningUuid) async {
    emit(const EscrowLoading());

    final result =
        await _ticketRepository.getEscrowByHappening(happeningUuid);

    result.fold(
      (failure) {

        if (failure is NotFoundFailure) {
          emit(const EscrowEmpty());
        } else {
          emit(EscrowError(failure.message));
        }
      },
      (escrow) => emit(EscrowLoaded(escrow)),
    );
  }


  Future<void> markEventComplete(String uuid) async {

    final currentEscrow =
        state is EscrowLoaded ? (state as EscrowLoaded).escrow : null;

    if (currentEscrow != null) {
      emit(EscrowActionLoading(currentEscrow));
    } else {
      emit(const EscrowLoading());
    }

    final result = await _ticketRepository.markEventComplete(uuid);

    result.fold(
      (failure) => emit(EscrowError(
        failure.message,
        previousEscrow: currentEscrow,
      )),
      (escrow) => emit(EscrowLoaded(escrow)),
    );
  }
}
