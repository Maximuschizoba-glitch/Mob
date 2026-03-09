import '../../../../shared/models/enums.dart';
import '../../domain/entities/ticket.dart';


class TicketModel extends Ticket {
  const TicketModel({
    required super.uuid,
    super.ticketNumber,
    super.paymentReference,
    required super.amount,
    required super.currency,
    required super.status,
    super.paymentGateway,
    super.paidAt,
    super.refundedAt,
    super.escrowStatus,
    super.escrowStatusMessage,
    required super.createdAt,
    super.happeningUuid,
    super.happeningTitle,
    super.happeningStartsAt,
    super.happeningAddress,
  });


  factory TicketModel.fromJson(Map<String, dynamic> json) {

    final happening = json['happening'] as Map<String, dynamic>?;

    return TicketModel(
      uuid: json['uuid'] as String,
      ticketNumber: json['ticket_number'] as String?,
      paymentReference: json['payment_reference'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'NGN',
      status: TicketStatus.fromString(json['status'] as String?) ??
          TicketStatus.pending,
      paymentGateway:
          PaymentGateway.fromString(json['payment_gateway'] as String?),
      paidAt: _parseDateTime(json['paid_at']),
      refundedAt: _parseDateTime(json['refunded_at']),
      escrowStatus:
          EscrowStatus.fromString(json['escrow_status'] as String?),
      escrowStatusMessage: json['escrow_status_message'] as String?,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),


      happeningUuid: happening?['uuid'] as String?,
      happeningTitle: happening?['title'] as String?,
      happeningStartsAt: _parseDateTime(happening?['starts_at']),
      happeningAddress: happening?['address'] as String?,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'ticket_number': ticketNumber,
      'payment_reference': paymentReference,
      'amount': amount,
      'currency': currency,
      'status': status.value,
      'payment_gateway': paymentGateway?.value,
      'paid_at': paidAt?.toIso8601String(),
      'refunded_at': refundedAt?.toIso8601String(),
      'escrow_status': escrowStatus?.value,
      'escrow_status_message': escrowStatusMessage,
      'happening': happeningUuid != null
          ? {
              'uuid': happeningUuid,
              'title': happeningTitle,
              'starts_at': happeningStartsAt?.toIso8601String(),
              'address': happeningAddress,
            }
          : null,
      'created_at': createdAt.toIso8601String(),
    };
  }


  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
