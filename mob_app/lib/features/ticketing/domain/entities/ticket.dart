import 'package:equatable/equatable.dart';

import '../../../../shared/models/enums.dart';


class Ticket extends Equatable {
  final String uuid;
  final String? ticketNumber;
  final String? paymentReference;
  final double amount;
  final String currency;
  final TicketStatus status;
  final PaymentGateway? paymentGateway;
  final DateTime? paidAt;
  final DateTime? refundedAt;
  final EscrowStatus? escrowStatus;
  final String? escrowStatusMessage;
  final DateTime createdAt;


  final String? happeningUuid;
  final String? happeningTitle;
  final DateTime? happeningStartsAt;
  final String? happeningAddress;

  const Ticket({
    required this.uuid,
    this.ticketNumber,
    this.paymentReference,
    required this.amount,
    required this.currency,
    required this.status,
    this.paymentGateway,
    this.paidAt,
    this.refundedAt,
    this.escrowStatus,
    this.escrowStatusMessage,
    required this.createdAt,
    this.happeningUuid,
    this.happeningTitle,
    this.happeningStartsAt,
    this.happeningAddress,
  });


  bool get isPaid => status == TicketStatus.paid;


  bool get isPending => status == TicketStatus.pending;


  bool get isRefundInProgress => status == TicketStatus.refundProcessing;


  bool get isRefunded => status == TicketStatus.refunded;


  String get formattedAmount => '\u20A6${amount.toStringAsFixed(0)}';


  String get displayLabel =>
      ticketNumber ?? '#${uuid.substring(0, 8).toUpperCase()}';

  @override
  List<Object?> get props => [
        uuid,
        ticketNumber,
        paymentReference,
        amount,
        currency,
        status,
        paymentGateway,
        paidAt,
        refundedAt,
        escrowStatus,
        escrowStatusMessage,
        createdAt,
        happeningUuid,
        happeningTitle,
        happeningStartsAt,
        happeningAddress,
      ];
}
