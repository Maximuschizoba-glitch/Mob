import 'package:equatable/equatable.dart';

import '../../../../shared/models/enums.dart';


class Escrow extends Equatable {
  final String uuid;
  final EscrowStatus status;
  final double totalAmount;
  final double platformFee;
  final double hostPayoutAmount;
  final int ticketsCount;
  final DateTime? hostCompletedAt;
  final DateTime? adminApprovedAt;
  final DateTime? releasedAt;
  final DateTime? refundInitiatedAt;
  final DateTime? refundCompletedAt;
  final DateTime createdAt;


  final String? happeningUuid;
  final String? happeningTitle;
  final DateTime? happeningStartsAt;
  final String? happeningAddress;


  final String? hostUuid;
  final String? hostName;


  final List<EscrowEvent>? events;

  const Escrow({
    required this.uuid,
    required this.status,
    required this.totalAmount,
    required this.platformFee,
    required this.hostPayoutAmount,
    required this.ticketsCount,
    this.hostCompletedAt,
    this.adminApprovedAt,
    this.releasedAt,
    this.refundInitiatedAt,
    this.refundCompletedAt,
    required this.createdAt,
    this.happeningUuid,
    this.happeningTitle,
    this.happeningStartsAt,
    this.happeningAddress,
    this.hostUuid,
    this.hostName,
    this.events,
  });


  bool get canMarkComplete =>
      status == EscrowStatus.collecting || status == EscrowStatus.held;


  bool get isReleased => status == EscrowStatus.released;


  bool get isRefunding => status == EscrowStatus.refunding;


  String get formattedTotalAmount =>
      '\u20A6${totalAmount.toStringAsFixed(0)}';


  String get formattedHostPayout =>
      '\u20A6${hostPayoutAmount.toStringAsFixed(0)}';


  String get formattedPlatformFee =>
      '\u20A6${platformFee.toStringAsFixed(0)}';

  @override
  List<Object?> get props => [
        uuid,
        status,
        totalAmount,
        platformFee,
        hostPayoutAmount,
        ticketsCount,
        hostCompletedAt,
        adminApprovedAt,
        releasedAt,
        refundInitiatedAt,
        refundCompletedAt,
        createdAt,
        happeningUuid,
        happeningTitle,
        happeningStartsAt,
        happeningAddress,
        hostUuid,
        hostName,
        events,
      ];
}


class EscrowEvent extends Equatable {
  final EscrowAction? action;
  final String performedByRole;
  final String? performedByUuid;
  final String? performedByName;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const EscrowEvent({
    this.action,
    required this.performedByRole,
    this.performedByUuid,
    this.performedByName,
    this.metadata,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        action,
        performedByRole,
        performedByUuid,
        performedByName,
        metadata,
        createdAt,
      ];
}
