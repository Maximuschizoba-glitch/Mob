import 'package:equatable/equatable.dart';

import '../../domain/entities/ticket.dart';


abstract class TicketState extends Equatable {
  const TicketState();

  @override
  List<Object?> get props => [];
}


class TicketInitial extends TicketState {
  const TicketInitial();
}


class TicketsLoading extends TicketState {
  const TicketsLoading();
}


class TicketsLoaded extends TicketState {

  final List<Ticket> tickets;


  final String? activeFilter;

  const TicketsLoaded({
    required this.tickets,
    this.activeFilter,
  });


  TicketsLoaded copyWith({
    List<Ticket>? tickets,
    String? activeFilter,
  }) {
    return TicketsLoaded(
      tickets: tickets ?? this.tickets,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object?> get props => [tickets, activeFilter];
}


class TicketDetailLoaded extends TicketState {
  final Ticket ticket;

  const TicketDetailLoaded(this.ticket);

  @override
  List<Object?> get props => [ticket];
}


class TicketError extends TicketState {

  final String message;


  final List<Ticket>? previousTickets;

  const TicketError(
    this.message, {
    this.previousTickets,
  });

  @override
  List<Object?> get props => [message, previousTickets];
}
