import 'package:equatable/equatable.dart';

import '../../domain/entities/ticket.dart';


abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}


class PaymentInitial extends PaymentState {
  const PaymentInitial();
}


class PaymentLoading extends PaymentState {
  const PaymentLoading();
}


class PaymentInitialized extends PaymentState {

  final String paymentUrl;


  final String? paymentReference;


  final String ticketUuid;


  final String gateway;

  const PaymentInitialized({
    required this.paymentUrl,
    this.paymentReference,
    required this.ticketUuid,
    required this.gateway,
  });

  @override
  List<Object?> get props => [
        paymentUrl,
        paymentReference,
        ticketUuid,
        gateway,
      ];
}


class PaymentVerifying extends PaymentState {
  const PaymentVerifying();
}


class PaymentSuccess extends PaymentState {

  final List<Ticket> tickets;

  const PaymentSuccess(this.tickets);

  @override
  List<Object?> get props => [tickets];
}


class PaymentFailed extends PaymentState {

  final String message;

  const PaymentFailed(this.message);

  @override
  List<Object?> get props => [message];
}
