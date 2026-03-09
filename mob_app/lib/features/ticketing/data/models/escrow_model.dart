import '../../../../shared/models/enums.dart';
import '../../domain/entities/escrow.dart';


class EscrowModel extends Escrow {
  const EscrowModel({
    required super.uuid,
    required super.status,
    required super.totalAmount,
    required super.platformFee,
    required super.hostPayoutAmount,
    required super.ticketsCount,
    super.hostCompletedAt,
    super.adminApprovedAt,
    super.releasedAt,
    super.refundInitiatedAt,
    super.refundCompletedAt,
    required super.createdAt,
    super.happeningUuid,
    super.happeningTitle,
    super.happeningStartsAt,
    super.happeningAddress,
    super.hostUuid,
    super.hostName,
    super.events,
  });


  factory EscrowModel.fromJson(Map<String, dynamic> json) {

    final happening = json['happening'] as Map<String, dynamic>?;
    final host = json['host'] as Map<String, dynamic>?;


    final eventsJson = json['events'] as List<dynamic>?;
    final events = eventsJson
        ?.map((e) => EscrowEventModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return EscrowModel(
      uuid: json['uuid'] as String,
      status: EscrowStatus.fromString(json['status'] as String?) ??
          EscrowStatus.collecting,
      totalAmount: (json['total_amount'] as num).toDouble(),
      platformFee: (json['platform_fee'] as num).toDouble(),
      hostPayoutAmount: (json['host_payout_amount'] as num).toDouble(),
      ticketsCount: json['tickets_count'] as int? ?? 0,
      hostCompletedAt: _parseDateTime(json['host_completed_at']),
      adminApprovedAt: _parseDateTime(json['admin_approved_at']),
      releasedAt: _parseDateTime(json['released_at']),
      refundInitiatedAt: _parseDateTime(json['refund_initiated_at']),
      refundCompletedAt: _parseDateTime(json['refund_completed_at']),
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),


      happeningUuid: happening?['uuid'] as String?,
      happeningTitle: happening?['title'] as String?,
      happeningStartsAt: _parseDateTime(happening?['starts_at']),
      happeningAddress: happening?['address'] as String?,


      hostUuid: host?['uuid'] as String?,
      hostName: host?['name'] as String?,

      events: events,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'status': status.value,
      'total_amount': totalAmount,
      'platform_fee': platformFee,
      'host_payout_amount': hostPayoutAmount,
      'tickets_count': ticketsCount,
      'host_completed_at': hostCompletedAt?.toIso8601String(),
      'admin_approved_at': adminApprovedAt?.toIso8601String(),
      'released_at': releasedAt?.toIso8601String(),
      'refund_initiated_at': refundInitiatedAt?.toIso8601String(),
      'refund_completed_at': refundCompletedAt?.toIso8601String(),
      'happening': happeningUuid != null
          ? {
              'uuid': happeningUuid,
              'title': happeningTitle,
              'starts_at': happeningStartsAt?.toIso8601String(),
              'address': happeningAddress,
            }
          : null,
      'host': hostUuid != null
          ? {
              'uuid': hostUuid,
              'name': hostName,
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


class EscrowEventModel extends EscrowEvent {
  const EscrowEventModel({
    super.action,
    required super.performedByRole,
    super.performedByUuid,
    super.performedByName,
    super.metadata,
    required super.createdAt,
  });


  factory EscrowEventModel.fromJson(Map<String, dynamic> json) {
    final performer = json['performed_by'] as Map<String, dynamic>?;

    return EscrowEventModel(
      action: EscrowAction.fromString(json['action'] as String?),
      performedByRole: json['performed_by_role'] as String? ?? 'system',
      performedByUuid: performer?['uuid'] as String?,
      performedByName: performer?['name'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'action': action?.value,
      'performed_by_role': performedByRole,
      'performed_by': performedByUuid != null
          ? {
              'uuid': performedByUuid,
              'name': performedByName,
            }
          : null,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
