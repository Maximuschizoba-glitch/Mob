import 'package:equatable/equatable.dart';

import '../../domain/entities/escrow.dart';


abstract class EscrowState extends Equatable {
  const EscrowState();

  @override
  List<Object?> get props => [];
}


class EscrowInitial extends EscrowState {
  const EscrowInitial();
}


class EscrowLoading extends EscrowState {
  const EscrowLoading();
}


class EscrowEmpty extends EscrowState {
  const EscrowEmpty();
}


class EscrowLoaded extends EscrowState {
  final Escrow escrow;

  const EscrowLoaded(this.escrow);

  @override
  List<Object?> get props => [escrow];
}


class EscrowActionLoading extends EscrowState {

  final Escrow escrow;

  const EscrowActionLoading(this.escrow);

  @override
  List<Object?> get props => [escrow];
}


class EscrowError extends EscrowState {

  final String message;


  final Escrow? previousEscrow;

  const EscrowError(
    this.message, {
    this.previousEscrow,
  });

  @override
  List<Object?> get props => [message, previousEscrow];
}
