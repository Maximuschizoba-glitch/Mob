import 'package:flutter/foundation.dart';

import '../../../../shared/models/enums.dart';
import '../../domain/entities/happening.dart';


class HappeningModel extends Happening {
  const HappeningModel({
    required super.uuid,
    required super.title,
    super.description,
    required super.category,
    required super.type,
    required super.latitude,
    required super.longitude,
    super.radiusMeters,
    super.address,
    super.startsAt,
    super.endsAt,
    required super.isTicketed,
    super.ticketPrice,
    super.ticketQuantity,
    required super.ticketsSold,
    super.ticketsRemaining,
    required super.vibeScore,
    required super.activityLevel,
    required super.status,
    required super.expiresAt,
    super.timeRemaining,
    super.distanceKm,
    required super.snapsCount,
    required super.hasSnaps,
    super.coverImageUrl,
    super.hostUuid,
    super.hostName,
    super.hostAvatarUrl,
    super.hostIsVerified,
    super.hostType,
    super.createdAt,
    super.displayStatus,
    super.isActive,
    super.canBuyTickets,
    super.canAddSnaps,
  });


  factory HappeningModel.fromJson(Map<String, dynamic> json) {
    debugPrint(
      '[Mob/fromJson] "${json['title']}" '
      'raw starts_at=${json['starts_at']} '
      'raw expires_at=${json['expires_at']} '
      'status=${json['status']} '
      'display_status=${json['display_status']}',
    );


    final host = json['host'] as Map<String, dynamic>?;

    return HappeningModel(
      uuid: json['uuid'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category:
          HappeningCategory.fromString(json['category'] as String?) ??
              HappeningCategory.hangoutsSocial,
      type: HappeningType.fromString(json['type'] as String?) ??
          HappeningType.casual,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMeters: (json['radius_meters'] as num?)?.toDouble(),
      address: json['address'] as String?,
      startsAt: _parseDateTime(json['starts_at']),
      endsAt: _parseDateTime(json['ends_at']),
      isTicketed: json['is_ticketed'] as bool? ?? false,
      ticketPrice: (json['ticket_price'] as num?)?.toDouble(),
      ticketQuantity: json['ticket_quantity'] as int?,
      ticketsSold: json['tickets_sold'] as int? ?? 0,
      ticketsRemaining: json['tickets_remaining'] as int?,
      vibeScore: (json['vibe_score'] as num?)?.toDouble() ?? 0.0,
      activityLevel:
          ActivityLevel.fromString(json['activity_level'] as String?),
      status:
          HappeningStatus.fromString(json['status'] as String?) ??
              HappeningStatus.active,
      expiresAt:
          _parseDateTime(json['expires_at']) ?? DateTime.now(),
      timeRemaining: json['time_remaining'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      snapsCount: json['snaps_count'] as int? ?? 0,
      hasSnaps: json['has_snaps'] as bool? ?? false,
      coverImageUrl: json['cover_image_url'] as String?,


      hostUuid: host?['uuid'] as String?,
      hostName: host?['name'] as String?,
      hostAvatarUrl: host?['avatar_url'] as String?,
      hostIsVerified: host?['is_verified'] as bool? ?? false,
      hostType: host?['host_type'] as String?,

      createdAt: _parseDateTime(json['created_at']),


      displayStatus: json['display_status'] as String?,


      isActive: json['is_active'] as bool? ?? true,
      canBuyTickets: json['can_buy_tickets'] as bool? ?? false,
      canAddSnaps: json['can_add_snaps'] as bool? ?? true,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'title': title,
      'description': description,
      'category': category.value,
      'type': type.value,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radiusMeters,
      'address': address,
      'starts_at': startsAt?.toIso8601String(),
      'ends_at': endsAt?.toIso8601String(),
      'is_ticketed': isTicketed,
      'ticket_price': ticketPrice,
      'ticket_quantity': ticketQuantity,
      'tickets_sold': ticketsSold,
      'tickets_remaining': ticketsRemaining,
      'vibe_score': vibeScore,
      'activity_level': activityLevel.value,
      'status': status.value,
      'expires_at': expiresAt.toIso8601String(),
      'time_remaining': timeRemaining,
      'distance_km': distanceKm,
      'snaps_count': snapsCount,
      'has_snaps': hasSnaps,
      'cover_image_url': coverImageUrl,
      'host': hostUuid != null
          ? {
              'uuid': hostUuid,
              'name': hostName,
              'avatar_url': hostAvatarUrl,
              'is_verified': hostIsVerified,
              'host_type': hostType,
            }
          : null,
      'created_at': createdAt?.toIso8601String(),
      'display_status': displayStatus,
      'is_active': isActive,
      'can_buy_tickets': canBuyTickets,
      'can_add_snaps': canAddSnaps,
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
