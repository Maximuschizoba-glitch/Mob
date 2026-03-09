import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/ticket_repository.dart';
import 'ticket_state.dart';


class TicketCubit extends Cubit<TicketState> {
  TicketCubit({
    required TicketRepository ticketRepository,
  })  : _ticketRepository = ticketRepository,
        super(const TicketInitial());

  final TicketRepository _ticketRepository;


  String? _activeFilter;


  String? get activeFilter => _activeFilter;


  Future<void> loadMyTickets({String? status}) async {
    _activeFilter = status;
    emit(const TicketsLoading());

    final result = await _ticketRepository.getMyTickets(status: status);

    result.fold(
      (failure) => emit(TicketError(failure.message)),
      (tickets) => emit(TicketsLoaded(
        tickets: tickets,
        activeFilter: _activeFilter,
      )),
    );
  }


  Future<void> loadTicketDetail(String uuid) async {
    emit(const TicketsLoading());

    final result = await _ticketRepository.getTicketDetail(uuid);

    result.fold(
      (failure) => emit(TicketError(failure.message)),
      (ticket) => emit(TicketDetailLoaded(ticket)),
    );
  }


  Future<void> requestRefund(String ticketUuid) async {

    final currentTickets =
        state is TicketsLoaded ? (state as TicketsLoaded).tickets : null;

    emit(const TicketsLoading());

    final result = await _ticketRepository.requestRefund(ticketUuid);

    result.fold(
      (failure) => emit(TicketError(
        failure.message,
        previousTickets: currentTickets,
      )),
      (_) async {

        await loadMyTickets(status: _activeFilter);
      },
    );
  }
}
