import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/enums.dart';


class Happening extends Equatable {
  final String uuid;
  final String title;
  final String? description;
  final HappeningCategory category;
  final HappeningType type;
  final double latitude;
  final double longitude;
  final double? radiusMeters;
  final String? address;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool isTicketed;
  final double? ticketPrice;
  final int? ticketQuantity;
  final int ticketsSold;
  final int? ticketsRemaining;
  final double vibeScore;
  final ActivityLevel activityLevel;
  final HappeningStatus status;
  final DateTime expiresAt;
  final String? timeRemaining;
  final double? distanceKm;
  final int snapsCount;
  final bool hasSnaps;
  final String? coverImageUrl;


  final String? hostUuid;
  final String? hostName;
  final String? hostAvatarUrl;
  final bool hostIsVerified;
  final String? hostType;

  final DateTime? createdAt;


  final String? displayStatus;


  final bool isActive;


  final bool canBuyTickets;


  final bool canAddSnaps;

  const Happening({
    required this.uuid,
    required this.title,
    this.description,
    required this.category,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.radiusMeters,
    this.address,
    this.startsAt,
    this.endsAt,
    required this.isTicketed,
    this.ticketPrice,
    this.ticketQuantity,
    required this.ticketsSold,
    this.ticketsRemaining,
    required this.vibeScore,
    required this.activityLevel,
    required this.status,
    required this.expiresAt,
    this.timeRemaining,
    this.distanceKm,
    required this.snapsCount,
    required this.hasSnaps,
    this.coverImageUrl,
    this.hostUuid,
    this.hostName,
    this.hostAvatarUrl,
    this.hostIsVerified = false,
    this.hostType,
    this.createdAt,
    this.displayStatus,
    this.isActive = true,
    this.canBuyTickets = false,
    this.canAddSnaps = true,
  });


  bool get isExpired =>
      displayStatus != null
          ? displayStatus == 'expired'
          : DateTime.now().isAfter(expiresAt);


  bool get isUpcoming =>
      displayStatus != null
          ? displayStatus == 'upcoming'
          : startsAt != null && startsAt!.isAfter(DateTime.now());


  bool get isLive =>
      displayStatus != null
          ? displayStatus == 'live'
          : !isExpired && !isUpcoming;


  bool get hasTicketsAvailable =>
      isTicketed &&
      (ticketQuantity == null || ticketsSold < ticketQuantity!);

  static final _priceFormat = NumberFormat('#,##0', 'en_US');


  String get formattedPrice {
    if (!isTicketed || ticketPrice == null) return 'Free';
    return '\u20A6${_priceFormat.format(ticketPrice!.toInt())}';
  }


  String? get formattedDistance {
    if (distanceKm == null) return null;
    if (distanceKm! < 1.0) {
      return '${(distanceKm! * 1000).round()} m';
    }
    return '${distanceKm!.toStringAsFixed(1)} km';
  }


  bool get isAreaBased => radiusMeters != null && radiusMeters! > 0;


  bool get isCasual => type == HappeningType.casual;


  bool get isEvent => type == HappeningType.event;

  @override
  List<Object?> get props => [
        uuid,
        title,
        description,
        category,
        type,
        latitude,
        longitude,
        radiusMeters,
        address,
        startsAt,
        endsAt,
        isTicketed,
        ticketPrice,
        ticketQuantity,
        ticketsSold,
        ticketsRemaining,
        vibeScore,
        activityLevel,
        status,
        expiresAt,
        timeRemaining,
        distanceKm,
        snapsCount,
        hasSnaps,
        coverImageUrl,
        hostUuid,
        hostName,
        hostAvatarUrl,
        hostIsVerified,
        hostType,
        createdAt,
        displayStatus,
        isActive,
        canBuyTickets,
        canAddSnaps,
      ];
}
